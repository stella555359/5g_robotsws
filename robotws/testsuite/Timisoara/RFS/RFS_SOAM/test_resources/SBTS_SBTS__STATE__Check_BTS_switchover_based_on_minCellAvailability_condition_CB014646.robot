*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Check_BTS_switchover_based_on_minCellAvailability_condition_CB014646
Variables    tc_variables/sbts_sbts__state__check_bts_switchover_based_on_minCellAvailability_condition_CB014646_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3     # Number of testcase cycles to check BTS switchover based on minCellAvailability condition. Default value 3
${RMOD_SERIAL_NUMBER_LIST}   ALL   # List of RMOD serial number list on which mapped cells will be disabled/enabled by lock/unlock Lane on active BTS.
                                   # Possible values (by default ALL):
                                   # - ALL: action will be performed on all RMODs (exempted CBRS RMODs) configured on active BTS
                                   # - list of selected RMOD serial number separated by comma
${automaticSwitchoverTimer}  15    # Automatic switchover timer (seconds) defines how long the BTS waits from the moment when the conditions for the
                                   # automatic switchover are met until the redundancy role switch is executed. Default value 15 secs
${STABLE_TIME}               900   # Waiting time to check BTS stability for switchover check. Default value 900 secs

*** Keywords ***
TC__SBTS_SBTS__STATE__Check_BTS_switchover_based_on_minCellAvailability_condition_CB014646
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30302
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB014646: check BTS switchover occurrence by minCellAvailability parameter change - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items
    ...  - get and check CB014646 feature settings
    ...  - trigger BTS switchover based on minCellAvailability condition
    ...    - get BTS redundancy role info
    ...    - set CB014646 feature parameter minCellAvailability=100 on active BTS
    ...    - disable cell(s) on active BTS by lock specific Lane checking BTS switchover is triggered
    ...    - enable cell(s) on previous impacted BTS by unlock specific Lane checking no BTS switchover back
    ...    - set CB014646 feature parameter minCellAvailability=10 on active BTS
    ...    - disable cell(s) on active BTS by lock specific Lane checking no BTS switchover is triggered
    ...    - set CB014646 feature parameter minCellAvailability=100 on active BTS
    ...    - check BTS switchover is triggered
    ...    - enable cell(s) on previous impacted BTS by unlock specific Lane checking no BTS switchover back
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: feature CB014646 related to BTS no switchover during cell block unblock works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30302 -
    ...  [CB014646] Trigger successful automatic switchover when minCellAvailability condition is met ->2604
    ...

    Set Tags    CA-STATE    OWNER-sergiu.silaghi@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Get and check CB014646 feature settings
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Trigger BTS switchover based on minCellAvailability condition
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
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

    ${emptyList}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        Set Test Variable  ${initial_${alias}_CB014646_feature_dict}  ${BTS_CB014646_feature_dict}

        Log  Check CB014646 feature settings on BTS ${alias}  console=True

        Set BTS CB014646 feature parameters  actAutomaticSwitchover  true  ${alias}
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${automaticSwitchoverTimer}  ${alias}
        Set BTS CB014646 feature parameters list  priorityNrCellsList  ${emptyList}  ${alias}
        Set BTS CB014646 feature parameters list  priorityLteCellsList  ${emptyList}  ${alias}

    END

Step ${index}: Trigger BTS switchover based on minCellAvailability condition

    Log  Step ${index}: Trigger BTS switchover based on minCellAvailability condition  console=True

    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}

        ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
        Display BTS redundancyRole info  ${BTS_alias_redundancyRole_dict}
        ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
        ${BTS_redundancyRole_standby}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  standby
        Get BTS MODULE LANE info dict  RMOD  ${BTS_redundancyRole_active}
        Check RMOD interface and PL info on BTS  ${RMOD_sn}  ${BTS_redundancyRole_active}

        Set CB014646 feature parameter minCellAvailability on BTS  100  ${BTS_redundancyRole_active}
        Perform Lane operation on BTS  Lock  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check failed BTS switchover behaviour  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check BTS switchover behaviour  True  ${BTS_redundancyRole_standby}  ${BTS_redundancyRole_active}  ${STABLE_TIME}
        Perform Lane operation on BTS  Unlock  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check BTS switchover behaviour  False  ${BTS_redundancyRole_standby}  ${BTS_redundancyRole_active}  180
        Check BTS states and alarms  active  ${BTS_redundancyRole_standby}
        Check BTS states and alarms  standby  ${BTS_redundancyRole_active}

        ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
        Display BTS redundancyRole info  ${BTS_alias_redundancyRole_dict}
        ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
        ${BTS_redundancyRole_standby}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  standby
        Get BTS MODULE LANE info dict  RMOD  ${BTS_redundancyRole_active}
        Check RMOD interface and PL info on BTS  ${RMOD_sn}  ${BTS_redundancyRole_active}

        Set CB014646 feature parameter minCellAvailability on BTS  10  ${BTS_redundancyRole_active}
        Perform Lane operation on BTS  Lock  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check BTS switchover behaviour  False  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${STABLE_TIME}
        Set CB014646 feature parameter minCellAvailability on BTS  100  ${BTS_redundancyRole_active}
        Check failed BTS switchover behaviour  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check BTS switchover behaviour  True  ${BTS_redundancyRole_standby}  ${BTS_redundancyRole_active}  ${STABLE_TIME}
        Perform Lane operation on BTS  Unlock  ${RMOD_sn}  ${BTS_redundancyRole_active}
        Check BTS switchover behaviour  False  ${BTS_redundancyRole_standby}  ${BTS_redundancyRole_active}  180
        Check BTS states and alarms  active  ${BTS_redundancyRole_standby}
        Check BTS states and alarms  standby  ${BTS_redundancyRole_active}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Set CB014646 feature parameter minCellAvailability on BTS
    [Arguments]  ${minCellAvailability}  ${alias}

    Log  Set CB014646 feature parameter minCellAvailability=${minCellAvailability} on BTS ${alias}  console=True
    Set BTS CB014646 feature parameters  minCellAvailability  ${minCellAvailability}  ${alias}

Check RMOD interface and PL info on BTS
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_RMOD_sn_interface_dict}=  Get From Dictionary  ${all_BTS_RMOD_sn_interface_info}  ${alias}
    ${RMOD_interface}=  Get From Dictionary  ${BTS_RMOD_sn_interface_dict}  ${RMOD_sn}
    Set Test Variable  ${${alias}_RMOD_${RMOD_sn}_interface}  ${RMOD_interface}

    Return From Keyword If  '${RMOD_interface}' != 'ECPRI_MPLANE'

    ${RMOD_linkModeSynchronization}=  Set Variable  False
    ${BTS_RMOD_sn_id_dict}=  Get From Dictionary  ${all_BTS_RMOD_sn_id_info}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${BTS_RMOD_sn_id_dict}  ${RMOD_sn}

    ${BTS_CABLINK_info}=  Get Parameters For All  CABLINK  connection=${alias}

    FOR  ${item}  IN  @{BTS_CABLINK_info}

        Continue For Loop If  '${item['secondEndpointDN']}' != '${RMOD_id}'

        ${RMOD_linkModeSynchronization}=  Set Variable If  '${item['linkModeSynchronization']}' == 'True'  True  ${RMOD_linkModeSynchronization}
        Exit For Loop If  '${item['linkModeSynchronization']}' == 'True'

    END

    Set Test Variable  ${${alias}_RMOD_${RMOD_sn}_linkModeSynchronization}  ${RMOD_linkModeSynchronization}

Perform Lane operation on BTS
    [Arguments]  ${Lane_operation}  ${RMOD_sn}  ${alias}

    ${BTS_RMOD_sn_id_dict}=  Get From Dictionary  ${all_BTS_RMOD_sn_id_info}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${BTS_RMOD_sn_id_dict}  ${RMOD_sn}

    Log  Perform ${Lane_operation} Lane operation for RMOD_${RMOD_sn} on BTS ${alias}  console=True
    Perform LANE operation  ${RMOD_id}  ${Lane_operation}  ${alias}

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

        Sleep  ${automaticSwitchoverTimer}s  Wait automaticSwitchoverTimer

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

Check failed BTS switchover behaviour
    [Arguments]  ${RMOD_sn}  ${alias}

    Return From Keyword If  '${${alias}_RMOD_${RMOD_sn}_interface}' != 'ECPRI_MPLANE'
    Return From Keyword If  '${${alias}_RMOD_${RMOD_sn}_linkModeSynchronization}' != 'True'

    Log  Check failed BTS switchover due to lock Lane on ECPRI RMOD_${RMOD_sn} with PL on BTS ${alias}  console=True

    ${alarm_timeout}=  Evaluate  ${automaticSwitchoverTimer} + 180
    ${alarm_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4782  timeout=${alarm_timeout}  connection=${alias}
    Run Keyword If  ${alarm_status}  Run Keywords
    ...  Log   Found "Automatic baseband switchover failed (4782)" alarm -> BTS switchover failed  console=True
    ...  AND  Log  Wait 15 min for next BTS switchover try  console=True
    ...  AND  Sleep  15min  Wait next BTS switchover try
    ...  ELSE
    ...  Log  Not found "Automatic baseband switchover failed (4782)" alarm -> No BTS switchover failed  console=True

Display BTS redundancyRole info
    [Arguments]  ${BTS_alias_redundancyRole_dict}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_alias_redundancyRole_dict}  ${alias}
        Log  BTS ${alias} redundancyRole: ${BTS_redundancyRole}  console=True

    END

Check BTS states and alarms
    [Arguments]  ${BTS_redundancyRole}  ${alias}

    Log  ***** Check BTS ${alias} states and alarms *****  console=True

    Run Keyword If  '${BTS_redundancyRole}' == 'active'  Run Keywords
    ...  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    ...  AND  Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - proceduralState: OnAir, blockingState: Unblocked  console=True
    ...  ELSE IF  '${BTS_redundancyRole}' == 'standby'  Run Keywords
    ...  Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_}  ${Unblocked_}  alias=${alias}
    ...  AND  Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - proceduralState: IntegratedToRan, blockingState: Unblocked
    ...  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias} (redundancyRole=${BTS_redundancyRole}) site - expected, ignored and critical alarms checked  console=True

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
        ${initial_priorityNrCellsList}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  priorityNrCellsList
        Set BTS CB014646 feature parameters list  priorityNrCellsList  ${initial_priorityNrCellsList}  ${alias}
        ${initial_priorityLteCellsList}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  priorityLteCellsList
        Set BTS CB014646 feature parameters list  priorityLteCellsList  ${initial_priorityLteCellsList}  ${alias}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS LANEs are unlocked
    Recover BTS CB014646 feature initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
