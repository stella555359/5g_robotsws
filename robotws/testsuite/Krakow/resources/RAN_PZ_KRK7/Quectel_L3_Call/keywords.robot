*** Settings ***
Documentation
...    author: Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
...    maintainers: Bartłomiej Bieńko
...                 Wioleta Święs (wioleta.swies@nokia.com)
...
...    Keywords stricly related for Quectel UE
...    If your suite uses same parameters for all TCs, like ue_alias, duration, packet, protocol or deviation
...    please define them within `*** Variables ***` section in your test suite.
...    These parameters are listed below with the proposed default values that work on our configurations:
...        · ${UE_DEFAULT_ALIAS_NAME}=    UE
...        · ${DATA_TRANSFER_DEFAULT_DURATION}=    60s
...        · ${DEFAULT_PACKET_SIZE}=    1320  # for TCP procotol
...        · ${DEFAULT_PROTOCOL}=    tcp
...        · ${DEFAULT_DEVIATION}=    25%  # for SISO Features its 40%
...
...    If your test checks data transfer or attached cell's PCI please use KWs with 'Require UE and' prefix,
...    otherwise call `ute_ue.Require UE` explicilty and use KWs without mentioned prefix.

Library    ute_ue
Library    ./ue_proxy.py    WITH NAME    ue_proxy
Library    ./helpers.py     WITH NAME    helpers

*** Keywords ***
Check data transfer with Quectel
    [Documentation]    Keyword used to verify throughput (both DL and UL) using Quectel UE.
    ...                Requires useage `Require UE` with same ue_alias before call this KW.
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                 - DATA_TRANSFER_DEFAULT_DURATION
    ...                 - DEFAULT_PACKET_SIZE
    ...                 - DEFAULT_PROTOCOL
    ...                 - DEFAULT_DEVIATION
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.

    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${ue_capabilities}=QUECTEL_UE
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${log_throughput}=${False}

    ue_proxy.Stop Ue Proxy On Ue PC
    ue_proxy.Start Ue Proxy On Ue PC

    ute_ue.Require UE    ${ue_alias}    capabilities=${ue_capabilities}
    Sleep    5sec

    ute_ue.Attach UE    ${ue_alias}
    Sleep    10sec

    ute_ue.Get UE Info    ${ue_alias}    ALL
    Check DL and UL data transfer with Quectel    throughput_DL=${throughput_DL}
    ...                                           throughput_UL=${throughput_UL}
    ...                                           parallel_streams_DL=${parallel_streams_DL}
    ...                                           parallel_streams_UL=${parallel_streams_UL}
    ...                                           ue_alias=${ue_alias}
    ...                                           duration=${duration}
    ...                                           packet=${packet}
    ...                                           protocol=${protocol}
    ...                                           deviation=${deviation}
    ...                                           linux_congestion=${linux_congestion}
    ...                                           log_throughput=${log_throughput}

    [Teardown]    ute_ue.Detach UE    ${ue_alias}


Check DL and UL data transfer with Quectel
    [Documentation]    Keyword used to verify throughput (both DL and UL) using Quectel UE.
    ...                Requires useage `Attach UE` before
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                 - DATA_TRANSFER_DEFAULT_DURATION
    ...                 - DEFAULT_PACKET_SIZE
    ...                 - DEFAULT_PROTOCOL
    ...                 - DEFAULT_DEVIATION
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.

    [Arguments]    ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${max_segment_size}=${DEFAULT_PACKET_SIZE}
    ...            ${log_throughput}=${False}

    # DL
    Wait Until Keyword Succeeds    3x    30 sec    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${ue_alias}
    ...                           direction=dl
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           throughput=${throughput_DL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_DL}
    ...                           max_segment_size=${max_segment_size}
    ...                           linux_congestion=${linux_congestion}

    ute_ue.Await Data Transfer Finish    dt_name=DT_DL

    # UL
    Wait Until Keyword Succeeds    3x    30 sec    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${ue_alias}
    ...                           direction=ul
    ...                           duration=${duration}
    ...                           packet=${packet}
    ...                           throughput=${throughput_UL}
    ...                           protocol=${protocol}
    ...                           parallel_streams=${parallel_streams_UL}
    ...                           max_segment_size=${max_segment_size}
    ...                           linux_congestion=${linux_congestion}

    ute_ue.Await Data Transfer Finish    dt_name=DT_UL

    # Verify Average Throughput With Deviation for both DL and UL
    ${dlbps}=    Get Average Throughput    dt_name=DT_DL
    ${tputdl_mbps}=    Evaluate    $dlbps / 1000
    ${ulbps}=    Get Average Throughput    dt_name=DT_UL
    ${tputul_mbps}=    Evaluate    $ulbps / 1000
    Run Keyword If    $log_throughput  log to console    DL tput is: ${tputdl_mbps} Mbps, UL tput is: ${tputul_mbps} Mbps

    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_DL    tput=${throughput_DL}    deviation=${deviation}
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_UL    tput=${throughput_UL}    deviation=${deviation}


Prepare Network Mode And Band
    [Arguments]    ${network_mode}=NR5G
    ...            ${band_num}=3
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${timeout}=3 min

    Wait Until Keyword Succeeds    ${timeout}    30 sec    Change Network Mode    ${ue_alias}    ${network_mode}    ue_type=${UE_TYPE}
    Set Active Bands    ${ue_alias}    ${network_mode}    ${band_num}
    Sleep    10sec


Check desired PCI
    [Arguments]    ${desired_pci}
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ${UE_INFO}=    ute_ue.Get UE Info    ${ue_alias}    ALL
    Run Keyword And Warn On Failure
    ...    helpers.log_ue_info    ue_info=${UE_INFO}    key_list=['cell_id','arfcn','mode','ARFCN','earfcn','PCID','PCID_lte','RSRP','RSRP_lte']
    helpers.Check PCI From Get UE Info    ${UE_INFO}    ${desired_pci}


Check connectivity and data transfer with Quectel on desired PCI
    [Documentation]    Keyword used to verify if UE has been attached to desired CELL (filtered by PCI).
    ...                Requires useage `Require UE` with same ue_alias before call this KW.
    ...                Intended to be used multiple times within single test case.
    ...                Please define variables such as:
    ...                 - UE_DEFAULT_ALIAS_NAME
    ...                on your Suite/Test level once as this Keyword will automatically loads these as defaults arguments.
    ...                Otherwise pass it normally - expicitly giving each argument desired value.
    [Arguments]    ${desired_pci}
    ...            ${throughput_DL}
    ...            ${throughput_UL}
    ...            ${ue_alias}=${UE_DEFAULT_ALIAS_NAME}
    ...            ${parallel_streams_DL}=1
    ...            ${parallel_streams_UL}=1
    ...            ${duration}=${DATA_TRANSFER_DEFAULT_DURATION}
    ...            ${packet}=${DEFAULT_PACKET_SIZE}
    ...            ${protocol}=${DEFAULT_PROTOCOL}
    ...            ${deviation}=${DEFAULT_DEVIATION}
    ...            ${linux_congestion}=reno
    ...            ${max_segment_size}=${DEFAULT_PACKET_SIZE}
    ...            ${timeout}=3 min
    ...            ${log_throughput}=${False}
    Run Keyword If    $log_throughput  Log To Console    cell pci=${desired_pci} :  no_newline=True
    Wait Until Keyword Succeeds    ${timeout}    30 sec    ute_ue.Attach UE    ${ue_alias}
    Sleep    5sec
    Wait Until Keyword Succeeds    ${timeout}    30 sec    Check desired PCI    ${desired_pci}    ${ue_alias}
    Sleep    5sec
    Check DL and UL data transfer with Quectel    throughput_DL=${throughput_DL}
    ...                                           throughput_UL=${throughput_UL}
    ...                                           parallel_streams_DL=${parallel_streams_DL}
    ...                                           parallel_streams_UL=${parallel_streams_UL}
    ...                                           ue_alias=${ue_alias}
    ...                                           duration=${duration}
    ...                                           packet=${packet}
    ...                                           protocol=${protocol}
    ...                                           deviation=${deviation}
    ...                                           linux_congestion=${linux_congestion}
    ...                                           max_segment_size=${max_segment_size}
    ...                                           log_throughput=${log_throughput}

    [Teardown]    Wait Until Keyword Succeeds    3 min    30 sec    ute_ue.Detach UE    ${ue_alias}
