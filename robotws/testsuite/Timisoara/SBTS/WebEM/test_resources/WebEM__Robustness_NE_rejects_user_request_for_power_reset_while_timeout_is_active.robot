*** Settings ***
Documentation
    ...  This test case is created to perform BBMOD power reset operation while BBMOD is not OnAir yet.
    ...  In this test case the FSP/BTS power reset operation will be rejected while timeout is active.
    ...  Operator checks that BBMOD power reset operation cannot be perform successfully after SW upgrade/site reset operation
    ...  while BBMOD is not OnAir yet.
    ...  The BTS is stopped and restarted.
    ...  Operator checks that FSP/BTS power reset operation cannot be done successfully while BTS is restarted.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26065
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26066 - Initial TAT creation
    ...  20.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26931 - Text changed
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  09.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30500 - XPath has been changed for the selected BBMOD

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Perform Site Reset
    Step2: Checks BBMOD Power Reset Operation While BBMOD Is Not OnAir Yet
    Step3: Operator Powers OFF And ON The BTS
    Step4: Checks BBMOD Power Reset Operation While BBMOD Is Not OnAir Yet


Step1: Perform Site Reset
    Log  \nStep1: Perform site reset  console=true
    Reset SBTS From Admin


Step${index}: Checks BBMOD Power Reset Operation While BBMOD Is Not OnAir Yet
    Log  \nStep${index}: Checks BBMOD power reset operation while BBMOD is not OnAir yet  console=true
    Open Baseband Module Power Reset
    Click Element  xpath=//bbmod-power-reset/div/div[1]/div[2]/p-listbox/div/div[2]/ul/li[1]/div/div
    Wait Until Element Is Clicked  //*[contains(text(), 'Execute')]  200
    ${div_number}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Wait Until Element Is Clicked  xpath:/html/body/div[${div_number}]/div/div[3]/ot-footer/p-button[1]/button/span  120
    IF  '${ENB_BRANCH}' >= 'SBTS24R2'
        Wait Until Element Is Visible  //*[contains(text(),'Power reset is rejected as HW is not ready for cold reset.')]  180
        Log  \nMessage 'Power reset is rejected as HW is not ready for cold reset.' appeared.  console=true
    ELSE
        Wait Until Element Is Visible  //*[contains(text(),'Power reset rejected as HW is not ready for cold reset.')]  180
        Log  \nMessage 'Power reset rejected as HW is not ready for cold reset.' appeared.  console=true
    END
    Wait Until Keyword Succeeds  10m  20s
    ...  ca_SBTS_general.Admin Check All Required State
    Log  \nSBTS is onAir state.  console=true


Step3: Operator Powers OFF And ON The BTS
    Log  \nStep3: Operator powers OFF and ON the BTS  console=true
    Wait Until Keyword Succeeds  200  5
    ...  Go To Site View
    Power SBTS  off
    Wait Until Element Is Visible  locator=//*[@id="simplifiedSiteContainer"]/div  timeout=400
    Power SBTS  on
    Close BTS Start-up View


TC Setup
    Common Test Setup  tc_name=WebEM__Robustness_NE_rejects_power_reset_request
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
