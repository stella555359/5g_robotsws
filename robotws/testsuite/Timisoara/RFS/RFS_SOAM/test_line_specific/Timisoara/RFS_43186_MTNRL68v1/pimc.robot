*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF
Documentation  Test Suite

Resource    ../../../test_resources/SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL68_1


*** Test Cases ***
[1] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[2] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[3] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[4] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order


[5] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[6] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[7] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[8] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order

[9] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order


[10] Automated_RFS_SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    10

    ...    AND    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
