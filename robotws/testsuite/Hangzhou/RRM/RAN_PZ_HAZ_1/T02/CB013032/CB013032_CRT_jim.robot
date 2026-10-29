*** Settings ***
Documentation
...    Author: j5liu
...    Contact: jim.3.liu@nokia-sbell.com
...    This file is used for CB013032 feature testing
...    Please do not modify the file without notification to author
...    Updated case 5 by j5liu 2025/03/18

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
&{NETACT}              was_host=10.107.245.83    fm_host=10.107.245.83    user=omc    password=Nokia123!
...                    url=https://qin6lbwas.qin6.srnhz.nsn-rdnet.net/authentication/Login
&{CHEN2_AUTH}          url=https://10.68.148.38/dana-na/auth/url_default/welcome.cgi
...                    username=j5liu@nsn-intra
...                    password=Louis872101
&{OIB}                 category_xpath=//*[@id="calypso-container"]/div[2]/div/a[6]/img
...                    page_xpath=//*[@id="calypso-container"]/div[2]/div/a[27]/img
...                    page_name=OIB
...                    release=NRBTSCL25R2_2502_101
...                    release_xpath=//*[@id="releaseDropDowncomboboxField"]
...                    lookfor_xpath=//*[@id="quickSearchValue"]
...                    parameter_xpath=//*[@id="tabBar__topLevel_3"]/table/tbody/tr/td[2]
...                    detail_xpath=//*[@id="cmdataTable:wrList:0:0:detailId0"]
...                    aibdetail_xpath=//*[@id="aibDetail"]/div[14]/div[2]
${MO_ADDR}             2212/NRBTS-2212/NRCELL-4/NRHOIF-1

*** Test Cases ***
CB013032_05_Advance_Filter_based_on_Related Function_in_WebEM_testline config1_current_configuration
    [Tags]    CRT    QC_167583    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    COAM_Admin.Login
    Parameter Updated In Gnb For CB013032
    Get Parameters For CB013032
    [Teardown]    Case Postcondition

CB013032_17_Applicable RAT_check for_ parameters_under_MNL-EQM-TNL-NRBTS_in_CM Editor_MantaRay_testline config1
    [Tags]    CRT    QC_129708    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jim.3.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Get Actual Configuration MO Data   mo_id=PLMN-PLMN/MRBTS-${MO_ADDR}
    Sleep    10s
    [Teardown]    Case Postcondition

*** Keywords ***

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
    COAM_Admin.Login

Setup NetAct
    [Arguments]     ${NETACT}
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}    alias=netrc_server
#    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}    alias=netrc_server
    ${web_url}=    netact.Detect WEB URL    alias=netrc_server
    netact.Add WEB URL    ${web_url}    ${NETACT['user']}    ${NETACT['password']}    alias=netrc_server

Teardown NetAct
    netact.Delete Node    cmwas     alias=netrc_server
#    netact.Delete Node    fmwas
    netact.Clean All     alias=netrc_server

Get Actual Configuration MO Data
    [Arguments]    ${mo_id}
    Setup NetAct    NETACT=${NETACT}
    ${actual_conf}=    netact.Get Actual Configuration    alias=netrc_server
    ${managed_object}=    netact.Get Managed Object    ${actual_conf}    ${mo_id}    alias=netrc_server
    Log    \nManaged Object: ${managed_object}    console=${TRUE}
    Log    Meta Class: ${managed_object.meta_class}    console=${TRUE}
    Log    Meta Version: ${managed_object.meta_version}    console=${TRUE}
    Log    Parameters: ${managed_object.parameters}    console=${TRUE}
    [RETURN]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}
    [Teardown]    Teardown NetAct

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