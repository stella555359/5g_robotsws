*** Settings ***
Documentation
    ...  This test case is created to trigger remote snapshot collection.
    ...  This test case will execute Bts power reset during ongoing remote snapshot.
    ...  The operator triggers BTS power reset when remote snapshot is collecting.
    ...  BTS power reset interrupts snapshot and is performed.
    ...  The operator triggers "BTS power reset with snapshot collection" when another remote snapshot is collecting.
    ...  The NE reject user request for "BTS power reset with snapshot collection".
    ...  The message for reject is "Request rejected as snapshot process is ongoing.".

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SNAPSHOT_TIMEOUT}  60m  # Timeout for snapshot collected


*** Keywords ***
TC__WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26065
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26065 - Initial TAT creation
    ...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26930 - Use KWs from resource
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  17.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28555 - Add check for lock screen during snapshot
    ...  29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29149 - Change value parameter 'diagSnapDestination' from netact to nms
    ...  08.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29662 - Increase timeout for snapshot collection
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29892 - Change timeout for snapshot collection
    ...  20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30186 - Deintegrate and integrate again SBTS to NMS
    ...  27.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30288 - Set the expected number of disconnections from NetAct

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Set Parameters And Deintegrate SBTS From Netact
    Step2: Operator Trigger Remote Snapshot Collection
    Step3: BTS Power Reset Interrupts Snapshot And Is Performed
    Step4: Integrate BTS To NMS And Operator Triggers When Another Remote Snapshot Is Collecting


Step1: Set Parameters And Deintegrate SBTS From Netact
    Log  \nStep1: Set Parameters And Deintegrate SBTS From Netact  console=true
    ${diagSnapDestination_value}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS25R3'  nms  netact
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=diagSnapDestination  operation=update
    ...  value=${diagSnapDestination_value}  skip_parameter_relation_errors=true  timeout=180
    Log  Parameter diagSnapDestination value was changed into ${diagSnapDestination_value}!  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers  operation=update
    ...  value=true  skip_parameter_relation_errors=true  timeout=180
    Log  Parameter actDefaultFaultSnapTriggers value was changed into true!  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=maxNumSnapByFaultTrigPerDay  operation=update
    ...  value=24  skip_parameter_relation_errors=true  timeout=180
    Log  Parameter maxNumSnapByFaultTrigPerDay value was changed into 24!  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1  parameter=oamTls  operation=update  value=off
    ...  skip_parameter_relation_errors=true  timeout=180
    Log  Parameter oamTls value was changed into off!  console=true
    Log  Deintegrate MRBTS from netact!  console=true
    Deintegrate MRBTS From Netact  ${MRBTS_DN}
    Log  Deintegration from netact was done successfully!  console=true


Step2: Operator Trigger Remote Snapshot Collection
    Log  \nStep2: Operator trigger remote snapshot collection  console=true
    Collect Snapshot And Navigate To BTS Power Reset
    Wait Until Element Is Clicked  xpath=//label[text()="Power reset"]
    Wait Until Element Is Clicked  xpath=//span[contains(text(),'Execute')]
    Log  Power reset and execute are clicked!  console=true
    ${DIV_NUMBER}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Set test variable  ${DIV_NUMBER}
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button/span  120


Step3: BTS Power Reset Interrupts Snapshot And Is Performed
    Log  \nStep3: BTS power reset interrupts snapshot and is performed  console=true
    Wait Until Keyword Succeeds  120  10
    ...  Go To Site View
    Log  Site view was opened and waiting for BTS Start-up View will perform!
    Close BTS Start-up View
    Wait Until Element Is Visible  locator=//*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[3]/div[2]/div/div[2]/div[2]  timeout=180
    Wait Until Keyword Succeeds  10m  20s
    ...  ca_SBTS_general.Admin Check All Required State
    Log  \nSBTS is onAir state.  console=true


Step4: Integrate BTS To NMS And Operator Triggers When Another Remote Snapshot Is Collecting
    Log  \nStep4: Integrate BTS To NMS And Operator triggers when another remote snapshot is collecting  console=true
    Log  Integrate BTS to NMS!  console=true
    ${mplane_ip}  Admin Get MPLANE IP
    Integrate MRBTS With Netact  release=${ENB_BRANCH}  mr=MRC-COMMON/MR-COMMON  mrbts_address=${mplane_ip}  dist_name=${MRBTS_DN}
    ...  security_mode=no TLS
    Log  Integration to NMS was done successfully.  console=true
    Collect Snapshot And Navigate To BTS Power Reset
    Wait Until Element Is Clicked  xpath=//label[text()="Power reset with snapshot collection"]
    Log  Power reset with snapshot collection is choose!  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(text(),'Execute')]
    Log  Execute button was clicked!  console=true
    Wait Until Element Is Clicked  xpath:/html/body/div[${DIV_NUMBER}]/div/div[3]/ot-footer/p-button[1]/button/span  120
    Wait Until Element Is Visible  locator=//span[contains(text(),'rejected as snapshot process is ongoing.')]  timeout=120
    Log  \nMessage 'Request is rejected as snapshot process is ongoing.' appeared.  console=true
    Open Snapshot Collection
    Wait Until Keyword Succeeds  ${SNAPSHOT_TIMEOUT}  60  Check if snapshot is collected


Collect Snapshot And Navigate To BTS Power Reset
    Open Snapshot Collection
    Log  Snapshot Collection menu is open!  console=true
    Wait Until Element Is Visible  locator=//*[@id="locationRemote-aria"]  timeout=30
    Wait Until Element Is Clicked  xpath=//*[@id="locationRemote-aria"]
    Log  Remote location is choose!  console=true
    Wait Until Element Is Visible  locator=//button[contains(text(),'Collect Snapshot')]  timeout=30
    Wait Until Element Is Clicked  xpath=//button[contains(text(),'Collect Snapshot')]
    Log  Collect Snapshot button was pushed successfully!  console=true
    Open BTS Power Reset


Check if snapshot is collected
    Login On WebEM If Lock Screen Or Logout Performed
    Wait Until Element Is Visible  locator=//label[text()="Collection completed"]  timeout=10
    Log  \nSnapshot has been collected.  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__Robustness_Bts_power_reset_with_remote_snapshot
    WebEM Setup
    Setup NetAct


TC Teardown
    Teardown Netact  number_of_expected_disconnections=${1}
    WebEM Teardown
    Common Test Teardown
