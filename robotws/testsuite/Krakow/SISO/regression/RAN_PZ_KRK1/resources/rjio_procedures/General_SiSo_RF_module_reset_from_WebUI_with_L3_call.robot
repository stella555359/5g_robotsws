*** Settings ***
Documentation
...    Test CB012524 - General_SiSo_RF_module_reset_from_WebUI_with_L3_call
...    author/contact: damian.silkowski@nokia.com, agnieszka.bylica@nokia.com

Library      Collections


*** Keywords ***
General_SiSo_RF_module_reset_from_WebUI_with_L3_call
    [Arguments]    ${prepare_ue}=${True}
    Set qRxLevMin to minus 22 on each cell
    ${cells_setup_list}    prepare_cells_setup_for_tput    ${ru_matrix}
    ${rus_ids}    check_number_of_rus    ${cells_setup_list}
    Run Keyword If    ${prepare_ue}    Prepare Ue
    FOR    ${cs}    IN    @{cells_setup_list}
        log    ${cs}
        ${ru_id}    Convert To String    ${cs}[ru_id]
        ${i}    Get Match Count    ${rus_ids}    ${ru_id}
        IF  ${i} > ${0}
            log to console    Reset RU-${ru_id}
            Reset RU and wait for Online    ${cs}[ru_id]
            Remove Values From List    ${rus_ids}    ${ru_id}
        END
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
    Verify If All Radio Modules Online
