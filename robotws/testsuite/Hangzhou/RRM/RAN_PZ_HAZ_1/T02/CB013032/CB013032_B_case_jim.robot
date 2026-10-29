*** Settings ***
Documentation
...    Author: j5liu
...    Contact: jim.3.liu@nokia-sbell.com
...    This file is used for CB013032 feature testing
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
Library           taf.ul.selenium.netact                                         WITH NAME    selenium_netact

*** Variables ***

${TESTLINE_NAME}    10_5_UTESRAN001T11283

*** Test Cases ***
CB013032_05_Advance_Filter_based_on_Related Function_in_WebEM_testline config1_current_configuration
    [Tags]    CRT    QC_69333    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    [Teardown]    Case Postcondition

CB013032_06_Advance_Filter_based_on_Related Function_in_WebEM_testline config2_planned_configuration
    [Tags]    CRT    QC_69334    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    [Teardown]    Case Postcondition

CB013032_07_Advance_Filter_based_on_Applicable RAT_in_WebEM_testline config1_current_configuration
    [Tags]    CRT    QC_69335    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    [Teardown]    Case Postcondition

CB013032_08_Advance_Filter_based_on_Applicable RAT_in_WebEM_testline config2_planned_configuration
    [Tags]    CRT    QC_69336    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    [Teardown]    Case Postcondition

CB013032_11_Advance_Filter setup with multi conditions_testline config1_current_configuration
    [Tags]    CRT    QC_69339    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
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
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword And Ignore Error    Get TestLine Name
    Run Keyword And Ignore Error    Get Expect Sw Version
    Run Keyword And Ignore Error    Prepare Netrc On VM

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}

Parameter Updated In Gnb For CB013032
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Get Parameters For CB013032
    COAM_Admin.Login
    @{para_list}    Create List   actChipsetAndRanInfoExchange
    @{mo_list}      Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ${out}          Parameter Operation    operation=parameter_value_check   product_type=gnb   para_list=${para_list}    mo_list=${mo_list}
    Log To Console    Parameter Check Result: ${out}