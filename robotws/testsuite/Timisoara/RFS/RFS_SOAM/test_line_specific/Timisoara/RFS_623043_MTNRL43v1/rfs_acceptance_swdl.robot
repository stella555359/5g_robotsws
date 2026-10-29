*** Settings ***
Documentation    Robot Test Suite 2
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${USER_RSI_INFO_COLLECT}    ${False}
${USER_RMOD_UDP_LOG_COLLECT}    ${False}


*** Test Cases ***
[1]SBTS_SBTS__SWM__BTS1_BTS2_SWDL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/Downloads
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/Downloads
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/Downloads
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/Downloads
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    6000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    1697
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    1600
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}    None
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__SWM__BTS1_BTS2_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    ALL
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    1200
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    1800

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__SWM__BTS1_BTS2_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    ALL
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    1200
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    1800

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order


