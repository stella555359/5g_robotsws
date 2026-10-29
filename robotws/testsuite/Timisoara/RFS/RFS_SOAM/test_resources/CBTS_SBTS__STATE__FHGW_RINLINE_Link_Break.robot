*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
Variables    tc_variables/cbts_sbts__state__fhgw_rinline_link_break_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             3         # Number of link break/restore between FHGW and RINLINE operations, default value 3
${FHGW_ID_CUSTOM_list}        ALL       # Custom FHGW id list on which connection with RINLINE should be cut. Possible values (by default ALL):
                                        # - ALL: action will be performed on all FHGW defined in init.py
                                        # - list of selected FHGW id separated by comma.
${SWITCH_USER_LINK_DOWN_list}           # List of switch users for for link break between each FHGW of ${FHGW_ID_CUSTOM_list} and RINLINE,
                                        # ex. cmntrl144-down-C4
${SWITCH_PASSWORD_LINK_DOWN_list}       # List of switch passwords for link break between each FHGW of ${FHGW_ID_CUSTOM_list} and RINLINE, ex.
                                        # Aikon_144-down
${SWITCH_USER_LINK_UP_list}             # List of switch users for for link restore between each FHGW of ${FHGW_ID_CUSTOM_list} and RINLINE, ex.
                                        # cmntrl144-up-C4
${SWITCH_PASSWORD_LINK_UP_list}         # List of Switch password for link restore between each FHGW ${FHGW_ID_CUSTOM_list} and RINLINE, ex.
                                        # Aikon_144-up
${SWITCH_IP_ADDRESS_list}               # List of switch IP addresses for switch(es) connecting each FHGW of ${FHGW_ID_CUSTOM_list} and RINLINE
${BTS_MAX_WAIT_TIME}          240       # Maximum time to wait for BTS checks after link break/restore between FHGW and RINLINE (by default 240)

*** Keywords ***
TC__CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27702
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for link break/restore between FHGW and RINLINE through Switch action - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: RMOD sharing info
    ...  - perform link break between FHGW and RINLINE through Switch action checking BTS states and alarms
    ...  - perform link restore between FHGW and RINLINE through Switch action checking BTS states and alarms
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: link break/restore between FHGW and RINLINE works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27702 -
    ...  [CBTS][CB009382]- New TCRFS_vRAN-SRAN_link_failure_between_RINLINE2_and_FHGW
    ...  - 09.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28199
    ...  [CBTS] CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break fail because ssh authentification fails
    ...  - 12.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30106
    ...  Enhancement for CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break ,if not all RMODs are connected to FHGW - after TAT-29959,TAT-29957

    Set Tags    CA-STATE    OWNER-violeta.zanfirescu@nokia.com   AUTHOR-georgiana.stefan@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        FOR  ${FHGW_data_set}  IN  @{input_variable_list}
            Set Test Variable  ${FHGW_data_set}
            Step 4: Get FHGW related info
            Step 5: Perform link break between FHGW and RINLINE through Switch action
            Step 6: Perform link restore between FHGW and RINLINE through Switch action
            Step 7: Check final all BTS states
            Step 8: Check final all BTS alarms
            Step 9: Check final number and state of Cells and RMs
        END
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${variable_list}=  Create List
    ...  FHGW_ID_CUSTOM_list_detailed
    ...  SWITCH_USER_LINK_DOWN_list
    ...  SWITCH_PASSWORD_LINK_DOWN_list
    ...  SWITCH_USER_LINK_UP_list
    ...  SWITCH_PASSWORD_LINK_UP_list
    ...  SWITCH_IP_ADDRESS_list

    ${initial_item_number}=  Set Variable  ${0}
    ${condition_fail_list}=  Create List
    ${input_variable_list}=  Create List

    ${FHGW_ID_CUSTOM_list_detailed}=  Run Keyword If  '${FHGW_ID_CUSTOM_list}' == 'ALL'
    ...  Get configured FHGW id list from init file
    ...  ELSE  Set Variable  ${FHGW_ID_CUSTOM_list}
    ${FHGW_ID_CUSTOM_list_detailed}=  Run Keyword If  '${FHGW_ID_CUSTOM_list}' == 'ALL'
    ...  Catenate  SEPARATOR=,  @{FHGW_ID_CUSTOM_list_detailed}
    ...  ELSE  Set Variable  ${FHGW_ID_CUSTOM_list_detailed}
    Set Test Variable  ${FHGW_ID_CUSTOM_list_detailed}

    FOR  ${variable}  IN  @{variable_list}
        ${condition_value_present}  ${condition_fail_text}  ${item_number}  ${item_value_list}=
        ...  Create check condition message and value lists  ${variable}

        ${initial_item_number}=  Set Variable If  ${initial_item_number} == ${0}
        ...  ${item_number}  ${initial_item_number}

        ${condition_number_of_values}=  Create Long String  ${item_number} != ${initial_item_number}
        ${error_message_number_of_values}=  Create Long String
        ...  Number of items in parameter \$\{${variable} (${item_number})\}
        ...  is different than number of items in \$\{${variable_list}[${0}]\}

        Run Keyword If  ${condition_value_present}  Run Keywords
        ...  Log  ${condition_fail_text}  level=ERROR
        ...  AND  Append to List  ${condition_fail_list}  ${condition_fail_text}
        ...  AND  Continue For Loop
        ...  ELSE IF  ${condition_number_of_values}
        ...  Run Keywords
        ...  Log  ${error_message_number_of_values}  level=ERROR
        ...  AND  Append to List  ${condition_fail_list}  ${error_message_number_of_values}
        ...  AND  Continue For Loop

        FOR  ${index}  ${item}  IN ENUMERATE  @{item_value_list}
            ${element}=  Create Dictionary
            ${variable_name}=  Split String  ${variable}  _list
            ${existing_variable_list_length}=  Get Length  ${input_variable_list}
            ${element}=  Set Variable If  ${existing_variable_list_length}>${index}  ${input_variable_list}[${index}]  ${element}
            Set To Dictionary  ${element}  ${variable_name[${0}]}=${item}
            ${existing_variable_list_length}=  Evaluate  ${existing_variable_list_length}-${1}
            Run Keyword If  ${index}>${existing_variable_list_length}
            ...  Append To List  ${input_variable_list}  ${element}
        END
    END
    Set Test Variable  ${input_variable_list}
    Log  ***** Input Variables *****  console=True
    Log  ${input_variable_list}  console=True
    Run Keyword If  ${condition_fail_list}
    ...  Fail  '${condition_fail_list}'

Create check condition message and value lists
    [Arguments]  ${actual_variable_name}
    ${variable_content}=  Get Variable Value  ${${actual_variable_name}}  ${None}

    Run Keyword If  '${variable_content}' == '${None}'
    ...  Fail  Variable \$\{${actual_variable_name}\} is not defined

    ${condition}=  Create Long String  '${${actual_variable_name}} '==' '
    ${condition_fail_text}=  Create Long String  At least 1 item in \$\{${actual_variable_name}\} needs to be indicated
    ${item_list}=  Strip String  ${variable_content}
    ${item_list}=  Split String  ${item_list}  ,
    ${item_number}=  Get Length  ${item_list}

    [Return]  ${condition}  ${condition_fail_text}  ${item_number}  ${item_list}

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

Step ${index}: Get BTS info for configured items
    [Documentation]
    ...  Get BTS info about following items:
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info

    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_all_alias_list}

    Set Test Variable  ${CBTS_VDU_RMOD_state_disabled}  Operational state=Disabled, Availability status=NotInstalled, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_disabled}
    ...  Operational state=Disabled, Availability status=Failed, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Get FHGW related info
    [Documentation]    Get information about RMOD and cells which are connected in FHGW and directly, for each BTS.

    Log  Step ${index}: Get FHGW related info  console=True

    Set Test Variable  ${FHGW_id}  ${FHGW_data_set}[FHGW_ID_CUSTOM]
    Set Test Variable  ${SWITCH_USER_LINK_DOWN}  ${FHGW_data_set}[SWITCH_USER_LINK_DOWN]
    Set Test Variable  ${SWITCH_PASSWORD_LINK_DOWN}  ${FHGW_data_set}[SWITCH_PASSWORD_LINK_DOWN]
    Set Test Variable  ${SWITCH_USER_LINK_UP}  ${FHGW_data_set}[SWITCH_USER_LINK_UP]
    Set Test Variable  ${SWITCH_PASSWORD_LINK_UP}  ${FHGW_data_set}[SWITCH_PASSWORD_LINK_UP]
    Set Test Variable  ${SWITCH_IP_ADDRESS}  ${FHGW_data_set}[SWITCH_IP_ADDRESS]

    ${FHGW_ip}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  IP
    ${FHGW_RMOD_sn_list}=  Get configured FHGW RMOD sn list from init file  ${FHGW_id}
    ${FHGW_RMOD_sn_count}=  Get Length  ${FHGW_RMOD_sn_list}
    Set Test Variable  ${FHGW_${FHGW_id}_RMOD_sn_count}  ${FHGW_RMOD_sn_count}

    ${aliases}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}

    FOR  ${bts_alias}  IN  @{aliases}
        ${rmod_sns}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${bts_alias}
        ${RMOD_NOT_FHGW_sn_list}=  Copy List  ${rmod_sns}
        Remove Values From List  ${RMOD_NOT_FHGW_sn_list}  @{FHGW_RMOD_sn_list}
        Set Test Variable  ${${bts_alias}_RMOD_NOT_FHGW_sn_list}  ${RMOD_NOT_FHGW_sn_list}

        ${RMOD_sn_id_dict}=  Get Variable Value  ${${bts_alias}_RMOD_sn_id_dict}
        ${RMOD_NOT_FHGW_id_list}=  Create List
        ${RMOD_FHGW_id_list}=  Create List
        ${CELL_NOT_FHGW_id_list}=  Create List
        ${CELL_FHGW_id_list}=  Create List

        FOR  ${sn}  IN  @{RMOD_NOT_FHGW_sn_list}
            ${id}=  Get Variable Value  ${RMOD_sn_id_dict}[${sn}]  ${None}
            Run Keyword If  '${id}' != '${None}'
            ...  Append To List  ${RMOD_NOT_FHGW_id_list}  ${id}
            ${NR_cell_list}=  Get Variable Value
            ...  ${all_BTS_RMOD_id_CELL_ids_info}[${bts_alias}][RMOD_id_NR_CELL_ids_dict][${id}]  ${None}
            Run Keyword If  ${NR_cell_list}
            ...  Append To List  ${CELL_NOT_FHGW_id_list}  @{NR_cell_list}

        END
        FOR  ${sn}  IN  @{FHGW_RMOD_sn_list}
            ${id}=  Get Variable Value  ${RMOD_sn_id_dict}[${sn}]  ${None}
            Run Keyword If  '${id}' != '${None}'
            ...  Append To List  ${RMOD_FHGW_id_list}  ${id}
            ${NR_cell_list}=  Get Variable Value
            ...  ${all_BTS_RMOD_id_CELL_ids_info}[${bts_alias}][RMOD_id_NR_CELL_ids_dict][${id}]  ${None}
            Run Keyword If  ${NR_cell_list}
            ...  Append To List  ${CELL_FHGW_id_list}  @{NR_cell_list}

        END

        Log  ${RMOD_NOT_FHGW_id_list}  console=True
        Log  ${RMOD_FHGW_id_list}  console=True
        Log  ${CELL_NOT_FHGW_id_list}  console=True
        Log  ${CELL_FHGW_id_list}  console=True
        Set Test Variable  ${${bts_alias}_RMOD_NOT_FHGW_id_list}  ${RMOD_NOT_FHGW_id_list}
        Set Test Variable  ${${bts_alias}_RMOD_FHGW_id_list}  ${RMOD_FHGW_id_list}
        Set Test Variable  ${${bts_alias}_CELL_NOT_FHGW_id_list}  ${CELL_NOT_FHGW_id_list}
        Set Test Variable  ${${bts_alias}_CELL_FHGW_id_list}  ${CELL_FHGW_id_list}

    END

Step ${index}: Perform link break between FHGW and RINLINE through Switch action
    [Documentation]
    ...  Perform link break between FHGW and RINLINE through Switch action checking both BTS states and alarms

    Log  Step ${index}: Perform link break between FHGW and RINLINE through Switch action  console=True

    ${command}=  Create Long String
    ...  sshpass -p ${SWITCH_PASSWORD_LINK_DOWN} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    ...  -tt ${SWITCH_USER_LINK_DOWN}@${SWITCH_IP_ADDRESS}
    Log  Perform link break between FHGW and RINLINE operation by following command on Switch: ${command}  console=True
    ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True  timeout=60
    Get Current Time  break

    Log  Check BTS states and alarms after link break between FHGW and RINLINE  console=True
    Check BTS states and alarms after link break between FHGW and RINLINE

Step ${index}: Perform link restore between FHGW and RINLINE through Switch action
    [Documentation]
    ...  Perform link restore between FHGW and RINLINE through Switch action checking both BTS states and alarms

    Log  Step ${index}: Perform link restore between FHGW and RINLINE through Switch action  console=True

    ${command}=  Create Long String
    ...  sshpass -p ${SWITCH_PASSWORD_LINK_UP} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    ...  -tt ${SWITCH_USER_LINK_UP}@${SWITCH_IP_ADDRESS}
    Log  Perform link restore between FHGW and RINLINE operation by following command on Switch: ${command}  console=True
    ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True  timeout=60
    Get Current Time  restore

    Log  Check BTS states and alarms after link restore between FHGW and RINLINE  console=True
    Check BTS states and alarms after link restore between FHGW and RINLINE

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS states and alarms after link break between FHGW and RINLINE

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS states and alarms after link break between FHGW and RINLINE  alias=${alias}
        ...  ELSE
        ...  Check cloud BTS states and alarms after link break between FHGW and RINLINE  vdu_alias=${alias}

    END

Check classical BTS states and alarms after link break between FHGW and RINLINE
    [Arguments]  ${alias}
    Log  Check ${alias} BTS status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    Log  Check ${alias} BTS cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}
    Check classical BTS cells operational status enabled  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${alias} BTS cells status:\n - operationalState=Enabled  console=True

    Log  Check ${alias} BTS alarms:  console=True
    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_LINK_BREAK}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_IGNORED_ALARMS_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after link break between FHGW and RINLINE
    [Arguments]  ${vdu_alias}
    Log  Check ${vdu_alias} RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}

    ${RMOD_NOT_FHGW_id_list}=  Get Variable Value  ${${vdu_alias}_RMOD_NOT_FHGW_id_list}  ${None}
    ${RMOD_FHGW_id_list}=  Get Variable Value  ${${vdu_alias}_RMOD_FHGW_id_list}  ${None}
    ${CELL_NOT_FHGW_id_list}=  Get Variable Value  ${${vdu_alias}_CELL_NOT_FHGW_id_list}  ${None}
    ${CELL_FHGW_id_list}=  Get Variable Value  ${${vdu_alias}_CELL_FHGW_id_list}  ${None}


    Log  \nChecking RMOD status Disabled for ${vdu_alias} RMOD connected to FHGW ${FHGW_id}:  console=True
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU RMODs expected states
    ...  rmod_runtime_id_list=${RMOD_FHGW_id_list}  vdu_alias=${vdu_alias}
    ...  availability_status=${CBTS_NotInstalled_}  administrative_state=${CBTS_Unlocked_}
    ...  operational_state=${CBTS_Disabled_}
    Log  ${vdu_alias} RMODs status ok: - ${CBTS_Disabled_} ${CBTS_NotInstalled_} ${CBTS_Unlocked_}  console=True

    Log  \nChecking RMOD status Enabled for ${vdu_alias} RMOD not connected to FHGW ${FHGW_id}:  console=True
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU RMODs expected states
    ...  rmod_runtime_id_list=${RMOD_NOT_FHGW_id_list}  vdu_alias=${vdu_alias}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}
    ...  operational_state=${CBTS_Enabled_}
    Log  ${vdu_alias} RMODs status ok: - ${CBTS_Enabled_} ${CBTS_Online_} ${CBTS_Unlocked_}  console=True

    Log  \nChecking ${vdu_alias} disabled cells status for Cells from RMODs connected to FHGW ${FHGW_id}:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU cells expected states
    ...  cell_id_list=${CELL_FHGW_id_list}  operational_state=${CBTS_Disabled_}
    ...  availability_status=${CBTS_Failed_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status ok: ${CBTS_Disabled_} ${CBTS_Failed_} ${CBTS_Unlocked_}  console=True

    Log  \nChecking ${vdu_alias} enabled cells status for Cells from RMODs not connected to FHGW ${FHGW_id}:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_break}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU cells expected states
    ...  cell_id_list=${CELL_NOT_FHGW_id_list}  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status ok: ${CBTS_Enabled_} ${CBTS_Online_} ${CBTS_Unlocked_}  console=True

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    ${VDU_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${vdu_alias_alarm.upper()}_EXPECTED_ALARMS_10}  ${FHGW_${FHGW_id}_RMOD_sn_count}
    ${VDU_IGNORED_ALARMS_full}=  Combine Lists  ${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}
    ...  ${${vdu_alias_alarm.upper()}_IGNORED_ALARMS_DURING_LINK_BREAK}
    Log  ${vdu_alias} "No connection to Unit (10)" alarm, expected number: ${FHGW_${FHGW_id}_RMOD_sn_count}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=@{VDU_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${VDU_IGNORED_ALARMS_full}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} "No connection to Unit (10)" alarm, found number: ${FHGW_${FHGW_id}_RMOD_sn_count}, as expected!  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms after link restore between FHGW and RINLINE

    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check classical BTS states and alarms after link restore between FHGW and RINLINE  alias=${alias}
        ...  ELSE
        ...  Check cloud BTS states and alarms after link restore between FHGW and RINLINE  vdu_alias=${alias}

    END

Check classical BTS states and alarms after link restore between FHGW and RINLINE
    [Arguments]  ${alias}

    Log  Check ${alias} BTS status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    Log  Check ${alias} BTS cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${alias} BTS cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after link restore between FHGW and RINLINE
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  VDU Check VDU Expected Status  operational_state=${CBTS_OnAir_}
    ...  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${CBTS_VDU_state_onair}  console=True

    Log  Check ${vdu_alias} RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all RMODs expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} RMODs status:\n - ${CBTS_VDU_RMOD_state_enabled}  console=True

    Log  Check ${vdu_alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_restore}  ${BTS_MAX_WAIT_TIME}
    Wait Until Keyword Succeeds  ${remained_MAX_WAIT_TIME}s  5s  Check cloud BTS VDU all cells expected states  operational_state=${CBTS_Enabled_}
    ...  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${vdu_alias}
    Log  ${vdu_alias} cells status:\n - ${CBTS_VDU_CELL_state_enabled}  console=True

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Particular Teardown
    FOR  ${FHGW_data_set}  IN  @{input_variable_list}
        ${SWITCH_USER_LINK_UP}=  Set Variable  ${FHGW_data_set}[SWITCH_USER_LINK_UP]
        ${SWITCH_PASSWORD_LINK_UP}=  Set Variable  ${FHGW_data_set}[SWITCH_PASSWORD_LINK_UP]
        ${SWITCH_IP_ADDRESS}=  Set Variable  ${FHGW_data_set}[SWITCH_IP_ADDRESS]
        ${command}=  Create Long String
        ...  sshpass -p ${SWITCH_PASSWORD_LINK_UP} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
        ...  -tt ${SWITCH_USER_LINK_UP}@${SWITCH_IP_ADDRESS}

        ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True  timeout=60
    END
    FOR  ${alias}  IN  @{BTS_all_alias_list}

        Run Keyword If  '${alias}' in ${alias_list}
        ...  Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
        ...  ELSE
        ...  Wait Until Keyword Succeeds  ${BTS_MAX_WAIT_TIME}s  30s  Check cloud BTS VDU all cells expected states
        ...  operational_state=${CBTS_Enabled_}  availability_status=${CBTS_Online_}  administrative_state=${CBTS_Unlocked_}  vdu_alias=${alias}

    END

Check cloud BTS VDU RMODs expected states
    [Arguments]  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_alias}
    ...  ${rmod_runtime_id_list}=${None}

    Return From Keyword If  not ${rmod_runtime_id_list}

    ${final_status}=  Set Variable  ${True}
    FOR  ${rmod_id}  IN  @{rmod_runtime_id_list}
        ${VDU_RMOD_check_status}=  Run Keyword And Return Status  VDU Check RMOD Expected Status  rmod_id=${rmod_id}
        ...  operational_state=${operational_state}  availability_status=${availability_status}
        ...  administrative_state=${administrative_state}  vdu_connection=${vdu_alias}
        ${final_status}=  Set Variable If  not ${VDU_RMOD_check_status}  ${VDU_RMOD_check_status}  ${final_status}
    END
    Should Be True  ${final_status}

Check cloud BTS VDU cells expected states
    [Arguments]  ${cell_id_list}  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_alias}

    Return From Keyword If  not ${cell_id_list}

    ${final_status}=  Set Variable  ${True}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${VDU_CELL_check_status}=  Run Keyword And Return Status  VDU Check Cell Expected Status  cell_id=${cell_id}
        ...  operational_state=${operational_state}  administrative_state=${administrative_state}
        ...  availability_status=${availability_status}
        ...  vdu_connection=${vdu_alias}
        ${final_status}=  Set Variable If  not ${VDU_CELL_check_status}  ${VDU_CELL_check_status}  ${final_status}
    END
    Should Be True  ${final_status}

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

