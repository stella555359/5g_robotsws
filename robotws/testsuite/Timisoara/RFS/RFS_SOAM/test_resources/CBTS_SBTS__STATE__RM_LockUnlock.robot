*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__RM_LockUnlock
Variables    tc_variables/cbts_sbts__state__rm_lockunlock_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             3    # Number of Lock/Unlock RMOD operations, default value 3
${RMOD_SERIAL_NUMBER_LIST}    ALL  # RMOD serial number list on which lock/unlock operations will be performed. Possible values (by default ALL):
                                   # - ALL: action will be performed on all RMOD
                                   # - list of selected RMOD serial number separated by comma.
${RMOD_SHARING_INFO}          ALL  # RMOD sharing info : shared and/or dedicated RMOD for lock/unlock operations. Possible values (by default ALL):
                                   # - ALL: action will be performed on shared and dedicated RMOD
                                   # - shared: action will be performed only on shared RMOD
                                   # - dedicated: action will be performed only on dedicated RMOD
${RMOD_LOCK_MAX_WAIT_TIME}    300  # Maximum time to wait for complete lock RMOD operation (RMOD and mapped cells status)
${RMOD_UNLOCK_MAX_WAIT_TIME}  300  # Maximum time to wait for complete unlock RMOD operation (RMOD and mapped cells status)
${LTE_IOT_check}             True  # Only for classical BTS RAT LTE. Specify in case of configured LTE IOT cells if their status
                                   # will be checked (True) or skipped (False) after RM Lock Unlock. By default True

*** Keywords ***
TC__CBTS_SBTS__STATE__RM_LockUnlock
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27563
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for Lock/Unlock RMOD, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), RMOD sharing info info, RAT cells (per BTS alias)
    ...  - perform Lock/Unlock RMOD from BTS primary controller checking states and alarms
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Lock/Unlock RMOD operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27563 - [CBTS][CLOUD_CLASSICAL][CB008388] P3 New TC Cloud_Classical_RM_Lock_Unlock
    ...  - 24.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27825 - [CNI-127210][Part 2] MIMO remove EXPECTED minor alarm from NR_* TCs
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27890 - [CBTS] Add ${tech_preset_list} in TC Setup for CBTS_SBTS tests
    ...  - 04.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28104 - [CBTS]_Some CBTS SBTS Tests are failed due to IoT Cells
    ...  - 19.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28781 -
    ...  NRL__STATE__NR_RM_LockUnlock_from_WEBEM,fails after LTE Standalone IoT Check
    ...  - 02.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28981 - Possible bug in rm lock/unlock regarding reading IOT cell
    ...  - 12.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29309 - CBTS_SBTS__STATE__RM_LockUnlock Enhancement
    ...

    Set Tags    CA-STATE    OWNER-daniel-cristinel.hauca@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Lock Unlock RMOD on cloud BTS
        Step 5: Perform Lock Unlock RMOD on classical BTS
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check ${when} all BTS states  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} state *****  console=True
        ...  AND  Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
        ...  AND  Log  ${alias} BTS site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} state *****  console=True
        ...  AND  Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        ...  AND  Admin Check BTS Procedural and Blocking states  exp_pro_state=${OnAir_}  exp_blk_state=${Unblocked_}  timeout=600  alias=${alias}
        ...  AND  Log  ${alias} BTS site - Procedural State: OnAir, Blocking State: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms CBTS  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    Run Keyword If  '${RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check RMOD serial number list

    Log  ========================================================  console=True
    Log  RMOD serial number list selected for Lock/Unlock action: ${RMOD_all_sn_list}  console=True
    Log  ========================================================  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    Set Test Variable  ${CBTS_RMOD_state_locked}  Operational state=Enabled, Availability status=Online, Administrative state=Locked
    Set Test Variable  ${CBTS_RMOD_state_unlocked}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_CELL_state_dependency}
    ...  Operational state=Disabled, Availability status=Dependency, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_CELL_state_failed}
    ...  Operational state=Disabled, Availability status=Failed, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_locked_check}  operationalState=${Enabled_}, administrativeState=${Locked_}
    Set Test Variable  ${SBTS_RMOD_state_locked}  operationalState=Enabled, administrativeState=Locked
    Set Test Variable  ${SBTS_RMOD_state_unlocked_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_unlocked}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${SBTS_CELL_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled_degraded}  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    Set Test Variable  ${SBTS_CELL_state_disabled_offline_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_disabled_offline}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Unblocked
    Set Test Variable  ${SBTS_CELL_state_disabled_failed_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_disabled_failed}  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    Set Test Variable  ${SBTS_CELL_state_disabled_dependency_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Dependency_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_disabled_dependency}  operationalState=Disabled, availabilityStatus=Dependency, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}
        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS']
        ...  Get SBTS Cell info  ${alias}
    END

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

Step ${index}: Perform Lock Unlock RMOD on cloud BTS
    Log  Step ${index}: Perform Lock Unlock RMOD on cloud BTS  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        Log  ***** Perform Lock Unlock RMOD on ${alias} BTS *****  console=True

        Perform Lock Unlock CBTS VDU RMOD  ${alias}

    END

Step ${index}: Perform Lock Unlock RMOD on classical BTS
    Log  Step ${index}: Perform Lock Unlock RMOD on classical BTS  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' not in ['NR', 'LTE', 'SBTS']
        Log  ***** Perform Lock Unlock RMOD on ${alias} BTS *****  console=True

        Perform Lock Unlock SBTS RMOD  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get SBTS Cell info
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Check RMOD serial number list
    ${RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SERIAL_NUMBER_LIST}=  Split String  ${RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalide_list}=  Create List

    FOR  ${item}  IN  @{RMOD_SERIAL_NUMBER_LIST}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${RMOD_all_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${RMOD_all_sn_list}  Append To List  ${RMOD_sn_invalide_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RMOD serial number values are not valid: ${RMOD_sn_invalide_list}. Please select values for test
    ...  argument \${RMOD_SERIAL_NUMBER_LIST} from configured RMOD: ${RMOD_all_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${RMOD_all_sn_list}  ${RMOD_SERIAL_NUMBER_LIST}
    Sort List  ${RMOD_all_sn_list}

Perform Lock Unlock CBTS VDU RMOD
    [Arguments]  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${vdu_alias}
        ${VDU_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${VDU_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        Sort List  ${VDU_primary_controller_RMOD_sn_list}
        Sort List  ${VDU_secondary_controller_RMOD_sn_list}
        ${VDU_primary_controller_RMOD_sn_count}=  Get Length  ${VDU_primary_controller_RMOD_sn_list}
        ${VDU_secondary_controller_RMOD_sn_count}=  Get Length  ${VDU_secondary_controller_RMOD_sn_list}

        Return From Keyword If  ${VDU_primary_controller_RMOD_sn_count} == 0

        Set Test Variable  ${${vdu_alias}_primary_controller_RMOD_sn_list}  ${VDU_primary_controller_RMOD_sn_list}
        Set Test Variable  ${${vdu_alias}_secondary_controller_RMOD_sn_list}  ${VDU_secondary_controller_RMOD_sn_list}

        ${VDU_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${vdu_alias}
        Sort List  ${VDU_RMOD_sn_list}

        Lock Unlock CBTS VDU RMOD  ${VDU_RMOD_sn_list}  ${vdu_alias}

    END

Perform Lock Unlock SBTS RMOD
    [Arguments]  ${alias}

    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    Sort List  ${BTS_primary_controller_RMOD_sn_list}
    Sort List  ${BTS_secondary_controller_RMOD_sn_list}
    ${BTS_primary_controller_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_RMOD_sn_list}
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}

    Return From Keyword If  ${BTS_primary_controller_RMOD_sn_count} == 0

    Set Test Variable  ${${alias}_primary_controller_RMOD_sn_list}  ${BTS_primary_controller_RMOD_sn_list}
    Set Test Variable  ${${alias}_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}

    ${SBTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
    Sort List  ${SBTS_RMOD_sn_list}

    Lock Unlock SBTS RMOD  ${SBTS_RMOD_sn_list}  ${alias}

Lock Unlock CBTS VDU RMOD
    [Arguments]  ${VDU_RMOD_sn_list}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_RMOD_sn_list}

        Continue For Loop If  '${item}' not in ${RMOD_all_sn_list} or '${item}' not in ${${vdu_alias}_primary_controller_RMOD_sn_list}

        Run Keyword If  '${RMOD_SHARING_INFO}' in ['ALL','shared'] and '${item}' in ${shared_RMOD_sn_list}  Run Keywords
        ...  Lock CBTS VDU shared RMOD  ${item}  ${vdu_alias}
        ...  AND  Unlock CBTS VDU shared RMOD  ${item}  ${vdu_alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${vdu_alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${peer_BTS_alias}

        Run Keyword If  '${RMOD_SHARING_INFO}' in ['ALL','dedicated'] and '${item}' in ${dedicated_RMOD_sn_list}  Run Keywords
        ...  Lock CBTS VDU dedicated RMOD  ${item}  ${vdu_alias}
        ...  AND  Unlock CBTS VDU dedicated RMOD  ${item}  ${vdu_alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${vdu_alias}

    END

Lock Unlock SBTS RMOD
    [Arguments]  ${SBTS_RMOD_sn_list}  ${alias}

    FOR  ${item}  IN  @{SBTS_RMOD_sn_list}

        Continue For Loop If  '${item}' not in ${RMOD_all_sn_list} or '${item}' not in ${${alias}_primary_controller_RMOD_sn_list}

        Run Keyword If  '${RMOD_SHARING_INFO}' in ['ALL','shared'] and '${item}' in ${shared_RMOD_sn_list}  Run Keywords
        ...  Lock SBTS shared RMOD  ${item}  ${alias}
        ...  AND  Unlock SBTS shared RMOD  ${item}  ${alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${peer_BTS_alias}

        Run Keyword If  '${RMOD_SHARING_INFO}' in ['ALL','dedicated'] and '${item}' in ${dedicated_RMOD_sn_list}  Run Keywords
        ...  Lock SBTS dedicated RMOD  ${item}  ${alias}
        ...  AND  Unlock SBTS dedicated RMOD  ${item}  ${alias}
        ...  AND  Check RMOD reset behavior on BTS  ${item}  ${alias}

    END

Lock CBTS VDU shared RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${vdu_alias}

    Log  Perform "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias}   console=True

    Get Current Time  initial
    VDU Lock RMOD  rmod_id_list=${${vdu_alias}_RMOD_id_list}  timeout=${RMOD_LOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${vdu_alias}
    ...  lock_triggered_from=${vdu_alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}
    ...  lock_triggered_from=${vdu_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${peer_BTS_alias}
    ...  lock_triggered_from=${vdu_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${vdu_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${vdu_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${vdu_alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${vdu_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unlock CBTS VDU shared RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${vdu_alias}

    Log  Perform "Unlock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias}   console=True

    Get Current Time  initial
    VDU Unlock RMOD  rmod_id_list=${${vdu_alias}_RMOD_id_list}  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${vdu_alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${peer_BTS_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${vdu_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${vdu_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${vdu_alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${vdu_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Lock CBTS VDU dedicated RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${vdu_alias}

    Log  Perform "Lock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias}   console=True

    Get Current Time  initial
    VDU Lock RMOD  rmod_id_list=${${vdu_alias}_RMOD_id_list}  timeout=${RMOD_LOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after lock dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=dedicated  vdu_alias=${vdu_alias}
    ...  lock_triggered_from=${vdu_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Lock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${vdu_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${vdu_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${vdu_alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${vdu_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unlock CBTS VDU dedicated RMOD
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${vdu_alias}

    Log  Perform "Unlock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${vdu_alias}   console=True

    Get Current Time  initial
    VDU Unlock RMOD  rmod_id_list=${${vdu_alias}_RMOD_id_list}  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after unlock dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check cloud BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=dedicated  vdu_alias=${vdu_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Unlock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${vdu_alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${vdu_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${vdu_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${vdu_alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${vdu_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${${vdu_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Lock SBTS shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  Perform "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} BTS   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    coam.Lock  dist_name=${${alias}_RMOD_id}  timeout=${RMOD_LOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${alias}
    ...  lock_triggered_from=${alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms after lock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}
    ...  lock_triggered_from=${alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${peer_BTS_alias}
    ...  lock_triggered_from=${alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Lock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unlock SBTS shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  Perform "Unlock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} BTS   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    coam.Unlock  dist_name=${${alias}_RMOD_id}  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${alias}
    Log  Check ${peer_BTS_alias} BTS state and alarms after unlock shared RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Run Keyword If  '${peer_BTS_alias}' in ${alias_list}
    ...  Check classical BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  alias=${peer_BTS_alias}
    ...  ELSE
    ...  Check cloud BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=shared  vdu_alias=${peer_BTS_alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Unlock" operation on shared RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${peer_BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${peer_BTS_alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${peer_BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${peer_BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${peer_BTS_LTE_IOT_CELL_ids_list}
    ...  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ...  ${peer_BTS_alias}=${peer_BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Lock SBTS dedicated RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  Perform "Lock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} BTS   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    coam.Lock  dist_name=${${alias}_RMOD_id}  timeout=${RMOD_LOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} state and alarms after lock dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms after lock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=dedicated  alias=${alias}
    ...  lock_triggered_from=${alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Lock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unlock SBTS dedicated RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    Log  Perform "Unlock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn} from ${alias} BTS   console=True

    Get Current Date UTC info  initial
    Get Current Time  initial
    coam.Unlock  dist_name=${${alias}_RMOD_id}  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} state and alarms after unlock dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}  console=True
    Check classical BTS states and alarms after unlock RMOD  RMOD_sn=${RMOD_sn}  sharing_info=dedicated  alias=${alias}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all cloud/classical BTS other cells are not impacted by "Unlock" operation on dedicated RMOD ${RMOD_pn} with SN ${RMOD_sn}
    ...  from ${alias}  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_NR_CELL_ids_list}
    ${BTS_LTE_IOT_CELL_ids_list}=  Create List
    FOR  ${LTE_CELL_id}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}
        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}
    END
    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_LTE_CELL_ids_exempted_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_RMOD_GSM_CELL_ids_list}
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    ${RMOD_id_list}=  Create List  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id}  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id_list}  ${RMOD_id_list}
    ${RMOD_pn}=  Get From Dictionary  ${${alias}_RMOD_sn_pn_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_pn}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${alias}_RMOD_id}
    Set Test Variable  ${${alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_IOT_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}
    Return From Keyword If  ${RMOD_BTS_alias_count} == 1

    ${RMOD_peer_BTS_alias_list}=  Copy List  ${RMOD_BTS_alias_list}
    Remove Values From List  ${RMOD_peer_BTS_alias_list}  ${alias}
    ${peer_BTS_alias}=  Get From List  ${RMOD_peer_BTS_alias_list}  0
    Set Test Variable  ${peer_BTS_alias}
    ${RMOD_id}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_id}  ${RMOD_id}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${peer_BTS_alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_IOT_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_interface}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_interface}

Check cloud BTS states and alarms after lock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${vdu_alias}  ${lock_triggered_from}

    Log  Check ${vdu_alias} ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_LOCK_MAX_WAIT_TIME}
    Check CBTS VDU RMOD state  ${RMOD_sn}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Locked_}  ${CBTS_RMOD_state_locked}  ${remained_MAX_WAIT_TIME}
    ...  ${vdu_alias}

    Log  Check ${vdu_alias} cells mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_LOCK_MAX_WAIT_TIME}
    Run Keyword If  '${lock_triggered_from}' != '${vdu_alias}'  Check CBTS VDU RMOD cell state  ${RMOD_sn}  ${${vdu_alias}_RMOD_NR_CELL_ids_list}
    ...  ${CBTS_Disabled_}  ${CBTS_Failed_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}  ${CBTS_CELL_state_failed}  ${remained_MAX_WAIT_TIME}
    ...  ${vdu_alias}  lock
    ...  ELSE
    ...  Check CBTS VDU RMOD cell state  ${RMOD_sn}  ${${vdu_alias}_RMOD_NR_CELL_ids_list}  ${CBTS_Disabled_}  ${CBTS_Dependency_}  ${CBTS_Unlocked_}
    ...  ${CBTS_Unblocked_}  ${CBTS_CELL_state_dependency}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}  lock

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    ${VDU_EXPECTED_ALARMS_full}=  Create List
    Run Keyword If  '${lock_triggered_from}' != '${vdu_alias}'  Append To List  ${VDU_EXPECTED_ALARMS_full}
    ...  @{${vdu_alias_alarm.upper()}_EXPECTED_ALARMS_1931}

    Run Keyword If  '${lock_triggered_from}' != '${vdu_alias}'
    ...  Log  ${vdu_alias} "RF Module blocked (1931)" alarm, expected number: 1  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=${VDU_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${lock_triggered_from}' != '${vdu_alias}'
    ...  Log  ${vdu_alias} "RF Module blocked (1931)" alarm, found number: 1, as expected!  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after unlock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${vdu_alias}

    Log  Check ${vdu_alias} ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check CBTS VDU RMOD state  ${RMOD_sn}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_RMOD_state_unlocked}
    ...  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} cells mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check CBTS VDU RMOD cell state  ${RMOD_sn}  ${${vdu_alias}_RMOD_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}
    ...  ${CBTS_Unblocked_}  ${CBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}  unlock

    Get Current Time  final

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms after lock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${alias}  ${lock_triggered_from}

    Log  Check ${alias} BTS ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_LOCK_MAX_WAIT_TIME}
    Check SBTS RMOD state  ${RMOD_sn}  ${SBTS_RMOD_state_locked_check}  ${SBTS_RMOD_state_locked}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS cells status mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on RMOD  ${alias}  ${lock_triggered_from}

    Log  Check ${alias} BTS alarms:  console=True
    ${SBTS_EXPECTED_ALARMS_full}=  Create List
    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_4003}  ${${alias.upper()}_IGNORED_ALARMS}
    Run Keyword If  '${lock_triggered_from}' != '${alias}'  Append To List  ${SBTS_EXPECTED_ALARMS_full}  @{${alias.upper()}_EXPECTED_ALARMS_1931}

    Run Keyword If  '${lock_triggered_from}' != '${alias}'
    ...  Log  ${alias} BTS "RF Module blocked (1931)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${SBTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${lock_triggered_from}' != '${alias}'
    ...  Log  ${alias} BTS "RF Module blocked (1931)" alarm, found number: 1, as expected!  console=True
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms after unlock RMOD
    [Arguments]  ${RMOD_sn}  ${sharing_info}  ${alias}

    Log  Check ${alias} BTS ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check SBTS RMOD state  ${RMOD_sn}  ${SBTS_RMOD_state_unlocked_check}  ${SBTS_RMOD_state_unlocked}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS cells mapped on ${sharing_info} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    Check SBTS RMOD cell state  ${RMOD_sn}  ${${alias}_RMOD_NR_CELL_ids_list}  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${${alias}_RMOD_GSM_CELL_ids_list}  ${SBTS_CELL_state_enabled_check}
    ...  ${SBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check CBTS VDU RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_operational_state_check}  ${RMOD_availability_status_check}  ${RMOD_administrative_state_check}
    ...  ${RMOD_state}  ${timeout}  ${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RMOD Expected Status  rmod_id=${${vdu_alias}_RMOD_id}
    ...  operational_state=${RMOD_operational_state_check}  availability_status=${RMOD_availability_status_check}
    ...  administrative_state==${RMOD_administrative_state_check}  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check CBTS VDU RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}
    ...  ${CELL_administrative_state_check}  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}  ${operation}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_${operation.upper()}_MAX_WAIT_TIME}

    END
    Log  ${vdu_alias} cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check SBTS RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}
    Assert  class_name=RMOD  id=${${alias}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  ${alias} BTS RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check SBTS RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}
        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_LTE_CELL_ids}
        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_WCDMA_CELL_ids}
        Assert  class_name=WNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    FOR  ${item}  IN  @{RMOD_GSM_NR_CELL_ids}
        Assert  class_name=GNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${RMOD_UNLOCK_MAX_WAIT_TIME}
    END

    Log  ${alias} BTS cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check cells state mapped on RMOD
    [Arguments]  ${alias}  ${lock_triggered_from}

    ${SBTS_LTE_IOT_SA_CELL_state_check}=  Set Variable If  '${lock_triggered_from}' == '${alias}'  ${SBTS_CELL_state_disabled_dependency_check}
    ...  ${SBTS_CELL_state_disabled_failed_check}
    ${SBTS_LTE_IOT_SA_CELL_state}=  Set Variable If  '${lock_triggered_from}' == '${alias}'  ${SBTS_CELL_state_disabled_dependency}
    ...  ${SBTS_CELL_state_disabled_failed}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_RMOD_NR_CELL_ids_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_RMOD_LTE_CELL_ids_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_WCDMA_CELL_ids_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_RMOD_WCDMA_CELL_ids_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_GSM_CELL_ids_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_RMOD_GSM_CELL_ids_list}  alias=${alias}

    Return From Keyword If  '${LTE_IOT_check}' != 'True'

    FOR  ${item}  IN  @{${alias}_RMOD_LTE_IOT_SA_CELL_ids_list}

        Assert  class_name=LNCEL  id=${item}  parameters=${SBTS_LTE_IOT_SA_CELL_state_check}  connection=${alias}
        Log  ${alias} LNCEL ${item} status:\n - ${SBTS_LTE_IOT_SA_CELL_state}  console=True

    END

    FOR  ${item}  IN  @{${alias}_RMOD_LTE_CELL_ids_list}

        ${LTE_IOT_CELL_check}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  not ${LTE_IOT_CELL_check}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  '${LTE_IOT_CELL_id}' == 'None'

        ${LTE_CELL_info}=  Assert  class_name=LNCEL  id=${item}  connection=${alias}
        ${LTE_CELL_operationalState}=  Get From Dictionary  ${LTE_CELL_info}  operationalState
        ${LTE_IOT_CELL_state_check}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${SBTS_CELL_state_disabled_offline_check}
        ...  ${SBTS_CELL_state_enabled_degraded_check}
        ${LTE_IOT_CELL_state}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${SBTS_CELL_state_disabled_offline}
        ...  ${SBTS_CELL_state_enabled_degraded}

        Assert  class_name=LNCEL  id=${LTE_IOT_CELL_id}  parameters=${LTE_IOT_CELL_state_check}  connection=${alias}
        Log  ${alias} LNCEL ${LTE_IOT_CELL_id} status:\n - ${LTE_IOT_CELL_state}  console=True

    END

Check RMOD reset behavior on BTS
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    ${RMOD_Uptime_initial}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_initial}  ${RMOD_sn}
    ${RMOD_Uptime_final}=  Get From Dictionary  ${RMOD_sn_Uptime_dict_final}  ${RMOD_sn}

    Log  Expecting RMOD with SN ${RMOD_sn} didn't reset on BTS ${alias}  console=True

    ${RMOD_Uptime_delta}=  Evaluate  ${RMOD_Uptime_final}-${RMOD_Uptime_initial}
    ${Uptime_log}=  Set Variable  (initial/final RMOD witn SN ${RMOD_sn} Uptime: ${RMOD_Uptime_initial} secs/${RMOD_Uptime_final} secs)

    Run Keyword If  ${RMOD_Uptime_delta} > 0
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior as expected ${Uptime_log}!  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected ${Uptime_log}!  level=ERROR
    ...  AND  Fail  BTS ${alias} RMOD_${RMOD_sn} reset behavior not as expected  ${Uptime_log}!

Check if all BTS RMODs are unlocked

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Check if CBTS VDU RMODs are unlocked  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Admin Check If BTS Objects Are Unlocked  class_name=RMOD  timeout=60  recover_timeout=60  connection=${alias}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS RMODs are unlocked

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
