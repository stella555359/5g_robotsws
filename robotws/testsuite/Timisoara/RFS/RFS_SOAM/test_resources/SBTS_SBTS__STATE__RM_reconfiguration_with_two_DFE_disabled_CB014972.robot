*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RM_reconfiguration_with_two_DFE_disabled_CB014972
Variables    tc_variables/sbts_sbts__state__rm_reconfiguration_with_two_dfe_disabled_cb014972_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot
Library    ../../resources/python_resources/rmod_ssh.py  WITH NAME  rmod_ssh

*** Variables ***
${REPEAT_COUNTER}         3         # Number of AEHC RM operations. By default 3
${RM_SERIAL_NUMBER}                 # AEHC RM serial number on which operation will be performed.
${RM_CONNECTION_METHOD}   SSH       # Connection method for RM operation commands. Possible values: RSI or SSH. By default SSH
${DFE_ID_LIST}            0, 2      # Non-critical DFE id list for AEHC RM which will be disabled. Possible values: 0, 1, 2, 3, 4, 5, 6. By default 0
                                    # and 2. Restriction: avoid to select DFE ids 1 and 6 at the same time
${DELTA_FILE_REMOVE_NR_CELL}        # Delta file path for remove NR cell on selected AEHC RM serial number
${DELTA_FILE_ADD_NR_CELL}           # Delta file path for add NR cell on selected AEHC RM serial number
${L3_CALL_CHECK}          True      # Specifies if L3 call will be performed during testcase run. Possible values: True or False. By default True
${L3_CALL_KW_INFO}        &{EMPTY}  # L3 call KW info as dictionary with following structure:
                                    # - 'KW_resource_path':<path to specific resource where external KW is defined>
                                    # - 'KW_name':<external L3 call KW name to be run>
                                    # - 'KW_impact':<impact of external L3 call KW run on testcase run>
${L3_CALL_KW_ARGUMENTS}   &{EMPTY}  # L3 call KW arguments as dictionary containing arguments info for external L3 call KW
${MAX_WAIT_TIME}          900       # Maximum time to wait for RM recovery. By default 900 secs

*** Keywords ***
TC__SBTS_SBTS__STATE__RM_reconfiguration_with_two_DFE_disabled_CB014972
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30178
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for CB014972:
    ...  - Tolerated DFE failure on AEHC radio - Radio reconfiguration cell add dellete works even after 2 RU DFE are disabled
    ...
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get and check BTS info
    ...  - run crash DFE commands on RM checking in order to get DFE disabled
    ...  - remove and and cell on RM checking impact on BTS
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 08.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30178 -
    ...  [CB014972] [P2] : Tolerated DFE failure on AEHC radio - Radio reconfiguration cell add delete works even after 2 RU DFE are disabled
    ...  - 03.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30571 - RM SSH connection instead RSI

    Set Tags    CA-STATE    OWNER-vasile-valentin.stanomir@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get and check BTS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform RM reconfiguration with DFE disabled
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_RM_sn_dict}  ${RM_sn_BTS_alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RM_sn_dict}
    Set Test Variable  ${RM_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Set Test Variable  ${dedicated_RM_sn_list}

    Check RM info
    Run Keyword If  '${RM_CONNECTION_METHOD}' == 'RSI'  Check RM RSI flag status

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
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get and check BTS info
    Log  Step ${index}: Get and check BTS info  console=True

    ${all_BTS_controller_role_RM_sn_list}=  Get all BTS controller role for configured RMOD from SCF

    ${RM_BTS_primary_controller}=  Get BTS primary controller role  ${RM_SERIAL_NUMBER}  ${all_BTS_controller_role_RM_sn_list}
    Set Test Variable  ${RM_BTS_primary_controller}

    ${BTS_RM_sn_runtime_dn_dict}=  Get RM sn runtime info  ${RM_BTS_primary_controller}
    Set Test Variable  ${BTS_RM_sn_runtime_dn_dict}

    Log  Get and check BTS ${RM_BTS_primary_controller} actForceUnitAutoReset parameter  console=True
    ${actForceUnitAutoReset}=  Get BTS actForceUnitAutoReset parameter value  ${RM_BTS_primary_controller}
    Set Test Variable  ${initial_actForceUnitAutoReset}  ${actForceUnitAutoReset}
    Set BTS actForceUnitAutoReset parameter value  false  ${RM_BTS_primary_controller}

    Log  Get and check BTS ${RM_BTS_primary_controller} maintenanceWindow list  console=True
    ${maintenanceWindow_list}=  Get BTS maintenanceWindow list values  ${RM_BTS_primary_controller}
    Set Test Variable  ${initial_maintenanceWindow_list}  ${maintenanceWindow_list}
    Set BTS maintenanceWindow list values  alias=${RM_BTS_primary_controller}

    ${all_BTS_RM_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RM_id_CELL_ids_info}

    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RM_state_disabled_check}  operationalState=${Disabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_disabled}  operationalState=Disabled, administrativeState=Unlocked

    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, blockingState=Unblocked


Step ${index}: Perform RM reconfiguration with DFE disabled

    Log  Step ${index}: Perform RM reconfiguration with DFE disabled  console=True

    Run Keyword If  '${RM_CONNECTION_METHOD}' == 'SSH'
    ...  Perform RM operation via SSH  ${RM_SERIAL_NUMBER}
    ...  ELSE IF  '${RM_CONNECTION_METHOD}' == 'RSI'
    ...  Perform RM operation via RSI  ${RM_SERIAL_NUMBER}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM RSI flag status
    Run Keyword If  not ${USER_RSI_INFO_COLLECT}  Run Keywords
    ...  Log  Flag USER_RSI_INFO_COLLECT should be set True to establish RSI setup!  level=ERROR
    ...  AND  Fail  Flag USER_RSI_INFO_COLLECT should be set True to establish RSI setup!

Check RM info
    ${Non_critical_DFE_id_list}=  Create List  0  1  2  3  4  5  6

    ${selected_DFE_id_list}=  Check item list  DFE_ID_LIST  ${Non_critical_DFE_id_list}
    Set Test Variable  ${DFE_id_list}  ${selected_DFE_id_list}

    Run Keyword If  '1' in ${DFE_id_list} and '6' in ${DFE_id_list}  Run Keywords
    ...  Log Long String  Selected DFE id values: ${DFE_id_list} are not allowed (RU is considered non-functional if both DFE1 and DFE6 are not
    ...  operable at the same time). Please select different values for test arguments \${DFE_id_list} from: ${Non_critical_DFE_id_list} or let
    ...  default values  console=True
    ...  AND  Fail  Improper value for argument!

    Check AEHC RM serial number info

Check AEHC RM serial number info

    ${AEHC_RM_sn_list}=  Create List
    ${AEHC_check}=  Set Variable  ${FALSE}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RM_sn_id_dict}  ${BTS_RM_id_sn_dict}  ${BTS_RM_sn_pn_dict}  ${BTS_RM_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
        ...  alias=${alias}
        Set Test Variable  ${${alias}_RM_sn_id_dict}  ${BTS_RM_sn_id_dict}
        Set Test Variable  ${${alias}_RM_id_sn_dict}  ${BTS_RM_id_sn_dict}
        Set Test Variable  ${${alias}_RM_sn_pn_dict}  ${BTS_RM_sn_pn_dict}

        ${BTS_RM_pn_list}=  Get Dictionary Values  ${BTS_RM_sn_pn_dict}
        ${AEHC_check}=  Set Variable If  'AEHC' in ${BTS_RM_pn_list}  ${TRUE}  ${AEHC_check}

    END

    Run Keyword If  not ${AEHC_check}  Run Keywords
    ...  Log  No AEHC RM configured on any BTS!  console=True
    ...  AND  Fail  No AEHC RM configured on any BTS!

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_AEHC_RM_sn_list}=  Get BTS AEHC RM sn list  ${alias}
        Set Test Variable  ${${alias}_AEHC_RM_sn_list}  ${BTS_AEHC_RM_sn_list}
        ${AEHC_RM_sn_list}=  Combine Lists  ${AEHC_RM_sn_list}  ${BTS_AEHC_RM_sn_list}

    END

    ${AEHC_RM_sn_list}=  Remove Duplicates  ${AEHC_RM_sn_list}
    Set Test Variable  ${AEHC_RM_sn_list}

    Run Keyword If  '${RM_SERIAL_NUMBER}' == ''  Run Keywords
    ...  Log  No selected AEHC RM serial number. Please select value for test argument \${RM_SERIAL_NUMBER} from configured items: ${AEHC_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    Run Keyword If  '${RM_SERIAL_NUMBER}' not in ${AEHC_RM_sn_list}  Run Keywords
    ...  Log Long String  Selected RM serial number is not valid: ${RM_SERIAL_NUMBER}. Please select value for test argument \${RM_SERIAL_NUMBER}
    ...  from configured items: ${AEHC_RM_sn_list}  console=True
    ...  AND  Fail  Improper value for argument!

Get BTS AEHC RM sn list
    [Arguments]  ${alias}
    ${BTS_AEHC_RM_sn_list}=  Create List

    FOR  ${key}  ${value}  IN  &{${alias}_RM_sn_pn_dict}

        Run Keyword If  '${value}' == 'AEHC'
        ...  Append To List  ${BTS_AEHC_RM_sn_list}  ${key}

    END

    [Return]  ${BTS_AEHC_RM_sn_list}

Check item list
    [Arguments]  ${arg_name}  ${item_list}
    ${arg_item_list_strip}=  Replace String  ${${arg_name}}  ${SPACE}  ${EMPTY}
    ${arg_item_list_split}=  Split String  ${arg_item_list_strip}  ,
    ${item_check}=  Set Variable  True
    ${item_valid_list}=  Create List
    ${item_invalid_list}=  Create List

    FOR  ${item}  IN  @{arg_item_list_split}

        ${item_check}=  Set Variable If  '${item}' not in ${item_list}  False  ${item_check}
        Run Keyword If  '${item}' in ${item_list}
        ...  Append To List  ${item_valid_list}  ${item}
        ...  ELSE
        ...  Append To List  ${item_invalid_list}  ${item}

    END

    Run Keyword If  '${item_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected item values are not valid: ${item_invalid_list}. Please select values for test argument \${${arg_name}}
    ...  from configured items: ${item_list} or let default value  console=True
    ...  AND  Fail  Improper value for argument!

    [Return]  ${item_valid_list}

Perform RM operation via SSH
    [Arguments]  ${RM_sn}

    Get RM info from BTS  ${RM_sn}  initial
    Check RM DFE files before operation via SSH  ${RM_sn}  ${RM_BTS_primary_controller}
    Disable DFE on RM via SSH  ${RM_sn}  ${RM_BTS_primary_controller}
    Perform RM reconfiguration by remove and add cell  ${RM_sn}
    Perform call
    Check RM DFE files before operation via SSH  ${RM_sn}  ${RM_BTS_primary_controller}
    Perform RM reset on BTS  ${RM_sn}
    Perform call

Perform RM operation via RSI
    [Arguments]  ${RM_sn}

    ${RSI_setup_status}=  Check RSI setup status on RM  ${RM_sn}
    Run Keyword If  not ${RSI_setup_status}  Run Keywords
    ...  Log  No RM_${RM_sn} operation can be triggered due to failed RSI setup!  console=True
    ...  AND  Run Keyword And Continue On Failure  Fail  No RM_${RM_sn} operation can be triggered due to failed RSI setup!
    ...  AND  Return From Keyword

    Get RM info from BTS  ${RM_sn}  initial
    Check RM DFE files before operation via RSI  ${RM_sn}
    Disable DFE on RM via RSI  ${RM_sn}
    Perform RM reconfiguration by remove and add cell  ${RM_sn}
    Perform call
    Check RM DFE files before operation via RSI  ${RM_sn}
    Perform RM reset on BTS  ${RM_sn}
    Perform call

Check RSI setup status on RM
    [Arguments]  ${RM_sn}

    Log  Check RSI setup on RM_${RM_sn}:  console=True
    Run Keyword If  '${RM_sn}' in ${rsi_rmod_setup_list}  Run Keywords
    ...  Log  Successfully RSI setup on RM_${RM_sn}!  console=True
    ...  AND  Return From Keyword  ${TRUE}

    [Return]  ${FALSE}

Get RM info from BTS
    [Arguments]  ${RM_sn}  ${when}

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Set Test Variable  ${${alias}_RM_id}  ${RM_id}

        ${BTS_RM_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RM_id_CELL_ids_info}  ${alias}
        ${RM_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
        ${RM_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
        ${RM_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
        ${RM_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
        ${RM_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
        ${RM_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RM_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
        ${RM_NR_CELL_ids_list}=  Get From Dictionary  ${RM_id_NR_CELL_ids_dict}  ${${alias}_RM_id}
        ${RM_LTE_CELL_ids_list}=  Get From Dictionary  ${RM_id_LTE_CELL_ids_dict}  ${${alias}_RM_id}
        ${RM_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RM_id_LTE_IOT_CELL_ids_dict}  ${${alias}_RM_id}
        ${RM_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RM_id_LTE_IOT_SA_CELL_ids_dict}  ${${alias}_RM_id}
        ${RM_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RM_id_WCDMA_CELL_ids_dict}  ${${alias}_RM_id}
        ${RM_GSM_CELL_ids_list}=  Get From Dictionary  ${RM_id_GSM_CELL_ids_dict}  ${${alias}_RM_id}
        Set Test Variable  ${${alias}_${when}_RM_NR_CELL_ids_list}  ${RM_NR_CELL_ids_list}
        Set Test Variable  ${${alias}_${when}_RM_LTE_CELL_ids_list}  ${RM_LTE_CELL_ids_list}
        Set Test Variable  ${${alias}_${when}_RM_LTE_IOT_CELL_ids_list}  ${RM_LTE_IOT_CELL_ids_list}
        Set Test Variable  ${${alias}_${when}_RM_LTE_IOT_SA_CELL_ids_list}  ${RM_LTE_IOT_SA_CELL_ids_list}
        Set Test Variable  ${${alias}_${when}_RM_WCDMA_CELL_ids_list}  ${RM_WCDMA_CELL_ids_list}
        Set Test Variable  ${${alias}_${when}_RM_GSM_CELL_ids_list}  ${RM_GSM_CELL_ids_list}

    END

Check RM DFE files before operation via SSH
    [Arguments]  ${RM_sn}  ${alias}

    Log  Check and delete RM_${RM_sn} DFE files before operation  console=True
    Check and delete DFE failure files on RM via SSH  ${RM_sn}  ${alias}

Check RM DFE files before operation via RSI
    [Arguments]  ${RM_sn}

    Log  Check and delete RM_${RM_sn} DFE files before operation  console=True
    Check and delete DFE failure files on RM via RSI  ${RM_sn}

Get RM Uptime info
    [Arguments]  ${when}

    ${BTS_alias_RM_sn_Uptime_dict}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${${when}_BTS_alias_RM_sn_Uptime_dict}  ${BTS_alias_RM_sn_Uptime_dict}

Check RM reset behavior on BTS
    [Arguments]  ${RM_sn}

    ${RM_sn_list}=  Create List  ${RM_sn}
    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        ${initial_RM_sn_Uptime_dict}=  Get From Dictionary  ${initial_BTS_alias_RM_sn_Uptime_dict}  ${alias}
        ${final_RM_sn_Uptime_dict}=  Get From Dictionary  ${final_BTS_alias_RM_sn_Uptime_dict}  ${alias}
        Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RM_sn_list}
        ...  RMOD_sn_Uptime_dict_initial=${initial_RM_sn_Uptime_dict}  RMOD_sn_Uptime_dict_final=${final_RM_sn_Uptime_dict}  alias=${alias}

    END

Disable DFE on RM via SSH
    [Arguments]  ${RM_sn}  ${alias}

    Log  Disable DFE on RM_${RM_sn}  console=True

    FOR  ${num}  IN RANGE  1  4

        ${num_str}=  Set Variable If  ${num} == 1  first  ${num} == 2  second  ${num} == 3  third
        Log  Shutdown DFE on RM_${RM_sn}: ${num_str} time  console=True

        Get RM Uptime info  initial
        Shutdown DFE on RM via SSH  ${RM_sn}  ${alias}
        Check BTS status and alarms during shutdown DFE on RM  ${RM_sn}  initial
        Get RM Uptime info  final
        Check RM reset behavior on BTS  ${RM_sn}
        Run Keyword If  ${num} < 3
        ...  Perform RM reset on BTS  ${RM_sn}
        ...  ELSE
        ...  Perform RM reset on BTS  ${RM_sn}  cells_check=False

    END

    Check BTS status and alarms during disabled DFE on RM  ${RM_sn}  initial

Disable DFE on RM via RSI
    [Arguments]  ${RM_sn}

    Log  Disable DFE on RM_${RM_sn}  console=True

    FOR  ${num}  IN RANGE  1  4

        ${num_str}=  Set Variable If  ${num} == 1  first  ${num} == 2  second  ${num} == 3  third
        Log  Shutdown DFE on RM_${RM_sn}: ${num_str} time  console=True

        Get RM Uptime info  initial
        Shutdown DFE on RM via RSI  ${RM_sn}
        Check BTS status and alarms during shutdown DFE on RM  ${RM_sn}  initial
        Get RM Uptime info  final
        Check RM reset behavior on BTS  ${RM_sn}
        Run Keyword If  ${num} < 3
        ...  Perform RM reset on BTS  ${RM_sn}
        ...  ELSE
        ...  Perform RM reset on BTS  ${RM_sn}  cells_check=False

    END

    Check BTS status and alarms during disabled DFE on RM  ${RM_sn}  initial

Shutdown DFE on RM via SSH
    [Arguments]  ${RM_sn}  ${alias}

    ${ssh_session}=  rmod_ssh.Setup Rmod Ssh Connection  rmod_sn=${RM_sn}  bts_alias=${alias}

    FOR  ${DFE_id}  IN  @{DFE_id_list}

        Log  Shutdown DFE${DFE_id} on RM_${RM_sn}  console=True
        rmod_ssh.Execute Command On Rmod  rmod_sn=${RM_sn}  command_for_rmod=dfe-shutdown.sh ${DFE_id}

        Sleep  5s  Wait before next RM command

    END

    [Teardown]  rmod_ssh.Teardown Rmod Ssh Connection  rmod_sn=${RM_sn}

Shutdown DFE on RM via RSI
    [Arguments]  ${RM_sn}

    FOR  ${DFE_id}  IN  @{DFE_id_list}

        Log  Shutdown DFE${DFE_id} on RM_${RM_sn}  console=True

        ${rsi_dfe-shutdown_status}  ${rsi_dfe-shutdown_info}=  RSI Send Command  cmd=dfe-shutdown.sh ${DFE_id}  connection=${RM_sn}

        Run Keyword If  '${rsi_dfe-shutdown_status}' == 'PASS'
        ...  Log  - shutdown DFE${DFE_id} successfully finished!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Operation failed!  level=ERROR
        ...  AND  Fail  Operation failed!

        Sleep  5s  Wait before next RM command

    END

Check BTS status and alarms during shutdown DFE on RM
    [Arguments]  ${RM_sn}  ${when}

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        Log  Check BTS ${alias} alarms and status during shutdown DFE on RM_${RM_sn}:

        ${BTS_EXPECTED_ALARMS}=  Combine Lists  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_1907']}
        ...  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_1911']}

        Log  Check BTS ${alias} alarms:  console=True
        Log  BTS ${alias} "TX out of order (1907)" alarm, expected number: 1  console=True
        Log  BTS ${alias} "RX out of order (1911)" alarm, expected number: 1  console=True
        Get and Check Alarms SOAM  time=30 min  alias=${alias}  expected_alarms=${BTS_EXPECTED_ALARMS}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} "TX out of order (1907)" alarm, found number: 1, as expected!  console=True
        Log  BTS ${alias} "RX out of order (1911)" alarm, found number: 1, as expected!  console=True
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

        Check Alarm additional information  ${RM_sn}  ${alias}

        Log  Check BTS ${alias} cell(s) mapped on RM_${RM_sn}:  console=True
        ${RM_NR_CELL_count}=  Get Length  ${${alias}_${when}_RM_NR_CELL_ids_list}
        ${RM_LTE_CELL_count}=  Get Length  ${${alias}_${when}_RM_LTE_CELL_ids_list}
        ${RM_WCDMA_CELL_count}=  Get Length  ${${alias}_${when}_RM_WCDMA_CELL_ids_list}
        ${RM_GSM_CELL_count}=  Get Length  ${${alias}_${when}_RM_GSM_CELL_ids_list}
        Run Keyword If  ${RM_NR_CELL_count} > 0
        ...  Check cell status  NRCEL  ${${alias}_${when}_RM_NR_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  300  ${alias}
        Run Keyword If  ${RM_LTE_CELL_count} > 0
        ...  Check cell status  LNCEL  ${${alias}_${when}_RM_LTE_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  300  ${alias}
        Run Keyword If  ${RM_WCDMA_CELL_count} > 0
        ...  Check cell status  WNCEL  ${${alias}_${when}_RM_WCDMA_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  300  ${alias}
        Run Keyword If  ${RM_GSM_CELL_count} > 0
        ...  Check cell status  GNCEL  ${${alias}_${when}_RM_GSM_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  300  ${alias}
        Log  BTS ${alias} cells mapped on RM_${RM_sn} checked  console=True

    END

    Sleep  60s  Wait for RM stability

Check BTS status and alarms during disabled DFE on RM
    [Arguments]  ${RM_sn}  ${when}

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        Log  Check BTS ${alias} alarms and status during disabled DFE on RM_${RM_sn}:

        ${BTS_EXPECTED_ALARMS}=  Combine Lists  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_1907']}
        ...  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_1911']}  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_2935']}

        Log  Check BTS ${alias} alarms:  console=True
        Log  BTS ${alias} "TX out of order (1907)" alarm, expected number: 1  console=True
        Log  BTS ${alias} "RX out of order (1911)" alarm, expected number: 1  console=True
        Log  BTS ${alias} "Radio module hardware failure (2935)" alarm, expected number: 1  console=True
        Get and Check Alarms SOAM  time=30 min  alias=${alias}  expected_alarms=${BTS_EXPECTED_ALARMS}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} "TX out of order (1907)" alarm, found number: 1, as expected!  console=True
        Log  BTS ${alias} "RX out of order (1911)" alarm, found number: 1, as expected!  console=True
        Log  BTS ${alias} "Radio module hardware failure (2935)" alarm, found number: 1, as expected!  console=True
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

        Log  Check BTS ${alias} cell(s) mapped on RM_${RM_sn}:  console=True
        ${RM_NR_CELL_count}=  Get Length  ${${alias}_${when}_RM_NR_CELL_ids_list}
        ${RM_LTE_CELL_count}=  Get Length  ${${alias}_${when}_RM_LTE_CELL_ids_list}
        ${RM_WCDMA_CELL_count}=  Get Length  ${${alias}_${when}_RM_WCDMA_CELL_ids_list}
        ${RM_GSM_CELL_count}=  Get Length  ${${alias}_${when}_RM_GSM_CELL_ids_list}
        Run Keyword If  ${RM_NR_CELL_count} > 0
        ...  Check cell status  NRCEL  ${${alias}_${when}_RM_NR_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  600  ${alias}
        Run Keyword If  ${RM_LTE_CELL_count} > 0
        ...  Check cell status  LNCEL  ${${alias}_${when}_RM_LTE_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  600  ${alias}
        Run Keyword If  ${RM_WCDMA_CELL_count} > 0
        ...  Check cell status  WNCEL  ${${alias}_${when}_RM_WCDMA_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  600  ${alias}
        Run Keyword If  ${RM_GSM_CELL_count} > 0
        ...  Check cell status  GNCEL  ${${alias}_${when}_RM_GSM_CELL_ids_list}  ${CELL_state_degraded_check}  ${CELL_state_degraded}  600  ${alias}
        Log  BTS ${alias} cells mapped on RM_${RM_sn} checked  console=True

    END

Perform RM reset on BTS
    [Arguments]  ${RM_sn}  ${cells_check}=True

    Log  Perform reset RM_${RM_sn} on BTS ${RM_BTS_primary_controller} primary controller:  console=True
    coam.Reset Unit  dist_name=${${RM_BTS_primary_controller}_RM_id}  reset_type=Hard  timeout=${MAX_WAIT_TIME}
    ...  connection=${RM_BTS_primary_controller}  graceful_cell_shutdown=${TRUE}

    Return From Keyword If  '${cells_check}' != 'True'

    ${RM_BTS_alias_list}=  Get From Dictionary  ${RM_sn_BTS_alias_dict}  ${RM_sn}

    FOR  ${alias}  IN  @{RM_BTS_alias_list}

        Log  Check BTS ${alias} status and alarms after reset RM_${RM_sn}:  console=True

        Log  Check BTS ${alias} RM_${RM_sn}:  console=True
        Assert  class_name=RMOD  id=${${alias}_RM_id}  parameters=${RM_state_enabled_check}  timeout=${MAX_WAIT_TIME}  connection=${alias}
        Log  BTS ${alias} RM_${RM_sn} status:\n - ${RM_state_enabled}  console=True

        Log  Check BTS ${alias} cell(s):  console=True
        Check cells availability status online  ${alias}  300
        Log  BTS ${alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

        Log  Check BTS ${alias} alarms:  console=True
        Get and Check Alarms SOAM  wait_for_alarm_clear=15 min  alias=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

    Sleep  120s  Wait for RM uptime refresh in BTS

Perform RM reconfiguration by remove and add cell
    [Arguments]  ${RM_sn}

    Perform cell operation by delta recommissioning  Remove  ${DELTA_FILE_REMOVE_NR_CELL}  ${RM_sn}  ${RM_BTS_primary_controller}
    Perform cell operation by delta recommissioning  Add  ${DELTA_FILE_ADD_NR_CELL}  ${RM_sn}  ${RM_BTS_primary_controller}

Perform cell operation by delta recommissioning
    [Arguments]  ${operation}  ${delta_file}  ${RM_sn}  ${alias}

    Get RM Uptime info  initial

    Log  ${operation} cell by delta recommissioning on BTS ${alias}  console=True
    coam.Perform Delta Recommissioning  alias=${alias}  delta_file=${delta_file}  skip_parameter_relation_errors=False  should_activate=True
    Log  ${operation} cell by delta recommissioning on BTS ${alias} successfully performed  console=True

    Get RM info from BTS  ${RM_sn}  ${operation}

    Check NR cells info on BTS  ${operation}  ${alias}

    Check BTS status and alarms during disabled DFE on RM  ${RM_sn}  ${operation}

    Get RM Uptime info  final
    Check RM reset behavior on BTS  ${RM_sn}

Check NR cells info on BTS
    [Arguments]  ${operation}  ${alias}

    ${initial_RM_NR_CELL_count}=  Get Length  ${${alias}_initial_RM_NR_CELL_ids_list}
    ${new_RM_NR_CELL_count}=  Get Length  ${${alias}_${operation}_RM_NR_CELL_ids_list}

    ${NR_CELL_check}=  Set Variable If
    ...  '${operation}' == 'Remove' and ${new_RM_NR_CELL_count} != ${initial_RM_NR_CELL_count}  ${TRUE}
    ...  '${operation}' == 'Add' and ${new_RM_NR_CELL_count} == ${initial_RM_NR_CELL_count}  ${TRUE}
    ...  ${FALSE}

    Run Keyword If  ${NR_CELL_check}
    ...  Log  ${operation} NR cell on BTS ${alias} check passed  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${operation} NR cell on BTS ${alias} check failed!  level=ERROR
    ...  AND  Fail  ${operation} NR cell on BTS ${alias} check failed!

Perform call
    Run Keyword If  '${L3_CALL_CHECK}' != 'True'  Run Keywords
    ...  Log  No L3 call requested during test scenario. This step will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  Perform call  console=True

    ${KW_resource_path}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_resource_path
    ${KW_name}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_name
    ${KW_impact}=  Get From Dictionary  ${L3_CALL_KW_INFO}  KW_impact

    Log  =========================  console=True
    Log  L3 call selected KW name: ${KW_name}  console=True
    Log  =========================  console=True

    ${KW_status}=  Execute External KW  KW_resource_path=${KW_resource_path}  KW_name=${KW_name}  KW_args=${L3_CALL_KW_ARGUMENTS}

    Run Keyword If  '${KW_status}' == 'True'  Run Keywords
    ...  Log  L3 call successfully performed: ${KW_name} run passed  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${KW_impact}' == 'False'
    ...  Log  L3 call failed: ${KW_name} run failed  level=WARN
    ...  ELSE IF  '${KW_impact}' == 'True'  Run Keywords
    ...  Log  L3 call failed: ${KW_name} run failed  level=ERROR
    ...  AND  Fail  L3 call failed: ${KW_name} run failed

Check and delete DFE failure files on RM via SSH
    [Arguments]  ${RM_sn}  ${alias}

    ${DFE_path}=  Set Variable  /mnt/runtime
    ${DFE_file_1}=  Set Variable  node_failures_times.sha256
    ${DFE_file_2}=  Set Variable  node_failures_times.txt
    ${DFE_file_3}=  Set Variable  node_failures.txt
    ${DFE_file_4}=  Set Variable  dfe_failed_info.txt
    ${DFE_file_list}=  Create List  ${DFE_file_1}  ${DFE_file_2}  ${DFE_file_3}  ${DFE_file_4}

    ${ssh_session}=  rmod_ssh.Setup Rmod Ssh Connection  rmod_sn=${RM_sn}  bts_alias=${alias}

    FOR  ${DFE_file}  IN  @{DFE_file_list}

        ${ssh_ls_info}=  rmod_ssh.Execute Command On Rmod  rmod_sn=${RM_sn}  command_for_rmod=ls ${DFE_path}
        ${DFE_file_status}=  Run Keyword And Return Status  Should Not Contain  ${ssh_ls_info}  ${DFE_file}
        Continue For Loop If  ${DFE_file_status}

        rmod_ssh.Execute Command On Rmod  rmod_sn=${RM_sn}  command_for_rmod=sudo rm -f ${DFE_path}/${DFE_file}
        ${ssh_ls_info}=  rmod_ssh.Execute Command On Rmod  rmod_sn=${RM_sn}  command_for_rmod=ls ${DFE_path}
        ${DFE_file_status}=  Run Keyword And Return Status  Should Not Contain  ${ssh_ls_info}  ${DFE_file}

        Run Keyword If  ${DFE_file_status}
        ...  Log  - delete ${DFE_path}/${DFE_file} successfully finished!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Operation failed!  level=ERROR
        ...  AND  Fail  Operation failed!

        Sleep  1s  Wait before next RM command

    END

    [Teardown]  rmod_ssh.Teardown Rmod Ssh Connection  rmod_sn=${RM_sn}

Check and delete DFE failure files on RM via RSI
    [Arguments]  ${RM_sn}

    ${DFE_path}=  Set Variable  /mnt/runtime
    ${DFE_file_1}=  Set Variable  node_failures_times.sha256
    ${DFE_file_2}=  Set Variable  node_failures_times.txt
    ${DFE_file_3}=  Set Variable  node_failures.txt
    ${DFE_file_4}=  Set Variable  dfe_failed_info.txt
    ${DFE_file_list}=  Create List  ${DFE_file_1}  ${DFE_file_2}  ${DFE_file_3}  ${DFE_file_4}

    FOR  ${DFE_file}  IN  @{DFE_file_list}

        ${rsi_ls_status}  ${rsi_ls_info}=  RSI Execute Command  cmd=ls ${DFE_path}  connection=${RM_sn}
        ${DFE_file_status}=  Run Keyword And Return Status  Should Not Contain  ${rsi_ls_info}  ${DFE_file}
        Continue For Loop If  ${DFE_file_status}

        ${rsi_rm_status}  ${rsi_rm_info}=  RSI Send Command  cmd=rm ${DFE_path}/${DFE_file}  connection=${RM_sn}
        Run Keyword If  '${rsi_rm_status}' == 'PASS'
        ...  Log  - delete ${DFE_path}/${DFE_file} successfully finished!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Operation failed!  level=ERROR
        ...  AND  Fail  Operation failed!

        Sleep  1s  Wait before next RM command

        ${rsi_ls_status}  ${rsi_ls_info}=  RSI Execute Command  cmd=ls ${DFE_path}  connection=${RM_sn}
        Should Not Contain  ${rsi_ls_info}  ${DFE_file}

    END

Get BTS primary controller role
    [Arguments]  ${RM_sn}  ${all_BTS_controller_role_RM_sn_list}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_controller_RM_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RM_sn_list}  ${alias}
        ${BTS_primary_controller_RM_sn_list}=  Get From Dictionary  ${BTS_controller_RM_sn_list}  BTS_primary_controller_RMOD_sn_list

        Exit For Loop If  '${RM_sn}' in ${BTS_primary_controller_RM_sn_list}

    END

    ${RM_BTS_primary_controller}=  Set Variable  ${alias}

    [Return]  ${RM_BTS_primary_controller}

Get RM sn runtime info
    [Arguments]  ${alias}

    ${BTS_RM_sn_runtime_dn_dict}=  Create Dictionary

    ${BTS_info}=  Get Bts Info  connection=${alias}

    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}

        ${rm_info}=  Get From Dictionary  ${item}  id
        ${BTS_RM_runtime_dn}=  Get From Dictionary  ${rm_info}  runtime
        ${BTS_RM_sn}=  Get From Dictionary  ${item}  serialNumber

        Set To Dictionary  ${BTS_RM_sn_runtime_dn_dict}  ${BTS_RM_sn}  ${BTS_RM_runtime_dn}

    END

    [Return]  ${BTS_RM_sn_runtime_dn_dict}

Check Alarm additional information
    [Arguments]  ${RM_sn}  ${alias}

    ${DFE_alarm_list}=  Create List  1907  1911
    ${BTS_alarm_info}=  coam.Get Alarms  connection=${alias}

    ${RM_runtime_dn}=  Get From Dictionary  ${BTS_RM_sn_runtime_dn_dict}  ${RM_sn}

    FOR  ${item}  IN  @{BTS_alarm_info}

        ${faultId}=  Set Variable  ${item['faultId']}
        Continue For Loop If  '${faultId}' not in ${DFE_alarm_list}

        Log  Check BTS ${alias} FID${faultId} info:  console=True

        ${supplAlarmInfo_check}=  Set Variable If
       ...  '${faultId}' == '1907'
       ...  .*${RM_runtime_dn}.*16 TX faulty.*(DFE:R${DFE_id_list[0]},R${DFE_id_list[1]}|DFE:R${DFE_id_list[1]},R${DFE_id_list[0]}).*
       ...  '${faultId}' == '1911'
       ...  .*${RM_runtime_dn}.*16 RX faulty.*(DFE:R${DFE_id_list[0]},R${DFE_id_list[1]}|DFE:R${DFE_id_list[1]},R${DFE_id_list[0]}).*

        ${supplAlarmInfo}=  Set Variable  ${item['alarmInformation']['alarmAdditionalInfo']['supplAlarmInfo']}
        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${supplAlarmInfo}  ${supplAlarmInfo_check}
        Run Keyword If  ${status}
        ...  Log  BTS ${alias} check FID${faultId} passed, properly found specific field "Supplementary alarm information" info: ${supplAlarmInfo}!
        ...  console=True
        ...  ELSE  Run Keywords
        ...  Log  BTS ${alias} check FID${faultId} failed, not found specific field "Supplementary alarm information" info!  level=ERROR
        ...  AND  Fail  BTS ${alias} check FID${faultId} failed!

    END

Check cell status
    [Arguments]  ${cell_class_name}  ${cell_id_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${cell_id}  IN  @{cell_id_list}

        Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${cell_id} status:\n - ${cell_state}  console=True

    END

Recover RM by reset
    [Arguments]  ${RM_sn}

    ${RM_reset_recover}=  Set Variable  ${FALSE}
    ${DFE_alarm_list}=  Create List  1907  1911

    ${BTS_alarm_info}=  coam.Get Alarms  connection=${RM_BTS_primary_controller}

    FOR  ${item}  IN  @{BTS_alarm_info}

        Continue For Loop If  '${item['faultId']}' not in ${DFE_alarm_list}
        Continue For Loop If  '${item['alarmInformation']['serialNo']}' != '${RM_sn}'

        ${RM_reset_recover}=  Set Variable  ${TRUE}
        Exit For Loop

    END

    Run Keyword If  ${RM_reset_recover}  Run Keywords
    ...  Log  Perform reset RM_${RM_sn} as recovery action:  console=True
    ...  AND  Perform RM reset on BTS  ${RM_sn}

Recover BTS initial settings

    Log  Recover BTS ${RM_BTS_primary_controller} actForceUnitAutoReset parameter initial value  console=True
    Set BTS actForceUnitAutoReset parameter value  ${initial_actForceUnitAutoReset}  ${RM_BTS_primary_controller}

    Log  Recover BTS ${RM_BTS_primary_controller} maintenanceWindow list initial value  console=True
    ${maintenanceWindow_count}=  Get Length  ${initial_maintenanceWindow_list}
    Run Keyword If  ${maintenanceWindow_count} == 0
    ...  Set BTS maintenanceWindow list values  alias=${RM_BTS_primary_controller}
    ...  ELSE
    ...  Set BTS maintenanceWindow list values  daysOfWeek=${initial_maintenanceWindow_list[0]}
    ...  gracefulCellShutdown=${initial_maintenanceWindow_list[1]}  inUse=${initial_maintenanceWindow_list[2]}
    ...  startTime=${initial_maintenanceWindow_list[3]}  windowDuration=${initial_maintenanceWindow_list[4]}  alias=${RM_BTS_primary_controller}

Particular Teardown
    Run Keyword If  '${RM_CONNECTION_METHOD}' == 'SSH'
    ...  Check and delete DFE failure files on RM via SSH  ${RM_SERIAL_NUMBER}  ${RM_BTS_primary_controller}
    ...  ELSE IF  '${RM_CONNECTION_METHOD}' == 'RSI'
    ...  Check and delete DFE failure files on RM via RSI  ${RM_SERIAL_NUMBER}
    Recover RM by reset  ${RM_SERIAL_NUMBER}
    Recover BTS initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown