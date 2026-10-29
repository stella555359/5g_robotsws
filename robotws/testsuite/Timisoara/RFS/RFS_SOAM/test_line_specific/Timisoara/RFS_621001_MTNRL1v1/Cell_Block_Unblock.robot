*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[4]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[5]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[6]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[7]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[8]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[9]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[10]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[11]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[12]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[13]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[14]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[15]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[16]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[17]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[18]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[19]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[20]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    360
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    360

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order
