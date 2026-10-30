# ODS SDK for Onboarding Deployment Definition Files (for Docker Compose)

## Overview

This repository publishes deployment definition files for Docker Compose as one of the SDK for Onboarding provided by Open Dataspaces (hereinafter referred to as ODS).
By using these definition files, users can easily deploy the ODS components in their local environment and use it for development and operational verification.

## Prerequisites

The software published in this repository has been verified to operate in the following environment:

- Machine specifications: Core i7-1265U, 16 GiB memory, 500 GB SSD
- OS: Windows 11 + WSL2 (Ubuntu 24.04)
- Docker:
  - Client: 28.1.1-rd
  - Server: 27.3.1
  - Compose: 2.37.1

In addition, the following versions of ODS components are used.

* [Web API Transfer Module](https://github.com/open-dataspaces/L2-dp-webapi): [v1.0.0](https://github.com/open-dataspaces/L2-dp-webapi/tree/v1.0.0)
* [Identity Component](https://github.com/open-dataspaces/L3-identity-component): [v1.0.0](https://github.com/open-dataspaces/L3-identity-component/tree/v1.0.0)
* [Clearing and Billing/Payment Service](https://github.com/open-dataspaces/DCS-Payment): [v1.0.0](https://github.com/open-dataspaces/DCS-Payment/tree/v1.0.0)

## Repository Structure

The directory structure of this repository is as follows:

| File / Directory      | Description |
| --------------------- | ----------- |
| docker-compose.yml | Top-level deployment definition file that aggregates definitions for each component and allows them to be started and stopped collectively |
| l2 | Directory containing deployment definition files for the Web API Transfer Module, which is a component of L2 (Transaction Layer) |
| l3 | Directory containing deployment definition files for the Identity Component, which is a component of L3 (Identity Layer) |
| logging | Directory containing deployment definition files for the logging service |
| mockserver | Deployment definition files for the mock server used for verification and testing (corresponding to the Industry Service in the System Architecture diagram) |
| payment | Deployment definition files for the Clearing and Billing/Payment Service |
| setup | Collection of scripts to simplify and automate the setup procedure |

## Setup Procedure

### System Architecture Diagram

The components and services constructed by this SDK are shown below.  
Rectangles represent components or services, and arrows represent dependency relationships between them.

```mermaid
block
  columns 3

  block:a:1
  columns 1
  AuthN_DB["RDBMS for Authentication System"]
  space
  AuthN_SV["Authentication System"]
  end

  block:b:1
  columns 1
  AuthZ_DB["RDBMS for Authorization System"]
  space
  AuthZ_SV["ReBAC Authorization System"]
  end

  space

  block:d:2
    columns 1
    L3["L3: Identity Component"]
    space
    L2["L2: Web API Transfer Module"]
  end

  IS["Industry Service (Data Provider Side)"]

AuthN_SV -- "Stored data reference / update" --> AuthN_DB
AuthZ_SV -- "Stored data reference / update" --> AuthZ_DB
L3 -- "Authentication request" --> AuthN_SV
L3 -- "Authorization request"--> AuthZ_SV
L2 -- "Authentication token verification request"--> L3
L2 -- "Authorization request"--> AuthZ_SV
L2 -- "Request forwarding"--> IS
```

In this SDK, PostgreSQL is used as the RDBMS, Keycloak is used as the Authentication System,
and OpenFGA is used as the ReBAC Authorization System.

In the following sections, the Identity Component and the Web API Transfer Module
may be simply referred to as **L3** and **L2**, respectively.

Unless otherwise specified, all commands are assumed to be executed
from the root directory of this repository created by running `git clone`.

### Startup and Shutdown

The procedures for starting and stopping each component individually
are as follows.

#### L3: Identity Component

Startup

```
$ docker compose -f l3/docker-compose.yml up -d
```

Shutdown

```
$ docker compose -f l3/docker-compose.yml down
```

#### Logging Service

Startup

```
$ docker compose -f logging/docker-compose.yml up -d
```

Shutdown

```
$ docker compose -f logging/docker-compose.yml down
```

#### L2: Web API Transfer Module

Startup (L3 and the Logging Service must be started in advance)

```
$ docker compose -f l2/docker-compose.yml up -d
```

Shutdown

```
$ docker compose -f l2/docker-compose.yml down
```

#### Clearing and Billing/Payment Service

Startup (Requires L3 to be started in advance)

```
$ docker compose -f payment/docker-compose.yml up -d
```

Shutdown

```
$ docker compose -f payment/docker-compose.yml down
```

### Configuration for SSL Inspection Environments

When using this repository in an SSL inspection environment, file downloads may fail during the container image build process.
In such cases, place the certificate required to pass the SSL inspection in `cert-file/cert.cer`,
and uncomment the corresponding sections in the Dockerfile.

The following four files require these changes.

- l2/Dockerfile
- l3/Dockerfile-local
- logging/Dockerfile
- payment/Dockerfile

### Initial Setup of Each Component

The initial setup procedures for each component are described below.

First, copy the L2, L3, and Clearing and Payment services from their respective official repositories.

```
$ git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L2-dp-webapi.git
$ git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L3-identity-component.git
$ git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/DCS-Payment.git
```

Once all required files are in place, create a network shared by the service group,
and start all services using the `docker-compose.yml` file located at the top level of this repository.

```
$ docker network create shared-network-ods
$ docker compose up -d
```

When all services are running as shown below, the setup has been completed successfully

```
[+] Running 17/17
 ✔ gateway                      Built                                                            0.0s
 ✔ payment-app                  Built                                                            0.0s
 ✔ l3-app                       Built                                                            0.0s
 ✔ Volume "ods_pgdata"          Created                                                          0.0s
 ✔ Volume "ods_postgres_data"   Created                                                          0.0s
 ✔ Volume "ods_pgdata_openfga"  Created                                                          0.0s
 ✔ Container silo               Started                                                          1.0s
 ✔ Container postgres           Started                                                          1.1s
 ✔ Container fluentd            Started                                                          1.1s
 ✔ Container l3-app             Started                                                          1.0s
 ✔ Container payment-db         Healthy                                                         11.5s
 ✔ Container postgres-openfga   Started                                                          1.0s
 ✔ Container payment-app        Started                                                         12.0s
 ✔ Container keycloak           Started                                                          1.7s
 ✔ Container openfga            Started                                                          1.6s
 ✔ Container ods-silo-init-1    Started                                                          1.4s
 ✔ Container gateway            Started                                                          2.2s
```

From this state, perform the initial setup for each component.

#### L3: Identity Component

For L3, the initial setup described in [Service Startup](https://github.com/open-dataspaces/L3-identity-component/blob/main/README_en.md#1-service-startup) and the [Reference Implementation Tutorial](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md) is required.

This guide provides a script that performs the SDK-specific configuration for "[1-1. Loading Tutorial Data](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#1-1-loading-tutorial-data)" described in the Reference Implementation Tutorial. The execution procedure is as follows.

```
$ cd setup
$ bash setup_l3.sh
$ cd -
$ docker compose -f l3/docker-compose.yml up -d
```

This script creates and configures Keycloak realms, clients for API authorization, OpenFGA stores, authorization models and tuples, as well as system API keys.

If you need to change these settings, edit `setup/setup_l3.sh` before executing the script.

In addition, the business operator client IDs should be created as described later in "Data Configuration Required for Starting Operation".

Next, execute the following commands to create the OpenFGA store and authorization model,
and reflect their contents in the L2 deployment definition file (`l2/docker-compose.yml`).

```
$ cd setup
$ bash setup_l2.sh
$ cd -
```

The store name created in OpenFGA by the above procedure is `"ODS-USER-STORE"`.
If you need to change this value, edit `setup/openfga/5-create-user-store.json`.

#### L2: Web API Transfer Module

By completing the above steps, the settings required to start L2
have already been reflected in the deployment definition files,
so no additional configuration is required.

## Operational Setup

### Preparation

The access token validity period is set to 60 seconds by default.
If this duration is too short, it can be extended as needed.

The following example shows how to extend the validity period to 300 seconds.

```
$ ADMIN_ACCESS_TOKEN=$(
  curl -s -X POST "http://localhost:8082/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    -d "username=admin" \
    -d "password=password" | jq -r .access_token
)

$ curl -X PUT "http://localhost:8082/admin/realms/master" \
    -H "Authorization: Bearer ${ADMIN_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"accessTokenLifespan": 300}'
```

### Data Configuration Required for Starting Operation

Follow the procedures described in [Reference Implementation Tutorial 2-1. Creation of Authentication Information (Operator Information / Individual Users / Client IDs)](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#2-1-creation-of-authentication-information-operator-information--individual-users--client-ids) and complete the steps from business information registration through [2-1-5. Retrieving the Operator Client Secret](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#2-1-5-retrieving-the-operator-client-secret).

For this procedure, specify `localhost:8080` as the destination host, set `$SYSTEM_CLIENT_SECRET` to the value defined in `l3/docker-compose.yml` shown below, set `API-Key` to `API-Key-Sample`, and specify `system-auth-sample` as the `client_id`.

```
KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET
```

### Environment Configuration Between Components

To enable L2 to integrate with L3, set the URL of the authentication system (Keycloak)
in the following parameter in `l2/docker-compose.yml`.

In the `docker-compose.yml` file provided by this SDK, a value corresponding to the L3
configuration is already set.
If the URL of L3 is changed for any reason, update the parameter below accordingly.

```
KEYCLOAK_URL
```

### Industry Service Integration

The configuration required to integrate with an industry service on the data provider side
is described below.

In this procedure, an example is shown in which communication with a mock server,
prepared as a sample industry service, is permitted.

#### L3: Identity Component

##### Registering Tuples in the OpenFGA Store

Execute the following command to register authorization tuples for the industry service
in the OpenFGA store.

Specify the following values for the variables used in the command.

| Variable | Value |
|---|---|
| `$USER_STORE_ID` | The value configured for `FGA_STORE_ID` in `l2/docker-compose.yml` |

```
$ curl -i -X POST \
  http://localhost:8083/stores/$USER_STORE_ID/write \
  -H "Content-Type: application/json" \
  -d '{
  "writes": {
    "tuple_keys": [
      { "user": "group:endpoint-test-get#member",    "relation": "can_access", "object": "endpoint:test.get" },
      { "user": "group:endpoint-test-post#member",   "relation": "can_access", "object": "endpoint:test.post" },
      { "user": "group:endpoint-test-put#member",    "relation": "can_access", "object": "endpoint:test.put" },
      { "user": "group:endpoint-test-delete#member", "relation": "can_access", "object": "endpoint:test.delete" }
    ],
    "on_duplicate": "ignore"
  }
}'
```

Here, permission groups are created for each CRUD operation on the endpoints
exposed by the industry service.

For example, the first entry in `tuple_keys` means that users who are members of
the group `endpoint-test-get` have a relationship (`can_access`) that allows them
to access the target endpoint `test.get`.

The endpoint `test.get` specified in the object corresponds to the route defined
later in the L2 configuration, which represents the request forwarding destination
to the industry service.

Similarly, the second through fourth entries indicate that users who are members of
the groups `endpoint-test-post`, `endpoint-test-put`, and `endpoint-test-delete`
can access the endpoints `test.post`, `test.put`, and `test.delete`, respectively.

##### Granting Authorization to an Operator

Next, execute the following command to register the operator’s authorization
settings for the industry service in the store.

Specify the following values for the variables used in the command.

| Variable | Value |
|---|---|
| `$USER_STORE_ID` | The value configured for `FGA_STORE_ID` in `l2/docker-compose.yml` |
| `$USER_MODEL_ID` | The value configured for `FGA_MODEL_ID` in `l2/docker-compose.yml` |
| `$OPERATOR_ID` | The `operator_id` issued when registering the operator information

```
$ curl -i -X POST "http://localhost:8083/stores/$USER_STORE_ID/write" \
      -H "Content-Type: application/json" \
      -d '{
        "authorization_model_id": "'$USER_MODEL_ID'",
        "writes": {
          "tuple_keys": [
            {
              "user": "user:'$OPERATOR_ID'",
              "relation": "member",
              "object": "group:endpoint-test-post"
            }
          ]
        }
      }'
```

Here, the operator is added to a group that has permission to send POST requests
to the industry service.

When changing the permissions to be granted, replace the value of the `object`
property with the corresponding group and execute the command again.

Note that both the tuple registration to the OpenFGA store in the previous step
and this authorization configuration are performed by sending requests directly
to OpenFGA in L3.

If direct requests to OpenFGA are not possible, refer to
[L3 Reference Implementation Tutorial 2‑4. Using Authorization Functions](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#2-4-using-authorization-features)

#### L2: Web API Transfer Module

For L2, it is necessary to reflect information in `l2/docker-compose.yml`
(the OpenFGA store ID and authorization model ID), apply the changes,
and configure routing.

Regarding information reflection, if `setup/setup_l2.sh` has been executed
as part of the initial setup procedure, `l2/docker-compose.yml` is edited
automatically and no additional action is required.


If the OpenFGA store and authorization model were created without executing
`setup/setup_l2.sh`, specify the IDs of the created store and authorization model
in the following parameters in `l2/docker-compose.yml`.

```
FGA_STORE_ID=
FGA_MODEL_ID=
```

Restart L2 using the following command to apply the configuration changes.

```
$ docker compose -f l2/docker-compose.yml up -d
```

Next, configure a route to forward requests to the industry service.

In this example, a route configuration is shown that allows POST requests
only to a mock server. Execute the following command.

```
$ curl -X POST\
    -H "Content-Type: application/json"\
    -H "X-API-Key: your-secret-management-api-key"\
    -d '{
    "id": "route01",
    "uri": "http://mockoon:4011/test",
    "predicates": [{
        "name": "Path",
        "args": {
        "_genkey_0": "/test**"
         }
     },
      { 
        "name": "Method",
        "args": { 
        "_genkey_0": "POST"
         }
      }],
    "metadata": {
      "endpointId": "test.post"
     }    
    }'\
    http://localhost:8090/actuator/gateway/routes/route01
```


By executing the above command, requests sent by data consumers to
`http://(L2 FQDN)/test` are forwarded to the industry service URL
specified in the `uri` field (in this example, `http://mockoon:4011/test`).

The value `test.post` specified as `endpointId` in the metadata corresponds
to the endpoint `endpoint:test.post` that was registered as an object in OpenFGA.

As a result, users who belong to the OpenFGA group `group:endpoint-test-post`
are allowed to send POST requests to this URL.

When registering a route, it is also possible to modify the exposed path,
add or remove headers, and perform other customizations.

Refer to the example below and add any required settings to the request payload
shown above.

```
    "filters": [
    {
        "name": "RewritePath",
        "args": {
        "_genkey_0": "/externally-exposed-path/(?<segment>.*)",
        "_genkey_1": "/${segment}"
         }
    },
    {
        "name": "AddRequestHeader",
        "args": {
            "name": "Custom header name used by the industry service",
            "value": "Custom value"
        }
    },
    {
        "name": "RemoveRequestHeader",
        "args": {
        "name": "Header name not required by the industry service"
         }
    }],
```

#### Data Consumer

Data consumers must include the following HTTP headers in their requests.
The headers required to access the industry service are as follows.

| Header Name | Description |
| ---: | --- |
| API-Key | API key issued by this service |
| Authorization | Access token issued by L3 (Identity Component) (JWT format) |
| X-TrackingId | Log output field for traceability management (UUID format) |
| X-ODS-xxx | Fields subject to logging. Specify `xxx` with a string designated by the service provider (e.g., `X-ODS-UserId`) |

#### Data Provider

Data providers start the industry service corresponding to the configured routing settings.

In this procedure, a mock server is used as an example.
The startup command is as follows.

```
$ docker compose -f mockserver/docker-compose.yml up -d
```

Note that the mock server used here is intended to simulate an industry service.

Mock servers for ODS components such as L3 and the Clearing and Billing/Payment Service are provided separately in the [SDK-mock-server](https://github.com/open-dataspaces/SDK-mock-server) repository.

If you change the port used by this mock server, update both the `-p` startup option and the `ports` parameter in `mockserver/docker-compose.yml`. You must also update the route URL specified during the route registration procedure described earlier (for example, `http://mockoon:4011/test`).

### Data Exchange

The following procedure describes how to perform data exchange between
consumers and providers using the components deployed by the deployment
definition files in this repository, as well as the industry services
integrated with them.

1. Obtain an access token
   Execute the procedure described in [L3 Reference Implementation Tutorial 2‑2‑1. Access Token Acquisition (Client Authentication)](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#2-2-1-obtaining-an-access-token-operator-client-id-authentication) to obtain an access token.
   Specify `localhost:8080` as the destination host and set `API-Key` to `API-Key-Sample`.

2. Data access  
   Perform data access using the obtained access token.
   To send a POST request to the industry service configured in the
   route registration, execute the following command:

    ```
    $ curl -X POST "http://localhost:8090/test" \
      -H 'API-Key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H 'X-ODS-UserId: 112233' \
      -H "Content-Type: application/json" \
      -H "Prefer: return=representation" \
      -d '{"userid":112233}' | jq .
    ```

    A response similar to the following is returned from the `/test` endpoint.

    ```
    {
      "message": "Request successfully delivered!"
    }
    ```

### Clearing and Billing/Payment

The Clearing and Billing/Payment Service provides functions to calculate and present
payment and billing amounts for both consumers and providers based on the
usage fee models registered by data providers and the history of data exchanges
conducted between consumers and providers.

In addition, the service integrates with external services to perform actual
payment processing.
Transaction records are registered by both consumers and providers, and are
cross-checked with log information collected from the Web API Transfer Module
to ensure validity.

For details, refer to the [Clearing and Billing/Payment Service documentation](https://github.com/open-dataspaces/DCS-Payment).

#### Preparation

##### Building the Container Image for L2 Transaction Check

In this procedure, L2 logs are analyzed to verify that data exchange has actually been performed.

First, build the container image used for the L2 Transaction Check.
```
$ docker build \
    -t ods-payment-checkl2log:latest \
    -f payment/Dockerfile.checkl2log \
    .
```

Note that if SSL inspection configuration is required when building this image, follow the instructions described in "SSL Inspection Configuration" and uncomment the corresponding section in the Dockerfile.

Be sure to place the required certificate and update the Dockerfile settings before building the image.

##### Creating Business Operator Clients

The Clearing and Billing/Payment Service requires two business operator clients: one for the data provider and one for the data consumer.

Follow the procedures described in [Reference Implementation Tutorial 2-1. Creating Authentication Information (Business Information / Individual Users / Client IDs)] and complete the steps from business information registration through [2-1-5. Obtaining the Business Client Secret] to create business operator clients for both the data provider and the data consumer.

In the following procedures, the client IDs of the created data provider and data consumer will be referred to as `PROVIDER_ID` and `CONSUMER_ID`, respectively.

##### Authorization Configuration

To verify the operation of the Clearing and Billing/Payment Service, it is necessary to exchange data with the industry service through L2. Therefore, both L3 and L2 require authorization settings and route configuration.

This section provides an example of authorization control and route configuration.

##### Registering Tuples in the OpenFGA Store

Run the following command to register authorization tuples for the industry service in the OpenFGA store.

Specify the following values for the variables used in the command.

If you have already completed the "Registering Tuples in the OpenFGA Store" procedure described in the Production Deployment section of this SDK, you can skip this step.

| Variable | Value |
| -------- | ----- |
| `$USER_STORE_ID` | Value of `FGA_STORE_ID` in `l2/docker-compose.yml` |

```
$ curl -i -X POST http://localhost:8083/stores/$USER_STORE_ID/write \
  -H "Content-Type: application/json" \
  -d '{
  "writes": {
    "tuple_keys": [
      {
        "user": "group:endpoint-test-get#member",
        "relation": "can_access",
        "object": "endpoint:test.get"
      }
    ],
    "on_duplicate": "ignore"
  }
}'
```

##### Granting Authorization to Business Operators

Next, run the following command to register authorization settings for the business operators in the OpenFGA store so that they can access the industry service.

Specify the following values for the variables used in the command.

| Variable | Value |
| -------- | ----- |
| `$USER_STORE_ID` | Value of `FGA_STORE_ID` in `l2/docker-compose.yml` |
| `$USER_MODEL_ID` | Value of `FGA_MODEL_ID` in `l2/docker-compose.yml` |
| `$PROVIDER_ID` | `operator_id` of the data provider issued during the business operator client creation procedure described above |
| `$CONSUMER_ID` | `operator_id` of the data consumer issued during the business operator client creation procedure described above |
```
$ curl -i -X POST http://localhost:8083/stores/$USER_STORE_ID/write \
  -H "Content-Type: application/json" \
  -d '{
    "authorization_model_id": "'$USER_MODEL_ID'",
    "writes": {
      "tuple_keys": [
        { "user": "user:'$PROVIDER_ID'", "relation": "member", "object": "group:endpoint-test-get" },
        { "user": "user:'$CONSUMER_ID'", "relation": "member", "object": "group:endpoint-test-get" }
        ],
      "on_duplicate": "ignore"
    }
  }'
```

##### Configuring Data Access Routes

Referring to "Integration with Industry Services - L2: Web API Transfer Module", configure routes so that communication logs are recorded by L2.

In this example, only GET requests to the mock server are permitted.

Run the following command.

```
$ curl -X POST\
    -H "Content-Type: application/json"\
    -H "X-API-Key: your-secret-management-api-key"\
    -d '{
    "id": "route02",
    "uri": "http://mockoon:4011/test",
    "predicates": [{
        "name": "Path",
        "args": {
        "_genkey_0": "/test**"
         }
     },
      {
        "name": "Method",
        "args": {
        "_genkey_0": "GET"
         }
      }],
    "metadata": {
      "endpointId": "test.get"
     }
    }'\
    http://localhost:8090/actuator/gateway/routes/route02
```

#### Clearing and Payment Processing

1. Execute the database migration for the Clearing and Billing/Payment Service.

```
$ cd DCS-Payment
$ docker compose exec payment-app alembic -c migrations/alembic.ini upgrade head

...

INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 001_initial, Initial tables - 全テーブル統合版
$ cd -
```

2. Set the same value as `KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET`
   defined in `l3/docker-compose.yml` for the following parameter in
   `payment/docker-compose.yml`, and restart the Clearing and Billing/Payment Service
   to apply the change.

   For simplicity, the authorization feature of the Clearing and Billing/Payment Service
   is disabled in this example.
   In a production environment, configure the authorization feature appropriately
   by referring to the [Clearing and Billing/Payment Service documentation](https://github.com/open-dataspaces/DCS-Payment).

```
L3_CLIENT_SECRET
```

```
$ docker compose up payment-app -d
```

3. Register a dummy payment service for verification purposes in advance, along with the associated data provider and data consumer, in the database.
   Also, store the ID of the registered service in a variable for later use.

```
$ PAYMENT_SERVICE_ID=$(uuidgen -t)
$ docker exec -it payment-db psql fastapi_db -U postgres -c "INSERT INTO payment_services VALUES ('$PAYMENT_SERVICE_ID', 'test_service', 'http://example.com/')"
INSERT 0 1
$ docker exec -it payment-db psql fastapi_db -U postgres -c 'SELECT * FROM payment_services'
          payment_service_id          | payment_service_name | payment_service_url |          created_at           |          updated_at           
--------------------------------------+----------------------+---------------------+-------------------------------+-------------------------------
 a116525e-c94e-11f1-8000-5847ca798141 | test_service         | http://example.com/ | 2026-10-16 12:45:03.322807+00 | 2026-10-16 12:45:03.322807+00
(1 row)

$ PAYMENT_SERVICE_USER_ID=$(uuidgen -t)
$ docker exec -it payment-db psql fastapi_db -U postgres -c "INSERT INTO payment_service_user_registrations (payment_service_user_id, payment_service_id, consumer_id, provider_id) VALUES ('$PAYMENT_SERVICE_USER_ID', '$PAYMENT_SERVICE_ID', '$CONSUMER_ID', '$PROVIDER_ID')"
INSERT 0 1
$ docker exec -it payment-db psql fastapi_db -U postgres -c '\x' -c 'SELECT * FROM payment_service_user_registrations'
Expanded display is on.
-[ RECORD 1 ]-----------+-------------------------------------
payment_service_user_id | 7ea201bc-c950-11f1-8000-5847ca798141
payment_service_id      | a116525e-c94e-11f1-8000-5847ca798141
consumer_id             | dd6abc7c-9544-4d5e-b91e-ef4083180c35
provider_id             | 21e1e373-4f8e-427f-9659-573c47b036f5
company_name            | 
department              | 
customer_name           | 
zip_code                | 
address                 | 
tel_no                  | 
external_buyer_id       | 
external_data           | 
created_at              | 2026-10-16 12:58:26.025228+00
updated_at              | 2026-10-16 12:58:26.025228+00
```

4. Obtain an access token
   Execute [L3 Reference Implementation Tutorial 2-2-1. Obtaining an Access Token (Operator Client ID Authentication)](https://github.com/open-dataspaces/L3-identity-component/blob/main/docs/tutorials/tutorials_en.md#2-2-1-obtaining-an-access-token-operator-client-id-authentication) to obtain an access token.
   Specify `localhost:8080` as the destination host and set `API-Key` to `API-Key-Sample`.

   In the following procedures, the data provider's access token is referred to as `PROVIDER_ACCESS_TOKEN`, and the data consumer's access token is referred to as `CONSUMER_ACCESS_TOKEN`.

##### Registering a Usage Fee Model (Data Provider)

Send the following request to register a usage fee model
with the Clearing and Billing/Payment Service.

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROVIDER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "valid_from": "2026-07-01T00:00:00Z",
    "provider_id": "'"$PROVIDER_ID"'",
    "consumer_id": "'"$CONSUMER_ID"'",
    "data_id": "'"I0101"'",
    "payment_service_id": "'"$PAYMENT_SERVICE_ID"'",
    "fee_model_name": "Standard Pricing Model",
    "price": "1000.00",
    "tax_classification": "taxable",
    "tax_rate": "0.10",
    "is_active": true,
    "version": 1
  }' \
  localhost:8001/api/v1/fee-model
```

If the request is successful, a response similar to the following is returned.

```
{
  "created_at": "2026-10-16T13:05:02.430355Z",
  "updated_at": "2026-10-16T13:05:02.430355Z",
  "valid_from": "2026-07-01T00:00:00Z",
  "is_active": true,
  "version": 1,
  "storage_type": "provider_env",
  "storage_key": "",
  "valid_to": null,
  "provider_id": "21e1e373-4f8e-427f-9659-573c47b036f5",
  "consumer_id": "dd6abc7c-9544-4d5e-b91e-ef4083180c35",
  "data_id": "I0101",
  "payment_service_id": "a116525e-c94e-11f1-8000-5847ca798141",
  "fee_model_name": "Standard Pricing Model",
  "price": "1000.00",
  "tax_classification": "taxable",
  "tax_rate": "0.1000",
  "fee_model_id": "103a6ccf-532a-4d2b-988e-7fe9881c0abc"
}
```

##### Retrieving the Usage Fee Model List (Data Provider)

The registered usage fee models can be confirmed using the following request.

```
$ curl -s \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROVIDER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  localhost:8001/api/v1/fee-model
```

If the request is successful, a response similar to the following is returned.

```
{
  "models": [
    {
      "created_at": "2026-10-16T13:05:02.430355Z",
      "updated_at": "2026-10-16T13:05:02.430355Z",
      "valid_from": "2026-07-01T00:00:00Z",
      "is_active": true,
      "version": 1,
      "storage_type": "provider_env",
      "storage_key": "",
      "valid_to": null,
      "provider_id": "21e1e373-4f8e-427f-9659-573c47b036f5",
      "consumer_id": "dd6abc7c-9544-4d5e-b91e-ef4083180c35",
      "data_id": "I0101",
      "payment_service_id": "a116525e-c94e-11f1-8000-5847ca798141",
      "fee_model_name": "Standard Pricing Model",
      "price": "1000.00",
      "tax_classification": "taxable",
      "tax_rate": "0.1000",
      "fee_model_id": "103a6ccf-532a-4d2b-988e-7fe9881c0abc"
    }
  ]
}
```

##### Executing Data Exchange (Data Consumer)

Perform data exchange using the route configured during the prerequisite steps.

The Clearing and Billing/Payment Service identifies each data exchange using the value of the `X-TrackingId` header included in the request. In this example, a dummy value is used.

Because this ID is required in subsequent steps, save it as an environment variable.

Run the following command.

```
$ export TRACKING_ID=$(uuidgen -t)
$ curl -X GET "http://localhost:8090/test" \
  -H 'API-Key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
  -H "Authorization: Bearer $CONSUMER_ACCESS_TOKEN" \
  -H "X-TrackingId: $TRACKING_ID" \
  -H 'X-ODS-UserId: 112233' \
  -H "Prefer: return=representation"
```

If a response similar to the following is returned from the `/test` endpoint, the data exchange has completed successfully.

```
{
  "message": "Request successfully delivered!"
}
```

##### Registering Data Exchange Status (Data Consumer and Data Provider)

When a data exchange is completed, both the data consumer and the data provider
register the transaction record with the Clearing and Billing/Payment Service.

###### Data Provider Execution

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROVIDER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "tracking_id": "'"$TRACKING_ID"'",
    "provider_id": "'"$PROVIDER_ID"'",
    "consumer_id": "'"$CONSUMER_ID"'",
    "data_id_list": ["I0101"],
    "completed_at": "'$(date -Iseconds -u)'",
    "status": "completed"
  }' \
  localhost:8001/api/v1/data-exchange/status
```

If the registration is successful, the following response is returned.

```
{"status":"success","detail":"Data exchange status registered"}
```

###### Data Consumer Execution

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CONSUMER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "tracking_id": "'"$TRACKING_ID"'",
    "provider_id": "'"$PROVIDER_ID"'",
    "consumer_id": "'"$CONSUMER_ID"'",
    "data_id_list": ["I0101"],
    "completed_at": "'$(date -Iseconds -u)'",
    "status": "completed"
  }' \
  localhost:8001/api/v1/data-exchange/status
```

If the registration is successful, the following response is returned.

```
{"status":"success","detail":"Data exchange completed for tracking_id: cfa22276-c951-11f1-8000-5847ca798141"}
```

##### L2 Transaction Check

The Clearing and Billing/Payment Service verifies transaction consistency by retrieving L2 logs from an AWS S3 bucket.

In this SDK, L2 logs are stored in the Silo bucket every hour. To perform the verification immediately, restart Fluentd to force log rotation.

The procedure is as follows.

```
$ docker compose restart fluentd
```

In a production environment, the consistency check should be executed periodically using a scheduler such as cron.

This SDK provides an example of executing the L2 Transaction Check once against a Silo bucket that is compatible with Amazon S3.

For the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` used in the command, specify the same values as `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` defined in `logging/.env`, respectively.

```
$ docker run --rm \
  --network shared-network-ods \
  -e POSTGRES_HOST=payment-db \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=fastapi_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e S3_BUCKET=pj-a-sbx \
  -e S3_PREFIX=applogs/ \
  -e AWS_ACCESS_KEY_ID=minio-sample \
  -e AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
  -e AWS_DEFAULT_REGION=ap-northeast-1 \
  -e AWS_ENDPOINT_URL=http://silo:9000 \
  ods-payment-checkl2log:latest
```

Once the execution has completed, output similar to the following will be displayed.

```
2026-10-16T13:08:39+0000 [INFO] === CronJob 開始 ===
2026-10-16T13:08:39+0000 [INFO] 対象バケット: pj-a-sbx / プレフィックス: applogs/
2026-10-16T13:08:39+0000 [INFO] 対象日付: 2026-10-15, 2026-10-16 (JST)
2026-10-16T13:08:39+0000 [INFO] DB から tracking_id を取得中 (2026-10-15 〜 2026-10-16)
2026-10-16T13:08:39+0000 [INFO] DB から 1 件の tracking_id を取得
2026-10-16T13:08:39+0000 [DEBUG] DB 接続クローズ
2026-10-16T13:08:39+0000 [INFO] --- 日付: 20261015 の処理を開始 (prefix=applogs/20261015) ---
2026-10-16T13:08:39+0000 [DEBUG] list_objects_v2 呼び出し: {'Bucket': 'pj-a-sbx', 'Prefix': 'applogs/20261015'}
2026-10-16T13:08:39+0000 [DEBUG] list_objects_v2 レスポンス: KeyCount=0, IsTruncated=False
2026-10-16T13:08:39+0000 [DEBUG] 該当オブジェクトなし
2026-10-16T13:08:39+0000 [INFO] 日付 20261015 完了: 0 ファイル処理
2026-10-16T13:08:39+0000 [INFO] --- 日付: 20261016 の処理を開始 (prefix=applogs/20261016) ---
2026-10-16T13:08:39+0000 [DEBUG] list_objects_v2 呼び出し: {'Bucket': 'pj-a-sbx', 'Prefix': 'applogs/20261016'}
2026-10-16T13:08:39+0000 [DEBUG] list_objects_v2 レスポンス: KeyCount=2, IsTruncated=False
2026-10-16T13:08:39+0000 [INFO] [ファイル 1] 取得開始: applogs/20261016-12_0.gz (size=256030 bytes)
2026-10-16T13:08:39+0000 [INFO] [ファイル 1] 処理完了: applogs/20261016-12_0.gz (11209 行)
2026-10-16T13:08:39+0000 [INFO] [ファイル 2] 取得開始: applogs/20261016-13_0.gz (size=9187 bytes)
2026-10-16T13:08:39+0000 [INFO] [ファイル 2] 処理完了: applogs/20261016-13_0.gz (207 行)
2026-10-16T13:08:39+0000 [INFO] 日付 20261016 完了: 2 ファイル処理
2026-10-16T13:08:39+0000 [INFO] S3 ログ取得完了: 合計 2 ファイル / 11416 行
2026-10-16T13:08:39+0000 [INFO] === tracking_id 照合開始 (1 件) ===
2026-10-16T13:08:39+0000 [DEBUG] gatewayResponse 検出: trackingId=9b07808f-46bf-4859-bf69-eac990e598f3, statusCode=200
2026-10-16T13:08:39+0000 [DEBUG] gatewayResponse 検出: trackingId=cfa22276-c951-11f1-8000-5847ca798141, statusCode=200
2026-10-16T13:08:39+0000 [INFO] gatewayResponse パース完了: 2 件の trackingId → statusCode マッピングを取得
2026-10-16T13:08:39+0000 [INFO] 照合結果: ログに存在=1 件, 存在しない=0 件
2026-10-16T13:08:39+0000 [INFO]   statusCode=200: 1 件
2026-10-16T13:08:39+0000 [INFO] 全ての tracking_id がログに存在します
2026-10-16T13:08:40+0000 [INFO] l2_http_status='200' に更新: 1 件 (tracking_id 1 件)
2026-10-16T13:08:40+0000 [INFO] l2_http_status の更新完了
2026-10-16T13:08:40+0000 [DEBUG] DB 接続クローズ
2026-10-16T13:08:40+0000 [INFO]   tracking_id 総数: 1
2026-10-16T13:08:40+0000 [INFO]   ログに存在:       1
2026-10-16T13:08:40+0000 [INFO]   ログに未検出:     0
2026-10-16T13:08:40+0000 [INFO] === settlement_status 更新処理 開始 ===
2026-10-16T13:08:40+0000 [INFO] settlement_status を 'settled' に更新: 1 件
2026-10-16T13:08:40+0000 [INFO] settlement_status の更新完了
2026-10-16T13:08:40+0000 [DEBUG] DB 接続クローズ
2026-10-16T13:08:40+0000 [INFO] === 請求確定/キャンセル処理 開始 ===
2026-10-16T13:08:40+0000 [INFO] === transactionレコード ステータス一覧 (最新50件) ===
2026-10-16T13:08:40+0000 [INFO] 請求確定依頼対象: なし
2026-10-16T13:08:40+0000 [INFO] 取引キャンセル対象（L2ステータス異常）: なし
2026-10-16T13:08:40+0000 [DEBUG] DB 接続クローズ
2026-10-16T13:08:40+0000 [INFO] tracking_id=NULL の未完了レコードを取得中
2026-10-16T13:08:40+0000 [INFO] tracking_id=NULL の未完了レコード: 0 件
2026-10-16T13:08:40+0000 [DEBUG] DB 接続クローズ
2026-10-16T13:08:40+0000 [INFO] 取引キャンセル対象（24時間経過・未完了）: なし
2026-10-16T13:08:40+0000 [INFO] === 請求確定/キャンセル処理 完了 ===
```

L2 Transaction Check verifies settlement and payment consistency by examining the `textPayload` field of each stored log record and extracting the `trackingId` and `statusCode` values contained in the `gatewayResponse`.

On the other hand, L2 log messages themselves do not contain a `textPayload` field. When they are converted into log records through Docker and Fluentd, they are stored in the `log` field by default, and therefore no `textPayload` field is added automatically.

In this SDK, Fluentd is configured to duplicate the `log` field as `textPayload` and store it in the Silo bucket for later processing.

##### Retrieving Estimated Payment Amount (Data Consumer)

Data consumers can check the estimated payment amount for the current day by sending the following request.

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CONSUMER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "provider_id": "'"$PROVIDER_ID"'",
    "start_date": "'$(date -I)'",
    "end_date": "'$(date -I -d'+1 day')'"
  }' \
  localhost:8001/api/v1/payment
```

If the request is successful, a response similar to the following is returned.

```
{
  "payment_details": [
    {
      "tracking_id": "cfa22276-c951-11f1-8000-5847ca798141",
      "fee_model_id": "103a6ccf-532a-4d2b-988e-7fe9881c0abc",
      "payment_service_id": "a116525e-c94e-11f1-8000-5847ca798141",
      "provider_id": "21e1e373-4f8e-427f-9659-573c47b036f5",
      "consumer_id": "dd6abc7c-9544-4d5e-b91e-ef4083180c35",
      "data_id_list": ["I0101"],
      "completed_at": "2026-10-16T13:07:58Z",
      "amount": 1100.0,
      "tax_rate": 0.1
    }
  ],
  "total_amount": 1100.0
}
```

##### Retrieving Today's Estimated Billing Amount (Data Provider)

Data providers can retrieve the estimated billing amount for the current day by sending the following request.

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROVIDER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "consumer_id": "'"$CONSUMER_ID"'",
    "start_date": "'$(date -I)'",
    "end_date": "'$(date -I -d'+1 day')'"
  }' \
  localhost:8001/api/v1/billing
```

If the request is successful, a response similar to the following is returned.

```
{
  "billing_details": [
    {
      "tracking_id": "cfa22276-c951-11f1-8000-5847ca798141",
      "fee_model_id": "103a6ccf-532a-4d2b-988e-7fe9881c0abc",
      "payment_service_id": "a116525e-c94e-11f1-8000-5847ca798141",
      "provider_id": "21e1e373-4f8e-427f-9659-573c47b036f5",
      "consumer_id": "dd6abc7c-9544-4d5e-b91e-ef4083180c35",
      "data_id_list": ["I0101"],
      "completed_at": "2026-10-16T13:07:58Z",
      "amount": 1100.0,
      "tax_rate": 0.1
    }
  ],
  "total_amount": 1100.0
}
```

##### Retrieving Payment Status (Data Provider)

Data providers can retrieve the current payment status by sending the following request.

```
$ curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PROVIDER_ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -H "Accept-Language: ja-JP" \
  -H "User-Agent: payment-test" \
  -d '{
    "consumer_id":"'"$CONSUMER_ID"'",
    "start_date":"'$(date -I)'",
    "end_date":"'$(date -I -d'+1 day')'",
    "settlement_status":"settled"
  }' \
  localhost:8001/api/v1/data-exchange/settlement/transactions
```

If the request is successful, a response similar to the following is returned.

```
{
  "transactions": [
    {
      "transaction_id": "26b70fbd-2b54-4e6d-aa95-afebac588d90",
      "tracking_id": "cfa22276-c951-11f1-8000-5847ca798141",
      "external_transaction_id": null,
      "provider_id": "21e1e373-4f8e-427f-9659-573c47b036f5",
      "consumer_id": "dd6abc7c-9544-4d5e-b91e-ef4083180c35",
      "data_id": "I0101",
      "snapshot_price": "1000.00",
      "snapshot_tax_rate": "0.1000",
      "snapshot_tax_classification": "taxable",
      "calculated_amount": "1100.00",
      "consumer_exchange_status": "completed",
      "provider_exchange_status": "completed",
      "l2_http_status": "200",
      "order_details": null,
      "request_date": null,
      "payment_deadline": null,
      "paid_at": null,
      "created_at": "2026-10-16T13:07:58Z",
      "updated_at": "2026-10-16T13:08:40.014402Z"
    }
  ],
  "total_count": 1
}
```

### Monitoring

The types of logs output by each component and service are as follows.

#### L2: Web API Transfer Module

Logs output by L2 are stored in object storage by the logging service.

The default output destination is shown below.
To change this location, edit `logging/docker-compose.yml`.

| Output Path | Description |
| ------------------ | ----------- |
| data/pj-a-sbx/applogs | Log files are rotated on an hourly basis |

These logs can be viewed not only by directly accessing the storage location, but also through a web browser by accessing the Silo console.

Access `http://localhost:9001/login` and enter the username and password.

![Login Screen](images/MinIO_login.png)

- Username: minio-sample
- Password: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
These user names and passwords can be changed by editing `logging/.env`.

After a successful login, you can view the stored logs.
The directory structure follows the storage hierarchy and is `pj-a-sbx/applogs`.

![Log Storage Location2](images/MinIO_pj-a-sbx_applogs.png)

Since log files are stored under the `applogs` directory, you can download and
extract them to review their contents.

![Log File List](images/MinIO_logfiles.png)

Note that these logs are also used by the Clearing and Billing/Payment Service. Therefore, the value of `record["log"]` is duplicated and stored as `record["textPayload"]`.

#### L3: Identity Component

L3 outputs logs to standard output and standard error.
When running in a container, logs can be checked using the following command.

```
$ docker logs l3-app
```

#### Clearing and Billing/Payment Service

The Clearing and Billing/Payment Service outputs logs to standard output and standard error.
When running in a container, logs can be checked using the following command.

```
$ docker logs payment-app
```

## License

- This repository is provided under the MIT License.
- The copyright of the source code and related documentation belongs to NTT DATA Group Corporation and NTT DATA Corporation.

## Disclaimer

- The contents of this repository may be changed or removed without prior notice.
- No responsibility is assumed for any losses or damages arising from the use of this repository.
