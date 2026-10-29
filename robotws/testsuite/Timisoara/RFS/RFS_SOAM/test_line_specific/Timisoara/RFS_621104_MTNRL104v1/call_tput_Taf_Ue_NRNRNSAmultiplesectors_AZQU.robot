*** Settings ***
Documentation    Test Suite
Resource    ../../../test_resources/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL104_2AZQS_3AZQU_1AHPE_3AHEH
...    SBTS25R1    STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}    ${FALSE}


*** Test Cases ***
[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE1}    10.0.71.104
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESS_LTE2}    10.0.71.204
    ...    AND    Set Test Variable    ${NR_MASTER_UE_CAPABILITIES}    NR2
    ...    AND    Set Test Variable    ${NR_SLAVE_UE_CAPABILITIES}    NR1
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_MASTER_UE}    66
    ...    AND    Set Test Variable    ${CELLS_LIST_NR_SLAVE_UE}    ANY
    ...    AND    Set Test Variable    ${CALL_DURATION}    120
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_MASTER_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DIRECTION_NR_SLAVE_UE}    uplink_downlink
    ...    AND    Set Test Variable    ${PROTOCOL_NR_MASTER_UE}    udp
    ...    AND    Set Test Variable    ${PROTOCOL_NR_SLAVE_UE}    udp
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_MASTER_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_MASTER_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_MASTER_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_MASTER_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT_NR_SLAVE_UE}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT_NR_SLAVE_UE}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT_NR_SLAVE_UE}    70 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT_NR_SLAVE_UE}    78 Kbits/sec
    ...    AND    Set Test Variable    ${CHECK_NR_MASTER_ATTACH}    aashell
    ...    AND    Set Test Variable    ${CHECK_NR_SLAVE_ATTACH}    aashell
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_MASTER_UE}    None
    ...    AND    Set Test Variable    ${MBN_PROFILE_NR_SLAVE_UE}    None
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${LTE_MASTER_ANCHOR_LIST}  159258626
    ...    AND    Set Test Variable    ${LTE_SLAVE_ANCHOR_LIST}  159284225

    ...    AND    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    TC__RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_NR_NSA_NR_NSA_Data_Transfer_on_Multiple_Sectors_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
