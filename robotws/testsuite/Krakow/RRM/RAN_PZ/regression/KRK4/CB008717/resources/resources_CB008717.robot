*** Settings ***
Documentation   kw to run CB008717

Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnb_cell
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    gnb_bts
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    gnb_scf
Library    taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnb_counters
Library    taf.ue    WITH NAME    tafue

*** Keywords ***
require_ue
    tafue.Require Ue    ue_alias=UE_1    capabilities=ANDROID_UE_1

attach_ue
    tafue.Attach Ue    ue_alias=UE_1

detach_ue
    tafue.Detach Ue    ue_alias=UE_1

turn_on_mobile_data
    tafue.turn_mobile_data_on    UE_1

turn_off_mobile_data
    tafue.turn_mobile_data_off    UE_1

start_stop_and_verify_data_transfer
    [Arguments]     ${dt_1}=DT_1
    ...             ${dt_2}=DT_2
    ...             ${ul_tp}=50Mbits/sec
    ...             ${dl_tp}=300Mbits/sec
    ...             ${data_transfer_duration}=30
    ...             ${require_ue}=${True}
    start_data_transfer    data_transfer_duration=${data_transfer_duration}    require_ue=${require_ue}
    tafue.Stop Data Transfer    ${dt_1}
    tafue.Stop Data Transfer    ${dt_2}
    tafue.Verify Average Throughput With Deviation    ${dt_1}    ${ul_tp}    90%
    tafue.Verify Average Throughput With Deviation    ${dt_2}    ${dl_tp}    90%
    Sleep    30
    detach_ue
    Sleep    30


Start Stop and Verify Data Transfer with Turn Off Mobile Data
    [Arguments]     ${dt_1}=DT_1
    ...             ${dt_2}=DT_2
    ...             ${ul_tp}=50Mbits/sec
    ...             ${dl_tp}=300Mbits/sec
    ...             ${data_transfer_duration}=120
    ...             ${require_ue}=${True}
    require_ue
    Sleep    5
    attach_ue
    tafue.Log Ue Info    UE_1
    tafue.Start Data Transfer     ${dt_1}    UE_1    UL    throughput=${ul_tp}    protocol=udp    packet=1380    apn=5gsakrk2
    tafue.Start Data Transfer     ${dt_2}    UE_1    DL    throughput=${dl_tp}    protocol=udp    packet=1380    apn=5gsakrk2
    Sleep    ${data_transfer_duration}
    tafue.Stop Data Transfer    ${dt_1}
    tafue.Stop Data Transfer    ${dt_2}
    tafue.turn_mobile_data_off    UE_1
    Sleep    ${data_transfer_duration}
    tafue.Verify Average Throughput With Deviation    ${dt_1}    ${ul_tp}    90%
    tafue.Verify Average Throughput With Deviation    ${dt_2}    ${dl_tp}    90%
    Sleep    120

start_data_transfer
    [Arguments]     ${dt_1}=DT_1
    ...             ${dt_2}=DT_2
    ...             ${ul_tp}=50Mbits/sec
    ...             ${dl_tp}=300Mbits/sec
    ...             ${data_transfer_duration}=30
    ...             ${require_ue}=${True}
    Run Keyword If    ${require_ue}    require_ue
    Sleep    20
    attach_ue
    tafue.Log Ue Info    UE_1
    tafue.Start Data Transfer     ${dt_1}    UE_1    UL    throughput=${ul_tp}    protocol=udp    packet=1380    apn=5gsakrk2
    sleep    10
    tafue.Start Data Transfer     ${dt_2}    UE_1    DL    throughput=${dl_tp}    protocol=udp    packet=1380    apn=5gsakrk2
    Sleep     ${data_transfer_duration}

stop_data_transfer
    [Arguments]     ${dt_1}=DT_1
    ...             ${dt_2}=DT_2
    ...             ${ul_tp}=50Mbits/sec
    ...             ${dl_tp}=300Mbits/sec
    ...             ${tput_deviation}=100%
    ...             ${def_sleep}=30
    tafue.Stop Data Transfer    ${dt_1}
    tafue.Stop Data Transfer    ${dt_2}
    Sleep    ${def_sleep}
    tafue.Verify Average Throughput With Deviation    ${dt_1}    ${ul_tp}    ${tput_deviation}
    tafue.Verify Average Throughput With Deviation    ${dt_2}    ${dl_tp}    ${tput_deviation}
    detach_ue
    Sleep    30

stop_data_transfer_without_verification
    [Arguments]     ${dt_1}=DT_1
    ...             ${dt_2}=DT_2
    run keyword and ignore error    tafue.Stop Data Transfer    ${dt_1}
    run keyword and ignore error    tafue.Stop Data Transfer    ${dt_2}

block_cell
    [Arguments]    ${cell_id}
    gnb_cell.block_cell    cell_id=${cell_id}
    gnb_cell.verify_cell_is_blocked    cell_id=${cell_id}

unblock_cell
    [Arguments]    ${cell_id}
    gnb_cell.unblock_cell    cell_id=${cell_id}
    gnb_cell.verify_cell_is_unblocked    cell_id=${cell_id}

verify_BTS_and_cells
    gnb_bts.verify_bts_is_onair
    gnb_cell.verify_all_cells_statuses    cell_type=nr
    ...                                   administrative_state=Unlocked
    ...                                   blocking_state=Unblocked
    ...                                   operational_state=enabled

perform_site_reset
    gnb_bts.reset_bts

modify_parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    gnb_scf.perform_configuration_parameter_recommissioning     dist_name=${dist_name}
    ...                                                         parameter=${parameter}
    ...                                                         operation=update
    ...                                                         value=${value}
    ...                                                         should_activate=${True}
    ...                                                         skip_parameter_relation_errors=${True}
    ...                                                         timeout=180

get_counter_value
    [Arguments]    ${counter_id}
#    gnb_counters.get_pm_counters_file    local_path=${OUTPUT_DIR}/lolek123
    ${counter_value}    gnb_counters.get_counter    counter_id=${counter_id}    timeout=300
    [Return]    ${counter_value}
#    ...                         network_element_dist_name=${dist_name}
