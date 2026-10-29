*** Settings ***
Documentation    TC__SBTS__STATE__RM_Energy_Saving_Mode_Activation
Variables    tc_variables/sbts__state__rm_energy_saving_mode_activation_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Library    taf.ul.energy_efficiency_monitoring  WITH NAME  eem

*** Variables ***
${REPEAT_COUNTER}              3          # Number of ESM operations on RMOD, default value 3
${RMOD_SERIAL_NUMBER}                     # RMOD serial number on which ESM operations will be performed.
${energySavingMode}            DEEPSLEEP  # Allows to set requested ESM on RMOD, default value DEEPSLEEP:
                                          # - DEEPSLEEP - deep sleep mode is activated on RMOD
                                          # - DEEPSLEEP_EXTREME_SFP - extreme deep sleep mode is activated on RMOD
${ESM_MAX_WAIT_TIME}           7500       # Maximum waiting time for ESM operations on RMOD; default value 7500 (seconds)
${PM_CHECK}                    True       # Specifies if check PM counters (NRCEL) M55601C01003 and M55601C01004  is requested. Possible values: True
                                          # or False; default value True
${PM_INTERVAL}                 15         # PM interval to get counters, default value 15 (minutes)
${L3_CALL_CHECK}               True       # Specifies if L3 call will be performed during ESM operations on RMOD. Possible values: True or False;
                                          # default value True
${L3_CALL_KW_INFO}             &{EMPTY}   # L3 call KW info as dictionary with following structure:
                                          # - 'KW_resource_path':<path to specific resource where external KW is defined>
                                          # - 'KW_name':<external L3 call KW name to be run>
                                          # - 'KW_impact':<impact of external L3 call KW run on testcase run>
${L3_CALL_KW_ARGUMENTS}        &{EMPTY}   # L3 call KW arguments as dictionary containing arguments info for external L3 call KW

*** Keywords ***
TC__SBTS__STATE__RM_Energy_Saving_Mode_Activation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28774
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for activate/deactivate ESM operations on RMOD, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get BTS info for requested RMOD
    ...  - perform call on requested RMOD before ESM operations (if requested)
    ...  - wait for start of PM period to perform ESM operations (if requested)
    ...  - set required ESM on RMOD
    ...  - activate ESM on RMOD by block all cells mapped on RMOD checking BTS states and alarms
    ...  - deactivate ESM on RMOD by unblock all cells mapped on RMOD checking BTS states and alarms
    ...  - perform call on requested RMOD after ESM operations (if requested)
    ...  - wait for end of PM period to collect and check counters after ESM operations (if requested)
    ...  - recover initial ESM on RMOD
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: RMOD Energy Saving Mode Activation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28774 - [CB011167] RM_activation_DSM_or_EDSM (deep sleep/extreme deep sleep)
    ...  - 29.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29758 -
    ...  Dictionary does not contain key 'BTS' during SBTS__STATE__RM_Energy_Saving_Mode_Activation Saving Mode Activation
    ...  - 05.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30233 - Pipeline failed on robotws with DryRunSuite error
    ...

    Set Tags    CA-STATE    OWNER-carla-iazmina.urezeanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Perform call on requested RMOD before ESM operations
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Set required ESM on RMOD
        Step 6: Activate ESM on RMOD by block all cells mapped on RMOD
        Step 7: Deactivate ESM on RMOD by unblock all cells mapped on RMOD
        Step 8: Perform call on requested RMOD after ESM operations
        Step 9: Check PM counters after ESM operations
        Step 10: Recover initial ESM on RMOD
        Step 11: Check final all BTS state
        Step 12: Check final all BTS alarms
        Step 13: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
    ...  alias=${alias_local}
    Set Test Variable  ${BTS_RMOD_sn_id_dict}
    Set Test Variable  ${BTS_RMOD_id_sn_dict}
    Set Test Variable  ${BTS_RMOD_sn_pn_dict}
    Set Test Variable  ${BTS_RMOD_sn_interface_dict}
    ${BTS_RMOD_sn_list}=  Get Dictionary Keys  ${BTS_RMOD_sn_id_dict}

    Run Keyword If  '${RMOD_SERIAL_NUMBER}' not in ${BTS_RMOD_sn_list}  Run Keywords
    ...  Log Long String  Selected RMOD serial number is not valid: ${RMOD_SERIAL_NUMBER}. Please select a value for test argument
    ...  \${RMOD_SERIAL_NUMBER} from configured RMOD: ${BTS_RMOD_sn_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Log  ===============================================  console=True
    Log  RMOD serial number selected for ESM operations: ${RMOD_SERIAL_NUMBER}  console=True
    Log  ===============================================  console=True

    Run Keyword If  '${energySavingMode}' not in ['DEEPSLEEP', 'DEEPSLEEP_EXTREME_SFP']  Run Keywords
    ...  Log Long String  Argument \${energySavingMode} value is not valid: ${energySavingMode}. Please select a value for test argument
    ...  \${energySavingMode} from possible values: DEEPSLEEP or DEEPSLEEP_EXTREME_SFP  console=True
    ...  AND  Fail  Improper value for argument!

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - RMOD and mapped cells

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    Get BTS cells info  alias=${alias_local}

    Get RMOD info from BTS  RMOD_sn=${RMOD_SERIAL_NUMBER}  alias=${alias_local}

    Get PM counters dist names info  alias=${alias_local}

    Set Test Variable  ${CELL_state_blocked_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    Set Test Variable  ${CELL_state_blocked}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    Set Test Variable  ${CELL_state_unblocked_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_unblocked}  operationalState=Enabled, blockingState=Unblocked
    ${RMOD_state_awake_check}=  Create Dictionary  operationalState=enabled  administrativeState=Unlocked  powerState=AWAKE
    Set Test Variable  ${RMOD_state_awake_check}
    Set Test Variable  ${RMOD_state_awake}  operationalState=enabled, administrativeState=Unlocked, powerState=AWAKE
    ${RMOD_state_sleep_check}=  Create Dictionary  operationalState=enabled  administrativeState=Unlocked  powerState=SLEEP
    Set Test Variable  ${RMOD_state_sleep_check}
    Set Test Variable  ${RMOD_state_sleep}  operationalState=enabled, administrativeState=Unlocked, powerState=SLEEP
    ${RMOD_state_sleep_extreme_check}=  Create Dictionary  operationalState=enabled  administrativeState=Unlocked  powerState=SLEEP_EXTREME
    Set Test Variable  ${RMOD_state_sleep_extreme_check}
    Set Test Variable  ${RMOD_state_sleep_extreme}  operationalState=enabled, administrativeState=Unlocked, powerState=SLEEP_EXTREME

Step ${index}: Perform call on requested RMOD ${when}
    [Documentation]
    ...  Perform call on requested RMOD

    Log  Step ${index}: Perform call on requested RMOD ${when}  console=True

    Run Keyword If  '${L3_CALL_CHECK}' != 'True'  Run Keywords
    ...  Log  No L3 call requested during test scenario. This step will be skipped!  console=True
    ...  AND  Return From Keyword

    ${KW_resource_path}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_resource_path
    ${KW_name}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_name
    ${KW_impact}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_impact

    Log  =========================  console=True
    Log  L3 call selected KW name: ${KW_name}  console=True
    Log  =========================  console=True

    ${KW_status}=  Execute External KW  KW_resource_path=${KW_resource_path}  KW_name=${KW_name}  KW_args=${L3_CALL_KW_ARGUMENTS}

    Run Keyword If  '${KW_status}' == 'True'  Run Keywords
    ...  Log  L3 call successfully performed: ${KW_name} run passed  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${KW_impact}' == 'False'
    ...  Log  L3 call failed: ${KW_name} run failed  level=WARN
    ...  ELSE IF  '${KW_impact}' == 'True'  Run Keywords
    ...  Log  L3 call failed: ${KW_name} run failed  level=ERROR
    ...  AND  Fail  L3 call failed: ${KW_name} run failed

Step ${index}: Set required ESM on RMOD
    [Documentation]
    ...  Set required ESM on RMOD

    Log  Step ${index}: Set required ESM on RMOD  console=True

    Run Keyword If  '${PM_CHECK}' == 'True'  Wait for start of PM period

    ${ESM_timestamp_start}=  Get Current Date  time_zone=UTC
    Log  Start ESM operations UTC time: ${ESM_timestamp_start}  console=True
    ${ESM_epoch_start}=  Convert Date  ${ESM_timestamp_start}  result_format=epoch  exclude_millis=True
    Set Test Variable  ${ESM_timestamp_start}
    Set Test Variable  ${ESM_epoch_start}

    Log  Check ESM feature parameter on BTS ${alias_local} for RMOD_${RMOD_SERIAL_NUMBER} and set accordingly if needed  console=True
    Get and check ESM feature parameter on classical BTS  ESM_parameter_name=energySavingMode  ESM_parameter_value=${energySavingMode}
    ...  RMOD_sn=${RMOD_SERIAL_NUMBER}  alias=${alias_local}

    Log  Check RMOD_${RMOD_SERIAL_NUMBER} status on BTS ${alias_local}:  console=True
    Wait Until Keyword Succeeds  300s  60s  Check RMOD status info  RMOD_id=${RMOD_id}  expected_info=${RMOD_state_awake_check}  alias=${alias_local}
    Log  - ${RMOD_state_awake}  console=True

Step ${index}: Activate ESM on RMOD by block all cells mapped on RMOD
    [Documentation]
    ...  Activate ESM on RMOD by block all cells mapped on RMOD checking RMOD powerState

    Log  Step ${index}: Activate ESM on RMOD by block all cells mapped on RMOD  console=True

    Perform BTS cell operation  operation=Block  cell_id_list=${RMOD_NR_CELL_ids_list}  cell_class_name=NRCEL
    ...  cell_state_check=${CELL_state_blocked_check}  cell_state=${CELL_state_blocked}  timeout=300  alias=${alias_local}

    Perform BTS cell operation  operation=Block  cell_id_list=${RMOD_LTE_CELL_ids_list}  cell_class_name=LNCEL
    ...  cell_state_check=${CELL_state_blocked_check}  cell_state=${CELL_state_blocked}  timeout=300  alias=${alias_local}

    Perform BTS cell operation  operation=Block  cell_id_list=${RMOD_LTE_IOT_SA_CELL_ids_list}  cell_class_name=LNCEL
    ...  cell_state_check=${CELL_state_blocked_check}  cell_state=${CELL_state_blocked}  timeout=300  alias=${alias_local}

    Perform BTS cell operation  operation=Block  cell_id_list=${RMOD_WCDMA_CELL_ids_list}  cell_class_name=WNCEL
    ...  cell_state_check=${CELL_state_blocked_check}  cell_state=${CELL_state_blocked}  timeout=300  alias=${alias_local}

    Perform BTS cell operation  operation=Block  cell_id_list=${RMOD_GSM_CELL_ids_list}  cell_class_name=GNCEL
    ...  cell_state_check=${CELL_state_blocked_check}  cell_state=${CELL_state_blocked}  timeout=300  alias=${alias_local}

    ${BTS_EXPECTED_ALARMS_49_full}=  Prepare expected alarms list  ${test_alarms_list['${alias_local.upper()}_EXPECTED_ALARMS_49']}
    ...  ${FID49_alarm_count}
    ${BTS_IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS_DURING_ACTION']}

    Log  Check BTS ${alias_local} alarms:  console=True
    Log  BTS ${alias_local} "Cell Blocked (49)" alarm, expected number: ${FID49_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  poll_interval=5s  expected_alarms=${BTS_EXPECTED_ALARMS_49_full}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_full}  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias_local} "Cell Blocked (49)" alarm, found number: ${FID49_alarm_count}, as expected  console=True
    Log  BTS ${alias_local} site - expected, ignored and critical alarms checked  console=True

    ${RMOD_state_check}=  Set variable If  '${energySavingMode}' == 'DEEPSLEEP'  ${RMOD_state_sleep_check}
    ...  '${energySavingMode}' == 'DEEPSLEEP_EXTREME_SFP'  ${RMOD_state_sleep_extreme_check}
    ${RMOD_state}=  Set variable If  '${energySavingMode}' == 'DEEPSLEEP'  ${RMOD_state_sleep}
    ...  '${energySavingMode}' == 'DEEPSLEEP_EXTREME_SFP'  ${RMOD_state_sleep_extreme}

    Log  Check RMOD_${RMOD_SERIAL_NUMBER} status on BTS ${alias_local} after ESM activation:  console=True
    Wait Until Keyword Succeeds  ${ESM_MAX_WAIT_TIME}s  30s  Check RMOD status info  RMOD_id=${RMOD_id}  expected_info=${RMOD_state_check}
    ...  alias=${alias_local}
    Log  - ${RMOD_state}  console=True

Step ${index}: Deactivate ESM on RMOD by unblock all cells mapped on RMOD
    [Documentation]
    ...  Deactivate ESM on RMOD by unblock all cells mapped on RMOD checking RMOD powerState

    Log  Step ${index}: Deactivate ESM on RMOD by unblock all cells mapped on RMOD  console=True

    Perform BTS cell operation  operation=Unblock  cell_id_list=${RMOD_NR_CELL_ids_list}  cell_class_name=NRCEL
    ...  cell_state_check=${CELL_state_unblocked_check}  cell_state=${CELL_state_unblocked}  timeout=${ESM_MAX_WAIT_TIME}  alias=${alias_local}

    Perform BTS cell operation  operation=Unblock  cell_id_list=${RMOD_LTE_CELL_ids_list}  cell_class_name=LNCEL
    ...  cell_state_check=${CELL_state_unblocked_check}  cell_state=${CELL_state_unblocked}  timeout=${ESM_MAX_WAIT_TIME}  alias=${alias_local}

    Perform BTS cell operation  operation=Unblock  cell_id_list=${RMOD_LTE_IOT_SA_CELL_ids_list}  cell_class_name=LNCEL
    ...  cell_state_check=${CELL_state_unblocked_check}  cell_state=${CELL_state_unblocked}  timeout=${ESM_MAX_WAIT_TIME}  alias=${alias_local}

    Perform BTS cell operation  operation=Unblock  cell_id_list=${RMOD_WCDMA_CELL_ids_list}  cell_class_name=WNCEL
    ...  cell_state_check=${CELL_state_unblocked_check}  cell_state=${CELL_state_unblocked}  timeout=${ESM_MAX_WAIT_TIME}  alias=${alias_local}

    Perform BTS cell operation  operation=Unblock  cell_id_list=${RMOD_GSM_CELL_ids_list}  cell_class_name=GNCEL
    ...  cell_state_check=${CELL_state_unblocked_check}  cell_state=${CELL_state_unblocked}  timeout=${ESM_MAX_WAIT_TIME}  alias=${alias_local}

    Log  Check BTS ${alias_local} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias_local} site - expected, ignored and critical alarms checked  console=True

    Log  Check RMOD_${RMOD_SERIAL_NUMBER} status on BTS ${alias_local} after ESM deactivation:  console=True
    Wait Until Keyword Succeeds  ${ESM_MAX_WAIT_TIME}s  30s  Check RMOD status info  RMOD_id=${RMOD_id}  expected_info=${RMOD_state_awake_check}
    ...  alias=${alias_local}
    Log  - ${RMOD_state_awake}  console=True

    ${ESM_timestamp_end}=  Get Current Date  time_zone=UTC
    Log  End ESM operations UTC time: ${ESM_timestamp_end}  console=True
    ${ESM_epoch_end}=  Convert Date  ${ESM_timestamp_end}  result_format=epoch  exclude_millis=True
    Set Test Variable  ${ESM_timestamp_end}
    Set Test Variable  ${ESM_epoch_end}

Step ${index}: Check PM counters after ESM operations
    [Documentation]
    ...  Check requested PM counters: M55601C01003, M55601C01004

    Log  Step ${index}: Check PM counters after ESM operations  console=True

    Run Keyword If  '${PM_CHECK}' != 'True'  Run Keywords
    ...  Log  No PM counters check requested during test scenario. This step will be skipped!  console=True
    ...  AND  Return From Keyword

    ${PM_info_epoch_list}  ${PM_info_timestamp_list}=  Get PM info with ESM impact
    Log  PM counter UTC timestamps for checks: ${PM_info_timestamp_list}  console=True
    ${PM_last_info_epoch}=  Get From List  ${PM_info_epoch_list}  -1

    ${PM_INTERVAL_check}=  Evaluate  2 * ${PM_INTERVAL}
    Wait Until Keyword Succeeds  ${PM_INTERVAL_check}min  1min  Wait for PM counter collect completed  ${PM_last_info_epoch}
    Sleep  60s  reason=Wait for PM counter collect completed

    FOR  ${counter_epoch}  IN  @{PM_info_epoch_list}

        Check requested PM counter info  counter_id=M55601C01003  counter_epoch=${counter_epoch}  expected_counter_value=0  alias=${alias_local}
        Check requested PM counter info  counter_id=M55601C01004  counter_epoch=${counter_epoch}  expected_counter_value=0  alias=${alias_local}

    END

Step ${index}: Recover initial ESM on RMOD
    [Documentation]
    ...  Recover initial ESM on RMOD

    Log  Step ${index}: Recover initial ESM on RMOD  console=True

    Log  Recover initial ESM on BTS ${alias_local} for RMOD_${RMOD_SERIAL_NUMBER}  console=True
    Get and check ESM feature parameter on classical BTS  ESM_parameter_name=energySavingMode
    ...  ESM_parameter_value=${RMOD_${RMOD_SERIAL_NUMBER}_energySavingMode_initial}  RMOD_sn=${RMOD_SERIAL_NUMBER}  alias=${alias_local}

    Log  Check RMOD_${RMOD_SERIAL_NUMBER} status on BTS ${alias_local}:  console=True
    Wait Until Keyword Succeeds  ${ESM_MAX_WAIT_TIME}s  30s  Check RMOD status info  RMOD_id=${RMOD_id}  expected_info=${RMOD_state_awake_check}
    ...  alias=${alias_local}
    Log  - ${RMOD_state_awake}  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BTS cells info
    [Arguments]  ${alias}

    ${BTS_NR_CELL_ids_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${BTS_LTE_CELL_ids_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${BTS_WCDMA_CELL_ids_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${BTS_GSM_CELL_ids_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${BTS_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}  ${BTS_LTE_IOT_SA_CELL_ids_list}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${BTS_LTE_CELL_ids_list}  alias=${alias}
    ${BTS_LTE_HOST_LTE_IOT_cell_mapping_dict}=  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${BTS_NR_CELL_ids_list}
    Set Test Variable  ${BTS_LTE_CELL_ids_list}
    Set Test Variable  ${BTS_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${BTS_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${BTS_WCDMA_CELL_ids_list}
    Set Test Variable  ${BTS_GSM_CELL_ids_list}
    Set Test Variable  ${BTS_LTE_HOST_LTE_IOT_cell_mapping_dict}

Get PM counters dist names info
    [Arguments]  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    ${MRBTS_id}=  Get From Dictionary  ${BTS_info}  mrbtsID
    ${NRBTS_id}=  Get From Dictionary  ${BTS_info}  nrBtsId

    ${BTS_CELL_info}=  Get From Dictionary  ${BTS_info}  cells
    ${NRCEL_info}=  Get From Dictionary  ${BTS_CELL_info}  nr

    ${NR_CELL_globalCellId_list}=  Create List

    FOR  ${item}  IN  @{NRCEL_info}

        ${cell_id_info}=  Get From Dictionary  ${item}  id
        ${cell_id}=  Get From Dictionary  ${cell_id_info}  internal
        Continue For Loop If  '${cell_id}' not in ${RMOD_NR_CELL_ids_list}

        ${cell_globalCellId}=  Get From Dictionary  ${item}  globalCellId
        Append To List  ${NR_CELL_globalCellId_list}  ${cell_globalCellId}

    END

    Set Test Variable  ${MRBTS_id}
    Set Test Variable  ${NRBTS_id}
    Set Test Variable  ${NR_CELL_globalCellId_list}

Get and check ESM feature parameter on classical BTS
    [Documentation]
    ...  Helper Keyword used to get and check ESM feature parameter on classical BTS and set accordingly if needed

    [Arguments]  ${ESM_parameter_name}  ${ESM_parameter_value}  ${RMOD_sn}  ${alias}

    ${RMOD_sn_list}=  Create List  ${RMOD_sn}

    ${BTS_ESM_feature_dict}=  Get RMOD ESM feature parameter on classical BTS  RMOD_sn_list=${RMOD_sn_list}  alias=${alias}
    ${energySavingMode_info}=  Get From Dictionary  ${BTS_ESM_feature_dict}  ${RMOD_sn}

    Log  - BTS ${alias} RMOD_${RMOD_sn} energySavingMode: ${energySavingMode_info}  console=True

    Set Test Variable  ${RMOD_${RMOD_sn}_energySavingMode_initial}  ${energySavingMode_info}

    Set RMOD ESM feature parameter on classical BTS  ESM_parameter_name=${ESM_parameter_name}
    ...  ESM_parameter_value=${ESM_parameter_value}  RMOD_sn=${RMOD_sn}  alias=${alias}

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${BTS_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_id}
    ${RMOD_pn}=  Get From Dictionary  ${BTS_RMOD_sn_pn_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_pn}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${RMOD_id}
    Set Test Variable  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${RMOD_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${RMOD_GSM_CELL_ids_list}

    FOR  ${cell_id}  IN  @{RMOD_LTE_CELL_ids_list}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${BTS_LTE_HOST_LTE_IOT_cell_mapping_dict}  ${cell_id}

        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'
        ...  Append To List  ${RMOD_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}

    END
    ${RMOD_CELL_ids_list}=  Combine Lists  ${RMOD_NR_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    ...  ${RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}
    ${RMOD_CELL_ids_count}=  Get Length  ${RMOD_CELL_ids_list}
    Set Test Variable  ${FID49_alarm_count}  ${RMOD_CELL_ids_count}

    ${RMOD_interface}=  Get From Dictionary  ${BTS_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_interface}

Check RMOD status info
    [Arguments]  ${RMOD_id}  ${expected_info}  ${alias}

    ${RMOD_info}=  coam.Get Parameters  dist_name=${RMOD_id}  timeout=10  connection=${alias}
    Dictionary Should Contain Sub Dictionary  ${RMOD_info}  ${expected_info}

Perform BTS cell operation
    [Arguments]  ${operation}  ${cell_id_list}  ${cell_class_name}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${cell_id}  IN  @{cell_id_list}

        Log  Perform "${operation} Cell" operation on ${cell_class_name} ${cell_id} from BTS ${alias}:   console=True

        Run Keyword If  '${operation}' == 'Block'
        ...  coam.Block Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}
        ...  ELSE IF  '${operation}' == 'Unblock'
        ...  coam.Unblock Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${alias}

        Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}

        Log  ${cell_class_name} ${cell_id} status:\n - ${cell_state}  console=True

    END

Get PM info with ESM impact

    ${PM_info_epoch_list}=  Create List  ${PM_1_info_epoch}
    ${PM_info_timestamp_list}=  Create List  ${PM_1_info_timestamp}
    ${PM_end_info_epoch}=  Set Variable  ${PM_1_info_epoch}

    FOR  ${cycle}  IN RANGE  1  10

        Exit For Loop If  ${ESM_epoch_end} < ${PM_end_info_epoch}

        ${PM_INTERVAL_secs}=  Evaluate  60 * ${PM_INTERVAL}
        ${PM_end_info_epoch}=  Evaluate  ${PM_end_info_epoch} + ${PM_INTERVAL_secs}
        ${PM_end_info_timestamp}=  Convert Date  ${PM_end_info_epoch}  result_format=timestamp  exclude_millis=True
        Append To List  ${PM_info_epoch_list}  ${PM_end_info_epoch}
        Append To List  ${PM_info_timestamp_list}  ${PM_end_info_timestamp}

    END

    [Return]  ${PM_info_epoch_list}  ${PM_info_timestamp_list}

Check requested PM counter info
    [Arguments]  ${counter_id}  ${counter_epoch}  ${expected_counter_value}  ${alias}

    ${counter_timestamp}=  Convert Date  ${counter_epoch}  result_format=timestamp  exclude_millis=True

    ${all_counter_info_dict}=  coam.Get Pm Counters  counter_ids=${counter_id}  connection=${alias}

    ${counter_epoch_str}=  Convert To String  ${counter_epoch}
    ${expected_counter_value_int}=  Convert To Integer  ${expected_counter_value}

    FOR  ${NRCEL_globalCellId}  IN  @{NR_CELL_globalCellId_list}

        ${BTS_info_dict}=  Get From Dictionary  ${all_counter_info_dict}  BTS
        ${MRBTS_info_dict}=  Get From Dictionary  ${BTS_info_dict}  MRBTS-${MRBTS_id}
        ${NRBTS_info_dict}=  Get From Dictionary  ${MRBTS_info_dict}  NRBTS-${NRBTS_id}
        ${NRCEL_info_dict}=  Get From Dictionary  ${NRBTS_info_dict}  NRCELL-${NRCEL_globalCellId}
        ${NCAV_info_dict}=  Get From Dictionary  ${NRCEL_info_dict}  NCAV
        ${counter_info_dict}=  Get From Dictionary  ${NCAV_info_dict}  ${counter_id}

        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${counter_info_dict}  ${counter_epoch_str}
        Run Keyword If  '${status}' == 'False'  Run Keywords
        ...  Log  No PM counter UTC timestamp ${counter_timestamp} found!  level=ERROR
        ...  AND  Fail  No PM counter UTC timestamp ${counter_timestamp} found!

        ${counter_value}=  Get From Dictionary  ${counter_info_dict}  ${counter_epoch_str}
        Should Be Equal  ${counter_value}  ${expected_counter_value_int}

        Log  BTS ${alias} PM UTC timestamp ${counter_timestamp} - NRCELL-${NRCEL_globalCellId} counter ${counter_id}: ${counter_value}  console=True

    END

Wait for start of PM period

    Log  Wait for start of PM period to perform ESM operations  console=True

    ${PM_1_info}=  eem.Wait For Next Pm Period  interval=${PM_INTERVAL}min

    ${PM_1_info_epoch}=  Get From List  ${PM_1_info}  1
    ${PM_1_info_timestamp}=  Convert Date  ${PM_1_info_epoch}  result_format=timestamp  exclude_millis=True
    Set Test Variable  ${PM_1_info_epoch}
    Set Test Variable  ${PM_1_info_timestamp}

Wait for PM counter collect completed
    [Arguments]  ${PM_info_epoch}

    ${current_date_epoch}=  Get Current Date  result_format=epoch  exclude_millis=True
    ${PM_check_date_epoch}=  Add Time To Date  ${PM_info_epoch}  ${PM_INTERVAL}min  result_format=epoch
    Should Be True  ${current_date_epoch} > ${PM_check_date_epoch}

Particular Teardown
    Admin Check if BTS cells are unblocked  ${alias_local}
    Set RMOD ESM feature parameter on classical BTS  ESM_parameter_name=energySavingMode
    ...  ESM_parameter_value=${RMOD_${RMOD_SERIAL_NUMBER}_energySavingMode_initial}  RMOD_sn=${RMOD_SERIAL_NUMBER}  alias=${alias_local}

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}
    ...  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown