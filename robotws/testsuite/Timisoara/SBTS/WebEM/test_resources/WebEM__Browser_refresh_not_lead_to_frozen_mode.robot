*** Settings ***
Documentation
    ...  This test case is created to check if all components are prezent in WebEM ADMIN after 10 reloads of page.
    ...  ADMIN connected from expected WEB browser and started without any errors.
    ...  All HW components are properly visible.
    ...  Refresh ADMIN Web Browser for 10 times and check if all components are present after each reload.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Browser_refresh_not_lead_to_frozen_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23226
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23226 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS23

    Step1: Check If All Components Are Correctly Displayed In ADMIN Interface
    Step2: Refresh ADMIN Web Browser


Step1: Check If All Components Are Correctly Displayed In ADMIN Interface
    Log  \nStep1: Check if all components are correctly displayed in ADMIN interface  console=true
    Wait Until Element Is Visible  locator=//*[@id="simplifiedSiteContainer"]/div/div/div[2]  timeout=200
    ${xpaths}  Combine Lists  ${SMODS_XPATH}  ${BBMODS_XPATH}  ${RMODS_XPATH}
    FOR  ${xpath}  IN  @{xpaths}
        Wait Until Element Is Visible  locator=${xpath}  timeout=20
    END
    Log  All HW components are present in the ADMIN Web Browser.  console=true


Step2: Refresh ADMIN Web Browser
    Log  \nStep2: Refresh ADMIN Web Browser  console=true
    FOR  ${refresh_index}  IN RANGE  0  10
        Reload Page
        ${status}  Run Keyword And Return Status
        ...  Wait Until Element Is Visible  locator=//*[@id="simplifiedSiteContainer"]/div/div/div[2]  timeout=60
        Run Keyword If  ${status}==${FALSE}
        ...  Fail  ADMIN Web Browser failed.
    END
    Log  All HW components are properly displayed in ADMIN Web Browser after 10 reloads.  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
