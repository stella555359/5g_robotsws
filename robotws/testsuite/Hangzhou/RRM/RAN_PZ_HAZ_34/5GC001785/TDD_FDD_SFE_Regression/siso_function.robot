*** Settings ***
Documentation    Author: Ming Shi
...              Contact: ming.shi@nokia-sbell.com
...    This is a test suite for the login page
...    RF block/unblock , cell block/unblock , BBU reset,gNB reset,cell reset, gnb block/unblock, reset, RF reset

Suite Setup

Suite Teardown

Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/uuf_common_keywords.py
Library    uuf_common_keywords.OperateGnb    WITH NAME    OperateGnb

*** Variables ***
${connection_name}    GNB_OAM
${epc_log_path}    /tmp/
${scf_file_path}    /opt/workspace/CRT/Master/SCF_file/
${snapshot_path}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_file}    gNB1_Golden_SCF.xml
@{gnb_index_list}    ${0}
@{scf_file_list}    gNB1_Golden_SCF.xml

*** Test Cases ***
[1]block_unblock_all_cells_case
    [Timeout]    1 hour
    [Setup]
    OperateGnb.block_unblock_all_cells_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=block_unblock_all_cells_snapshot_gnb

[1]block_unblock_per_cell_case
    [Timeout]    1 hour
    [Setup]
    OperateGnb.block_unblock_per_cell_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=block_unblock_per_cell_snapshot_gnb

[1]block_unblock_bts_case
    [Timeout]    2 hours
    [Setup]
    OperateGnb.block_unblock_bts_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=block_unblock_bts_snapshot_gnb

[1]lock_unlock_per_cell_case
    [Timeout]    1 hour
    [Setup]
    OperateGnb.lock_unlock_per_cell_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=lock_unlock_per_cell_snapshot_gnb

[1]block_unblock_rat_case
    [Timeout]    2 hours
    [Setup]
    OperateGnb.block_unblock_rat_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=block_unblock_rat_snapshot_gnb

[1]lock_unlock_BBMOD_case
    [Timeout]    2 hours
    [Setup]
    OperateGnb.lock_unlock_bbmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=lock_unlock_bbmod_snapshot_gnb

[1]lock_unlock_RMOD_case
    [Timeout]    2 hours
    [Setup]
    OperateGnb.lock_unlock_rmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=lock_unlock_rmod_snapshot_gnb

[1]power_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.power_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=power_reset_snapshot_gnb

[1]site_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.site_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=site_reset_snapshot_gnb

[1]reset_all_cells_case
    [Timeout]    1 hour
    [Setup]
    OperateGnb.reset_all_cells_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=reset_all_cells_snapshot_gnb

[1]reset_per_cell_case
    [Timeout]    1 hour
    [Setup]
    OperateGnb.reset_per_cell_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=reset_per_cell_snapshot_gnb

[1]soft_rat_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.soft_rat_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=soft_rat_reset_snapshot_gnb

[1]hard_rat_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.hard_rat_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=hard_rat_reset_snapshot_gnb

[1]reset_site_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.reset_site_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=reset_site_snapshot_gnb

[1]warm_reset_BBMOD_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.warm_reset_bbmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=warm_reset_bbmod_snapshot_gnb

[1]warm_reset_BBMOD_with_force_radio_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.warm_reset_bbmod_with_force_radio_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=warm_reset_bbmod_with_force_radio_reset_snapshot_gnb

[1]hard_reset_BBMOD_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.hard_reset_bbmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=hard_reset_bbmod_snapshot_gnb

[1]hard_reset_BBMOD_with_force_radio_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.hard_reset_bbmod_with_force_radio_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=hard_reset_BBMOD_with_force_radio_reset_snapshot_gnb

[1]warm_reset_GNSSE_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.warm_reset_gnsse_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=warm_reset_gnsse_snapshot_gnb

[1]hard_reset_GNSSE_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.hard_reset_gnsse_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=hard_reset_gnsse_snapshot_gnb

[1]soft_reset_RMOD_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.soft_reset_rmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=soft_reset_rmod_snapshot_gnb

[1]hard_reset_RMOD_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.hard_reset_rmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=hard_reset_rmod_snapshot_gnb

[1]warm_reset_RMOD_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.warm_reset_rmod_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=warm_reset_rmod_snapshot_gnb

[1]commissioning_reset_case
    [Timeout]    5 hours
    [Setup]
    OperateGnb.commissioning_reset_threading    index_list=@{gnb_index_list}    local_dir_path=${snapshot_path}
    ...    snapshot_name=commissioning_reset_snapshot_gnb    scf_file=@{scf_file_list}
