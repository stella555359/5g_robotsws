*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[4]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[5]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[6]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[7]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[8]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[9]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[10]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order
