*** Settings ***
Documentation
...    author: Zhang Ruizhi
...    contact: ruizhi.zhang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB013999


Resource    ./Resources/CB013999_common_keywords.robot
Library     ./Resources/CB013999_common_keywords.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog


Suite Setup       CB013999 Suite Setup
Suite Teardown       CB013999 Suite Teardown

*** Test Cases ***
[1]CB013999_SR_A_02_Shared_pool_of_eCPRI_Ethernet_ ports_on_full_ABIQ_General_SiSo_Commissioning
    [Setup]  Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    block all cell        NRCELL_id=${NRCELL_list1}
    unblock one cell      cell_id=0
    Xiaomi Attach By Power UE And Check TP      ue_index=${0}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[0:1]}
    ...    dl_list=${NR_cell_id_list[0:1]}      target_avg_percent=0.9     log_time=60s    tput_dl_sent=800    tput_ul_sent=140
    wait until keyword succeeds    5x   2min    unblock one cell      cell_id=14
    Xiaomi Attach By Power UE And Check TP      ue_index=${1}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[1:2]}
    ...    dl_list=${NR_cell_id_list[1:2]}      target_avg_percent=0.9     log_time=60s      tput_dl_sent=800    tput_ul_sent=140
    @{unblock_cell_id_list}    Create List    7    15    16
    FOR   ${id}   IN    @{unblock_cell_id_list}
        unblock one cell      cell_id=${id}
        sleep   5s
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case26 Teardown

[1]CB013999_SR_A_03_Shared_pool_of_eCPRI_Ethernet_ ports_on_half_ABIQ_General_SiSo_Cell_block_and_unblock
    [Setup]    robot_common_operations.Common case Setup
     Log To Console      PASS
    [Teardown]      Case26 Teardown

[1]CB013999_SR_A_07_Shared_pool_of_eCPRI_Ethernet_ ports_on_half_ABIQ_General_SiSo_RU_module_reset_from_GUI
    [Setup]  Case Setup
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    @{allow_alarm}    Create List    10    1815    4589      49
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    Reset all RMOD       RU_id=${RU_id_list}
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    Block One Cell        cell_id=15
    Block One Cell        cell_id=16
    Xiaomi Attach By Power UE And Check TP      ue_index=${1}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[1:2]}
    ...    dl_list=${NR_cell_id_list[1:2]}      target_avg_percent=0.9     log_time=60s      tput_dl_sent=800    tput_ul_sent=140
    unblock one cell      cell_id=15
    unblock one cell      cell_id=16
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    [Teardown]    Case26 Teardown


[1]CB013999_SR_A_13_Shared_pool_of_eCPRI_Ethernet_ ports_on_half_ABIQ_Manual_SiSo_CM_SFP_Lock
    [Setup]  Case Setup
    @{allow_alarm}    Create List    10    1868      49
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list}    BBMOD_id=2    lock_flag=${True}
    sleep    10s
    Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list}    BBMOD_id=2    lock_flag=${False}
    Block One Cell        cell_id=7
    sleep    5s
    Xiaomi Attach By Power UE And Check TP      ue_index=${0}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[0:1]}
    ...    dl_list=${NR_cell_id_list[0:1]}      target_avg_percent=0.9     log_time=60s    tput_dl_sent=800    tput_ul_sent=140
    unblock one cell      cell_id=7
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    [Teardown]    Case26 Teardown

[1]CB013999_SR_A_29_Shared_pool_of_eCPRI_Ethernet_ ports_on_full_ABIQ_RU_lock_unlock_scenario
    [Setup]  Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Lock all RMOD      RU_id=${RU_id_list}
    sleep     5s
    unlock all RMOD      RU_id=${RU_id_list}
    Block One Cell        cell_id=15
    Block One Cell        cell_id=16
    Xiaomi Attach By Power UE And Check TP      ue_index=${1}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[1:2]}
    ...    dl_list=${NR_cell_id_list[1:2]}      target_avg_percent=0.9     log_time=60s      tput_dl_sent=800    tput_ul_sent=140
    unblock one cell      cell_id=15
    unblock one cell      cell_id=16
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    [Teardown]    Case26 Teardown

[1][1.0] CB013999_SR_A_09_Shared_pool_of_eCPRI_Ethernet_ ports_on_half_ABIQ_General_SiSo_RU_module_reset_Power_off_on
    [Documentation]    BBMOD-3_2*50G_RMOD-2_AVQC BBOMD-2_4*25G_RMOD-4_AQQY
    [Setup]    Case Setup
    @{allow_alarm}    Create List    10    4589
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    @{power_off_on_rmod_list}    create list    4    0
    FOR    ${i}    IN    @{power_off_on_rmod_list}
        Power Off RU  model=HBTE  RU_PDU_IP=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...    RU_PDU_PORT=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        Wait until keyword succeeds     5min    10s    Power off RU and check the expected fault
        Power On RU   model=HBTE  RU_PDU_IP=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...    RU_PDU_PORT=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        Check GNB on air
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    block all cell with only one time login        NRCELL_id=${NRCELL_list1}
    unblock one cell      cell_id=0
    Xiaomi Attach By Power UE And Check TP      ue_index=${0}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[0:1]}
    ...    dl_list=${NR_cell_id_list[0:1]}      target_avg_percent=0.9     log_time=60s    tput_dl_sent=800    tput_ul_sent=140
    @{unblock_cell_id_list}    Create List    14    7    15    16
    unblock all cell with only one time login    NRCELL_id=${unblock_cell_id_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case26 Teardown

[1][1.0] CB013999_SR_A_19_Shared_pool_of_eCPRI_Ethernet_ ports_on_half_ABIQ_General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]    BBMOD-3 RMOD-2 NRCELL-16 NRCELLGRP-16 NRDU-1:refNrCellGroup 16
    [Setup]    Case Setup
    @{cell_id_list}    Create List    16
    @{nrcellgrp_id_list}    Create List    16
    Set CONF-1 Name
    ${output_list}    Add Element To List    input_list=${T720_all_cell_list}    excpet_element_list=${cell_id_list}
    Add Or Delete Cell And Check On air    if_add=${False}    bts_host=${gNB_ip}   BTS_ID=${BTS_ID}    expect_cell_list=${output_list}
    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${NRBTS}
    Add Or Delete Cell And Check On air    if_add=${True}    bts_host=${gNB_ip}   BTS_ID=${BTS_ID}    expect_cell_list=${T720_all_cell_list}
    ...     cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    allowed_list=${allowed_list1}     NRBTS_ID=${NRBTS}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    block all cell with only one time login        NRCELL_id=${NRCELL_list1}
    unblock one cell      cell_id=16
    Xiaomi Attach By Power UE And Check TP      ue_index=${1}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[2:3]}
    ...    dl_list=${NR_cell_id_list[2:3]}      target_avg_percent=0.9     log_time=60s    tput_dl_sent=800    tput_ul_sent=140
    @{unblock_cell_id_list}    Create List    0    7    14    15
    unblock all cell with only one time login    NRCELL_id=${unblock_cell_id_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case26 Teardown

[1][1.0] CB013999_SR_A_26_Shared_pool_of_eCPRI_Ethernet_ ports_on_full_ABIQ_mix_celltype_4DL4UL_8DL8U_L3call
    [Documentation]    BBMOD-3 RMOD-2 NRCELL-16 nrcelltype change from 8DL8UL to 4DL4UL
    [Setup]    Case Setup
    Log To Console    BBMOD-3 RMOD-2 NRCELL-16 nrcelltype change from 8DL8UL to 4DL4UL
    @{cell_id_list}    Create List    16
    Change Nrcells nrcelltype from 8DL8UL to 4DL4UL by WebUI   bts_host=${gNB_ip}  BTS_ID=${BTS_ID}  NRBTS_ID=${NRBTS}  cell_id_list=${cell_id_list}
    Check GNB on air
    AlarmWatchdog.add_allow_alarms    fault_id=49
    block all cell with only one time login        NRCELL_id=${NRCELL_list1}
    unblock one cell      cell_id=16
    Xiaomi Attach By Power UE And Check TP      ue_index=${1}      ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list[2:3]}
    ...    dl_list=${NR_cell_id_list[2:3]}      target_avg_percent=0.9     log_time=60s    tput_dl_sent=800    tput_ul_sent=140
    @{unblock_cell_id_list}    Create List    0    7    14    15
    unblock all cell with only one time login    NRCELL_id=${unblock_cell_id_list}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case26 Teardown


