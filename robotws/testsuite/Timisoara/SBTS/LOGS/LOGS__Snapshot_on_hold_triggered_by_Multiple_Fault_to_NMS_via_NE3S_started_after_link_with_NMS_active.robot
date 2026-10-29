*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     Collections
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  2400


*** Keywords ***
TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22195
    ...  ******************
    ...  Author: Justyna Durak
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-11-15 - https://jira3.ext.net.nokia.com/browse/TAT-22195 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-01-04 - TAT-22173-2  - Check RMOD Availability Status KW moved to resources -> Check RMOD States
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-05-17 - TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  - 18.07.2023 - TAT-25780 - Added KW "Create List Of All Cells" to fix issue with test failing when there is only one cell of given technology
    ...                 when at least 2 cells are needed.
    ...  - 03.01.2023 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case checks such behaviours for remote snapshot, triggered on fault detection:
    ...  - if first snapshot is triggered, while connection to NetAct is inactive, it should wait on-hold
    ...  until connection will be restored and then should be sent to NetAct
    ...  -if one snapshot is waiting in queue with 'on-hold' status, another one can't be trigged
    ...  and relevant prints should be present in syslog
    ...  *******************
    ...  Test case flowchart: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__Snapshot_on-hold_triggered_by_multiple_fault_to_NMS_via_NE3S_started_after_link_with_NMS_active#
    ...

    Set Tags    CA-LOGS OWNER-justyna.durak@nokia.com AUTHOR-justyna.durak@nokia.com MAINTAINER-justyna.durak@nokia.com GROUP_IN_CHARGE-WRO_6_Vrf
    ...         PHASE-CRT SW-SBTS22

    Step 1: Preconditions
    Step 2: Link break simulation
    Step 3: Faults detected on BTS
    Step 4: Restore connection with NetAct
    Step 5: Check If Snapshot Is Collected

Step 1: Preconditions
    [Documentation]  Preconditions for test: BTS connected with NetAct, parameter diagSnapDestination set to netact,
    ...  fault Snapshot trigger configured with parameters faultNumber=49 triggerType=onFaultDetection

    Log  \nStep 1: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Create List Of All Cells
    Configure Fault Snapshot Trigger
    Set Snapshot Destination To  NetAct
    Set Test Variable    ${NetAct_Deintegrate}    ${False}
    ${bts_connection}=  coam.connect_to
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Set Test Variable    ${NetAct_Deintegrate}    ${True}



Step 2: Link break simulation
    [Documentation]  This step simulates S1 interface disconnection, which is accomplished via seting ETHLK-1 administrativeState locked,
    ...  then timeout for reconnection is set.

    Log  \nStep 2: Link break simulation  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=locked  skip_parameter_relation_errors=True  timeout=120
    Wait Until Keyword Succeeds  10x  35s  Check if expected alarm occurred  6202  link break
    Sleep  15minutes 30seconds

Step 3: Faults detected on BTS
    [Documentation]  This step triggers snapshot collection two times. First cell block should tigger snapshot
    ...  collectin and since netact connection is inactive, this snapshot is on-hold. While first snapshot is on-hold,
    ...  second snapshot should not be triggered and relevant print in syslog is expected.

    Log  \nStep 3: Faults detected on BTS  console=${True}
    FOR  ${cell_num}  IN RANGE  2
        Cell Block and Unblock  ${cell_num}
    END
    ${msg_in_syslog}  Run Keyword And Return Status  Check syslog content after second fault trigger
    Run Keyword If  ${msg_in_syslog}
    ...  Log  Print, expected after second cell block, present in syslog  console=true
    ...  ELSE  verdicts.Set Test Failed  Check if syslog is started and the check for proper prints.  ${TRUE}

Step 4: Restore connection with NetAct
    [Documentation]  This step simulates S1 interface reconnection, which is accomplished via seting ETHLK-1 administrativeState unlocked.

    Log  \nStep 4: Restore connection with NetAct  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=120
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200

Step 5: Check If Snapshot Is Collected
    [Documentation]  In this test step it is checked if snapshot is triggered by fault 49 and collection is finished.

    Log  \nStep 5: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_object}  Query Infomodel  query=get object /MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-*  timeout=120s
    Should Contain  ${snapshot_triggering_object['reason']}  49:On fault detection  msg=Snapshot was not triggered by fault

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=true
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=true
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Configure Fault Snapshot Trigger
    [Documentation]  faultSnapshotTriggers list for fault 49 is created and added to configuration.
    Log  Configure Fault Snapshot Trigger  console=${True}
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

Cell Block and Unblock
    [Documentation]  This KW blocks cell, checks if alarm regarding cell block occurred and then unblocks cell
    [Arguments]  ${cell_num}
    ${cell_dist_name}  Set Variable  ${ALL_CELLS_LIST[${cell_num}]['dist_name']}
    ${block_result}  Run Keyword And Ignore Error  coam.Block Cell  ${cell_dist_name}
    Run Keyword If  '${block_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell block operation unsuccessful.  ${TRUE}
    ...  ELSE  Log  Cell block operation successful.  console=true
    Wait Until Keyword Succeeds  20x  5s  Check if expected alarm occurred  49  cell block
    ${unblock_result}  Run Keyword And Ignore Error  coam.Unblock Cell  ${cell_dist_name}
    Run Keyword If  '${unblock_result[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Cell unblock operation unsuccessful.  ${TRUE}
    ...  ELSE  Log  Cell unblock operation successful.  console=true

Create List Of All Cells
    [Documentation]
    ...  This KW creates list of cells from all RATs
    ${nrcell_m_objects}  Query Infomodel  get list //NRCELL_R-*  allow_negative_result=True
    ${lncell_m_objects}  Query Infomodel  get list //LNCEL_R-*  allow_negative_result=True
    ${wncell_m_objects}  Query Infomodel  get list //WNCEL_R-*  allow_negative_result=True
    ${gncell_m_objects}  Query Infomodel  get list //GNCEL_R-*  allow_negative_result=True
    ${all_cells_list}  Collections.Combine Lists  ${nrcell_m_objects}  ${lncell_m_objects}  ${wncell_m_objects}  ${gncell_m_objects}
    Set Test Variable  ${ALL_CELLS_LIST}

Check syslog content after second fault trigger
    [Documentation]  This KW checks if expected print is present in syslog, after second cell block.
    ${msg}  ute_syslog.Message Should Exist In Syslog File  regexp=Trigger for snapshot already exists in queue, discarding trigger for fault: 49
    ...  alias=SMOD1
    [Return]  ${msg}

Custom Test Teardown
    Log  Custom Test Teardown - undo delta changes  console=true
    ${delta_id}  Set Variable  teardown_delta
    coam.Create Delta  ${delta_id}
    coam.Append Parameter Delete To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  faultSnapshotTriggers  ${delta_id}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1  administrativeState  unlocked  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    Log  Wait until BTS become onair  console=true
    Wait Until Keyword Succeeds  10m  30s  pm_logs_general.Check All Modules And All Cells Working States

    Run Keyword If  ${NetAct_Deintegrate}  Run Keywords
    ...  Log  Start NetAct deintegrate  console=${True}
    ...  AND  Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}
    ...  AND  Set Test Variable    ${NetAct_Deintegrate}    ${False}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    coam.Remove All Delta Id
    ...    AND    Common Test Teardown
