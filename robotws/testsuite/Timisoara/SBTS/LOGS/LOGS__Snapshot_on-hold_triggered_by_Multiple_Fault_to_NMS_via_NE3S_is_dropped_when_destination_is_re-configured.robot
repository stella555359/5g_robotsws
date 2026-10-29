*** Settings ***
Documentation    Test Case Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     Collections
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Keywords ***
TC__LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25748
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify functionality of clearing buffered on-hold snapshots when remote snapshot destination is changed.
    ...  Snapshot waiting in queue with 'on-hold' status should be dropped after diagSnapDestination reconfiguration
    ...  and relevant print should be present in syslog.
    ...  *******************
    ...  History of changes
    ...  ******************
    ...  - 13.07.2023 - Damian Kotula - Initial Creation
    ...  - 03.01.23 - change NetAct integration KW and variables
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/raw/master/testsuite/SBTS/
    ...  LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R3    FEATURE-RP000936_3_F1

    Step 0: Preconditions
    Step 1: Link Break Simulation
    Step 2: Trigger Fault 49
    Step 3: Reconfigure Snapshot Destination
    Step 4: Unlock S1 Interface

Step 0: Preconditions
    [Documentation]
    ...  Preconditions for test: BTS connected with NetAct, parameter diagSnapDestination set to netact,
    ...  fault Snapshot trigger configured with parameters faultNumber=49 triggerType=onFaultDetection

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable  ${ETHLK_DISTNAME}  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1
    run keyword if  '${BTS_ID}'=='10827'    Set Test Variable    ${ETHLK_DISTNAME}    MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-5
    Create List Of All Cells
    Create Fault Snapshot Triggers
    Set Snapshot Destination To  NetAct
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}

Step 1: Link Break Simulation
    [Documentation]
    ...  This step simulates S1 interface disconnection, which is accomplished via seting ETHLK-1 administrativeState locked,
    ...  then timeout for reconnection is set.

    Log  \nStep 1: Link break simulation  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=${ETHLK_DISTNAME}  parameter=administrativeState
    ...  operation=update  value=locked  skip_parameter_relation_errors=${True}  timeout=120
    Wait Until Keyword Succeeds  10x  20s  Check if expected alarm occurred  6202  link break
    Sleep  15minutes 30seconds

Step 2: Trigger Fault 49
    [Documentation]
    ...  This step triggers snapshot collection two times. First cell block should tigger snapshot
    ...  collection and since netact connection is inactive, this snapshot is on-hold. While first snapshot is on-hold,
    ...  second snapshot should not be triggered and relevant print in syslog is expected.

    Log  \nStep 2: Trigger Fault 49  console=${True}
    FOR  ${cell_num}  IN RANGE  2
        Cell Block and Unblock  ${cell_num}
    END
    ${msg_in_syslog}  Run Keyword And Return Status  Check Expected Print In Syslog
    ...  Trigger for snapshot already exists in queue, discarding trigger for fault: 49
    Run Keyword If  ${msg_in_syslog}
    ...  Log  Print expected after second cell block is present in syslog  console=${true}
    ...  ELSE  verdicts.Set Test Failed  Check if syslog is started and the check for proper prints.  ${TRUE}

Step 3: Reconfigure Snapshot Destination
    [Documentation]
    ...  In this step diagSnapDestination is changed from netact to lss. Triggered on-hold snapshot should be dropped due to reconfiguration
    ...  and relevant print should be present in syslog.

    Log  \nStep 3: Reconfigure Snapshot Destination  console=${True}
    Set Snapshot Destination To  LSS
    ${msg_in_syslog}  Run Keyword And Return Status  Check Expected Print In Syslog
    ...  Clearing buffered snapshots due to diagSnapDestination reconfiguration
    Run Keyword If  ${msg_in_syslog}
    ...  Log  Print confirming that snapshot was dropped due to diagSnapDestination reconfiguration is present in syslog  console=${true}
    ...  ELSE  verdicts.Set Test Failed  Print confirming snapshot was dropped not found in syslog.  ${TRUE}

Step 4: Unlock S1 Interface
    [Documentation]
    ...  This step simulates S1 interface reconnection, which is accomplished via seting ETHLK-1 administrativeState unlocked.
    ...  Check if snapshot is not collecting after reconnection is performed.

    Log  \nStep 4: Unlock S1 Interface  console=${True}
    coam.Perform Parameter Recommissioning  dist_name=${ETHLK_DISTNAME}  parameter=administrativeState
    ...  operation=update  value=unlocked  skip_parameter_relation_errors=True  timeout=120
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"49:On fault detection"]
    ...  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot which was on-hold is not collecting - as expected.  console=${true}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection is ongoing, please check why.  ${TRUE}
    Wait Until Keyword Succeeds    20min    60s    coam.Assert alarm inactive    faultId=4297, severity=Minor

Create Fault Snapshot Triggers
    [Documentation]
    ...  In this KW delta with faultSnapshotTriggers is prepared and recomissioned, to trigger snapshot on fault 49 detection..

    ${delta_id}  Set Variable  fault_49_detection
    coam.Create Delta  ${delta_id}
    ${dict_fault_49_detection}  Create Dictionary  faultNumber=49  triggerType=onFaultDetection  snapshotCoverageLevel=Full
    Log  \nAdding faultSnapshotTriggers list for fault 49 to configuration.  console=${True}
    coam.Append Complex Item To Delta
    ...  ${TRBL_MNLENT_DISTNAME}  list_name=faultSnapshotTriggers  &{dict_fault_49_detection}  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/fault_triggers_delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/fault_triggers_delta.json  skip_parameter_relation_errors=${True}

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
    [Documentation]
    ...  This KW blocks cell, checks if alarm regarding cell block occurred and then unblocks cell
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

Check Expected Print In Syslog
    [Documentation]
    ...  This KW checks if expected print is present in syslog.
    [Arguments]  ${expected_print}
    ${msg}  ute_syslog.Message Should Exist In Syslog File  regexp=${expected_print}  alias=SMOD1
    [Return]  ${msg}

Custom Test Teardown
    Log  Custom Test Teardown - undo delta changes  console=true
    ${delta_id}  Set Variable  teardown_delta
    coam.Create Delta  ${delta_id}
    coam.Append Parameter Delete To Delta  ${TRBL_MNLENT_DISTNAME}  faultSnapshotTriggers  ${delta_id}
    coam.Append Parameter Update To Delta  ${ETHLK_DISTNAME}  administrativeState  unlocked  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta2.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta2.json  skip_parameter_relation_errors=${True}
    Log  Wait until BTS become onair  console=${true}
    Wait Until Keyword Succeeds  10m  30s  pm_logs_general.Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}
    ...    AND    Custom Test Teardown
    ...    AND    coam.Remove All Delta Id
    ...    AND    Common Test Teardown
