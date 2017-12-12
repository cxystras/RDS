/* USERS I/O STATISTICS */
SELECT * 
FROM pg_statio_all_tables 
ORDER BY heap_blks_hit DESC LIMIT 50;
