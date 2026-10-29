*** Settings ***
Library    String
Library    taf.ue    WITH NAME    ue
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.ue.data_transfer
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.tput_logs_collecting
Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.ue.ue_attach_verification.UeAttachVerification
Resource    ../../../resources/Macro/bts/gnb.robot

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}  ${True}

*** Keywords ***
Require Ue for L3 Call
    [Arguments]    ${capabilities}=REAL_UE  ${alias}=UE
    [Documentation]    Require Ue with alias UE and capabilities
    ...    :param capabilities:    Capabilites for UE with configuration file
    ...    :param alias:           UE connection name
    ue.Require Ue    ${alias}    capabilities=${capabilities}

Prepare Ue for L3 Call
    [Arguments]    ${capabilities}=REAL_UE    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100  ${alias}=UE
    [Documentation]    Require Ue with alias UE and capabilities and reboot Ue
    ...    :param capabilities:         Capabilites for UE with configuration file
    ...    :param reboot_ue:            Flag for rebooting UE True/False
    ...    :param timeout_reboot_ue:    Timeout for Reboot Ue in seconds
    ...    :param alias:                UE connection name
    ue.Require Ue    ${alias}    capabilities=${capabilities}
    ue.Detach Ue     ${alias}
    Run Keyword If  ${reboot_ue}    ue.Reboot Ue    ${alias}    timeout=${timeout_reboot_ue}

Verify L3 Call One Way Data Transfer
    [Arguments]    ${direction}    ${duration}    ${tput}    ${protocol}=udp    ${deviation}=25%    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}  ${alias}=UE
    [Documentation]    Attach, Data Transfer DL or UL, Verification Average Troughput and Detach
    ...     :param direction:           dl or ul
    ...     :param duration:            Duration of transmision, exaple: 600s
    ...     :param tput:                Expected tput, example 100 Mbits/sec
    ...     :param protocol:            udp or tcp
    ...     :param deviation:           Percentage of deviation in tput, example: 25%
    ...     :param parallel_streams:    Number of parallel streams
    ...     :param size_packet:         Parameter -l for UDP and -M for TCP in iPerf
    ...     :param buffer_client:       Parameter -w in iPerf for client
    ...     :param buffer_server_dl:    Parameter -w in iPerf for server
    ...     :param interval:            Parameter -i in iPerf
    ...     :param qci:                 UDP/TCP port
    ...     :param linux_congestion:    TCP congestion control algorithm (Linux only)
    ...     :param alias:               UE connection name

    Perform Attach and Verify UE Properly Attached  alias=${alias}
    Start Data Transfer and Verify Troughput   direction=${direction}    duration=${duration}    tput=${tput}    protocol=${protocol}
    ...    deviation=${deviation}    parallel_streams=${parallel_streams}    size_packet=${size_packet}    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}    interval=${interval}    qci=${qci}    linux_congestion=${linux_congestion}  alias=${alias}
    [Teardown]    ue.Detach Ue    ${alias}

Verify L3 Call Data Transfer DL&UL
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}=udp    ${deviation}=25%    ${deviation_dl}=${deviation}
    ...    ${deviation_ul}=${deviation}    ${parallel_streams_dl}=1    ${parallel_streams_ul}=1    ${size_packet}=1400B
    ...    ${size_packet_dl}=${size_packet}    ${size_packet_ul}=${size_packet}    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}
    ...    ${buffer_client_ul}=${None}    ${buffer_server_ul}=${None}    ${interval}=1    ${qci_dl}=${None}    ${qci_ul}=${None}
    ...    ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}  ${alias}=UE
    [Documentation]    Attach, Data Transfer DL and UL, Verification Average Troughput and Detach
    ...     :param duration:               Duration of transmision, exaple: 600s
    ...     :param tput_dl:                Expected tput for DL, example 100 Mbits/sec
    ...     :param tput_ul:                Expected tput for UL, example 100 Mbits/sec
    ...     :param protocol:               udp or TCP
    ...     :param deviation:              Percentage of deviation in tput, example: 25%
    ...     :param deviation_dl:           Percentage of deviation in tput (downlink), example: 25%
    ...     :param deviation_ul:           Percentage of deviation in tput (uplink), example: 25%
    ...     :param paralel_streams_dl:     Number of parallel streams for DL
    ...     :param paralel_streams_ul:     Number of parallel streams for UL
    ...     :param size_packet:            Parameter -l for UDP and -M for TCP in iPerf
    ...     :param size_packet_dl:         Parameter -l for UDP and -M for TCP in iPerf (downlink)
    ...     :param size_packet_ul:         Parameter -l for UDP and -M for TCP in iPerf (uplink)
    ...     :param buffer_client_dl:       Parameter -w in iPerf for client (downlink)
    ...     :param buffer_server_dl:       Parameter -w in iPerf for server (downlink)
    ...     :param buffer_client_ul:       Parameter -w in iPerf for client (uplink)
    ...     :param buffer_server_ul:       Parameter -w in iPerf for server (uplink)
    ...     :param interval:               Parameter -i in iPerf
    ...     :param qci_dl:                 UDP/TCP port for DL
    ...     :param qci_ul:                 UDP/TCP port for UL
    ...     :param linux_congestion_dl:    TCP congestion control algorithm (Linux only) (downlink)
    ...     :param linux_congestion_ul:    TCP congestion control algorithm (Linux only) (uplink)
    ...     :param alias:                  UE connection name
    Perform Attach and Verify UE Properly Attached  alias=${alias}
    Start Data Transfer DL&UL and Verify Troughput    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...    protocol=${protocol}    deviation=${deviation}    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}
    ...    buffer_client_dl=${buffer_client_dl}    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}    interval=${interval}    qci_dl=${qci_dl}    qci_ul=${qci_ul}
    ...    linux_congestion_dl=${linux_congestion_dl}    linux_congestion_ul=${linux_congestion_ul}  alias=${alias}
    [Teardown]    ue.Detach UE   ${alias}


Start Data Transfer and Verify Troughput
    [Arguments]    ${direction}    ${duration}    ${tput}    ${protocol}=udp    ${deviation}=25%    ${parallel_streams}=1    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}  ${alias}=UE
    [Documentation]    Data Transfer DL or UL and Verification Average Troughput
    ...     :param direction:           dl or ul
    ...     :param duration:            Duration of transmision, exaple: 600s
    ...     :param tput:                Expected tput, example 100 Mbits/sec
    ...     :param protocol:            udp or tcp
    ...     :param deviation:           Percentage of deviation in tput, example: 25%
    ...     :param parallel_streams:    Number of parallel streams
    ...     :param size_packet:         Parameter -l for UDP and -M for TCP in iPerf
    ...     :param buffer_client:       Parameter -w in iPerf for client
    ...     :param buffer_server_dl:    Parameter -w in iPerf for server
    ...     :param interval:            Parameter -i in iPerf
    ...     :param qci:                 UDP/TCP port
    ...     :param linux_congestion:    TCP congestion control algorithm (Linux only)
    ...     :param alias:               UE connection name

    ${direction_upper}    Convert To Upper Case  ${direction}

    Start Data Transfer on Real UE   dt_name=DT_${direction_upper}  ue_alias=${alias}  direction=${direction}  protocol=${protocol}
    ...  duration=${duration}  tput=${tput}  parallel_streams=${parallel_streams}  size_packet=${size_packet}
    ...  buffer_client=${buffer_client}  buffer_server=${buffer_server}  interval=${interval}  qci=${qci}    linux_congestion=${linux_congestion}
    Wait for truput stabilization
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Collect logs during data transfer   direction=${direction_upper}
    ue.Check Data Transfer is Alive     dt_name=DT_${direction_upper}
    ue.Await Data Transfer Finish       dt_name=DT_${direction_upper}
    ue.Verify Average Throughput With Deviation   dt_name=DT_${direction_upper}   tput=${tput}   deviation=${deviation}
    [Teardown]  Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Download logs from gNB    sub_dir=data_transfer

Start Data Transfer DL&UL and Verify Troughput
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${protocol}=udp   ${parallel_streams_dl}=1    ${parallel_streams_ul}=1
    ...    ${size_packet}=1400B    ${deviation}=25%     ${deviation_dl}=${deviation}    ${deviation_ul}=${deviation}
    ...    ${size_packet_dl}=${size_packet}    ${size_packet_ul}=${size_packet}
    ...    ${buffer_client_dl}=${None}    ${buffer_server_dl}=${None}    ${buffer_client_ul}=${None}    ${buffer_server_ul}=${None}
    ...    ${interval}=1  ${qci_dl}=${None}  ${qci_ul}=${None}    ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}
    ...    ${alias}=UE
    [Documentation]    Data Transfer DL and UL, Verification Average Troughput
    ...     :param duration:               Duration of transmision, exaple: 600s
    ...     :param tput_dl:                Expected tput for DL, example 100 Mbits/sec
    ...     :param tput_ul:                Expected tput for UL, example 100 Mbits/sec
    ...     :param protocol:               udp or TCP
    ...     :param deviation:              Percentage of deviation in tput, example: 25%
    ...     :param paralel_streams_dl:     Number of parallel streams for DL
    ...     :param paralel_streams_ul:     Number of parallel streams for UL
    ...     :param size_packet:            Parameter -l for UDP and -M for TCP in iPerf
    ...     :param size_packet_dl:         Parameter -l for UDP and -M for TCP in iPerf (downlink)
    ...     :param size_packet_ul:         Parameter -l for UDP and -M for TCP in iPerf (uplink)
    ...     :param buffer_client_dl:       Parameter -w in iPerf for client (downlink)
    ...     :param buffer_server_dl:       Parameter -w in iPerf for server (downlink)
    ...     :param buffer_client_ul:       Parameter -w in iPerf for client (uplink)
    ...     :param buffer_server_ul:       Parameter -w in iPerf for server (uplink)
    ...     :param interval:               Parameter -i in iPerf
    ...     :param qci_dl:                 UDP/TCP port for DL
    ...     :param qci_ul:                 UDP/TCP port for UL
    ...     :param linux_congestion_dl:    TCP congestion control algorithm (Linux only) (downlink)
    ...     :param linux_congestion_ul:    TCP congestion control algorithm (Linux only) (uplink)
    ...     :param alias:                  UE connection name
    Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=${alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_dl}  parallel_streams=${parallel_streams_dl}  size_packet=${size_packet_dl}  buffer_client=${buffer_client_dl}
    ...  buffer_server=${buffer_server_dl}  interval=${interval}  qci=${qci_dl}    linux_congestion=${linux_congestion_dl}
    Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=${alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_ul}  parallel_streams=${parallel_streams_ul}  size_packet=${size_packet_ul}  buffer_client=${buffer_client_ul}
    ...  buffer_server=${buffer_server_ul}  interval=${interval}  qci=${qci_ul}    linux_congestion=${linux_congestion_ul}
    Wait for truput stabilization
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Collect logs during data transfer   direction=BOTH
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${tput_dl}   deviation=${deviation_dl}
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${tput_ul}   deviation=${deviation_ul}
    [Teardown]  Download logs from gNB    sub_dir=data_transfer


Perform Attach and Verify UE Properly Attached
    [Arguments]    ${alias}=UE
    [Documentation]    Perform Attach and Verify UE Properly Attached
    ...     :param alias:                  UE connection name
    # TODO so far only collecting BIP logs from attach. In the futher need to add verification
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Start collecting logs during attach
    Start Ue RACH Observer
    ue.Attach Ue    ${alias}
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Stop collecting logs after attach
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Download logs from gNB    sub_dir=attach
    Verify RACH

Wait for truput stabilization
    Sleep  10

Wait for next PM period
    ${pm_interval_range}  gnbcounter.wait_for_next_pm_period
    Set Test Variable  ${PM_PERIOD_START_TIME}  ${pm_interval_range[0]}
    Set Test Variable  ${PM_PERIOD_END_TIME}  ${pm_interval_range[1]}
