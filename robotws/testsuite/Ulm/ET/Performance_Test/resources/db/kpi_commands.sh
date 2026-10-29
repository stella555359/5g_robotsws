#!/bin/bash

# Copyright (c) 2024 Nokia. All rights reserved.

# --------------------------------------------------
# -- RETRIEVE
# --------------------------------------------------



DATABASE_PATH=/mnt/etlogs/logs/performance/02_database/performance.sqlite3
# DATABASE_PATH=/mnt/etlogs/logs/performance/02_database/test.sqlite3

perf_show_commands(){
    echo "Available_commands:"
    echo "    perf_get_testcase_names"
    echo "    perf_get_testcase <testname>"
    echo "    perf_get_testcase_all_details <testcase_id>"
    echo "    perf_get_testcase_flags <testcase_id>"
    echo "    perf_get_pmcounters <testcase_id>"
    echo "    perf_get_emperf <testcase_id>"
    echo "    perf_get_emperf_container <testcase_id> <container>"
    echo "    perf_get_emperf_disps <testcase_id> <disp_number>"
    echo "    perf_get_kpi <testcase_id>"
    echo "    perf_perf_sqlite3_query <query> <args>"
    echo "    perf_show_commands"
    echo ""
}

perf_get_testcase_names(){
    perf_sqlite3_query "
    SELECT * FROM view_testnames;
    " "$1 $2 $3"
}

perf_get_testcase(){
    test_name=${1}
    limit=${2}
    if [[ -z ${limit} ]]
    then
        limit_query="LIMIT 3"
    elif [[ ${limit}==0 ]]
    then
        limit_query=''
    else
        limit_query="LIMIT ${limit}"
    fi
    perf_sqlite3_query "
    SELECT *
        FROM testcase
        WHERE
            testname=\"${test_name}\"
            ORDER BY testdate DESC
        ${limit_query};
    " "$2 $3 $4"
}

perf_get_testcase_all_details(){
    testcase_id=${1}
    perf_sqlite3_query "
    SELECT *
        FROM view_testcase_all_details
        WHERE
            view_testcase_all_details.testcase_id=${testcase_id};
    " "$2 $3 $4"
}

perf_get_testcase_flags(){
    testcase_id=${1}
    perf_sqlite3_query "
    SELECT *
        FROM view_testcase_flags
        WHERE
            view_testcase_flags.testcase_id=${testcase_id};
    " "$2 $3 $4"
}

perf_get_pmcounters(){
    testcase_id=${1}
    perf_sqlite3_query "
    SELECT *
        FROM view_pmcounters
        WHERE
            view_pmcounters.testcase_id=${testcase_id};
    " "$2 $3 $4"
}

perf_get_emperf(){
    testcase_id=${1}
    perf_sqlite3_query "
    SELECT *
        FROM view_emperf
        WHERE
            testcase_id=${testcase_id};
    " "${2} ${3} ${4}"
}

perf_get_emperf_container(){
    testcase_id=${1}
    container=${2}
    perf_sqlite3_query "
    SELECT *
        FROM view_emperf
        WHERE
            testcase_id=${testcase_id}
            AND container='${container}';
    " "$3 $4 $5"
}

perf_get_emperf_disps(){
    testcase_id=${1}
    disp_number=${2}
    perf_sqlite3_query "
    SELECT *
        FROM view_emperf
        WHERE
            testcase_id=${testcase_id}
            AND disp_number='${disp_number}';
    " "$3 $4 $5"
}

perf_get_kpi(){
    testcase_id=${1}
    perf_sqlite3_query "
    SELECT *
        FROM view_kpi
        WHERE
            testcase_id=${testcase_id}
    " "$2 $3 $4"
}

perf_sqlite3_query(){
    query="${1}"
    args='-header -column'
    if [[ ! -z "${2// /}" ]]
    then
        args="${2}"
    fi
    echo "args: ${args}"
    echo "${query}"
    sqlite3 ${args} -readonly ${DATABASE_PATH} "${1}"
    echo ""
}

perf_show_commands
