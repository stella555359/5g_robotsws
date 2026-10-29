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
${UE_ID}     1
${GW_ID}     1
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     3

*** Test Cases ***
[1][1.0] CB011006_A_4_1Verify_Successful_L3_call_in_NR_cell_FR1_FDD_50Mhz_chBW_in_SA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify successful SA call on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28321   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]      Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make SA Call           ${UE_ID}    ${GW_ID}
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID}
    Sleep    10s
    Stop Traffic For SA    ${UE_ID}
    ${pcap_file}        Stop Pcap Collection In GNB     gnbTcpdump      ${Log_Path}
    Log To Console      ${pcap_file}
    [Teardown]      Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
