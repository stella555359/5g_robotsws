*** Settings ***
Documentation    Robot Test Suite
Force Tags    QCD_MN_RAN    QCP_RAN_ST    CLOUD_HRAN_RFS_AIR_B4_AILR_B4_B5_MTNRL90_3xFHFB_3xAHFIB_1xMDEA    SBTS00

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__Stability.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_6
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_7
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_8
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_9
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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

[1]SBTS_SBTS_SBTS_SBTS__LOGS__Stability_10
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    210
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




