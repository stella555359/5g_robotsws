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
Library     taf.ue    WITH NAME    ute_ue
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
${data_size_dl_10_30mhz}    620M
${data_size_ul_10_30mhz}    240M
${data_size_dl_10_20mhz}    400M
${data_size_ul_10_20mhz}    160M
${parallel_streams_dl}     6
${parallel_streams_ul}     4

${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   192.168.255.126
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${VM_IP}                    ${tl.test_pc.default_ssh_connection_details.addr}

*** Test Cases ***
CB007149-5G-A_1_One_cell_setup_NSA
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_01
    Set MTK UE APN  5gkrk
    Enable NSA Support
    Reboot MTK Ue
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_01_attenuation_list}
    mtk_attach
    mtk_detach

CB007149-5G-A_16_Max_configuration_cell_setup
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_16
    Set MTK UE APN  5gkrk
    Enable NSA Support
    Reboot MTK Ue
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_16_attenuation_list}
    mtk_attach
    mtk_detach

CB007149-5G-A_10_One_cell_setup_SA_with_large_and_small_BWP_UE_attach_interaction_with_CB007552
    Run keyword And Ignore Error  Block all lte cells
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB007149_10
    Set MTK UE APN  5gsakrk
    Enable SA Support
    Enable 30MHz Bandwidth Support on MTK UE
    Set Cell Attenuation
    ...  attenuation_ports=${attenuator_ports}
    ...  values_in_db=${TC_10_attenuation_list}
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_10_30mhz}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_10_30mhz}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_10_30mhz}
    ...  ul_tput=${data_size_ul_10_30mhz}
    ...  tolerance=10%
    mtk_detach
    Disable 30MHz Bandwidth Support on MTK UE
    Reboot MTK Ue
    mtk_attach
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams_ul}
    ...  data_size_ul=${data_size_ul_10_20mhz}
    ...  parallel_streams_dl=${parallel_streams_dl}
    ...  data_size_dl=${data_size_dl_10_20mhz}
    ...  protocol=${protocol}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=120
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl_10_20mhz}
    ...  ul_tput=${data_size_ul_10_20mhz}
    ...  tolerance=10%
    mtk_detach
    Enable 30MHz Bandwidth Support on MTK UE

*** Keywords ***
Setup
    Wait for UE PC is available
    Lock UE PC
    reupload_sw
    Common Suite Setup With Commissioning  prefix_tag=CB007149_01
    Run keyword And Ignore Error  Unblock all lte cells

Teardown
    Unlock UE PC
    Common Suite Teardown
