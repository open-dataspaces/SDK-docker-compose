-- Clean up existing data if any
DELETE FROM
    auth.tbl_cidrs
WHERE
    api_key = :'api_key';

DELETE FROM
    auth.tbl_api_keys
WHERE
    id = :'api_key_id';

DELETE FROM
    auth.tbl_authz_stores
WHERE
    idp_realm = :'idp_realm';

DELETE FROM
    auth.tbl_authz_uc_stores
WHERE
    usecase = :'usecase';

-- Setup tutorials for API-Key management
INSERT
INTO auth.tbl_api_keys(
    id
    , api_key
    , application_name
    , idp_realm
    , usecase
    , deleted_flag
    , effective_start_date
    , effective_end_date
    , created_at
    , created_user_id
    , updated_at
    , updated_user_id
)
VALUES (
    :'api_key_id'
    , :'api_key'
    , :'api_key_name'
    , :'idp_realm'
    , :'usecase'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'setup script'
    , now()
    , 'setup script'
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
    :'cidr'
    , :'api_key'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'setup script'
    , now()
    , 'setup script'
);

-- Setup tutorials for Authorization Store management
INSERT
INTO auth.tbl_authz_stores(
    pdp_store_id
    , pdp_store_name
    , pdp_store_purpose
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
    :'pdp_store_id_api_authz'
    , 'API_EXECUTION-' || :'idp_realm' || '-' || :'environment_name' || ' Store'
    , 'API_EXECUTION'
    , :'environment_name'
    , :'idp_realm'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'setup script'
    , now()
    , 'setup script'
),
(
    :'pdp_store_id_realm_store_binding'
    , 'REALM_STORE_BINDING-' || :'idp_realm' || '-' || :'environment_name' || ' Store'
    , 'REALM_STORE_BINDING'
    , :'environment_name'
    , :'idp_realm'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'setup script'
    , now()
    , 'setup script'
);

-- Setup tutorials for Authorization Usecase Store management
INSERT 
INTO auth.tbl_authz_uc_stores( 
    uc_store_id
    , uc_store_name
    , usecase
    , deleted_flag
    , effective_start_date
    , effective_end_date
    , created_at
    , created_user_id
    , updated_at
    , updated_user_id
) 
VALUES ( 
    :'pdp_store_id_operator_plant_authz'
    , :'usecase' || ' Store'
    , :'usecase'
    , false
    , '2000-01-01'
    , '9999-12-31'
    , now()
    , 'setup script'
    , now()
    , 'setup script'
);
