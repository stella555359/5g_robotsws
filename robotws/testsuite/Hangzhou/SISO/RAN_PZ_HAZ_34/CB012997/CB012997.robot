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

Suite Setup       CB012997 Suit Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


*** Test Cases ***
#  CB012997_SR_A--705
[1]CB012997_SR_A_02_General_SiSo_Cell_block_and_unblock
    [Documentation]    AQQL cell4
    [Setup]    Case Setup
    BLock or UnBlock Cell And Check Status    block_flag=${True}    block_cell_id_list=${T705_all_cell_list}    allowed_list=${allowed_list2}
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[-1:]}    all_cells_list=${T705_all_cell_list}    log_time=60s
    ...    block_flag=${False}    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[-1:]}    exp_ul_tp=4    exp_dl_tp=35
    ...    if_ul=${False}
    [Teardown]    Case Teardown

[1]CB012997_SR_A_03_BTS_Site_Reset_without_HWF_deletion
    [Documentation]    AQQL cell4
    [Setup]    Case Setup
 #  ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
 #  Modify Swconfig File   para_update=${swconfig_list}    bts_host=${gNB_ip}
    Save Snapshot    bts_host=${gNB_ip}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Reset Station And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[-1:]}    all_cells_list=${T705_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[-1:]}    exp_ul_tp=4   exp_dl_tp=35    log_time=60s
    [Teardown]    Case Teardown

[1]CB012997_SR_A_04_General_SiSo_RU_module_reset_from_GUI_and_Power_off_on
    [Documentation]    AQQY cell4
    [Setup]    Case Setup
    Reset RF Module And Check On Air    bts_host=${gNB_ip}    RMOD_index_list=${RF_index_list[0:1]}    allowed_list=${allowed_list1}
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[3:4]}    all_cells_list=${T705_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[1:2]}    exp_ul_tp=4   exp_dl_tp=35    log_time=60s
    [Teardown]    Case Teardown

####  CB012997_SR_B--705
[1]CB012997_SR_B_02_General_SiSo_Cell_block_and_unblock
    [Documentation]    AQQL cell3
    [Setup]    Case Setup
    BLock or UnBlock Cell And Check Status    block_flag=${True}    block_cell_id_list=${T705_all_cell_list}    allowed_list=${allowed_list2}
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[6:7]}    all_cells_list=${T705_all_cell_list}    log_time=60s
    ...    block_flag=${False}    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[2:3]}    exp_ul_tp=8    exp_dl_tp=56
    ...    if_ul=${False}
    [Teardown]    Case Teardown

[1]CB012997_SR_B_03_BTS_Site_Reset_without_HWF_deletion
    [Documentation]    AQQL cell3
    [Setup]    Case Setup
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File   para_update=${swconfig_list}    bts_host=${gNB_ip}
    Save Snapshot    bts_host=${gNB_ip}
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Reset Station And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[6:7]}    all_cells_list=${T705_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[2:3]}    exp_ul_tp=8   exp_dl_tp=56    log_time=60s
    [Teardown]    Case Teardown

[1]CB012997_SR_B_04_General_SiSo_RU_module_reset_from_GUI_and_Power_off_on
    [Documentation]    AQQL cell3
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Reset PDU And Check On Air    model=TopYoung    PDU_IP=${AQQL_PDU_ip}    PDU_PORT=${AQQL_PDU_port}    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_list1}    sleep_time=1min
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[6:7]}    all_cells_list=${T705_all_cell_list}   if_ul=${False}
    ...    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[2:3]}    exp_ul_tp=8   exp_dl_tp=56    log_time=60s
    [Teardown]    Case Teardown

#####  CB012997_SR_D--705
#[1]CB012997_SR_D_01_L3Call_setup_with_data_transfer_conducted_when_mixed_BW_100MHz_50MHz_10MHz_10MHz_CA
#    [Documentation]    AQQY cell3 15M-->10M, test AQQY cell3 cell4, peak can't reach
#    [Setup]    Case Setup
#    Modify Parameter And Wait On Air    input_list=${D_case1_para}    bts_host=${gNB_ip}
##    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM
##    ...    dl_cell_list=${T705_all_cell_list[2:4]}    ul_cell_list=${T705_all_cell_list[2:4]}    UL_Rank=${2}
#    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[2:4]}    all_cells_list=${T705_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list[-1:]}    nr_cell_list=${T705_all_nr_cell_list[0:2]}    exp_ul_tp=8   exp_dl_tp=205    log_time=120s
#    [Teardown]    Run Keywords    Modify Parameter And Wait On Air    input_list=${D_case1_para_recover}    bts_host=${gNB_ip}    AND
#    ...    Case Teardown
#
#[1]CB012997_SR_D_13_General_SiSo_SW_upgrade_rollback_with_mixed_BW_100MHz_50MHz_15MHz_10MHz
#    [Documentation]    Software upgrade and rollback three times, AQQY cell4
#    [Setup]    Case Setup
#    ${branch_version}    ${software}    Get BTS ActiveVersion    bts_host=${gNB_ip}
#    FOR    ${i}   IN RANGE    ${3}
#        Save Snapshot    bts_host=${gNB_ip}
#        Classical gNB Rollback And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}
#        Save Snapshot    bts_host=${gNB_ip}
#        Classical gNB Upgraded And Check On Air    bts_host=${gNB_ip}    allowed_list=${allowed_list1}    target_version=${software}
#        ...    SW_build_path=/home/ute/${branch_version}
#    END
#    Block Cell And Start Traffic    excpet_element_list=${T705_all_cell_list[3:4]}    all_cells_list=${T705_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list[0:1]}    nr_cell_list=${T705_all_nr_cell_list[1:2]}    exp_ul_tp=4    exp_dl_tp=35    log_time=60s
#    [Teardown]    Case Teardown
#
###  CB012997_SR_C--706
#[1]CB012997_SR_C_01_L3Call_setup_with_data_transfer_conducted_when_mixed_BW_100MHz_15MHz_10MHz
#    [Documentation]    AQQY 10M, AQQL 15M,peak
#    [Setup]    T719 Case Setup
#    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[0:1]}    all_cells_list=${T719_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[0:1]}    exp_ul_tp=10    exp_dl_tp=110    log_time=180s
#    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
#
#    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[1:2]}    all_cells_list=${T719_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[1:2]}    exp_ul_tp=20    exp_dl_tp=130    log_time=180s
#    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
#    [Teardown]    Case Teardown
#
#[1]CB012997_SR_C_06_General_SiSo_Online_Cell_Addition_Deletion_when_mixed_BW_100MHz_15MHz_10MHz
#    [Documentation]    AQQL 10M cell，AQQY 15M cell
#    [Setup]    T719 Case Setup
#    @{cell_id_list}    Create List    5    6
#    ${output_list}    Add Element To List    input_list=${T719_all_cell_list}    excpet_element_list=${cell_id_list}
#    Add Or Delete Cell And Check On air    if_add=${False}    bts_host=${gNB_ip}   BTS_ID=${TL_BTS_ID}    expect_cell_list=${output_list}
#    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cell_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${TL_NRBTS_ID}
#    sleep  1min
#    Add Or Delete Cell And Check On air    if_add=${True}    bts_host=${gNB_ip}   BTS_ID=${TL_BTS_ID}    expect_cell_list=${T719_all_cell_list}
#    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${cell_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${TL_NRBTS_ID}
#    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[0:1]}    all_cells_list=${T719_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[0:1]}    exp_ul_tp=10    exp_dl_tp=100    log_time=60s
#    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
#    Block Cell And Start Traffic    excpet_element_list=${T719_all_cell_list[1:2]}    all_cells_list=${T719_all_cell_list}
#    ...    ul_tp_list=${ul_traffic_list}    nr_cell_list=${T719_all_nr_cell_list[1:2]}    exp_ul_tp=20    exp_dl_tp=130    log_time=60s
#    ...    multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}
#    [Teardown]    Case Teardown

