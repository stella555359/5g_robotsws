*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSCMTNRL157
Documentation
...   contact: VRF_SISO
...   maintainer: Raluca Butcovan
Resource    ../../../test_resources/CBTS_SBTS__LOGS__Stability.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Reset.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}   ${FALSE}
${POWER_ON_FLAG}    ${True}
${USER_UPDATE_DCAP}  ${FALSE}
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR_T02
${SCOUT_TL_NAME}    10_18_UTESRANRFSCMTNRL157
${TEST STATUS}  PASSED
${USB_Byte_Protocol}  ${True}



*** Test Cases ***
[1][1.0] Automated_CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FHGW_CONNECT}    False
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_CBTS_SBTS__STATE__RM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    240
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__RM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Reset
    TC__CBTS_SBTS__STATE__RM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__LOGS__Stability
    [Timeout]    94400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    600
    ...    AND    Set Test Variable    ${CHECK_INTERVAL}    1
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_CBTS}    True
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_SBTS}    True
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4}    Current

    ...    AND    CBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    CBTS_SBTS__LOGS__Stability
    TC__CBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    CBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order



[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    UE1 UE2 UE3 UE4
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS3 BTS4
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE NR LTE
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order