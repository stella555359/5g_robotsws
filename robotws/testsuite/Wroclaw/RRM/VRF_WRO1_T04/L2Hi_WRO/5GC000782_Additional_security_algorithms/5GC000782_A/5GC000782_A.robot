*** Settings ***
Resource     ../../resources/common_keywords.robot
Library      5GC000782_A.py
Library      ta5g_tshark

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

*** Variables ***
${SgNBAdditionRequestReject}=    x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 2 and x2ap.Cause == 0 and x2ap.radioNetwork == 15
${DEFAULT_NG_XN_TSHARK_ALIAS}=   default_s1_x2

*** Keywords ***
5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as NULL and AES(nea2-128) but gNB support only
    ...        SNOW3G(nea1-128) and ZUC(nea3-128)
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc1_nea0_0_nea1_1_nea2_0_nea3_2.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=11
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    ta5g_ue_mobility.Detach Ue    ue_id=11

5GC000782_A_12_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and ZUC(nea3-128) but
    ...        gNB support only AES(nea2-128)
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc2_nea0_0_nea1_0_nea2_8_nea3_0.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=12
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    ta5g_ue_mobility.Detach Ue    ue_id=12

5GC000782_A_13_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and AES(nea2-128) but
    ...        gNB support only ZUC(nea3-128)
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc3_nea0_0_nea1_0_nea2_0_nea3_6.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=13
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
     ta5g_ue_mobility.Detach Ue    ue_id=13

5GC000782_A_17_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Documentation]     This test case Verifies that SgNB addition reject with cause 15 is received
    ...        by MeNB when UE support ciphering Algorithm as SNOW3G(nea1-128) and AES(nea2-128) but
    ...        gNB support only ZUC(nea3-128)
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc4_nea0_0_nea1_0_nea2_0_nea3_0.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=14
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    ta5g_ue_mobility.Detach Ue    ue_id=14

5GC000782_A_1_Gnb_Selects_Zuc_Algorithm_Dl_Data
    [Documentation]    This test case Verifies gNB selects NULL algorithm
    ...        having high priority and and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.

    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc5_nea0_1_nea1_4_nea2_6_nea3_8.json
    Perform SgNBAddition With Start Data Traffic And Capture Pcap
    ...    ue_id=14
    ...    direction=dl
    ...    throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    ta5g_ue_mobility.Detach Ue    ue_id=14
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
    Assert That E1ap Ciphering Algorithm Equals Nea3             output_dirpath=${OUTPUT_DIR}/E1ap_Ciphering_Algorithm_Equals_Nea3.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
    Assert That Nrrrc Ciphering Algorithm Equals Nea3            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea3.pcap

5GC000782_A_2_Gnb_Selects_Zuc_Algorithm_Ul_Data
    [Documentation]    This test case Verifies gNB selects NULL algorithm
    ...        having high priority and and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.

    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc5_nea0_1_nea1_4_nea2_6_nea3_8.json
    Perform SgNBAddition With Start Data Traffic And Capture Pcap
    ...    ue_id=14
    ...    direction=ul
    ...    throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    ta5g_ue_mobility.Detach Ue    ue_id=14
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
    Assert That E1ap Ciphering Algorithm Equals Nea3             output_dirpath=${OUTPUT_DIR}/E1ap_Ciphering_Algorithm_Equals_Nea3.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
    Assert That Nrrrc Ciphering Algorithm Equals Nea3            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea3.pcap

5GC000782_A_3_Gnb_Selects_Zuc_Nea3_128_Algorithm_Dl_Ul_Data
    [Documentation]     This TC verify that gNB selects ZUC ciphering algorithm for ciphering/diciphering of user data
    ...        having high priority and and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.
    ...        AP P1 NSA TDD Asik/Abil or Asib/Abil

    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc7_nea0_5_nea1_6_nea2_7_nea3_8.json
    Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
    ...    ue_id=14
    ...    dl_throughput=5mbps
    ...    ul_throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    ta5g_ue_mobility.Detach Ue    ue_id=14
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
    Assert That E1ap Ciphering Algorithm Equals Nea3             output_dirpath=${OUTPUT_DIR}/E1ap_Ciphering_Algorithm_Equals_Nea3.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
    Assert That Nrrrc Ciphering Algorithm Equals Nea3            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea3.pcap

5GC000782_A_15_Gnb_Selects_Null_Algorithm_Dl_Ul_Data
    [Documentation]     This test case Verifies gNB selects NULL algorithm
    ...        having high priority and and "nullFallback" parameter is set as true
    ...        and verify DL/UL user data transfer.

    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc8_nea0_1_nea1_0_nea2_0_nea3_0.json
    Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
    ...    ue_id=14
    ...    dl_throughput=5mbps
    ...    ul_throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=14    bearer_id=2    throughput=1    direction=dl    selection_type=average
    ta5g_ue_mobility.Detach Ue    ue_id=14
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
    Assert That E1ap Ciphering Algorithm Are Not Supported       output_dirpath=${OUTPUT_DIR}/E1ap_Ciphering_Algorithm_Equals_Nea3.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
    Assert That Nrrrc Ciphering Algorithm Are Not Supported      output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea3.pcap

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
#    Sleep    15s    Waiting For All Packets To Be Captured
#    Stop Capturing     alias=${DEFAULT_NG_XN_TSHARK_ALIAS}

Perform SgNBAddition With Start Data Traffic And Capture Pcap
    [Arguments]    ${direction}    ${throughput}    ${filename}    ${ue_id}
    Perform SgNBAddition And Capture Pcap    filename=${filename}    ue_id=${ue_id}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=${direction}    throughput=${throughput}
    Sleep    10s    Waiting For Traffic To Start

Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${filename}    ${ue_id}
    Perform SgNBAddition And Capture Pcap    filename=${filename}    ue_id=${ue_id}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=dl    throughput=${dl_throughput}
    Start Data Traffic    ues=${ue_id}    bearer_id=2    direction=ul    throughput=${ul_throughput}
    Sleep    10s    Waiting For Traffic To Start

Perform SgNBAddition And Capture Pcap
    [Arguments]    ${filename}    ${ue_id}
    Start Capturing Pcap On E1 And F1 Interfaces    filename=${filename}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Sleep    5s    Waiting For All Packets To Be Captured
    Stop Capturing Pcap On E1 And F1 Interfaces    filename=${filename}

Stop Capturing Pcap On E1 And F1 Interfaces
    [Arguments]    ${filename}
    ${output}=    Execute Enb Command    cmd=ps -ef | grep ${filename} | awk '{print $2}' | awk 'NR==1'
    Execute Enb Command    cmd=kill -TERM ${output}
    Get File From Enb    source=/tmp/${filename}    destination=${OUTPUT_DIR}/${filename}

Modify Ciphering Algorithms
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_ue simulated id=11    nia=aes+zuc+snow3g+null nea=null+aes
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

Reset Ciphering Algorithms To Default
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    wts.Modify    set_ue simulated id=11    nia=null+zuc+snow3g+aes nea=null+zuc+snow3g+aes
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
