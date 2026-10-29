*** Settings ***

Documentation
...   author: PZ_2_WRO_5

Resource    ../../cOAM/resources/system.robot
Resource    admin/BasicKeywords.robot
Resource    ConnectivityKeywords.robot

Library     taf.collectors.core      WITH NAME   core
Library     taf.collectors.btslog    WITH NAME   btslog
Library     taf.sbts.oam.coam.admin    WITH NAME     admin
Library     BuiltIn
Library     String
Library     DateTime


*** Variables ***
${LMP_IP}=    ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${SysLogOutputMode}=    0x10041=5
${flag2}=    0x10040=1
${flag3}=    0x1003F=1

*** Keywords ***

Setup Log Collection
    BTSLOG Start btslog on local machine
    admin cli connection

Teardown Log Collection
    BTSLOG Collect btslog
    admin cli connection
    Run Keyword If Test Failed    Admin Collect Snapshot cOAM1
    ConnectivityKeywords.Close Connections cOAM1

Activate SysLogOutputMode
    SYSTEM Add Flag In Swconfig File cOAM1    ${SysLogOutputMode}

gNB goes to OnAir after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    gNB in onAir state

gNB goes to configured after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    gNB in configured state

gNB goes to commissioned after reset
    ADMIN CLI connection
    wait until keyword succeeds    900   30    gNB in conmissioned state

SYSTEM Add Flag In Swconfig File cOAM1
    [Arguments]    ${flag}
    ${status}    SYSTEM Execute Command On gNB
    ...    command=cat /rom/swconfig.txt | grep ${flag}
    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
    Run Keyword If    ${status}
    ...    Run Keywords
    ...    SYSTEM Execute Command On gNB
    ...    command=echo \n >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=echo \ >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=echo ${SysLogOutputMode} >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=echo ${flag2} >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=echo ${flag3} >> /rom/swconfig.txt    AND
    ...    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt    AND
    ...    admin cli connection    AND
    ...    BasicKeywords.gNB Site Reset    AND
    ...    Wait Until Keyword Succeeds
    ...    240
    ...    5
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${LMP_IP}

Admin Collect Snapshot cOAM1
    [Arguments]    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/    ${snapshot_name}=snapshot.zip
    ADMIN CLI connection
    admin.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}    coverage=Full   timeout=2700
    ADMIN CLI disconnection

Admin Collect Snapshot Alias cOAM1
    [Arguments]    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/
    ...            ${snapshot_name}=snapshot.zip    ${snap_timeout}=900
    admin.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}  coverage=Full   timeout=${snap_timeout}

Admin Collect Snapshot cOAM1 Suite
    [Arguments]    ${snapshot_dir_path}=${OUTPUT_DIR}/${SUITE_NAME}/    ${snapshot_name}=snapshot.zip
    ADMIN CLI connection
    admin.get_snapshot  target_file_name=${snapshot_dir_path}/${snapshot_name}    coverage=Full   timeout=2700
    ADMIN CLI disconnection
    ConnectivityKeywords.Close Connections cOAM1

BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    Make empty BTS logs dir cOAM1      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect btslog
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    run keyword and ignore error    Stop and collect btslog on local machine cOAM1
    Copy btslog to logs dir and clean BTSlog workspace cOAM1   ${bts_logs_dir}

Stop and collect btslog on local machine cOAM1
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Make empty BTS logs dir cOAM1
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Copy btslog to logs dir and clean BTSlog workspace cOAM1
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

Prepare logs path cOAM1
    [Documentation]      Sets path and creates directory where collected log files will be saved.
    ...                  logs_path is unique per test suite run and accessible from Test Suite scope.
    [Arguments]          ${testCase_name}=${TEST_NAME}
    ${date}              DateTime.Get Current Date
    ${tc_name}           String.Replace String
    ...                  string=${testCase_name}
    ...                  search_for=${SPACE}
    ...                  replace_with=_
    Set Global Variable  ${logs_path}
    ...                  ${OUTPUT DIR}/OAM_TS_${date[0:10]}/${date[11:19]}_${tc_name}
    Run                  mkdir -p ${logs_path}
