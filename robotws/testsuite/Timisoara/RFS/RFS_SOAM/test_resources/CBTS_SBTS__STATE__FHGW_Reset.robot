*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__FHGW_Reset
Variables    tc_variables/cbts_sbts__state__fhgw_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}       3    # Number of Reset FHGW operations, default value 3
${FHGW_ID_CUSTOM_LIST}  ALL  # Custom FHGW id list on which reset operation will be performed. Possible values (by default ALL):
                             # - ALL: action will be performed on all FHGW defined in init.py
                             # - list of selected FHGW id separated by comma.
${BTS_MAX_WAIT_TIME}    900  # Maximum time to wait for BTS OnAir after reset (by default 900)

*** Keywords ***
TC__CBTS_SBTS__STATE__FHGW_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27712
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for Reset FHGW, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: RMOD sharing info
    ...  - perform Reset FHGW checking states and alarms
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Reset FHGW operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27712 - [CBTS][Cloud_Classical][CB008388] P3 -New TC Cloud_Classical_FHGW_Reset
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27890 - [CBTS] Add ${tech_preset_list} in TC Setup for CBTS_SBTS tests
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28029 - [CBTS] Robot CBTS_SBTS__STATE__FHGW_Reset fails due to wrong checks
    ...  - 22.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28227 -
    ...  [CBTS] CBTS_SBTS__STATE__FHGW_Reset - Refactor after delivery of TAT-27753 - FHGW info from init.py
    ...  - 28.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29957 -
    ...  Enhancement for [1]CBTS_SBTS__STATE__FHGW_Reset for configurations where not all RMODs are connected to FHGW - after TAT-29959
    ...

    Set Tags    CA-STATE    OWNER-daniel-cristinel.hauca@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Reset FHGW operation
        Step 5: Check final all BTS states
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

TC Preconditions
    ${FHGW_id_list}=  Get configured FHGW id list from init file
    Set Test Variable  ${FHGW_id_list}

    Run Keyword If  '${FHGW_ID_CUSTOM_LIST}' != 'ALL'  Check FHGW id list

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
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_all_alias_list}

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Perform Reset FHGW operation
    Log  Step ${index}: Perform Reset FHGW operation  console=True

    FOR  ${FHGW_id}  IN  @{FHGW_id_list}

        Reset FHGW operation  ${FHGW_id}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check FHGW id list
    ${FHGW_ID_CUSTOM_LIST_strip}=  Replace String  ${FHGW_ID_CUSTOM_LIST}  ${SPACE}  ${EMPTY}
    ${FHGW_id_list_custom}=  Split String  ${FHGW_ID_CUSTOM_LIST_strip}  ,
    ${FHGW_id_check}=  Set Variable  True
    ${FHGW_id_invalid_list}=  Create List

    FOR  ${FHGW_id}  IN  @{FHGW_id_list_custom}

        ${FHGW_id_check}=  Set Variable If  '${FHGW_id}' not in ${FHGW_id_list}  False  ${FHGW_id_check}

        Run Keyword If  '${FHGW_id}' not in ${FHGW_id_list}  Append To List  ${FHGW_id_invalid_list}  ${FHGW_id}

    END

    Run Keyword If  '${FHGW_id_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected FHGW id values are not valid: ${FHGW_id_invalid_list}. Please select values for test argument
    ...  \${FHGW_ID_CUSTOM_LIST} from configured FHGW id in init.py file: ${FHGW_id_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${FHGW_id_list}  ${FHGW_id_list_custom}

Reset FHGW operation
    [Arguments]  ${FHGW_id}

    Log  ***** Perform Reset FHGW_${FHGW_id} operation *****  console=True

    ${FHGW_alias}=  Set Variable  FHGW_${FHGW_id}_reset
    ${command}=  Set Variable  sudo systemctl reboot

    ${FHGW_ip}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  IP
    ${FHGW_RMOD_sn_list}=  Get configured FHGW RMOD sn list from init file  ${FHGW_id}
    ${FHGW_RMOD_sn_count}=  Get Length  ${FHGW_RMOD_sn_list}
    Set Test Variable  ${FHGW_${FHGW_id}_RMOD_sn_list}  ${FHGW_RMOD_sn_list}
    Set Test Variable  ${FHGW_${FHGW_id}_RMOD_sn_count}  ${FHGW_RMOD_sn_count}

    Get classical BTS shared RMOD synchronisation info  ${FHGW_RMOD_sn_list}

    Log  Setup connection to FHGW_${FHGW_id}  console=True
    FHGW Setup Connection  FHGW_id=${FHGW_id}  alias=${FHGW_alias}

    Log  Perform reset FHGW_${FHGW_id} by local command on FHGW: ${command}  console=True
    Get Current Time  initial
    fhgw.Execute  command=${command}  check_result=${False}  alias=${FHGW_alias}

    Log  Check BTS alarms during reset FHGW_${FHGW_id}  console=True
    Check BTS alarms during reset FHGW operation  ${FHGW_id}

    Log  Check BTS status and alarms after reset FHGW_${FHGW_id}  console=True
    Wait For Target To Be Reachable TAF  hostname=${FHGW_ip}  timeout=900
    Check BTS states and alarms after reset FHGW operation

    [Teardown]  FHGW Teardown Connection  FHGW_id=${FHGW_id}  alias=${FHGW_alias}


Get classical BTS shared RMOD synchronisation info
    [Arguments]  ${FHGW_RMOD_sn_list}

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Continue For Loop If  '${alias}' not in ${alias_list}

        ${CPRI_shared_RMOD_sn_SYNC_loss_list}  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}=
        ...  Get classical BTS shared RMOD synchronisation impact due to reset FHGW operation  ${FHGW_RMOD_sn_list}  ${RMOD_sn_BTS_alias_dict}
        ...  ${alias}
        Set Test Variable  ${${alias}_CPRI_shared_RMOD_sn_SYNC_loss_list}  ${CPRI_shared_RMOD_sn_SYNC_loss_list}
        Set Test Variable  ${${alias}_ECPRI_shared_RMOD_sn_SYNC_loss_list}  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}

    END

Check BTS alarms during reset FHGW operation
    [Arguments]  ${FHGW_id}

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS alarms during reset FHGW operation  alias=${alias}

    END

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' not in ${alias_list}
        ...  Check cloud BTS alarms during reset FHGW operation  FHGW_id=${FHGW_id}  vdu_alias=${alias}

    END

Check classical BTS alarms during reset FHGW operation
    [Arguments]  ${alias}
    ${CPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${${alias}_CPRI_shared_RMOD_sn_SYNC_loss_list}
    ${ECPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${${alias}_ECPRI_shared_RMOD_sn_SYNC_loss_list}

    ${SBTS_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10_1815}
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}
    ${SBTS_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_16}
    ...  ${ECPRI_shared_RMOD_sn_SYNC_loss_count}
    ${SBTS_EXPECTED_ALARMS_full}=  Combine Lists  ${SBTS_EXPECTED_ALARMS_10_1815_full}  ${SBTS_EXPECTED_ALARMS_16_full}
    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_4220}

    Log  Check ${alias} BTS alarms:  console=True
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log Long String  ${alias} BTS "Not able to synchronize baseband bus (1815) or No connection to Unit (10)" alarm, expected number:
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${alias} BTS "Unit synchronization failed (16)" alarm, expected number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=@{SBTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log Long String  ${alias} BTS "Not able to synchronize baseband bus (1815) or No connection to Unit (10)" alarm, found number:
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${alias} BTS "Unit synchronization failed (16)" alarm, found number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!
    ...  console=True
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check cloud BTS alarms during reset FHGW operation
    [Arguments]  ${FHGW_id}  ${vdu_alias}

    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _

    ${VDU_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${vdu_alias_alarm.upper()}_EXPECTED_ALARMS_10}  ${FHGW_${FHGW_id}_RMOD_sn_count}
    ${VDU_IGNORED_ALARMS_full}=  Combine Lists  ${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  ${${vdu_alias_alarm.upper()}_IGNORED_ALARMS_4220}

    Log  Check ${vdu_alias} alarms:  console=True
    Log  ${vdu_alias} "No connection to Unit (10)" alarm, expected number: ${FHGW_${FHGW_id}_RMOD_sn_count}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{VDU_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${VDU_IGNORED_ALARMS_full}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} "No connection to Unit (10)" alarm, found number: ${FHGW_${FHGW_id}_RMOD_sn_count}, as expected!  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms after reset FHGW operation

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS states and alarms after reset FHGW operation  alias=${alias}
        ...  ELSE
        ...  Check cloud BTS states and alarms after reset FHGW operation  vdu_alias=${alias}

    END

Check classical BTS states and alarms after reset FHGW operation
    [Arguments]  ${alias}

    Log  Check ${alias} BTS status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${alias} BTS cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after reset FHGW operation
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  VDU Check VDU Expected Status  operational_state=${CBTS_OnAir_}
    ...  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${CBTS_VDU_state_onair}  console=True

    Log  Check ${vdu_alias} RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all RMODs expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} RMODs status:\n - ${CBTS_VDU_RMOD_state_enabled}  console=True

    Log  Check ${vdu_alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all cells expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status:\n - ${CBTS_VDU_CELL_state_enabled}  console=True

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
