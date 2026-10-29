*** Settings ***
Library     taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations    WITH NAME    cell_operations
Library     taf.rfrl.ue.helpers.data_transfer    WITH NAME    data_transfer
Resource    taf/rfrl/ue/robot/REAL_UE.robot
*** Keywords ***
Block_specific_cell
    [Arguments]    ${cells_to_block}
    FOR    ${cell}    IN    @{cells_to_block}
        cell_operations.block_cell    cell_id=${cell}
    END

Unblock_specific_cell
    [Arguments]    ${cells_to_block}
    FOR    ${cell}    IN    @{cells_to_block}
        cell_operations.unblock_cell    cell_id=${cell}
    END

Run_Bi_Directional_thpt_tcp_and_udp
    [Arguments]    ${tput_dl}   ${tput_ul}
    #tcp
    Bi-Directional Tput
    ...    capabilities=${capabilities}
    ...    duration=${duration}
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=${size_packet}
    ...    deviation=${deviation}
    ...    protocol=tcp
    ...    size_packet_dl=${size_packet_dl}
    ...    size_packet_ul=${size_packet_ul}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    deviation_dl=${deviation}
    ...    deviation_ul=${deviation}
    ...    qci_dl=${None}
    ...    qci_ul=${None}
    ...    linux_congestion_dl=${None}
    ...    linux_congestion_ul=${None}
    ...    alias=${alias}   omit=${omit}
    ...    prepare_ue=${prepare_ue}
    ...    reboot_ue=${False}
    ...    timeout_reboot_ue=100

    #udp
    Bi-Directional Tput
    ...    capabilities=${capabilities}
    ...    duration=${duration}
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=${size_packet}
    ...    deviation=${deviation}
    ...    protocol=udp
    ...    size_packet_dl=${size_packet_dl}
    ...    size_packet_ul=${size_packet_ul}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    deviation_dl=${deviation}
    ...    deviation_ul=${deviation}
    ...    qci_dl=${None}
    ...    qci_ul=${None}
    ...    linux_congestion_dl=${None}
    ...    linux_congestion_ul=${None}
    ...    alias=${alias}
    ...    omit=${omit}
    ...    prepare_ue=${prepare_ue}
    ...    reboot_ue=${False}
    ...    timeout_reboot_ue=100

Run_Bi_Directional_thpt_to_specific_cell
    [Arguments]    ${cell_setup}
    ${cells_to_block}    Get Length    ${cell_setup}[cells_to_block]
    Run Keyword If    '${cells_to_block}'>='1'    Block_specific_cell    ${cell_setup}[cells_to_block]
    kw.set_rf_switch_output_ports    rfs_alias=RF_SWITCH
    ...                              vendor=${RF_VENDOR}
    ...                              ip_addr=${RF_IP}
    ...                              model=${RF_MODEL}
    ...                              output_ports=${cell_setup}[active_cell][ports]
    log    Thpt for RU: ${cell_setup}[ru_id]    console=${True}
    log    cell: ${cell_setup}[active_cell][id] ports ${cell_setup}[active_cell][ports]    console=${True}
    Set Test Variable   ${exp_tput_dl}   ${cell_setup}[active_cell][exp_dl_tput]
    Set Test Variable   ${exp_tput_ul}   ${cell_setup}[active_cell][exp_ul_tput]
    Run_Bi_Directional_thpt_tcp_and_udp    tput_dl=${exp_tput_dl}   tput_ul=${exp_tput_ul}
    [Teardown]    Run Keyword If    '${cells_to_block}'>='1'    Unblock_specific_cell    ${cell_setup}[cells_to_block]

Bi-Directional Tput
    [Arguments]    ${capabilities}                   ${duration}                       ${tput_dl}
    ...            ${tput_ul}                        ${parallel_streams_dl}            ${parallel_streams_ul}
    ...            ${size_packet}                    ${deviation}                      ${protocol}
    ...            ${size_packet_dl}                 ${size_packet_ul}                 ${buffer_client_dl}
    ...            ${buffer_server_dl}               ${buffer_client_ul}               ${buffer_server_ul}
    ...            ${interval}                       ${deviation_dl}=${deviation}      ${deviation_ul}=${deviation}
    ...            ${qci_dl}=${None}                 ${qci_ul}=${None}                 ${linux_congestion_dl}=${None}
    ...            ${linux_congestion_ul}=${None}    ${alias}=${alias}                 ${omit}=${omit}
    ...            ${prepare_ue}=${True}             ${reboot_ue}=${False}             ${timeout_reboot_ue}=100

    REAL_UE.Perform Attach and Verify UE Properly Attached   alias=${alias}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=${alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_dl}  parallel_streams=${parallel_streams_dl}  size_packet=${size_packet_dl}  buffer_client=${buffer_client_dl}
    ...  buffer_server=${buffer_server_dl}  interval=${interval}  qci=${qci_dl}    linux_congestion=${linux_congestion_dl}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=${alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_ul}  parallel_streams=${parallel_streams_ul}  size_packet=${size_packet_ul}  buffer_client=${buffer_client_ul}
    ...  buffer_server=${buffer_server_ul}  interval=${interval}  qci=${qci_ul}    linux_congestion=${linux_congestion_ul}
    REAL_UE.Wait for truput stabilization
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Collect logs during data transfer   direction=BOTH
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${tput_dl}   deviation=${deviation_dl}    omit=${omit}
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${tput_ul}   deviation=${deviation_ul}    omit=${omit}
    Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Download logs from gNB    sub_dir=data_transfer
    ue.Detach UE   ${alias}


