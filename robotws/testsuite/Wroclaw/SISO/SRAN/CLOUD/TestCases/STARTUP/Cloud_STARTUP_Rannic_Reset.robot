*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot

*** Variables ***
${VDU_RANNIC_RESET_CELLS_ONAIR_TIMEOUT}=  500s
@{VDU_RANNIC_RESET_ALLOWED_HIST_ALARMS}=  faultId=4405, severity=minor
                                     ...  faultId=4298, severity=major
                                     ...  faultId=16, severity=critical
@{VCU_RANNIC_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_STARTUP_Rannic_Reset
    [Arguments]  ${scfc_file_path}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case performs RAN NICs reset.
    ...  First test case restarts all cards, then checks the states of RAN NICs, radio modules, cells and VDU.
    ...  Next (in case of more than one RAN NIC) test case restarts all cards one by one,
    ...  then checks the states of RAN NICs, radio modules, cells and VDU.
    ...  All RAN NICs should be correctly added to the test line configuration file __init__.py.
    ...  __init__.py minimum one RAN NIC configuration:
    ...  _rannic_0 = RANNIC(
    ...  serial_number="L1234567890",
    ...  rus=[],
    ...  )
    ...
    ...  Step 1: Initial Check Rannic Reset
    ...  a) RAN NIC expected states:
    ...                         operational_state = enabled
    ...                         availability_status = on line
    ...  b) Radio modules expected states:
    ...                         administrativeState = unlocked
    ...                         operationalState = enabled
    ...                         availabilityStatus = on line
    ...  c) Cells expected states:
    ...                         operationalState = enabled
    ...                         administrativeState = unlocked
    ...                         availabilityStatus = on line
    ...  d) vDU expected state:
    ...                        operationalState = onAir
    ...  Step 2: Reset All Rannics
    ...  a) RAN NIC operation reset status: success
    ...  b) RAN NIC expected states:
    ...                         operational_state = disabled
    ...                         availability_status = off line
    ...  Step 3: Check Bts States
    ...  The same values as in Step 1
    ...
    ...  Step 4 and Step 5 are performed in the loop of more than one RAN NIC
    ...  Step 4: Reset One Rannic
    ...  a) RAN NIC operation reset status: success
    ...  b) One RAN NIC expected states:
    ...                         operational_state = disabled
    ...                         availability_status = off line
    ...  c) Rest RAN NIC expected states:
    ...                         operational_state = enabled
    ...                         availability_status = on line
    ...  Step 5: Check Bts States
    ...  The same values as in Step 1
    ...  Step 6: Postconditions Rannic Reset
    ...  The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Rannic_Reset  console=${log_to_console}
    Step 1: Initial Check Rannic Reset
    Step 2: Reset All Rannics
    Step 3: Check Bts States
    IF  ${rannics_init_number}>1
      FOR  ${rannics_sn}  IN  @{rannics_sn_list}
        Set Test Variable  ${rannics_sn}
        Step 4: Reset One Rannic
        Step 5: Check Bts States
      END
    END
    Step 6: Postconditions Rannic Reset
    Log  ${done_prefix_green}Test Case: Rannic_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Initial Check Rannic Reset
    Log  ${dots_prefix_green}Step 1: Initial check rannic reset  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_RANNIC_RESET_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RANNIC_RESET_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# Check RAN NICs state and status
    ${rannics_init_number}=   Get Rannic Number From Init File
    Set Test Variable  ${rannics_init_number}
    ${rannics_init_sn_list}=  Get Rannic Serial Numbers From Init File
    Set Test Variable  ${rannics_init_sn_list}
    vDU Wait Until Rannics Are Online
    ...  rannics_sn_list=${rannics_init_sn_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs are on line  console=${log_to_console}
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
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
    Log  ${ok_prefix_green}Step 1: Initial check rannic reset  console=${log_to_console}

Step 2: Reset All Rannics
    Log  ${dots_prefix_green}Step 2: Reset all RAN NICs  console=${log_to_console}
    ${rannics_dict}=  vDU Rannics Get Serial Numbers And Given Parameters Value
    ...  rannic_param=r_nic_mod_dist_name
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${rannics_dict}
    ${rannics_sn_list}=  Get Dictionary Keys  dictionary=${rannics_dict}
    Set Test Variable  ${rannics_sn_list}
# Reset all RAN NICs check reset operation status
    Log  ${info_prefix}All RAN NICs are now reset ...  console=${log_to_console}
    FOR  ${rannics_sn}  IN  @{rannics_sn_list}
      ${rannics_dn}=  Get From Dictionary  dictionary=${rannics_dict}  key=${rannics_sn}
      ${reset_result}=  vdu.Reset Rannic
      ...  rannic_r_dn=${rannics_dn}
      ...  timeout=60s
      ...  vdu_connection=${vdu_connection}
      ${operation_id}=  Set Variable  ${reset_result['id']}
      vDU Rannic Reset Wait For Expected Status
      ...  operation_id=${operation_id}
      ...  expected_status=success
      ...  timeout=180s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}RAN NIC (sn: ${rannics_sn}) reset operation status: success  console=${log_to_console}
      vdu.Delete Rnic Rest Operation
      ...  operation_id=${operation_id}
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}All RAN NICs have been reset  console=${log_to_console}
# Check RAN NICs state and status
    Log  ${info_prefix}Waiting for all RAN NICs to be off line ...  console=${log_to_console}
    vDU Wait Until Rannics Are Offline
    ...  rannics_sn_list=${rannics_init_sn_list}
    ...  timeout=180s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs are off line  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2:Reset all RAN NICs  console=${log_to_console}

Step 3: Check Bts States
    Log  ${dots_prefix_green}Step 3: Check BTS states  console=${log_to_console}
# Check rannic state and status
    Log  ${info_prefix}Waiting for all RAN NICs to be on line ...  console=${log_to_console}
    vDU Wait Until Rannics Are Online
    ...  rannics_sn_list=${rannics_init_sn_list}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs are on line  console=${log_to_console}
# Wait Until all radio modules are on line
    Log  ${info_prefix}Waiting for all radio modules to be on line ...  console=${log_to_console}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=360s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Log  ${info_prefix}Waiting for all cells to be OnAir ...  console=${log_to_console}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${VDU_RANNIC_RESET_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Check BTS states  console=${log_to_console}

# Step 4 and Step 5 are performed in the loop of more than one RAN NIC
Step 4: Reset One Rannic
    Log  ${dots_prefix_green}Step 4: Reset one RAN NIC  console=${log_to_console}
# Reset RAN NIC and check reset operation status
    Log  ${info_prefix}RAN NIC (sn: ${rannics_sn}) is now reset ...  console=${log_to_console}
    ${rannics_dn}=  Get From Dictionary  dictionary=${rannics_dict}  key=${rannics_sn}
    ${reset_result}=  vdu.Reset Rannic
    ...  rannic_r_dn=${rannics_dn}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    ${operation_id}=  Set Variable  ${reset_result['id']}
    vDU Rannic Reset Wait For Expected Status
    ...  operation_id=${operation_id}
    ...  expected_status=success
    ...  timeout=180s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}RAN NIC (sn: ${rannics_sn}) reset operation status: success  console=${log_to_console}
    vdu.Delete Rnic Rest Operation
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NIC (sn: ${rannics_sn}) has been reset  console=${log_to_console}
# Check RAN NICs state and status
    Log  ${info_prefix}Waiting for RAN NIC (sn: ${rannics_sn}) to be off line ...  console=${log_to_console}
    ${one_rannic_sn_list}=  Create List  ${rannics_sn}
    vDU Wait Until Rannics Are Offline
    ...  rannics_sn_list=${one_rannic_sn_list}
    ...  timeout=180s
    ...  vdu_connection=${vdu_connection}
    ${rest_rannics_sn_list}=  Copy List  ${rannics_init_sn_list}
    Remove Values From List  ${rest_rannics_sn_list}  ${rannics_sn}
    vDU Wait Until Rannics Are Online
    ...  rannics_sn_list=${rest_rannics_sn_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs except one (sn: ${rannics_sn}) are on line  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Reset one RAN NIC  console=${log_to_console}

Step 5: Check Bts States
    Log  ${dots_prefix_green}Step 5: Check BTS states  console=${log_to_console}
# Check rannic state and status
    Log  ${info_prefix}Waiting for all RAN NICs to be on line ...  console=${log_to_console}
    vDU Wait Until Rannics Are Online
    ...  rannics_sn_list=${rannics_init_sn_list}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs are on line  console=${log_to_console}
# Wait Until all radio modules are on line
    Log  ${info_prefix}Waiting for all radio modules to be on line ...  console=${log_to_console}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=360s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Log  ${info_prefix}Waiting for all cells to be OnAir ...  console=${log_to_console}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${VDU_RANNIC_RESET_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Check BTS states  console=${log_to_console}

Step 6: Postconditions Rannic Reset
     Log  ${dots_prefix_green}Step 6: Postconditions Rannic Reset  console=${log_to_console}
# Check RAN NICs state and status
    vDU Wait Until Rannics Are Online
    ...  rannics_sn_list=${rannics_init_sn_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RAN NICs are on line  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 6: Postconditions Rannic Reset  console=${log_to_console}
