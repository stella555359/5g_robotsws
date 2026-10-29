*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts__state__sharedrm_lockunlock_cell_blockunblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3     # Number of RM Lock/Unlock Cell Block/Unblock operations, default value 3
${RM_MAX_WAIT_TIME}   900  # Maximum time for wait of BTS OnAir (first cell up after RM unlock). If this value is exceeded, test will fail
${CELL_MAX_WAIT_TIME}    200  # Maximum waiting time for cell to be blocked/unblocked; default value 200 seconds

*** Keywords ***
TC__SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23508
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for SharedRM Lock/Unlock Cell Block/Unblock on all BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get cells info on all BTS
    ...  - perform Lock/Unlock RMODs and Block/Unblock cells on all BTS checking alarms and state;
    ...  for each BTS
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: RM Lock/Unlock and Cell Block/Unblock operation works as expected; states and alarms are as expected
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 07.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23508 - [5G][CB007588]
    ...  SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23834 - [5G] Common part fails for SBTS_SBTS_SBTS configuration
    ...  - 19.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23834 - [5G] Remove FID10 expectation from secondary controller
    ...  SBTS_SBTS_SBTS_STATE_SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26223 - [5G] Robots should skip check states on IoT cells
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 16.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26404 - [5G][CB007184] Adapt
    ...  SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM for CB007184
    ...  - 09.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26586 - [5G]Update in TCs handling of Admin Get LTE HOST and IOT Cell(s) Id list,
    ...  for KW returning Empty list instead of None - SBTS_SBTS_SBTS
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27819 - [CNI-127210][Part 1] MIMO remove EXPECTED minor alarm from SBTS_* TCs
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23508_SBTS_SBTS_SBTS__STATE__SharedRM_LockUnlock_Cell_BlockUnblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-adrian.ierulescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS23R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared RM and cells info on all BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform shared RM and cell operations for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get shared RM and cells info on all BTS
    [Documentation]
    ...  Get shared RM and cells info on all BTS

    Log  Step ${index}: Get shared RM and cells info on all BTS  console=True
    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_radioMaster_RM_list}=  Get RMOD radioMaster info  ${alias}
        Set Test Variable  ${${alias}_radioMaster_RM_list}  ${BTS_radioMaster_RM_list}
        Get BTS CELL list by RAT  ${alias}
    END

Step ${index}: Perform shared RM and cell operations for iteration ${CYCLE}
    [Documentation]
    ...  Get shared RM and cell info from connected BTSs and perform lock/unlock and block/unblock operations

    Log  Step ${index}: Perform shared RM and cell operations for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{alias_list}
        Perform shared RM and cell operations  ${alias}
    END

Perform shared RM and cell operations
    [Arguments]  ${alias}

    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    FOR  ${RM_id}  IN  @{${alias}_radioMaster_RM_list}
        Log  Perform Lock Unlock operations on ${RM_id} from ${alias} BTS  console=True
        ${RM_SN}=  Get From Dictionary  ${${alias}_RM_id_sn_dict}  ${RM_id}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_SN}
        Remove Values from list  ${RM_bts-alias_list}  ${alias}
        ${peer_alias}=  Get From List  ${RM_bts-alias_list}  0
        ${peer_RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_SN}
        Get shared RM all cells from specific RAT  ${RM_id}  ${alias}
        Get shared RM all cells from specific RAT  ${peer_RM_id}  ${peer_alias}
        Lock RM  ${RM_SN}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}
        Block RM Cells  ${alias}
        Unlock RM  ${RM_SN}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}
        Unblock RM Cells  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Lock RM
    [Arguments]  ${RM_SN}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    ${RM_state_locked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Locked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, blockingState=${Unblocked_}
    ${RM_state_locked}=  Set Variable  operationalState=Enabled, administrativeState=Locked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, blockingState=Unblocked

    Log  Perform Lock ${RM_id}(SN: ${RM_SN}) from BTS ${alias}  console=True

    coam.Lock  ${RM_id}  timeout=60  connection=${alias}
    Get Current Time  rm_initial

    Check RM state  ${RM_SN}  ${RM_id}  ${RM_state_locked_check}  ${RM_state_locked}  ${alias}
    Check RM state  ${RM_SN}  ${peer_RM_id}  ${RM_state_locked_check}  ${RM_state_locked}  ${peer_alias}

    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${alias}
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${peer_alias}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

    ${peer_SBTS_IGNORED_ALARMS}=  Combine Lists  ${SBTS_${peer_alias.upper()}_IGNORED_ALARMS_4003}  ${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}

    Log  BTS ${peer_alias} "RF Module blocked (1931)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${SBTS_${peer_alias.upper()}_EXPECTED_ALARMS_1931}
    ...  ignored_alarms=${peer_SBTS_IGNORED_ALARMS}  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} "RF Module blocked (1931)" alarm, found number: 1  console=True
    Log  ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Check cells state not mapped on shared RM  ${alias}  ${RM_SN}
    Check cells state not mapped on shared RM  ${peer_alias}  ${RM_SN}

Unlock RM
    [Arguments]  ${RM_SN}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    ${RM_state_unlocked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RM_state_unlocked}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  Perform Unlock ${RM_id}(SN: ${RM_SN}) from BTS ${alias}  console=True

    coam.Unlock  ${RM_id}  timeout=60  connection=${alias}
    Get Current Time  rm_initial

    Check RM state  ${RM_SN}  ${RM_id}  ${RM_state_unlocked_check}  ${RM_state_unlocked}  ${alias}
    Check RM state  ${RM_SN}  ${peer_RM_id}  ${RM_state_unlocked_check}  ${RM_state_unlocked}  ${peer_alias}
    Check RM all cells expected states  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${peer_alias}
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}

Block RM Cells
    [Arguments]  ${alias}
    Log  Perform Block all cells mapped on shared RM  console=True
    Set Test Variable  ${cells_blocked}  0
    FOR  ${item}  IN  @{${alias}_CELL_RM_list}
        Block RM cell  ${item}  ${alias}
    END

Unblock RM Cells
    [Arguments]  ${alias}
    Log  Perform Unblock all cells mapped on shared RM  console=True
    FOR  ${item}  IN  @{${alias}_CELL_RM_list}
        Unblock RM cell  ${item}  ${alias}
    END
    Check RM all cells expected states  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${alias}

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}=  Create List
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=
    ...  Admin Get LTE HOST and IOT Cell(s) Id list  ${LTE_CELL_list}  alias=${alias}
    ${LTE_HOST_CELL_ID_LIST}=  Run Keyword If  ${LTE_CELL_list}  Set Variable  ${LTE_HOST_CELL_ID_LIST}
    ...  ELSE  Create List
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    ...  ELSE  Create Dictionary
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}
    ${CELL_list}=  Combine Lists  ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}
    Log  BTS ${alias} cells found:  console=True
    Run Keyword If  ${${alias}_NR_CELL_list}  Log  - NRCEL: ${${alias}_NR_CELL_list}  console=True
    Run Keyword If  ${${alias}_LTE_CELL_list}  Log  - LNCEL: ${${alias}_LTE_CELL_list}  console=True
    Run Keyword If  ${${alias}_WCDMA_CELL_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_list}  console=True
    Run Keyword If  ${${alias}_GSM_CELL_list}  Log  - GNCEL: ${${alias}_GSM_CELL_list}  console=True

Block RM cell
    [Arguments]  ${cell_id}  ${alias}

    Set Test Variable  ${CELL_state_blocked_check}  operationalState=${Disabled_}, blockingState=${Blocked_}
    Set Test Variable  ${CELL_state_blocked}  operationalState=Disabled, blockingState=Blocked

    Log  Perform "Block" operation on BTS ${alias} cell ${cell_id}  console=True
    coam.Block Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
    ${LTE_IOT_cell}=  Run Keyword If  '${cell_id}' in ${${alias}_LTE_CELL_RM_list}
    ...  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}
    ...  ELSE  Set Variable  None
    ${cells_blocked}=  Run Keyword If  '${LTE_IOT_cell}' == 'None'  Evaluate  ${cells_blocked} + 1
    ...  ELSE IF  '${LTE_IOT_cell}' != 'None'  Evaluate  ${cells_blocked} + 2
    Set Test Variable  ${cells_blocked}
    Log  Check BTS ${alias} state and alarms after "Block" operation on BTS ${alias} cell ${cell_id}  console=True
    Check BTS cell state  ${cell_id}  ${CELL_state_blocked_check}  ${CELL_state_blocked}  ${CELL_MAX_WAIT_TIME}  ${alias}
    Check BTS alarms  ${alias}  ${cells_blocked}

Unblock RM cell
    [Arguments]  ${cell_id}  ${alias}

    Set Test Variable  ${CELL_state_unblocked_check}  blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_unblocked}  blockingState=Unblocked

    Log  Perform "Unblock" operation on BTS ${alias} cell ${cell_id}  console=True
    coam.Unblock Cell  dist_name=${cell_id}  timeout=${CELL_MAX_WAIT_TIME}  connection=${alias}
    ${LTE_IOT_cell}=  Run Keyword If  '${cell_id}' in ${${alias}_LTE_CELL_RM_list}
    ...  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}
    ...  ELSE  Set Variable  None
    ${cells_blocked}=  Run Keyword If  '${LTE_IOT_cell}' == 'None'  Evaluate  ${cells_blocked} - 1
    ...  ELSE IF  '${LTE_IOT_cell}' != 'None'  Evaluate  ${cells_blocked} - 2
    Set Test Variable  ${cells_blocked}
    Log  Check BTS ${alias} state and alarms after "Unblock" operation on BTS ${alias} cell ${cell_id}  console=True
    Check BTS cell state  ${cell_id}  ${CELL_state_unblocked_check}  ${CELL_state_unblocked}  ${CELL_MAX_WAIT_TIME}  ${alias}
    Check BTS alarms  ${alias}  ${cells_blocked}

Check BTS cell state
    [Arguments]  ${cell_id}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    ${cell_class_name}=  Set Variable If
    ...  '${cell_id}' in ${${alias}_NR_CELL_list}  NRCEL
    ...  '${cell_id}' in ${${alias}_LTE_CELL_list}  LNCEL
    ...  '${cell_id}' in ${${alias}_WCDMA_CELL_list}  WNCEL
    ...  '${cell_id}' in ${${alias}_GSM_CELL_list}  GNCEL

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} cell ${cell_id} status:\n - ${cell_state}  console=True
    Log  BTS ${alias} cell status as expected!  console=True

Check cells state mapped on shared RM
    [Arguments]  ${alias}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RM_list}
    ...   Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RM_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RM_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RM_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RM_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RM_list}  alias=${alias}

Check cells state not mapped on shared RM
    [Arguments]  ${alias}  ${RM_sn}

    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RM_sn}:\n - ${CELL_state_enabled}  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check RM state
    [Arguments]  ${RM_sn}  ${RM_id}  ${RM_state_check}  ${RM_state}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rm_initial}  ${RM_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RM with SN ${RM_sn} status:\n - ${RM_state}  console=True

Check BTS alarms
    [Arguments]  ${alias}  ${SBTS_alarm_count}

    ${SBTS_EXPECTED_ALARMS_49_multiplicated}=  Prepare expected alarms list
    ...  ${SBTS_${alias.upper()}_EXPECTED_ALARMS_49}  ${SBTS_alarm_count}
    Log  BTS ${alias} "Cell Blocked (49)" alarm, expected number: ${SBTS_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_49_multiplicated}
    ...  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "Cell Blocked (49)" alarm, found number: ${SBTS_alarm_count}, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Get shared RM all cells from specific RAT
    [Arguments]  ${RM_id}  ${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_NR_CELL_RM_list}  ${NR_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_list}  ${LTE_CELL_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RM_list}  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_RM_list}  ${GSM_CELL_RM_list}
    ${CELL_RM_list}=  Combine Lists  ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_CELL_RM_list}  ${CELL_RM_list}

    ${NR_CELL_not_RM_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${WCDMA_CELL_not_RM_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RM_list}=  Copy List  ${${alias}_GSM_CELL_list}
    FOR  ${item}  IN  @{${alias}_CELL_RM_list}
        Remove Values From List  ${NR_CELL_not_RM_list}  ${item}
        Remove Values From List  ${LTE_CELL_not_RM_list}  ${item}
        Remove Values From List  ${WCDMA_CELL_not_RM_list}  ${item}
        Remove Values From List  ${GSM_CELL_not_RM_list}  ${item}
    END
    Set Test Variable  ${${alias}_NR_CELL_not_RM_list}  ${NR_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}

Check RM all cells expected states
    [Arguments]  ${cell_state_expected_check}  ${cell_state_expected}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_rm_initial}  ${RM_MAX_WAIT_TIME}
    FOR  ${item}  IN  @{${alias}_CELL_RM_list}
        Check BTS cell state  ${item}  ${cell_state_expected_check}  ${cell_state_expected}  ${remained_MAX_WAIT_TIME}  ${alias}
    END

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Admin Check If BTS Objects Are Unlocked  class_name=RMOD  timeout=60  recover_timeout=60  connection=${alias}
        Admin Check if BTS cells are unblocked  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown