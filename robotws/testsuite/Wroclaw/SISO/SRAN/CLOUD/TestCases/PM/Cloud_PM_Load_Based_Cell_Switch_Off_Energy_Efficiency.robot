*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot

*** Variables ***
# Allowed test case historical alarms
@{VCU_CELL_SWITCH_OFF_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_PM_Load_Based_Cell_Switch_Off_Energy_Efficiency
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_cells_id_list}=@{EMPTY}
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FPB-1283157
    ...  Feature CB013026 brings parity to the list of energy saving functionalities when used with O-RU (RF8.0).
    ...  Feature: CB013026-C - Load-based Cell Switch Off Energy Efficiency (parity to 5GC000431, LTE1103, CB007416)
    ...  - actNrLBPowerSaving:
    ...    This parameter activates/deactivates NR load-based power saving feature.
    ...
    ...  Test case assumes that no "NRPGRP" objects exist.
    ...  If any "NRPGRP" objects exist, they will be deleted and a new "NRPGRP-0" object will be created.
    ...  During test case execution several parameters of the "NRPGRP-0" object will be updated.
    ...
    ...  Step 1: Preconditions Cell Switch Off Energy Efficiency
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Set Initial Parameters Cell Switch Off Energy Efficiency
    ...  a) Deactivating NR load-based power saving feature (actNrLBPowerSaving=false)
    ...  b) Removing existing NRPGRP objects
    ...  c) Creation of new NRPGRP-0 object
    ...  Step 3: Activate Load Based Power Saving Feature
    ...  a) Activating NR load-based power saving feature (actNrLBPowerSaving=true)
    ...  b) Setting the parameters of the energy saving period
    ...  c) Activating power saving period settings
    ...  Step 4: Check Switched Off Cells States
    ...  Step 5: Check Switched On Cells States
    ...  Step 6: Deactivate Load Based Power Saving Feature
    ...  a) Deactivating NR load-based power saving feature (actNrLBPowerSaving=false)
    ...  b) Removing NRPGRP-0 object
    ...  Step 7: Postconditions Cell Switch Off Energy Efficiency
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     | Yes  | List of cell ids that will be tested (switched-off).                       |
    ...  |                        |      | If list is set to @{EMPTY} then all cells will be tested (switched-off).   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_cells_id_list}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Load_Based_Cell_Switch_Off_Energy_Efficiency  console=${log_to_console}
    Step 1: Preconditions Cell Switch Off Energy Efficiency
    Step 2: Set Initial Parameters Cell Switch Off Energy Efficiency
    Step 3: Activate Load Based Power Saving Feature
    Step 4: Check Switched Off Cells States
    Step 5: Check Switched On Cells States
    Step 6: Deactivate Load Based Power Saving Feature
    Step 7: Postconditions Cell Switch Off Energy Efficiency
    Log  ${done_prefix_green}Test Case: Load_Based_Cell_Switch_Off_Energy_Efficiency  console=${log_to_console}
    [Teardown]  Cell Switch Off Energy Efficiency Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Preconditions Cell Switch Off Energy Efficiency
    Log  ${dots_prefix_green}Step 1: Preconditions cell switch-off energy efficiency  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_CELL_SWITCH_OFF_ALLOWED_HIST_ALARMS}
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
    ${nrbts_dist_name_list}=  Get Dist Names Current Plan Objects
    ...  class_name_list=NRBTS
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${nrbts_dist_name}  ${nrbts_dist_name_list[0]}
    ${vdu_scfc_nrcell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcell_id_list}
    ${cbts_nrpgrp_cells_id_list}=  Set Variable If  ${cbts_cells_id_list}==@{EMPTY}
    ...  ${vdu_scfc_nrcell_id_list}  ${cbts_cells_id_list}
    Set Test Variable  ${cbts_nrpgrp_cells_id_list}
# Cells states
    ${cbts_nrpgrp_cell_state_dict}=  Create Dictionary  availabilityStatus=off line
    ...  operationalState=disabled  administrativeState=Unlocked  energySavingState=energySaving
    Set Test Variable  ${cbts_nrpgrp_cell_state_dict}
    ${cbts_onair_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  energySavingState=notEnergySaving
    Set Test Variable  ${cbts_onair_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: Preconditions cell switch-off energy efficiency  console=${log_to_console}

Step 2: Set Initial Parameters Cell Switch Off Energy Efficiency
    Log  ${dots_prefix_green}Step 2: Set initial parameters cell switch-off energy efficiency  console=${log_to_console}
    Log  ${info_prefix}Initial parameters are checked and set  console=${log_to_console}
# Deactivating NR load-based power saving feature (actNrLBPowerSaving=false)
    ${actnrlbpowersaving_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${nrbts_dist_name}
    ...  para_name=actNrLBPowerSaving
    IF  '${actnrlbpowersaving_value}'=='true'
      Log  ${info_prefix}NR load-based power saving feature is deactivated. Please wait ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning
      ...  dist_name=${nrbts_dist_name}
      ...  parameter=actNrLBPowerSaving
      ...  operation=update
      ...  value=false
      ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ...  vdu_connection=${vdu_connection}
      Log  ${below_info_prefix}NR load-based power saving feature has been deactivated  console=${log_to_console}
    END
# Removing existing NRPGRP objects
    ${nrpgrp_dist_name_list}=  Get Dist Names Current Plan Objects
    ...  class_name_list=NRPGRP
    ...  vdu_connection=${vdu_connection}
    IF  ${nrpgrp_dist_name_list}!=@{EMPTY}
      Log  ${info_prefix}Existing NRPGRP objects are removed. Please wait ...  console=${log_to_console}
      Delete NRPGRP objects
      ...  nrpgrp_dist_name_list=${nrpgrp_dist_name_list}
      ...  vdu_connection=${vdu_connection}
      Log  ${below_info_prefix}Existing NRPGRP objects have been removed  console=${log_to_console}
    END
    Sleep  5s  reason=Wait for the NRPGRP-0 object to be created
# Creation of new NRPGRP-0 object
    Log  ${info_prefix}New NRPGRP-0 object is created. Please wait ...  console=${log_to_console}
    Create NRPGRP object
    ...  nrpgrp_dist_name=${nrbts_dist_name}/NRPGRP-0
    ...  cbts_cells_id_list=${cbts_nrpgrp_cells_id_list}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}New NRPGRP-0 object has been created  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Set initial parameters cell switch-off energy efficiency  console=${log_to_console}

Step 3: Activate Load Based Power Saving Feature
    Log  ${dots_prefix_green}Step 3: Activate load-based power saving feature  console=${log_to_console}
# Activating NR load-based power saving feature (actNrLBPowerSaving=true)
    Log  ${info_prefix}NR load-based power saving feature is activated. Please wait ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning
    ...  dist_name=${nrbts_dist_name}
    ...  parameter=actNrLBPowerSaving
    ...  operation=update
    ...  value=true
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}NR load-based power saving feature has been activated  console=${log_to_console}
# Setting the parameters of the energy saving period
    ${waiting_time}=  Set Variable  10
    Set Test Variable  ${waiting_time}
    ${hour}  ${minutes}  ${week_day}  ${hour_minutes}=  Get Power Saving Time Components  increment_time=${waiting_time}
    Log  ${info_prefix}Power saving period parameters:  console=${log_to_console}
    Log  ${below_info_prefix}lbpsDayOfWeek=${week_day}  console=${log_to_console}
    Log  ${below_info_prefix}lbpsStartTimeHour=${hour}  console=${log_to_console}
    Log  ${below_info_prefix}lbpsStartTimeMinute=${minutes}  console=${log_to_console}
# Creating lbpsPeriodList
    ${lbps_duration}=  Set Variable  30
    Set Test Variable  ${lbps_duration}
    ${lbps_period_structure_dict}=  Create Dictionary  lbpsDayOfWeek=${week_day}
    ...  lbpsDuration=${lbps_duration}  lbpsStartTimeHour=${hour}  lbpsStartTimeMinute=${minutes}
    ${lbps_period_list}=  Create List  ${lbps_period_structure_dict}
    ${lbps_period_dict}=  Create Dictionary  parameterName=lbpsPeriodList
    ...  operation=update  value=${lbps_period_list}
# Activating power saving period settings
    Log  ${info_prefix}Power saving period settings are activated. Please wait ...  console=${log_to_console}
    ${parameters_list}=  Create List  ${lbps_period_dict}
    vdu.Perform Object Recommissioning
    ...  dist_name=${nrbts_dist_name}/NRPGRP-0
    ...  parameter=${parameters_list}
    ...  operation=create
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Power saving period has been activated  console=${log_to_console}
    Log  ${info_prefix}The cells will start entering the "energySaving" state at ${week_day} ${hour_minutes}
    ...  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Activate load-based power saving feature  console=${log_to_console}

Step 4: Check Switched Off Cells States
    Log  ${dots_prefix_green}Step 4: Check switched off cells states  console=${log_to_console}
    Log  ${info_prefix}Waiting ${waiting_time} min for cells to start entering the "energySaving" state ...
    ...  console=${log_to_console}
    Sleep  ${waiting_time} min  reason=Waiting time for cells to start entering the "energySaving" state
    Set Test Variable  ${grace_period}  6 min
    Log  ${info_prefix}Waiting ${grace_period} for cells to switch-off ...  console=${log_to_console}
    FOR  ${nrpgrp_cell_id}  IN  @{cbts_nrpgrp_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${nrpgrp_cell_id}
      ...  state_status_dict=${cbts_nrpgrp_cell_state_dict}
      ...  timeout=${grace_period}
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}All NR power group cells are in power saving mode  console=${log_to_console}
# Check if not affected cells are OnAir
    Sleep  5s  reason=Waiting time before check no impact on other cells
    ${onair_cell_id_list}=  Copy List  ${vdu_scfc_nrcell_id_list}
    Remove Values From List  ${onair_cell_id_list}  @{cbts_nrpgrp_cells_id_list}
    FOR  ${onair_cell_id}  IN  @{onair_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${onair_cell_id}
      ...  state_status_dict=${cbts_onair_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    IF  ${onair_cell_id_list}!=@{EMPTY}
    ...  Log  ${info_prefix}All not NR power group cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check switched off cells states  console=${log_to_console}

Step 5: Check Switched On Cells States
    Log  ${dots_prefix_green}Step 5: Check switched on cells states  console=${log_to_console}
    Log  ${info_prefix}Waiting ${lbps_duration} min for cells to start coming out of "energy saving" state ...
    ...  console=${log_to_console}
    Sleep  ${lbps_duration} min  reason=Waiting time for cells to start coming out of "energySaving" state
    Log  ${info_prefix}Waiting ${grace_period} for cells to wake up ...  console=${log_to_console}
    FOR  ${nrpgrp_cell_id}  IN  @{cbts_nrpgrp_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${nrpgrp_cell_id}
      ...  state_status_dict=${cbts_onair_cell_state_dict}
      ...  timeout=${grace_period}
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}All NR power grou cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Check switched on cells states  console=${log_to_console}

Step 6: Deactivate Load Based Power Saving Feature
    Log  ${dots_prefix_green}Step 6: Deactivate load-based power saving feature  console=${log_to_console}
# Deactivating NR load-based power saving feature (actNrLBPowerSaving=false)
    Log  ${info_prefix}NR load-based power saving feature is deactivated. Please wait ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning
    ...  dist_name=${nrbts_dist_name}
    ...  parameter=actNrLBPowerSaving
    ...  operation=update
    ...  value=false
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}NR load-based power saving feature has been activated  console=${log_to_console}
# Removing NRPGRP-0 object
    Log  ${info_prefix}NRPGRP-0 object is removed. Please wait ...  console=${log_to_console}
    ${parameters_list}=  Create List
    vdu.Perform Object Recommissioning
    ...  dist_name=${nrbts_dist_name}/NRPGRP-0
    ...  parameter=${parameters_list}
    ...  operation=delete
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}NRPGRP-0 object has been removed  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Deactivate load-based power saving feature  console=${log_to_console}

Step 7: Postconditions Cell Switch Off Energy Efficiency
    Log  ${dots_prefix_green}Step 7: Postconditions cell switch-off energy efficiency  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 7: Postconditions cell switch-off energy efficiency  console=${log_to_console}

# INTERNAL TEST CASE KEYWORDS
Delete NRPGRP objects
    [Arguments]  ${nrpgrp_dist_name_list}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword deletes all existing NRPGRP objects based on a list of dist names.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrpgrp_dist_name_list  |  Yes | List of all NRPGRP object dist names.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${parameters_list}=  Create List
    FOR  ${nrpgrp_dist_name}  IN  @{nrpgrp_dist_name_list}
      vdu.Perform Object Recommissioning
      ...  dist_name=${nrpgrp_dist_name}
      ...  parameter=${parameters_list}
      ...  operation=delete
      ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ...  vdu_connection=${vdu_connection}
      Sleep  5s  reason=Wait for the next object to be removed
    END

Create NRPGRP object
    [Arguments]  ${nrpgrp_dist_name}  ${cbts_cells_id_list}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword creates a new NRPGRP-0 object.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrpgrp_dist_name       |  Yes | NRPGRP-0 object dist name.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     |  Yes | List of cell ids that will be tested (switched-off).                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# Creating lbpsCellList
    ${lbps_so_method_dict}=  Create Dictionary  parameterName=lbpsSOMethod
    ...  operation=update  value=cell switch off
    ${lbps_suspended_dict}=  Create Dictionary  parameterName=lbpsSuspended
    ...  operation=update  value=notSuspended
    ${lbps_min_load_dict}=  Create Dictionary  parameterName=lbpsMinLoad
    ...  operation=update  value=20
    ${lbps_max_load_dict}=  Create Dictionary  parameterName=lbpsMaxLoad
    ...  operation=update  value=60
    ${lbps_last_cell_so_enabled_dict}=  Create Dictionary  parameterName=lbpsLastCellSOEnabled
    ...  operation=update  value=true
    ${lbps_cell_list}=  Create List
    FOR  ${cbts_cell_id}  IN  @{cbts_cells_id_list}
      ${lbps_cell_structure_dict}=  Create Dictionary  lbpsCellSOOrder=100
      ...  lbpsUseExtConfig=false  nrCellId=${cbts_cell_id}
      Append To List  ${lbps_cell_list}  ${lbps_cell_structure_dict}
    END
    ${lbps_cell_dict}=  Create Dictionary  parameterName=lbpsCellList
    ...  operation=update  value=${lbps_cell_list}
# Create lbpsPeriodList
    ${lbps_period_structure_dict}=  Create Dictionary  lbpsDayOfWeek=Mon
    ...  lbpsDuration=10  lbpsStartTimeHour=10  lbpsStartTimeMinute=10
    ${lbps_period_list}=  Create List  ${lbps_period_structure_dict}
    ${lbps_period_dict}=  Create Dictionary  parameterName=lbpsPeriodList
    ...  operation=update  value=${lbps_period_list}
# Perform object recommissioning
    ${parameters_list}=  Create List  ${lbps_so_method_dict}  ${lbps_suspended_dict}  ${lbps_last_cell_so_enabled_dict}
    ...  ${lbps_min_load_dict}  ${lbps_max_load_dict}  ${lbps_cell_dict}  ${lbps_period_dict}
    vdu.Perform Object Recommissioning
    ...  dist_name=${nrpgrp_dist_name}
    ...  parameter=${parameters_list}
    ...  operation=create
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}

Get Power Saving Time Components
    [Arguments]  ${increment_time}=10
    [Documentation]
    ...  Description:

    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | increment_time       |  Yes | Time that will be added to the current time (in minutes).                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${time_diff}=  Get Container And Host Time Difference
    ${increment_time}=  Evaluate  expression=${increment_time}+(${time_diff}*60)
    ${current_time}=  Get Current Date  result_format=%H:%M  increment=${increment_time} minutes
    ${current_day}=  Get Current Date  result_format=%A  increment=${increment_time} minutes
    ${hour}=  Convert To Integer  item=${current_time.split(':')[0]}
    ${minutes}=  Convert To Integer  item=${current_time.split(':')[1]}
    ${short_day}=  Set Variable  ${current_day[:3]}
    [Return]  ${hour}  ${minutes}  ${short_day}  ${current_time}

Cell Switch Off Energy Efficiency Teardown
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
# Deactivating NR load-based power saving feature (actNrLBPowerSaving=false)
      ${actnrlbpowersaving_value}=  vdu.Search Parameter Of Current Plan
      ...  mo_dn=${nrbts_dist_name}
      ...  para_name=actNrLBPowerSaving
      IF  '${actnrlbpowersaving_value}'=='true'
        Log  ${info_prefix}NR load-based power saving feature is deactivated. Please wait ...  console=${log_to_console}
        vdu.Perform Parameter Recommissioning
        ...  dist_name=${nrbts_dist_name}
        ...  parameter=actNrLBPowerSaving
        ...  operation=update
        ...  value=false
        ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}NR load-based power saving feature has been deactivated  console=${log_to_console}
      END
# Removing existing NRPGRP objects
      ${nrpgrp_dist_name_list}=  Get Dist Names Current Plan Objects
      ...  class_name_list=NRPGRP
      ...  vdu_connection=${vdu_connection}
      IF  ${nrpgrp_dist_name_list}!=@{EMPTY}
        Log  ${info_prefix}Existing NRPGRP objects are removed. Please wait ...  console=${log_to_console}
        Delete NRPGRP objects
        ...  nrpgrp_dist_name_list=${nrpgrp_dist_name_list}
        ...  vdu_connection=${vdu_connection}
        Log  ${below_info_prefix}Existing NRPGRP objects have been removed  console=${log_to_console}
      END
    END
    Run Keyword And Ignore Error  vDU Rest Logout
