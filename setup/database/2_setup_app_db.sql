-- command
-- psql -h ::1 -p 5433 -U app_ods -d db_ods -f 2_setup_app_db.sql


--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: app_ods
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO app_ods;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_api_keys; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_api_keys (
    id character varying(256) NOT NULL,
    api_key character varying(256) NOT NULL,
    application_name character varying(256),
    idp_realm character varying(256) NOT NULL,
    deleted_flag boolean NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    created_at timestamp without time zone,
    created_user_id text,
    updated_at timestamp without time zone,
    updated_user_id text
);


ALTER TABLE auth.tbl_api_keys OWNER TO app_ods;

--
-- Name: TABLE tbl_api_keys; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_api_keys IS 'API-Keyテーブル';


--
-- Name: COLUMN tbl_api_keys.id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.id IS 'APIキー識別子';


--
-- Name: COLUMN tbl_api_keys.api_key; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.api_key IS 'APIキー';


--
-- Name: COLUMN tbl_api_keys.application_name; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.application_name IS 'アプリケーション名';


--
-- Name: COLUMN tbl_api_keys.idp_realm; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.idp_realm IS 'レルム';


--
-- Name: COLUMN tbl_api_keys.deleted_flag; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.deleted_flag IS '論理削除フラグ';


--
-- Name: COLUMN tbl_api_keys.effective_start_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.effective_start_date IS '有効開始日';


--
-- Name: COLUMN tbl_api_keys.effective_end_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.effective_end_date IS '有効終了日';


--
-- Name: COLUMN tbl_api_keys.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.created_at IS '作成日時';


--
-- Name: COLUMN tbl_api_keys.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.created_user_id IS '作成ユーザ';


--
-- Name: COLUMN tbl_api_keys.updated_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.updated_at IS '更新日時';


--
-- Name: COLUMN tbl_api_keys.updated_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_api_keys.updated_user_id IS '更新ユーザ';


--
-- Name: tbl_authz_stores; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_authz_stores (
    pdp_store_id character varying(256) NOT NULL,
    pdp_store_name character varying(256) NOT NULL,
    environment_name character varying(256) NOT NULL,
    idp_realm character varying(256) NOT NULL,
    deleted_flag boolean NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    created_at timestamp(6) without time zone,
    created_user_id text,
    updated_at timestamp(6) without time zone,
    updated_user_id text
);


ALTER TABLE auth.tbl_authz_stores OWNER TO app_ods;

--
-- Name: TABLE tbl_authz_stores; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_authz_stores IS '認可ストア管理テーブル';


--
-- Name: COLUMN tbl_authz_stores.pdp_store_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.pdp_store_id IS 'ストアID';


--
-- Name: COLUMN tbl_authz_stores.pdp_store_name; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.pdp_store_name IS 'ストア名';


--
-- Name: COLUMN tbl_authz_stores.environment_name; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.environment_name IS '環境名';


--
-- Name: COLUMN tbl_authz_stores.idp_realm; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.idp_realm IS 'レルム';


--
-- Name: COLUMN tbl_authz_stores.deleted_flag; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.deleted_flag IS '論理削除フラグ';


--
-- Name: COLUMN tbl_authz_stores.effective_start_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.effective_start_date IS '有効開始日';


--
-- Name: COLUMN tbl_authz_stores.effective_end_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.effective_end_date IS '有効終了日';


--
-- Name: COLUMN tbl_authz_stores.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.created_at IS '作成日時';


--
-- Name: COLUMN tbl_authz_stores.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.created_user_id IS '作成ユーザ';


--
-- Name: COLUMN tbl_authz_stores.updated_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.updated_at IS '更新日時';


--
-- Name: COLUMN tbl_authz_stores.updated_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_authz_stores.updated_user_id IS '更新ユーザ';


--
-- Name: tbl_cidrs; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_cidrs (
    cidr character varying(18) NOT NULL,
    api_key character varying(256) NOT NULL,
    deleted_flag boolean NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    created_at timestamp without time zone,
    created_user_id text,
    updated_at timestamp without time zone,
    updated_user_id text
);


ALTER TABLE auth.tbl_cidrs OWNER TO app_ods;

--
-- Name: TABLE tbl_cidrs; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_cidrs IS 'CIDRテーブル';


--
-- Name: COLUMN tbl_cidrs.cidr; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.cidr IS 'CIDR';


--
-- Name: COLUMN tbl_cidrs.api_key; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.api_key IS 'APIキー';


--
-- Name: COLUMN tbl_cidrs.deleted_flag; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.deleted_flag IS '論理削除フラグ';


--
-- Name: COLUMN tbl_cidrs.effective_start_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.effective_start_date IS '有効開始日';


--
-- Name: COLUMN tbl_cidrs.effective_end_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.effective_end_date IS '有効終了日';


--
-- Name: COLUMN tbl_cidrs.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.created_at IS '作成日時';


--
-- Name: COLUMN tbl_cidrs.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.created_user_id IS '作成ユーザ';


--
-- Name: COLUMN tbl_cidrs.updated_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.updated_at IS '更新日時';


--
-- Name: COLUMN tbl_cidrs.updated_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_cidrs.updated_user_id IS '更新ユーザ';


--
-- Name: tbl_operators; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_operators (
    operator_id character varying(256) NOT NULL,
    operator_name character varying(256),
    operator_address character varying(256),
    open_operator_id character varying(20),
    global_operator_id character varying(256),
    deleted_flag boolean NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    created_at timestamp without time zone,
    created_user_id text,
    updated_at timestamp without time zone,
    updated_user_id text
);


ALTER TABLE auth.tbl_operators OWNER TO app_ods;

--
-- Name: TABLE tbl_operators; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_operators IS '事業者情報テーブル';


--
-- Name: COLUMN tbl_operators.operator_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.operator_id IS '事業者識別子（内部）';


--
-- Name: COLUMN tbl_operators.operator_name; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.operator_name IS '事業者名';


--
-- Name: COLUMN tbl_operators.operator_address; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.operator_address IS '事業者所在地';


--
-- Name: COLUMN tbl_operators.open_operator_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.open_operator_id IS '事業者識別子（ローカル）';


--
-- Name: COLUMN tbl_operators.global_operator_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.global_operator_id IS '事業者識別子（グローバル）';


--
-- Name: COLUMN tbl_operators.deleted_flag; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.deleted_flag IS '論理削除フラグ';


--
-- Name: COLUMN tbl_operators.effective_start_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.effective_start_date IS '有効開始日';


--
-- Name: COLUMN tbl_operators.effective_end_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.effective_end_date IS '有効終了日';


--
-- Name: COLUMN tbl_operators.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.created_at IS '作成日時';


--
-- Name: COLUMN tbl_operators.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.created_user_id IS '作成ユーザ';


--
-- Name: COLUMN tbl_operators.updated_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.updated_at IS '更新日時';


--
-- Name: COLUMN tbl_operators.updated_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_operators.updated_user_id IS '更新ユーザ';


--
-- Name: tbl_plants; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_plants (
    plant_id character varying(256) NOT NULL,
    operator_id character varying(256) NOT NULL,
    plant_name character varying(256),
    plant_address character varying(256),
    open_plant_id character varying(26),
    global_plant_id character varying(256),
    deleted_flag boolean NOT NULL,
    effective_start_date date NOT NULL,
    effective_end_date date NOT NULL,
    created_at timestamp without time zone,
    created_user_id text,
    updated_at timestamp without time zone,
    updated_user_id text
);


ALTER TABLE auth.tbl_plants OWNER TO app_ods;

--
-- Name: TABLE tbl_plants; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_plants IS '属性（事業所）テーブル';


--
-- Name: COLUMN tbl_plants.plant_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.plant_id IS '事業所識別子（内部）';


--
-- Name: COLUMN tbl_plants.operator_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.operator_id IS '事業者識別子（内部）';


--
-- Name: COLUMN tbl_plants.plant_name; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.plant_name IS '事業所名';


--
-- Name: COLUMN tbl_plants.plant_address; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.plant_address IS '事業所所在地';


--
-- Name: COLUMN tbl_plants.open_plant_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.open_plant_id IS '事業所識別子（ローカル）';


--
-- Name: COLUMN tbl_plants.global_plant_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.global_plant_id IS '事業所識別子（グローバル）';


--
-- Name: COLUMN tbl_plants.deleted_flag; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.deleted_flag IS '論理削除フラグ';


--
-- Name: COLUMN tbl_plants.effective_start_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.effective_start_date IS '有効開始日';


--
-- Name: COLUMN tbl_plants.effective_end_date; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.effective_end_date IS '有効終了日';


--
-- Name: COLUMN tbl_plants.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.created_at IS '作成日時';


--
-- Name: COLUMN tbl_plants.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.created_user_id IS '作成ユーザ';


--
-- Name: COLUMN tbl_plants.updated_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.updated_at IS '更新日時';


--
-- Name: COLUMN tbl_plants.updated_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_plants.updated_user_id IS '更新ユーザ';


--
-- Name: tbl_api_keys pk_tbl_api_keys; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_api_keys
    ADD CONSTRAINT pk_tbl_api_keys PRIMARY KEY (id);


--
-- Name: tbl_authz_stores tbl_authz_stores_pkey; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_authz_stores
    ADD CONSTRAINT tbl_authz_stores_pkey PRIMARY KEY (pdp_store_id);


--
-- Name: tbl_cidrs tbl_cidrs_pkey; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_cidrs
    ADD CONSTRAINT tbl_cidrs_pkey PRIMARY KEY (cidr, api_key);


--
-- Name: tbl_operators tbl_operators_pkey; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_operators
    ADD CONSTRAINT tbl_operators_pkey PRIMARY KEY (operator_id);


--
-- Name: tbl_plants tbl_plants_pkey; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_plants
    ADD CONSTRAINT tbl_plants_pkey PRIMARY KEY (plant_id);


--
-- Name: tbl_api_keys uk_tbl_api_keys_api_key; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_api_keys
    ADD CONSTRAINT uk_tbl_api_keys_api_key UNIQUE (api_key);


--
-- Name: tbl_authz_stores uk_tbl_authz_stores_idp_realm_and_environment_name; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_authz_stores
    ADD CONSTRAINT uk_tbl_authz_stores_idp_realm_and_environment_name UNIQUE (environment_name, idp_realm);


--
-- Name: tbl_cidrs fk_tbl_cidrs_api_key; Type: FK CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_cidrs
    ADD CONSTRAINT fk_tbl_cidrs_api_key FOREIGN KEY (api_key) REFERENCES auth.tbl_api_keys(api_key);


--
-- Name: tbl_plants fk_tbl_plants_operator_id; Type: FK CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_plants
    ADD CONSTRAINT fk_tbl_plants_operator_id FOREIGN KEY (operator_id) REFERENCES auth.tbl_operators(operator_id);


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: app_ods
--

GRANT USAGE ON SCHEMA auth TO app_ods;


--
-- Name: TABLE tbl_api_keys; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_api_keys TO app_ods;


--
-- Name: TABLE tbl_cidrs; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_cidrs TO app_ods;


--
-- Name: TABLE tbl_operators; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_operators TO app_ods;


--
-- Name: TABLE tbl_plants; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_plants TO app_ods;

--
-- Name: TABLE tbl_plants; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_authz_stores TO app_ods;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: app_ods
--

ALTER DEFAULT PRIVILEGES FOR ROLE app_ods IN SCHEMA auth GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_ods;


--
-- Name: tbl_client_secrets; Type: TABLE; Schema: auth; Owner: app_ods
--

CREATE TABLE auth.tbl_client_secrets (
    client_uuid character varying(256) NOT NULL,
    api_key character varying(256) NOT NULL,
    created_at  timestamp without time zone,
    created_user_id text
);

ALTER TABLE auth.tbl_client_secrets OWNER TO app_ods;

--
-- Name: TABLE tbl_client_secrets; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON TABLE auth.tbl_client_secrets IS 'クライアントシークレット取得管理用テーブル';

--
-- Name: COLUMN tbl_client_secrets.client_uuid; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_client_secrets.client_uuid IS 'クライアントUUID';

--
-- Name: COLUMN tbl_client_secrets.api_key; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_client_secrets.api_key IS 'APIキー';

--
-- Name: COLUMN tbl_client_secrets.created_at; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_client_secrets.created_at IS '作成日時';

--
-- Name: COLUMN tbl_client_secrets.created_user_id; Type: COMMENT; Schema: auth; Owner: app_ods
--

COMMENT ON COLUMN auth.tbl_client_secrets.created_user_id IS '作成ユーザ';

--
-- Name: tbl_client_secrets tbl_client_secrets_pkey; Type: CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_client_secrets
    ADD CONSTRAINT tbl_client_secrets_pkey PRIMARY KEY (client_uuid);

--
-- Name: tbl_client_secrets fk_tbl_client_secrets_api_key; Type: FK CONSTRAINT; Schema: auth; Owner: app_ods
--

ALTER TABLE ONLY auth.tbl_client_secrets
    ADD CONSTRAINT fk_tbl_client_secrets_api_key
    FOREIGN KEY (api_key) REFERENCES auth.tbl_api_keys(api_key);

--
-- Name: TABLE tbl_client_secrets; Type: ACL; Schema: auth; Owner: app_ods
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE auth.tbl_client_secrets TO app_ods;

--
-- PostgreSQL database dump complete
--

