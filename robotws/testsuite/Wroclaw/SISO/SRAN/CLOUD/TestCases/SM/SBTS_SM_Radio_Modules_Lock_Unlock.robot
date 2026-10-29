*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Robot/admin.robot
Resource    ../../../resources/bts_scfc.robot

*** Variables ***
# Maximum time to wait for complete lock RMOD operation
${RMOD_LOCK_MAX_WAIT_TIME}=    300s
# Maximum time to wait for complete unlock RMOD operation
${RMOD_UNLOCK_MAX_WAIT_TIME}=  300s

*** Keywords ***
TC__SBTS_SM_Radio_Modules_Lock_Unlock
    [Arguments]  ${sbts_scfc_file_path}  ${sbts_rmod_sn_list}=@{EMPTY}
    ...  ${admin_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case locks and unlocks radio module based on rmod serial number.
    ...  If the list of the radio modules serial numbers is empty then all radio modules are locked/unlocked.
    ...
    ...  Step 1: SBTS Preconditions Radio Modules Lock Unlock
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 2: SBTS Lock Radio Module
    ...  a) Radio module lock operation is successful
    ...  b) Radio module expected state: administrative_state = Locked
    ...  c) Impacted radio module cells have correct states
    ...  d) Not impacted radio modules are on line
    ...  e) Not impacted cells are OnAir
    ...  Step 3: SBTS Unlock Radio Module
    ...  a) Radio module unlock operation is successful
    ...  b) Radio module expected state: administrative_state = Unlocked
    ...  c) All cells should be OnAir
    ...  Step 4: SBTS Postconditions Radio Modules Lock Unlock
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | sbts_scfc_file_path    | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_rmod_sn_list      |  No  | List of radio module serial numbers to locked/unlocked.                    |
    ...  |                        |      | If the list is empty then all radio modules are locked/unlocked.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${sbts_scfc_file_path}
    Set Test Variable  ${sbts_rmod_sn_list}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  \n${start_prefix_green}Test Case: SBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}
    Step 1: SBTS Preconditions Radio Modules Lock Unlock
    FOR  ${sbts_locked_rmod_sn}  IN  @{sbts_locked_rmod_sn_list}
       Set Test Variable  ${sbts_locked_rmod_sn}
       Step 2: SBTS Lock Radio Module
       Step 3: SBTS Unlock Radio Module
    END
    Step 4: SBTS Postconditions Radio Modules Lock Unlock
    Log  ${done_prefix_green}Test Case: SBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}

Step 1: SBTS Preconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 1: SBTS preconditions radio modules lock unlock  console=${log_to_console}
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
    ${sbts_rmod_sn_cells_id_dict}=  BTS Get Radio Modules Serial Number And Cells Ids
    Set Test Variable  ${sbts_rmod_sn_cells_id_dict}
    ${sbts_rmod_sn_conf_id_dict}  ${smod_rmod_sn_internal_id_dict}=  BTS Get Radio Modules Serial Number And Ids
    ...  admin_connection=${admin_connection}
    Set Test Variable  ${sbts_rmod_sn_conf_id_dict}
    Set Test Variable  ${smod_rmod_sn_internal_id_dict}
# Set radio module locked list
    ${sbts_rmod_sn_actual_list}=  Get Dictionary Keys  dictionary=${sbts_rmod_sn_conf_id_dict}
    ${sbts_locked_rmod_sn_list}=  Set Variable If  ${sbts_rmod_sn_list}==@{EMPTY}
    ...  ${sbts_rmod_sn_actual_list}  ${sbts_rmod_sn_list}
    Set Test Variable  ${sbts_locked_rmod_sn_list}
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
    ${sbts_unimpacted_lncel_states}=
    ...  Set Variable  operationalState=regex"(?i)enabled",administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    Set Test Variable  ${sbts_unimpacted_lncel_states}
    Log  ${ok_prefix_green}Step 1: SBTS preconditions radio modules lock unlock  console=${log_to_console}

Step 2: SBTS Lock Radio Module
    Log  ${dots_prefix_green}Step 2: SBTS lock radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}
# Lock radio module
    ${sbts_locked_rmod_conf_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_conf_id_dict}  key=${sbts_locked_rmod_sn}
    Set Test Variable  ${sbts_locked_rmod_conf_id}
    ${lock_result}=  admin.Lock
    ...  dist_name=${sbts_locked_rmod_conf_id}
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}
    ...  connection=${admin_connection}
    Log  ${info_prefix}Lock radio module (sn: ${sbts_locked_rmod_sn}) succeeded (${lock_result})  console=${log_to_console}
# Wait for radio module expected states
    ${smod_locked_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${sbts_locked_rmod_sn}
    Set Test Variable  ${smod_locked_rmod_internal_id}
    admin.Assert
    ...  class_name=RMOD
    ...  id=${smod_locked_rmod_internal_id}
    ...  parameters=${sbts_locked_rmod_states}
    ...  timeout=300s
    ...  connection=${admin_connection}
    Log  ${info_prefix}Radio module (sn: ${sbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check radio module impacted LTE cells states
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
    Log  ${info_prefix}Impacted radio module (sn: ${sbts_locked_rmod_sn}) LNCELs status is OK  console=${log_to_console}
# Check radio module impacted IoT LTE cells states
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
    Log  ${info_prefix}Impacted radio module (sn: ${sbts_locked_rmod_sn}) IoT LNCELs status is OK  console=${log_to_console}
# Check if not impacted radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    ${smod_unlocked_rmod_internal_id_list}=  Get Dictionary Values  dictionary=${smod_rmod_sn_internal_id_dict}
    Set Test Variable  ${smod_unlocked_rmod_internal_id_list}
    Remove Values From List  ${smod_unlocked_rmod_internal_id_list}  ${smod_locked_rmod_internal_id}
    FOR  ${smod_unlocked_rmod_internal_id}  IN  @{smod_unlocked_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_unlocked_rmod_internal_id}
      ...  parameters=${sbts_unlocked_rmod_states}
      ...  timeout=300s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not impacted radio modules are on line  console=${log_to_console}
# Check radio module not impacted LTE cells states
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
    Log  ${info_prefix}Not impacted radio module (sn: ${sbts_locked_rmod_sn}) LNCELs are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: SBTS lock radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}

Step 3: SBTS Unlock Radio Module
    Log  ${dots_prefix_green}Step 3: SBTS unlock radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}
# Unlock radio module
    ${unlock_result}=  admin.Unlock
    ...  dist_name=${sbts_locked_rmod_conf_id}
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  connection=${admin_connection}
    Log  ${info_prefix}Unlock radio module (sn: ${sbts_locked_rmod_sn}) succeeded (${unlock_result})  console=${log_to_console}
# Wait for radio module expected state
    admin.Assert
    ...  class_name=RMOD
    ...  id=${smod_locked_rmod_internal_id}
    ...  parameters=${sbts_unlocked_rmod_states}
    ...  timeout=300s
    ...  connection=${admin_connection}
    Log  ${info_prefix}Radio module (sn: ${sbts_locked_rmod_sn}) is Unlocked  console=${log_to_console}
# Check if all radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    FOR  ${smod_unlocked_rmod_internal_id}  IN  @{smod_unlocked_rmod_internal_id_list}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_unlocked_rmod_internal_id}
      ...  parameters=${sbts_unlocked_rmod_states}
      ...  timeout=300s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: SBTS unlock radio module (sn: ${sbts_locked_rmod_sn})  console=${log_to_console}

Step 4: SBTS Postconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 4: SBTS postconditions radio modules lock unlock  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: SBTS postconditions radio modules lock unlock  console=${log_to_console}
