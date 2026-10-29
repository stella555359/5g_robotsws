*** Settings ***
Documentation    TC__CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
Variables    tc_variables/cbts_sbts__state_check_ru_sw_package_and_nvm_integrity_on_ru_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of customized diagnostic check operations, default value 3

*** Keywords ***
TC__CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29033
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  ...  CBTS-SBTS test case to perform customized diagnostic check - RU SW package and NVM integrity option , - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get BTS primary controller and BTS secondary controller role; for this test, we need to have a BTS with mixed roles (a BTS is primary
    ...  controller for some shared RMOD and secondary controller for other shared RMOD); test will perform customized diagnostic check with check
    ...  TRM feature accordingly
    ...  - check TRM feature settings on cloud BTS secondary controller: tempRadioMasterTriggerTime will be set to 2min and tempRadioMasterRecovTime
    ...  will be set to 0s if needed; initial values will be restored at the end of the Test Case
    ...  - perform customized diagnostic check on cloud BTS primary controller - RU SW package and NVM integrity option
    ...  - perform power OFF operation on classical BTS primary controller: PDU for classical BTS
    ...  - check TRM feature on cloud BTS secondary controller
    ...  - perform customized diagnostic check on cloud BTS secondary controller - RU SW package and NVM integrity option
    ...  - perform power ON operation on classical BTS primary controller checking states and alarms on both BTS
    ...  - check final states and alarms for all BTS
    ...  Pass criteria: Customized diagnostic check with and without TRM feature works as expected, states and alarms are as expected
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29033 - New TC to Check the 40 RU SW package and NVM integrity line for
    ...  each radio (CB010415)
    ...

    Set Tags    CA-STATE    OWNER-cristian.croitoru@nokia.com   AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-CBTS25R3,SBTS25R3

    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Check classical BTS power unit info
    Step 5: Check TRM feature settings on cloud BTS secondary controller
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform customized diagnostic check on cloud BTS primary controller
        Step 7: Power OFF classical BTS primary controller
        Step 8: Perform customized diagnostic check on cloud BTS secondary controller
        Step 9: Power ON classical BTS primary controller
        Step 10: Check final all BTS states
        Step 11: Check final all BTS alarms
        Step 12: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

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

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_alias_list}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    ${BTS_primary_controller_alias_list}=  Create List
    ${BTS_secondary_controller_alias_list}=  Create List

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_primary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}
        ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}

        Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_RMOD_sn_list}  console=True
        Log  BTS ${alias} configured as secondary controller for: ${BTS_secondary_controller_RMOD_sn_list}  console=True

        Run Keyword If  ${BTS_primary_controller_RMOD_sn_count} > 0  Append To List  ${BTS_primary_controller_alias_list}  ${alias}
        Run Keyword If  ${BTS_secondary_controller_RMOD_sn_count} > 0  Append To List  ${BTS_secondary_controller_alias_list}  ${alias}

    END

    Set Test Variable  ${BTS_primary_controller_alias_list}
    Set Test Variable  ${BTS_secondary_controller_alias_list}

Step ${index}: Check classical BTS power unit info

    Log  Step ${index}: Check classical BTS power unit info  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'

        Check classical BTS PDU definition and reachability  ${alias}

    END

Step ${index}: Check TRM feature settings on cloud BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings on BTS secondary controller and set them accordingly if needed

    Log  Step ${index}: Check TRM feature settings on BTS secondary controller  console=True

    Set Test Variable  ${tempRadioMasterTriggerTime}  2
    Set Test Variable  ${tempRadioMasterRecovTime}  0

    FOR  ${alias}  IN  @{BTS_secondary_controller_alias_list}

        Continue For Loop If  '${alias}' in ${alias_list}

        Check TRM feature settings on cloud BTS  ${alias}

    END

Step ${index}: Perform customized diagnostic check on cloud BTS ${controller_role} controller

    Log  Step ${index}: Perform customized diagnostic check on cloud BTS ${controller_role} controller  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'

        Perform customized diagnostic check on BTS  ${alias}  ${controller_role}

    END

Step ${index}: Power OFF classical BTS primary controller

    Log  Step ${index}: Power OFF classical BTS primary controller  console=True

    FOR  ${alias}  IN  @{BTS_primary_controller_alias_list}

        Continue For Loop If  '${alias}' not in ${alias_list}

        Perform Power OFF classical BTS primary controller  ${alias}

    END

Step ${index}: Power ON classical BTS primary controller

    Log  Step ${index}: Power ON classical BTS primary controller  console=True

    FOR  ${alias}  IN  @{BTS_primary_controller_alias_list}

        Continue For Loop If  '${alias}' not in ${alias_list}

        Perform Power ON classical BTS primary controller  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check shared RMOD serial number list
    ${shared_RMOD_sn_list_strip}=  Replace String  ${SHARED_RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${custom_shared_RMOD_sn_list}=  Split String  ${shared_RMOD_sn_list_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalid_list}=  Create List

    FOR  ${item}  IN  @{custom_shared_RMOD_sn_list}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${shared_RMOD_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${shared_RMOD_sn_list}  Append To List  ${RMOD_sn_invalid_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected shared RMOD serial number values are not valid: ${RMOD_sn_invalid_list}. Please select values for test
    ...  argument \${SHARED_RMOD_SERIAL_NUMBER_LIST} from configured shared RMOD: ${shared_RMOD_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Sort List  ${custom_shared_RMOD_sn_list}
    Set Test Variable  ${shared_RMOD_sn_list}  ${custom_shared_RMOD_sn_list}

Check classical BTS PDU definition and reachability
    [Documentation]
    ...  Helper Keyword used to check classical BTS PDU definition and reachability

    [Arguments]  ${alias}

    ${BTS_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  ${alias}
    Set Test Variable  ${${alias}_SM_PDU_if_name_list}  ${BTS_SM_PDU_if_name_list}
    ${PDU_port_status}=  Check BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on
    Run Keyword if  ${PDU_port_status}
    ...  Log  ${alias} SMs PDU port status as expected  console=True  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for ${alias} SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for ${alias} SMs is either not reachable or not switched on!

Check TRM feature settings on cloud BTS
    [Documentation]
    ...  Helper Keyword used to check cloud BTS VDU TRM feature settings and set them accordingly if needed

    [Arguments]  ${vdu_alias}
    Log  Check TRM feature settings on ${vdu_alias} BTS and set them accordingly if needed  console=True
    ${VDU_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${vdu_alias.lower()}_scf_initial}  alias=${vdu_alias}
    Set Test Variable  ${${vdu_alias}_TRM_feature_dict_initial}  ${VDU_TRM_feature_dict_initial}
    Set cloud BTS VDU TRM feature parameter  actTempRadioMaster  true  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime}  update  ${vdu_alias}
    Log Long String  Test will be performed with TRM feature settings on ${vdu_alias} secondary controller : actTempRadioMaster: true,
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}  console=True

Perform customized diagnostic check on BTS
    [Arguments]    ${alias}  ${controller_role}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${vdu_alias}
        ${VDU_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${VDU_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${VDU_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        Sort List  ${VDU_primary_controller_RMOD_sn_list}
        Sort List  ${VDU_secondary_controller_RMOD_sn_list}
        ${VDU_primary_controller_RMOD_sn_count}=  Get Length  ${VDU_primary_controller_RMOD_sn_list}
        ${VDU_secondary_controller_RMOD_sn_count}=  Get Length  ${VDU_secondary_controller_RMOD_sn_list}

        Continue For Loop If  ${VDU_${controller_role}_controller_RMOD_sn_count} == 0

        Log  ***** Perform customized diagnostic check on ${vdu_alias} BTS *****  console=True
        Log Long String  ${vdu_alias} BTS ${controller_role} controller shared RM SN list selected for customized diagnostic check:
        ...  ${VDU_${controller_role}_controller_RMOD_sn_list}  console=True

        ${vnf_and_rmod_checkpoints_details}=  VDU Get VNF And RMOD Checkpoints  vdu_connection=${vdu_alias}
        ${rmod_checkpoint_id_list}=  Get RU SW package and NVM integrity Checkpoint Id  ${vnf_and_rmod_checkpoints_details}
        ${rmod_dn_checkpoint_id_list}=  Get RMOD DN and Checkpoint Id  ${VDU_${controller_role}_controller_RMOD_sn_list}
        ...  ${rmod_checkpoint_id_list}  ${vdu_alias}

        Get Current Date UTC info  start_diagnostic_check

        Log  Customized Diagnostic Check started at ${date_timestamp_start_diagnostic_check_UTC}!   console=True
        VDU Start Customized Diagnostic Check  vnf_checkpoint_ids=@{EMPTY}  rmod_checkpoint_ids=${rmod_dn_checkpoint_id_list}
        ...  vdu_connection=${vdu_alias}

        Get Current Date UTC info  end_diagnostic_check
        Log  Customized Diagnostic Check ended at ${date_timestamp_end_diagnostic_check_UTC}!   console=True

        ${reports}=  VDU Get Diagnostic Check Reports  vdu_connection=${vdu_alias}

        Check Diagnostic Check Reports  ${reports}  ${VDU_${controller_role}_controller_RMOD_sn_list}  ${vdu_alias}

    END

Get RU SW package and NVM integrity Checkpoint Id
    [Arguments]  ${vnf_and_rmod_checkpoints_details}

    ${rmod_checkpoint_id_list}=  Create List

    FOR  ${checkpoint_details}  IN  @{vnf_and_rmod_checkpoints_details}

        ${name}=  Get From Dictionary  ${checkpoint_details}  name
        ${id}=  Get From Dictionary  ${checkpoint_details}  id

        Run Keyword If  '${name}' == 'RU SW package and NVM integrity'
        ...  Append To List  ${rmod_checkpoint_id_list}  ${id}

    END

    [Return]  ${rmod_checkpoint_id_list}

Get RMOD DN and Checkpoint Id
    [Arguments]    ${rmod_sn_list}  ${rmod_checkpoint_id_list}  ${alias}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
        ...  VDU Get RMOD sn config runtime info  ${alias}

    ${rmod_dn_checkpoint_id_list}=  Create List

    FOR  ${RMOD_sn}  IN  @{rmod_sn_list}

        ${RMOD_config_dn}=  Get From Dictionary  ${VDU_RMOD_sn_config_dict}  ${RMOD_sn}
        ${rmod_dn_checkpoint_ids_dict}=  Create Dictionary  targetDN=${RMOD_config_dn}  checkpointIds=${rmod_checkpoint_id_list}
        Append To List  ${rmod_dn_checkpoint_id_list}  ${rmod_dn_checkpoint_ids_dict}

    END

    [Return]  ${rmod_dn_checkpoint_id_list}

Check Diagnostic Check Reports
    [Arguments]  ${diagnostic_check_reports}  ${rmod_sn_list}  ${alias}

    ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}=
        ...  VDU Get RMOD sn config runtime info  ${alias}

    FOR  ${RMOD_sn}  IN  @{rmod_sn_list}

        ${RMOD_runtime_dn}=  Get From Dictionary  ${VDU_RMOD_sn_runtime_dict}  ${RMOD_sn}
        Check Reports For RU SW package and NVM integrity  ${diagnostic_check_reports}  ${RMOD_runtime_dn}  ${RMOD_sn}

    END

Check Reports For RU SW package and NVM integrity
    [Arguments]  ${diagnostic_check_reports}  ${RMOD_runtime_dn}  ${RMOD_sn}

    FOR  ${report}  IN  @{diagnostic_check_reports}

        ${checkpointName}=  Get From Dictionary  ${report}  checkpointName
        ${targetDistinguishedName}=  Get From Dictionary  ${report}  targetDistinguishedName
        Continue For Loop If  '${targetDistinguishedName}' != '${RMOD_runtime_dn}' or '${checkpointName}' != 'RU SW package and NVM integrity'

        Log  Check RU SW package and NVM integrity report for shared RM with SN ${RMOD_sn}:  console=True

        ${checkStatus}=  Get From Dictionary  ${report}  checkStatus
        ${triggerType}=  Get From Dictionary  ${report}  triggerType
        ${executionTime}=  Get From Dictionary  ${report}  executionTimeOfLastDefinitiveStatus
        ${executionTime_UTC}=  Convert Date  ${executionTime}  result_format=timestamp
        ${executionTime_epoch}=  Convert Date  ${executionTime_UTC}  epoch  exclude_millis=True
        ${start_diagnostic_check_epoch}=  Convert Date  ${date_timestamp_start_diagnostic_check_UTC}  epoch  exclude_millis=True
        ${end_diagnostic_check_epoch}=  Convert Date  ${date_timestamp_end_diagnostic_check_UTC}  epoch  exclude_millis=True

        Run Keyword If  '${checkStatus}' != 'Check point successful'  Run Keywords
        ...  Log Long String  Diagnostic "RU SW package and NVM integrity" check status not successfull for shared RM with SN ${RMOD_sn}:
        ...  ${checkStatus}  level=ERROR
        ...  AND  Fail  Diagnostic "RU SW package and NVM integrity" check status not successfull for shared RM with SN ${RMOD_sn}: ${checkStatus}
        Run Keyword If  '${triggerType}' != 'WebEM'  Run Keywords
        ...  Log  Trigger type found for shared RM with SN ${RMOD_sn} not as expected: ${triggerType}  level=ERROR
        ...  AND  Fail  Trigger type found for shared RM with SN ${RMOD_sn} not as expected: ${triggerType}

        ${time_result}=  Evaluate  ${start_diagnostic_check_epoch} <= ${executionTime_epoch} <= ${end_diagnostic_check_epoch}
        Run Keyword If  '${time_result}' == 'False'  Run Keywords
        ...  Log  executionTimeOfLastDefinitiveStatus not as expected for shared RM with SN ${RMOD_sn}: ${executionTime_UTC}  level=ERROR
        ...  AND  Fail  executionTimeOfLastDefinitiveStatus not as expected for shared RM with SN ${RMOD_sn}: ${executionTime_UTC}

        Log  - checkStatus:${checkStatus}\n- triggerType:${triggerType}\n- executionTimeOfLastDefinitiveStatus:${executionTime_UTC}  console=True
        Log  RU SW package and NVM integrity report results, as expected!  console=True

    END

Perform Power OFF classical BTS primary controller
    [Arguments]  ${BTS_primary_controller}

    ${BTS_alias_list_temp}=  Copy List  ${BTS_alias_list}
    Remove Values from list  ${BTS_alias_list_temp}  ${BTS_primary_controller}
    ${BTS_secondary_controller}=  Get From List  ${BTS_alias_list_temp}  0

    Power classical BTS  alias=${BTS_primary_controller}  power=OFF
    Check TRM feature behavior on cloud BTS secondary controller  ${BTS_secondary_controller}

Power classical BTS
    [Documentation]
    ...  Helper Keyword used to power ON/OFF classical BTS

    [Arguments]  ${alias}  ${power}
    Log  Power ${power} ${alias} BTS  console=True

    ${power_lower}=  Convert To Lower Case  ${power}
    ${PDU_port_status}=  Set BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  ${power_lower}

    Run Keyword If  ${PDU_port_status}
    ...  Log  ${alias} SMs PDU port status ${power}, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set ${alias} SMs PDU port status ${power} failed!  level=ERROR
    ...  AND  Fail  Set ${alias} SMs PDU port status on failed!

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  '${power_lower}' == 'off'
    ...  Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  timeout=300  remote_host=${remote_host_ip}
    ...  ELSE IF  '${power_lower}' == 'on'
    ...  Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  timeout=300  remote_host=${remote_host_ip}
    Sleep  1 m  reason=Waiting time after power off/on action

Check TRM feature behavior on cloud BTS secondary controller
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on cloud BTS secondary controller
    [Arguments]  ${BTS_secondary_controller}

    Log  Check TRM feature behavior on cloud BTS secondary controller: ${BTS_secondary_controller}  console=True

    ${BTS_secondary_controller_alarm}=  Replace String  ${BTS_secondary_controller}  ${SPACE}  _
    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${BTS_secondary_controller}
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}
    ${FID4220_count}=  Set Variable  ${BTS_secondary_controller_RMOD_sn_count}

    ${VDU_EXPECTED_ALARMS_4220_full}=  Prepare expected alarms list  ${${BTS_secondary_controller_alarm.upper()}_EXPECTED_ALARMS_4220}
    ...  ${FID4220_count}
    ${VDU_IGNORED_ALARMS_full}=  Combine Lists  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}
    ...  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS_10}  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS_16}

    Log  Wait tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime} min for ${BTS_secondary_controller} BTS TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterTriggerTime} min

    Log  Check ${BTS_secondary_controller} alarms:  console=True
    Log Long String  ${BTS_secondary_controller} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${FID4220_count}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${BTS_secondary_controller}  expected_alarms=${VDU_EXPECTED_ALARMS_4220_full}
    ...  ignored_alarms=${VDU_IGNORED_ALARMS_full}  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log Long String  ${BTS_secondary_controller} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${FID4220_count}, as expected!  console=True
    Log  ${BTS_secondary_controller} site - expected, ignored and critical alarms checked  console=True

Perform Power ON classical BTS primary controller
    [Arguments]  ${BTS_primary_controller}

    ${BTS_alias_list_temp}=  Copy List  ${BTS_alias_list}
    Remove Values from list  ${BTS_alias_list_temp}  ${BTS_primary_controller}
    ${BTS_secondary_controller}=  Get From List  ${BTS_alias_list_temp}  0

    Power classical BTS  alias=${BTS_primary_controller}  power=ON

    Log  Check alarms and states on ${BTS_secondary_controller}  console=True
    Log Long String  Wait for ${BTS_secondary_controller} "Radio slave has taken temporary radio master role (4220)" alarm to be cleared.
    ...  No alarms are expected!  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${BTS_secondary_controller}  wait_for_alarm_clear=10 min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log  ${BTS_secondary_controller} site - expected, ignored and critical alarms checked  console=True

    Log  Check all cloud/classical BTS cells  console=True
    Check BTS cells are enabled online with exceptions  timeout=900
    Log  All cloud/classical BTS cells status is OK.  console=True

Recover BTS power unit status

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'

        Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}

    END

Recover initial settings for TRM feature on cloud BTS
    [Documentation]
    ...  Keyword used to recover initial settings for TRM feature on cloud BTS

    [Arguments]  ${vdu_alias}
    Log  Recover initial settings for TRM feature on ${vdu_alias} BTS  console=True
    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    ${tempRadioMasterRecovTime_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  tempRadioMasterRecovTime
    Set cloud BTS VDU TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime_initial}  update  ${vdu_alias}

Particular Teardown

    Run Keyword And Continue On Failure  Recover BTS power unit status

    FOR  ${alias}  IN  @{BTS_secondary_controller_alias_list}

        Continue For Loop If  '${alias}' in ${alias_list}

        Recover initial settings for TRM feature on cloud BTS  ${alias}

    END

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown