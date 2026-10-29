*** Settings ***
Documentation    Test Suite
Resource    ../../../test_resources/NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost.robot
Resource    ../../../test_resources/NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config.robot
Resource    ../../../test_resources/NRL__STATE__NR_Site_Reset_with_sharedFHS_config.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/NRL__STATE__NR_SharedFHS_Reset.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
${USER_STOP_AND_FIX}    ${True}
${USER_STOP_AND_FIX_BLOCK_TEST}    ${False}


*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    400
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    240
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NRL__STATE__NR_Site_Reset_with_sharedFHS_config
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__state__nr_site_reset_with_sharedFHS_config_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    240
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    NRL__STATE__NR_Site_Reset_with_sharedFHS_config.TC Setup
    ...    AND    Modify Resource Search Order    NRL__STATE__NR_Site_Reset_with_sharedFHS_config
    ...    AND    Set Library Search Order    NRL__STATE__NR_Site_Reset_with_sharedFHS_config
    TC__NRL__STATE__NR_Site_Reset_with_sharedFHS_config
    [Teardown]    Run Keywords    NRL__STATE__NR_Site_Reset_with_sharedFHS_config.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__state__bbmod_sharedfhs_primary_link_is_lost_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${FHS_serialNumber}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    240
    ...    AND    NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost.TC Setup
    ...    AND    Modify Resource Search Order    NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
    ...    AND    Set Library Search Order    NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
    TC__NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
    [Teardown]    Run Keywords    NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__state__nr_sm_power_off_on_with_with_sharedFHS_config_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    240
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${NR_MAX_WAIT_TIME}    900
    ...    AND    NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config.TC Setup
    ...    AND    Modify Resource Search Order    NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config
    ...    AND    Set Library Search Order    NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config
    TC__NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config
    [Teardown]    Run Keywords    NRL__STATE__NR_SM_Power_Off_On_with_sharedFHS_config.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NRL__STATE__NR_SharedFHS_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__state__nr_sharedfhs_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    NRL__STATE__NR_SharedFHS_Reset.TC Setup
    ...    AND    Modify Resource Search Order    NRL__STATE__NR_SharedFHS_Reset
    ...    AND    Set Library Search Order    NRL__STATE__NR_SharedFHS_Reset
    TC__NRL__STATE__NR_SharedFHS_Reset
    [Teardown]    Run Keywords    NRL__STATE__NR_SharedFHS_Reset.TC Teardown
    ...    AND    Restore Resource Search Order
