*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Check_BTS_switchover_downtime_duration_CB014646
Variables    tc_variables/sbts_sbts__state__check_bts_switchover_downtime_duration_cb014646_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3                    # Number of BTS switchover operations. Default value 3
${BTS1_NR_CELL_ID_LIST}      ALL                  # BTS1 list of NR global cell ID on which Reset cell operation will be performed. Possible
                                                  # values (default value ALL):
                                                  # - ALL: action will be performed on any NR cell from all NR cells (exempted CBRS cells)
                                                  # configured on BTS1
                                                  # - list of selected NR global cell ID separated by comma
${BTS1_LTE_CELL_ID_LIST}     ALL                  # BTS1 list of LTE global cell ID on which Reset cell operation will be performed. Possible
                                                  # values (default value ALL):
                                                  # - ALL: action will be performed on any LTE cell from all LTE cells (exempted CBRS cells)
                                                  # configured on BTS1
                                                  # - list of selected LTE global cell ID separated by comma
${BTS2_NR_CELL_ID_LIST}      ALL                  # BTS2 list of NR global cell ID on which Reset cell operation will be performed. Possible
                                                  # values (default value ALL):
                                                  # - ALL: action will be performed on any NR cell from all NR cells (exempted CBRS cells)
                                                  # configured on BTS2
                                                  # - list of selected NR global cell ID separated by comma
${BTS2_LTE_CELL_ID_LIST}     ALL                  # BTS2 list of LTE global cell ID on which Reset cell operation will be performed. Possible
                                                  # values (default value ALL):
                                                  # - ALL: action will be performed on any LTE cell from all LTE cells (exempted CBRS cells)
                                                  # configured on BTS2
                                                  # - list of selected LTE global cell ID separated by comma
${BTS_SWITCHOVER_CONDITION}  minCellAvailability  # CB014646 parameter to trigger BTS switchover. Possible values: minCellAvailability,
                                                  # priorityLteCellsList or priorityNrCellsList. Default value minCellAvailability
${automaticSwitchoverTimer}  1                    # Automatic switchover timer (seconds) defines how long the BTS waits from the moment when the
                                                  # conditions for the automatic switchover are met until the redundancy role switch is executed.
                                                  # Default value 1 sec
${KPI56b_WRN_THR}            30                   # KPI56b threshold value defined as BTS switchover downtime duration:
                                                  # - Start point: 1. Cell from priorityLteCellsList or priorityNrCellsList is disabled or 2.
                                                  # Percentage cells that are disabled is greater than minCellAvailability on first (active) BTS
                                                  # (exempted CBRS cells)
                                                  # - End point: Last cell up on second (standby) BTS (exempted CBRS cells)
${MAX_WAIT_TIME}             300                  # Maximum time to wait for all cells enabled on active BTS after switchover. Default value 300 secs
${STABLE_TIME}               300                  # Waiting time to check BTS stability after BTS switchover. Default value 300 secs

*** Keywords ***
TC__SBTS_SBTS__STATE__Check_BTS_switchover_downtime_duration_CB014646
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30316
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB014646: check BTS switchover downtime duration - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - get BTS redundancy role
    ...  - check initial state and alarms for all BTS
    ...  - perform Reset cells on BTS redundancy role active checking BTS switchover occurs and calculate BTS switchover downtime duration
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: feature CB014646 related to BTS switchover downtime duration works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30316 - [CB0014646] Duration of automatic switchover downtime
    ...

    Set Tags    CA-STATE    OWNER-robert.vesa@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get and check CB014646 feature settings
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Trigger BTS switchover by Reset cell on active BTS for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}

    Check CB014646 feature info

    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled

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

Step ${index}: Get and check CB014646 feature settings
    Log  Step ${index}: Get and check CB014646 feature settings  console=True

    ${emptyList}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        Set Test Variable  ${initial_${alias}_CB014646_feature_dict}  ${BTS_CB014646_feature_dict}

        Log  Check CB014646 feature settings on BTS ${alias}  console=True

        Set BTS CB014646 feature parameters  actAutomaticSwitchover  true  ${alias}
        Set BTS CB014646 feature parameters  automaticSwitchoverTimer  ${automaticSwitchoverTimer}  ${alias}
        Run Keyword If  '${BTS_SWITCHOVER_CONDITION}' == 'minCellAvailability'  Run Keywords
        ...  Set BTS CB014646 feature parameters  minCellAvailability  100  ${alias}
        ...  AND  Set BTS CB014646 feature parameters list  priorityNrCellsList  ${emptyList}  ${alias}
        ...  AND  Set BTS CB014646 feature parameters list  priorityLteCellsList  ${emptyList}  ${alias}
        Run Keyword If  '${BTS_SWITCHOVER_CONDITION}' == 'priorityNrCellsList'  Run Keywords
        ...  Set BTS CB014646 feature parameters list  priorityNrCellsList  ${${alias}_NR_cell_globalCellId_list}  ${alias}
        ...  AND  Set BTS CB014646 feature parameters  minCellAvailability  10  ${alias}
        ...  AND  Set BTS CB014646 feature parameters list  priorityLteCellsList  ${emptyList}  ${alias}
        Run Keyword If  '${BTS_SWITCHOVER_CONDITION}' == 'priorityLteCellsList'  Run Keywords
        ...  Set BTS CB014646 feature parameters list  priorityLteCellsList  ${${alias}_LTE_cell_globalCellId_list}  ${alias}
        ...  AND  Set BTS CB014646 feature parameters  minCellAvailability  10  ${alias}
        ...  AND  Set BTS CB014646 feature parameters list  priorityNrCellsList  ${emptyList}  ${alias}

    END

Step ${index}: Trigger BTS switchover by Reset cell on active BTS for iteration ${CYCLE}
    Log  Step ${index}: Trigger BTS switchover by Reset cell on active BTS for iteration ${CYCLE}  console=True

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    Display BTS redundancyRole info  ${BTS_alias_redundancyRole_dict}
    ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
    ${BTS_redundancyRole_standby}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  standby
    Trigger BTS switchover behaviour  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${CYCLE}

    ${BTS_alias_redundancyRole_dict}  ${BTS_redundancyRole_alias_dict}=  Get BTS redundancy role info
    Display BTS redundancyRole info  ${BTS_alias_redundancyRole_dict}
    ${BTS_redundancyRole_active}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  active
    ${BTS_redundancyRole_standby}=  Get From Dictionary  ${BTS_redundancyRole_alias_dict}  standby
    Trigger BTS switchover behaviour  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${CYCLE}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check CB014646 feature info

    ${BTS_SWITCHOVER_CONDITION_list}=  Create List  minCellAvailability  priorityLteCellsList  priorityNrCellsList
    Run Keyword If  '${BTS_SWITCHOVER_CONDITION}' not in ${BTS_SWITCHOVER_CONDITION_list}  Run Keywords
    ...  Log Long String  Selected value for \${BTS_SWITCHOVER_CONDITION}: ${BTS_SWITCHOVER_CONDITION} is not valid. Please select a value for test
    ...  argument \${BTS_SWITCHOVER_CONDITION} from ${BTS_SWITCHOVER_CONDITION_list} or let default value: minCellAvailability  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}

        ${NR_non_CBRS_cell_globalCellId_list}  ${NR_non_CBRS_cell_id_list}=  Check CELL info  nr  ${alias}
        ${LTE_non_CBRS_cell_globalCellId_list}  ${LTE_non_CBRS_cell_id_list}=  Check CELL info  lte  ${alias}
        Set Test Variable  ${${alias}_NR_cell_globalCellId_list}  ${NR_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_NR_cell_id_list}  ${NR_non_CBRS_cell_id_list}
        Set Test Variable  ${${alias}_LTE_cell_globalCellId_list}  ${LTE_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_LTE_cell_id_list}  ${LTE_non_CBRS_cell_id_list}
        Set Test Variable  ${${alias}_selected_NR_cell_globalCellId_list}  ${NR_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_NR_cell_id_list}  ${NR_non_CBRS_cell_id_list}
        Set Test Variable  ${${alias}_selected_LTE_cell_globalCellId_list}  ${LTE_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_LTE_cell_id_list}  ${LTE_non_CBRS_cell_id_list}

        Continue For Loop If  '${${BTS_label}_NR_CELL_ID_LIST}' == 'ALL' and '${${BTS_label}_LTE_CELL_ID_LIST}' == 'ALL'

        ${selected_NR_cell_globalCellId_list}=  Run Keyword If  '${${BTS_label}_NR_CELL_ID_LIST}' != 'ALL'
        ...  Check item list  ${BTS_label}_NR_CELL_ID_LIST  ${NR_non_CBRS_cell_globalCellId_list}
        ...  ELSE
        ...  Set Variable  ${NR_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_NR_cell_globalCellId_list}  ${selected_NR_cell_globalCellId_list}
        ${selected_NR_cell_runtimeId_list}=  Get CELL runtime id based on globalCellId info  ${${alias}_selected_NR_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_NR_cell_id_list}  ${selected_NR_cell_runtimeId_list}

        ${selected_LTE_cell_globalCellId_list}=  Run Keyword If  '${${BTS_label}_LTE_CELL_ID_LIST}' != 'ALL'
        ...  Check item list  ${BTS_label}_LTE_CELL_ID_LIST  ${LTE_non_CBRS_cell_globalCellId_list}
        ...  ELSE
        ...  Set Variable  ${LTE_non_CBRS_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_LTE_cell_globalCellId_list}  ${selected_LTE_cell_globalCellId_list}
        ${selected_LTE_cell_runtimeId_list}=  Get CELL runtime id based on globalCellId info  ${${alias}_selected_LTE_cell_globalCellId_list}
        Set Test Variable  ${${alias}_selected_LTE_cell_id_list}  ${selected_LTE_cell_runtimeId_list}

    END

Get CELL runtime id based on globalCellId info
    [Arguments]  ${cell_globalCellId_list}

    ${cell_runtimeId_list}=  Create List

    FOR  ${key}  ${value}  IN  &{cell_globalCellId_runtimeId_dict}

        Run Keyword If  '${key}' in ${cell_globalCellId_list}
        ...  Append To List  ${cell_runtimeId_list}  ${value}

    END

    [Return]  ${cell_runtimeId_list}

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

Display BTS redundancyRole info
    [Arguments]  ${BTS_alias_redundancyRole_dict}

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_alias_redundancyRole_dict}  ${alias}
        Log  BTS ${alias} redundancyRole: ${BTS_redundancyRole}  console=True

    END

Trigger BTS switchover behaviour
    [Arguments]  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${CYCLE}

    ${BTS_switchover_cell_id}=  Perform Reset cell on active BTS  ${BTS_redundancyRole_active}
    Check BTS cells after BTS switchover  ${BTS_redundancyRole_standby}  ${MAX_WAIT_TIME}
    Check BTS switchover behaviour  True  ${BTS_redundancyRole_standby}  ${BTS_redundancyRole_active}  ${STABLE_TIME}
    Check BTS states and alarms  active  ${BTS_redundancyRole_standby}
    Check BTS states and alarms  standby  ${BTS_redundancyRole_active}

    Get and check KPI56 info from events  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${BTS_switchover_cell_id}  ${CYCLE}

Perform Reset cell on active BTS
    [Arguments]  ${alias}

    ${BTS_selected_cell_id_list}=  Combine Lists  ${${alias}_selected_NR_cell_id_list}  ${${alias}_selected_LTE_cell_id_list}

    ${BTS_switchover_cell_id}=  Run Keyword If  '${BTS_SWITCHOVER_CONDITION}' == 'minCellAvailability'
    ...  Evaluate  random.choice(${BTS_selected_cell_id_list})  random
    ...  ELSE IF  '${BTS_SWITCHOVER_CONDITION}' == 'priorityNrCellsList'
    ...  Evaluate  random.choice(${${alias}_selected_NR_cell_id_list})  random
    ...  ELSE IF  '${BTS_SWITCHOVER_CONDITION}' == 'priorityLteCellsList'
    ...  Evaluate  random.choice(${${alias}_selected_LTE_cell_id_list})  random

    ${BTS_switchover_cell_class_name}=  Set Variable If
    ...  '${BTS_SWITCHOVER_CONDITION}' == 'minCellAvailability' and '${BTS_switchover_cell_id}' in ${${alias}_selected_NR_cell_id_list}  NRCEL
    ...  '${BTS_SWITCHOVER_CONDITION}' == 'minCellAvailability' and '${BTS_switchover_cell_id}' in ${${alias}_selected_LTE_cell_id_list}  LNCEL
    ...  '${BTS_SWITCHOVER_CONDITION}' == 'priorityNrCellsList'  NRCEL
    ...  '${BTS_SWITCHOVER_CONDITION}' == 'priorityLteCellsList'  LNCEL

    Reset BTS cell  ${BTS_switchover_cell_id}  ${BTS_switchover_cell_class_name}  ${alias}

    [Return]  ${BTS_switchover_cell_id}

Reset BTS cell
    [Arguments]  ${cell_id}  ${cell_class_name}  ${alias}

    Log  ***** Perform "Reset Cell" operation on ${cell_class_name} ${cell_id} on BTS ${alias} *****   console=True

    coam.Reset Cell  cell_id=${cell_id}  graceful_cell_shutdown=${False}  timeout=300  connection=${alias}

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${CELL_state_disabled_check}  timeout=300  connection=${alias}
    Get Current Time  cell_disabled
    Log  ${cell_class_name} ${cell_id} status:\n - ${CELL_state_disabled}  console=True

Check BTS cells after BTS switchover
    [Arguments]  ${alias}  ${timeout}

    FOR  ${item}  IN  @{${alias}_NR_cell_id_list}

        Assert  class_name=NRCEL  id=${item}  parameters=${CELL_state_enabled_check}  connection=${alias}  timeout=${timeout}

    END

    FOR  ${item}  IN  @{${alias}_LTE_cell_id_list}

        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_enabled_check}  connection=${alias}  timeout=${timeout}

    END

    Get Current Time  cell_enabled

Get and check KPI56 info from events
    [Arguments]  ${BTS_redundancyRole_active}  ${BTS_redundancyRole_standby}  ${BTS_switchover_cell_id}  ${CYCLE}

    ${kpi_56b}=  DateTime.Subtract Date From Date  ${time_cell_enabled}  ${time_cell_disabled}  number
    ${kpi_56a}=  Evaluate  ${kpi_56b} - ${automaticSwitchoverTimer}
    Log  ***** Get and check KPI56 info related to BTS switchover: ${BTS_redundancyRole_active} -> ${BTS_redundancyRole_standby} *****  console=True

    Export KPI Results to File  alias=${BTS_redundancyRole_standby}  obj_info=BTS switchover  obj=BTS KPI measurement
    ...  obj_type=${BTS_redundancyRole_standby} -> ${BTS_redundancyRole_active}  obj_id=BTS switchover  action_1=BTS switchover
    ...  kpi_reported_1=KPI_56a  event_value_1=${kpi_56a}  cycle=${CYCLE}  source_info=events  add_info_label=BTS switchover condition trigger action
    ...  add_info_value=${BTS_redundancyRole_standby} ${BTS_SWITCHOVER_CONDITION} condition -> Reset cell ${BTS_switchover_cell_id}
    Export KPI Results to File  alias=${BTS_redundancyRole_standby}  obj_info=BTS switchover  obj=BTS KPI measurement
    ...  obj_type=${BTS_redundancyRole_standby} -> ${BTS_redundancyRole_active}  obj_id=BTS switchover  action_1=BTS switchover
    ...  kpi_reported_1=KPI_56b  event_value_1=${kpi_56b}  cycle=${CYCLE}  source_info=events  add_info_label=BTS switchover condition trigger action
    ...  add_info_value=${BTS_redundancyRole_standby} ${BTS_SWITCHOVER_CONDITION} condition -> Reset cell ${BTS_switchover_cell_id}

    Check and set KPI verdict  kpi56b  ${kpi_56b}  ${KPI56b_WRN_THR}

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
    Recover BTS CB014646 feature initial settings
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
