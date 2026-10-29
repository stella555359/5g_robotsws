*** Settings ***
Documentation    TC__SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
Variables    tc_variables/sbts_sbts__cm__commissioning_of_cacv_parameters_cb013031_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Library    json

*** Variables ***
${REPEAT_COUNTER}     3    # Number of cycles to perform commissioning of CACV parameters on both BTS, default value 3
${BTS_LIST}           ALL  # BTS list on which commissioning operation will be performed. Possible values (by default ALL):
                           # - ALL: action will be performed on all BTS (commission each BTS until last BTS from TL)
                           # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS3)
${BTS_MAX_WAIT_TIME}  900  # Max time (seconds) to wait for BTS to reach OnAir state
${BTS_YAML_PARAMETERS_PATH}  # Relative path to YAML file with CACV parameters for BTS; MANDATORY parameter
                             # Path is relative to: test_line_specific/Timisoara/
                             # Example: RFS_43164_MTNRL49v1/cacv_parameters.yaml

*** Keywords ***
TC__SBTS_SBTS__CM__Commissioning_of_CACV_parameters_CB013031
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30498
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case to validate Commissioning of CACV parameters (CB013031 feature) on both BTS.
    ...  Verifies that auto-calculated parameters can be safely removed without causing BTS or RMOD resets. - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...
    ...  Prerequisites:
    ...  - BTS_YAML_PARAMETERS_PATH must be set to point to CACV parameters YAML config file
    ...  - YAML file must be located in: test_line_specific/Timisoara/TL_name/cacv_parameters.yaml
    ...
    ...  The main steps performed (per BTS) for the test are:
    ...  - Step 1-2: Check initial state and alarms for both BTS
    ...  - For each cycle:
    ...    - Step 3: Save and validate initial BTS SCF (default and autoconfigured exports)
    ...    - Step 4: Check NIDD definition of CACV parameters (verify isAutoconfigurable=true)
    ...    - Step 5: Perform BTS commissioning using initial autoconfigured SCF
    ...    - Step 6: Check and activate feature CB013031 on BTS (actCondAutoConfValCalc parameter)
    ...    - Step 7: Check CACV parameters presence in current SCF
    ...    - Step 8: Remove CACV parameters from current SCF via delta commissioning
    ...    - Step 9: Save and validate final BTS SCF (both export types)
    ...    - Step 10: Check removed CACV parameters in final SCF:
    ...      - NOT present in default SCF (configurationAndPlannedObjects, without autoconfigured parameters)
    ...      - PRESENT in autoconfigured SCF (with autoconfigured parameters)
    ...    - Step 11: Check RMOD reset behavior using Uptime info (verify no reset occurred)
    ...    - Step 12: Check BTS reset behavior using IMS logs (verify no reset occurred)
    ...    - Step 13: Perform BTS commissioning with initial SCF (restore original state)
    ...    - Step 14: Check final BTS state
    ...    - Step 15: Check final BTS alarms
    ...    - Step 16: Check final number and state of Cells and RMs
    ...
    ...  Pass Criteria:
    ...  - Feature CB013031 can be enabled/disabled successfully
    ...  - CACV parameters are properly autoconfigured when feature is enabled
    ...  - Delta commissioning removes parameters as expected
    ...  - Parameters appear/disappear correctly in different SCF export types
    ...  - No BTS or RMOD resets occur during parameter removal
    ...  - BTS recovers to initial state successfully
    ...  - All states and alarms are as expected throughout the test
    ...
    ...  ******************
    ...  History of changes
    ...  *******************
    ...  - 11.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30498 - New Test Case
    ...

    Set Tags    CA-STATE    OWNER-florina.stefan@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Set Test Variable  ${CYCLE}  ${INDEX}
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Perform commissioning of CACV parameters on both BTS
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list
    Log  ============================================================  console=True
    Log  BTS label list selected for commissioning operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for commissioning operation: ${BTS_alias_list}  console=True
    Log  ============================================================  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}

    Load and Validate CACV Parameters YAML Config file

Check BTS list
    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND
    ...  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}


Load and Validate CACV Parameters YAML Config file
    [Documentation]
    ...  Loads and validates CACV parameter definitions from YAML configuration file.

    ${yaml_path}=  OperatingSystem.Normalize Path  ${CURDIR}/../test_line_specific/Timisoara/${BTS_YAML_PARAMETERS_PATH}

    Log  Loading YAML config from: ${yaml_path}  console=True
    Validate YAML File Exists  ${yaml_path}

    ${loaded_yaml_file}=  Load YAML Config With Validation  ${yaml_path}
    Set Test Variable  ${cacv_parameters_yaml_file}  ${loaded_yaml_file}
    Log  Successfully loaded CACV parameters YAML configuration  console=True

    Validate YAML BTS Coverage  yaml_path=${yaml_path}

Validate YAML File Exists
    [Documentation]
    ...  Validates that YAML file exists at specified path.

    [Arguments]  ${yaml_path}

    ${file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${yaml_path}

    Run Keyword If  not ${file_exists}  Run Keywords
    ...  Log  YAML config file not found: ${yaml_path}  level=ERROR
    ...  AND  Log  Please check BTS_YAML_PARAMETERS_PATH variable. Expected format: TL_name/cacv_parameters.yaml  level=ERROR
    ...  AND  Log  Example: RFS_43164_MTNRL49v1/cacv_parameters.yaml  level=ERROR
    ...  AND  Fail  YAML config file not found: ${yaml_path}

Load YAML Config With Validation
    [Documentation]
    ...  Loads YAML configuration file with error handling.

    [Arguments]  ${yaml_path}

    ${load_status}  ${loaded_yaml_file}=  Run Keyword And Ignore Error  Load yaml config  ${yaml_path}

    Run Keyword If  '${load_status}' == 'FAIL'  Run Keywords
    ...  Log  Failed to parse YAML config file: ${yaml_path}  level=ERROR
    ...  AND  Log  File exists but content is invalid. Please check YAML syntax and structure.  level=ERROR
    ...  AND  Fail  Failed to load YAML config file with CACV parameters from: ${yaml_path}

    [Return]  ${loaded_yaml_file}

Validate YAML BTS Coverage
    [Arguments]  ${yaml_path}

    ${not_found_elements}=  Create List
    ${BTS_check}=  Set Variable  True
    ${yaml_keys}=  Get Dictionary Keys  ${cacv_parameters_yaml_file}  False

    FOR  ${item}  IN  @{BTS_label_list}

        ${BTS_check}=  Set Variable If  '${item}' not in ${yaml_keys}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${yaml_keys}
        ...  Append To List  ${not_found_elements}  ${item}

    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log  Following selected BTS: ${not_found_elements} are not found in YAML config file, please check content of file: ${yaml_path}  level=ERROR
    ...  AND
    ...  FAIL  Following selected BTS: ${not_found_elements} are not found in YAML config file, please check content of file: ${yaml_path}

Step ${index}: Check ${when} both BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS state  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} both BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Perform commissioning of CACV parameters on both BTS
    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${alias}
        Set Test Variable  ${BTS_label}
        Step 3: Save and validate initial BTS SCF
        Step 4: Check NIDD definition of CACV parameters on BTS
        Step 5: Perform BTS commissioning using the initial autoconfigured SCF
        Step 6: Check and activate feature CB013031 on BTS
        Step 7: Check CACV parameters presence in current SCF
        Step 8: Remove CACV parameters from current SCF
        Step 9: Save and validate final BTS SCF
        Step 10: Check that CACV parameters are removed in final SCF
        Step 11: Check RMOD reset behavior based on Uptime info after CACV parameters removal
        Step 12: Check BTS reset behavior based on IMS info after CACV parameters removal
        Step 13: Perform BTS commissioning with initial default SCF
        Step 14: Check final both BTS state
        Step 15: Check final both BTS alarms
        Step 16: Check final number and state of Cells and RMs

    END

Step ${index}: Save and validate ${when} BTS SCF
    [Documentation]
    ...  Saves BTS SCF in two export formats and validates specified SCF.

    Log  Step ${index}: Save and validate ${when} BTS SCF  console=True

    Save BTS SCF  when=${when}

    ${scf_type}=  Run Keyword If  '${when}' == 'initial'
    ...  Set Variable  default
    ...  ELSE
    ...  Set Variable  autoconfigured

    Validate BTS SCF  when=${when}  scf_type=${scf_type}

Step ${index}: Check NIDD definition of CACV parameters on BTS
    [Documentation]  Checks NIDD definition of CACV parameters on BTS

    Log  Step ${index}: Check NIDD definition of CACV parameters on BTS  console=True

    ${json_file_path}=  Set Variable  ${BTS Files}/${alias}/export_nidd_run_${CYCLE}.json
    ${result}=  coam.Export NIDD  json_file=${json_file_path}  connection=${alias}

    OperatingSystem.File Should Exist  ${json_file_path}
    ${file_content}=  OperatingSystem.Get file  ${json_file_path}
    ${dict_result}=  json.loads  ${file_content}
    Set Test Variable  ${${alias}_dict_result}  ${dict_result}

    Check NIDD parameters

Step ${index}: Perform BTS commissioning using the initial autoconfigured SCF
    [Documentation]
    ...  Performs BTS commissioning using the initial autoconfigured SCF and validates the result.

    Set Test Variable  ${${alias}_recover_initial_scf_needed}  ${TRUE}

    Log  Step ${index}: Perform BTS commissioning using the initial autoconfigured SCF  console=True

    Log  Commissioning ${BTS_label} with: ${${alias}_initial_autoconfigured_scf_path}  console=True
    Perform BTS Commissioning  alias=${alias}  BTS_label=${BTS_label}  scf_path=${${alias}_initial_autoconfigured_scf_path}

    Admin Validate SCF TAF  alias=${alias}
    Admin Validate SCF With Detected Hardware  alias=${alias}

Step ${index}: Check and activate feature CB013031 on BTS
    [Documentation]
    ...  Checks and activates feature CB013031:
    ...  - Ensures feature CB013031 is activated before testing parameter removal
    ...  - Tests feature toggle behavior (disable then enable if initially true)
    ...  - Validates parameter commissioning works correctly

    Log  Step ${index}: Check and activate feature CB013031 on BTS  console=True

    ${actCondAutoConfValCalc_initial}=  Get feature CB013031 info  alias=${alias}
    Log  ${BTS_label} initial actCondAutoConfValCalc value: ${actCondAutoConfValCalc_initial}  console=True
    Set Test Variable  ${${alias}_actCondAutoConfValCalc_initial}  ${actCondAutoConfValCalc_initial}

    Run Keyword If  '${actCondAutoConfValCalc_initial}' == 'false'
    ...  Handle Feature Initially Disabled  alias=${alias}  BTS_label=${BTS_label}
    ...  ELSE
    ...  Handle Feature Initially Enabled  alias=${alias}  BTS_label=${BTS_label}

Step ${index}: Check CACV parameters presence in current SCF
    [Documentation]
    ...  Verifies that all CACV parameters are present in the current autoconfigured SCF under at least one MO instance.

    Log  Step ${index}: Check CACV parameters presence in current SCF  console=True
    Log  Check that all ${BTS_label} CACV parameters are present in current SCF  console=True

    ${nidd_params_dict}  ${nidd_params_keys}=  Get NIDD Parameters for BTS
    ${params_count}=  Get Length  ${nidd_params_keys}
    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    Log  Checking ${params_count} CACV parameters in curent SCF: ${scf_path}. List: ${nidd_params_keys}   console=True

    FOR  ${param}  IN  @{nidd_params_keys}

        ${param_parent_mo}=  Get Parameter Parent MO  ${nidd_params_dict}  ${param}
        ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/${param_parent_mo}-[\\d]+$  scf_path=${scf_path}  alias=${alias}

        ${dn_list_exists}=  Run Keyword And Return Status  Should Not Be Empty  ${dn_list}
        Run Keyword If  not ${dn_list_exists}  Run Keywords
        ...  Log  ${BTS_label} current SCF: ${scf_path} does not contain any MO for parameter: ${param}, not as expected!  level=ERROR
        ...  AND  Fail  ${BTS_label} current SCF: ${scf_path} does not contain any MO for parameter: ${param}, not as expected!

        FOR  ${dn}  IN  @{dn_list}
            ${param_exists}=  Check If Parameter Exists from SCF  item_dist_name=${dn}  parameter_to_check=${param}  scf_path=${scf_path}
            Exit For Loop If  ${param_exists}
        END

        Run Keyword If  not ${param_exists}  Run Keywords
        ...  Log  ${BTS_label} parameter: ${param} is not present in current SCF: ${scf_path}, not as expected!  level=ERROR
        ...  AND  Fail  ${BTS_label} parameter: ${param} is not present in current SCF: ${scf_path}, not as expected!

    END

    Log  All ${params_count} CACV parameters are present in ${BTS_label} current SCF, as expected!  console=True

Step ${index}: Remove CACV parameters from current SCF
    [Documentation]
    ...  Removes CACV parameters from current BTS SCF using delta commissioning.

    Log  Step ${index}: Remove CACV parameters from current SCF  console=True

    Get Current Date UTC info  start_cacv_param_removal
    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    ${delta_id}=  Create Delta Commissioning Plan

    ${nidd_params_dict}  ${nidd_params_keys}=  Get NIDD Parameters for BTS
    Add CACV Parameter Deletions To Delta  delta_id=${delta_id}  nidd_params_dict=${nidd_params_dict}  nidd_params_keys=${nidd_params_keys}

    Execute Delta Commissioning  delta_id=${delta_id}

    Check BTS states and alarms after commissioning  alias=${alias}  BTS_label=${BTS_label}

    Get Current Date UTC info  end_cacv_param_removal

Step ${index}: Check that CACV parameters are removed in final SCF
    [Documentation]
    ...  Validates that CACV parameters were properly removed and auto-recalculated by feature CB013031.

    Log  Step ${index}: Check that CACV parameters are removed in final SCF  console=True

    Check removed CACV parameters absent from final default SCF  scf_path=${${alias}_final_default_scf_path}
    Check removed CACV parameters present in final autoconfigured SCF  scf_path=${${alias}_final_autoconfigured_scf_path}

Step ${index}: Check RMOD reset behavior based on Uptime info after CACV parameters removal
    [Documentation]
    ...  Validates that no RMOD resets occurred during CACV parameter removal.

    Log  Step ${index}: Check RMOD reset behavior based on Uptime info after CACV parameters removal  console=True

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    ${RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    Check RMOD reset behavior on BTS  ${RMOD_sn_list}  ${alias}

Step ${index}: Check BTS reset behavior based on IMS info after CACV parameters removal
    [Documentation]
    ...  Validates that BTS did NOT reset during CACV parameter removal via IMS file analysis.

    Log  Step ${index}: Check BTS reset behavior based on IMS info after CACV parameters removal  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_cacv_param_removal_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_cacv_param_removal_UTC}

Step ${index}: Perform BTS commissioning with initial default SCF
    [Documentation]
    ...  Recovers BTS to initial state by commissioning with the initial default SCF.

    Log  Step ${index}: Perform BTS commissioning with initial default SCF  console=True

    Log  Commissioning ${BTS_label} with: ${${alias}_initial_default_scf_path}  console=True
    Perform BTS Commissioning  alias=${alias}  BTS_label=${BTS_label}  scf_path=${${alias}_initial_default_scf_path}

    Set Test Variable  ${${alias}_recover_initial_scf_needed}  ${FALSE}


Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Save BTS SCF
    [Documentation]
    ...  Saves BTS SCF in two export formats without validation.
    ...  Export Types:
    ...  1. Default (configurationAndRuntimeObjects) - WITHOUT autoconfigured parameters
    ...  2. Autoconfigured - WITH autoconfigured parameters

    [Arguments]  ${when}

    Log  Save ${BTS_label} ${when} SCF with default Admin API option  console=True
    ${default_scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  file_name=${when}_default_scf
    ...  with_auto_configured_parameters=${FALSE}
    Log  ${BTS_label} ${when} default SCF saved to: ${default_scf_path}  console=True

    Log  Save ${BTS_label} ${when} SCF with autoconfigured parameters option  console=True
    ${autoconfigured_scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  file_name=${when}_autoconfigured_scf
    Log  ${BTS_label} ${when} autoconfigured SCF saved to: ${autoconfigured_scf_path}  console=True

    Set Test Variable  ${${alias}_${when}_default_scf_path}  ${default_scf_path}
    Set Test Variable  ${${alias}_${when}_autoconfigured_scf_path}  ${autoconfigured_scf_path}

Validate BTS SCF
    [Documentation]
    ...  Validates specified BTS SCF

    [Arguments]  ${when}  ${scf_type}

    ${scf_path}=  Set Variable  ${${alias}_${when}_${scf_type}_scf_path}
    Log  Validate ${BTS_label} ${when} ${scf_type} SCF  console=True

    Admin Validate SCF TAF  scf_path_file=${scf_path}  alias=${alias}
    Admin Validate SCF With Detected Hardware  scf_path_file=${scf_path}  alias=${alias}

    Log  ${BTS_label} ${when} ${scf_type} SCF validation completed successfully!  console=True

Check NIDD parameters
    [Documentation]
    ...  Validates that all CACV parameters have isAutoconfigurable flag set to true in NIDD.

    Log  Check that ${BTS_label} NIDD parameters have isAutoconfigurable option set to true  console=True

    ${nidd_params_dict}  ${nidd_params_keys}=  Get NIDD Parameters for BTS
    ${param_isAutoconfigurable_true}=  Create List
    ${param_isAutoconfigurable_false}=  Create List

    FOR  ${param}  IN  @{nidd_params_keys}

        ${param_parent_mo}=  Get Parameter Parent MO  ${nidd_params_dict}  ${param}
        ${param_isAutoconfigurable_value}=  Set Variable  ${${alias}_dict_result}[${param_parent_mo}][params][${param}][isAutoconfigurable]
        ${param_isAutoconfigurable_value}=  Convert to String  ${param_isAutoconfigurable_value}
        ${param_isAutoconfigurable_value}=  Convert To Lower Case  ${param_isAutoconfigurable_value}

        Run Keyword If  '${param_isAutoconfigurable_value}' == 'true'
        ...  Append To List  ${param_isAutoconfigurable_true}  ${param}
        ...  ELSE
        ...  Append To List  ${param_isAutoconfigurable_false}  ${param}

    END

    ${true_count}=  Get Length  ${param_isAutoconfigurable_true}
    Run Keyword If  ${true_count} > 0
    ...  Log Long String  ${BTS_label}: ${true_count} CACV parameters have isAutoconfigurable=true, as expected!
    ...  List: ${param_isAutoconfigurable_true}  console=True

    ${false_count}=  Get Length  ${param_isAutoconfigurable_false}
    Run Keyword If  ${false_count} > 0  Run Keywords
    ...  Log Long String  ${BTS_label}: ${false_count} CACV parameters have isAutoconfigurable=false, not as expected!
    ...  List: ${param_isAutoconfigurable_false}  level=ERROR
    ...  AND  Fail  ${BTS_label}: Following CACV parameters have isAutoconfigurable=false -> ${param_isAutoconfigurable_false}

Get NIDD Parameters for BTS
    [Documentation]
    ...  Retrieves NIDD parameter dictionary and keys for a given BTS label.

    ${nidd_params_dict}=  Get From Dictionary  ${cacv_parameters_yaml_file}  ${BTS_label}
    ${nidd_params_keys}=  Get Dictionary Keys  ${nidd_params_dict}  False

    [Return]  ${nidd_params_dict}  ${nidd_params_keys}

Get Parameter Parent MO
    [Documentation]
    ...  Extracts parent MO name from the parameter's MOC name value.

    [Arguments]  ${nidd_params_dict}  ${param}

    ${param_values_dict}=  Get From Dictionary  ${nidd_params_dict}  ${param}
    ${param_moc_name_value}=  Get From Dictionary  ${param_values_dict}  moc_name
    ${param_parent_mo}=  Fetch From Right  ${param_moc_name_value}  /

    [Return]  ${param_parent_mo}

Perform BTS Commissioning
    [Arguments]  ${alias}  ${BTS_label}  ${scf_path}

    ${BTS_ID}=  Get Id For Current  class_name=BTS  connection=${alias}

    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${scf_path}  should_activate=True
    ...  timeout=${BTS_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS_label} commissioning has been performed!  console=True
    Check BTS states and alarms after commissioning  alias=${alias}  BTS_label=${BTS_label}

Check BTS states and alarms after commissioning
    [Arguments]  ${alias}  ${BTS_label}

    Log  Check ${BTS_label} states and alarms after commissioning  console=True
    Log  Check ${BTS_label} state:  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}

    Log  Check ${BTS_label} alarms:
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Get feature CB013031 info
    [Arguments]  ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${actCondAutoConfValCalc_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}
    ...  dist_name=${BTS_SCF_dn}  p_name=actCondAutoConfValCalc

    ${actCondAutoConfValCalc_count}=  Get Length  ${actCondAutoConfValCalc_info_dict}
    ${actCondAutoConfValCalc_value}=  Run Keyword If  ${actCondAutoConfValCalc_count} > 0
    ...  Get From Dictionary  ${actCondAutoConfValCalc_info_dict}  actCondAutoConfValCalc
    ...  ELSE  Set Variable  NA

    [Return]  ${actCondAutoConfValCalc_value}

Handle Feature Initially Disabled
    [Documentation]
    ...  Handles feature CB013031 when initially disabled.

    [Arguments]  ${alias}  ${BTS_label}

    Log  Feature CB013031 initially disabled on ${BTS_label} - enabling feature  console=True
    Set and Verify feature CB013031 on BTS  alias=${alias}  BTS_label=${BTS_label}
    Log  Feature CB013031 successfully enabled on ${BTS_label}!  console=True

Handle Feature Initially Enabled
    [Documentation]
    ...  Handles feature CB013031 when initially enabled.

    [Arguments]  ${alias}  ${BTS_label}

    Log  Feature CB013031 initially enabled on ${BTS_label}  console=True

    Log  Disabling feature CB013031 on ${BTS_label}  console=True
    Set and Verify feature CB013031 on BTS  alias=${alias}  BTS_label=${BTS_label}  actCondAutoConfValCalc_value=false
    Log  Feature CB013031 successfully disabled on ${BTS_label}  console=True

    Log  Re-enabling feature CB013031 on ${BTS_label}  console=True
    Set and Verify feature CB013031 on BTS  alias=${alias}  BTS_label=${BTS_label}
    Log  Feature CB013031 successfully re-enabled on ${BTS_label}  console=True

Set and Verify feature CB013031 on BTS
    [Documentation]
    ...  Sets the actCondAutoConfValCalc parameter value on BTS and verifies it was set correctly.

    [Arguments]  ${alias}  ${BTS_label}  ${actCondAutoConfValCalc_value}=true

    Set feature CB013031 on BTS  alias=${alias}  actCondAutoConfValCalc_value=${actCondAutoConfValCalc_value}
    Check BTS states and alarms after commissioning  alias=${alias}  BTS_label=${BTS_label}
    Check feature CB013031 status  param_value=${actCondAutoConfValCalc_value}

Set feature CB013031 on BTS
    [Documentation]
    ...  Sets the actCondAutoConfValCalc parameter value on BTS via parameter recommissioning.

    [Arguments]  ${alias}  ${actCondAutoConfValCalc_value}=true

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/FEATCADM-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${BTS_SCF_dn}=  Get From List  ${dn_list}  0

    ${actCondAutoConfValCalc}=  Get feature CB013031 info  alias=${alias}

    Run Keyword If  '${actCondAutoConfValCalc}' == '${actCondAutoConfValCalc_value}'
    ...  Log  Parameter actCondAutoConfValCalc: ${actCondAutoConfValCalc} already set on BTS ${alias}, commissioning not needed!  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_dn}  parameter=actCondAutoConfValCalc  operation=update
    ...  value=${actCondAutoConfValCalc_value}  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
    ...  AND  Sleep  3s

Check feature CB013031 status
    [Arguments]  ${param_value}

    Log  Check feature CB013031 status on ${BTS_label}  console=True

    ${actCondAutoConfValCalc_final}=  Get feature CB013031 info  alias=${alias}

    Run Keyword If  '${actCondAutoConfValCalc_final}' == '${param_value}'
    ...  Log  ${BTS_label} final actCondAutoConfValCalc parameter value: ${actCondAutoConfValCalc_final}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${BTS_label} parameter actCondAutoConfValCalc = ${actCondAutoConfValCalc_final}, not properly commissioned!  level=ERROR
    ...  AND
    ...  Fail  ${BTS_label} parameter actCondAutoConfValCalc = ${actCondAutoConfValCalc_final}, not properly commissioned!

Create Delta Commissioning Plan
    [Documentation]
    ...  Creates a delta commissioning plan with timestamp identifier.

    ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}=  Get Time  format=year,month,day,hour,min,sec
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}_${sec}
    ${delta_id}=  Set Variable  cacv_plan_${timestamp}

    Log  Creating delta commissioning plan: ${delta_id}  console=True
    coam.Create Delta  delta_id=${delta_id}
    Log  Delta plan ${delta_id} created successfully!  console=True

    [Return]  ${delta_id}

Add CACV Parameter Deletions To Delta
    [Documentation]
    ...  Adds all CACV parameter deletions to delta commissioning plan.

    [Arguments]  ${delta_id}  ${nidd_params_dict}  ${nidd_params_keys}

    Log  Adding CACV parameter deletions to delta ${delta_id}  console=True

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}

    FOR  ${param}  IN  @{nidd_params_keys}

        ${param_parent_mo}=  Get Parameter Parent MO  ${nidd_params_dict}  ${param}
        ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/${param_parent_mo}-[\\d]+$  scf_path=${scf_path}  alias=${alias}

        FOR  ${dn}  IN  @{dn_list}
            coam.Append Parameter Delete To Delta  dist_name=${dn}  parameter=${param}  delta_id=${delta_id}
        END

        ${dn_count}=  Get Length  ${dn_list}
        Log  Added deletion for parameter: ${param} with ${dn_count} MO instances. MO instance list is: ${dn_list}  console=True

    END

    ${params_count}=  Get Length  ${nidd_params_keys}
    Log  Successfully added ${params_count} CACV parameter deletions to delta ${delta_id}.  console=True

Execute Delta Commissioning
    [Documentation]
    ...  Executes delta commissioning plan to remove CACV parameters.

    [Arguments]  ${delta_id}

    Log  Executing delta commissioning: ${delta_id}  console=True

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    coam.Save Delta  target_file_name=${BTS Files}/${alias}/delta_cacv_param_removal_run_${CYCLE}.json  delta_id=${delta_id}
    Log  Delta saved to: ${BTS Files}/${alias}/delta_cacv_param_removal_run_${CYCLE}.json  console=True

    Log  Performing delta recommissioning to remove CACV parameters  console=True
    coam.Perform Delta Recommissioning  alias=${alias}  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True

    Log  Delta commissioning ${delta_id} completed successfully - CACV parameters removed  console=True

Check removed CACV parameters absent from final default SCF
    [Documentation]
    ...  Validates that CACV parameters were successfully removed from default SCF.

    [Arguments]  ${scf_path}

    ${nidd_params_dict}  ${nidd_params_keys}=  Get NIDD Parameters for BTS
    ${params_count}=  Get Length  ${nidd_params_keys}

    Log  Checking ${params_count} removed CACV parameters absent from final ${BTS_label} default SCF: ${scf_path}  console=True

    FOR  ${param}  IN  @{nidd_params_keys}
        Check Parameter Absent From Default SCF  param=${param}  nidd_params_dict=${nidd_params_dict}  scf_path=${scf_path}
    END

    Log  All ${params_count} CACV parameters absent from final ${BTS_label} default SCF, as expected!  console=True

Check Parameter Absent From Default SCF
    [Documentation]
    ...  Helper keyword to check a single parameter is absent from default SCF.
    ...  Checks all MO instances for the parameter and fails if found.

    [Arguments]  ${param}  ${nidd_params_dict}  ${scf_path}

    ${param_parent_mo}=  Get Parameter Parent MO  ${nidd_params_dict}  ${param}
    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/${param_parent_mo}-[\\d]+$  scf_path=${scf_path}  alias=${alias}

    FOR  ${dn}  IN  @{dn_list}

        ${param_status}=  Check If Parameter Exists from SCF  item_dist_name=${dn}  parameter_to_check=${param}  scf_path=${scf_path}

        Run Keyword If  '${param_status}' == 'True'  Run Keywords
        ...  Log  ${BTS_label} parameter: ${param} with MO: ${dn} is still present in final default SCF: ${scf_path}, not as expected!  level=ERROR
        ...  AND
        ...  Fail  ${BTS_label} parameter: ${param} with MO: ${dn} is still present in final default SCF: ${scf_path}, not as expected!

    END

Check removed CACV parameters present in final autoconfigured SCF
    [Documentation]
    ...  Validates that CACV parameters were auto-recalculated by feature CB013031.

    [Arguments]  ${scf_path}

    ${nidd_params_dict}  ${nidd_params_keys}=  Get NIDD Parameters for BTS
    ${params_count}=  Get Length  ${nidd_params_keys}

    Log  Checking ${params_count} removed CACV parameters present in final ${BTS_label} autoconfigured SCF: ${scf_path}  console=True

    FOR  ${param}  IN  @{nidd_params_keys}
        Check Parameter Present In Autoconfigured SCF  param=${param}  nidd_params_dict=${nidd_params_dict}  scf_path=${scf_path}
    END

    Log  All ${params_count} CACV parameters present in final ${BTS_label} autoconfigured SCF, as expected!  console=True

Check Parameter Present In Autoconfigured SCF
    [Documentation]
    ...  Helper keyword to check a single parameter is present with expected value in autoconfigured SCF.
    ...  Checks all MO instances for the parameter and checks values. If expected value is ${NONE} (it was not defined in YAML file), any parameter
    ...  value is accepted. Otherwise, parameter value must match expected value defined in YAMl file for at least one MO instance. If parameter is
    ...  not found with expected value in any MO instance, keyword fails.

    [Arguments]  ${param}  ${nidd_params_dict}  ${scf_path}

    ${param_parent_mo}=  Get Parameter Parent MO  ${nidd_params_dict}  ${param}
    ${param_values_dict}=  Get From Dictionary  ${nidd_params_dict}  ${param}
    ${param_expected_autoconfigured_value}=  Get From Dictionary  ${param_values_dict}  expected_autoconfigured_value

    ${is_boolean}=  Evaluate  type($param_expected_autoconfigured_value) is bool
    ${param_expected_autoconfigured_value}=  Run Keyword If  ${is_boolean}
    ...  Convert to String  ${param_expected_autoconfigured_value}
    ...  ELSE  Set Variable  ${param_expected_autoconfigured_value}
    ${param_expected_autoconfigured_value}=  Run Keyword If  ${is_boolean}
    ...  Convert To Lower Case  ${param_expected_autoconfigured_value}
    ...  ELSE  Set Variable  ${param_expected_autoconfigured_value}

    ${dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/${param_parent_mo}-[\\d]+$  scf_path=${scf_path}  alias=${alias}

    FOR  ${dn}  IN  @{dn_list}
        ${param_found}=  Check Parameter Presence And Value  param=${param}  dn=${dn}  expected_value=${param_expected_autoconfigured_value}
        ...  scf_path=${scf_path}
        Exit For Loop If  ${param_found}
    END

    ${fail_log_message}=  Create Long String  ${BTS_label} parameter: ${param} was not found with expected value:
    ...  ${param_expected_autoconfigured_value}  in any of its MO instances in final autoconfigured SCF: ${scf_path}!

    Run Keyword If  not ${param_found}  Run Keywords
    ...  Log  ${fail_log_message}  level=ERROR
    ...  AND  Fail  ${fail_log_message}

Check Parameter Presence And Value
    [Documentation]
    ...  Checks that a parameter exists in SCF and has the expected autoconfigured value.
    ...  Handles two cases:
    ...  1. Expected value is ${NONE}: Parameter must exist (any value OK)
    ...  2. Expected value is specified: Parameter value must match exactly

    [Arguments]  ${param}  ${dn}  ${expected_value}  ${scf_path}

    ${param_status}=  Check If Parameter Exists from SCF  item_dist_name=${dn}  parameter_to_check=${param}  scf_path=${scf_path}

    Run Keyword If  '${param_status}' == 'False'  Run Keywords
    ...  Log  ${BTS_label} parameter: ${param} with MO: ${dn} is not present in final autoconfigured SCF: ${scf_path}, not as expected!  level=ERROR
    ...  AND  Fail  ${BTS_label} parameter: ${param} with MO: ${dn} is not present in final autoconfigured SCF: ${scf_path}, not as expected!

    ${param_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${dn}  p_name=${param}
    ${param_count}=  Get Length  ${param_info_dict}
    ${param_value}=  Run Keyword If  ${param_count} > 0
    ...  Get From Dictionary  ${param_info_dict}  ${param}
    ...  ELSE  Set Variable  NA

    Run Keyword If  '${param_value}' == 'NA'
    ...  Return From Keyword  ${FALSE}

    Run Keyword If  '${expected_value}' == '${NONE}'  Run Keywords
    ...  Log Long String  ${BTS_label} parameter: ${param} with MOL ${dn} has value: ${param_value}. Expected value not specified in YAML -
    ...  accepting any value.  console=True
    ...  AND  Return From Keyword  ${TRUE}

    ${param_found}=  Evaluate  '${param_value}' == '${expected_value}'
    Run Keyword If  ${param_found}
    ...  Log  ${BTS_label} parameter: ${param} with MO: ${dn} has value: ${param_value} in final autoconfigured SCF, as expected!  console=True

    [Return]  ${param_found}

Check RMOD reset behavior on BTS
    [Documentation]
    ...  Helper keyword to validate RMOD reset behavior by comparing Uptime values.

    [Arguments]  ${RMOD_sn_list}  ${alias}

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RMOD_sn_list}
    ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}  alias=${alias}

Recover initial BTS SCF
    [Arguments]  ${alias}

    ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

    ${flag_exists}=  Run Keyword And Return Status  Variable Should Exist  ${${alias}_recover_initial_scf_needed}

    Run Keyword If  not ${flag_exists}  Run Keywords
    ...  Log  Recovery flag not set for ${BTS_label} - test may have failed before processing this BTS. Skipping recovery.  level=WARN
    ...  AND  Return From Keyword

    Run Keyword If  not ${${alias}_recover_initial_scf_needed}  Run Keywords
    ...  Log  Recovery not needed for ${BTS_label} - already recovered in Step 13. Skipping.  console=True
    ...  AND  Return From Keyword

    Log  Recovery needed for ${BTS_label}. Starting recovery...  console=True
    Perform Recovery for BTS  ${alias}  ${BTS_label}

Perform Recovery for BTS
    [Documentation]
    ...  Internal keyword to perform the actual BTS recovery with initial SCF.
    ...  Checks if initial SCF path is available before attempting recovery.

    [Arguments]  ${alias}  ${BTS_label}

    ${scf_path_exists}=  Run Keyword And Return Status  Variable Should Exist  ${${alias}_initial_default_scf_path}

    Run Keyword If  not ${scf_path_exists}  Run Keywords
    ...  Log  Initial SCF path not available for ${BTS_label} - test failed before Step 3. Skipping recovery.  level=WARN
    ...  AND  Return From Keyword

    Log  Recovering ${BTS_label} with initial default SCF: ${${alias}_initial_default_scf_path}  console=True
    Perform BTS Commissioning  alias=${alias}  BTS_label=${BTS_label}  scf_path=${${alias}_initial_default_scf_path}

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        Recover initial BTS SCF  ${alias}
    END
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
