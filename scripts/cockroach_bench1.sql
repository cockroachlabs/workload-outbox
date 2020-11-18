-- Create database
\benchmark once \name 1_init
DROP DATABASE IF EXISTS loadtest; CREATE DATABASE loadtest; USE loadtest;  CREATE TABLE outbox ( message_key UUID NOT NULL DEFAULT gen_random_uuid(), message BYTES NOT NULL, message_checksum VARCHAR(64) NOT NULL, message_checksum_algorithm VARCHAR(50) NOT NULL, outbox_published_date TIMESTAMPTZ NOT NULL, topic VARCHAR(255) NOT NULL, last_replayed TIMESTAMPTZ NOT NULL, iterval INT NULL, CONSTRAINT "primary" PRIMARY KEY (message_key ASC), INDEX outbox_last_replayed_idx (last_replayed ASC), INDEX outbox_topic_last_replayed_idx (topic ASC, last_replayed ASC) STORING (message, message_checksum, message_checksum_algorithm), INDEX outbox_topic_name_last_replayed_index (topic ASC, last_replayed ASC), INDEX outbox_iterval (iterval ASC), FAMILY "primary" (message_key, message, message_checksum, message_checksum_algorithm, outbox_published_date, topic, last_replayed, iterval));

\benchmark loop \name 1_insert
USE loadtest; INSERT INTO outbox (message, message_checksum, message_checksum_algorithm, outbox_published_date, topic, last_replayed, iterval) VALUES (e'\\370\\370\\370\\370kH028ba2c5-8087-4ec5-a20a-c297f33ea6d4\\370\\370\\370\\370\\370]\\370\\370\\370\\370\\370]\\370\\370\\370\\370\\370]\\370INSERT\\370transaction_id\\3701.0.0H8134b803-b89c-42ea-82ef-02bfdf8e520e\\370H8134b803-b89c-42ea-82ef-02bfdf8e520eH79c22cb1-e523-4921-8291-4199a841d9fe\\370\\370(\\370AUD\\370\\370\\370\\370\\370\\370\\370\\370\\370\\370]\\370\\370\\370\\370\\370]\\370COMPLETE\\370CACS_CT_IN\\370PMNT.RCDT.DMCT\\370\\370\\370\\370\\370\\370\\370]\\370\\370Uranus', 'e41d6430', 'CRC32', current_timestamp() - INTERVAL '{{call .RandInt63n 28}} days', 'topic-exists-v00{{call .RandInt63n 9}}', current_timestamp() - INTERVAL '{{call .RandInt63n 28}} days', {{.Iter}});

-- How long does a select take?
\benchmark loop \name 1_badSelect1
USE loadtest; SELECT (SELECT message_key FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - interval '7 days') AND (outbox_published_date < now())) ORDER BY outbox_published_date ASC LIMIT 1) AS first_message_key, (SELECT message_key FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - interval '7 days') AND (outbox_published_date < now())) ORDER BY outbox_published_date DESC LIMIT 1) AS last_message_key, (SELECT count(*) FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - INTERVAL '7 days') AND (outbox_published_date < now()))) AS count;
\benchmark loop \name 1_badSelect2
USE loadtest; SELECT (SELECT message_key FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - interval '7 days') AND (outbox_published_date < now())) ORDER BY outbox_published_date ASC LIMIT 1) AS first_message_key, (SELECT message_key FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - interval '7 days') AND (outbox_published_date < now())) ORDER BY outbox_published_date DESC LIMIT 1) AS last_message_key, (SELECT count(*) FROM outbox WHERE (topic = 'topic-does-not-exist') AND ((outbox_published_date >= now() - INTERVAL '{{call .RandInt63n 7}} days') AND (outbox_published_date < now()))) AS count;
\benchmark loop \name 1_badSelect3
USE loadtest; SELECT (SELECT message_key FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - interval '7 days') AND (outbox_published_date < current_timestamp())) ORDER BY outbox_published_date ASC LIMIT 1) AS first_message_key, (SELECT message_key FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - interval '7 days') AND (outbox_published_date < current_timestamp())) ORDER BY outbox_published_date DESC LIMIT 1) AS last_message_key, (SELECT count(*) FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - INTERVAL '7 days') AND (outbox_published_date < current_timestamp()))) AS count;
\benchmark loop \name 1_badSelect4
USE loadtest; SELECT (SELECT message_key FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - interval '7 days') AND (outbox_published_date < current_timestamp())) ORDER BY outbox_published_date ASC LIMIT 1) AS first_message_key, (SELECT message_key FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - interval '7 days') AND (outbox_published_date < current_timestamp())) ORDER BY outbox_published_date DESC LIMIT 1) AS last_message_key, (SELECT count(*) FROM outbox WHERE (topic = 'topic-exists-v001') AND ((outbox_published_date >= current_timestamp() - INTERVAL '{{call .RandInt63n 7}} days') AND (outbox_published_date < current_timestamp()))) AS count;

-- How long does an update of 1 row take?
\benchmark once \name 1_update1
USE loadtest; UPDATE outbox SET iterval = NULL WHERE iterval = 10000;
\benchmark once \name 1_update1a
USE loadtest; UPDATE outbox SET iterval = 10000 WHERE iterval IS NULL;

-- How long does an update of 10 rows take?
\benchmark once \name 1_update10
USE loadtest; UPDATE outbox SET iterval = NULL WHERE iterval >= 1000 AND iterval < 1010;
\benchmark once \name 1_update10a
USE loadtest; UPDATE outbox SET iterval = 10000 WHERE iterval IS NULL;

-- How long does an update of 100 rows take?
\benchmark once \name 1_update100
USE loadtest; UPDATE outbox SET iterval = NULL WHERE iterval >= 2000 AND iterval < 2100;
\benchmark once \name 1_update100a
USE loadtest; UPDATE outbox SET iterval = 10000 WHERE iterval IS NULL;

-- How long does an update of 1000 rows take?
\benchmark once \name 1_update1000
USE loadtest; UPDATE outbox SET iterval = NULL WHERE iterval >= 3000 AND iterval < 4000;
\benchmark once \name 1_update1000a
USE loadtest; UPDATE outbox SET iterval = 10000 WHERE iterval IS NULL;

-- Does using an indexed NULL in the WHERE clause break the optimizer?
\benchmark once \name 1_indexedNullUpd
USE loadtest; UPDATE outbox SET iterval = NULL, last_replayed = current_timestamp() WHERE iterval = 10000;
\benchmark once \name 1_indexedNullUpda
USE loadtest; UPDATE outbox SET last_replayed = current_timestamp() WHERE iterval >= 4000 AND iterval < 5000;

\benchmark loop \name 1_indexedNullSel
USE loadtest; SELECT COUNT(*) FROM outbox WHERE topic = 'topic-does-not-exist' AND last_replayed >= current_timestamp() - INTERVAL '24 hours';
\benchmark loop \name 1_indexedNullSela
USE loadtest; SELECT COUNT(*) FROM outbox WHERE topic = 'topic-exists-v001' AND last_replayed >= current_timestamp() - INTERVAL '24 hours';
\benchmark loop \name 1_indexedNullSela
USE loadtest; SELECT COUNT(*) FROM outbox WHERE topic = 'topic-does-not-exist' AND last_replayed >= current_timestamp() - INTERVAL '24 hours' AND iterval IS NULL;
\benchmark loop \name 1_indexedNullSelb
USE loadtest; SELECT COUNT(*) FROM outbox WHERE topic = 'topic-exists-v001' AND last_replayed >= current_timestamp() - INTERVAL '24 hours' AND iterval IS NULL;

-- Clean up
\benchmark once \name 1_clean
DROP DATABASE IF EXISTS loadtest;
