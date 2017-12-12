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

# This script is intended to be a proof of concept and is provided as is without any support.
#
# WARNING: This script use the PGPASSWORD global variable to store password credential.
# This is an insecure method, it is strongly advised to not use the PGPASSWORD in any sensitive environment.

RDSHOST=''
RDSUSER=''
RDSDB=''
#RDSPASSWORD=''
STAT_DIR="${HOME}/postgre_stats/"

# Enter the password direcly on the script
#RDSPASSWORD='' 

# to pass password during call - for schedule
#RDSPASSWORD=$1 

# To prompt for password - for one time run (uncoment all 5 below lines)
echo "Enter DB password for "$RDSUSER 
stty_orig=`stty -g` # save original terminal setting.
stty -echo          # turn-off echoing.
read RDSPASSWORD    # to catch password - for one time run
stty $stty_orig     # restore terminal setting.

export PGPASSWORD=${RDSPASSWORD}

DATE=`date -u '+%Y-%m-%d-%H%M%S'`

# Output to be saved as HTML
OUTPUTFILE="${STAT_DIR}/${DATE}.html"

# The -H, --html HTML table output mode
CMD="psql -H -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -f "


##################
# SCRIPT
#################
mkdir -p ${STAT_DIR}

if [ $? -eq 0 ]; then

        echo "<h2>================RUNNING QUERIES================</h2>" >> ${OUTPUTFILE}
        `${CMD} queries/current_transactions.sql >> ${OUTPUTFILE}`

        echo "<h2>================WAITING QUERIES===:=============</h2>" >> ${OUTPUTFILE}
        `$CMD queries/waiting_queries.sql >> ${OUTPUTFILE}`

        echo "<h2>================BLOCKING QUERIES================</h2>" >> ${OUTPUTFILE}
        `$CMD queries/blocking_queries.sql >> ${OUTPUTFILE}`

        echo "<h2>================DATABASES INFO====================</h2>" >> ${OUTPUTFILE}
        `$CMD queries/database_statistics.sql >> ${OUTPUTFILE}`

        echo "<h2>================USERS I/O STATISTICS==============</h2>" >> ${OUTPUTFILE}
        `$CMD queries/io_statistics.sql >> ${OUTPUTFILE}`

        echo "<h2>================USERS TABLE STATISTICS============</h2>" >> ${OUTPUTFILE}
        `$CMD queries/table_statistics.sql >> ${OUTPUTFILE}`

        echo "<h2>================USERS INDEX STATISTICS============</h2>" >> ${OUTPUTFILE}
        `$CMD queries/index_statistics.sql >> ${OUTPUTFILE}`

#       echo "<h2>================ALL PARAMETERS=====================</h2>" >> ${OUTPUTFILE}
#       psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -x -c 'SHOW ALL;' >> ${OUTPUTFILE}

#       ATTN: This might perform a vacuum on system databases
#       echo "<h2>================ANALYSE VACUUM NEED================</h2>" >> ${OUTPUTFILE}
#       psql -h ${RDSHOST} -U ${RDSUSER} ${RDSDB} -c 'VACUUM VERBOSE ANALYSE;' >> ${OUTPUTFILE}

else
        echo "DIRECTORY CREATING ERROR"
fi

#export PGPASSWORD=''
unset PGPASSWORD