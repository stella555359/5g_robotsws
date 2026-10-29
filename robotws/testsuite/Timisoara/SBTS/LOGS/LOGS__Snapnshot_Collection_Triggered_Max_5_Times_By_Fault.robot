*** Settings ***
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SITE_RESET}  ${False}  # Perform site reset before test execution
${STARTUP_TIMEOUT}  1200  # Startup timeout after site reset
${SNAPSHOT_COLLECTION_TIMEOUT}  1200  # Snapshot collection timeout


*** Keywords ***
TC__LOGS__Snapnshot_Collection_Triggered_Max_5_Times_By_Fault
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14491
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2019-03-28 - https://jira3.int.net.nokia.com/browse/TAT-14491 - Initial Creation
    ...  - 2020-04-16 - https://jira3.int.net.nokia.com/browse/TAT-17558
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 17.05.2023 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 49 is detected only max 5 times in 24hours. Fault is
    ...  added to faultSnapshotTriggers list and reported after cell block operation. This test case check only if snapshot is
    ...  triggered but it is not checking if it is correctly saved in the remote location.
    ...  *******************
    ...  Test case flowchart:
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapshot_Collection_Triggered_Max_5_Times_By_Fault.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS17

    Step 0: Preconditions
    Step 1: Configure Fault Snapshot Trigger
    Step 2: Perform Cell Block To Trigger Snapshot
    Step 3: Check If Snapshot Is Collected
    Step 4: Perform Cell Unblock
    Step 5: Perform Cell Block To Trigger Snapshot
    Step 6: Check If Snapshot Is Collected
    Step 7: Perform Cell Unblock
    Step 6: Perform Cell Block To Trigger Snapshot
    Step 7: Check If Snapshot Is Collected
    Step 8: Perform Cell Unblock
    Step 9: Perform Cell Block To Trigger Snapshot
    Step 10: Check If Snapshot Is Collected
    Step 11: Perform Cell Unblock
    Step 12: Perform Cell Block To Trigger Snapshot
    Step 13: Check If Snapshot Is Collected
    Step 14: Perform Cell Unblock
    Step 15: Perform Cell Block To Trigger Snapshot
    Step 16: Check If Snapshot Is Not Triggered


Step 0: Preconditions
    Log  \nPreconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_BLOCKED}  ${False}
    Set Test Variable  ${PREV_NUM_OF_SNAPSHOT_CANCEL_MESSAGES}  0
    ${bts_med_connection_status}  Query Infomodel  check //URI-*/SESSION-* is [type=NE3SADAPT,stateInfo.usageState=Active]  allow_negative_result=True
    Run Keyword If  ${SITE_RESET}  Perform Site Reset
    Run Keyword If  ${bts_med_connection_status}
    ...  Log  Connection to NMS is Active.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Connection to NMS is not Active.  ${TRUE}

Step 1: Configure Fault Snapshot Trigger
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for foult 49 is created and added to configuration.

    Log  \nStep 1: Configure Fault Snapshot Trigger  console=${True}
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  trigger
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo  ${SCF}  ${delta_id}
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

Step ${n}: Perform Cell Block To Trigger Snapshot
    [Documentation]
    ...  In this test step cell block operation is performed to activate fault 49.
    ...  Activation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep ${n}: Perform Cell Block To Trigger Snapshot  console=${True}
    ${CELL_DISTNAME}  Get Cell Distname
    Set Test Variable  ${CELL_DISTNAME}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked  console=${True}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${CELL_DISTNAME}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell block operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${True}

Step ${n}: Check If Snapshot Is Collected
    [Documentation]
    ...  In this test step it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep ${n}: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    ${num_of_snapshot_cancel_messages}  Count Syslog Messages  \\[Snapshot::Controller\\] \\[cancel\\] Cancel troubleshooting\\.  alias=SMOD1
    Run Keyword If  ${num_of_snapshot_cancel_messages}>${PREV_NUM_OF_SNAPSHOT_CANCEL_MESSAGES}  Run Keywords
    ...  Set Test Variable  ${PREV_NUM_OF_SNAPSHOT_CANCEL_MESSAGES}  10
    ...  AND  log  {PREV_NUM_OF_SNAPSHOT_CANCEL_MESSAGES}=${PREV_NUM_OF_SNAPSHOT_CANCEL_MESSAGES}  console=${True}
    ...  AND  Log  Snapshot cancel message found in Syslog  console=${True}  level=WARN
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Step ${n}: Perform Cell Unblock
    [Documentation]
    ...  In this test step cell unblock operation is performed.

    Log  \nStep ${n}: Perform Cell Unblock.  console=${True}
    Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${CELL_DISTNAME}
    Run Keyword If  '${unblock_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell unblock operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${False}

Step 16: Check If Snapshot Is Not Triggered
    [Documentation]
    ...  In this test step it is checked if snapshot is not triggered.

    Log  \nStep 16: Check If Snapshot Is Not Triggered  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  verdicts.Set Test Failed  Snapshot was triggered by fault.  ${TRUE}
    ...  ELSE  Log  Snapshot was not triggered by fault.  console=${True}

Perform Site Reset
    [Documentation]
    ...     BTS site reset is performed if user had set site_reset variable to True.

    Log  Perform BTS site reset  console=${True}
    coam.Reset Site  600
    Sleep  5s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}s  30s  Verify all BTS states
    Log  All cells and modules reached working state  console=yes
    bts_states.Check Active Alarms

Verify all BTS states
    ${BTS_state_is_ok}  Verify BTS proceduralState  OnAir
    ${system_modules_ok}  Verify system modules states
    ${radio_modules_ok}  Verify radio modules states
    ${GSM_onair}  Verify GSM cells states
    ${WCDMA_onair}  Verify WCDMA cells states
    ${LTE_onair}  Verify LTE cells states

    Run Keyword Unless  ${BTS_state_is_ok} and ${system_modules_ok} and ${radio_modules_ok} and ${GSM_onair} and ${WCDMA_onair} and ${LTE_onair}
    ...  Fail  At least one module, cell or BTS proceduralState indicates a faulty state!

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}

Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=49  triggerType=onFaultDetection
    ${fault_snapshot_trigger}  Evaluate Xpath  ${SCF}  //p[@name='faultNumber' and text()='49']
    Run Keyword If  '${fault_snapshot_trigger}'=='[]'  Run Keywords
    ...  Log  Adding faultSnapshotTriggers list for fault 49 to configuration.  console=${True}
    ...  AND  coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    ...  AND  Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

Get Cell Distname
    ${lncell_m_objects}  Query Infomodel  get list //LNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${lncell_m_objects}
    ...  Return From Keyword  ${lncell_m_objects[0]['dist_name']}
    ${wncell_m_objects}  Query Infomodel  get list //WNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${wncell_m_objects}
    ...  Return From Keyword  ${wncell_m_objects[0]['dist_name']}
    ${gncell_m_objects}  Query Infomodel  get list //GNCEL_R-*  allow_negative_result=True
    Run Keyword If  ${gncell_m_objects}
    ...  Return From Keyword  ${gncell_m_objects[0]['dist_name']}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${CELL_BLOCKED}  Run Keywords
    ...  Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ...  AND  coam.Unblock Cell  ${CELL_DISTNAME}

    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}

    Run Keyword If  ${TRBLCADM_MO_ADDED} and ${FAULT_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
    ...  Log  Removing TRBLCADM managed object from configuration  console=${True}
    ...  AND  coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  delete  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    ...  ELSE IF  ${FAULT_SNAPSHOT_TRIGGER_ADDED} and not ${TRBLCADM_MO_ADDED}  Run Keywords
    ...  Log  Removing faultSnapshotTriggers list from configuration  console=${True}
    ...  AND  coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  faultSnapshotTriggers  ${delta_id}
    ...  AND  coam.Get Delta  ${delta_id}
    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}

    coam.Remove All Delta Id


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
