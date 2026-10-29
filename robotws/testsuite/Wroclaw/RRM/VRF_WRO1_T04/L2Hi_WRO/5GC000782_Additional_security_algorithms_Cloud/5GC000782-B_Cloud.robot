*** Settings ***
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_keywords.robot
Resource     keywords_5GC000782_AiC.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ta5g_tshark
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.tcpdump_AIC.TcpdumpCU    WITH NAME    TcpdumpCU

Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 22R3

Suite Setup    Run Keywords    Modify AiC Config Ciphering 5GC000782-B
...   AND   Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC srb3Support

*** Test Cases ***
5GC000782_B_5_Gnb_Selects_Snow3g_Algorithm_Dl_Data_Cloud
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL&DL traffic is ciphered & diciphered at gNB & UE

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_1_nea1_4_nea2_2_nea3_3_CU.json
    Start tcpdump    file_name=TC_B_5
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_5    ciphering_algoritm=1
    Stop Tshark    alias=${alias}

5GC000782_B_6_Gnb_Selects_Snow3g_Algorithm_Ul_Data_Cloud
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL traffic is ciphered & diciphered at gNB & UE

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_5_nea1_9_nea2_7_nea3_8_CU.json
    Start tcpdump    file_name=TC_B_6
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_6    ciphering_algoritm=1
    Stop Tshark    alias=${alias}

5GC000782_B_7_Gnb_Selects_Snow3g_Algorithm_Ul_Dl_data_Cloud
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
     ...          Also verify that DL & UL traffic is ciphered & diciphered at gNB & UE

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_0_nea1_0_nea2_0_nea3_6_CU.json
    Start tcpdump    file_name=TC_B_7
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_7    ciphering_algoritm=3
    Stop Tshark    alias=${alias}

5GC000782_B_8_Gnb_Selects_Snow3g_Algorithm_Dl_data_Cloud
    [Documentation]   This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that DL & UL traffic is not degrading due to enabling ZUC algorithm

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_1_nea1_4_nea2_2_nea3_3_CU.json
    Start tcpdump    file_name=TC_B_8
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_8    ciphering_algoritm=1
    Stop Tshark    alias=${alias}

5GC000782_B_9_Gnb_Selects_Snow3g_Algorithm_Ul_Dl_Zuc_Data_Cloud
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/deciphering of user data
    ...         Also verify that DL traffic is ciphered & deciphered at gNB and UE respectively

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_1_nea1_1_nea2_0_nea3_1_CU.json
    Start tcpdump    file_name=TC_B_9
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_9    ciphering_algoritm=1
    Stop Tshark    alias=${alias}

5GC000782_B_14_Gnb_Selects_Aes_Algorithm_Ul_Dl_data_Cloud
    [Documentation]  This TC verify that gNB selects AES ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL&DL traffic is ciphered & diciphered at gNB & UE

    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC000782/5GC000782_B/nea0_1_nea1_2_nea2_9_nea3_3_CU.json
    Start tcpdump    file_name=TC_B_14
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=5mbps
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=5mbps
    Sleep    20s
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Detach Ue    ue_id=11
    Stop tcpdump
    Check Wireshark Pcap For Exisitng Messages    alias=${alias}    file_name=TC_B_14    ciphering_algoritm=2
    Stop Tshark    alias=${alias}
