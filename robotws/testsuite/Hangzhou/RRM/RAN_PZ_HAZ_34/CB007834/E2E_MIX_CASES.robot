*** Settings ***
Documentation
...    Contact: ming.shi@nokia.com

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/KPI/generate_padding_analysis_kpi.robot


Suite Setup    Common Suite Setup For E2E case And Get Suite Time
Suite Teardown    Common Suite Teardown For E2E case And Wait For KPI Done
Test Setup    Common Case Setup For E2E case
Test Teardown    Common Case Teardown For E2E case


*** Test Cases ***
[1]E2E_CB007834_5G_A_001_9UE_CA_VONR_EC_intraF_interGNB_HO
    [Documentation]    This user scenario to verify 8UE attach and peak Tput for UL and DL besed on TMO configuration.
    [Timeout]    10 hours
    Step0 barred GNB2 LTE OF CELL 211
    E2E case 1
    E2E case 2


[1]E2E_5GC000784_B_015_success_Inter_RAT_HO_with_EC_call_with_emergencyCallMrListIgnore_on
    [Documentation]    IRAT HO WITH EC
    [Timeout]    1 hour
    [Tags]    classical    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=49
    sleep    3s
    [Teardown]    Run Keyword    Get record time    label=end

[1]E2E_CB007834_5G_A_003_Verify_3CC_peakTput_for_DL_FDD_N25_PCell_FDD_N71_TDD_N41_Scell
    [Documentation]    covered by TMO KPI testing
    [Timeout]    1 hour
    [Tags]    classical    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=49
    sleep    3s
    [Teardown]    Run Keyword    Get record time    label=end

[1]E2E_CB007834_5G_A_002_UL_DL_peak_Tput_verify_per_release
    [Documentation]    covered by TMO KPI testing
    [Timeout]    1 hour
    [Tags]    classical    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4459,49
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=49
    sleep    3s
    [Teardown]    Run Keyword    Get record time    label=end


*** Keywords ***
Step0 barred GNB2 LTE OF CELL 211
    Log To Console    ***********para modify LTE barred*********************
    paras change on BTS    paras=${PARAMETERS_LTE_BARRED}    delta_file_name=${JSON_PATH}LTE_BARRED.json
    ...    gnb_index=${1}
    Log To Console    ***********precondition set pa and rf matrix*********************
    recover_pa    ports=${test_info}[pa_all_ports]
    recover_rf_matrix
    set_precondition_values_with_rf_matrix
    ...    ports=${test_info}[RF_MATRIX_G1_PRECONDITION_PORTS]    values=${test_info}[RF_MATRIX_G1_PRECONDITION_VALUES]

Step1 UE1_4 attach then make DL_UL_1M on CELL21 then HO and UE5_7 attach then peak Tput 3CC TFF CELL302_22_3 DL_550_UL_40
    Log To Console    ***********Prapare Spark UE*********************
    Prapare Spark UE
    Prepare to caculate PM counter    period=start
    Get record time    label=start
    Log To Console    ***********MutlUE attach and check tput via spark and loop HO*********************
    MutlUE attach and check tput via spark and loop HO

Inter rat ho with VoNR and EMC call
    Prepare to caculate PM counter    period=start
    Get record time    label=start
    set_nr_pa_value_to_start_group_3
    ...    ports=${test_info}[set_nr_pa_value_to_start_group_3][ports]
    ...    values=${test_info}[set_nr_pa_value_to_start_group_3][values]
    Log To Console    ***********para modify LTE UNBARRED and NR barred*********************
    paras change on BTS    paras=${PARAMETERS_LTE_UNBARRED_NR_BARRED}    delta_file_name=${JSON_PATH}LTE_UNBARRED_NR_BARRED.json
    ...    gnb_index=${1}
    Log To Console    ***********Inter rat ho with VoNR and EMC call*********************
    ues were operated via py file
    ...    file_name=all_ues_attach_via_thread_pool.py
    ...    pc_ip=${test_info}[ues_were_operated_via_py_file][pc_ip]
    ...    pc_usr=${test_info}[ues_were_operated_via_py_file][pc_usr]
    ...    pc_pwd=${test_info}[ues_were_operated_via_py_file][pc_pwd]
    ...    tl_id=${test_info}[ues_were_operated_via_py_file][tl_id]
    Sleep    ${test_info}[inter_rat_ho_make_voice][time_between_attach_and_voice_call]
#    make_vonr_call_per_ue    ue_index=${0}
#    make_emc_call_per_ue    ue_index=${9}
    make_vonr_and_emc_call    vonr_ue_index=${0}    emc_ue_index=${9}
    Log To Console    ***********Inter rat ho start*********************
    inter_rat_ho_make_voice
    ...    lte_ports=${test_info}[inter_rat_ho_make_voice][lte][lte_ports]
    ...    lte_values=${test_info}[inter_rat_ho_make_voice][lte][lte_values]
    ...    lte_source_value=${test_info}[inter_rat_ho_make_voice][lte][lte_source_value]
    ...    lte_target_value=${test_info}[inter_rat_ho_make_voice][lte][lte_target_value]
    ...    lte_steps=${test_info}[inter_rat_ho_make_voice][lte][lte_steps]
    ...    nr_ports=${test_info}[inter_rat_ho_make_voice][nr][nr_ports]
    ...    nr_values_1=${test_info}[inter_rat_ho_make_voice][nr][nr_values_1]
    ...    nr_values_2=${test_info}[inter_rat_ho_make_voice][nr][nr_values_2]
    ...    nr_source_value=${test_info}[inter_rat_ho_make_voice][nr][nr_source_value]
    ...    nr_target_value=${test_info}[inter_rat_ho_make_voice][nr][nr_target_value]
    ...    nr_steps=${test_info}[inter_rat_ho_make_voice][nr][nr_steps]
    ...    ho_times=${test_info}[inter_rat_ho_make_voice][ho_times]
    Log To Console    ***********Inter rat ho end*********************
    [Teardown]    ho hang up voice detach to end group_3

EPSFB make and hang up
    Prepare to caculate PM counter    period=start
    set_pa
    ...    ports=${test_info}[epsfb_make_and_hang_up][nr][nr_ports]
    ...    values=${test_info}[epsfb_make_and_hang_up][nr][nr_values]
    Log To Console    ***********ppara modify EPSFB paras*********************
    paras change on BTS    paras=${PARAMETERS_EPSFB}    delta_file_name=${JSON_PATH}epsfb_paras.json
    ...    gnb_index=${0}
    Log To Console    ***********EPSFB make and hang up start*********************
    FOR    ${t}    IN RANGE    ${test_info}[epsfb_make_and_hang_up][make_hang_up_times]
        Log To Console    This is ${t} times EPSFB make and hang up
        recover_pa
        ...    ports=${test_info}[epsfb_make_and_hang_up][lte][lte_ports]
        ues were operated via py file
        ...    file_name=all_ues_attach_via_thread_pool.py
        ...    pc_ip=${test_info}[ues_were_operated_via_py_file][pc_ip]
        ...    pc_usr=${test_info}[ues_were_operated_via_py_file][pc_usr]
        ...    pc_pwd=${test_info}[ues_were_operated_via_py_file][pc_pwd]
        ...    tl_id=${test_info}[ues_were_operated_via_py_file][tl_id]
        set_pa
        ...    ports=${test_info}[epsfb_make_and_hang_up][lte][lte_ports]
        ...    values=${test_info}[epsfb_make_and_hang_up][lte][lte_values]
        Sleep    ${test_info}[epsfb_make_and_hang_up][time_between_attach_and_voice_call]
        make_vonr_and_emc_call    vonr_ue_index=${0}    emc_ue_index=${9}
#        make_vonr_call_per_ue    ue_index=${0}
#        make_emc_call_per_ue    ue_index=${9}
        Sleep    ${test_info}[epsfb_make_and_hang_up][voice_duration]
        hang_up_vonr_and_emc_call    vonr_ue_index=${0}    emc_ue_index=${9}
#        hang_up_vonr_call_per_ue    ue_index=${0}
#        hang_up_emc_call_per_ue    ue_index=${9}
        Sleep    ${test_info}[epsfb_make_and_hang_up][time_between_hang_up_and_detach]
        ues were operated via py file
        ...    file_name=all_ues_detach_via_thread_pool.py
        ...    pc_ip=${test_info}[ues_were_operated_via_py_file][pc_ip]
        ...    pc_usr=${test_info}[ues_were_operated_via_py_file][pc_usr]
        ...    pc_pwd=${test_info}[ues_were_operated_via_py_file][pc_pwd]
        ...    tl_id=${test_info}[ues_were_operated_via_py_file][tl_id]
        Sleep    ${test_info}[epsfb_make_and_hang_up][time_between_detach_and_attach]
    END
    Log To Console    ***********EPSFB make and hang up end*********************
    [Teardown]    ho hang up voice detach to end group_3

Generate And Analyze KPI
    [Arguments]    ${case_part}=case_1
    ...            ${template_name}=CHZ_SG3_TMO_SA_KPI
    ...            ${report_excel_file_path}=/opt/workspace/E2E_KPI/
    ...            ${origin_kpi_excel}=/opt/workspace/KPI_Report_Summary/E2E_SFE_Qos_TMO_KPI_monitor_summary_2026_0211_TL363_LX.xlsx
    ...            ${sheet_name}=SA
    ...            ${receiver_email}=xu.2.liu@nokia.com
    ...            ${sw_build_name_row}=3
    ...            ${start_row_index}=4
    ...            ${start_row_sparkline_index}=4
    ...            ${sparkline_col}=K
    ...            ${kpi_value_col}=BC
    ...            ${kpi_name_col}=D
    ...            ${kpi_rule_col}=G
    ...            ${kpi_value_end_col}=DL
    Log To Console    ***********Generate And Analyze KPI start*********************
    Get record time    label=end
    ${end_time}=    DateTime.Convert Date    ${end_time}    result_format=%Y-%m-%d %H:%M
    ${report_time}=    DateTime.Get Current Date    result_format=%Y-%m-%dT%H%M%S%f
    SFE_TMO_common_keywords.Get bts package version
    ${ute_tl_id}    set variable    ${test_info}[get_and_download_kpi][tl_id]
    ${test_line}    set variable    7_5_UTE5G402T${ute_tl_id}
    ${case_kpi_excel}    set variable
    ...    ${report_excel_file_path}/${package_version}_${test_info}[get_and_download_kpi][CASE_REPORT_NAME]_${case_part}_${report_time}.xlsx
    Run Script To Generate Padding Analysis KPI
    ...    template_name=${template_name}
    ...    report_name=${package_version}_${test_info}[get_and_download_kpi][CASE_REPORT_NAME]_${case_part}_${report_time}
    ...    ute_tl_id=${ute_tl_id}
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    report_excel_file_path=${report_excel_file_path}
    ...    origin_kpi_excel=${origin_kpi_excel}
    ...    suite_timestamp=${suite_timestamp}
    ...    sheet_name=${sheet_name}
    ...    receiver_email=${receiver_email}
    ...    sw_build_name_row=${sw_build_name_row}
    ...    start_row_index=${start_row_index}
    ...    start_row_sparkline_index=${start_row_sparkline_index}
    ...    sparkline_col=${sparkline_col}
    ...    kpi_value_col=${kpi_value_col}
    ...    kpi_name_col=${kpi_name_col}
    ...    kpi_rule_col=${kpi_rule_col}
    ...    case_kpi_excel=${case_kpi_excel}
    ...    test_line=${test_line}
    ...    kpi_value_end_col=${kpi_value_end_col}
    Log To Console    ***********Generate and Analyze KPI end*********************

Prapare Spark UE
    Multi MTU power and prepare ue     ue_index_MTU_all=${MTU_ALL_UE_INDEX}
    ...    ue_index_MTU_poweron_all=${test_info}[MTU_POWER_OFF_ON_ALL_INDEX]
    ...    ue_index_MTU_poweroff_all=${test_info}[MTU_POWER_OFF_ON_ALL_INDEX]
    ...    MTU=Multi-UE Power Management.exe    detach_request=${false}    index_ue=${1}
    Log To Console    ***********Detach UE*********************
    FOR    ${index}    IN    @{ALL_UE_INDEX}
        MultiUE.Detach    ue_index=${index}
    END

MutlUE attach and check tput via spark and loop HO
    Comment    ***********Attach UE And Start Traffic*********************
    FOR    ${index}    ${UE_INDEX}    IN ENUMERATE    @{ALL_UE_INDEX}
        Attach and check IP OK    ue_index=${UE_INDEX}    APN=${ALL_UES_SPECIAL_APN}[${index}]
        MultiUE.Start DL Traffic    throughput_for_DL=${DL_THROUGHPUT}[${index}]    ue_index=${UE_INDEX}
        ...    duration=${test_info}[loop_cell21_ho_gnb2_cell1][DL_traffic_duration]
        ...    APN=${ALL_UES_SPECIAL_APN}[${index}]    process_num=${1}    direction=dl
        MultiUE.Start DL Traffic    throughput_for_DL=${UL_THROUGHPUT}[${index}]    ue_index=${UE_INDEX}
        ...    duration=${test_info}[loop_cell21_ho_gnb2_cell1][UL_traffic_duration]
        ...    APN=${ALL_UES_SPECIAL_APN}[${index}]    process_num=${1}    direction=ul
    END
    sleep    10s
#    Comment    ***********Check DL UL Traffic*********************
#    FOR    ${index}    ${UE_INDEX}    IN ENUMERATE    @{ALL_UE_INDEX}
#        Log To Console    ***Check ${UE_INDEX} UE tput***
#        Repeat keyword    10 times
#        ...    Check tput via spark    ue_index=${UE_INDEX}
#        ...    direction==DL    target_throughput=${DL_EXPECT_THROUGHPUT}[${index}]
#        ...    direction_UL=UL    target_throughput_UL=${UL_EXPECT_THROUGHPUT}[${index}]
#    END
#    sleep    10s
    Comment    *************loop CELL21 HO GNB2 CELL1*******************
    loop_cell21_ho_gnb2_cell1
    ...    source_ports=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_SOURCE_PORTS]
    ...    source_values=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_SOURCE_VALUES]
    ...    target_ports=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_TARGET_PORTS]
    ...    target_values=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_TARGET_VALUES]
    ...    step=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_STEPS]
    ...    ho_times=${test_info}[loop_cell21_ho_gnb2_cell1][RF_MATRIX_G1_HO_TIMES]
    [Teardown]    Multi UE stop traffic and detach

Attach and check IP OK
    [Arguments]    ${ue_index}=${7}    ${APN}=${APN}
    MultiUE.Attach    ue_index=${ue_index}
    sleep    1s
    IF    '${ue_index}' == '${5}' or '${ue_index}' == '${6}' or '${ue_index}' == '${7}'
        Wait until keyword succeeds    4x   10s    Spark.send AT command CPE
            ...    param=at+cgact=1,3    ue_alias=UE_${ue_index}
    END
    ${IP}    MutiUE.Get PDU IP    ue_index=${ue_index}    APN=${APN}
    Should Not Be Empty    ${IP}
    Should Not Start With    ${IP}    192.168.

#Attach with multi PDU Session OK and check IP OK
#    [Arguments]    ${ue_index}=${7}    ${Multi_APN}=${Multi_APN}    ${Multi_APN_all}=${Multi_APN_all}
#    MultiUE.Attach    ue_index=${ue_index}
#    sleep    1s
#    FOR    ${index}    ${APN_index}    IN ENUMERATE    @{Multi_APN}
#        ${index1}    Set Variable    ${${index}+${3}}
#        Wait until keyword succeeds    4x   10s    Spark.send AT command CPE
#        ...    param=at+cgact=1,${index1}    ue_alias=UE_${ue_index}
#    END
#    Sleep    2s
#    FOR    ${apn_index}    IN    @{Multi_APN_all}
#        ${IP}    MutiUE.Get PDU IP    ue_index=${ue_index}    APN=${apn_index}
#        Should Not Be Empty    ${IP}
#        Should Not Start With    ${IP}    192.168.
#    END

Multi UE stop traffic and detach
    FOR    ${index}    ${UE_INDEX}    IN ENUMERATE    @{ALL_UE_INDEX}
        MultiUE.Stop DL Traffic    direction=dl    ue_index=${UE_INDEX}    APN=${ALL_UES_SPECIAL_APN}[${index}]
        MultiUE.Stop DL Traffic    direction=ul    ue_index=${UE_INDEX}    APN=${ALL_UES_SPECIAL_APN}[${index}]
        MultiUE.Detach    ue_index=${UE_INDEX}
    END

Setup TTI for case steps
    CB007834_common_keywords.Setup BTS TTitrace Mirror to remote UTE
    ...    ute_ip=${test_info}[tti_uteip]
    ...    nr_phy_cell_ids=${test_info}[tti_celllist]
    ...    tti_component=${test_info}[tti_component]
    CB007834_common_keywords.Start Collect TTitrace on remote UTE
    ...    uteTTI_ip=${test_info}[tti_uteip]
    ...    uteTTI_username=${test_info}[tti_uteuser]
    ...    uteTTI_password=${test_info}[tti_utepw]
    ...    maxnumber=${test_info}[tti_number]
    ...    timeout=${test_info}[tti_timeout]
    Step1 UE1_4 attach then make DL_UL_1M on CELL21 then HO and UE5_7 attach then peak Tput 3CC TFF CELL302_22_3 DL_550_UL_40
    [Teardown]    Finish tti log collect

Finish tti log collect
    ${tti_path}=    Evaluate    '${test_info}[tti_tragetpath]' + '/'.join('${epc_log_path}'.split('/')[5:])
    CB007834_common_keywords.Stop Collect TTitrace and package TTitrace on remote UTE
    ...    uteTTI_ip=${test_info}[tti_uteip]
    ...    uteTTI_username=${test_info}[tti_uteuser]
    ...    uteTTI_password=${test_info}[tti_utepw]
    ...    tti_path=${tti_path}
    CB007834_common_keywords.Teardown TTitrace mirror on BTS

E2E case 1
    Setup TTI for case steps
    Generate And Analyze KPI    case_part=case_1    start_row_index=4    kpi_value_end_col=DU

E2E case 2
    Inter rat ho with VoNR and EMC call
    EPSFB make and hang up
    Generate And Analyze KPI    case_part=case_2    start_row_index=503    kpi_value_end_col=DU

Common Suite Setup For E2E case And Get Suite Time
    Common Suite Setup For E2E case
    @{parts}=    Split String    ${epc_log_path}    /
    Set Suite Variable    ${SUITE_TIMESTAMP}    ${parts}[-2]

Common Suite Teardown For E2E case And Wait For KPI Done
    Common Suite Teardown For E2E case
    Sleep    15m
