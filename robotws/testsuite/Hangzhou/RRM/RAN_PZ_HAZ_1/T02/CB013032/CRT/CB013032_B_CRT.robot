*** Settings ***
Documentation
...    Author: dotong
...    Contact: dongjun.tong@nokia-sbell.com
...    This file is used for CB013032 feature testing
...    Please do not modify the file without notification to author

Suite Setup    Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../../T02/Common_Case/common_resource_new.robot
Library           taf.selenium.sbts                                        WITH NAME    SBTS


*** Variables ***
@{applicable_rat}      5G
@{related_function}      Carrier Aggregation

*** Test Cases ***
CB013032_01_Parameters_under_MNL/EQM/TNL/NRBTS_Related Functions_check_in_WebEM_testline config1
    [Tags]    CRT    QC_162367   QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: dongjun.tong@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    COAM_Admin.Logout
    CB013032 detail
    [Teardown]    Case Postcondition

CB013032_60_Advance_filter_check_in WebEM when login_via_different_user_roles_in classical site
    [Tags]    CRT    QC_167584   QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: dongjun.tong@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Test Case 60
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
    @{para_list}          Create List    actNrDc
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    enabled
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Get Parameters For CB013032
    COAM_Admin.Login
    @{para_list}    Create List   actNrDc
    @{mo_list}      Create List   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ${out}          Parameter Operation    operation=parameter_value_check   product_type=gnb   para_list=${para_list}
    ...             mo_list=${mo_list}
    Log To Console    Parameter Check Result: ${out}
    COAM_Admin.Login
CB013032 detail
   selenium_coam.enable_virtual_display
   SBTS.Login   url=https://10.56.201.211/    username=Nemuadmin    password=nemuuser    download_dir=/tmp
   ...          timeout=120    version=SBTS26R1    browser=Firefox

    SBTS.Disable Message Box
    SBTS.Disable Screen Lock

    ${result} =    SBTS.Get Parameter Details     dist_name=MRBTS-37096    filter_param=GPS antenna altitude
    ${result} =    SBTS.Get Parameter Details     dist_name=MRBTS-37096/NRBTS-37096/NRCELL-1
    ...      filter_param=A1 measurement configuration for handover enabled
    ${result} =    SBTS.Get Parameter Details     dist_name=MRBTS-37096/MNL-1/AMGR-1
    ...     filter_param=Activate CNUM LDAP client account supervision
    SBTS.close_browser

Test Case 60
    selenium_coam.enable_virtual_display
    SBTS.Login   url=https://10.56.201.211/    username=Nemuadmin    password=nemuuser    download_dir=/tmp
    ...    timeout=120    version=SBTS26R1    browser=Firefox

    SBTS.Disable Message Box
    SBTS.Disable Screen Lock

    ${result} =    SBTS.Get Parameter Details By Advanced Filter     applicable_rat=${applicable_rat}
    ...            related_function=${related_function}    related_parameter=carrierAggregationSupportList


    SBTS.close_browser

