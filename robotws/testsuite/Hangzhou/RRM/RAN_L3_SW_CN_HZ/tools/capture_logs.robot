*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_NUMBER}     1
${SKIP_ON_AIR}    ${True}
${SNAPSHOT_FLAG}    pass:True,fail:True
${AP_BIP_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}


*** Test Cases ***
Capture Logs
    Log To Console    ${EMPTY}
    Log To Console    \##########################
    Log To Console    You can start your testing now
    Log To Console    Press CTRL-C for only one time if finished...
    Sleep    10h

*** Keywords ***
Suite Setup
    Run Keyword If    '${BTS_NUMBER}'=='1'    Suite Setup For 1GNB
    Run Keyword If    '${BTS_NUMBER}'=='2'    Suite Setup For 2GNB

Suite Setup For 1GNB
    Common Suite Setup
    _Get Iphy Info
    _Set Iphy Ip
#    ${bts_state}    Get Mrbts State
#    Run Keyword If    "${bts_state.lower()}"!="onair" and  ${SKIP_ON_AIR} is not ${True}   Generate CFG And Start WTS for 1GNB
    run keyword and ignore error    Execute Egate Command    sim_trace protocol=rrc on uec=1
    run keyword and ignore error    Execute Egate Command    trace uec=1 protocol=nr_rrc on
    run keyword and ignore error    Execute Egate Command    sim_trace amf=1 protocol=ng on

Suite Setup For 2GNB
    Common Suite Setup
    _Setup GNB2
#    ${bts_port}    ${use_ssl}    Define Admin Port
#    Setup Admin    bts_port=${bts_port}    use_ssl=${use_ssl}    admin_api_log_dir=${SAVE LOG DIRECTORY}/gnb2/admin_logs
#    ...    timeout=120    bts_host=${GNB2_IP}    alias=${GNB2_ALIAS}
    _Get Iphy Info
    _Set Iphy Ip
#    ${bts_state}    Get Mrbts State
#    Run Keyword If    "${bts_state.lower()}"!="onair" and ${SKIP_ON_AIR} is not ${True}    Generate CFG And Start WTS for 2gnb
    run keyword and ignore error    Execute Egate Command    sim_trace protocol=rrc on uec=1
    run keyword and ignore error    Execute Egate Command    trace uec=1 protocol=nr_rrc on
    run keyword and ignore error    Execute Egate Command    sim_trace amf=1 protocol=ng on

Test Setup
    Common Test Setup And Start To Capture Logs
    Get Current Scf File    local_dir_path=${SAVE LOG DIRECTORY}
    ...  file_name=scf_before_test.xml  export_type=configurationAndRuntimeObjects

Test Teardown
    Common Test Teardown And Stop Capture Logs

Suite Teardown
    Execute Cmd On Pc    ls -ltR ${SUITE_LOG_DIRECTORY}
    Execute Cmd On Pc    rm -rf ${SUITE_LOG_DIRECTORY}/admin_api*.log
    Common Suite Teardown
    Log To Console    all logs are in ${SUITE_LOG_DIRECTORY}
    Log To Console    \##########################

Generate CFG And Start WTS for 1GNB
    kill_edaemon_and_egate
    Get Current Scf File    local_dir_path=.    file_name=scf.xml
    _Auto Generate Cfg BTS1    30    scf.xml    source_wts_cfg=xx
    start wts and waiting for gnb onair    ${AUTO_CFG}    ${DEBUG_LOG_LEVEL}    ${SA_NSA_MODEL}

Generate CFG And Start WTS for 2GNB
    kill_edaemon_and_egate
    Get Current Scf File    local_dir_path=.    file_name=scf1.xml
    Get Current Scf File    local_dir_path=.    file_name=scf2.xml    alias=${GNB2_ALIAS}}
    _Auto Generate Cfg BTS2  30    scf1.xml   scf2.xml    source_wts_cfg=xx
    start wts and waiting for gnb onair    ${AUTO_CFG}    ${DEBUG_LOG_LEVEL}    ${SA_NSA_MODEL}

