*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library    DateTime

*** Variables ***
&{state_dict_unblock}    administrativeState=unlocked  operationalState=enabled  blockingState=unblocked

*** Keywords ***
Reset Radio
    [Arguments]    ${RMOD_TO_RESET}  ${KPI}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    ${RMOD_OBJ}=                          Get RMOD Object From User Given Values  ${RMOD_TO_RESET}
    ${LTE441A_ACTIVE}=                    Check If Lte441a Feature Is Active  ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure   Check If Fault 4003 Should Be Allowed  ${RMOD_OBJ.name}  lte441a_active=${LTE441A_ACTIVE}
    Print Step Text                    1  Check Preconditions  automatic=${True}
    Run Keyword And Continue On Failure   Common Preconditions
    ${RADIO_CELLS}=                       Get Cells Of Radio  ${RMOD_OBJ.name}
    Print Step Text                    2  Reset ${RMOD_TO_RESET}  automatic=${True}
    Print Text To Eventlog                Request warm reset to ${RMOD_OBJ.dist_name} (${RMOD_OBJ.name}) (${RMOD_OBJ.serial_number})
    ${RESET_TIMESTAMP}=                   DateTime.Get Current Date	 UTC  result_format=datetime
    Run Keyword And Continue On Failure   ADMIN.Reset Unit  dist_name=${RMOD_OBJ.dist_name}  reset_type=Warm  timeout=600  detailed_output=True
    Print Step Text                    3  Wait For All Cells Up max ${WAIT_FOR_CELLS_UP} seconds  automatic=${True}
    ${DEGRADED}=                          Set Variable If  '${KPI}' == 'C'  All  ${None}
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}  degraded_cells=${DEGRADED}
    Print Step Text                    4  Check alarm history  automatic=${True}
    Run Keyword And Continue On Failure   Check Alarm History  reset_alarms=True
    Print Step Text                    5  Check cell states  automatic=${True}
    &{cell_state_dict}                    Create Dictionary  All_cells=${state_dict_unblock}
    Run Keyword And Continue On Failure   Check Cell States  ${cell_state_dict}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Print Step Text                    6  Check Postconditions  automatic=${True}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    7  Collect KPIs  automatic=${True}
    Run Keyword and Continue On Failure   Collect KPIs  Radio reset ${KPI}
    Run Keyword And Continue On Failure   Check Loop Kpi  Radio reset ${KPI}  ${OAM_KPI_TARGETS}
    Print Step Text                    8  Print extra KPIs  automatic=${True}
    ${RESET_TIMESTAMP_CONVERTED}=         Get Omkpi Timestamp  ${RESET_TIMESTAMP}
    Run Keyword And Continue On Failure   Print Extra KPIs  RU reset  start_point=${RESET_TIMESTAMP_CONVERTED}  cells=${True}
    ...                                                               cells_to_print=${RADIO_CELLS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Reset All Radios In Succession
    [Documentation]  This keyword resets all radios one by one in succession.
    [Arguments]     ${KPI}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${COMMISSIONING_PARAMETERS}  ${RMOD}

    IF    '${KPI}' == 'C'
        Print Step Text                      1  Create delta file  automatic=${True}
        Run Keyword And Continue On Failure     Create Delta File And Perform Recommissioning    ${COMMISSIONING_PARAMETERS}
    END


    Print Step Text                       2  Reset the next radio in sequence  automatic=${True}
    Run Keyword And Continue On Failure   Reset Radio  ${RMOD}  ${KPI}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
    Print Text To Eventlog                Radio ${RMOD} has been reset
    Run Keyword And Continue On Failure   Reset Alarms


    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
