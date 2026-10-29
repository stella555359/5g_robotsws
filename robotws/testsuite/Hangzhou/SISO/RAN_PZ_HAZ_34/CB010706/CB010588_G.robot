*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB010706


Resource    ./Resources/CB010706_common_keywords.robot
Library     ./Resources/CB010706_common_keywords.py
Variables   ./Resources/CB010706_modify_para.py


Suite Setup       CB010588 Suite Setup
Suite Teardown    robot_common_operations.Common suite teardown

*** Test Cases ***
[1]CB010706-E-RRM-03_mix_super_normall_with_CA_VONR
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common case Setup
    Download Current BTS SCF To UTE    scf_name=peak_scf.xml
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=4476
    ${checked_cell_list}    create list    5
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM_725    scf_name=peak_scf.xml
    ...    dl_cell_list=${checked_cell_list}    ul_cell_list=${checked_cell_list}
    Block Cell And Check Status    operate_cell_id=${11}    keep_cell_id=${5}    block_flag=${True}
    sleep    90s
    MTK90 Attach By Power UE And Start Traffic And Check TP    ul_throughput=${expect_ul_tp}    dl_throughput=${expect_dl_tp}
    ...    ul_list=${10588_cell_list[0:1]}    dl_list=${10588_cell_list[0:1]}    ue_index=${0}
    ...    target_avg_percent=0.98    log_time=300s    min_percent=0.85    ignore_time=90s    check_tput=${False}
#    Make a VoNR call(+6688)    ue_index=${0}
    run keyword and continue on failure    Check Throught From Asslog   ul_list=${10588_cell_list[0:1]}    dl_list=${10588_cell_list[0:1]}
    ...    ul_tp=${expect_ul_tp}    dl_tp=${expect_dl_tp}    if_ul=${True}   if_dl=${True}
    ...    target_avg_percent=0.98    min_percent=0.85    log_time=300s    ignore_time=90s
    MTK90 Stop Traffic And Detach UE    ue_index=${0}    if_ul=${True}    if_dl=${True}    protocol=udp
    Block Cell And Check Status    operate_cell_id=${11}    keep_cell_id=${5}    block_flag=${False}
    [Teardown]  Case Teardown


[1]CB010588-G-SISO-01_Full_ABIQ_mix_supercell_normallcell_site_reset_by_WEBEM_with_L3call
    [Tags]  CRT_TRUNK
    [Setup]  robot_common_operations.Common case Setup
    Reset Site And Check BTS Status    bts_host=${gnb_ip}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=4476
#    Block Cell And Check Status    operate_cell_id=${11}    keep_cell_id=${5}    block_flag=${True}
#    sleep    120s
#    MTK90 Attach By Power UE And Check TP    ul_throughput=100    dl_throughput=100    ul_list=${10588_cell_list[0:1]}
#    ...    dl_list=${10588_cell_list[0:1]}    protocol=udp    ue_index=${0}    target_avg_percent=1    log_time=120s
#    Block Cell And Check Status    operate_cell_id=${11}    keep_cell_id=${5}    block_flag=${False}
    Block Cell And Check Status    operate_cell_id=${5}    keep_cell_id=${11}    block_flag=${True}
    MTK90 Attach By Power UE And Check TP    ul_throughput=100    dl_throughput=100    ul_list=${10588_cell_list[-1:-2:-1]}
    ...    dl_list=${10588_cell_list[-1:-2:-1]}    protocol=udp    ue_index=${0}    target_avg_percent=1    log_time=120s
    Block Cell And Check Status    operate_cell_id=${5}    keep_cell_id=${11}    block_flag=${False}
    [Teardown]  Case Teardown
