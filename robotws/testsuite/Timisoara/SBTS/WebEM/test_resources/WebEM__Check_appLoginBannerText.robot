*** Settings ***
Documentation
    ...  This test case is created to perform changes on appLoginBannerText parameter.
    ...  The initial value of the parameter is displayed.
    ...  Change appLoginBannerText parameter
    ...  Logout from WebEM.
    ...  WebEM login.
    ...  Verify if parameter was change.
    ...  Change appLoginBannerText parameter in initial value.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Check_appLoginBannerText
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22349
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22349 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21

    Step1: Change AppLoginBannerText Parameter


Step1: Change AppLoginBannerText Parameter
    Log  Change appLoginBannerText parameter  console=true
    Log  appLoginBannerText initial value is: \n ${BANNER_TEXT}  console=true
    Set Test Variable  ${BANNER_TEXT_BEFORE}  ${BANNER_TEXT}
    ${status}  Run Keyword And Return Status
    ...  Change AppLoginBannerText Parameter  example_text
    Run Keyword If  ${status}
    ...  Log  appLoginBannerText parameter value is changed![OK]  console=true
    ...  ELSE
    ...  Fail  appLoginBannerText parameter value is not change![NOK]
    Wait Until Keyword Succeeds  300  10
    ...  Logout From SBTS
    Login SBTS
    Legal Notice
    ${status_after_change}  Run Keyword And Return Status
    ...  Should Contain  ${BANNER_TEXT}  example_text
    Run Keyword If  ${status_after_change}
    ...  Log  appLoginBannerText value after change is: \n ${BANNER_TEXT}! [OK]  console=true
    ...  ELSE
    ...  Fail  appLoginBannerText value after change is incorrect![NOK]


Change AppLoginBannerText Parameter
    [Arguments]  ${app_login_banner_text}

    ${bts_info}  Get_bts_info
    ${mrbts}  Set Variable  ${bts_info["id"]["configuration"]}
    Perform_parameter_recommissioning  dist_name=${mrbts}/MNL-1/MNLENT-1/SECADM-1  parameter=appLoginBannerText  value=${app_login_banner_text}
    ...  operation=update  skip_parameter_relation_errors=true  timeout=900


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    Change AppLoginBannerText Parameter  ${BANNER_TEXT_BEFORE}
    WebEM Teardown
    Common Test Teardown
