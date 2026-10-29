*** Settings ***
Documentation
...   Keywords implementing test procedures with L3 call for the feature CB009042
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot
Resource    taf/rfrl/procedures/SISO/Online_Cell_addition_deletion.robot


*** Keywords ***
General SiSo Auto RF lock unlock with L3call
    General SiSo Auto RF Lock Unlock
    Verify L3 call

General SiSo Auto RF module reset from WebUI with L3call
    Reset All gNB Radio Units from GUI
    gnbcell.wait_for_all_cells_statuses    operational_state=disabled    timeout=30 sec    interval=5 sec
    gnbcell.wait_for_cell_to_be_onair    timeout=${RU_startup_time} sec    interval=30 sec
    Verify L3 call

General SiSo Auto RF module power reset with L3call
    [Arguments]      ${mandatory_alarms}    ${mandatory_alarms_after_power_on}=@{EMPTY}    ${allowed_alarms}=@{EMPTY}
    ${execution_finished}    Set Variable    ${False}
    gnbalarm.allow_alarm       alarm=${allowed_alarms}
    General_SiSo_Auto_RF_module_power_reset.General SiSo Auto RF module power reset
    ...    mandatory_alarms=${mandatory_alarms}    mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}
    ${execution_finished}    Set Variable    ${True}
    [Teardown]    Run Keywords    gnbalarm.disallow_alarm    alarm=${allowed_alarms}
    ...                           AND
    ...                           Run Keyword If    ${execution_finished}    Verify L3 call

General SiSo Auto RAT reset with L3call
    ${number_of_cells}    gnbcell.get_number_of_cells
    gnbcell.verify_all_cells_are_onair        expected_cell_amount=${number_of_cells}
    Verify L3 call
    gnbbbu.rat_reset                          rat_type=NR
    gnbru.wait_for_all_radio_unit_statuses    operational_state=disabled    timeout=${60}    interval=${5}
    gnbcell.wait_for_all_cells_to_be_onair    expected_cell_amount=${number_of_cells}    timeout=${RAT_startup_time}
    ...                                       interval=${30}
    Verify L3 call

General SiSo Auto Startup BTS power reset with L3call
    ${number_of_cells}    gnbcell.get_number_of_cells
    gnbbbu.bts_power_off
    Wait Until Keyword Succeeds     60 sec     5 sec    Verify gNB Does Not Respond
    gnbbbu.bts_power_on
    gnbcell.wait_for_all_cells_to_be_onair    expected_cell_amount=${number_of_cells}    timeout=${BTS_startup_time}
    ...                                       interval=${30}
    Verify L3 call

General SiSo Auto Cell block and unblock with L3call
    @{all_cells_ids_randomised}    get_randomised_list_of_cells_ids
    FOR    ${cell_id}    IN    @{all_cells_ids_randomised}
        Log to console    Block and unblock cell with ID: ${cell_id}
        gnbcell.block_cell    cell_id=${cell_id}
        Wait Until Keyword Succeeds     ${cell_block_unblock_time} sec     2 sec    gnbcell.verify_cell_is_blocked    cell_id=${cell_id}
        gnbcell.unblock_cell    cell_id=${cell_id}
        Wait Until Keyword Succeeds     ${cell_block_unblock_time} sec     2 sec    gnbcell.verify_cell_is_unblocked    cell_id=${cell_id}
        Log to console    Block and unblock cell with ID: ${cell_id} - operation finished successfully.
    END
    Verify L3 call

Manual SiSo SM NR cell lock unlock administrative state change from GUI
    @{all_cells_ids_randomised}    get_randomised_list_of_cells_ids
    FOR    ${cell_id}    IN    @{all_cells_ids_randomised}
        Log to console    Lock and unlock cell with ID: ${cell_id}
        gnbcell.lock_cell    cell_id=${cell_id}    administrative_state=${True}
        Wait Until Keyword Succeeds     ${cell_lock_unlock_time} sec     2 sec    gnbcell.verify_cell_is_locked    cell_id=${cell_id}
        gnbcell.unlock_cell    cell_id=${cell_id}    administrative_state=${True}
        Wait Until Keyword Succeeds     ${cell_lock_unlock_time} sec     2 sec    gnbcell.verify_cell_is_unlocked    cell_id=${cell_id}
        Log to console    Lock and unlock cell with ID: ${cell_id} - operation finished successfully.
    END
    Verify L3 call

General SiSo Auto Online Cell Addition Deletion with L3call
    ${random_cell}    get_random_value_from_list    list_of_items=${cells_to_delete_mapping}
    Online Cell addition deletion    cell_id_to_delete=${random_cell}[cell_id_to_delete]
    ...    cell_id_to_copy_from=${random_cell}[cell_id_to_copy_from]
    ...    cell_group_id_to_delete=${random_cell}[cell_group_id_to_delete]
    ...    tput_dl=${tput_dl}    tput_ul=${tput_ul}    tput_dl_without_cell=${tput_dl_without_cell}
    ...    tput_ul_without_cell=${tput_ul_without_cell}
    ...    capabilities=${capabilities}    duration=${duration}    ue_alias=${alias}    protocol=${protocol}
    ...    require_ue=${True}    deviation=${None}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_client_ul=${buffer_client_ul}    buffer_server_dl=${buffer_server_dl}     buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    linux_congestion_dl=${linux_congestion_dl}
