*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...         throughput_computation

Variables   ./Resources/TLConfigration_12997.py
Resource    ./Resources/CB012997_common_keywords.robot

Suite Setup       T719 Suit Setup
Suite Teardown    T719 Suit Teardown
Test Timeout      24 hours




*** Test Cases ***
#  CB012997_SR_A--705
[1][1.0] CB012997_SR_A_02_General_SiSo_Cell_block_and_unblock
    [Documentation]    AQQL cell4--10M
    [Setup]    Case Setup
    BLock or UnBlock Cell And Check Status    block_flag=${True}    block_cell_id_list=${T719_all_cell_list}    allowed_list=${allowed_list2}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[4:5]}    all_cells_list=${T719_all_cell_list}    log_time=60s
    ...    block_flag=${False}    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[4:5]}    exp_ul_tp=4    exp_dl_tp=35
    ...    if_ul=${False}    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

[1][1.0] CB012997_SR_A_03_BTS_Site_Reset_without_HWF_deletion
    [Documentation]    AQQL cell4--10M
    [Setup]    Case Setup
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File   para_update=${swconfig_list}    bts_host=${gNB_ip}
    Save Snapshot    bts_host=${gNB_ip}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Reset Station And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[4:5]}    all_cells_list=${T719_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[4:5]}    exp_ul_tp=4   exp_dl_tp=35    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

[1][1.0] CB012997_SR_A_04_General_SiSo_RU_module_reset_from_GUI_and_Power_off_on
    [Documentation]    AQQY cell4--10M， AQQY reset
    [Setup]    Case Setup
    Reset RF Module And Check On Air    bts_host=${gNB_ip}    RMOD_index_list=${T719_RF_index_list[-1:]}    allowed_list=${allowed_list1}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[3:4]}    all_cells_list=${T719_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[3:4]}    exp_ul_tp=4   exp_dl_tp=35    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

####  CB012997_SR_B--705
[1][1.0] CB012997_SR_B_02_General_SiSo_Cell_block_and_unblock
    [Documentation]    AQQL cell3--15M
    [Setup]    Case Setup
    BLock or UnBlock Cell And Check Status    block_flag=${True}    block_cell_id_list=${T719_all_cell_list}    allowed_list=${allowed_list2}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[-1:]}    all_cells_list=${T719_all_cell_list}    log_time=60s
    ...    block_flag=${False}    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[-1:]}    exp_ul_tp=8    exp_dl_tp=56
    ...    if_ul=${False}    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

[1][1.0] CB012997_SR_B_03_BTS_Site_Reset_without_HWF_deletion
    [Documentation]    AQQL cell3--15M
    [Setup]    Case Setup
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File   para_update=${swconfig_list}    bts_host=${gNB_ip}
    Save Snapshot    bts_host=${gNB_ip}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Reset Station And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[-1:]}    all_cells_list=${T719_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[-1:]}    exp_ul_tp=8   exp_dl_tp=56    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown


[1][1.0] CB012997_SR_B_04_General_SiSo_RU_module_reset_from_GUI_and_Power_off_on
    [Documentation]    AQQL cell3--15M
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Reset PDU And Check On Air    model=HBTE    PDU_IP=${AQQL_PDU_ip}    PDU_PORT=${AQQL_PDU_port}    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_list1}    sleep_time=1min
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[-1:]}    all_cells_list=${T719_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[-1:]}    exp_ul_tp=8   exp_dl_tp=56    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

#####  CB012997_SR_D--705
[1][1.0] CB012997_SR_D_01_L3Call_setup_with_data_transfer_conducted_when_mixed_BW_100MHz_50MHz_10MHz_10MHz_CA
    [Documentation]    AQQY cell3 15M-->10M, test AQQY cell3 cell4, peak can't reach
    [Setup]    Case Setup
#    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM
#    ...    dl_cell_list=${T719_all_cell_list[2:4]}    ul_cell_list=${T719_all_cell_list[2:4]}    UL_Rank=${2}
    Block Cell And Start Traffic    excpet_element_list=${CA_10M_cell_list}    all_cells_list=${T719_all_cell_list}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${CA_10M_nr_list}    exp_ul_tp=0   exp_dl_tp=223    log_time=120s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}

    Block Cell And Start Traffic    excpet_element_list=${CA_15M_cell_list}    all_cells_list=${T719_all_cell_list}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${CA_15M_nr_list}    exp_ul_tp=0   exp_dl_tp=352    log_time=120s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

[1]CB012997_SR_C_01_L3Call_setup_with_data_transfer_conducted_when_mixed_BW_100MHz_15MHz_10MHz
    [Documentation]    AQQY 10M, AQQL 15M,peak
    [Setup]    Case Setup
    Log to console   Success
    [Teardown]    Case Teardown

[1][1.0] CB012997_SR_D_13_General_SiSo_SW_upgrade_rollback_with_mixed_BW_100MHz_50MHz_15MHz_10MHz
    [Documentation]    Software upgrade and rollback three times, AQQY cell4--10M
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    ${branch_version}    ${software}    Get BTS ActiveVersion    bts_host=${gNB_ip}
    FOR    ${i}   IN RANGE    ${3}
        Save Snapshot    bts_host=${gNB_ip}
        Classical gNB Rollback And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
        Save Snapshot    bts_host=${gNB_ip}
        Classical gNB Upgraded And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}    target_version=${software}
        ...    SW_build_path=/home/ute/${branch_version}
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Commission CB012997 scf    scf_path=${scf_path}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[3:4]}    all_cells_list=${T719_all_cell_list}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[3:4]}    exp_ul_tp=0    exp_dl_tp=35    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

###  CB012997_SR_C--706

[1][1.0] CB012997_SR_C_06_General_SiSo_Online_Cell_Addition_Deletion_when_mixed_BW_100MHz_15MHz_10MHz
    [Documentation]    AQQL 10M cell，AQQY 15M cell
    [Setup]    Case Setup
    @{cell_id_list}    Create List    4   11
    ${output_list}    Add Element To List    input_list=${T719_all_cell_list}    excpet_element_list=${cell_id_list}
    Add Or Delete Cell And Check On air    if_add=${False}    bts_host=${gNB_ip}   BTS_ID=${TL_BTS_ID}    expect_cell_list=${output_list}
    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cell_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${TL_NRBTS_ID}
    sleep  1min
    Add Or Delete Cell And Check On air    if_add=${True}    bts_host=${gNB_ip}   BTS_ID=${TL_BTS_ID}    expect_cell_list=${T719_all_cell_list}
    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cell_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${TL_NRBTS_ID}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[4:5]}    all_cells_list=${T719_all_cell_list}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[4:5]}    exp_ul_tp=0    exp_dl_tp=100    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[1:2]}    all_cells_list=${T719_all_cell_list}
    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[1:2]}    exp_ul_tp=0    exp_dl_tp=130    log_time=60s
    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
    [Teardown]    Case Teardown

