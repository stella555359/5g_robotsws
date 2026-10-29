*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library    testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod
Library    testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FMRecoCommon
Library    testsuite.Oulu.TrunkEng.Common.Python.Resources.RMODLoginInfo  WITH NAME  RMOD_LOGIN
Resource   testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot

*** Variables ***
${STEP}              ${1}
${DIRECTION}         TX
# for radio:
&{rmods_enabled}     administrativeState=Unlocked  operationalState=enabled
&{rmods_disabled}    administrativeState=Unlocked  operationalState=disabled
&{rmods_degraded}    administrativeState=Unlocked  operationalState=enabled   availabilityStatus=degraded
&{rmods_faulty}      administrativeState=Unlocked  operationalState=disabled  availabilityStatus=faulty
# for cells
&{cell_enabled}      operationalState=enabled
&{cell_disabled}     operationalState=disabled
&{cell_degraded}     operationalState=enabled   availabilityStatus=degraded
&{cell_faulty}       operationalState=disabled  availabilityStatus=faulty
# Create empty affected_cells list
@{affected_cells}
${LOOPING_KW}       ${False}
# empty allowed_alarms list that is updated during test and added in the end before alarm history check
@{allowed_alarms_during_test}
${WAIT_BEFORE_STATE_CHECKS}  120

*** Keywords ***
Rmod fault To All Tx or Rx of Radio
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}
# Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text                        ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=            Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_unit_path}=      Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=        Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=           Get Values From Object    ${RMOD_OBJ}    name
    ${cells_of_rmod}=       Get Cells Of Radio        ${rmod_name}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}         @{EMPTY}
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed
    ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${True}
    ${ANTENNA_AMOUNT}=      Get length    ${ANTENNAS}
    ${LOOP_CNT}=            Addition  ${ANTENNA_AMOUNT}  1
    Run Keyword If          '${RESOURCE}' == 'All_RX'   Set Suite Variable   ${DIRECTION}    RX
    ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
    Run Keyword If      '${FAULT}' == '1907'              Run Keyword And Continue On Failure
    ...                  ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4329
    ...                                            fault_name=Radio memory consumption exceeds abnormal threshold
# testing method is telnet
    Run Keyword If      '${TESTING_METHOD}' == '${True}'    Fault To All Antennas
    ...                  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}    ${WAIT}    ${FAULT_NAME}  ${LOOP_CNT}  ${STEP}
    ...                  ${RMOD_OBJ}  ${cells_of_rmod}    ${rmod_name}    ${ANTENNA_AMOUNT}
    ...                  ${rmod_unit_path}    ${rmod_hw_path}
# testing method is other than telnet
    ${STEP}=     Get Current Step Value
    Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
    ...                                                         Increace Step Value    ${STEP}
    ${STEP}=     Get Current Step Value
    Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
    ...                 Cause Fault Unit Reset And Checks       ${STEP}  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                                         ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Remove Expected Alarms
    Set Suite Variable    ${SNAPSHOT_D}    ${False}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    ${STEP}
    Run Keyword If  '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Fault To All Antennas
    [Arguments]    ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}  ${FAULT_NAME}  ${LOOP_CNT}  ${STEP}  ${RMOD_OBJ}  ${cells_of_rmod}
    ...            ${rmod_name}  ${ANTENNA_AMOUNT}  ${rmod_unit_path}  ${rmod_hw_path}
    ${CELL_ON_TWO_RADIO}=    Check If Cell Resources On Two Radios  ${RMOD_OBJ.name}  check_also_tx=${False}
    ${LTE441A_ACTIVE}=       Check If Lte441a Feature Is Active

    FOR    ${index}     IN RANGE    1    ${LOOP_CNT}
        ${STEP}=             Check If Step Smaller Or Same As Saved If Is Increase  ${STEP}
        ${WHAT_TO_EXPECT}=   Expect Reset Or Fault    ${RESOURCE}  ${LTE441A_ACTIVE}  ${CELL_ON_TWO_RADIO}
        ...                                           ${index}  ${ANTENNA_AMOUNT}  ${cells_of_rmod}   all_one_by_one=${True}
        Run Keyword If      '${WHAT_TO_EXPECT}' == 'fault'    Run Keyword And Continue On Failure
        ...                  Cause Fault Active Alarm And Checks  ${STEP}  ${FAULT}  ${FAULT_NAME}  ${RMOD}
        ...                  ${RMOD_OBJ}  ${DIRECTION}${index}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}

        Run Keyword If       '${WHAT_TO_EXPECT}' == 'reset'  Run Keyword And Continue On Failure
        ...                  Cause Fault Unit Reset And Checks  ${STEP}.1  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${DIRECTION}${index}
        ...                  ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    END

    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Rmod fault To Tx Or Rx
    [Documentation]    Cause given fault to given source of given radio module
    [Arguments]        ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...                ${WAIT}    ${FAULT_NAME}
# Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    Print Step Text                        1  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=        Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_unit_path}=  Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=    Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=       Get Values From Object    ${RMOD_OBJ}    name
    ${cells_of_rmod}=   Get Cells Of Radio        ${rmod_name}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}         @{EMPTY}
# Alarm active/reset
    ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${False}
    ${ANTENNA_AMOUNT}=      Get length                ${ANTENNAS}
    ${index}=               Get Number From Resource  ${RESOURCE}
    ${CELL_ON_TWO_RADIO}=   Check If Cell Resources On Two Radios    ${RMOD_OBJ.name}    check_also_tx=${False}
    ${LTE441A_ACTIVE}=      Check If Lte441a Feature Is Active
    ${WHAT_TO_EXPECT}=      Expect Reset Or Fault     ${RESOURCE}    ${LTE441A_ACTIVE}    ${CELL_ON_TWO_RADIO}
        ...                                           ${index}    ${ANTENNA_AMOUNT}  ${cells_of_rmod}
    Run Keyword And Continue On Failure               Check If Fault 4003 Should Be Allowed   lte441a_active=${LTE441A_ACTIVE}
    Run Keyword If   '${FAULT}' == '1907'             Run Keyword And Continue On Failure
    ...              ALARMS.Add Allowed Alarm         severity=Minor  alarm_id=7115  fault_id=4329
    ...                                               fault_name=Radio memory consumption exceeds abnormal threshold
#    Run Keyword And Continue On Failure    Cause Fault Active Alarm And Checks    2  ${FAULT}    ${FAULT_NAME}    ${RMOD}
#    ...                                    ${RMOD_OBJ}  ${RESOURCE}    ${WAIT}  ${cells_of_rmod}  ${rmod_name}
    Run Keyword If   '${WHAT_TO_EXPECT}' == 'fault'   Run Keyword And Continue On Failure
    ...              Cause Fault Active Alarm And Checks    2  ${FAULT}   ${FAULT_NAME}  ${RMOD}
    ...              ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}

    Run Keyword If   '${WHAT_TO_EXPECT}' == 'reset'    Run Keyword And Continue On Failure
    ...              Cause Fault Unit Reset And Checks    2.1    ${FAULT}    ${RMOD}   ${RMOD_OBJ}    ${RESOURCE}
    ...              ${WAIT}    ${rmod_unit_path}    ${rmod_hw_path}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    Set Suite Variable    ${SNAPSHOT_D}    ${False}
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    3
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If   '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}


Rmod Fault To Ltx
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}
# Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    Print Step Text    1  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=    Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_unit_path}=    Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=    Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=    Get Values From Object    ${RMOD_OBJ}    name
    ${cells_of_rmod}=    Get Cells Of Radio    ${rmod_name}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}     @{EMPTY}
# Unit autonomous reset
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.1  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.2  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.3  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
# Alarm active
    Run Keyword And Continue On Failure    Cause Fault Active Alarm And Checks    3  ${FAULT}    ${FAULT_NAME}   ${RMOD}
    ...                                    ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    Set Suite Variable    ${SNAPSHOT_D}    ${False}
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    4
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Cause Fault Active Alarm And Checks
    [Arguments]    ${STEP}  ${FAULT}  ${FAULT_NAME}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}
    ...            ${cells_of_rmod}  ${rmod_name}
    ${cells_of_antenna}=    Get Cells Of Resource On Antenna  ${RMOD_OBJ}  ${RESOURCE}  print_to_eventlog=${True}
# In faulty category alarms every cells are added to same alarm -> all affected cells needs to be offered to expected alarm
    ${AFFECTED}=            add_list_to_list  ${affected_cells}  ${cells_of_antenna}
    Set Suite Variable      ${affected_cells}  ${AFFECTED}

    IF  'RX' in '${RESOURCE}'
        ${cells_changed_to_faulty}=  Check If More Than One Cells On Rmod And Last Rx Of Cell
        ...                          ${RESOURCE}  ${cells_of_antenna}  ${cells_of_rmod}  ${rmod_name}
        IF   ${cells_changed_to_faulty}
            ${ALARM_ID}=        Select Alarm Id By Resources And Add Fault To Expected Alarm  ${RESOURCE}  ${RMOD_OBJ}
            ...                 ${FAULT}  ${FAULT_NAME}    list_of_cells=${affected_cells}   cells_degraded_faulty=faulty
        ELSE
            ${ALARM_ID}=        Select Alarm Id By Resources And Add Fault To Expected Alarm  ${RESOURCE}  ${RMOD_OBJ}
            ...                 ${FAULT}  ${FAULT_NAME}    list_of_cells=${affected_cells}
        END
    ELSE
       ${ALARM_ID}=        Select Alarm Id By Resources And Add Fault To Expected Alarm  ${RESOURCE}  ${RMOD_OBJ}
       ...                 ${FAULT}  ${FAULT_NAME}    list_of_cells=${affected_cells}
    END

    Print Step Text         ${STEP}.1  Fault ${FAULT} to ${RESOURCE} of ${RMOD}
    Run Keyword And Continue On Failure  Raise Fault To Rmod  ${FAULT}  ${RMOD_OBJ}  ${RESOURCE}
    Wait Time And Reason    ${WAIT}    before doing any checks

    Run Keyword If   '${ALARM_ID}' == '7116' and '${RESOURCE}' == 'LTX'  Cells Faulty Radio Disabled   ${cells_of_rmod}  ${rmod_name}
    Run Keyword If   '${ALARM_ID}' == '7116' and '${RESOURCE}' == 'LTX'  Cells Degraded Radio Enabled  ${rmod_name}
    Run Keyword If   '${ALARM_ID}' == '7116' and '${RESOURCE}' != 'LTX'  Cells Degraded Radio Enabled  ${rmod_name}
    Run Keyword If   '${ALARM_ID}' == '7116' and '${RESOURCE}' != 'LTX'  Cells Faulty Radio Enabled    ${cells_of_antenna}  ${rmod_name}

    Run Keyword And Continue On Failure    Check Expected Alarms   wait_active_timeout=180
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Cause Fault Unit Reset And Checks
    [Arguments]    ${STEP}  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}

    ${MADE_RMOD}=    RMOD_LOGIN.Made Radio    ${RMOD_OBJ}
    Run Keyword If   '${MADE_RMOD}' == '${False}'    Run Keyword And Continue On Failure
        ...                                          Add Expected Alarm  alarm_id=7101  fault_id=${FAULT}
        ...                                          fault_name=Radio autonomous reset as recovery action
        ...                                          unit_path=${rmod_unit_path}    hw_path=${rmod_hw_path}
    Print Step Text    ${STEP}  Fault ${FAULT} to ${RESOURCE} of ${RMOD}

    Run Keyword And Continue On Failure    Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}
    Run Keyword If   '${MADE_RMOD}' == '${True}'     Run Keyword And Continue On Failure    Add Expected Made Radio alarms
        ...                                          ${FAULT}    ${RMOD_OBJ}
    Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  severity=Critical  alarm_id=7116  fault_id=${FAULT}
    ...                                    fault_name=TX out of order / RX out of order
    ...                                    unit_path=${rmod_unit_path}  hw_path=${rmod_hw_path}
    Wait Time And Reason    ${WAIT}        before doing any checks
    Run Keyword And Continue On Failure    Check Expected Alarms   wait_active_timeout=180
    Run Keyword And Continue On Failure    Reset Alarms
    Run Keyword And Continue On Failure    Wait Time And Reason    ${WAIT_BEFORE_STATE_CHECKS}    before doing state checks
    &{cell_state_dict}    Create Dictionary  All_cells=${cell_enabled}
    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}
    &{rmod_state_dict}    Create Dictionary  All_radios=${rmods_enabled}
    Run Keyword And Continue On Failure    Check Radio States   ${rmod_state_dict}    print_ok_states=${True}
    ${bts_state}=    Get Expected BTS State
    Run Keyword And Continue On Failure    Check BTS State    ${bts_state}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Cells Faulty Radio Disabled
    [Arguments]  ${cells_of_rmod}    ${rmod_name}
    &{cell_state_dictionary}    Create Dictionary
    ${cell_state_dict}=    add_list_to_dict_if_it_exist    ${cell_state_dictionary}  ${cells_of_rmod}  ${cell_disabled}
    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}  states_of_other_cells=${cell_enabled}
    &{state_dict}    Create Dictionary  ${rmod_name}=${rmods_disabled}
    Run Keyword And Continue On Failure    Check Radio States  ${state_dict}  states_of_other_rmods=${rmods_enabled}
    ...                                    print_ok_states=${True}
    ${bts_state}=    Get Expected BTS State    ${cells_of_rmod}
    Run Keyword And Continue On Failure    Check BTS State    ${bts_state}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Cells Degraded Radio Enabled
    [Arguments]  ${rmod_name}
    &{cell_state_dictionary}    Create Dictionary
    FOR    ${affected_cell}    IN    ${affected_cells}
        ${cell_state_dict}=    add_list_to_dict_if_it_exist    ${cell_state_dictionary}  ${affected_cell}  ${cell_degraded}
    END
    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}  states_of_other_cells=${cell_enabled}
    &{state_dict}    Create Dictionary  ${rmod_name}=${rmods_enabled}
    Run Keyword And Continue On Failure    Check Radio States  ${state_dict}  states_of_other_rmods=${rmods_enabled}
    ...                                    print_ok_states=${True}
    ${bts_state}=    Get Expected BTS State
    Run Keyword And Continue On Failure    Check BTS State    ${bts_state}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Cells Faulty Radio Enabled
    [Documentation]    This keyword is used to check that cells are in faulty state and radio is enabled.
    [Arguments]  ${cells_of_antenna}    ${rmod_name}
    &{cell_state_dictionary}    Create Dictionary
    FOR    ${affected_cell}    IN    ${affected_cells}
        ${cell_state_dict}=    add_list_to_dict_if_it_exist    ${cell_state_dictionary}  ${affected_cell}  ${cell_disabled}
    END
    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}  states_of_other_cells=${cell_enabled}
    &{state_dict}    Create Dictionary  ${rmod_name}=${rmods_enabled}
    Run Keyword And Continue On Failure    Check Radio States  ${state_dict}  states_of_other_rmods=${rmods_enabled}
    ...                                    print_ok_states=${True}
    ${bts_state}=    Get Expected BTS State    ${cells_of_antenna}
    Run Keyword And Continue On Failure    Check BTS State    ${bts_state}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

#Check Cell, Radio And BTS States
#    [Documentation]    This keyword is used to check that cells are in expected state and radio is in expected state.
#    [Arguments]    ${RMOD_OBJ}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATE}
#    &{cell_state_dict}    Create Dictionary
#    ${cell_state}=    Set Variable    ${cell_degraded}
#    ${rmod_state}=    Set Variable    ${rmods_degraded}
#    ${cells_of_antenna}=  ${NONE}
#    Run Keyword If    '${EXPECTED_CELL_STATE}' == 'faulty'  Set Variable    ${cell_state}        ${cell_faulty}
#    Run Keyword If    '${EXPECTED_CELL_STATE}' == 'faulty'  Set Variable    ${cells_of_antenna}  ${affected_cells}
#    Run Keyword If    '${EXPECTED_RMOD_STATE}' == 'faulty'  Set Variable    ${rmod_state}        ${rmods_faulty}
#    FOR    ${affected_cell}    IN    ${affected_cells}
#        ${cell_state_dict}=    add_list_to_dict_if_it_exist    ${cell_state_dict}  ${affected_cell}  ${cell_state}
#    END
#    Run Keyword And Continue On Failure    Check Cell States  ${cell_state_dict}  states_of_other_cells=${cell_enabled}
#    &{state_dict}    Create Dictionary  ${rmod_name}=${rmods_state}
#    Run Keyword And Continue On Failure    Check Radio States  ${state_dict}  states_of_other_rmods=${rmods_enabled}
#    ...                                    print_ok_states=${True}
#
#    ${bts_state}=    Get Expected BTS State    ${cells_of_antenna}
#    Run Keyword And Continue On Failure    Check BTS State    ${bts_state}
#    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Increace Step Value
    [Arguments]    ${STEP}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}

Cause Fault To All Radios One By One
    [Documentation]  This KW runs selected test to all radio modules that are found from the enviroment one by one.
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}    ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}    ${TEST_TYPE}
    Set Suite Variable                     ${LOOPING_KW}    ${True}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_LIST}=                          Get All Radios
    FOR    ${radio}    IN    @{RMOD_LIST}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Rmod fault To All Tx or Rx of Radio'
        ...    Run Keyword And Continue On Failure    Rmod fault To All Tx or Rx of Radio    ${WAIT_FOR_CELLS_UP}
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}   ${radio}  ${RESOURCE}  ${WAIT}    ${FAULT_NAME}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Rmod fault To Tx Or Rx'
        ...    Run Keyword And Continue On Failure    Rmod fault To Tx Or Rx    ${WAIT_FOR_CELLS_UP}
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}   ${radio}  ${RESOURCE}  ${WAIT}    ${FAULT_NAME}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Rmod Fault To Ltx'
        ...    Run Keyword And Continue On Failure    Rmod Fault To Ltx    ${WAIT_FOR_CELLS_UP}
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}   ${radio}  ${RESOURCE}  ${WAIT}    ${FAULT_NAME}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Set and Cancel RMOD Fault With No Recovery Actions'
        ...    Run Keyword And Continue On Failure    Set and Cancel RMOD Fault With No Recovery Actions
        ...    ${radio}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATE}   ${WAIT}
        ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    END
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    Set Suite Variable                     ${LOOPING_KW}    ${False}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

RF module alarm set and cancel
    [Documentation]    Cause and clear given fault to given source of given radio module. Recovery actions are not expected.
    ...                After fault is cleared, alarms and states are checked.
    ...                If WAIT_BEFORE_CLEAR is more than 60 seconds, alarms and states are checked also before clearing the fault.
    ...                If EXPECTED_CELL_STATE is 'degraded' or 'faulty', cells of resources are expected to be in that state.
    ...                If EXPECTED_RMOD_STATE is 'degraded' or 'faulty', given radio is expected to be in that state.
    [Arguments]        ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
#    ${cells_of_antenna}=    Get Cells Of Resource On Antenna    ${RMOD_OBJ}   ${RESOURCE}    print_to_eventlog=${True}
## In faulty category alarms every cells are added to same alarm -> all affected cells needs to be offered to expected alarm
#    ${AFFECTED}=            add_list_to_list    ${affected_cells}    ${cells_of_antenna}
#    Set Suite Variable      ${affected_cells}    ${AFFECTED}
#    Run Keyword And Continue On Failure    Select Alarm Id By Resources And Add Fault To Expected Alarm    ${RESOURCE}    ${RMOD_OBJ}
#    ...                                    ${FAULT}  ${FAULT_NAME}  list_of_cells=${affected_cells}   cells_degraded_faulty=${EXPECTED_CELL_STATE}
## Get expected alarms that will be added to allowed after active alarm check
#    ${alarm_to_add_allowed}=  Get Expected Alarms
#    ${a_alarms_during_test}=  add_list_to_list  ${allowed_alarms_during_test}  ${alarm_to_add_allowed}
#    Set Suite Variable        ${allowed_alarms_during_test}  ${a_alarms_during_test}
#    Print Step Text    ${STEP}.1  Fault ${FAULT} to ${RESOURCE} of ${RMOD}
#    Run Keyword And Continue On Failure    Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}
#    Wait Time And Reason    ${WAIT_BEFORE_CLEAR}     before clearing the fault
#    Run Keyword If  '${WAIT_BEFORE_CLEAR}' > '60'    Run Keywords
#    ...             Print Step Text    ${STEP}.2  Fault ${FAULT} to ${RESOURCE} of ${RMOD} is cancelled   AND
#    ...             Run Keyword And Continue On Failure    Check Expected Alarms   AND
#    ...             Run Keyword And Continue On Failure    Check Cell, Radio And BTS States  ${RMOD_OBJ}  ${RESOURCE}
#    ...                                                    ${EXPECTED_CELL_STATE}   ${EXPECTED_RMOD_STATES}   AND
#    ...             Run Keyword And Continue On Failure    Remove Expected Alarms
    Run Keyword And Continue On Failure    Activate RF module alarm   ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}
    ...                                                               ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    Print Step Text    ${STEP}.2  Fault ${FAULT} to ${RESOURCE} of ${RMOD_OBJ.name} is cancelled
    Run Keyword And Continue On Failure    Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}  deactivate_fault=${True}
    Run Keyword If  '${WAIT_BEFORE_CLEAR}' > '60'   Print Step Text    ${STEP}.3  Check alarms and states after Fault ${FAULT} is cancelled
    Run Keyword If  '${WAIT_BEFORE_CLEAR}' < '61'   Print Step Text    ${STEP}.2  Check alarms and states after Fault ${FAULT} is cancelled
    Run Keyword And Continue On Failure    Check Active Alarms
    Run Keyword And Continue On Failure    Check BTS Status
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Activate RF module alarm
    [Documentation]    Cause given fault to given source of given radio module. Recovery actions are not expected.
    ...                If WAIT_BEFORE_CLEAR is more than 60 seconds, alarms and states are checked, otherwise not.
    ...                If EXPECTED_CELL_STATE is 'degraded' or 'faulty', cells of resources are expected to be in that state.
    ...                If EXPECTED_RMOD_STATE is 'degraded' or 'faulty', given radio is expected to be in that state.
    [Arguments]        ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATES}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    Print Step Text    ${STEP}.1  Fault ${FAULT} to ${RESOURCE} of ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure    Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}
    Wait Time And Reason    ${WAIT_BEFORE_CLEAR}
    Run Keyword And Continue On Failure    Check From Wait Time If Alarm And States Should Be Check
    ...   ${WAIT_BEFORE_CLEAR}  ${RMOD_OBJ}  ${FAULT}  ${FAULT_NAME}  ${RESOURCE}  ${STEP}  ${affected_cells}
    ...   expected_cell_states=${EXPECTED_CELL_STATE}  expected_rmod_states=${EXPECTED_RMOD_STATES}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Set and Cancel RMOD Fault With No Recovery Actions
    [Documentation]    Cause given fault to given source of given radio module. Recovery actions are not expected.
    [Arguments]        ${RMOD}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATE}   ${WAIT}
    ...                ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    # Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text    ${STEP}             Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword If                         '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=    Get Rmod Object From User Given Values    ${RMOD}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}     @{EMPTY}
    ${cells_of_antenna}=    Get Cells Of Resource On Antenna    ${RMOD_OBJ}   ${RESOURCE}    print_to_eventlog=${True}
# In faulty category alarms every cells are added to same alarm -> all affected cells needs to be offered to expected alarm
    Set Suite Variable      ${affected_cells}    ${cells_of_antenna}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
# Time that is waited before clearing the fault. If time is more than 60s alarms and states are checked before clearing the fault
    ${WAIT_BEFORE_CLEAR}=    Set Variable  ${60}
    Run Keyword And Continue On Failure    RF module alarm set and cancel  ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}
    ...                                                                    ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    ${WAIT_BEFORE_CLEAR}=    Set Variable  ${180}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure    RF module alarm set and cancel  ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}
    ...                                                                    ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure    RF module alarm set and cancel  ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}
    ...                                                                    ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    Wait Time And Reason    ${WAIT}        before Post conditions checks
# add expected alarms during test as allowed alarms
    Run Keyword And Continue On Failure    Add Collected Alarms To Allowed
#    Run Keyword And Continue On Failure    Add List Of Alarms To Allowed  ${allowed_alarms_during_test}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text         ${STEP}        Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If   '${LOOPING_KW}' == '${False}'   Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

RMOD Fault With No Recovery Actions and Clear With RMOD reset
    [Documentation]    Cause given fault to given source of given radio module. Recovery actions are not expected.
    [Arguments]        ${RMOD}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}  ${EXPECTED_RMOD_STATE}   ${WAIT}
    ...                ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    # Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text    ${STEP}             Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
    Run Keyword If                         '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                  Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=    Get Rmod Object From User Given Values    ${RMOD}
    ${cells_of_antenna}=    Get Cells Of Resource On Antenna    ${RMOD_OBJ}   ${RESOURCE}    print_to_eventlog=${True}
# In faulty category alarms every cells are added to same alarm -> all affected cells needs to be offered to expected alarm
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}     @{EMPTY}
    Set Suite Variable      ${affected_cells}    ${cells_of_antenna}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
# Time that is waited needs to be more than 60s alarms so states and alarms are checked before RMOD WebEM reset
    ${WAIT_BEFORE_CLEAR}=   Set Variable   ${180}
    Run Keyword And Continue On Failure    Activate RF module alarm  ${RMOD_OBJ}  ${FAULT}  ${RESOURCE}  ${EXPECTED_CELL_STATE}
    ...                                                              ${EXPECTED_RMOD_STATE}  ${WAIT_BEFORE_CLEAR}  ${STEP}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text                        ${STEP}  RMOD reset via WebEM
    Print Text To Eventlog                 Request warm reset to ${RMOD_OBJ.dist_name} (${RMOD_OBJ.name}) (${RMOD_OBJ.serial_number})
    Run Keyword And Continue On Failure    Reset Unit With Error Handling  ${RMOD_OBJ.dist_name}  reset_type=Warm
    ...                                                                     detailed_output=${True}   allow_error=${True}
    Wait Time And Reason    ${WAIT}        before Post conditions checks
# add expected alarms during test as allowed alarms
    Run Keyword And Continue On Failure    Add Collected Alarms To Allowed
#    Run Keyword And Continue On Failure    Add List Of Alarms To Allowed  ${allowed_alarms_during_test}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Print Step Text    ${STEP}             Check Postconditions
    Run Keyword And Continue On Failure    Common Postconditions
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If   '${LOOPING_KW}' == '${False}'   Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for RMOD All Tx
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text                        ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
    FOR  ${INDEX}  IN RANGE  1  4
        # Get radio information again because radio IP is dynamic and may change if test is run in loops
        Run Keyword And Continue On Failure    Update Rmod Information
    #    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
          ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
        ${RMOD_OBJ}=            Get Rmod Object From User Given Values    ${RMOD}
        ${rmod_unit_path}=      Get Values From Object    ${RMOD_OBJ}    unit_path
        ${rmod_hw_path}=        Get Values From Object    ${RMOD_OBJ}    hw_path
        ${rmod_name}=           Get Values From Object    ${RMOD_OBJ}    name
        ${cells_of_rmod}=       Get Cells Of Radio        ${rmod_name}
    # Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
        Set Suite Variable      @{affected_cells}         @{EMPTY}
    # This is needed if Nokia nahka radio and there are cells on the radio
        Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
    # This is needed because it depends on commissioning if the fault is allowed or not
        Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed
        ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${True}
        ${ANTENNA_AMOUNT}=      Get length    ${ANTENNAS}
        ${LOOP_CNT}=            Addition  ${ANTENNA_AMOUNT}  1
        Run Keyword If          '${RESOURCE}' == 'All_RX'   Set Suite Variable   ${DIRECTION}    RX
        ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
        Run Keyword If      '${FAULT}' == '1907'              Run Keyword And Continue On Failure
        ...                  ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4329
        ...                                            fault_name=Radio memory consumption exceeds abnormal threshold
    # testing method is telnet
        Run Keyword If      '${TESTING_METHOD}' == '${True}'    Rmod fault To All Tx or Rx of Radio
        ...                  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...                  ${WAIT}    ${FAULT_NAME}
    # testing method is other than telnet
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                                                         Increace Step Value    ${STEP}
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                 Cause Fault Unit Reset And Checks       ${STEP}  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
        ...                                                         ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END
    # Get radio information again because radio IP is dynamic and may change if test is run in loops
        Run Keyword And Continue On Failure    Update Rmod Information
    #    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
          ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
        ${RMOD_OBJ}=            Get Rmod Object From User Given Values    ${RMOD}
        ${rmod_unit_path}=      Get Values From Object    ${RMOD_OBJ}    unit_path
        ${rmod_hw_path}=        Get Values From Object    ${RMOD_OBJ}    hw_path
        ${rmod_name}=           Get Values From Object    ${RMOD_OBJ}    name
        ${cells_of_rmod}=       Get Cells Of Radio        ${rmod_name}
    # Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
        Set Suite Variable      @{affected_cells}         @{EMPTY}
    # This is needed if Nokia nahka radio and there are cells on the radio
        Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
    # This is needed because it depends on commissioning if the fault is allowed or not
        Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed
        ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${True}
        ${ANTENNA_AMOUNT}=      Get length    ${ANTENNAS}
        ${LOOP_CNT}=            Addition  ${ANTENNA_AMOUNT}  1
        Run Keyword If          '${RESOURCE}' == 'All_RX'   Set Suite Variable   ${DIRECTION}    RX
        ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
        Run Keyword If      '${FAULT}' == '1907'              Run Keyword And Continue On Failure
        ...                  ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4329
        ...                                            fault_name=Radio memory consumption exceeds abnormal threshold
    # testing method is telnet
        Run Keyword If      '${TESTING_METHOD}' == '${True}'    Rmod fault To All Tx or Rx of Radio
        ...                  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...                  ${WAIT}    ${FAULT_NAME}
    # testing method is other than telnet
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                                                         Increace Step Value    ${STEP}
        ${STEP}=     Get Current Step Value
#        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
#        ...                 Cause Fault Unit Reset And Checks       ${STEP}  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
#        ...                                                         ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
        Print Step Text    ${STEP}  Fault ${FAULT} to ${RESOURCE} of ${RMOD}
        Run Keyword If     '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}

        Run Keyword And Continue On Failure    Enable Maintenance Window    ${USER_GIVEN_TIME}
#        Run Keyword And Continue On Failure    Add Expected Alarm  fault_name=Baseband card autonomous reset as recovery action
#        ...                                                        severity=Warning  alarm_id=7101  unit_path=${BBMOD_OBJ.unit_path}
#        ...                                                        hw_path=${BBMOD_OBJ.hw_path}
        # Run Keyword And Continue On Failure    Check Expected Alarms  wait_active_timeout=${WAIT_FOR_MW_ALARM}
        Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=300

        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
            ...                                  extra_name=MW
        END

        Run Keyword And Continue On Failure    Disable Maintenance Window
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  severity=Major  alarm_id=7116  fault_id=1907
        ...                                    fault_name=TX out of order
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
        Run Keyword And Continue On Failure    Common Postconditions

Recovery during MW for RMOD LTX
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}
# Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    Print Step Text    1  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=    Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_unit_path}=    Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=    Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=    Get Values From Object    ${RMOD_OBJ}    name
    ${cells_of_rmod}=    Get Cells Of Radio    ${rmod_name}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}     @{EMPTY}
# Unit autonomous reset
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.1  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.2  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.3  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
# Alarm active
    Run Keyword And Continue On Failure    Cause Fault Active Alarm And Checks    3  ${FAULT}    ${FAULT_NAME}   ${RMOD}
    ...                                    ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    Set Suite Variable    ${SNAPSHOT_D}    ${False}
    Run Keyword And Continue On Failure    Enable Maintenance Window    ${USER_GIVEN_TIME}
        Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=300
        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
            ...                                  extra_name=MW
        END
        Run Keyword And Continue On Failure    Disable Maintenance Window
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    4
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Recovery During MW for RMOD All Tx With Additional Fault
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}  ${WAIT_FOR_RECO_COUNTER_CLEAR}
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text                        ${STEP}  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
    FOR  ${INDEX}  IN RANGE  1  4
        # Get radio information again because radio IP is dynamic and may change if test is run in loops
        Run Keyword And Continue On Failure    Update Rmod Information
    #    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
          ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
        ${RMOD_OBJ}=            Get Rmod Object From User Given Values    ${RMOD}
        ${rmod_unit_path}=      Get Values From Object    ${RMOD_OBJ}    unit_path
        ${rmod_hw_path}=        Get Values From Object    ${RMOD_OBJ}    hw_path
        ${rmod_name}=           Get Values From Object    ${RMOD_OBJ}    name
        ${cells_of_rmod}=       Get Cells Of Radio        ${rmod_name}
    # Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
        Set Suite Variable      @{affected_cells}         @{EMPTY}
    # This is needed if Nokia nahka radio and there are cells on the radio
        Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
    # This is needed because it depends on commissioning if the fault is allowed or not
        Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed
        ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${True}
        ${ANTENNA_AMOUNT}=      Get length    ${ANTENNAS}
        ${LOOP_CNT}=            Addition  ${ANTENNA_AMOUNT}  1
        Run Keyword If          '${RESOURCE}' == 'All_RX'   Set Suite Variable   ${DIRECTION}    RX
        ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
        Run Keyword If      '${FAULT}' == '1907'              Run Keyword And Continue On Failure
        ...                  ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4329
        ...                                            fault_name=Radio memory consumption exceeds abnormal threshold
    # testing method is telnet
        Run Keyword If      '${TESTING_METHOD}' == '${True}'    Rmod fault To All Tx or Rx of Radio
        ...                  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...                  ${WAIT}    ${FAULT_NAME}
    # testing method is other than telnet
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                                                         Increace Step Value    ${STEP}
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                 Cause Fault Unit Reset And Checks       ${STEP}  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
        ...                                                         ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
        Run Keyword And Continue On Failure    Remove Expected Alarms
    END
    # Get radio information again because radio IP is dynamic and may change if test is run in loops
        Run Keyword And Continue On Failure    Update Rmod Information
    #    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
        Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
          ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
        ${RMOD_OBJ}=            Get Rmod Object From User Given Values    ${RMOD}
        ${rmod_unit_path}=      Get Values From Object    ${RMOD_OBJ}    unit_path
        ${rmod_hw_path}=        Get Values From Object    ${RMOD_OBJ}    hw_path
        ${rmod_name}=           Get Values From Object    ${RMOD_OBJ}    name
        ${cells_of_rmod}=       Get Cells Of Radio        ${rmod_name}
    # Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
        Set Suite Variable      @{affected_cells}         @{EMPTY}
    # This is needed if Nokia nahka radio and there are cells on the radio
        Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
    # This is needed because it depends on commissioning if the fault is allowed or not
        Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
        Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed
        ${ANTENNAS}=            Select Antenna From Active Antennas Of Radio By Position  ${RESOURCE}  ${RMOD_OBJ}  print_to_eventlog=${True}
        ${ANTENNA_AMOUNT}=      Get length    ${ANTENNAS}
        ${LOOP_CNT}=            Addition  ${ANTENNA_AMOUNT}  1
        Run Keyword If          '${RESOURCE}' == 'All_RX'   Set Suite Variable   ${DIRECTION}    RX
        ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
        Run Keyword If      '${FAULT}' == '1907'              Run Keyword And Continue On Failure
        ...                  ALARMS.Add Allowed Alarm  severity=Minor  alarm_id=7115  fault_id=4329
        ...                                            fault_name=Radio memory consumption exceeds abnormal threshold
    # testing method is telnet
        Run Keyword If      '${TESTING_METHOD}' == '${True}'    Rmod fault To All Tx or Rx of Radio
        ...                  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...                  ${WAIT}    ${FAULT_NAME}
    # testing method is other than telnet
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                                                         Increace Step Value    ${STEP}
        ${STEP}=     Get Current Step Value
        Print Step Text    ${STEP}  Fault ${FAULT} to ${RESOURCE} of ${RMOD}
        Run Keyword If     '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}

        ${START_TIME}=                         Enable Maintenance Window    ${USER_GIVEN_TIME}
        Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=300
        # Cause the same fault again
        ${TESTING_METHOD}=      Use Telnet For Faulting    ${RMOD_OBJ}
        # testing method is telnet
        Run Keyword If      '${TESTING_METHOD}' == '${True}'    Rmod fault To All Tx or Rx of Radio
        ...                  ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
        ...                  ${WAIT}    ${FAULT_NAME}
        # testing method is other than telnet
        ${STEP}=     Get Current Step Value
        Run Keyword If      '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                                                         Increace Step Value    ${STEP}
        ${STEP}=     Get Current Step Value
        Print Step Text    ${STEP}  Fault ${FAULT} to ${RESOURCE} of ${RMOD}
        Run Keyword If     '${TESTING_METHOD}' == '${False}'       Run Keyword And Continue On Failure
        ...                Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  ${RESOURCE}
        Run Keyword And Continue On Failure    Disable Maintenance Window And Wait  ${USER_GIVEN_TIME}  ${START_TIME}
        ${log_collection}=  Logs Should Be Collected
        IF  '${log_collection}' == '${True}'
            Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
            ...                                  extra_name=MW
        END
        Run Keyword And Continue On Failure    ALARMS.Add Allowed Alarm  severity=Major  alarm_id=7116  fault_id=1907
        ...                                    fault_name=TX out of order
        Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_RECO_COUNTER_CLEAR}  ${5}
        Run Keyword And Continue On Failure    Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
        Run Keyword And Continue On Failure    Stop Background Syslog Print Search
        Run Keyword And Continue On Failure    Common Postconditions

Recovery during MW for RMOD LTX With Additional Fault
    [Arguments]    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${FAULT}  ${RMOD}  ${RESOURCE}
    ...            ${WAIT}    ${FAULT_NAME}  ${USER_GIVEN_TIME}
# Get radio information again because radio IP is dynamic and may change if test is run in loops
    Run Keyword And Continue On Failure    Update Rmod Information
    Print Step Text    1  Check Preconditions
    Run Keyword And Continue On Failure    Common Preconditions
#    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=    Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_unit_path}=    Get Values From Object    ${RMOD_OBJ}    unit_path
    ${rmod_hw_path}=    Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=    Get Values From Object    ${RMOD_OBJ}    name
    ${cells_of_rmod}=    Get Cells Of Radio    ${rmod_name}
# Empty suite variable so if multiple radios in same suite cells of earlier tests will not be took to use
    Set Suite Variable      @{affected_cells}     @{EMPTY}
# Unit autonomous reset
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.1  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.2  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.3  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
# Alarm active
    Run Keyword And Continue On Failure    Cause Fault Active Alarm And Checks    3  ${FAULT}    ${FAULT_NAME}   ${RMOD}
    ...                                    ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    Set Suite Variable    ${SNAPSHOT_D}    ${False}
    ${START_TIME}=                         Enable Maintenance Window    ${USER_GIVEN_TIME}
    Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=300
    # Cause the same fault again
    # Unit autonomous reset
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.1  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.2  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Cause Fault Unit Reset And Checks    2.3  ${FAULT}  ${RMOD}  ${RMOD_OBJ}  ${RESOURCE}
    ...                                    ${WAIT}  ${rmod_unit_path}  ${rmod_hw_path}
    Run Keyword And Continue On Failure    Add Expected Alarm To Allowed
    Run Keyword And Continue On Failure    Remove Expected Alarms
    # Alarm active
    Run Keyword And Continue On Failure    Cause Fault Active Alarm And Checks    3  ${FAULT}    ${FAULT_NAME}   ${RMOD}
    ...                                    ${RMOD_OBJ}  ${RESOURCE}  ${WAIT}  ${cells_of_rmod}  ${rmod_name}
    Run Keyword And Continue On Failure    Disable Maintenance Window And Wait  ${USER_GIVEN_TIME}  ${START_TIME}
    ${log_collection}=  Logs Should Be Collected
    IF  '${log_collection}' == '${True}'
        Run Keyword And Continue On Failure  Get Snapshot And Ims Log  info_text=Before site reset cleaner
        ...                                  extra_name=MW
    END
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    4
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
#    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Kill Application From RMOD And Check Recovery
    [Documentation]    Kill given application from given radio module. Faults and recovery actions are expected.
    ...                Do cleaning with site reset after test.
    [Arguments]        ${RMOD}  ${RMOD_APPLICATION}  ${FAULT}  ${FAULT_NAME}  ${WAIT_FOR_CELLS_UP}=${300}
    ...                ${SYSLOG_LIST}=${None}   ${WAIT}=${10}  ${UNALLOWED_SYSLOGS}=${None}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                        1   Check Preconditions   automatic=${True}
    Run Keyword And Continue On Failure    Common Preconditions
    ${RMOD_OBJ}=                           Get Rmod Object From User Given Values    ${RMOD}
    ${cells_of_rmod}=                      Get Cells Of Radio        ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure    Add Expected Alarm   fault_id=${FAULT}   fault_name=${FAULT_NAME}
        ...                                unit_path=${RMOD_OBJ.unit_path}    hw_path=${RMOD_OBJ.hw_path}
    # This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4590 Should Be Allowed
    Print Step Text                        2   Kill application ${RMOD_APPLICATION} from ${RMOD_OBJ.name}   automatic=${True}
    Run Keyword And Continue On Failure    Raise Fault To Rmod    ${FAULT}    ${RMOD_OBJ}  application_to_kill=${RMOD_APPLICATION}
    Print Step Text                        3   Wait for expected alarms to be active max ${WAIT} seconds   automatic=${True}
    Run Keyword And Continue On Failure    ALARMS.Wait For Active Alarm   time_limit=${WAIT}
    Run Keyword And Continue On Failure    Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
#    Wait Time And Reason    ${WAIT}        before Post conditions checks
# add expected alarms during test as allowed alarms
    Print Step Text                        4  Check Postconditions   automatic=${True}
    Run Keyword and Return Status          Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure    Common Postconditions
    ${STEP}=    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure    Site reset cleaner    ${WAIT_FOR_CELLS_UP}  ${WAIT}    ${STEP}
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
