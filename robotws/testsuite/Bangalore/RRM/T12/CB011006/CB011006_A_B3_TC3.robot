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
${UE_ID}             11
${TARGET_CELLS}       1
${BEARER_ID}          2
${TRAFFIC_DL_RATE}    5
${TRAFFIC_UL_RATE}    2


*** Test Cases ***
[1][1.0] CB011006_A_3_1Verify_Successful_L3_call_in_NR_cell_FR1_FDD_50Mhz_chBW_in_NSA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify successful NSA call on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28322   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make ENDC Call    ${UE_ID}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Sleep    10s
    Stop Traffic      ${UE_ID}    ${BEARER_ID}
    UE 5GDetach Should Be Successful For NSA         ${UE_ID}
    Stop Pcap Collection In GNB     gnbTcpdump       ${Log_Path}
    [Teardown]      Run Keyword And Ignore Error     Common Test Case Tear Down LO AP LO
