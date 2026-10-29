*** Settings ***
Documentation    TC__NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config
Variables    tc_variables/nr_sbts__state__nr_bts_block_unblock_from_webem_with_sharedfhs_config_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3    # Number of NR block/unblock BTS operations, default value 3

*** Keywords ***
TC__NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24444
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for NR Block/Unblock Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - get primary link info
    ...  - perform Block/Unblock BTS operation on NR
    ...  - check reset behavior on NR and SBTS based on IMS info as follows:
    ...    - NR site: reset number is 1
    ...    - SBTS site: reset number is 0
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: NR Block/Unblock BTS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24444 - [5G][OBSAI][CPRI][FHS] [CB008470]New NRL scenario
    ...  NR_SBTS__STATE__NR_Site_Block/Unblock_from_WEBEM
    ...  - 18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26133 - [5G] New expected state after NR BTS block for
    ...  NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 25.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26765 -
    ...  [5G] Include DSS alarms check on TC__NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_confi
    ...  - 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27211 -
    ...  [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not cleared in current timer - NR_SBTS
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29834 - Update KW for BBMOD CELL mapping based on BBPOOL info
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-24444_NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM_with_sharedFHS_config.png

    Set Tags    CA-STATE    OWNER-alexandru-eugen.miron@nokia.com    AUTHOR-horea.olars@nokia.com    PHASE-QT  SW-SBTS23

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared FHS and RMOD Info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Get shared RMOD Primary Link before NR BTS Block Unblock operation
        Step 5: Block NR BTS
        Step 6: Unblock NR BTS and export results for iteration ${INDEX}
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check NR and SBTS reset behavior based on IMS info
        Step 10: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get shared RMOD Primary Link before NR BTS Block Unblock operation
    [Documentation]
    ...  Get shared RMOD Primary Link
    Log  Step ${index}: Get shared RMOD Primary Link before NR BTS Block Unblock operation  console=True
    ${Master_Primary_Link_shared_FHS_list}=  Create List
    ${Slave_Primary_Link_shared_FHS_list}=  Create List
    Set Test Variable  ${Master_Primary_Link_shared_FHS_count}  0
    Set Test Variable  ${Slave_Primary_Link_shared_FHS_count}  0
    ${Master_Primary_Link_dict}  ${Slave_Primary_Link_dict}=  Get Primary Link status based on linkModeSynchronization  FHS
    ${Master_keys}=  Get Dictionary Keys  ${Master_Primary_Link_dict}  False
    ${Slave_keys}=  Get Dictionary Keys  ${Slave_Primary_Link_dict}  False
    FOR  ${Master_key}  ${Slave_key}  IN ZIP  ${Master_keys}  ${Slave_keys}
        ${Master_value}=  Get From Dictionary  ${Master_Primary_Link_dict}  ${Master_key}
        ${Slave_value}=  Get From Dictionary  ${Slave_Primary_Link_dict}  ${Slave_key}
        Run Keyword If  'True' in '${Master_value}'
        ...  Append To List  ${Master_Primary_Link_shared_FHS_list}  ${Master_key}
        ...  ELSE IF  'True' in '${Slave_value}'
        ...  Append To List  ${Slave_Primary_Link_shared_FHS_list}  ${Slave_key}
    END
    Set Test Variable  ${Master_Primary_Link_shared_FHS_list}
    Set Test Variable  ${Slave_Primary_Link_shared_FHS_list}
    ${Master_Primary_Link_shared_FHS_count}=  Get Length  ${Master_Primary_Link_shared_FHS_list}
    ${Slave_Primary_Link_shared_FHS_count}=  Get Length  ${Slave_Primary_Link_shared_FHS_list}

    ${Slave_RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Slave
    ${Slave_PL_CPRI_shared_RMOD_list}=  Create List
    ${Slave_non_PL_CPRI_shared_RMOD_list}=  Create List
    ${Slave_PL_OBSAI_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{Slave_shared_RMOD_list}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${Slave_RMOD_L3Protocol_dict}  ${item}

        Run Keyword If  '${RMOD_L3Protocol}' == 'CPRI_RP1' and ${Slave_Primary_Link_shared_FHS_list}
        ...  Append To List  ${Slave_PL_CPRI_shared_RMOD_list}  ${item}
        ...  ELSE IF  '${RMOD_L3Protocol}' == 'CPRI_RP1' and ${Master_Primary_Link_shared_FHS_list}
        ...  Append To List  ${Slave_non_PL_CPRI_shared_RMOD_list}  ${item}
        Run Keyword If  '${RMOD_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${Slave_PL_OBSAI_shared_RMOD_list}  ${item}
    END
    ${Slave_non_PL_CPRI_shared_RMOD_count}=  Get Length  ${Slave_non_PL_CPRI_shared_RMOD_list}
    ${alarm_count}=  Evaluate  ${Master_Primary_Link_shared_FHS_count} + ${Slave_non_PL_CPRI_shared_RMOD_count}
    Set Test Variable  ${alarm_count}
    Set Test Variable  ${Slave_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${Slave_non_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${Slave_PL_OBSAI_shared_RMOD_list}

    ${LTE_non_PL_CPRI_shared_RM_CELL_list}  ${LTE_non_PL_CPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Slave_non_PL_CPRI_shared_RMOD_list}  Slave
    Set Test Variable  ${LTE_non_PL_CPRI_shared_RM_CELL_list}
    ${Slave_non_pl_shared_FHS_RMOD_CELL_list}=  Run Keyword If  ${Master_Primary_Link_shared_FHS_count} > 0
    ...  Set Variable  ${Slave_shared_FHS_RMOD_CELL_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${Slave_non_pl_shared_FHS_RMOD_CELL_list}

Step ${index}: Get shared FHS and RMOD Info
    [Documentation]
    ...  Get shared FHS Primary Link info

    Log  Step ${index}: Get shared FHS and RMOD Info  console=True
    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    ${Slave_shared_FHS_RMOD_list}=  Get shared RMOD connected to shared FHS  ${Slave_shared_FHS_list}  Slave
    ${Slave_shared_FHS_RMOD_CELL_list}=  Get RMOD Cell list  ${Slave_shared_FHS_RMOD_list}  Slave
    Set Test Variable  ${Slave_shared_FHS_RMOD_CELL_list}
    Log  Shared FHS on NR BTS: ${Master_shared_FHS_list}  console=True
    Log  Shared FHS on SBTS BTS: ${Slave_shared_FHS_list}  console=True
    ${Master_shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    ${Slave_shared_FHS_count}=  Get Length  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_count}
    Set Test Variable  ${Slave_shared_FHS_count}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}
    ${Master_shared_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Master_shared_RMOD_list}  Master
    ${Master_dedicated_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Master_dedicated_RMOD_list}  Master
    ${Slave_shared_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Slave_shared_RMOD_list}  Slave
    ${Slave_dedicated_RMOD_CELL_list}=  Get CELL Mapping By RMOD list  ${Slave_dedicated_RMOD_list}  Slave
    Set Test Variable  ${Master_shared_RMOD_CELL_list}
    Set Test Variable  ${Master_dedicated_RMOD_CELL_list}
    Set Test Variable  ${Slave_shared_RMOD_CELL_list}
    Set Test Variable  ${Slave_dedicated_RMOD_CELL_list}

    ${SBTS_LTE_CELL_shared_RM_list}=  Copy List  ${SBTS_LTE_CELL_ids}
    ${SBTS_WCDMA_CELL_shared_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_ids}
    ${SBTS_GSM_CELL_shared_RM_list}=  Copy List  ${SBTS_GSM_CELL_ids}
    ${SBTS_LTE_CELL_dedicated_RM_list}=  Copy List  ${SBTS_LTE_CELL_ids}
    ${SBTS_WCDMA_CELL_dedicated_RM_list}=  Copy List  ${SBTS_WCDMA_CELL_ids}
    ${SBTS_GSM_CELL_dedicated_RM_list}=  Copy List  ${SBTS_GSM_CELL_ids}
    FOR  ${item}  IN  @{Slave_shared_RMOD_CELL_list}
        Remove Values From List  ${SBTS_LTE_CELL_dedicated_RM_list}  ${item}
        Remove Values From List  ${SBTS_WCDMA_CELL_dedicated_RM_list}  ${item}
        Remove Values From List  ${SBTS_GSM_CELL_dedicated_RM_list}  ${item}
    END

    Set Test Variable  ${SBTS_LTE_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_WCDMA_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_GSM_CELL_shared_RM_list}
    Set Test Variable  ${SBTS_LTE_CELL_dedicated_RM_list}
    Set Test Variable  ${SBTS_WCDMA_CELL_dedicated_RM_list}
    Set Test Variable  ${SBTS_GSM_CELL_dedicated_RM_list}

    ${SBTS_BBMOD_list}=  Get Ids For All  BBMOD  alias=Slave
    Set Test Variable  ${SBTS_BBMOD_list}

    Get BBMOD ID SN dict  Master
    Get BBMOD ID SN dict  Slave

    ${SBTS_BBMOD_shared_FHS_dict}  ${SBTS_BBMOD_dedicated_FHS_dict}=  Get BBMOD FHS dict  ${SBTS_BBMOD_list}  Slave
    Set Test Variable  ${SBTS_BBMOD_shared_FHS_dict}
    Set Test Variable  ${SBTS_BBMOD_dedicated_FHS_dict}

    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Master
    Set Test Variable  ${Master_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}
    ${BBMOD_CELL_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${Slave_BBMOD_CELL_dict}  ${BBMOD_CELL_dict}

    Get SBTS BBMOD and FHS cell lists using BBPOOL

Step ${index}: Block NR BTS
    [Documentation]
    ...  Block Site operation is launched on NR. Check state and alarms for both NR and SBTS technologies.

    [Timeout]  15 min
    Log  Step ${index}: Block NR BTS  console=True

    Log  Perform "Block BTS" operation on NR from ADMIN  console=True
    Get Current Date UTC info  start
    coam.Block  timeout=600  alias=Master
    Sleep  10s

    Log  Check NR states and alarms after block NR BTS:  console=True
    Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Blocked_}  180  Master
    Log  NR site - proceduralState: IntegratedToRAN|Configured, blockingState: Blocked, as expected!  console=True
    Log  NR "BTS blocked (50)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR "BTS blocked (50)" alarm, found number: 1, as expected!  console=True

    Log  Check SBTS states after block NR BTS:  console=True
    Admin Check BTS RAT Procedural State  alias=Slave  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  Slave
    Log  SBTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

Step ${index}: Unblock NR BTS and export results for iteration ${CYCLE}
    [Documentation]
    ...  Unblock BTS procedure is launched on NR.

    [Timeout]  15 min
    Log  Step ${index}: Unblock NR BTS and export results for iteration ${CYCLE}  console=True
    Log  Perform "Unblock BTS" operation on NR from ADMIN  console=True

    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}

    coam.Unblock  timeout=60  alias=Master  wait_for_reconnection=False

    Check SBTS state and alarms

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  Master

    Admin Check BTS RAT cells expected states  expected_state=${CELL_state_enabled_check}  alias=Master  timeout=600

    Get Current Date UTC info  end

Check SBTS state and alarms
    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed_Offline
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled

    FOR  ${item}  IN  @{Slave_shared_FHS_list}
        Run Keyword If  '${item}' in @{Slave_Primary_Link_shared_FHS_list}
        ...  Wait Until Keyword Succeeds  60 sec  10 sec  Admin Check FHS state  ${item}  ${Enabled_}  ${Online_}  ${Unlocked_}  Slave
        ...  ELSE IF  '${item}' not in @{Slave_Primary_Link_shared_FHS_list}
        ...  Wait Until Keyword Succeeds  60 sec  10 sec  Admin Check FHS state  ${item}  ${Disabled_}  ${NotInstalled_}  ${Unlocked_}  Slave
    END
    Run Keyword If  ${Slave_non_PL_CPRI_shared_RMOD_list}
    ...  Check BTS Item State  RMOD  ${Slave_non_PL_CPRI_shared_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  Slave
    Run Keyword If  ${Slave_PL_CPRI_shared_RMOD_list}
    ...  Check BTS Item State  RMOD  ${Slave_PL_CPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  60  Slave
    Run Keyword If  ${Slave_PL_OBSAI_shared_RMOD_list}
    ...  Check BTS Item State  RMOD  ${Slave_PL_OBSAI_shared_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  60  Slave

    Check BTS Item State  LNCEL  ${BBMOD_LTE_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Run Keyword If  ${Master_Primary_Link_shared_FHS_list}
    ...  Check BTS Item State  LNCEL  ${BBMOD_FHS_LTE_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Slave
    ...  ELSE  Check BTS Item State  LNCEL  ${BBMOD_FHS_LTE_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Check BTS Item State  WNCEL  ${BBMOD_WCDMA_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Run Keyword If  ${Master_Primary_Link_shared_FHS_list}
    ...  Check BTS Item State  WNCEL  ${BBMOD_FHS_WCDMA_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Slave
    ...  ELSE  Check BTS Item State  WNCEL  ${BBMOD_FHS_WCDMA_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Check BTS Item State  GNCEL  ${BBMOD_GSM_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave
    Run Keyword If  ${Master_Primary_Link_shared_FHS_list}
    ...  Check BTS Item State  GNCEL  ${BBMOD_FHS_GSM_cells}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Slave
    ...  ELSE  Check BTS Item State  GNCEL  ${BBMOD_FHS_GSM_cells}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  60  Slave

    ${SLAVE_EXPECTED_ALARMS_10_multiplicated}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10}  ${alarm_count}
    ${SLAVE_EXPECTED_ALARMS_full}=  Create List  @{EMPTY}
    ${SLAVE_IGNORED_ALARMS_full}=  Combine Lists  ${SLAVE_IGNORED_ALARMS_DSS}  ${SLAVE_IGNORED_ALARMS}
    Run Keyword If  ${alarm_count} > 0  Run Keywords
    ...  Append To List  ${SLAVE_EXPECTED_ALARMS_full}  @{SLAVE_EXPECTED_ALARMS_10_multiplicated}
    ...  AND  Log  SBTS "No connection to unit (10)" alarm, expected count: ${alarm_count}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS_full}  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Run Keyword If  ${alarm_count} > 0
    ...  Log  SBTS "No connection to unit (10)" alarm, found count: ${alarm_count}, as expected!  console=True

Get SBTS BBMOD and FHS cell lists using BBPOOL
    ${BBMOD_cells_list}=  Create List
    ${BBMOD_FHS_cells_list}=  Create List
    FOR  ${item}  IN  @{SBTS_BBMOD_list}
        ${connected_to_FHS}=  Get From Dictionary  ${SBTS_BBMOD_shared_FHS_dict}  ${item}
        ${cells_list}=  Get From Dictionary  ${Slave_BBMOD_CELL_dict}  ${item}
        Run Keyword If  ${connected_to_FHS}  Append To List  ${BBMOD_FHS_cells_list}  @{cells_list}
        ...  ELSE  Append To List  ${BBMOD_cells_list}  @{cells_list}
    END
    ${BBMOD_LTE_cells}=  Create List
    ${BBMOD_WCDMA_cells}=  Create List
    ${BBMOD_GSM_cells}=  Create List
    ${BBMOD_FHS_LTE_cells}=  Create List
    ${BBMOD_FHS_WCDMA_cells}=  Create List
    ${BBMOD_FHS_GSM_cells}=  Create List
    FOR  ${item}  IN  @{SBTS_LTE_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_cells_list}  Append To List  ${BBMOD_LTE_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${BBMOD_FHS_LTE_cells}  ${item}
    END
    FOR  ${item}  IN  @{SBTS_WCDMA_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_cells_list}  Append To List  ${BBMOD_WCDMA_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${BBMOD_FHS_WCDMA_cells}  ${item}
    END
    FOR  ${item}  IN  @{SBTS_GSM_CELL_shared_RM_list}
        Run Keyword If  '${item}' in @{BBMOD_cells_list}  Append To List  ${BBMOD_GSM_cells}  ${item}
        ...  ELSE IF  '${item}' in @{BBMOD_FHS_cells_list}  Append To List  ${BBMOD_FHS_GSM_cells}  ${item}
    END
    Set Test Variable  ${BBMOD_LTE_cells}
    Set Test Variable  ${BBMOD_WCDMA_cells}
    Set Test Variable  ${BBMOD_GSM_cells}
    Set Test Variable  ${BBMOD_FHS_LTE_cells}
    Set Test Variable  ${BBMOD_FHS_WCDMA_cells}
    Set Test Variable  ${BBMOD_FHS_GSM_cells}

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  RESET info is taken from IMS file for both NR and SBTS. Reset behavior as expected if:
    ...  - NR site: reset number is 1
    ...  - SBTS site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BBMOD FHS dict
    [Arguments]  ${BBMOD_list}  ${alias}
    ${BBMOD_shared_FHS_dict}=  Create Dictionary
    ${BBMOD_dedicated_FHS_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BBMOD_list}
        ${shared_FHS_list}  ${dedicated_FHS_list}=  Get FHS Mapping By BBMOD Id  ${item}  ${alias}
        Set To Dictionary  ${BBMOD_shared_FHS_dict}  ${item}  ${shared_FHS_list}
        Set To Dictionary  ${BBMOD_dedicated_FHS_dict}  ${item}  ${dedicated_FHS_list}
    END
    [Return]  ${BBMOD_shared_FHS_dict}  ${BBMOD_dedicated_FHS_dict}

Get FHS Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${shared_FHS_list}=  Create List
    ${dedicated_FHS_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  BBMOD_R
        ${secondEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  FHS_R
        ${shared_FHS}=  Run Keyword And Return Status  Should Contain  ${${alias}_shared_FHS_list}  ${item.secondEndpointDN}
        ${dedicated_FHS}=  Run Keyword And Return Status  Should Contain  ${${alias}_dedicated_FHS_list}  ${item.secondEndpointDN}
        Run Keyword If  ${firstEndpointDN_BBMOD_R} and ${secondEndpointDN_FHS_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${shared_FHS}
        ...  Append To List  ${shared_FHS_list}  ${item.secondEndpointDN}
        Run Keyword If  ${firstEndpointDN_BBMOD_R} and ${secondEndpointDN_FHS_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}' and ${dedicated_FHS}
        ...  Append To List  ${dedicated_FHS_list}  ${item.secondEndpointDN}
    END
    ${shared_FHS_list}=  Remove Duplicates  ${shared_FHS_list}
    ${dedicated_FHS_list}=  Remove Duplicates  ${dedicated_FHS_list}
    [Return]  ${shared_FHS_list}  ${dedicated_FHS_list}

Get CELL Mapping By RMOD list
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_list}  @{RMOD_CELL_list}
    END
    ${CELL_list}=  Remove Duplicates  ${CELL_list}
    [Return]  ${CELL_list}

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${item} state: ${BTS_item_state}  console=True
    END

Get shared RMOD connected to shared FHS
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_list}=  Create List
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Append To List  ${shared_FHS_RMOD_list}  @{RMOD_list}
    END
    ${shared_FHS_RMOD_list}=  Remove Duplicates  ${shared_FHS_RMOD_list}
    [Return]  ${shared_FHS_RMOD_list}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${RMOD_list}  ${item.secondEndpointDN}
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    [Return]  ${RMOD_list}

Get RMOD CELL list
    [Arguments]  ${RMOD_list}  ${alias}
    ${RMOD_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Run Keyword If  ${CELL_list}  Append To List  ${RMOD_CELL_list}  @{CELL_list}
    END
    Remove Duplicates  ${RMOD_CELL_list}
    [Return]  ${RMOD_CELL_list}

Get cells mapped on shared RM
    [Arguments]  ${shared_RM_list}  ${alias}
    ${shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{shared_RM_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=${alias}
        Append To List  ${shared_RM_CELL_list}  @{CELL_RM_list}
    END
    ${shared_RM_CELL_list}=  Remove Duplicates  ${shared_RM_CELL_list}
    ${shared_RM_CELL_count}=  Get Length  ${shared_RM_CELL_list}
    [Return]  ${shared_RM_CELL_list}  ${shared_RM_CELL_count}

Particular Teardown
    Admin Check if BTS is unblocked  Master
    Export ResetTime Results Global

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
