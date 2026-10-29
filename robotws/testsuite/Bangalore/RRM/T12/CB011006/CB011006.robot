*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Jenish Valan
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to verify the functionality of newly introduced FR1 FDD 50Mhz chBW cell NR cell

Resource    resources/Keywords/CB011006_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
# PDU Session Patterns
${PDU_SESSION_MOD_PATTERN}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${PDU_SESSION_QOS_PATTERN}     QoS Routing Table
${UE_ID_50MHz_NOT_CAPABLE}      2
${UE_ID_50MHZ_CAPABLE}      1
${GW_ID_1}     1
${GW_ID_2}     2
${TRAFFIC_DL_RATE}     5
${TRAFFIC_UL_RATE}     3


*** Test Cases ***
[1][1.0] CB011006_A_3_1Verify_Successful_L3_call_in_NR_cell_FR1_FDD_50Mhz_chBW_in_NSA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify successful NSA call on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28322   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    ${UE_ID}    Set Variable    11
    ${TARGET_CELLS}    Set Variable    1
    ${BEARER_ID}    Set Variable    2
    ${TRAFFIC_DL_RATE}    Set Variable    5
    ${TRAFFIC_UL_RATE}    Set Variable    2
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make ENDC Call    ${UE_ID}    ${TARGET_CELLS}    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    Sleep    10s
    Stop Traffic      ${UE_ID}    ${BEARER_ID}
    UE 5GDetach Should Be Successful For NSA         ${UE_ID}
    Stop Pcap Collection In GNB     gnbTcpdump       ${Log_Path}
    [Teardown]     Teardown Edaemon And Egate process

[1][1.0] CB011006_A_4_1Verify_Successful_L3_call_in_NR_cell_FR1_FDD_50Mhz_chBW_in_SA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify successful SA call on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28321   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]     Start UTE WTS      basic_setup_TC3_TC4_TC8_TC9.cfg
    ${UE_ID}    Set Variable    1
    ${GW_ID}    Set Variable    1
    ${TRAFFIC_DL_RATE}    Set Variable    5
    ${TRAFFIC_UL_RATE}    Set Variable    3
    Start Pcap Collection In GNB CU
    Basic Bring Up
    Make SA Call           ${UE_ID}    ${GW_ID}
    Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_ID}
    Sleep    10s
    Stop Traffic For SA    ${UE_ID}
    UE Deregister Should Be Successful For SA     ${UE_ID}
    ${pcap_file}        Stop Pcap Collection In GNB     gnbTcpdump      ${Log_Path}
    Log To Console      ${pcap_file}
    [Teardown]      Teardown Edaemon And Egate process

[1][1.0] CB011006_A_8_1Verify_Successful_L3_call_for_multiple_UE_in_NR_cell_FR1_FDD_50Mhz_chBW_in_NSA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify multiple NSA UE attach and DL and UL data transfer
    ...                 on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28320   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Start UTE WTS      basic_setup_TC3_TC4_TC8_TC9.cfg
    ${BEARER_ID}    Set Variable    2
    ${TRAFFIC_DL_RATE}    Set Variable    5
    ${TRAFFIC_UL_RATE}    Set Variable    2
    @{UE_IDS}    Create List    11    12    13    14    15
    Start Pcap Collection In GNB CU
    Basic Bring Up
    FOR    ${UE_ID}    IN    @{UE_IDS}
        Make ENDC Call    ${UE_ID}    1    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}
    END
    Sleep    10s
    FOR    ${UE_ID}    IN    @{UE_IDS}
        Stop Traffic      ${UE_ID}    ${BEARER_ID}
        UE 5GDetach Should Be Successful For NSA    ${UE_ID}
    END
    Stop Pcap Collection In GNB     gnbTcpdump      ${Log_Path}
    [Teardown]    Teardown Edaemon And Egate process

[1][1.0] CB011006_A_9_1Verify_Successful_L3_call_for_multiple_UE_in_NR_cell_FR1_FDD_50Mhz_chBW_in_SA_mode_with_both_UL_and_DL_data
    [Documentation]     The purpose of this test case is to verify multiple SA UE attach and DL and UL data transfer
    ...                 on NR cell FR1 FDD 50Mhz chBW cell.
    [Tags]    QC_28319   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CB011006_TC3_TC4_TC8_TC9
    Start UTE WTS      basic_setup_TC3_TC4_TC8_TC9.cfg
    ${TRAFFIC_DL_RATE}    Set Variable    5
    ${TRAFFIC_UL_RATE}    Set Variable    3
    @{UE_IDS}    Create List    1    2    3    4    5
    @{GW_IDS}    Create List    1    2    3    4    5
    Start Pcap Collection In GNB CU
    Basic Bring Up
    FOR    ${INDEX}    IN RANGE    5
        Enable Internal TG   ${UE_IDS}[${INDEX}]      1
        UE Register Should Be Successful For SA    ${UE_IDS}[${INDEX}]    ${GW_IDS}[${INDEX}]
        Sleep   10s
        Traffic Should Be Successful For SA    ${TRAFFIC_DL_RATE}    ${TRAFFIC_UL_RATE}    ${UE_IDS}[${INDEX}]
    END
    FOR    ${UE_ID}    IN    @{UE_IDS}
        Stop Data Traffic For SA    ${UE_ID}
    END
    ${PCAP_FILE}        Stop Pcap Collection In GNB     gnbTcpdump      ${LOG_PATH}
    Log To Console      ${PCAP_FILE}
    [Teardown]   Teardown Edaemon And Egate process


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
    [Teardown]     RAT block unblock
