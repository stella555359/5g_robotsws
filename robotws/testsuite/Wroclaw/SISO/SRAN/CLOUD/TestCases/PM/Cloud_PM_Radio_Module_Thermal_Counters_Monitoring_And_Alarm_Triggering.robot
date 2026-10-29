*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{VDU_THERMAL_MONITORING_ALLOWED_HIST_ALARMS}=  faultId=4584, severity=minor
${COUNTER_ID}=  M40008C1
${MEASUREMENT_INTERVAL}=  15
${SNAPSHOT_TIMEOUT}=  800s
${LSS_SERVER_IP}=  10.44.184.246
${LSS_USERNAME}=  syslab
${LSS_PASSWORD}=  Pass4System!
${LSS_PORT}=  22

*** Keywords ***
TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-25016
    ...  Feature: CB008967-F - CB007257 Extension to support new counters and legacy temperature counters
    ...  Feature CB008967 (Fan Speed and Ambient Temperature Monitoring feature)
    ...  enhances current faults and alarms, counters, and configuration
    ...  settings to supervise the thermal condition of:
    ...  radio modules, system modules, BTS cabinets (sub-racks).
    ...  CB008967 feature extends the existing thermal state monitoring options by introducing additional functions
    ...  (faults, alarms, counters, and configuration options).
    ...
    ...  "mtSBTSRMODTemperature" parameter defines the measurement interval for SBTS
    ...  RMOD Thermal Monitoring measurement in minutes.
    ...  Counters related to the feature (only CLOUDRAN):
    ...  M40008C1: SBTS_RM_MAX_TEMPERATURE - provides the maximum temperature of the radio unit expressed in degrees Celsius.
    ...  The counter is updated over the measurement period.
    ...  The value of the counter is the maximum value of all temperature data reported by the temperature sensor(s).
    ...
    ...  Feature CB007257 (KPI triggered alarm and log collection in gNB) introduces automatic alarm reporting/log collection
    ...  based on configurable trigger using a set of PM counters available in the NE with 1 minute interval.
    ...  Operator can configure conditions for alarm/log(snapshot) collection in the NE
    ...  using CM parameters ("kpiAlarmTriggers") which include:
    ...  - formula description
    ...  - Fault ID (Fault ID can be chosen from list of faults 4569 to 4588)
    ...  - triggering formula
    ...  - time to trigger
    ...   KPI alarm reporting feature can be activated when feature flag "actKpiAlarms" is set to "true".
    ...
    ...  Step 1: Initial Check Thermal Counters Monitoring And Alarm Triggering
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 2: Activate Measurement Interval For Radio Module Thermal Monitoring
    ...  a) Set parameter "mtSBTSRMODTemperature" to "15min"
    ...  Step 3: Get And Check Temperature Counters
    ...  a) Counter M40008C1 is collected and checked
    ...  Step 4: Deactivate Measurement Interval For Radio Module Thermal Monitoring
    ...  a) Set parameter  "mtSBTSRMODTemperature" to "disabled"
    ...  Step 5: Configure Connection To Local Symptoms Server
    ...  a) Set parameter "lssConfig" to ["lssIPaddress", "lssPortNo"]
    ...  Step 6: Activate Fault Triggers For Snapshot
    ...  a) Set parameters: "actDefaultFaultSnapTriggers"="true", "actRemoteSyslogTransmission"="false",
    ...                     "diagSnapDestination"="lss", "maxNumSnapByFaultTrigPerDay"="200"
    ...  Step 7: Define BTS Faults List To Trigger Automatic Symptom Data Collection
    ...  a) Set parameter "faultSnapshotTriggers" to ["faultNumber"="4584", "snapshotCoverageLevel"="Full",
    ...                                               "triggerType"="onFaultDetection"]
    ...  Step 8: Define Kpi List To Trigger Automatic Alarm
    ...  a) Set parameter "kpiAlarmTriggers" to ["faultID"="4584", "formulaDescription"="Custom temperature fault",
    ...                                          "timeToTrigger"="1"  "triggeringFormula"="SBTS_RM_MAX_TEMPERATURE >= 0"]
    ...  Step 9: Activate KPI Triggered Alarm Functionality
    ...  Set parameter "actKpiAlarms" to "true"
    ...  Step 10: Wait For Triggered Alarms
    ...  a) faultid=4584, severity=minor
    ...  Step 11: Check If Triggered Snapshot Collected
    ...  Step 12: Define Kpi List To Cancel Automatic Alarm
    ...  a) Set parameter "kpiAlarmTriggers"= ["faultID"="4584", "formulaDescription"="Custom temperature fault",
    ...                                        "timeToTrigger"="1"  "triggeringFormula"="SBTS_RM_MAX_TEMPERATURE < 0"]
    ...  Step 13: Wait For Triggered Alarms To Cancel
    ...  a) faultid=4584, severity=minor
    ...  Step 14: Verify Counters When Thermal Monitoring Disabled
    ...  Step 15: Deactivate KPI Triggered Alarm Functionality
    ...  Set parameter "actKpiAlarms" to "false"
    ...  Step 16: Delete Kpi List To Trigger Automatic Alarm
    ...  Delete parameter kpiAlarmTriggers
    ...  Step 17: Set Default BTS Faults List To Trigger Automatic Symptom Data Collection
    ...  a) Set parameter "faultSnapshotTriggers" to default values
    ...  Step 18: Postconditions Thermal Counters Monitoring And Alarm Triggering
    ...  a) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering  console=${log_to_console}
    Step 1: Initial Check Thermal Counters Monitoring And Alarm Triggering
    Step 2: Activate Measurement Interval For Radio Module Thermal Monitoring
    Step 3: Get And Check Temperature Counters
    Step 4: Deactivate Measurement Interval For Radio Module Thermal Monitoring
    Step 5: Configure Connection To Local Symptoms Server
    Step 6: Activate Fault Triggers For Snapshot
    Step 7: Define BTS Faults List To Trigger Automatic Symptom Data Collection
    Step 8: Define Kpi List To Trigger Automatic Alarm
    Step 9: Activate KPI Triggered Alarm Functionality
    Step 10: Wait For Triggered Alarms
    Step 11: Check If Triggered Snapshot Collected
    Step 12: Define Kpi List To Cancel Automatic Alarm
    Step 13: Wait For Triggered Alarms To Cancel
    Step 14: Verify Counters When Thermal Monitoring Disabled
    Step 15: Deactivate KPI Triggered Alarm Functionality
    Step 16: Delete Kpi List To Trigger Automatic Alarm
    Step 17: Set Default BTS Faults List To Trigger Automatic Symptom Data Collection
    Step 18: Postconditions Thermal Counters Monitoring And Alarm Triggering
    Log  ${done_prefix_green}Test Case: Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering  console=${log_to_console}
    [Teardown]  Radio Module Thermal Counters Monitoring And Alarm Triggering Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Initial Check Thermal Counters Monitoring And Alarm Triggering
    Log  ${dots_prefix_green}Step 1: Initial check thermal counters monitoring and alarm triggering  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_THERMAL_MONITORING_ALLOWED_HIST_ALARMS}
    vDU Rest Login
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}  rmod_sn_count=${rmod_sn_count}
    Set Test Variable  ${rmod_serial_number_list}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${cells_count}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    Log  ${info_prefix}vDU operational state is OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${mrbts_id}
    ${rmods_runtime_dist_names_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names  rmod_sub_param=runtime
    ${rmod_runtime_dist_names}=  Get Dictionary Values  dictionary=${rmods_runtime_dist_names_dict}
    Set Test Variable  ${rmod_runtime_dist_names}
    ${rmods_config_dist_names_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names  rmod_sub_param=config
    Set Test Variable  ${rmods_config_dist_names_dict}
    ${prev_counters_time_dict}=  Create Dictionary
    Set Test Variable  ${prev_counters_time_dict}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_config_dn}=  Get From Dictionary  dictionary=${rmods_config_dist_names_dict}  key=${rmod_sn}
      ${last_counter_time}=  Get Counter Start Time  counter_id=${COUNTER_ID}  dist_name=${rmod_config_dn}
      Set To Dictionary  ${prev_counters_time_dict}  ${rmod_sn}=${last_counter_time}
    END
    Log  ${ok_prefix_green}Step 1: Initial check thermal counters monitoring and alarm triggering  console=${log_to_console}

Step 2: Activate Measurement Interval For Radio Module Thermal Monitoring
    Log  ${dots_prefix_green}Step 2: Activate measurement interval for radio module thermal monitoring  console=${log_to_console}
    Log  ${info_prefix}Setting parameter to activate measurement interval for radio module temperature monitoring  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRMODTemperature=${MEASUREMENT_INTERVAL}min  console=${log_to_console}
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    vdu.Perform Parameter Recommissioning  dist_name=${mtsbtsrmodtemperature_mo_dn}  parameter=mtSBTSRMODTemperature
    ...  operation=update  value=15min  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Measurement interval for radio module temperature monitoring has been activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Activate measurement interval for radio module thermal monitoring  console=${log_to_console}

Step 3: Get And Check Temperature Counters
    Log  ${dots_prefix_green}Step 3: Get and check temperature counters  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${MEASUREMENT_INTERVAL}
    Log  ${info_prefix}The counters (${COUNTER_ID}) will start being collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for counters (${COUNTER_ID}) to start collecting ...  console=${log_to_console}
    Sleep  ${time_to_sleep}min
    ${counters_start_time_dict}=  Create Dictionary
    Set Test Variable  ${counters_start_time_dict}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}=  Get From Dictionary  dictionary=${rmods_config_dist_names_dict}  key=${rmod_sn}
      ${counter_temperature}  ${counter_start_time}=  Get Counter And Check If Collected  counter_id=${COUNTER_ID}
      ...  dist_name=${rmod_dn}  prev_counter_time=${prev_counters_time_dict['${rmod_sn}']}
      Set To Dictionary  ${counters_start_time_dict}  ${rmod_sn}=${counter_start_time}
    END
    Log  ${info_prefix}All temperature counters (${COUNTER_ID}) have been checked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Get and check temperature counters  console=${log_to_console}

Step 4: Deactivate Measurement Interval For Radio Module Thermal Monitoring
    Log  ${dots_prefix_green}Step 4: Deactivate measurement interval for radio module thermal monitoring  console=${log_to_console}
    Log  ${info_prefix}Setting parameter to deactivate measurement interval for radio module temperature monitoring  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRMODTemperature=disabled  console=${log_to_console}
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    vdu.Perform Parameter Recommissioning  dist_name=${mtsbtsrmodtemperature_mo_dn}  parameter=mtSBTSRMODTemperature
    ...  operation=update  value=disabled  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Measurement interval for radio module temperature monitoring has been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Deactivate measurement interval for radio module thermal monitoring  console=${log_to_console}

Step 5: Configure Connection To Local Symptoms Server
    Log  ${dots_prefix_green}Step 5: Configure connection to local symptoms server  console=${log_to_console}
    Log  ${info_prefix}Configuring connection to local symptoms server (LSS)  console=${log_to_console}
    Log  ${below_info_prefix}lssConfig=[lssIPaddress=${LSS_SERVER_IP}, lssPortNo=${LSS_PORT}]  console=${log_to_console}
    ${lssConfig_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_dict}=  Create Dictionary  lssIPaddress=${LSS_SERVER_IP}  lssPortNo=${LSS_PORT}
    ${parameters_list}=  Create List  ${parameters_dict}
    vdu.Perform Parameter Recommissioning  dist_name=${lssConfig_mo_dn}  parameter=lssConfig
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Connection to local symptoms server configured  console=${log_to_console}
    vdu.Account Users Lss  username=syslab  password=Pass4System!
    Log  ${info_prefix}Local symptoms server user updated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Configure connection to local symptoms server  console=${log_to_console}

Step 6: Activate Fault Triggers For Snapshot
    Log  ${dots_prefix_green}Step 6: Activate fault triggers for snapshot  console=${log_to_console}
    Log  ${info_prefix}Activating fault triggers for snapshot  console=${log_to_console}
    Log  ${below_info_prefix}actDefaultFaultSnapTriggers=true  console=${log_to_console}
    Log  ${below_info_prefix}actRemoteSyslogTransmission=false  console=${log_to_console}
    Log  ${below_info_prefix}diagSnapDestination=lss  console=${log_to_console}
    Log  ${below_info_prefix}maxNumSnapByFaultTrigPerDay=200  console=${log_to_console}
    ${object_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${actdefaultfaultsnaptriggers_dict}=  Create Dictionary  parameterName=actDefaultFaultSnapTriggers
    ...  operation=update  value=true
    ${actremotesyslogtransmission _dict}=  Create Dictionary  parameterName=actRemoteSyslogTransmission
    ...  operation=update  value=false
    ${diagsnapdestination_dict}=  Create Dictionary  parameterName=diagSnapDestination
    ...  operation=update  value=lss
    ${maxnumsnapbyfaulttrigperday_dict}=  Create Dictionary  parameterName=maxNumSnapByFaultTrigPerDay
    ...  operation=update  value=200
    ${parameters_list}=  Create List  ${actdefaultfaultsnaptriggers_dict}  ${actremotesyslogtransmission _dict}
    ...  ${diagsnapdestination_dict}  ${maxnumsnapbyfaulttrigperday_dict}
    vdu.Perform Object Recommissioning  dist_name=${object_mo_dn}  parameter=${parameters_list}
    ...    operation=update  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Fault triggers for snapshot activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Activate fault triggers for snapshot  console=${log_to_console}

Step 7: Define BTS Faults List To Trigger Automatic Symptom Data Collection
    Log  ${dots_prefix_green}Step 7: Define BTS faults list to trigger automatic symptom data collection  console=${log_to_console}
    Log  ${info_prefix}Setting BTS faults list (faultSnapshotTriggers) to trigger automatic symptom data collection
    ...  console=${log_to_console}
    Log  ${below_info_prefix}faultSnapshotTriggers=[faultNumber=4584, snapshotCoverageLevel=Full, triggerType=onFaultDetection]
    ...  console=${log_to_console}
    ${faultsnapshottriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_list}=  Get Fault Snapshot Triggers List  scfc_file_path=${VDU_SCF_PATH}
    ${parameter_dict}=  Create Dictionary  faultNumber=4584
    ...  snapshotCoverageLevel=Full  triggerType=onFaultDetection
    Append To List  ${parameters_list}  ${parameter_dict}
    vdu.Perform Parameter Recommissioning  dist_name=${faultsnapshottriggers_mo_dn}  parameter=faultSnapshotTriggers
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}BTS faults list to trigger automatic symptom data collection has been defined  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Define BTS faults list to trigger automatic symptom data collection   console=${log_to_console}

Step 8: Define Kpi List To Trigger Automatic Alarm
    Log  ${dots_prefix_green}Step 8: Define KPI list to trigger automatic alarm  console=${log_to_console}
    Log  ${info_prefix}Setting KPI list (kpiAlarmTriggers) to trigger automatic alarm  console=${log_to_console}
    ${kpialarmtriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_dict}=  Create Dictionary  faultID=4584  formulaDescription=Custom temperature fault
    ...  timeToTrigger=1  triggeringFormula=SBTS_RM_MAX_TEMPERATURE >= 0
    ${parameters_list}=  Create List  ${parameters_dict}
    vdu.Perform Parameter Recommissioning  dist_name=${kpialarmtriggers_mo_dn}  parameter=kpiAlarmTriggers
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}KPI list to trigger automatic alarm has been defined  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Define KPI list to trigger automatic alarm  console=${log_to_console}

Step 9: Activate KPI Triggered Alarm Functionality
    Log  ${dots_prefix_green}Step 9: Activate KPI triggered alarm functionality  console=${log_to_console}
    Log  ${info_prefix}Setting parameter to activate KPI triggered alarm functionality  console=${log_to_console}
    Log  ${below_info_prefix}actKpiAlarms=true  console=${log_to_console}
    ${actkpialarms_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    vdu.Perform Parameter Recommissioning  dist_name=${actkpialarms_mo_dn}  parameter=actKpiAlarms
    ...  operation=update  value=true  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}KPI triggered alarm functionality has been activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Activate KPI triggered alarm functionality  console=${log_to_console}

Step 10: Wait For Triggered Alarms
    Log  ${dots_prefix_green}Step 10: Wait for triggered alarms  console=${log_to_console}
    Log  ${info_prefix}Waiting for defined faults on radio modules  console=${log_to_console}
    ${alarm_severity_list}=  Create List  minor
    vDU Assert Alarm Active  fault_id=4584  alarming_object_list=${rmod_runtime_dist_names}
    ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False  timeout=240
    Log  ${below_info_prefix}4584 faults on radio modules checked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 10: Wait for triggered alarms  console=${log_to_console}

Step 11: Check If Triggered Snapshot Collected
    Log  ${dots_prefix_green}Step 11: Check if triggered snapshot collected  console=${log_to_console}
    Log  ${info_prefix}Snapshot triggered and history files are checking  console=${log_to_console}
    ${snapshot_history_file_before}=  vdu.Get Snapshot History File
    ${line_count_before}=  Run  grep "Remote:4584 - On fault detection" ${snapshot_history_file_before} | grep succeeded | wc -l
    ${vdu_data}=  vdu.Get Vdu State Data
    ${snapshot_dir_name}=  Set Variable
    ...  Snapshot_MRBTS-${vdu_data['mrbts_id']}_${vdu_data['name']}_${vdu_data['software_version']}
    Set Test Variable  ${snapshot_dir_name}
    ${snapshot_dirs_count_before}=  Get Number Of Collected Snapshot File Directories  snapshot_dir_name=${snapshot_dir_name}
    Log  ${below_info_prefix}Snapshot triggered files are being collected. Please wait ...  console=${log_to_console}
    Wait Until Keyword Succeeds  ${SNAPSHOT_TIMEOUT}  40s
    ...  Check_Triggered_Snapshot_Status  snapshot_status=idle
    Log  ${below_info_prefix}Snapshot triggered files have been collected  console=${log_to_console}
    ${snapshot_history_file}=  vdu.Get Snapshot History File
    Log  ${below_info_prefix}Snapshot history file has been collected  console=${log_to_console}
    ${line_count_after}=  Run  grep "Remote:4584 - On fault detection" ${snapshot_history_file} | grep succeeded | wc -l
    Run Keyword If  ${line_count_before}>=${line_count_after}
    ...  Run Keyword And Continue On Failure
    ...  Fail  msg=There is no new snapshot result information ("succeeded") in snapshot history file !
    ...  ELSE
    ...  Log  ${below_info_prefix}Snapshot history file has been checked  console=${log_to_console}
    ${snapshot_dirs_count_after}=  Get Number Of Collected Snapshot File Directories  snapshot_dir_name=${snapshot_dir_name}
    Run Keyword If  ${snapshot_dirs_count_before}>=${snapshot_dirs_count_after}
    ...  Run Keyword And Continue On Failure
    ...  Fail  msg=There is no new triggered snapshot directory on LSS server!
    ...  ELSE
    ...  Log  ${below_info_prefix}Snapshot triggered files directory exists on LSS server  console=${log_to_console}
    Log  ${ok_prefix_green}Step 11: Check if triggered snapshot collected  console=${log_to_console}

Step 12: Define Kpi List To Cancel Automatic Alarm
    Log  ${dots_prefix_green}Step 12: Define KPI list to cancel automatic alarm  console=${log_to_console}
    Log  ${info_prefix}Setting KPI list (kpiAlarmTriggers) to cancel automatic alarm  console=${log_to_console}
    ${kpialarmtriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_dict}=  Create Dictionary  faultID=4584  formulaDescription=Custom temperature fault
    ...  timeToTrigger=1  triggeringFormula=SBTS_RM_MAX_TEMPERATURE < 0
    ${parameters_list}=  Create List  ${parameters_dict}
    vdu.Perform Parameter Recommissioning  dist_name=${kpialarmtriggers_mo_dn}  parameter=kpiAlarmTriggers
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}KPI list to cancel automatic alarm has been defined  console=${log_to_console}
    Log  ${ok_prefix_green}Step 12: Define KPI list to trigger automatic alarm  console=${log_to_console}

Step 13: Wait For Triggered Alarms To Cancel
    Log  ${dots_prefix_green}Step 13: Wait for triggered alarms to cancel  console=${log_to_console}
    Log  ${info_prefix}Waiting for defined faults on radio modules to be canceled  console=${log_to_console}
    ${alarm_severity_list}=  Create List  minor
    vDU Assert Alarm Inactive  fault_id=4584  alarming_object_list=${rmod_runtime_dist_names}
    ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False  timeout=60
    Log  ${below_info_prefix}4584 faults on radio modules checked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 13: Wait for triggered alarms to cancel  console=${log_to_console}

Step 14: Verify Counters When Thermal Monitoring Disabled
    Log  ${dots_prefix_green}Step 14: Verify counters when thermal monitoring disabled  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${MEASUREMENT_INTERVAL}
    Log  ${info_prefix}The counters will not be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for counters to be collected ...  console=${log_to_console}
    Sleep  ${time_to_sleep} min
    Log  ${info_prefix}Verification of counter deactivation for radio modules ...  console=${log_to_console}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}=  Get From Dictionary  dictionary=${rmods_config_dist_names_dict}  key=${rmod_sn}
      ${counter_prev_start_time}=  Get From Dictionary  dictionary=${counters_start_time_dict}  key=${rmod_sn}
      Log  ${below_info_prefix}Verification of counter deactivation for radio module (sn: ${rmod_sn})  console=${log_to_console}
      Counter Should Be Deactivated  counter_id=${COUNTER_ID}  dist_name=${rmod_dn}  prev_counter_time=${counter_prev_start_time}
    END
    Log  ${info_prefix}All counters have been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 14: Verify counters when thermal monitoring disabled  console=${log_to_console}

Step 15: Deactivate KPI Triggered Alarm Functionality
    Log  ${dots_prefix_green}Step 15: Deactivate KPI triggered alarm functionality  console=${log_to_console}
    Log  ${info_prefix}Setting parameter to deactivate KPI triggered alarm functionality  console=${log_to_console}
    Log  ${below_info_prefix}actKpiAlarms=false  console=${log_to_console}
    ${actkpialarms_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    vdu.Perform Parameter Recommissioning  dist_name=${actkpialarms_mo_dn}  parameter=actKpiAlarms
    ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}KPI triggered alarm functionality has been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 15: Deactivate KPI triggered alarm functionality  console=${log_to_console}

Step 16: Delete Kpi List To Trigger Automatic Alarm
    Log  ${dots_prefix_green}Step 16: Delete KPI list to trigger automatic alarm  console=${log_to_console}
    Log  ${info_prefix}Deleting KPI list (kpiAlarmTriggers) to trigger automatic alarm  console=${log_to_console}
    ${kpialarmtriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${values_list}=  Create List
    ${parameters_dict}=  Create Dictionary  parameterName=kpiAlarmTriggers  operation=delete
    ...  value=${values_list}
    ${parameters_list}=  Create List  ${parameters_dict}
    vdu.Perform Object Recommissioning  dist_name=${kpialarmtriggers_mo_dn}  parameter=${parameters_list}
    ...    operation=update  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}KPI list to trigger automatic alarm has been deleted  console=${log_to_console}
    Log  ${ok_prefix_green}Step 16: Delete KPI list to trigger automatic alarm  console=${log_to_console}

Step 17: Set Default BTS Faults List To Trigger Automatic Symptom Data Collection
    Log  ${dots_prefix_green}Step 17: Set default BTS faults list to trigger automatic symptom data collection  console=${log_to_console}
    Log  ${info_prefix}Setting default BTS faults list (faultSnapshotTriggers) to trigger automatic symptom data collection
    ...  console=${log_to_console}
    ${faultsnapshottriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_list}=  Get Fault Snapshot Triggers List  scfc_file_path=${VDU_SCF_PATH}
    vdu.Perform Parameter Recommissioning  dist_name=${faultsnapshottriggers_mo_dn}  parameter=faultSnapshotTriggers
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}BTS default faults list to trigger automatic symptom data collection has been defined  console=${log_to_console}
    Log  ${ok_prefix_green}Step 17: Set default BTS faults list to trigger automatic symptom data collection   console=${log_to_console}

Step 18: Postconditions Thermal Counters Monitoring And Alarm Triggering
    Log  ${dots_prefix_green}Step 18: Postconditions thermal counters monitoring  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 18: Postconditions thermal counters monitoring  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Get Number Of Collected Snapshot File Directories
    [Arguments]  ${snapshot_dir_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the number of snapshot directories from the LSS server with the given name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | snapshot_dir_name      | Yes  | Snapshot directory name.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    tafssh.Connect To  hostname=${LSS_SERVER_IP}  username=${LSS_USERNAME}
    ...  password=${LSS_PASSWORD}  port=${LSS_PORT}  alias=default  timeout=30
    ${snapshot_dirs}=  tafssh.Execute  command=ls -d ${snapshot_dir_name}* 2>/dev/null
    ${snapshot_dirs_list} =	Get Regexp Matches	string=${snapshot_dirs}	pattern=Snapshot.*
    ${snapshot_dirs_count}=  Get Length  item=${snapshot_dirs_list}
    tafssh.disconnect  connection=default
    [Return]  ${snapshot_dirs_count}

Remove Collected Snapshot Directory
    [Arguments]  ${snapshot_dir_name}
    [Documentation]
    ...  Description:
    ...  Keyword removes the snapshot directory from the LSS server with the given name.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | snapshot_dir_name     | Yes  | Snapshot directory name.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    tafssh.Connect To  hostname=${LSS_SERVER_IP}  username=${LSS_USERNAME}
    ...  password=${LSS_PASSWORD}  port=${LSS_PORT}  alias=default  timeout=30
    tafssh.Execute  command=rm -fr ${snapshot_dir_name}
    tafssh.disconnect  connection=default

Get Fault Snapshot Triggers List
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword returns the list of BTS faults that trigger automatic symptom data collection based on scfc file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${parameters_list}=  Create List
    ${parameters_dict}=  Create Dictionary
    ${item_list}=  Get Elements  source=${scfc_file_path}
    ...  xpath=//managedObject[@class='com.nokia.srbts.mnl:TRBLCADM']/list[@name="faultSnapshotTriggers"]/item
    FOR  ${item_element}  IN  @{item_list}
      ${element_list}=  Get Elements  source=${item_element}  xpath=.//*
      FOR  ${element}  IN  @{element_list}
        ${element_attribute}=  Get Element Attribute  source=${element}  name=name
        ${element_text}=  Get Element Text  source=${element}  xpath=.
        Set To Dictionary  ${parameters_dict}  ${element_attribute}=${element_text}
      END
      Append To List  ${parameters_list}  ${parameters_dict}
      ${parameters_dict}=  Create Dictionary
    END
    [Return]  ${parameters_list}

Check_Triggered_Snapshot_Status
    [Arguments]  ${snapshot_status}
    [Documentation]
    ...  Description:
    ...  Keyword waits for the expected status of the snapshot collection operation.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | snapshot_status        | Yes  | Expected status of the snapshot collection operation.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${actual_snapshot_status}=  vdu.Check Snapshot Status
    Should Be Equal As Strings  first=${actual_snapshot_status}  second=${snapshot_status}

Radio Module Thermal Counters Monitoring And Alarm Triggering Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed (PASS or FAIL).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error
    ...  Remove Collected Snapshot Directory  snapshot_dir_name=${snapshot_dir_name}*
    Run Keyword If  '${tc_status}'=='PASS'  Run Keyword And Ignore Error  vDU Rest Logout
    Return From Keyword If  '${tc_status}'=='PASS'
    #Deactivate KPI Triggered Alarm Functionality
    ${actkpialarms_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    vdu.Perform Parameter Recommissioning  dist_name=${actkpialarms_mo_dn}  parameter=actKpiAlarms
    ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    #Deactivate Measurement Interval For Radio Module Thermal Monitoring
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    vdu.Perform Parameter Recommissioning  dist_name=${mtsbtsrmodtemperature_mo_dn}  parameter=mtSBTSRMODTemperature
    ...  operation=update  value=disabled  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    #Delete Kpi List To Trigger Automatic Alarm
    ${kpialarmtriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${values_list}=  Create List
    ${parameters_dict}=  Create Dictionary  parameterName=kpiAlarmTriggers  operation=delete
    ...  value=${values_list}
    ${parameters_list}=  Create List  ${parameters_dict}
    vdu.Perform Object Recommissioning  dist_name=${kpialarmtriggers_mo_dn}  parameter=${parameters_list}
    ...    operation=update  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    #Set Default BTS Faults List To Trigger Automatic Symptom Data Collection
    ${faultsnapshottriggers_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ${parameters_list}=  Get Fault Snapshot Triggers List  scfc_file_path=${VDU_SCF_PATH}
    vdu.Perform Parameter Recommissioning  dist_name=${faultsnapshottriggers_mo_dn}  parameter=faultSnapshotTriggers
    ...  operation=update  value=${parameters_list}  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Run Keyword And Ignore Error  vDU Rest Logout
