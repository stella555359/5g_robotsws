*** Settings ***
Documentation
...   Author:   Sirpa Passoja
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/hot_remove_insert.robot

Library     Collections

*** Variables ***
${LOOPING_KW}                   ${False}
# for radio:
&{state_dict_unlock}            administrativeState=Unlocked  operationalState=enabled
&{state_dict_lock}              administrativeState=Locked  operationalState=disabled
&{state_dict_lock_enabled}      administrativeState=Locked  operationalState=enabled
&{state_dict_disabled}          administrativeState=Unlocked  operationalState=disabled
# for cells
&{state_dict_cell_enabled}      operationalState=enabled
&{state_dict_cell_disabled}     operationalState=disabled


*** Keywords ***
Lock Unlock RMOD
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}
    Run Keyword If      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text             ${STEP}     Check Preconditions
    Run Keyword And Continue On Failure     Common Preconditions
    ${RMOD_OBJ}=                Get Rmod Object From User Given Values    ${RMOD_TO_TEST}
    ${rmod_hw_path}=            Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=               Get Values From Object    ${RMOD_OBJ}    name
# This is needed for lock/unlock
    Print Text To Eventlog      Target unit: ${rmod_name}
    ${cells_of_rmod}=           Get Cells Of Radio    ${rmod_name}
    ${LTE441A_ACTIVE}=          Check If Lte441a Feature Is Active    ${rmod_name}
    Set Suite Variable          ${LTE441A_ACTIVE}
#  This below is needed if there are rmods in chain after the selected rmod
#    @{change_values}=           Create List    unit_path    hw_path
    ${chained_rmods}=           Get Chained Rmods      ${rmod_name}
# create cell state dict and get dist names of cells mapped to rmod
    &{cell_state_dict}          Create Dictionary  All_cells=${state_dict_cell_enabled}
    ${FAULTY_CELL}=             if_parameter_not_list_add_it_to_list    ${cells_of_rmod}
# lock rmod
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Lock RMOD And Checks  ${STEP}  ${RMOD_OBJ}  ${cell_state_dict}
    ...                                     ${WAIT_CHECKS}    ${FAULTY_CELL}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If Selected Radio Locked    ${STEP}    ${rmod_name}
    ${bts_state}=             Get Expected BTS State     ${FAULTY_CELL}    lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure     Check BTS State    ${bts_state}
    &{cell_state_dict}          Create Dictionary
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure    Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure    Check If Fault 4003 Should Be Allowed    ${rmod_name}  lte441a_active=${LTE441A_ACTIVE}
# unlock rmod
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Unlock RMOD And Checks  ${STEP}    ${RMOD_OBJ}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
# smod, rmod and cell states are checked in post conditions -> not really needed here
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If Radios Enabled    ${STEP}    ${rmod_name}    ${chained_rmods}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}    ${FAULTY_CELL}
    ${bts_state}=             Get Expected BTS State
    Run Keyword And Continue On Failure     Check BTS State    ${bts_state}
    Run Keyword If    '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure  Stop Background Syslog Print Search
# IMS history checks
#    Run Keyword And Continue On Failure    IMS History Checks    ${cells_of_rmod}   ${cells_of_rmods_in_chain}
#    ...                                                          ${rmod_serial_number}   ${chained_rmods}
    Run Keyword And Continue On Failure     Reset Alarms
    Run Keyword And Continue On Failure     Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Do Lock Test To All Radios One By One
    [Documentation]  This KW runs the given test type to all radio modules that are found from enviroment one by one.
    ...              Test type can be for example: Lock Unlock RMOD
    [Arguments]    ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}  ${TEST_TYPE}
    Set Suite Variable    ${LOOPING_KW}    ${True}
    ${RMOD_LIST}=    Get All Radios
    FOR    ${radio}    IN    @{RMOD_LIST}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Lock Unlock RMOD'  Run Keyword And Continue On Failure
        ...    Lock Unlock RMOD             ${radio}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Lock Unlock BBMOD
    [Arguments]    ${BBMOD_TO_TEST}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}
    Run Keyword If      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                       Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${0}
    Print Step Text             ${STEP}     Check Preconditions
    Run Keyword And Continue On Failure     Common Preconditions
    ${BBMOD_OBJ}=               Get BBMOD Object From User Given Values    ${BBMOD_TO_TEST}
#    ${bbmod_hw_path}=           Get Values From Object    ${BBMOD_OBJ}    hw_path
    ${bbmod_name}=              Get Values From Object    ${BBMOD_OBJ}    name
#    ${bbmod_serial_number}=     Get Values From Object    ${BBMOD_OBJ}    serial_number
# This is needed for lock/unlock
    ${bbmod_configuration_id}=  Get Values From Object    ${BBMOD_OBJ}    scf_dist_name
    Print Text To Eventlog      Target unit: ${bbmod_name}
    ${cells_of_bbmod}=          Get Cells Of Bbmod    ${bbmod_name}

# create cell state dict and get dist names of cells mapped to rmod
    &{cell_state_dict}          Create Dictionary  All_cells=${state_dict_cell_enabled}
    ${FAULTY_CELL}=             if_parameter_not_list_add_it_to_list    ${cells_of_bbmod}
    Print Text To Eventlog      Faulty cells: ${FAULTY_CELL}

# lock bbmod
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Lock BBMOD And Checks  ${STEP}  ${bbmod_configuration_id}  ${bbmod_name}
    ...                                  ${cell_state_dict}    ${WAIT_CHECKS}    ${FAULTY_CELL}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If Selected BBMOD Locked    ${STEP}    ${bbmod_name}
    ${bts_state}=             Get Expected BTS State     ${FAULTY_CELL}
    Run Keyword And Continue On Failure     Check BTS State    ${bts_state}
    &{cell_state_dict}          Create Dictionary

# unlock bbmod
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Unlock BBMOD And Checks  ${STEP}    ${bbmod_configuration_id}  ${bbmod_name}
    ...                                                              ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}

# smod, rmod and cell states are checked in post conditions -> not really needed here
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If BBMODs Enabled    ${STEP}    ${bbmod_name}
    ${STEP}=                    Check If Step Smaller Or Same As Saved If Is Increase    ${STEP}
    Run Keyword And Continue On Failure     Check If Cells Of Radios Enabled  ${STEP}  ${cell_state_dict}    ${FAULTY_CELL}

    ${bts_state}=             Get Expected BTS State
    Run Keyword And Continue On Failure     Check BTS State    ${bts_state}
    Run Keyword If    '${LOOPING_KW}' == '${False}'  Run Keyword And Continue On Failure  Stop Background Syslog Print Search
    Run Keyword And Continue On Failure     Reset Alarms
    Run Keyword And Continue On Failure     Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Do Lock Test To All BBMODs One By One
    [Documentation]  This KW runs the given test type to all baseband modules that are found from environment one by one.
    ...              Test type can be for example: Lock Unlock BBMOD
    [Arguments]    ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}
    ...            ${UNALLOWED_SYSLOGS}  ${TEST_TYPE}
    Set Suite Variable    ${LOOPING_KW}    ${True}
    ${BBMOD_LIST}=    Get All Bbmods
    FOR    ${bbmod}    IN    @{BBMOD_LIST}
        Run Keyword If  '${KW_SUCCESS}' == '${True}' and '${TEST_TYPE}' == 'Lock Unlock BBMOD'  Run Keyword And Continue On Failure
        ...    Lock Unlock BBMOD             ${bbmod}  ${WAIT_CHECKS}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    END
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
