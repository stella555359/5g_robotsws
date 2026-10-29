*** Settings ***
Documentation
...  author : liangliang.heng@nokia-sbell.com
...  contact: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_5_SA_ClassicalgNB_PCMD_Deactivation_From_WebEM
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui_de}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=3
    ...      nodeType=0
    ${nodeType_Xpath_Deactivate}=     set variable     .//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.nodeType/
    ${stopSesseion_CU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=${nodeType_Xpath_Deactivate}nsetapx.gnb_cu_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${stopSesseion_CU_plmn_Identity}
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${CU_plmn_Identity}    Replace String   ${stopSesseion_CU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${CU_plmn_Identity}' == '${plmn_Identity}'
    END
    ${stopSesseion_CU_cellIdentity}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ${cellIdentity_length}=     Get Length   ${stopSesseion_CU_cellIdentity}
    FOR   ${idx}    IN RANGE    0    ${cellIdentity_length}
        ${CU_cellIdentity}    Replace String   ${stopSesseion_CU_cellIdentity}[${idx}]    :    ${EMPTY}
        ${cell_string}    Check the target cellIdentity For 1756   ${cellIdentity}    ${CU_cellIdentity}    ${cell_numbers}
    END
    Run keyword if   '${cell_string}' == '0'   Fail
    ${stopSesseion_CU_traceId}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.traceReference_element/nsetapx.traceId
    ${traceId_length}=     Get Length   ${stopSesseion_CU_traceId}
    FOR   ${idx}    IN RANGE    0    ${traceId_length}
        ${CU_traceId}    Replace String   ${stopSesseion_CU_traceId}[${idx}]    :    ${EMPTY}
        should be true       '${CU_traceId}' == '${traceId}'
    END
    Run keyword if  '${plmn_Identity_length}'==0 or '${cellIdentity_length}'==0 or '${traceId_length}'==0    fail
    log to console            Search message StopSession on node CU in file ${OUTPUT_DIR}/${pcmd_file_webui_de}
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui_de}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=3
    ...      nodeType=2
    ${stopSesseion_DU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.traceReference_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${stopSesseion_DU_plmn_Identity}
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${DU_plmn_Identity}    Replace String   ${stopSesseion_DU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${DU_plmn_Identity}' == '${plmn_Identity}'
    END
    ${stopSesseion_DU_cellIdentity}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ${cellIdentity_length}=     Get Length   ${stopSesseion_DU_cellIdentity}
    FOR   ${idx}    IN RANGE    0    ${cellIdentity_length}
        ${DU_cellIdentity}    Replace String   ${stopSesseion_DU_cellIdentity}[${idx}]    :    ${EMPTY}
        ${cell_string}    Check the target cellIdentity For 1756   ${cellIdentity}    ${DU_cellIdentity}    ${cell_numbers}
    END
    Run keyword if   '${cell_string}' == '0'   Fail
    ${stopSesseion_DU_traceId}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.stopSession_element/nsetapx.traceReference_element/nsetapx.traceId
    ${traceId_length}=     Get Length   ${stopSesseion_DU_traceId}
    FOR   ${idx}    IN RANGE    0    ${traceId_length}
        ${DU_traceId}    Replace String   ${stopSesseion_DU_traceId}[${idx}]    :    ${EMPTY}
        should be true       '${DU_traceId}' == '${traceId}'
    END
    Run keyword if  '${plmn_Identity_length}'=='0' or '${cellIdentity_length}'=='0' or '${traceId_length}'=='0'    fail

Case Setup: B_5
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Common Setup 1756
    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_webui_de}
    Remove And Add PCMD Object
    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_webui_de}

Case Teardown: B_5
    robot_common_operations.Common Case Teardown
    Common Teardown 1756
