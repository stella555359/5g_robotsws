*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB007149-5G 30 MHz cell bandwidth - FR1-FDD - legacy

*** Settings ***
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    ./resources/Resources.robot
Library     taf.rfrl.ue.iperf.tput_runner.ThroughputRunner    WITH NAME  tput
Library     taf.ue    WITH NAME    ue
Library     ./resources/resources.py
Library     ./resources/syslog.py
Library     testsuite/Krakow/RRM/RAN_PZ/resources/small_cells/tl_configuration_keywords.py
Library     testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.sc_keywords.SmallCellsKeywords
Library     ute_syslog
Variables   ./resources/attenuation.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  24 hours

Suite Setup         Setup
Suite Teardown      Teardown
Test Setup          Run Keyword And Ignore Error     Common Preconditions
Test Teardown       Run Keyword And Ignore Error     Common Postconditions

*** Variables ***
${capabilities_ue}                      REAL_UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

${protocol}                tcp
${data_size_dl_11}         1240M
${data_size_ul_11}         120M
${data_size_dl_15}         1240M
${data_size_ul_15}         160M
${data_size_dl_9_30mhz}    620M
${data_size_ul_9_30mhz}    240M
${data_size_dl_9_20mhz}    400M
${data_size_ul_9_20mhz}    140M
${parallel_streams_dl}     6
${parallel_streams_ul}     4

${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   192.168.255.126
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${VM_IP}                    ${tl.test_pc.default_ssh_connection_details.addr}

*** Test Cases ***
CB007149-5G-B_11_SA_UE_attach_with_CA_30MHz_FDD_Pcell_with_FDD_Scell_without_UL_256QAM
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_11
    Set MTK UE APN  5gsakrk
    Enable SA Support
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_11_attenuation_list}
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_11}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_11}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_11}
    ...  ul_tput=${data_size_ul_11}
    ...  tolerance=10%
    mtk_detach

[1]CB007149-5G-C_15_SA_Ue_attach_with_CA_30MHz_FDD_Pcell_with_FDD_Scell_with_UL_256QAM
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_15
    Set MTK UE APN  5gsakrk
    Enable SA Support
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_15_attenuation_list}
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_15}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_15}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_15}
    ...  ul_tput=${data_size_ul_15}
    ...  tolerance=10%
    mtk_detach

CB007149-5G-A_9_SA_inter_gNB_HO_succesfull_and_unsuccesfull_cases
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_09
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_09_365
    ...  bts_id=${1}
    Set MTK UE APN  5gsakrk
    Enable SA Support
    Enable 30MHz Bandwidth Support on MTK UE
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_9_1_attenuation_list}
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_9_30mhz}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_9_30mhz}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_9_30mhz}
    ...  ul_tput=${data_size_ul_9_30mhz}
    ...  tolerance=10%
    Start Collecting Syslog
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_9_2_attenuation_list}
    Sleep  10
    ${syslog_path}=  Stop Collecting Syslog
    Verify Handover Succeeded
    mtk_detach
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_9_1_attenuation_list}
    Disable 30MHz Bandwidth Support on MTK UE
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_9_20mhz}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_9_20mhz}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_9_20mhz}
    ...  ul_tput=${data_size_ul_9_20mhz}
    ...  tolerance=10%
    Start Collecting Syslog
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_9_2_attenuation_list}
    Sleep  10
    ${syslog_path}=  Stop Collecting Syslog
    Verify Handover Failed
    mtk_detach
    Enable 30MHz Bandwidth Support on MTK UE

*** Keywords ***
Setup
    Wait for UE PC is available
    Lock UE PC
    Common Suite Setup With Commissioning  prefix_tag=CB007149_11
    Run keyword And Ignore Error  Block all lte cells
    Set swconfig flag  flag=0x890003  value=1

Teardown
    Unlock UE PC
    Common Suite Teardown
