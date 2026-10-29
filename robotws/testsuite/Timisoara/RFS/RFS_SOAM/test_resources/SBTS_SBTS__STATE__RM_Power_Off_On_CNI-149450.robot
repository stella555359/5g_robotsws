*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RM_Power_Off_On_CNI-149450
Variables    tc_variables/sbts_sbts__state__rm_power_off_on_cni-149450_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             3         # Number of RMOD Power Off On operations. By default 3
${RADIO_MODULE_SN_LIST}       ALL       # RMOD serial number list on which RMOD Power Off On will be performed.
                                        # Possible values: ALL (all shared and dedicated RMODs)
                                        # or list of selected RMOD serial numbers separated by comma.
${RMOD_POWER_MAX_WAIT_TIME}   900       # Maximum waiting time for action to be completed
${RMOD_RESET_TIME_INTERVAL}   480       # Time interval between reset RMOD (due to power OFF/ON), default value 480 seconds.
${RMOD_LED_CONFIG_YAML_PATH}  ${EMPTY}  # Relative path to the YAML config file. Path is relative to testline_configuration
                                        # Path example: 10_18_UTESRANRFSMTNRL9/RMOD_LED_Check_Settings.yaml
${LED_MONITORING_TIMEOUT}     600       # Maximum time (seconds) for the LED monitoring start operation

*** Keywords ***
TC__SBTS_SBTS__STATE__RM_Power_Off_On_CNI-149450
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30473
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for RMOD Power Off On CNI-149450
    ...  Verifies that performing RMOD Power Off On operations on RMOD from BTS primary controller leads to expected BTS states and alarms,
    ...  and that the RMOD LED control feature works as expected for BTS primary controller RMODs. - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items
    ...  - check PDU definition and reachability
    ...  - check initial ledControl/ledControlState parameter values and current LED state for all RMODs
    ...  - enable LED control feature for all BTS primary controller RMODs
    ...    - check ledControl/ledControlState parameter values and current LED state after feature enable
    ...  - perform power OFF/ON RMOD for BTS primary controller RMODs - one RMOD at a time, sequence repeated x times
    ...    - shared RMODs: power OFF/ON performed once, checks done for both BTS
    ...    - safe time verified before each operation to avoid short-interval resets on the same RMOD
    ...    - RMOD info collected from all BTS before operation to capture initial state
    ...    - after power ON: UNIT LED occurrence checked (UNIT LED was ON at least once during RMOD boot)
    ...    - after power ON: ledControl/ledControlState parameter values and LED stable states in interval checked
    ...  - check final state and alarms for all BTS after each power OFF/ON operation
    ...  - check final number and state of Cells and RMs after each power OFF/ON operation
    ...  - restore initial LED control feature for all BTS primary controller RMODs
    ...    - check ledControl/ledControlState parameter values and current LED state after feature restore
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 11.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30473 - [CNI-149450] New test case SBTS_SBTS_STATE_RM_Power_Off_On_CNI-149450
    ...

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS26R3

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Check PDU definition and reachability
    Step 5: Check initial all RMOD ledControl and ledControlState parameters value and LEDs state
    Step 6: Enable LED control feature for all BTS primary controller RMODs and check LEDs state
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 7: Perform power OFF/ON RMOD
        Step 8: Check final all BTS state
        Step 9: Check final all BTS alarms
        Step 10: Check final number and state of Cells and RMs
    END
    Step 11: Restore initial LED control feature for all BTS primary controller RMODs and check LEDs state

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=
    ...  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    IF  '${RADIO_MODULE_SN_LIST}' != 'ALL'
        Check RMOD serial number list
    END

    Log  =====================================================================  console=True
    Log  RMOD serial number list selected for LED Control test: ${RMOD_all_sn_list}  console=True
    Log  =====================================================================  console=True

    Validate RMOD LED YAML Config  ${RMOD_all_sn_list}

Check RMOD serial number list
    ${RADIO_MODULE_SN_LIST_strip}=  Replace String  ${RADIO_MODULE_SN_LIST}  ${SPACE}  ${EMPTY}
    ${RADIO_MODULE_SN_LIST_split}=  Split String  ${RADIO_MODULE_SN_LIST_strip}  ,
    ${sn_invalid_list}=  Create List

    FOR  ${item}  IN  @{RADIO_MODULE_SN_LIST_split}
        IF  '${item}' not in ${RMOD_all_sn_list}
            Append To List  ${sn_invalid_list}  ${item}
        END
    END

    IF  ${sn_invalid_list}
        Log Long String  Following selected RMOD serial numbers are not valid: ${sn_invalid_list}. Please select values from configured RMODs:
        ...  ${RMOD_all_sn_list}  level=ERROR
        Fail  Improper value for test argument \${RADIO_MODULE_SN_LIST}!
    END

    Set Test Variable  ${RMOD_all_sn_list}  ${RADIO_MODULE_SN_LIST_split}

Validate RMOD LED YAML Config
    [Documentation]
    ...  Validates the RMOD_LED_Check_Settings.yaml config file.
    ...  Checks performed:
    ...  1. \${RMOD_LED_CONFIG_YAML_PATH} variable is not empty.
    ...  2. The YAML file exists on disk.
    ...  3. The YAML file can be loaded (valid syntax) using Load yaml config KW.
    ...  4. Every RMOD serial number from \${RMOD_all_sn_list} has a top-level key
    ...     in the YAML - one entry per RMOD that will be tested.
    ...  5. Each RMOD entry contains all required keys:
    ...     host_ip, host_user, host_password, com_port, baud_rate,
    ...     MEASUREMENT_SEPARATOR, LED_NUMBERS, LED_THRESHOLDS.

    [Arguments]  ${rmod_sn_list}

    ${yaml_path}=  Set Variable  /home/ute/testline_configuration/${RMOD_LED_CONFIG_YAML_PATH}
    Set Test Variable  ${yaml_path}

    Should Not Be Empty  ${RMOD_LED_CONFIG_YAML_PATH}
    ...  msg=\${RMOD_LED_CONFIG_YAML_PATH} is empty. Set it to the path of RMOD_LED_Check_Settings.yaml.

    ${file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${yaml_path}
    IF  not ${file_exists}
        Log  RMOD LED config YAML not found: ${yaml_path}  level=ERROR
        Log  Please check \${RMOD_LED_CONFIG_YAML_PATH}. Expected: path to RMOD_LED_Check_Settings.yaml  level=ERROR
        Fail  RMOD LED config YAML not found: ${yaml_path}
    END

    ${load_status}  ${yaml_content}=  Run Keyword And Ignore Error  Load yaml config  ${yaml_path}
    IF  '${load_status}' == 'FAIL'
        Log  Failed to parse RMOD LED config YAML: ${yaml_path}  level=ERROR
        Log  File exists but content is invalid. Please check the YAML syntax.  level=ERROR
        Fail  Failed to load RMOD LED config YAML: ${yaml_path}
    END
    Set Test Variable  ${RMOD_LED_yaml_content}  ${yaml_content}

    ${yaml_keys}=  Get Dictionary Keys  ${yaml_content}  False
    Log  YAML top-level keys (RMOD labels): ${yaml_keys}  console=True

    ${missing_labels}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
        ${found}=  Set Variable If  '${rmod_sn}' in ${yaml_keys}  True  False
        IF  not ${found}
            Append To List  ${missing_labels}  ${rmod_sn}
        END
    END

    IF  ${missing_labels}
        Log  YAML '${yaml_path}' is missing entries for RMOD serial numbers: ${missing_labels}  level=ERROR
        Log  Add a top-level key matching each RMOD serial number to the YAML file.  level=ERROR
        Fail  YAML '${yaml_path}' is missing entries for RMOD serial numbers: ${missing_labels}
    END

    ${required_keys}=  Create List
    ...  host_ip  host_user  host_password  com_port  baud_rate  MEASUREMENT_SEPARATOR  LED_NUMBERS  LED_THRESHOLDS

    ${invalid_entries}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
        ${rmod_entry}=  Get From Dictionary  ${yaml_content}  ${rmod_sn}
        ${entry_keys}=  Get Dictionary Keys  ${rmod_entry}  False
        FOR  ${req_key}  IN  @{required_keys}
            ${has_key}=  Set Variable If  '${req_key}' in ${entry_keys}  True  False
            IF  not ${has_key}
                Append To List  ${invalid_entries}  ${rmod_sn}: missing key '${req_key}'
            END
        END
    END

    IF  ${invalid_entries}
        Log  YAML '${yaml_path}' has incomplete RMOD entries: ${invalid_entries}  level=ERROR
        Fail  YAML '${yaml_path}' has incomplete RMOD entries: ${invalid_entries}
    END

    Log  YAML '${yaml_path}' validated OK for all RMOD serial numbers: ${rmod_sn_list}  console=True

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

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        Sort List  ${BTS_primary_controller_RMOD_sn_list}
        Sort List  ${BTS_secondary_controller_RMOD_sn_list}
        Set Test Variable  ${${alias}_BTS_primary_controller_RMOD_sn_list}  ${BTS_primary_controller_RMOD_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller_RMOD_sn_list}
        Log  BTS ${alias} primary controller RM SN list: ${BTS_primary_controller_RMOD_sn_list}  console=True
        Log  BTS ${alias} secondary controller RM SN list: ${BTS_secondary_controller_RMOD_sn_list}  console=True

        Get BTS CELL list by RAT  ${alias}

    END

    Set Test Variable  ${RMOD_state_powered_off_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_powered_off}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_powered_on_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_powered_on}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}

Step ${index}: Check PDU definition and reachability

    Log  Step ${index}: Check PDU definition and reachability  console=True

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        Check PDU port status  RMOD_${RMOD_sn}  on

    END

Step ${index}: Check initial all RMOD ledControl and ledControlState parameters value and LEDs state

    Log  Step ${index}: Check initial all RMOD ledControl and ledControlState parameters value and LEDs state  console=True

    Start LED Monitoring
    Check all RMOD ledControl and ledControlState parameters value  when=initial
    Check all RMOD current LEDS state  when=initial

Step ${index}: Enable LED control feature for all BTS primary controller RMODs and check LEDs state

    Log  Step ${index}: Enable LED control feature for all BTS primary controller RMODs and check LEDs state  console=True

    Get all RMODs which have LED control feature disabled

    FOR  ${alias}  IN  @{alias_list}

        IF  not ${${alias}_ledControl_disabled_RMOD_sn_list}  CONTINUE

        Get Current Date UTC info  start_enable_feature

        Log Long String  Create and perform Delta Commissioning to enable ledControl parameter for BTS ${alias} RMODs with SN list:
        ...  ${${alias}_ledControl_disabled_RMOD_sn_list}  console=True

        ${delta_id}=  Create Delta Commissioning Plan  alias=${alias}

        Add ledControl parameter updates to Delta  delta_id=${delta_id}  parameter_value=Enabled  alias=${alias}
        Perform Delta Commissioning  delta_id=${delta_id}  alias=${alias}

        Check BTS states and alarms after commissioning  alias=${alias}

        Get Current Date UTC info  end_enable_feature

        Check BTS reset behavior after commissioning  alias=${alias}  start_timestamp_UTC=${date_timestamp_start_enable_feature_UTC}
        ...  end_timestamp_UTC=${date_timestamp_end_enable_feature_UTC}

    END

    Check all RMOD ledControl and ledControlState parameters value  when=after feature enable
    Check all RMOD current LEDS state  when=after feature enable
    Stop LED Monitoring

Step ${index}: Perform power OFF/ON RMOD

    Log  Step ${index}: Perform power OFF/ON RMOD  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list} or '${RMOD_sn}' not in ${${alias}_BTS_primary_controller_RMOD_sn_list}  CONTINUE

            ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
            ${RMOD_peer_BTS_alias_list}=  Copy List  ${RMOD_BTS_alias_list}
            Remove Values From List  ${RMOD_peer_BTS_alias_list}  ${alias}

            IF  '${RMOD_sn}' in ${shared_RMOD_sn_list}
                ${peer_BTS_alias}=  Get From List  ${RMOD_peer_BTS_alias_list}  0
            ELSE
                ${peer_BTS_alias}=  Set Variable  None
            END

            Check safe time for RMOD operations  RMOD_sn=${RMOD_sn}

            Get RMOD info from all BTS  RMOD_sn=${RMOD_sn}

            Power OFF RMOD  RMOD_sn=${RMOD_sn}  BTS_alias=${alias}  peer_BTS_alias=${peer_BTS_alias}
            Power ON RMOD  RMOD_sn=${RMOD_sn}

        END

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Restore initial LED control feature for all BTS primary controller RMODs and check LEDs state

    Log  Step ${index}: Restore initial LED control feature for all BTS primary controller RMODs and check LEDs state  console=True

    Start LED Monitoring

    FOR  ${alias}  IN  @{alias_list}

        IF  not ${${alias}_ledControl_disabled_RMOD_sn_list}  CONTINUE

        Get Current Date UTC info  start_disable_feature

        Log Long String  Create and perform Delta Commissioning to restore initial ledControl parameter value for BTS ${alias} RMODs with SN list:
        ...  ${${alias}_ledControl_disabled_RMOD_sn_list}  console=True

        ${delta_id}=  Create Delta Commissioning Plan  alias=${alias}

        Add ledControl parameter updates to Delta  delta_id=${delta_id}  parameter_value=Disabled  alias=${alias}
        Perform Delta Commissioning  delta_id=${delta_id}  alias=${alias}

        Check BTS states and alarms after commissioning  alias=${alias}

        Get Current Date UTC info  end_disable_feature

        Check BTS reset behavior after commissioning  alias=${alias}  start_timestamp_UTC=${date_timestamp_start_disable_feature_UTC}
        ...  end_timestamp_UTC=${date_timestamp_end_disable_feature_UTC}

    END

    Check all RMOD ledControl and ledControlState parameters value  when=after feature disable
    Check all RMOD current LEDS state  when=after feature disable

    Stop LED Monitoring

Start LED Monitoring
    Log  Starting LED monitoring for all RMODs  console=True

    ${status}  ${msg}=  Run Keyword And Ignore Error  rmod_led_checker.Start Led Monitoring For Multiple Hosts
    ...  log_folder=${Test Results Dir}/RMOD_LED_CHECK  config_yaml_path=${yaml_path}  timeout=${LED_MONITORING_TIMEOUT}

    IF  '${status}' == 'FAIL'
        Log  Failed to start LED monitoring for all RMODs: ${msg}  level=ERROR
        Fail  Failed to start LED monitoring for all RMODs: ${msg}
    END

Stop LED Monitoring
    Log  Stop LED monitoring for all RMODs  console=True

    ${status}  ${msg}=  Run Keyword And Ignore Error  rmod_led_checker.Stop Led Monitoring

    IF  '${status}' == 'FAIL'
        Log  Failed to stop LED monitoring for all RMODs: ${msg}  level=ERROR
        Fail  Failed to stop LED monitoring for all RMODs: ${msg}
    END

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

    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=
    ...  Admin Get LTE HOST and IOT Cell(s) Id list  CELL_list=${LTE_CELL_list}  alias=${alias}

    Set Test Variable  ${${alias}_NR_CELL_list}     ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}    ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}    ${GSM_CELL_list}

Check PDU port status
    [Arguments]  ${item}  ${status}

    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
    IF  '${PDU_port_status}' == '${status}'
        Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}  console=True
    ELSE
        Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!  level=ERROR
        Fail  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!
    END

Check all RMOD ledControl and ledControlState parameters value
    [Arguments]  ${when}

    Log  *** Check ${when} all RMOD ledControl and ledControlState parameters value ***  console=True
    Log Long String  ledControl parameter value will be checked only for BTS primary controller RMODs,
    ...  while ledControlState parameter value will be checked for all RMODs.  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        ${RMOD_sn_ledControl_dict}=  Create Dictionary
        ${RMOD_sn_ledControlState_dict}=  Create Dictionary

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list}  CONTINUE

            ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
            ${ledControl_value}  ${ledControlState_value}=  Get ledControl and ledControlState parameters value  RMOD_id=${RMOD_id}  alias=${alias}

            IF  '${RMOD_sn}' in ${${alias}_BTS_primary_controller_RMOD_sn_list}
                IF  '${ledControl_value}' == 'NA'
                    Log  Failed to get ledControl parameter value for BTS ${alias} RMOD ${RMOD_sn}  level=ERROR
                    Fail  Failed to get ledControl parameter value for BTS ${alias} RMOD ${RMOD_sn}
                END
                Log  BTS ${alias} RMOD ${RMOD_sn}: ledControl=${ledControl_value}  console=True
                Set To Dictionary  ${RMOD_sn_ledControl_dict}  ${RMOD_sn}=${ledControl_value}
            END

            IF  '${ledControlState_value}' == 'NA'
                Log  Failed to get ledControlState parameter value for BTS ${alias} RMOD ${RMOD_sn}  level=ERROR
                Fail  Failed to get ledControlState parameter value for BTS ${alias} RMOD ${RMOD_sn}
            END
            Log  BTS ${alias} RMOD ${RMOD_sn}: ledControlState=${ledControlState_value}  console=True
            Set To Dictionary  ${RMOD_sn_ledControlState_dict}  ${RMOD_sn}=${ledControlState_value}

        END

        Set Test Variable  ${${alias}_${when}_RMOD_sn_ledControl_dict}  ${RMOD_sn_ledControl_dict}
        Set Test Variable  ${${alias}_${when}_RMOD_sn_ledControlState_dict}  ${RMOD_sn_ledControlState_dict}

    END

Check all RMOD current LEDS state
    [Arguments]  ${when}

    Log  *** Check ${when} all RMOD current LEDS state ***  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list} or '${RMOD_sn}' not in ${${alias}_BTS_primary_controller_RMOD_sn_list}  CONTINUE

            Ensure that ledControl and ledControlState have the same values  ${when}  ${RMOD_sn}  ${alias}
            Check RMOD current LEDs state  ${when}  ${RMOD_sn}  ${alias}

        END

    END

Ensure that ledControl and ledControlState have the same values
    [Arguments]  ${when}  ${RMOD_sn}  ${alias}

    ${ledControl_value}=  Get From Dictionary  ${${alias}_${when}_RMOD_sn_ledControl_dict}  ${RMOD_sn}
    ${RMOD_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Log  Ensure that ledControl and ledControlState parameters have the same value for RMOD ${RMOD_sn} BTS ${RMOD_alias_list}  console=True

    FOR  ${alias}  IN  @{RMOD_alias_list}

        ${ledControlState_value}=  Get From Dictionary  ${${alias}_${when}_RMOD_sn_ledControlState_dict}  ${RMOD_sn}
        ${status}=  Run Keyword And Return Status  Should Be Equal  ${ledControl_value}  ${ledControlState_value}

        ${error_message}=  Create Long String  BTS ${alias} RMOD ${RMOD_sn}: ledControl and ledControlState parameters have different values:
        ...  ledControl=${ledControl_value}, ledControlState=${ledControlState_value}
        IF  ${status}
            Log  BTS ${alias} RMOD ${RMOD_sn}: ledControl and ledControlState parameters have the same value: ${ledControl_value}  console=True
        ELSE
            Log  ${error_message}  level=ERROR
            Fail  ${error_message}
        END

    END

Check RMOD current LEDs state
    [Arguments]  ${when}  ${RMOD_sn}  ${alias}

    ${ledControl_value}=  Get From Dictionary  ${${alias}_${when}_RMOD_sn_ledControl_dict}  ${RMOD_sn}

    IF  '${ledControl_value}'.lower() == 'enabled'
        Check current LED states  OFF  ${RMOD_sn}  ${when} state (ledControl=Enabled, ledControlState=Enabled -> LED OFF)
    ELSE IF  '${ledControl_value}'.lower() == 'disabled'
        Check current LED states  ON  ${RMOD_sn}  ${when} state (ledControl=Disabled, ledControlState=Disabled -> LED ON)
    END

Check current LED states
    [Arguments]  ${LED_state}  ${RMOD_sn}  ${context}

    ${wrong_LED_state}=  Set Variable If  '${LED_state}' == 'OFF'  ON  OFF

    Log  Checking all LEDs are ${LED_state} for RMOD ${RMOD_sn} - ${context}  console=True

    rmod_led_checker.Clear Read Buffer  rmod_label=${RMOD_sn}
    Sleep  3s  reason=Allowing fresh LED samples to accumulate after buffer clear

    ${current_states}=  rmod_led_checker.Get Current LED states  rmod_label=${RMOD_sn}

    IF  '${LED_state}' == 'OFF'
        ${wrong_LED_status}=  Run Keyword And Return Status  Should Contain  ${current_states}  ${1}
    ELSE
        ${wrong_LED_status}=  Run Keyword And Return Status  Should Contain  ${current_states}  ${0}
    END

    IF  ${wrong_LED_status}
        Log  At least one LED is ${wrong_LED_state} for RMOD ${RMOD_sn} during check. Current states: ${current_states}  level=ERROR
        Fail  At least one LED is ${wrong_LED_state} for RMOD ${RMOD_sn} during check. Current states: ${current_states}
    END

    Log  All LEDs are ${LED_state} for RMOD ${RMOD_sn} during ${context} check as expected! Current states: ${current_states}  console=True

Get all RMODs which have LED control feature disabled

    Log  Get all RMODs which have LED control feature disabled  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        ${ledControl_disabled_RMOD_sn_list}=  Create List

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list} or '${RMOD_sn}' not in ${${alias}_BTS_primary_controller_RMOD_sn_list}  CONTINUE

            ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
            ${ledControl_value}  ${ledControlState_value}=  Get ledControl and ledControlState parameters value  RMOD_id=${RMOD_id}  alias=${alias}

            IF  '${ledControl_value}'.lower() == 'enabled'
                Log  BTS ${alias} RMOD ${RMOD_sn} has ledControl already enabled, skipping commissioning plan update for this RMOD.  console=True
            ELSE
                Log Long String  BTS ${alias} RMOD ${RMOD_sn} has ledControl disabled, it will be included in commissioning
                ...  plan update to enable ledControl.
                Append To List  ${ledControl_disabled_RMOD_sn_list}  ${RMOD_sn}
            END

        END

        Set Test Variable  ${${alias}_ledControl_disabled_RMOD_sn_list}  ${ledControl_disabled_RMOD_sn_list}

    END

Create Delta Commissioning Plan
    [Arguments]  ${alias}
    [Documentation]
    ...  Creates a delta commissioning plan with timestamp identifier.

    ${now}=  DateTime.Get Current Date  result_format=%Y_%m_%d_%H_%M_%S
    ${delta_id}=  Set Variable  commissioning_plan_${now}

    Log  Creating Delta Commissioning plan for BTS ${alias}: ${delta_id}  console=True
    coam.Create Delta  delta_id=${delta_id}
    Log  BTS ${alias} Delta plan ${delta_id} created successfully!  console=True

    RETURN  ${delta_id}

Add ledControl parameter updates to Delta
    [Arguments]  ${delta_id}  ${parameter_value}  ${alias}

    Log  Append BTS ${alias} RMOD info to Delta:  console=True
    FOR  ${RMOD_sn}  IN  @{${alias}_ledControl_disabled_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}

        Log  BTS ${alias} RMOD SN ${RMOD_sn}:\n - dist_name: ${RMOD_dn}\n - parameter: ledControl\n - value: ${parameter_value}  console=True
        coam.Append Parameter Update To Delta  dist_name=${RMOD_dn}  parameter=ledControl  value=${parameter_value}  delta_id=${delta_id}

    END

Perform Delta Commissioning
    [Arguments]  ${delta_id}  ${alias}

    Log  Perform BTS ${alias} Delta Recommissioning JSON file ${delta_id}  console=True

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  alias=${alias}  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True

    Log  BTS ${alias} Delta Recommissioning for ${delta_id} performed successfully!  console=True

Check BTS states and alarms after commissioning
    [Arguments]  ${alias}

    Log  Check BTS ${alias} states and alarms after commissioning  console=True
    Log  Check BTS ${alias} state:  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=900
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  900  ${alias}
    Check cells availability status online  ${alias}  900

    Log  Check BTS ${alias} alarms:
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS reset behavior after commissioning
    [Arguments]  ${alias}  ${start_timestamp_UTC}  ${end_timestamp_UTC}

    Log  Check BTS ${alias} reset behavior based on IMS info after commissioning  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  start_point_timestamp_UTC=${start_timestamp_UTC}
    ...  end_point_timestamp_UTC=${end_timestamp_UTC}

Check safe time for RMOD operations
    [Arguments]  ${RMOD_sn}

    ${RMOD_time_power_on}=  Get Variable Value  ${${RMOD_sn}_time_power_on}  ${EMPTY}
    IF  '${RMOD_time_power_on}' == '${EMPTY}'
        RETURN
    END

    Get Current Time  current
    ${time_elapsed}=  DateTime.Subtract Date From Date  ${time_current}  ${RMOD_time_power_on}  number
    ${waiting_time}=  BuiltIn.Evaluate  ${RMOD_RESET_TIME_INTERVAL} - ${time_elapsed}
    IF  ${waiting_time} > 0
        Log Long String  Check safe time interval between RMOD_${RMOD_sn} operations (due to RMOD reset): ${RMOD_RESET_TIME_INTERVAL} sec -> Wait
        ...  ${waiting_time} sec  console=True
        Sleep  ${waiting_time} sec
    END

Get RMOD info from all BTS
    [Arguments]  ${RMOD_sn}

    ${sharing_info}=  Set Variable If  '${RMOD_sn}' in ${shared_RMOD_sn_list}  shared  '${RMOD_sn}' in ${dedicated_RMOD_sn_list}  dedicated
    Set Test Variable  ${${RMOD_sn}_sharing_info}  ${sharing_info}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    END

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}

    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_id}  ${RMOD_id}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${RMOD_id}

    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

Power OFF RMOD
    [Arguments]  ${RMOD_sn}  ${BTS_alias}  ${peer_BTS_alias}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Log  ***** Perform power OFF operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn} *****  console=True

    Get Current Time  power_off
    Pdu BTS Interface Off  RMOD_${RMOD_sn}
    Sleep  10 s  reason=Waiting for PDU port to switch off and RMOD to power off
    Check PDU port status  RMOD_${RMOD_sn}  off

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Log  Check BTS ${alias} state and alarms after power OFF operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn}  console=True

        Log  Check BTS ${alias} ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_off}  ${RMOD_POWER_MAX_WAIT_TIME}
        Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_powered_off_check}  ${RMOD_state_powered_off}  ${remained_MAX_WAIT_TIME}  ${alias}

        Log  Check BTS ${alias} cells status mapped on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn}:  console=True
        Wait Until Keyword Succeeds  60s  10s  Check cells state mapped on RMOD  ${RMOD_sn}  ${alias}

        Log  Check BTS ${alias} alarms:  console=True
        Check alarms after power OFF RMOD  ${alias}

    END

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Power OFF" operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn}  console=True

    ${NR_cell_info_exempted}=  Create Dictionary
    ${LTE_cell_info_exempted}=  Create Dictionary
    ${WCDMA_cell_info_exempted}=  Create Dictionary
    ${GSM_cell_info_exempted}=  Create Dictionary

    IF  '${RMOD_sn}' in ${shared_RMOD_sn_list}
        Check all BTS other cells state mapped on shared RMOD  RMOD_sn=${RMOD_sn}  alias=${BTS_alias}
        ...  peer_BTS_alias=${peer_BTS_alias}
    ELSE IF  '${RMOD_sn}' in ${dedicated_RMOD_sn_list}
        Check all BTS other cells state mapped on dedicated RMOD  RMOD_sn=${RMOD_sn}  alias=${BTS_alias}
    END

Power ON RMOD
    [Arguments]  ${RMOD_sn}

    Start LED Monitoring

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Log  ***** Perform power ON operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn} *****  console=True

    Get Current Time  power_on
    Get Current Date UTC info  power_on
    Set Test Variable  ${${RMOD_sn}_time_power_on}  ${time_power_on}
    Pdu BTS Interface On  RMOD_${RMOD_sn}
    Sleep  10 s  reason=Waiting for PDU port to switch on and RMOD to power on
    Check PDU port status  RMOD_${RMOD_sn}  on

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Log  Check BTS ${alias} state and alarms after power ON operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn}  console=True

        Log  Check BTS ${alias} ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
        Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_powered_on_check}  ${RMOD_state_powered_on}  ${remained_MAX_WAIT_TIME}  ${alias}

    END

    Check RMOD UNIT LED was ON at least one time until RMOD enabled  RMOD_sn=${RMOD_sn}

    Stop LED Monitoring
    Start LED Monitoring

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Log  Check BTS ${alias} cells mapped on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn} status:  console=True
        Check BTS RMOD cell state  ${RMOD_sn}  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
        ...  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  ${CELL_state_enabled_check}
        ...  ${CELL_state_enabled}  ${alias}

        Log  Check BTS ${alias} alarms:  console=True
        Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by "Power ON" operation on ${${RMOD_sn}_sharing_info} RMOD SN ${RMOD_sn}  console=True
    Check BTS cells are enabled online with exceptions   timeout=3
    Log  All BTS other cells status is OK.  console=True

    Check all RMOD ledControl and ledControlState parameters value  when=after power on RMOD
    Check all RMOD LED stable states in interval  when=after power on RMOD

    Stop LED Monitoring

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        IF  '${RMOD_sn}' in ${${alias}_BTS_primary_controller_RMOD_sn_list}
            Check FaultId 4589 on BTS primary controller from IMS  RMOD_sn=${RMOD_sn}  alias=${alias}
        END

    END


Check BTS RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    Assert  class_name=RMOD  id=${${alias}_${RMOD_sn}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} RMOD SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check cells state mapped on RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    IF  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
        ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=
        ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  alias=${alias}
    END

    IF  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
        ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=
        ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}  alias=${alias}
    END

    IF  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
        ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=
        ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  alias=${alias}
    END

    IF  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}
        ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=
        ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  alias=${alias}
    END

Check alarms after power OFF RMOD
    [Arguments]  ${alias}

    ${BTS_IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_4003']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}

    Log  BTS ${alias} "No connection to unit (10)" alarm, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_10']}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_full}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

    Log  BTS ${alias} "No connection to unit (10)" alarm, found number: 1, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  NRCEL  ${RMOD_NR_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  LNCEL  ${RMOD_LTE_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  WNCEL  ${RMOD_WCDMA_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  GNCEL  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}

    Log  BTS ${alias} cells mapped on RMOD SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check RMOD cells are enabled online
    [Arguments]  ${CELL_class_name}  ${RMOD_cell_list}  ${CELL_state_check}  ${alias}  ${timeout}

    FOR  ${item}  IN  @{RMOD_cell_list}

       Assert  class_name=${CELL_class_name}  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
       Wait Until Keyword Succeeds  120s  1s  Check cell is enabled online  ${CELL_class_name}  ${item}  ${CELL_state_enabled_degraded_check}
       ...  ${alias}  1

    END

Check cell is enabled online
    [Arguments]  ${CELL_class_name}  ${CELL_id}  ${CELL_state_check}  ${alias}  ${timeout}

    ${CELL_status_enabled_degraded_check}=  Run Keyword And Return Status  Assert  class_name=${CELL_class_name}  id=${CELL_id}
    ...  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
    Should Be Equal  ${CELL_status_enabled_degraded_check}  ${False}

Check all BTS other cells state mapped on shared RMOD
    [Arguments]  ${RMOD_sn}  ${alias}  ${peer_BTS_alias}

    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}
    ...  ${peer_BTS_alias}=${${peer_BTS_alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}

    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3

    Log  All BTS other cells status is OK.  console=True

Check all BTS other cells state mapped on dedicated RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}

    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3

    Log  All BTS other cells status is OK.  console=True

Check RMOD UNIT LED was ON at least one time until RMOD enabled
    [Arguments]  ${RMOD_sn}

    Log  Check RMOD ${RMOD_sn} UNIT LED was ON at least one time until RMOD enabled  console=True

    ${RMOD_entry}=  Get From Dictionary  ${RMOD_LED_yaml_content}  ${RMOD_sn}
    ${LED_numbers}=  Get From Dictionary  ${RMOD_entry}  LED_NUMBERS
    ${UNIT_LED}=  Get From List  ${LED_numbers}  0
    ${LED_ON_map}=  Create Dictionary  ${UNIT_LED}=${1}

    ${result}  ${sparse_match_dict}=  rmod_led_checker.Check LED States Occurence In Interval  rmod_label=${RMOD_sn}
    ...  expected_value_map=${LED_ON_map}

    IF  not ${result}
        Log  RMOD ${RMOD_sn} UNIT LED: ${UNIT_LED} was NOT ON at least one time until RMOD enabled! Sparse match dict: ${sparse_match_dict}
        ...  level=ERROR
        Fail  RMOD ${RMOD_sn} UNIT LED: ${UNIT_LED} was NOT ON at least one time until RMOD enabled! Sparse match dict: ${sparse_match_dict}
    END

    Log  RMOD ${RMOD_sn} UNIT LED: ${UNIT_LED} was ON at least one time until RMOD enabled as expected!  console=True

Check all RMOD LED stable states in interval
    [Arguments]  ${when}

    Log  *** Check ${when} all RMOD LED stable states in interval ***  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list} or '${RMOD_sn}' not in ${${alias}_BTS_primary_controller_RMOD_sn_list}  CONTINUE

            Ensure that ledControl and ledControlState have the same values  ${when}  ${RMOD_sn}  ${alias}
            Check RMOD LED stable states in interval  ${when}  ${RMOD_sn}  ${alias}

        END

    END

Check RMOD LED stable states in interval
    [Arguments]  ${when}  ${RMOD_sn}  ${alias}

    ${ledControl_value}=  Get From Dictionary  ${${alias}_${when}_RMOD_sn_ledControl_dict}  ${RMOD_sn}

    ${RMOD_entry}=  Get From Dictionary  ${RMOD_LED_yaml_content}  ${RMOD_sn}
    ${LED_numbers}=  Get From Dictionary  ${RMOD_entry}  LED_NUMBERS
    ${LED_OFF_map}=  Create Dictionary
    ${LED_ON_map}=  Create Dictionary

    FOR  ${LED_idx}  IN  @{LED_numbers}
        ${LED_idx}=  Convert To String  ${LED_idx}
        Set To Dictionary  ${LED_OFF_map}  ${LED_idx}=${0}
        Set To Dictionary  ${LED_ON_map}  ${LED_idx}=${1}
    END

    IF  '${ledControl_value}'.lower() == 'enabled'
        Check RMOD LED stable states  OFF  ${RMOD_sn}  ${when} state (ledControl=Enabled, ledControlState=Enabled -> LED OFF)
        ...  ${LED_numbers}  ${LED_OFF_map}
    ELSE IF  '${ledControl_value}'.lower() == 'disabled'
        Check RMOD LED stable states  ON  ${RMOD_sn}  ${when} state (ledControl=Disabled, ledControlState=Disabled -> LED ON)
        ...  ${LED_numbers}  ${LED_ON_map}
    END

Check RMOD LED stable states
    [Arguments]  ${LED_state}  ${RMOD_sn}  ${context}  ${LED_numbers}  ${expected_LED_state_map}

    Log  Checking all LEDs (${LED_numbers}) are ${LED_state} for RMOD ${RMOD_sn} - ${context}  console=True

    ${result}  ${unexpected_states}=  rmod_led_checker.Check LED Stable States In Interval  rmod_label=${RMOD_sn}
    ...  expected_value_map=${expected_LED_state_map}

    IF  not ${result}
        Log  Unexpected LED states detected for RMOD ${RMOD_sn} during check: ${unexpected_states}  level=ERROR
        Fail  RMOD ${RMOD_sn}: LEDs NOT all ${LED_state} as expected (${context}). Unexpected states: ${unexpected_states}
    END

    Log  RMOD ${RMOD_sn}: All LEDs confirmed ${LED_state} (${context})  console=True

Check FaultId 4589 on BTS primary controller from IMS
    [Arguments]  ${RMOD_sn}  ${alias}

    Log  Check BTS ${alias} alarms from IMS  console=True

    Log Long String  Check that "Unit power reset (4589)" alarm was raised on BTS ${alias} primary controller after
    ...  power ON operation on ${RMOD_sn} RMOD, based on IMS info.

    Get And Check Detailed IMS2 Alarms SOAM  alias=${alias}  start_timestamp=${date_timestamp_power_on_UTC}
    ...  expected_alarms=${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_4589']}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}

    Log  "Unit power reset (4589)" alarm was raised on BTS ${alias} primary controller after power ON operation on ${RMOD_sn} RMOD, as expected!

Recover initial ledControl parameter value

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        Sort List  ${BTS_RMOD_sn_list}

        FOR  ${RMOD_sn}  IN  @{BTS_RMOD_sn_list}

            IF  '${RMOD_sn}' not in ${RMOD_all_sn_list} or '${RMOD_sn}' not in ${${alias}_BTS_primary_controller_RMOD_sn_list}  CONTINUE

            ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
            ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
            ${initial_ledControl_value}=  Get From Dictionary  ${${alias}_initial_RMOD_sn_ledControl_dict}  ${RMOD_sn}
            ${final_ledControl_value}  ${final_ledControlState_value}=  Get ledControl and ledControlState parameters value
            ...  RMOD_id=${RMOD_id}  alias=${alias}

            IF  '${initial_ledControl_value}'.lower() == '${final_ledControl_value}'.lower()  CONTINUE

            Log Long String  Recovering initial ledControl parameter value for BTS ${alias} RMOD SN ${RMOD_sn}:
            ...  ledControl=${initial_ledControl_value}  console=True
            coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=ledControl  operation=update  value=${initial_ledControl_value}
            ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}
            Sleep  3s

        END

    END

Check if all PDU port status is on

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        Check if PDU port status is on  RMOD_${RMOD_sn}  120

    END

Particular Teardown
    Stop LED monitoring
    Check if all PDU port status is on
    Recover initial ledControl parameter value

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown