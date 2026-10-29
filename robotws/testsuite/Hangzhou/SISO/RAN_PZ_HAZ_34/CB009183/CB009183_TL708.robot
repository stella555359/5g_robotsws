*** Settings ***
Documentation
...    author: Zhang Ruizhi
...    contact: ruizhi.zhang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009183


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009183/Resources/CB009183_common_keywords.robot
Library     ./Resources/CB009183_common_keywords.py
Variables   ./Resources/CB009183_modify_para.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog


Suite Setup       CB009183 Suite Setup
Suite Teardown       robot_common_operations.Common Suite Teardown

*** Test Cases ***
[1]CB009183-SR-A_004_General_SiSo_RF_module_Web_reset_and_power_reset
    [Documentation]
    ...    covered by the CB012510-SR-B_004_General_SiSo_RF_module_Web_reset_and_power_reset
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
#    Input SCF    scf_name=_A
#    Check GNB on air    bts_host=${gnb_ip}
#    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
#    AlarmWatchdog.add_allow_alarms    fault_id=10
#    AlarmWatchdog.add_allow_alarms    fault_id=4589
#    AlarmWatchdog.add_allow_alarms    fault_id=1815
#    Reset TDD/FDD RMOD    RU1_index=${2}     RU2_index=${4}     RU3_index=${9}
#    Check GNB on air    bts_host=${gnb_ip}
#    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
#    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    list_length=${90}    protocol=tcp    log_time=1min
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=60s
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${2}    target_avg_percent=1    log_time=60s
#    Power OFF/ON TDD/FDD RMOD
#    Check GNB on air    bts_host=${gnb_ip}
#    AlarmWatchdog.remove_allow_alarms    fault_id=10
#    AlarmWatchdog.remove_allow_alarms    fault_id=4589
#    AlarmWatchdog.remove_allow_alarms    fault_id=1815
#    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
#    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    list_length=${90}    protocol=tcp    log_time=1min
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=60s
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=20    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${2}    target_avg_percent=1    log_time=60s
    log to console         pass
    Recovery TMOconfiguration
    [Teardown]    Case Teardown

[1]CB009183-SR-A_007_General_SiSo_SBTS_reset_without_HWF_in_loop
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    Input SCF    scf_name=_A
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    ${checked_TDD_cell_list}    create list    17
    ${TDD_expect_ul_tp}    ${TDD_expect_dl_tp}    Get Theoretical TP From NRDIM    scf_name=_A
    ...    dl_cell_list=${checked_TDD_cell_list}    ul_cell_list=${checked_TDD_cell_list}    UL_Rank=${1}
    Reset without HWF
    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=200    list_length=${90}    protocol=tcp    log_time=2min
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=90s
    UE Attach GET 172 IP And Check TP    ul_throughput=${TDD_expect_ul_tp}    dl_throughput=${TDD_expect_dl_tp}
    ...    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${2}    target_avg_percent=0.98    log_time=300s    min_percent=0.85
    recovery SWCONFIG
    Recovery TMOconfiguration
    [Teardown]    Case Teardown

[1]CB009183-SR-B_008_Manual_SiSo_SM_BTS_Block_Site
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    Input SCF    scf_name=_B
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
#    block site and check the expected alarm
    Recovery TMOconfiguration
    [Teardown]    Case Teardown

[1]CB009183-SR-C_001_L3_call_on_M2_configuration_for_tri-mode_LTE_FDD_normal_cell
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    Input SCF    scf_name=_C
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    ${checked_TDD_cell_list}    create list    17
    ${TDD_expect_ul_tp}    ${TDD_expect_dl_tp}    Get Theoretical TP From NRDIM    scf_name=_C
    ...    dl_cell_list=${checked_TDD_cell_list}    ul_cell_list=${checked_TDD_cell_list}    UL_Rank=${1}
    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=200    list_length=${90}    protocol=tcp    log_time=2min
#    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=200    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
#    ...    protocol=tcp    ue_index=${1}    target_avg_percent=1    log_time=90s
    UE Attach GET 172 IP And Check TP    ul_throughput=${TDD_expect_ul_tp}    dl_throughput=${TDD_expect_dl_tp}
    ...    ul_list=${NR_cell_id_list}    dl_list=${NR_cell_id_list}
    ...    protocol=tcp    ue_index=${2}    target_avg_percent=0.98    log_time=300s    min_percent=0.85
    Recovery TMOconfiguration
    [Teardown]    Case Teardown

[1]CB009183-SR-C_008_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]  CRT_TRUNK
    [Setup]  Case Setup
    Reset gnb
    Check GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}
    Recovery TMOconfiguration
    [Teardown]    Case Teardown

[1][1.0] CB009181-SR-B_009_SiSo_RF_module_Web_reset_and_power_reset
    [Tags]  CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup
#     Should Be Equal As Strings  ${PREV_TEST_STATUS}  PASS
     Log To Console      PASS
    [Teardown]      Case Teardown
