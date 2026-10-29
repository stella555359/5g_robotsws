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





*** Test Cases ***
CB006139_AA_01_Common _Preconditions_Verification_on_webEM
    [Tags]    CRT    case1
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
    Parameter Updated In Gnb For CB006139
    Start Emil log    product_type=vdu    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start Call For UE    ue_index=${0}    direction=dl
    Modify PA Signal For Source And Target
    ${local_file_path}    Stop And Download Emil Log    product_type=vdu    bts_index=${0}
    Test Decoded Emil Log To Csv File    local_file_path=${local_file_path}
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

Common Suite Setup For RRM
    _Create Suite Directory

Case Postcondition
    [Arguments]    ${ue_index}=${0}
    Log To Console    ${ue_index}
    log to console    Case Postcondition

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In Gnb For CB006139
    @{para_list}          Create List    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJECELL-1
    @{value_list_true}    Create List    IRATDirectDataFwdOnNg    directDataFwd
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}


Check Wireshark Log For CB013289_TC12_before
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.procedureCode == 11
    ${expect_message}=    Create list    RRC Setup Request
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Check Wireshark Log For CB013289_TC12
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=f1ap.procedureCode==11
    ${expect_message}=    Set Variable    RRC Setup Request
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}