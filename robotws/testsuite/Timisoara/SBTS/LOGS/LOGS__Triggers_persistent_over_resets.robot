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
${RESET_TYPE}    site_reset
${STARTUP_TIMEOUT}  10
*** Keywords ***
TC__LOGS__Triggers_persistent_over_resets
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24256
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2022-12-06 - Damian Kotula - Test rewritten based on BOAM ET test -
    ...  Automatic_snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  - 2023-05-17 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 49 is cancelled. Fault is
    ...  added to faultSnapshotTriggers list and reported after cell block.
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                       LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-RP002771

    Step 0: Preconditions
    Step 1: Configure Fault Snapshot Trigger
    Step 2: Perform reset
    Step 3: Check fault still exist after reset


Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    Set Test Variable  ${FAULT_SNAPSHOT_TRIGGER_ADDED}  ${False}
    Set Test Variable  ${CELL_BLOCKED}  ${False}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
#    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
#    Set Test Variable  ${snapshot_name}
#    Set Snapshot Destination To  LSS

Step 1: Configure Fault Snapshot Trigger
    [Documentation]
    ...  In this step faultSnapshotTriggers list for foult 12 is created and added to configuration.

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
    ...  ELSE  Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    12    onFaultDetection


Step 2: Perform reset
    Log  \nStep 2: Perform reset  console=${True}
    run keyword if  '${RESET_TYPE}'=='site_reset'  run keywords
    ...    log to console    Execute Site Reset
#    ...  set test variable  ${BLACKBOX_INFO}  User (Execute reset.)
    ...  AND  Site Reset


Step 3: Check fault still exist after reset
    Log  \nStep 3: Check fault still exist after reset  console=${True}
    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*
    ${count_faultSnapshotTriggers}  Evaluate  len(${trblcadm_conf['faultSnapshotTriggers']})
    Should Be True  ${count_faultSnapshotTriggers}==1


Site Reset
    Log  Step1: Perform BTS site reset  console=yes
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    coam.Reset Site  600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms

Create Trblcadm Mo
    [Arguments]  ${SCF}  ${delta_id}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  create  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actCoreDumpFileCollection  true  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  actRemoteSyslogTransmission  false  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  snapshotUploadDelayForFault6450  24  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  lss  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    Create Fault Snapshot Triggers  ${SCF}  ${delta_id}    12    onFaultDetection

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

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
#    Run Keyword If  ${CELL_BLOCKED}  Run Keywords
#    ...  Log  Cell with distname ${CELL_DISTNAME} will be unblocked  console=${True}
#    ...  AND  coam.Unblock Cell  ${CELL_DISTNAME}

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

