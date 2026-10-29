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

Suite Teardown    Run Keywords    Get bts package version
#...                               AND    check hanging resource
...                               AND    Log to console    collect gnb1 snapshot
...                               AND    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=0
...                               AND    Log to console    generate case1 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case1}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case1}    end_time=${end_time_case1}
...                               AND    Run Keyword And Ignore Error    Crawling and download kpi data   file_path=${excel_kpi_path}
...                               report_id=${report_id}    file_name=${report_name_case1}_${package_version}_${test_time_case1}    tl_id=${tl_id}
...                               AND    Run Keyword If Any Tests Failed    Teardown for case failure

Library  BuiltIn
Resource    ../Resources/FDD_TMO_common_keyword_new.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword_new_375.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/HBTE_PA_setting_375.py


*** Variables ***
${UE_attach_py}    all_ues_attach_via_thread_pool.py
${UE_detach_py}    all_ues_detach_via_thread_pool.py
${py_file_path}    /opt/workspace/SCF/
${report_name_case1}    case1
${report_name_case2}    case2
${report_name_case3}    case3
${attach_times}    10
@{pm_all_list}
${atten_ip}    ${tl.attenuator[0].ip_addr}     #atten1
${atten_ip2}    ${tl.attenuator[1].ip_addr}    #atten2
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${interval}    30
${pa_settime}    0.6
${paerror_counter}    0
${BWP_ho_times}    20
${ANR_ho_times}    2
${ho_times}    50
${cell_type}    SA
${ue_type}    samsung
${tl_id}    375
${traffic_path}    /opt/workspace/SCF/new_traffic_file/
${new_brust_file_name}    SFE_new_brust_traffic_mode.py
${yml_name_case1}    case1_DL_brust_ue_traffic_info.yml
${yml_name_case2}    case1_all_UE_DL_brust_20M_ue_traffic_info.yml
${yml_name_case3}    CA_case_20M_traffic_3s_sleep_10_info.yml
${sh_file_name}    375_brust_10M_5s.sh
${path_1}    /opt/workspace/SCF/SA_kpi_report.yml
${path_2}    /opt/workspace/SCF/NSA_kpi_report.yml
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${SCF_name}    GNB1_SA_SCF.xml
${execution_run}    run
${execution_kill}    kill
${ue_info_path_case1}    /opt/workspace/SCF/new_traffic_file/case1_DL_UL_ue_traffic_info.yml
${ue_info_path_case2}    /opt/workspace/SCF/new_traffic_file/case2_DL_UL_ue_traffic_info.yml
${allow_fault_list}    7311    7107    8000    6261    6203    7115
*** Test Cases ***
[1]TC01_SFE_Benchmark_NR_SW_UPGRADE
    [Documentation]    case:trigger ANR scenario gnb1 and gnb2 cell1 and cell11
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Block NR cell
    sleep    1min
    Unblock NR cell
    sleep    1min
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    trigger ANR scenario gnb1 and gnb2 cell1 and cell11
    set all PA ports and one cell set designated value    pa_name=${gnb2_cell21_pa_info}    value=${gnb2_cell21_pa_value}[setup][1]
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell1_pa_info}    s_value=${gnb1_cell1_pa_value}[setup][1]
    ...    e_value=${gnb1_cell1_pa_value}[setup][2]    step=${gnb1_cell1_pa_info}[step][0]    ho_times=${ANR_ho_times}
    sleep    3s
    Log to console    trigger ANR scenario gnb1 cell1 and cell301
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    sleep    5s
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ANR_ho_times}
    sleep    2s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][2]
    [Teardown]    Run Keywords    sleep    5s
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    robot_common_operations.Common Case Teardown

[1]TC02_SFE_Benchmark_NR_CELL_AVAILABILITY
    [Documentation]    test casee1:CELL1-CELL11 Inter F(FDD-FDD) inter gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2
    [Setup]
    robot_common_operations.Common Case Setup
    Log to console    change cell301 blocked
    change cell301 status to Locked
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    ${start_time_case1}=    Get record time for 375
    Set Suite Variable  ${start_time_case1}
    Log to console    report start time: ${start_time_case1}
    ${test_time_case1} =    Convert Date     date=${start_time_case1}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case1}
    Log to console    report test time: ${test_time_case1}
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    30s
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${yml_name_case2}
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    20s
    set PA port on one cell    pa_name=${gnb2_cell21_pa_info}    value=${gnb2_cell21_pa_value}[setup][1]
    Log to console    start GNB1 and GNB2 handover test
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell1_pa_info}    s_value=${gnb1_cell1_pa_value}[setup][1]
    ...    e_value=${gnb1_cell1_pa_value}[setup][2]    step=${gnb1_cell1_pa_info}[step][0]    ho_times=${ho_times}
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][2]
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[max]
    sleep    2s
    Log to console    trigger reestablish from cell21 to cell1
    set PA port on one cell    pa_name=${gnb2_cell21_pa_info}    value=${gnb2_cell21_pa_value}[max]
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
    [Teardown]    Run Keywords   Log to console    Hang up VONR FOR 5 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${yml_name_case2}
    ...    AND    Log to console    change cell301 UNblocked
    ...    AND    change cell301 status to Unlocked
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown

[1]TC04_SFE_Benchmark_NR_RACH
    [Documentation]    test casee3:CELL301-CELL302 Intra F(TDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2    debug2
    [Setup]
#    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell2_pa_info}    value=${gnb1_cell2_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    fligt mode off all UE on two pc
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    30s
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${yml_name_case1}
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    20s
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][3]
    ...    e_value=${gnb1_cell301_pa_value}[setup][4]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][4]
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[max]
    [Teardown]    Run Keywords    Log to console    Hang up VONR FOR 5 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${yml_name_case1}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown

[1]TC14_SFE_Benchmark_NR_SA_INTRA-5G_MOBILITY - per PLMN_per slice
    [Documentation]    test casee2:CELL1-CELL301 Inter F(FDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2    debug2
    [Setup]
    robot_common_operations.Common Case Setup
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    fligt mode off all UE on two pc
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    30s
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${yml_name_case1}
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    20s
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][2]
    sleep    5s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[max]
    sleep    2s
    Log to console    trigger reestablish from cell1 to cell301
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[max]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][1]
    [Teardown]    Run Keywords    Log to console    Hang up VONR FOR 5 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${yml_name_case1}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    PA recover
#    ...    AND    robot_common_operations.Common Case Teardown
#
[1]TC06_SFE_Benchmark_NR_SA_ACCESS
    [Documentation]    case3:Multiple UEs network operation action WITH FLIGH MODE ON AND OFF and BWP swtich AND CA test
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
#    Prepare with PM counter time to caculate    period=start
#    ${start_time_case1}=    Get record time for 375
#    Set Suite Variable  ${start_time_case1}
#    Log to console    report start time: ${start_time_case1}
#    ${test_time_case1} =    Convert Date     date=${start_time_case1}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
#    ...     result_format=%Y_%m_%d_%H_%M
#    Set Suite Variable    ${test_time_case1}
#    Log to console    report test time: ${test_time_case1}
    Log to console    start to loop attach and detach on cell1
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][4]
    Multiple UEs network operation action WITH FLIGH MODE ON AND OFF    attach_times=${attach_times}
    Log to console    start to loop attach and detach on cell1
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][4]
    Multiple UEs network operation action WITH FLIGH MODE ON AND OFF    attach_times=${attach_times}
    Log to console    start to CA and BWP swithc test on cell1
    Log to console    change cell301 blocked
    change cell301 status to Locked
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    fligt mode off all UE on two pc
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${yml_name_case3}
    sleep    20s
    Log to console    VONR CALL SETUP FOR 5 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    20s
    set PA port on one cell    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][4]
    sleep    20mins
    Log to console    start to CA and BWP swithc test on cell301
    Log to console    change cell301 UNblocked
    change cell301 status to Unlocked
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    sleep    3s
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][4]
    sleep    20mins
    [Teardown]    Run Keywords    Prepare with PM counter time to caculate    period=start
    ...    AND    Get record end time for 375 case1
    ...    AND    Log to console    report end time: ${end_time_case1}
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${yml_name_case2}
    ...    AND    PA recover
#    ...    AND    sleep    10mins
#    ...    AND    robot_common_operations.Common Case Teardown
#
[1]TC07_SFE_Benchmark_NR_SA_ACCESS - per PLMN_per slice
    [Documentation]    remove NRcell rel
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    robot_common_operations.Common Case Setup
    Prepare all online UE with data start test_375
    [Teardown]    Run Keywords    Log to console    delete 37511 NRREL
    ...    AND    online delete object parameters for 37511 NRREL
    ...    AND    Log to console    delete 37512 NRREL
    ...    AND    online delete object parameters for 37512 NRREL
    ...    AND    Log to console    delete 37511 xnlink AND NRADJGNB NRADJNRCELL
    ...    AND    delete required mo    gnb_index=${0}
    ...    AND    Log to console    delete 37512 xnlink AND NRADJGNB NRADJNRCELL
    ...    AND    delete required mo    gnb_index=${1}
    ...    AND    robot_common_operations.Common Case Teardown

#[1]TC09_SFE_Benchmark_NR_UE_CONTEXT_MODIFICATION
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]TC27_SFE_Benchmark_NR_SA_RLF
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]TC31_SFE_Benchmark_Long_PUCCH_-_PM Counters
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]TC32_SFE_Benchmark_PDSCH_at_SSB_slots (5GC002534)
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]TC33_SFE_Benchmark_PDSCH_at_TRS_slots (5GC002538)
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]TC38_SFE_Benchmark_NR_SA_RELEASE
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]CB007834-5G-A_001_DL_Tput_verify_per_release_8UE
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]E2E_latency_and_Robustness_Testing
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]E2E_Rep_010_03962758_Slicing_PMQAP_counter_Monitoring
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]virtual_drive_throughput_performance_test
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown
#
#[1]x2_slice_amf_block_lock_concurrency_case
#    [Documentation]    case2 already cover this case
#    [Timeout]    10 hour
#    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Prepare all online UE with data start test_375
#    [Teardown]    Run Keyword    robot_common_operations.Common Case Teardown

*** Keywords ***
Get record end time for 375 case1
    ${end_time_case1}=    Get record time for 375
    Set Suite Variable  ${end_time_case1}

Get record end time for 375 case2
    ${end_time_case2}=    Get record time for 375
    Set Suite Variable  ${end_time_case2}

Get record end time for 375 case3
    ${end_time_case3}=    Get record time for 375
    Set Suite Variable  ${end_time_case3}

Get record time for 375
    [Arguments]    ${label}=start
    ${record_time}=    record_time    label=${label}
    [Return]  ${record_time}

Multiple UEs network operation action WITH FLIGH MODE ON AND OFF
    [Arguments]    ${attach_times}
    FOR  ${times}    IN RANGE    ${attach_times}
        Log to console    Number of loop for attach: attach_times=${attach_times} NO.${times}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
        ...    pc_ip=${control_pc_ip1}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
        ...    pc_ip=${control_pc_ip3752}
        sleep    30s
        Log to console    All ue start to detach
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_detach_py}
        ...    pc_ip=${control_pc_ip1}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_detach_py}
        ...    pc_ip=${control_pc_ip3752}
        sleep    30s
    END
