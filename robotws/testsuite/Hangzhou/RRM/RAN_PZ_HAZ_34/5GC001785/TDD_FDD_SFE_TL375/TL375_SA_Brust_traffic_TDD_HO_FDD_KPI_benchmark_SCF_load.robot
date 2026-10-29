*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Non_Feature

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    check SA or NSA suite name
...                            AND    FDD_TMO_common_keyword_new.Common Suite Setup for COAM
#...                            AND    Prepare the gnb commission for SFE GNB1    SCF_name=${SCF_name}    cell_type=${cell_type}
#...                            AND    Prepare the gnb commission for SFE two testline    cell_type=${cell_type}

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
#...                               AND    check hanging resource
...                               AND    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=0
...                               AND    Get bts package version
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_1}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
...                               AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
...                               report_id=${report_id}    file_name=${report_name_1}_${package_version}_${formatted_time}    tl_id=${tl_id}
#...                               AND    generate new report and get report id    file_path=${path_2}    report_name=${report_name_2}
#...                               tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
#...                               AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
#...                               report_id=${report_id}    file_name=${report_name_2}_${package_version}    tl_id=${tl_id}
...                               AND    Run Keyword If Any Tests Failed    Teardown for case failure

Library  BuiltIn
Resource    ../Resources/FDD_TMO_common_keyword_new.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword_new_375.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_375.py


*** Variables ***
@{pm_all_list}
${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${interval}    30
${pa_settime}    0.6
${paerror_counter}    0
${ANR_ho_times}    2
${ho_times}    50
${cell_type}    SA
${ue_type}    samsung
${tl_id}    375
${brust_traffic_path}    /opt/workspace/SCF/
${brust_file_name}    ryan.py
${sh_file_name}    5GC007835_benchmark.sh
${path_1}    /opt/workspace/SCF/SA_kpi_report.yml
${path_2}    /opt/workspace/SCF/NSA_kpi_report.yml
${report_name_1}    SA
${report_name_2}    NSA
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${SCF_name}    GNB1_SA_SCF.xml
${allow_fault_list}    7311    7107    8000    6261    6203    7115
*** Test Cases ***
[1]TC38_SFE_Benchmark_NR_SA_RELEASE
    [Documentation]    CELL3-CELL21 Inter F(FDD-FDD) inter gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Log to console    change cell301 barred
#    change cell301Barred status to barred
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell302_pa_info}    value=${gnb1_cell302_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    Get record time    label=start
    Log to console    report start time: ${start_time}
    python handle get record time formate for excel name
    Log to console    format time for excel: ${formatted_time}
    make multi ues network with single pc    control_pc_ip=${control_pc_ip3752}    action_index=${0}
#    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][2]
    Log to console    Start DL Brust traffic for all UEs
    Start brust DL UDP traffic    tl_id=${tl_id}    path=${brust_traffic_path}    file_name=${brust_file_name}
    ...    shell_file_name=${sh_file_name}
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][2]
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell1_pa_info}    s_value=${gnb1_cell1_pa_value}[setup][1]
    ...    e_value=${gnb1_cell1_pa_value}[setup][2]    step=${gnb1_cell1_pa_info}[step][0]    ho_times=${ho_times}
    sleep    2s
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][2]
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
#    ...    AND    Log to console    change cell301 UNbarred
#    ...    AND    change cell301Barred status to Unbarred
    ...    AND    Log to console    Hang up VONR FOR 5 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    make multi ues network with single pc    control_pc_ip=${control_pc_ip3752}    action_index=${1}
#    ...    AND    Prepare with PM counter time to caculate    period=start
#    ...    AND    Get record time    label=end
#    ...    AND    Log to console    report end time: ${end_time}
    ...    AND    Stop brust DL UDP traffic    tl_id=${tl_id}   sh_file_name=${sh_file_name}
    ...    AND    PA recover

[1]TC14_SFE_Benchmark_NR_SA_INTRA-5G_MOBILITY - per PLMN_per slice
    [Documentation]    CELL1-CELL301 Inter F(FDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
#    Get record time    label=start
#    Log to console    report start time: ${start_time}
#    python handle get record time formate for excel name
#    Log to console    format time for excel: ${formatted_time}
    multi_all_ues_network_operate    action_index=${0}
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ANR_ho_times}
    sleep    2s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][2]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    Start DL traffic for all UEs
    make_traffic_multi_ue    file_path=${ue_info_path}    direction=dl
    Log to console    Start UL traffic for all UEs
    make_traffic_multi_ue    file_path=${ue_info_path}    direction=ul
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    Adjust_HBTE_PA with loop    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
    sleep    2s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][2]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][3]
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    Log to console    Hang up VONR FOR 5 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    multi_all_ues_network_operate    action_index=${1}
    ...    AND    Prepare with PM counter time to caculate    period=start
    ...    AND    Get record time    label=end
    ...    AND    Log to console    report end time: ${end_time}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul
    ...    AND    Log to console    delete 37511 NRREL
    ...    AND    online delete object parameters for 37511 NRREL
    ...    AND    Log to console    delete 37512 NRREL
    ...    AND    online delete object parameters for 37512 NRREL
    ...    AND    Log to console    delete 37512 xnlink AND NRADJGNB NRADJNRCELL
    ...    AND    delete required mo    gnb_index=${1}
    ...    AND    Log to console    delete 37511 xnlink AND NRADJGNB NRADJNRCELL
    ...    AND    delete required mo    gnb_index=${0}
    ...    AND    PA recover

[1]TC01_SFE_Benchmark_NR_SW_UPGRADE
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC02_SFE_Benchmark_NR_CELL_AVAILABILITY
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC04_SFE_Benchmark_NR_RACH
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC06_SFE_Benchmark_NR_SA_ACCESS
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC07_SFE_Benchmark_NR_SA_ACCESS - per PLMN_per slice
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC09_SFE_Benchmark_NR_UE_CONTEXT_MODIFICATION
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC27_SFE_Benchmark_NR_SA_RLF
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC31_SFE_Benchmark_Long_PUCCH_-_PM Counters
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC32_SFE_Benchmark_PDSCH_at_SSB_slots (5GC002534)
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]TC33_SFE_Benchmark_PDSCH_at_TRS_slots (5GC002538)
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]CB007834-5G-A_001_DL_Tput_verify_per_release_8UE
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]E2E_latency_and_Robustness_Testing
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]E2E_Rep_010_03962758_Slicing_PMQAP_counter_Monitoring
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]virtual_drive_throughput_performance_test
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

[1]x2_slice_amf_block_lock_concurrency_case
    [Documentation]    case2 already cover this case
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Prepare all online UE with data start test    cell_type=SA
    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
