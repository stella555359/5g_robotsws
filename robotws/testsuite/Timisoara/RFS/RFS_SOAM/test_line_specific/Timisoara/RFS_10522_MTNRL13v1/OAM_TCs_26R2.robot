*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RAT_Reset_CB010846.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446.robot


Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL13
...    26R2   STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_without_ru_reset_cb012446_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTimeSite}    450
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${CB012446_SHARED_RM_SN_EXCEPTIONS_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_CB012446.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__BBMOD_Reset_from_WEBEM_CB010846
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${ACTIVATE_CB010846}    ${False}
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime}    450
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB007447_RMOD_SN}
    ...    AND    Set Test Variable    ${EXCEPTED_FROM_CB010846_RMOD_SN}
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_RFS_SBTS_SBTS__STATE__RAT_Reset_from_WEBEM_CB010846
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rat_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTime}    450
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${RAT_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__RAT_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RAT_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RAT_Reset_CB010846
    TC__SBTS_SBTS__STATE__RAT_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RAT_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order

[1][3.0] Automated_RFS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1][1.0] Automated_RFS_SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_power_off_peer_BTS_CB012446
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_without_ru_reset_with_peer_bts_powered_off_cb012446_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${cntrldResetMplaneBreakTimeSite}    450
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${BTS1_SYNC_ROLE}    Master
    ...    AND    Set Test Variable    ${BTS2_SYNC_ROLE}    Slave

    ...    AND    SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
    TC__SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_without_RU_reset_with_peer_BTS_powered_off_CB012446.TC Teardown
    ...    AND    Restore Resource Search Order


