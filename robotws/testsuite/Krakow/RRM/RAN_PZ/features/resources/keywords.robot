*** Settings ***
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations  WITH NAME  GnbAsir
Library      taf.rfrl.bts.devices.asir.basic_logs.GnbAsirHubLog  WITH NAME  AsirLog
Library      taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library      taf.sbts.oam.sc.rest  WITH NAME  Rest


Library      taf.sbts.oam.coam.admin  WITH NAME  SbtsAdmin
Library      taf.ue
Library      xml_parser.py
Library      ./sbts_keywords.py
Library      testsuite.Krakow.RRM.RAN_PZ.features.CB008229.resources.pcap_collector.PcapCollector    WITH NAME    pcap

Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables    ./targets.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${bts_type}                             GNB
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${deviation_ul}                         5%
${deviation_dl}                         5%
${duration}                             300s
${interval}                             1
${linux_congestion}                     reno
${parallel_streams_dl}                  4
${parallel_streams_ul}                  4
${reboot_ue}                            True
${size_packet_dl}                       1320B
${size_packet_ul}                       1380B
${timeout_reboot_ue}                    100
${tput_dl}                              200 Mbits/sec
${tput_ul}                              100 Mbits/sec
${qci}                                  None
${protocol}                             tcp
${buffer_client_dl}                     None
${buffer_server_dl}                     None
${buffer_client_ul}                     None
${buffer_server_ul}                     None

# -----------------------------BWP Value-----------------------------
${N_Size_BWP}                           275
${RB_DEDICATED}                         106
${RB_INITIAL}                           133

${GNB_SCF_NAME}                         SCF_main_gnb.xml
${ASIR_SCF_NAME}                         main_asir_gnb.xml


*** Keywords ***
Run Traffic And Verify BWP
    pcap.Start Pcap Logs
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci}    qci_ul=${qci}    linux_congestion_dl=${linux_congestion}
    ...    linux_congestion_ul=${linux_congestion}
    pcap.Stop Pcap Logs
    @{packet_list}    pcap.Get Packet List    file_name=test   dir_path=${OUTPUT DIR}
    Verify Sgnb Additione Complete    packet_list=${packet_list}
    Verify Correction Of BWP    packet_list=${packet_list}    rb_dedicated=${RB_DEDICATED}    rb_initial=${RB_INITIAL}
