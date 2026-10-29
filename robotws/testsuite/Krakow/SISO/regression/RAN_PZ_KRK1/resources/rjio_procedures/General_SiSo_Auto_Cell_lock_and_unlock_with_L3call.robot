*** Settings ***
Documentation
...    Test CB012524 - General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
...    author/contact: julia.luszcz@nokia.com


*** Keywords ***
General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    ${cells_setup_list}    prepare_cells_setup_for_tput    ${ru_matrix}
    Set qRxLevMin to minus 22 on each cell
    check_number_of_rus    ${cells_setup_list}
    REAL_UE.Prepare Ue for L3 Call
    ...  capabilities=${capabilities}
    ...  reboot_ue=${reboot_ue}
    ...  timeout_reboot_ue=${timeout_reboot_ue}
    FOR    ${cs}    IN    @{cells_setup_list}
        gnbcell.lock_cell    cell_id=${cs}[active_cell][id]
        gnbcell.wait_for_cell_to_be_locked    cell_id=${cs}[active_cell][id]
        gnbcell.unlock_cell    cell_id=${cs}[active_cell][id]
        gnbcell.wait_for_cell_to_be_onair    cell_id=${cs}[active_cell][id]
        Prepare cell for tput    ${cs}[active_cell][id]    ${cs}[cells_to_block]
        set_rf_matrix_output_ports    rfs_alias=${RFS_ALIAS}
        ...                                     vendor=${RF_VENDOR}
        ...                                     ip_addr=${RF_IP}
        ...                                     model=${RF_MODEL}
        ...                                     output_ports=${cs}[active_cell][ports]
        Run Keyword And Continue On Failure    Run Bi Directional tput TCP    ${cs}[active_cell][exp_dl_tput]
        ...                                                                   ${cs}[active_cell][exp_ul_tput]
        Fill in tput table            cell_id=${cs}[active_cell][id]
        ...                           tput_dl=${cs}[active_cell][exp_dl_tput]
        ...                           tput_ul=${cs}[active_cell][exp_ul_tput]
        ...                           protocol=tcp
        ...                           deviation=${deviation}
    END
    Sleep   180s
    Verify If All Radio Modules Online
