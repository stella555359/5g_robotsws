*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
Variables    tc_variables/sbts_sbts__state__rmod_high_temp_alarm_and_counters_check_cb011167.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3       # Number of RM reset operations, default value 3
${RM_SERIAL_NUMBER_LIST}             # Serial numbers of RMODs where test is done, separated by comma
${GRACEFUL_CELL_SHUTDOWN}    True    # Graceful cell shutdown: True or False; default value: True
${USER_RSI_INFO_COLLECT}     True    # Flag to enable/disable RMOD serial interface logs  collection. By default True
${RM_RESET_MAX_WAIT_TIME}    480     # Time interval to wait for RMOD Reset to finish
${PM_Counters_Check}         True    # PM counters check Flag for checking M40008C1 (Maximum temperature of a Radio Unit).
                                     # M40005C2	(Average temperature of an SFP/QSFP inserted into an RMOD)
                                     # Possible values: True or False; by default: True
${PM_INTERVAL}               15      # PM interval to get counters, default value 15 (minutes)

*** Keywords ***
TC__SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29070
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for raising high temperature alarm on RMOD, and checking associated counters: M40008C1, M40005C2
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - Check initial state and alarms for all BTS
    ...  - Get both BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info and cells info
    ...  - Update Thigh and NT_fail by using Frmon tool:
    ...     - generate "tcs_parameters.bin" and "/ram/tcs_parameters.json from Frmon tool
    ...     - update Thigh and NT_fail in tcs_parameters.json
    ...     - store changes in Frmon tool
    ...  - Reboot RMOD from WebEm. Check RMOD OperationalState=disabled , availabilityStatus=NotInstalled during Reset
    ...  - Check alarm (1936)EFaultId_FrTempHigh on RMOD in RawAlarmHistory.txt and IMS2 trace
    ...  - Check fault EFaultId_TemperatureHigh (1167) in fault_history_log.txt on RMOD
    ...  - Deactivate fault on RMOD through Frmon tool, by restoring initial Thigh and NT_fail.
    ...  - Reboot RMOD from WebEm. Check RMOD OperationalState=disabled , availabilityStatus=NotInstalled during Reset
    ...  - Check alarm (1936)EFaultId_FrTempHigh not visible any more on RMOD in RawAlarmHistory.txt and IMS2 trace
    ...  - Check fault EFaultId_TemperatureHigh (1167) not visible any more in fault_history_log.txt on RMOD
    ...  - Check that for counters regarding RMOD and SFP temperature, M40008C1, M40005C2, values are reported in PM interval
    ...    after Thigh and NT_fail modification
    ...  - Check final state and alarms for all BTS
    ...  - Repeat for next RMOD
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ***************************
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29070 - [CB011167] TEMP_RU_TEMP_FrTempHigh_counters
    ...  - 05.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29813 - Update with user/password changes for RF connection
    ...  - 20.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30171 - Update
    ...  SBTS_SBTS_STATE_RMOD_high_temp_alarm_and_counters_check_CB011167 regarding PM counter
    ...  - 27.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30420 - Update
    ...  SBTS_SBTS_STATE_RMOD_high_temp_alarm_and_counters_check_CB011167 test for restore in case of NA initial value

    Set Tags    CA-STATE    OWNER-carla-iazmina.urezeanu@nokia.com    AUTHOR-valentin.marian@nokia.com
    ...    PHASE-QT    SW-SBTS25R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check RMOD thermal monitoring counter settings
    Step 4: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform temperature test on RMODs  RMOD_list=${all_RM_sn_list}
    END

    [Teardown]    Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  \nStep ${index}: Check ${when} all BTS state\n  console=True
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

    Log  \nStep ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS info for configured items

    Log  \nStep ${index}: Get all BTS info for configured items  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${all_RM_sn_list}=  Combine Lists   ${shared_RM_sn_list}  ${dedicated_RM_sn_list}
    Set Test Variable  ${all_RM_sn_list}
    Set Test Variable  ${RM_sn_bts-alias_dict}

    Check RM serial number list

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_dedicated_RM_sn_list}=  Get dedicated RMOD list   ${dedicated_RM_sn_list}  ${alias}
        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}

        Set Test Variable  ${${alias}_BTS_dedicated_RM_sn_list}  ${BTS_dedicated_RM_sn_list}
        ${BTS_all_impacted_RM_sn_list}=  Combine Lists  ${BTS_dedicated_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_all_impacted_RM_sn_list}  ${BTS_all_impacted_RM_sn_list}

        Get BTS CELL list by RAT  ${alias}

    END

    FOR  ${RM_sn}  IN  @{all_RM_sn_list}

        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get RM info  ${RM_sn}  ${RM_bts-alias_list}

    END

Step ${index}: Check RMOD thermal monitoring counter settings
    [Documentation]
    ...  Check mtSBTSRMODTemperature mtSBTSSfpRMOD parameters on BTS

    Log  \nStep ${index}: Check mtSBTSRMODTemperature mtSBTSSfpRMOD parameters  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  Check mtSBTSRMODTemperature mtSBTSSfpRMOD parameters on BTS ${alias} and set them accordingly if needed  console=True

        ${BTS_RMOD_thermal_monitoring_counter_dict}=  Get RMOD thermal monitoring counter parameters
        ...  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
        Set Test Variable  ${${alias}_BTS_RMOD_thermal_monitoring_counter_dict}  ${BTS_RMOD_thermal_monitoring_counter_dict}

        ${remaining_time}=  Get Time  epoch
        ${remaining_time}=  Evaluate  ${PM_INTERVAL}*60 - ${remaining_time}%(${PM_INTERVAL}*60)

        ${condition1}=  Set Variable  '${BTS_RMOD_thermal_monitoring_counter_dict}[mtSBTSRMODTemperature]'!='${PM_INTERVAL}'
        ${condition2}=  Set Variable  '${BTS_RMOD_thermal_monitoring_counter_dict}[mtSBTSSfpRMOD]'!='${PM_INTERVAL}'
        Run Keyword If  ${condition1}
        ...  Set RMOD thermal monitoring counter parameter  mtSBTSRMODTemperature  ${PM_INTERVAL}min  ${alias}
        Run Keyword If  ${condition2}
        ...  Set RMOD thermal monitoring counter parameter  mtSBTSSfpRMOD  ${PM_INTERVAL}min  ${alias}
        Run Keyword If  ${condition1} or ${condition2}
        ...  Sleep  ${remaining_time}  Sleep ${remaining_time} until the end of the current PM period

        ${mt_param_seconds}=  Convert PM duration to seconds  ${PM_INTERVAL}
        Set Test Variable  ${${alias}_pm_seconds}  ${mt_param_seconds}
        Log  BTS ${alias} PM duration in seconds: ${${alias}_pm_seconds}  console=True
    END

Convert PM duration to seconds
    [Arguments]  ${pm_duration}

    ${pm_duration_value}=  Fetch From Left  ${pm_duration}  min
    ${pm_duration_value}=  Strip String  ${pm_duration_value}
    ${pm_duration_value_int}=  Convert To Integer  ${pm_duration_value}
    ${pm_duration_value_seconds}=  Evaluate  ${pm_duration_value_int}*60
    [Return]  ${pm_duration_value_seconds}

Recover initial RMOD thermal monitoring counter settings
    [Documentation]
    ...  Keyword used to recover initial RMOD thermal monitoring counter settings

    [Arguments]  ${alias}

    Log  Recover initial RMOD thermal monitoring counter settings on BTS ${alias}  console=True
    ${mtSBTSRMODTemperature_initial}=  Get From Dictionary  ${${alias}_BTS_RMOD_thermal_monitoring_counter_dict}  mtSBTSRMODTemperature
    ${mtSBTSSfpRMOD_initial}=  Get From Dictionary  ${${alias}_BTS_RMOD_thermal_monitoring_counter_dict}  mtSBTSRMODTemperature
    Set RMOD thermal monitoring counter parameter  mtSBTSRMODTemperature  ${mtSBTSRMODTemperature_initial}  ${alias}
    Set RMOD thermal monitoring counter parameter  mtSBTSSfpRMOD  ${mtSBTSSfpRMOD_initial}  ${alias}

Perform temperature test on RMODs
    [Arguments]    ${RMOD_list}

    FOR  ${RMOD_SN}  IN  @{RMOD_list}

        Set Test Variable  ${RMOD_SN}
        Step 5: Detect BTS and Cells of RMOD
        Step 6: Update RMOD temperature tresholds using frmon
        Run Keyword And Continue On Failure  Step 7: Perform RM Reset from WebEM
        Run Keyword And Continue On Failure  Step 8: Check RMOD and Cell state during reset RM
        Run Keyword And Continue On Failure  Step 9: Check RMOD and Cell states and BTS alarms after reset RM
        Run Keyword And Continue On Failure  Step 10: Check IMS and raw history alarms after modifying temperature parameters
        Run Keyword And Continue On Failure  Step 11: Check Frmon alarms after modify temperature parameters
        Step 12: Restore RMOD temperature tresholds using frmon
        Step 13: Perform RM Reset from WebEM without setting PM variables
        Step 14: Check RMOD and Cell state during reset RM
        Step 15: Check RMOD and Cell states and BTS alarms after reset RM
        Step 16: Check IMS and raw history alarms are cleared after modifying temperature parameters
        Step 17: Check Frmon alarms are cleared after restore temperature parameters
        Step 18: Check final all BTS state
        Step 19: Check final all BTS alarms
        Step 20: Check final number and state of Cells and RMs
        Step 21: Check PM counters for RMOD M40008C1 and SFP M40005C2

    END

Step ${index}: Detect BTS and Cells of RMOD

    Log  \nStep ${index}: Detect BTS and Cells of RMOD  console=True

    ${aliases}=  Copy List  ${RM_sn_bts-alias_dict}[${RMOD_SN}]
    FOR  ${alias}  IN  @{aliases}
        Run Keyword If  '${RMOD_SN}' in ${${alias}_BTS_all_impacted_RM_sn_list}
        ...  Run Keywords
        ...  Remove Values From List  ${aliases}  ${alias}
        ...  AND  Exit For Loop
    END
    ${alias_secondary}=  Set Variable If  ${aliases}  ${aliases[${0}]}  ${None}

    Log  ==============================================================================  console=True
    Log  Perform test on ${RMOD_SN} of  console=True
    Log  primaryController: ${alias}  console=True
    Run Keyword If  '${alias_secondary}'
    ...  Log  secondaryController: ${alias_secondary}  console=True
    ...  ELSE  Log  RMOD is dedicated to ${alias}  console=True
    Log  ==============================================================================  console=True

    Get RMOD Id SN mapping  ${alias}
    ${primarycontroller_RMOD_id}=  Get From Dictionary  ${rmod_SN_rmod_Id}  ${RMOD_SN}

    Run Keyword If  '${alias_secondary}'!='${None}'
    ...  Get RMOD Id SN mapping  ${alias_secondary}
    ${secondarycontroller_RMOD_id}=  Run Keyword If  '${alias_secondary}'!='${None}'
    ...  Get From Dictionary  ${rmod_SN_rmod_Id}  ${RMOD_SN}
    ...  ELSE  Set Variable  ${None}

    ${result}=  Create Dictionary  primaryController=${alias}  primaryControllerRMODid=${primarycontroller_RMOD_id}
    ...  secondaryController=${alias_secondary}  secondaryControllerRMODid=${secondarycontroller_RMOD_id}
    Set Test Variable  ${alias_and_id_dictionary}  ${result}

    ${configured}=  Set Variable If  '${alias_secondary}'!='${None}'  shared  dedicated
    Set Test Variable  ${configured}

    Get RM all cells from specific RAT  ${RMOD_SN}  ${primarycontroller_RMOD_ID}  ${configured}  ${alias}
    Run Keyword If  '${alias_secondary}'!='${None}'
    ...  Get RM all cells from specific RAT  ${RMOD_SN}  ${secondarycontroller_RMOD_ID}  ${configured}  ${alias_secondary}

Step ${index}: Update RMOD temperature tresholds using frmon

    Log  \nStep ${index}: Update RMOD temperature tresholds using Frmon  console=True
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}

    Perform Frmon Changes  RMOD_SN=${RMOD_SN}  desired_Thigh=20  desired_NT_fail=1

    Set Test Variable  ${restore_needed}  ${True}
    Log  RMOD temperature tresholds successfully updated using Frmon  console=True

Step ${index}: Restore RMOD temperature tresholds using frmon

    ${restore_needed}=  Get Variable Value  ${restore_needed}  ${False}
    Run Keyword If  not ${restore_needed}
    ...  Run Keywords  Log  Restore Thigh and NT_Fail not needed because they were not modified  console=True
    ...  AND  Return From Keyword

    Log  \nStep ${index}: Restore RMOD temperature tresholds using Frmon  console=True
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}

    Perform Frmon Changes  RMOD_SN=${RMOD_SN}  desired_Thigh=${old_thigh}  desired_NT_fail=${old_ntfail}

    Set Test Variable  ${restore_needed}  ${False}
    Log  RMOD temperature tresholds successfully restored using Frmon  console=True

Perform Frmon Changes
    [Arguments]    ${RMOD_SN}  ${desired_Thigh}  ${desired_NT_fail}

    ${cmd_1}=  Set Variable  frmonShellClient localhost 2000
    ${response_1}=  Set Variable  $
    ${cmd_2}=  Set Variable  / action create ConfigAccess /ca /module
    ${response_2}=  Set Variable  done ok
    ${cmd_3}=  Set Variable  /ca action fetch DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"
    ${response_3}=  Set Variable  done ok
    ${cmd_4}=  Set Variable  \x03
    ${response_4}=  Set Variable  connection closed
    ${cmd_5}=  Set Variable  chmod 766 /ram/tcs_parameters.json
    ${cmd_6}=  Set Variable  cat /ram/tcs_parameters.json
    ${response_6}=  Set Variable  "tcs"

    ${exit_sequence}=  Create Dictionary  ${cmd_4}=${Empty}
    Set Test Variable  ${exit_sequence}
    ${command_and_response_dict_read}=  Create Dictionary  ${cmd_1}=${response_1}  ${cmd_2}=${response_2}  ${cmd_3}=${response_3}
    ...  ${cmd_4}=${response_4}  ${cmd_5}=${Empty}  ${cmd_6}=${response_6}
    Set Test Variable  ${command_and_response_dict_read}
    ${tcs_file_content}=  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${command_and_response_dict_read}
    ${tcs_dictionary}=  Evaluate  json.loads('''${tcs_file_content}''')  modules=json


    ${tcs}=  Get From Dictionary  ${tcs_dictionary}  tcs
    ${old_thigh}=  Get From Dictionary  ${tcs}  Thigh
    Set Test Variable  ${old_thigh}
    ${old_ntfail}=  Get From Dictionary  ${tcs}  NT_fail
    Set Test Variable  ${old_ntfail}

    Set To Dictionary  ${tcs}  Thigh=${desired_Thigh}  NT_fail=${desired_NT_fail}
    Set To Dictionary  ${tcs_dictionary}  tcs=${tcs}
    ${tcs_file_content}=  Evaluate  json.dumps(${tcs_dictionary}, indent=4)  modules=json

    ${cmd_6}=  Set Variable  echo '${tcs_file_content}' > /ram/tcs_parameters_${desired_NT_fail}.json
    ${cmd_7}=  Set Variable  chmod 766 /ram/tcs_parameters_${desired_NT_fail}.json
    ${command_and_response_dict_write}=  Create Dictionary  ${cmd_6}=${Empty}  ${cmd_7}=${Empty}
    Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${command_and_response_dict_write}
    ...  linux_commands_as_rfsw=${False}

    ${cmd_8}=  Set Variable  frmonShellClient localhost 2000
    ${response_8}=  Set Variable  $
    ${cmd_9}=  Set Variable  /ca action store PERMANENT DECODED "tcs_parameters.bin" "/ram/tcs_parameters_${desired_NT_fail}.json"
    ${response_9}=  Set Variable  done ok
    ${cmd_10}=  Set Variable  /ca action update
    ${response_10}=  Set Variable  done ok
    ${command_and_response_dict_write}=  Create Dictionary  ${cmd_8}=${response_8}  ${cmd_9}=${response_9}  ${cmd_10}=${response_10}
    Set Test Variable  ${command_and_response_dict_write}
    Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${command_and_response_dict_write}

    [Teardown]  Run Keyword If  ${frmon_mode}
    ...  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${exit_sequence}

Step ${index}: Check Frmon alarms after modify temperature parameters

    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    Log  \nStep ${index}: Check Frmon alarms after modify temperature parameters on ${RMOD_SN}  console=True

    ${cmd_1}=  Set Variable  frmonShellClient localhost 2000
    ${response_1}=  Set Variable  $
    ${cmd_2}=  Set Variable  / action create FaultControl /CI/FaultControl /module
    ${response_2}=  Set Variable  done ok
    ${cmd_3}=  Set Variable  /CI/FaultControl action fetch_history
    ${response_3}=  Set Variable  done ok
    ${cmd_4}=  Set Variable  \x03
    ${response_4}=  Set Variable  connection closed
    ${cmd_5}=  Set Variable  chmod 744 /run/fault_history_log.txt
    ${cmd_6}=  Set Variable  cat /run/fault_history_log.txt
    ${response_6}=  Set Variable  EFaultId_TemperatureHigh \\(1167\\)\\s+module\\s+minor\\s+active

    ${exit_sequence}=  Create Dictionary  ${cmd_4}=${Empty}
    ${command_and_response_dict}=  Create Dictionary  ${cmd_1}=${response_1}  ${cmd_2}=${response_2}  ${cmd_3}=${response_3}  ${cmd_4}=${response_4}
    ...  ${cmd5}=${Empty}  ${cmd6}=${response_6}
    ${cmd_status}=  Run Keyword And Return Status
    ...  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${command_and_response_dict}
    ...  expected_output_as_regex=${True}

    Run Keyword If  ${cmd_status}
    ...  Log  Fault: EFaultId_TemperatureHigh (1167) found successfully in Frmon report  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault: EFaultId_TemperatureHigh (1167) could not be found in Frmon report  console=True
    ...  AND
    ...  Fail  Fault: EFaultId_TemperatureHigh (1167) could not be found in Frmon report  console=True

    [Teardown]  Run Keyword If  ${frmon_mode}
    ...  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${exit_sequence}

Step ${index}: Check Frmon alarms are cleared after restore temperature parameters

    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    Log  \nStep ${index}: Check Frmon alarms cleared after restore temperature parameters on ${RMOD_SN}  console=True

    ${cmd_1}=  Set Variable  frmonShellClient localhost 2000
    ${response_1}=  Set Variable  $
    ${cmd_2}=  Set Variable  / action create FaultControl /CI/FaultControl /module
    ${response_2}=  Set Variable  done ok
    ${cmd_3}=  Set Variable  /CI/FaultControl action fetch_history
    ${response_3}=  Set Variable  done ok
    ${cmd_4}=  Set Variable  \x03
    ${response_4}=  Set Variable  connection closed
    ${cmd_5}=  Set Variable  chmod 744 /run/fault_history_log.txt
    ${cmd_6}=  Set Variable  cat /run/fault_history_log.txt
    ${response_6}=  Set Variable  EFaultId_TemperatureHigh \\(1167\\)\\s+module\\s+minor\\s+active

    ${exit_sequence}=  Create Dictionary  ${cmd_4}=${Empty}
    ${command_and_response_dict}=  Create Dictionary  ${cmd_1}=${response_1}  ${cmd_2}=${response_2}  ${cmd_3}=${response_3}  ${cmd_4}=${response_4}
    ...  ${cmd_5}=${Empty}
    ${alarm_check_dict}=  Create Dictionary  ${cmd_6}=${response_6}

    Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${command_and_response_dict}

    ${cmd_status}=  Run Keyword And Return Status
    ...  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${alarm_check_dict}

    Run Keyword If  not ${cmd_status}
    ...  Log  Fault: EFaultId_TemperatureHigh (1167) cleared successfully from Frmon report  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault: EFaultId_TemperatureHigh (1167) could not be cleared from Frmon report  console=True
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  Fault: EFaultId_TemperatureHigh (1167) could not be cleared from Frmon report  console=True

    [Teardown]  Run Keyword If  ${frmon_mode}
    ...  Command list executor  RMOD_SN=${RMOD_SN}  command_and_response_dict=${exit_sequence}

Command list executor
    [Arguments]    ${RMOD_SN}  ${command_and_response_dict}  ${linux_commands_as_rfsw}=${True}
    ...  ${expected_output_as_regex}=${False}

    ${frmon_mode} =  Set Variable  ${False}
    ${as_rfsw}=  Evaluate  not ${frmon_mode} and ${linux_commands_as_rfsw}
    Set Test Variable  ${frmon_mode}

    FOR  ${cmd}  ${expected_response}  IN  &{command_and_response_dict}
        Log  Serial console: ${cmd}  console=True
        Log  Frmon mode: ${frmon_mode}  console=True
        Log  As rfsw user: ${as_rfsw}  console=True
        ${status}  ${output}=  RSI Execute Command  cmd=${cmd}
        ...  connection=${RMOD_SN}  as_rfsw=${as_rfsw}
        Should Be True  '${status}'=='PASS'
        Run Keyword If  '${expected_response}' and not ${expected_output_as_regex}
        ...  Should Contain  ${output}  ${expected_response}
        ...  ELSE IF  '${expected_response}' and ${expected_output_as_regex}
        ...  Should Match Regexp  ${output}  ${expected_response}
        Log  -> Ok\n  console=True
        ${frmon_mode}=  Set Variable If  '${expected_response}'=='$'
        ...  ${True}  ${frmon_mode}
        ${frmon_mode}=  Set Variable If  '${expected_response}'=='connection closed'
        ...  ${False}  ${frmon_mode}
        ${as_rfsw}=  Evaluate  not ${frmon_mode} and ${linux_commands_as_rfsw}
        Set Test Variable  ${frmon_mode}
    END
    [Return]    ${output}

Step ${index}: Perform RM Reset from WebEM

    Log  \nStep ${index}: Perform RM Reset via WebEM for temperature parameters update  console=True

    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid

    Start new ADMIN instance  alias=${primary_controller_alias}  new_alias=${primary_controller_alias}_new
    ...  connection_type=${connection_type_${primary_controller_alias}}

    Synchronize RM reset to PM generation  mt_param_seconds=${${primary_controller_alias}_pm_seconds}

    Get Current Date UTC info  start_alarm
    Get Current Date UTC info  start_reset

    ${reset_info}=  RFS RM Reset  dist_name=${RMOD_ID}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${primary_controller_alias}_new
    ...  alias=${primary_controller_alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Set Test Variable  ${reset_info}

Step ${index}: Perform RM Reset from WebEM without setting PM variables

    Log  \nStep ${index}: Perform RM Reset from WebEM without setting PM and alarms variables  console=True

    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid

    Start new ADMIN instance  alias=${primary_controller_alias}  new_alias=${primary_controller_alias}_new
    ...  connection_type=${connection_type_${primary_controller_alias}}

    Synchronize second RM reset to first RM Reset for PM  old_reset_time=${date_timestamp_start_reset_UTC}
    ...  mt_param_seconds=${${primary_controller_alias}_pm_seconds}
    Get Current Date UTC info  start_reset

    ${reset_info}=  RFS RM Reset  dist_name=${RMOD_ID}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${primary_controller_alias}_new
    ...  alias=${primary_controller_alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Set Test Variable  ${reset_info}

Synchronize RM reset to PM generation
    [Arguments]  ${mt_param_seconds}

    Run Keyword If  not ${PM_Counters_Check}  Run Keywords
    ...  Log  Skipping synchronization with PM period due to \$\{PM_Counters_Check\} = ${PM_Counters_Check}  console=True
    ...  AND  Return From Keyword

    ${epoch_time_now}=  GET event epoch time
    ${current_PM_sec_elapsed}=  Evaluate  ${epoch_time_now}%${mt_param_seconds}
    ${mid_PM_duration_seconds}=  Evaluate  ${mt_param_seconds}/2
    ${mid_PM_duration_seconds_int}=  Convert To Integer  ${mid_PM_duration_seconds}
    ${time_to_wait}=  Evaluate  ${mt_param_seconds}-${current_PM_sec_elapsed}
    ${time_to_wait}=  Evaluate  ${time_to_wait}+45
    Run Keyword If  ${current_PM_sec_elapsed}>${mid_PM_duration_seconds}  Run Keywords
    ...  Log  Waiting ${time_to_wait} seconds more to synchronize event with PM generation  console=True
    ...  AND  Sleep  ${time_to_wait}s

Synchronize second RM reset to first RM Reset for PM
    [Arguments]  ${old_reset_time}  ${mt_param_seconds}

    Run Keyword If  not ${PM_Counters_Check}  Run Keywords
    ...  Log  Skipping synchronization with PM period due to \$\{PM_Counters_Check\} = ${PM_Counters_Check}  console=True
    ...  AND  Return From Keyword

    ${epoch_time_now}=  GET event epoch time
    ${old_reset_epoch_time}=  Convert Date  ${old_reset_time}  epoch
    ${time_to_wait}=  Evaluate  2*${mt_param_seconds}-${epoch_time_now}+${old_reset_epoch_time}-${old_reset_epoch_time}%${mt_param_seconds}
    Log  Waiting ${time_to_wait} seconds more to allow 1 full PM period since last reset  console=True
    Sleep  ${time_to_wait}s

GET event epoch time
    ${epoch_time}=  OperatingSystem.Run    date +%s
    [Return]  ${epoch_time}

Step ${index}: Check RMOD and Cell state during reset RM

    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid
    ${secondary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryController
    ${RMOD_ID_secondary}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryControllerRMODid
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${configured}=  Get Variable Value  ${configured}
    ${reset_info}=  Get Variable Value  ${reset_info}

    Log  \nStep ${index}: Check RMOD and Cell state during RMOD ${RMOD_SN}, ${RMOD_ID} reset  console=True

    Check RMOD and Cells state on BTS during reset  ${primary_controller_alias}  ${RMOD_ID}  ${RMOD_SN}  ${configured}
    Check RMOD and Cells state on BTS during reset  ${secondary_controller_alias}  ${RMOD_ID_secondary}  ${RMOD_SN}  ${configured}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
    Collect Keyword Result  ${reset_info}  timeout=${remained_MAX_WAIT_TIME}

Check RMOD and Cells state on BTS during reset
    [Arguments]    ${alias}  ${RMOD_ID}  ${RMOD_SN}  ${configured}

    Return From Keyword If  '${alias}'=='${None}'

    Log  \nCheck RMOD ${RMOD_SN}, ${RMOD_ID} and Cells state on BTS ${alias} during reset  console=True
    ${RM_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RM_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked

    Log  \nCheck BTS ${alias} ${configured} RM with SN ${RMOD_SN} status: ${RM_state_disabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
    Check RM state  ${RMOD_SN}  ${RMOD_ID}  shared  ${RM_state_disabled_check}  ${RM_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  RM with SN ${RMOD_SN} status succeessfully found: - ${RM_state_disabled}  console=True

    Log  \nCheck BTS ${alias} cells mapped on RM with SN ${RMOD_SN}: Cell channel state matching cell state  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}  10s  Check cells state mapped on RM  ${alias}
    Log  Cells state on RM with SN ${RMOD_SN} succeessfully checked: All cells' state matches their channels' state  console=True

    Log  \nCheck BTS ${alias} cells status: ${Enabled_} for any cells not mapped on RM with SN ${RMOD_SN}:  console=True
    Check cells state not mapped on RM  ${RMOD_SN}  ${alias}  ${configured}
    Log  Cells status check for any cells not mapped on RM with SN ${RMOD_SN} finished successfully  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  \nStep ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM serial number list
    ${RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RM_SERIAL_NUMBER_LIST}=  Split String  ${RM_SERIAL_NUMBER_LIST_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_sn_check_serial}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List
    ${RM_SN_no_serial_list}=  Create List
    FOR  ${item}  IN  @{RM_SERIAL_NUMBER_LIST}
        ${RM_sn_check}=  Set Variable If  '${item}' not in ${all_RM_sn_list}  False  ${RM_sn_check}
        ${RM_sn_check_serial}=  Set Variable If  '${item}' not in ${rsi_rmod_setup_list}  False  ${RM_sn_check_serial}
        Run Keyword If  '${item}' not in ${all_RM_sn_list}  Append To List  ${RM_sn_invalide_list}  ${item}
        Run Keyword If  not ${RM_sn_check_serial}  Append To List  ${RM_sn_no_serial_list}  ${item}
    END
    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RM_SERIAL_NUMBER_LIST} from configured RM: ${all_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Run Keyword If  '${RM_sn_check_serial}' == 'False'  Run Keywords
    ...  Log  Could not establish serial connections to following RMOD: ${RM_sn_no_serial_list}.  console=True
    ...  AND  Fail  No serial connection to needed RMODs!
    Set Test Variable  ${all_RM_sn_list}  ${RM_SERIAL_NUMBER_LIST}

Get dedicated RMOD list
    [Arguments]  ${dedicated_RM_sn_list}  ${alias}

    ${BTS_dedicated_RM_sn_list}=  Create List
    FOR  ${RMOD_sn}  IN  @{dedicated_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RMOD_sn}
        Run Keyword If  '${alias}' in ${RM_bts-alias_list}
        ...  Append To List  ${BTS_dedicated_RM_sn_list}  ${RMOD_sn}
    END

    [Return]  ${BTS_dedicated_RM_sn_list}

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

Get RM info
    [Arguments]   ${RM_sn}  ${RM_bts-alias_list}
    Log  RM with SN ${RM_sn} info:  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${BTS_role}=  Set Variable If  '${RM_sn}' in ${${alias}_BTS_primary_controller_shared_RM_sn_list} or ${${alias}_BTS_dedicated_RM_sn_list}
        ...  Primary Controller  '${RM_sn}' in ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Secondary Controller
        Log  - BTS ${alias} role: ${BTS_role} -> RM id: ${RM_id}  console=True
    END

Get RM all cells from specific RAT
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${alias}
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
    ${CELL_RM_list}=  Combine Lists   ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_NR_CELL_RM_list}  ${NR_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_list}  ${LTE_CELL_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RM_list}  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_CELL_RM_list}  ${CELL_RM_list}
    Log  BTS ${alias} cells mapped on ${configured} RM with SN ${RM_sn}:  console=True
    Run Keyword If  ${NR_CELL_RM_list}  Log  - NRCEL: ${${alias}_NR_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_CELL_RM_list}  Log  - LNCEL: ${${alias}_LTE_CELL_RM_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RM_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_RM_list}  console=True
    Run Keyword If  ${GSM_CELL_RM_list}  Log  - GNCEL: ${${alias}_GSM_CELL_RM_list}  console=True

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
    Sort List  ${NR_CELL_not_RM_list}
    Sort List  ${LTE_CELL_not_RM_list}
    Sort List  ${WCDMA_CELL_not_RM_list}
    Sort List  ${GSM_CELL_not_RM_list}
    ${CELL_not_RM_list}=  Combine Lists  ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${${alias}_NR_CELL_not_RM_list}  ${NR_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${${alias}_CELL_not_RM_list}  ${CELL_not_RM_list}

Check RM state
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${RM_state_check}  ${RM_state}  ${timeout}  ${alias}

    Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} ${configured} RM with SN ${RM_sn} status:\n - ${RM_state}  console=True

Check cells state mapped on RM
    [Arguments]  ${alias}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RM_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RM_list}  alias=${alias}
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RM_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RM_list}  alias=${alias}
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RM_list}  alias=${alias}
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RM_list}  alias=${alias}

Check cells state not mapped on RM
    [Arguments]  ${RM_sn}  ${alias}  ${configured}

    ${CELL_state_enabled_check}=  Set Variable
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_enabled}=  Set Variable
    ...  operationalState=Enabled, administrativeState=Unlocked

    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}  Run Keywords
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    ...  AND  Log  BTS ${alias} NRCELs not mapped on ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    ...  ELSE  Log  No NRCELs mapped on BTS ${alias} ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}  Run Keywords
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    ...  AND  Log  BTS ${alias} LNCELs not mapped on ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    ...  ELSE  Log  No LNCELs mapped on BTS ${alias} ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}  Run Keywords
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    ...  AND  Log  BTS ${alias} WNCELs not mapped on ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    ...  ELSE  Log  No WNCELs mapped on BTS ${alias} ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}  Run Keywords
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    ...  AND  Log  BTS ${alias} GNCELs not mapped on ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True
    ...  ELSE  Log  No GNCELs mapped on BTS ${alias} ${configured} RM with SN ${RM_sn}: - ${CELL_state_enabled}  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Step ${index}: Check IMS and raw history alarms after modifying temperature parameters

    Log  Step ${index}: Check IMS alarms after modify temperature parameters  console=True
    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID_primary}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid

    Log  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, expected in ims2 trace
    ...  console=True
    ${temperature_RatingValue_overheated_found}=  Check object status change for desired parameter value
    ...  alias=${primary_controller_alias}  object_dn=RADIO_TEMPERATURE_NOTIF-  parameter_name=temperatureRatingValue  parameter_value=Overheated
    ...  start_timestamp=${date_timestamp_start_alarm_UTC}
    Run Keyword If  ${temperature_RatingValue_overheated_found}
    ...  Log  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, found in ims2 trace as expected!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, not found in ims2 trace!
    ...  console=True
    ...  AND  Fail  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, not found in ims2 trace!

    ${event_epoch_time}=  GET event epoch time
    Set Test Variable  ${event_epoch_time}
    Log  Event epoch time: ${event_epoch_time}  console=True

    Log  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, expected in raw alarm history  console=True
    ${raw_alarm_history_file}=  Set Variable  ${Test Results Dir}/BTSFiles/${primary_controller_alias}/raw_alarm_history.txt
    Wait Until Keyword Succeeds  3x  30s
    ...  coam.Collect Raw Alarm History File  target_file_name=${raw_alarm_history_file}  connection=${primary_controller_alias}
    ${raw_alarm_content}=  OperatingSystem.Get File  ${raw_alarm_history_file}
    ${alarm_found}=  Run Keyword And Return Status  Should Match Regexp
    ...  ${raw_alarm_content}
    ...  Active faults[\\s|\\S]+\\(1936\\)\\s*EFaultId_FrTempHigh[\\s|\\S]+Inactive faults
    Run Keyword If  ${alarm_found}
    ...  Log  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, found in raw alarm history, as expected!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log
    ...  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, not found active alarms, in raw alarm history!
    ...  console=True
    ...  AND  Fail
    ...  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, not found active alarms, in raw alarm history!

Step ${index}: Check IMS and raw history alarms are cleared after modifying temperature parameters

    Log  \nStep ${index}: Check IMS alarms after modify temperature parameters  console=True
    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID_primary}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid

    Log  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, expected to be cleared from ims2 trace
    ...  console=True
    ${temperature_RatingValue_overheated_found}=  Check object status change for desired parameter value
    ...  alias=${primary_controller_alias}  object_dn=RADIO_TEMPERATURE_NOTIF-  parameter_name=temperatureRatingValue  parameter_value=Overheated
    ...  start_timestamp=${date_timestamp_start_reset_UTC}
    Run Keyword If  not ${temperature_RatingValue_overheated_found}
    ...  Log  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF" with temperatureRatingValue=Overheated, cleared from ims2 trace as expected!
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log
    ...  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF", temperatureRatingValue=Overheated, still found in ims2 trace, notif not cleared!
    ...  console=True
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail
    ...  BTS ${primary_controller_alias} "RADIO_TEMPERATURE_NOTIF", temperatureRatingValue=Overheated, still found in ims2 trace, notif not cleared!

    Log  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, expected to be cleared from raw active alarms
    ...  console=True
    ${raw_alarm_history_file}=  Set Variable  ${Test Results Dir}/BTSFiles/${primary_controller_alias}/raw_alarm_history.txt
    coam.Collect Raw Alarm History File  target_file_name=${raw_alarm_history_file}  connection=${primary_controller_alias}
    ${raw_alarm_content}=  OperatingSystem.Get File  ${raw_alarm_history_file}
    ${alarm_not_found}=  Run Keyword And Return Status  Should Not Match Regexp
    ...  ${raw_alarm_content}
    ...  Active faults[\\s|\\S]+\\(1936\\)\\s*EFaultId_FrTempHigh[\\s|\\S]+Inactive faults
    Run Keyword If  ${alarm_not_found}
    ...  Log  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, cleared from raw active alarms, as expected.
    ...  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, not cleared from raw active alarms!
    ...  console=True
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  BTS ${primary_controller_alias} "(1936) EFaultId_FrTempHigh" BTS internal fault, not cleared from raw active alarms!

Step ${index}: Check RMOD and Cell states and BTS alarms after reset RM

    Log  \nStep ${index}: Check RMOD and Cell states and BTS alarms after reset RM  console=True

    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID_primary}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid
    ${secondary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryController
    ${RMOD_ID_secondary}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryControllerRMODid
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${configured}=  Get Variable Value  ${configured}

    ${RM_state_enabled_check}=  Set Variable
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RM_state_enabled}=  Set Variable
    ...  operationalState=Disabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_enabled}=  Set Variable
    ...  operationalState=Enabled, administrativeState=Unlocked

    ${aliases}=  Create List  ${primary_controller_alias}
    ${RM_ids}=  Create List  ${RMOD_ID_primary}
    Run Keyword If  '${secondary_controller_alias}' != '${None}'  Run Keywords
    ...  Append To List  ${aliases}  ${secondary_controller_alias}
    ...  AND  Append To List  ${RM_ids}  ${RMOD_ID_secondary}

    FOR  ${alias}  ${RM_id}  IN ZIP  ${aliases}  ${RM_ids}
        Log  \nChecking BTS ${alias} RM state:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
        Check RM state  ${RMOD_SN}  ${RM_id}  ${configured}  ${RM_state_enabled_check}  ${RM_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

        Log  \nChecking BTS ${alias} cells state ${CELL_state_enabled}:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
        Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}  timeout=${remained_MAX_WAIT_TIME}
        Log  All BTS ${alias} cell(s) status: - ${CELL_state_enabled}  console=True

        Log  \nChecking BTS ${alias} cells AvailabilityStatus : online  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
        Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
        Log  All BTS ${alias} cell(s) AvailabilityStatus: - online  console=True

        Log  \nCheck BTS ${alias} has no alarms:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${date_timestamp_start_reset_UTC}  ${RM_RESET_MAX_WAIT_TIME}
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}  wait_for_alarm_clear=${remained_MAX_WAIT_TIME}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check PM counters for RMOD M40008C1 and SFP M40005C2

    Run Keyword If  not ${PM_Counters_Check}
    ...  Run Keywords
    ...  Log  \nSkipping PM counters check due to \$\{PM_Counters_Check\} = ${PM_Counters_Check}  console=${True}
    ...  AND  Return From Keyword
    ...  ELSE  Log  \nStep ${index}: Check PM counters for RMOD M40008C1 and SFP M40005C2  console=True

    ${primary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryController
    ${RMOD_ID_primary}=  Get From Dictionary  ${alias_and_id_dictionary}  primaryControllerRMODid
    ${secondary_controller_alias}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryController
    ${RMOD_ID_secondary}=  Get From Dictionary  ${alias_and_id_dictionary}  secondaryControllerRMODid
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${configured}=  Get Variable Value  ${configured}

    Run Keyword And Continue on Failure  Check PM counter M40008C1  ${RMOD_sn}  ${RMOD_ID_primary}  ${primary_controller_alias}  ${event_epoch_time}
    Run Keyword And Continue on Failure  Check PM counter M40005C2  ${RMOD_sn}  ${RMOD_ID_primary}  ${primary_controller_alias}  ${event_epoch_time}

Check PM counter M40008C1
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${alias}  ${reset_date_epoch}

    Log  ***** Checking M40008C1 counter value on BTS ${alias}  console=True
    ${RMOD_scf_id}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${pm_date_epoch}=  Evaluate  ${reset_date_epoch}+${${alias}_pm_seconds}

    ${epoch_time_now}=  OperatingSystem.Run    date +%s
    ${elapsed_time_seconds}=  Evaluate  ${epoch_time_now}-${reset_date_epoch}
    ${remaining_time}=  Evaluate  ${${alias}_pm_seconds}-${elapsed_time_seconds}%${${alias}_pm_seconds}+45

    Run Keyword If  ${remaining_time}>0  Run Keywords
    ...  Log  Waiting ${remaining_time}s for PM completion  console=True
    ...  AND  Sleep  ${remaining_time}s

    Run Keyword If  '${RMOD_scf_id}'
    ...  Run Keywords
    ...  Log  ***** SFP Reatlime DN for RMOD ${RMOD_sn} with id ${RMOD_id} on BTS ${alias}:  console=True
    ...  AND  Log  ${RMOD_scf_id}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD SCF DN could not be retrieved!  level=ERROR
    ...  AND  Fail  RMOD SCF DN could not be retrieved!

    ${counter_value}=  Get PM Counter Value from Admin
    ...  ${RMOD_scf_id}/SBTS_RMOD_TEMPERATURE   M40008C1  ${reset_date_epoch}  ${${alias}_pm_seconds}  ${alias}

    Run Keyword If  '${counter_value}'
    ...  Log  ***** Counter M40008C1 on RMOD ${RMOD_sn} with realtime ID ${RMOD_id} on BTS ${alias}: ${counter_value}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ***** Counter M40008C1 on RMOD ${RMOD_sn} with realtime ID ${RMOD_id} on BTS ${alias} could not be retrieved!  level=ERROR
    ...  AND  Fail  Counter M40008C1 on RMOD ${RMOD_sn} with realtime ID ${RMOD_id} on BTS ${alias} could not be retrieved!

Check PM counter M40005C2
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${alias}  ${reset_date_epoch}

    Log  ***** Checking M40005C2 counter value on BTS ${alias}  console=True
    ${RMOD_scf_id}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${bts_rmod_sfp_list}=  Get SFP list from BTS module  RMOD  ${alias}
    ${rmod_sfp_r_dn_list}=  Create List

    FOR  ${sfp}  IN  @{bts_rmod_sfp_list}
        Run Keyword If  '${RMOD_id}' in '${sfp}'
        ...  Append To List  ${rmod_sfp_r_dn_list}  ${sfp}
    END

    ${All_SFP_list}=  coam.Get SFP data  connection=${alias}
    ${sfp_scf_dn_list}=  Create list
    FOR  ${item}  IN  @{All_SFP_list['connected']}
        ${SFP_scf_DN}=  Set Variable  ${Empty}
        ${SFP_source_internal_DN}=  Get Variable Value  ${item['source']['connector']['extendedId']['internal']}  ${Empty}
        ${SFP_source_scf_DN}=  Get Variable Value  ${item['source']['connector']['extendedId']['configuration']}  ${Empty}
        ${SFP_destination_internal_DN}=  Get Variable Value  ${item['destination']['connector']['extendedId']['internal']}  ${Empty}
        ${SFP_destination_scf_DN}=  Get Variable Value  ${item['destination']['connector']['extendedId']['configuration']}  ${Empty}
        ${SFP_scf_DN}=  Set Variable if  '${SFP_source_internal_DN}' in @{rmod_sfp_r_dn_list}
        ...  ${SFP_source_scf_DN}  ${SFP_scf_DN}
        ${SFP_scf_DN}=  Set Variable if  '${SFP_destination_internal_DN}' in ${rmod_sfp_r_dn_list}
        ...  ${SFP_destination_scf_DN}  ${SFP_scf_DN}
        Run Keyword If  '${SFP_scf_DN}'  Append To List  ${sfp_scf_dn_list}  ${SFP_scf_DN}
    END

    ${sfp_dn_for_counters}=  Create List
    FOR  ${item}  IN  @{sfp_scf_dn_list}
        ${sfp_number}=  Get Regexp Matches  ${item}  ([0-9]+)$  1
        Append To List  ${sfp_dn_for_counters}  ${RMOD_scf_id}/SFP-${sfp_number[${0}]}
    END

    Run Keyword If  ${sfp_dn_for_counters}
    ...  Run Keywords
    ...  Log  ***** SFP Realtime DN for RMOD ${RMOD_sn} with id ${RMOD_id} on BTS ${alias}:  console=True
    ...  AND  Log  ${rmod_sfp_r_dn_list}  console=True
    ...  AND  Log  ***** SFP SCF DN:  console=True
    ...  AND  Log  ${sfp_scf_dn_list}  console=True
    ...  AND  Log  ***** SFP DN for counters:  console=True
    ...  AND  Log  ${sfp_dn_for_counters}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD SFP DN could not be retrieved!  level=ERROR
    ...  AND  Fail  RMOD SFP DN could not be retrieved!

    FOR  ${sfp_scf_id}  IN  @{sfp_dn_for_counters}
        ${counter_value}=  Get PM Counter Value from Admin
        ...  ${sfp_scf_id}/SBTS_SFP_RMOD   M40005C2  ${reset_date_epoch}  ${${alias}_pm_seconds}  ${alias}
        Run Keyword If  '${counter_value}'
        ...  Log  Counter M40005C2 on RMOD ${RMOD_sn}, BTS ${alias}, SFP ${sfp_scf_id}: ${counter_value}  console=True
        ...  ELSE  Run Keywords
        ...  Log  Counter M40005C2 on RMOD ${RMOD_sn}, BTS ${alias}, SFP ${sfp_scf_id} could not be retrieved!  level=ERROR
        ...  AND  Fail  Counter M40005C2 on RMOD ${RMOD_sn}, BTS ${alias}, SFP ${sfp_scf_id} could not be retrieved!
    END

Particular Teardown

    Log  \nRestore RMOD thermal monitoring counter settings  console=True
    FOR  ${alias}  IN  @{alias_list}
        Recover initial RMOD thermal monitoring counter settings  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}
    ...  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown