*** Settings ***
Documentation  TC Snapshot upload to external server
Library         SeleniumLibrary
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/BTS_log_level.robot

*** Variables ***
${DIAGNOSTIC DPDN LIST}           //div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
${DIAGNOSTIC DPDN LIST25R}        //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]
${SNAPSHOT TAB}                   //a[@href="#/diagnostic/snapshot"]
${GET SNAPSHOT}                   //ui-button[@a-text="Collect Snapshot"]
${Nemuadmin}                    //span[@ui-tooltip="User Account Management for Nemuadmin"]
${Nemuadmin 25R1}               //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/otx-user-account/div/span[3]
${Logout}                       //button[text()=' Logout']
${Logout 25R1}                  partial link:Logout

*** Keywords ***
TC__LOGS__Snapshot_upload_to_external_server_long_link_break
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22547
    ...  ******************
    ...  Author: Justyna Durak
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-01-21 - https://jira3.ext.net.nokia.com/browse/TAT-22547 - Initial Creation
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - https://jiradc.ext.net.nokia.com/browse/TAT-24824 - TC Verified and updated
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-01-03 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case checks such behaviour: if connection with external server will be lost after triggering
    ...  remote snapshot, then snapshot collection should be aborted. Connection lost is simulated via
    ...  disconnecting S1 interface.
    ...  *******************
    ...  Test case flowchart:
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_upload_to_external_server_long_link_break.png#
    ...

    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-justyna.durak@nokia.com     MAINTAINER-damian.kotula@nokia.com
    ...         GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R2

    Step 1: Preconditions
    Step 2: Trigger Remote Snapshot And Disconnect S1 Interface
    Step 3: Restore Connection With S1 Interface

Step 1: Preconditions
    [Documentation]  Preconditions for test: BTS connected with NetAct, parameter diagSnapDestination set to netact

    Log  \nStep 1: Preconditions  console=${True}
    Set Screenshot Directory  ${BTS Files}
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.Get Sw Release Name
    Set Test Variable  ${enb_release}
    Check If NetAct Is Deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 2: Trigger Remote Snapshot And Disconnect S1 Interface
    [Documentation]  This step triggers remote snapshot via WebEM and checks if message with information,
    ...  that files collecting started appears on screen, then simulates S1 interface disconnection
    ...  and wait for message "Remote snapshot collection failed."

    Log  \nStep 2: Trigger Remote Sanpshot and disconnect S1 interface, wait for snapshot abortion  console=${True}
    BTS_log_level.WebEM Login
    Sleep   5
#    BTS_log_level.Change Screen Lock Timeout
    Sleep   5
    Trigger Remote Snapshot    expected_msg=Collecting files...
    Link Break Simulation
    Check Remote Snapshot Result
    [Teardown]   WebEM Logout

Step 3: Restore Connection With S1 Interface
    [Documentation]  This step simulates S1 interface reconnection, which is accomplished via seting ETHLK-1 administrativeState unlocked.

    Log  \nStep 3: Restore connection with S1 interface  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=240
    Wait Until Keyword Succeeds  10m  30s  Check All Modules And All Cells Working States

Check Remote Snapshot Result
    [Documentation]   This KW wait until message "Remote snapshot collection failed." appears,
    ...  it can be used only if WebEM session is already open and after remote snapshot was triggered
    Wait Until Page Contains Element  xpath=//label[text()="Remote snapshot collection failed."]  timeout=900s
    Capture Page Screenshot

Link Break Simulation
    [Documentation]  This KW simulates S1 interface disconnection, which is accomplished via seting ETHLK-1 administrativeState locked,
    ...  then timeout for reconnection is set.
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=locked  skip_parameter_relation_errors=True  timeout=240
    Wait Until Keyword Succeeds  5m  10s  Check If Expected Alarm Occurred  6202  link break

Trigger Remote Snapshot
    [Documentation]  Triggers remote snapshot via selenium and waits until
    ...  relevant message appears on screen
    [Arguments]    ${expected_msg}
#    Wait Until Keyword Succeeds  1min  2s  Click Element  xpath=//span[@ui-tooltip="Diagnostic"]
#    Click Element  xpath=//span[text()="Snapshot"]
#    Click Element  xpath=//label[@for="locationRemote"]
#    Capture Page Screenshot
#    Click Element  xpath=//button[text()=" Collect Snapshot"]
#    Capture Page Screenshot
#    Wait Until Page Contains Element  xpath=//label[text()="${expected_msg}"]  timeout=120s
#    Capture Page Screenshot
#    ${DIAGNOSTIC DPDN LIST}    Set Variable If    '${sbts version}'=='SBTS26'    ${DIAGNOSTIC DPDN LIST25R}
#    ...                                                ${DIAGNOSTIC DPDN LIST}
    Click Element    xpath=${DIAGNOSTIC DPDN LIST25R}
#    Run Keyword If  '${sbts version}'=='SBTS24'    Click Element    xpath=${SNAPSHOT TAB}
    Click Element  xpath=//label[@for="locationRemote"]
    Capture Page Screenshot
    Click Element    xpath=${GET SNAPSHOT}
    Wait Until Page Contains Element  xpath=//label[text()="${expected_msg}"]  timeout=120s
    Capture Page Screenshot

WebEM Logout
    [Documentation]  Triggers WebEm logout via selenium
#    Wait Until Keyword Succeeds  1min  2s  Click Element  xpath=//span[@ui-tooltip="User Account Management for Nemuadmin"]
#    Click Element  xpath=//button[text()=' Logout']
#    ${Nemuadmin}    Set Variable If    '${sbts version}'=='SBTS26'    ${Nemuadmin 25R1}
#    ...                                                ${Nemuadmin}
    Wait Until Keyword Succeeds  1min  2s  Click Element  ${Nemuadmin 25R1}
    Sleep   10
#    ${Logout}    Set Variable If    '${sbts version}'=='SBTS26'    ${Logout 25R1}
#    ...                                                ${Logout}
    Wait Until Keyword Succeeds  1min  2s  Click Element  ${Logout 25R1}
#    Click Element   partial link:Logout
    Sleep   2
    Capture Page Screenshot

Check If Expected Alarm Occurred
    [Documentation]  This KW downloads list of active alarms and checks if expected fault is on the list.
    [Arguments]  ${fault_ID}  ${reason}
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${active_faults_ids}  Get Fault IDs From Active Alarms  ${active_alarms}
    ${expected_fault}  Convert To Integer  ${fault_ID}
    List Should Contain Value  ${active_faults_ids}  ${expected_fault}  msg=Fail: Fault ${fault_ID} is expected due to ${reason}

Get Fault IDs From Active Alarms
    [Documentation]  This KW creates a list of fault IDs from list of active alarms.
    [Arguments]  ${alarms}
    ${faults_ids}  Create List
    FOR  ${alarm}  IN  @{alarms}
      ${fault_id}  Get From Dictionary  ${alarm}  faultId
      Append To list  ${faults_ids}  ${fault_id}
    END
    [Return]  ${faults_ids}

Custom Test Teardown
    Log  Custom Test Teardown  console=true
    ${ethlk_conf}  Query Infomodel
    ...  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/TNLSVC_CONF_M-*/TNL_CONF_M-*/ETHSVC_CONF_M-*/ETHLK_CONF_M-*
    Run Keyword If  '${ethlk_conf['administrativeState']}'=='locked'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=240
    ...  AND  Wait Until Keyword Succeeds  10m  30s  Check All Modules And All Cells Working States
    ...  AND  Log  S1 interface is reconnected  console=true
    Wait Until Keyword Succeeds  10m  10s  Check If There Are No Critical Alarms
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Sleep    300
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
