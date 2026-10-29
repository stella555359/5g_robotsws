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
# Maximum time to wait for complete lock RMOD operation
${RMOD_LOCK_MAX_WAIT_TIME}=    300
# Maximum time to wait for complete unlock RMOD operation
${RMOD_UNLOCK_MAX_WAIT_TIME}=  300
# Allowed test case historical alarms
@{VCU_SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
@{VDU_SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}=  faultId=1931, severity=critical
@{SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}=  faultId=1931, severity=Critical

*** Keywords ***
TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
    [Arguments]  ${vdu_scfc_file_path}  ${sbts_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}
    ...  ${cbts_rmod_sn_count}=0  ${sbts_rmod_sn_list}=@{EMPTY}  ${sbts_rmod_sn_count}=0
    ...  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}  ${admin_connection}=${ADMIN_CONNECTION_DEFAULT}
    ...  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case locks and unlocks radio module based on rmod serial number.
    ...  If the list of the radio modules serial numbers is empty then all radio modules are locked/unlocked.
    ...  Test supports RF sharing SBTS-CBTS configuration.
    ...  Test case supports:
    ...  - CBTS side: NR cells
    ...  - SBTS side: LTE cells
    ...  SCF file should contain the serial numbers of the radio modules.
    ...
    ...  Step 1: CBTS Sharing Preconditions Radio Modules Lock Unlock
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: SBTS Preconditions Radio Modules Lock Unlock
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 3: CBTS Sharing Lock Radio Module
    ...  a) Lock CBTS radio module
    ...  b) Check CBTS radio module lock operation status
    ...  c) Check locked CBTS radio module state
    ...  d) Check locked CBTS radio module NR cells states
    ...  e) Check shared locked SBTS radio module states
    ...  f) Check shared locked SBTS radio module LTE cells states
    ...  g) Check shared locked SBTS radio module IoT LTE cells states
    ...  h) Check shared locked SBTS radio module active alarm
    ...  i) Check if not locked CBTS radio modules are on line
    ...  j) Check CBTS not locked radio modules NR cells states
    ...  k) Check if shared not locked SBTS radio modules are on line
    ...  l) Check shared not locked SBTS radio modules all LTE cells states
    ...  Step 4: CBTS Sharing Unlock Radio Module
    ...  a) Unlock CBTS radio module
    ...  b) Check CBTS radio module unlock operation status
    ...  c) Check unlocked CBTS radio module state
    ...  d) Check shared unlocked SBTS radio module inactive alarm
    ...  e) Check if all CBTS radio modules are on line
    ...  f) Check if all cells are OnAir
    ...  Step 5: SBTS Lock Radio Module
    ...  a) Lock SBTS radio module
    ...  b) Check locked SBTS radio module states
    ...  c) Check locked SBTS radio module LTE cells states
    ...  d) Check locked SBTS radio module IoT LTE cells states
    ...  e) Check shared locked CBTS radio module state
    ...  f) Check shared locked CBTS radio module NR cells states
    ...  g) Check shared locked CBTS radio module active alarm
    ...  h) Check if not locked SBTS radio modules are on line
    ...  i) Check not locked SBTS radio modules LTE cells states
    ...  k) Check if shared not locked CBTS radio modules are on line
    ...  l) Check shared not locked CBTS radio modules NR cells states
    ...  Step 6: SBTS Unlock Radio Module
    ...  a) Unlock SBTS radio module
    ...  b) Check unlocked SBTS radio module state
    ...  c) Check shared unlocked SBTS radio module inactive alarm
    ...  d) Check if all SBTS radio modules are on line
    ...  e) Check if all SBTS cells are OnAir
    ...  Step 7: CBTS Sharing Postconditions Radio Modules Lock Unlock
    ...  a) The same values as in Step 1
    ...  Step 8: SBTS Postconditions Radio Modules Lock Unlock
    ...  a) The same values as in Step 1
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
    Log  ${start_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}
    Step 1: CBTS Sharing Preconditions Radio Modules Lock Unlock
    Step 2: SBTS Sharing Preconditions Radio Modules Lock Unlock
    FOR  ${cbts_locked_rmod_sn}  IN  @{cbts_locked_rmod_sn_list}
      Set Test Variable  ${cbts_locked_rmod_sn}
      Step 3: CBTS Sharing Lock Radio Module
      Step 4: CBTS Sharing Unlock Radio Module
    END
    FOR  ${sbts_locked_rmod_sn}  IN  @{sbts_locked_rmod_sn_list}
       Set Test Variable  ${sbts_locked_rmod_sn}
       Step 5: SBTS Sharing Lock Radio Module
       Step 6: SBTS Sharing Unlock Radio Module
    END
    Step 7: CBTS Sharing Postconditions Radio Modules Lock Unlock
    Step 8: SBTS Sharing Postconditions Radio Modules Lock Unlock
    Log  ${done_prefix_green}Test Case: CBTS_SBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Sharing Preconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 1: CBTS preconditions radio modules lock unlock  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}
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
    ${vdu_scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${vdu_scfc_file_path}
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
    ${cbts_locked_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${cbts_rmod_sn_list}  rmod_sn_count=${cbts_rmod_sn_count}
    Set Test Variable  ${cbts_locked_rmod_sn_list}
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
    Remove Values From List  ${cbts_locked_rmod_sn_list}  @{cbts_sharing_secondary_rmod_sn_list}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=dependency
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_shared_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_shared_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions radio modules lock unlock  console=${log_to_console}

Step 2: SBTS Sharing Preconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 2: SBTS preconditions radio modules lock unlock  console=${log_to_console}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{SBTS_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}
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
# Set tested radio modules list
    ${sbts_locked_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${sbts_scfc_file_path}
    ...  rmod_sn_list=${sbts_rmod_sn_list}  rmod_sn_count=${sbts_rmod_sn_count}
    Set Test Variable  ${sbts_locked_rmod_sn_list}
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
    Remove Values From List  ${sbts_locked_rmod_sn_list}  @{sbts_sharing_secondary_rmod_sn_list}
    Set Test Variable  ${sbts_sharing_secondary_rmod_sn_list}
# Set radio modules states
    ${sbts_locked_rmod_states}=  Set Variable  operationalState=regex"(?i)enabled", administrativeState=regex"(?i)locked
    Set Test Variable  ${sbts_locked_rmod_states}
    ${sbts_unlocked_rmod_states}=  Set Variable  operationalState=regex"(?i)enabled", administrativeState=regex"(?i)unlocked
    Set Test Variable  ${sbts_unlocked_rmod_states}
# Set cells states
    ${sbts_impacted_lncel_states_1}=  Set Variable  availabilityStatus=regex"(?i)dependency", operationalState=regex"(?i)disabled"
    ${sbts_impacted_lncel_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_impacted_lncel_states}=  Set Variable  ${sbts_impacted_lncel_states_1}, ${sbts_impacted_lncel_states_2}
    Set Test Variable  ${sbts_impacted_lncel_states}
    ${sbts_impacted_iot_lncel_states_1}=  Set Variable  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled"
    ${sbts_impacted_iot_lncel_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_impacted_iot_lncel_states}=  Set Variable  ${sbts_impacted_iot_lncel_states_1}, ${sbts_impacted_iot_lncel_states_2}
    Set Test Variable  ${sbts_impacted_iot_lncel_states}
    ${sbts_shared_impacted_lncel_states_1}=  Set Variable  availabilityStatus=regex"(?i)failed", operationalState=regex"(?i)disabled"
    ${sbts_shared_impacted_lncel_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_shared_impacted_lncel_states}=  Set Variable  ${sbts_shared_impacted_lncel_states_1}, ${sbts_shared_impacted_lncel_states_2}
    Set Test Variable  ${sbts_shared_impacted_lncel_states}
    ${sbts_unimpacted_lncel_states}=
    ...  Set Variable  operationalState=regex"(?i)enabled",administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    Set Test Variable  ${sbts_unimpacted_lncel_states}
    Log  ${ok_prefix_green}Step 2: SBTS preconditions radio modules lock unlock  console=${log_to_console}

Step 3: CBTS Sharing Lock Radio Module
    ${rmod_type}=  Set Variable If  '${cbts_locked_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}  shared  dedicated
    Set Test Variable  ${rmod_type}
    Log  ${dots_prefix_green}Step 3: CBTS lock ${rmod_type} radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}
# Lock CBTS radio module
    ${cbts_rmod_conf_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_conf_id_dict}  key=${cbts_locked_rmod_sn}
    ${cbts_rmod_conf_id}=  Convert To String  item=${cbts_rmod_conf_id}
    ${cbts_block_rmods_conf_id_list}=  Create List  ${cbts_rmod_conf_id}
    Set Test Variable  ${cbts_block_rmods_conf_id_list}
    ${lock_result}=  vdu.Lock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Check CBTS radio module lock operation status
    RMOD Lock Wait For Expected Status
    ...  operation_id=${lock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Lock CBTS radio module (sn: ${cbts_locked_rmod_sn}) succeeded  console=${log_to_console}
# Check locked CBTS radio module state
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_locked_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Locked
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}CBTS radio module (sn: ${cbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check locked CBTS radio module NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Locked CBTS radio module (sn: ${cbts_locked_rmod_sn}) cells status is OK  console=${log_to_console}
# Check shared locked SBTS radio module and cells states and alarms
    IF  '${cbts_locked_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared locked SBTS radio module (sn: ${cbts_locked_rmod_sn}) and cells status checking  console=${log_to_console}
# Check shared locked SBTS radio module states
      ${smod_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${cbts_locked_rmod_sn}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_locked_rmod_internal_id}
      ...  parameters=${sbts_locked_rmod_states}
      ...  timeout=30s
      ...  connection=${admin_connection}
      Log  ${below_info_prefix}Shared SBTS radio module (sn: ${cbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check shared locked SBTS radio module LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
      @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
      Remove Values From List   ${sbts_rmod_impacted_lncelid_list}  @{sbts_scfc_lncelid_iot_inband_guardband_list}
      FOR  ${sbts_rmod_impacted_lncelid}  IN  @{sbts_rmod_impacted_lncelid_list}
        ${sbts_rmod_impacted_lncel_distname}=  admin.Get Cell Id By Configuration Id
        ...  rat=LTE
        ...  configuration_id=${sbts_rmod_impacted_lncelid}
        ...  connection=${admin_connection}
        admin.Assert  class_name=LNCEL
        ...  id=${sbts_rmod_impacted_lncel_distname}
        ...  parameters=${sbts_shared_impacted_lncel_states}
        ...  timeout=10s
        ...  connection=${admin_connection}
      END
      Log  ${below_info_prefix}Shared locked SBTS radio module (sn: ${cbts_locked_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check shared locked SBTS radio module IoT LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
      @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
      Remove Values From List   ${sbts_rmod_impacted_lncelid_list}  @{sbts_scfc_lncelid_not_iot_list}
      FOR  ${sbts_rmod_impacted_lncelid}  IN  @{sbts_rmod_impacted_lncelid_list}
        ${sbts_rmod_impacted_lncel_distname}=  admin.Get Cell Id By Configuration Id
        ...  rat=LTE
        ...  configuration_id=${sbts_rmod_impacted_lncelid}
        ...  connection=${admin_connection}
        admin.Assert  class_name=LNCEL
        ...  id=${sbts_rmod_impacted_lncel_distname}
        ...  parameters=${sbts_shared_impacted_lncel_states}
        ...  timeout=10s
        ...  connection=${admin_connection}
      END
      Log  ${below_info_prefix}Shared locked SBTS radio module (sn: ${cbts_locked_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
# Check shared locked SBTS radio module active alarm
      IF  ${sbts_rmod_impacted_lncelid_list}!=@{EMPTY}
        admin.Assert Alarm Active
        ...  parameters=faultId=1931, severity=Critical, faultName="RF Module blocked", alarmingResource=${smod_locked_rmod_internal_id}
        ...  timeout=30s
        ...  connection=${admin_connection}
        Log  ${below_info_prefix}Alarm (faultId:1931) on shared SBTS radio module (sn: ${cbts_locked_rmod_sn}) is active  console=${log_to_console}
      END
    END
# Check if not locked CBTS radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    ${cbts_online_rmod_sn_list}=  Copy List  ${cbts_locked_rmod_sn_list}
    Remove Values From List  ${cbts_online_rmod_sn_list}  ${cbts_locked_rmod_sn}
    FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
      RMOD Wait For Online
      ...  rmod_sn=${cbts_online_rmod_sn}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not locked CBTS radio modules are on line  console=${log_to_console}
# Check CBTS not locked radio modules NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
    ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
    Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
    FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unimpacted_cbts_cell_id}
      ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not locked CBTS radio modules cells are OnAir  console=${log_to_console}
# Check shared not locked SBTS radio modules and cells states
    IF  '${cbts_locked_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared not locked SBTS radio modules and cells status checking  console=${log_to_console}
# Check if shared not locked SBTS radio modules are on line
      ${smod_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${cbts_locked_rmod_sn}
      ${smod_unlocked_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${smod_rmod_sn_internal_id_dict}
      Remove Values From List  ${smod_unlocked_rmod_internal_id_list}  ${smod_locked_rmod_internal_id}
      FOR  ${smod_unlocked_rmod_internal_id}  IN  @{smod_unlocked_rmod_internal_id_list}
        admin.Assert
        ...  class_name=RMOD
        ...  id=${smod_unlocked_rmod_internal_id}
        ...  parameters=${sbts_unlocked_rmod_states}
        ...  timeout=300s
        ...  connection=${admin_connection}
      END
      Log  ${below_info_prefix}Shared not locked SBTS radio modules are on line  console=${log_to_console}
# Check shared not locked SBTS radio modules LTE cells states
      ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
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
      Log  ${below_info_prefix}Shared not locked SBTS radio modules LNCELs are OnAir  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 3: CBTS lock ${rmod_type} radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}

Step 4: CBTS Sharing Unlock Radio Module
    Log  ${dots_prefix_green}Step 4: CBTS unlock ${rmod_type} radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}
# Unlock CBTS radio module
    Log  ${info_prefix}Wait a while for CBTS radio module (sn: ${cbts_locked_rmod_sn}) unlock ...  console=${log_to_console}
    Sleep  10s  reason=Waiting time before unlock radio module
    ${unlock_result}=  vdu.Unlock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Check CBTS radio module unlock operation status
    RMOD Unlock Wait For Expected Status
    ...  operation_id=${unlock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Unlock CBTS radio module (sn: ${cbts_locked_rmod_sn}) succeeded  console=${log_to_console}
# Check unlocked CBTS radio module state
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_locked_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Unlocked
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}CBTS radio module (sn: ${cbts_locked_rmod_sn}) is Unlocked  console=${log_to_console}
# Check shared unlocked SBTS radio module inactive alarm
    IF  '${cbts_locked_rmod_sn}' in ${sbts_sharing_secondary_rmod_sn_list}
      ${smod_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${cbts_locked_rmod_sn}
      admin.Assert Alarm Inactive
      ...  parameters=faultId=1931, severity=Critical, faultName="RF Module blocked", alarmingResource=${smod_locked_rmod_internal_id}
      ...  timeout=30s
      ...  connection=${admin_connection}
      Log  ${info_prefix}Alarm (faultId:1931) on shared SBTS radio module (sn: ${cbts_locked_rmod_sn}) is inactive  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: CBTS unlock ${rmod_type} radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}

Step 5: SBTS Sharing Lock Radio Module
    ${rmod_type}=  Set Variable If  '${sbts_locked_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}  shared  dedicated
    Log  ${dots_prefix_green}Step 5: SBTS lock ${rmod_type} radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}
# Lock SBTS radio module
    ${sbts_locked_rmod_conf_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_conf_id_dict}  key=${sbts_locked_rmod_sn}
    Set Test Variable  ${sbts_locked_rmod_conf_id}
    ${lock_result}=  admin.Lock
    ...  dist_name=${sbts_locked_rmod_conf_id}
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}
    ...  connection=${admin_connection}
    Log  ${info_prefix}Lock radio module (sn: ${sbts_locked_rmod_sn}) succeeded (${lock_result})  console=${log_to_console}
# Check locked SBTS radio module states
    ${smod_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${sbts_locked_rmod_sn}
    Set Test Variable  ${smod_locked_rmod_internal_id}
    admin.Assert
    ...  class_name=RMOD
    ...  id=${smod_locked_rmod_internal_id}
    ...  parameters=${sbts_locked_rmod_states}
    ...  timeout=300s
    ...  connection=${admin_connection}
    Log  ${info_prefix}SBTS radio module (sn: ${sbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check locked SBTS radio module LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_locked_rmod_sn}
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
    Log  ${info_prefix}Locked SBTS radio module (sn: ${sbts_locked_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check locked SBTS radio module IoT LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_locked_rmod_sn}
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
    Log  ${info_prefix}Locked SBTS radio module (sn: ${sbts_locked_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
# Check shared locked CBTS radio module and cells states and alarms
    IF  '${sbts_locked_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared locked CBTS radio module (sn: ${sbts_locked_rmod_sn}) and cells checking  console=${log_to_console}
# Check shared locked CBTS radio module state
      RMOD Wait For Expected State
      ...  rmod_sn=${sbts_locked_rmod_sn}
      ...  rmod_state=administrative_state
      ...  rmod_state_value=Locked
      ...  vdu_connection=${vdu_connection}
      Log  ${below_info_prefix}Shared CBTS radio module (sn: ${sbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check shared locked CBTS radio module NR cells states
      ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${sbts_locked_rmod_sn}
      FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
        Cell Wait For Expected States Or Statuses
        ...  cell_id=${cbts_rmod_impacted_cell_id}
        ...  state_status_dict=${cbts_shared_impacted_cell_state_dict}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared locked CBTS radio module (sn: ${sbts_locked_rmod_sn}) cells status is OK  console=${log_to_console}
# Check shared locked CBTS radio module active alarm
      IF  ${cbts_rmod_impacted_cells_id_list}!=@{EMPTY}
        ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${sbts_locked_rmod_sn}
        ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
        ${alarm_severity_list}=  Create List  critical
        vDU Assert Alarm Active
        ...  fault_id=1931
        ...  alarming_object_list=${alarming_object_list}
        ...  alarm_severity_list=${alarm_severity_list}
        ...  timeout=30s
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Alarm (faultId:1931) on shared CBTS radio module (sn: ${sbts_locked_rmod_sn}) is active  console=${log_to_console}
      END
    END
# Check if not locked SBTS radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    ${smod_unlocked_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${smod_rmod_sn_internal_id_dict}
    Set Test Variable  ${smod_unlocked_rmod_internal_id_list}
    Remove Values From List  ${smod_unlocked_rmod_internal_id_list}  ${smod_locked_rmod_internal_id}
    FOR  ${smod_unlocked_rmod_internal_id}  IN  @{smod_unlocked_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_unlocked_rmod_internal_id}
      ...  parameters=${sbts_unlocked_rmod_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not locked SBTS radio modules are on line  console=${log_to_console}
# Check not locked SBTS radio modules LTE cells states
    ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_locked_rmod_sn}
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
    Log  ${info_prefix}Not locked SBTS radio modules LNCELs are OnAir  console=${log_to_console}
# Check shared not locked CBTS radio modules and cells states
    IF  '${sbts_locked_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      Log  ${info_prefix}Shared not locked CBTS radio modules and cells checking  console=${log_to_console}
# Check if shared not locked CBTS radio modules are on line
      ${cbts_online_rmod_sn_list}=  Copy List  ${cbts_locked_rmod_sn_list}
      Remove Values From List  ${cbts_online_rmod_sn_list}  ${sbts_locked_rmod_sn}
      FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
        RMOD Wait For Online
        ...  rmod_sn=${cbts_online_rmod_sn}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared not locked CBTS radio modules are on line  console=${log_to_console}
# Check shared not locked CBTS radio modules NR cells states
      ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${sbts_locked_rmod_sn}
      ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
      Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
      FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
        Cell Wait For Expected States Or Statuses
        ...  cell_id=${unimpacted_cbts_cell_id}
        ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
        ...  timeout=10s
        ...  vdu_connection=${vdu_connection}
      END
      Log  ${below_info_prefix}Shared not locked CBTS radio modules cells are OnAir  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 5: SBTS lock ${rmod_type} radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}

Step 6: SBTS Sharing Unlock Radio Module
    Log  ${dots_prefix_green}Step 6: SBTS unlock ${rmod_type} radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}
# Unlock SBTS radio module
    ${unlock_result}=  admin.Unlock
    ...  dist_name=${sbts_locked_rmod_conf_id}
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  connection=${admin_connection}
    Log  ${info_prefix}Unlock SBTS radio module (sn: ${sbts_locked_rmod_sn}) succeeded (${unlock_result})  console=${log_to_console}
# Check unlocked SBTS radio module state
    admin.Assert
    ...  class_name=RMOD
    ...  id=${smod_locked_rmod_internal_id}
    ...  parameters=${sbts_unlocked_rmod_states}
    ...  timeout=300s
    ...  connection=${admin_connection}
    Log  ${info_prefix}SBTS radio module (sn: ${sbts_locked_rmod_sn}) is Unlocked  console=${log_to_console}
# Check shared unlocked CBTS radio module inactive alarm
    IF  '${sbts_locked_rmod_sn}' in ${cbts_sharing_secondary_rmod_sn_list}
      ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${sbts_locked_rmod_sn}
      ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
      ${alarm_severity_list}=  Create List  critical
      vDU Assert Alarm Inactive
      ...  fault_id=1931
      ...  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Alarm (faultId:1931) on shared CBTS radio module (sn: ${sbts_locked_rmod_sn}) is inactive  console=${log_to_console}
    END
# Check if all SBTS radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    FOR  ${smod_unlocked_rmod_internal_id}  IN  @{smod_unlocked_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_unlocked_rmod_internal_id}
      ...  parameters=${sbts_unlocked_rmod_states}
      ...  timeout=300s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}All SBTS radio modules are on line  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: SBTS unlock ${rmod_type} radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}

Step 7: CBTS Sharing Postconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 7: CBTS postconditions radio modules lock unlock  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
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
    Log  ${ok_prefix_green}Step 7: CBTS postconditions radio modules lock unlock  console=${log_to_console}

Step 8: SBTS Sharing Postconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 8: SBTS postconditions radio modules lock unlock  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 8: SBTS postconditions radio modules lock unlock  console=${log_to_console}
