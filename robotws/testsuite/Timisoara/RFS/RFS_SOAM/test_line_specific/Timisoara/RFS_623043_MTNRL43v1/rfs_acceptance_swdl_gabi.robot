*** Settings ***
Documentation
...   author: Alin Bacos
...   maintainer: traian-alin.bacos@nokia.com

Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL43_1
${CNI_127210_ENABLED}    ${True}


*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}   900
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_RESET_UPDATE_WRN_THR}   900
    ...    AND    Set Test Variable    ${BTS_RESET_ROLLBACK_WRN_THR}   900
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order
