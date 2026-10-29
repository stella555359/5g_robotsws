*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB009444


Suite Setup    Run keywords    Common Suite Setup for Cloud    AND
...                            Get golden scf path and control parameter    AND
...                            multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
...                            ADD 12810_flag to vdu

Suite Teardown    Run Keyword    check_resources_leakage_aic

#Suite Teardown    Run Keywords
#...                               run keyword and ignore error    Add ue list    AND
#...                               Caculate kpi and write into csv    pm_allvcu_list=${pm_allvcu_list}    pm_allvdu_list=${pm_allvdu_list}    AND
#...                               check_resources_leakage_aic



Resource    ../Resources/HO_common_keywords.robot
Library     ../Resources/get_cloud_counters_from_pm_file.py

*** Variables ***

${traffic_direction}    DLUL
${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${max_attenuation_value}    ${127}
${vendor}    ${tl.attenuators[0].vendor}
${interval}    10
${pa_settime}    0.6
${paerror_counter}    0
${enb1_def_gnb_dist}    MRBTS-$[tl.enbs[0].instance_id}/LNBTS-$[tl.enbs[0].instance_id}/LNCEL-0
${cell_counter_file}    cell_counter.txt
${vcu_counter_file}     vcu_counter.txt
${vdu_counter_file}     vdu_counter.txt
${kpi_list}             SFE_kpi.txt
${csv_file}       /opt/workspace/SCF/SFE_KPI.csv
${ue_info_path}    /opt/workspace/SCF/TL239_ue_traffic_info.yml
${kpi_list_9444W10}       kpi_list_9444W10.txt
${kpi_list_9444N20}       kpi_list_9444N20.txt
${kpi_list_9444N07}       kpi_list_9444N07.txt
${kpi_list_9881SCE4}      kpi_list_9881SCE4.txt
${kpi_list_interRAT}      kpi_list_interRAT.txt

*** Test Cases ***
[1]CB009444_W_10_NSA_Handover_latency_Inter-Gnb_without_SRB3_6_beam
    [Documentation]
    ...    inter freq inter gnb HO gnb1 cell1 to gnb2 cell4
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup
    Check and prepare for gnb    cell_type=NSA
    PA preparation    cell_type=NSA
    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]    cell_type=NSA
    ${ue_num_SCE5}=    Check actual UE num with pc reset
    ${time5_start}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    Prepare with PM counter time caculate    period=start
    Prepare all online UE with data start
    sleep    5s
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell4_pa_info}    s_value=${gnb2_cell4_pa_value}[setup][1]
    ...    e_value=${gnb2_cell4_pa_value}[setup][2]    step=${gnb2_cell4_pa_info}[step][0]    ho_times=${ho_times}
    sleep    5s
    Prepare with PM counter time caculate    period=end
    ${time5_end}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${vcu_counter_file_list_5}    Download new SFE counter from vcu    test_start=${time5_start}    test_end=${time5_end}
    ${vdu_counter_file_list_5}    Download new SFE counter from vdu    test_start=${time5_start}    test_end=${time5_end}
    comment    check counter NR_5730,NR_5731,NR_5034
    ${counter_94444_W_10}    Caculate kpi with kpi_file    pm_allvcu_list=${vcu_counter_file_list_5}
    ...                                                    pm_allvdu_list=${vdu_counter_file_list_5}
    ...                                                    kpi_list=${kpi_list_9444W10}
    [Teardown]    Run Keywords
    ...    CI_interface.Common Case Teardown    AND
    ...    Set Suite Variable    ${ue_num_SCE5}    AND
#    ...    Add pmcounter list    caselist=${vcu_counter_file_list_5}    alllist=${pm_allvcu_list}    AND
#    ...    Add pmcounter list    caselist=${vdu_counter_file_list_5}    alllist=${pm_allvdu_list}    AND
#    ...    Stop all online UE DL data transfer    ue_num=${3}    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul    AND
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
    ...    PA recover    AND
    ...    run keyword and ignore error    Collect CU Snapshot Log

[1]CB009444_N_20_5GC000574_RRM_Verify_SgNB_addition_support_for_inter_MeNB_HO_with_change_in_SCG_configuration_without_Pscell_change
    [Documentation]
    ...    Inter-MeNB (FDD<-->FDD) LTE handover without gNB change, LTE1 cell1  to LTE2 cell1
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK    N20
    [Setup]
    robot_common_operations.Common Case Setup
#    Check and prepare for gnb    cell_type=NSA
#    PA preparation    cell_type=NSA
    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[initial]    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell1_pa_info}    value=${enb1_cell1_pa_value}[setup][0]
    ${ue_num_SCE7}=    Check actual UE num with pc reset
    ${time7_start}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    Prepare with PM counter time caculate    period=start
    Prepare all online UE with data start
    sleep    5s
    Adjust_HBTE_PA with loop    pa_name=${enb2_cell1_pa_info}    s_value=${enb2_cell1_pa_value}[setup][1]
    ...    e_value=${enb2_cell1_pa_value}[setup][2]    step=${enb2_cell1_pa_info}[step][1]    ho_times=${ho_times}
    sleep    5s
    Prepare with PM counter time caculate    period=end
    ${time7_end}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${vcu_counter_file_list_7}    Download new SFE counter from vcu    test_start=${time7_start}    test_end=${time7_end}
    ${vdu_counter_file_list_7}    Download new SFE counter from vdu    test_start=${time7_start}    test_end=${time7_end}
    Comment    M55128C00502
    ${counter_94444_N_20}    Caculate kpi with kpi_file    pm_allvcu_list=${vcu_counter_file_list_7}
    ...                                                    pm_allvdu_list=${vdu_counter_file_list_7}
    ...                                                    kpi_list=${kpi_list_9444N20}
    [Teardown]    Run Keywords
    ...    CI_interface.Common Case Teardown    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Set Suite Variable    ${ue_num_SCE7}    AND
#    ...    Add pmcounter list    caselist=${vcu_counter_file_list_7}    alllist=${pm_allvcu_list}    AND
#    ...    Add pmcounter list    caselist=${vdu_counter_file_list_7}    alllist=${pm_allvdu_list}    AND
#    ...    Stop all online UE DL data transfer    ue_num=${3}    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul    AND
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
    ...    PA recover    AND
    ...    run keyword and ignore error    CU Save Snapshot
#
#
[1]CB009444_N_07_5GC000575_Counter_pegged_on_SgNbModification_during_intraMeNbHO
    [Documentation]
    ...    Intra-MeNB (FDD<-->FDD) LTE handover without gNB change, LTE1 cell1  to LTE1 cell2
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup
#    Check and prepare for gnb    cell_type=NSA
#    PA preparation    cell_type=NSA
    run keyword and ignore error    CU online modify parameters     parameter_cu=nrarfcn
    ...                                                             cu_parameter_value=630700
    ...                                                             dist_name_cu=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
    ...                                                             gnb_index=${0}
    run keyword and ignore error    VDU online modify parameters    dist_name_vdu=MRBTS-${gnb1_id}/NRBTS-${gnb1_id}/NRCELL-2
    ...                                                             parameter_vdu=nrarfcn
    ...                                                             vdu_parameter_value=630700
    ...                                                             gnb_index=${0}    vdu_index=${0}
    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[initial]    cell_type=NSA
    set PA port on one cell    pa_name=${enb1_cell1_pa_info}    value=${enb1_cell1_pa_value}[setup][0]
    ${ue_num_SCE8}=    Check actual UE num with pc reset
    ${time8_start}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    Prepare with PM counter time caculate    period=start
    Prepare all online UE with data start
    sleep    5s
    Adjust_HBTE_PA with loop    pa_name=${enb1_cell2_pa_info}    s_value=${enb1_cell2_pa_value}[setup][1]
    ...    e_value=${enb1_cell2_pa_value}[setup][2]    step=${enb1_cell2_pa_info}[step][1]    ho_times=${ho_times}
    sleep    5s
    Prepare with PM counter time caculate    period=end
    ${time8_end}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${vcu_counter_file_list_8}    Download new SFE counter from vcu    test_start=${time8_start}    test_end=${time8_end}
    ${vdu_counter_file_list_8}    Download new SFE counter from vdu    test_start=${time8_start}    test_end=${time8_end}
    Comment    M55128C00002
    ${counter_94444_N_07}    Caculate kpi with kpi_file    pm_allvcu_list=${vcu_counter_file_list_8}
    ...                                                    pm_allvdu_list=${vdu_counter_file_list_8}
    ...                                                    kpi_list=${kpi_list_9444N07}
    [Teardown]    Run Keywords
    ...    CI_interface.Common Case Teardown    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Set Suite Variable    ${ue_num_SCE8}   AND
#    ...    Add pmcounter list    caselist=${vcu_counter_file_list_8}    alllist=${pm_allvcu_list}    AND
#    ...    Add pmcounter list    caselist=${vdu_counter_file_list_8}    alllist=${pm_allvdu_list}    AND
#    ...    Stop all online UE DL data transfer    ue_num=${3}    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul    AND
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
    ...    PA recover    AND
    ...    run keyword and ignore error    Collect CU Snapshot Log    AND
    ...    run keyword and ignore error    Collect vDU Snapshot Log    AND
    ...    run keyword and ignore error    SCF recovery    celltype=NSA


[1]CB009881_CR_SCE4_SA_Cloud_interfre_intergnb_HO_via_Xn_706
    [Documentation]
    ...    inter freq inter gnb HO gnb1 cell1 to gnb2 cell4
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK
    [Setup]
    CI_interface.Common Case Setup
    Check and prepare for gnb
    PA preparation
    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    ${ue_num_SCE13}=    Check actual UE num with pc reset
    ${time13_start}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    Prepare with PM counter time caculate    period=start
    Prepare all online UE with data start
    sleep    3s
    Make mutil UE for VoNR Setup with special index
    Make mutil UE for EMC Setup with special index
    sleep    1s
    Adjust_HBTE_PA with loop    pa_name=${gnb2_cell4_pa_info}    s_value=${gnb2_cell4_pa_value}[setup][1]
    ...    e_value=${gnb2_cell4_pa_value}[setup][2]    step=${gnb2_cell4_pa_info}[step][1]    ho_times=${ho_times}
    sleep    5s
    Prepare with PM counter time caculate    period=end
    ${time13_end}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${vcu_counter_file_list_13}    Download new SFE counter from vcu    test_start=${time13_start}    test_end=${time13_end}
    ${vdu_counter_file_list_13}    Download new SFE counter from vdu    test_start=${time13_start}    test_end=${time13_end}
    Comment    NR_5206,M55147C00503
    ${counter_9881_SCE4}    Caculate kpi with kpi_file    pm_allvcu_list=${vcu_counter_file_list_13}
    ...                                                    pm_allvdu_list=${vdu_counter_file_list_13}
    ...                                                    kpi_list=${kpi_list_9881SCE4}
    [Teardown]    Run Keywords
    ...    CI_interface.Common Case Teardown    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Set Suite Variable    ${ue_num_SCE13}    AND
#    ...    Add pmcounter list    caselist=${vcu_counter_file_list_13}    alllist=${pm_allvcu_list}    AND
#    ...    Add pmcounter list    caselist=${vdu_counter_file_list_13}    alllist=${pm_allvdu_list}    AND
    ...    hang up mutil UE for VoNR Setup    AND
    ...    hang up mutil UE for EMC Setup    AND
#    ...    Stop all online UE DL data transfer    ue_num=${3}    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul    AND
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]    AND
    ...    PA recover    AND
    ...    run keyword and ignore error    Collect CU Snapshot Log

[1]SFE_707_711_inter-rat_handover_between_5G_and_4G
    [Documentation]
    ...    inter-rat handover
    [Timeout]     120 minutes
    [Tags]    CRT_TRUNK
    [Setup]
#    Check and prepare for gnb
#    PA preparation
    Check GNB status and collect logs    vcu_ALLOWED_FAULT=${vcu_ALLOWED_FAULT}    vdu_ALLOWED_FAULT=${vdu_ALLOWED_FAULT}
    set all PA ports and one cell set designated value    pa_name=${gnb1_cell1_pa_info}    value=${gnb1_cell1_pa_value}[setup][0]
    ${ue_num_18}=    Check actual UE num with pc reset
    ${time18_start}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    Prepare with PM counter time caculate    period=start
    Prepare all online UE with UL and DL data start
    sleep    5s
    Adjust_HBTE_PA with loop    pa_name=${enb1_cell1_pa_info}    s_value=${enb1_cell1_pa_value}[setup][1]
    ...    e_value=${enb1_cell1_pa_value}[setup][2]    step=${enb1_cell1_pa_info}[step][1]    ho_times=${ho_times}
    sleep    5s
    Prepare with PM counter time caculate    period=end
    ${time18_end}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${vcu_counter_file_list_18}    Download new SFE counter from vcu    test_start=${time18_start}    test_end=${time18_end}
    ${vdu_counter_file_list_18}    Download new SFE counter from vdu    test_start=${time18_start}    test_end=${time18_end}
    Comment    M55125C02002,
    ${counter_inter_RAT}    Caculate kpi with kpi_file    pm_allvcu_list=${vcu_counter_file_list_18}
    ...                                                    pm_allvdu_list=${vdu_counter_file_list_18}
    ...                                                    kpi_list=${kpi_list_interRAT}
    [Teardown]    Run Keywords
    ...    Set Suite Variable    ${ue_num_18}   AND
#    ...    Add pmcounter list    caselist=${vcu_counter_file_list_18}    alllist=${pm_allvcu_list}    AND
#    ...    Add pmcounter list    caselist=${vdu_counter_file_list_18}    alllist=${pm_allvdu_list}    AND
#    ...    Stop all online UE DL data transfer    ue_num=${3}    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=dl    AND
    ...    stop_traffic_multi_ue    file_path=${ue_info_path}    direction=ul    AND
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[1]      AND
    ...    PA recover    AND
    ...    run keyword and ignore error    CU Save Snapshot    AND
    ...    run keyword and ignore error    Collect vDU Snapshot Log    AND
    ...    SCF recovery



*** Keywords ***
Add time list
    ${time1_start}    Get Variable Value    ${time1_start}
    ${time1_end}    Get Variable Value    ${time1_end}
    ${time2_start}    Get Variable Value    ${time2_start}
    ${time2_end}    Get Variable Value    ${time2_end}
    ${time3_start}    Get Variable Value    ${time3_start}
    ${time3_end}    Get Variable Value    ${time3_end}
    ${time4_start}    Get Variable Value    ${time4_start}
    ${time4_end}    Get Variable Value    ${time4_end}
    ${time5_start}    Get Variable Value    ${time5_start}
    ${time5_end}    Get Variable Value    ${time5_end}
    ${time6_start}    Get Variable Value    ${time6_start}
    ${time6_end}    Get Variable Value    ${time6_end}
    ${time7_start}    Get Variable Value    ${time7_start}
    ${time7_end}    Get Variable Value    ${time7_end}
    ${time8_start}    Get Variable Value    ${time8_start}
    ${time8_end}    Get Variable Value    ${time8_end}
    Append To List    ${list_}    ${time1_start}    ${time1_end}    ${time2_start}    ${time2_end}    ${time3_start}    ${time3_end}
    ...    ${time4_start}    ${time4_end}    ${time5_start}    ${time5_end}    ${time6_start}    ${time6_end}    ${time7_start}    ${time7_end}
    ...    ${time8_start}    ${time8_end}
    @{list}    replace_value_from_list    ${list_}
    Set Suite Variable    @{list}

Add pmcounter list
    [Arguments]    ${caselist}    ${alllist}
    ${p_lenth}=    Get Length    ${caselist}
    FOR    ${i}    IN RANGE    ${p_lenth}
      Append To List    ${alllist}    ${caselist}[${i}]
    END



Add UE list
    ${ue_num_SCE1}    Get Variable Value    ${ue_num_SCE1}
    ${ue_num_SCE2}    Get Variable Value    ${ue_num_SCE2}
    ${ue_num_SCE3}    Get Variable Value    ${ue_num_SCE3}
    ${ue_num_SCE4}    Get Variable Value    ${ue_num_SCE4}
    ${ue_num_SCE5}    Get Variable Value    ${ue_num_SCE5}
    ${ue_num_SCE6}    Get Variable Value    ${ue_num_SCE6}
    ${ue_num_SCE7}    Get Variable Value    ${ue_num_SCE7}
    ${ue_num_SCE8}    Get Variable Value    ${ue_num_SCE8}
    ${ue_num_SCE11}    Get Variable Value    ${ue_num_SCE11}
    ${ue_num_SCE12}    Get Variable Value    ${ue_num_SCE12}
    ${ue_num_SCE13}    Get Variable Value    ${ue_num_SCE13}
    ${ue_num_SCE14}    Get Variable Value    ${ue_num_SCE14}
    ${ue_num_SCE15}    Get Variable Value    ${ue_num_SCE15}
    ${ue_num_SCE16}    Get Variable Value    ${ue_num_SCE16}
    ${ue_num_SCE17}    Get Variable Value    ${ue_num_SCE17}
    ${ue_num_SCE18}    Get Variable Value    ${ue_num_SCE18}
    Append to list    ${ue_list_}    ${ue_num_SCE2}    ${ue_num_SCE3}    ${ue_num_SCE6}    ${ue_num_SCE5}    ${ue_num_SCE4}
    ...    ${ue_num_SCE1}    ${ue_num_SCE7}    ${ue_num_SCE8}    ${ue_num_SCE12}    ${ue_num_SCE13}    ${ue_num_SCE16}    ${ue_num_SCE15}
    ...    ${ue_num_SCE14}    ${ue_num_SCE11}    ${ue_num_SCE17}    ${ue_num_SCE18}
    @{ue_num_list}    replace_value_from_list    ${ue_list_}
    Set Suite Variable    @{ue_num_list}
