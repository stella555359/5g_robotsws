*** Settings ***
Documentation
...    Test CB010367 - General_SiSo_Cell_block_and_unblock
...    author/contact: damian.silkowski@nokia.com


*** Keywords ***
General_SiSo_Cell_block_and_unblock
    [Arguments]     ${attach_timeout}=${20}
    ${cells_setup_list}    prepare_cells_setup_for_tput    ${ru_matrix}
    Set qRxLevMin to minus 22 on each cell
    check_number_of_rus    ${cells_setup_list}
    REAL_UE.Prepare Ue for L3 Call
    ...  capabilities=${capabilities}
    ...  reboot_ue=${reboot_ue}
    ...  timeout_reboot_ue=${timeout_reboot_ue}
    gnbalarm.allow_alarm    alarm=@{allowed_alarms_during_cell_block}
    FOR    ${cs}    IN    @{cells_setup_list}
        gnbcell.block_cell    cell_id=${cs}[active_cell][id]
        ...                           timeout=80
        gnbalarm.wait_for_alarm_activation    fault_id=49    awaiting_time=80
        gnbcell.unblock_cell    cell_id=${cs}[active_cell][id]
        ...                            timeout=80
        gnbalarm.wait_for_alarm_deactivation    fault_id=49    awaiting_time=80
        Prepare cell for tput    ${cs}[active_cell][id]    ${cs}[cells_to_block]
        set_rf_matrix_output_ports    rfs_alias=${RFS_ALIAS}
        ...                                     vendor=${RF_VENDOR}
        ...                                     ip_addr=${RF_IP}
        ...                                     model=${RF_MODEL}
        ...                                     output_ports=${cs}[active_cell][ports]
        Run Keyword And Continue On Failure    Run Bi Directional tput TCP    ${cs}[active_cell][exp_dl_tput]
        ...                                                                   ${cs}[active_cell][exp_ul_tput]
        ...                                                                   attach_timeout=${attach_timeout}
        Fill in tput table            cell_id=${cs}[active_cell][id]
        ...                           tput_dl=${cs}[active_cell][exp_dl_tput]
        ...                           tput_ul=${cs}[active_cell][exp_ul_tput]
        ...                           protocol=tcp
        ...                           deviation=${deviation}
    END
    gnbalarm.disallow_alarm    alarm=@{allowed_alarms_during_cell_block}
    Verify If All Radio Modules Online
