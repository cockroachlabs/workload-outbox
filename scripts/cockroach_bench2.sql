-- Create database
\benchmark once \name 2_initSchedTask
DROP DATABASE IF EXISTS dre_loadtest; CREATE DATABASE dre_loadtest; USE dre_loadtest; CREATE TABLE scheduled_tasks (task_name STRING NOT NULL, task_instance STRING NOT NULL, task_data BYTES NULL, execution_time TIMESTAMPTZ NOT NULL, picked BOOL NOT NULL, picked_by STRING NULL, last_success TIMESTAMPTZ NULL, last_failure TIMESTAMPTZ NULL, consecutive_failures INT8 NULL, last_heartbeat TIMESTAMPTZ NULL, version INT8 NOT NULL, CONSTRAINT "primary_1" PRIMARY KEY (task_name ASC, task_instance ASC), FAMILY "primary_f" (task_name, task_instance, task_data, execution_time, picked, picked_by, last_success, last_failure, consecutive_failures, last_heartbeat, version));

\benchmark once \name 2_insertSchedTask
USE dre_loadtest; INSERT INTO scheduled_tasks VALUES ('publish-outbox-heartbeat-balance', 'recurring', NULL, '2020-10-28 08:35:23.199+00:00', 'false', NULL, '2020-10-28 08:35:21.199+00:00', '2020-10-22 01:18:23.309+00:00', 0, NULL, 6918769); INSERT INTO scheduled_tasks VALUES ('publish-outbox-heartbeat-transaction', 'recurring', NULL, '2020-10-28 08:35:23.202+00:00', 'false', NULL, '2020-10-28 08:35:21.202+00:00', '2020-10-22 01:18:23.319+00:00', 0, NULL, 6916725); INSERT INTO scheduled_tasks VALUES ('publish-outbox-message', 'recurring', NULL, '2020-10-28 08:34:50.781+00:00', 'true', 'productmanager-default-5b85c9f9d7-tcwd2', '2020-10-28 08:34:49.781+00:00', '2020-10-27 19:37:04.381+00:00', 0, '2020-10-28 08:35:04.351+00:00', 8117838);

-- How long does a select take?
\benchmark loop \name 2_selectSchedTask
USE dre_loadtest; SELECT * FROM scheduled_tasks WHERE task_name = 'publish-outbox-message';

-- How long does an update of 1 row take?
\benchmark loop \name 2_update1SchedTask
USE dre_loadtest; UPDATE scheduled_tasks SET execution_time = current_timestamp(), last_success = current_timestamp(), version = version + 1 WHERE task_name = 'publish-outbox-message';

-- Clean up
\benchmark once \name 2_cleanSchedTask
DROP DATABASE IF EXISTS dre_loadtest;
