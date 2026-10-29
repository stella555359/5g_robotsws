*** Settings ***
Documentation
...    Test Suite Author: Mateusz Kawka
...    Test Suite Owner: Magda Bielska

Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.robot
Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.robot
Resource          ../../../../test_resources/BS-RF/SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.robot
Library           ../../../../../../resources/ca_BSRF_excel_operation.py  WITH NAME  excel

Suite Setup
...  excel.Create Excel File  ${REPORT_NAME}   ${PATH_TO_REPORT_FILE}  sheet_name=${MAIN_SHEET_NAME}

*** Variables ***
${PATH_TO_REPORT_FILE}     /home/ute/logi_EEM/5G_Evolution
${REPORT_NAME}             EEM_REPORT_SRAN_EUR_5GEVOLUTION
${MAIN_SHEET_NAME}         SRAN_EUR_5GEVOLUTION
${BTS_MPLANE_IP}           10.42.175.65
${BTS_ID}                  1318

*** Test Cases ***

[1]SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    Idle with cells locked
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Idle_Cell_Locked.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    onAir
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Low_Cell_Onair.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_5_1dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  51
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_51dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_2_9dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  29
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_29dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1]SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset_0dB
    [Setup]    Run Keywords
    ...    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${INTERVAL_AMOUNT}    4
    ...    AND    Set Test Variable    ${TM_OFFSET}  0
    ...    AND    Set Test Variable    ${COUNTERS_SHEET_NAME}    TM1_1-Offset_0dB
    ...    AND    Set Test Variable    ${SNAPSHOT}    True
    ...    AND    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Timeout]    14400
    TC__SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset
    [Teardown]    SiSo_PM_Energy_Efficiency_Measurements_Medium_TM1_1_Offset.TC Teardown


[1] Calculate ETSI avg (wighted)
    Calculate ETSI  ETSI avg (wighted)

[1] Calculate ETSI Avg Target(W)-wighted
    Calculate ETSI  ETSI Avg Target(W)-wighted
