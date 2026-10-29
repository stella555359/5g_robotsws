*** Settings ***
Library     taf.collectors.core      WITH NAME   core
Library     taf.collectors.btslog    WITH NAME   btslog
Library     ./webUI_operations.py
Resource    ./preconditions.robot
Resource    ./swconfig_operations.robot


*** Keywords ***
BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}


BTSLOG Collect btslog
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2    ${filename}=${test_name}
    run keyword and ignore error    Stop and collect btslog on local machine
    Copy btslog to logs dir and clean BTSlog workspace    bts_logs_dir=${bts_logs_dir}    filename=${filename}


Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}


Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run   if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi


Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2    ${filename}=${test_name}
    Run   mv ${bts_logs_dir}/syslog_files.tgz ${LOG_PATH}/${filename}_bts_log.tgz
    Run   rm ${bts_logs_dir}/*
