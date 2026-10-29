*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB008419-5G-A-SyVe-Parity-[5GC002637_Throughput_Counter]

Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Library     counters.py
Variables   variables.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    	CLOUD_5G_ASOD_AEUD_ENB
...           CRT__WITH__RAN_5G_TDD_MP__WITH__pDU22R2

Suite Setup       Perform commissioning on gNB to onAir state    prefix_tag=8419
Suite Teardown    Teardown Logs Collectors
Test Setup        Run Keyword And Ignore Error     Collect logs during test
Test Teardown     Run Keyword And Ignore Error     Collect logs after test finished

*** Variables ***
${capabilities_ue}                      REAL_UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${gnb_id}                               ${tl.gnbs[0].dus[0].global_bts_id}

${size_packet}         1400B
${dl_size_packet}      1400B
${ul_size_packet}      1000B
${buffer_client_dl}    8M
${buffer_server_dl}    8M
${buffer_client_ul}    2M
${buffer_server_ul}    2M
${interval}            1

*** Test Cases ***
CB008419-5G-A_1_5GC002637_Throughput_Counter_Feature_Activate_via_WebEM
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3  param_name=actIpThpt
    ...  operation=update  param_value=true  timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRDRB-1
    ...  param_name=durationThresDiscard  operation=update  param_value=0  timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRDRB-1
    ...  param_name=volThresDiscard  operation=update  param_value=0  timeout=${180}
    Set PM Interval gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRPMRNL-1  abbr_group_name=miNrHighRlcCell  interval=15min
    gnbalarm.Check If Critical Alarm Exist
    Bi-Directional_Throughput
    Compare counters  counters=${A_1_counter_dict}  zero_counters_list=${A_1_zero_counter_list}

CB008419-5G-A_3_5GC002637_MAC_Throughput_Counter__Activate_Deactivate_via_WebEM
    Bi-Directional_Throughput
    Compare counters  ${A_3_counter_dict}
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRPMRNL-1
    ...  param_name=miNrCellUtilization  operation=update  param_value=disabled  timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRPMRNL-1
    ...  param_name=miNrMacSduReport  operation=update  param_value=disabled  timeout=${180}
    gnbalarm.Check If Critical Alarm Exist
    Verify MAC Tgroughput Counters Halted  ${A_3_counter_dict}

CB008419-5G-A_4_5GC002637_Throughput_Counter_Update_with_different_Measurement_Interval
    Perform Configuration Parameter Recommissioning On gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3  param_name=actIpThpt
    ...  operation=update  param_value=true  timeout=${180}
    Set PM Interval gNB  dist_name=MRBTS-${gnb_id}/NRBTS-3/NRPMRNL-1  abbr_group_name=miNrHighRlcCell  interval=30min
    gnbalarm.Check If Critical Alarm Exist
    Bi-Directional_Throughput
    Compare counters  counters=${A_4_counter_dict}  interval=30  zero_counters_list=${A_4_zero_counter_list}


*** Keywords ***
Compare counters
    [Arguments]  ${counters}  ${interval}=15  ${zero_counters_list}=${None}
    ${previus_counters}=  Get PM Counters  ${counters}
    Wait for counter change  ${interval}
    ${current_counters}=  Get PM Counters  ${counters}
    Verify counters are higher  ${current_counters}  ${previus_counters}  ${zero_counters_list}

Verify MAC Tgroughput Counters Halted
    [Arguments]  ${counters}  ${interval}=15
    ${timestamps}=  Get Counter Timestamps  ${counters}
    Wait for counter change  ${interval}
    Compare Counter Timestamps  ${counters}  ${timestamps}

Bi-Directional_Throughput
    REAL_UE.Wait for next PM period
    ue.Require Ue    UE    capabilities=REAL_UE
    ue.Reboot Ue     UE    timeout=100
    ue.Attach Ue     UE
    Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=UE  direction=dl  protocol=udp  duration=30s
    ...  tput=100 Mbits/sec  parallel_streams=1  size_packet=${ul_size_packet}  buffer_client=${buffer_client_dl}
    ...  buffer_server=${buffer_server_dl}  interval=${interval}  qci=${None}    linux_congestion=${None}
    Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=UE  direction=ul  protocol=udp  duration=30s
    ...  tput=50 Mbits/sec  parallel_streams=1  size_packet=${ul_size_packet}  buffer_client=${buffer_client_ul}
    ...  buffer_server=${buffer_server_ul}  interval=${interval}  qci=${None}    linux_congestion=${None}
    Wait for truput stabilization
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Collect logs during data transfer   direction=BOTH
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Detach Ue     UE
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Download logs from gNB    sub_dir=data_transfer
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=100 Mbits/sec   deviation=13%
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=50 Mbits/sec  deviation=13%
