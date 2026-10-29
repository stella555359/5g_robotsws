*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Robustness.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__Robustness
    [Timeout]    44400
    Set Test Variable    ${runs}    3
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
        ...    AND    Set Test Variable    ${BTS}    BTS1
        ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
        ...    AND    Set Test Variable    ${RESOURCE}    RMOD
        ...    AND    Set Test Variable    ${HW_SN_LIST}    LR242900458,LR240512220,LR240614441,1M234401656,1M234401658,1M234401657
        ...    AND    Set Test Variable    ${CELL_ID_LIST}
        ...    AND    Set Test Variable    ${RAT_LIST}
        ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
        ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
        ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
        ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
        ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
        ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
        ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
        ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    True

        ...    AND    Set Test Variable    ${runs}    3
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
        ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS__STATE__Robustness.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Robustness.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS__STATE__Robustness
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Robustness.TC Teardown
    END
    Restore Resource Search Order



[2]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    Set Test Variable    ${runs}    3
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
        ...    AND    Set Test Variable    ${BTS}    BTS1
        ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
        ...    AND    Set Test Variable    ${RESOURCE}    BTS
        ...    AND    Set Test Variable    ${HW_SN_LIST}
        ...    AND    Set Test Variable    ${CELL_ID_LIST}
        ...    AND    Set Test Variable    ${RAT_LIST}
        ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
        ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
        ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
        ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
        ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
        ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
        ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
        ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    True

        ...    AND    Set Test Variable    ${runs}    3
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
        ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS__STATE__Robustness.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Robustness.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS__STATE__Robustness
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Robustness.TC Teardown
    END
    Restore Resource Search Order



[3]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Power Off
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}    BL2331H60BI,BL2330H60AO,K9241813524
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    True

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order



[4]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}
    ...    AND    Set Test Variable    ${OAM_OPERATION}     Power On
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}    BL2331H60BI,BL2330H60AO,K9241813524
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order



[5]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RAT
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}    NR
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order



[6]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}    1001,1002,1003,1101,1102,1103
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    60
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order



[7]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}    LR242900458,LR240512220,LR240614441
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    606
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order



[8]SBTS_SBTS__STATE__Robustness
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}    1001,1002,1003,1101,1102,1103
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    60
    ...    AND    Set Test Variable    ${CRITICAL_FAULT_ID_LIST}
    ...    AND    Set Test Variable    ${LOAD_HISTORY}    False
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    True

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order
