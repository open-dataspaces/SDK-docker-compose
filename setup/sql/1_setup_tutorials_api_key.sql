-- \prompt 'SET OpenFGA Store ID: ' pdp_store_id

-- Clean up existing tutorial data if any
DELETE FROM
    auth.tbl_cidrs
WHERE
    api_key = 'API-Key-Sample';

DELETE FROM
    auth.tbl_api_keys
WHERE
    id = 'API-Key-UUID-Sample';

DELETE FROM
    auth.tbl_authz_stores
WHERE
    pdp_store_id = :'pdp_store_id';

-- Setup tutorials for API-Key management
INSERT
INTO auth.tbl_api_keys(
    id
    , api_key
    , application_name
    , idp_realm
    , deleted_flag
    , effective_start_date
    , effective_end_date
    , created_at
    , created_user_id
    , updated_at
    , updated_user_id
)
VALUES (
    'API-Key-UUID-Sample'       -- API-KeyのID(UUID)を設定
    , 'API-Key-Sample'          -- API-Keyの文字列を設定
    , 'API-Key-Name-Sample'     -- API-Keyの名前を設定
    , 'master'                  -- KeycloakのRealmを設定
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'tutorial patch'
    , now()
    , 'tutorial patch'
);

-- Setup tutorials for CIDR management
INSERT
INTO auth.tbl_cidrs(
    cidr
    , api_key
    , deleted_flag
    , effective_start_date
    , effective_end_date
    , created_at
    , created_user_id
    , updated_at
    , updated_user_id
)
VALUES (
    '0.0.0.0/0'
    , 'API-Key-Sample'         -- 上記で設定したAPI-Keyの文字列を設定
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'tutorial patch'
    , now()
    , 'tutorial patch'
);

-- Setup tutorials for Authorization Store management
INSERT
INTO auth.tbl_authz_stores(
    pdp_store_id
    , pdp_store_name
    , environment_name
    , idp_realm
    , deleted_flag
    , effective_start_date
    , effective_end_date
    , created_at
    , created_user_id
    , updated_at
    , updated_user_id
)
VALUES (
    :'pdp_store_id'
    , 'ODS-Auth-Admin'
    , 'local'
    , 'master'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'tutorial patch'
    , now()
    , 'tutorial patch'
)