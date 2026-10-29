*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
Variables    tc_variables/sbts_sbts__state__bts1_bts2_blockunblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}       3      # Number of BTS Block/Unblock operations, default value 3
${BTS_RESET_WRN_THR}    600    # Time interval between first cell down till last cell up in accordance with KPI 1a specifications
${BTS_MAX_WAIT_TIME}    900    # Time (secs) spent between first cell down to last cell up on BTS; default value: in accordance with KPI1a
                               # specifications

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23090
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS Block/Unblock, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - following steps are repeated for both BTS:
    ...  - get shared RMOD Primary Link Info before Block/Unblock operation
    ...  - perform Block Site operation on BTS checking states and alarms on both BTS
    ...  - perform Unblock Site operation on BTS checking states and alarms on both BTS
    ...  - check reset behavior on both BTS based on initial and final RESET info as follows:
    ...    - BTS: reset number is 1
    ...    - peer BTS: reset number is 0
    ...  - check final BTS reset behavior after BTS Block Unblock on BTS
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS Block/Unblock operations works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23090 - [5G][CB007636] New SBTS_SBTS scenario_RFS_SBTS_Block_Unblock_from_WebEM
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 17.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24729 -
    ...  [5G][CRT][SBTS-SBTS]Ignore FID7107, FID7114 in SBTS_SBTS TCs, where there are alarm checks made, while one BTS is failed
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24195 - [5G][Reset Number ims2] Update SBTS-SBTS CM, STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 12.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25472 - [5G][CB008129] SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  handling of non-primary link eCPRI RF state
    ...  - 11.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25853 - [5G][CB009569] Add checks regarding DSS alarms -
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  - 31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25484 -
    ...  [5G][CB008378] Resolve CB007437 impact on Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26056 - [5G] SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM fails with
    ...  Variable '${FID6134_alarm_count}' not found
    ...  - 18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26133 - [5G] New expected state after NR BTS block for
    ...  NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26369 -  [5G][CB009210] Update SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM
    ...  with MHA checks
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26705 - [5G][CB007329] " SBTS__STATE__Baseband_module_LockUnlock
    ...  " is failed with "Critical alarms present and/or missing expected alarms!"
    ...  -29.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27008 - [5G][DSS alarms]Add wait_for_alarm_clear
    ...  because DSS alarms are not cleared in current timer
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27183 - [5G] Increase kpi from bts_block_unblock
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 17.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28021 - [5G] [Infomodel] Infomodel refactor in
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM - after TAT-27963
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23090_SBTS_SBTS__STATE__BTS1_BTS2_BlockUnblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-razvan.roman@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT

    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Get Both BTS cells info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform BTS Block Unblock operation on BTS1 for CYCLE ${INDEX}
        Perform BTS Block Unblock operation on BTS2 for CYCLE ${INDEX}
    END

    [Teardown]  Particular Teardown

Get Both BTS cells info
    Get BTS CELL list by RAT  Master
    Get BTS CELL list by RAT  Slave

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    FOR  ${alias}  IN  @{alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
        ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        Run Keyword If  '${peer_alias}' not in ${BTS_DSS_peer}
        ...  Set Test Variable  ${BTS_DSS_configured}  False

        Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    END

    Run Keyword If  ${Master_DSS_configured} and ${Slave_DSS_configured}
    ...  Log  DSS is configured between BTS1 and BTS2. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured between BTS1 and BTS2. DSS alarms check will be skipped!  console=True

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    Get and Check ALD state info  alias=${alias}

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    Log  Step ${index}: Check ${when} BTS ${alias} alarms  console=True
    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Perform BTS Block Unblock operation on ${BTS} for CYCLE ${CYCLE}
    Log  ============================================  console=True
    Log  ***** Perform BTS Block Unblock operation on ${BTS} *****  console=True
    Log  ============================================  console=True
    ${BTS}=  Set Variable If  '${BTS}' == 'BTS1'  BTS1  BTS2
    ${peer_BTS}=  Set Variable If  '${BTS}' == 'BTS1'  BTS2  BTS1
    ${alias}=  Set Variable If  '${BTS}' == 'BTS1'  Master  Slave
    ${peer_alias}=  Set Variable If  '${BTS}' == 'BTS1'  Slave  Master
    Set Test Variable  ${BTS}
    Set Test Variable  ${peer_BTS}
    Set Test Variable  ${alias}
    Set Test Variable  ${peer_alias}
    Step 6: Get shared RMOD Primary Link Info
    Step 7: Block ${BTS} Site
    Step 8: Unblock ${BTS} Site and export results for iteration ${CYCLE}
    Step 9: Check final BTS Master state
    Step 10: Check final BTS Slave state
    Step 11: Check final BTS Master alarms
    Step 12: Check final BTS Slave alarms
    Step 13: Check final BTS reset behavior after BTS Block Unblock on ${BTS} from IMS
    Step 14: Check final number and state of Cells and RMs

Step ${index}: Get shared RMOD Primary Link Info
    [Documentation]
    ...  Get RMOD Primary Link Info

    Log  Step ${index}: Get shared RMOD Primary Link Info  console=True
    ${BTS1_PL_CPRI_shared_RMOD_list}=  Create List
    ${BTS1_non_PL_CPRI_shared_RMOD_list}=  Create List
    ${BTS2_PL_CPRI_shared_RMOD_list}=  Create List
    ${BTS2_non_PL_CPRI_shared_RMOD_list}=  Create List
    ${BTS1_PL_ECPRI_shared_RMOD_list}=  Create List
    ${BTS1_non_PL_ECPRI_shared_RMOD_list}=  Create List
    ${BTS2_PL_ECPRI_shared_RMOD_list}=  Create List
    ${BTS2_non_PL_ECPRI_shared_RMOD_list}=  Create List
    ${BTS1_PL_dict}  ${BTS2_PL_dict}=  Get Primary Link shared RMOD status based on linkModeSynchronization
    ${BTS1_keys}=  Get Dictionary Keys  ${BTS1_PL_dict}  False
    ${BTS2_keys}=  Get Dictionary Keys  ${BTS2_PL_dict}  False
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  Master
    FOR  ${BTS1_key}  ${BTS2_key}  IN ZIP  ${BTS1_keys}  ${BTS2_keys}
        ${BTS1_value}=  Get From Dictionary  ${BTS1_PL_dict}  ${BTS1_key}
        ${BTS2_value}=  Get From Dictionary  ${BTS2_PL_dict}  ${BTS2_key}
        ${RMOD_L3Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${BTS1_key}
        ${module_SN}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${BTS1_key}
        Log  Primary Link status (linkModeSynchronization) for shared RMOD with SN ${module_SN}:  console=True
        Log  - BTS Master RMOD ${BTS1_key}: ${BTS1_value}  console=True
        Log  - BTS Slave RMOD ${BTS2_key}: ${BTS2_value}  console=True
        Run Keyword If  'True' in '${BTS1_value}' and '${RMOD_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${BTS1_PL_CPRI_shared_RMOD_list}  ${BTS1_key}
        ...  ELSE IF  'False' in '${BTS1_value}' and '${RMOD_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${BTS1_non_PL_CPRI_shared_RMOD_list}  ${BTS1_key}
        Run Keyword If  'True' in '${BTS2_value}' and '${RMOD_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${BTS2_PL_CPRI_shared_RMOD_list}  ${BTS2_key}
        ...  ELSE IF  'False' in '${BTS2_value}' and '${RMOD_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${BTS2_non_PL_CPRI_shared_RMOD_list}  ${BTS2_key}
        Run Keyword If  'True' in '${BTS1_value}' and '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${BTS1_PL_ECPRI_shared_RMOD_list}  ${BTS1_key}
        ...  ELSE IF  'False' in '${BTS1_value}' and '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${BTS1_non_PL_ECPRI_shared_RMOD_list}  ${BTS1_key}
        Run Keyword If  'True' in '${BTS2_value}' and '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${BTS2_PL_ECPRI_shared_RMOD_list}  ${BTS2_key}
        ...  ELSE IF  'False' in '${BTS2_value}' and '${RMOD_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${BTS2_non_PL_ECPRI_shared_RMOD_list}  ${BTS2_key}
    END
    Set Test Variable  ${BTS1_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${BTS1_non_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${BTS2_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${BTS2_non_PL_CPRI_shared_RMOD_list}
    Set Test Variable  ${BTS1_PL_ECPRI_shared_RMOD_list}
    Set Test Variable  ${BTS1_non_PL_ECPRI_shared_RMOD_list}
    Set Test Variable  ${BTS2_PL_ECPRI_shared_RMOD_list}
    Set Test Variable  ${BTS2_non_PL_ECPRI_shared_RMOD_list}
    ${BTS1_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS1_PL_CPRI_shared_RMOD_list}
    ${BTS2_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS2_PL_CPRI_shared_RMOD_list}
    ${BTS1_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS1_PL_ECPRI_shared_RMOD_list}
    ${BTS2_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS2_PL_ECPRI_shared_RMOD_list}
    Set Test Variable  ${BTS1_PL_CPRI_shared_RMOD_count}
    Set Test Variable  ${BTS2_PL_CPRI_shared_RMOD_count}
    Set Test Variable  ${BTS1_PL_ECPRI_shared_RMOD_count}
    Set Test Variable  ${BTS2_PL_ECPRI_shared_RMOD_count}
    Log  CPRI Shared RMOD count with Primary Link configured on BTS1: ${BTS1_PL_CPRI_shared_RMOD_count}  console=True
    Log  CPRI Shared RMOD count with Primary Link configured on BTS2: ${BTS2_PL_CPRI_shared_RMOD_count}  console=True
    Log  ECPRI Shared RMOD count with Primary Link configured on BTS1: ${BTS1_PL_ECPRI_shared_RMOD_count}  console=True
    Log  ECPRI Shared RMOD count with Primary Link configured on BTS2: ${BTS2_PL_ECPRI_shared_RMOD_count}  console=True

Step ${index}: Block ${BTS} Site
    [Documentation]
    ...  Perform Block Site on requested BTS checking states and alarms on both BTS

    [Timeout]  15 min

    Log  Step ${index}: Block ${BTS} Site  console=True

    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, blockingState=${Blocked_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, blockingState=Blocked
    Run Keyword If  ${${alias}_DSS_configured}  Get DSS alarms
    Get Current Date UTC info  start

    Log  Perform "Block Site" operation on ${BTS} from Admin  console=True
    coam.Block  timeout=600  alias=${alias}

    Log  Check ${BTS} states and alarms after ${BTS} block:  console=True
    Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Blocked_}  180  ${alias}
    Log  ${BTS} site - proceduralState: IntegratedToRAN|Configured, blockingState: Blocked, as expected!  console=True
    Run Keyword If  ${${alias}_NR_CELL_list}  Run Keywords
    ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_disabled_check}  timeout=5  connection=${alias}
    ...  AND  Log  All NR ${alias} cell(s) status:\n - ${CELL_state_disabled}  console=True
    Run Keyword If  ${${alias}_LTE_CELL_list}  Run Keywords
    ...  Assert Every  class_name=LNCEL  parameters=${CELL_state_disabled_check}  timeout=5  connection=${alias}
    ...  AND  Log  All LTE ${alias} cell(s) status:\n - ${CELL_state_disabled}  console=True
    Run Keyword If  ${${alias}_WCDMA_CELL_list}  Run Keywords
    ...  Assert Every  class_name=WNCEL  parameters=${CELL_state_disabled_check}  timeout=5  connection=${alias}
    ...  AND  Log  All WCDMA ${alias} cell(s) status:\n - ${CELL_state_disabled}  console=True
    Run Keyword If  ${${alias}_GSM_CELL_list}  Run Keywords
    ...  Assert Every  class_name=GNCEL  parameters=${CELL_state_disabled_check}  timeout=5  connection=${alias}
    ...  AND  Log  All GSM ${alias} cell(s) status:\n - ${CELL_state_disabled}  console=True
    Log  ${BTS} "BTS blocked (50)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_50}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} "BTS blocked (50)" alarm, found number: 1, as expected!  console=True
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    Log  Check ${peer_BTS} states and alarms after ${BTS} block:  console=True
    Check peer BTS state and alarms after block

Check peer BTS state and alarms after block

    ${peer_SBTS_EXPECTED_ALARMS}=  Create List
    ${peer_SBTS_EXPECTED_ALARMS}=  Set Variable If  ${${peer_alias}_DSS_configured}
    ...  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}  ${peer_SBTS_EXPECTED_ALARMS}
    ${peer_SBTS_IGNORED_ALARMS_full}=  Combine lists  ${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS_LTE_DSS}

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  10  ${peer_alias}
    Log  ${peer_BTS} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log Long String  ${peer_BTS} "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm, or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  expected number: ${FID7513_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_SBTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${peer_SBTS_IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log Long String  ${peer_BTS} "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" alarm, or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  found number: ${FID7513_alarm_count}, as expected!  console=True

    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

Get DSS alarms
    ${DSS_NR_LTE_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${peer_alias}
    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${peer_alias}

    ${NR_CELL_DSS_count}=  Get Length  ${DSS_NR_LTE_CELL_runtime_dict}
    ${LTE_CELL_DSS_count}=  Get Length  ${DSS_LTE_NR_CELL_runtime_dict}

    Set Test Variable  ${FID7513_alarm_count}  ${NR_CELL_DSS_count}

    ${peer_SBTS_EXPECTED_ALARMS_DSS_NR}=  Prepare expected alarms list
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_NR_DSS}  ${FID7513_alarm_count}

    ${peer_SBTS_EXPECTED_ALARMS_DSS_full}=  Copy List  ${peer_SBTS_EXPECTED_ALARMS_DSS_NR}

    Set Test Variable  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}

Step ${index}: Unblock ${BTS} Site and export results for iteration ${CYCLE}
    [Documentation]
    ...  Perform Reset Site on requested BTS checking states and alarms on both BTS

    Log  Step ${index}: Unblock ${BTS} Site and export results for iteration ${CYCLE} console=True

    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${new_alias}=  Set Variable  unblockBTS

    Log  Perform "Unblock Site" operation on ${BTS} from Admin  console=True

    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    Get Current Time  bts_initial
    Log  ${BTS} reset_start_time is: ${time_bts_initial}  console=True
    ${unblock_info}=  Run Keyword In Background  Unblock  timeout=600  connection=${new_alias}

    Log  Check ${peer_BTS} states and alarms during ${BTS} unblock:  console=True
    Check peer BTS state and alarms during unblock

    Get Current Time  start_first_cell_up_check
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_start_first_cell_up_check}  ${time_bts_initial}  number
    ${first_cell_up_check_remained_time}=  BuiltIn.Evaluate  ${BTS_MAX_WAIT_TIME} - ${elapsed_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${first_cell_up_check_remained_time}  ${alias}
    Get Current Time  end_first_cell_up_check
    ${first_cell_up_elapsed_time}=  DateTime.Subtract Date from Date  ${time_end_first_cell_up_check}  ${time_bts_initial}  number
    Log  Time interval between first cell down till first cell up on ${BTS} due to "Unblock Site" operation on ${BTS}: ${first_cell_up_elapsed_time}s
    ...  console=True

    Get Current Time  start_last_cell_up_check
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_start_last_cell_up_check}  ${time_bts_initial}  number
    ${last_cell_up_check_remained_time}=  BuiltIn.Evaluate  ${BTS_MAX_WAIT_TIME} - ${elapsed_time}
    Admin Check BTS RAT cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}  timeout=${last_cell_up_check_remained_time}
    Get Current Time  end_last_cell_up_check
    ${last_cell_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_end_last_cell_up_check}  ${time_bts_initial}  number
    Log  Time interval between first cell down till last cell up on ${BTS} due to "Unblock Site" operation on ${BTS}: ${last_cell_up_elapsed_time}s
    ...  console=True

    Export ResetTime Results  ${alias}  ${BTS Files}/${alias}/ResetTimeInfo.txt  unblock_sm  sbts  ${CYCLE}  ${last_cell_up_elapsed_time}  ${EMPTY}
    Check KPI  ${last_cell_up_elapsed_time}  ${BTS_RESET_WRN_THR}

    Collect Keyword Result  ${unblock_info}  timeout=600

    [Teardown]  Teardown Admin  alias=${new_alias}

Step ${index}: Check final BTS reset behavior after BTS Block Unblock on ${BTS} from IMS
    [Documentation]
    ...  Final RESET info is compared with initial RESET info for both SBTS
    ...  Reset behavior as expected in following conditions:
    ...  - BTS1: reset number is 0
    ...  - BTS2: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    Log  Step ${index}: Check final BTS reset behavior after BTS Block Unblock on ${BTS} from IMS  console=True
    Get Current Date UTC info  end
    ${BTS1_reset_count}=  Set Variable If  '${BTS}' == 'BTS1'  1  '${BTS}' == 'BTS2'  0
    ${BTS2_reset_count}=  Set Variable If  '${BTS}' == 'BTS1'  0  '${BTS}' == 'BTS2'  1
    Get and check BTS RESET info from IMS file  expected_reset_number=${BTS1_reset_count}  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number= ${BTS2_reset_count}  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Get Primary Link shared RMOD status based on linkModeSynchronization
    ${BTS1_PL_dict}=  Create Dictionary
    ${BTS2_PL_dict}=  Create Dictionary
    ${BTS1_shared_RMOD_list}  ${BTS2_shared_RMOD_list}  ${BTS1_dedicated_RMOD_list}  ${BTS2_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    FOR  ${BTS1_RMOD_id}  ${BTS2_RMOD_id}  IN ZIP  ${BTS1_shared_RMOD_list}  ${BTS2_shared_RMOD_list}
        ${BTS1_RMOD_linkModeSynchronization_list}=  Get linkModeSynchronization from CABLINK  ${BTS1_RMOD_id}  Master
        Run Keyword If  ${BTS1_RMOD_linkModeSynchronization_list}
        ...  Set To Dictionary  ${BTS1_PL_dict}  ${BTS1_RMOD_id}  ${BTS1_RMOD_linkModeSynchronization_list}
        ${BTS2_RMOD_linkModeSynchronization_list}=  Get linkModeSynchronization from CABLINK  ${BTS2_RMOD_id}  Slave
        Run Keyword If  ${BTS2_RMOD_linkModeSynchronization_list}
        ...  Set To Dictionary  ${BTS2_PL_dict}  ${BTS2_RMOD_id}  ${BTS2_RMOD_linkModeSynchronization_list}
    END
    [Return]  ${BTS1_PL_dict}  ${BTS2_PL_dict}

Check peer BTS state and alarms during unblock
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${peer_SBTS_EXPECTED_ALARMS}=  Create List
    ${peer_SBTS_EXPECTED_ALARMS}=  Set Variable If  ${${peer_alias}_DSS_configured}
    ...  ${peer_SBTS_EXPECTED_ALARMS_DSS_full}  ${peer_SBTS_EXPECTED_ALARMS}
    ${SBTS_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}
    ...  ${${BTS}_PL_CPRI_shared_RMOD_count}
    ${SBTS_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_16}
    ...  ${${BTS}_PL_ECPRI_shared_RMOD_count}
    ${SBTS_EXPECTED_ALARMS_10_1815_16_full}=  Combine Lists  ${SBTS_EXPECTED_ALARMS_10_1815_full}  ${SBTS_EXPECTED_ALARMS_16_full}
    ${peer_SBTS_EXPECTED_ALARMS}=  Set Variable If
    ...  (${${BTS}_PL_CPRI_shared_RMOD_count} == 0 and ${${BTS}_PL_ECPRI_shared_RMOD_count} == 0)  ${peer_SBTS_EXPECTED_ALARMS}
    ...  ${SBTS_EXPECTED_ALARMS_10_1815_16_full}
    ${peer_SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias.upper()}_IGNORED_ALARMS_LTE_DSS}

    Run Keyword If  ${${BTS}_PL_CPRI_shared_RMOD_count} > 0
    ...  Log Long String  ${peer_BTS} "No connection to Unit (10)" alarm or "Not able to synchronize baseband bus (1815)" alarm,
    ...  expected number: ${${BTS}_PL_CPRI_shared_RMOD_count}  console=True
    Run Keyword If  ${${BTS}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  BTS ${peer_BTS} "Unit synchronization failed (16)" alarm, expected number: ${${BTS}_PL_ECPRI_shared_RMOD_count}
    ...  console=True
    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log  ${peer_BTS} "EN DSS De-activated on partner side (7513)" alarm, expected number: ${FID7513_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_SBTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${peer_SBTS_IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${${BTS}_PL_CPRI_shared_RMOD_count} > 0
    ...  Log Long String  ${peer_BTS} "No connection to Unit (10)" alarm or "Not able to synchronize baseband bus (1815)" alarm,
    ...  found number: ${${BTS}_PL_CPRI_shared_RMOD_count}, as expected!  console=True
    Run Keyword If  ${${BTS}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log  BTS ${peer_BTS} "Unit synchronization failed (16)" alarm, found number: ${${BTS}_PL_ECPRI_shared_RMOD_count}, as expected!
    ...  console=True
    Run Keyword If  ${${peer_alias}_DSS_configured}
    ...  Log  ${peer_BTS} "EN DSS De-activated on partner side (7513)" alarm, found number: ${FID7513_alarm_count}, as expected!  console=True

    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

    Run Keyword If  ${${peer_BTS}_PL_ECPRI_shared_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${${peer_BTS}_PL_ECPRI_shared_RMOD_list}  ${RMOD_state_enabled_check}  60  ${peer_alias}
    ...  AND  Log  All ${peer_BTS} ECPRI Shared RMOD with Primary Link configured on ${peer_BTS} status:\n - ${RMOD_state_enabled}  console=True

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
    END

Particular Teardown
    Admin Check if BTS is unblocked  Master
    Admin Check if BTS is unblocked  Slave
    Export ResetTime Results Global

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
