/* Get waiting queries. */
SELECT
pg_locks.pid AS pid,
CASE WHEN LENGTH(pg_stat_activity.datname) > 16
THEN SUBSTRING(pg_stat_activity.datname FROM 0 FOR 6)||'...'||SUBSTRING(pg_stat_activity.datname FROM '........$')
ELSE pg_stat_activity.datname
END
AS database,
pg_stat_activity.usename AS user,
pg_locks.mode AS mode,
pg_locks.locktype AS type,
pg_locks.relation::regclass AS relation,
EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) AS duration,
pg_stat_activity.state as state,
pg_stat_activity.query AS query
FROM
pg_catalog.pg_locks
JOIN pg_catalog.pg_stat_activity ON(pg_catalog.pg_locks.pid = pg_catalog.pg_stat_activity.pid)
WHERE
NOT pg_catalog.pg_locks.granted
AND pg_catalog.pg_stat_activity.pid <> pg_backend_pid()
ORDER BY
EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) DESC;
