*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/NR_NR__STATE__BTS1_BTS2_Startup.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_DSS}   alarmId=7114   faultId=7513
&{ADD_IGNORED_ALARM_DSS2}   alarmId=7114   faultId=7509
&{ADD_IGNORED_ALARM_PPS}   alarmId=7108   faultId=1898
&{ADD_IGNORED_ALARM_Phase}   alarmId=7114   faultId=4452
&{ADD_IGNORED_ALARM_XP}   alarmId=7107   faultId=62003



*** Test Cases ***
[1]NR_NR__STATE__BTS1_BTS2_Startup_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order


[1]NR_NR__STATE__BTS1_BTS2_Startup_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nr_nr__state__bts1_bts2_startup_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900

    ...    AND    NR_NR__STATE__BTS1_BTS2_Startup.TC Setup
    ...    AND    Modify Resource Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    ...    AND    Set Library Search Order    NR_NR__STATE__BTS1_BTS2_Startup
    TC__NR_NR__STATE__BTS1_BTS2_Startup
    [Teardown]    Run Keywords    NR_NR__STATE__BTS1_BTS2_Startup.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Restore Resource Search Order



