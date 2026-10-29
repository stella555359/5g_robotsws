*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB009365

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/cbrs_common_case_variables.py

*** Variables ***
${common_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${common_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${common_json_path}/enable_actcbrs.json
${conf_path}    ${CURDIR}/conf
${common_case_conf}    ${conf_path}/common_case_conf.conf
@{cell_id_common}    ${1}
@{delete_cell}    ${1}

*** Keywords ***
Common case cbrs Suite Setup
    [Arguments]    ${if_commissioning}=${False}     ${UTECloud}=${False}
    Download Sas Server
    log to console    \n***CBRS Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    run keyword if     ${UTECloud}==${True}     cbrs_common_keywords.CBRS UTE Common Suite Setup
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
#    ${Golden_SCF_Path}    Get Golden SCF Path
#    set suite variable      ${Golden_SCF_Path}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path_common}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set suite variable     ${scf_path_common}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    run keyword if    ${ute_env}    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
    run keyword if    '${if_commissioning}'=='True'
    ...    Commissioning SCF And Check RU On Air    scf_file_path=${scf_path_common}
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    cbrs get gNb CuType
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    get mtbitsid and lnbtsid
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    get mtbitsid and nrbtsid
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

cbrs get gNb CuType
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}

get mtbitsid and lnbtsid
    ${mrbtsID}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${scf_path_common}
    log to console  MRBTS_ID:${mrbtsID}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${lnbtsID}

get mtbitsid and nrbtsid
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path_common}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}

Common case cbrs Test Setup
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Setup***
    robot_common_operations.CommonCaseSetup
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${cbsdIds}     Create Dictionary
    set test variable    ${cbsdIds}
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    Activate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}

common case cbrs Test Teardown
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Teardown***
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    Connect to gnb coam via ssl
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=GNB_OAM
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    kill process for SAS server
    Wait Until Keyword Succeeds    5 min    5 sec    Verify all cells should be disabled
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
