*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB010706


Resource    ./Resources/CB010706_common_keywords.robot
Library     ./Resources/CB010706_common_keywords.py
Variables   ./Resources/CB010706_modify_para.py


Suite Setup       CB010706 Suite Setup
#Suite Teardown    CB010706 Suite Teardown

*** Test Cases ***
[1]CB010706-G-RRM-02_LF_NT_enable_CA_with_L3_call
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    LTE UE Start Traffic And Check Tp    ul_throughput=35    dl_throughput=200    list_length=${60}    protocol=tcp    log_time=2min
    Xiaomi Start Traffic And Check Tp    ul_throughput=100    dl_throughput=1000    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=60s
    recovery IWK
    [Teardown]    Case Teardown

[1]CB010706-G-SISO-08_LF_NT_different_bwp_mixed_with_RF_lock_unlock
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    Modify Parameter And Check BTS Status    input_list=${gnb_para1}    bts_host=${gnb_ip}
    LTE UE Start Traffic And Check Tp    ul_throughput=15    dl_throughput=90    list_length=${60}    protocol=tcp    log_time=2min
    Xiaomi Start Traffic And Check Tp    ul_throughput=100    dl_throughput=1000    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=60s
    recovery IWK
    [Teardown]    Case8 Teardown

[1]CB010706-G-SISO-09_LF_NT_Cell_block_unblock_with_L3_call
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup    if_activate_scf=${True}
    ${checked_cell_list}    create list    17
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM
    ...    dl_cell_list=${checked_cell_list}    ul_cell_list=${checked_cell_list}    UL_Rank=${2}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block And Unblock All Cell
    LTE UE Start Traffic And Check Tp    ul_throughput=65    dl_throughput=370    list_length=${60}    protocol=tcp    log_time=2min
    Xiaomi Start Traffic And Check Tp    ul_throughput=${expect_ul_tp}    dl_throughput=${expect_dl_tp}
    ...    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${1}    target_avg_percent=0.98    log_time=300s    min_percent=0.85
    recovery IWK
    [Teardown]    Case Teardown

[1]CB010706-G-SISO-03_LF_supercell_NT_100M_with_L3_call
    [Tags]  CRT_TRUNK
    Case Setup    scf_name=_mix    bts_host=${gnb_ip}    if_activate_scf=${True}
    LTE UE Start Traffic And Check Tp    ul_throughput=35    dl_throughput=90    list_length=${60}    protocol=tcp    log_time=2min
    Xiaomi Start Traffic And Check Tp    ul_throughput=100    dl_throughput=1000    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=60s
    recovery IWK
    [Teardown]    Run Keywords    Case Teardown    AND    CB010706 Suite Teardown
