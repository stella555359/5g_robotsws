*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}    1200


*** Keywords ***
TC__WebEM__Reset_operation_for_BBMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22346
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case performes BBMODs Reset.
    ...  Reset BBMODs that supports 5G.
    ...  Check all cells to be enabled.
    ...  History of changes
    ...  ******************
    ...  - 22.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22346 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    FEATURE-CB005750
    ...    PHASE-CRT    SW-SBTS21

    Step1: Reset BBMODs
    Step2: Verify all cells


Step1: Reset BBMODs
    Log  Step1: Reset BBMODs  console=true
    FOR  ${xpath}  IN  @{bbmods_xpath}
      Click Element  ${xpath}
      ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
      ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
      Log  \nReset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
      Click Element  ${xpath}/div/div[1]
      ${status_reset}  Run Keyword and Return Status  Element Should be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
      Run Keyword If  ${status_reset}
      ...  Reset BBMOD  ${bbmod_number}  ${bbmod_name}  ${xpath}
      ...  ELSE  run keywords
      ...  Click element  ${xpath}/div/div[1]  AND
      ...  Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true

    END

Step2: Verify all cells
    Log  Step2: Verify all cells  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Log  All cells are Enabled!  console=true


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown
