*** Settings ***
Documentation    Author: arunkumar.a@nokia.com 
...    Only Suite Setup and tear down.
Resource    ../robot/Rjio_Operation_keywords.robot
Resource    ../robot/Basic_vm_operation.robot
*** Keywords ***
RJIO Suite Setup
    [Arguments]    ${gnb_index}=0  ${if_update_swconfig}=${False}  ${cell_id}=${3}
    BuiltIn.Log To Console    \n[ INFO ]: RJIO Suite Setup
    Run Keyword And Ignore Error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    # run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup 
    #    gnb_index=${gnb_index}  # Scf common commission
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${SW_stream}   String.Split String    string=${Active_SW_version}   separator=_    max_split=1
    set suite variable    ${SW_stream}
    set suite variable    ${abbr_SW_stream}    ${SW_stream}[0]
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Scf_selection_depends_on_sw_version 
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    # Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    # set suite variable    ${scf_path}
    Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${main_scf_path}    cell_id=${cell_id}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    ${BTS_name}    set variable    MRBTS-${mrbtsID}
    set suite variable    ${BTS_name}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version
    add fault to the allowed fault list    faultId=${7311}
    add fault to the allowed fault list    faultId=${7307}
    add fault to the allowed fault list    faultId=${4293}
    add fault to the allowed history fault list    faultId=${7311}
    set suite variable    ${suite_setup_fail_flag}    ${False}

RJIO Suite Teardown
    [Arguments]    ${gnb_index}=${0}
    robot_common_operations.Common Suite Teardown
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ...        gnb_index=${gnb_index}
    BuiltIn.Run Keyword If    ${save_snapshot}    AND    ${suite_setup_fail_flag}    run keywords    Save Coam Snapshot    
    ...    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND    Save Coam im snapshot
    ...        target_dir=${SAVE LOG DIRECTORY}    
    ...    connection=${connection}    AND    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    ...        gnb_index=${gnb_index}
    ...    ELSE    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections    ${connection} 
    BuiltIn.Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

RJIO Test Setup
    [Arguments]    ${gnb_index}=${0}
    robot_common_operations.Common Case Setup
    BuiltIn.Log To Console    \n[ INFO ]: SISO Coam Test Setup
    BuiltIn.Log To Console    gNB CU type:${gNb_CuType}
    BuiltIn.Log To Console    Active_SW_version(gNB):${Active_SW_version}
    BuiltIn.Run Keyword If    '${gNb_CuType}'=='NSA'    or    '${gNb_CuType}'=='SA+NSA'    
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    Generate test case log path
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    BuiltIn.Set Test Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    OperatingSystem.Create Directory    ${TS_CASE_LOG_PATH}
    BuiltIn.Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    BuiltIn.Log To Console    case log path:${TS_CASE_LOG_PATH}
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ...        gnb_index=${gnb_index}
    ${ru_info}    COAM get all ru detail info    connection=${connection}
    ${ru_value}    Collections.Get Dictionary Values     ${ru_info}
    &{ru_info}    BuiltIn.Set Variable    ${ru_value}[0]
    BuiltIn.Run Keyword And Ignore Error    should contain    ${TEST_NAME}    &{ru_info}[productName]
    ${ru_status}    BuiltIn.Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    BuiltIn.Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    ${Status}    ${key}    BuiltIn.Run Keyword And Ignore Error    get specified scf
    ${SCF_Path}    BuiltIn.Set Variable If    '${Status}'=='PASS'    @{key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    BuiltIn.Set Variable If    '${Status}'=='PASS'    @{key}[1]    ${False}
    BuiltIn.Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    BuiltIn.Run Keyword If    ${ru_status}==${False}    or    ${cell_status}==${False}
    ...        or    ${SCF_Status}==${True}    and    ${gnb_index}==0    Commissioning SCF And Check On Air    scf_path=${SCF_Path}
    Start Btslog With Path Check
    BuiltIn.Run Keyword And Ignore Error    selenium_coam.close_browser

Test_Tear_down 
    [Arguments]    ${gnb_index}=${0}     ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False} 
    robot_common_operations.Common Case Teardown
    BuiltIn.Log To Console    \n[ INFO ]: RJIO Test Teardown***
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}    BuiltIn.Run Keyword And Ignore Error    COAM Check GNB RU status    connection=${connection}
    BuiltIn.Log To Console    [ INFO ]: RU status: ${ru_status}
    ${cell_status}    BuiltIn.Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    BuiltIn.Should Be True    ${cell_status}
    ${alarm_status}    BuiltIn.Run Keyword And Return Status    Unexpect Alarm Should Not Exist    allowed_faults=@{ALLOWED_FAULT}
    ...    connection=${connection}
    BuiltIn.Should Be True    ${alarm_status}
    &{fault_7313}    BuiltIn.Create Dictionary    faultId=${7313}
    ${ALLOWED_HISTORY_FAULT}    BuiltIn.Create List    @{ALLOWED_HISTORY_FAULT}    ${fault_7313}
    ${history_alarm_status}    BuiltIn.Run Keyword And Return Status    Unexpect History Alarm Should Not Exist    
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    BuiltIn.Run Keyword If    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    ${test_fail_flag}    BuiltIn.Run Keyword If    ${is_case_teardown}    run keyword if test failed    set variable    ${True}
    ${test_fail_flag}    BuiltIn.Set Variable If    ${test_fail_flag}    ${True}    ${False}
    BuiltIn.Run Keyword If    ${save_snapshot}    and    ${test_fail_flag}    
    ...    run keywords    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    ...    AND    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    ...    AND    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE    log to console    don't collect snapshot in test teardown!!!
    Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    BuiltIn.Run Keyword And Ignore Error    csn.Disconnect    connection=ASIK Master

RJIO Test Teardown
    save full snapshot
    Test_Tear_down