-- command
-- psql -h ::1 -p 5433 -U keycloak -d keycloak -f 1_create_app_db.sql

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
-- Create User; Owner: keycloak
--
CREATE USER app_ods WITH PASSWORD 'password';

--
-- Create database; Owner: keycloak
--
CREATE DATABASE db_ods WITH OWNER app_ods;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: keycloak
--
