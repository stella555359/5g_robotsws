*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB012510


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012510_TL708/Resources/CB012510_common_keywords.robot
Library     ./Resources/CB012510_common_keywords.py
Variables   ./Resources/CB012510_modify_para.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog


Suite Setup       CB012510 Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Test Cases ***
[1]CB012510-SR-B_002_L3_call_on_M4_configuration_tri_mode_concurrent_with_LTE_supercell
    [Tags]  CRT_TRUNK    CRT_25R1
    [Setup]  Case Setup
    Input new SCF    scf_name=_LTEsupercell
    3 UEs Start Peak Traffic and Check TP on LTEFDD NRFDD NRTDD concurrently
    Input new SCF    scf_name=_TMOonly5G
    [Teardown]    Case Teardown for LTE supercell new

[1]CB012510-SR-B_003_SuperCell_activation_deactivation
    [Tags]  CRT_TRUNK    CRT_25R1
    [Setup]  Case Setup
    Supercell Deactivation via Delta Commission without any unexpected behavior
    LTE UE Start Traffic And Check Tp    ul_throughput=48    dl_throughput=220    list_length=${90}    protocol=udp    log_time=1min
    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    UE Attach GET 172 IP And Check TP    ul_throughput=50    dl_throughput=1000
    ...    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${2}    target_avg_percent=0.9    log_time=60s    min_percent=0.8
    Supercell Activation via Delta Commission without any unexpected behavior
    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    list_length=${90}    protocol=udp    log_time=1min
    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    UE Attach GET 172 IP And Check TP    ul_throughput=50    dl_throughput=1000
    ...    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${2}    target_avg_percent=0.9    log_time=60s    min_percent=0.8
    Input new SCF    scf_name=_TMOonly5G
    [Teardown]    Case Teardown for supercell reconfiguration new

[1]CB012510-SR-B_004_General_SiSo_RF_module_Web_reset_and_power_reset
    [Tags]  CRT_TRUNK    CRT_25R1
    [Setup]  Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    Reset tri-mode RMOD and check no unexpected alarm    RU1_index=${12}     RU2_index=${14}     RU3_index=${19}
    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    list_length=${90}    protocol=udp    log_time=1min
    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    UE Attach GET 172 IP And Check TP    ul_throughput=50    dl_throughput=1000
    ...    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${2}    target_avg_percent=0.9    log_time=60s    min_percent=0.8
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Power OFF/ON tri-mode RMOD and check no unexpected alarm
    sleep    300s
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    LTE UE Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    list_length=${90}    protocol=udp    log_time=1min
    Xiaomi Start Traffic And Check Tp    ul_throughput=50    dl_throughput=220    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${1}    target_avg_percent=0.9    log_time=60s
    UE Attach GET 172 IP And Check TP    ul_throughput=50    dl_throughput=1000
    ...    ul_list=${NR_cell_id_list_1}    dl_list=${NR_cell_id_list_1}
    ...    protocol=udp    ue_index=${2}    target_avg_percent=0.9    log_time=60s    min_percent=0.8
    Input new SCF    scf_name=_TMOonly5G
    [Teardown]    Case Teardown

[1]CB012510-SR-B_007_General_BBMOD_reset_from_WebUI_robustness_testing
    [Tags]  CRT_TRUNK    CRT_25R1
    [Setup]  Case Setup
    Input new SCF    scf_name=${EMPTY}
    log to console    Start to reset BBMOD 5 times
    BBMOD reset in loop
    3 UEs Start Peak Traffic and Check TP on LTEFDD NRFDD NRTDD concurrently
    Input new SCF    scf_name=_TMOonly5G
    [Teardown]    Case Teardown





###################################################  END  ###############################################################







*** Keywords ***
BBMOD reset in loop
    FOR    ${ID}    IN RANGE    0    5
        Check onair and alarm
    END

Check onair and alarm
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Reset BBMOD
    Check GNB on air_debug
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Reset BBMOD
    [Arguments]      ${connection}=GNB_OAM
#    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    Reset BBMOD
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-2    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=600s    connection=${connection}
    sleep    3s

Input new SCF
    [Arguments]    ${scf_name}
    Log To Console    input case SCF
    ${default_scf}    Set default SCF    scf_name=${scf_name}
    Commission new Default SCF    default_scf=${default_scf}
    Check GNB on air and Check Alarm List on BTS

Commission new Default SCF
    [Arguments]    ${default_scf}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console    Commission Default SCF
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}    is_pdl_checking_needed=${False}    timeout=600
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case Teardown for supercell reconfiguration new
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Input new SCF    scf_name=${EMPTY}
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot

Case Teardown for LTE supercell new
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Input new SCF    scf_name=${EMPTY}
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
