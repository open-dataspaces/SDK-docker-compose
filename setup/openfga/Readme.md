# ユーザ認証システム 認可モデル
## API実行権限管理モデル

### モデル定義
```
model
  schema 1.1

type user

type role
  relations
    define member: [user]

type api
  relations
    define allowed_get_roles: [role]
    define allowed_post_roles: [role]
    define GET: allowed_get_roles or member from allowed_get_roles
    define POST: allowed_post_roles or member from allowed_post_roles
```

### タプル定義(role-api)
| user(role) | relation | object(api) | 実行権限管理対象API |
| --- | --- | --- | --- |
| authz-models-admin | allowed_post_roles | /authz/stores/{store_id}/authorization-models | 認可モデル登録API |
| authz-models-admin | allowed_get_roles | /authz/stores/{store_id}/authorization-models | 認可モデル取得API |
| authz-tuples-admin | allowed_post_roles | /authz/stores/{store_id}/write | 認可タプル登録API |
| authz-tuples-admin | allowed_post_roles | /authz/stores/{store_id}/read | 認可タプル取得API |
| authz-user-admin | allowed_post_roles | /account/user | 個人ユーザ登録API |
```
{
  "writes": {
    "tuple_keys": [
      {
        "user": "role:authz-models-admin",
        "relation": "allowed_get_roles",
        "object": "api:/authz/stores/{store_id}/authorization-models"
      }
      ,{
        "user": "role:authz-models-admin",
        "relation": "allowed_post_roles",
        "object": "api:/authz/stores/{store_id}/authorization-models"
      }
      ,{
        "user": "role:authz-tuples-admin",
        "relation": "allowed_post_roles",
        "object": "api:/authz/stores/{store_id}/write"
      }
      ,{
        "user": "role:authz-tuples-admin",
        "relation": "allowed_post_roles",
        "object": "api:/authz/stores/{store_id}/read"
      }
      ,{
        "user": "role:authz-user-admin",
        "relation": "allowed_post_roles",
        "object": "api:/account/user"
      }
    ],
    "on_duplicate": "ignore"
  }
}
```

### タプル定義(user-role)
| user(user) | relation | object(role) | 実行権限管理対象API |
| --- | --- | --- | --- |
| 事業者識別子(内部) または オープンシステムID | member | authz-models-admin | 認可モデル登録API、認可モデル取得API |
| 事業者識別子(内部) または オープンシステムID | member | authz-tuples-admin | 認可タプル登録API、認可タプル取得API |
| 事業者識別子(内部) または オープンシステムID | member | authz-user-admin | 個人ユーザ登録API |

```
{
  "writes": {
    "tuple_keys": [
      {
        "user": "user:${AUTHZ_USER_ID}",
        "relation": "member",
        "object": "role:authz-models-admin"
      }
      ,{
        "user": "user:${AUTHZ_USER_ID}",
        "relation": "member",
        "object": "role:authz-tuples-admin"
      }
      ,{
        "user": "user:${AUTHZ_USER_ID}",
        "relation": "member",
        "object": "role:authz-user-admin"
      }
    ],
    "on_duplicate": "ignore"
  }
}
```