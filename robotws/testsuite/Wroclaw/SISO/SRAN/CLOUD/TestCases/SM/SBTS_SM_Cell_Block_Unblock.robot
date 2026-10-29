*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

Resource    ../../../resources/Robot/admin.robot
Resource    ../../../resources/bts_scfc.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Variables ***
@{BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=49, severity=Critical

*** Keywords ***
TC__SBTS_SM_Cell_Block_Unblock
    [Arguments]  ${sbts_scfc_file_path}  ${sbts_cells_id_list}=@{EMPTY}  ${get_kpi}=${False}
    ...  ${admin_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case blocks and unblocks cell based on cell id
    ...  given from scfc file or specified by the cell id list.
    ...  If the list of the cells id is empty then all cells are blocked/unblocked.
    ...
    ...  Step 1: SBTS Preconditions Block Unblock Cell
    ...  a) BTS procedural state should be OnAir
    ...  b) All cells should be OnAir
    ...  Step 2: SBTS Block Cell
    ...  a) Cell expected state: blocking_state = Blocked
    ...  b) Alarm (fault id=49) is active
    ...  c) Not impacted SBTS cells are OnAir
    ...  Step 3: SBTS Unblock Cell
    ...  a) Cell expected state: blocking_state = Unblocked
    ...  b) Alarm (fault id=49) is inactive.
    ...  c) All cells should be OnAir
    ...  Step 4: SBTS Postconditions Block Unblock Cell
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | sbts_scfc_file_path    | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | sbts_cells_id_list     |  No  | (optional) SBTS list of cell id to be blocked/unblocked.                   |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${sbts_scfc_file_path}
    Set Test Variable  ${sbts_cells_id_list}
    Set Test Variable  ${get_kpi}
    Set Test Variable  ${admin_connection}
    Set Test Variable  ${log_to_console}
    Log  \n${start_prefix_green}Test Case: SBTS_Cell_Block_Unblock  console=${log_to_console}
    Step 1: SBTS Preconditions Cell Block Unblock
    FOR  ${sbts_blocked_cell_id}  IN  @{sbts_blocked_cells_id_list}
       Set Test Variable  ${sbts_blocked_cell_id}
       Step 2: SBTS Block Cell
       Step 3: SBTS Unblock Cell
    END
    Step 4: SBTS Postconditions Block Unblock Cell
    Log  ${done_prefix_green}Test Case: SBTS_Cell_Block_Unblock  console=${log_to_console}

Step 1: SBTS Preconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 1: SBTS preconditions block unblock cell  console=${log_to_console}
    Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  @{BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
    Run Keyword If  not ${get_kpi}
    ...  Log  ${info_prefix}KPIs will not be calculated  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 1: SBTS preconditions block unblock cell  console=${log_to_console}

Step 2: SBTS Block Cell
    Log  ${dots_prefix_green}Step 2: SBTS block cell (LNCELL-${sbts_blocked_cell_id})  console=${log_to_console}
    ${blocked_lncel_id_list}=  Create List  ${sbts_blocked_cell_id}
    ${lcr_id}=  SCFC Get LcrId For LncelId  scfc_file_path=${sbts_scfc_file_path}  lncel_id=${sbts_blocked_cell_id}
# Local cell resource ID of the paired host LTE cell or NB-IoT cell (inband or guardband)
    ${lcr_id_list}=  Create List  ${lcr_id}
    ${nbiot_lcr_id_list}=  SCFC Create IoT Linked LcrId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${lcr_id_list}
    ${nbiot_lncel_id_list}=  SCFC Create LncelId List For LcrdId List
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id_list=${nbiot_lcr_id_list}
# Create blocked lncel distname list
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
# Create unblocked lncel distname list
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
# Check If dynamic spectrum sharing between LTE and NR is activated
    ${dss_nrcell_id}=  SCFC Get NrcellId For eNB LcrId After Dss Sharing Activation
    ...  scfc_file_path=${sbts_scfc_file_path}  lcr_id=${lcr_id}
    Set Test Variable  ${dss_nrcell_id}
# Block cell
    ${block_result}=  admin.Block Cell
    ...  dist_name=${blocked_lncel_distname_list[0]}
    ...  timeout=120
    ...  connection=${admin_connection}
# Check states and alarms
    FOR  ${blocked_lncel_distname}  IN  @{blocked_lncel_distname_list}
# Check states
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${blocked_lncel_distname}
      ...  parameters=blockingState=regex"(?i)Blocked"
      ...  connection=${admin_connection}
      ${lncel_params}=  admin.Get Parameters For
      ...  class_name=LNCEL
      ...  id_num=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Block cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}Cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) is ${lncel_params.blockingState}
      ...  console=${log_to_console}
# Check active alarms
      admin.Assert Alarm Active
      ...  parameters=faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Alarm (faultId:49) on cell (E-UTRAN cell id: ${lncel_params.eutraCelId}) is active
      ...  console=${log_to_console}
      IF  '${dss_nrcell_id}'!='${EMPTY}'
        ${dss_nrcell_distname}=  Run Keyword If  '${dss_nrcell_id}'!='${EMPTY}'
        admin.Get Cell Id By Configuration Id
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
        ...  connection=${admin_connection}
        Log  ${info_prefix}Alarm (faultId:7513|7511) on cell (NR cell id: NRCELL-${dds_fault_id}) is active
        Append To List  ${ALLOWED_HISTORICAL_ALARMS_FAULT_ID}  faultId=7513, severity=Major  faultId=7511, severity=Major
      END
    END
    Sleep  5s  reason=Waiting time before check no impact on other cells
# Check if not impacted SBTS cells are OnAir
    FOR  ${unblocked_lncel_distname}  IN  @{unblocked_lncel_distname_list}
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${unblocked_lncel_distname}
      ...  parameters=blockingState=regex"(?i)Unblocked"
      ...  connection=${admin_connection}
      ${lncel_params}=  admin.Get Parameters For
      ...  class_name=LNCEL
      ...  id_num=${unblocked_lncel_distname}
      ...  connection=${admin_connection}
    END
    Log  ${info_prefix}Not impacted cells are ${lncel_params.blockingState}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: SBTS block cell (LNCELL-${sbts_blocked_cell_id})  console=${log_to_console}

Step 3: SBTS Unblock Cell
    Log  ${dots_prefix_green}Step 3: SBTS unblock cell (LNCELL-${sbts_blocked_cell_id})  console=${log_to_console}
    Log  ${info_prefix}Wait a while for cell unblock ...  console=${log_to_console}
    Sleep  5s  reason=Waiting time before unlock cell
# Unblock cell
    admin.Unblock Cell
    ...  dist_name=${blocked_lncel_distname_list[0]}
    ...  timeout=120
    ...  connection=${admin_connection}
    FOR  ${blocked_lncel_distname}  IN  @{blocked_lncel_distname_list}
# Check states
      admin.Assert
      ...  class_name=LNCEL
      ...  id=${blocked_lncel_distname}
      ...  parameters=blockingState=regex"(?i)Unblocked"
      ...  connection=${admin_connection}
      ${lncel_params}=  admin.Get Parameters For
      ...  class_name=LNCEL
      ...  id_num=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Unblock cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}Cell (${lncel_params.technology}) (E-UTRAN cell id: ${lncel_params.eutraCelId}) is ${lncel_params.blockingState}
      ...  console=${log_to_console}
# Check inactive alarms
      admin.Assert Alarm Inactive
      ...  parameters=faultId=49, severity=Critical, faultName="Cell blocked", alarmingResource=${blocked_lncel_distname}
      ...  connection=${admin_connection}
      Log  ${info_prefix}Alarm (faultId:49) on cell (E-UTRAN cell id: ${lncel_params.eutraCelId}) is inactive
      ...  console=${log_to_console}
      IF  '${dss_nrcell_id}'!='${EMPTY}'
        admin.Assert Alarm Inactive
        ...  parameters=faultId=${dds_fault_id}, severity=Major, faultName=${dds_fault_name}, alarmingResource=${dss_nrcell_distname}
        ...  connection=${admin_connection}
        Log  ${info_prefix}Alarm (faultId:7513|7511) on cell (NR cell id: NRCELL-${dds_fault_id}) is inactive
      END
    END
    IF  ${get_kpi}
      Sleep  5s
      ${kpi_list}=  Create List  kpi17a  kpi17b
      ${kpi_dict}=  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
      Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 3: SBTS unblock cell (LNCELL-${sbts_blocked_cell_id})  console=${log_to_console}

Step 4: SBTS Postconditions Block Unblock Cell
    Log  ${dots_prefix_green}Step 4: SBTS postconditions block unblock cell  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: SBTS postconditions block unblock cell   console=${log_to_console}
