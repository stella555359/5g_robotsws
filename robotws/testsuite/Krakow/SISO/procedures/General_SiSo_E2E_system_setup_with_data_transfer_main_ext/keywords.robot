*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot

*** Keywords ***
Data Transfer DL UL and DL&UL for Main RU and Ext Panel
    [Documentation]    Data Transfer DL, UL and BiDir for main RU and extension panel run one by one
    ...    and Verification Average Troughput of every transfer
    ...    Example:    DL Main + EXT, UL Main + EXT, BiDir Main + EXT
    [Arguments]    ${duration}    ${main_tput_dl}    ${main_tput_ul}    ${ext_tput_dl}    ${ext_tput_ul}
    ...    ${UE_main_alias}=UE_MAIN
    ...    ${main_parallel_streams_dl}=1    ${main_buffer_server_dl}=${None}    ${main_buffer_client_dl}=${None}    ${main_size_packet_dl}=1400B
    ...    ${main_deviation_dl}=25%
    ...    ${main_parallel_streams_ul}=1    ${main_buffer_server_ul}=${None}    ${main_buffer_client_ul}=${None}    ${main_size_packet_ul}=1400B
    ...    ${main_deviation_ul}=25%
    ...    ${UE_ext_alias}=UE_EXT
    ...    ${ext_parallel_streams_dl}=1    ${ext_buffer_server_dl}=${None}    ${ext_buffer_client_dl}=${None}    ${ext_size_packet_dl}=1400B
    ...    ${ext_deviation_dl}=25%
    ...    ${ext_parallel_streams_ul}=1    ${ext_buffer_server_ul}=${None}    ${ext_buffer_client_ul}=${None}    ${ext_size_packet_ul}=1400B
    ...    ${ext_deviation_ul}=25%
    ...    ${interval}=1    ${qci}=${None}    ${protocol}=udp    ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}

    Start Data Transfer and Verify Troughput for Main RU and Extension Panel    duration=${duration}
    ...    main_tput=${main_tput_dl}    ext_tput=${ext_tput_dl}    protocol=${protocol}
    ...    UE_main_alias=${UE_main_alias}    main_direction=DL
    ...    main_parallel_streams=${main_parallel_streams_dl}   main_buffer_server=${main_buffer_server_dl}
    ...    main_buffer_client=${main_buffer_client_dl}   main_size_packet=${main_size_packet_dl}   main_deviation=${main_deviation_dl}
    ...    UE_ext_alias=${UE_ext_alias}    ext_direction=DL
    ...    ext_parallel_streams=${ext_parallel_streams_dl}    ext_buffer_server=${ext_buffer_server_dl}
    ...    ext_buffer_client=${ext_buffer_client_dl}    ext_size_packet=${ext_size_packet_dl}    ext_deviation=${ext_deviation_dl}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion=${linux_congestion_dl}

    Start Data Transfer and Verify Troughput for Main RU and Extension Panel    duration=${duration}
    ...    main_tput=${main_tput_ul}   ext_tput=${ext_tput_ul}    protocol=${protocol}
    ...    UE_main_alias=${UE_main_alias}    main_direction=UL
    ...    main_parallel_streams=${main_parallel_streams_ul}   main_buffer_server=${main_buffer_server_ul}
    ...    main_buffer_client=${main_buffer_client_ul}   main_size_packet=${main_size_packet_ul}   main_deviation=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}    ext_direction=UL
    ...    ext_parallel_streams=${ext_parallel_streams_ul}    ext_buffer_server=${ext_buffer_server_ul}
    ...    ext_buffer_client=${ext_buffer_client_ul}    ext_size_packet=${ext_size_packet_ul}    ext_deviation=${ext_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion=${linux_congestion_ul}

    Start Data Transfer DL&UL and Verify Troughput for Main RU and Extension Panel    duration=${duration}
    ...    main_tput_dl=${main_tput_dl}   main_tput_ul=${main_tput_ul}   ext_tput_dl=${ext_tput_dl}   ext_tput_ul=${ext_tput_ul}
    ...    protocol=${protocol}    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}
    ...    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}    main_size_packet_ul=${main_size_packet_ul}
    ...    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}
    ...    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}
    ...    ext_deviation_ul=${ext_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}
    ...    linux_congestion_dl=${linux_congestion_dl}    linux_congestion_ul=${linux_congestion_ul}


Data Transfer DL UL and DL&UL for Main RU or Ext Panel
    [Documentation]    Data Transfer DL, UL and BiDir run one by one (can by run for Main RU or Extension panel)
    ...    and Verification Average Troughput of every transfer
    ...    Example:    DL Main, UL Main and BiDir Main
    [Arguments]    ${duration}    ${tput_dl}    ${tput_ul}    ${UE_alias}=UE_MAIN
    ...    ${parallel_streams_dl}=2    ${buffer_server_dl}=${None}    ${buffer_client_dl}=1400B    ${size_packet_dl}=1400B
    ...    ${deviation_dl}=25%    ${qci_dl}=${None}
    ...    ${parallel_streams_ul}=1    ${buffer_server_ul}=${None}    ${buffer_client_ul}=1400B    ${size_packet_ul}=1400B    ${deviation_ul}=15%
    ...    ${interval}=1    ${qci_ul}=${None}    ${protocol}=udp    ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}

    Start Data Transfer and Verify Troughput   duration=${duration}    direction=dl    tput=${tput_dl}    alias=${UE_alias}
    ...    parallel_streams=${parallel_streams_dl}    buffer_server=${buffer_server_dl}    buffer_client=${buffer_client_dl}
    ...    size_packet=${size_packet_dl}    linux_congestion=${linux_congestion_dl}    deviation=${deviation_dl}
    ...    interval=${interval}    qci=${qci_dl}    protocol=${protocol}

    Start Data Transfer and Verify Troughput   duration=${duration}    direction=ul    tput=${tput_ul}    alias=${UE_alias}
    ...    parallel_streams=${parallel_streams_ul}    buffer_server=${buffer_server_ul}    buffer_client=${buffer_client_ul}
    ...    size_packet=${size_packet_ul}    linux_congestion=${linux_congestion_ul}    deviation=${deviation_ul}
    ...    interval=${interval}    qci=${qci_ul}    protocol=${protocol}

    Start Data Transfer DL&UL and Verify Troughput    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}    alias=${UE_alias}
    ...    parallel_streams_dl=${parallel_streams_dl}    buffer_server_dl=${buffer_server_dl}    buffer_client_dl=${buffer_client_dl}
    ...    size_packet_dl=${size_packet_dl}    linux_congestion_dl=${linux_congestion_dl}    deviation_dl=${deviation_dl}
    ...    qci_dl=${qci_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}    buffer_server_ul=${buffer_server_ul}    buffer_client_ul=${buffer_client_ul}
    ...    size_packet_ul=${size_packet_ul}    linux_congestion_ul=${linux_congestion_ul}    deviation_ul=${deviation_ul}
    ...    qci_ul=${qci_ul}    interval=${interval}    protocol=${protocol}


Data Transfer DL and UL for Main RU and Ext Panel
    [Documentation]    Data Transfer DL and UL run simultaneously and alternately for Main RU and Extension panel
    ...    and Verification Average Troughput of every transfer
    ...    Example:    DL Main + EXT, UL Main + EXT, BiDir Main + EXT
    [Arguments]    ${duration}    ${main_tput_dl}    ${main_tput_ul}    ${ext_tput_dl}    ${ext_tput_ul}
    ...    ${UE_main_alias}=UE_MAIN
    ...    ${main_parallel_streams_dl}=1    ${main_buffer_server_dl}=${None}    ${main_buffer_client_dl}=${None}    ${main_size_packet_dl}=1400B
    ...    ${linux_congestion_dl}=${None}    ${main_deviation_dl}=25%
    ...    ${main_parallel_streams_ul}=1    ${main_buffer_server_ul}=${None}    ${main_buffer_client_ul}=${None}    ${main_size_packet_ul}=1400B
    ...    ${linux_congestion_ul}=${None}    ${main_deviation_ul}=25%
    ...    ${UE_ext_alias}=UE_EXT
    ...    ${ext_parallel_streams_dl}=1    ${ext_buffer_server_dl}=${None}    ${ext_buffer_client_dl}=${None}    ${ext_size_packet_dl}=1400B
    ...    ${ext_deviation_dl}=25%
    ...    ${ext_parallel_streams_ul}=1    ${ext_buffer_server_ul}=${None}    ${ext_buffer_client_ul}=${None}    ${ext_size_packet_ul}=1400B
    ...    ${ext_deviation_ul}=25%
    ...    ${interval}=1    ${qci}=${None}    ${protocol}=udp

    Start Data Transfer and Verify Troughput for Main RU and Extension Panel   duration=${duration}
    ...    ext_tput=${ext_tput_ul}    main_tput=${main_tput_dl}
    ...    UE_ext_alias=${UE_ext_alias}    ext_direction=UL
    ...    ext_parallel_streams=${ext_parallel_streams_ul}    ext_buffer_server=${ext_buffer_server_ul}
    ...    ext_buffer_client=${ext_buffer_client_ul}    ext_size_packet=${ext_size_packet_ul}    ext_deviation=${ext_deviation_ul}
    ...    UE_main_alias=${UE_main_alias}    main_direction=DL
    ...    main_parallel_streams=${main_parallel_streams_dl}    main_buffer_server=${main_buffer_server_dl}
    ...    main_buffer_client=${main_buffer_client_dl}    main_size_packet=${main_size_packet_dl}    main_deviation=${main_deviation_dl}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion=${linux_congestion_ul}

    Start Data Transfer and Verify Troughput for Main RU and Extension Panel   duration=${duration}
    ...    ext_tput=${ext_tput_dl}    main_tput=${main_tput_ul}
    ...    UE_ext_alias=${UE_ext_alias}    ext_direction=DL
    ...    ext_parallel_streams=${ext_parallel_streams_dl}    ext_buffer_server=${ext_buffer_server_dl}
    ...    ext_buffer_client=${ext_buffer_client_dl}    ext_size_packet=${ext_size_packet_dl}    ext_deviation=${ext_deviation_dl}
    ...    UE_main_alias=${UE_main_alias}    main_direction=UL
    ...    main_parallel_streams=${main_parallel_streams_ul}    main_buffer_server=${main_buffer_server_ul}
    ...    main_buffer_client=${main_buffer_client_ul}    main_size_packet=${main_size_packet_ul}    main_deviation=${main_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion=${linux_congestion_dl}


Data Transfer DL or UL and DL&UL for Main RU and Ext Panel
    [Documentation]    Data Transfer DL or UL and BiDir run simultaneously and alternately for Main RU and Extension panel
    ...    and Verification Average Troughput of every transfer
    ...    Example:    UL EXT + BiDir Main
    [Arguments]    ${duration}    ${unidir_tput}    ${bidir_tput_dl}    ${bidir_tput_ul}
    ...    ${unidir_UE_alias}=UE_MAIN    ${unidir_direction}=DL
    ...    ${unidir_parallel_streams}=1    ${unidir_buffer_server}=${None}    ${unidir_buffer_client}=${None}
    ...    ${unidir_size_packet}=1400B    ${unidir_linux_congestion}=${None}    ${unidir_deviation}=25%
    ...    ${bidir_UE_alias}=UE_EXT
    ...    ${bidir_parallel_streams_dl}=2    ${bidir_buffer_server_dl}=${None}    ${bidir_buffer_client_dl}=${None}
    ...    ${bidir_size_packet_dl}=1400B    ${bidir_linux_congestion_dl}=${None}    ${bidir_deviation_dl}=25%
    ...    ${bidir_parallel_streams_ul}=1    ${bidir_buffer_server_ul}=${None}    ${bidir_buffer_client_ul}=${None}
    ...    ${bidir_size_packet_ul}=1400B    ${bidir_linux_congestion_ul}=${None}    ${bidir_deviation_ul}=25%
    ...    ${interval}=1    ${qci}=${None}    ${protocol}=udp

    Start Data Transfer and Verify Unidir and BiDir Troughput for Multi UE    duration=${duration}
    ...    unidir_UE_alias=${unidir_UE_alias}    unidir_direction=${unidir_direction}
    ...    unidir_parallel_streams=${unidir_parallel_streams}    unidir_buffer_server=${unidir_buffer_server}
    ...    unidir_buffer_client=${unidir_buffer_client}    unidir_size_packet=${unidir_size_packet}    unidir_tput=${unidir_tput}
    ...    unidir_linux_congestion=${unidir_linux_congestion}    unidir_deviation=${unidir_deviation}
    ...    bidir_UE_alias=${bidir_UE_alias}
    ...    bidir_tput_dl=${bidir_tput_dl}    bidir_parallel_streams_dl=${bidir_parallel_streams_dl}
    ...    bidir_buffer_server_dl=${bidir_buffer_server_dl}    bidir_buffer_client_dl=${bidir_buffer_client_dl}
    ...    bidir_size_packet_dl=${bidir_size_packet_dl}    bidir_linux_congestion_dl=${bidir_linux_congestion_dl}
    ...    bidir_deviation_dl=${bidir_deviation_dl}
    ...    bidir_tput_ul=${bidir_tput_ul}    bidir_parallel_streams_ul=${bidir_parallel_streams_ul}
    ...    bidir_buffer_server_ul=${bidir_buffer_server_ul}    bidir_buffer_client_ul=${bidir_buffer_client_ul}
    ...    bidir_size_packet_ul=${bidir_size_packet_ul}    bidir_linux_congestion_ul=${bidir_linux_congestion_ul}
    ...    bidir_deviation_ul=${bidir_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}


E2E Data Transfer
    [Documentation]    Run all possible Data Transfer configurations for Main RU and Extension panel during single attach
    ...    and Verification Average Troughput
    [Arguments]    ${duration}    ${main_tput_dl}    ${main_tput_ul}    ${ext_tput_dl}    ${ext_tput_ul}
    ...    ${UE_main_alias}=UE_MAIN
    ...    ${main_parallel_streams_dl}=1    ${main_buffer_server_dl}=${None}    ${main_buffer_client_dl}=${None}    ${main_size_packet_dl}=1400B
    ...    ${linux_congestion_dl}=${None}    ${main_deviation_dl}=25%
    ...    ${main_parallel_streams_ul}=1    ${main_buffer_server_ul}=${None}    ${main_buffer_client_ul}=${None}    ${main_size_packet_ul}=1400B
    ...    ${linux_congestion_ul}=${None}    ${main_deviation_ul}=25%
    ...    ${UE_ext_alias}=UE_EXT
    ...    ${ext_parallel_streams_dl}=1    ${ext_buffer_server_dl}=${None}    ${ext_buffer_client_dl}=${None}    ${ext_size_packet_dl}=1400B
    ...    ${ext_deviation_dl}=25%
    ...    ${ext_parallel_streams_ul}=1    ${ext_buffer_server_ul}=${None}    ${ext_buffer_client_ul}=${None}    ${ext_size_packet_ul}=1400B
    ...    ${ext_deviation_ul}=25%
    ...    ${interval}=1    ${qci}=${None}    ${protocol}=udp

    ue.Attach Ue    ${UE_main_alias}
    ue.Attach Ue    ${UE_ext_alias}
    &{KW_statuses}    Create Dictionary

    # DL Main, UL Main and BiDir Main
    Run Keyword And Continue On Failure    Data Transfer DL UL and DL&UL for Main RU or Ext Panel
    ...    duration=${duration}    protocol=${protocol}    tput_dl=${main_tput_dl}    tput_ul=${main_tput_ul}
    ...    UE_alias=${UE_main_alias}
    ...    parallel_streams_dl=${main_parallel_streams_dl}    buffer_server_dl=${main_buffer_server_dl}    buffer_client_dl=${main_buffer_client_dl}
    ...    size_packet_dl=${main_size_packet_dl}    deviation_dl=${main_deviation_dl}    linux_congestion_dl=${linux_congestion_dl}
    ...    parallel_streams_ul=${main_parallel_streams_ul}    buffer_server_ul=${main_buffer_server_ul}    buffer_client_ul=${main_buffer_client_ul}
    ...    size_packet_ul=${main_size_packet_ul}    deviation_ul=${main_deviation_ul}    linux_congestion_ul=${linux_congestion_ul}

    # DL Ext, UL Ext and BiDir Ext
    Run Keyword And Continue On Failure    Data Transfer DL UL and DL&UL for Main RU or Ext Panel
    ...    duration=${duration}    protocol=${protocol}    tput_dl=${ext_tput_dl}    tput_ul=${ext_tput_ul}
    ...    UE_alias=${UE_ext_alias}
    ...    parallel_streams_dl=${ext_parallel_streams_dl}    buffer_server_dl=${ext_buffer_server_dl}    buffer_client_dl=${ext_buffer_client_dl}
    ...    size_packet_dl=${ext_size_packet_dl}    deviation_dl=${ext_deviation_dl}    linux_congestion_dl=${linux_congestion_dl}
    ...    parallel_streams_ul=${ext_parallel_streams_ul}    buffer_server_ul=${ext_buffer_server_ul}    buffer_client_ul=${ext_buffer_client_ul}
    ...    size_packet_ul=${ext_size_packet_ul}    deviation_ul=${ext_deviation_ul}    linux_congestion_ul=${linux_congestion_ul}

    # DL Main + EXT, UL Main + EXT, BiDir Main + EXT
    Run Keyword And Continue On Failure    Data Transfer DL UL and DL&UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    main_tput_dl=${main_tput_dl}    main_tput_ul=${main_tput_ul}
    ...    ext_tput_dl=${ext_tput_dl}    ext_tput_ul=${ext_tput_ul}
    ...    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}
    ...    linux_congestion_dl=${linux_congestion_dl}    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}   main_size_packet_ul=${main_size_packet_ul}
    ...    linux_congestion_ul=${linux_congestion_ul}    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}
    ...    linux_congestion_dl=${linux_congestion_dl}    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}
    ...    linux_congestion_ul=${linux_congestion_ul}    ext_deviation_ul=${ext_deviation_ul}

    # DL Main + UL EXT, UL Main + DL EXT
    Run Keyword And Continue On Failure        Data Transfer DL and UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    main_tput_dl=${main_tput_dl}    main_tput_ul=${main_tput_ul}
    ...    ext_tput_dl=${ext_tput_dl}    ext_tput_ul=${ext_tput_ul}
    ...    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}
    ...    linux_congestion_dl=${linux_congestion_dl}    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}    main_size_packet_ul=${main_size_packet_ul}
    ...    linux_congestion_ul=${linux_congestion_ul}    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}
    ...    linux_congestion_dl=${linux_congestion_dl}    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}
    ...    linux_congestion_ul=${linux_congestion_ul}    ext_deviation_ul=${ext_deviation_ul}

    # DL Main + BiDir EXT
    Run Keyword And Continue On Failure    Data Transfer DL or UL and DL&UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    unidir_tput=${main_tput_dl}
    ...    bidir_tput_dl=${ext_tput_dl}    bidir_tput_ul=${ext_tput_ul}
    ...    unidir_UE_alias=${UE_main_alias}    unidir_direction=DL
    ...    unidir_parallel_streams=${main_parallel_streams_dl}    unidir_buffer_server=${main_buffer_server_dl}
    ...    unidir_buffer_client=${main_buffer_client_dl}    unidir_size_packet=${main_size_packet_dl}
    ...    unidir_linux_congestion=${linux_congestion_dl}    unidir_deviation=${main_deviation_dl}
    ...    bidir_UE_alias=${UE_ext_alias}
    ...    bidir_parallel_streams_dl=${ext_parallel_streams_dl}    bidir_buffer_server_dl=${ext_buffer_server_dl}
    ...    bidir_buffer_client_dl=${ext_buffer_client_dl}    bidir_size_packet_dl=${ext_size_packet_dl}
    ...    bidir_linux_congestion_dl=${linux_congestion_dl}    bidir_deviation_dl=${ext_deviation_dl}
    ...    bidir_parallel_streams_ul=${ext_parallel_streams_ul}    bidir_buffer_server_ul=${ext_buffer_server_ul}
    ...    bidir_buffer_client_ul=${ext_buffer_client_ul}    bidir_size_packet_ul=${ext_size_packet_ul}
    ...    bidir_linux_congestion_ul=${linux_congestion_ul}    bidir_deviation_ul=${ext_deviation_ul}

    # UL Main + BiDir EXT
    Run Keyword And Continue On Failure    Data Transfer DL or UL and DL&UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    unidir_tput=${main_tput_ul}
    ...    bidir_tput_dl=${ext_tput_dl}    bidir_tput_ul=${ext_tput_ul}
    ...    unidir_UE_alias=${UE_main_alias}    unidir_direction=UL
    ...    unidir_parallel_streams=${main_parallel_streams_ul}    unidir_buffer_server=${main_buffer_server_ul}
    ...    unidir_buffer_client=${main_buffer_client_ul}    unidir_size_packet=${main_size_packet_ul}
    ...    unidir_linux_congestion=${linux_congestion_ul}    unidir_deviation=${main_deviation_ul}
    ...    bidir_UE_alias=${UE_ext_alias}
    ...    bidir_parallel_streams_dl=${ext_parallel_streams_dl}    bidir_buffer_server_dl=${ext_buffer_server_dl}
    ...    bidir_buffer_client_dl=${ext_buffer_client_dl}    bidir_size_packet_dl=${ext_size_packet_dl}
    ...    bidir_linux_congestion_dl=${linux_congestion_dl}    bidir_deviation_dl=${ext_deviation_dl}
    ...    bidir_parallel_streams_ul=${ext_parallel_streams_ul}    bidir_buffer_server_ul=${ext_buffer_server_ul}
    ...    bidir_buffer_client_ul=${ext_buffer_client_ul}    bidir_size_packet_ul=${ext_size_packet_ul}
    ...    bidir_linux_congestion_ul=${linux_congestion_ul}    bidir_deviation_ul=${ext_deviation_ul}

    # DL EXT + BiDir Main
    Run Keyword And Continue On Failure    Data Transfer DL or UL and DL&UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    unidir_tput=${ext_tput_dl}
    ...    bidir_tput_dl=${main_tput_dl}    bidir_tput_ul=${main_tput_ul}
    ...    unidir_UE_alias=${UE_ext_alias}    unidir_direction=DL
    ...    unidir_parallel_streams=${ext_parallel_streams_dl}    unidir_buffer_server=${ext_buffer_server_dl}
    ...    unidir_buffer_client=${ext_buffer_client_dl}    unidir_size_packet=${ext_size_packet_dl}
    ...    unidir_linux_congestion=${linux_congestion_dl}    unidir_deviation=${ext_deviation_dl}
    ...    bidir_UE_alias=${UE_main_alias}
    ...    bidir_parallel_streams_dl=${main_parallel_streams_dl}    bidir_buffer_server_dl=${main_buffer_server_dl}
    ...    bidir_buffer_client_dl=${main_buffer_client_dl}    bidir_size_packet_dl=${main_size_packet_dl}
    ...    bidir_linux_congestion_dl=${linux_congestion_dl}    bidir_deviation_dl=${main_deviation_dl}
    ...    bidir_parallel_streams_ul=${main_parallel_streams_ul}    bidir_buffer_server_ul=${main_buffer_server_ul}
    ...    bidir_buffer_client_ul=${main_buffer_client_ul}    bidir_size_packet_ul=${main_size_packet_ul}
    ...    bidir_linux_congestion_ul=${linux_congestion_ul}    bidir_deviation_ul=${main_deviation_ul}

    # UL EXT + BiDir Main
    Run Keyword And Continue On Failure    Data Transfer DL or UL and DL&UL for Main RU and Ext Panel
    ...    duration=${duration}    protocol=${protocol}    unidir_tput=${ext_tput_ul}
    ...    bidir_tput_dl=${main_tput_dl}    bidir_tput_ul=${main_tput_ul}
    ...    unidir_UE_alias=${UE_ext_alias}    unidir_direction=UL
    ...    unidir_parallel_streams=${ext_parallel_streams_ul}    unidir_buffer_server=${ext_buffer_server_ul}
    ...    unidir_buffer_client=${ext_buffer_client_ul}        unidir_size_packet=${ext_size_packet_ul}
    ...    unidir_linux_congestion=${linux_congestion_ul}    unidir_deviation=${ext_deviation_ul}
    ...    bidir_UE_alias=${UE_main_alias}
    ...    bidir_parallel_streams_dl=${main_parallel_streams_dl}    bidir_buffer_server_dl=${main_buffer_server_dl}
    ...    bidir_buffer_client_dl=${main_buffer_client_dl}    bidir_size_packet_dl=${main_size_packet_dl}
    ...    bidir_linux_congestion_dl=${linux_congestion_dl}    bidir_deviation_dl=${main_deviation_dl}
    ...    bidir_parallel_streams_ul=${main_parallel_streams_ul}    bidir_buffer_server_ul=${main_buffer_server_ul}
    ...    bidir_buffer_client_ul=${main_buffer_client_ul}    bidir_size_packet_ul=${main_size_packet_ul}
    ...    bidir_linux_congestion_ul=${linux_congestion_ul}    bidir_deviation_ul=${main_deviation_ul}

    [Teardown]    Run Keywords    ue.Detach Ue    ${UE_main_alias}    AND    ue.Detach Ue    ${UE_ext_alias}
