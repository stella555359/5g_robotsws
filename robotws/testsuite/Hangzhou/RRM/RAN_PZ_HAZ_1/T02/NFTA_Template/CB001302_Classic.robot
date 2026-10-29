*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Library     taf.selenium.sbts    WITH NAME    selenium_sbts


*** Test Cases ***
CB001302_02
    [Tags]    CRT    case1
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    Parameter Updated In Gnb For CB001302
    Get Parameters For CB001302
    Collect Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start Call For UE    ue_index=${0}    direction=dl
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
    [Teardown]    Case Postcondition

CB001302_03
    [Tags]    CRT    netact
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    Get Actual Configuration MO Data   mo_id=NRCELL_A-1/NRREL_A-1
    Collect Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start Call For UE    ue_index=${0}    direction=dl
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}

Common Suite Setup For RRM
    _Create Suite Directory
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword And Ignore Error    Get TestLine Name
    Run Keyword And Ignore Error    Get Expect Sw Version
    Run Keyword And Ignore Error    Prepare Netrc On VM

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In Gnb For CB001302
    @{para_list}          Create List    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJECELL-1
    @{value_list_true}    Create List    IRATDirectDataFwdOnNg    directDataFwd
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Get Parameters For CB001302
    &{dict_parameters}    coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}
    ...                    timeout=${timeout}    connection=${connection}

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    ${actual_conf}=    netact.Get Actual Configuration    alias=${NETACT_NAME}
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=${NETACT_NAME}
    Log    \nManaged Object: ${managed_object}    console=${TRUE}
    Log    Meta Class: ${managed_object.meta_class}    console=${TRUE}
    Log    Meta Version: ${managed_object.meta_version}    console=${TRUE}
    Log    Parameters: ${managed_object.parameters}    console=${TRUE}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

Get Parameter Details by WebEM
    Selenium Login
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${result} =    selenium_coam.Get Parameter Details     dist_name=MRBTS-${NRBTS_ID}    filter_param=GPS antenna altitude
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Selenium Logout

Selenium Login
    [Arguments]    ${url}=https://192.168.255.1
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    ...            ${download_dir}=${TEST_LOGS_DIR_PATH}
    ...            ${timeout}=${60}
    ...            ${index}=${0}
    ...            ${version}=SBTS25R1
    ...            ${browser}=Firefox
    ...            ${alias}=default
    Log    ${index}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...    username=${username}
    ...    password=${password}
    ...    download_dir=${download_dir}
    ...    timeout=${timeout}
    ...    version=${version}
    ...    browser=${browser}
    ...    alias=${alias}
    selenium_coam.disable_message_box    sbts=${alias}
    selenium_coam.disable_screen_lock    sbts=${alias}

Selenium Logout
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    selenium_coam.logout    sbts=${alias}
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser    sbts=${alias}