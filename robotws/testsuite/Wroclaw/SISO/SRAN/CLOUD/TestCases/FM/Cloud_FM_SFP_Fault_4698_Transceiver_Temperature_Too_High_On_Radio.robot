*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library     taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ./Cloud_FM_Fault_Signature.resource
Resource    ./Cloud_FM_SFP.resource
Resource    ../ALD/Cloud_ALD.resource

*** Variables ***
@{VDU_SFP_4698_ALLOWED_HIST_ALARMS}=  faultId=4698, severity=minor|major


*** Keywords ***
TC__Cloud_FM_SFP_Fault_4698_Transceiver_Temperature_Too_High_On_Radio
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_ru_sn_list}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...
    ...  The purpose of this case is:
    ...  The purpose of this case is to verify the situation when the BTS received information about [Q]SFP Transceiver Temp Too High
    ...  from Radio Unit and the operator is informed about [Q]SFP Transceiver Temp Too High on Radio Unit by fault in Admin.
    ...  TC raises fault 4698 with severity Major or Minor. ALarm should be visible in Active Alarms.
    ...  TC activates each fault on all available and commissioned SFPs on tested RU.
    ...
    ...  TC works with RU families: 8, tested on AXEGHA.
    ...
    ...  Step 1 CBTS Preconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
    ...  a) Perform delta recommissioning for: 'actTransceiverAlarmMonitoring' to 'Transceiver alarms and warnings'
    ...  b) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  c) Prepare details according SFPs on tested radio unit provided by user
    ...  Step 2 CBTS Trigger Fault 4698 Minor On Radio SFPs
    ...  a) Trigger fault 4698 minor
    ...  b) Wait for fault 4698 minor in ADMIN
    ...  c) Check if Alarming Info in Active Alarm for fault 4698 minor is correct according to NIDD
    ...  c) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  d) Recover from fault 4698 minor
    ...  e) Wait for fault 4698 minor to be cleared in ADMIN
    ...  Step 3 CBTS Trigger Fault 4698 Major On Radio SFPs
    ...  a) Trigger fault 4698 major
    ...  b) Wait for fault 4698 major in ADMIN
    ...  c) Check if Alarming Info in Active Alarm for fault 4698 major is correct according to NIDD
    ...  d) Check if all radio, VDU are in expected state (radio modules online, vDU onAir)
    ...  e) Check if cells on tested radio are degraded
    ...  f) Check if not impacted cells are OnAir
    ...  g) Recover from fault 4698 major
    ...  h) Wait for fault 44698 major to be cleared in ADMIN
    ...  i) Check if all radio, cells, VDU are in expected state (radio modules online, cells OnAir, vDU onAir)
    ...  Step 4 CBTS Postconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
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
    Log  ${start_prefix_green}Test Case: Cloud_FM_SFP_Fault_4698_Transceiver_Temperature_Too_High_On_Radio  console=${log_to_console}
    Step 1 CBTS Preconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
    FOR  ${cbts_ru_sn}  IN  @{cbts_ru_sn_list}
      Set Test Variable  ${cbts_ru_sn}
      Cloud FM SFP Get SFPs From Radio  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Cloud FM SFP Get Cells From Other Radios Than Tested RU  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Step 2 CBTS Trigger Fault 4698 Minor On Radio SFPs
      Step 3 CBTS Trigger Fault 4698 Major On Radio SFPs
    END
    Step 4 CBTS Postconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
    Log  ${done_prefix_green}Test Case: Cloud_FM_SFP_Fault_4698_Transceiver_Temperature_Too_High_On_Radio  console=${log_to_console}
    [Teardown]  Cloud Teardown FM SFP  tc_status=${KEYWORD_STATUS}  vdu_connection=${vdu_connection}

Step 1 CBTS Preconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
    Log  ${dots_prefix_green}Step 1 CBTS Preconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio  console=${log_to_console}
    Should Not Be Empty  ${cbts_ru_sn_list}  msg=CBTS RU SN list is empty
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SFP_4698_ALLOWED_HIST_ALARMS}
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
    Log  ${ok_prefix_green}Step 1 CBTS Preconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio  console=${log_to_console}

Step 2 CBTS Trigger Fault 4698 Minor On Radio SFPs
    Log  ${dots_prefix_green}Step 2 CBTS Trigger Fault 4698 Minor On Radio SFPs  console=${log_to_console}
    ${4698_minor_list}=  Create List  minor
    FOR  ${sfp_id}  IN  @{sfp_ids_dict}
      Log  ${info_prefix}Triggering fault 4698 minor on SFP OPT_IF-${sfp_id}, distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
      ${4698_alarming_object_list}=  Create List  ${sfp_ids_dict['${sfp_id}']}
      radio.Generate Fault
      ...  fault_id=4698
      ...  sfp_id=${sfp_id}
      ...  severity=minor
      ...  ru_serial_number=${cbts_ru_sn}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Active
      ...  fault_id=4698
      ...  alarming_object_list=${4698_alarming_object_list}
      ...  alarm_severity_list=${4698_minor_list}
      ...  timeout=300s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 minor triggered. Checking vDU states  console=${log_to_console}
      Cloud FM Check Alarming Info In Active Alarm  faultId=4698  alarming_info=${FID_4698_ALARM_INFO}  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 minor alarming info in active alarm is correct  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      radio.Recover Fault
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=4698
      ...  sfp_id=${sfp_id}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Inactive
      ...  fault_id=4698
      ...  alarm_severity_list=${4698_minor_list}
      ...  timeout=120s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 minor recovered, checking vDU states  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      Log  ${ok_prefix_green}Triggered and recovered fault 4698 minor on SFP OPT_IF-${sfp_id}, distname: distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 2 CBTS Trigger Fault 4698 Minor on radio SFPs  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  radio.Recover Fault
    ...  ru_serial_number=${cbts_ru_sn}
    ...  fault_id=4698
    ...  sfp_id=${sfp_id}
    ...  cloud_server_ip=${K8s_vdu_connection}

Step 3 CBTS Trigger Fault 4698 Major On Radio SFPs
    Log  ${dots_prefix_green}Step 3 CBTS Trigger Fault 4698 Major On Radio SFPs  console=${log_to_console}
    ${4698_major_list}=  Create List  major
    FOR  ${sfp_id}  IN  @{sfp_ids_dict}
      Log  ${info_prefix}Triggering fault 4698 major on SFP OPT_IF-${sfp_id}, distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
      ${4698_alarming_object_list}=  Create List  ${sfp_ids_dict['${sfp_id}']}
      radio.Generate Fault
      ...  fault_id=4698
      ...  sfp_id=${sfp_id}
      ...  severity=major
      ...  ru_serial_number=${cbts_ru_sn}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Active
      ...  fault_id=4698
      ...  alarming_object_list=${4698_alarming_object_list}
      ...  alarm_severity_list=${4698_major_list}
      ...  timeout=300s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 major triggered.  console=${log_to_console}  console=${log_to_console}
      Cloud FM Check Alarming Info In Active Alarm  faultId=4698  alarming_info=${FID_4698_ALARM_INFO}  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 major alarming info in active alarm is correct  console=${log_to_console}
      Cloud FM SFP Check If Radio Has Degraded Cells  ru_sn=${cbts_ru_sn}  vdu_connection=${vdu_connection}
      Cloud ALD Check Cells According To Impact
      ...  impacted_cells=@{EMPTY}
      ...  not_impacted_cells=${not_impacted_cells}
      ...  impacted_state_dict=@{EMPTY}
      ...  not_impacted_state_dict=${cbts_cell_onair}
      Log  ${info_prefix}Not impacted cells check passed  console=${log_to_console}
      radio.Recover Fault
      ...  ru_serial_number=${cbts_ru_sn}
      ...  fault_id=4698
      ...  sfp_id=${sfp_id}
      ...  cloud_server_ip=${K8s_vdu_connection}
      vDU Assert Alarm Inactive
      ...  fault_id=4698
      ...  alarm_severity_list=${4698_major_list}
      ...  timeout=120s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4698 major recovered, checking vDU states  console=${log_to_console}
      Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
      Log  ${ok_prefix_green}Triggered and recovered fault 4698 major on SFP OPT_IF-${sfp_id}, distname: distname: ${sfp_ids_dict['${sfp_id}']}
      ...  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 3 CBTS Trigger Fault 4698 Major On Radio SFPs  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  radio.Recover Fault
    ...  ru_serial_number=${cbts_ru_sn}
    ...  fault_id=4698
    ...  sfp_id=${sfp_id}
    ...  cloud_server_ip=${K8s_vdu_connection}

Step 4 CBTS Postconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio
    Log  ${dots_prefix_green}Step 4 CBTS Postconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio  console=${log_to_console}
    Cloud FM SFP Perform actTransceiverAlarmMonitoring Recommissioning
    ...  value=${actTransceiverAlarmMonitoring_initial_value}
    ...  vdu_connection=${vdu_connection}
    Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 4 CBTS Postconditions FM Sfp Fault 4698 Transceiver Temperature Too High On Radio  console=${log_to_console}
