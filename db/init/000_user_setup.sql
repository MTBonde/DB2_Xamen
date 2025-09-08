-- PostgreSQL User Setup Script
-- This script runs first (000_) to ensure user and database exist before schema creation
-- Ensures consistent PostgreSQL setup across all environments

-- Ensure role 'mfb' exists with correct password
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mfb') THEN
      CREATE ROLE mfb WITH LOGIN PASSWORD 'mfb_pwd';
      RAISE NOTICE 'Created user: mfb';
   ELSE
      ALTER ROLE mfb WITH PASSWORD 'mfb_pwd';
      RAISE NOTICE 'Updated password for user: mfb';
   END IF;
END$$;

-- Create database mfbdb if it doesn't exist
SELECT 'CREATE DATABASE mfbdb OWNER mfb'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mfbdb')\gexec

-- Grant comprehensive permissions to mfb user
GRANT ALL PRIVILEGES ON DATABASE mfbdb TO mfb;

-- Connect to mfbdb to set schema permissions
\c mfbdb

-- Grant permissions on public schema and all current objects
GRANT ALL PRIVILEGES ON SCHEMA public TO mfb;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO mfb;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO mfb;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO mfb;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO mfb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO mfb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO mfb;

-- Verify setup
\echo 'User setup completed successfully!'
\echo 'User mfb can now access database mfbdb with full privileges'