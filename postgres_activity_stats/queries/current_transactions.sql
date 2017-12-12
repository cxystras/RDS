/* Get current sum of transactions, total size and  timestamp. */
SELECT pg_stat_activity.pid AS pid,
CASE WHEN LENGTH(pg_stat_activity.datname) > 16
THEN SUBSTRING(pg_stat_activity.datname FROM 0 FOR 6)||'...'||SUBSTRING(pg_stat_activity.datname FROM '........$')
ELSE pg_stat_activity.datname
END
AS database,
pg_stat_activity.client_addr AS client,
EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) AS duration,
pg_stat_activity.waiting AS wait,
pg_stat_activity.usename AS user,
pg_stat_activity.state AS state,
pg_stat_activity.query AS query
FROM pg_stat_activity
WHERE state <> 'idle'
AND pid <> pg_backend_pid()
ORDER BY EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) DESC;
