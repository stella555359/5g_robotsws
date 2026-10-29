# Copyright (c) 2020 Nokia. All rights reserved.


*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...           RAN_5G_FDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish Valan
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to verify the functionality of newly introduced FR1 FDD 50Mhz chBW NR cell

Resource    resources/Keywords/CB011006_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables  ***
${PDU_SESSION_MOD_PATTEN}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${PDU_SESSION_QOS_PATTERN}     QoS Routing Table
${UE_ID_1}     1
${UE_ID_2}     2
${UE_ID_3}     3
${UE_ID_4}     4
${UE_ID_5}     5
${GW_ID_1}     1
${GW_ID_2}     2
${GW_ID_3}     3
${GW_ID_4}     4
${GW_ID_5}     5
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     3


*** Test Cases ***
[1][1.0] CB011006_A_9_1Verify_Successful_L3_call_for_multiple_UE_in_NR_cell_FR1_FDD_50Mhz_chBW_in_SA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify multiple SA UE attach and DL and UL data transfer
    ...                 on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28319   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Start Pcap Collection In Gnb Cu
    Basic Bring Up
    Enable Internal TG   ${UE_ID_1}      1
    UE Register Should Be Successful For SA    ${UE_ID_1}    ${GW_ID_1}
    Sleep   10s
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID_1}
    Enable Internal TG   ${UE_ID_2}      1
    UE Register Should Be Successful For SA    ${UE_ID_2}    ${GW_ID_2}
    Sleep   10s
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID_2}
    Enable Internal TG   ${UE_ID_3}      1
    UE Register Should Be Successful For SA    ${UE_ID_3}    ${GW_ID_3}
    Sleep   10s
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID_3}
    Enable Internal TG   ${UE_ID_4}      1
    UE Register Should Be Successful For SA    ${UE_ID_4}    ${GW_ID_4}
    Sleep   10s
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID_4}
    Enable Internal TG   ${UE_ID_5}      1
    UE Register Should Be Successful For SA    ${UE_ID_5}    ${GW_ID_5}
    Sleep   10s
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID_5}
    Stop Data Traffic For SA    ${UE_ID_1}
    Stop Data Traffic For SA    ${UE_ID_2}
    Stop Data Traffic For SA    ${UE_ID_3}
    Stop Data Traffic For SA    ${UE_ID_4}
    Stop Data Traffic For SA    ${UE_ID_5}
    ${PCAP_FILE}        Stop Pcap Collection In GNB     gnbTcpdump      ${LOG_PATH}
    Log To Console      ${PCAP_FILE}
    [Teardown]      Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
