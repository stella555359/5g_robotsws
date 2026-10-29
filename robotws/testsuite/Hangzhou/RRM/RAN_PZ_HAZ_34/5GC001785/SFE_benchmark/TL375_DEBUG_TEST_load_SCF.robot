*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Non_Feature

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    check SA or NSA suite name
...                            AND    FDD_TMO_common_keyword_new.Common Suite Setup for COAM
...                            AND    Prepare the gnb commission for SFE GNB1    SCF_name=${SCF_name}    cell_type=${cell_type}
#...                            AND    get traffic direction and ho times    cell_type=SA
#...                            AND    get value of control parameter
#...                            AND    Prepare the gnb commission for SFE two testline    cell_type=${cell_type}

Suite Teardown    Run Keywords    Get bts package version
#...                               AND    check hanging resource
...                               AND    Log to console    generate case1 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case1}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case1}    end_time=${end_time_case1}
...                               AND    Run Keyword And Ignore Error    crawling_data_to_excel_file
...                               report_id=${report_id}    json_file_path=${excel_kpi_path}
...                               json_file_name=${report_name_case1}_${package_version}_${test_time_case1}    tl_id=${tl_id}
...                               excel_path=${excel_kpi_path}    excel_name=${report_name_case1}_${package_version}_${test_time_case1}
...                               AND    Log to console    generate case2 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case2}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case2}    end_time=${end_time_case2}
...                               AND    Run Keyword And Ignore Error    crawling_data_to_excel_file
...                               report_id=${report_id}    json_file_path=${excel_kpi_path}
...                               json_file_name=${report_name_case2}_${package_version}_${test_time_case2}    tl_id=${tl_id}
...                               excel_path=${excel_kpi_path}    excel_name=${report_name_case2}_${package_version}_${test_time_case2}
...                               AND    Log to console    generate case3 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case3}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case3}    end_time=${end_time_case3}
...                               AND    Run Keyword And Ignore Error    crawling_data_to_excel_file
...                               report_id=${report_id}    json_file_path=${excel_kpi_path}
...                               json_file_name=${report_name_case3}_${package_version}_${test_time_case3}    tl_id=${tl_id}
...                               excel_path=${excel_kpi_path}    excel_name=${report_name_case3}_${package_version}_${test_time_case3}
...                               AND    Log to console    generate case4 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case4}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case4}    end_time=${end_time_case4}
...                               AND    Run Keyword And Ignore Error    crawling_data_to_excel_file
...                               report_id=${report_id}    json_file_path=${excel_kpi_path}
...                               json_file_name=${report_name_case4}_${package_version}_${test_time_case4}    tl_id=${tl_id}
...                               excel_path=${excel_kpi_path}    excel_name=${report_name_case4}_${package_version}_${test_time_case4}
...                               AND    Log to console    generate case5 KPI
...                               AND    generate new report and get report id    file_path=${path_1}
...                               report_name=${report_name_case5}_${package_version}    tl_id=${tl_id}
...                               package_version=${package_version}    start_time=${start_time_case5}    end_time=${end_time_case5}
...                               AND    Run Keyword And Ignore Error    crawling_data_to_excel_file
...                               report_id=${report_id}    json_file_path=${excel_kpi_path}
...                               json_file_name=${report_name_case5}_${package_version}_${test_time_case5}    tl_id=${tl_id}
...                               excel_path=${excel_kpi_path}    excel_name=${report_name_case5}_${package_version}_${test_time_case5}
...                               AND    Log to console    collect gnb1 snapshot
...                               AND    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=0
...                               AND    Log to console    collect gnb2 snapshot
...                               AND    Save snapshot Teardown for SFE    connection=GNB_OAM    gnb_index=1
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
${report_name_case1}    case1_F_F_HO
${report_name_case2}    case2_FDD_CE
${report_name_case3}    case3_F_T_HO
${report_name_case4}    case4_T_T_HO
${report_name_case5}    case5_TDD_CE
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
${inter_gnb_HO_ue_traffic_info}    case2_inter_gnb_HO_All_UE_DL_brust_20M.yml
${intra_gnb_DL_traffic_info}    case3_intra_gnb_DL_traffic_info.yml
${CA_brust_long_sleep_traffic_info}    CA_brust_traffic_long_sleep_20M_traffic_3s_sleep_10.yml
${path_1}    /opt/workspace/SCF/SA_kpi_report.yml
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${SCF_name}    GNB1_SA_SCF.xml
${execution_run}    run
${execution_kill}    kill
${ue_info_path_case1}    /opt/workspace/SCF/new_traffic_file/case1_DL_UL_ue_traffic_info.yml
${allow_fault_list}    7311    7107    8000    6261    6203    7115
*** Test Cases ***
[1]TC001_E2E_Benchmark_HO_based_neighbor_addition_for_Intra_or_Inter_gNB_Inter_Freq_ANR
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
    set all PA ports and one cell set designated value    pa_name=${gnb2_cell11_pa_info}    value=${gnb2_cell11_pa_value}[setup][1]
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    10s
    Adjust_HBTE_PA with loop for 375    pa_name=${gnb1_cell1_pa_info}    s_value=${gnb1_cell1_pa_value}[setup][1]
    ...    e_value=${gnb1_cell1_pa_value}[setup][2]    step=${gnb1_cell1_pa_info}[step][0]    ho_times=${ANR_ho_times}
    sleep    3s
    Log to console    trigger ANR scenario gnb1 cell1 and cell301
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][1]
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
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]TC002_E2E_Benchmark_inter_F_inter_GNB_handover_stability_test
    [Documentation]    test case1:CELL1-CELL11 Inter F(FDD-FDD) inter gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    change cell301 blocked
    change cell301 status to Locked
    Log to console    start gnb1 cell_1 and gnb2 cell_11 handover test
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[initial]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb2_cell401_pa_info}    value=${gnb2_cell401_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    ${start_time_case1}=    Get record time for 375
    Set Suite Variable  ${start_time_case1}
    Log to console    report start time: ${start_time_case1}
    ${test_time_case1} =    Convert Date     date=${start_time_case1}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case1}
    Log to console    report test time: ${test_time_case1}
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${inter_gnb_HO_ue_traffic_info}
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    40s
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    set PA port on one cell    pa_name=${gnb2_cell11_pa_info}    value=${gnb2_cell11_pa_value}[setup][1]
    Log to console    start video call for two UEs
    make Video call over NR    MO_UE_index=${1}    MT_UE_index=${2}
    sleep    30s
    ${vonr_ue_index_list}=    Create List    ${28}    ${25}    ${27}
    ${emc_ue_index_list}=    Create List    ${37}    ${34}    ${35}    ${38}    ${39}
    functions_thread_pool    vonr_ue_index_list=${vonr_ue_index_list}    emc_ue_index_list=${emc_ue_index_list}
    ...    pa_name=${gnb1_cell1_pa_info}    s_value=${gnb1_cell1_pa_value}[setup][1]
    ...    e_value=${gnb1_cell1_pa_value}[setup][2]    step=${gnb1_cell1_pa_info}[step][0]    ho_times=${ho_times}
    ...    interval=${interval}    pa_settime=${pa_settime}
    [Teardown]    Run Keywords    Log to console    wait end time for case1
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    Get record end time for 375 case1
    ...    AND    Log to console    report end time: ${end_time_case1}
    ...    AND    Log to console    Hang up VONR FOR 3 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    Hang up VINR CALL
    ...    AND    hang up VoNR or ViNR call    ue_index=${1}
    ...    AND    sleep    10s
    ...    AND    Log to console    stop the brust traffic
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${inter_gnb_HO_ue_traffic_info}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    Log to console    change cell301 UNblocked
    ...    AND    change cell301 status to Unlocked
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]TC007_E2E_Benchmark_CB012121_CellQuality_MultipleMR_InterGNB_InterFREQ_XN
    [Documentation]    test case2:cell edge CA and rach test
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    change cell301 blocked
    change cell301 status to Locked
    Prepare with PM counter time to caculate    period=start
    ${start_time_case2}=    Get record time for 375
    Set Suite Variable  ${start_time_case2}
    Log to console    report start time: ${start_time_case2}
    ${test_time_case2} =    Convert Date     date=${start_time_case2}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case2}
    Log to console    report test time: ${test_time_case2}
    Log to console    start to CA and BWP swithc test on cell1
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][5]
    set PA port on one cell    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[initial]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${CA_brust_long_sleep_traffic_info}
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    20s
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    start to loop attach and detach on cell1 10 times
    Multiple UEs network operation action WITH FLIGH MODE ON AND OFF    attach_times=${attach_times}
    sleep    20s
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    start video call for two UEs
    make Video call over NR    MO_UE_index=${1}    MT_UE_index=${2}
    Log to console    VONR CALL SETUP FOR 3 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    25mins
    [Teardown]    Run Keywords    Log to console    wait end time for case2
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    Get record end time for 375 case2
    ...    AND    Log to console    report end time: ${end_time_case2}
    ...    AND    Log to console    Hang up VONR FOR 3 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    Hang up VINR CALL
    ...    AND    hang up VoNR or ViNR call    ue_index=${1}
    ...    AND    sleep    10s
    ...    AND    Log to console    stop the brust traffic
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${CA_brust_long_sleep_traffic_info}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    Log to console    change cell301 UNblocked
    ...    AND    change cell301 status to Unlocked
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]TC003_E2E_Benchmark_inter_F_intra_F_intra_GNB_handover_and_RACH_stability_test
    [Documentation]    test case3:CELL1-CELL301 Inter F(FDD-TDD) intra gnb HO and cell301 and cell302 handover
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2    debug2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    Start gnb1 cell1 and cell301 handover test
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[initial]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    ${start_time_case3}=    Get record time for 375
    Set Suite Variable  ${start_time_case3}
    Log to console    report start time: ${start_time_case3}
    ${test_time_case3} =    Convert Date     date=${start_time_case3}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case3}
    Log to console    report test time: ${test_time_case3}
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${intra_gnb_DL_traffic_info}
    Log to console    fligt mode off all UE on two pc
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    1min
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    start video call for two UEs
    make Video call over NR    MO_UE_index=${1}    MT_UE_index=${2}
    sleep    30s
    ${vonr_ue_index_list}=    Create List    ${28}    ${25}    ${27}
    ${emc_ue_index_list}=    Create List    ${37}    ${34}    ${35}    ${38}    ${39}
    functions_thread_pool    vonr_ue_index_list=${vonr_ue_index_list}    emc_ue_index_list=${emc_ue_index_list}
    ...    pa_name=${gnb1_cell301_pa_info}    s_value=${gnb1_cell301_pa_value}[setup][1]
    ...    e_value=${gnb1_cell301_pa_value}[setup][2]    step=${gnb1_cell301_pa_info}[step][0]    ho_times=${ho_times}
    ...    interval=${interval}    pa_settime=${pa_settime}
    [Teardown]    Run Keywords    Log to console    wait end time for case3
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    Get record end time for 375 case3
    ...    AND    Log to console    report end time: ${end_time_case3}
    ...    AND    Log to console    Hang up VONR FOR 3 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    Hang up VINR CALL
    ...    AND    hang up VoNR or ViNR call    ue_index=${1}
    ...    AND    sleep    10s
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${intra_gnb_DL_traffic_info}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]TC006_E2E_Benchmark_CB012582_VoNR_counter_check_for_intra_gnb_HO_on_WEBEM
    [Documentation]    test case4:CELL301-CELL302 Inter F(FDD-TDD) intra gnb HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2    debug2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][0]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    Start DL Brust traffic for dedicate UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${intra_gnb_DL_traffic_info}
    Prepare with PM counter time to caculate    period=start
    ${start_time_case4}=    Get record time for 375
    Set Suite Variable  ${start_time_case4}
    Log to console    report start time: ${start_time_case4}
    ${test_time_case4} =    Convert Date     date=${start_time_case4}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case4}
    Log to console    report test time: ${test_time_case4}
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    1min
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    start video call for two UEs
    make Video call over NR    MO_UE_index=${1}    MT_UE_index=${2}
    sleep    30s
    ${vonr_ue_index_list}=    Create List    ${28}    ${25}    ${27}
    ${emc_ue_index_list}=    Create List    ${37}    ${34}    ${35}    ${38}    ${39}
    Log to console    Start gnb1 cell301 and cell302 handover test
    functions_thread_pool    vonr_ue_index_list=${vonr_ue_index_list}    emc_ue_index_list=${emc_ue_index_list}
    ...    pa_name=${gnb1_cell302_pa_info}    s_value=${gnb1_cell302_pa_value}[setup][3]
    ...    e_value=${gnb1_cell302_pa_value}[setup][4]    step=${gnb1_cell302_pa_info}[step][0]    ho_times=${ho_times}
    ...    interval=${interval}    pa_settime=${pa_settime}
    [Teardown]    Run Keywords    Log to console    wait end time for case4
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    Get record end time for 375 case4
    ...    AND    Log to console    report end time: ${end_time_case4}
    ...    AND    Log to console    Hang up VONR FOR 3 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    Hang up VINR CALL
    ...    AND    hang up VoNR or ViNR call    ue_index=${1}
    ...    AND    sleep    10s
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${intra_gnb_DL_traffic_info}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    PA recover
    ...    AND    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

[1]TC004_E2E_Benchmark_NRREL_XNLINK_NRADJNRCELL_Remove
    [Documentation]    test case5:CELL301 cell edge CA and rach
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_TRUNK    CRT_24R1    CRT_24R2    debug2
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,8000,7115
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Log to console    Start CELL301 cell edge CA and rach test
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[initial]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Prepare with PM counter time to caculate    period=start
    ${start_time_case5}=    Get record time for 375
    Set Suite Variable  ${start_time_case5}
    Log to console    report start time: ${start_time_case5}
    ${test_time_case5} =    Convert Date     date=${start_time_case5}     date_format=%Y-%m-%d %H:%M    exclude_millis=yes
    ...     result_format=%Y_%m_%d_%H_%M
    Set Suite Variable    ${test_time_case5}
    Log to console    report test time: ${test_time_case5}
    Log to console    start to CA and BWP switch test on cell301
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell301_pa_info}    value=${gnb1_cell301_pa_value}[setup][5]
    set PA port on one cell    pa_name=${gnb1_cell23_pa_info}    value=${gnb1_cell23_pa_value}[setup][0]
    Log to console    start DL Brust traffic for all UEs
    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_run}    yml_name=${CA_brust_long_sleep_traffic_info}
    Log to console    flight off all UEs and attach to network
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip1}
    SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
    ...    pc_ip=${control_pc_ip3752}
    sleep    20s
    Log to console    Start DL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    Log to console    start to loop attach and detach on cell1 10 times
    Multiple UEs network operation action WITH FLIGH MODE ON AND OFF    attach_times=${attach_times}
    sleep    20s
    Log to console    Start UL traffic for dedicate UEs
    make_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    Log to console    start video call for two UEs
    make Video call over NR    MO_UE_index=${1}    MT_UE_index=${2}
    Log to console    VONR CALL SETUP FOR 3 UEs
    Make mutil UE for VoNR Setup TL375_new
    Log to console    EMC CALL SETUP FOR 5 UEs
    Make mutil UE for EMC Setup TL375_new
    sleep    25mins
    [Teardown]    Run Keywords    Log to console    wait end time for case5
    ...    AND    Prepare with PM counter time to caculate    period=end
    ...    AND    Get record end time for 375 case5
    ...    AND    Log to console    report end time: ${end_time_case5}
    ...    AND    Log to console    Hang up VONR FOR 3 UEs
    ...    AND    hang up mutil UE for VoNR Setup TL375_new
    ...    AND    Log to console    Hang up EMC FOR 5 UEs
    ...    AND    hang up mutil UE for EMC Setup TL375_new
    ...    AND    Log to console    Hang up VINR CALL
    ...    AND    hang up VoNR or ViNR call    ue_index=${1}
    ...    AND    sleep    10s
    ...    AND    Log to console    fligt mode on for all UEs
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip1}
    ...    AND    SFE Multiple UEs network operation action    tl_id=${tl_id}     path=${py_file_path}
    ...    file_name=${UE_detach_py}    pc_ip=${control_pc_ip3752}
    ...    AND    Log to console    stop the brust traffic
    ...    AND    SFE Multiple data models procedure    tl_id=${tl_id}    path=${traffic_path}    file_name=${new_brust_file_name}
    ...    execution=${execution_kill}    yml_name=${CA_brust_long_sleep_traffic_info}
    ...    AND    Log to console    Stop DL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=dl
    ...    AND    Log to console    Stop UL traffic for all UEs
    ...    AND    stop_traffic_multi_ue    file_path=${ue_info_path_case1}    direction=ul
    ...    AND    PA recover
#    ...    AND    Log to console    delete 37511 NRREL
#    ...    AND    online delete object parameters for 37511 NRREL
#    ...    AND    Log to console    delete 37512 NRREL
#    ...    AND    online delete object parameters for 37512 NRREL
#    ...    AND    Log to console    delete 37511 xnlink AND NRADJGNB NRADJNRCELL
#    ...    AND    delete required mo    gnb_index=${0}
#    ...    AND    Log to console    delete 37512 xnlink AND NRADJGNB NRADJNRCELL
#    ...    AND    delete required mo    gnb_index=${1}
#    ...    AND    robot_common_operations.Common Case Teardown
#    ...    AND    Run keyword and ignore error    CI_interface.Common Case Teardown

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

Get record end time for 375 case4
    ${end_time_case4}=    Get record time for 375
    Set Suite Variable  ${end_time_case4}

Get record end time for 375 case5
    ${end_time_case5}=    Get record time for 375
    Set Suite Variable  ${end_time_case5}

Get record time for 375
    [Arguments]    ${label}=start
    ${record_time}=    record_time    label=${label}
    [Return]  ${record_time}

Multiple UEs network operation action WITH FLIGH MODE ON AND OFF
    [Arguments]    ${attach_times}
    FOR  ${times}    IN RANGE    ${attach_times}
        Log to console    Number of loop for attach: attach_times=${attach_times} NO.${times}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_detach_py}
        ...    pc_ip=${control_pc_ip1}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_detach_py}
        ...    pc_ip=${control_pc_ip3752}
        sleep    30s
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
        ...    pc_ip=${control_pc_ip1}
        SFE Multiple UEs network operation action    tl_id=${tl_id}    path=${py_file_path}    file_name=${UE_attach_py}
        ...    pc_ip=${control_pc_ip3752}
        sleep    30s
    END
