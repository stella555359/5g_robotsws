*** Settings ***

Resource    ./keywords.robot

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_for_main_RU_and_ext_panel
    [Arguments]    ${main_capabilities}    ${ext_capabilities}    ${duration}    ${main_tput_dl}    ${main_tput_ul}
    ...    ${ext_tput_dl}    ${ext_tput_ul}    ${timeout_reboot_ue}=100    ${repeat_measurement_tput}=1    ${reboot_ue}=False
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

    Prepare Ue for L3 Call    capabilities=${main_capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    ...    alias=${UE_main_alias}
    Prepare Ue for L3 Call    capabilities=${ext_capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    ...    alias=${UE_ext_alias}
    Repeat Keyword    ${repeat_measurement_tput}
    ...    E2E Data Transfer    duration=${duration}    main_tput_dl=${main_tput_dl}    main_tput_ul=${main_tput_ul}
    ...    ext_tput_dl=${ext_tput_dl}    ext_tput_ul=${ext_tput_ul}
    ...    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}    main_size_packet_ul=${main_size_packet_ul}    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}    ext_deviation_ul=${ext_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}
    Reset gNB via GUI
    Verify gNB Does Not Respond
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Setup of All Cells
    E2E Data Transfer    duration=${duration}    main_tput_dl=${main_tput_dl}    main_tput_ul=${main_tput_ul}
    ...    ext_tput_dl=${ext_tput_dl}    ext_tput_ul=${ext_tput_ul}
    ...    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}    main_size_packet_ul=${main_size_packet_ul}    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}    ext_deviation_ul=${ext_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}
    Reset gNB Radio Unit from GUI
    Wait for Cell Status Change after RU Reboot
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    E2E Data Transfer    duration=${duration}    main_tput_dl=${main_tput_dl}    main_tput_ul=${main_tput_ul}
    ...    ext_tput_dl=${ext_tput_dl}    ext_tput_ul=${ext_tput_ul}
    ...    UE_main_alias=${UE_main_alias}
    ...    main_parallel_streams_dl=${main_parallel_streams_dl}    main_buffer_server_dl=${main_buffer_server_dl}
    ...    main_buffer_client_dl=${main_buffer_client_dl}    main_size_packet_dl=${main_size_packet_dl}    main_deviation_dl=${main_deviation_dl}
    ...    main_parallel_streams_ul=${main_parallel_streams_ul}    main_buffer_server_ul=${main_buffer_server_ul}
    ...    main_buffer_client_ul=${main_buffer_client_ul}    main_size_packet_ul=${main_size_packet_ul}    main_deviation_ul=${main_deviation_ul}
    ...    UE_ext_alias=${UE_ext_alias}
    ...    ext_parallel_streams_dl=${ext_parallel_streams_dl}    ext_buffer_server_dl=${ext_buffer_server_dl}
    ...    ext_buffer_client_dl=${ext_buffer_client_dl}    ext_size_packet_dl=${ext_size_packet_dl}    ext_deviation_dl=${ext_deviation_dl}
    ...    ext_parallel_streams_ul=${ext_parallel_streams_ul}    ext_buffer_server_ul=${ext_buffer_server_ul}
    ...    ext_buffer_client_ul=${ext_buffer_client_ul}    ext_size_packet_ul=${ext_size_packet_ul}    ext_deviation_ul=${ext_deviation_ul}
    ...    interval=${interval}    qci=${qci}    protocol=${protocol}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}
