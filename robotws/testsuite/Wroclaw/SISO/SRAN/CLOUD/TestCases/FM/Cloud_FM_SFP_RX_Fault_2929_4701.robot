*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library     taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library     ../../resources/python/arch_helpers.py

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ./Cloud_FM_Fault_Signature.resource
Resource    ./Cloud_FM_SFP.resource
Resource    ../ALD/Cloud_ALD.resource

*** Variables ***
@{VDU_SFP_4701_ALLOWED_HIST_ALARMS}=  faultId=4701, severity=major


*** Keywords ***
TC__Cloud_FM_SFP_RX_Fault_2929_4701
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_ru_sn_list}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...
    ...  The purpose of this case is:
    ...  1. To verify the situation when the BTS received information about [Q]SFP Transceiver RX LOS from Radio Unit
    ...     and setting fault 1385 in raw alarms history on radio side.
    ...  2. To verify the situation when the BTS received information about RX Power on [Q]SFP's LANE too low from Radio Unit
    ...     and the operator is informed about RX Power on [Q]SFP's LANE too low on Radio Unit by an alarm in ADMIN.
    ...     BTS shall report Rx Power too low alarms to ADMIN. FID:4701 RX power too low is visible in ADMIN with Major severity
    ...
    ...  TC activates each fault on all available and commissioned SFPs on tested RU.
    ...  TC works with RU families: 8, tested on AXEGHA.
    ...
    ...  Step 1 CBTS Preconditions FM Sfp Rx Fault 2929 4701
    ...  a) Perform delta recommissioning for: 'actTransceiverAlarmMonitoring' to 'Transceiver alarms and warnings'
    ...  b) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  c) Prepare details according SFPs on tested radio unit provided by user
    ...  Step 2 CBTS Trigger Fault 2929 on radio SFPs
    ...  a) Trigger fault 2929
    ...  b) Wait for alarm 1385 EfaultId_LossOfSignalCapacityWarning 'warning' to appear in fault_history_log.txt on radio
    ...  c) Check if R&D fault 2929 in snapshot under fm_fault_history file is raised with correct trigger timestamp
    ...  d) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  e) Recover from fault 2929
    ...  f) Check if R&D fault 2929 in snapshot under fm_fault_history file is cleared with correct trigger timestamp
    ...  g) Wait for alarm 1385 EfaultId_LossOfSignalCapacityWarning 'warning' to be inacive in fault_history_log.txt on radio
    ...  Step 3 CBTS Trigger Fault 4701 major on radio SFPs
    ...  a) Trigger fault 4701 major
    ...  b) Wait for fault 4701 major in ADMIN
    ...  c) Check if Alarming Info in Active Alarm for fault 4701 is correct according to NIDD
    ...  d) Check if all radio, VDU are in expected state (radio modules online, vDU onAir)
    ...  e) Check if cells on tested radio are degraded
    ...  f) Check if not impacted cells are OnAir
    ...  g) Recover from fault 4701 major
    ...  h) Wait for fault 4701 major to be cleared in ADMIN
    ...  i) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  Step 4 CBTS Postconditions FM Sfp Rx Fault 2929 4701
    ...  a) Perform delta recommissioning for: 'actTransceiverAlarmMonitoring' to initial value
    ...  b) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_ru_sn_list        |  Yes | radio serial number list for testing                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_ru_sn_list}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_FM_SFP_RX_Fault_2929_4701  console=${log_to_console}
    Step 1 CBTS Preconditions FM Sfp Rx Fault 2929 4701
    FOR  ${cbts_ru_sn}  IN  @{cbts_ru_sn_list}
      Set Test Variable  ${cbts_ru_sn}
      Cloud FM SFP Get SFPs From Radio  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Cloud FM SFP Get Cells From Other Radios Than Tested RU  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Step 2 CBTS Trigger Fault 2929 on radio SFPs
      Step 3 CBTS Trigger Fault 4701 major on radio SFPs
    END
    Step 4 CBTS Postconditions FM Sfp Rx Fault 2929 4701
    Log  ${done_prefix_green}Test Case: Cloud_FM_SFP_RX_Fault_2929_4701  console=${log_to_console}
    [Teardown]  Cloud Teardown FM SFP  tc_status=${KEYWORD_STATUS}  vdu_connection=${vdu_connection}

Step 1 CBTS Preconditions FM Sfp Rx Fault 2929 4701
    Log  ${dots_prefix_green}Step 1 CBTS Preconditions FM Sfp Rx Fault 2929 4701  console=${log_to_console}
    Should Not Be Empty  ${cbts_ru_sn_list}  msg=CBTS RU SN list is empty
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SFP_4701_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    ${K8s_vdu_connection}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable  ${K8s_vdu_connection}  ${K8s_vdu_connection['ip_addr']}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${mrbts_id}
    ${actTransceiverAlarmMonitoring_initial_value}=  Cloud FM SFP Get Initail Value For actTransceiverAlarmMonitoring
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${actTransceiverAlarmMonitoring_initial_value}
    Cloud FM SFP Perform actTransceiverAlarmMonitoring Recommissioning  value=Transceiver alarms and warnings
    ${cbts_cell_onair}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_cell_onair}
    Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 1 CBTS Preconditions FM Sfp Rx Fault 2929 4701  console=${log_to_console}

Step 2 CBTS Trigger Fault 2929 on radio SFPs
    Log  ${dots_prefix_green}Step 2 CBTS Trigger Fault 2929 on radio SFPs  console=${log_to_console}
    FOR  ${sfp_id}  IN  @{sfp_ids_dict}
      Log  ${info_prefix}Triggering fault 2929 on SFP OPT_IF-${sfp_id}, distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
      ${2929_trigger_timestamp}=  Get Current Date  UTC
      ${2929_trigger_time_in_epoch}=  Convert Date  date=${2929_trigger_timestamp}
      ...  result_format=epoch
      ...  exclude_millis=False
      radio.Generate Fault
      ...  fault_id=2929
      ...  sfp_id=${sfp_id}
      ...  ru_serial_number=${cbts_ru_sn}
      ...  cloud_server_ip=${K8s_vdu_connection}
      Wait Until Keyword Succeeds  180s  30s  radio.Assert Active Fault In Fault History Log File
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=1385
      ...  severity=warning
      ...  fault_name=EFaultId_LossOfSignalCapacityWarning
      ...  cloud_server_ip=${K8s_vdu_connection}
      Log  ${info_prefix}fault 1385 visible in fault history log on radio, checking R&D 2929 in snapshot  console=${log_to_console}
      Sleep  120s  Waiting for active R&D 2929
      Cloud FM SFP Verify R&D Fault In Snapshot
      ...  fault_id=2929
      ...  trigger_timestamp_epoch=${2929_trigger_time_in_epoch}
      ...  state=Raise
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}R&D fault 2929 found in fm_fault_history file in snapshot, checking vDU states  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      radio.Recover Fault
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=2929
      ...  sfp_id=${sfp_id}
      ...  cloud_server_ip=${K8s_vdu_connection}
      Wait Until Keyword Succeeds  180s  30s  radio.Assert Inactive Fault In Fault History Log File
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=1385
      ...  severity=warning
      ...  fault_name=EFaultId_LossOfSignalCapacityWarning
      ...  cloud_server_ip=${K8s_vdu_connection}
      Log  ${info_prefix}fault 1385 inactive in fault history log on radio, checking R&D 2929 in snapshot  console=${log_to_console}
      Sleep  120s  Waiting for inactive R&D 2929
      Cloud FM SFP Verify R&D Fault In Snapshot
      ...  fault_id=2929
      ...  trigger_timestamp_epoch=${2929_trigger_time_in_epoch}
      ...  state=Clear
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}R&D fault 2929 cleared in fm_fault_history file in snapshot, checking vDU states  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      Log  ${ok_prefix_green}Triggered and recovered fault 2929 on SFP OPT_IF-${sfp_id}, distname: distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 2 CBTS Trigger Fault 2929 on radio SFPs  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  radio.Recover Fault
    ...  ru_serial_number=${cbts_ru_sn}
    ...  fault_id=2929
    ...  sfp_id=${sfp_id}
    ...  cloud_server_ip=${K8s_vdu_connection}

Step 3 CBTS Trigger Fault 4701 major on radio SFPs
    Log  ${dots_prefix_green}Step 3 CBTS Trigger Fault 4701 major on radio SFPs  console=${log_to_console}
    ${4701_major_list}=  Create List  major
    FOR  ${sfp_id}  IN  @{sfp_ids_dict}
      Log  ${info_prefix}Triggering fault 4701 major on SFP OPT_IF-${sfp_id}, distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
      ${4701_alarming_object_list}=  Create List  ${sfp_ids_dict['${sfp_id}']}
      radio.Generate Fault
      ...  fault_id=4701
      ...  sfp_id=${sfp_id}
      ...  severity=major
      ...  ru_serial_number=${cbts_ru_sn}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Active
      ...  fault_id=4701
      ...  alarming_object_list=${4701_alarming_object_list}
      ...  alarm_severity_list=${4701_major_list}
      ...  timeout=300s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4701 major triggered  console=${log_to_console}
      Cloud FM Check Alarming Info In Active Alarm  faultId=4701  alarming_info=${FID_4701_ALARM_INFO}  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4701 major alarming info in active alarm is correct  console=${log_to_console}
      Log  ${info_prefix}Checking vDU states including degraded cells check  console=${log_to_console}
      Cloud FM SFP Check If Radio Has Degraded Cells  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Cloud ALD Check Cells According To Impact
      ...  impacted_cells=@{EMPTY}
      ...  not_impacted_cells=${not_impacted_cells}
      ...  impacted_state_dict=@{EMPTY}
      ...  not_impacted_state_dict=${cbts_cell_onair}
      Log  ${info_prefix}Not impacted cells check passed  console=${log_to_console}
      radio.Recover Fault
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=4701
      ...  sfp_id=${sfp_id}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Inactive
      ...  fault_id=4701
      ...  alarm_severity_list=${4701_major_list}
      ...  timeout=120s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4701 major recovered, checking vDU and Cloud FM states  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      Log  ${ok_prefix_green}Triggered and recovered fault 4701 major on SFP OPT_IF-${sfp_id}, distname: distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 3 CBTS Trigger Fault 4701 major on radio SFPs  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  radio.Recover Fault
    ...  ru_serial_number=${cbts_ru_sn}
    ...  fault_id=4701
    ...  sfp_id=${sfp_id}
    ...  cloud_server_ip=${K8s_vdu_connection}

Step 4 CBTS Postconditions FM Sfp Rx Fault 2929 4701
    Log  ${dots_prefix_green}Step 4 CBTS Postconditions FM Sfp Rx Fault 2929 4701  console=${log_to_console}
    Cloud FM SFP Perform actTransceiverAlarmMonitoring Recommissioning
    ...  value=${actTransceiverAlarmMonitoring_initial_value}
    ...  vdu_connection=${vdu_connection}
    Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 4 CBTS Postconditions FM Sfp Rx Fault 2929 4701  console=${log_to_console}
