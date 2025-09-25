-- PostgreSQL Replication Setup
-- This script sets up streaming replication for primary-replica configuration
-- Runs after all other initialization scripts (999_ prefix ensures last execution)

-- Create replication user with appropriate privileges
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replica_password';

-- Create a replication slot for the replica
SELECT pg_create_physical_replication_slot('replica_slot');

-- Grant necessary permissions to the replication user
GRANT CONNECT ON DATABASE mfbdb TO replicator;

-- Add replication entry to pg_hba.conf using COPY command
\! echo 'host replication replicator 0.0.0.0/0 trust' >> /var/lib/postgresql/data/pg_hba.conf

-- Reload configuration to apply changes
SELECT pg_reload_conf();

-- Log the replication setup completion
DO $$
BEGIN
    RAISE NOTICE 'Replication setup completed successfully';
    RAISE NOTICE 'Replication user "replicator" created with password "replica_password"';
    RAISE NOTICE 'Physical replication slot "replica_slot" created';
    RAISE NOTICE 'pg_hba.conf updated for replication access';
END
$$;