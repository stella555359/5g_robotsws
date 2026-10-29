*** Settings ***
Documentation  Tests for Volkswagen
Library     SeleniumLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.selenium.sbts    WITH NAME    selenium_coam
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200
${DIAGNOSTIC DPDN LIST}           //div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
${DIAGNOSTIC DPDN LIST25R}        //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]
${SNAPSHOT TAB}                   //a[@href="#/diagnostic/snapshot"]
${GET SNAPSHOT}                   //ui-button[@a-text="Collect Snapshot"]
${Nemuadmin}                    //span[@ui-tooltip="User Account Management for Nemuadmin"]
${Nemuadmin 25R1}               //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/otx-user-account/div/span[3]
${Logout}                       //button[text()=' Logout']
${Logout 25R1}                  partial link:Logout

*** Keywords ***
TC__LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22135
    ...  ******************
    ...  Author: Justyna Durak
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-11-03 - https://jira3.ext.net.nokia.com/browse/TAT-22135 - Initial Creation
    ...  - 2022-01-05 - TAT-22177 resource change due to CNI-61110
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  - 03.01.23 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case checks such behaviours for remote snapshot, triggered on GUI:
    ...  - if snapshot is triggered, while connection to NetAct is inactive, it should be rejected
    ...  with relevant reason
    ...  - if snapshot is triggered, while connection to NetAct is active, it should be send
    ...  to proper server, configured in SCF
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/tree/master/testsuite/SBTS/
    ...                       LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down.png#
    ...

    Set Tags    CA-LOGS OWNER-justyna.durak@nokia.com AUTHOR-justyna.durak@nokia.com MAINTAINER-justyna.durak@nokia.com GROUP_IN_CHARGE-WRO_6_Vrf
    ...         PHASE-CRT SW-SBTS22

    Step 1: Preconditions
    Step 2: Link break simulation
    Step 3: Trigger Remote Sanpshot while NetAct is disconnected
    Step 4: Restore connection with NetAct
    Step 5: Trigger Remote Sanpshot while NetAct is reconnected
    Step 6: Check If Snapshot Is Collected

Step 1: Preconditions
    [Documentation]  Preconditions for test: BTS connected with NetAct, parameter diagSnapDestination set to netact

    Log  \nStep 1: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${bts_id}
    Set Screenshot Directory  ${BTS Files}
    Set Snapshot Destination To  NetAct
    ${bts_connection}=  coam.connect_to
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 2: Link break simulation
    [Documentation]  This step simulates S1 interface disconnection, which is accomplished via seting ETHLK-1 administrativeState locked,
    ...  then timeout for reconnection is set.

    Log  \nStep 2: Link break simulation  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=locked  skip_parameter_relation_errors=True  timeout=120
    Wait Until Keyword Succeeds  20x  15s  Check if expected alarm occurred  6202  link break
    Sleep  3minutes 30seconds

Step 3: Trigger Remote Sanpshot while NetAct is disconnected
    [Documentation]  This step triggers remote snapshot via WebEM and checks if message with information,
    ...  that snapshot request is rejected appears on screen

    Log  \nStep 3: Trigger Remote Sanpshot while NetAct is disconnected  console=${True}
    BTS_log_level.WebEM Login
    Sleep   20
#    BTS_log_level.Change Screen Lock Timeout
    sleep    20
#    Trigger Remote Snapshot    expected_msg=Request rejected due to no active link with snapshot remote destination.
    Trigger Remote Snapshot    expected_msg=Remote snapshot collection failed.
    WebEM Logout

Step 4: Restore connection with NetAct
    [Documentation]  This step simulates S1 interface reconnection, which is accomplished via seting ETHLK-1 administrativeState unlocked.

    Log  \nStep 4: Restore connection with NetAct  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=120
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200

Step 5: Trigger Remote Sanpshot while NetAct is reconnected
    [Documentation]  This step triggers remote snapshot via WebEM and checks if message with information,
    ...  that files collecting started appears on screen

    Log  \nStep 5: Trigger Remote Sanpshot while NetAct is reconnected  console=${True}
    BTS_log_level.WebEM Login
    Sleep   60
    Trigger Remote Snapshot    expected_msg=Collecting files...
    WebEM Logout

Step 6: Check If Snapshot Is Collected
    [Documentation]  In this test step it is checked if snapshot was triggered
    ...  and if collection is finished

    Log  \nStep 5: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_object}  Query Infomodel  query=get object /MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-*
    Should Contain  ${snapshot_triggering_object['stateInfo']['usageState']}  Active  msg=Snapshot was not triggered

    Log  Wait up to ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=true
    ${snapshot_collection_status}  Query Infomodel  none //MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-* is [originator=ADMIN,usageState=Active]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=true
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Trigger Remote Snapshot
    [Documentation]  Triggers remote snapshot via selenium and waits until
    ...  relevant message appears on screen
    [Arguments]    ${expected_msg}
#    ${DIAGNOSTIC DPDN LIST}    Set Variable If    '${sbts version}'=='SBTS25'    ${DIAGNOSTIC DPDN LIST25R}
#    ...                                                ${DIAGNOSTIC DPDN LIST}
    Click Element    xpath=${DIAGNOSTIC DPDN LIST25R}
    Run Keyword If  '${sbts version}'=='SBTS24'    Click Element    xpath=${SNAPSHOT TAB}
    Click Element  xpath=//label[@for="locationRemote"]
    Click Element    xpath=${GET SNAPSHOT}
#    Wait Until Keyword Succeeds  1min  2s  Click Element  xpath=//span[@ui-tooltip="Diagnostic"]
#    Click Element  xpath=//span[text()="Snapshot"]
#    Click Element  xpath=//label[@for="locationRemote"]
#    Capture Page Screenshot
#    Click Element  xpath=//button[text()=" Collect Snapshot"]
#    Capture Page Screenshot
    Wait Until Page Contains Element  xpath=//label[text()="${expected_msg}"]  timeout=220s
    Capture Page Screenshot

WebEM Logout
#    ${Nemuadmin}    Set Variable If    '${sbts version}'=='SBTS25'    ${Nemuadmin 25R1}
#    ...                                                ${Nemuadmin}
    Wait Until Keyword Succeeds  1min  2s  Click Element  ${Nemuadmin 25R1}
    Sleep   10
#    ${Logout}    Set Variable If    '${sbts version}'=='SBTS25'    ${Logout 25R1}
#    ...                                                ${Logout}
    Wait Until Keyword Succeeds  1min  2s  Click Element  ${Logout 25R1}
#    Click Element   partial link:Logout
    Sleep   2
    Capture Page Screenshot

Check if expected alarm occurred
    [Arguments]  ${fault_ID}  ${reason}
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${active_faults_ids}  Get fault IDs from active alarms  ${active_alarms}
    ${expected_fault}  Convert To Integer  ${fault_ID}
    List Should Contain Value  ${active_faults_ids}  ${expected_fault}  msg=Fail: Fault ${fault_ID} is expected due to ${reason}

Get fault IDs from active alarms
    [Arguments]  ${alarms}
    ${faults_ids}  Create List
    FOR  ${alarm}  IN  @{alarms}
        ${fault_id}  Get From Dictionary  ${alarm}  faultId
        Append To list  ${faults_ids}  ${fault_id}
    END
    [Return]  ${faults_ids}

Check If Any Critical Alarm Is Raised
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${severity_list}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        ${severity}  Get From Dictionary  ${alarm}  severity
        Append To list  ${severity_list}  ${severity}
    END
    Log  ${severity_list}
    Should Not Contain  ${severity_list}  Critical  msg=Critical alarm occured

Custom Test Teardown
    Log  Custom Test Teardown - undo delta changes  console=true
    ${ethlk_conf}  Query Infomodel
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/TNLSVC_CONF_M-*/TNL_CONF_M-*/ETHSVC_CONF_M-*/ETHLK_CONF_M-*
    Run Keyword Unless  '${ethlk_conf['administrativeState']}'=='unlocked'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=120
    ...  AND  Wait Until Keyword Succeeds  10m  30s  Check All Modules And All Cells Working States
    ...  AND  Log  S1 interface is reconnected  console=true
    Wait Until Keyword Succeeds  10m  10s  Check If Any Critical Alarm Is Raised
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
