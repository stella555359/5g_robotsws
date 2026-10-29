*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com
...   desctiption: This test suite covers basic functionalities of feature CB007813

Resource    testsuite/Krakow/RRM/RAN_PZ/resources/small_cells/tl_preparation.robot
Library     testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.sc_keywords.SmallCellsKeywords
Library     testsuite/Krakow/RRM/RAN_PZ/resources/remote_tl_preparation/remote_tl_preparation.py
Library     taf/rfrl/bts/devices/du/logs_collecting/bip_collector.py
Library     ./bip_keywords.py
Library     ute_ue


Suite Setup       Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
&{mirroring_script_params}=    number_of_files=${1}    file_size_mbytes=${100}

*** Test Cases ***
CB007813-5G-A_1_SA_DL_30MHz_UL_10MHz_Cell_setup_single_UE_attach_DL_UL_traffic_ABIO
    [Setup]  SC Test Preconditions    attenuation_config=CB007813_A_01
    change_enb_default_ln_rel_gnb_cell_id    value=4
    ue_mode_reconfiguration    mode=SA
    #    UDP
    ue.Detach Ue     UE
    ue.Attach Ue     UE
    verify_cell_id    cell_type=NR    cell_id=1229291523
    Start Data Transfer on Real UE    dt_name=DT_DL    ue_alias=UE    direction=dl    protocol=udp    duration=60s
    ...  tput=290 Mbits/sec
    ...  size_packet=1400B
    ...  buffer_client=4M
    ...  buffer_server=4M
    ...  parallel_streams=1
    Start Data Transfer on Real UE    dt_name=DT_UL    ue_alias=UE    direction=ul    protocol=udp    duration=60s
    ...  tput=50 Mbits/sec
    ...  size_packet=1400B
    ...  buffer_client=2M
    ...  buffer_server=2M
    ...  parallel_streams=1
    Wait for truput stabilization
    bip_collector.start_bip_trace_log_capturing    mirroring_script_params=${mirroring_script_params}
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    Sleep    30s
    bip_collector.stop_bip_trace_log_capturing
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Detach Ue     UE
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=290 Mbits/sec   deviation=10%
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=50 Mbits/sec  deviation=10%
    bip_collector.download_bip_logs    ${OUTPUT_DIR}
    join_pcap_files
    validate_dl_prb_number    expected_number_of_prb=156    tolerance=20%
    validate_ul_prb_number    expected_number_of_prb=44    tolerance=20%
    #    TCP
    ue.Detach Ue     UE
    ue.Attach Ue     UE
    verify_cell_id    cell_type=NR    cell_id=1229291523
    Start Data Transfer on Real UE    dt_name=DT_DL    ue_alias=UE    direction=dl    protocol=tcp    duration=60s
    ...  tput=290 Mbits/sec
    ...  size_packet=1400B
    ...  buffer_client=4M
    ...  buffer_server=4M
    ...  linux_congestion=reno
    ...  parallel_streams=1
    Start Data Transfer on Real UE    dt_name=DT_UL    ue_alias=UE    direction=ul    protocol=tcp    duration=60s
    ...  tput=50 Mbits/sec
    ...  size_packet=1400B
    ...  buffer_client=2M
    ...  buffer_server=2M
    ...  parallel_streams=2
    Wait for truput stabilization
    bip_collector.start_bip_trace_log_capturing    mirroring_script_params=${mirroring_script_params}
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    Sleep    30s
    bip_collector.stop_bip_trace_log_capturing
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Detach Ue     UE
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=290 Mbits/sec   deviation=10%
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=50 Mbits/sec  deviation=10%
    bip_collector.download_bip_logs    ${OUTPUT_DIR}
    join_pcap_files
    validate_dl_prb_number    expected_number_of_prb=156    tolerance=20%
    validate_ul_prb_number    expected_number_of_prb=44    tolerance=20%
    ue.Stop Using UE    UE
    [Teardown]  SC Test Postconditions

*** Keywords ***
Suite Setup
	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
	Common Suite Setup With Commissioning    prefix_tag=CB007813_A_01      asir_hub=${True}
