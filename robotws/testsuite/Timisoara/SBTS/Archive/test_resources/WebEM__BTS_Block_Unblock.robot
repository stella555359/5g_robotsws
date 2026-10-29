*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  #Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__BTS_Block_Unblock
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21613
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to Block and Unblock Site.
    ...  Verify if all cells on SBTS are working.
    ...  Open Operational History View.
    ...  Block Site will be performed.
    ...  Verify if all cells have the parameter 'Blocking State'-'Blocked'.
    ...  Check if alarm with faultId '50' is visible.
    ...  Block action is checked to appear properly in Operational History View.
    ...  Unblock Site will be performed.
    ...  Verify if all cells have the parameter 'Blocking State'-'Unblocked'.
    ...  Check if alarm with faultId '50' is cleared.
    ...  Unblock action is checked to appear properly in Operational History View.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21613 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com     AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com   GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS22

    Step1: Verify cells on SBTS and Open Operations History
    Step2: Block BTS and verify alarm
    Step3: Unblock BTS and verify alarm


Step1: Verify cells on SBTS and Open Operations History
    Log  Step1: Verify cells on SBTS and Open Operations History  console=true
    Check all cells to be Unblocked
    Log  Open Operations history!  console=true
    Wait Until Keyword Succeeds  120  5  Click Element  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/div[2]/menu-bar/nav-item/div/ng-transclude/ul/li[3]

Step2: Block BTS and verify alarm
    Log  Step2: Block BTS and verify alarm  console=true
    ${button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /site-runtime-views/div/div/div[1]/simplified-site-tab/toolbar/execution-bar/div/site-block-unblock/div/ui-button
    Wait Until Keyword Succeeds  120  5  Click Element  ${button}
    ${site_status}  Get Text
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run keyword and return status  Should match regexp  ${site_status}  Block Site|Block
    ${block_button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-block-modal/ui-modal/div/div
    ...  /div[3]/div/ui-footer/ui-button[1]/button
    Run keyword if  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Block will be performed![OK]  console=true  AND
    ...  Click Element  ${block_button}
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]  console=true
    ${cells_status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10  Check all cells to be Blocked
    Run keyword if  ${cells_status}
    ...  Log  All cells are blocked![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are blocked after ${RECOVERY_TIMEOUT}s![NOK]
    Check BTS Block alarm is visible
    Verify operation in Operations History  Block

Step3: Unblock BTS and verify alarm
    Log  Step3: Unblock BTS and verify alarm  console=true
    ${button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
    ...  /site-runtime-views/div/div/div[1]/simplified-site-tab/toolbar/execution-bar/div/site-block-unblock/div/ui-button
    Wait until Element is Enabled  ${button}  300
    Wait Until Keyword Succeeds  120  5  Click Element  ${button}
    ${site_status}  Get Text
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal/div/div/div[3]/div/ui-footer/ui-button[1]
    ${status}  Run keyword and return status  Should match regexp  ${site_status}  Unblock Site|Unblock
    ${unblock_button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/site-unblock-modal/ui-modal
    ...  /div/div/div[3]/div/ui-footer/ui-button[1]/button
    Run keyword if  ${status}
    ...  Run Keywords
    ...  Log  ${site_status} button is visible and Site Unblock will be performed![OK]  console=true  AND
    ...  Click Element  ${unblock_button}  AND
    ...  Close BTS Start-up View
    ...  ELSE
    ...  Fail  ${site_status} button isn't in expected state![NOK]
    ${cells_status_blockingState}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check all cells to be Unblocked
    ${cells_status}  Run keyword and return status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run keyword if  ${cells_status_blockingState} and ${cells_status}
    ...  Log  All cells are unblocked and enabled![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are unblocked and enabled after ${RECOVERY_TIMEOUT}s![NOK]
    Check BTS Block alarm is not visible
    Verify operation in Operations History  Unblock

Check BTS Block alarm is visible
    ${active_alarm}  Get Active Alarms from WebEM
    ${status}  Run keyword and return status  Dictionary Should Contain Key  ${active_alarm}  ${FAULT_50}[fault_id]
    Run keyword if  ${status}
    ...  Log  Alarm with faultId 50 and faultName "BTS blocked" appeard![OK]  console=true
    ...  ELSE
    ...  Fail  Alarm with faultId 50 and faultName "BTS blocked" not appeard![NOK]
    Go To Site View

Check BTS Block alarm is not visible
    ${active_alarm}  Get Active Alarms from WebEM
    ${status}  Run keyword and return status  Dictionary Should Not Contain Key  ${active_alarm}  ${FAULT_50}[fault_id]
    Run keyword if  ${status}
    ...  Log  Alarm with faultId 50 and faultName "BTS blocked" is not visible![OK]  console=true
    ...  ELSE
    ...  Fail  Alarm with faultId 50 and faultName "BTS blocked" is still visible![NOK]
    Go To Site View

Check all cells to be ${blockingState}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every    WNCEL    blockingState=${blockingState}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every    LNCEL    blockingState=${blockingState}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every    GNCEL    blockingState=${blockingState}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every    NRCEL    blockingState=${blockingState}  timeout=60


TC Setup
    Common test setup  tc_name=WebEM__BTS_Block_Unblock
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown
