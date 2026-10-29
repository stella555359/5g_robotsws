*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__FHGW_RMOD_Link_Break
Variables    tc_variables/cbts_sbts__state__fhgw_rmod_link_break_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}        3                 # Number of cycles to perform the link failure, default value 3, default value 3
${RMOD_SERIAL_NUMBERS}                     # Serial Numbers of the shared CPRI RMOD which will be disconnected from FHGW, separated by ;
${RMOD_FHGW_Calient_Crossconnections}      # List of Crossconnection between FHGW and RMOD separated by ; example: 1.2.1-5.6.1;1.3.1-5.7.1
                                           # Must respect order to its corresponding RMOD_SERIAL_NUMBERS list
${BTS_MAX_WAIT_TIME}       240             # Maximum time to wait for BTS checks after link break/restore between FHGW and RMOD (by default 240)

*** Keywords ***
TC__CBTS_SBTS__STATE__FHGW_RMOD_Link_Break
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28202
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for checking CPRI link failure between FHGW and shared radio, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - perform CPRI link failure between RMOD and FHGW
    ...  - check behavior if Classical BTS has primary Link for RMOD connected to FHGW
    ...  - check behavior if CBTS has primary Link for RMOD connected to FHGW
    ...  - reestablish fiber connection
    ...  Pass criteria: CPRI link failure between FHGW and shared radio behaviour as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 04.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28202 - TC Creation
    ...

    Set Tags    CA-STATE    OWNER-cristian.croitoru@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Get Primary Link Info for requested RMOD
        Step 5: Perform FHGW to shared radio modules link failure and restore
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Log  Check test argument values validity:  console=True
    ${RMOD_SERIAL_NUMBERS_list}=  Split String   ${RMOD_SERIAL_NUMBERS}  ;
    ${Crossconnections_list}=  Split String   ${RMOD_FHGW_Calient_Crossconnections}  ;
    ${rmod_sn_crossconnection_dict}=  Create Dictionary
    ${rmod_sn_cbts_rmod_id_dict}=  Create Dictionary
    ${rmod_sn_cbts_vdu_alias_dict}=  Create Dictionary
    Set Test Variable  ${rmod_sn_crossconnection_dict}
    Set Test Variable  ${rmod_sn_cbts_rmod_id_dict}
    Set Test Variable  ${RMOD_SERIAL_NUMBERS_list}
    Set Test Variable  ${rmod_sn_cbts_vdu_alias_dict}
    FOR  ${RMOD_SERIAL_NUMBER}  ${Crossconnection}  IN ZIP  ${RMOD_SERIAL_NUMBERS_list}  ${Crossconnections_list}
        Set To Dictionary  ${rmod_sn_crossconnection_dict}  ${RMOD_SERIAL_NUMBER}=${Crossconnection}
    END
    FOR  ${RMOD_SERIAL_NUMBER}  IN  @{RMOD_SERIAL_NUMBERS_list}
        ${rm_id}  ${vdu_alias}=  Get and check RM info precondition  ${RMOD_SERIAL_NUMBER}
        Set To Dictionary  ${rmod_sn_cbts_rmod_id_dict}  ${RMOD_SERIAL_NUMBER}=${RM_id}
        Set To Dictionary  ${rmod_sn_cbts_vdu_alias_dict}  ${RMOD_SERIAL_NUMBER}=${vdu_alias}
    END

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
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_disabled}  Operational state=Disabled, Availability status=NotInstalled, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_disabled}
    ...  Operational state=Disabled, Availability status=Failed, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_RMOD_state_disabled}  Operational state=Disabled, Availability status=Offline, Administrative state=Unlocked
    Set Test Variable  ${CBTS_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_cell_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_CELL_state_failed}
    ...  Operational state=Disabled, Availability status=Failed, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_disabled}
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}
    ...  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${SBTS_CELL_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}
        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Get SBTS Cell info  ${alias}
        ...  AND  Set Test Variable  ${bts_alias}  ${alias}
    END

Step ${index}: Perform FHGW to shared radio modules link failure and restore

    Log  Step ${index}: Perform FHGW to shared radio module link failure and restore  console=True

    FOR  ${RMOD_SERIAL_NUMBER}  IN  @{RMOD_SERIAL_NUMBERS_list}
        Perform FHGW to shared radio module link removal  ${RMOD_SERIAL_NUMBER}
        ${CBTS_holds_PL}=  Get From Dictionary  ${CBTS_PL_info_dict}  ${RMOD_SERIAL_NUMBER}
        ${vdu_alias}=  Get From Dictionary  ${rmod_sn_cbts_vdu_alias_dict}  ${RMOD_SERIAL_NUMBER}
        Check cloud BTS states and alarms after link failure between FHGW and shared RMOD  ${RMOD_SERIAL_NUMBER}  ${vdu_alias}
        Check Classical BTS states and alarms after link failure between FHGW and shared RMOD  ${RMOD_SERIAL_NUMBER}  ${CBTS_holds_PL}  ${bts_alias}
        Perform FHGW to shared radio module link restore  ${RMOD_SERIAL_NUMBER}
        Check BTS states and alarms after link restore between FHGW and shared RMOD
    END

Check cloud BTS states and alarms after link failure between FHGW and shared RMOD
    [Arguments]  ${RMOD_SERIAL_NUMBER}  ${vdu_alias}

    Log  Check Cloud BTS states and alarms after link failure between FHGW and shared RMOD  console=True
    Get RMOD info from BTS  ${RMOD_SERIAL_NUMBER}  ${vdu_alias}
    ${RMOD_id_action}=  Get From Dictionary  ${rmod_sn_cbts_rmod_id_dict}  ${RMOD_SERIAL_NUMBER}
    ${bts_cells}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${vdu_alias}
    ${bts_NR_cells}=  Get From Dictionary  ${bts_cells}  RMOD_id_NR_CELL_ids_dict
    ${bts_RMOD_NR_cells}=  Get From Dictionary  ${bts_NR_cells}  ${RMOD_id_action}
    ${bts_all_RMOD_ids}=  Get Dictionary Keys  ${bts_NR_cells}

    Log  Check impacted RMOD CBTS state  console=True
    Update Remained max wait time
    Check CBTS VDU RMOD state  ${RMOD_SERIAL_NUMBER}  ${RMOD_id_action}  ${CBTS_Disabled_}  ${CBTS_NotInstalled_Offline_}  ${CBTS_Unlocked_}
    ...  ${CBTS_VDU_RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check impacted RMOD CBTS cells state  console=True
    Update Remained max wait time
    Check CBTS VDU RMOD cell state  ${RMOD_SERIAL_NUMBER}  ${bts_RMOD_NR_cells}  ${CBTS_Disabled_}  ${CBTS_Failed_}  ${CBTS_Unlocked_}
    ...  ${CBTS_Unblocked_}  ${CBTS_CELL_state_failed}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check CBTS not impacted RMODs and Cells  console=True
    FOR  ${RMOD_id}  IN  @{bts_all_RMOD_ids}
        Run Keyword If  ${RMOD_id}==${RMOD_id_action}  Continue For Loop
        ${RMOD_SERIAL_NUMBER}=  Get From Dictionary  ${VDU_RMOD_id_sn_dict}  ${RMOD_id}
        Update Remained max wait time
        Check CBTS VDU RMOD state  ${RMOD_SERIAL_NUMBER}  ${RMOD_id}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}
        ...  ${CBTS_VDU_RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}
        ${bts_RMOD_NR_cells}=  Get From Dictionary  ${bts_NR_cells}  ${RMOD_id}
        Update Remained max wait time
        Check CBTS VDU RMOD cell state  ${RMOD_SERIAL_NUMBER}  ${bts_RMOD_NR_cells}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}
        ...  ${CBTS_Unblocked_}  ${CBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}
    END

    Log  ${vdu_alias} "No connection to Unit (10)" alarm, expected number: 1  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=${${vdu_alias_alarm.upper()}_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} "No connection to Unit (10)" alarm, found number: 1, as expected!  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True


Check Classical BTS states and alarms after link failure between FHGW and shared RMOD
    [Arguments]  ${RMOD_SERIAL_NUMBER}  ${CBTS_holds_PL}  ${alias}
    Log  Check Classical BTS states and alarms after link failure between FHGW and shared RMOD  console=True
    Log  RMOD ${RMOD_SERIAL_NUMBER} - Primary Link on CBTS: ${CBTS_holds_PL}  console=True
    Get RMOD info from BTS  ${RMOD_SERIAL_NUMBER}  ${alias}
    ${RMOD_id_action}=  Set Variable  ${${alias}_RMOD_id}
    ${bts_cells}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${bts_NR_cells}=  Get From Dictionary  ${bts_cells}  RMOD_id_NR_CELL_ids_dict
    ${bts_RMOD_NR_cells}=  Get From Dictionary  ${bts_NR_cells}  ${RMOD_id_action}
    ${bts_all_RMOD_ids}=  Get Dictionary Keys  ${bts_NR_cells}
    ${bts_LTE_cells}=  Get From Dictionary  ${bts_cells}  RMOD_id_LTE_CELL_ids_dict
    ${bts_RMOD_LTE_cells}=  Get From Dictionary  ${bts_LTE_cells}  ${RMOD_id_action}
    ${bts_WCDMA_cells}=  Get From Dictionary  ${bts_cells}  RMOD_id_WCDMA_CELL_ids_dict
    ${bts_RMOD_WCDMA_cells}=  Get From Dictionary  ${bts_WCDMA_cells}  ${RMOD_id_action}
    ${bts_GSM_cells}=  Get From Dictionary  ${bts_cells}  RMOD_id_GSM_CELL_ids_dict
    ${bts_RMOD_GSM_cells}=  Get From Dictionary  ${bts_GSM_cells}  ${RMOD_id_action}


    ${SBTS_RMOD_state_check}=  Set Variable If  '${CBTS_holds_PL}'=='True'  ${SBTS_RMOD_state_disabled_check}  ${SBTS_RMOD_state_enabled_check}
    ${SBTS_RMOD_state}=  Set Variable If  '${CBTS_holds_PL}'=='True'  ${SBTS_RMOD_state_disabled}  ${SBTS_RMOD_state_enabled}

    Run Keyword If  '${CBTS_holds_PL}'=='True'
    ...  Log  Since CBTS holds PL for RMOD ${RMOD_SERIAL_NUMBER}, expecting RMOD reset, FID10, and change of Primary Link  console=True
    ...  ELSE
    ...  Log Long String  Since Classical BTS holds PL for RMOD ${RMOD_SERIAL_NUMBER}, expecting no RMOD reset, no FID10,
    ...  no Primary Link switch  console=True

    Log  Check impacted RMOD SBTS state  console=True
    Update Remained max wait time
    Check SBTS RMOD state  ${RMOD_SERIAL_NUMBER}  ${RMOD_id_action}  ${SBTS_RMOD_state_check}  ${SBTS_RMOD_state}  ${remained_MAX_WAIT_TIME}  ${alias}

    Run Keyword If  '${CBTS_holds_PL}'=='True'  Run Keywords
    ...  Update Remained max wait time
    ...  AND  Log  ${alias} "No connection to Unit (10)" alarm, expected number: 1  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  ${alias} "No connection to Unit (10)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  ${alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check impacted RMOD SBTS cells  console=True
    Run Keyword If  '${CBTS_holds_PL}'!='True'  Run Keywords
    ...  Update Remained max wait time
    ...  AND  Log  Since CBTS holds PL for RMOD ${RMOD_SERIAL_NUMBER}, expecting no impact on SBTS cells mapped on RMOD  console=True
    ...  AND  Check SBTS RMOD cell state  ${RMOD_SERIAL_NUMBER}  ${bts_RMOD_NR_cells}  ${bts_RMOD_LTE_cells}
    ...  ${bts_RMOD_WCDMA_cells}  ${bts_RMOD_GSM_cells}  ${SBTS_CELL_state_enabled_check}
    ...  ${SBTS_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}
    ...  ELSE  Run Keywords
    ...  Update Remained max wait time
    ...  AND  Log  Since CBTS holds PL for RMOD ${RMOD_SERIAL_NUMBER}, expecting impact on SBTS cells mapped on RMOD  console=True
    ...  AND  Check SBTS RMOD cell state  ${RMOD_SERIAL_NUMBER}  ${bts_RMOD_NR_cells}  ${bts_RMOD_LTE_cells}
    ...  ${bts_RMOD_WCDMA_cells}  ${bts_RMOD_GSM_cells}  ${SBTS_CELL_state_disabled_check}
    ...  ${SBTS_CELL_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Log  Check other SBTS cells. Expecting no impact  console=True
    ${NR_cell_info_exempted}=  Create Dictionary  ${alias}=${bts_RMOD_NR_cells}
    ${IoT_exempted_LTE_CELL_ids_list}=  Create List
    FOR  ${lte_cell_id}  IN  @{bts_RMOD_LTE_cells}
        ${cell_IOT_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${lte_cell_id}
        Run Keyword If  '${cell_IOT_id}' != 'None'  Append To List  ${IoT_exempted_LTE_CELL_ids_list}  ${cell_IOT_id}
    END
    ${bts_RMOD_LTE_cells_list_full}=
    ...  Combine Lists  ${bts_RMOD_LTE_cells}  ${IoT_exempted_LTE_CELL_ids_list}
    ${bts_RMOD_LTE_cells_list_full}=  Remove Duplicates  ${bts_RMOD_LTE_cells_list_full}
    ${LTE_cell_info_exempted}=  Create Dictionary  ${alias}=${bts_RMOD_LTE_cells_list_full}
    ${WCDMA_cell_info_exempted}=  Create Dictionary  ${alias}=${bts_RMOD_WCDMA_cells}
    ${GSM_cell_info_exempted}=  Create Dictionary  ${alias}=${bts_RMOD_GSM_cells}
    Update Remained max wait time
    Check classical BTS cells are enabled online  NR_cell_info_exempted=&{NR_cell_info_exempted}  LTE_cell_info_exempted=&{LTE_cell_info_exempted}
    ...  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  alias=${alias}

    ${SBTS_controller_roles}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${SBTS_secondary_controller_list}=  Get From Dictionary  ${SBTS_controller_roles}  BTS_secondary_controller_RMOD_sn_list
    Run Keyword If  '${RMOD_SERIAL_NUMBER}' not in ${SBTS_secondary_controller_list}  Run Keywords
    ...  Log  SBTS has primary controller role for RMOD ${RMOD_SERIAL_NUMBER}, Temporary Radio Master should not be triggered!  console=True
    ...  AND  Return From Keyword

    ${BTS_TRM_feature_dict}=  Get BTS TRM feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}
    ${actTempRadioMaster}=  Get From Dictionary  ${BTS_TRM_feature_dict}  actTempRadioMaster
    ${tempRadioMasterTriggerTime}=  Get From Dictionary  ${BTS_TRM_feature_dict}  tempRadioMasterTriggerTime
    Run Keyword If  '${actTempRadioMaster}'=='false'  Run Keywords
    ...  Log  actTempRadioMaster=False on SBTS ${alias}. Checking TRM skipped!
    ...  AND  Return From Keyword

    Run Keyword If  '${CBTS_holds_PL}'=='True'  Run Keywords
    ...  Log  Waiting stable state to start counting tempRadioMasterTriggerTime  console=True
    ...  AND  Update Remained max wait time
    ...  AND  Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}

    Log  Waiting ${tempRadioMasterTriggerTime} min for TRM to be triggered!  console=True
    Sleep  ${tempRadioMasterTriggerTime}min

    Log   BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_4220}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number: 1, as expected!  console=True
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after link restore between FHGW and shared RMOD
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    Update Remained max wait time
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  VDU Check VDU Expected Status  operational_state=${CBTS_OnAir_}
    ...  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${CBTS_VDU_state_onair}  console=True

    Log  Check ${vdu_alias} RMODs status:  console=True
    Update Remained max wait time
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all RMODs expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} RMODs status:\n - ${CBTS_VDU_RMOD_state_enabled}  console=True

    Log  Check ${vdu_alias} cells status:  console=True
    Update Remained max wait time
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all cells expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status:\n - ${CBTS_VDU_CELL_state_enabled}  console=True

    Log  Check ${vdu_alias} alarms:  console=True
    Update Remained max wait time
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check classical BTS states and alarms after link restore between FHGW and shared RMOD
    [Arguments]  ${alias}

    Log  Check ${alias} BTS status:  console=True
    Update Remained max wait time
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    Update Remained max wait time
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    Log  Check ${alias} BTS cells status:  console=True
    Update Remained max wait time
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${alias} BTS cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${alias} BTS alarms:  console=True
    Update Remained max wait time
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms after link restore between FHGW and shared RMOD

    FOR  ${alias}  IN  @{BTS_all_alias_list}
        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS states and alarms after link restore between FHGW and shared RMOD  alias=${alias}
        ...  ELSE
        ...  Check cloud BTS states and alarms after link restore between FHGW and shared RMOD  vdu_alias=${alias}
    END

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    ${RMOD_id_list}=  Create List  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id}  ${RMOD_id}
    Set Test Variable  ${${alias}_RMOD_id_list}  ${RMOD_id_list}
    ${RMOD_pn}=  Get From Dictionary  ${${alias}_RMOD_sn_pn_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_pn}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${alias}_RMOD_id}
    Set Test Variable  ${${alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${RMOD_BTS_alias_count}=  Get Length  ${RMOD_BTS_alias_list}
    Return From Keyword If  ${RMOD_BTS_alias_count} == 1

    ${RMOD_peer_BTS_alias_list}=  Copy List  ${RMOD_BTS_alias_list}
    Remove Values From List  ${RMOD_peer_BTS_alias_list}  ${alias}
    ${peer_BTS_alias}=  Get From List  ${RMOD_peer_BTS_alias_list}  0
    Set Test Variable  ${peer_BTS_alias}
    ${RMOD_id}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_id}  ${RMOD_id}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${peer_BTS_alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${${peer_BTS_alias}_RMOD_id}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${peer_BTS_alias}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

    ${RMOD_interface}=  Get From Dictionary  ${${peer_BTS_alias}_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_interface}

Check CBTS VDU RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_operational_state_check}  ${RMOD_availability_status_check}  ${RMOD_administrative_state_check}
    ...  ${RMOD_state}  ${timeout}  ${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RMOD Expected Status  rmod_id=${RMOD_id}
    ...  operational_state=${RMOD_operational_state_check}  availability_status=${RMOD_availability_status_check}
    ...  administrative_state==${RMOD_administrative_state_check}  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check CBTS VDU RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}
    ...  ${CELL_administrative_state_check}  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}
        Update Remained max wait time

    END
    Log  ${vdu_alias} cells mapped on RMOD ${RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check SBTS RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  ${alias} BTS RMOD ${RMOD_id} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check SBTS RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{RMOD_NR_CELL_ids}
        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        Update Remained max wait time
    END

    FOR  ${item}  IN  @{RMOD_LTE_CELL_ids}
        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        Update Remained max wait time
    END

    FOR  ${item}  IN  @{RMOD_WCDMA_CELL_ids}
        Assert  class_name=WNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        Update Remained max wait time
    END

    FOR  ${item}  IN  @{RMOD_GSM_NR_CELL_ids}
        Assert  class_name=GNCEL  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
        Update Remained max wait time
    END

    Log  ${alias} BTS cells mapped on RMOD with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Perform FHGW to shared radio module link removal
    [Arguments]  ${RMOD_SERIAL_NUMBER}

    Log  Perform FHGW to shared radio module link removal  console=True

    ${cross_connect}=  Get From Dictionary  ${rmod_sn_crossconnection_dict}  ${RMOD_SERIAL_NUMBER}
    ${vdu_alias}=  Get From Dictionary  ${rmod_sn_cbts_vdu_alias_dict}  ${RMOD_SERIAL_NUMBER}
    Log Long String   ***** Performing link removal from FHGW to shared radio module RMOD_${RMOD_SERIAL_NUMBER}
    ...  port ${cross_connect} on ${vdu_alias}   console=True
    Save cross connection details  ${cross_connect}
    Remove Cross Connection By Id  ${cross_connect}
    Get Current Date UTC info  initial
    Get Current Time  initial
    ${status_cross_connect}=  Get Cross Connection Status by Id  ${cross_connect}
    Run Keyword If  '${status_cross_connect}' == 'False'
    ...  Log  Cross connection: ${cross_connect} has been removed between FHGW and RMOD: ${RMOD_SERIAL_NUMBER}  console=True
    ...  ELSE  Fail  Removing Cross Connection: ${cross_connect} failed

Perform FHGW to shared radio module link restore
    [Arguments]  ${RMOD_SERIAL_NUMBER}

    Log  Perform FHGW to shared radio module link restore  console=True

    ${cross_connect}=  Get From Dictionary  ${rmod_sn_crossconnection_dict}  ${RMOD_SERIAL_NUMBER}
    ${vdu_alias}=  Get From Dictionary  ${rmod_sn_cbts_vdu_alias_dict}  ${RMOD_SERIAL_NUMBER}
    Log Long String   ***** Performing link restore from FHGW to shared radio module RMOD_${RMOD_SERIAL_NUMBER}
    ...  port ${cross_connect} on ${vdu_alias}   console=True
    Create Cross Connection with Options by Id  new_connection=${cross_connect}  group=${options['group']}  conn=${options['connid']}
    ...  dir=${options['dir'].lower()}  band=${options['band'][0]}  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
    ${status_cross_connect}=  Get Cross Connection Status by Id  ${cross_connect}
    Run Keyword If  ${status_cross_connect}  Log  Cross Connection: ${cross_connect} successfully recreated  console=True
    ...  ELSE  Fail  Cross Connection: ${cross_connect} coudn't be established
    Get Current Date UTC info  initial
    Get Current Time  initial

Step ${index}: Get Primary Link Info for requested RMOD

    Log  Step ${index}: Get Primary Link Info for requested RMOD

    ${CBTS_PL_info_dict}=  Create Dictionary
    Set Test Variable  ${CBTS_PL_info_dict}
    FOR  ${RMOD_SERIAL_NUMBER}  IN  @{RMOD_SERIAL_NUMBERS_list}
        ${RMOD_BTS_alias_list}=  Get From Dictionary   ${RMOD_sn_BTS_alias_dict}  ${RMOD_SERIAL_NUMBER}
        ${SYNC_entity}  ${NON_SYNC_entity}  ${RMOD_interface}=
        ...  Get shared RMOD synchronisation info with FHGW connected  ${RMOD_SERIAL_NUMBER}  ${RMOD_BTS_alias_list}
        ${PL_on_CBTS}=  Set Variable If  '${SYNC_entity}'=='FHGW'  True  False
        Set To Dictionary     ${CBTS_PL_info_dict}  ${RMOD_SERIAL_NUMBER}=${PL_on_CBTS}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get and check RM info precondition
    [Arguments]   ${RMOD_SERIAL_NUMBER}

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable    ${BTS_all_alias_list}
    FOR  ${alias}  IN  @{BTS_all_alias_list}
        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${alias}  VDU
        Continue For Loop If  not ${is_vdu_alias}
        ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${RM_found}=  Set Variable If  ('${RMOD_SERIAL_NUMBER}' in ${RM_sn_list}) and ('${RMOD_SERIAL_NUMBER}' in ${shared_RMOD_sn_list})
        ...  ${TRUE}  ${FALSE}
        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=
        ...  VDU Get RMOD sn id pn interface info  ${alias}
        Set Test Variable  ${VDU_RMOD_id_sn_dict}
        ${RM_id}=  Get From Dictionary  ${VDU_RMOD_sn_id_dict}  ${RMOD_SERIAL_NUMBER}
        Return From Keyword If  '${RM_found}'=='${TRUE}'  ${RM_id}  ${alias}
        Exit For Loop If  ${RM_found}
    END

    Run Keyword If  not ${RM_found}  Run Keywords
    ...  Log Long String  Selected value ${RMOD_SERIAL_NUMBER} for test argument \${RMOD_SERIAL_NUMBER} is not valid. Please select a valid value for
    ...  test argument \${RMOD_SERIAL_NUMBER}. Must meet the following criteria: shared CPRI RMOD  level=ERROR
    ...  AND  Fail  Improper value for argument!

Get SBTS Cell info
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Save cross connection details
    [Arguments]  ${cross_connect}
    ${options}=  Get Cross Connection details  ${cross_connect}
    Set Test Variable  ${options}

Update Remained max wait time
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Set Test Variable  ${remained_MAX_WAIT_TIME}

Particular Teardown
    FOR  ${RMOD_SERIAL_NUMBER}  IN  @{RMOD_SERIAL_NUMBERS_list}
        ${cross_connect}=  Get From Dictionary  ${rmod_sn_crossconnection_dict}  ${RMOD_SERIAL_NUMBER}
        ${vdu_alias}=  Get From Dictionary  ${rmod_sn_cbts_vdu_alias_dict}  ${RMOD_SERIAL_NUMBER}
        ${cross_connect_status}=  Get Cross Connection Status by Id  ${cross_connect}
        Run Keyword If  '${cross_connect_status}'=='False'  Create Cross Connection with Options by Id  ${cross_connect}
        ...  group=${options['group']}  conn=${options['connid']}  dir=${options['dir'].lower()}  band=${options['band'][0]}
        ...  nolight=${options['nolight']}  deadreckon=${options['deadreckon']}
        Sleep  60s
        Check BTS cells are enabled online with exceptions
    END
    Teardown Optical Switch

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}
    Optical Switch Setup  switch_ip=${OPTICAL_SWITCH['IP']}
    ...  switch_username=${OPTICAL_SWITCH['USERNAME']}  switch_password=${OPTICAL_SWITCH['PASSWORD']}  port=${OPTICAL_SWITCH['PORT']}

TC Teardown
    Common Test Teardown
