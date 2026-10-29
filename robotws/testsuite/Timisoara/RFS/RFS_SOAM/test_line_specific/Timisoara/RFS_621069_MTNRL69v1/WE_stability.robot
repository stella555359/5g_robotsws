*** Settings ***
Documentation  Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_MTNRL69    SBTS00

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__Stability.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Robustness.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    240
    ...    AND    Set Test Variable    ${CHECKS_INTERVAL}    10
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION}    False
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_CHECK}    False
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/TARGET_SW_SLAVE1
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/TARGET_SW_SLAVE2

    ...    AND    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__Robustness_BTS1_Reset
    [Timeout]    14400
    Set Test Variable    ${runs}    2
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
        ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
        ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    660
        ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

        ...    AND    Set Test Variable    ${runs}    2
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

[1.1]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  EA203756188,EA203756202
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    400
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

[1.2]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  AS212707135,F7204203029
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    400
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS__STATE__Robustness_Cell_Block
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  30,31,32,124
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

[1]SBTS_SBTS__STATE__Robustness_Cell_Unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  30,31,32,124
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



[1]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${KPI_LIST}    kpi1a
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    500
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    400
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    240
    ...    AND    Set Test Variable    ${CHECKS_INTERVAL}    10
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION}    False
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_CHECK}    False
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/TARGET_SW_SLAVE1
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/TARGET_SW_SLAVE2

    ...    AND    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order



[2]SBTS_SBTS__STATE__Robustness_BTS1_Reset
    [Timeout]    14400
    Set Test Variable    ${runs}    2
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
        ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    300
        ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    660
        ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

        ...    AND    Set Test Variable    ${runs}    2
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

[2.1]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS1
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  EA203756188,EA203756202
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    400
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
    ...    AND    Set Test Variable    ${SNAPSHOT_COLLECT}    False

    ...    AND    SBTS_SBTS__STATE__Robustness.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Robustness
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Robustness
    TC__SBTS_SBTS__STATE__Robustness
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Robustness.TC Teardown
    ...    AND    Restore Resource Search Order

[2.2]SBTS_SBTS__STATE__Robustness_RMOD_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Reset
    ...    AND    Set Test Variable    ${RESOURCE}    RMOD
    ...    AND    Set Test Variable    ${HW_SN_LIST}  AS212707135,F7204203029
    ...    AND    Set Test Variable    ${CELL_ID_LIST}
    ...    AND    Set Test Variable    ${RAT_LIST}
    ...    AND    Set Test Variable    ${RAT_RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${RESET_WITHOUT_RU}    False
    ...    AND    Set Test Variable    ${OAM_OPERATION_TIMEOUT}    400
    ...    AND    Set Test Variable    ${BTS_STABLE_TIME}    606
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
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Block
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  30,31,32
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

[2]SBTS_SBTS__STATE__Robustness_Cell_Unblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__robustness_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${OAM_OPERATION}    Unblock
    ...    AND    Set Test Variable    ${RESOURCE}    NRCEL
    ...    AND    Set Test Variable    ${HW_SN_LIST}
    ...    AND    Set Test Variable    ${CELL_ID_LIST}  30,31,32
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



[2]SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${KPI_LIST}    kpi1a
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR_LIST}    660
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    500
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    400
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Timeout]    34400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    360
    ...    AND    Set Test Variable    ${CHECKS_INTERVAL}    10
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION}    False
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_CHECK}    False
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/TARGET_SW_SLAVE1
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/TARGET_SW_SLAVE2

    ...    AND    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order