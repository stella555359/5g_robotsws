*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.ul.alarms_watchdog.interface.alarms_watchdog   WITH NAME    awd
Library    taf.rfrl.common_resources.python.ims2_alarms.IMS2AlarmVerifier   WITH NAME    iav


Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/admin.robot
Resource    ../../../resources/Robot/pdu.robot

*** Variables ***
# Maximum time to wait for complete reset RMOD operation
${RMOD_RESET_MAX_WAIT_TIME}=    300s
# Allowed test case historical alarms
@{VCU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
@{VDU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
...                                          faultId=4589, severity=warning
@{SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, alarmingObjectIds[0].runtime=regex".*RMOD_R-/d+$"

*** Keywords ***
TC__Cloud_SBTS_STARTUP_Radio_Modules_Power_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${sbts_scfc_file_path}  ${rmod_sn_list}=@{EMPTY}
    ...  ${rmod_sn_count}=0  ${rmod_sn_dyinggasp_excluded_list}=@{EMPTY}
    ...  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}  ${admin_connection}=${ADMIN_CONNECTION_DEFAULT}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case performs radio module power off/on based on rmod serial number.
    ...  If the list of the radio modules serial numbers is empty then all radio modules are reset.
    ...  NOTE. Tested radio modules need to be described in CBTS init.py file under PDU objects.
    ...
    ...  Test is verifying DyingGaspAlarm CB005763
    ...  If any radio module should be excluded, fill in list 'RMOD_SN_DYINGGASP_EXCLUDED_LIST'
    ...  Supported DyingGaspAlarm radio modules can be found under LINK or in CFAM CB005763:
    ...  https://nokia.sharepoint.com/:x:/r/sites/ASCOP/_layouts/15/Doc.aspx?sourcedoc=%7BCBAC57CE-BC3D-4BAB-B798-7A940B1A44FA%7D&file=
    ...  Radios_DyingGaspAlarm_Support.xlsx&action=default&mobileredirect=true
    ...  Feature CB005763 limitations:
    ...  1. With ABIL, the feature is limitted to CPRI/FDD only; the feature doesn't support eCPRI/TDD on ABIL.
    ...  2. This feature heavily depends on the capabilities of the radio hardware. For CPRI radios, when the RU loses power,
    ...     the PSU can sustain supply for at least 1 ms, RU can send at least 15 consecutive hyperframes with power loss alarm.
    ...     For eCPRI radios, when the RU loses power, the PSU can sustain supply for at least 400 µs,
    ...     RU can send at least one ethernet message with power loss alarm.
    ...  3. RF family ScRMTDr6.1_2T2R, FRMTDr5.1a_1_8T8R, and FRMTDr5.1_2T2R are not supported for RF chaining, making them out of scope as well.
    ...  4. For the RF family FRMr5.1_1_6T6R (eg. AREA), the Dying Gasp alarm cannot be reported in the following
    ...     scenarios due to RU hardware limitations:
    ...     i. When in RF standalone configuration with the link connected to RF OPT3.
    ...     ii. When in RF sharing or RF split configuration with the primary link connected to RF OPT3.
    ...  5. With eCPRI M-Plane resilience feature enabled (CB005833), upon link failure and until switchover to the redundant link is complete,
    ...     there is no guarantee that dying gasp message will be successfully delivered to the DU.
    ...  6. The FHS does not monitor or report PSU alarm sent by a CPRI-N radio directly connected to it.
    ...  7. For the MAA Rel 6.2 RF Family, RU Dying Gasp Alarm won't be transmitted when RU is in Deep Sleep Mode.
    ...
    ...  Test supports RF sharing SBTS-CBTS configuration.
    ...  Test case supports:
    ...  - CBTS side: NR cells
    ...  - SBTS side: LTE cells
    ...  SCF file should contain the serial numbers of the radio modules.
    ...
    ...  Step 1: CBTS Sharing Preconditions Radio Modules Power Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  d) Set Specific CBTS global variables
    ...  Step 2: SBTS Sharing Preconditions Radio Modules Power Reset
    ...  a) BTS procedural state should be OnAir
    ...  b) All radio modules should be on line
    ...  c) All cells should be OnAir
    ...  d) Set Specific SBTS global variables
    ...  Step 3: Power Off Radio Module
    ...  Step 4: Check Target Radio Module State And Faults After Power Off On CBTS
    ...  a) Check tested radio module states on CBTS
    ...  b) Check tested radio module NR cells states on CBTS
    ...  c) Check active fault on CBTS - fault 10 (dyinggasp suplementary info if supported)
    ...  Step 5: Check Non-Target Radio Modules States After Power Off On CBTS
    ...  a) Check not impacted NR cells states on CBTS
    ...  b) Check not impacted radio modules states on CBTS
    ...  Step 6: Check Target Radio Module State And Faults After Power Off On SBTS
    ...  a) Check tested radio module states on SBTS
    ...  b) Check tested radio module LTE cells states on SBTS
    ...  c) Check tested radio module IoT cells states on SBTS
    ...  d) Check active fault on SBTS (fault 10/dyinggasp suplementary info and R&D 4774 if suppoerted)
    ...  Step 7: Check Non-Target Radio Modules States After Power Off On SBTS
    ...  a) Check not impacted radio modules states on SBTS
    ...  b) Check not impacted radio module LTE cells states on SBTS
    ...  c) Check not impacted radio module IoT cells states on SBTS
    ...  Step 8: Power On Radio Module
    ...  Step 9: Check CBTS State And Faults After Radio Module Power On
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  d) fault 10 is inactive
    ...  Step 10: Check SBTS State And Faults After Radio Module Power On
    ...  a) BTS procedural state should be OnAir
    ...  b) All radio modules should be on line
    ...  c) All cells should be OnAir
    ...  d) fault 10 is inactive
    ...
    ...  Arguments:
    ...  +==================================+======+============================================================================+
    ...  | Argument                         | Man. | Description                                                                |
    ...  +==================================+======+============================================================================+
    ...  | vdu_scfc_file_path               | Yes  | Path to the vDU scfc file.                                                 |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_scfc_file_path              | Yes  | Path to the scfc file.                                                     |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list                     |      | List of serial number of the tested radio modules.                         |
    ...  |                                  |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                                  |      | so all radio modules defined in the SCFC files will be used.               |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count                    |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                                  |      | the list obtained from the SCFC files.                                     |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_dyinggasp_excluded_list  |  No  | List of radio mudules serial numbers that are not supported by CB005763    |
    ...  |                                  |      | or dependent on limitations                                                |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection                   |  No  | vDU connection object or string name alias if used.                        |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection                 |  No  | Admin connection object or if used, string name alias.                     |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console                   |  No  | Show or not the information on the console.                                |
    ...  +----------------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${sbts_scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${rmod_sn_dyinggasp_excluded_list}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Power_Reset  console=${log_to_console}
    Prepare Tested Radio Modules SN List
    Step 1: CBTS Sharing Preconditions Radio Modules Power Reset
    Step 2: SBTS Sharing Preconditions Radio Modules Power Reset
    FOR  ${tested_rmod_sn}  IN  @{tested_rmod_serial_number_list}
      Set Test Variable  ${tested_rmod_sn}
      Step 3: Power Off Radio Module
      Step 4: Check Target Radio Module State And Faults After Power Off On CBTS
      Step 5: Check Non-Target Radio Modules States After Power Off On CBTS
      Step 6: Check Target Radio Module State And Faults After Power Off On SBTS
      Step 7: Check Non-Target Radio Modules States After Power Off On SBTS
      Step 8: Power On Radio Module
      Step 9: Check CBTS State And Faults After Radio Module Power On
      Step 10: Check SBTS State And Faults After Radio Module Power On
    END
    Log  ${done_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Power_Reset  console=${log_to_console}
    [Teardown]  TC_Cloud_SBTS_STARTUP_Radio_Modules_Power_Reset_Teardown  tc_status=${KEYWORD_STATUS}

Step 1: CBTS Sharing Preconditions Radio Modules Power Reset
    Log  ${dots_prefix_green}Step 1: CBTS Sharing Preconditions Radio Modules Power Reset  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}
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
    ${vdu_scfc_cell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_cell_id_list}
    ${cbts_rmod_sn_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_id_dict}
    ${cbts_rmod_sn_runtime_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names
    ...  rmod_sub_param=runtime
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_runtime_id_dict}
    ${cbts_rmod_sn_conf_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=configuration_id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_conf_id_dict}
    ${vdu_rmod_sn_list}=  Get Dictionary Keys  dictionary=${cbts_rmod_sn_conf_id_dict}
    Sort List  ${vdu_scfc_rmod_sn_list}
    Sort List  ${vdu_rmod_sn_list}
    Lists Should Be Equal  list1=${vdu_scfc_rmod_sn_list}  list2=${vdu_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
    ${cbts_rmod_sn_cells_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=cell_ids
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_cells_id_dict}
# Get BTS controller role sharing configuration
    ${cbts_actrfsconfigperunit_value}=  SCFC Get Managed Object Parameter Value
    ...  scfc_file_path=${vdu_scfc_file_path}
    ...  dist_name=FEATCADM
    ...  parameter_name=actRfsConfigPerUnit
    IF  '${cbts_actrfsconfigperunit_value}'=='true'
      ${cbts_sharing_primary_rmod_sn_list}  ${cbts_sharing_secondary_rmod_sn_list}=
      ...  Get BTS Controller Role Sharing Configuration  scfc_file_path=${vdu_scfc_file_path}
# find not shared radio modules on CBTS and add them to 'cbts_sharing_primary_rmod_sn_list'
      ${temporary_all_cbts_radios}=  Copy List  ${vdu_scfc_rmod_sn_list}
      Remove Values From List  ${temporary_all_cbts_radios}  @{cbts_sharing_secondary_rmod_sn_list}
      ${cbts_sharing_primary_rmod_sn_list}=  Combine Lists  ${cbts_sharing_primary_rmod_sn_list}  ${temporary_all_cbts_radios}
      Remove Duplicates  ${cbts_sharing_primary_rmod_sn_list}
    ELSE
      ${cbts_sharing_primary_rmod_sn_list}=  Create List  @{vdu_scfc_rmod_sn_list}
    END
    Set Test Variable  ${cbts_sharing_primary_rmod_sn_list}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS Sharing Preconditions Radio Modules Power Reset  console=${log_to_console}

Step 2: SBTS Sharing Preconditions Radio Modules Power Reset
    Log  ${dots_prefix_green}Step 2: SBTS preconditions radio modules power reset  console=${log_to_console}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}
# BTS procedural state should be onair
    Admin BTS Procedural State Should Be
    ...  state_value=OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}SBTS procedural state is onAir  console=${log_to_console}
# Wait until all cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    BTS SCFC And Admin Cells Count Should Match
    ...  scfc_file_path=${sbts_scfc_file_path}
    ...  admin_connection=${admin_connection}
# Get and set variables
    ${sbts_scfc_lncelid_list}=  SCFC Create LncelId List
    ...  scfc_file_path=${sbts_scfc_file_path}
    Set Test Variable  ${sbts_scfc_lncelid_list}
    ${sbts_scfc_lcrid_not_iot_list}=  SCFC Create Not IoT LcrId List
    ...  scfc_file_path=${sbts_scfc_file_path}
    ${sbts_scfc_lncelid_not_iot_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${sbts_scfc_lcrid_not_iot_list}
    Set Test Variable  ${sbts_scfc_lncelid_not_iot_list}
    ${sbts_scfc_lcrid_iot_inband_guardband_list}=  SCFC Create IoT Inband And Guardband LcrId List
    ...  scfc_file_path=${sbts_scfc_file_path}
    ${sbts_scfc_lncelid_iot_inband_guardband_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${sbts_scfc_lcrid_iot_inband_guardband_list}
    Set Test Variable  ${sbts_scfc_lncelid_iot_inband_guardband_list}
    ${sbts_scfc_rmod_sn_list}=  SCFC Get Radio Module Serial Number List  scfc_file_path=${sbts_scfc_file_path}
    ${sbts_rmod_sn_cells_id_dict}=  BTS Get Radio Modules Serial Number And Cells Ids
    Set Test Variable  ${sbts_rmod_sn_cells_id_dict}
    ${sbts_rmod_sn_conf_id_dict}  ${smod_rmod_sn_internal_id_dict}=  BTS Get Radio Modules Serial Number And Ids
    ...  admin_connection=${admin_connection}
    Set Test Variable  ${sbts_rmod_sn_conf_id_dict}
    Set Test Variable  ${smod_rmod_sn_internal_id_dict}
    ${admin_rmod_sn_list}=  Get Dictionary Keys  dictionary=${sbts_rmod_sn_conf_id_dict}
    Sort List  ${sbts_scfc_rmod_sn_list}
    Sort List  ${admin_rmod_sn_list}
    Lists Should Be Equal  list1=${sbts_scfc_rmod_sn_list}  list2=${admin_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
# Get BTS controller role sharing configuration
    ${sbts_actrfsconfigperunit_value}=  SCFC Get Managed Object Parameter Value
    ...  scfc_file_path=${sbts_scfc_file_path}
    ...  dist_name=FEATCADM
    ...  parameter_name=actRfsConfigPerUnit
    IF  '${sbts_actrfsconfigperunit_value}'=='true'
      ${sbts_sharing_primary_rmod_sn_list}  ${sbts_sharing_secondary_rmod_sn_list}=
      ...  Get BTS Controller Role Sharing Configuration  scfc_file_path=${sbts_scfc_file_path}
# find not shared radio modules on SBTS and add them to 'sbts_sharing_primary_rmod_sn_list'
      ${temporary_all_sbts_radios}=  Copy List  ${sbts_scfc_rmod_sn_list}
      Remove Values From List  ${temporary_all_sbts_radios}  @{sbts_sharing_secondary_rmod_sn_list}
      ${sbts_sharing_primary_rmod_sn_list}=  Combine Lists  ${sbts_sharing_primary_rmod_sn_list}  ${temporary_all_sbts_radios}
      Remove Duplicates  ${sbts_sharing_primary_rmod_sn_list}
    ELSE
      ${sbts_sharing_primary_rmod_sn_list}=  Create List  @{sbts_scfc_rmod_sn_list}
    END
    Set Test Variable  ${sbts_sharing_primary_rmod_sn_list}
# Set radio modules states
    ${sbts_rmod_power_off_states}=  Set Variable
    ...  operationalState=regex"(?i)disabled", administrativeState=regex"(?i)unlocked", availabilityStatus=regex"(?i)not installed"
    Set Test Variable  ${sbts_rmod_power_off_states}
    ${sbts_rmod_power_on_states}=  Set Variable  operationalState=regex"(?i)enabled", administrativeState=regex"(?i)unlocked"
    Set Test Variable  ${sbts_rmod_power_on_states}
# Set cells states
    ${sbts_impacted_lncel_states_1}=  Set Variable  availabilityStatus=regex"(?i)failed", operationalState=regex"(?i)disabled"
    ${sbts_impacted_lncel_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_impacted_lncel_states}=  Set Variable  ${sbts_impacted_lncel_states_1}, ${sbts_impacted_lncel_states_2}
    Set Test Variable  ${sbts_impacted_lncel_states}
    ${sbts_impacted_iot_lncel_states_1}=  Set Variable  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled"
    ${sbts_impacted_iot_lncel_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_impacted_iot_lncel_states}=  Set Variable  ${sbts_impacted_iot_lncel_states_1}, ${sbts_impacted_iot_lncel_states_2}
    Set Test Variable  ${sbts_impacted_iot_lncel_states}
    ${sbts_unimpacted_lncel_states}=
    ...  Set Variable  operationalState=regex"(?i)enabled",administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    Set Test Variable  ${sbts_unimpacted_lncel_states}
    Log  ${ok_prefix_green}Step 2: SBTS preconditions radio modules power reset  console=${log_to_console}

Step 3: Power Off Radio Module
    Log  ${dots_prefix_green}Step 3: Power Off Radio Module  console=${log_to_console}
    Log  ${info_prefix}Radio module (sn: ${tested_rmod_sn}) is going to be powered off  console=${log_to_console}
# Set startup timeframe for R&D dying gasp alarm verification
    iav.Set Start Timestamp
# Power off radio
    ${power_off_status}=  Run Keyword And Return Status  PDU Turn Off Radio Module  rmod_sn=${tested_rmod_sn}
    IF  not ${power_off_status}
      Log  ${failed_result}Power off procedure failed. Check PDU/RU description in init.py  console=${log_to_console}
      Fail  Power off procedure failed. Check PDU/RU description in init.py
    END
    Log  ${ok_prefix_green}Step 3: Power Off Radio Module  console=${log_to_console}

Step 4: Check Target Radio Module State And Faults After Power Off On CBTS
    Log  ${dots_prefix_green}Step 4: Check Target Radio Module State And Faults After Power Off On CBTS  console=${log_to_console}
    ${is_cbts_rmod}=  Set Variable If  '${tested_rmod_sn}' in ${vdu_scfc_rmod_sn_list}  ${TRUE}  ${FALSE}
    Set Test Variable  ${is_cbts_rmod}
    IF  not ${is_cbts_rmod}
      Log  ${info_prefix}Radio module (sn: ${tested_rmod_sn}) is not configured on CBTS. Verification skipped.  console=${log_to_console}
      Log  ${ok_prefix_green}Step 4: Check Target Radio Module State And Faults After Power Off On CBTS  console=${log_to_console}
      Return From Keyword
    END
    ${cbts_reset_rmod_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_id_dict}  key=${tested_rmod_sn}
    ${cbts_reset_rmod_id_list}=  Create List  ${cbts_reset_rmod_id}
# Check until CBTS radio module is not installed
    RMOD Wait For Offline
    ...  rmod_sn=${tested_rmod_sn}
    ...  timeout=100s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}CBTS radio module (sn: ${tested_rmod_sn}) is not installed  console=${log_to_console}
# Check reset CBTS radio module NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${tested_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}CBTS radio module (sn: ${tested_rmod_sn}) cells status after power off is OK  console=${log_to_console}
# Check Faults on CBTS
    ${any_cell_on_tested_radio}=  Run Keyword And Return Status  Should Not Be Empty  ${cbts_rmod_impacted_cells_id_list}
    Log  ${info_prefix}Waiting for fault activation (fault id=10)  console=${log_to_console}
    ${alarm_severity_list}=  IF  ${any_cell_on_tested_radio}  Create List  critical  ELSE  Create List  minor
    IF  '${tested_rmod_sn}' in ${cbts_sharing_primary_rmod_sn_list} and '${tested_rmod_sn}' not in ${rmod_sn_dyinggasp_excluded_list}
      Log  ${below_info_prefix}Waiting for Dying gasp additional info (RU power loss)
      vDU Assert Alarm Active
      ...  fault_id=10
      ...  alarm_severity_list=${alarm_severity_list}
      ...  custom_field_search=additionalInfo=supplAlarmInfo=RU power loss
      ...  timeout=5min
      Log  ${below_info_prefix}Alarm (faultId:10) on shared CBTS radio module (sn: ${tested_rmod_sn}) is active
      ...  console=${log_to_console}
      Log  ${below_info_prefix}Dying gasp alram (RU power loss) is visible in fault details
      ...  console=${log_to_console}
    ELSE
      Log  ${below_info_prefix}Dying gasp (RU power loss) should be cleared in fault additional info
      vDU Assert Alarm Active
      ...  fault_id=10
      ...  alarm_severity_list=${alarm_severity_list}
      ...  custom_field_search=additionalInfo=^(?!.*RU power loss).*
      ...  timeout=5min
      Log  ${below_info_prefix}Alarm (faultId:10) on shared CBTS radio module (sn: ${tested_rmod_sn}) is active
      ...  console=${log_to_console}
      Log  ${below_info_prefix}Dying gasp alram (RU power loss) inactive.
      ...  console=${log_to_console}
    END
    Log  ${info_prefix}Alarm (fault id=10) is active now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check Target Radio Module State And Faults After Power Off On CBTS  console=${log_to_console}

Step 5: Check Non-Target Radio Modules States After Power Off On CBTS
    Log  ${dots_prefix_green}Step 5: Check Non-Target Radio Modules States After Power Off On CBTS  console=${log_to_console}
# Check until all non-reset CBTS radio modules are on line and exit from step when tested radio module is not configured on CBTS
    IF  not ${is_cbts_rmod}
      Check If CBTS Is OnAir
      Log  ${ok_prefix_green}Step 5: Check Non-Target Radio Modules States After Power Off On CBTS  console=${log_to_console}
      Return From Keyword
    END
# Check not reset CBTS radio modules states
    ${cbts_online_rmod_sn_list}=  Copy List  ${vdu_scfc_rmod_sn_list}
    Remove Values From List  ${cbts_online_rmod_sn_list}  ${tested_rmod_sn}
    FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
      RMOD Wait For Online
      ...  rmod_sn=${cbts_online_rmod_sn}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not reset CBTS radio modules are on line  console=${log_to_console}
# Check not reset CBTS radio modules NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${tested_rmod_sn}
    ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
    Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
    FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unimpacted_cbts_cell_id}
      ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not reset CBTS radio modules cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Check Non-Target Radio Modules States After Power Off On CBTS  console=${log_to_console}

Step 6: Check Target Radio Module State And Faults After Power Off On SBTS
    Log  ${dots_prefix_green}Step 6: Check Target Radio Module State And Faults After Power Off On SBTS  console=${log_to_console}
    ${is_sbts_rmod}=  Set Variable If  '${tested_rmod_sn}' in ${sbts_scfc_rmod_sn_list}  ${TRUE}  ${FALSE}
    Set Test Variable  ${is_sbts_rmod}
    IF  not ${is_sbts_rmod}
      Log  ${info_prefix}Radio module (sn: ${tested_rmod_sn}) is not configured on SBTS. Verification skipped.  console=${log_to_console}
      Log  ${ok_prefix_green}Step 6: Check Target Radio Module State And Faults After Power Off On SBTS  console=${log_to_console}
      Return From Keyword
    END
    ${sbts_reset_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${tested_rmod_sn}
    Set Test Variable  ${sbts_reset_rmod_internal_id}
# Check until reset SBTS radio module is off line
    admin.Assert
    ...  class_name=RMOD
    ...  id=${sbts_reset_rmod_internal_id}
    ...  parameters=${sbts_rmod_power_off_states}
    ...  timeout=60s
    ...  connection=${admin_connection}
    Log  ${info_prefix}SBTS reset radio module (sn: ${tested_rmod_sn}) is off line  console=${log_to_console}
# Check reset SBTS radio module LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${tested_rmod_sn}
    @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
    Remove Values From List   ${sbts_rmod_impacted_lncelid_list}  @{sbts_scfc_lncelid_iot_inband_guardband_list}
    FOR  ${sbts_rmod_impacted_lncelid}  IN  @{sbts_rmod_impacted_lncelid_list}
      ${sbts_rmod_impacted_lncel_distname}=  admin.Get Cell Id By Configuration Id
      ...  rat=LTE
      ...  configuration_id=${sbts_rmod_impacted_lncelid}
      ...  connection=${admin_connection}
      admin.Assert  class_name=LNCEL
      ...  id=${sbts_rmod_impacted_lncel_distname}
      ...  parameters=${sbts_impacted_lncel_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Reset SBTS radio module (sn: ${tested_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check reset SBTS radio module IoT LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${tested_rmod_sn}
    @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
    Remove Values From List   ${sbts_rmod_impacted_lncelid_list}  @{sbts_scfc_lncelid_not_iot_list}
    FOR  ${sbts_rmod_impacted_lncelid}  IN  @{sbts_rmod_impacted_lncelid_list}
      ${sbts_rmod_impacted_lncel_distname}=  admin.Get Cell Id By Configuration Id
      ...  rat=LTE
      ...  configuration_id=${sbts_rmod_impacted_lncelid}
      ...  connection=${admin_connection}
      admin.Assert  class_name=LNCEL
      ...  id=${sbts_rmod_impacted_lncel_distname}
      ...  parameters=${sbts_impacted_iot_lncel_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Reset SBTS radio module (sn: ${tested_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
# Check Faults on SBTS
    ${any_cell_on_tested_radio}=  Run Keyword And Return Status  Should Not Be Empty  ${sbts_rmod_impacted_cells_id_dict['LNCEL']}
    Log  ${info_prefix}Waiting for fault activation (fault id=10)  console=${log_to_console}
    ${alarm_severity}=  IF  ${any_cell_on_tested_radio}  Set Variable  Critical  ELSE  Set Variable  Minor
    IF  '${tested_rmod_sn}' in ${sbts_sharing_primary_rmod_sn_list} and '${tested_rmod_sn}' not in ${rmod_sn_dyinggasp_excluded_list}
# Find Admin fault 10
      Log  ${below_info_prefix}Waiting for Dying gasp additional info (RU power loss)
      ${parameters}=  Set Variable
      ...  faultId=10, severity=${alarm_severity}, supplAlarmInfo=regex"RU connection was lost.*RU power loss"
      admin.Assert Alarm Active
      ...  parameters=${parameters}, alarmingResource=${sbts_reset_rmod_internal_id}
      ...  timeout=30s
      ...  connection=${admin_connection}
      Log  ${below_info_prefix}Alarm (faultId:10) on shared SBTS radio module (sn: ${tested_rmod_sn}) is active
      ...  console=${log_to_console}
      Log  ${below_info_prefix}Dying gasp alram (RU power loss) is visible in fault details
      ...  console=${log_to_console}
# Find R&D fault 4774 for dying gasp alarm
      Log  ${below_info_prefix}Waiting for Dying gasp alram (R&D 4774)
      Check Active Fault In IMS For RD Fault  fault_id=4774
      Log  ${below_info_prefix}Dying gasp alram (R&D 4774) is visible in ims under ALARMS/FAULT_NOTIF objects
    ELSE
      Log  ${below_info_prefix}Dying gasp (RU power loss) should be cleared in fault additional info
      ${parameters}=  Set Variable
      ...  faultId=10, severity=${alarm_severity}, supplAlarmInfo=regex"^(?!.*RU power loss).*"
      admin.Assert Alarm Active
      ...  parameters=${parameters}, alarmingResource=${sbts_reset_rmod_internal_id}
      ...  timeout=30s
      ...  connection=${admin_connection}
      Log  ${below_info_prefix}Alarm (faultId:10) on shared SBTS radio module (sn: ${tested_rmod_sn}) is active
      ...  console=${log_to_console}
      Log  ${below_info_prefix}Dying gasp alram (RU power loss) inactive.
      ...  console=${log_to_console}
    END
    Log  ${info_prefix}Alarm (fault id=10) is active now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Check Target Radio Module State And Faults After Power Off On SBTS  console=${log_to_console}

Step 7: Check Non-Target Radio Modules States After Power Off On SBTS
    Log  ${dots_prefix_green}Step 7: Check Non-Target Radio Modules States After Power Off On SBTS  console=${log_to_console}
# Check until all non-reset SBTS radio modules are on line and exit from step when tested radio module is not configured on SBTS
    IF  not ${is_sbts_rmod}
      Check If SBTS Is OnAir
      Log  ${ok_prefix_green}Step 7: Check Non-Target Radio Modules States After Power Off On SBTS  console=${log_to_console}
      Return From Keyword
    END
    # Check if not reset SBTS radio modules are on line
    ${smod_not_reset_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${smod_rmod_sn_internal_id_dict}
    Set Test Variable  ${smod_not_reset_rmod_internal_id_list}
    Remove Values From List  ${smod_not_reset_rmod_internal_id_list}  ${sbts_reset_rmod_internal_id}
    FOR  ${smod_not_reset_rmod_internal_id}  IN  @{smod_not_reset_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_not_reset_rmod_internal_id}
      ...  parameters=${sbts_rmod_power_on_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not reset SBTS radio modules are on line  console=${log_to_console}
# Check not reset SBTS radio modules LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${tested_rmod_sn}
    @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
    ${sbts_scfc_not_impacted_lncelid_list}=  Copy List  ${sbts_scfc_lncelid_list}
    Remove Values From List   ${sbts_scfc_not_impacted_lncelid_list}  @{sbts_rmod_impacted_lncelid_list}
    FOR  ${sbts_scfc_not_impacted_lncelid}  IN  @{sbts_scfc_not_impacted_lncelid_list}
      ${sbts_scfc_not_impacted_lncel_distname}=  admin.Get Cell Id By Configuration Id
      ...  rat=LTE
      ...  configuration_id=${sbts_scfc_not_impacted_lncelid}
      ...  connection=${admin_connection}
      admin.Assert  class_name=LNCEL
      ...  id=${sbts_scfc_not_impacted_lncel_distname}
      ...  parameters=${sbts_unimpacted_lncel_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not reset SBTS radio module (sn: ${tested_rmod_sn}) LNCELs are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Check Non-Target Radio Modules States After Power Off On SBTS  console=${log_to_console}

Step 8: Power On Radio Module
    Log  ${dots_prefix_green}Step 8: Power On Radio Module  console=${log_to_console}
    PDU Turn On Radio Module  rmod_sn=${tested_rmod_sn}
    Log  ${info_prefix}Radio module (sn: ${tested_rmod_sn}) has been powered on  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Power On Radio Module  console=${log_to_console}

Step 9: Check CBTS State And Faults After Radio Module Power On
    Log  ${dots_prefix_green}Step 9: Check CBTS State And Faults After Radio Module Power On  console=${log_to_console}
    Check If CBTS Is OnAir
    Log  ${ok_prefix_green}Step 9: Check CBTS State And Faults After Radio Module Power On  console=${log_to_console}

Step 10: Check SBTS State And Faults After Radio Module Power On
    Log  ${dots_prefix_green}Step 10: Check SBTS State And Faults After Radio Module Power On  console=${log_to_console}
    Check If SBTS Is OnAir
    Log  ${ok_prefix_green}Step 10: Check SBTS State And Faults After Radio Module Power On  console=${log_to_console}

Prepare Tested Radio Modules SN List
    ${vdu_scfc_rmod_sn_list}=  SCFC Get Radio Module Serial Number List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmod_sn_list}
    ${sbts_scfc_rmod_sn_list}=  SCFC Get Radio Module Serial Number List  scfc_file_path=${sbts_scfc_file_path}
    Set Test Variable  ${sbts_scfc_rmod_sn_list}
    ${all_scfc_rmod_sn_list}=  Combine Lists  ${vdu_scfc_rmod_sn_list}  ${sbts_scfc_rmod_sn_list}
    ${combined_scfc_rmod_sn_list}=  Remove Duplicates  ${all_scfc_rmod_sn_list}
    ${tested_rmod_serial_number_list}=  Run Keyword If  ${rmod_sn_count}>0
    ...  Get Random List Based On Input List  list=${combined_scfc_rmod_sn_list}  length=${rmod_sn_count}
    ...  ELSE IF  ${rmod_sn_list}==@{EMPTY}
    ...  Create List  @{combined_scfc_rmod_sn_list}
    ...  ELSE
    ...  Create List  @{rmod_sn_list}
    ${sn_status}=  Run Keyword And Return Status  List Should Contain Sub List
    ...  list1=${combined_scfc_rmod_sn_list}
    ...  list2=${tested_rmod_serial_number_list}
    ...  msg=Defined rfs scfs don't contain sn from 'rmod_sn_list'
    IF  not ${sn_status}  Fail  Defined rfs scfs don't contain sn from 'rmod_sn_list'
    Set Test Variable  ${tested_rmod_serial_number_list}

Check Active Fault In IMS For RD Fault
    [Arguments]  ${fault_id}  ${severity}=${NONE}
    [Documentation]
    ...  KW checks if fault is active in IMS. KW Prepared for checking ALARMS/FAULT_NOTIF object in FRI when R&D fault
    ...  need to be verified.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | fault_id               | Yes  | fault id                                                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | severity               | No   | if not aplicable use ${NONE}                                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    iav.Set End Timestamp
    ${wanted_alarm}=  awd.create_alarm  fault_id=${fault_id}  severity=${severity}
    admin.Collect Im Snapshot
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2
    ...  connection=${admin_connection}
    ${rd_alarm_dist_name}=  iav.Verify Alarm Was Set
    ...  alarm=${wanted_alarm}
    ...  ims_file_path=${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2
    ...  include_fault_notif=${TRUE}
    Remove File  ${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2
    Set Test Variable  ${RD_ALARM_DISTNAME}  ${rd_alarm_dist_name}

Check Removed Active Fault In IMS For RD Fault
    [Documentation]
    ...  KW checks if active fault was removed in IMS. KW Prepared for checking ALARMS/FAULT_NOTIF object in FRI when R&D fault
    ...  need to be verified. KW introduced after CNI-127210 implementation.
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    iav.Set End Timestamp
    admin.Collect Im Snapshot
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2
    ...  connection=${admin_connection}
    iav.Verify Alarm Was Removed
    ...  alarm_dist_name=${RD_ALARM_DISTNAME['dist_name']}
    ...  ims_file_path=${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2
    ...  include_fault_notif=${TRUE}
    Remove File  ${SUITE_LOGS_DIR_PATH}/sbts/suite_teardown_logs/RD_dying_gasp_log.ims2

TC_Cloud_SBTS_STARTUP_Radio_Modules_Power_Reset_Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial BTS setup after the test is performed.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Log  ${dots_prefix_green}Teardown actions started  console=${log_to_console}
    IF  "${tc_status}"=="FAIL"
      Run Keyword And Ignore Error  PDU Turn On Radio Module  rmod_sn=${tested_rmod_sn}
    END
    Run Keyword And Ignore Error  vDU Rest Logout
    Log  ${ok_prefix_green}Teardown actions finished  console=${log_to_console}

Check If CBTS Is OnAir
    [Documentation]
    ...  Description:
    ...  Keyword checks if CBTS is OnAir
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
# Check inactive faults
    vDU Assert Alarm Inactive  fault_id=10  timeout=1min
    Log  ${info_prefix}Fault 10 is inactive on CBTS  console=${log_to_console}

Check If SBTS Is OnAir
    [Documentation]
    ...  Description:
    ...  Keyword checks if SBTS is OnAir
    # Wait until all RMODs OnAir
    Admin Check Radio Modules State When BTS OnAir
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS radio modules are OnAir  console=${log_to_console}
# Wait until all cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
# BTS Procedural State Should Be OnAir
    Admin BTS Procedural State Should Be
    ...  state_value=OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}SBTS procedural state is onAir  console=${log_to_console}
# Check inactive faults
    admin.Assert Alarm Inactive
    ...  parameters=faultId=10
    ...  timeout=60s
    ...  connection=${admin_connection}
    Log  ${info_prefix}Fault 10 is inactive on SBTS  console=${log_to_console}
