*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CLOUD_10_18_UTESRANRFSMTNRL122
Documentation    Robot Test Suite
Resource    ../../../test_resources/SBTS__CM__SMOD_Plug_and_Play.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL122_1



*** Test Cases ***
[2]Automated_CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__cm__smod_plug_and_play_alarms_definitions.py
    ...    AND    Set Test Variable    ${TARGET_BTS_SW}
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${SN_OF_NEW_SYSTEM_MODULE}    L1204302086
    ...    AND    Set Test Variable    ${CONFIG_RESET_KPI}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    7200
    ...    AND    Set Test Variable    ${AUTOCONNECTION_OPTION}    HWID

    ...    AND    SBTS__CM__SMOD_Plug_and_Play.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__CM__SMOD_Plug_and_Play
    ...    AND    Set Library Search Order    SBTS__CM__SMOD_Plug_and_Play
    TC__SBTS__CM__SMOD_Plug_and_Play
    [Teardown]    Run Keywords    SBTS__CM__SMOD_Plug_and_Play.TC Teardown
    ...    AND    Restore Resource Search Order

