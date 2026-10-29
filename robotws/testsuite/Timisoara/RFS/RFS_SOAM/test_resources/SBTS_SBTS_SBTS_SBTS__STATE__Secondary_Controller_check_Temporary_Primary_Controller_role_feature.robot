*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature
Variables    tc_variables/sbts_sbts_sbts_sbts__state__check_temporary_primary_controller_role_feature_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                    3    # Number of cycles to check temporary primary controller role feature on BTS secondary controller,
                                          # default value 3
${tempFhsPrimControllerTriggerTime}  2    # Temporary FHS primary controller trigger time, default value 2 (minutes)
${tempRadioMasterTriggerTime}        2    # Temporary radio master trigger time, default value 2 (minutes)
${tempRadioMasterRecovTime}          0    # Temporary radio master recovery time, default value 0 (minutes)
${BTS_MAX_WAIT_TIME}                 900  # Maximum time to wait for BTS OnAir after power on (by default 900)

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_check_Temporary_Primary_Controller_role_feature
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29083
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for check temporary primary controller role feature on BTS secondary controller, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and set if needed BTS secondary controller temporary role feature settings:
    ...    - temporary primary controller role for shared FHS
    ...    - temporary radio master role for shared RMOD
    ...  - perform BTS primary controller power off/on checking BTS secondary controller behavior related to temporary role feature for shared
    ...  FHS/RMOD
    ...  - check reset behavior on all BTS based on IMS info as follows:
    ...    - BTS primary controller powered off/on: reset number is 1
    ...    - BTS secondary controller not powered off/on: reset number is 0
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: BTS temporary primary controller role feature works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29083 - Generic test for TRM Power off ON Common Startup Tests
    ...  - 22.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29590 - [5G] Common_startup_check_TRM_feature failure with allowed alarm 7509

    Set Tags    CA-STATE    OWNER-catalin.chiorean@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R3

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Check BTS primary controller PDU definition and reachability
    Step 5: Check Temporary Primary Controller role feature settings on BTS secondary controller
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Check Temporary Primary Controller role feature behavior on BTS secondary controller
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
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
        Get and Check ALD state info  alias=${alias}

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info
    [Documentation]
    ...  Keyword used to get all BTS info related to FHS, RMOD, cells, controller role, DSS feature

    Log  Step ${index}: Get all BTS info  console=True

    ${BTS_alias_FHS_sn_dict}  ${FHS_sn_BTS_alias_dict}  ${shared_FHS_sn_list}  ${dedicated_FHS_sn_list}=  Get all BTS FHS sharing info
    Set Test Variable  ${BTS_alias_FHS_sn_dict}
    Set Test Variable  ${FHS_sn_BTS_alias_dict}
    Set Test Variable  ${shared_FHS_sn_list}
    Set Test Variable  ${dedicated_FHS_sn_list}

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${all_BTS_controller_role_FHS_sn_dict}=  Get all BTS controller role for configured FHS from SCF
    Set Test Variable  ${all_BTS_controller_role_FHS_sn_dict}

    ${all_BTS_controller_role_RMOD_sn_dict}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_dict}

    ${BTS_primary_controller_shared_FHS_list}  ${BTS_secondary_controller_shared_FHS_list}  ${BTS_primary_controller_shared_RMOD_list}
    ...  ${BTS_secondary_controller_shared_RMOD_list}=  Get all BTS controller role for shared modules
    Set Test Variable  ${BTS_primary_controller_shared_FHS_list}
    Set Test Variable  ${BTS_secondary_controller_shared_FHS_list}
    Set Test Variable  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${BTS_secondary_controller_shared_RMOD_list}

    ${BTS_primary_controller_list}=  Combine Lists  ${BTS_primary_controller_shared_FHS_list}  ${BTS_primary_controller_shared_RMOD_list}
    ${BTS_primary_controller_list}=  Remove Duplicates  ${BTS_primary_controller_list}
    ${BTS_secondary_controller_list}=  Combine Lists  ${BTS_secondary_controller_shared_FHS_list}  ${BTS_secondary_controller_shared_RMOD_list}
    ${BTS_secondary_controller_list}=  Remove Duplicates  ${BTS_secondary_controller_list}
    Set Test Variable  ${BTS_primary_controller_list}
    Set Test Variable  ${BTS_secondary_controller_list}

    Get all BTS RAT cell list
    Get all BTS FHS sn id pn info
    Get all BTS RMOD sn id pn interface info

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    ${NR_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm alarm
    ${LTE_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm

    Set Test Variable  ${NR_DSS_alarms_info}
    Set Test Variable  ${LTE_DSS_alarms_info}

    Set Test Variable  ${FHS_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${FHS_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_degraded}  operationalState=Enabled, availabilityStatus=Degraded, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked

Step ${index}: Check BTS primary controller PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if BTS primary controller SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check BTS primary controller PDU definition and reachability  console=True

    FOR  ${alias}  IN  @{BTS_primary_controller_list}

        ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
        Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}

        ${status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
        Run Keyword If  ${status}
        ...  Log  BTS primary controller ${alias} SMs PDU port status as expected  console=True
        ...  ELSE  Run Keywords
        ...  Log  PDU for BTS primary controller ${alias} SMs is either not reachable or not switched on!  level=ERROR
        ...  AND  Fail  PDU for BTS primary controller ${alias} SMs is either not reachable or not switched on!

    END

Step ${index}: Check Temporary Primary Controller role feature settings on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check Temporary Primary Controller role feature settings on BTS secondary controller and set them accordingly
    ...  if needed

    Log  Step ${index}: Check Temporary Primary Controller role feature settings on BTS secondary controller  console=True

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_FHS_list}

        Check Temporary Primary Controller role feature settings for shared FHS  ${alias}

    END

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        Check Temporary Primary Controller role feature settings for shared RMOD  ${alias}

    END

Step ${index}: Check Temporary Primary Controller role feature behavior on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check Temporary Primary Controller role feature behavior on BTS secondary controller

    Log  Step ${index}: Check Temporary Primary Controller role feature behavior on BTS secondary controller  console=True

    FOR  ${alias}  IN  @{BTS_primary_controller_list}

        Get impacted BTS secondary controller info  ${alias}

        Perform BTS primary controller power off  ${alias}

        Check Temporary Primary Controller role feature behavior on BTS secondary controller  ${alias}

        Perform BTS primary controller power on  ${alias}

        Check all BTS reset behavior based on IMS info  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get all BTS controller role for shared modules

    ${BTS_primary_controller_shared_FHS_list}=  Create List
    ${BTS_secondary_controller_shared_FHS_list}=  Create List
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    ${BTS_secondary_controller_shared_RMOD_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_role_FHS_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_FHS_sn_dict}  ${alias}
        ${BTS_primary_controller_FHS_sn_list}=  Get From Dictionary  ${BTS_controller_role_FHS_sn_dict}  BTS_primary_controller_FHS_sn_list
        ${BTS_secondary_controller_FHS_sn_list}=  Get From Dictionary  ${BTS_controller_role_FHS_sn_dict}  BTS_secondary_controller_FHS_sn_list
        ${BTS_primary_controller_shared_FHS_sn_list}=  Get BTS info for shared modules  ${BTS_primary_controller_FHS_sn_list}  FHS
        ${BTS_primary_controller_shared_FHS_sn_count}=  Get Length  ${BTS_primary_controller_shared_FHS_sn_list}
        Run Keyword If  ${BTS_primary_controller_shared_FHS_sn_count} > 0  Append To List  ${BTS_primary_controller_shared_FHS_list}  ${alias}
        ${BTS_secondary_controller_shared_FHS_sn_list}=  Get BTS info for shared modules  ${BTS_secondary_controller_FHS_sn_list}  FHS
        ${BTS_secondary_controller_shared_FHS_sn_count}=  Get Length  ${BTS_secondary_controller_shared_FHS_sn_list}
        Run Keyword If  ${BTS_secondary_controller_shared_FHS_sn_count} > 0  Append To List  ${BTS_secondary_controller_shared_FHS_list}  ${alias}

        ${BTS_controller_role_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_primary_controller_shared_RMOD_sn_list}=  Get BTS info for shared modules  ${BTS_primary_controller_RMOD_sn_list}  RMOD
        ${BTS_primary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_primary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${alias}
        ${BTS_secondary_controller_shared_RMOD_sn_list}=  Get BTS info for shared modules  ${BTS_secondary_controller_RMOD_sn_list}  RMOD
        ${BTS_secondary_controller_shared_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_shared_RMOD_sn_list}
        Run Keyword If  ${BTS_secondary_controller_shared_RMOD_sn_count} > 0  Append To List  ${BTS_secondary_controller_shared_RMOD_list}  ${alias}

        Set Test Variable  ${${alias}_secondary_controller_shared_FHS_sn_count}  ${BTS_secondary_controller_shared_FHS_sn_count}
        Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_sn_count}  ${BTS_secondary_controller_shared_RMOD_sn_count}

    END

    [Return]  ${BTS_primary_controller_shared_FHS_list}  ${BTS_secondary_controller_shared_FHS_list}  ${BTS_primary_controller_shared_RMOD_list}
    ...  ${BTS_secondary_controller_shared_RMOD_list}

Get BTS info for shared modules
    [Arguments]  ${MOD_sn_list}  ${MOD_class}

    ${shared_MOD_sn_list}=  Create List

    FOR  ${MOD_sn}  IN  @{MOD_sn_list}

        Run Keyword If  '${MOD_sn}' in ${shared_${MOD_class}_sn_list}  Append To List  ${shared_MOD_sn_list}  ${MOD_sn}

    END

    [Return]  ${shared_MOD_sn_list}

Get all BTS RAT cell list

    FOR  ${alias}  IN  @{alias_list}

       Get BTS CELL list by RAT  ${alias}

    END

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_cell_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_cell_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_cell_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_cell_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${BTS_cell_id_list}=  Combine Lists   ${NR_cell_id_list}  ${LTE_cell_id_list}  ${WCDMA_cell_id_list}  ${GSM_cell_id_list}

    Set Test Variable  ${${alias}_NR_cell_id_list}  ${NR_cell_id_list}
    Set Test Variable  ${${alias}_LTE_cell_id_list}  ${LTE_cell_id_list}
    Set Test Variable  ${${alias}_WCDMA_cell_id_list}  ${WCDMA_cell_id_list}
    Set Test Variable  ${${alias}_GSM_cell_id_list}  ${GSM_cell_id_list}
    Set Test Variable  ${${alias}_BTS_cell_id_list}  ${BTS_cell_id_list}

Get all BTS FHS sn id pn info

    FOR  ${alias}  IN  @{alias_list}

       ${BTS_FHS_sn_id_dict}  ${BTS_FHS_id_sn_dict}  ${BTS_FHS_sn_pn_dict}=  Admin Get FHS sn id pn info
       ...  ${alias}
       Set Test Variable  ${${alias}_FHS_sn_id_dict}  ${BTS_FHS_sn_id_dict}

    END

Get all BTS RMOD sn id pn interface info

    FOR  ${alias}  IN  @{alias_list}

       ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
       ...  ${alias}
       Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${BTS_RMOD_sn_id_dict}

    END

Check Temporary Primary Controller role feature settings for shared FHS
    [Arguments]  ${alias}

    Log  Check Temporary Primary Controller role feature settings for shared FHS on BTS ${alias} and set them accordingly if needed  console=True

    ${BTS_TFM_feature_dict_initial}=  Get BTS TFM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_TFM_feature_dict_initial}  ${BTS_TFM_feature_dict_initial}
    Set BTS TFM feature parameter  actTempFhsPrimController  true  ${alias}
    Set BTS TFM feature parameter  tempFhsPrimControllerTriggerTime  ${tempFhsPrimControllerTriggerTime}  ${alias}

    Log Long String  Test will be performed with Temporary Primary Controller role feature settings for shared FHS on BTS ${alias}:
    ...  actTempFhsPrimController: true, tempFhsPrimControllerTriggerTime: ${tempFhsPrimControllerTriggerTime}  console=True

Check Temporary Primary Controller role feature settings for shared RMOD
    [Arguments]  ${alias}

    Log  Check Temporary Primary Controller role feature settings for shared RMOD on BTS ${alias} and set them accordingly if needed  console=True

    ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_TRM_feature_dict_initial}  ${BTS_TRM_feature_dict_initial}
    Set classical BTS TRM feature parameter  actTempRadioMaster  true  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime}  ${alias}

    Log Long String  Test will be performed with Temporary Primary Controller role feature settings for shared RMOD on BTS ${alias}:
    ...  actTempRadioMaster: true, tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}
    ...  console=True

Get impacted BTS secondary controller info
    [Arguments]  ${alias}

    ${BTS_controller_role_FHS_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_FHS_sn_dict}  ${alias}
    ${BTS_primary_controller_FHS_sn_list}=  Get From Dictionary  ${BTS_controller_role_FHS_sn_dict}  BTS_primary_controller_FHS_sn_list
    Get BTS secondary controller info  ${BTS_primary_controller_FHS_sn_list}  FHS

    ${BTS_controller_role_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_dict}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_RMOD_sn_dict}  BTS_primary_controller_RMOD_sn_list
    Get BTS secondary controller info  ${BTS_primary_controller_RMOD_sn_list}  RMOD

Get BTS secondary controller info
    [Arguments]  ${MOD_sn_list}  ${MOD_class}

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_${MOD_class}_list}

        ${BTS_MOD_list}=  Create List
        Set Test Variable  ${${alias}_secondary_controller_shared_${MOD_class}_sn_list}  ${BTS_MOD_list}

    END

    FOR  ${MOD_sn}  IN  @{MOD_sn_list}

        Get BTS secondary controller info for shared module  ${MOD_sn}  ${MOD_class}

    END

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_${MOD_class}_list}

        ${BTS_secondary_controller_shared_MOD_sn_count}=  Get Length  ${${alias}_secondary_controller_shared_${MOD_class}_sn_list}
        Set Test Variable  ${${alias}_secondary_controller_shared_${MOD_class}_sn_count}  ${BTS_secondary_controller_shared_MOD_sn_count}

    END

Get BTS secondary controller info for shared module
    [Arguments]  ${MOD_sn}  ${MOD_class}

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_${MOD_class}_list}

        ${BTS_controller_role_MOD_sn_dict}=  Get From Dictionary  ${all_BTS_controller_role_${MOD_class}_sn_dict}  ${alias}
        ${BTS_secondary_controller_MOD_sn_list}=  Get From Dictionary  ${BTS_controller_role_MOD_sn_dict}
        ...  BTS_secondary_controller_${MOD_class}_sn_list

        Run Keyword If  '${MOD_sn}' in ${BTS_secondary_controller_MOD_sn_list}
        ...  Append To List  ${${alias}_secondary_controller_shared_${MOD_class}_sn_list}  ${MOD_sn}

    END

Perform BTS primary controller power off
    [Arguments]  ${alias}

    Log  ***** Perform BTS ${alias} power off *****  console=True

    Get Current Date UTC info  power_off
    Log  BTS ${alias} power off UTC timestamp: ${date_timestamp_power_off_UTC}  console=True

    ${status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  off
    Run Keyword If  ${status}
    ...  Log  BTS ${alias} SMs PDU port status off, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS ${alias} SMs PDU port status off failed!  level=ERROR
    ...  AND  Fail  Set BTS ${alias} SMs PDU port status off failed!
    Get Current Time  initial

    Sleep  1 min  Wait for trigger PL switch if needed

Check Temporary Primary Controller role feature behavior on BTS secondary controller
    [Arguments]  ${alias}

    Get Current Date UTC info  start_alarm_check

    FOR  ${peer_alias}  IN  @{alias_list}

        Continue For Loop If  '${peer_alias}' == '${alias}'

        Log  ***** Check BTS ${peer_alias} states and alarms *****  console=True

        Check peer BTS FHSs state in stable phase  ${peer_alias}
        Check peer BTS RMODs state in stable phase  ${peer_alias}
        Check peer BTS cells state in stable phase  ${peer_alias}
        Count peer BTS expected alarms related to DSS feature info  ${alias}  ${peer_alias}
        Prepare peer BTS stable alarm list for check  ${peer_alias}
        Check peer BTS alarms in stable phase  ${peer_alias}

    END

Perform BTS primary controller power on
    [Arguments]  ${alias}

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Log  ***** Perform BTS ${alias} power on *****  console=True
    Get Current Date UTC info  power_on
    Log  BTS ${alias} power on UTC timestamp: ${date_timestamp_power_on_UTC}  console=True

    ${status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
    Run Keyword If  ${status}
    ...  Log  BTS ${alias} SMs PDU port status on, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS ${alias} SMs PDU port status on failed!  level=ERROR
    ...  AND  Fail  Set BTS ${alias} SMs PDU port status on failed!

    Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    Sleep  120 sec  Wait for Admin starting

    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}

    Log  Check BTS ${alias} cells after BTS ${alias} powered on:  console=True
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  BTS ${alias} all cells status:\n - operationalState=Enabled  console=True

    Log  Check BTS ${alias} alarms after BTS ${alias} powered on:  console=True
    Get and Check Alarms SOAM  alias=${alias}  wait_for_alarm_clear= 15min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    FOR  ${peer_alias}  IN  @{alias_list}

        Continue For Loop If  '${peer_alias}' == '${alias}'

        Set Test Variable  ${${peer_alias}_FID4001_reset}  ${FALSE}

        Assert Alarm Inactive  parameters=faultId=4220  timeout=300  connection=${alias}
        Check fault 4001 on BTS  alias=${peer_alias}

        Log  Check BTS ${peer_alias} cells after BTS ${alias} powered on:  console=True
        Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${peer_alias} all cells status:\n - operationalState=Enabled  console=True

        Log  Check BTS ${peer_alias} alarms after BTS ${alias} powered on:  console=True
        Get and Check Alarms SOAM  alias=${peer_alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
        ...   ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    END

Count peer BTS expected alarms related to DSS feature info
    [Arguments]  ${alias}  ${peer_alias}

    ${BTS_alias_NR_DSS_alarms_dict}=  Create Dictionary
    ${BTS_alias_LTE_DSS_alarms_dict}=  Create Dictionary
    ${LTE_DSS_alarms_count}=  Set Variable  0
    ${NR_DSS_alarms_count}=  Set Variable  0

    FOR  ${cell_id}  IN  @{${alias}_NR_cell_id_list}

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  NR  ${alias}

        ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        Continue For Loop If  not ${cond}

        ${DSS_peer_cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=LNCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${DSS_peer_alias}

        ${LTE_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Evaluate  ${LTE_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${LTE_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Set To Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${DSS_peer_alias}=${LTE_DSS_alarms_count}

    END

    FOR  ${cell_id}  IN  @{${alias}_LTE_cell_id_list}

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  LTE  ${alias}

        ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' not in ['${alias}', 'None']
        Continue For Loop If  not ${cond}

        ${DSS_peer_cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=NRCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${DSS_peer_alias}

        ${NR_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Evaluate  ${NR_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${NR_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Set To Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${DSS_peer_alias}=${NR_DSS_alarms_count}

    END

    FOR  ${cell_id}  IN  @{${peer_alias}_NR_cell_id_list}

        ${cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=NRCEL  id=${cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${peer_alias}
        Continue For Loop If  '${cell_status}' == 'True'

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  NR  ${peer_alias}

        ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' == '${peer_alias}'
        Continue For Loop If  not ${cond}

        ${DSS_peer_cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=LNCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${DSS_peer_alias}

        ${LTE_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Evaluate  ${LTE_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${LTE_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Set To Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${DSS_peer_alias}=${LTE_DSS_alarms_count}

    END

    FOR  ${cell_id}  IN  @{${peer_alias}_LTE_cell_id_list}

        ${cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=LNCEL  id=${cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${peer_alias}
        Continue For Loop If  '${cell_status}' == 'True'

        ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}=  Get DSS feature impact  ${cell_id}  LTE  ${peer_alias}

        ${cond}=  Set Variable  '${DSS_peer_cell_id}' != 'None' and '${DSS_peer_alias}' == '${peer_alias}'
        Continue For Loop If  not ${cond}

        ${DSS_peer_cell_status}=  Run Keyword And Return Status
        ...  Assert  class_name=NRCEL  id=${DSS_peer_cell_id}  parameters=operationalState=${Enabled_}  timeout=3  connection=${DSS_peer_alias}

        ${NR_DSS_alarms_count}=  Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Evaluate  ${NR_DSS_alarms_count} + 1
        ...  ELSE
        ...  Set Variable  ${NR_DSS_alarms_count}

        Run Keyword If  '${DSS_peer_cell_status}' == 'True'
        ...  Set To Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${DSS_peer_alias}=${NR_DSS_alarms_count}

    END

    Set Test Variable  ${BTS_alias_NR_DSS_alarms_dict}
    Set Test Variable  ${BTS_alias_LTE_DSS_alarms_dict}

Get DSS feature impact
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${DSS_peer_rat}=  Set Variable If  '${rat}' == 'NR'  LTE  NR

    ${actLteNrDss}=  Run Keyword If  '${rat}' == 'NR'
    ...  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ...  ELSE IF  '${rat}' == 'LTE'
    ...  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    Return From Keyword If  '${actLteNrDss}' == 'False'  None  ${DSS_peer_rat}  None

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_dict}  ${alias}
    ${DSS_NR_LTE_dict_keys}=  Get Dictionary Keys  ${DSS_NR_LTE_CELL_dict}
    ${DSS_LTE_NR_dict_keys}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_dict}

    ${DSS_peer_cell_id}=  Run Keyword If  '${rat}' == 'NR' and '${cell_id}' in ${DSS_NR_LTE_dict_keys}
    ...  Get From Dictionary  ${DSS_NR_LTE_CELL_dict}  ${cell_id}
    ...  ELSE IF  '${rat}' == 'LTE' and '${cell_id}' in ${DSS_LTE_NR_dict_keys}
    ...  Get From Dictionary  ${DSS_LTE_NR_CELL_dict}  ${cell_id}
    ...  ELSE
    ...  Set Variable  None

    Return From Keyword If  '${DSS_peer_cell_id}' == 'None'  None  ${DSS_peer_rat}  None

    ${DSS_peer_alias_list}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    ${DSS_peer_alias}=  Get DSS peer BTS  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    [Return]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias}

Get DSS peer BTS
    [Arguments]  ${DSS_peer_cell_id}  ${DSS_peer_rat}  ${DSS_peer_alias_list}

    ${DSS_peer_alias}=  Set Variable  None

    FOR  ${alias}  IN  @{DSS_peer_alias_list}

        ${DSS_peer_alias}=  Set Variable If  '${DSS_peer_cell_id}' in ${${alias}_${DSS_peer_rat}_cell_id_list}  ${alias}
        Exit For Loop If  '${DSS_peer_alias}' != 'None'

    END

    [Return]  ${DSS_peer_alias}

Prepare peer BTS stable alarm list for check
    [Arguments]  ${alias}

    ${NR_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_NR_DSS_alarms_dict}  ${alias}
    ${LTE_DSS_alarms}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_LTE_DSS_alarms_dict}  ${alias}
    ${NR_DSS_alarms_count}=  Run Keyword If  ${NR_DSS_alarms}
    ...  Get From Dictionary  ${BTS_alias_NR_DSS_alarms_dict}  ${alias}
    ...  ELSE
    ...  Set Variable  0
    ${LTE_DSS_alarms_count}=  Run Keyword If  ${LTE_DSS_alarms}
    ...  Get From Dictionary  ${BTS_alias_LTE_DSS_alarms_dict}  ${alias}
    ...  ELSE
    ...  Set Variable  0
    ${NR_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${${alias.upper()}_ALARMS_NR_DSS}  ${NR_DSS_alarms_count}
    ${LTE_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${${alias.upper()}_ALARMS_LTE_DSS}  ${LTE_DSS_alarms_count}

    ${BTS_EXPECTED_ALARMS_IMS_stable_list}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4661_IMS}
    ...  ${${alias}_secondary_controller_shared_FHS_sn_count}

    ${BTS_EXPECTED_ALARMS_4220}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4220}
    ...  ${${alias}_secondary_controller_shared_RMOD_sn_count}

    ${BTS_EXPECTED_ALARMS_stable_list}=  Combine Lists  ${NR_DSS_EXPECTED_ALARMS_full}  ${LTE_DSS_EXPECTED_ALARMS_full}  ${BTS_EXPECTED_ALARMS_4220}
    ${BTS_IGNORED_ALARMS_stable_list}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_STABLE_BTS_POWERED_OFF}

    Set Test Variable  ${${alias.upper()}_NR_DSS_alarms_count}  ${NR_DSS_alarms_count}
    Set Test Variable  ${${alias.upper()}_LTE_DSS_alarms_count}  ${LTE_DSS_alarms_count}
    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_IMS_stable_list}  ${BTS_EXPECTED_ALARMS_IMS_stable_list}
    Set Test Variable  ${${alias.upper()}_EXPECTED_ALARMS_stable_list}  ${BTS_EXPECTED_ALARMS_stable_list}
    Set Test Variable  ${${alias.upper()}_IGNORED_ALARMS_stable_list}  ${BTS_IGNORED_ALARMS_stable_list}

Check peer BTS alarms in stable phase
    [Arguments]  ${alias}

    Log  Check BTS ${alias} alarms in stable phase:  console=True

    Run Keyword If  ${${alias.upper()}_NR_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${NR_DSS_alarms_info}, expected number: ${${alias.upper()}_NR_DSS_alarms_count}  console=True
    Run Keyword If  ${${alias.upper()}_LTE_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${LTE_DSS_alarms_info}, expected number: ${${alias.upper()}_LTE_DSS_alarms_count}  console=True
    Run Keyword If  ${${alias}_secondary_controller_shared_RMOD_sn_count} > 0
    ...  Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${alias}_secondary_controller_shared_RMOD_sn_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  time=15min  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_stable_list}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS_stable_list}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${alias.upper()}_NR_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${NR_DSS_alarms_info}, found number: ${${alias.upper()}_NR_DSS_alarms_count}, as expected!  console=True
    Run Keyword If  ${${alias.upper()}_LTE_DSS_alarms_count} > 0
    ...  Log  BTS ${alias} ${LTE_DSS_alarms_info}, found number: ${${alias.upper()}_LTE_DSS_alarms_count}, as expected!  console=True
    Run Keyword If  ${${alias}_secondary_controller_shared_RMOD_sn_count} > 0
    ...  Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${alias}_secondary_controller_shared_RMOD_sn_count}, as expected!  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Return From Keyword If  ${${alias}_secondary_controller_shared_FHS_sn_count} == 0

    Log  Check BTS ${alias} IMS alarms in stable phase:  console=True
    Log Long String  BTS ${alias} IMS "FHS secondary controller has taken temporary FHS primary controller role (4661)" alarm, expected number:
    ...  ${${alias}_secondary_controller_shared_FHS_sn_count}  console=True

    Get and check detailed IMS2 Alarms SOAM  alias=${alias}  start_timestamp=${date_timestamp_start_alarm_check_UTC}
    ...  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_IMS_stable_list}

    Log Long String  BTS ${alias} IMS "FHS secondary controller has taken temporary FHS primary controller role (4661)" alarm, found number:
    ...  ${${alias}_secondary_controller_shared_FHS_sn_count}, as expected!  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS FHSs state in stable phase
    [Arguments]  ${alias}

    ${alias_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_FHS_sn_dict}  ${alias}
    Return From Keyword If  not ${alias_status}

    ${BTS_FHS_sn_list}=  Get From Dictionary  ${BTS_alias_FHS_sn_dict}  ${alias}

    Run Keyword If  ${BTS_FHS_sn_list}  Run Keywords
    ...  Log  Check BTS ${alias} FHS status in stable phase:  console=True
    ...  AND  Check BTS FHSs state  FHS_sn_list=${BTS_FHS_sn_list}  FHS_state_check=${FHS_state_enabled_check}  FHS_state=${FHS_state_enabled}
    ...  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}

Check peer BTS RMODs state in stable phase
    [Arguments]  ${alias}

    ${alias_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${BTS_alias_RMOD_sn_dict}  ${alias}
    Return From Keyword If  not ${alias_status}

    ${BTS_RMOD_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}

    ${BTS_secondary_controller_shared_RMOD_sn_list}=  Get Variable Value  ${${alias}_secondary_controller_shared_RMOD_sn_list}  @{EMPTY}
    FOR  ${item}  IN  @{BTS_secondary_controller_shared_RMOD_sn_list}
        Remove Values From List  ${BTS_RMOD_sn_list}  ${item}
    END

    Run Keyword If  ${BTS_RMOD_sn_list}  Run Keywords
    ...  Log  Check BTS ${alias} RMOD status in stable phase:   console=True
    ...  AND  Check BTS RMODs state  RMOD_sn_list=${BTS_RMOD_sn_list}
    ...  RMOD_state_check=${RMOD_state_enabled_check}  RMOD_state=${RMOD_state_enabled}  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}

    Run Keyword If  ${BTS_secondary_controller_shared_RMOD_sn_list}  Run Keywords
    ...  Log  Check BTS ${alias} (as secondary controller) RMOD status in stable phase:   console=True
    ...  AND  Check BTS RMODs state  RMOD_sn_list=${BTS_secondary_controller_shared_RMOD_sn_list}
    ...  RMOD_state_check=${RMOD_state_enabled_degraded_check}  RMOD_state=${RMOD_state_enabled_degraded}  timeout=${BTS_MAX_WAIT_TIME}
    ...  alias=${alias}

    Sleep  2 min  Wait for cells stable phase

Check peer BTS cells state in stable phase
    [Arguments]  ${alias}

    Run Keyword If  ${${alias}_NR_cell_id_list}  Run Keywords
    ...  Log  Check BTS ${alias} NR cells status in stable phase:   console=True
    ...  AND  Wait Until Keyword Succeeds  900 sec  10 sec  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_cell_id_list}
    ...  alias=${alias}

    Run Keyword If  ${${alias}_LTE_cell_id_list}  Run Keywords
    ...  Log  Check BTS ${alias} LTE cells status in stable phase:   console=True
    ...  AND  Wait Until Keyword Succeeds  60 sec  10 sec  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_cell_id_list}
    ...  alias=${alias}

    Run Keyword If  ${${alias}_WCDMA_cell_id_list}  Run Keywords
    ...  Log  Check BTS ${alias} WCDMA cells status in stable phase:   console=True
    ...  AND  Wait Until Keyword Succeeds  60 sec  10 sec  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_cell_id_list}
    ...  alias=${alias}

    Run Keyword If  ${${alias}_GSM_cell_id_list}  Run Keywords
    ...  Log  Check BTS ${alias} GSM cells status in stable phase:   console=True
    ...  AND  Wait Until Keyword Succeeds  60 sec  10 sec  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_cell_id_list}
    ...  alias=${alias}

Check BTS FHSs state
    [Arguments]  ${FHS_sn_list}  ${FHS_state_check}  ${FHS_state}  ${timeout}  ${alias}

    FOR  ${FHS_sn}  IN  @{FHS_sn_list}

        ${FHS_id}=  Get From Dictionary  ${${alias}_FHS_sn_id_dict}  ${FHS_sn}
        Assert  class_name=FHS  id=${FHS_id}  parameters=${FHS_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} FHS_${FHS_sn} status:\n - ${FHS_state}  console=True

    END

Check BTS RMODs state
    [Arguments]  ${RMOD_sn_list}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} RMOD_${RMOD_sn} status:\n - ${RMOD_state}  console=True

    END

Check fault 4001 on BTS
    [Arguments]  ${alias}

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    ${FID4001_active}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4001  timeout=600  connection=${alias}
    Return From Keyword If  '${FID4001_active}' == 'False'

    ${FID4001_autonomous_reset}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4001, alarmId=7101  connection=${alias}
    Run Keyword If  ${FID4001_autonomous_reset}  Run Keywords
    ...  Log  BTS ${alias} site autonomous reset as recovery action  console=True
    ...  AND  Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    ...  AND  Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    ...  AND  Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
    ...  AND  Sleep  60s  Wait for Admin starting
    ...  AND  Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    ...  AND  Return From Keyword

    Log  BTS ${alias} reset is needed to activate features requiring network level synchronization accuracy  console=True
    coam.Reset Site  connection=${alias}
    Set Test Variable  ${${alias}_FID4001_reset}  ${TRUE}
    Sleep  60s  Wait for Admin starting
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS powered off/on: reset number is 1
    ...  - BTS not powered off/on: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get Current Date UTC info  end

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_power_off_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    FOR  ${peer_alias}  IN  @{alias_list}

        Continue For Loop If  '${peer_alias}' == '${alias}'

        ${peer_BTS_expected_reset_number}=  Set Variable If  ${${peer_alias}_FID4001_reset}  1  0

        Get and check BTS RESET info from IMS file  expected_reset_number=${peer_BTS_expected_reset_number}  alias=${peer_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_power_off_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    END

Recover Temporary Primary Controller role feature initial settings for shared FHS
    [Documentation]
    ...  Keyword used to recover Temporary Primary Controller role feature initial settings for shared FHS

    [Arguments]  ${alias}
    Log  Recover Temporary Primary Controller role feature initial settings for shared FHS on BTS ${alias}  console=True
    ${actTempFhsPrimController_initial}=  Get From Dictionary  ${${alias}_TFM_feature_dict_initial}  actTempFhsPrimController
    ${tempFhsPrimControllerTriggerTime_initial}=  Get From Dictionary  ${${alias}_TFM_feature_dict_initial}  tempFhsPrimControllerTriggerTime
    Set BTS TFM feature parameter  actTempFhsPrimController  ${actTempFhsPrimController_initial}  ${alias}
    Set BTS TFM feature parameter  tempFhsPrimControllerTriggerTime  ${tempFhsPrimControllerTriggerTime_initial}  ${alias}

Recover Temporary Primary Controller role feature initial settings for shared RMOD
    [Documentation]
    ...  Keyword used to recover Temporary Primary Controller role feature initial settings for shared RMOD

    [Arguments]  ${alias}
    Log  Recover Temporary Primary Controller role feature initial settings for shared RMOD on BTS ${alias}  console=True
    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    ${tempRadioMasterRecovTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterRecovTime
    Set classical BTS TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime_initial}  ${alias}

Particular Teardown
    FOR  ${alias}  IN  @{BTS_primary_controller_list}

        ${SM_PDU_if_name_status}=  Run Keyword and Return Status  Variable Should Exist  ${${alias}_SM_PDU_if_name_list}
        Continue For Loop If  not ${SM_PDU_if_name_status}

        Run Keyword And Continue On Failure  Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}

    END

    Check all BTS cells availability status online


    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_FHS_list}

        ${TFM_feature_dict_status}=  Run Keyword and Return Status  Variable Should Exist  ${${alias}_TFM_feature_dict_initial}
        Continue For Loop If  not ${TFM_feature_dict_status}

        Recover Temporary Primary Controller role feature initial settings for shared FHS  ${alias}

    END

    FOR  ${alias}  IN  @{BTS_secondary_controller_shared_RMOD_list}

        ${TRM_feature_dict_status}=  Run Keyword and Return Status  Variable Should Exist  ${${alias}_TRM_feature_dict_initial}
        Continue For Loop If  not ${TRM_feature_dict_status}

        Recover Temporary Primary Controller role feature initial settings for shared RMOD  ${alias}

    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
