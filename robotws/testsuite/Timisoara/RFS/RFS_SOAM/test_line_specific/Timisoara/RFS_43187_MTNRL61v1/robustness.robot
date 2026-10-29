*** Settings ***
Documentation  Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_MTNRL61    SBTS00

Resource    ../../../test_resources/SBTS_SBTS__STATE__Robustness.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__Robustness_Cell_Block
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  9,10,6,7
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    100
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  EA231552536,EA231552539,AS220890753,AS214812125
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__Robustness_Cell_Unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  9,10,6,7
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    100
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

[2]SBTS_SBTS__STATE__Robustness_Cell_Block
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  9,10,6,7
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    100
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

[2]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  EA231552536,EA231552539,AS220890753,AS214812125
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__Robustness_Cell_Unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  9,10,6,7
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    100
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order