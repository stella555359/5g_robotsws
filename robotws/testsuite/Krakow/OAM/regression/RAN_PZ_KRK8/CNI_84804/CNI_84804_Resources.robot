*** Settings ***
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    testsuite/Krakow/resources/throughput_ota_aeub_regression.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${number_of_UEs}       ${2}
${dl_tput_60Mhz}       ${700}
${ul_tput_60Mhz}       ${78}
${dl_tput_20Mhz}       ${280}
${ul_tput_20Mhz}       ${50}

${duration}            30s
${branch_tag}          None
${capabilities_ue}     REAL_UE
${size_packet}         1400B
${dl_size_packet}      1400B
${ul_size_packet}      1400B
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    2M
${buffer_server_ul}    2M
${interval}            1
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${parallel_streams}    4
${protocol}            tcp

${UE_1_alias}          UE_1
${UE_2_alias}          UE_2
${fault_cell}          Cell blocked
${fault_bts_reset}     BTS Reset Cause

@{CUSTOM_ALLOWED_ALARMS}  ${fault_cell}  ${fault_bts_reset}

*** Keywords ***
Suite Setup for CNI 84804
    Common Suite Setup
    Perform Full Commissioning and Wait for onAir    prefix_tag=CNI84804

Test Teardown for 2 UEs
    run keyword and ignore error   gnbcell.Unblock Cell    cell_id=0
    run keyword and ignore error   gnbcell.Unblock Cell    cell_id=1
    ue.Detach Ue     ${UE_1_alias}
    ue.Detach Ue     ${UE_2_alias}
    Common postconditions with watching alarms

Run and verify data transfer for two UEs
    [Arguments]    ${dl_tput_per_ue}   ${ul_tput_per_ue}
    ue.Attach Ue     ${UE_1_alias}
    ue.Attach Ue     ${UE_2_alias}

    Start Data Transfer on Real UE    dt_name=DT_UL_1  ue_alias=${UE_1_alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${ul_tput_per_ue} Mbits/sec  parallel_streams=${parallel_streams}  size_packet=${ul_size_packet}  buffer_client=${buffer_client_ul}
    ...  buffer_server=${buffer_server_ul}  interval=${interval}  qci=${None}    linux_congestion=${None}
    Start Data Transfer on Real UE    dt_name=DT_UL_2  ue_alias=${UE_2_alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${ul_tput_per_ue} Mbits/sec  parallel_streams=${parallel_streams}  size_packet=${ul_size_packet}  buffer_client=${buffer_client_ul}
    ...  buffer_server=${buffer_server_ul}  interval=${interval}  qci=${None}    linux_congestion=${None}
    Start Data Transfer on Real UE    dt_name=DT_DL_1  ue_alias=${UE_1_alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${dl_tput_per_ue} Mbits/sec  parallel_streams=${parallel_streams}  size_packet=${ul_size_packet}  buffer_client=${buffer_client_dl}
    ...  buffer_server=${buffer_server_dl}  interval=${interval}  qci=${None}    linux_congestion=${None}
    Start Data Transfer on Real UE    dt_name=DT_DL_2  ue_alias=${UE_2_alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${dl_tput_per_ue} Mbits/sec  parallel_streams=${parallel_streams}  size_packet=${ul_size_packet}  buffer_client=${buffer_client_dl}
    ...  buffer_server=${buffer_server_dl}  interval=${interval}  qci=${None}    linux_congestion=${None}


    Wait for truput stabilization
    ue.Check Data Transfer is Alive     dt_name=DT_UL_1
    ue.Check Data Transfer is Alive     dt_name=DT_UL_2
    ue.Check Data Transfer is Alive     dt_name=DT_DL_1
    ue.Check Data Transfer is Alive     dt_name=DT_DL_2

    ue.Await Data Transfer Finish       dt_name=DT_UL_1
    ue.Await Data Transfer Finish       dt_name=DT_UL_2
    ue.Await Data Transfer Finish       dt_name=DT_DL_1
    ue.Await Data Transfer Finish       dt_name=DT_DL_2

    ue.Detach Ue     ${UE_1_alias}
    ue.Detach Ue     ${UE_2_alias}

    Run keyword And Continue On Failure   ue.Verify Average Throughput With Deviation   dt_name=DT_DL_1   tput=${dl_tput_per_ue} Mbits/sec
    ...   deviation=15%
    Run keyword And Continue On Failure   ue.Verify Average Throughput With Deviation   dt_name=DT_DL_2   tput=${dl_tput_per_ue} Mbits/sec
    ...   deviation=15%
    Run keyword And Continue On Failure   ue.Verify Average Throughput With Deviation   dt_name=DT_UL_1   tput=${ul_tput_per_ue} Mbits/sec
    ...   deviation=15%
    Run keyword And Continue On Failure   ue.Verify Average Throughput With Deviation   dt_name=DT_UL_2   tput=${ul_tput_per_ue} Mbits/sec
    ...   deviation=15%

