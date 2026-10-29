*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.selenium.gnb.oam.coam.cu         WITH NAME     vcu


*** Test Cases ***
CB001302_01
    [Tags]    CRT    case1
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;
#    Parameter Updated In Gnb For CB001302
    Get Parameter Details In vCU
    Get Parameter Details In vDU
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start Call For UE    ue_index=${0}    direction=dl
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    [Teardown]    Case Postcondition


CB001302_02
    [Tags]    CRT    case2
    [Documentation]
    ...    Author: XXXXXX@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
#    Get Advance Filter by WebEM For vDU
    Get Advance Filter by WebEM For vCU
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Common Test Setup For AIC
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}
    _Check Maximum Line Length

Common Suite Setup For AIC
    Create Suite Directory
    ${vdu_version}=    Get vDU Version
    Set Suite Variable    ${VDU_VERSION}    ${vdu_version}
    Get SSH Connection Infor For vDU K8s Master
    Get SSH Connection Infor For vCU K8s Master
    ${mrbts_id_list}    ${nrbts_id_list}    Get Multi Gnb Id
    Set suite variable     ${MRBTS_ID_LIST}    ${mrbts_id_list}
    Set suite variable     ${NRBTS_ID_LIST}    ${nrbts_id_list}
    Run Keyword And Ignore Error    Get Iperf Info
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Run Keyword And Ignore Error    Get TestLine Name From UTE Cloud
    Run Keyword And Ignore Error    Get Testline Type

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

Parameter Updated In Gnb For CB001302
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

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


Get Managed Object By Adaptation Id
    [Arguments]    ${managed_objects}    ${adaptation_id}
    FOR    ${obj}    IN    @{managed_objects}
        ${obj_adaptation_id}=    Get From Dictionary    ${obj}    adaptationId
        Run Keyword If    '${obj_adaptation_id}' == '${adaptation_id}'    Return From Keyword    ${obj}
    END
    Fail    Managed object with adaptationId ${adaptation_id} not found


Get Parameter Details In vCU
    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/NFTA_Template/parameter_config.json
    Login To vCU By Rest    gnb_index=${0}
    ${all_nidd_info}    cu.get_nidd    raw=True
    ${managed_objects}=    Get From Dictionary    ${all_nidd_info}    managedObjects
    ${context}    OperatingSystem.Get File    ${para_config_path}
    ${parameters_config_list}    json.Loads    ${context}
    ${parameters_config_list_lenth}    Get Length    ${parameters_config_list}
    FOR   ${index}    IN RANGE    ${parameters_config_list_lenth}
        ${adaptationId}=    Get From Dictionary    ${parameters_config_list[${index}]}    adaptationId_name
        ${obj}=    Get Managed Object By Adaptation Id    ${managed_objects}    ${adaptation_id}
        ${parameters}=    Get From Dictionary    ${obj}    parameters
        ${parameter_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    parameter_name
        ${param}=    Get From Dictionary    ${parameters}    ${parameter_name}
        ${simple_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    simple_name
        ${number_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    number_name
        ${check_list}=    Get From Dictionary    ${parameters_config_list[${index}]}    check_list
        ${check_list_lenth}    Get Length    ${check_list}
        FOR   ${i}    IN RANGE    ${check_list_lenth}
            ${result}=    Get From Dictionary    ${param['${simple_name}']['${number_name}']}    ${check_list[${i}]}
            Log    result: ${result}
        END
    END
    [Teardown]    Logout To vCU By Rest

Get Parameter Details In vDU
    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/NFTA_Template/parameter_config_vdu.json
    vDU Login By Rest    vdu_index=0
    ${all_nidd_info}    vdu.get_nidd    raw=True
    ${managed_objects}=    Get From Dictionary    ${all_nidd_info}    managedObjects
    ${context}    OperatingSystem.Get File    ${para_config_path}
    ${parameters_config_list}    json.Loads    ${context}
    ${parameters_config_list_lenth}    Get Length    ${parameters_config_list}
    FOR   ${index}    IN RANGE    ${parameters_config_list_lenth}
        ${adaptationId}=    Get From Dictionary    ${parameters_config_list[${index}]}    adaptationId_name
        ${obj}=    Get Managed Object By Adaptation Id    ${managed_objects}    ${adaptation_id}
        ${parameters}=    Get From Dictionary    ${obj}    parameters
        ${parameter_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    parameter_name
        ${param}=    Get From Dictionary    ${parameters}    ${parameter_name}
        ${simple_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    simple_name
        ${number_name}=    Get From Dictionary    ${parameters_config_list[${index}]}    number_name
        ${check_list}=    Get From Dictionary    ${parameters_config_list[${index}]}    check_list
        ${check_list_lenth}    Get Length    ${check_list}
        FOR   ${i}    IN RANGE    ${check_list_lenth}
            ${result}=    Get From Dictionary    ${param['${simple_name}']['${number_name}']}    ${check_list[${i}]}
            Log    result: ${result}
        END
    END
    [Teardown]    vDU Logout By Rest     vdu_index=0

Get Advance Filter by WebEM For vDU
    svdu.enable_virtual_display
    svdu.login    url=https://10.69.108.2/login  password=Nokia@123    browser=Chrome
    ...           version=COAM25R2
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    svdu.get_parameter_details    object_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                           advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vdu Logout By Selenium

Vdu Logout By Selenium
    svdu.logout
    svdu.disable_virtual_display

Get Advance Filter by WebEM For vCU
    vcu.enable_virtual_display
    vcu.login    url=https://10.107.92.18/login  password=Nokia@123    browser=Chrome
    ...           version=COAM25R2
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    vcu.get_parameter_details    object_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                           advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vcu Logout By Selenium

Vcu Logout By Selenium
    vcu.logout
    vcu.disable_virtual_display