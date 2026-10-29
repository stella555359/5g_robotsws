*** Settings ***
Documentation
...   Resource file implemented for the feature CB012524 that containes keywords for tput testing using ru matrix
...   maintainer: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com


Library     taf.rfrl.ue.helpers.data_transfer    WITH NAME    data_transfer
Resource    taf/rfrl/bts/robot/recovery_gnb.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot


*** Keywords ***
Set qRxLevMin to minus 22 on each cell
    [Documentation]
    ...    Set value -22 for param qRxLevMin in the beggining of the test
    ...    -22 - for the cell on which traffic WILL NOT be ran
    ...    -45 - for the cell on which traffic WILL be ran
    ${cells}    gnbcell.get_all_cells_id
    FOR    ${cell}    IN    @{cells}
        Change qRxLevMin value    ${cell}    -22
    END


Change qRxLevMin value
    [Arguments]    ${cell_id}    ${qRxLevMin_value}
    ${qRxLevMin_distname}    prepare_distname_for_qRxLevMin
    gnb_scf.Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${qRxLevMin_distname}${cell_id}
    ...  param_name=qRxLevMin
    ...  operation=update
    ...  param_value=${qRxLevMin_value}
    ...  timeout=${180}


Prepare cell for tput
    [Documentation]
    ...    Set specific value for param qRxLevMin to run tput for specific cell
    ...    -22 - for the cell on which traffic WILL NOT be ran
    ...    -45 - for the cell on which traffic WILL be ran
    [Arguments]    ${traffic_cell}    ${non_trafic_cells}
    Change qRxLevMin value    ${traffic_cell}    -45
    FOR    ${cell}    IN    @{non_trafic_cells}
        Change qRxLevMin value    ${cell}    -22
    END


Run Bi Directional tput TCP
    [Arguments]    ${tput_dl}   ${tput_ul}   ${attach_timeout}=${20}
    Bi Directional Tput
    ...    duration=${duration}
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    deviation=${deviation}
    ...    protocol=tcp
    ...    size_packet_dl=${size_packet_dl}
    ...    size_packet_ul=${size_packet_ul}
    ...    interval=${interval}
    ...    deviation_dl=${deviation}
    ...    deviation_ul=${deviation}
    ...    qci_dl=${None}
    ...    qci_ul=${None}
    ...    linux_congestion_dl=${None}
    ...    linux_congestion_ul=${None}
    ...    alias=${alias}
    ...    omit=${omit}
    ...    attach_timeout=${attach_timeout}

Bi Directional Tput
    [Arguments]    ${duration}                       ${tput_dl}
    ...            ${tput_ul}                        ${parallel_streams_dl}            ${parallel_streams_ul}
    ...            ${deviation}                      ${protocol}
    ...            ${size_packet_dl}                 ${size_packet_ul}                 ${interval}
    ...            ${deviation_dl}=${deviation}      ${deviation_ul}=${deviation}      ${qci_dl}=${None}
    ...            ${qci_ul}=${None}                 ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}
    ...            ${alias}=${alias}                 ${omit}=${omit}                   ${attach_timeout}=${20}
    REAL_UE.Perform Attach and Verify UE Properly Attached   alias=${alias}     timeout=${attach_timeout}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=${alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_dl}  parallel_streams=${parallel_streams_dl}  size_packet=${size_packet_dl}    interval=${interval}  qci=${qci_dl}
    ...  linux_congestion=${linux_congestion_dl}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=${alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_ul}  parallel_streams=${parallel_streams_ul}  size_packet=${size_packet_ul}    interval=${interval}  qci=${qci_ul}
    ...  linux_congestion=${linux_congestion_ul}
    REAL_UE.Wait for truput stabilization
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    Run Keyword And Continue On Failure    ue.Verify Average Throughput With Deviation   dt_name=DT_DL
    ...    tput=${tput_dl}   deviation=${deviation_dl}    omit=${omit}
    Run Keyword And Continue On Failure    ue.Verify Average Throughput With Deviation   dt_name=DT_UL
    ...    tput=${tput_ul}   deviation=${deviation_ul}    omit=${omit}
    [Teardown]    ue.Detach UE   ${alias}


Run L3 call on all cells one by one and verify tput
    [Arguments]    ${sheetname_in_tput_table}=L3 call on all cells
    Set qRxLevMin to minus 22 on each cell
    ${cells_setup_list}    Prepare cells setup for tput    ru_map=${ru_matrix}
    FOR    ${cell_item}    IN    @{cells_setup_list}
        Prepare cell for tput          traffic_cell=${cell_item}[active_cell][id]
        ...                            non_trafic_cells=${cell_item}[cells_to_block]
        set_rf_matrix_output_ports     rfs_alias=${RFS_ALIAS}
        ...                            vendor=${RF_VENDOR}
        ...                            ip_addr=${RF_IP}
        ...                            model=${RF_MODEL}
        ...                            output_ports=${cell_item}[active_cell][ports]
        ${tput_status}    ${return}    Run Keyword And Ignore Error    Run Bi Directional tput TCP    tput_dl=${cell_item}[active_cell][exp_dl_tput]
        ...                                                                               tput_ul=${cell_item}[active_cell][exp_ul_tput]
        Fill in tput table            sheetname=${sheetname_in_tput_table}
        ...                           cell_id=${cell_item}[active_cell][id]
        ...                           tput_dl=${cell_item}[active_cell][exp_dl_tput]
        ...                           tput_ul=${cell_item}[active_cell][exp_ul_tput]
        ...                           protocol=tcp
        ...                           deviation=${deviation}
        Run Keyword If    '${tput_status}' == 'FAIL'    Fail    msg=${return}
    END

Prepare Ue
    REAL_UE.Prepare Ue for L3 Call                         capabilities=${capabilities}
    ...                                                    reboot_ue=${reboot_ue}
    ...                                                    timeout_reboot_ue=${timeout_reboot_ue}
