*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/admin.robot

*** Variables ***
# Maximum time to wait for complete reset RMOD operation
${RMOD_RESET_MAX_WAIT_TIME}=    300s
# Allowed test case historical alarms
@{VCU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
@{VDU_SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=4773, severity=critical
@{SBTS_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=4773, severity=Critical

*** Keywords ***
TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${sbts_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}
    ...  ${cbts_rmod_sn_count}=0  ${sbts_rmod_sn_list}=@{EMPTY}  ${sbts_rmod_sn_count}=0
    ...  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}  ${admin_connection}=${ADMIN_CONNECTION_DEFAULT}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case reset radio module based on rmod serial number.
    ...  If the list of the radio modules serial numbers is empty then all radio modules are reset.
    ...  Test supports RF sharing SBTS-CBTS configuration.
    ...  Test case supports:
    ...  - CBTS side: NR cells
    ...  - SBTS side: LTE cells
    ...  SCF file should contain the serial numbers of the radio modules.
    ...
    ...  Step 1: CBTS Sharing Preconditions Radio Modules Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: SBTS Preconditions Radio Modules Reset
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 3: CBTS Sharing Radio Module Reset
    ...  a) CBTS radio module reset
    ...  b) Check until reset CBTS radio module is off line
    ...  c) Check reset CBTS radio module NR cells states
    ...  d) Check shared reset SBTS radio module states
    ...  e) Check shared reset SBTS radio module LTE cells states
    ...  f) Check shared reset SBTS radio module IoT LTE cells states
    ...  g) Check shared reset SBTS radio module active alarm
    ...  h) Check CBTS radio module reset operation status
    ...  i) Check if not reset CBTS radio modules are on line
    ...  j) Check not reset CBTS radio modules NR cells states
    ...  k) Check if shared not reset SBTS radio modules are on line
    ...  l) Check shared not reset SBTS radio modules LTE cells states
    ...  m) Check if reset CBTS radio module is on line
    ...  n) Check shared reset SBTS radio module inactive alarm
    ...  o) Check if all CBTS radio modules are on line
    ...  p) Check if all CBTS cells are OnAir
    ...  r) Check if all SBTS cells are OnAir
    ...  Step 4: SBTS Sharing Radio Module Reset
    ...  a) SBTS radio module reset
    ...  b) Check until reset SBTS radio module is off line
    ...  c) Check reset SBTS radio module LTE cells states
    ...  d) Check reset SBTS radio module IoT LTE cells states
    ...  e) Check until shared reset CBTS radio module is off line
    ...  f) Check shared reset CBTS radio module NR cells states
    ...  g) Check shared reset CBTS radio module active alarm
    ...  h) Check if not reset SBTS radio modules are on line
    ...  i) Check not reset SBTS radio modules LTE cells states
    ...  j) Check if shared not reset CBTS radio modules are on line
    ...  k) Check shared not reset CBTS radio modules NR cells states
    ...  l) Check if reset SBTS radio module is on line
    ...  m) Check shared reset CBTS radio module inactive alarm
    ...  n) Check if all SBTS radio modules are on line
    ...  o) Check if all SBTS cells are OnAir
    ...  p) Check if all CBTS cells are OnAir
    ...  Step 5: CBTS Sharing Postconditions Radio Modules Reset
    ...  a) The same values as in Step 1
    ...  Step 6: SBTS Postconditions Radio Modules Reset
    ...  a) The same values as in Step 2
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_scfc_file_path    | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${sbts_scfc_file_path}
    Set Test Variable  ${cbts_rmod_sn_list}
    Set Test Variable  ${cbts_rmod_sn_count}
    Set Test Variable  ${sbts_rmod_sn_list}
    Set Test Variable  ${sbts_rmod_sn_count}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Reset  console=${log_to_console}
    Step 1: CBTS Sharing Preconditions Radio Modules Reset
    Step 2: SBTS Sharing Preconditions Radio Modules Reset
    FOR  ${cbts_reset_rmod_sn}  IN  @{cbts_reset_rmod_sn_list}
      Set Test Variable  ${cbts_reset_rmod_sn}
      Step 3: CBTS Sharing Radio Module Reset
    END
    FOR  ${sbts_reset_rmod_sn}  IN  @{sbts_reset_rmod_sn_list}
      Set Test Variable  ${sbts_reset_rmod_sn}
      Step 4: SBTS Sharing Radio Module Reset
    END
    Step 5: CBTS Sharing Postconditions Radio Modules Reset
    Step 6: SBTS Sharing Postconditions Radio Modules Reset
    Log  ${done_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Sharing Preconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 1: CBTS preconditions radio modules reset  console=${log_to_console}
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
    ${vdu_scfc_rmod_sn_list}=  SCFC Get Radio Module Serial Number List  scfc_file_path=${vdu_scfc_file_path}
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
# Set tested radio modules list
    ${cbts_reset_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${cbts_rmod_sn_list}  rmod_sn_count=${cbts_rmod_sn_count}
    Set Test Variable  ${cbts_reset_rmod_sn_list}
# Get BTS controller role sharing configuration
    ${cbts_actrfsconfigperunit_value}=  SCFC Get Managed Object Parameter Value
    ...  scfc_file_path=${vdu_scfc_file_path}
    ...  dist_name=FEATCADM
    ...  parameter_name=actRfsConfigPerUnit
    IF  '${cbts_actrfsconfigperunit_value}'=='true'
      ${cbts_sharing_primary_rmod_sn_list}  ${cbts_sharing_secondary_rmod_sn_list}=
      ...  Get BTS Controller Role Sharing Configuration  scfc_file_path=${vdu_scfc_file_path}
    ELSE
      ${cbts_sharing_secondary_rmod_sn_list}=  Create List
    END
    Set Test Variable  ${cbts_sharing_secondary_rmod_sn_list}
    Remove Values From List  ${cbts_reset_rmod_sn_list}  @{cbts_sharing_secondary_rmod_sn_list}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions radio modules reset  console=${log_to_console}

Step 2: SBTS Sharing Preconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 2: SBTS preconditions radio modules reset  console=${log_to_console}
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
    ${sbts_rmod_sn_conf_id_dict}  ${sbts_rmod_sn_internal_id_dict}=  BTS Get Radio Modules Serial Number And Ids
    ...  admin_connection=${admin_connection}
    Set Test Variable  ${sbts_rmod_sn_conf_id_dict}
    Set Test Variable  ${sbts_rmod_sn_internal_id_dict}
    ${admin_rmod_sn_list}=  Get Dictionary Keys  dictionary=${sbts_rmod_sn_conf_id_dict}
    Sort List  ${sbts_scfc_rmod_sn_list}
    Sort List  ${admin_rmod_sn_list}
    Lists Should Be Equal  list1=${sbts_scfc_rmod_sn_list}  list2=${admin_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
# Set tested radio modules list
    ${sbts_reset_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${sbts_scfc_file_path}
    ...  rmod_sn_list=${sbts_rmod_sn_list}  rmod_sn_count=${sbts_rmod_sn_count}
    Set Test Variable  ${sbts_reset_rmod_sn_list}
# Get BTS controller role sharing configuration
    ${sbts_actrfsconfigperunit_value}=  SCFC Get Managed Object Parameter Value
    ...  scfc_file_path=${sbts_scfc_file_path}
    ...  dist_name=FEATCADM
    ...  parameter_name=actRfsConfigPerUnit
    IF  '${sbts_actrfsconfigperunit_value}'=='true'
      ${sbts_sharing_primary_rmod_sn_list}  ${sbts_sharing_secondary_rmod_sn_list}=
      ...  Get BTS Controller Role Sharing Configuration  scfc_file_path=${sbts_scfc_file_path}
    ELSE
      ${sbts_sharing_secondary_rmod_sn_list}=  Create List
    END
    Remove Values From List  ${sbts_reset_rmod_sn_list}  @{sbts_sharing_secondary_rmod_sn_list}
    Set Test Variable  ${sbts_sharing_secondary_rmod_sn_list}
# Set radio modules states
    ${sbts_rmod_offline_states}=  Set Variable  operationalState=regex"(?i)disabled", administrativeState=regex"(?i)unlocked
    Set Test Variable  ${sbts_rmod_offline_states}
    ${sbts_rmod_online_states}=  Set Variable  operationalState=regex"(?i)enabled", administrativeState=regex"(?i)unlocked
    Set Test Variable  ${sbts_rmod_online_states}
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
    Log  ${ok_prefix_green}Step 2: SBTS preconditions radio modules reset  console=${log_to_console}

Step 3: CBTS Sharing Radio Module Reset
    ${rmod_type}=  Set Variable If  '${cbts_reset_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}  shared  dedicated
    Log  ${dots_prefix_green}Step 3: CBTS ${rmod_type} radio module (sn: ${cbts_reset_rmod_sn}) reset  console=${log_to_console}
    Log  ${info_prefix}Radio module (sn: ${cbts_reset_rmod_sn}) has been reset  console=${log_to_console}
    ${cbts_reset_rmod_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_id_dict}  key=${cbts_reset_rmod_sn}
    ${cbts_reset_rmod_id_list}=  Create List  ${cbts_reset_rmod_id}
# CBTS radio module reset
    ${reset_result}=  vdu.Reset Rmods
    ...  rmods_list=${cbts_reset_rmod_id_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
# Check until reset CBTS radio module is off line
    RMOD Wait For Offline
    ...  rmod_sn=${cbts_reset_rmod_sn}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Reset CBTS radio module (sn: ${cbts_reset_rmod_sn}) is off line  console=${log_to_console}
# Check reset CBTS radio module NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Reset CBTS radio module (sn: ${cbts_reset_rmod_sn}) cells status is OK  console=${log_to_console}
# Check shared reset SBTS radio module and cells states
    IF  '${cbts_reset_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared reset SBTS radio module (sn: ${cbts_reset_rmod_sn}) and cells status checking  console=${log_to_console}
# Check shared reset SBTS radio module states
      ${sbts_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_internal_id_dict}  key=${cbts_reset_rmod_sn}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${sbts_locked_rmod_internal_id}
      ...  parameters=${sbts_rmod_offline_states}
      ...  timeout=30s
      ...  connection=${admin_connection}
      Log  ${below_info_prefix}Shared reset SBTS radio module (sn: ${cbts_reset_rmod_sn}) is off line  console=${log_to_console}
# Check shared reset SBTS radio module LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
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
      Log  ${below_info_prefix}Shared reset SBTS radio module (sn: ${cbts_reset_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check shared reset SBTS radio module IoT LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
      @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
      ${sbts_rmod_impacted_iot_lncelid_list}=  Copy List  ${sbts_rmod_impacted_lncelid_list}
      Remove Values From List   ${sbts_rmod_impacted_iot_lncelid_list}  @{sbts_scfc_lncelid_not_iot_list}
      FOR  ${sbts_rmod_impacted_iot_lncelid}  IN  @{sbts_rmod_impacted_iot_lncelid_list}
        ${sbts_rmod_impacted_iot_lncel_distname}=  admin.Get Cell Id By Configuration Id
        ...  rat=LTE
        ...  configuration_id=${sbts_rmod_impacted_iot_lncelid}
        ...  connection=${admin_connection}
        admin.Assert  class_name=LNCEL
        ...  id=${sbts_rmod_impacted_iot_lncel_distname}
        ...  parameters=${sbts_impacted_iot_lncel_states}
        ...  timeout=10s
        ...  connection=${admin_connection}
      END
      IF  ${sbts_rmod_impacted_iot_lncelid_list}!=@{EMPTY}
        Log  ${below_info_prefix}Shared reset SBTS radio module (sn: ${cbts_reset_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
      END
# Check shared reset SBTS radio module active alarm
      ${fault_name}=  Set Variable  "Radio unit reset triggered by peer BTS"
      IF  ${sbts_rmod_impacted_lncelid_list}!=@{EMPTY}
        admin.Assert Alarm Active
        ...  parameters=faultId=4773, severity=Critical, faultName=${fault_name}, alarmingObjectIds[0].internal=${sbts_locked_rmod_internal_id}
        ...  timeout=30s
        ...  connection=${admin_connection}
        Log  ${below_info_prefix}Alarm (faultId:4773) on shared SBTS radio module (sn: ${cbts_reset_rmod_sn}) is active
        ...  console=${log_to_console}
      END
    END
# Check CBTS radio module reset operation status
    Log  ${info_prefix}Wait a while for the radio module (sn: ${cbts_reset_rmod_sn}) to reset ...  console=${log_to_console}
    RMOD Reset Wait For Expected Status
    ...  operation_id=${reset_result["operation_id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}CBTS radio module reset operation (sn: ${cbts_reset_rmod_sn}) succeeded  console=${log_to_console}
# Check if not reset CBTS radio modules are on line
    ${cbts_online_rmod_sn_list}=  Copy List  ${cbts_reset_rmod_sn_list}
    Remove Values From List  ${cbts_online_rmod_sn_list}  ${cbts_reset_rmod_sn}
    FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
      RMOD Wait For Online
      ...  rmod_sn=${cbts_online_rmod_sn}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not reset CBTS radio modules are on line  console=${log_to_console}
# Check not reset CBTS radio modules NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
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
# Check shared not reset SBTS radio modules and cells states
    IF  '${cbts_reset_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      Log  ${dots_prefix_green}Shared not reset SBTS radio modules and cells status checking  console=${log_to_console}
# Check if shared not reset SBTS radio modules are on line
      ${sbts_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_internal_id_dict}  key=${cbts_reset_rmod_sn}
      ${sbts_online_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${sbts_rmod_sn_internal_id_dict}
      Remove Values From List  ${sbts_online_rmod_internal_id_list}  ${sbts_locked_rmod_internal_id}
      FOR  ${sbts_online_rmod_internal_id}  IN  @{sbts_online_rmod_internal_id_list}
        admin.Assert
        ...  class_name=RMOD
        ...  id=${sbts_online_rmod_internal_id}
        ...  parameters=${sbts_rmod_online_states}
        ...  timeout=10s
        ...  connection=${admin_connection}
      END
      Log  ${below_info_prefix}Shared not reset SBTS radio modules are on line  console=${log_to_console}
# Check shared not reset SBTS radio modules LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
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
      Log  ${below_info_prefix}Shared not reset SBTS radio modules LNCELs are OnAir  console=${log_to_console}
    END
# Check if reset CBTS radio module is on line
    RMOD Wait For Online
    ...  rmod_sn=${cbts_reset_rmod_sn}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Reset CBTS radio module (serial number: ${cbts_reset_rmod_sn}) is online  console=${log_to_console}
# Check shared reset SBTS radio module inactive alarm
    IF  '${cbts_reset_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      ${fault_name}=  Set Variable  "Radio unit reset triggered by peer BTS"
      IF  ${sbts_rmod_impacted_lncelid_list}!=@{EMPTY}
        admin.Assert Alarm Inactive
        ...  parameters=faultId=4773, severity=Critical, faultName=${fault_name}, alarmingObjectIds[0].internal=${sbts_locked_rmod_internal_id}
        ...  timeout=30s
        ...  connection=${admin_connection}
        Log  ${below_info_prefix}Alarm (faultId:4773) on shared SBTS radio module (sn: ${cbts_reset_rmod_sn}) is inactive
        ...  console=${log_to_console}
      END
    END
# Check if all CBTS radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS radio modules are on line  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: CBTS ${rmod_type} radio module (sn: ${cbts_reset_rmod_sn}) reset  console=${log_to_console}

Step 4: SBTS Sharing Radio Module Reset
    ${rmod_type}=  Set Variable If  '${sbts_reset_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}  shared  dedicated
    Log  ${dots_prefix_green}Step 4: SBTS ${rmod_type} radio module (sn: ${sbts_reset_rmod_sn}) reset  console=${log_to_console}
# SBTS radio module reset
    ${sbts_reset_rmod_internal_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_internal_id_dict}  key=${sbts_reset_rmod_sn}
    Set Test Variable  ${sbts_reset_rmod_internal_id}
    ${reset_alias}=  Set Variable  rmod_reset
    Run Keyword And Ignore Error  admin.Teardown Admin  connection=${reset_alias}
    admin.Setup Admin  update_interval=100  admin_api_log_dir=${SUITE_LOGS_DIR_PATH}  alias=${reset_alias}
    ${reset_result}=  admin.Run Keyword In Background  Reset Unit
    ...  dist_name=${sbts_reset_rmod_internal_id}
    ...  reset_type=Soft
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  connection=${reset_alias}
# Check until reset SBTS radio module is off line
    admin.Assert
    ...  class_name=RMOD
    ...  id=${sbts_reset_rmod_internal_id}
    ...  parameters=${sbts_rmod_offline_states}
    ...  timeout=60s
    ...  connection=${admin_connection}
    Log  ${info_prefix}SBTS reset radio module (sn: ${sbts_reset_rmod_sn}) is off line  console=${log_to_console}
# Check reset SBTS radio module LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_reset_rmod_sn}
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
    Log  ${info_prefix}Reset SBTS radio module (sn: ${sbts_reset_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check reset SBTS radio module IoT LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_reset_rmod_sn}
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
    IF  ${sbts_rmod_impacted_lncelid_list}!=@{EMPTY}
      Log  ${info_prefix}Reset SBTS radio module (sn: ${sbts_reset_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
    END
# Check shared reset CBTS radio module and cells states
    IF  '${sbts_reset_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared reset CBTS radio module (sn: ${sbts_reset_rmod_sn}) and cells status checking  console=${log_to_console}
# Check until shared reset CBTS radio module is off line
      RMOD Wait For Offline
      ...  rmod_sn=${sbts_reset_rmod_sn}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
      Log  ${below_info_prefix}Shared reset CBTS radio module (sn: ${sbts_reset_rmod_sn}) is off line  console=${log_to_console}
# Check shared reset CBTS radio module NR cells states
      ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${sbts_reset_rmod_sn}
      FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
        Cell Wait For Expected States Or Statuses
        ...  cell_id=${cbts_rmod_impacted_cell_id}
        ...  state_status_dict=${cbts_impacted_cell_state_dict}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared reset CBTS radio module (sn: ${sbts_reset_rmod_sn}) cells status is OK  console=${log_to_console}
# Check shared reset CBTS radio module active alarm
      IF  ${cbts_rmod_impacted_cells_id_list}!=@{EMPTY}
        ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${sbts_locked_rmod_sn}
        ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
        ${alarm_severity_list}=  Create List  critical
        vDU Assert Alarm Active
        ...  fault_id=4773
        ...  alarming_object_list=${alarming_object_list}
        ...  alarm_severity_list=${alarm_severity_list}
        ...  timeout=30s
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Alarm (faultId:4773) on shared CBTS radio module (sn: ${sbts_locked_rmod_sn}) is active
        ...  console=${log_to_console}
      END
    END
    Log  ${info_prefix}Wait a while for the radio module (sn: ${sbts_reset_rmod_sn}) to reset ...  console=${log_to_console}
    admin.Collect Keyword Result  ${reset_result}  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    Log  ${info_prefix}SBTS radio module reset operation (sn: ${sbts_reset_rmod_sn}) succeeded  console=${log_to_console}
    Run Keyword And Ignore Error  admin.Teardown Admin  connection=${reset_alias}
# Check if not reset SBTS radio modules are on line
    ${sbts_not_reset_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${sbts_rmod_sn_internal_id_dict}
    Set Test Variable  ${sbts_not_reset_rmod_internal_id_list}
    Remove Values From List  ${sbts_not_reset_rmod_internal_id_list}  ${sbts_reset_rmod_internal_id}
    FOR  ${sbts_not_reset_rmod_internal_id}  IN  @{sbts_not_reset_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${sbts_not_reset_rmod_internal_id}
      ...  parameters=${sbts_rmod_online_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not reset SBTS radio modules are on line  console=${log_to_console}
# Check not reset SBTS radio modules LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_reset_rmod_sn}
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
    Log  ${info_prefix}Not reset SBTS radio module (sn: ${sbts_reset_rmod_sn}) LNCELs are OnAir  console=${log_to_console}
# Check shared not reset CBTS radio modules and cells states
    IF  '${sbts_reset_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared not reset CBTS radio modules and cells status checking  console=${log_to_console}
# Check if shared not reset CBTS radio modules are on line
      ${cbts_online_rmod_sn_list}=  Copy List  ${cbts_reset_rmod_sn_list}
      Remove Values From List  ${cbts_online_rmod_sn_list}  ${sbts_reset_rmod_sn}
      FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
        RMOD Wait For Online
        ...  rmod_sn=${cbts_online_rmod_sn}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared not reset CBTS radio modules are on line  console=${log_to_console}
# Check shared not reset CBTS radio modules NR cells states
      ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
      ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
      Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
      FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
        Cell Wait For Expected States Or Statuses
        ...  cell_id=${unimpacted_cbts_cell_id}
        ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared not reset CBTS radio modules cells are OnAir  console=${log_to_console}
    END
# Check if reset SBTS radio module is on line
    admin.Assert
    ...  class_name=RMOD
    ...  id=${sbts_reset_rmod_internal_id}
    ...  parameters=${sbts_rmod_online_states}
    ...  timeout=300s
    ...  connection=${admin_connection}
    Log  ${info_prefix}Reset SBTS radio module (sn: ${sbts_reset_rmod_sn}) is on line  console=${log_to_console}
# Check shared reset CBTS radio module inactive alarm
    IF  '${sbts_reset_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      IF  ${cbts_rmod_impacted_cells_id_list}!=@{EMPTY}
        ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${sbts_locked_rmod_sn}
        ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
        ${alarm_severity_list}=  Create List  critical
        vDU Assert Alarm Inactive
        ...  fault_id=4773
        ...  alarming_object_list=${alarming_object_list}
        ...  alarm_severity_list=${alarm_severity_list}
        ...  timeout=30s
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Alarm (faultId:4773) on shared CBTS radio module (sn: ${sbts_locked_rmod_sn}) is inactive
        ...  console=${log_to_console}
      END
    END
# Check if all SBTS radio modules are on line
    ${sbts_online_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${sbts_rmod_sn_internal_id_dict}
    FOR  ${sbts_online_rmod_internal_id}  IN  @{sbts_online_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${sbts_online_rmod_internal_id}
      ...  parameters=${sbts_rmod_online_states}
      ...  timeout=30s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}All SBTS radio modules are on line  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: SBTS ${rmod_type} radio module (sn: ${sbts_reset_rmod_sn}) reset  console=${log_to_console}

Step 5: CBTS Sharing Postconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 5: CBTS postconditions radio modules reset  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 5: CBTS postconditions radio modules reset  console=${log_to_console}

Step 6: SBTS Sharing Postconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 6: SBTS postconditions radio modules reset  console=${log_to_console}
# BTS Procedural State Should Be OnAir
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
    Log  ${ok_prefix_green}Step 6: SBTS postconditions radio modules reset  console=${log_to_console}
