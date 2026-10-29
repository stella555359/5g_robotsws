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

@{VDU_FID_4590_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
                                 ...  faultId=4590, severity=warning

@{VCU_FID_4590_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_FM_Fault_Signature_FID_4590
    [Arguments]  ${vdu_scfc_file_path}  ${rec_vdu_reset}=${FALSE}  ${tolerance_timeout}=600  ${cbts_ru_sn_list}=@{EMPTY}
    ...          ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Triggers given FID4590 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  The purpose of this Test Case is to check correct raise of fault 4590 "Fault signature for crash or failure"
    ...  and if faultSignature part of alarm response contains correct values.
    ...  Alarm ID/Name name is provided in variables.robot file according to NIDD: EFaultId_CrashOrFailureSignatureAl.
    ...  FAULT_SIGNATURE_DICT for 4590 is provided in variables.robot file and contains reference values
    ...  to be checked in Fault Signature.
    ...  Fault Signature for critical severity should not exist in fault details.
    ...  'rec_vdu_reset' flag enables vDU reset in teardown to clear oam counter to avoid improper fault generation.
    ...  Fault 4590 was tested on AXEGHA under CLOUDRAN
    ...
    ...  Step 1 CBTS preconditions FM fault signature FID 4590
    ...  a) All radio modules should be on line
    ...  d) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2 CBTS trigger fault 4590
    ...  a) Trigger fault 4590
    ...  b) Wait for alarm 4590 'warning' to appear 1 time
    ...  c) Radio autonomous recovery reset should occur, radio and cells should return to OnAir state
    ...  Step 3 Check fault signature for FID 4590
    ...  a) Check fault signature values for alarm 4590 'warning' according to requirements:
    ...     - category=SW_FAILURE
    ...     - component=radio s/n
    ...     - date=date not earlier than trigger time
    ...     - extraInfo=impacted cells
    ...     - loadName=vdu sw release; radio sw release
    ...     - resetCounter=int value
    ...     - scope=RFM
    ...  b) Fault 4590 warning should appear 1 time
    ...  Step4 CBTS postconditions FM fault signature FID 4590
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
    Set Test Variable  ${cbts_ru_sn_list}
    Set Test Variable  ${rec_vdu_reset}
    Set Test Variable  ${tolerance_timeout}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_FM_Fault_Signature_FID_4590  console=${log_to_console}
    Step 1: CBTS preconditions FM fault signature FID 4590
    FOR  ${cbts_ru_sn}  IN  @{cbts_ru_sn_list}
      Set Test Variable  ${cbts_ru_sn}
      Step 2: CBTS trigger fault 4590
      Step 3: Check fault signature for FID 4590
    END
    Step 4: CBTS postconditions FM fault signature FID 4590
    Log  ${done_prefix_green}Test Case: Cloud_FM_Fault_Signature_FID_4590  console=${log_to_console}
    [Teardown]  Teardown FM Fault Signature  tc_status=${KEYWORD_STATUS}  vdu_connection=${vdu_connection}

Step 1: CBTS preconditions FM fault signature FID 4590
    Log  ${dots_prefix_green}Step 1: CBTS preconditions FM fault signature FID 4590  console=${log_to_console}
    Should Not Be Empty  ${cbts_ru_sn_list}  msg=CBTS RU SN list is empty
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_FID_4590_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_FID_4590_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Cloud FM Check Basic States Onair  timeout=30  vdu_connection=${vdu_connection}
    ${alarms_before}=  vdu.Vdu Get Historical Alarms  vdu_connection=${vdu_connection}  raw=True
    Set Test Variable  ${alarms_before}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions FM fault signature FID 4590  console=${log_to_console}

Step 2: CBTS trigger fault 4590
    Log  ${dots_prefix_green}Step 2: CBTS trigger fault 4590  console=${log_to_console}
    ${fault_trigger_timestamp}=  Get Current Date  UTC
    ${K8s_vdu_connection}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Trigger Fault 4590
    ...  cloud_server_ip=${K8s_vdu_connection['ip_addr']}
    ...  vdu_connection=${vdu_connection}
    ${alarms_after}=  vdu.Vdu Get Historical Alarms  vdu_connection=${vdu_connection}  raw=True
    ${alarms_after}=  Set Variable  ${alarms_after['alarms']}
    Remove Values From List  ${alarms_after}  @{alarms_before['alarms']}
    Set Test Variable  ${alarms_after}
    Set Test Variable  ${fault_trigger_timestamp}
    Log  ${ok_prefix_green}Step 2: CBTS trigger fault 4590  console=${log_to_console}

Step 3: Check fault signature for FID 4590
    Log  ${dots_prefix_green}Step 3: Check fault signature for FID 4590  console=${log_to_console}
    Cloud FM Analyze Alarm List For Fault Signature
    ...  faultId=4590
    ...  alarm_info=${alarms_after}
    ...  allowed_severity=warning
    ...  expected_alarm_info=${FID_4590_ALARM_INFO}
    ...  occurence_rate=1
    ...  ru_sn=${cbts_ru_sn}
    ...  fault_trigger_timestamp=${fault_trigger_timestamp}
    ...  fault_signature_scheme=${FAULT_SIGNATURE_DICT_4590}
    ...  tolerance_timeout=${tolerance_timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 3: Check fault signature for FID 4590  console=${log_to_console}

Step 4: CBTS postconditions FM fault signature FID 4590
    Log  ${dots_prefix_green}Step 4: CBTS postconditions FM fault signature FID 4590  console=${log_to_console}
    Cloud FM Check Basic States Onair  timeout=${RADIO_STARTUP_DELAY}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 4: CBTS postconditions FM fault signature FID 4590  console=${log_to_console}

Trigger Fault 4590
    [Arguments]  ${cloud_server_ip}  ${vdu_connection}=default
    [Documentation]
    ...  Triggers fault 4590 on radio module with serial number stored in 'cbts_ru_sn' variable.
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | cloud_server_ip           | Yes  | vdu cloud server ip                                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ${warning_list}=  Create List  warning
    ${rmod_prod_name}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${cbts_ru_sn}  rmod_param=product_name
#    ${radio_family}=  radio.Get Radio Module Hardware Family  ru_name=${rmod_prod_name}
#    ${process_name}=  Set Variable If  ${radio_family} >= 8  start-syscon-with-user   eventcollector
    radio.Kill Process On Radio Module By Name  ru_serial_number=${cbts_ru_sn}
    ...  process_name=eventcollector  cloud_server_ip=${cloud_server_ip}
    ${warning_status}=  Run Keyword And Return Status  vDU Assert Alarm Active
    ...  fault_id=4590
    ...  alarm_severity_list=${warning_list}
    ...  timeout=600
    ...  vdu_connection=${vdu_connection}
    IF  ${warning_status}
      Log  ${ok_prefix_green}Fault 4590 with severity warning appeared !  console=${log_to_console}
    ELSE
      Log  ${failed_result}Fault 4590 with severity warning missing !  console=${log_to_console}
      Log  ${failed_result}Try to set flag 'rec_vdu_reset' to TRUE  console=${log_to_console}
      Fail  Fault 4590 with severity warning did not appear ! Try to set flag 'rec_vdu_reset' to TRUE
    END
    vDU Assert Alarm Inactive
    ...  fault_id=4590
    ...  alarm_severity_list=${warning_list}
    ...  timeout=180s
    ...  vdu_connection=${vdu_connection}
