*** Settings ***
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200

*** Keywords ***
TC__LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination
    [Documentation]
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-05-30 - Radu Turcu - Test rewritten based on WRO_6_Vrf test -
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 49 is cancelled. Fault is
    ...  added to faultSnapshotTriggers list and reported after cell block.
    ...  *******************
    [Arguments]  ${triggerType}

    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-RP002771

    Step 0: Preconditions
    Step 1: Configure Fault Snapshot Trigger    ${triggerType}
    Step 2: Perform Cell Block To Trigger Snapshot
    Step 3: Check If Snapshot Is Collected
#    Step 4: Perform Cell Unblock


Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_BLOCKED}  ${False}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    coam.Reset Site
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}

    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 1: Configure Fault Snapshot Trigger
    [Arguments]  ${triggerType}=onFaultDetection
    [Documentation]
    ...  In this step faultSnapshotTriggers list for foult 49 is created and added to configuration.

    Log  \nStep 1: Configure Fault Snapshot Trigger  console=${True}
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  fault
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Run Keyword If  '${trblcadm_element}'=='[]'
    ...  Create Trblcadm Mo  ${SCF}  ${delta_id}
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    49    ${triggerType}

Step 2: Perform Cell Block To Trigger Snapshot
    [Documentation]
    ...  In this step cell block and unblock operations are performed to activate fault 49.
    ...  Cancellation of fault 49 will cause snapshot to automatically trigger.

    Log  \nStep 2: Perform Cell Block/Unblock  console=${True}
    ${CELL_DISTNAME}  Get Cell Distname
    Set Test Variable  ${CELL_DISTNAME}
    Log  Cell with distname ${CELL_DISTNAME} will be blocked  console=${True}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${CELL_DISTNAME}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell block operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${True}
    Wait Until Keyword Succeeds  3m  10s  coam.Assert Alarm Active  faultId=49
    Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${CELL_DISTNAME}
    Run Keyword If  '${unblock_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell unblock operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${False}

Step 3: Check If Snapshot Is Collected
    [Documentation]
    ...  In this step it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep 3: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault 49 cancellation.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault 49 cancellation.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}


Step 4: Perform Cell Unblock
    Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${CELL_DISTNAME}
    Run Keyword If  '${unblock_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
    ...  ELSE  Run Keywords  Log  Cell unblock operation successful.  console=${True}
    ...  AND  Set Test Variable  ${CELL_BLOCKED}  ${False}

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  24  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  lss  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    49    onFaultDetection

Create Fault Snapshot Triggers
    [Arguments]  ${SCF}  ${delta_id}   ${faultNumber}   ${triggerType}
    ${fault_snapshot_triggers_dict}  Create Dictionary  faultNumber=${faultNumber}  triggerType=${triggerType}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actDefaultFaultSnapTriggers  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  24  ${delta_id}
    coam.Append Complex Item To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  list_name=faultSnapshotTriggers  &{fault_snapshot_triggers_dict}
    ...  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${True}

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


Step 4: Check If Snapshot Is Collected on NMS
    [Arguments]  ${i}
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep 3.2.${i}: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection",stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by fault.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by fault.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}


Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}
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


