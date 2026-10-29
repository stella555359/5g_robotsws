# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_CPRI_CMWV_FDD
...           RAN_5G_FDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish Valan
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to verify the functionality of newly introduced FR1 FDD 50Mhz chBW CELL NR CELL

Resource    resources/Keywords/CB011006_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables  ***
${CELL1}        50
${CELL2}        51
${UE_ID}         1
${GW_ID}         1
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     3

*** Test Cases ***
[1][1.0] CB011006_B_12_1Verify_intra_gNB_Handover_between_cells_configured_between_different_BW
    [Documentation]     The purpose of this test case is to verify successful Intra-gNB handover from
    ...                 FR1 FDD non 50MHZ chBW NR CELL to FR1 FDD 50Mhz chBW NR CELL and vice versa.
    [Tags]    QC_28323   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC12
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make SA Call            ${UE_ID}         ${GW_ID}
    Traffic Should Be Successful For SA      ${TRAFFIC_DL_RATE}     ${TRAFFIC_UL_RATE}       ${UE_ID}
    Log To Console      \n Starting A2 event
    ${MEAS_ID_FOR_UE}      Display Measurement Configuration For UE      ${UE_ID}     A2
    Log To Console      ${MEAS_ID_FOR_UE}
    Trigger A2 Measurement       ${UE_ID}      ${MEAS_ID_FOR_UE}         ${CELL1}
    Log To Console      \nStarting HO based on A3 event
    ${MEAS_ID_FOR_UE}      Display Measurement Configuration For UE      ${UE_ID}     A3
    Log To Console      ${MEAS_ID_FOR_UE}
    Trigger A3 Measurement       ${UE_ID}      ${MEAS_ID_FOR_UE}         ${CELL2}
    Sleep   15s
    Log To Console      \n Starting A2 event
    ${MEAS_ID_FOR_UE}      Display Measurement Configuration For UE      ${UE_ID}     A2
    Log To Console      ${MEAS_ID_FOR_UE}
    Trigger A2 Measurement       ${UE_ID}      ${MEAS_ID_FOR_UE}         ${CELL2}
    Log To Console      \nStarting HO based on A3 event
    ${MEAS_ID_FOR_UE}      Display Measurement Configuration For UE      ${UE_ID}     A3
    Log To Console      ${MEAS_ID_FOR_UE}
    Trigger A3 Measurement       ${UE_ID}      ${MEAS_ID_FOR_UE}         ${CELL1}
    Sleep   15s
    Stop Data Traffic for SA     ${UE_ID}
    ${PCAP_FILE}        Stop Pcap Collection In GNB     gnbTcpdump       ${LOG_PATH}
    Log To Console      ${PCAP_FILE}
    [Teardown]          Run Keyword And Ignore Error      Common Test Case Tear Down BOO AP LOO
