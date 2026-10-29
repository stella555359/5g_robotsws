*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot

*** Variables ***
# Maximum time to wait for complete reset RET operation in seconds
${RET_HARD_RESET_MAX_WAIT_TIME}=    120

*** Keywords ***
TC__Cloud_ALD_Ret_Hard_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_ald_sn_list}=@{EMPTY}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case performs a CBTS ALD hard Ret reset.
    ...
    ...  Step 1: CBTS Preconditions ALD Ret hard reset
    ...  a) All radio modules should be on line
    ...  b) All ALD should be on line
    ...  c) All Ret should be on line
    ...  d) All cells should be OnAir
    ...  e) vDU operational state should be onAir
    ...  Step 2: CBTS ALD Ret Hard Reset
    ...  a) CBTS ALD Ret hard reset
    ...  b) Tested ALD RET should become disabled
    ...  b) All radio modules, ALDs, RETs, cells should be on line including tested ALD RET
    ...  c) vDU operational state should be onAir
    ...  Step 4: CBTS Postconditions ALD Ret soft reset
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_ald_sn_list       |  Yes | List of serial number of the tested ALD Ret modules.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_ald_sn_list}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_ALD_Ret_Hard_Reset  console=${log_to_console}
    Step 1: CBTS Preconditions ALD Ret Hard Reset
    FOR  ${cbts_reset_ald_sn}  IN  @{cbts_ald_sn_list}
      Set Test Variable  ${cbts_reset_ald_sn}
      Step 2: CBTS ALD Ret Hard Reset
      Step 3: CBTS ALD Ret Hard Reset Check States
    END
    Step 4: CBTS Postconditions ALD Ret Hard Reset
    Log  ${done_prefix_green}Test Case: Cloud_ALD_Ret_Hard_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Preconditions ALD Ret Hard Reset
    Log  ${dots_prefix_green}Step 1: CBTS Preconditions ALD Ret hard reset  console=${log_to_console}
    Should Not Be Empty  ${cbts_ald_sn_list}  msg=CBTS ALD SN list is empty
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
# Wait until all ALD are on line
    ${vdu_scfc_all_ald_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${vdu_scfc_file_path}  dist_name=.*?/ALD_R-\\d+
    ${vdu_scfc_ald_count}=  Get Length  ${vdu_scfc_all_ald_list}
    Wait Until All ALDs Are OnAir
    ...  alds_count=${vdu_scfc_ald_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_ald_count}
    Log  ${info_prefix}All ALD are on line  console=${log_to_console}
# Wait until all RET are on line
    ${vdu_scfc_all_ret_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${vdu_scfc_file_path}  dist_name=.*?/RETU_R-\\d+
    ${vdu_scfc_ret_count}=  Get Length  ${vdu_scfc_all_ret_list}
    Wait Until All RETs Are OnAir
    ...  rets_count=${vdu_scfc_ret_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_ret_count}
    Log  ${info_prefix}All RET are on line  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    ${ald_reset_dict}=  Create Dictionary For ALD Hard Reset
    Set Test Variable  ${ald_reset_dict}
    Log  ${ok_prefix_green}Step 1: CBTS Preconditions ALD Ret hard reset  console=${log_to_console}

Step 2: CBTS ALD Ret Hard Reset
    Log  ${dots_prefix_green}Step 2: CBTS ALD Ret Hard Reset  console=${log_to_console}
    Log  ${info_prefix}ALD module (sn: ${cbts_reset_ald_sn}) has been reset  console=${log_to_console}
    ${reset_info}=  vdu.Create Ald Reset
    ...  target_dn=${ald_reset_dict['${cbts_reset_ald_sn}']}
    ...  type=hard
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${reset_info}
    Log  ${ok_prefix_green}CBTS ALD Ret Soft Reset request sent  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: CBTS ALD Ret Hard Reset  console=${log_to_console}

Step 3: CBTS ALD Ret Hard Reset Check States
    Log  ${dots_prefix_green}Step 3: CBTS ALD Ret Hard Reset Check States  console=${log_to_console}
    Log  ${info_prefix}Waiting for RET device to become disabled  console=${log_to_console}
    Check Tested Ret States  onair=${False}
    Log  ${info_prefix}Waiting for RET device to become enabled  console=${log_to_console}
    Check Tested Ret States  onair=${True}  loop_interval=3
    Log  ${info_prefix}Check if RU/ALD/RET/CELL have expected states  console=${log_to_console}
    Check States While Ret Hard Reset
    Log  ${info_prefix}RU/ALD/RET/CELL state check succeeded  console=${log_to_console}
    Log  ${info_prefix}ALD hard reset operation (sn: ${cbts_reset_ald_sn}) succeeded  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: CBTS ALD Ret Hard Reset Check States  console=${log_to_console}

Step 4: CBTS Postconditions ALD Ret Hard Reset
    Log  ${dots_prefix_green}Step 4: CBTS Postconditions ALD Ret hard reset  console=${log_to_console}
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
# Wait until all ALD are on line
    Wait Until All ALDs Are OnAir
    ...  alds_count=${vdu_scfc_ald_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All ALD are on line  console=${log_to_console}
# Wait until all RET are on line
    Wait Until All RETs Are OnAir
    ...  rets_count=${vdu_scfc_ret_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RET are on line  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${done_prefix_green}Step 4: CBTS Postconditions ALD Ret hard reset  console=${log_to_console}

Create Dictionary For ALD Hard Reset
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword creates a dictionary with ALD information required for RET reset.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ald_reset_dict}=  Create Dictionary
    ${vdu_alds_summary}=  vdu.Get Alds  vdu_connection=${vdu_connection}
    FOR  ${ald_info}  IN  @{vdu_alds_summary}
      Set To Dictionary  ${ald_reset_dict}  ${ald_info['serial_number']}=${ald_info['dist_names']['runtime']}
    END
    [Return]  ${ald_reset_dict}

Check States While Ret Hard Reset
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if any of RMOD, ALD, RET, CELL failed during the RET reset operation.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${ru_stat}=  Run Keyword And Return Status  vDU Radio Modules Should Be Online
    ...  rmods_count=${vdu_scfc_rmods_count}  vdu_connection=${vdu_connection}
    ${ald_stat}=  Run Keyword And Return Status  vDU All ALDs Should Be Onair
    ...  alds_count=${vdu_scfc_ald_count}  vdu_connection=${vdu_connection}
    ${ret_stat}=  Run Keyword And Return Status  vDU All RETs Should Be Onair
    ...  rets_count=${vdu_scfc_ret_count}  vdu_connection=${vdu_connection}
    ${cell_stat}=  Run Keyword And Return Status  vDU All NR Cells Should Be OnAir
    ...  nrcells_count=${vdu_scfc_nrcells_count}  vdu_connection=${vdu_connection}
    IF  not (${ru_stat} and ${ald_stat} and ${ret_stat} and ${cell_stat})
      Log  ${info_prefix}One of RU/ALD/RET/CELL state check failed when RET SN:${cbts_reset_ald_sn} hard reset ongoing
      ...  console=${log_to_console}
      Fail  One of RU/ALD/RET/CELL state check failed when RET SN:${cbts_reset_ald_sn} hard reset ongoing
    END

Check Tested Ret States
    [Arguments]  ${onair}=${TRUE}  ${loop_interval}=1  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks the tested RET state until it reaches the expected state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | onair                  |  No  | Expected RET state: True - OnAir, False - OffLine.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | loop_interval          |  No  | Define time to wait for each state check in seconds                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${start_time}=  Get Time  epoch
    WHILE  ${TRUE}
      Sleep  ${loop_interval}  Extending wait time for states to be updated
      ${current_time}=  Get Time  epoch
      ${elapsed_time}=  Evaluate  ${current_time} - ${start_time}
      IF  ${elapsed_time} >= ${RET_HARD_RESET_MAX_WAIT_TIME}
        Log  ${info_prefix}Waiting for RET hard reset operation success excided ${RET_SOFT_RESET_MAX_WAIT_TIME} seconds
        ...  console=${log_to_console}
        Fail  RET soft reset operation did not complete within ${RET_SOFT_RESET_MAX_WAIT_TIME} seconds
      END
      ${ald_inf}=  vdu.Get Ald State Data  ald_dn=${ald_reset_dict['${cbts_reset_ald_sn}']}  vdu_connection=${vdu_connection}
      TRY
        IF  ${onair}
          Should Be Equal As Strings  first=${ald_inf['operational_state']}  second=enabled
          Should Be Equal As Strings  first=${ald_inf['availability_status']}  second=on line
        ELSE
          Should Be Equal As Strings  first=${ald_inf['operational_state']}  second=disabled
          Should Be Equal As Strings  first=${ald_inf['availability_status']}  second=off line
        END
        Log  ${info_prefix}Tested RET SN:${cbts_reset_ald_sn} reached expected state:  console=${log_to_console}
        Log  ${info_prefix} operational_state->${ald_inf['operational_state']} availability_status->${ald_inf['availability_status']}
        ...  console=${log_to_console}
        BREAK
      EXCEPT
        CONTINUE
      END
    END
