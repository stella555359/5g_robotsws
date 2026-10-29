*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL104_2AZQS_3AZQU_1AHPE_3AHEH
...    SBTS00   STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}    ${TRUE}
${POWER_ON_FLAG}    ${True}
${CNI_127210_ENABLED}    ${True}



*** Test Cases ***
[1]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[2]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[3]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[4]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[5]SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    700
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    True
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[1][4.0] Automated_RFS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${SHARED_RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    400
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][3.0] Automated_RFS_SBTS_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    259200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    480
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order
