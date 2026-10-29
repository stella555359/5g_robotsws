*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia-sbell.com
...    squad group: VRF3_SG04
...    feature : CB009183


Resource    ./Resources/CB009183_TL709_common_keywords.robot
Resource    ./Resources/Modify_SCF.robot
Library     ./Resources/CB009183_TL709_common_keywords.py
Variables   ./Resources/CB009183_TL709_modify_para.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog


Suite Setup       CB009183 Suite Setup
Suite Teardown

*** Test Cases ***
[1]CB009183-SR-A_001_L3_call_on_M1-L_configuration_for_tri-mode_LTE_FDD_normal_cell
    [Tags]  CIT_TRUNK
    [Setup]  Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    LTE Block Cell And Check Status    operate_cell_id=${2}    keep_cell_id=${6}    block_flag=${True}
#    Set UE related variable
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    [Teardown]   Case Teardown


[1]CB009183-SR-B_001_L3_call_on_M1-N_configuration_for_tri-mode_LTE_FDD_normal_cell
    [Tags]  CIT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=49
    Demo A to B    new_scf_path=${output_dir}/new2.xml
    Case Setup    scf_path=${output_dir}/new2.xml    bts_host=${gnb_ip}    if_activate_scf=${True}
#    Set UE related variable
    AlarmWatchdog.add_allow_alarms    fault_id=49
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]   Case Teardown


[1]CB009183-SR-B_003_General_SiSo_RU_lock_and_unlock
    [Tags]  CIT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=49
    Demo A to B    new_scf_path=${output_dir}/new2.xml
    Case Setup    scf_path=${output_dir}/new2.xml    bts_host=${gnb_ip}    if_activate_scf=${True}  
    @{lock_ru_id_list1}    create list    ${4}    ${8}    ${9}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=11157
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}    lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=11157
    Check GNB on air and Check Alarm List on BTS
#    Set UE related variable
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case Teardown


[1]CB009183-SR-B_006_General_SiSo_RAT_reset_with_L3call
    [Tags]  CIT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=49
    Demo A to B    new_scf_path=${output_dir}/new2.xml
    Case Setup    scf_path=${output_dir}/new2.xml    bts_host=${gnb_ip}    if_activate_scf=${True}
    NR RAT Reset
    LTE RAT Reset
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    Set UE related variable
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case Teardown


[1]CB009183-SR-C_004_General_SiSo_Cell_block_and_unbloc
    [Tags]  CIT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=49
    Demo A to C    new_scf_path=${output_dir}/new1.xml
    Case Setup    scf_path=${output_dir}/new1.xml    bts_host=${gnb_ip}    if_activate_scf=${True}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block And Unblock All Cell
#    Set UE related variable
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case Teardown


[1]CB009183-SR-C_006_General_SiSo_RAT_reset_with_L3call
    [Tags]  CIT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=49
    Demo A to C    new_scf_path=${output_dir}/new1.xml
    Case Setup    scf_path=${output_dir}/new1.xml    bts_host=${gnb_ip}    if_activate_scf=${True}
    LTE RAT Reset
    NR RAT Reset
    AlarmWatchdog.add_allow_alarms    fault_id=49
#    Set UE related variable
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrtdd}    dl_list=${NR_cell_id_list_nrtdd}
    ...    protocol=udp    ue_index=${0}    target_avg_percent=0.9    log_time=60s
    UE Start Traffic And Check Tp    ul_throughput=20    dl_throughput=140    ul_list=${NR_cell_id_list_nrfdd}    dl_list=${NR_cell_id_list_nrfdd}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    [Teardown]    Case Teardown


*** Keywords ***
