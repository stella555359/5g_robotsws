*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
L3 Call Both NR and LTE
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${lte_dl_tp}    ${lte_ul_tp}
    ...    ${target_avg_percent}=0.3    ${min_percent}=0.1    ${duration}=60
    ...    ${log}=${SAVE LOG DIRECTORY}    ${scf_path}=${Case_SCF_Path}    ${gnb_ssl_connection}=GNB_OAM
    ${ue_info_dict}    create dictionary
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    ${nr_ue_index_list}    ${nr_cell_list}    Obtain UE List for Given Cell List    cell_list=${nr_cell_id_list}
    ...    scf_path=${scf_path}    mobile_network_system=NR
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    ${lte_ue_index_list}    ${lte_cell_list}    Obtain UE List for Given Cell List    cell_list=${lte_cell_id_list}
    ...    scf_path=${scf_path}    mobile_network_system=LTE
    ${ue_index_list}    combine lists    ${nr_ue_index_list}    ${lte_ue_index_list}
    Simple Ue Prepare    ue_index_list=${nr_ue_index_list}    scf_path=${scf_path}    mobile_network_system=NR
    Simple Ue Prepare    ue_index_list=${lte_ue_index_list}    scf_path=${scf_path}    mobile_network_system=LTE
    Simple Ue Attach    ue_index_list=${nr_ue_index_list}    log_type=Aasyslog    scf_path=${scf_path}    power_reset=${True}
    Simple Ue Attach    ue_index_list=${lte_ue_index_list}    log_type=Iperf    scf_path=${scf_path}    power_reset=${True}
    ${ue_num}    get length    ${ue_index_list}
    ${start_traffic_duration}    evaluate    ${duration}+${ue_num}*240
    ${nr_dl_tp}    ${nr_ul_tp}    Get NR Theoretical Throughput    scf_path=${scf_path}
    ${nr_start_traffic_dl}    evaluate    ${nr_dl_tp}*1.15
    ${nr_start_traffic_ul}    evaluate    ${nr_ul_tp}*1.25
    Simple Ue Start DL UL Traffic    ue_index_list=${nr_ue_index_list}    dl_tp=${nr_start_traffic_dl}    ul_tp=${nr_start_traffic_ul}
    ...    duration=${start_traffic_duration}
    ${lte_start_traffic_dl}    evaluate    ${lte_dl_tp}*1.15
    ${lte_start_traffic_ul}    evaluate    ${lte_ul_tp}*1.25
    Simple Ue Start DL UL Traffic    ue_index_list=${lte_ue_index_list}    dl_tp=${lte_start_traffic_dl}    ul_tp=${lte_start_traffic_ul}
    ...    duration=${start_traffic_duration}
    ${tput_log}    Simple Ue Collect Tput    ue_index_list=${nr_ue_index_list}    check_source=Aasyslog    duration=${duration}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_ssl_connection}
    ${cell_id}    Convert To String    ${cell_mapping[${nr_cell_list[0]}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    Simple Ue Stop DL UL Traffic    ue_index_list=${ue_index_list}
    Simple UE Verify Peak Throughput    ue_index_list=${nr_ue_index_list}    dl_tp=${nr_dl_tp}    ul_tp=${nr_ul_tp}
    ...    log=${tput_log}    check_source=Aasyslog    cells=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Simple UE Verify Peak Throughput    ue_index_list=${lte_ue_index_list}    dl_tp=${lte_dl_tp}    ul_tp=${lte_ul_tp}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    log=${log}    scf_path=${scf_path}    mobile_network_system=LTE
    Simple Ue Detach    ue_index_list=${ue_index_list}

Get Branch for Puchprb
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${sw_version}    coam.get_sw_version    connection=${connection}
    ${status}    run keyword and return status    should contain    ${sw_version}    _9999_
    ${branch}    run keyword if    ${status}    set variable    None
    ...    ELSE    Get Regexp Matches    ${sw_version}    SBTS(.*)_ENB   1
    [Return]  ${branch}

Get NR Theoretical Throughput
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${scf_path}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${ue_dl_layer}    get_ue_dl_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_path}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_path}
    ${branch}    Get Branch for Puchprb
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    ${nr_dl_tp}    ${nr_ul_tp}    get_theoretical_throughput    scf_path=${SCF_Path}
    ...                                                         cell_id=${nr_cell_id_list[0]}
    ...                                                         ue_dl_layer=${ue_dl_layer}
    ...                                                         ue_ul_layer=${ue_ul_layer}
    ...                                                         branch=${branch}
    [Return]  ${nr_dl_tp}    ${nr_ul_tp}
