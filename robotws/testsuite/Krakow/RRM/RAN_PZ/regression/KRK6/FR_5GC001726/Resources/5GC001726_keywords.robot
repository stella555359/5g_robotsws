*** Settings ***
Documentation
...   This is for 1726 TA common keywords
...   squad group: MMW_SG1
...   migrated to krk by klaudia.horyn@nokia.com

Library     taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Library     taf.analyzer.pcap                                                           WITH NAME    pcap
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py              WITH NAME    scd
Library     testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py    WITH NAME    flow_verifier
Library     ute_ue                                                                      WITH NAME    ue
Library     DateTime                                                                    WITH NAME    dt
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                       WITH NAME    uteueconfig
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                   WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning                      WITH NAME    enbscf
Library     ta5g_pm_counters                                                            WITH NAME    pmcounter
Library     ute_fsmaccess
Library     Process
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource    taf/rfrl/bts/robot/common/gnb_log.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${TSHARK_PATH}                     /usr/bin/tshark
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
${current_config}                  5GC001726

*** Keywords ***
Stop Tcpdump
    Sleep   3 s    reason=Wait a while before stopping the logs
    ${alias}=        Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=killall tcpdump
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo killall tcpdump
    ...              connection=${alias}

Start Tcpdump
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any   ${sleep_after_start_s}=3
    ${alias}=    Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.send_command    command=tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    Sleep   ${sleep_after_start_s} s   reason=Wait a while after the log starts

Start Streams For DL And UL Data Transmission For Specified Time For UDP
    [Arguments]    ${data_transfer_time}    ${ul_throughput}     ${dl_throughput}
    [Documentation]    Keyword starts UDP traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param ul_throughput:    level of throughput in uplink direction
    ...                :param dl_throughput:    level of throughput in downlink direction
    ...                :protocol:    protocol type tcp/udp
    Log To Console    Start DL and UL data transmission for specified time
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE_1
    ...                 direction=ul    duration=${data_transfer_time}s    protocol=udp   throughput=${ul_throughput}
    ...                 packet=1320    buffer_client=4M
    Sleep    2s   reason=Wait a while to start DL traffic
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE_1
    ...                  direction=dl    duration=${data_transfer_time}s    protocol=udp   throughput=${dl_throughput}
    ...                  packet=1320    buffer=4M
    Sleep    1s    reason=Wait a while to stabilize throughput

Await DL And UL Data Transmission Finish
    Log To Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    DT_1_UL
    ue.Await Data Transfer Finish    DT_1_DL

Verify DL And UL Data Transmission Loss For UDP
    [Arguments]    ${deviation}=5
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss parameter value.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param deviation:   max allowed data loss value in percentage, e.g: '25' for 25%
    Log To Console    Verify DL and UL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=DT_1_DL    tput=100000000 bits/sec    deviation=${deviation}%
    ue.Verify Average Throughput With Deviation    dt_name=DT_1_UL    tput=50000000 bits/sec    deviation=${deviation}%
    ${avg_UL_tput}=      ue.Get Average Throughput   DT_1_UL
    Log To Console   Average UL TPUT: ${avg_UL_tput} Mbps
    ${avg_DL_tput}=      ue.Get Average Throughput   DT_1_DL
    Log To Console   Average DL TPUT: ${avg_DL_tput} Mbps

Stop DL And UL Data Transmission
    Log To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
