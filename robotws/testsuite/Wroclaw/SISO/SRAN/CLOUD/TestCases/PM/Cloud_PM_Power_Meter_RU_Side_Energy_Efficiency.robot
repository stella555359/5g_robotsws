*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}=  15
# SBTS energy consumption in radio modules (M40002C1) counter
@{M40002CX_COUNTERS}=  M40002C1
# SBTS RFM energy monitoring (M40003) counters
@{M40003CX_COUNTERS}=  M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
# O-RAN radio counters
@{M40021CX_COUNTERS}=  M40021C0  M40021C1  M40021C2  M40021C6  M40021C7  M40021C8  M40021C9  M40021C10  M40021C11
@{SBTS_COUNTERS}=  @{M40002CX_COUNTERS}
@{SBTS_ORAN_COUNTERS}=  @{M40003CX_COUNTERS}  @{M40021CX_COUNTERS}

*** Keywords ***
TC__Cloud_PM_Power_Meter_RU_Side_Energy_Efficiency
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}  ${cbts_rmod_sn_count}=0
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FPB-1283159
    ...  Feature CB013026 brings parity to the list of energy saving functionalities when used with O-RU (RF8.0).
    ...  Feature CB013026-E - Power Meter on RU side Energy Efficiency (parity to 5GC000433/CB007777/CB011206/CB006831)
    ...  Feature CB013026-E provides "Power Meter on RU side Energy Efficiency" functionalities,
    ...  specifically aiming to achieve feature parity for RF8-based Nokia O-RAN Units (O-RU).
    ...
    ...  O-RAN EPE measurement counters (Power, Voltage, Current) as reported by RF8 are reused to provide
    ...  the necessary Power, Voltage and Current legacy measurements counters.
    ...  Legacy SBTS counters:
    ...  M40002C1: ENERGY_CONSUMPTION_IN_RF
    ...  M40003C0: MIN_INPUT_VOLTAGE_IN_RF
    ...  M40003C1: MAX_INPUT_VOLTAGE_IN_RF
    ...  M40003C2: RU_ENERGY_CONSUMPTION
    ...  M40003C3: RU_MIN_PWR_USAGE
    ...  M40003C4: RU_AVG_PWR_USAGE
    ...  M40003C5: RU_MAX_PWR_USAGE
    ...  ORAN specific counters introduced as part of CB009196:
    ...  M40021C0: O_RAN_RADIO_POWER_MAX
    ...  M40021C1: O_RAN_RADIO_POWER_MIN
    ...  M40021C2: O_RAN_RADIO_POWER_AVG
    ...  M40021C6: O_RAN_RADIO_VOLTAGE_MAX
    ...  M40021C7: O_RAN_RADIO_VOLTAGE_MIN
    ...  M40021C8: O_RAN_RADIO_VOLTAGE_AVG
    ...  M40021C9: O_RAN_RADIO_CURRENT_MAX
    ...  M40021C10: O_RAN_RADIO_CURRENT_MIN
    ...  M40021C11: O_RAN_RADIO_CURRENT_AVG
    ...  Note: O-RAN EPE Temperature counters are not supported with current feature scope.
    ...
    ...  Test case checks whether the appropriate counters (legacy SBTS counters, ORAN specific counters)
    ...  have been collected after enabling the CB013026-E feature, and then after disabling the CB013026-E feature,
    ...  test case checks whether the appropriate counters are not collected.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_rmod_sn_list}
    Set Test Variable  ${cbts_rmod_sn_count}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Power_Meter_Energy_Efficiency  console=${log_to_console}
    Step 1: Preconditions Power Meter RU Side Energy Efficiency
    Step 2: Set Initial Parameters Power Meter RU Side Energy Efficiency
    Step 3: Activate Power Meter Energy Efficiency Feature
    Step 4: Set Energy Monitoring Measurement Intervals
    Step 5: Get And Verify Counters When Energy Monitoring Activated
    Step 6: Disable Energy Monitoring Measurement Intervals
    Step 7: Get And Verify Counters When Energy Monitoring Deactivated
    Step 8: Deactivate Power Meter Energy Efficiency Feature
    Step 9: Postconditions Power Meter Energy Efficiency
    Log  ${done_prefix_green}Test Case: Power_Meter_Energy_Efficiency  console=${log_to_console}
    [Teardown]  Power Meter RU Side Energy Efficiency Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Preconditions Power Meter RU Side Energy Efficiency
    Log  ${dots_prefix_green}Step 1: Preconditions power meter RU side energy efficiency  console=${log_to_console}
    vDU Rest Login  vdu_connection=${vdu_connection}
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
# Get and set variables
    ${pmmnl_dist_name_list}=  Get Dist Names Current Plan Objects
    ...  class_name_list=PMMNL
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${pmmnl_dist_name}  ${pmmnl_dist_name_list[0]}
    ${featcadm_dist_name_list}=  Get Dist Names Current Plan Objects
    ...  class_name_list=FEATCADM
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${featcadm_dist_name}  ${featcadm_dist_name_list[0]}
    ${mrbts_dist_name_list}=  Get Dist Names Current Plan Objects
    ...  class_name_list=MRBTS
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${mrbts_dist_name}  ${mrbts_dist_name_list[0]}
    ${cbts_rmod_serial_number_list}=  Get Radio Modules Serial Numbers List
    ...  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${cbts_rmod_sn_list}
    ...  rmod_sn_count=${cbts_rmod_sn_count}
    Set Test Variable  ${cbts_rmod_serial_number_list}
    ${cbts_rmods_config_dist_names_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names
    ...  rmod_sub_param=config
    Set Test Variable  ${cbts_rmods_config_dist_names_dict}
    Log  ${ok_prefix_green}Step 1: Preconditions power meter RU side energy efficiency  console=${log_to_console}

Step 2: Set Initial Parameters Power Meter RU Side Energy Efficiency
    Log  ${dots_prefix_green}Step 2: Set initial parameters power meter RU side energy efficiency  console=${log_to_console}
    Log  ${info_prefix}Initial parameters are checked and set  console=${log_to_console}
#  Deactivating BTS Embedded Power Meter (actPowerMeter=false)
    ${actpowermeter_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${featcadm_dist_name}
    ...  para_name=actPowerMeter
    IF  '${actpowermeter_value}'=='true'
      Log  ${info_prefix}Power meter feature is deactivated. Please wait ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning
      ...  dist_name=${featcadm_dist_name}
      ...  parameter=actPowerMeter
      ...  operation=update
      ...  value=false
      ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ...  vdu_connection=${vdu_connection}
      Log  ${below_info_prefix}Power meter feature has been deactivated  console=${log_to_console}
    END
# Disabling energy monitoring measurement intervals
    Log  ${info_prefix}Energy monitoring measurement intervals are disabled. Please wait ...  console=${log_to_console}
    Set Energy Monitoring Measurement Intervals  parameter_value=disabled
    Log  ${below_info_prefix}Energy monitoring measurement intervals have been disabled  console=${log_to_console}
# Get SBTS_COUNTERS start time values (MRBTS object)
    &{sbts_counters_start_time_dict}=  Create Dictionary
    Set Test Variable  ${sbts_counters_start_time_dict}
    FOR  ${counter_id}  IN  @{SBTS_COUNTERS}
      ${start_counter_time}=  Get Counter Start Time  counter_id=${counter_id}  dist_name=${mrbts_dist_name}
      Set To Dictionary  ${sbts_counters_start_time_dict}  ${counter_id}=${start_counter_time}
    END
    Log  message=${sbts_counters_start_time_dict}
# Get SBTS_ORAN_COUNTERS start time values (MRBTS/EQM/APEQM/RMOD object)
    &{sbts_oran_counters_start_time_dict}=  Create Dictionary
    ${sbts_oran_counters_start_time_list}=  Create List
    Set Test Variable  ${sbts_oran_counters_start_time_dict}
    FOR  ${cbts_rmod_sn}  IN  @{cbts_rmod_serial_number_list}
      ${cbts_rmod_config_dn}=  Get From Dictionary  dictionary=${cbts_rmods_config_dist_names_dict}  key=${cbts_rmod_sn}
      FOR  ${counter_id}  IN  @{SBTS_ORAN_COUNTERS}
        ${start_counter_time}=  Get Counter Start Time  counter_id=${counter_id}  dist_name=${cbts_rmod_config_dn}
        &{start_counter_time_dict}=  Create Dictionary  ${counter_id}=${start_counter_time}
        Append To List  ${sbts_oran_counters_start_time_list}  ${start_counter_time_dict}
        Set To Dictionary  ${sbts_oran_counters_start_time_dict}  ${cbts_rmod_sn}=${sbts_oran_counters_start_time_list}
      END
      ${sbts_oran_counters_start_time_list}=  Create List
    END
    Log  message=${sbts_oran_counters_start_time_dict}
    Log  ${ok_prefix_green}Step 2: Set initial parameters power meter RU side energy efficiency  console=${log_to_console}

Step 3: Activate Power Meter Energy Efficiency Feature
    Log  ${dots_prefix_green}Step 3: Activate power meter energy efficiency feature  console=${log_to_console}
#  Activating BTS Embedded Power Meter (actPowerMeter=true)
    Log  ${info_prefix}Power meter feature is activated. Please wait ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning
    ...  dist_name=${featcadm_dist_name}
    ...  parameter=actPowerMeter
    ...  operation=update
    ...  value=true
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Power meter feature has been activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Activate power meter energy efficiency feature  console=${log_to_console}

Step 4: Set Energy Monitoring Measurement Intervals
    Log  ${dots_prefix_green}Step 4: Set energy monitoring measurement intervals  console=${log_to_console}
# Setting energy monitoring measurement intervals
    Log  ${info_prefix}Energy monitoring measurement intervals are set. Please wait ...  console=${log_to_console}
    Set Energy Monitoring Measurement Intervals  parameter_value=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}min
    Log  ${below_info_prefix}Energy monitoring measurement intervals have been set  console=${log_to_console}
    Log  ${below_info_prefix}mtBtsEnergyMonitoring=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}min  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRfmEnergyMonitoring=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}min  console=${log_to_console}
    Log  ${below_info_prefix}miOranEpeStats=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}min  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Set energy monitoring measurement intervals  console=${log_to_console}

Step 5: Get And Verify Counters When Energy Monitoring Activated
    Log  ${dots_prefix_green}Step 5: Get and verify counters when energy monitoring activated  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}
    Log  ${info_prefix}The counters will start being collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${below_info_prefix}Wait ${time_to_sleep} minutes for counters to start collecting ...  console=${log_to_console}
    Sleep  ${time_to_sleep}min
# Get and check SBTS_COUNTERS if collected (MRBTS object)
    Log  ${info_prefix}Verification of SBTS (MRBTS object) counters ...  console=${log_to_console}
    &{sbts_counters_active_time_dict}=  Create Dictionary
    Set Test Variable  ${sbts_counters_active_time_dict}
    ${sbts_counters_list}=  Get Dictionary Keys  dictionary=${sbts_counters_start_time_dict}
    FOR  ${counter_id}  IN  @{sbts_counters_list}
      ${last_counter_time}=  Get From Dictionary  dictionary=${sbts_counters_start_time_dict}  key=${counter_id}
      ${counter_value}  ${counter_start_time}=  Get Counter And Check If Collected
      ...  counter_id=${counter_id}
      ...  dist_name=${mrbts_dist_name}
      ...  prev_counter_time=${last_counter_time}
      Set To Dictionary  ${sbts_counters_active_time_dict}  ${counter_id}=${counter_start_time}
    END
    Log  message=${sbts_counters_active_time_dict}
    Log  ${below_info_prefix}SBTS (MRBTS object) counters have been verified ...  console=${log_to_console}
# Get and check SBTS_ORAN_COUNTERS if collected (MRBTS/EQM/APEQM/RMOD object)
    Log  ${info_prefix}Verification of SBTS and ORAN (MRBTS/EQM/APEQM/RMOD object) counters ...  console=${log_to_console}
    &{sbts_oran_counters_active_time_dict}=  Create Dictionary
    ${sbts_oran_counters_active_time_list}=  Create List
    Set Test Variable  ${sbts_oran_counters_active_time_dict}
    FOR  ${cbts_rmod_sn}  IN  @{cbts_rmod_serial_number_list}
      Log  ${below_info_prefix}Verification of counter for radio module (sn: ${cbts_rmod_sn})  console=${log_to_console}
      ${cbts_rmod_config_dn}=  Get From Dictionary  dictionary=${cbts_rmods_config_dist_names_dict}  key=${cbts_rmod_sn}
      ${last_counters_time_list}=  Get From Dictionary  dictionary=${sbts_oran_counters_start_time_dict}  key=${cbts_rmod_sn}
      FOR  ${last_counter_time_dict}  IN  @{last_counters_time_list}
        ${counter_id}=  Get Dictionary Keys  dictionary=${last_counter_time_dict}
        ${last_counter_time}=  Get Dictionary Values  dictionary=${last_counter_time_dict}
        ${counter_value}  ${counter_start_time}=  Get Counter And Check If Collected
        ...  counter_id=${counter_id[0]}
        ...  dist_name=${cbts_rmod_config_dn}
        ...  prev_counter_time=${last_counter_time[0]}
        &{actual_counter_time_dict}=  Create Dictionary  ${counter_id[0]}=${counter_start_time}
        Append To List  ${sbts_oran_counters_active_time_list}  ${actual_counter_time_dict}
        Set To Dictionary  ${sbts_oran_counters_active_time_dict}  ${cbts_rmod_sn}=${sbts_oran_counters_active_time_list}
      END
      ${sbts_oran_counters_active_time_list}=  Create List
    END
    Log  message=${sbts_oran_counters_active_time_dict}
    Log  ${below_info_prefix}SBTS and ORAN (MRBTS/EQM/APEQM/RMOD object) counters have been verified ...  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Get and verify counters when energy monitoring activated  console=${log_to_console}

Step 6: Disable Energy Monitoring Measurement Intervals
    Log  ${dots_prefix_green}Step 6: Activate energy monitoring measurement intervals  console=${log_to_console}
# Disabling energy monitoring measurement intervals
    Log  ${info_prefix}Energy monitoring measurement intervals are disabled. Please wait ...  console=${log_to_console}
    Set Energy Monitoring Measurement Intervals  parameter_value=disabled
    Log  ${below_info_prefix}Energy monitoring measurement intervals have been disabled  console=${log_to_console}
    Log  ${below_info_prefix}mtBtsEnergyMonitoring=disabled  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRfmEnergyMonitoring=disabled  console=${log_to_console}
    Log  ${below_info_prefix}miOranEpeStats=disabled  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Set energy monitoring measurement intervals  console=${log_to_console}

Step 7: Get And Verify Counters When Energy Monitoring Deactivated
    Log  ${dots_prefix_green}Step 7: Get and verify counters when energy monitoring deactivated  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${POWER_METER_ENERGY_EFFICIENCY_MEASUREMENT_INTERVAL}
    Log  ${info_prefix}The counters will not be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${below_info_prefix}Wait ${time_to_sleep} minutes for counters to start collecting ...  console=${log_to_console}
    Sleep  ${time_to_sleep}min
# Get and check SBTS_COUNTERS if not collected
    Log  ${info_prefix}Verification of SBTS (MRBTS object) counters ...  console=${log_to_console}
      ${sbts_counters_list}=  Get Dictionary Keys  dictionary=${sbts_counters_active_time_dict}
      FOR  ${counter_id}  IN  @{sbts_counters_list}
        ${last_counter_time}=  Get From Dictionary  dictionary=${sbts_counters_active_time_dict}  key=${counter_id}
        Counter Should Be Deactivated
        ...  counter_id=${counter_id}
        ...  dist_name=${mrbts_dist_name}
        ...  prev_counter_time=${last_counter_time}
      END
    Log  ${below_info_prefix}SBTS (MRBTS object) counters have been verified ...  console=${log_to_console}
# Get and check SBTS_ORAN_COUNTERS if not collected
    Log  ${info_prefix}Verification of SBTS and ORAN (MRBTS/EQM/APEQM/RMOD object) counters ...  console=${log_to_console}
    FOR  ${cbts_rmod_sn}  IN  @{cbts_rmod_serial_number_list}
      Log  ${below_info_prefix}Verification of counter for radio module (sn: ${cbts_rmod_sn})  console=${log_to_console}
      ${cbts_rmod_config_dn}=  Get From Dictionary  dictionary=${cbts_rmods_config_dist_names_dict}  key=${cbts_rmod_sn}
      ${last_counters_time_list}=  Get From Dictionary  dictionary=${sbts_oran_counters_active_time_dict}  key=${cbts_rmod_sn}
      FOR  ${last_counter_time_dict}  IN  @{last_counters_time_list}
        ${counter_id}=  Get Dictionary Keys  ${last_counter_time_dict}
        ${last_counter_time}=  Get Dictionary Values  ${last_counter_time_dict}
        Counter Should Be Deactivated
        ...  counter_id=${counter_id[0]}
        ...  dist_name=${cbts_rmod_config_dn}
        ...  prev_counter_time=${last_counter_time[0]}
      END
    END
    Log  ${below_info_prefix}SBTS and ORAN (MRBTS/EQM/APEQM/RMOD object) counters have been verified ...  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Get and verify counters when energy monitoring deactivated  console=${log_to_console}

Step 8: Deactivate Power Meter Energy Efficiency Feature
    Log  ${dots_prefix_green}Step 8: Deactivate power meter energy efficiency feature  console=${log_to_console}
#  Deactivating BTS Embedded Power Meter (actPowerMeter=false)
    Log  ${info_prefix}Power meter feature is deactivated. Please wait ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning
    ...  dist_name=${featcadm_dist_name}
    ...  parameter=actPowerMeter
    ...  operation=update
    ...  value=false
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Power meter feature has been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Deactivate power meter energy efficiency feature  console=${log_to_console}

Step 9: Postconditions Power Meter Energy Efficiency
    Log  ${dots_prefix_green}Step 9: Postconditions power meter energy efficiency  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=10s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Postconditions power meter energy efficiency  console=${log_to_console}

# INTERNAL TEST CASE KEYWORDS
Set Energy Monitoring Measurement Intervals
    [Arguments]  ${parameter_value}
    [Documentation]
    ...  Description:
    ...  Keyword sets monitoring measurement intervals (mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, miOranEpeStats).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | parameter_value        | Yes  |  Energy monitoring measurement interval value.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mtbtsenergymonitoring_dict}=  Create Dictionary  parameterName=mtBtsEnergyMonitoring
    ...  operation=update  value=${parameter_value}
    ${mtsbtsrfmenergymonitoring_dict}=  Create Dictionary  parameterName=mtSBTSRfmEnergyMonitoring
    ...  operation=update  value=${parameter_value}
    ${mioranepestats_dict}=  Create Dictionary  parameterName=miOranEpeStats
    ...  operation=update  value=${parameter_value}
    ${parameters_list}=  Create List  ${mtbtsenergymonitoring_dict}  ${mtsbtsrfmenergymonitoring_dict}  ${mioranepestats_dict}
    vdu.Perform Object Recommissioning
    ...  dist_name=${pmmnl_dist_name}
    ...  parameter=${parameters_list}
    ...  operation=update
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}

Power Meter RU Side Energy Efficiency Teardown
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

    IF  '${tc_status}'=='FAIL'
      Log  ${failed_result}Test case FAILED. Teardown operations will be executed  console=${log_to_console}
#  Deactivating BTS Embedded Power Meter (actPowerMeter=false)
      ${actpowermeter_value}=  vdu.Search Parameter Of Current Plan
      ...  mo_dn=${featcadm_dist_name}
      ...  para_name=actPowerMeter
      IF  '${actpowermeter_value}'=='true'
        Log  ${info_prefix}Power meter feature is deactivated. Please wait ...  console=${log_to_console}
        vdu.Perform Parameter Recommissioning
        ...  dist_name=${featcadm_dist_name}
        ...  parameter=actPowerMeter
        ...  operation=update
        ...  value=false
        ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Power meter feature has been deactivated  console=${log_to_console}
      END
# Setting energy monitoring measurement intervals
      Log  ${info_prefix}Energy monitoring measurement intervals are disabled. Please wait ...  console=${log_to_console}
      Set Energy Monitoring Measurement Intervals  parameter_value=disabled
      Log  ${below_info_prefix}Energy monitoring measurement intervals have been disabled  console=${log_to_console}
    END
    Run Keyword And Ignore Error  vDU Rest Logout
