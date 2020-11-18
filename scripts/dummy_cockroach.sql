-- Create database
\benchmark once \name init
DROP DATABASE IF EXISTS dre_loadtest; CREATE DATABASE dre_loadtest; USE dre_loadtest; CREATE TABLE scheduled_tasks ( task_name STRING NOT NULL, task_instance STRING NOT NULL, task_data BYTES NULL, execution_time TIMESTAMPTZ NOT NULL, picked BOOL NOT NULL, picked_by STRING NULL, last_success TIMESTAMPTZ NULL, last_failure TIMESTAMPTZ NULL, consecutive_failures INT8 NULL, last_heartbeat TIMESTAMPTZ NULL, version INT8 NOT NULL, CONSTRAINT "primary" PRIMARY KEY (task_name ASC, task_instance ASC), FAMILY "primary" (task_name, task_instance, task_data, execution_time, picked, picked_by, last_success, last_failure, consecutive_failures, last_heartbeat, version));

-- How long does an update take?
\benchmark loop \name one
USE dre_loadtest; UPSERT INTO scheduled_tasks (task_name, task_instance, task_data, execution_time, picked, picked_by, last_success, last_failure, consecutive_failures, last_heartbeat, version) VALUES ('publish-outbox-heartbeat-balance', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924307), ('publish-outbox-heartbeat-transaction', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924323), ('publish-outbox-message', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 8550885);

-- How long does an update take?
\benchmark loop \name two
USE dre_loadtest; UPSERT INTO scheduled_tasks (task_name, task_instance, task_data, execution_time, picked, picked_by, last_success, last_failure, consecutive_failures, last_heartbeat, version) VALUES ('publish-outbox-heartbeat-balance', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924307), ('publish-outbox-heartbeat-transaction', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924323), ('publish-outbox-message', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 8550885);

-- How long does an update take?
\benchmark loop \name three
USE dre_loadtest; UPSERT INTO scheduled_tasks (task_name, task_instance, task_data, execution_time, picked, picked_by, last_success, last_failure, consecutive_failures, last_heartbeat, version) VALUES ('publish-outbox-heartbeat-balance', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924307), ('publish-outbox-heartbeat-transaction', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 4924323), ('publish-outbox-message', 'recurring', NULL, now(), false, NULL, now(), now(), 0, NULL, 8550885);

-- Clean up
\benchmark once \name clean
DROP DATABASE IF EXISTS dre_loadtest;
