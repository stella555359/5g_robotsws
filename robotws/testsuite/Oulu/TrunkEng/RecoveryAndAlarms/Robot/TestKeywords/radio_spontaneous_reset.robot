*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod

*** Variables ***
${LOOPING_KW}                   ${False}


*** Keywords ***
Radio Spontaneous Reset
    [Arguments]    ${RMOD}    ${WAIT}    ${WAIT_FOR_CELLS_UP}    ${SYSLOG_LIST}    ${UNALLOWED_SYSLOGS}
    Run Keyword If                      '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure
      ...                                Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                      ${0}     Check Preconditions    automatic=${True}
    Run Keyword And Continue On Failure  Common Preconditions
    ${RMOD_OBJ}=                         Get Rmod Object From User Given Values    ${RMOD}
    ${rmod_hw_path}=                     Get Values From Object    ${RMOD_OBJ}    hw_path
    ${rmod_name}=                        Get Values From Object    ${RMOD_OBJ}    name
    ${rmod_serial_number}=               Get Values From Object    ${RMOD_OBJ}    serial_number
    Print Text To Eventlog               Target unit: ${rmod_name}
    ${cells_of_rmod}=                    Get Cells Of Radio    ${rmod_name}
    ${LTE441A_ACTIVE}=                   Check If Lte441a Feature Is Active    ${rmod_name}
    Set Suite Variable                   ${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add 10 Fault As Expected To Radios    ${rmod_name}
        ...                                                                    cells_of_radio=${cells_of_rmod}
        ...                                                                    get_and_add_to_chain_radios=${True}
        ...                                                                    lte441a_active=${LTE441A_ACTIVE}
    Run Keyword And Continue On Failure  Add Expected Alarm To Allowed
    ${chained_rmods}=                    Get Chained Rmods         ${rmod_name}
    ${cells_of_rmods_in_chain}=          Get Cells Of Radio        ${chained_rmods}
    ${chained_rmod_names}=               Get Values From Object    ${chained_rmods}   name

# now if rmod in chain it's cells will be also disabled
    ${FAULTY_CELL}=                      add_list_to_list    ${cells_of_rmod}     ${cells_of_rmods_in_chain}
# This is needed if Nokia nahka radio and there are cells on the radio
    Run Keyword And Continue On Failure  Check If Fault 1815 Should Be Allowed  ${rmod_name}  ${cells_of_rmod}  ${rmod_hw_path}
# This is needed because it depends on commissioning if the fault is allowed or not
    Run Keyword And Continue On Failure  Check If Fault 4590 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
    Run Keyword And Continue On Failure  Check If Fault 4003 Should Be Allowed  ${rmod_name}  lte441a_active=${LTE441A_ACTIVE}
# spontaneous reset
    Print Step Text                      ${1}     Spontaneous reset to ${rmod_name}   automatic=${True}
    Run Keyword And Continue On Failure  Rmod Ltx Spontaneous Reset     ${RMOD_OBJ}
    Run Keyword And Continue On Failure  Wait For Cells Faulty          600    ${FAULTY_CELL}
    Run Keyword And Continue On Failure  Wait For All Cells Up          ${WAIT_FOR_CELLS_UP}
    Run Keyword And Continue On Failure  ALARMS.Check Expected Alarms   wait_active_timeout=300
# wait
    Wait Time And Reason                 ${WAIT}  before checking post conditions
# check alarms and post conditions
    Print Step Text                      ${2}  Check Postconditions    automatic=${True}
    Run Keyword And Continue On Failure  Common Postconditions
    Run Keyword and Continue On Failure  Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword If  '${LOOPING_KW}' == '${False}'    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}


Do Spontaneous Reset To All Radios One By One
    [Documentation]  This KW runs spontaneous reset test to all radio modules that are found from enviroment one by one.
    [Arguments]    ${WAIT}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}    ${UNALLOWED_SYSLOGS}
    Set Suite Variable                     ${LOOPING_KW}    ${True}
    Run Keyword And Continue On Failure    Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_LIST}=                          Get All Radios
    FOR    ${radio}    IN    @{RMOD_LIST}
        Run Keyword If  '${KW_SUCCESS}' == '${True}'    Run Keyword And Continue On Failure    Radio Spontaneous Reset
        ...     ${radio}  ${WAIT}    ${WAIT_FOR_CELLS_UP}  ${SYSLOG_LIST}    ${UNALLOWED_SYSLOGS}
    END
    Run Keyword And Continue On Failure    Stop Background Syslog Print Search
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}
