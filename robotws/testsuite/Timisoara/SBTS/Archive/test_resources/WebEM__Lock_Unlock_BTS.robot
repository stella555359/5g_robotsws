*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${5G_CLASSICAL_SCF}  SCF_5gClassicalBTS.xml   #SCF 5G Classical SCF is mandatory.


*** Keywords ***
TC__WebEM__Lock_Unlock_BTS
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21224
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to check some operations on 5GClassicalBTS mode.
    ...  5GClassicalBTS SCF will be uploaded
    ...  Lock/Unlock BTS will be performed with checking status cells
    ...  Site Block/Unblock, NR RAT Block/Unblock, NR RAT Reset will be checked and should not be visible
    ...  Final, initial SCF will be uploaded
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.4.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21224 - Initial TAT creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com
    ...         MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21B

    Step0: Prepare 5G SCF
    Step1: Changing configuration to 5gClassicalBTS
    Step2: Lock/Unlock BTS
    Step3: Verify SBTS buttons


Step0: Prepare 5G SCF
    Log  Step0: Prepare 5G SCF  console=true
    ${config_path}  Fetch from left  ${COMMISSIONING_PATH}  SCF
    set test variable  ${SCF_5gClassicalBTS}  ${config_path}${5G_CLASSICAL_SCF}
    Log  Path to 5G Classical Mode SCF is: ${SCF_5gClassicalBTS}  console=true
    ${block_unblock_button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/
    ...  site-runtime-views/div/div/div[1]/simplified-site-tab/toolbar/execution-bar/div/site-block-unblock/div/ui-button/button
    Set Test Variable  ${site_block_unblock_button}  ${block_unblock_button}
    ${NR_RAT_block_unblock}  Catenate  SEPARATOR=   //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/
    ...  site-runtime-views/div/div/div[1]/simplified-site-tab/toolbar/execution-bar/div/n-site-type-recognize-ui/div/rat-block-unblock/ui-select/
    ...  div/wf-dropdown/div/button
    Set Test Variable  ${NR_RAT_block_unblock_button}  ${NR_RAT_block_unblock}
    Set Test Variable  ${NR_RAT_reset_button}  //*[@id="main-view"]/div/div[1]/div[1]/div/div[2]/cells-delivery/cells-status[1]/div/div[2]/ui-button

Step1: Changing configuration to 5gClassicalBTS
    Log  Step1: Changing configuration to 5gClassicalBTS  console=true
    Admin Get bts_id and perform commissioning  ${SCF_5gClassicalBTS}
    Close BTS Start-up View
    Wait until keyword succeeds  600  10  Check NR status to be working

Step2: Lock/Unlock BTS
    Log  Step2: Lock/Unlock BTS  console=true
    Log  Lock BTS  console=true
    ${lock_unlock}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/site-runtime-views
    ...  /div/div/div[1]/simplified-site-tab/toolbar/execution-bar/div/site-lock-unlock/div/ui-button
    Click Element  ${lock_unlock}
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Sleep  60s
    Wait until keyword succeeds  300s  5s  Checking nr cells operational state  ${Disabled_}
    Log  Unlock BTS  console=true
    Click Element  ${lock_unlock}
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  Checking NR cells status  console=true
    Wait until keyword succeeds  600  10  Check NR status to be working

Step3: Verify SBTS buttons
    Log  Step3: Verify SBTS buttons  console=true
    Log  Verify site block/unblock button  console=true
    Verify buttons  ${site_block_unblock_button}
    Log  Verify NR RAT block/unblock button  console=true
    Verify buttons  ${NR_RAT_block_unblock_button}
    Log  Verify NR RAT reset button  console=true
    Verify buttons  ${NR_RAT_reset_button}

Checking nr cells operational state
    [Arguments]  ${operationalState}
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every    NRCEL    operationalState=${operationalState}  timeout=60

Verify buttons
    [Arguments]  ${button}
    ${status}  Run keyword and return status  Page Should Not Contain Element  ${button}
    Run keyword if  ${status}
    ...  Log  Button is not visible [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Button is visible [NOK]

Restore SBTS initial configuration
    Admin Get bts_id and perform commissioning  ${COMMISSIONING_PATH}
    Close BTS Start-up View
    Wait until keyword succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}


TC Setup
    Common test setup  tc_name=WebEM__Lock_Unlock_BTS
    WebEM Setup

TC Teardown
    Restore SBTS initial configuration
    WebEM Teardown
    Common test teardown
