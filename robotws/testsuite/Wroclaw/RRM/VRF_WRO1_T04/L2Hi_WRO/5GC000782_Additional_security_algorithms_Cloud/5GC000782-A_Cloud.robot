*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_keywords.robot
Resource     keywords_5GC000782_AiC.robot
Variables     ../resources/common_variables_vran.py
Library     ta5g_tshark
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.tcpdump_AIC.TcpdumpCU    WITH NAME    TcpdumpCU

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 22R3

Suite Setup    Run Keywords    Modify AiC Config Ciphering 5GC000782-A
...   AND   Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC srb3Support

Test Setup    Start Default Tshark On S1 Mme And Uu Interfaces Aic    log_dirpath=${OUTPUT DIR}/tshark

Test Teardown    Stop Existing Default Tshark On S1 Mme And Uu Interfaces

*** Variables ***
${SgNBAdditionRequestReject}=    x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 2 and x2ap.Cause == 0 and x2ap.radioNetwork == 15
${DEFAULT_NG_XN_TSHARK_ALIAS}=    default_s1_x2

*** Test Cases ***
5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb_Cloud
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as NULL and AES(nea2-128) but gNB support only
    ...        SNOW3G(nea1-128) and ZUC(nea3-128)
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_0_nea1_1_nea2_0_nea3_2_CU.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=11

5GC000782_A_12_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb_Cloud
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and ZUC(nea3-128) but
    ...        gNB support only AES(nea2-128)
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_0_nea1_0_nea2_8_nea3_0_CU.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=12
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=12

5GC000782_A_13_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb_Cloud
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and AES(nea2-128) but
    ...        gNB support only ZUC(nea3-128)
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_0_nea1_0_nea2_0_nea3_6_CU.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=13
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=13

5GC000782_A_17_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb_Cloud
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and AES(nea2-128) but
    ...        gNB support only ZUC(nea3-128)
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_0_nea1_0_nea2_0_nea3_0_CU.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=14
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=14

5GC000782_A_1_2_Gnb_Selects_Zuc_Algorithm_Dl_Ul_Data_Cloud
    [Documentation]    This test case Verifies gNB selects NULL algorithm
    ...        having high priority and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_1_nea1_4_nea2_6_nea3_8_CU.json
    Start tcpdump    file_name=TC_A_1_2
    Attach Ue And Perform SgNBAdditionRequest    ue_id=14
    Start Data Traffic    ues=14    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=14    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=14
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_A_1_2    ciphering_algoritm=3
    Stop Tshark    alias=${alias}

5GC000782_A_3_Gnb_Selects_Zuc_Nea3_128_Algorithm_Dl_Ul_Data_Cloud
    [Documentation]     This TC verify that gNB selects ZUC ciphering algorithm for ciphering/diciphering of user data
    ...        having high priority and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.
    ...        AP P1 NSA TDD Asik/Abil or Asib/Abil

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_5_nea1_6_nea2_7_nea3_8_CU.json
    Start tcpdump    file_name=TC_A_3
    Attach Ue And Perform SgNBAdditionRequest    ue_id=14
    Start Data Traffic    ues=14    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=14    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Detach Ue    ue_id=14
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_A_3    ciphering_algoritm=3
    Stop Tshark    alias=${alias}

5GC000782_A_15_Gnb_Selects_Null_Algorithm_Dl_Ul_Data_Cloud
    [Documentation]     This test case Verifies gNB selects NULL algorithm
    ...        having high priority and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_A/nea0_1_nea1_0_nea2_0_nea3_0_CU.json
    Start tcpdump    file_name=TC_A_15
    Attach Ue And Perform SgNBAdditionRequest    ue_id=14
    Start Data Traffic    ues=14    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=14    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Detach Ue    ue_id=14
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_A_15    ciphering_algoritm=0
    Stop Tshark    alias=${alias}
