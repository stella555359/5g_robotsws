*** Settings ***
Documentation    SFE HO
Suite Setup    Suite prepare
#Suite Teardown    Suite end
Test Setup    Test Start trace faults and capture syslog
Test Teardown    Test End trace faults and stop capture syslog

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_TL390/bollinger_ue_common_keywords.robot

*** Test Cases ***
[1]CB010701_Syve_B_B3_003_IWK_with_CB006086_for_TF_UL_CA_2CCs_with_3Tx
    [Timeout]    10 hours
    feature CB010701 case steps
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        ping_pang_common_keywords.Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
#    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
#    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
#    ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
#    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    Sleep   10s
    IF    ${case_test_info}[traffic] == True
        run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
    END
    Sleep   30s
    IF    ${case_test_info}[VoNR] == True
#        make_vonr_calls    ue_index_list=${ue_index_list}
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    Sleep   30s
    IF    ${case_test_info}[EMC] == True
#        make_emc_calls    ue_index_list=${ue_index_list}
        make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END
    [Teardown]    Run Keywords
    ...    Test End trace faults and stop capture syslog
    ...    AND    MTK UE recover

[1]CASE2_Syve_CELL1_CELL302_HO_IWK_with_CB010701_for_TF_UL_CA_2CCs_with_3Tx
    [Timeout]    10 hours
    feature CB010701 case steps
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        ping_pang_common_keywords.Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
#    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
#    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
#    ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
#    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    Sleep   10s
    IF    ${case_test_info}[traffic] == True
        run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
    END
    Sleep   30s
    IF    ${case_test_info}[VoNR] == True
#        make_vonr_calls    ue_index_list=${ue_index_list}
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    Sleep   30s
    IF    ${case_test_info}[EMC] == True
#        make_emc_calls    ue_index_list=${ue_index_list}
        make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END
    [Teardown]    Run Keywords
    ...    Test End trace faults and stop capture syslog
    ...    AND    MTK UE recover

[1]CASE3_Syve_CELL1_CELL2_HO_IWK_with_CB010701_for_TF_UL_CA_2CCs_with_3Tx
    [Timeout]    10 hours
    feature CB010701 case steps
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        ping_pang_common_keywords.Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
#    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
#    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
#    ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
#    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    Sleep   10s
    IF    ${case_test_info}[traffic] == True
        run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
    END
    Sleep   30s
    IF    ${case_test_info}[VoNR] == True
#        make_vonr_calls    ue_index_list=${ue_index_list}
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    Sleep   30s
    IF    ${case_test_info}[EMC] == True
#        make_emc_calls    ue_index_list=${ue_index_list}
        make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END
    [Teardown]    Run Keywords
    ...    Test End trace faults and stop capture syslog
    ...    AND    MTK UE recover
