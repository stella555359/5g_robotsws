*** Settings ***
Documentation    :copyright: Nokia
Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource            taf/rfrl/utilities/utf_lab/utf_lab.robot
Library      ../../../resources/scout_report.py
Library             testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.py    WITH NAME    kws
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_cell_operations
Library      ta5g_ue_mobility
Library      ta5g_pm_counters
Library      ta5g_throughput
Library      ta5g_iphy
Library      ta5g_enb
Library      DateTime


*** Variables ***
${bufferMonitoring} =     itf_l2_ps_user_BufferMonitoringInd_t.bufferMonitoring == 2
${reducedCCsUL} =       nr-rrc.reducedCCsUL_r16 == 0
${sCellToReleaseList} =       itf_l2_ps_user_RrcReconfCompletedReq_t.sCellReleaseInd == True
${BufferCriterion_For_UL} =       itf_l2_ps_user_BufferCriterionInd_t.bufferCriterion == 1
${sCellULConfigured } =     f1ap.sCellULConfigured == 1
${allowedBC } =     nr-rrc.allowedBC_ListMRDC == 2


*** Keywords ***
Verify Messages
    Verify Tcpdump Log    packet_filter=${bufferMonitoring}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${reducedCCsUL}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${sCellToReleaseList}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60

Verify Messages UL Buffer Triggered SCell
    Verify Tcpdump Log    packet_filter=${bufferMonitoring}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${BufferCriterion_For_UL}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${sCellULConfigured}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${allowedBC}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
