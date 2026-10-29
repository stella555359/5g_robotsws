*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Check_automatic_switchover_after_BTS_update_to_active_role_CB014646
Variables    tc_variables/sbts_sbts__state__check_automatic_switchover_after_bts_update_to_active_role_cb014646_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}           3      # Number of testcase cycles to check automatic switchover after BTS update to active role. Default value 3
${RMOD_SERIAL_NUMBER_LIST}  ALL    # RM serial number list on which operation will be performed, separated by comma or ALL. Default value: ALL
                                   # - ALL: action will be performed on all RMODs (exempted CBRS RMODs)
${automaticSwitchoverTimer}  15    # Automatic switchover timer (seconds) defines how long the BTS waits from the moment when the conditions for the
                                   # automatic switchover are met until the redundancy role switch is executed. Default value 15 secs
${STABLE_TIME}               300   # Waiting time to check BTS stability after switchover. Default value 300 secs

*** Keywords ***
TC__SBTS_SBTS__STATE__Check_automatic_switchover_after_BTS_update_to_active_role_CB014646
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30315
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB014646: check perform BTS swithcover by locking LANE to RMOD on former active BTS - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get BTS redundancy role
    ...  - set both BTS to standby role
    ...  - lock LANE of RU on former active BTS and check no BTS switchover is performed
    ...  - set former active BTS back to active role and check switchover is performed
    ...  - unlock LANE of RU on former active BTS
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: feature CB014646 related to BTS automatic BTS switchover after former active BTS back to active role is working as expected
    ...  states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30315 - TC Creation
    ...

    Set Tags    CA-STATE    OWNER-robert.vesa@nokia.com   AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Get and check CB014646 feature settings
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}
            Log  ==============================================================================  console=True
            Log  Cycle ${INDEX} - Perform test action on RU ${RMOD_sn}  console=True
            Log  ==============================================================================  console=True
            Log  ==============================================================================  console=True
            Step 5: Set Both BTS to start in standby role
            Step 6: Lock Lane for RU ${RMOD_sn} on former Active BTS and check both BTS remain standby
            Step 7: Set former active BTS back to active role
            Step 8: Check BTS switchover is performed
            Step 9: Unlock Lane for RU ${RMOD_sn} on former Active BTS
            Step 10: Check final all BTS state
            Step 11: Check final all BTS alarms
            Step 12: Check final number and state of Cells and RMs
        END
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    ${RMOD_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_sn_list}

    ${RMOD_sn_list}=  Run Keyword If  '${RMOD_SERIAL_NUMBER_LIST}' != 'ALL'
    ...  Check item list  RMOD_SERIAL_NUMBER_LIST  ${RMOD_sn_list}
    ...  ELSE
    ...  Set Variable  ${RMOD_sn_list}
    Set Test Variable  ${RMOD_sn_list}

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    ${all_roles}=  Get Dictionary Values  ${BTS_alias_redundancyRole_dict}
    Run Keyword If  'active' not in ${all_roles}  Fail  No BTS has active role! Please check BTSs initial states before starting the test!
    ${BTS_initial_active_alias}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
    Set Test Variable  ${BTS_initial_active_alias}

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole

        Run Keyword If  '${BTS_redundancyRole}' == 'active'  Run Keywords
        ...  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        ...  AND  Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - proceduralState: OnAir, blockingState: Unblocked  console=True
        ...  ELSE IF  '${BTS_redundancyRole}' == 'standby'  Run Keywords
        ...  Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_}  ${Unblocked_}  alias=${alias}
        ...  AND  Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - proceduralState: IntegratedToRan, blockingState: Unblocked
        ...  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole

        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

        Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_sn_id_info}  ${all_BTS_RMOD_id_sn_info}  ${all_BTS_RMOD_sn_interface_info}=  Get all BTS RMOD sn id info
    Set Test Variable  ${all_BTS_RMOD_sn_id_info}
    Set Test Variable  ${all_BTS_RMOD_id_sn_info}
    Set Test Variable  ${all_BTS_RMOD_sn_interface_info}

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_non_CBRS_RMOD_id_info}  ${all_BTS_non_CBRS_RMOD_sn_info}=  Get all BTS non-CBRS RMOD info
    Set Test Variable  ${all_BTS_non_CBRS_RMOD_id_info}
    Set Test Variable  ${all_BTS_non_CBRS_RMOD_sn_info}

    Check non-CBRS RMOD info

Step ${index}: Get and check CB014646 feature settings
    Log  Step ${index}: Get and check CB014646 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        Set Test Variable  ${initial_${alias}_CB014646_feature_dict}  ${BTS_CB014646_feature_dict}

        Log  Check CB014646 feature settings on BTS ${alias}  console=True

        Set BTS CB014646 feature parameters  actAutomaticSwitchover  true  ${alias}
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${automaticSwitchoverTimer}  ${alias}
        Set BTS CB014646 feature parameters  minCellAvailability  100  ${alias}

    END

Step ${index}: Set Both BTS to start in standby role
    Log  Step ${index}: Set Both BTS to start in standby role  console=True

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Run Keyword If  '${BTS_redundancyRole}' == 'active'  Set Test Variable  ${start_BTS_active_alias}  ${alias}
        Run Keyword If  '${BTS_redundancyRole}' == 'standby'  Set Test Variable  ${start_BTS_standby_alias}  ${alias}
    END

    Run Keyword If  '${start_BTS_active_alias}' == '' or '${start_BTS_standby_alias}' == ''
    ...  Run Keywords
    ...  Log Long String  Expected one active BTS and one standby BTS,
    ...  but got: active BTS: ${start_BTS_active_alias}, standby BTS: ${start_BTS_standby_alias}  level=ERROR
    ...  AND  Fail  Start conditions not met. Active BTS: ${start_BTS_active_alias}, Standby BTS: ${start_BTS_standby_alias}

    Log  Current active BTS: ${start_BTS_active_alias}, standby BTS: ${start_BTS_standby_alias}  console=True

    Log  Set CB014646 feature parameters on BTS ${alias}: redundancyRole=standby  console=True
    Set BTS CB014646 feature parameters  redundancyRole  standby  ${start_BTS_active_alias}

    Log  Check that both BTS keep standby role for 150s  console=True
    Get Current Time  initial
    FOR  ${count}  IN RANGE  0  100
        Sleep  10s
        FOR  ${alias}  IN  @{alias_list}
            Check BTS redundancyRole  expected_role=standby  alias=${alias}
        END
        Get Current Time  current
        ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_current}  ${time_initial}  number
        ${remained_time}=  BuiltIn.Evaluate  150 - ${elapsed_time}
        Exit For Loop If  ${remained_time} <= 0
    END
    Log  Both BTS kept standby role for 150s. Check successfully completed!  console=True

Step ${index}: Lock Lane for RU ${RMOD_sn} on former Active BTS and check both BTS remain standby
    Log  Step ${index}: Lock Lane for RU ${RMOD_sn} on former Active BTS and check both BTS remain standby  console=True

    ${BTS_RMOD_sn_id_dict}=  Get From Dictionary  ${all_BTS_RMOD_sn_id_info}  ${start_BTS_active_alias}
    ${RMOD_id}=  Get From Dictionary  ${BTS_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_ID}
    Get BTS MODULE LANE info dict  RMOD  ${start_BTS_active_alias}
    Perform LANE operation  ${RMOD_ID}  Lock  ${start_BTS_active_alias}
    Sleep  10s

    Log  Check both BTS remain standby after locking LANE of RU ${RMOD_sn} on former Active BTS ${start_BTS_active_alias} for 300s
    ...  console=True

    Get Current Time  initial
    FOR  ${count}  IN RANGE  0  100
        Sleep  10s
        ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
        FOR  ${alias}  IN  @{BTS_alias_redundancyRole_dict}
            Run Keyword If  '${BTS_alias_redundancyRole_dict}[${alias}]' == 'active'  Run Keywords
            ...  Log  ERROR: BTS ${alias} changed role to active after locking RMOD ${RMOD_sn} LANE on former Active BTS!  level=ERROR
            ...  AND  Fail  BTS ${alias} changed role unexpectedly after locking RMOD ${RMOD_sn} LANE on former Active BTS ${start_BTS_active_alias}!
        END
        Get Current Time  current
        ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_current}  ${time_initial}  number
        ${remained_time}=  BuiltIn.Evaluate  300 - ${elapsed_time}
        Exit For Loop If  ${remained_time} <= 0
    END

    Log  Check succesfully completed! Both BTS remained in standby role for 300s  console=True

Step ${index}: Set former active BTS back to active role
    Log  Step ${index}: Set former active BTS back to active role  console=True

    Set BTS CB014646 feature parameters  redundancyRole  active  ${start_BTS_active_alias}

    Check BTS redundancyRole  expected_role=active  alias=${start_BTS_active_alias}
    Check BTS redundancyRole  expected_role=standby  alias=${start_BTS_standby_alias}

Step ${index}: Check BTS switchover is performed
    Log  Step ${index}: Check BTS switchover is performed  console=True

    Check BTS switchover behaviour  True  ${start_BTS_standby_alias}  ${start_BTS_active_alias}  ${STABLE_TIME}

Step ${index}: Unlock Lane for RU ${RMOD_sn} on former Active BTS
    Log  Step ${index}: Unlock Lane for RU ${RMOD_sn} on former Active BTS  console=True

    Perform LANE operation  ${RMOD_ID}  Unlock  ${start_BTS_active_alias}
    Sleep  10s

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states
    ...  - RTWP_check is not performed in this test case, because final active BTS might differ from the initial active BTS

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks  RTWP_check=${FALSE}

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
    ...  from configured items: ${item_list} or let default value  level=ERROR
    ...  AND  Fail  Improper value for argument!

    [Return]  ${item_valid_list}

Check RM serial number list

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${all_RM_sn_list}=  Combine Lists   ${shared_RM_sn_list}  ${dedicated_RM_sn_list}

    Run Keyword If  'ALL' in '${RMOD_SERIAL_NUMBER_LIST}'  Return From Keyword

    ${RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SERIAL_NUMBER_LIST}=  Split String  ${RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List
    ${RM_SN_no_serial_list}=  Create List
    FOR  ${item}  IN  @{RMOD_SERIAL_NUMBER_LIST}
        ${RM_sn_check}=  Set Variable If  '${item}' not in ${all_RM_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${item}' not in ${all_RM_sn_list}  Append To List  ${RM_sn_invalide_list}  ${item}
    END
    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RMOD_SERIAL_NUMBER_LIST} from configured RM: ${all_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${RMOD_SERIAL_NUMBER_LIST}

Check BTS redundancyRole
    [Arguments]  ${expected_role}  ${alias}

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    Should Be Equal  ${BTS_alias_redundancyRole_dict}[${alias}]  ${expected_role}

Get all BTS RMOD sn id info
    ${all_BTS_RMOD_sn_id_info}=  Create Dictionary
    ${all_BTS_RMOD_id_sn_info}=  Create Dictionary
    ${all_BTS_RMOD_sn_interface_info}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}=  Admin Get RMOD sn id pn interface info
        ...  alias=${alias}
        Set To Dictionary  ${all_BTS_RMOD_sn_id_info}  ${alias}  ${BTS_RMOD_sn_id_dict}
        Set To Dictionary  ${all_BTS_RMOD_id_sn_info}  ${alias}  ${BTS_RMOD_id_sn_dict}
        Set To Dictionary  ${all_BTS_RMOD_sn_interface_info}  ${alias}  ${BTS_RMOD_sn_interface_dict}

    END

    [Return]  ${all_BTS_RMOD_sn_id_info}  ${all_BTS_RMOD_id_sn_info}  ${all_BTS_RMOD_sn_interface_info}

Check BTS role switchover
    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    Should Be Equal  ${BTS_alias_redundancyRole_dict}[${start_BTS_active_alias}]  standby
    Should Be Equal  ${BTS_alias_redundancyRole_dict}[${start_BTS_standby_alias}]  active

Check BTS switchover behaviour
    [Arguments]  ${exp_switchover}  ${exp_BTS_redundancyRole_active}  ${exp_BTS_redundancyRole_standby}  ${timeout}

    Log  ***** Check BTS switchover behaviour *****  console=True

    Sleep  ${automaticSwitchoverTimer}s  Wait automaticSwitchoverTimer
    Run Keyword If  '${exp_switchover}' == 'True'
    ...  Sleep  120s  Wait for BTS switchover completed

    Get Current Time  initial

    FOR  ${count}  IN RANGE  0  100

        ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
        ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
        ${BTS_redundancyRole_standby}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  standby

        Should be equal  ${BTS_redundancyRole_active}  ${exp_BTS_redundancyRole_active}
        Should be equal  ${BTS_redundancyRole_standby}  ${exp_BTS_redundancyRole_standby}

        Sleep  10s  Wait 10 seconds before next check

        Get Current Time  current
        ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_current}  ${time_initial}  number
        ${remained_time}=  BuiltIn.Evaluate  ${timeout} - ${elapsed_time}
        Exit For Loop If  ${remained_time} <= 0

    END

    Run Keyword If  '${exp_switchover}' == 'True'
    ...  Log  Check BTS switchover behaviour passed -> BTS switchover occurred  console=True
    ...  ELSE IF  '${exp_switchover}' == 'False'
    ...  Log  Check BTS switchover behaviour passed -> No BTS switchover occurred  console=True

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    Display BTS redundancyRole info  ${BTS_alias_redundancyRole_dict}

Display BTS redundancyRole info
    [Arguments]  ${BTS_alias_redundancyRole_dict}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_alias_redundancyRole_dict}  ${alias}
        Log  BTS ${alias} redundancyRole: ${BTS_redundancyRole}  console=True

    END

Get all BTS non-CBRS RMOD info
    ${all_BTS_non_CBRS_RMOD_id_info}=  Create Dictionary
    ${all_BTS_non_CBRS_RMOD_sn_info}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${CBRS_cell_id_list}=  Get BTS CBRS cell info  ${alias}
        ${BTS_non_CBRS_RMOD_id_list}  ${BTS_non_CBRS_RMOD_sn_list}=  Get BTS non-CBRS RMOD info  ${CBRS_cell_id_list}  ${alias}
        Set To Dictionary  ${all_BTS_non_CBRS_RMOD_id_info}  ${alias}  ${BTS_non_CBRS_RMOD_id_list}
        Set To Dictionary  ${all_BTS_non_CBRS_RMOD_sn_info}  ${alias}  ${BTS_non_CBRS_RMOD_sn_list}

    END

    [Return]  ${all_BTS_non_CBRS_RMOD_id_info}  ${all_BTS_non_CBRS_RMOD_sn_info}

Get BTS CBRS cell info
    [Arguments]  ${alias}

    ${CBRS_NR_cell_id_list}=  Get CBRS NR cell info  ${alias}
    ${CBRS_LTE_cell_id_list}=  Get CBRS LTE cell info  ${alias}
    ${CBRS_cell_id_list}=  Combine Lists  ${CBRS_NR_cell_id_list}  ${CBRS_LTE_cell_id_list}

    [Return]  ${CBRS_cell_id_list}

Get BTS non-CBRS RMOD info
    [Arguments]  ${CBRS_cell_id_list}  ${alias}

    ${BTS_non_CBRS_RMOD_id_list}=  Create List
    ${BTS_non_CBRS_RMOD_sn_list}=  Create List

    ${BTS_RMOD_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}

    FOR  ${RMOD_id}  IN  @{BTS_RMOD_id_list}

        ${BTS_RMOD_id_sn_dict}=  Get From Dictionary  ${all_BTS_RMOD_id_sn_info}  ${alias}
        ${RMOD_sn}=  Get From Dictionary  ${BTS_RMOD_id_sn_dict}  ${RMOD_id}

        ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
        ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
        ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
        ${RMOD_NR_cell_id_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${RMOD_id}
        ${RMOD_LTE_cell_id_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${RMOD_id}
        ${RMOD_cell_id_list}=  Combine Lists  ${RMOD_NR_cell_id_list}  ${RMOD_LTE_cell_id_list}

        ${non_CBRS_RMOD_check}=  Check BTS non-CBRS RMOD info  ${RMOD_cell_id_list}  ${CBRS_cell_id_list}

        Run Keyword If  ${non_CBRS_RMOD_check}  Run Keywords
        ...  Append To List  ${BTS_non_CBRS_RMOD_id_list}  ${RMOD_id}
        ...  AND  Append To List  ${BTS_non_CBRS_RMOD_sn_list}  ${RMOD_sn}

    END

    [Return]  ${BTS_non_CBRS_RMOD_id_list}  ${BTS_non_CBRS_RMOD_sn_list}

Check BTS non-CBRS RMOD info
    [Arguments]  ${RMOD_cell_id_list}  ${CBRS_cell_id_list}

    ${non_CBRS_RMOD_check}=  Set Variable  ${True}

    FOR  ${cell_id}  IN  @{RMOD_cell_id_list}

        ${non_CBRS_RMOD_check}=  Set Variable If  '${cell_id}' in ${CBRS_cell_id_list}  ${False}  ${non_CBRS_RMOD_check}
        Exit For Loop If  not ${non_CBRS_RMOD_check}

    END

    [Return]   ${non_CBRS_RMOD_check}

Check non-CBRS RMOD info

    ${RMOD_check}=  Set Variable  True
    ${RMOD_valid_list}=  Create List
    ${RMOD_invalid_list}=  Create List
    ${all_BTS_non_CBRS_RMOD_sn_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_non_CBRS_RMOD_sn_info}=  Get From Dictionary  ${all_BTS_non_CBRS_RMOD_sn_info}  ${alias}
        Append To List  ${all_BTS_non_CBRS_RMOD_sn_list}  @{BTS_non_CBRS_RMOD_sn_info}

    END

    ${all_BTS_non_CBRS_RMOD_sn_list}=  Remove Duplicates  ${all_BTS_non_CBRS_RMOD_sn_list}

    ${RMOD_sn_list}=  Set Variable If  '${RMOD_SERIAL_NUMBER_LIST}' == 'ALL'  ${all_BTS_non_CBRS_RMOD_sn_list}  ${RMOD_sn_list}
    Return From Keyword If  '${RMOD_SERIAL_NUMBER_LIST}' == 'ALL'

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${RMOD_check}=  Set Variable If  '${RMOD_sn}' not in ${all_BTS_non_CBRS_RMOD_sn_list}  False  ${RMOD_check}
        Run Keyword If  '${RMOD_sn}' in ${all_BTS_non_CBRS_RMOD_sn_list}
        ...  Append To List  ${RMOD_valid_list}  ${RMOD_sn}
        ...  ELSE
        ...  Append To List  ${RMOD_invalid_list}  ${RMOD_sn}

    END

    Run Keyword If  '${RMOD_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RMOD serial number values are not valid: ${RMOD_invalid_list}. Please select values for test argument
    ...  \${RMOD_SERIAL_NUMBER_LIST} from configured items: ${all_BTS_non_CBRS_RMOD_sn_list} or let default value  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RMOD_sn_list}  ${RMOD_valid_list}

Check if all BTS LANEs are unlocked
    FOR  ${alias}  IN  @{alias_list}

        Admin Check if BTS LANEs are unlocked  ${alias}

    END

Recover BTS CB014646 feature initial settings
    FOR  ${alias}  IN  @{alias_list}
        Log  Recover CB014646 feature initial settings on BTS ${alias}  console=True
        ${initial_actAutomaticSwitchover}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  actAutomaticSwitchover
        Set BTS CB014646 feature parameters  actAutomaticSwitchover  ${initial_actAutomaticSwitchover}  ${alias}
        ${initial_automaticSwitchoverTimer}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  automaticSwitchoverTimer
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${initial_automaticSwitchoverTimer}  ${alias}
        ${initial_minCellAvailability}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  minCellAvailability
        Set BTS CB014646 feature parameters  minCellAvailability  ${initial_minCellAvailability}  ${alias}
    END

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    ${all_roles}=  Get Dictionary Values  ${BTS_alias_redundancyRole_dict}
    Run Keyword If  'active' not in ${all_roles}  Run Keywords
    ...  Log  No BTS has active role! Setting active role for BTS ${BTS_initial_active_alias}  console=True
    ...  AND  Set BTS CB014646 feature parameters  redundancyRole  active  ${BTS_initial_active_alias}
    ...  AND  Sleep  60s

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS LANEs are unlocked
    Recover BTS CB014646 feature initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown