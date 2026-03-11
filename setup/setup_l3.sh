#!/bin/bash

## OpenFGA migration: run only on initial setup.
docker compose run --rm openfga migrate \
  --datastore-engine postgres \
  --datastore-uri 'postgres://openfga:password@postgres-openfga:5432/openfga?sslmode=disable'


## Database setup
# Copy the script file into the container
docker cp database/1_create_app_db.sql postgres:/tmp/1_create_app_db.sql
docker cp database/2_setup_app_db.sql postgres:/tmp/2_setup_app_db.sql

# Run the script
docker exec -it postgres bash -c "PGPASSWORD=password psql -U keycloak -d keycloak -f /tmp/1_create_app_db.sql -q"
docker exec -it postgres bash -c "PGPASSWORD=password psql -U app_ods -d db_ods -f /tmp/2_setup_app_db.sql -q"


## OpenFGA store setup
export API_ENDPOINT=http://localhost:8083

# Create a new store
echo "Creating Store..."
AUTHZ_STORE_ID="$(curl -sS -X POST \
  "$API_ENDPOINT/stores" \
  -H "Content-Type: application/json" \
  -d @openfga/1-create-store.json \
  | jq -r '.id'
)"
echo ""
echo "Create Store completed."
echo "AUTHZ_STORE_ID=$AUTHZ_STORE_ID"

# Create Model
echo "Creating Model..."
curl -i -X POST \
  $API_ENDPOINT/stores/$AUTHZ_STORE_ID/authorization-models \
  -H "Content-Type: application/json" \
  -d @openfga/2-create-model.json

echo ""
echo "Create Model completed."

# Create role tuples
echo "Creating role tuples..."
curl -i -X POST \
  $API_ENDPOINT/stores/$AUTHZ_STORE_ID/write \
  -H "Content-Type: application/json" \
  -d @openfga/3-create-tuples.json

echo ""
echo "Create role tuples completed."

# 1-1. Load tutorial data
# Copy the script file into the container
docker cp ./sql/1_setup_tutorials_api_key.sql postgres:/tmp/1_setup_tutorials_api_key.sql
# Run the script 
docker exec -it postgres bash -c "PGPASSWORD=password psql -U app_ods -d db_ods -v "pdp_store_id=${AUTHZ_STORE_ID}" -f /tmp/1_setup_tutorials_api_key.sql -q"

echo "get access token"
# 2.1 Get an access token
RESP="$(curl -sS -X POST "http://localhost:8082/realms/master/protocol/openid-connect/token" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "grant_type=password"  \
-d "client_id=admin-cli" \
-d "username=admin" \
-d "password=password"
)"
ACCESS_TOKEN="$(printf '%s' "$RESP" | jq -r '.access_token')"

echo "creat CLIENT_UUID"
# 2.2 Create a client ID for testing
SYSTEM_CLIENT_UUID="$(
  curl -sS -D - -o /dev/null -X POST "http://localhost:8082/admin/realms/master/clients" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
	    "clientId": "system-auth-sample",
	    "protocol": "openid-connect",
	    "name": "Tutorials System Auth ClientID",
	    "enabled": true,
	    "publicClient": false,
	    "serviceAccountsEnabled": true,
	    "standardFlowEnabled": false,
	    "directAccessGrantsEnabled": false,
	    "implicitFlowEnabled": false,
	    "attributes": {
	        "client_credentials.use_refresh_token": "false"
	    }
    }' \
  | awk '/^Location:/{
      sub("\r","");          # Strip CR (handle CRLF)
      url=$2;                # URL from the Location header
      n=split(url,a,"/");    # Split by '/'
      print a[n];            # Print the last element (UUID)
    }'
)"


# 2-3. Add a Hardcoded Claim mapper (Open System ID) to the test client
curl -sS -X POST "http://localhost:8082/admin/realms/master/clients/$SYSTEM_CLIENT_UUID/protocol-mappers/models" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
    "name": "open_system_id_mapper",
    "protocol": "openid-connect",
    "protocolMapper": "oidc-hardcoded-claim-mapper",
    "config": {
        "claim.name": "open_system_id",
        "claim.value": "open_system_id_sample",
        "jsonType.label": "String",
        "id.token.claim": "false",
        "access.token.claim": "true",
        "userinfo.token.claim": "false",
        "introspection.token.claim": "true"
    }
}'

echo "get SYSTEM_CLIENT_SECRET"
# 2-4. Get the client secret for the test client (client authentication)
RESP="$(curl -sS -X GET "http://localhost:8082/admin/realms/master/clients/$SYSTEM_CLIENT_UUID/client-secret" \
-H "Authorization: Bearer $ACCESS_TOKEN"
)"
SYSTEM_CLIENT_SECRET="$(printf '%s' "$RESP" | jq -r '.value')"

echo "create USER_CLIENT_UUID"
# 2-5. Create a test client ID for user authentication
USER_CLIENT_UUID="$(
	curl -i -X POST "http://localhost:8082/admin/realms/master/clients" \
	-H "Authorization: Bearer $ACCESS_TOKEN" \
	-H "Content-Type: application/json" \
	-d '{
	    "clientId": "user-auth-sample",
	    "protocol": "openid-connect",
	    "name": "Tutorials User Auth (Autorization frow and ROPC)",
	    "enabled": true,
	    "publicClient": false,
	    "standardFlowEnabled": true,
	    "implicitFlowEnabled": false,
	    "directAccessGrantsEnabled": true,
	    "serviceAccountsEnabled": false,
	    "redirectUris": [
	        "urn:ietf:wg:oauth:2.0:oob"
	    ],
	    "attributes": {
	        "pkce.code.challenge.method": "S256",
	        "oauth.pkce.required": "true"
	    }
	}' \
  | awk '/^Location:/{
      sub("\r","");          # Strip CR (handle CRLF)
      url=$2;                # URL from the Location header
      n=split(url,a,"/");    # Split by '/'
      print a[n];            # Print the last element (UUID)
    }'
)"

# 2-6. Add a User Property mapper (business entity identifier) to the test client
curl -i -X POST "http://localhost:8082/admin/realms/master/clients/$USER_CLIENT_UUID/protocol-mappers/models" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
    "name": "operator_id_mapper",
    "protocol": "openid-connect",
    "protocolMapper": "oidc-usermodel-property-mapper",
    "config": {
        "user.attribute": "id",
        "claim.name": "operator_id",
        "jsonType.label": "String",
        "id.token.claim": "false",
        "access.token.claim": "true",
        "userinfo.token.claim": "false",
        "introspection.token.claim": "true"
    }
}'

echo "get USER_CLIENT_SECRET"
# 2-7. Get the client secret for the test client used for end-user authentication
RESP="$(curl -sS -X GET "http://localhost:8082/admin/realms/master/clients/$USER_CLIENT_UUID/client-secret" \
-H "Authorization: Bearer $ACCESS_TOKEN"
)"
USER_CLIENT_SECRET="$(printf '%s' "$RESP" | jq -r '.value')"


## L3 l3-app Keycloak Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/l3/docker-compose.yml"

echo "updating l3 docker-compose.yml"
if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    # Update SYSTEM_CLIENT_SECRET
    esc_secret=$(printf '%s' "$SYSTEM_CLIENT_SECRET" | sed 's/[\/&]/\\&/g')
    sed -i \
        "s|^\([[:space:]]*KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET:[[:space:]]*\).*|\1$esc_secret|" \
        "$DOCKER_COMPOSE_FILE"
    echo "l3 docker-compose.yml updated"
else
    echo "Warning: docker-compose.yml not found at $DOCKER_COMPOSE_FILE"
fi
echo ""

echo "SYSTEM_CLIENT_UUID=${SYSTEM_CLIENT_UUID}"
echo "SYSTEM_CLIENT_SECRET=${SYSTEM_CLIENT_SECRET}"
echo "USER_CLIENT_UUID=${USER_CLIENT_UUID}"
echo "USER_CLIENT_SECRET=${USER_CLIENT_SECRET}"
