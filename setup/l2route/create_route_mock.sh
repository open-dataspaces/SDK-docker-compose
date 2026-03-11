curl -X POST \
     -H "Content-Type: application/json" \
     -H "X-API-KEY: your-secret-management-api-key" \
     -d '{
       "id": "route00",
       "uri": "http://mockoon:4011/test",
       "predicates": [{
         "name": "Path",
         "args": {
           "_genkey_0": "/test**"
         }
       }]
     }' \
     http://localhost:8090/actuator/gateway/routes/route00
