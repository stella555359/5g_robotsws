*** Settings ***
Documentation
...    Test CB012524 - General_SiSo_RF_module_lock_unlock_from_WebUI_with_L3_call
...    author/contact: damian.silkowski@nokia.com, agnieszka.bylica@nokia.com, marcin.bereznicki@nokia.com

Library      Collections
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    ru_operations
Resource     taf/rfrl/bts/robot/common/gnb_ru.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot


*** Keywords ***
General_SiSo_RF_module_lock_unlock_from_WebUI_with_L3_call
    Set qRxLevMin to minus 22 on each cell
    ${cells_setup_list}    Prepare Cells Setup For Tput    ${ru_matrix}
    ${rus_ids}             check_number_of_rus             ${cells_setup_list}
    REAL_UE.Prepare Ue for L3 Call                         capabilities=${capabilities}
    ...                                                    reboot_ue=${reboot_ue}
    ...                                                    timeout_reboot_ue=${timeout_reboot_ue}
    FOR    ${cs}    IN    @{cells_setup_list}
        Log         ${cs}
        ${ru_id}    Convert To String    ${cs}[ru_id]
        ${i}        Get Match Count      ${rus_ids}    ${ru_id}
        IF  ${i} > ${0}
            Log To Console                        Lock Unlock RU-${ru_id}
            Lock Unlock RU and Verify Statuses    ${cs}[ru_id]
            Remove Values From List               ${rus_ids}    ${ru_id}
        END
        Prepare Cell For Tput         ${cs}[active_cell][id]    ${cs}[cells_to_block]
        Set RF Matrix Output Ports    rfs_alias=${RFS_ALIAS}
        ...                           vendor=${RF_VENDOR}
        ...                           ip_addr=${RF_IP}
        ...                           model=${RF_MODEL}
        ...                           output_ports=${cs}[active_cell][ports]
        Run Keyword And Continue On Failure    Run Bi Directional tput TCP    ${cs}[active_cell][exp_dl_tput]
        ...                                                                   ${cs}[active_cell][exp_ul_tput]
        Fill in tput table            cell_id=${cs}[active_cell][id]
        ...                           tput_dl=${cs}[active_cell][exp_dl_tput]
        ...                           tput_ul=${cs}[active_cell][exp_ul_tput]
        ...                           protocol=tcp
        ...                           deviation=${deviation}
    END
    Verify If All Radio Modules Online
