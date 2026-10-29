*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Emilia Godlewska-Lipka
...             :contact: emilia.godlewska-lipka@nokia.com

Resource         ../CB008490/resources/feature_keywords.robot
Resource         testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Variables        feature_variables.py
Library          ../resources/multignb_variables.py
Library          ../resources/syslog_collector.py
Library          testsuite/Wroclaw/RRM/resources/scout_report.py
Resource         ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library          ../../resources/scout_report.py
Library          ../../resources/airphone/multignb_testlines_variables.py
Library          ta5g_testline_management
Library          ta5g_ue_measurements
Library          ta5g_pm_counters
Library          ta5g_throughput
Library          ta5g_ue_mobility
Library          ta5g_iphy
Library          ta5g_enb


*** Keywords ***
Set VM Ethernet Interfaces for Simulated gNB
    Start Vm Ethernet Interface    if_name=eth3:GNB4_X2          ip_with_mask=10.0.1.5/24
    Start Vm Ethernet Interface    if_name=eth3:GNB4_NG          ip_with_mask=10.0.1.6/24

Reset SMF
    Execute Egate Command    cmd=smf_param id=1 reset

Verify If Counters Were Not Incremented On MN gNB Before Test
        Verify If Counters Were Not Incremented
        ...    counter_id_list=@{COUNTERS_LIST}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${MN_Cell}
        ...    remote_host=None

Verify That New Counters Are Incremented After Test On MN Side
      ${pm_counter_file_after_test}=    Get Next Unpacked Raw Pm Counters File
      Verify That New Counters Are Incremented After Test And Have Value Eq 1 For PCell

Verify That New Counters Are Incremented After Test And Have Value Eq ${x:\d+} For PCell
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
            ...    counter_id_list=@{COUNTERS_LIST}
            ...    value=${x}
            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${MN_Cell}
            ...    filepath=${pm_counter_file_after_test}

Verify Secondary Node Addition Flow
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}
        ...    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
        ...    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SNODE_ADDITION_REQUEST_ACKNOWLEDGE_FILTER}
        ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION_FILTER}
        ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SN_STATUS_TRANSFER_FILTER}
        ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SNODE_RECONFIGURATION_COMPLETE_FILTER}
        ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${SGNB_RECONFIGURATION_FILTER}
        ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}
        ...    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
        ...    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/tshark/sn_add_flow/tcpdump.pcap

Verify NR-DC Takeback Procedure and VoNR QoS Flow Establish
    tshark_verifying.Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_REQUEST}
            ...    number_of_messages=5    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}
            ...    number_of_messages=5    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST}
            ...    number_of_messages=4    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
            ...    number_of_messages=4    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_XNU_ADDRESS_INDICATION_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SN_STATUS_TRANSFER_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SNODE_RELEASE_REQUEST_FITLER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_SNODE_RELEASE_REQUEST_ACKNOWLEDGE_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_INDICATOR_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${XNAP_UE_CONTEXT_RELEASE_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_CONFIRM_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap
    tshark_verifying.Verify Tcpdump Log    packet_filter=${RRC_SGNB_RELEASE_FILTER}
            ...    number_of_messages=1    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_sn_takeback/tcpdump.pcap

Add Aditional QoS Flow To Activate
    [Arguments]    ${ue_id}    ${qosflows_to_act}
    Execute Egate Command    cmd=smf_param additional_qosflows_to_activate=${qosflows_to_act} id=${ue_id}

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=150
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=60
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=100
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=60

Send Data Traffic For UE${ue_id:\d+} With Only One QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=150
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=60

Start Data Traffic For All PDUs For UE${ue_id:\d+}
    Sleep    1s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=50 dir=ul
    Execute Egate Command    cmd=ttrf_data_start ue=${ue_id} pdu=2 qfi=2 trf_id=2 mbps=175 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=2 qfi=2 trf_id=1 mbps=50 dir=ul

Set Traffic Params For UE${ue_id:\d+}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    cmd=uec_param id=${ue_id} scg_ul_dist_percent=50

Verify RRC MeasConfig Events
    tshark_verifying.Verify Tcpdump Log    packet_filter=${MEAS_EVENT_A2_FILTER}
    tshark_verifying.Verify Tcpdump Log    packet_filter=${MEAS_EVENT_A3_FILTER}
    tshark_verifying.Verify Tcpdump Log    packet_filter=${MEAS_EVENT_A5_FILTER}
    tshark_verifying.Verify Tcpdump Log    packet_filter=${MEAS_EVENT_A1_FILTER}

