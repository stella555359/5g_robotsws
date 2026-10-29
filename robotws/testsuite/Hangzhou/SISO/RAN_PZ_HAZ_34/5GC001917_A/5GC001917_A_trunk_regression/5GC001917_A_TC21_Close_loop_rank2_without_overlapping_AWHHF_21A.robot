# # #*** Settings ***
# # #Documentation
# # #...   author: liu xu
# # #...   contact: xu.2.liu@nokia-sbell.com
# # #...   squad group: SG_03
# # #...   feature : 5GC001917-A in trunk
# # #
# # #Force Tags    5G_SISO            7.2836
# # #...    PY36
# # #
# # #Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
# # #...    get CellID    lcrid=${1}
# # #
# # #Suite Teardown    Run Keyword If Any Tests Failed
# # #...               Run Keyword And Ignore Error    Common Suite Teardown for COAM
# # #
# # #Library    OperatingSystem
# # #Library    Collections
# # #Library    String
# # #Library    BuiltIn
# # #Library    taf.transport.ssh    WITH NAME    csn
# # #Library    taf.pdu       WITH NAME    pdu
# # #Library    taf.analyzer.pcap    WITH NAME    cap
# # #Resource    ../Resources/5GC001917_A_common_keyword_MTK.robot
# # #
# # #*** Variables ***
# # #${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
# # #${tl_scf_filename}    TL347_gnb_SCF_closed_dlMimoMode.xml
# # #${enb_BTS}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
# # #${gnb_BTS}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# # #${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
# # #${enb_instance}     ${tl.enbs[1].instance_id}
# # #${gnb_instance}     ${tl.gnbs[0].instance_id}
# # #${enbx2_para}    administrativeState
# # #${atten_ip}    ${tl.attenuator[0].ip_addr}
# # #${x2logname_A21}    1917_A21_x2.pcap
# # #${ul_port}    ${tl.ues[0].iperf_details.port}
# # #${ul_time}    600
# # #${ul_length}    1024B
# # #${ul_throughput}     60M
# # #${dl_port}    ${tl.appserver.iperf_details.port}
# # #${dl_time}    600
# # #${dl_length}    1024B
# # #${dl_throughput}    300M
# # #${Expect_UPLINK}    0
# # #${Expect_DOWNLINK}    5
# # #${ul_tp_expect}    10
# # #${dl_tp_expect}    200
# # #${tshark_path}      /usr/bin/tshark
# # #${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# # #${ue_type}    ${tl.ues[0].capabilities[1]}
# # #
# # #*** Test Cases ***
# # #[1][1.0] [1]5GC001917_A_21_Close_loop_rank_2_CSI_RS_on_PUCCH_with_E2E_system_setup_with_data_transfer _without_overlapping
# # #    [Tags]    Qualcomm    classical    CIT_22R1
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Prepare with COMA classical gnb BTS cell onair TL347
# # #    Prepare the atten
# # #    Precondition for power UE    ue_type=${ue_type}
# # #    sleep    10s
# # #    Start Capture Classical x2_WS Logs    x2logname=${x2logname_A21}
# # #    Attach and check power UE    ue_type=${ue_type}
# # #    Stop and Save classical x2_WS Logs    x2logname=${x2logname_A21}
# # #    Start DL UL traffic and monitor throughput
# # #    sleep    3s
# # #    Analysis capture log    x2logname=${x2logname_A21}
# # #    [Teardown]    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_A09}
# # #
# # #*** Keywords ***
# # #Analysis capture log
# # #    [Arguments]    ${x2logname}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${x2logname}
# # #    ...    tshark_path=${tshark_path}    command_template=${command_template_Y}
# # #    ${filter_expression}=     Catenate    x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 27
# # #    ${filtered_packets}=    cap.filter_packets_by_expression
# # #    ...    filter_expression=${filter_expression}
# # #    ${AS_ciphering_algorithms}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//nr-rrc.cipheringAlgorithm
# # #    should contain    ${AS_ciphering_algorithms}    3
