# Copyright (c) 2020 Nokia. All rights reserved.


*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...           RAN_5G_FDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish Valan
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to verify the functionality of newly introduced FR1 FDD 50Mhz chBW cell NR cell

Resource    resources/Keywords/CB011006_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE_ID_1}             11
${UE_ID_2}             12
${UE_ID_3}             13
${UE_ID_4}             14
${UE_ID_5}             15
${BEARER_ID}           2
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     2

*** Test Cases ***
[1][1.0] CB011006_A_8_1Verify_Successful_L3_call_for_multiple_UE_in_NR_cell_FR1_FDD_50Mhz_chBW_in_NSA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify multiple NSA UE attach and DL and UL data transfer
    ...                 on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28320   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]      Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Log To Console          \nStarting the  CB011006_A_B2_TC8
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make ENDC Call    ${UE_ID_1}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Make ENDC Call    ${UE_ID_2}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Make ENDC Call    ${UE_ID_3}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Make ENDC Call    ${UE_ID_4}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Make ENDC Call    ${UE_ID_5}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Sleep    10s
    Stop Traffic      ${UE_ID_1}    ${BEARER_ID}
    Stop Traffic      ${UE_ID_2}    ${BEARER_ID}
    Stop Traffic      ${UE_ID_3}    ${BEARER_ID}
    Stop Traffic      ${UE_ID_4}    ${BEARER_ID}
    Stop Traffic      ${UE_ID_5}    ${BEARER_ID}
    UE 5GDetach Should Be Successful For NSA    ${UE_ID_1}
    UE 5GDetach Should Be Successful For NSA    ${UE_ID_2}
    UE 5GDetach Should Be Successful For NSA    ${UE_ID_3}
    UE 5GDetach Should Be Successful For NSA    ${UE_ID_4}
    UE 5GDetach Should Be Successful For NSA    ${UE_ID_5}
    Stop Pcap Collection In GNB     gnbTcpdump      ${Log_Path}
    [Teardown]      Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
