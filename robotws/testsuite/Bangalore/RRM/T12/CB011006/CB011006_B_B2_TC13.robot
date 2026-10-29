# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...           RAN_5G_FDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish Valan
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to verify the functionality of
...             newly introduced FR1 FDD 50Mhz chBW cell NR cell

Resource    resources/Keywords/CB011006_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${UE_ID_50MHz_NOT_CAPABLE}      2
${UE_ID_50MHZ_CAPABLE}      1
${GW_ID_1}     1
${GW_ID_2}     2
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     3


*** Test Cases ***
[1][1.0] CB011006_B_13_1Verify UE attach fails due to lack of 50MHz capability when CB007552 disabled
    [Documentation]     The purpose of this test case is to verify gNB rejects UE attach attempt
    ...                 when UE does not have capability to support 50MHz bandwidth for NR FR1 FDD cells
    [Tags]    QC_28324   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC13
    Log To Console    Starting TestCase...
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Run Keyword And Ignore Error         Make SA Call      ${UE_ID_50MHZ_NOT_CAPABLE}       ${GW_ID_2}
    Make SA Call    ${UE_ID_50MHz_CAPABLE}   ${GW_ID_1}
    Traffic Should Be Successful For SA      ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}       ${UE_ID}
    Sleep   30s
    Stop Data Traffic For SA      ${UE_ID}
    UE Deregister Should Be Successful For SA    ${UE_ID_50MHz_CAPABLE}
    ${pcap_file}        Stop Pcap Collection In GNB     gnbTcpdump  ${Log_Path}
    Log To Console      ${pcap_file}
    [Teardown]      Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
