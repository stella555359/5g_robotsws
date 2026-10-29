*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${BBMOD_MODEL}    ABIL    #Mandatory BBMOD with 5G short model name!
${SMOD_MODEL}     ASIB    #Mandatory SMOD short model name!


*** Keywords ***
TC__WebEM__Simplified_Site_View_BBMOD_and_SMOD_visualization
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22347
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case check if BBMOD and SMOD are visible in site view.
    ...  Check if BBMOD is visible in Site View.
    ...  Check if Reset button is enabled.
    ...  Check if canceling Reset operation is possible.
    ...  Check if SMOD is visible in Site View.
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22347 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    FEATURE-CB005750
    ...    PHASE-CRT    SW-SBTS21

    Step1: BBMOD visualization
    Step2: SMOD visualization


Step1: BBMOD visualization
    Log  Start Simplified Site View BBMOD and SMOD visualization test  console=true
    Log  Step1: BBMOD visualization  console=true
    ${status_bbmod}  Run keyword and return status  Element Should Be Visible  locator=//div[contains(text(), '${BBMOD_MODEL}')]
    Run keyword if  ${status_bbmod}
    ...  Log  ${BBMOD_MODEL} is visible in Site View![OK]  console=true
    ...  ELSE
    ...  Fail  ${BBMOD_MODEL} is not visible in Site View![NOK]
    SELENIUM Click Visible Element  locator=//div[contains(text(), '${BBMOD_MODEL}')]/../..//button
    ${status_reset}  Run keyword and return status  Wait Until Keyword Succeeds  120  3  Click Element
    ...  locator=//div[contains(text(), '${BBMOD_MODEL}')]/../..//button[@title='Reset']
    Run keyword if  ${status_reset}
    ...  Log  ${BBMOD_MODEL} Reset button is pushed![OK]  console=true
    ...  ELSE
    ...  Fail  ${BBMOD_MODEL} Reset button is not visible in Site View![NOK]
    ${status_cancel}  Run keyword and return status  Wait Until Keyword Succeeds  120  3  SELENIUM Click Visible Element
    ...  locator=//button[contains(text(), 'Cancel')]
    Run keyword if  ${status_cancel}
    ...  Log  ${BBMOD_MODEL} Reset action is canceled![OK]  console=true
    ...  ELSE
    ...  Fail  ${BBMOD_MODEL} Reset not canceled![NOK]
    ${status_onair}  Run keyword and return status  Element Should Be Visible
    ...  locator=//div[text()='${BBMOD_MODEL}']/../..//div[contains(@class, 'green-diode')]
    Run keyword if  ${status_onair}
    ...  Log  ${BBMOD_MODEL} is Online![OK]  console=true
    ...  ELSE
    ...  Fail  ${BBMOD_MODEL} is Online![NOK]

Step2: SMOD visualization
    Log  Step2: SMOD visualization  console=true
    Element Should Be Visible  locator=//div[contains(text(), 'SMOD-1')]
    ${status_smod}  Run keyword and return status  Element Should Be Visible
    ...  locator=//div[contains(text(), '${SMOD_MODEL}')]
    Run keyword if  ${status_smod}
    ...  Log  ${SMOD_MODEL} is visible in site View![OK]  console=true
    ...  ELSE
    ...  Fail  ${SMOD_MODEL} is not visible in site View![NOK]
    Element Should Be Visible  locator=//span[contains(@title, 'Minor Alarms')]


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown
