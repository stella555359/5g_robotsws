*** Settings ***
Documentation
...     Creation Date:		    27.06.2025
...     Author:                Shaheena Parveen
...     Team:                  MN RAN VRF BLR1

Resource          ../../../5GET_BLR/resources/robot/common_log_collection.robot
Resource          ../../../5GET_BLR/resources/robot/wts_sim_keywords.robot
Resource	  ../../../5GET_BLR/CB008278/resources/common_CA.robot
Resource          ../../../5GET_BLR/5GC000937/resources/5GC000937_Keywords.robot
Library           ../../../5GET_BLR/resources/python/BIP_Capture.py
Library          taf.analyzer.pdml    WITH NAME    taf_pdml_analyser
Library          taf.analyzer.pcap    WITH NAME    parser

*** Variables ***

${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${exp_precoding}        255
${exp_precoding_SIB}        1 #SCDD
${exp_transscheme}      1
${exp_pdcch_precoding_Msg}    2
${exp_pdsch_precoding_Msg4}    3

*** Keywords ***
Collect BIP and decode
    [Arguments]    ${test_scenario}
    Start log  biptaf
    ${crnti_list_1}   UE Register should be Successful    ue_id=${UE_ID}    pdu_id=1    nw_id=1
    ...     gw_id=1
    wts_sim_keywords.Trigger DL Traffic for SA      ${UE_ID}      mbps     175     1      1      1
    wts_sim_keywords.UE Deregister should be Successful    ${UE_ID}
    ${path_BIP}   Stop log   biptaf    test_scenario=${test_scenario}
    set test variable      ${path_BIP}
Collect BIP and decode with NSA
    [Arguments]    ${test_scenario}
    Start log  biptaf
    ${crnti_list_1}   NSA LTE Attach should be Successful    ${UE_ID}
    NSA UE Attach should be Successful    ${UE_ID}    ${target_cell}
    wts_sim_keywords.Trigger DL Traffic for NSA      ${UE_ID}      mbps      150      1      1
    wts_sim_keywords.NSA UE Detach should be Successful    ${UE_ID}
    ${path_BIP}   Stop log   biptaf    test_scenario=${test_scenario}
    set test variable      ${path_BIP}
Verifying MIB with CB013440 Enabled
    [Arguments]    ${path_BIP}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      (dldata_ssblocksendreql1sw) && (3gpp.subcellid == 3)
    Log to Console    ***MIB Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_ssblocksendreql1sw/
    ...  nr_l1dl_l2ps_dldata_ssblocksendreql1sw_t/DlData_SsBlockSendReqL1sw_t.precodingVectorIndex
    ${packet}    set variable    DlData_SsBlockSendReqL1sw_t.precodingVectorIndex
    Log to Console   ${packet}
    ${precoding_vector}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${precoding_vector}
    Run Keyword if   ${precoding_vector} !=${exp_precoding}   Fail   Precoding check failed
    ...         else    Pass     Precoding check passed

    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_ssblocksendreql1sw/
    ...  nr_l1dl_l2ps_dldata_ssblocksendreql1sw_t/DlData_SsBlockSendReqL1sw_t.enhTransScheme
    ${packet}    set variable    DlData_SsBlockSendReqL1sw_t.enhTransScheme
    Log to Console   ${packet}
    ${trans_scheme}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Run Keyword if   ${trans_scheme} !=${exp_transscheme}   Fail   CB013440 Disabled  failed
    ...         else    Pass   CB013440 Feature Enabled check passed

Verifying SIB with CB013440 Enabled
    [Arguments]    ${path_BIP}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      ((dldata_pdcchsendreql1sw) && (3gpp.subcellid == 3)) && (3gpp.rnti == 65535)
    Log to Console    ***SIB Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${precoding_vector}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${precoding_vector}
    Run Keyword if   ${precoding_vector} !=${exp_precoding_SIB}   Fail   Precoding SCDD failed
    ...         else    Pass     Precoding SCDD passed
Verifying MSG2
    [Arguments]    ${path_BIP}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      DlData_DciInfoL1sw.rachStatus == 2 && (3gpp.subcellid == 3)
    Log to Console    ***MSG2 Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${pdcch_precoding_Msg2}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${pdcch_precoding_Msg2}
    Run Keyword if   ${pdcch_precoding_Msg2} !=${exp_pdcch_precoding_Msg}   Fail   Precoding RepitionOnexPolBeam failed
    ...         else    Pass     Precoding RepititionOnexPolBeam passed
Verifying MSG4_A
    [Arguments]    ${path_BIP}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      DlData_DciInfoL1sw.rachStatus == 4 && (3gpp.subcellid == 3)
    Log to Console    ***MSG4 PDCCH Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${pdcch_precoding_Msg4}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${pdcch_precoding_Msg4}
    Run Keyword if   ${pdcch_precoding_Msg4} !=${exp_pdcch_precoding_Msg}   Fail   Precoding RepitionOnexPolBeam failed
    ...         else    Pass     Precoding RepititionOnexPolBeam passed

    Log to Console    ***MSG4 PDSCH Validation***
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      (dldata_pdschsendreql1sw) && (3gpp.subcellid == 3)
    ${path_cu1} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdschsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdschsendreql1sw_t/_/nr_l1dl_l2ps_dldata_pdschgrantl1sw/DlData_PdschGrantL1sw.openLoopScheme
    ${packet1}    set variable    DlData_PdschGrantL1sw.openLoopScheme
    Log to Console   ${packet1}
    ${pdsch_precoding_Msg4}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet1}
    ...                               path=${path_cu1}
    ...                               endPacket=1
    Log to Console   ${pdsch_precoding_Msg4}
    Run Keyword if   ${pdsch_precoding_Msg4} !=${exp_pdsch_precoding_Msg4}   Fail   Precoding Not_EnhCtrlChannelTransPrecoding failed
    ...         else    Pass     Precoding EnhCtrlChannelTransPrecoding passed
Verifying MSG5
    [Arguments]    ${path_BIP}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${path_BIP}[biptaf]/BIP_L1L2.pcap
    ...      DlData_DciInfoL1sw.rachStatus == 5 && (3gpp.subcellid == 3)
    Log to Console    ***MSG4 Validation***
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/nr_l1dl_l2ps/dldata_pdcchsendreql1sw/
    ...     nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t/_/nr_l1dl_l2ps_dldata_dciinfol1sw/DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ${packet}    set variable    DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    Log to Console   ${packet}
    ${pdcch_precoding_Msg5}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${pdcch_precoding_Msg5}
    Run Keyword if   ${pdcch_precoding_Msg5} !=${exp_pdcch_precoding_Msg}   Fail   Precoding RepitionOnexPolBeam failed
    ...         else    Pass     Precoding RepititionOnexPolBeam passed



