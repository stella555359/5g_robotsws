*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot
Library     ./CB008924_keywords.py


*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer
    [Arguments]   ${repeat_measurement_tput}    ${duration}    ${data_size_dl}    ${data_size_ul}
    ...           ${parallel_streams}    ${capabilities}=REAL_MEDIATEK_UE    ${protocol}=udp    ${deviation}=10%
    ...           ${server_buffer_dl}=8M  ${client_buffer_dl}=2M
    ...           ${maximum_segment_size}=${EMPTY}  ${rat}=NR  ${apn}=5gsakrk
    prepare_ue_network_type  ${apn}  ${rat}
    Repeat Keyword    ${repeat_measurement_tput}
    ...  Data Transfer DL UL and DL&UL
    ...  duration=${duration}        data_size_dl=${data_size_dl}    data_size_ul=${data_size_ul}
    ...  parallel_streams= ${parallel_streams}  protocol=${protocol}        deviation=${deviation}
    ...  server_buffer_dl=${server_buffer_dl}   client_buffer_dl=${client_buffer_dl}
    ...  maximum_segment_size=${maximum_segment_size}
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Setup of All Cells
    prepare_ue_network_type  ${apn}  ${rat}
    Data Transfer DL UL and DL&UL
    ...  duration=${duration}        data_size_dl=${data_size_dl}    data_size_ul=${data_size_ul}
    ...  parallel_streams= ${parallel_streams}  protocol=${protocol}        deviation=${deviation}
    ...  maximum_segment_size=${maximum_segment_size}
    Reset gNB Radio Unit from GUI
    Wait for Cell Status Change after RU Reboot
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    prepare_ue_network_type  ${apn}  ${rat}
    Data Transfer DL UL and DL&UL
    ...  duration=${duration}        data_size_dl=${data_size_dl}    data_size_ul=${data_size_ul}
    ...  parallel_streams= ${parallel_streams}  protocol=${protocol}        deviation=${deviation}
    ...  maximum_segment_size=${maximum_segment_size}


Data Transfer DL UL and DL&UL
    [Arguments]    ${duration}          ${data_size_dl}    ${data_size_ul}
    ...            ${parallel_streams}  ${protocol}=udp    ${deviation}=10%
    ...            ${server_buffer_dl}=8M  ${client_buffer_dl}=2M
    ...            ${maximum_segment_size}=${EMPTY}
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams}
    ...  data_size_ul=${data_size_ul}
    ...  protocol=${protocol}
    ...  maximum_segment_size=${maximum_segment_size}
    ...  server_buffer_dl=${server_buffer_dl}
    ...  client_buffer_dl=${client_buffer_dl}
    tput.run_ul_traffic_with_ues_simultaneously
    ...  duration=${duration}
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  ul_tput=${data_size_ul}
    ...  tolerance=${deviation}
    tput.Set data transfer parameters
    ...  parallel_streams_dl=${parallel_streams}
    ...  data_size_dl=${data_size_dl}
    ...  protocol=${protocol}
    ...  maximum_segment_size=${maximum_segment_size}
    ...  server_buffer_dl=${server_buffer_dl}
    ...  client_buffer_dl=${client_buffer_dl}
    tput.run_dl_traffic_with_ues_simultaneously
    ...  duration=${duration}
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl}
    ...  tolerance=${deviation}
    tput.Set data transfer parameters
    ...  parallel_streams_ul=${parallel_streams}
    ...  data_size_ul=${data_size_ul}
    ...  parallel_streams_dl=${parallel_streams}
    ...  data_size_dl=${data_size_dl}
    ...  protocol=${protocol}
    ...  maximum_segment_size=${maximum_segment_size}
    ...  server_buffer_dl=${server_buffer_dl}
    ...  client_buffer_dl=${client_buffer_dl}
    tput.run_bi_dir_traffic_with_ues_simultaneously
    ...  duration=${duration}
    tput.Validate current throughput values
    ...  transfers_to_validate=1
    ...  dl_tput=${data_size_dl}
    ...  ul_tput=${data_size_ul}
    ...  tolerance=${deviation}
