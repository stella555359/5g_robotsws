*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.sbts.oam.coam.admin.interface    WITH NAME    admin

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/bts_scfc.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/admin.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Variables ***
# Maximum waiting time for cell to be blocked
${CELL_BLOCK_MAX_WAIT_TIME}=    200s
# Maximum waiting time for cell to be unblocked
${CELL_UNBLOCK_MAX_WAIT_TIME}=  200s
# Allowed test case historical alarms
@{VDU_SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=49, severity=critical
@{VCU_SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
@{SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=49, severity=Critical

*** Keywords ***
TC__Cloud_SBTS_CM_Cell_Block_Unblock
    [Arguments]  ${vdu_scfc_file_path}  ${sbts_scfc_file_path}  ${cbts_cells_id_list}=@{EMPTY}
    ...  ${sbts_cells_id_list}=@{EMPTY}  ${get_kpi}=${False}  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}
    ...  ${admin_connection}=${ADMIN_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case blocks and unblocks cell based on cell id
    ...  given from scfc file or specified by the cell id list.
    ...  If the list of the cells id is empty then all cells are blocked/unblocked.
    ...  Test supports RF sharing SBTS-CBTS configuration.
    ...  Test case supports:
    ...  - CBTS side: NR cells
    ...  - SBTS side: LTE cells
    ...  SCF file should contain the serial numbers of the radio modules.
    ...
    ...  Step 1: CBTS Sharing Preconditions Block Unblock Cell
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: SBTS Sharing Preconditions Block Unblock Cell
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 3: CBTS Sharing Cell Block
    ...  a) Block CBTS cell
    ...  b) Check blocked cell expected state
    ...  c) Check blocked CBTS cell other states
    ...  d) Check if alarm (fault id=49) is active
    ...  e) Check if not blocked CBTS cells are OnAir
    ...  f) Check if all SBTS cells are OnAir
    ...  Step 4: CBTS Sharing Cell Unblock
    ...  a) Unblock CBTS cell
    ...  b) Check unblocked CBTS cell expected state
    ...  c) Check unblocked CBTS cell other states
    ...  d) Check if alarm (fault id=49) is inactive
    ...  e) Check if all CBTS cells are OnAir
    ...  f) Get Kpi values
    ...  Step 5: SBTS Sharing Cell Block
    ...  a) Block SBTS cell
    ...  b) Check SBTS blocked cell states
    ...  c) Check blocked SBTS cell other states
    ...  d) Check active alarms
    ...  e) Check if not blocked SBTS cells are OnAir
    ...  f) Check if all SBTS cells are OnAir
    ...  Step 6: SBTS Sharing Cell Unblock
    ...  a) Unblock SBTS cell
    ...  b) Check unblocked SBTS cells states
    ...  d) Check inactive alarms
    ...  e) Check if all SBTS cells are OnAir
    ...  f) Get Kpi values
    ...  Step 7: CBTS Sharing Postconditions Block Unblock Cell
    ...  a) The same values as in Step 1
    ...  Step 8: SBTS Sharing Postconditions Block Unblock Cell
    ...  a) The same values as in Step 2
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_scfc_file_path    | Yes  | Path to the SBTS scfc file.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     |  No  | (optional) CBTS list of cell id to be blocked/unblocked.                   |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_cells_id_list     |  No  | (optional) SBTS list of cell id to be blocked/unblocked.                   |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
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
    Set Test Variable  ${cbts_cells_id_list}
    Set Test Variable  ${sbts_cells_id_list}
    Set Test Variable  ${get_kpi}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_SBTS_Cell_Block_Unblock  console=${log_to_console}
    Step 1: CBTS Sharing Preconditions Cell Block Unblock
    Step 2: SBTS Sharing Preconditions Cell Block Unblock
    FOR  ${cbts_blocked_cell_id}  IN  @{cbts_blocked_cells_id_list}
       Set Test Variable  ${cbts_blocked_cell_id}
       Step 3: CBTS Sharing Cell Block
       Step 4: CBTS Sharing Cell Unblock
    END
    FOR  ${sbts_blocked_cell_id}  IN  @{sbts_blocked_cells_id_list}
       Set Test Variable  ${sbts_blocked_cell_id}
       Step 5: SBTS Sharing Cell Block
       Step 6: SBTS Sharing Cell Unblock
    END
    Step 7: CBTS Sharing Postconditions Cell Block Unblock
    Step 8: SBTS Sharing Postconditions Cell Block Unblock
    Log  ${done_prefix_green}Test Case: CBTS_SBTS_Cell_Block_Unblock  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Sharing Preconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 1: CBTS preconditions cell block unblock  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
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
    ${vdu_cells_id_dist_name_dict}=  vDU Cells Get Ids And Given Parameters Value
    ...  cell_param=dist_names
    ...  cell_sub_param=config
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_dist_name_dict}
    ${vdu_cells_id_identity_dict}=  vDU Cells Get Identity And Id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_identity_dict}
    ${vdu_scfc_nrcell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcell_id_list}
    ${cbts_blocked_cells_id_list}=  Set Variable If  ${cbts_cells_id_list}==@{EMPTY}
    ...  ${vdu_scfc_nrcell_id_list}  ${cbts_cells_id_list}
    Set Test Variable  ${cbts_blocked_cells_id_list}
# Set cells states
    ${cbts_blocked_cell_state_dict}=  Create Dictionary  availabilityStatus=off line
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Blocked
    Set Test Variable  ${cbts_blocked_cell_state_dict}
    ${cbts_unblocked_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unblocked_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions cell block unblock  console=${log_to_console}

Step 2: SBTS Sharing Preconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 2: SBTS preconditions cell block unblock  console=${log_to_console}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{SBTS_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
    Run Keyword If  not ${get_kpi}
    ...  Log  ${info_prefix}KPIs will not be calculated  console=${log_to_console}
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
# Get and set variables
    BTS SCFC And Admin Cells Count Should Match
    ...  scfc_file_path=${sbts_scfc_file_path}
    ...  admin_connection=${admin_connection}
    ${sbts_scfc_lcr_id_list}=  SCFC Create Not IoT Inband And Guardband LcrId List
    ...  scfc_file_path=${sbts_scfc_file_path}
    ${sbts_scfc_lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${sbts_scfc_lcr_id_list}
    Set Test Variable  ${sbts_scfc_lncel_id_list}
    ${sbts_blocked_cells_id_list}=  Set Variable If  ${sbts_cells_id_list}==@{EMPTY}
    ...  ${sbts_scfc_lncel_id_list}  ${sbts_cells_id_list}
    Set Test Variable  ${sbts_blocked_cells_id_list}
# Set cells states
    ${sbts_blocked_cell_states_1}=  Set Variable  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled"
    ${sbts_blocked_cell_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)blocked"
    ${sbts_blocked_cell_states}=  Set Variable  ${sbts_blocked_cell_states_1}, ${sbts_blocked_cell_states_2}
    Set Test Variable  ${sbts_blocked_cell_states}
    ${sbts_unblocked_cell_states_1}=  Set Variable  operationalState=regex"(?i)enabled"
    ${sbts_unblocked_cell_states_2}=  Set Variable  administrativeState=regex"(?i)unlocked", blockingState=regex"(?i)unblocked"
    ${sbts_unblocked_cell_states}=  Set Variable  ${sbts_unblocked_cell_states_1}, ${sbts_unblocked_cell_states_2}
    Set Test Variable  ${sbts_unblocked_cell_states}
    Log  ${ok_prefix_green}Step 2: SBTS preconditions cell block unblock  console=${log_to_console}

Step 3: CBTS Sharing Cell Block
    Log  ${dots_prefix_green}Step 3: CBTS cell (NRCELL-${cbts_blocked_cell_id}) block  console=${log_to_console}
# Block CBTS cell
    ${time_vdu_block_cell_start}=  Get Time  time_=UTC
    vDU Block Cell And Check
    ...  cell_id=${cbts_blocked_cell_id}
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Block CBTS cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) operation succeeded
    ...  console=${log_to_console}
# Check blocked CBTS cell expected state
    Cell Wait For Expected State
    ...  cell_id=${cbts_blocked_cell_id}
    ...  cell_state=blocking_state
    ...  cell_state_value=Blocked
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    ${time_vdu_block_cell_end}=  Get Time  time_=UTC
    Log  ${info_prefix}Cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is blocked
    ...  console=${log_to_console}
# Check blocked CBTS cell other states
    Cell Wait For Expected States Or Statuses
    ...  cell_id=${cbts_blocked_cell_id}
    ...  state_status_dict=${cbts_blocked_cell_state_dict}
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  time_interval=5s
    ...  vdu_connection=${vdu_connection}
# Check if alarm (fault id=49) is active
    ${alarm_severity_list}=  Create List  Critical
    Set Test Variable  ${alarm_severity_list}
    ${cbts_blocked_cell_config_dist_name}=  Get From Dictionary
    ...  dictionary=${vdu_cells_id_dist_name_dict}  key=${cbts_blocked_cell_id}
    ${alarming_object_list}=  Create List  ${cbts_blocked_cell_config_dist_name}
    Set Test Variable  ${alarming_object_list}
    vDU Assert Alarm Active
    ...  fault_id=49
    ...  alarming_object_list=${alarming_object_list}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (faultId:49) on CBTS cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is active
    ...  console=${log_to_console}
# Check if not blocked CBTS cells are OnAir
    Sleep  5s  reason=Waiting time before check no impact on other cells
    ${unblocked_cbts_cell_id_list}=  Copy List  ${vdu_scfc_nrcell_id_list}
    Remove Values From List  ${unblocked_cbts_cell_id_list}  ${cbts_blocked_cell_id}
    FOR  ${unblocked_cbts_cell_id}  IN  @{unblocked_cbts_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unblocked_cbts_cell_id}
      ...  state_status_dict=${cbts_unblocked_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not blocked CBTS cells are OnAir  console=${log_to_console}
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
    ${vdu_cell_kpi_17a}=  Subtract Date From Date  date1=${time_vdu_block_cell_end}  date2=${time_vdu_block_cell_start}
    Set Test Variable  ${vdu_cell_kpi_17a}
    Log  ${ok_prefix_green}Step 3: CBTS cell (NRCELL-${cbts_blocked_cell_id}) block  console=${log_to_console}

Step 4: CBTS Sharing Cell Unblock
    Log  ${dots_prefix_green}Step 4: CBTS cell (NRCELL-${cbts_blocked_cell_id}) unblock  console=${log_to_console}
# Unblock CBTS cell
    Log  ${info_prefix}Wait a while for CBTS cell unblock ...  console=${log_to_console}
    Sleep  5s  reason=Waiting time before unlock cell
    ${time_vdu_unblock_cell_start}=  Get Time  time_=UTC
    vDU Unblock Cell And Check
    ...  cell_id=${cbts_blocked_cell_id}
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
# Check unblocked CBTS cell expected state
    Cell Wait For Expected State
    ...  cell_id=${cbts_blocked_cell_id}
    ...  cell_state=blocking_state
    ...  cell_state_value=Unblocked
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    ${time_vdu_unblock_cell_end}=  Get Time  time_=UTC
    Log  ${info_prefix}Unblock CBTS cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) operation succeeded
    ...  console=${log_to_console}
# Check unblocked CBTS cell other states
    Cell Wait For Expected States Or Statuses
    ...  cell_id=${cbts_blocked_cell_id}
    ...  state_status_dict=${cbts_unblocked_cell_state_dict}
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=5s
    ...  vdu_connection=${vdu_connection}
# Check if alarm (fault id=49) is inactive
    vDU Assert Alarm Inactive
    ...  fault_id=49
    ...  alarming_object_list=${alarming_object_list}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (faultId:49) on CBTS cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is inactive
    ...  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
# Get KPI values
    IF  ${get_kpi}
      Log  ${info_prefix}KPI values for CBTS cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}):
      ...  console=${log_to_console}
      ${vdu_cell_kpi_17b}=  Subtract Date From Date  date1=${time_vdu_unblock_cell_end}  date2=${time_vdu_unblock_cell_start}
      Log  ${below_info_prefix}KPI 17a: ${vdu_cell_kpi_17a}  console=${log_to_console}
      Log  ${below_info_prefix}KPI 17b: ${vdu_cell_kpi_17b}  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 4: CBTS cell (NRCELL-${cbts_blocked_cell_id}) unblock  console=${log_to_console}

Step 5: SBTS Sharing Cell Block
    Log  ${dots_prefix_green}Step 5: SBTS cell (LNCELL-${sbts_blocked_cell_id}) block  console=${log_to_console}
    ${blocked_lncel_id_list}=  Create List  ${sbts_blocked_cell_id}
    ${lcr_id}=  SCFC Get LcrId For LncelId  scfc_file_path=${sbts_scfc_file_path}  lncel_id=${sbts_blocked_cell_id}
# Local cell resource ID of the paired host LTE cell or NB-IoT cell (inband or guardband)
    ${lcr_id_list}=  Create List  ${lcr_id}
    ${nbiot_lcr_id_list}=  SCFC Create IoT Linked LcrId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${nbiot_lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${nbiot_lcr_id_list}
# Create blocked SBTS lncel distname list
    Append To List  ${blocked_lncel_id_list}  @{nbiot_lncel_id_list}
    Set Test Variable  ${blocked_lncel_id_list}
    ${blocked_lncel_distname_list}=  Create List
    Set Test Variable  ${blocked_lncel_distname_list}
    FOR  ${blocked_lncel_id}  IN  @{blocked_lncel_id_list}
      ${blocked_lncel_distname}=  admin.Get Cell Id By Configuration Id
      ...  rat=LTE
      ...  configuration_id=${blocked_lncel_id}
      ...  connection=${admin_connection}
      Append To List  ${blocked_lncel_distname_list}  ${blocked_lncel_distname}
    END
# Create unblocked SBTS lncel distname list
    ${unblocked_lncel_id_list}=  Copy List  ${sbts_scfc_lncel_id_list}
    Remove Values From List  ${unblocked_lncel_id_list}  @{blocked_lncel_id_list}
    ${unblocked_lncel_distname_list}=  Create List
    FOR  ${unblocked_lncel_id}  IN  @{unblocked_lncel_id_list}
      ${unblocked_lncel_distname}=  admin.Get Cell Id By Configuration Id
      ...  rat=LTE
      ...  configuration_id=${unblocked_lncel_id}
      ...  connection=${admin_connection}
      Append To List  ${unblocked_lncel_distname_list}  ${unblocked_lncel_distname}
    END
# Check if dynamic spectrum sharing between LTE and NR is activated
    ${dss_nrcell_id}=  SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id=${lcr_id}
    Set Test Variable  ${dss_nrcell_id}
# Block SBTS cell
    ${block_result}=  admin.Block Cell
    ...  dist_name=${blocked_lncel_distname_list[0]}
    ...  timeout=120
    ...  connection=${admin_connection}
# Check states and alarms
    FOR  ${blocked_lncel_distname}  IN  @{blocked_lncel_distname_list}
# Check SBTS blocked cell states
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${blocked_lncel_distname}
      ...  parameters=${sbts_blocked_cell_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
      ${lncel_params}=  admin.Get Parameters For
      ...  class_name=LNCEL
      ...  id_num=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Block SBTS cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}SBTS cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) is ${lncel_params.blockingState}
      ...  console=${log_to_console}
# Check active alarms
      admin.Assert Alarm Active
      ...  parameters=faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${blocked_lncel_distname}
      ...  timeout=60s
      ...  connection=${admin_connection}
      Log  ${info_prefix}Alarm (faultId:49) on SBTS cell (E-UTRAN cell id: ${lncel_params.eutraCelId}) is active
      ...  console=${log_to_console}
      IF  '${dss_nrcell_id}'!='${EMPTY}'
        ${dss_nrcell_distname}=  Run Keyword If  '${dss_nrcell_id}'!='${EMPTY}'
        ...  admin.Get Cell Id By Configuration Id
        ...  rat=NR
        ...  configuration_id=${dss_nrcell_id}
        ...  connection=${admin_connection}
        Set Test Variable  ${dss_nrcell_distname}
        ${dds_fault_id}=  Set Variable  regex"7513|7511"
        Set Test Variable  ${dds_fault_id}
        ${dds_fault_name}=  Set Variable  regex"EN DSS De-activated on partner side|EN DSS Keep Alive Procedure Time out"
        Set Test Variable  ${dds_fault_name}
        admin.Assert Alarm Active
        ...  parameters=faultId=${dds_fault_id}, severity=Major, faultName=${dds_fault_name}, alarmingResource=${dss_nrcell_distname}
        ...  timeout=60s
        ...  connection=${admin_connection}
        Log  ${info_prefix}Alarm (faultId:7513|7511) on SBTS cell (NR cell id: NRCELL-${dds_fault_id}) is active
        Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  faultId=7513, severity=Major  faultId=7511, severity=Major
      END
    END
    Sleep  5s  reason=Waiting time before check no impact on other cells
# Check if not blocked SBTS cells are OnAir
    FOR  ${unblocked_lncel_distname}  IN  @{unblocked_lncel_distname_list}
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${unblocked_lncel_distname}
      ...  parameters=${sbts_unblocked_cell_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not blocked SBTS cells are OnAir  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All CBTS cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: SBTS block cell (LNCELL-${sbts_blocked_cell_id})  console=${log_to_console}

Step 6: SBTS Sharing Cell Unblock
    Log  ${dots_prefix_green}Step 6: SBTS cell (LNCELL-${sbts_blocked_cell_id}) unblock  console=${log_to_console}
    Log  ${info_prefix}Wait a while for SBTS cell unblock ...  console=${log_to_console}
    Sleep  5s  reason=Waiting time before unlock cell
# Unblock SBTS cell
    ${unblock_result}=  admin.Unblock Cell
    ...  dist_name=${blocked_lncel_distname_list[0]}
    ...  timeout=120
    ...  connection=${admin_connection}
    FOR  ${blocked_lncel_distname}  IN  @{blocked_lncel_distname_list}
# Check unblocked SBTS cell states
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${blocked_lncel_distname}
      ...  parameters=${sbts_unblocked_cell_states}
      ...  timeout=10s
      ...  connection=${admin_connection}
      ${lncel_params}=  admin.Get Parameters For
      ...  class_name=LNCEL
      ...  id_num=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Unblock SBTS cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}SBTS cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) is ${lncel_params.blockingState}
      ...  console=${log_to_console}
# Check inactive alarms
      admin.Assert Alarm Inactive
      ...  parameters=faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${blocked_lncel_distname}
      ...  timeout=60s
      ...  connection=${admin_connection}
      Log  ${info_prefix}Alarm (faultId:49) on SBTS cell (E-UTRAN cell id: ${lncel_params.eutraCelId}) is inactive
      ...  console=${log_to_console}
      IF  '${dss_nrcell_id}'!='${EMPTY}'
        admin.Assert Alarm Inactive
        ...  parameters=faultId=${dds_fault_id}, severity=Major, faultName=${dds_fault_name}, alarmingResource=${dss_nrcell_distname}
        ...  timeout=60s
        ...  connection=${admin_connection}
        Log  ${info_prefix}Alarm (faultId:7513|7511) on SBTS cell (NR cell id: NRCELL-${dds_fault_id}) is inactive
      END
    END
# Check if all SBTS cells are OnAir
    Admin Check Cells State When BTS OnAir
    ...  timeout=30s
    ...  admin_connection=${admin_connection}
    Log  ${info_prefix}All SBTS cells are OnAir  console=${log_to_console}
# Get KPI values
    IF  ${get_kpi}
      Sleep  5s
      ${kpi_list}=  Create List  kpi17a  kpi17b
      ${kpi_dict}=  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
      Log  ${info_prefix}KPI values for SBTS cell (E-UTRAN cell id: ${lncel_params.eutraCelId}):
      Log  ${below_info_prefix}KPI 17a: ${kpi_dict['kpi17a']}  console=${log_to_console}
      Log  ${below_info_prefix}KPI 17b: ${kpi_dict['kpi17b']}  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 6: SBTS cell (LNCELL-${sbts_blocked_cell_id}) unblock  console=${log_to_console}

Step 7: CBTS Sharing Postconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 7: SBTS postconditions cell block unblock  console=${log_to_console}
# Wait Until all radio modules are on line
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
    Log  ${ok_prefix_green}Step 7: SBTS postconditions cell block unblock  console=${log_to_console}

Step 8: SBTS Sharing Postconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 8: SBTS postconditions cell block unblock  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 8: SBTS postconditions cell block unblock  console=${log_to_console}
