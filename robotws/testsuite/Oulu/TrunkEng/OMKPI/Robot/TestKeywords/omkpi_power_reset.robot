*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

*** Variables ***
${POWER_RESET_TEST}   ${True}

*** Keywords ***
Power Reset
    [Arguments]  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${PB_WAIT}  ${OAM_KPI_TARGETS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    Run Keyword And Continue On Failure   Enable Extended Post Test
    Setup Power Breaker Controller        smod
    ${FULLRACK}=                          Site Is Fullrack
    ${FULL_BTS}=                          Get Variable Value  ${FULL_BTS}  ${False}
    IF       ${FULL_BTS} == True
            Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
            Run Keyword And Continue On Failure  Switch Power Of All SMODs OFF and ON  ${PB_WAIT}  also_rmod=${True}
    ELSE IF  '${FULL_BTS}' == '${True}'
            Run Keyword And Continue On Failure  Check If Fault 4589 Should Be Allowed
            Run Keyword And Continue On Failure  Switch Power Of All SMODs OFF and ON  ${PB_WAIT}  also_rmod=${True}
    ELSE IF  '${FULLRACK}' == '${True}'
            Run Keyword And Continue On Failure  Switch Power Of All SMODs OFF and ON  ${PB_WAIT}
    ELSE
            Switch Power Of SMOD OFF and ON   ${PB_WAIT}
    END
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                   disconnection=${True}  time_to_wait=300
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure   Special Logs And Or Ssh Commands After Reset Before Test   after_what=Power reset
    Run Keyword And Continue On Failure   Check If Admin Connection Available   900
    Print Step Text                    3  Wait for all cells faulty and up
    Run Keyword And Continue On Failure   Wait For Cells Faulty    600
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                    4  Check If spurious reset in Syslog prints
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Print Step Text                    5  Check from history that SMOD, RMODs, BBMODs and cells were reset
    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  all_cells=${True}
    Print Step Text                    6  Check Ocxo init temperature and setpoints
    Run Keyword And Continue On Failure   Check Ocxo Init Temperature
    Run Keyword And Continue On Failure   Check Ocxo Setpoints
    Print Step Text                    7  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    8  Collect KPIs
    ${POWER_ON_START}                     Get Power On Timestamp
    Set Suite Variable                    ${POWER_ON_START}
    Run Keyword and Continue On Failure   Collect KPIs  Power reset  ${POWER_ON_START}
    Run Keyword And Continue On Failure   Check Loop Kpi  Power reset  ${OAM_KPI_TARGETS}
    Print Step Text                    9  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  Power reset  ${POWER_ON_START}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

RFS Power Reset
    [Arguments]  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${PB_WAIT}  ${OAM_KPI_TARGETS}

    Run Keyword And Continue On Failure   Start Syslog Print Search To Background  ${SYSLOG_LIST}
    Print Step Text                    1  Check Preconditions
    Run Keyword And Continue On Failure   Common Preconditions
#    Run Keyword And Continue On Failure   Check If Netboot Is Active And Deactivate It
    Run Keyword And Continue On Failure   Enable Extended Post Test
    Run Keyword And Continue On Failure   Switch Power Of All SMODs OFF and ON   ${PB_WAIT}
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129
    ...                                   disconnection=True  time_to_wait=300
    Run Keyword And Continue On Failure   Ping Ip Until Disconnection Or Reconnection  ip_to_ping=192.168.255.129  time_to_wait=300
    Run Keyword And Continue On Failure   Check If Admin Connection Available   900
    Print Step Text                    3  Wait for all cells up
    Run Keyword And Continue On Failure   Wait For All Cells Up  time_limit=${WAIT_FOR_CELLS_UP}
    Wait Time And Reason                  ${WAIT_CHECKS}  before checking post conditions
    Print Step Text                    4  Check If spurious reset in Syslog prints
    Run Keyword And Continue On Failure   Check If Unexpected Syslog Print  ${UNALLOWED_SYSLOGS}
    Run Keyword And Continue On Failure   Stop Background Syslog Print Search
    Print Step Text                    5  Check from history that SMOD, RMODs, BBMODs and cells were reset
    Run Keyword And Continue On Failure   Check SMOD RMOD And BBMOD States
    Run Keyword And Continue On Failure   Check If Selected Cells Were Disabled And Enabled  all_cells=${True}  rfs=${True}
    Print Step Text                    6  Check Ocxo init temperature and setpoints
    Run Keyword And Continue On Failure   Check Ocxo Init Temperature
    Run Keyword And Continue On Failure   Check Ocxo Setpoints
    Print Step Text                    7  Check Postconditions
    Run Keyword And Continue On Failure   Common Postconditions
    Print Step Text                    8  Collect KPIs
    ${POWER_ON_START}                     Get Power On Timestamp
    Set Suite Variable                    ${POWER_ON_START}
    Run Keyword and Continue On Failure   Collect KPIs  Power reset  ${POWER_ON_START}
    Run Keyword And Continue On Failure   Check Loop Kpi  Power reset  ${OAM_KPI_TARGETS}
    Print Step Text                    9  Print extra KPIs
    Run Keyword And Continue On Failure   Print Extra KPIs  Power reset  ${POWER_ON_START}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}


Switch Power Of All SMODs OFF and ON
    [Arguments]    ${PB_WAIT}  ${ALSO_RMOD}=${False}
    Print Step Text                    2  Switch power OFF, wait ${PB_WAIT}seconds and switch power ON
    Run Keyword And Continue On Failure   Switch Power Off From All Local Units  also_rmod=${ALSO_RMOD}
    Run Keyword And Continue On Failure   Switch Power On To All Local Units  also_rmod=${ALSO_RMOD}
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}

Switch Power Of SMOD OFF and ON
    [Arguments]    ${PB_WAIT}

    ${SMOD}=                              Get Master SMOD ProductName
    Print Step Text                    2  Switch power OFF, wait ${PB_WAIT}seconds and switch power ON
    Run Keyword And Continue On Failure   Turn Power Off From Chosen Units  ${SMOD}
    Run Keyword And Continue On Failure   Turn Power On To Chosen Units  ${SMOD}

    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}  ${False}
