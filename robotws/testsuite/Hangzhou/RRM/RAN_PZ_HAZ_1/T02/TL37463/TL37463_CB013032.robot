*** Settings ***
Documentation
...    Author: Zhao Lanhua
...    Contact: lanhua.zhao@nokia-sbell.com
...    This file is for CRT regression cases in TL37463.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown     Custom Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    60 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.selenium.gnb.oam.coam.cu         WITH NAME     vcu

*** Variables ***
${TESTLINE_NAME}             7_5_UTE5GAIC025T006

*** Test Cases ***
CB013032_32_Parameters_under_MNL-EQM-TNL-NRBTS_Related Functions_check_in_WebEM_testline config1
    [Tags]    CRT    CB013032    METADATA
    [Documentation]
    ...    Author: lanhua.zhao@nokia-sbell.com
    ...    history change: 06.03.2025,lanhua.zhao@nokia-sbell.com draft
    [Setup]    Common Case Precondition
    Get Parameter Details In vCU
    Get Parameter Details In vDU
    [Teardown]    Common Case Postcondition

CB013032_59_Advance_filter_check_in WebEM when login_via_different_user_roles_in_vCU_VDU
    [Tags]    CRT    CB013032    FILTER
    [Documentation]
    ...    Author: lanhua.zhao@nokia-sbell.com
    ...    history change: 11.03.2025,lanhua.zhao@nokia-sbell.com draft
    [Setup]    Common Case Precondition
    Log To Console    \nlogin vDU as Nemuadmin
    Get Advance Filter by WebEM For vDU
    Log To Console    \nlogin vCU as Nemuadmin
    Get Advance Filter by WebEM For vCU
    Log To Console    \nlogin vDU as BTSSecurity
    Get Advance Filter by WebEM For vDU as BTSSecurityAdministrator
    Log To Console    \nlogin vCU as BTSSecurity
    Get Advance Filter by WebEM For vCU as BTSSecurityAdministrator
    Log To Console    \nlogin vDU as BTSApplication
    Get Advance Filter by WebEM For vDU as BTSApplicationAdministrator
    Log To Console    \nlogin vCU as BTSApplication
    Get Advance Filter by WebEM For vCU as BTSApplicationAdministrator
    Log To Console    \nlogin vDU as BTSRead
    Get Advance Filter by WebEM For vDU as BTSReadOnlyUser
    Log To Console    \nlogin vCU as BTSRead
    Get Advance Filter by WebEM For vCU as BTSReadOnlyUser
    [Teardown]    Common Case Postcondition

*** Keywords ***
Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}    Get Test Case Name
    Set Test Variable    ${NEW_PLAN_NAME}

Common Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error    svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error    vDU Logout By Rest
    Run Keyword And Ignore Error    Detach UE0
    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
    ...                                                             conn=${conn}    timeout=${timeout}

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}

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

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}
    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

######################################### CB013032 ########################################
Get Managed Object By Adaptation Id
    [Arguments]    ${managed_objects}    ${adaptation_id}
    FOR    ${obj}    IN    @{managed_objects}
        ${obj_adaptation_id}=    Get From Dictionary    ${obj}    adaptationId
        Run Keyword If    '${obj_adaptation_id}' == '${adaptation_id}'    Return From Keyword    ${obj}
    END
    Fail    Managed object with adaptationId ${adaptation_id} not found

Get Parameter Details In vCU
    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL37014/parameter_config_vcu.json
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
    [Arguments]    ${para_config_path}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL37014/parameter_config_vdu.json
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
    svdu.login    url=https://10.70.85.66/login    password=Nokia@123    browser=Chrome
    ...           version=COAM25R2     username=Nemuadmin
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    svdu.get_parameter_details    object_name=MRBTS-37469/NRBTS-37463
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                          advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vdu Logout By Selenium

Vdu Logout By Selenium
    svdu.logout
    svdu.disable_virtual_display

Get Advance Filter by WebEM For vCU
    vcu.enable_virtual_display
    vcu.login    url=https://10.107.104.171/login    password=Nokia@123    browser=Chrome
    ...           version=COAM25R2    username=Nemuadmin
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

Get Advance Filter by WebEM For vDU as BTSSecurityAdministrator
    svdu.enable_virtual_display
    svdu.login    url=https://10.70.85.66/login    password=Secuser_01!    browser=Chrome
    ...           version=COAM25R2     username=BTSSecurity
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    svdu.get_parameter_details    object_name=MRBTS-37469/NRBTS-37463
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                          advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vdu Logout By Selenium

Get Advance Filter by WebEM For vDU as BTSApplicationAdministrator
    svdu.enable_virtual_display
    svdu.login    url=https://10.70.85.66/login    password=Apluser_01!    browser=Chrome
    ...           version=COAM25R2     username=BTSApplication
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    svdu.get_parameter_details    object_name=MRBTS-37469/NRBTS-37463
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                          advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vdu Logout By Selenium

Get Advance Filter by WebEM For vDU as BTSReadOnlyUser
    svdu.enable_virtual_display
    svdu.login    url=https://10.70.85.66/login    password=Readuser_01!    browser=Chrome
    ...           version=COAM25R2     username=BTSRead
    ${advanced_filter_related_function}    Create List    Carrier Aggregation
    ${parameter_detailed}    svdu.get_parameter_details    object_name=MRBTS-37469/NRBTS-37463
    ...                           filter_param=Activate buffer-based SCell addition
    ...                           abbreviation=actBufferBasedSCellAddition
    ...                           advanced_filter=True
    ...                           advanced_filter_related_function=${advanced_filter_related_function}
#    ...                          advanced_filter_related_parameter=none
    ...                           timeout=10
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related functions
    ${related_function}=    Get From Dictionary    ${parameter_detailed}    Related parameters
    [Teardown]    Vdu Logout By Selenium

Get Advance Filter by WebEM For vCU as BTSSecurityAdministrator
    vcu.enable_virtual_display
    vcu.login    url=https://10.107.104.171/login    password=Secuser_01!    browser=Chrome
    ...           version=COAM25R2    username=BTSSecurity
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

Get Advance Filter by WebEM For vCU as BTSApplicationAdministrator
    vcu.enable_virtual_display
    vcu.login    url=https://10.107.104.171/login    password=Apluser_01!    browser=Chrome
    ...           version=COAM25R2    username=BTSApplication
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

Get Advance Filter by WebEM For vCU as BTSReadOnlyUser
    vcu.enable_virtual_display
    vcu.login    url=https://10.107.104.171/login    password=Readuser_01!    browser=Chrome
    ...           version=COAM25R2    username=BTSRead
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