*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
Variables    tc_variables/cbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                             3     # Number of RMOD climate control profiling setting operations, default value 3
${RMOD_CLIMATE_CONTROL_PROFILING_LIST}        ALL   # RMOD climate control profiling list. Possible values (by default ALL):
                                                    # - ALL: action will be performed on selected RMOD list with all climate control profiling
                                                    # values: Optimized Cooling, Linear, Low Noise
                                                    # - list of climate control profiling values separated by comma which will be applied on
                                                    # selected RMOD list.
${RMOD_SERIAL_NUMBER_LIST}                    ALL   # RMOD serial number list on which climate control profiling setting operations will be performed.
                                                    # Possible values (by default ALL):
                                                    # - ALL: action will be performed on all RMOD
                                                    # - list of selected RMOD serial number separated by comma.
${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}        # RMOD serial number list exempted from CB010874 feature
${CB010874_SNAPSHOT_REMOVE}                   True  # Allow snapshot remove action for collected snapshots related to passed check CB010874 feature
                                                    # transitions
${file_name_regex}                            .*SOAP.*[.]xml[.]gz    # Expression describing soap trace files from snapshot,
                                                                     # which are parsed to check the profile modification
${delay_to_snapshot_save}                     30         # Delay in seconds between temperature control profile commissioning
                                                         # and snapshot saving


*** Keywords ***
TC__CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29163
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for RMOD climate control profiling setting operation, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), RMOD climateControlProfiling info
    ...  - perform RMOD climate control profiling setting operations on BTS primary controller
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: RMOD climate control profiling setting operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29163 -
    ...  [5G][CB010874]RFS_CBTS_SBTS_CB010874_Fan_temperature_control_profiles_for_5G_RUs
    ...  - 11.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29539 -
    ...  CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874 fails when climateControlProfiling not populated in CBTS / SBTS
    ...  - 23.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30016 -
    ...  CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874 time extension - through TAT-29890

    Set Tags    CA-STATE    OWNER-radu.hirsovescu@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS25R3,SBTS25R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform RMOD climate control profiling setting operations on BTS primary controller
        Step 5: Check final all BTS states
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_all_alias_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    Run Keyword If  '${RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check RMOD serial number list

    Log  =================================================================================  console=True
    Log  RMOD serial number list selected for climate control profiling setting operation: ${RMOD_all_sn_list}  console=True
    Log  =================================================================================  console=True

    ${climateControlProfiling_list}=  Check RMOD climate control profiling list
    Set Test Variable  ${climateControlProfiling_list}

    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}=  Check CB010874 exempted RMOD list
    Set Test Variable  ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

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

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    ${RMOD_sn_BTS_primary_controller_dict}=  Get all RMOD BTS primary controller info
    Set Test Variable  ${RMOD_sn_BTS_primary_controller_dict}

    ${RMOD_sn_climateControlProfiling_dict}=  Get all RMOD climate control profiling setting on BTS primary controller
    Set Test Variable  ${RMOD_sn_climateControlProfiling_dict_scf_initial}  ${RMOD_sn_climateControlProfiling_dict}

    Check and set all RMOD CB010874 feature on BTS primary controller

    ${RMOD_sn_climateControlProfiling_dict}=  Get all RMOD climate control profiling setting on BTS primary controller
    Set Test Variable  ${RMOD_sn_climateControlProfiling_dict_initial}  ${RMOD_sn_climateControlProfiling_dict}

    ${climateControlProfiling_scf_list}=  Get Dictionary Values  ${RMOD_sn_climateControlProfiling_dict_initial}
    ${climateControlProfiling_scf_list}=  Remove Duplicates  ${climateControlProfiling_scf_list}
    ${climateControlProfiling_scf_count}=  Get Length  ${climateControlProfiling_scf_list}
    ${climateControlProfiling_count}=  Get Length  ${climateControlProfiling_list}
    Run Keyword If  ${climateControlProfiling_count} == 1 and ${climateControlProfiling_scf_count} == 1
    ...  Run Keyword If  '${climateControlProfiling_scf_list[0]}' == '${climateControlProfiling_list[0]}'  Run Keywords
    ...  Log Long String  Selected value for test argument \${RMOD_CLIMATE_CONTROL_PROFILING_LIST}: ${climateControlProfiling_list} is already set
    ...  on selected RMOD: ${RMOD_all_sn_list}. Please select values for test argument \${RMOD_CLIMATE_CONTROL_PROFILING_LIST} from:
    ...  ${climateControlProfiling_full_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${CB010874_profile_dict}=  Create Dictionary  Linear=LINEAR  Low Noise=LOW_NOISE  Optimized Cooling=OPTIMISED_COOLING
    Set Test Variable  ${CB010874_profile_dict}

Step ${index}: Perform RMOD climate control profiling setting operations on BTS primary controller
    Log  Step ${index}: Perform RMOD climate control profiling setting operations on BTS primary controller  console=True

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${BTS_primary_controller}=  Get From Dictionary  ${RMOD_sn_BTS_primary_controller_dict}  ${RMOD_sn}
        Set RMOD climateControlProfiling parameter on BTS primary controller  ${RMOD_sn}  ${BTS_primary_controller}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RMOD serial number list
    ${RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SERIAL_NUMBER_LIST}=  Split String  ${RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalid_list}=  Create List

    FOR  ${item}  IN  @{RMOD_SERIAL_NUMBER_LIST}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${RMOD_all_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${RMOD_all_sn_list}  Append To List  ${RMOD_sn_invalid_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RMOD serial number values are not valid: ${RMOD_sn_invalid_list}. Please select values for test
    ...  argument \${RMOD_SERIAL_NUMBER_LIST} from configured RMOD: ${RMOD_all_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${RMOD_all_sn_list}  ${RMOD_SERIAL_NUMBER_LIST}
    Sort List  ${RMOD_all_sn_list}

Check RMOD climate control profiling list
    ${climateControlProfiling_full_list}=  Create List  Optimized Cooling  Linear  Low Noise
    Set Test Variable  ${climateControlProfiling_full_list}
    ${climateControlProfiling_list}=  Create List  Optimized Cooling  Linear  Low Noise
    Return From Keyword If  '${RMOD_CLIMATE_CONTROL_PROFILING_LIST}' == 'ALL'  ${climateControlProfiling_list}


    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST_split}=  Split String  ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}  ,
    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST_stripped}=  Create List
    FOR  ${item}  IN  @{RMOD_CLIMATE_CONTROL_PROFILING_LIST_split}

        ${item_stripped}=  Strip String  ${SPACE}${item}${SPACE}
        Append To List  ${RMOD_CLIMATE_CONTROL_PROFILING_LIST_stripped}  ${item_stripped}

    END
    ${climateControlProfiling_check}=  Set Variable  True
    ${climateControlProfiling_invalid_list}=  Create List

    FOR  ${item}  IN  @{RMOD_CLIMATE_CONTROL_PROFILING_LIST_stripped}

        ${climateControlProfiling_check}=  Set Variable If  '${item}' not in ${climateControlProfiling_full_list}  False
        ...  ${climateControlProfiling_check}
        Run Keyword If  '${item}' not in ${climateControlProfiling_full_list}  Append To List  ${climateControlProfiling_invalid_list}  ${item}

    END

    Run Keyword If  '${climateControlProfiling_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected climateControlProfiling values are not valid: ${climateControlProfiling_invalid_list}. Please select
    ...  values for test argument \${RMOD_CLIMATE_CONTROL_PROFILING_LIST} from: ${climateControlProfiling_full_list} or let default value: ALL
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${climateControlProfiling_list}  ${RMOD_CLIMATE_CONTROL_PROFILING_LIST_stripped}

    [Return]  ${climateControlProfiling_list}

Check CB010874 exempted RMOD list
    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_isEmpty}=  Set Variable If  '${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}' == ''  ${TRUE}  ${FALSE}

    Return From Keyword If  ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_isEmpty}  @{EMPTY}

    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}=  Split String  ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_strip}  ,

    [Return]  ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

Get all RMOD BTS primary controller info

    ${RMOD_sn_BTS_primary_controller_dict}=  Create Dictionary

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${BTS_primary_controller}=  Get RMOD BTS primary controller info  ${RMOD_sn}

        Set To Dictionary  ${RMOD_sn_BTS_primary_controller_dict}  ${RMOD_sn}  ${BTS_primary_controller}

    END

    [Return]  ${RMOD_sn_BTS_primary_controller_dict}

Get RMOD BTS primary controller info
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_primary_controller}=  Set Variable If  '${RMOD_sn}' in ${BTS_primary_controller_RMOD_sn_list}  ${alias}

        Exit For Loop If  '${RMOD_sn}' in ${BTS_primary_controller_RMOD_sn_list}

    END

    [Return]  ${BTS_primary_controller}

Get all RMOD climate control profiling setting on BTS primary controller

    ${RMOD_sn_climateControlProfiling_dict}=  Create Dictionary

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${BTS_primary_controller}=  Get From Dictionary  ${RMOD_sn_BTS_primary_controller_dict}  ${RMOD_sn}

        ${BTS_SCF_path_file}=  Run Keyword If  '${BTS_primary_controller}' in ${alias_list}
        ...  Admin Collect scf.xml with timestamp TAF  alias=${BTS_primary_controller}
        ...  ELSE  VDU Get Current Plan File  vdu_connection=${BTS_primary_controller}

        ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller
        ...  ${RMOD_sn}  ${BTS_primary_controller}  ${BTS_SCF_path_file}

        Set To Dictionary  ${RMOD_sn_climateControlProfiling_dict}  ${RMOD_sn}  ${RMOD_climateControlProfiling}

    END

    [Return]  ${RMOD_sn_climateControlProfiling_dict}

Check and set all RMOD CB010874 feature on BTS primary controller

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${RMOD_climateControlProfiling_scf_initial}=  Get From Dictionary  ${RMOD_sn_climateControlProfiling_dict_scf_initial}  ${RMOD_sn}
        Continue For Loop If  '${RMOD_climateControlProfiling_scf_initial}' != 'NA'

        ${BTS_primary_controller}=  Get From Dictionary  ${RMOD_sn_BTS_primary_controller_dict}  ${RMOD_sn}

        Run Keyword If  '${BTS_primary_controller}' in ${alias_list}
        ...  Set RMOD climateControlProfiling parameter on classical BTS  Optimized Cooling  ${RMOD_sn}  ${BTS_primary_controller}
        ...  ELSE
        ...  Set RMOD climateControlProfiling parameter on cloud BTS  Optimized Cooling  ${RMOD_sn}  ${BTS_primary_controller}

    END

Set RMOD climateControlProfiling parameter on BTS primary controller
    [Arguments]  ${RMOD_sn}  ${alias}

    ${RMOD_climateControlProfiling_initial}=  Get From Dictionary  ${RMOD_sn_climateControlProfiling_dict_initial}  ${RMOD_sn}

    Get Current Time  start

    FOR  ${RMOD_climateControlProfiling_new}  IN  @{climateControlProfiling_list}

        Continue For Loop If  '${RMOD_climateControlProfiling_new}' == '${RMOD_climateControlProfiling_initial}'

        ${RMOD_climateControlProfiling_current}=  Run Keyword If  '${alias}' in ${alias_list}
        ...  Get RMOD climateControlProfiling parameter on classical BTS  ${RMOD_sn}  ${alias}
        ...  ELSE
        ...  Get RMOD climateControlProfiling parameter on cloud BTS  ${RMOD_sn}  ${alias}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Set RMOD climateControlProfiling parameter on classical BTS  ${RMOD_climateControlProfiling_new}  ${RMOD_sn}  ${alias}
        ...  ELSE
        ...  Set RMOD climateControlProfiling parameter on cloud BTS  ${RMOD_climateControlProfiling_new}  ${RMOD_sn}  ${alias}

        Check all BTS states and alarms

        Check CB010874 feature based on BTS primary controller snapshot info  ${RMOD_sn}  ${alias}  ${RMOD_climateControlProfiling_new}
        ...  ${RMOD_climateControlProfiling_current}

    END

    Return From Keyword If  '${RMOD_climateControlProfiling_initial}' not in ${climateControlProfiling_list}

    ${RMOD_climateControlProfiling_current}=  Run Keyword If  '${alias}' in ${alias_list}
    ...  Get RMOD climateControlProfiling parameter on classical BTS  ${RMOD_sn}  ${alias}
    ...  ELSE
    ...  Get RMOD climateControlProfiling parameter on cloud BTS  ${RMOD_sn}  ${alias}

    Run Keyword If  '${alias}' in ${alias_list}
    ...  Set RMOD climateControlProfiling parameter on classical BTS  ${RMOD_climateControlProfiling_initial}  ${RMOD_sn}  ${alias}
    ...  ELSE
    ...  Set RMOD climateControlProfiling parameter on cloud BTS  ${RMOD_climateControlProfiling_initial}  ${RMOD_sn}  ${alias}

    Check all BTS states and alarms

    Check CB010874 feature based on BTS primary controller snapshot info  ${RMOD_sn}  ${alias}  ${RMOD_climateControlProfiling_initial}
    ...  ${RMOD_climateControlProfiling_current}

Get RMOD climateControlProfiling parameter on classical BTS
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${alias}
    ...  ${BTS_SCF_path_file_info}

    [Return]  ${RMOD_climateControlProfiling}

Get RMOD climateControlProfiling parameter on cloud BTS
    [Arguments]  ${RMOD_sn}  ${vdu_alias}

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    ${RMOD_climateControlProfiling}=  Get RMOD climate control profiling setting on BTS primary controller  ${RMOD_sn}  ${vdu_alias}
    ...  ${VDU_SCF_path_file_info}

    [Return]  ${RMOD_climateControlProfiling}

Check CB010874 feature based on BTS primary controller snapshot info
    [Arguments]  ${RMOD_sn}  ${alias}  ${new_value}  ${previous_value}

    ${SOAP_new_value}=  Get From Dictionary  ${CB010874_profile_dict}  ${new_value}
    ${SOAP_previous_value}=  Get From Dictionary  ${CB010874_profile_dict}  ${previous_value}

    Sleep  ${delay_to_snapshot_save}  Sleeping ${delay_to_snapshot_save}s to insure action is contained in files from snapshot

    Run Keyword If  '${alias}' in ${alias_list}
    ...  Check CB010874 feature based on classical BTS snapshot info  ${RMOD_sn}  ${alias}  ${SOAP_new_value}  ${SOAP_previous_value}
    ...  ELSE
    ...  Check CB010874 feature based on cloud BTS snapshot info  ${RMOD_sn}  ${alias}  ${SOAP_new_value}  ${SOAP_previous_value}

Check CB010874 feature based on classical BTS snapshot info
    [Arguments]  ${RMOD_sn}  ${alias}  ${SOAP_new_value}  ${SOAP_previous_value}

    Log  ***** Check CB010874 feature based on ${alias} BTS snapshot info *****  console=True

    ${folder_path}=  Set Variable  ${Test Results Dir}/CB010874_Snapshot/${alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${status}  Create Directory  ${folder_path}
    ${timestamp}=  Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_filename}=  Set Variable  Snapshot_${timestamp}.zip

    coam.Collect Snapshot  alias=${alias}  target_file_name=${folder_path}/${snapshot_filename}  timeout=1260
    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${folder_path}/${snapshot_filename}
    Run Keyword If  ${status}
    ...  Log  ${alias} BTS snapshot file ${snapshot_filename} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} BTS snapshot file ${snapshot_filename} not available at ${folder_path}  level=ERROR
    ...  AND  Fail  ${alias} BTS snapshot file ${snapshot_filename} not available at ${folder_path}

    Get Current Time  end

    ${SOAP_timestamp_info}=  soap_trace_analysis.Check Climate Profiling Soap Log  snapshot_path=${folder_path}/${snapshot_filename}
    ...  new_value=${SOAP_new_value}  prev_value=${SOAP_previous_value}  rmod_sn=${RMOD_sn}  start_time=${time_start}
    ...  file_name_regex=${file_name_regex}

    Run Keyword If  ${SOAP_timestamp_info}  Run Keywords
    ...  Log  Climate control profiling parameter change ${SOAP_previous_value} -> ${SOAP_new_value} timestamp: ${SOAP_timestamp_info}  console=True
    ...  AND  Log  ${alias} check feature CB010874 info passed  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  No info related to Climate control profiling parameter change ${SOAP_previous_value} -> ${SOAP_new_value} in selected time
    ...  interval: start_time=${time_start} - end_time=${time_end}  level=ERROR
    ...  AND  FAIL  No info related to TemperatureControl change ${SOAP_previous_value} -> ${SOAP_new_value} in selected time interval

    Run Keyword If  '${CB010874_SNAPSHOT_REMOVE}' == 'True'
    ...  OperatingSystem.Remove File  ${folder_path}/${snapshot_filename}

Check CB010874 feature based on cloud BTS snapshot info
    [Arguments]  ${RMOD_sn}  ${vdu_alias}  ${SOAP_new_value}  ${SOAP_previous_value}

    Log  ***** Check CB010874 feature based on ${vdu_alias} snapshot info *****  console=True

    ${folder_path}=  Set Variable  ${Test Results Dir}/CB010874_Snapshot/${vdu_alias}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${status}  Create Directory  ${folder_path}

    ${vdu_snapshot_status}=  vdu.Check Snapshot Status  vdu_connection=${vdu_alias}
    Run Keyword If  '${vdu_snapshot_status}' != 'idle'  Wait Until Keyword Succeeds  3min  5s
    ...  Cancel VDU collect snapshot  vdu_alias=${vdu_alias}

    ${vdu_snapshot_operation_id}=  vdu.Trigger Local Snapshot  vdu_connection=${vdu_alias}
    Sleep  5s
    ${vdu_snapshot_status}=  vdu.Check Snapshot Status  vdu_connection=${vdu_alias}
    Should Be Equal As Strings  ${vdu_snapshot_status}  local-ongoing

    ${vdu_snapshot_info}=  vdu.Check Local Snapshot Status And Save It  directory=${folder_path}
    ...  operation_id=${vdu_snapshot_operation_id}  compressed_or_not=True  vdu_connection=${vdu_alias}

    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${vdu_snapshot_info}
    Run Keyword If  ${status}
    ...  Log  ${vdu_alias} snapshot file available at ${vdu_snapshot_info}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${vdu_alias} snapshot file not available at ${folder_path}  level=ERROR
    ...  AND  Fail  ${vdu_alias} snapshot file not available at ${folder_path}

    Get Current Time  end

    ${SOAP_timestamp_info}=  soap_trace_analysis.Check Climate Profiling Soap Log  snapshot_path=${vdu_snapshot_info}
    ...  new_value=${SOAP_new_value}  prev_value=${SOAP_previous_value}  rmod_sn=${RMOD_sn}  start_time=${time_start}
    ...  file_name_regex=${file_name_regex}

    Run Keyword If  ${SOAP_timestamp_info}  Run Keywords
    ...  Log  Climate control profiling parameter change ${SOAP_previous_value} -> ${SOAP_new_value} timestamp: ${SOAP_timestamp_info}  console=True
    ...  AND  Log  ${vdu_alias} check feature CB010874 info passed  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  No info related to Climate control profiling parameter change ${SOAP_previous_value} -> ${SOAP_new_value} in selected time
    ...  interval: start_time=${time_start} - end_time=${time_end}  level=ERROR
    ...  AND  FAIL  No info related to TemperatureControl change ${SOAP_previous_value} -> ${SOAP_new_value} in selected time interval

    Run Keyword If  '${CB010874_SNAPSHOT_REMOVE}' == 'True'
    ...  OperatingSystem.Remove File  ${vdu_snapshot_info}

Check all BTS states and alarms

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS states and alarms  ${alias}
        ...  ELSE
        ...  Check cloud BTS states and alarms  ${alias}

    END

Check classical BTS states and alarms
    [Arguments]  ${alias}

    Log  Check ${alias} BTS status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  30  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=30  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    Check cells availability status online  ${alias}  30
    Log  ${alias} BTS cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    Wait Until Keyword Succeeds  30s  5s  VDU Check VDU Expected Status  operational_state=${CBTS_OnAir_}  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${CBTS_VDU_state_onair}  console=True

    Log  Check ${vdu_alias} RMODs status:  console=True
    Wait Until Keyword Succeeds  30s  5s  Check cloud BTS VDU all RMODs expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} RMODs status:\n - ${CBTS_VDU_RMOD_state_enabled}  console=True

    Log  Check ${vdu_alias} cells status:  console=True
    Wait Until Keyword Succeeds  30s  5s  Check cloud BTS VDU all cells expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status:\n - ${CBTS_VDU_CELL_state_enabled}  console=True

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Recover initial RMOD climate control profiling setting on BTS primary controller

    Log  Recover initial RMOD climate control profiling setting on BTS primary controller  console=True

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        ${RMOD_climateControlProfiling_scf_initial}=  Get From Dictionary  ${RMOD_sn_climateControlProfiling_dict_scf_initial}  ${RMOD_sn}
        ${BTS_primary_controller}=  Get From Dictionary  ${RMOD_sn_BTS_primary_controller_dict}  ${RMOD_sn}

        Run Keyword If  '${BTS_primary_controller}' in ${alias_list}
        ...  Set RMOD climateControlProfiling parameter on classical BTS  ${RMOD_climateControlProfiling_scf_initial}  ${RMOD_sn}
        ...  ${BTS_primary_controller}
        ...  ELSE
        ...  Set RMOD climateControlProfiling parameter on cloud BTS  ${RMOD_climateControlProfiling_scf_initial}  ${RMOD_sn}
        ...  ${BTS_primary_controller}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial RMOD climate control profiling setting on BTS primary controller

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
