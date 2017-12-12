/* Getting blocking_queries */
SELECT
pid,
CASE
WHEN LENGTH(datname) > 16
THEN SUBSTRING(datname FROM 0 FOR 6)||'...'||SUBSTRING(datname FROM '........$')
ELSE datname
END
AS database,
usename AS user,
relation,
mode,
locktype AS type,
duration,
state,
query
FROM
(
SELECT
blocking.pid,
pg_stat_activity.query,
blocking.mode,
pg_stat_activity.datname,
pg_stat_activity.usename,
blocking.locktype,
EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) AS duration,
pg_stat_activity.state as state,
blocking.relation::regclass AS relation
FROM
pg_locks AS blocking
JOIN (
SELECT
transactionid
FROM
pg_locks
WHERE
NOT granted) AS blocked ON (blocking.transactionid = blocked.transactionid)
JOIN pg_stat_activity ON (blocking.pid = pg_stat_activity.pid)
WHERE
blocking.granted
UNION ALL
SELECT
blocking.pid,
pg_stat_activity.query,
blocking.mode,
pg_stat_activity.datname,
pg_stat_activity.usename,
blocking.locktype,
EXTRACT(epoch FROM (NOW() - pg_stat_activity.query_start)) AS duration,
pg_stat_activity.state as state,
blocking.relation::regclass AS relation
FROM
pg_locks AS blocking
JOIN (
SELECT
database,
relation,
mode
FROM
pg_locks
WHERE
NOT granted
AND relation IS NOT NULL) AS blocked ON (blocking.database = blocked.database AND blocking.relation = blocked.relation)
JOIN pg_stat_activity ON (blocking.pid = pg_stat_activity.pid)
WHERE
blocking.granted
) AS sq
GROUP BY
pid,
query,
mode,
locktype,
duration,
datname,
usename,
state,
relation
ORDER BY duration DESC;
