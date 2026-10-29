*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
Variables    tc_variables/sbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                        3                    # Number of RM reset operations, default value 3
${RMOD_CLIMATE_CONTROL_PROFILING_LIST}    Optimized Cooling,Linear,Low Noise    # climateControlProfiling values selected by user to perform test with
${RM_SERIAL_NUMBER_LIST}                 ALL                  # Serial numbers of RMODs where test is done, separated by comma
${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}                  # Serial numbers of RMODs which do not support checks
${start_climateControlProfiling_value}   Optimized Cooling    # Value which will be initially commissioned in case for one or more RMOD,
                                                              # climateControlProfiling is not set at all
${file_name_regex}                       .*SOAP.*[.]xml[.]gz    # Expression describing soap trace files from snapshot,
                                                                # which are parsed to check the profile modification
${delay_to_snapshot_save}                30                   # Delay in seconds between temperature control profile commissioning
                                                              # and snapshot saving


*** Keywords ***
TC__SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29086
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for testing the possibility to modify fan temperature control profiles for RMODs
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - Check initial state and alarms for all BTS
    ...  - Get for each RMOD information about primaryController, secondaryController BTS
    ...  - For each RMOD
    ...        For each value from input parameter \$\{climateControlProfiling\}
    ...            Set up climateControlProfiling parameter on primaryController BTS of the RMOD with the first value form input parameter
    ...            Check state and alarms for all BTS to make sure no alarm or change state occured as a result of parameter commissioning
    ...            Get BTS Snapshot from primaryController BTS
    ...            In BTS snapshot, check in syslog, in SOAP log messages the expected regex indicating the profile selected for our RMOD
    ...            Check final state and alarms for all BTS
    ...  - Restore initial climateControlProfiling value on each BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ***************************
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29086 -
    ...  [5G][CB010874]RFS_SBTS_SBTS_CB010874_Fan_temperature_control_profiles_for_5G_RUs
    ...  - 23.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29890 -
    ...  Fan temperature control profiles for 5G RUs_CB010874 checks the wrong log file
    ...  for climate profile switch - temporary fix

    Set Tags    CA-STATE    OWNER-radu.hirsovescu@nokia.com    AUTHOR-valentin.marian@nokia.com    PHASE-QT    SW-SBTS25R3

    TC preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Detect BTS and Cells of RMOD
    Step 5: Get initial climateControlProfiling values on primaryController of each RMOD
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform climateControlProfiling test on RMODs  RMOD_list=${all_RM_sn_list}

    END

    [Teardown]    Step 12: Restore initial climateControlProfiling value on primaryController of each RMOD

Perform climateControlProfiling test on RMODs
    [Arguments]    ${RMOD_list}

    FOR  ${RMOD_SN}  IN  @{RMOD_list}
        Continue For Loop If  '${RMOD_SN}' in '${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}'
        Set Test Variable  ${RMOD_SN}
        Perform climateControlProfiling test on single RMOD

    END

Perform climateControlProfiling test on single RMOD

    Step 6: Place initial climateControlProfiling value at end of list if needed
    FOR  ${climateControlProfiling}  IN  @{climateControlProfiling_list}

        Set Test Variable  ${climateControlProfiling}
        Step 7: Preliminary set RMOD climateControlProfiling if not populated in BTS
        Step 8: Set RMOD climateControlProfiling
        Step 9: Save snapshot from BTS and check trace
        Step 10: Check final all BTS state
        Step 11: Check final all BTS alarms
        Step 12: Check final number and state of Cells and RMs

    END

TC preconditions
    ${temp_climateControlProfiling_list}=  Split String  ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}  ,
    ${climateControlProfiling_list}=  Create List
    FOR  ${climateControlProfile}  IN  @{temp_climateControlProfiling_list}
        ${climateControlProfile}=  Strip String  ${climateControlProfile}
        Append To List  ${climateControlProfiling_list}  ${climateControlProfile}
    END
    Set Test Variable  ${climateControlProfiling_list}

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
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

Step ${index}: Get initial climateControlProfiling values on primaryController of each RMOD

    Log  \nStep ${index}: Get initial climateControlProfiling values on primaryController of each RMOD  console=True

    ${initial_climateControlProfiling}=  Create Dictionary
    FOR  ${RMOD_SN}  IN  @{all_RM_sn_list}
        Continue For Loop If  '${RMOD_SN}' in '${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}'
        ${rmod_dict}=  Pop From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}

        ${primaryController_alias}=  Get From Dictionary  ${rmod_dict}  primaryController
        ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${primaryController_alias}
        ${initial_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller
        ...  BTS_SCF_path_file=${BTS_SCF_path_file_info}  RMOD_sn=${RMOD_SN}  alias=${primaryController_alias}

        Set To Dictionary  ${rmod_dict}  initial_climateControlProfiling=${initial_climateControlProfiling}

        Set To Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}=${rmod_dict}
        Set Test Variable  ${alias_and_id_dictionary}
        Log  ${RMOD_SN} on ${primaryController_alias}: ${initial_climateControlProfiling}  console=True
    END

    ${length_of_climateControlProfiling_list}=  Get Length  ${climateControlProfiling_list}
    ${exit_condition}=  Create Long String  ${length_of_climateControlProfiling_list}==${1} and
    ...  '${climateControlProfiling_list[${0}]}' == '${rmod_dict['initial_climateControlProfiling']}'
    Run Keyword If  ${exit_condition}
    ...  Run Keywords
    ...  Log Long String  List of ${climateControlProfiling} contains only 1 value
    ...  which is the same as the value on BTS ${primaryController_alias} for RMOD ${RMOD_SN}  console=True
    ...  AND  Fail  List of ${climateControlProfiling} contains only 1 value which is the same as the value on BTS

Step ${index}: Place initial climateControlProfiling value at end of list if needed

    Log  \nStep ${index}: Place initial climateControlProfiling value at end of list if needed  console=True
    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${rmod_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
    ${primaryController_alias}=  Get From Dictionary  ${rmod_dict}  primaryController
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${primaryController_alias}
    ${initial_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller
    ...  BTS_SCF_path_file=${BTS_SCF_path_file_info}  RMOD_sn=${RMOD_SN}  alias=${primaryController_alias}
    ${initial_climateControlProfiling}=  Set Variable If  '${initial_climateControlProfiling}' == 'NA'
    ...  ${start_climateControlProfiling_value}  ${initial_climateControlProfiling}

    Run Keyword If  '${initial_climateControlProfiling}' not in ${climateControlProfiling_list}
    ...  Run Keywords
    ...  Log  No replacement of initial climateControlProfiling value needed  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${climateControlProfiling_list[${0}]}' == '${initial_climateControlProfiling}'
    ...  Run Keywords
    ...  Remove Values From List  ${climateControlProfiling_list}  ${initial_climateControlProfiling}
    ...  AND  Append To List  ${climateControlProfiling_list}  ${initial_climateControlProfiling}
    ...  AND  Log  \nPlacement of initial climateControlProfiling value at end of list done  console=True
    ...  ELSE  Run Keywords
    ...  Log  No replacement of initial climateControlProfiling value needed  console=True
    ...  AND  Return From Keyword

    Set Test Variable  ${climateControlProfiling_list}

Step ${index}: Preliminary set RMOD climateControlProfiling if not populated in BTS
    [Documentation]
    ...  Set RMOD parameter climateControlProfiling on BTS

    ${rmod_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
    ${primary_controller_alias}=  Get From Dictionary  ${rmod_dict}  primaryController
    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${primaryController_alias}
    ${bts_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller
    ...  BTS_SCF_path_file=${BTS_SCF_path_file_info}  RMOD_sn=${RMOD_SN}  alias=${primaryController_alias}

    Log  \nStep ${index}: Preliminary set RMOD climateControlProfiling if not populated in BTS  console=True
    Log  RMOD : ${RMOD_SN}  console=True
    Log  PrimaryController: ${primary_controller_alias}  console=True

    Run Keyword If  '${bts_climateControlProfiling}' == 'NA'
    ...  Run Keywords
    ...  Set RMOD climateControlProfiling parameter on classical BTS
    ...  RMOD_climateControlProfiling_value=${start_climateControlProfiling_value}  RMOD_sn=${RMOD_SN}  alias=${primary_controller_alias}
    ...  AND  Set Test Variable  ${restore_needed}  ${True}
    ...  ELSE  Log  climateControlProfiling is already set in scf: ${bts_climateControlProfiling}  console=True

Step ${index}: Set RMOD climateControlProfiling
    [Documentation]
    ...  Set RMOD parameter climateControlProfiling on BTS

    ${rmod_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
    ${primary_controller_alias}=  Get From Dictionary  ${rmod_dict}  primaryController

    Log  ==============================================  console=True
    Log  Run TC on: ${RMOD_SN}  console=True
    Log  PrimaryController: ${primary_controller_alias}  console=True
    Log  ==============================================  console=True

    Log  \nStep ${index}: Set RMOD climateControlProfiling  console=True

    Get Current Date UTC info  start_profiling_commissioning
    Set RMOD climateControlProfiling parameter on classical BTS
    ...  RMOD_climateControlProfiling_value=${climateControlProfiling}  RMOD_sn=${RMOD_SN}  alias=${primary_controller_alias}

    Set Test Variable  ${restore_needed}  ${True}

Step ${index}: Detect BTS and Cells of RMOD

    Log  \nStep ${index}: Detect BTS and Cells of RMOD  console=True

    ${alias_and_id_dictionary}=  Create Dictionary
    Set Test Variable  ${alias_and_id_dictionary}

    FOR  ${RMOD_SN}  IN  @{all_RM_sn_list}
        Continue For Loop If  '${RMOD_SN}' in '${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}'
        Detect BTS and Cells of single RMOD  ${RMOD_SN}
    END

Detect BTS and Cells of single RMOD
    [Arguments]    ${RMOD_SN}

    ${aliases}=  Copy List  ${RM_sn_bts-alias_dict}[${RMOD_SN}]
    FOR  ${alias}  IN  @{aliases}
        Run Keyword If  '${RMOD_SN}' in ${${alias}_BTS_all_impacted_RM_sn_list}
        ...  Run Keywords
        ...  Remove Values From List  ${aliases}  ${alias}
        ...  AND  Exit For Loop
    END
    ${alias_secondary}=  Set Variable If  ${aliases}  ${aliases[${0}]}  ${None}

    Log  \n${RMOD_SN}:  console=True
    Log  primaryController: ${alias}  console=True
    Run Keyword If  '${alias_secondary}'
    ...  Log  secondaryController: ${alias_secondary}  console=True
    ...  ELSE  Log  RMOD is dedicated to ${alias}  console=True

    Get RMOD Id SN mapping  ${alias}
    ${primarycontroller_RMOD_id}=  Get From Dictionary  ${rmod_SN_rmod_Id}  ${RMOD_SN}

    Run Keyword If  '${alias_secondary}'!='${None}'
    ...  Get RMOD Id SN mapping  ${alias_secondary}
    ${secondarycontroller_RMOD_id}=  Run Keyword If  '${alias_secondary}'!='${None}'
    ...  Get From Dictionary  ${rmod_SN_rmod_Id}  ${RMOD_SN}
    ...  ELSE  Set Variable  ${None}

    ${configured}=  Set Variable If  '${alias_secondary}'!='${None}'  shared  dedicated

    ${result}=  Create Dictionary  primaryController=${alias}  primaryControllerRMODid=${primarycontroller_RMOD_id}
    ...  secondaryController=${alias_secondary}  secondaryControllerRMODid=${secondarycontroller_RMOD_id}
    ...  configured=${configured}

    Set To Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}=${result}
    Set Test Variable  ${alias_and_id_dictionary}

Step ${index}: Save snapshot from BTS and check trace

    Log  \nStep ${index}: Save snapshot from BTS and check trace  console=True
    Sleep  ${delay_to_snapshot_save}  Sleeping ${delay_to_snapshot_save}s to insure action is contained in files from snapshot

    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${rmod_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
    ${primary_controller_alias}=  Get From Dictionary  ${RMOD_dict}  primaryController

    ${path}=  Set Variable  ${Test Results Dir}/CB010874_Snapshot/
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H:%M:%S
    Log  Saving snapshot from BTS ${primary_controller_alias}:  console=True
    ${folder_path}  ${snapshot_filename}=  Snapshot collection on demand SOAM  ${primaryController_alias}  ${path}/${timestamp}
    ${snapshot_path}=  Join Path  ${folder_path}  ${snapshot_filename}

    Log  ${snapshot_path}  console=True
    Log  \nAnalyzing snapshot:  console=True

    ${BTS_value_TRACE_value_dict}=  Create Dictionary
    ...  Linear=LINEAR  Low Noise=LOW_NOISE  Optimized Cooling=OPTIMISED_COOLING  NA=OPTIMISED_COOLING

    ${trace_end_value}=  Get From Dictionary  ${BTS_value_TRACE_value_dict}  ${climateControlProfiling}
    ${bts_start_value}=  Get Variable Value  ${bts_start_value_${RMOD_SN}}  ${rmod_dict['initial_climateControlProfiling']}
    ${trace_start_value}=  Get From Dictionary  ${BTS_value_TRACE_value_dict}  ${bts_start_value}
    ${start_time_soap}=  Set Variable  ${date_timestamp_start_profiling_commissioning_UTC}
    ${occurence_list}=
    ...  soap_trace_analysis.Check Climate Profiling Soap Log  snapshot_path=${snapshot_path}
    ...  new_value=${trace_end_value}  prev_value=${trace_start_value}
    ...  rmod_sn=${RMOD_SN}  start_time=${start_time_soap}  file_name_regex=${file_name_regex}
    Run Keyword If  ${occurence_list}  Run Keywords
    ...  Log  Found following timestamp(s) in SOAP trace indicating switch of FAN climate control profiling:  console=True
    ...  AND  Log  ${trace_start_value} -> ${trace_end_value}: ${occurence_list}  console=True
    ...  AND  OperatingSystem.Remove Directory  ${folder_path}  recursive=${True}
    ...  ELSE  Run Keywords
    ...  Log  Not found any timetamp(s) indicating switch of FAN climateControlProfiling   console=True
    ...  AND  FAIL  Not found any timetamp(s) indicating switch of FAN climateControlProfiling

    Set Test Variable  ${bts_start_value_${RMOD_SN}}  ${climateControlProfiling}

Step ${index}: Check RMOD and Cell states and BTS alarms after reset RM

    Log  \nStep ${index}: Check RMOD and Cell states and BTS alarms after reset RM  console=True

    ${RMOD_SN}=  Get Variable Value  ${RMOD_SN}
    ${RMOD_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
    ${primary_controller_alias}=  Get From Dictionary  ${RMOD_dict}  primaryController
    ${RMOD_ID_primary}=  Get From Dictionary  ${RMOD_dict}  primaryControllerRMODid
    ${secondary_controller_alias}=  Get From Dictionary  ${RMOD_dict}  secondaryController
    ${RMOD_ID_secondary}=  Get From Dictionary  ${RMOD_dict}  secondaryControllerRMODid

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${remained_MAX_WAIT_TIME}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  \nStep ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM serial number list

    Run Keyword If  'ALL' in '${RM_SERIAL_NUMBER_LIST}'
    ...  Return From Keyword

    ${RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RM_SERIAL_NUMBER_LIST}=  Split String  ${RM_SERIAL_NUMBER_LIST_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List
    ${RM_SN_no_serial_list}=  Create List
    FOR  ${item}  IN  @{RM_SERIAL_NUMBER_LIST}
        ${RM_sn_check}=  Set Variable If  '${item}' not in ${all_RM_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${item}' not in ${all_RM_sn_list}  Append To List  ${RM_sn_invalide_list}  ${item}
    END
    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RM_SERIAL_NUMBER_LIST} from configured RM: ${all_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
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

Step ${index}: Restore initial climateControlProfiling value on primaryController of each RMOD

    Log  \nStep ${index}: Restore initial climateControlProfiling value on primaryController of each RMOD  console=True

    ${restore_needed}=  Get Variable Value  ${restore_needed}  ${False}

    Run Keyword If  not ${restore_needed}  Run Keywords
    ...  Log  No commissioning has been done by the TC, no restore needed  console=True
    ...  AND  Return From Keyword

    FOR  ${RMOD_SN}  IN  @{all_RM_sn_list}
        Continue For Loop If  '${RMOD_SN}' in '${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}'
        ${rmod_dict}=  Get From Dictionary  ${alias_and_id_dictionary}  ${RMOD_SN}
        ${primary_controller_alias}=  Get From Dictionary  ${rmod_dict}  primaryController
        ${climateControlProfiling}=  Get From Dictionary  ${rmod_dict}  initial_climateControlProfiling
        ${status}=  Run Keyword and Return Status  Run Keyword If  '${climateControlProfiling}'!='NA'
        ...  Set RMOD climateControlProfiling parameter on classical BTS
        ...  RMOD_climateControlProfiling_value=${climateControlProfiling}  RMOD_sn=${RMOD_SN}  alias=${primary_controller_alias}
        ...  ELSE
        ...  Set RMOD climateControlProfiling parameter on classical BTS
        ...  RMOD_climateControlProfiling_value=NA  RMOD_sn=${RMOD_SN}  alias=${primary_controller_alias}
        Run Keyword If  '${climateControlProfiling}'!='NA'
        ...  Log  Set For ${RMOD_SN} on ${primary_controller_alias}: value ${climateControlProfiling} - ${status}  console=True
        ...  ELSE  Log  Remove For ${RMOD_SN} on ${primary_controller_alias}: parameter climateControlProfiling - ${status}  console=True

        Run Keyword If  not ${status}
        ...  Run Keyword And Continue On Failure
        ...  Fail  Set For ${RMOD_SN} on ${primary_controller_alias}: value ${climateControlProfiling} - ${status}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
