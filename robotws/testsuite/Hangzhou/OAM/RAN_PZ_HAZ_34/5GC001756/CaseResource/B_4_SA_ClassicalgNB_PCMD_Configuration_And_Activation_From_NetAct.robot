*** Settings ***
Documentation
...  author : liangliang.heng@nokia-sbell.com
...  contact: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot
Resource   ../Resource/NetAct.robot

*** Variables ***

*** Keyword ***
B_4_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_netact}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=2
    ...      nodeType=0
    ${nodeType_Xpath_Acticate}=     set variable     .//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.nodeType/
    ${startSesseion_CU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=${nodeType_Xpath_Acticate}nsetapx.gnb_cu_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${startSesseion_CU_plmn_Identity}
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${CU_plmn_Identity}    Replace String   ${startSesseion_CU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${CU_plmn_Identity}' == '${plmn_Identity}'
    END
    ${startSesseion_CU_cellIdentity}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ${cellIdentity_length}=     Get Length   ${startSesseion_CU_cellIdentity}
    FOR   ${idx}    IN RANGE    0    ${cellIdentity_length}
        ${CU_cellIdentity}    Replace String   ${startSesseion_CU_cellIdentity}[${idx}]    :    ${EMPTY}
        ${cell_string}    Check the target cellIdentity For 1756   ${cellIdentity}    ${CU_cellIdentity}   ${cell_numbers}
    END
    Run keyword if   '${cell_string}' == '0'   Fail
    ${startSesseion_CU_traceId}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.traceReference_element/nsetapx.traceId
    ${traceId_length}=     Get Length   ${startSesseion_CU_traceId}
    FOR   ${idx}    IN RANGE    0    ${traceId_length}
        ${CU_traceId}    Replace String   ${startSesseion_CU_traceId}[${idx}]    :    ${EMPTY}
        should be true       '${CU_traceId}' == '${traceId}'
    END
    Run keyword if  '${plmn_Identity_length}'==0 or '${cellIdentity_length}'==0 or '${traceId_length}'==0    fail
    log to console            Search message StartSession on node DU in file ${OUTPUT_DIR}/${pcmd_file_netact}
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_netact}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=2
    ...      nodeType=2
    ${startSesseion_DU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=${nodeType_Xpath_Acticate}nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${startSesseion_DU_plmn_Identity}
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${DU_plmn_Identity}    Replace String   ${startSesseion_DU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${DU_plmn_Identity}' == '${plmn_Identity}'
    END
    ${startSesseion_DU_cellIdentity}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ${cellIdentity_length}=     Get Length   ${startSesseion_DU_cellIdentity}
    FOR   ${idx}    IN RANGE    0    ${cellIdentity_length}
        ${DU_cellIdentity}    Replace String   ${startSesseion_DU_cellIdentity}[${idx}]    :    ${EMPTY}
        ${cell_string}    Check the target cellIdentity For 1756   ${cellIdentity}    ${DU_cellIdentity}    ${cell_numbers}
    END
    Run keyword if   '${cell_string}' == '0'   Fail
    ${startSesseion_DU_traceId}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.traceReference_element/nsetapx.traceId
    ${traceId_length}=     Get Length   ${startSesseion_DU_traceId}
    FOR   ${idx}    IN RANGE    0    ${traceId_length}
        ${DU_traceId}    Replace String   ${startSesseion_DU_traceId}[${idx}]    :    ${EMPTY}
        should be true       '${DU_traceId}' == '${traceId}'
    END
    Run keyword if  '${plmn_Identity_length}'==0 or '${cellIdentity_length}'==0 or '${traceId_length}'==0    fail
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_netact}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=0
    ...      nodeType=2
    ${nodeType_Xpath_config}=     set variable      .//nsetapx.TraceMessage/nsetapx.configure_element/nsetapx.nodeType/
    ${configure_DU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=${nodeType_Xpath_config}nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${configure_DU_plmn_Identity}
    Run keyword if  ${plmn_Identity_length}==0     fail
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${DU_plmn_Identity}    Replace String   ${configure_DU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${DU_plmn_Identity}' == '${plmn_Identity}'
    END
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_netact}
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=0
    ...      nodeType=0
    ${configure_CU_plmn_Identity}=    wireshark.get_field_value_by_xpath
    ...   xpath=${nodeType_Xpath_config}nsetapx.gnb_cu_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_length}=     Get Length   ${configure_CU_plmn_Identity}
    Run keyword if  ${plmn_Identity_length}==0     fail
    FOR   ${idx}    IN RANGE    0    ${plmn_Identity_length}
        ${CU_plmn_Identity}    Replace String   ${configure_CU_plmn_Identity}[${idx}]    :    ${EMPTY}
        should be true       '${CU_plmn_Identity}' == '${plmn_Identity}'
    END

Case Setup: B_4
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Common Setup 1756
    Get ALL Suite Variables
    COAM Remove PCMD Object
    COAM Update PCMD Flag   flag=false
    Integrate NE to NetAct and CM Upload
    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_netact}
    Activated And Configured PCMD By NetAct
    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_netact}

Case Teardown: B_4
    robot_common_operations.Common Case Teardown
    Common Teardown 1756
