*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
Variables    tc_variables/cbts_sbts__state__check_trm_feature_with_fhgw_config_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3              # Number of cycles to perform check TRM feature, default value 3
${tempRadioMasterTriggerTime}  2              # Temporary radio master trigger time, default value 2
${tempRadioMasterRecovTime}    0              # Temporary radio master recovery time, default value 0
${FHGW_BMC_IP}                                # BMC IP address interface to FHGW
${FHGW_BMC_PORT}               443            # BMC port interface to FHGW (by default 443)
${FHGW_BMC_USERNAME}           bmc_user       # BMC username interface to FHGW (by default bmc_user)
${FHGW_BMC_PASSWORD}           Aikon_1234     # BMC password interface to FHGW (by default Aikon_1234)
${FHGW_BMC_INTERFACE}          redfish_oe_19  # BMC version interface to FHGW (by default redfish_oe_19). Supported versions: ‘redfish_rm_17’,
                                              # ‘redfish_oe_19’, ‘redfish_oe_20’, ‘redfish_oe_22’

*** Keywords ***
TC__CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27706
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case to perform BTS common startup with check TRM feature, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get BTS primary controller and BTS secondary controller role; if primary controller is shared (a BTS is primary controller for some shared
    ...  RMOD and secondary controller for other shared RMOD), test will perform BTS common startup with check TRM feature accordingly
    ...  - perform power OFF operation on BTS primary controller: PDU for classical BTS and BMC FHGW for cloud BTS
    ...  - check TRM feature on BTS secondary controller
    ...  - perform power ON operation on BTS primary controller checking states and alarms on both BTS
    ...  - check reset behavior on classical BTS based on IMS RESET info
    ...  Pass criteria: BTS common startup with check TRM feature works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27706 -
    ...  [CBTS][CLOUD_CLASSICAL][CB008388] CloudBTS_ClassicalSBTS__STATE_BTS's_Common_startup_Check_TRM
    ...  - 09.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28569 -
    ...  [CBTS] [CB012840] Unified WebEM on RAN Verification automation - CBTS Part - 28.01
    ...

    Set Tags    CA-STATE    OWNER-daniel-cristinel.hauca@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Check BTS power unit info
    Step 5: Check TRM feature settings on BTS secondary controller
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Check TRM feature behavior on BTS secondary controller
        Step 7: Check final all BTS states
        Step 8: Check final all BTS alarms
        Step 9: Check final number and state of Cells and RMs
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
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_alias_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    ${BTS_secondary_controller_alias_list}=  Create List

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
        ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}

        Run Keyword If  ${BTS_secondary_controller_RMOD_sn_count} > 0  Append To List  ${BTS_secondary_controller_alias_list}  ${alias}

    END

    Set Test Variable  ${BTS_secondary_controller_alias_list}

    Set Test Variable  ${CBTS_VDU_RMOD_state_degraded}  Operational state=Enabled, Availability status=Degraded, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_degraded}
    ...  Operational state=Enabled, Availability status=Degraded, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked

    Set Test Variable  ${SBTS_RMOD_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    Set Test Variable  ${SBTS_RMOD_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded
    Set Test Variable  ${SBTS_CELL_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked

Step ${index}: Check BTS power unit info
    [Documentation]
    ...  Helper Keyword used to check check BTS power unit info:
    ...  - PDU for classical BTS
    ...  - BMC FHGW for cloud BTS

    Log  Step ${index}: Check BTS power unit info  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'

        Check classical BTS PDU definition and reachability  ${alias}

    END

    Check cloud BTS BMC FHGW definition and reachability

Step ${index}: Check TRM feature settings on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings on BTS secondary controller and set them accordingly if needed

    Log  Step ${index}: Check TRM feature settings on BTS secondary controller  console=True

    FOR  ${alias}  IN  @{BTS_secondary_controller_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check TRM feature settings on classical BTS  ${alias}
        ...  ELSE
        ...  Check TRM feature settings on cloud BTS  ${alias}

    END

Step ${index}: Check TRM feature behavior on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check TRM feature behavior on BTS secondary controller

    Log  Step ${index}: Check TRM feature behavior on BTS secondary controller  console=True

    FOR  ${alias}  IN  @{BTS_secondary_controller_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check TRM feature behavior on classical BTS secondary controller  ${alias}
        ...  ELSE
        ...  Check TRM feature behavior on cloud BTS secondary controller  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Check cloud BTS BMC FHGW definition and reachability
    [Documentation]
    ...  Helper Keyword used to check cloud BTS BMC FHGW definition and reachability

    ${FHGW_alias}=  Set Variable  FHGW

    ${FHGW_BMC_setup_status}=  Run Keyword And Return Status  bmc.Connect To  address=${FHGW_BMC_IP}  port=${FHGW_BMC_PORT}
    ...  username=${FHGW_BMC_USERNAME}  password=${FHGW_BMC_PASSWORD}  name=${FHGW_alias}  interface=${FHGW_BMC_INTERFACE}
    Run Keyword If  ${FHGW_BMC_setup_status}
    ...  Log  BMC FHGW (ip=${FHGW_BMC_IP}, port=${FHGW_BMC_PORT}) successful setup as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  BMC FHGW (ip=${FHGW_BMC_IP}, port=${FHGW_BMC_PORT}) failed setup!  level=ERROR
    ...  AND  Fail  BMC FHGW (ip=${FHGW_BMC_IP}, port=${FHGW_BMC_PORT}) failed setup!

    [Teardown]  bmc.Disconnect  connection=${FHGW_alias}

Check TRM feature settings on classical BTS
    [Documentation]
    ...  Helper Keyword used to check classical BTS TRM feature settings and set them accordingly if needed

    [Arguments]  ${alias}
    Log  Check TRM feature settings on ${alias} BTS and set them accordingly if needed  console=True
    ${BTS_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_TRM_feature_dict_initial}  ${BTS_TRM_feature_dict_initial}
    Set classical BTS TRM feature parameter  actTempRadioMaster  true  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime}  ${alias}
    Log Long String  Test will be performed with TRM feature settings on ${alias} BTS secondary controller : actTempRadioMaster: true,
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}  console=True

Check TRM feature settings on cloud BTS
    [Documentation]
    ...  Helper Keyword used to check cloud BTS VDU TRM feature settings and set them accordingly if needed

    [Arguments]  ${vdu_alias}
    Log  Check TRM feature settings on ${vdu_alias} and set them accordingly if needed  console=True
    ${VDU_TRM_feature_dict_initial}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${vdu_alias.lower()}_scf_initial}  alias=${vdu_alias}
    Set Test Variable  ${${vdu_alias}_TRM_feature_dict_initial}  ${VDU_TRM_feature_dict_initial}
    Set cloud BTS VDU TRM feature parameter  actTempRadioMaster  true  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime}  update  ${vdu_alias}
    Log Long String  Test will be performed with TRM feature settings on ${vdu_alias} secondary controller : actTempRadioMaster: true,
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}  console=True

Check TRM feature behavior on classical BTS secondary controller
    [Documentation]
    ...  Check TRM feature behavior on classical BTS secondary controller

    [Arguments]  ${BTS_secondary_controller}

    ${BTS_alias_list_temp}=  Copy List  ${BTS_alias_list}
    Remove Values from list  ${BTS_alias_list_temp}  ${BTS_secondary_controller}
    ${BTS_primary_controller}=  Get From List  ${BTS_alias_list_temp}  0

    Set Test Variable  ${BTS_secondary_controller}
    Set Test Variable  ${BTS_primary_controller}

    Log  Check TRM feature on classical BTS secondary controller: ${BTS_secondary_controller}  console=True
    Get Current Date UTC info  initial
    Power cloud BTS FHGW  power=OFF
    Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterTriggerTime
    Power cloud BTS FHGW  power=ON
    Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterRecovTime

    Log  Check all cloud/classical BTS cells  console=True
    Check BTS cells are enabled online with exceptions  timeout=600
    Log  All cloud/classical BTS cells status is OK.  console=True

    Check all classical BTS reset behavior based on IMS info  ${BTS_secondary_controller}  0

Check TRM feature behavior on cloud BTS secondary controller
    [Documentation]
    ...  Check TRM feature behavior on cloud BTS secondary controller

    [Arguments]  ${BTS_secondary_controller}

    ${BTS_alias_list_temp}=  Copy List  ${BTS_alias_list}
    Remove Values from list  ${BTS_alias_list_temp}  ${BTS_secondary_controller}
    ${BTS_primary_controller}=  Get From List  ${BTS_alias_list_temp}  0

    Set Test Variable  ${BTS_secondary_controller}
    Set Test Variable  ${BTS_primary_controller}

    Log  Check TRM feature on classical BTS secondary controller: ${BTS_secondary_controller}  console=True
    Get Current Date UTC info  initial
    Power classical BTS  alias=${BTS_primary_controller}  power=OFF
    Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterTriggerTime
    Power classical BTS  alias=${BTS_primary_controller}  power=ON
    Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterRecovTime

    Log  Check all cloud/classical BTS cells  console=True
    Check BTS cells are enabled online with exceptions  timeout=900
    Log  All cloud/classical BTS cells status is OK.  console=True

    Check all classical BTS reset behavior based on IMS info  ${BTS_primary_controller}  1

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

Power cloud BTS FHGW
    [Documentation]
    ...  Helper Keyword used to power ON/OFF cloud BTS FHGW

    [Arguments]  ${power}
    Log  Power ${power} FHGW  console=True

    ${power_lower}=  Convert To Lower Case  ${power}
    ${FHGW_alias}=  Set Variable  FHGW

    bmc.Connect To  address=${FHGW_BMC_IP}  port=${FHGW_BMC_PORT}  username=${FHGW_BMC_USERNAME}  password=${FHGW_BMC_PASSWORD}  name=${FHGW_alias}
    ...  interface=${FHGW_BMC_INTERFACE}
    Run Keyword If  '${power_lower}' == 'off'
    ...  bmc.Power Off Immediate  connection=${FHGW_alias}
    ...  ELSE IF  '${power_lower}' == 'on'
    ...  bmc.Power On  connection=${FHGW_alias}
    Sleep  1 m  reason=Waiting time after power off/on action

    [Teardown]  bmc.Disconnect  connection=${FHGW_alias}

Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterTriggerTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterTriggerTime

    Log  Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterTriggerTime  console=True

    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${BTS_secondary_controller}
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}
    ${FID4220_count}=  Set Variable  ${BTS_secondary_controller_RMOD_sn_count}

    ${SBTS_EXPECTED_ALARMS_4220_full}=  Prepare expected alarms list  ${${BTS_secondary_controller.upper()}_EXPECTED_ALARMS_4220}  ${FID4220_count}
    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}
    ...  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS_X2}  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS_SYNC}

    Get BTS secondary controller cells impacted by TRM feature  ${BTS_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller}

    Log  Wait tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime} min for ${BTS_secondary_controller} BTS TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterTriggerTime} min

    Log  Check ${BTS_secondary_controller} BTS alarms:  console=True
    Log Long String  ${BTS_secondary_controller} BTS "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${FID4220_count}  console=True
    Get and Check Alarms SOAM  alias=${BTS_secondary_controller}    poll_interval=1s  expected_alarms=${SBTS_EXPECTED_ALARMS_4220_full}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_full}  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log Long String  ${BTS_secondary_controller} BTS "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${FID4220_count}, as expected!  console=True
    Log  ${BTS_secondary_controller} BTS site - expected, ignored and critical alarms checked  console=True

    Log  Check ${BTS_secondary_controller} BTS RMODs impacted by TRM feature status:  console=True
    Check SBTS TRM RMOD state  ${BTS_secondary_controller_RMOD_sn_list}  ${SBTS_RMOD_state_degraded_check}  ${SBTS_RMOD_state_degraded}  300
    ...  ${BTS_secondary_controller}

    Log  Check ${BTS_secondary_controller} BTS cells impacted by TRM feature status:  console=True
    Check SBTS TRM cell state  ${${BTS_secondary_controller}_TRM_NR_CELL_ids_list}  ${${BTS_secondary_controller}_TRM_LTE_CELL_ids_list}
    ...  ${${BTS_secondary_controller}_TRM_WCDMA_CELL_ids_list}  ${${BTS_secondary_controller}_TRM_GSM_CELL_ids_list}
    ...  ${SBTS_CELL_state_degraded_check}  ${SBTS_CELL_state_degraded}  300  ${BTS_secondary_controller}

Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterRecovTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterRecovTime

    Log  Check TRM feature behavior on classical BTS secondary controller related to tempRadioMasterRecovTime  console=True
    Log  Wait tempRadioMasterRecovTime=${tempRadioMasterRecovTime} min for ${BTS_secondary_controller} BTS TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterRecovTime} min

    Log  Check alarms and states on ${BTS_secondary_controller} BTS  console=True
    Get and Check Alarms SOAM  alias=${BTS_secondary_controller}  wait_for_alarm_clear=10 min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log  ${BTS_secondary_controller} BTS site - expected, ignored and critical alarms checked  console=True

Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterTriggerTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterTriggerTime

    Log  Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterTriggerTime  console=True

    ${BTS_secondary_controller_alarm}=  Replace String  ${BTS_secondary_controller}  ${SPACE}  _
    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${BTS_secondary_controller}
    ${BTS_secondary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_secondary_controller_RMOD_sn_list
    ${BTS_secondary_controller_RMOD_sn_count}=  Get Length  ${BTS_secondary_controller_RMOD_sn_list}
    ${FID4220_count}=  Set Variable  ${BTS_secondary_controller_RMOD_sn_count}

    ${VDU_EXPECTED_ALARMS_4220_full}=  Prepare expected alarms list  ${${BTS_secondary_controller_alarm.upper()}_EXPECTED_ALARMS_4220}
    ...  ${FID4220_count}
    ${VDU_IGNORED_ALARMS_full}=  Combine Lists  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}
    ...  ${${BTS_secondary_controller.upper()}_IGNORED_ALARMS_SYNC}

    Get BTS secondary controller cells impacted by TRM feature  ${BTS_secondary_controller_RMOD_sn_list}  ${BTS_secondary_controller}

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

    Log  Check ${BTS_secondary_controller} RMODs impacted by TRM feature status:  console=True
    Check CBTS VDU TRM RMOD state  ${BTS_secondary_controller_RMOD_sn_list}  ${CBTS_Enabled_}  ${CBTS_Degraded_}  ${CBTS_Unlocked_}
    ...  ${CBTS_VDU_RMOD_state_degraded}  300  ${BTS_secondary_controller}

Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterRecovTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterRecovTime

    Log  Check TRM feature behavior on cloud BTS secondary controller related to tempRadioMasterRecovTime  console=True
    Log  Wait tempRadioMasterRecovTime=${tempRadioMasterRecovTime} min for ${BTS_secondary_controller} TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterRecovTime} min

    Log  Check alarms and states on ${BTS_secondary_controller}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${BTS_secondary_controller}  wait_for_alarm_clear=10 min  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log  ${BTS_secondary_controller} site - expected, ignored and critical alarms checked  console=True

Get BTS secondary controller cells impacted by TRM feature
    [Arguments]  ${RMOD_sn_list}  ${alias}

    ${TRM_NR_CELL_ids_list}=  Create List
    ${TRM_LTE_CELL_ids_list}=  Create List
    ${TRM_WCDMA_CELL_ids_list}=  Create List
    ${TRM_GSM_CELL_ids_list}=  Create List

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict

    FOR  ${item}  IN  @{RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${item}
        ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${RMOD_id}
        ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${RMOD_id}
        ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${RMOD_id}
        ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${RMOD_id}

        Run Keyword If  ${RMOD_NR_CELL_ids_list}  Append To List  ${TRM_NR_CELL_ids_list}  @{RMOD_NR_CELL_ids_list}
        Run Keyword If  ${RMOD_LTE_CELL_ids_list}  Append To List  ${TRM_LTE_CELL_ids_list}  @{RMOD_LTE_CELL_ids_list}
        Run Keyword If  ${RMOD_WCDMA_CELL_ids_list}  Append To List  ${TRM_WCDMA_CELL_ids_list}  @{RMOD_WCDMA_CELL_ids_list}
        Run Keyword If  ${RMOD_GSM_CELL_ids_list}  Append To List  ${TRM_GSM_CELL_ids_list}  @{RMOD_GSM_CELL_ids_list}

    END

    Remove Duplicates  ${TRM_NR_CELL_ids_list}
    Remove Duplicates  ${TRM_LTE_CELL_ids_list}
    Remove Duplicates  ${TRM_WCDMA_CELL_ids_list}
    Remove Duplicates  ${TRM_GSM_CELL_ids_list}

    Set Test Variable  ${${alias}_TRM_NR_CELL_ids_list}  ${TRM_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_TRM_LTE_CELL_ids_list}  ${TRM_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_TRM_WCDMA_CELL_ids_list}  ${TRM_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_TRM_GSM_CELL_ids_list}  ${TRM_GSM_CELL_ids_list}

Check SBTS TRM RMOD state
    [Arguments]  ${TRM_RMOD_sn_list}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{TRM_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${item}
        Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}

    END

    Log  ${alias} BTS secondary controller RMODs impacted by TRM feature status:\n - ${RMOD_state}  console=True

Check SBTS TRM cell state
    [Arguments]  ${TRM_NR_CELL_ids}  ${TRM_LTE_CELL_ids}  ${TRM_WCDMA_CELL_ids}  ${TRM_GSM_NR_CELL_ids}  ${CELL_state_check}  ${CELL_state}
    ...  ${timeout}  ${alias}

    FOR  ${item}  IN  @{TRM_NR_CELL_ids}

        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}

    END

    FOR  ${item}  IN  @{TRM_LTE_CELL_ids}

        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}

    END

    FOR  ${item}  IN  @{TRM_WCDMA_CELL_ids}

        Assert  class_name=WNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}

    END

    FOR  ${item}  IN  @{TRM_GSM_NR_CELL_ids}

        Assert  class_name=GNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}

    END

    Log  ${alias} BTS secondary controller cells impacted by TRM feature status:\n - ${CELL_state}  console=True

Check CBTS VDU TRM RMOD state
    [Arguments]  ${TRM_RMOD_sn_list}  ${RMOD_operational_state}  ${RMOD_availability_status}  ${RMOD_administrative_state}  ${RMOD_state}
    ...  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{TRM_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${vdu_alias}_RMOD_sn_id_dict}  ${item}
        Wait Until Keyword Succeeds  ${timeout}s  5s  VDU Check RMOD Expected Status  rmod_id=${RMOD_id}  operational_state=${RMOD_operational_state}
        ...  availability_status=${RMOD_availability_status}  administrative_state=${RMOD_administrative_state}  vdu_connection=${vdu_alias}

    END

    Log  ${vdu_alias} RMODs status:\n - ${RMOD_state}  console=True

Check CBTS VDU TRM cell state
    [Arguments]  ${TRM_NR_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}
    ...  ${CELL_administrative_state_check}  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{TRM_NR_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  5s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}

    END

    Log  ${vdu_alias} secondary controller cells impacted by TRM feature status:\n - ${CELL_state}  console=True

Check all classical BTS reset behavior based on IMS info
    [Arguments]  ${alias}  ${expected_reset_number}

    Log  Check all classical BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  final

    Get and check BTS RESET info from IMS file  expected_reset_number=${expected_reset_number}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}' or '${${other_alias.upper()}}[${other_alias.upper()}_TECH]' == 'CBTS'

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    END

Recover BTS power unit status

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'

        Recover BTS SMs PDU port status  ${${alias}_SM_PDU_if_name_list}  on  ${alias}

    END

Recover cloud BTS FHGW power by BMC
    [Documentation]
    ...  Helper Keyword used to recover cloud BTS FHGW power by BMC
    ${FHGW_alias}=  Set Variable  FHGW

    bmc.Connect To  address=${FHGW_BMC_IP}  port=${FHGW_BMC_PORT}  username=${FHGW_BMC_USERNAME}  password=${FHGW_BMC_PASSWORD}  name=${FHGW_alias}
    ...  interface=${FHGW_BMC_INTERFACE}
    bmc.Power On  connection=${FHGW_alias}

    [Teardown]  bmc.Disconnect  connection=${FHGW_alias}

Recover initial settings for TRM feature on classical BTS
    [Documentation]
    ...  Keyword used to recover initial settings for TRM feature on classical BTS

    [Arguments]  ${alias}
    Log  Recover initial settings for TRM feature on ${alias} BTS  console=True
    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    ${tempRadioMasterRecovTime_initial}=  Get From Dictionary  ${${alias}_TRM_feature_dict_initial}  tempRadioMasterRecovTime
    Set classical BTS TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  ${alias}
    Set classical BTS TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime_initial}  ${alias}

Recover initial settings for TRM feature on cloud BTS
    [Documentation]
    ...  Keyword used to recover initial settings for TRM feature on cloud BTS

    [Arguments]  ${vdu_alias}
    Log  Recover initial settings for TRM feature on ${vdu_alias}  console=True
    ${actTempRadioMaster_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  actTempRadioMaster
    ${tempRadioMasterTriggerTime_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  tempRadioMasterTriggerTime
    ${tempRadioMasterRecovTime_initial}=  Get From Dictionary  ${${vdu_alias}_TRM_feature_dict_initial}  tempRadioMasterRecovTime
    Set cloud BTS VDU TRM feature parameter  actTempRadioMaster  ${actTempRadioMaster_initial}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterTriggerTime  ${tempRadioMasterTriggerTime_initial}  update  ${vdu_alias}
    Set cloud BTS VDU TRM feature parameter  tempRadioMasterRecovTime  ${tempRadioMasterRecovTime_initial}  update  ${vdu_alias}

Particular Teardown

    Run Keyword And Continue On Failure  Recover BTS power unit status
    Run Keyword And Continue On Failure  Recover cloud BTS FHGW power by BMC

    FOR  ${alias}  IN  @{BTS_secondary_controller_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Recover initial settings for TRM feature on classical BTS  ${alias}
        ...  ELSE
        ...  Recover initial settings for TRM feature on cloud BTS  ${alias}

    END

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
