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

*** Variables ***
${RADIO_STARTUP_DELAY}     450         # Custom radio startup delay

@{VDU_FID_1907_ALLOWED_HIST_ALARMS}=  faultId=1907, severity=critical|warning
                                 ...  faultId=1920, severity=major
                                 ...  faultId=10, severity=critical

@{VCU_FID_1907_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_FM_Fault_Signature_FID_1907
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_ru_sn_list}  ${nr_cell_id_dict}  ${rec_vdu_reset}=${FALSE}
    ...          ${tolerance_timeout}=1500  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Triggers given FID1907 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  The purpose of this Test Case is to check correct raise of fault 1907 "TX out of order"
    ...  and if faultSignature part of alarm response contains correct values.
    ...  Alarm ID/Name name is provided in variables.robot file according to NIDD: EFaultId_FrTxOutOfOrder.
    ...  FAULT_SIGNATURE_DICT for 1907 is provided in variables.robot file and contains reference values
    ...  to be checked in Fault Signature.
    ...  Fault Signature for critical severity should not exist in fault details.
    ...  'rec_vdu_reset' flag enables vDU reset in teardown to clear oam counter to avoid improper fault generation.
    ...  Each tested radio should have its nr cell id provided in 'nr_cell_id_dict' variable
    ...  to perform targetTotalLoad recommissioning.
    ...  It is mandatory that parameter targetTotalLoad exists on provided NR cells.
    ...  Fault 1907 was tested on AXEGHA under CLOUDRAN
    ...
    ...  Step 1 CBTS preconditions FM fault signature FID 1907
    ...  a) All radio modules should be on line
    ...  d) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2 CBTS trigger fault 1907
    ...  a) Set TotaltargetLoad parameter on NR cell to 100
    ...  b) Trigger fault 1907
    ...  c) Wait for alarm 1907 'warning' to appear 3 times
    ...  d) Wait for permanent alarm 1907 'critical' to appear
    ...  e) Verify ORAN alarm 19 in raw_alarm_history.txt on radio
    ...  f) Verify RAW alarm 1124, 1298 in raw_alarm_history.txt on radio
    ...  g) Recover from fault 1907
    ...  Step 3 Check fault signature for FID 1907
    ...  a) Check fault signature values for alarm 1907 'warning' according to requirements:
    ...     - category=SW_FAILURE
    ...     - component=radio s/n
    ...     - date=date not earlier than trigger time
    ...     - extraInfo=impacted cells
    ...     - loadName=vdu sw release; radio sw release
    ...     - resetCounter=int value
    ...     - scope=RFM
    ...  b) Check fault signature for alarm 1907 'critical'. Fault signature should not exist in fault details.
    ...  c) Fault 1907 warning should appear 3 times
    ...  d) Fault 1907 critical should appear 1 time
    ...  Step4 CBTS postconditions FM fault signature FID 1907
    ...  a) All radio modules should be on line
    ...  d) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nr_cell_id_dict        |  Yes | nr cell id dict to perform recommissioning of totalTargetload              |
    ...  |                        |      | key=value convention -> <radio_serial_number>=<nr_cell_id>                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_ru_sn_list        |  Yes | radio serial number list for testing                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rec_vdu_reset          |  No  | Flag enabling vdu reset in teardown to clear oam counter                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | tolerance_timeout      |  No  | timeout that defines timeout window for fault to appear                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${nr_cell_id_dict}
    Set Test Variable  ${cbts_ru_sn_list}
    Set Test Variable  ${rec_vdu_reset}
    Set Test Variable  ${tolerance_timeout}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_FM_Fault_Signature_FID_1907  console=${log_to_console}
    Step 1: CBTS preconditions FM fault signature FID 1907
    FOR  ${cbts_ru_sn}  IN  @{cbts_ru_sn_list}
      Set Test Variable  ${cbts_ru_sn}
      Step 2: CBTS trigger fault 1907
      Step 3: Check fault signature for FID 1907
    END
    Step 4: CBTS postconditions FM fault signature FID 1907
    Log  ${done_prefix_green}Test Case: Cloud_FM_Fault_Signature_FID_1907  console=${log_to_console}
    [Teardown]  Teardown FM Fault Signature  tc_status=${KEYWORD_STATUS}  vdu_connection=${vdu_connection}

Step 1: CBTS preconditions FM fault signature FID 1907
    Log  ${dots_prefix_green}Step 1: CBTS preconditions FM fault signature FID 1907  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_FID_1907_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_FID_1907_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
    ${alarms_before}=  vdu.Vdu Get Historical Alarms  vdu_connection=${vdu_connection}  raw=True
    Set Test Variable  ${alarms_before}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions FM fault signature FID 1907  console=${log_to_console}

Step 2: CBTS trigger fault 1907
    Log  ${dots_prefix_green}Step 2: CBTS trigger fault 1907  console=${log_to_console}
#  get initial targetTotalLoad value
    ${nr_cell_id}=  Get From Dictionary  ${nr_cell_id_dict}  ${cbts_ru_sn}
    ${nr_cell_info}=  vdu.Get Cell Specific Info  cell_id=${nr_cell_id}  vdu_connection=${vdu_connection}
    ${status}  ${targetTotalLoad_initial_value}=  Run Keyword And Ignore Error  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${nr_cell_info['basicCell']['distNames']['config']}
    ...  para_name=targetTotalLoad
    IF  '${status}'=='FAIL'
      Log  ${failed_result}Could not get initial targetTotalLoad value from NRCELL-${nr_cell_id}  console=${log_to_console}
      Log  ${failed_result}Check if parameter exists on provided NRCELL-${nr_cell_id}  console=${log_to_console}
      Fail  Could not get initial targetTotalLoad value from NRCELL-${nr_cell_id}  console=${log_to_console}
    END
    Set Test Variable  ${targetTotalLoad_initial_value}
    Set Test Variable  ${cell_distname_for_recommissioning}  ${nr_cell_info['basicCell']['distNames']['config']}
#  Fault triggering
    ${fault_trigger_timestamp}=  Get Current Date  UTC
    ${K8s_vdu_connection}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Trigger Fault 1907
    ...  cloud_server_ip=${K8s_vdu_connection['ip_addr']}
    ...  vdu_connection=${vdu_connection}
    vDU Assert Alarm Inactive  fault_id=1907  alarm_severity_list=${critical_list}  timeout=300s  vdu_connection=${vdu_connection}
    Sleep  5s  wait for alarms to be logged in historical alarms
    Log  ${info_prefix}Fault 1907 critical is inactive  console=${log_to_console}
    ${alarms_after}=  vdu.Vdu Get Historical Alarms  vdu_connection=${vdu_connection}  raw=True
    ${alarms_after}=  Set Variable  ${alarms_after['alarms']}
    Remove Values From List  ${alarms_after}  @{alarms_before['alarms']}
    Set Test Variable  ${alarms_after}
    Set Test Variable  ${fault_trigger_timestamp}
    Log  ${ok_prefix_green}Step 2: CBTS trigger fault 1907  console=${log_to_console}

Step 3: Check fault signature for FID 1907
    Log  ${dots_prefix_green}Step 3: Check fault signature for FID 1907  console=${log_to_console}
    Cloud FM Analyze Alarm List For Fault Signature
    ...  faultId=1907
    ...  alarm_info=${alarms_after}
    ...  allowed_severity=warning
    ...  expected_alarm_info=${FID_1907_ALARM_INFO}
    ...  occurence_rate=3
    ...  ru_sn=${cbts_ru_sn}
    ...  fault_trigger_timestamp=${fault_trigger_timestamp}
    ...  fault_signature_scheme=${FAULT_SIGNATURE_DICT}
    ...  tolerance_timeout=${tolerance_timeout}
    ...  vdu_connection=${vdu_connection}
    Cloud FM Analyze Alarm List For Fault Signature
    ...  faultId=1907
    ...  alarm_info=${alarms_after}
    ...  allowed_severity=critical
    ...  expected_alarm_info=${FID_1907_ALARM_INFO}
    ...  occurence_rate=1
    Log  ${ok_prefix_green}Step 3: Check fault signature for FID 1907  console=${log_to_console}

Step 4: CBTS postconditions FM fault signature FID 1907
    Log  ${dots_prefix_green}Step 4: CBTS postconditions FM fault signature FID 1907  console=${log_to_console}
    Cloud FM Check Basic States Onair  timeout=${RADIO_STARTUP_DELAY}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 4: CBTS postconditions FM fault signature FID 1907  console=${log_to_console}

Trigger Fault 1907
    [Arguments]  ${cloud_server_ip}  ${vdu_connection}=default
    [Documentation]
    ...  Triggers fault 1907 on radio module with serial number stored in 'cbts_ru_sn' variable.
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | cloud_server_ip           | Yes  | vdu cloud server ip                                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    Perform targetTotalLoad Recommissioning  value=100  vdu_connection=${vdu_connection}
    ${warning_list}=  Create List  warning
    FOR  ${index}  IN RANGE  1  4
      radio.Generate Fault  fault_id=1907  ru_serial_number=${cbts_ru_sn}  cloud_server_ip=${cloud_server_ip}
      Sleep  5  Timeout between fault generating actions
      vdu.Reset Cells  dist_name=${cell_distname_for_recommissioning}  vdu_connection=${vdu_connection}
      ${warning_status}=  Run Keyword And Return Status  vDU Assert Alarm Active
      ...  fault_id=1907
      ...  alarm_severity_list=${warning_list}
      ...  timeout=180
      ...  vdu_connection=${vdu_connection}
      IF  ${warning_status}
        Log  ${ok_prefix_green}Fault 1907 with severity warning appeared ! Attempt ${index} succeeded  console=${log_to_console}
      ELSE
        Log  ${failed_result}Fault 1907 with severity warning missing ! Attempt ${index} failed  console=${log_to_console}
        Log  ${failed_result}Try to set flag 'rec_vdu_reset' to TRUE  console=${log_to_console}
        Fail  Fault 1907 with severity warning did not appear ! Try to set flag 'rec_vdu_reset' to TRUE
      END
      vDU Assert Alarm Inactive
      ...  fault_id=1907
      ...  alarm_severity_list=${warning_list}
      ...  timeout=180s
      ...  vdu_connection=${vdu_connection}
      Wait Until All Radio Modules Are Online
      ...  rmods_count=${vdu_scfc_rmods_count}
      ...  timeout=${RADIO_STARTUP_DELAY}
      ...  vdu_connection=${vdu_connection}
      Sleep  300  Delay between fault generating actions
    END
    ${critical_list}=  Create List  critical
    Set Test Variable  ${critical_list}
    radio.Generate Fault  fault_id=1907  ru_serial_number=${cbts_ru_sn}  cloud_server_ip=${cloud_server_ip}
    Sleep  5  Timeout between fault generating actions
    vdu.Reset Cells  dist_name=${cell_distname_for_recommissioning}  vdu_connection=${vdu_connection}
    ${critical_status}=  Run Keyword And Return Status  vDU Assert Alarm Active
    ...  fault_id=1907
    ...  alarm_severity_list=${critical_list}
    ...  timeout=180
    ...  vdu_connection=${vdu_connection}
    IF  ${critical_status}
      Log  ${ok_prefix_green}Fault 1907 with severity critical active.  console=${log_to_console}
    ELSE
      Log  ${failed_result}Fault 1907 with severity warning inactive.  console=${log_to_console}
      Fail  Fault 1907 with severity critical inactive
    END
    Cloud FM Verify Oran Alarm On Radio
    ...  ru_sn=${cbts_ru_sn}
    ...  oran_alarm_id=19
    ...  oran_alarm_name=TxOutOfOrder
    ...  cloud_server_ip=${cloud_server_ip}
    ...  status=active
    Cloud FM Verify Raw Fault On Radio
    ...  ru_sn=${cbts_ru_sn}
    ...  raw_fault_id=1124
    ...  raw_fault_name=EFaultId_NoFeedBackSignal
    ...  cloud_server_ip=${cloud_server_ip}
    ...  status=active
	Cloud FM Verify Raw Fault On Radio
    ...  ru_sn=${cbts_ru_sn}
    ...  raw_fault_id=1298
    ...  raw_fault_name=EFaultId_PermanentNoFeedbackSignal
    ...  cloud_server_ip=${cloud_server_ip}
    ...  status=active
    [Teardown]  Run Keywords
    ...  Run Keyword And Continue On Failure  Perform targetTotalLoad Recommissioning
    ...  value=${targetTotalLoad_initial_value}
    ...  vdu_connection=${vdu_connection}
    ...  AND
    ...  Cloud FM Recover Fault  faultId=1907  ru_serial_number=${cbts_ru_sn}  cloud_server_ip=${cloud_server_ip}

Perform targetTotalLoad Recommissioning
    [Arguments]  ${value}  ${vdu_connection}=default
    [Documentation]
    ...  Keyword performs targetTotalLoad recommissioning on NR cell from dictionary 'nr_cell_id_dict'
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | value                     | Yes  | recommissioning value of targetTotalLoad                           |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    Log  ${info_prefix}Performing targetTotalLoad recommissioning on radio ${cbts_ru_sn}  console=${log_to_console}
    ${recommissioning_status}=  Run Keyword And Return Status  vdu.Perform Parameter Recommissioning
    ...  dist_name=${cell_distname_for_recommissioning}  parameter=targetTotalLoad
    ...  operation=update  value=${value}  timeout=120  vdu_connection=${vdu_connection}
    IF  not ${recommissioning_status}
      Log  ${failed_result}targetTotalLoad recommissioning failed on ${cell_distname_for_recommissioning}  console=${log_to_console}
      Fail  targetTotalLoad recommissioning failed on ${cell_distname_for_recommissioning}  console=${log_to_console}
    END
    Log  ${info_prefix}targetTotalLoad recommissioning successfully performed on ${cell_distname_for_recommissioning} to value ${value}
    ...  console=${log_to_console}
