*** Settings ***
Library    XML    use_lxml=${TRUE}
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2700


*** Keywords ***
TC__LOGS__Snapshot_collection__Triggers_persistent_over_resets
    [Documentation]
    ...  ******************
    ...  Author: Radu Turcu
    ...  ******************

    Step 1: Test preconditions
    Step 2: Configure Fault Snapshot Trigger 49
    Step 3: Execute reset site
    Step 4: Check fault 49 still exist after reset


Step 1: Test preconditions
    Log  \nStep 1 Preconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_ADDED}  ${False}
    ${bts_connection}=  coam.connect_to
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
#    Log  Reset ongoing    console=${True}
#    coam.Reset Site
#    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
#    Log    Reset site done    console=${TRUE}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${BTS_ID}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
#    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
#    Check if NetAct is deintegrated
#    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}


Step 2: Configure Fault Snapshot Trigger 49
    [Documentation]
    ...  In this test step faultSnapshotTriggers list for foult 49 is created and added to configuration.
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
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}


Step 3: Execute reset site
    Log  Reset ongoing    console=${True}
    coam.Reset Site
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    Reset site done    console=${TRUE}

Step 4: Check fault 49 still exist after reset
    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*
    ${count_faultSnapshotTriggers}  Evaluate  len(${trblcadm_conf['faultSnapshotTriggers']})
    Should Be True  ${count_faultSnapshotTriggers}==1

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  0  ${delta_id}
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

TC Setup
    Common Test Setup

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
#    Unblocket Cell
    ${delta_id}  Set Variable  teardown
    coam.Create Delta  ${delta_id}
#    Run Keyword If  ${TRBLCADM_MO_ADDED} and ${FAULT_SNAPSHOT_TRIGGER_ADDED}  Run Keywords
#    ...  Log  Removing TRBLCADM managed object from configuration  console=${True}
#    ...  AND  coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  delete  ${delta_id}
#    ...  AND  coam.Get Delta  ${delta_id}
#    ...  AND  coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
#    ...  AND  coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
#    ...  ELSE IF  ${FAULT_SNAPSHOT_TRIGGER_ADDED} and not ${TRBLCADM_MO_ADDED}  Run Keywords
#    ...  Log  Removing faultSnapshotTriggers list from configuration  console=${True}
    coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  faultSnapshotTriggers  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    coam.Remove All Delta Id
#    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    LOGS__Snapshot_collection__Triggers_persistent_over_resets.Custom Test Teardown
    ...    AND    Common Test Teardown
