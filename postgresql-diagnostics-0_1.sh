#!/bin/sh

##################
#
# SETTINGS
# PLEASE SET VARIABLES BELOW
# 
# RDSUSER requires at least a PROCESS PRIVILEGE
# 
# It's advised to call this script as unpriviled user from cron. Please set proper permissions for STAT_DIR to allow that user to write files in that directory
#################
RDSHOST=''
RDSUSER=''
RDSDB=''
RDSPASSWORD=''
STAT_DIR="${HOME}/postgre_stats/"

export PGPASSWORD=${RDSPASSWORD}

##################
# SCRIPT
#################
DATE=`date -u '+%Y-%m-%d-%H%M%S'`
mkdir -p ${STAT_DIR}
if [ $? -eq 0 ]; then

	echo "================ACTIVE SESSION USE================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM PG_STAT_ACTIVITY;' >> ${STAT_DIR}/${DATE}.output
	echo "================LOCKS=============================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT blocked_locks.pid AS blocked_pid, blocked_activity.usename  AS blocked_user, blocking_locks.pid     AS blocking_pid, blocking_activity.usename AS blocking_user, blocked_activity.query AS blocked_statement, blocking_activity.query AS blocking_statement FROM  pg_catalog.pg_locks         blocked_locks JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid JOIN pg_catalog.pg_locks         blocking_locks ON blocking_locks.locktype = blocked_locks.locktype AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid AND blocking_locks.pid != blocked_locks.pid JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid WHERE NOT blocked_locks.GRANTED;' >> ${STAT_DIR}/${DATE}.output
	echo "================LOCKS -2 ====================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_locks;' >> ${STAT_DIR}/${DATE}.output
	echo "================DATABASES INFO====================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_stat_database;' >> ${STAT_DIR}/${DATE}.output
	echo "================INDEXES===========================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_stat_all_indexes;' >> ${STAT_DIR}/${DATE}.output
#	ATTN: This might perform a vacuum on system databases
#	echo "================ANALYSE VACUUM NEED===============" >> ${STAT_DIR}/${DATE}.output
#	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'VACUUM VERBOSE ANALYSE;' >> ${STAT_DIR}/${DATE}.output
	echo "================ALL PARAMETERS====================" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SHOW ALL;' >> ${STAT_DIR}/${DATE}.output
#	ATTN: might not be needed - generates too much noise
#	echo "================ALL PARAMETERS====================" >> ${STAT_DIR}/${DATE}.output
#	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_stat_all_tables;' >> ${STAT_DIR}/${DATE}.output
	echo "================USER'S TABLE STATISTICS===========" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_stat_user_tables;' >> ${STAT_DIR}/${DATE}.output
	echo "================USER'S INDEX STATISTICS===========" >> ${STAT_DIR}/${DATE}.output
	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SELECT * FROM pg_stat_user_indexes;' >> ${STAT_DIR}/${DATE}.output
#	echo "================ALL PARAMETERS====================" >> ${STAT_DIR}/${DATE}.output
#	psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'SHOW ALL;' >> ${STAT_DIR}/${DATE}.output


else
	echo "DIRECTORY CREATING ERROR"
fi

#export PGPASSWORD=''
unset PGPASSWORD