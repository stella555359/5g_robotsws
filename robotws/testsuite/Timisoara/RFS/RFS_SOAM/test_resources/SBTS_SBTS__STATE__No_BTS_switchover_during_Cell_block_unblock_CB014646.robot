*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__No_BTS_switchover_during_Cell_block_unblock_CB014646
Variables    tc_variables/sbts_sbts__state__no_bts_switchover_during_cell_block_unblock_cb014646_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3     # Number of testcase cycles to check no BTS switchover during cell block unblock operations. Default value 3
${NR_CELL_ID_LIST}           ALL   # List of NR global cell ID on which Block/Unblock operation will be performed. Possible values (by default ALL):
                                   # - ALL: action will be performed on all NR cells (exempted CBRS cells) configured on active BTS
                                   # - list of selected NR global cell ID separated by comma
${LTE_CELL_ID_LIST}          ALL   # List of LTE global cell ID on which Block/Unblock operation will be performed. Possible values (by default ALL):
                                   # - ALL: action will be performed on all LTE cells (exempted CBRS cells) configured on active BTS
                                   # - list of selected LTE global cell ID separated by comma
${automaticSwitchoverTimer}  15    # Automatic switchover timer (seconds) defines how long the BTS waits from the moment when the conditions for the
                                   # automatic switchover are met until the redundancy role switch is executed. Should be less than 30 secs. Default
                                   # value 15 secs
${minCellAvailability}       100   # Minimum cell availability (percentage) defines a minimum number of cells in the BTS that must be operating
                                   # as expected. If percentage of such cells drops below defined value, the preparation for automatic switchover
                                   # begins. Default value 100 %
${priorityNrCellsList}             # List of priority NR global cell ID defines which NR cells are critical to trigger automatic switchover when at
                                   # least one cell from the list does not operate as expected.
${priorityLteCellsList}            # List of priority LTE global cell ID defines which LTE cells are critical to trigger automatic switchover when at
                                   # least one cell from the list does not operate as expected.
${STABLE_TIME}               900   # Waiting time to check BTS stability (no switchover) during cell block unblock operations. Default value 900 secs

*** Keywords ***
TC__SBTS_SBTS__STATE__No_BTS_switchover_during_Cell_block_unblock_CB014646
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30317
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB014646: check no BTS switchover occurs during cell block unblock operations - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - get BTS redundancy role
    ...  - check initial state and alarms for all BTS
    ...  - perform Block/Unblock cells on BTS redundancy role active checking no BTS switchover occurs
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: feature CB014646 related to BTS no switchover during cell block unblock works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30317 - [CB014646] Negative_No_Switchover_On_Cell_Unblock
    ...

    Set Tags    CA-STATE    OWNER-robert.vesa@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB014646 feature settings
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Block/Unblock cells on active BTS
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Check CB014646 feature info

    Set Test Variable  ${CELL_state_blocked_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    Set Test Variable  ${CELL_state_blocked}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    Set Test Variable  ${CELL_state_unblocked_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_unblocked}  operationalState=Enabled, blockingState=Unblocked

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

Step ${index}: Check CB014646 feature settings
    Log  Step ${index}: Check CB014646 feature settings  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_redundancyRole}=  Get From Dictionary  ${initial_BTS_alias_redundancyRole_dict}  ${alias}
        Log  Check CB014646 feature settings on BTS ${alias} (redundancyRole=${BTS_redundancyRole})  console=True

        Set BTS CB014646 feature parameters  actAutomaticSwitchover  true  ${alias}
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${automaticSwitchoverTimer}  ${alias}

        Continue for Loop If  '${BTS_redundancyRole}' != 'active'

        Set BTS CB014646 feature parameters  minCellAvailability  ${minCellAvailability}  ${alias}
        Set BTS CB014646 feature parameters list  priorityNrCellsList  ${priorityNrCellsList_info}  ${alias}
        Set BTS CB014646 feature parameters list  priorityLteCellsList  ${priorityLTECellsList_info}  ${alias}

    END

Step ${index}: Perform Block/Unblock cells on active BTS
    Log  Step ${index}: Perform Block/Unblock cells on active BTS  console=True

    ${BTS_redundancyRole_active}=  Get From Dictionary  ${initial_BTS_redundancyRole_alias_dict}  active

    Perform Block cells on active BTS  ${BTS_redundancyRole_active}
    Check BTS switchover behaviour  after block  ${STABLE_TIME}  ${BTS_redundancyRole_active}
    Perform Unblock cells on active BTS  ${BTS_redundancyRole_active}
    Check BTS switchover behaviour  after unblock  ${STABLE_TIME}  ${BTS_redundancyRole_active}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check CB014646 feature info
    ${BTS_alias_redundancyRole_dict}=  Create Dictionary
    ${BTS_redundancyRole_alias_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        Set Test Variable  ${initial_${alias}_CB014646_feature_dict}  ${BTS_CB014646_feature_dict}

        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Set To Dictionary  ${BTS_alias_redundancyRole_dict}  ${alias}  ${BTS_redundancyRole}
        Set To Dictionary  ${BTS_redundancyRole_alias_dict}  ${BTS_redundancyRole}  ${alias}
        Log  BTS ${alias} redundancyRole: ${BTS_redundancyRole}  console=True

    END

    Set Test Variable  ${initial_BTS_alias_redundancyRole_dict}  ${BTS_alias_redundancyRole_dict}
    Set Test Variable  ${initial_BTS_redundancyRole_alias_dict}  ${BTS_redundancyRole_alias_dict}

    ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active

    ${NR_non_CBRS_cell_globalCellId_list}  ${NR_non_CBRS_cell_id_list}=  Check CELL info  nr  ${BTS_redundancyRole_active}
    ${LTE_non_CBRS_cell_globalCellId_list}  ${LTE_non_CBRS_cell_id_list}=  Check CELL info  lte  ${BTS_redundancyRole_active}
    Set Test Variable  ${NR_cell_list}  ${NR_non_CBRS_cell_id_list}
    Set Test Variable  ${LTE_cell_list}  ${LTE_non_CBRS_cell_id_list}

    Run Keyword If  ${automaticSwitchoverTimer} >= 30  Run Keywords
    ...  Log Long String  Selected value for \${automaticSwitchoverTimer}: ${automaticSwitchoverTimer} is not valid for check case of no BTS
    ...  switchover during cell block unblock. Please select a value for test argument \${automaticSwitchoverTimer} < 30 or let default value: 15
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    ${priorityNrCellsList_info}=  Run Keyword If  '${priorityNrCellsList}' != ''
    ...  Check item list  priorityNrCellsList  ${NR_non_CBRS_cell_globalCellId_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${priorityNrCellsList_info}

    ${priorityLteCellsList_info}=  Run Keyword If  '${priorityLteCellsList}' != ''
    ...  Check item list  priorityLteCellsList  ${LTE_non_CBRS_cell_globalCellId_list}
    ...  ELSE
    ...  Create List
    Set Test Variable  ${priorityLteCellsList_info}

Check CELL info
    [Arguments]  ${cell_type}  ${alias}

    ${BTS_non_CBRS_cell_globalCellId_list}=  Create List
    ${BTS_non_CBRS_cell_id_list}=  Create List
    ${cell_globalCellId_runtimeId_dict}  ${cell_runtimeId_globalCellId_dict}=  Get configured CELL info  ${cell_type}  ${alias}

    ${CBRS_cell_id_list}=  Run Keyword If  '${cell_type}' == 'nr'
    ...  Get CBRS NR cell info  ${alias}
    ...  ELSE IF  '${cell_type}' == 'lte'
    ...  Get CBRS LTE cell info  ${alias}

    ${BTS_cell_id_list}=  Run Keyword If  '${cell_type}' == 'nr'
    ...  Get Ids For All  class_name=NRCEL  connection=${alias}
    ...  ELSE IF  '${cell_type}' == 'lte'
    ...  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${BTS_non_CBRS_cell_id_list}=  Copy List  ${BTS_cell_id_list}  deepcopy=${True}

    FOR  ${item}  IN  @{CBRS_cell_id_list}

        Remove Values From List  ${BTS_non_CBRS_cell_id_list}  ${item}

    END

    FOR  ${key}  ${value}  IN  &{cell_runtimeId_globalCellId_dict}

        Run Keyword If  '${key}' in ${BTS_non_CBRS_cell_id_list}
        ...  Append To List  ${BTS_non_CBRS_cell_globalCellId_list}  ${value}

    END

    Return From Keyword If  ('${cell_type}' == 'nr' and '${NR_CELL_ID_LIST}' == 'ALL') or ('${cell_type}' == 'lte' and '${LTE_CELL_ID_LIST}' == 'ALL')
    ...  ${BTS_non_CBRS_cell_globalCellId_list}  ${BTS_non_CBRS_cell_id_list}

    ${selected_cell_globalCellId_list}=  Run Keyword If  '${cell_type}' == 'nr'
    ...  Check item list  NR_CELL_ID_LIST  ${BTS_non_CBRS_cell_globalCellId_list}
    ...  ELSE IF  '${cell_type}' == 'lte'
    ...  Check item list  LTE_CELL_ID_LIST  ${BTS_non_CBRS_cell_globalCellId_list}

    FOR  ${key}  ${value}  IN  &{cell_globalCellId_runtimeId_dict}

        Run Keyword If  '${key}' in ${selected_cell_globalCellId_list}
        ...  Append To List  ${BTS_non_CBRS_cell_id_list}  ${value}

    END

    [Return]  ${BTS_non_CBRS_cell_globalCellId_list}  ${BTS_non_CBRS_cell_id_list}

Get configured CELL info
    [Arguments]  ${cell_type}  ${alias}

    ${cell_globalCellId_runtimeId_dict}=  Create Dictionary
    ${cell_runtimeId_globalCellId_dict}=  Create Dictionary

    ${cells_info}=  Get Cells Info  cell_type=${cell_type}  timeout=10  connection=${alias}

    FOR  ${item}  IN  @{cells_info}
        ${cell_globalCellId}=  Get From Dictionary  ${item}  globalCellId
        ${cell_globalCellId}=  Convert To String  ${cell_globalCellId}
        Set To Dictionary  ${cell_globalCellId_runtimeId_dict}  ${cell_globalCellId}  ${item['id']['internal']}
        Set To Dictionary  ${cell_runtimeId_globalCellId_dict}  ${item['id']['internal']}  ${cell_globalCellId}
    END

    [Return]  ${cell_globalCellId_runtimeId_dict}  ${cell_runtimeId_globalCellId_dict}

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
    ...  from configured items: ${item_list}  console=True
    ...  AND  Fail  Improper value for argument!

    [Return]  ${item_valid_list}

Check BTS switchover behaviour
    [Arguments]  ${when}  ${timeout}  ${BTS_redundancyRole_active}

    Log  ***** Check BTS switchover behaviour ${when} cells on BTS ${BTS_redundancyRole_active} *****  console=True

    Sleep  ${automaticSwitchoverTimer}s  Wait automaticSwitchoverTimer
    Get Current Time  initial

    FOR  ${count}  IN RANGE  0  100

        Check no BTS switchover is triggered

        Sleep  ${automaticSwitchoverTimer}s  Wait automaticSwitchoverTimer

        Get Current Time  current
        ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_current}  ${time_initial}  number
        ${remained_time}=  BuiltIn.Evaluate  ${timeout} - ${elapsed_time}
        Exit For Loop If  ${remained_time} <= 0

    END

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Log  BTS ${alias} redundancyRole: ${BTS_redundancyRole}  console=True

    END

    Log  Check BTS switchover behaviour ${when} cells on BTS ${BTS_redundancyRole_active} passed -> No BTS switchover  console=True

Check no BTS switchover is triggered

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}

        ${current_BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        ${initial_BTS_redundancyRole}=  Get From Dictionary  ${initial_BTS_alias_redundancyRole_dict}  ${alias}
        ${no_BTS_switchover}=  Run Keyword And Return Status
        ...  Should be equal  ${current_BTS_redundancyRole}  ${initial_BTS_redundancyRole}
        Should Be True  ${no_BTS_switchover}

    END

Perform Block cells on active BTS
    [Arguments]  ${alias}

    Log  ***** Perform Block cells on BTS ${alias} *****  console=True

    FOR  ${item}  IN  @{NR_cell_list}

        Block BTS cell  ${item}  NR  ${alias}

    END

    FOR  ${item}  IN  @{LTE_cell_list}

        Block BTS cell  ${item}  LTE  ${alias}

    END

Perform Unblock cells on active BTS
    [Arguments]  ${alias}

    Log  ***** Perform Unblock cells on BTS ${alias} *****  console=True

    FOR  ${item}  IN  @{NR_cell_list}

        Unblock BTS cell  ${item}  NR  ${alias}

    END

    FOR  ${item}  IN  @{LTE_cell_list}

        Unblock BTS cell  ${item}  LTE  ${alias}

    END

Block BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL

    Log  Perform "Block Cell" operation on ${rat} cell ${cell_id} on BTS ${alias}   console=True

    coam.Block Cell  dist_name=${cell_id}  timeout=300  connection=${alias}

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${CELL_state_blocked_check}  timeout=300  connection=${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${CELL_state_blocked}  console=True

Unblock BTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL

    Log  Perform "Unblock Cell" operation on ${rat} cell ${cell_id} on BTS ${alias}   console=True

    coam.Unblock Cell  dist_name=${cell_id}  timeout=300  connection=${alias}

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${CELL_state_unblocked_check}  timeout=300  connection=${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${CELL_state_unblocked}  console=True

Recover BTS CB014646 feature initial settings
    FOR  ${alias}  IN  @{alias_list}

        ${BTS_redundancyRole}=  Get From Dictionary  ${initial_BTS_alias_redundancyRole_dict}  ${alias}
        Log  Recover CB014646 feature initial settings on BTS ${alias}  console=True

        ${initial_actAutomaticSwitchover}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  actAutomaticSwitchover
        Set BTS CB014646 feature parameters  actAutomaticSwitchover  ${initial_actAutomaticSwitchover}  ${alias}
        ${initial_automaticSwitchoverTimer}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  automaticSwitchoverTimer
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${initial_automaticSwitchoverTimer}  ${alias}

        Continue for Loop If  '${BTS_redundancyRole}' != 'active'

        ${initial_minCellAvailability}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  minCellAvailability
        Set BTS CB014646 feature parameters  minCellAvailability  ${initial_minCellAvailability}  ${alias}
        ${initial_priorityNrCellsList}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  priorityNrCellsList
        Set BTS CB014646 feature parameters list  priorityNrCellsList  ${initial_priorityNrCellsList}  ${alias}
        ${initial_priorityLteCellsList}=  Get From Dictionary  ${initial_${alias}_CB014646_feature_dict}  priorityLteCellsList
        Set BTS CB014646 feature parameters list  priorityLteCellsList  ${initial_priorityLteCellsList}  ${alias}

    END

Particular Teardown
    ${BTS_redundancyRole_active}=  Get From Dictionary  ${initial_BTS_redundancyRole_alias_dict}  active
    Run Keyword And Continue On Failure
    ...  Admin Check if BTS cells are unblocked  ${BTS_redundancyRole_active}
    Recover BTS CB014646 feature initial settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
