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
${SITE_RESET_MAX_WAIT_TIME}=  300s
# Allowed test case historical alarms
@{VCU_SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
@{VDU_SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
...                                          faultId=10, severity=minor
...                                          faultId=4592, severity=warning
...                                          faultId=4592, severity=minor
@{SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, severity=Critical
...                                          faultId=10, severity=Minor
...                                          faultId=1815, severity=Minor
...                                          faultId=4592, severity=Warning
...                                          faultId=4592, severity=Minor

*** Keywords ***
TC__Cloud_SBTS_STARTUP_CBTS_vDU_SBTS_Site_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${sbts_scfc_file_path}  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}
    ...  ${admin_connection}=${ADMIN_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case performs vDU reset (CBTS side) and next site reset (SBTS side).
    ...  Test supports RF sharing SBTS-CBTS configuration.
    ...  Test case supports:
    ...  - CBTS side: NR cells
    ...  - SBTS side: LTE cells
    ...  SCFC file should contain the serial numbers of the radio modules.
    ...
    ...  Step 1: CBTS Sharing Preconditions Radio Modules Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: SBTS Preconditions Radio Modules Reset
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 3: CBTS Sharing vDU Reset
    ...  a) vDU reset
    ...  b) Check if vDU OAM IP address is unavailable
    ...  c) Check shared impacted SBTS radio module states
    ...  d) Check shared impacted SBTS radio module active alarm
    ...  e) Check shared impacted SBTS radio modules LTE cells states
    ...  f) Check shared impacted SBTS radio module IoT LTE cells states
    ...  g) Check shared reset SBTS radio module active alarm
    ...  h) Check if vDU OAM IP address is available
    ...  i) Check if API connection is established
    ...  j) Check BTS Reset Cause Alarm
    ...  k) Check if all CBTS radio modules are on line
    ...  l) Check if all CBTS cells are OnAir
    ...  m) Check vDU operational state
    ...  n) Check if all SBTS cells are OnAir
    ...  Step 4: SBTS Sharing Site Reset
    ...  a) SBTS site reset
    ...  b) Check if shared impacted CBTS radio modules are off line
    ...  c) Check shared impacted CBTS radio module active alarm
    ...  d) Check shared impacted CBTS radio modules cells states
    ...  e) Check if all SBTS radio modules are on line
    ...  f) BTS Procedural State should be OnAir
    ...  g) Check if all SBTS cells are OnAir
    ...  h) Check if all CBTS cells are OnAir
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
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_SBTS_CBTS_vDU_SBTS_Site_Reset  console=${log_to_console}
    Step 1: CBTS Sharing Preconditions vDU And Site Reset
    Step 2: SBTS Sharing Preconditions vDU And Site Reset
    Step 3: CBTS Sharing vDU Reset
    Step 4: SBTS Sharing Site Reset
    Step 5: CBTS Sharing Postconditions vDU And Site Reset
    Step 6: SBTS Sharing Postconditions vDU And Site Reset
    Log  ${done_prefix_green}Test Case: CBTS_SBTS_CBTS_vDU_SBTS_Site_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Sharing Preconditions vDU And Site Reset
    Log  ${dots_prefix_green}Step 1: CBTS preconditions radio modules reset  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}
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
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
#Get fault 4592 cancellation timer
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${timer_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${fault_cancellation_timer}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${timer_mo_dn}
    ...  para_name=fault4592CancellationTimer
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${fault_cancellation_timer}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions radio modules reset  console=${log_to_console}

Step 2: SBTS Sharing Preconditions vDU And Site Reset
    Log  ${dots_prefix_green}Step 2: SBTS preconditions radio modules reset  console=${log_to_console}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{SBTS_VDU_SITE_RESET_ALLOWED_HIST_ALARMS}
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
    ${sbts_rmod_sn_conf_id_dict}  ${smod_rmod_sn_internal_id_dict}=
    ...  BTS Get Radio Modules Serial Number And Ids  admin_connection=${admin_connection}
    Set Test Variable  ${sbts_rmod_sn_conf_id_dict}
    Set Test Variable  ${smod_rmod_sn_internal_id_dict}
    ${sbts_admin_rmod_sn_list}=  Get Dictionary Keys  dictionary=${sbts_rmod_sn_conf_id_dict}
    Sort List  ${sbts_scfc_rmod_sn_list}
    Sort List  ${sbts_admin_rmod_sn_list}
    Lists Should Be Equal  list1=${sbts_scfc_rmod_sn_list}  list2=${sbts_admin_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
    Set Test Variable  ${sbts_admin_rmod_sn_list}
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
    ${sbts_sharing_rmod_sn_list}=  Create List  @{sbts_sharing_primary_rmod_sn_list}  @{sbts_sharing_secondary_rmod_sn_list}
# Set radio module synchronization link list
    ${sbts_sync_rmod_conf_id_list}=  Get Radio Module Synchronization Link List
    ${sbts_sync_rmod_sn_list}=  Create List
    FOR  ${sbts_sharing_rmod_sn}  IN  @{sbts_sharing_rmod_sn_list}
      ${sbts_rmod_conf_id}=  Get From Dictionary  dictionary=${sbts_rmod_sn_conf_id_dict}  key=${sbts_sharing_rmod_sn}
      IF  '${sbts_rmod_conf_id}' in ${sbts_sync_rmod_conf_id_list}
        Append To List  ${sbts_sync_rmod_sn_list}  ${sbts_sharing_rmod_sn}
      END
    END
# Set affected radio modules list
    ${cbts_affected_rmod_sn_list}=  Create List
    FOR  ${sbts_sync_rmod_sn}  IN  @{sbts_sync_rmod_sn_list}
      IF  '${sbts_sync_rmod_sn}' in ${sbts_sharing_rmod_sn_list}
        Append To List  ${cbts_affected_rmod_sn_list}  ${sbts_sync_rmod_sn}
      END
    END
    ${sbts_affected_rmod_sn_list}=  Copy List  ${sbts_sharing_rmod_sn_list}
    Remove Values From List  ${sbts_affected_rmod_sn_list}  @{cbts_affected_rmod_sn_list}
    Set Test Variable  ${cbts_affected_rmod_sn_list}
    Set Test Variable  ${sbts_affected_rmod_sn_list}
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

Step 3: CBTS Sharing vDU Reset
    Log  ${dots_prefix_green}Step 3: CBTS sharing vDU reset  console=${log_to_console}
    Log  ${info_prefix}vDU reset is being performed. Wait for vDU reset ...  console=${log_to_console}
    ${reset_result}=  vdu.Reset Vdu
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}vDU reset operation status: ${reset_result['status']}  console=${log_to_console}
    vDU Rest Logout  vdu_connection=${vdu_connection}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
# Check if vDU OAM IP address is unavailable
    Ip Address Is Unavailable  ip_addr=${ip_addr}  timeout=240s
    Log  ${info_prefix}vDU is unavailable now  console=${log_to_console}
    IF  ${sbts_affected_rmod_sn_list}!=@{EMPTY}
# Check shared impacted SBTS radio module states
      Log  ${info_prefix}Shared SBTS radio modules are checking  console=${log_to_console}
      FOR  ${sbts_affected_rmod_sn}  IN  @{sbts_affected_rmod_sn_list}
        ${smod_affected_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${sbts_affected_rmod_sn}
        admin.Assert
        ...  class_name=RMOD
        ...  id=${smod_affected_rmod_internal_id}
        ...  parameters=${sbts_rmod_offline_states}
        ...  timeout=30s
        ...  connection=${admin_connection}
        Log  ${below_info_prefix}Shared impacted SBTS radio module (sn: ${sbts_affected_rmod_sn}) is off line  console=${log_to_console}
      END
# Check shared impacted SBTS radio module active alarm
      ${fault_name}=  Set Variable  "No connection to unit"
      ${sbts_shared_rmod_impacted_lncelid_list}=  Create List
      FOR  ${sbts_affected_rmod_sn}  IN  @{sbts_affected_rmod_sn_list}
        ${sbts_rmod_impacted_cells_id_dict}=  Get From Dictionary  dictionary=${sbts_rmod_sn_cells_id_dict}  key=${sbts_affected_rmod_sn}
        @{sbts_rmod_impacted_lncelid_list}=  Get From Dictionary  dictionary=${sbts_rmod_impacted_cells_id_dict}  key=LNCEL
        Append To List  ${sbts_shared_rmod_impacted_lncelid_list}  @{sbts_rmod_impacted_lncelid_list}
        IF  ${sbts_rmod_impacted_lncelid_list}==@{EMPTY}
          ${smod_affected_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${sbts_affected_rmod_sn}
          admin.Assert Alarm Active
          ...  parameters=faultId=10, severity=Minor, faultName=${fault_name}, alarmingResource=${smod_affected_rmod_internal_id}
          ...  timeout=30s
          ...  connection=${admin_connection}
          Log  ${below_info_prefix}Alarm (FID:10, severity:Minor) on shared impacted SBTS radio module (sn: ${sbts_affected_rmod_sn}) is active
          ...  console=${log_to_console}
        ELSE
          ${smod_affected_rmod_internal_id}=  Get From Dictionary  dictionary=${smod_rmod_sn_internal_id_dict}  key=${sbts_affected_rmod_sn}
          admin.Assert Alarm Active
          ...  parameters=faultId=10, severity=Critical, faultName=${fault_name}, alarmingResource=${smod_affected_rmod_internal_id}
          ...  timeout=30s
          ...  connection=${admin_connection}
          Log  ${below_info_prefix}Alarm (FID:10, severity:Critical) on shared impacted SBTS radio module (sn: ${sbts_affected_rmod_sn}) is active
          ...  console=${log_to_console}
        END
      END
      IF  ${sbts_shared_rmod_impacted_lncelid_list}!=@{EMPTY}
# Check shared impacted SBTS radio modules LTE cells states
        ${sbts_rmods_impacted_lncelid_list}=  Copy List  ${sbts_shared_rmod_impacted_lncelid_list}
        Remove Values From List   ${sbts_rmods_impacted_lncelid_list}  @{sbts_scfc_lncelid_iot_inband_guardband_list}
        FOR  ${sbts_rmod_impacted_lncelid}  IN  @{sbts_rmods_impacted_lncelid_list}
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
        Log  ${below_info_prefix}Shared impacted SBTS radio modules LNCELs status is OK  console=${log_to_console}
# Check shared impacted SBTS radio module IoT LTE cells states
        ${sbts_rmods_impacted_lncelid_list}=  Copy List  ${sbts_shared_rmod_impacted_lncelid_list}
        Remove Values From List   ${sbts_rmods_impacted_lncelid_list}  @{sbts_scfc_lncelid_not_iot_list}
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
        Log  ${below_info_prefix}Shared impacted SBTS radio modules IoT LNCELs status is OK  console=${log_to_console}
      END
    END
# Check if vDU OAM IP address is available
    Log  ${info_prefix}Wait for vDU availability ...  console=${log_to_console}
    Ip Address Is Available  ip_addr=${ip_addr}  timeout=240s
    Log  ${below_info_prefix}vDU is available now  console=${log_to_console}
# Check if API connection is established
    Log  ${info_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  30  2
    ...  vDU Rest Login  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}API connection established  console=${log_to_console}
# Check BTS Reset Cause Alarm
    vDU Check BTS Reset Cause Alarm
    ...  activation_timeout=60s
    ...  cancellation_timeout=${fault_cancellation_timer}
    ...  info_pattern=*due to user request*
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${info_prefix}
# Check if all CBTS radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS radio modules are on line  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=60s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: CBTS sharing vDU reset  console=${log_to_console}

Step 4: SBTS Sharing Site Reset
    Log  ${dots_prefix_green}Step 4: SBTS sharing site reset  console=${log_to_console}
# SBTS site reset
    Log  ${info_prefix}SBTS reset site is being performed. Wait for BTS reset ...  console=${log_to_console}
    admin.Reset Site
    ...  timeout=${SITE_RESET_MAX_WAIT_TIME}
    ...  admin_connection=${admin_connection}
    Ip Address Is Available  ip_addr=${ENB_IP_ADDR}  timeout=240
    Log  ${info_prefix}SBTS is available (pingable)  console=${log_to_console}
    IF  ${cbts_affected_rmod_sn_list}!=@{EMPTY}
# Check if shared impacted CBTS radio modules are off line
      Log  ${info_prefix}Shared CBTS radio modules and cells are checking  console=${log_to_console}
      FOR  ${cbts_affected_rmod_sn}  IN  @{cbts_affected_rmod_sn_list}
        RMOD Wait For Offline
        ...  rmod_sn=${cbts_affected_rmod_sn}
        ...  timeout=30s
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Shared impacted CBTS radio module (sn: ${cbts_affected_rmod_sn}) is off line  console=${log_to_console}
      END
# Check shared impacted CBTS radio module active alarm
      ${fault_name}=  Set Variable  "No connection to unit"
      ${cbts_shared_rmod_impacted_cells_id_list}=  Create List
      FOR  ${cbts_affected_rmod_sn}  IN  @{cbts_affected_rmod_sn_list}
        ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_affected_rmod_sn}
        Append To List  ${cbts_shared_rmod_impacted_cells_id_list}  @{cbts_rmod_impacted_cells_id_list}
        IF  ${cbts_rmod_impacted_cells_id_list}==@{EMPTY}
          ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${cbts_affected_rmod_sn}
          ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
          ${alarm_severity_list}=  Create List  minor
          vDU Assert Alarm Active
          ...  fault_id=10
          ...  alarming_object_list=${alarming_object_list}
          ...  alarm_severity_list=${alarm_severity_list}
          ...  timeout=30s
          ...  vdu_connection=${vdu_connection}
          Log  ${below_info_prefix}Alarm (FID:10, severity:Minor) on shared impacted CBTS radio module (sn: ${cbts_affected_rmod_sn_list}) is active
          ...  console=${log_to_console}
        ELSE
          ${cbts_rmod_runtime_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_runtime_id_dict}  key=${cbts_affected_rmod_sn}
          ${alarming_object_list}=  Create List  ${cbts_rmod_runtime_id}
          ${alarm_severity_list}=  Create List  critical
          vDU Assert Alarm Active
          ...  fault_id=10
          ...  alarming_object_list=${alarming_object_list}
          ...  alarm_severity_list=${alarm_severity_list}
          ...  timeout=30s
          ...  vdu_connection=${vdu_connection}
          Log  ${below_info_prefix}Alarm (FID:10, severity:Critical) on shared impacted SBTS radio module (sn: ${cbts_affected_rmod_sn}) is active
          ...  console=${log_to_console}
        END
      END
# Check shared impacted CBTS radio modules cells states
      IF  ${cbts_shared_rmod_impacted_cells_id_list}!=@{EMPTY}
        FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_shared_rmod_impacted_cells_id_list}
          Cell Wait For Expected States Or Statuses
           ...  cell_id=${cbts_rmod_impacted_cell_id}
           ...  state_status_dict=${cbts_impacted_cell_state_dict}
           ...  timeout=30s
           ...  vdu_connection=${vdu_connection}
        END
        Log  ${below_info_prefix}Shared impacted CBTS radio modules NRCELs status is OK  console=${log_to_console}
      END
    END
# Check if all SBTS radio modules are on line
    FOR  ${sbts_admin_rmod_sn}  IN  @{sbts_admin_rmod_sn_list}
      ${smod_rmod_internal_id}=  Get From Dictionary
      ...  dictionary=${smod_rmod_sn_internal_id_dict}
      ...  key=${sbts_admin_rmod_sn}
      admin.Assert
      ...  class_name=RMOD
      ...  id=${smod_rmod_internal_id}
      ...  parameters=${sbts_rmod_online_states}
      ...  timeout=300s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}All SBTS radio modules are on line  console=${log_to_console}
# BTS Procedural State should be OnAir
    Admin BTS Procedural State Should Be
    ...  state_value=OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}SBTS procedural state is onAir  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
    BTS SCFC And Admin Cells Count Should Match  scfc_file_path=${sbts_scfc_file_path}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: SBTS sharing site reset  console=${log_to_console}

Step 5: CBTS Sharing Postconditions vDU And Site Reset
    Log  ${dots_prefix_green}Step 5: CBTS postconditions radio modules reset  console=${log_to_console}
# Wait until all SBTS radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All SBTS radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=60s
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

Step 6: SBTS Sharing Postconditions vDU And Site Reset
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

# INTERNAL TEST CASE KEYWORDS
Get Radio Module Synchronization Link List
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the link of the radio modules is synchronization link
    ...  and returns a list of radio modules configuration ids.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_configuration_id_list}=  Create List
    ${bts_info}=  admin.Get Bts Info
    ${cablink_list}=  Set Variable  ${bts_info['cables']}
    FOR  ${cablink_item}  IN  @{cablink_list}
      IF  ${cablink_item['linkMode']['synchronization']}
        ${rmod_configuration_id}=  Set Variable  ${cablink_item['secondEndPointId']['configuration']}
        ${rmod_configuration_id}=  Fetch From Left  string=${rmod_configuration_id}  marker=/OPT
        Append To List  ${rmod_configuration_id_list}  ${rmod_configuration_id}
      END
    END
    [Return]  ${rmod_configuration_id_list}
