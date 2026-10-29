*** Settings ***
Documentation
...  The purpose of this test case is to check RU returning from PowerSaving Mode to normal operation

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../../Resources/SiSo_L3_call.robot
Library    taf.ul.energy_efficiency_monitoring  WITH NAME  ee_monitoring

*** Variables ***
${RMOD_SN}                         # list of RMOD's serial numbers separated by a comma eg. EA200262091,BL1909V001Y - fill by tester
${REPETITIONS_AMOUNT}  1           # number of times to execute change and restoring of RU power state
${RECOMMISSIONING_TIMEOUT}  600    # Timeout for recommissioning procedure
${SELECTED_CELLS}  None
${SISO_L3_CALL}  False             # default value for L3 call is False, set test variable as True to perform test with L3 call
${CELLS_YAML_PATH}                 # mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
${node}  default
${EE_INTERVAL}  15min              # time interval of getting counters for EEM - Energy Efficiency Monitoring

*** Keywords ***
TC__SiSo_REC_RU_Deep_Sleep_Mode_Power_State
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check RU returning from PowerSaving Mode to normal operation.
    ...  Test Case enable EnergySaving on RMOD (value=DEEPSLEEP), block all cells on testing RMOD and wait for change
    ...  Power State of RU from AWAKE on SLEEP. This operation can take 5-7 minutes.
    ...  After unblock cells Power State of RU must be back on AWAKE.
    ...  Test Case checks also cell status after recovering from Deep Sleep Mode,
    ...  it is expected availabilityStatus=off line, operationalState=disabled.
    ...  Process of checking RU power state while blocking and unblocking cells can be repeated multiple times
    ...  - need to complete ${REPETITIONS_AMOUNT} with the desired number of executions.
    ...  Test case checks RU operation on families: 5.1 (AHEGB, ARMA) and 6.2 (AHFII, AHEGHA) - all technologies.
    ...
    ...  There is possibility to verify UL and DL throughputs by perform L3 call on cells. Throughputs should reach at least
    ...  80% of maximal values.
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}
    ...  ${CELLS_YAML_PATH}
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.06.2024 - https://jiradc.ext.net.nokia.com/browse/TST-15306 - Initial creation
    ...  - 01.07.2024 - adding check of cells status after recovering from Deep Sleep Mode
    ...  - 06.08.2024 - expanding TC with taf.ul.energy_efficiency_monitoring for monitoring of power consumpstion savings
    ...    according to BitStream 4.3

    Set Tags  CA-BS-RF  OWNER-malgorzata.piecyk-celuch@nokia.com  AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...  MAINTAINER-malgorzata.piecyk-celuch@nokia.com  PHASE-CRT  SW-SBTS24  CNI-122115

    Step 1: Test Case Preconditions
    Step 2: Enable energySaving On RMOD
    Step 3: Check Power State Of RMOD During Block And Unblock Cells
    Step 4: Perform L3 call
    Restore Energy Saving Mode Activation To Initial Status


Step 1: Test Case Preconditions
    Log  ${\n}Step 1: Test Case Preconditions  console=True
    Log       -------------------------------${\n}  console=True

    Log  Enabling Energy Efficiency Monitoring (EEM) and getting counters when DeepSleepMode is deactivated${\n}  console=True
    ee_monitoring.configure_bts_connection
    ee_monitoring.enable_energy_efficiency_monitoring
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=disabled  interval=${EE_INTERVAL}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}

    Log  Get RMOD(s) info  console=True
    ${radios_sn}  Split String  ${RMOD_SN}  ,
    &{rmods_info}  Create Dictionary
    FOR  ${test_radio}  IN  @{radios_sn}
        ${rmod_internal_id}  ${rmod_config_id}  Get RU Internal Dist And RU Configuration Dist  ${test_radio}  alias=${node}
        Set To Dictionary  ${rmods_info}  ${rmod_config_id}  ${rmod_internal_id}
    END
    Set Test Variable  ${RMODS_INFO}

    ${all_cells}  Create List
    FOR  ${distname}  IN  @{RMODS_INFO.values()}
       ${rmod_cells}  Get All Cells Mapping By RMOD Id  ${distname}
       ${all_cells}  Combine Lists  ${all_cells}  ${rmod_cells}
    END
    Set Test Variable  ${CELLS_DISTNAME_ID}  ${all_cells}

    Sleep  5 m
    Log  ${\n}Saving counters EEM - DeepSleepMode disabled   console=True
    ee_monitoring.stop_measurement_period  ee_features_status=disabled
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values  ee_features_status=disabled  filepath=/home/ute/disabled_features_log.json

Step 2: Enable energySaving On RMOD
    Log  ${\n}Step 2: Enable EnergySaving On RMOD  console=True
    Log       -----------------------------------  console=True

    Log  Check if parametr energySavingMode has proper value${\n}  console=True
    ${initial_status_esm_dict}  Check Status Of energySavingMode
    Set Test Variable  ${INITIAL_STATUS_ESM_DICT}
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

    Log  Appending to delta parameter energySavingMode=DEEPSLEEP for RMOD(s)  console=True
    admin.Create Delta
    @{listRmodToModyfy}  Create List
    FOR  ${rmod}  ${esm_status}  IN ZIP  ${INITIAL_STATUS_ESM_DICT.keys()}  ${INITIAL_STATUS_ESM_DICT.values()}
        ${activate_esm}  Run Keyword And Return Status  Should Be Equal  ${esm_status}  DEEPSLEEP
        Run Keyword If  '${activate_esm}'=='True'
        ...  Log  Parametr energySavingMode for ${rmod} has expected value ${esm_status}  console=True
        ...  ELSE  Run Keywords  Log  Parametr energySavingMode for ${rmod} is going to be set DEEPSLEEP  console=True
        ...  AND  admin.Append Parameter Update To Delta  ${rmod}  energySavingMode  DEEPSLEEP
        ...  AND  Append To List  ${listRmodToModyfy}  ${rmod}
    END
    ${energyMode_recomm}  Run Keyword And Return Status  Should Not Be Empty  ${listRmodToModyfy}
    Run Keyword If  '${energyMode_recomm}'=='True'  Run Keywords
    ...  Perform recommissioning
    ...  AND  Check Parametr energySavingMode After Recommissioning
    Set Test Variable  ${ENERGYMODE_RECOMM}
    admin.Remove Delta

    Log  ${\n}Checking power state of RMOD(s):${\n}  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
       Log  Checking ${rmod}, required power state is AWAKE - wait for verdict  console=True
       Check Rmod Power State  distname=${distname}  expected_powerState=AWAKE
    END

Step 3: Check Power State Of RMOD During Block And Unblock Cells
    Log  Step 3: Check Power State Of RMOD During Block And Unblock Cells  console=True
    Log  ----------------------------------------------------------------  console=True

    ${REPETITIONS_AMOUNT}  Convert To Integer  ${REPETITIONS_AMOUNT}
    FOR  ${number}  IN RANGE  1  ${REPETITIONS_AMOUNT + 1}
      Log  ${\n}============ REPETITION ${number} ============  console=True
      ${verdict}  Block Cells And Check Power State Of RMOD
      Unblock Cells And Check Power State Of RMOD  ${verdict}
    END

Block Cells And Check Power State Of RMOD
    Log  ${\n}Block Cells And Check Power State Of RMOD  console=True
    Log       -----------------------------------------  console=True

    Log  Perform cells block  console=True
    FOR  ${cell}  IN  @{CELLS_DISTNAME_ID}
      ${block_status}  Run Keyword And Return Status  admin.Block Cell  ${cell}  240  False
      Run Keyword If  '${block_status}'=='True'
      ...  Log  ${cell} blocked successfully  console=True
      ...  ELSE  Run Keywords
      ...  Log  ${cell} blocked unsuccessfully, parameters restoring will be performed${\n}  console=True
      ...  AND  admin.Unblock Cell  ${cell}  180  False
      ...  AND  Fail  ${cell} blocked unsuccessfully
    END

    Log  ${\n}Check if fault 49 appeared  console=True
    FOR  ${cell}  IN  @{CELLS_DISTNAME_ID}
      ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=49  timeout=60
      Run Keyword If  '${alarm_status}'=='True'
      ...  Log  Fault 49 for ${cell} appeared  console=True
      ...  ELSE  Run Keywords  Log  Fault 49 for ${cell} did not appear, but should be. Parameters restoring will be performed  console=True
      ...  AND  admin.Unblock Cell  ${cell}  180  False
      ...  AND  Fail  Fault 49 for ${cell} did not appear
    END

    Sleep  6m  Waiting for SLEEP mode on RMOD(s)
    Log  ${\n}Checking power state of RMOD(s):${\n}  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
       Log  Checking ${rmod}, required power state is SLEEP - wait for verdict  console=True
       ${verdict}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2 min  20 s
       ...  Check Rmod Power State  distname=${distname}  expected_powerState=SLEEP
       Run Keyword If  '${verdict}'=='False'  Run Keywords
       ...  Log  ${rmod} has not required power state - should be SLEEP, TC failed  console=True
       ...  AND  Log  ${\n}Recovery action will be performed, cells need to be unblocked  console=True
       ...  AND  Unblock Cells And Check Power State Of RMOD  ${verdict}
       ...  AND  Fail  RMOD has not required power state - should be SLEEP, TC failed
    END
    [Return]  ${verdict}

    Log  Getting counters for EEM when DeepSleepMode is activated${\n}  console=True
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=enabled  interval=${EE_INTERVAL}

    Log  Saving counters for EEM (DeepSleepMode enabled) and getting the difference  console=True
    ee_monitoring.stop_measurement_period  ee_features_status=enabled
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values  ee_features_status=enabled  filepath=/home/ute/enabled_features_log.json
    ee_monitoring.get_counters_difference_for_enabled_disabled_features

Unblock Cells And Check Power State Of RMOD
    [Arguments]  ${verdict}
    Log  ${\n}Unblock Cells And Check Power State Of RMOD  console=True
    Log       -------------------------------------------  console=True

    Log  Perform cells unblock  console=True
    FOR  ${cell}  IN  @{CELLS_DISTNAME_ID}
      ${unblock_status}  Run Keyword And Return Status  admin.Unblock Cell  ${cell}  180  False
      Run Keyword If  '${unblock_status}'=='True'
      ...  Log  ${cell} unblocked successfully  console=True
      ...  ELSE  Run Keywords
      ...  Log  ${cell} unblocked unsuccessfully, parameters restoring will be performed${\n}  console=True
      ...  AND  admin.Unblock Cell  ${cell}  180  False
      ...  AND  Fail  ${cell} unblock unsuccessfully
    END

    Run Keyword If  '${verdict}'=='True'  Check RMOD reset

    Log  ${\n}Waiting until RMOD will be enabled  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
      ${rmod_availability}  Run Keyword And Return Status
      ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Assert No  RMOD  availabilityStatus=regex"(.*)"  alias=${node}
      ${rmod_operability}  Run Keyword And Return Status
      ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Assert  RMOD  ${distname}  operationalState=regex"(?i)Enabled"  alias=${node}
      Run Keyword If  '${rmod_availability}'=='True' and '${rmod_operability}'=='True'
      ...  Log  RMOD-${rmod} has correct state  console=True
      ...  ELSE  Run Keywords
      ...  Log  RMOD-${rmod} has wrong state, check logs  console=True
      ...  AND  Fail  RMOD-${rmod} has wrong state, check logs
    END

    Log  ${\n}Check if BTS and cells are onAir  console=True
    ${BTS_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  3 min  15 s
    ...  Check If All Cells And Modules Are OnAir  timeout=60  alias=${node}
    Run Keyword If  '${BTS_status}'=='True'
    ...  Log  BTS is onAir  console=True
    ...  ELSE
    ...  Fail  BTS is not onAir

    Log  ${\n}Checking power state of RMOD(s):${\n}  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
       Log  Checking ${rmod}, required power state is AWAKE - wait for verdict  console=True
       Wait Until Keyword Succeeds  3 min  20 s  Check Rmod Power State  distname=${distname}  expected_powerState=AWAKE
    END

Step 4: Perform L3 call
    Log  ${\n}Step 4: Perform L3 call  console=True
    Log       -----------------------  console=True

    Log  Perform L3 call  console=True
    Set Test Variable  ${SELECTED_CELLS}  ${CELLS_DISTNAME_ID}
    Log  ${SELECTED_CELLS}
    Set Test Variable  ${LOGS_DIR}  ${BTS_Files}
    Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
    ...  ELSE  Log  Call skipped  console=True

Restore Energy Saving Mode Activation To Initial Status
    Log  ${\n}Restoring Energy Saving Mode Activation To Initial Status  console=True
    Log       ---------------------------------------------------------${\n}  console=True

    Log  Appending to restore parametr energySavingMode to initial status  console=True
    admin.Create Delta
    FOR  ${rmod}  ${esm_status}  IN ZIP  ${INITIAL_STATUS_ESM_DICT.keys()}  ${INITIAL_STATUS_ESM_DICT.values()}
        ${status_esm}  Run Keyword And Return Status  Should Be Equal  ${esm_status}  DEEPSLEEP
        Run Keyword If  '${status_esm}'=='True'
        ...  Log  ${\n}Restoring parameter energySavingMode for ${rmod} is not needed  console=True
        ...  ELSE  Run Keywords
        ...  Log  Restoring parameter energySavingMode for ${rmod} will be performed  console=True
        ...  AND  admin.Append Parameter Update To Delta  ${rmod}  energySavingMode  ${esm_status}
    END
    Run Keyword If  ${ENERGYMODE_RECOMM}  Perform recommissioning
    admin.Remove Delta

    Log  ${\n}Checking if parametr energySavingMode has initial status  console=True
    ${dict_current_status_esm}  Check Status Of energySavingMode
    ${compare_dicts}  Run Keyword And Return Status  Dictionaries Should Be Equal  ${dict_current_status_esm}  ${INITIAL_STATUS_ESM_DICT}
    Run Keyword If  '${compare_dicts}'=='True'
    ...  Log  Parametr energySavingMode for tested RMOD(s) has initial status${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Current status of parameter energySavingMode is different than initial status${\n}  console=True
    ...  AND  Fail  Current status of parameter energySavingMode is different than initial status


Perform recommissioning
    Log  ${\n}Performing recommissioning, please wait  console=True
    ${delta}  admin.Get Delta
    ${delta_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Perform Delta Recommissioning  ${delta}
    ...  timeout=${RECOMMISSIONING_TIMEOUT}
    Run Keyword If  '${delta_status}'=='True'
    ...  Log  Recommissioning is done successfully${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Fail  Recommissioning is not done successfully
    ...  AND  Log  Recommissioning is not done successfully  console=True

    Log  Checking cells status  console=True
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=180  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log  All cells are onAir  console=True
    ...  ELSE  Run Keywords
    ...  Fail  Cells are not onAir
    ...  AND  Log  Cells are not onAir  console=True

Get RU Internal Dist And RU Configuration Dist
    [Arguments]  ${rmod_sn}  ${alias}=default
    ${all_ru_params}  admin.Get FRM  60
    FOR  ${rmod}  IN  @{all_ru_params}
        Continue For Loop If  '${rmod_sn}'!='${rmod['serialNumber']}'
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
    END
    [Return]  ${rmod_internal_id}  ${rmod_config_id}

Check Status Of energySavingMode
    &{status_esm_dict}  Create Dictionary
    ${param_energySavingMode}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${param_energySavingMode}
    FOR  ${config_id}  IN ZIP  ${RMODS_INFO.keys()}
      ${esm_status}  Evaluate Xpath  ${scfc_xml}
      ...  string(.//managedObject[@distName='${config_id}']/p[@name='energySavingMode']/text())
      Set To Dictionary  ${status_esm_dict}  ${config_id}  ${esm_status}
    END
    [Return]  ${status_esm_dict}

Check Parametr energySavingMode After Recommissioning
    Log  ${\n}Checking if parametr energySavingMode has changed properly  console=True
    ${status_esm_dict}  Check Status Of energySavingMode
    FOR  ${rmod}  ${esm_status}  IN ZIP  ${status_esm_dict.keys()}  ${status_esm_dict.values()}
       Run Keyword If  '${esm_status}'!='DEEPSLEEP'  Run Keywords
       ...  Log  ${\n}Parametr energySavingMode for ${rmod} has not expected value  console=True
       ...  AND  Fail  Parametr energySavingMode for ${rmod} has not expected value  console=True
       ...  ELSE  Log  Parametr energySavingMode for ${rmod} has changed properly  console=True
    END

Check Rmod Power State
    [Arguments]  ${distname}  ${expected_powerState}
    ${expected_powerState}  Set Variable  ${expected_powerState.upper()}
    ${param_dict}  admin.Get Parameters  ${distname}
    ${actual_powerState}  Set Variable  ${param_dict['powerState'].upper()}
    Run Keyword If  '${actual_powerState}'=='${expected_powerState}'
    ...  Log  RMOD has correct power state - ${expected_powerState}${\n}  console=True
    ...  ELSE  Fail  ${\n}RMOD has not required power state - ${expected_powerState}

Check RMOD reset
    Log  ${\n}Checking if RMOD reset  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
      ${rmod_availability}  Run Keyword And Return Status
      ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${distname}  availabilityStatus=regex"(?i)not installed"  alias=${node}
      ${rmod_operability}  Run Keyword And Return Status
      ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${distname}  operationalState=regex"(?i)Disabled"  alias=${node}
      Run Keyword If  '${rmod_availability}'=='True' and '${rmod_operability}'=='True'
      ...  Log  RMOD-${rmod} has correct state, reset performed  console=True
      ...  ELSE  Run Keywords
      ...  Log  RMOD-${rmod} has wrong state, shoud be resetting  console=True
      ...  AND  Fail  RMOD-${rmod} has wrong state, shoud be resetting
    END

    Log  ${\n}Checking if cells have disabled/off line status  console=True
    FOR  ${cell}  IN  @{CELLS_DISTNAME_ID}
       ${cell_status}  Run Keyword And Return Status  Check If Cell Has Disabled/Off line Status  ${cell}
       Run Keyword If  '${cell_status}'=='True'
        ...  Log  ${cell} has correct status: disabled/off line  console=True
        ...  ELSE  Run Keywords
        ...  Log  ${cell} has incorrect status, should be disabled/off line${\n}  console=True
        ...  AND  Fail  ${cell} has incorrect status, should be disabled/off line
    END

Check If Cell Has Disabled/Off line Status
    [Arguments]  ${cell}
    ${class_id}  Evaluate  '${cell}'.split('/')[-1].split('_')[0]
    Run Keyword If  '${class_id}'=='NRCELL'
    ...  admin.Assert  NRCEL  ${cell}  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled"  timeout=60
    ...  ELSE
    ...  admin.Assert  ${class_id}  ${cell}  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled"  timeout=60


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore Energy Saving Mode Activation To Initial Status
    Common Test Teardown
