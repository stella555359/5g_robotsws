*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Keywords ***
RF power reset
    [Arguments]    ${RMOD_TO_TEST}  ${WAIT_AFTER_POWER_CUT}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}
    ...            ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${OAM_KPI_TARGETS}

    ${KPIS}=                              Create Dictionary
    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    ${RMOD_OBJ}=                          Get RMOD Object From User Given Values  ${RMOD_TO_TEST}
    Print Text To Eventlog                Target unit: ${RMOD_OBJ.name}
    ${cells_of_rmod}=                     Get Cells Of Radio  ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure   Add Expected Alarm  alarm_id=7116   fault_id=10   fault_name=No connection to unit
    ...                                   severity=Critical / Major   unit_path=${RMOD_OBJ.unit_path}
    ${suite_variables}=      Get variables
    IF  "\${RFS}" in $suite_variables
        IF  '${RFS}' == '${True}'
            Run Keyword And Continue On Failure   Add Radio Of Other Side To Allowed If Shared  ${RMOD_OBJ}  alarm_id=7116
            ...                                   fault_id=10   fault_name=No connection to unit   severity=Critical / Major
        END
    END
# this below is needed if chained rmods
    @{change_values}=                     Create List  unit_path
    ${chained_rmods}=                     Get Chained Rmods  ${RMOD_OBJ.name}
    ${cells_of_rmods_in_chain}=           Get Cells Of Radio  ${chained_rmods}
    Run Keyword And Continue On Failure   Add Objects To Expected_alarms  ${chained_rmods}  ${change_values}  alarm_id=7116  fault_id=10
    ...                                   fault_name=No connection to unit  severity=Critical / Major
    Run Keyword And Continue On Failure   Add Expected Alarm To Allowed
# This is needed if Nokia nahka radio and there are cells on the radio
    ${rmod_hw_path}=                      Get Values From Object  ${RMOD_OBJ}  hw_path
    Run Keyword And Continue On Failure   Check If Fault 1815 Should Be Allowed  ${RMOD_OBJ.name}  ${cells_of_rmod}  ${rmod_hw_path}
    Setup Power Breaker Controller        rmod
    @{ports}=                             Find Ports For Chosen Units  ${RMOD_OBJ.name}
    Print Step Text                    2  Requesting power cut for ${RMOD_OBJ.name} (port: ${ports})
    Run Keyword And Continue On Failure   Turn Power Off From Chosen Units  ${RMOD_OBJ.name}
    Wait Time And Reason                  ${WAIT_AFTER_POWER_CUT}  after power cut
    Print Step Text                    3  Check alarms
    Run Keyword And Continue On Failure   Check Expected Alarms  wait_active_timeout=300
    Print Step Text                    4  Reconnect power to ${RMOD_OBJ.name} (port: ${ports})
    Run Keyword And Continue On Failure   Turn Power On To Chosen Units  ${RMOD_OBJ.name}
    Run Keyword And Continue On Failure   Wait For All Cells Up  ${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Print Step Text                    5  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Run Keyword and Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Reset Alarms
    Print Step Text                    6  Collect KPIs
    ${POWER_ON_START}                     Get Power On Timestamp
    Set Suite Variable                    ${POWER_ON_START}
    Run Keyword and Continue On Failure   Collect KPIs  Rf power reset  ${POWER_ON_START}
    Run Keyword And Continue On Failure   Check Loop Kpi  Rf power reset  ${OAM_KPI_TARGETS}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
