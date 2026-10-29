*** Settings ***
Documentation    Author: ming.shi
Suite Setup    Suite prepare
Suite Teardown    Suite end
Test Setup    Test Start trace faults and capture syslog
Test Teardown    Test End trace faults and stop capture syslog

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot

*** Test Cases ***
inter gnb inter freq pingpang ho
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    pa_set_interval_time=${case_test_info}[target_cell][pa_set_interval_time]
    END

intra gnb inter freq pingpang ho
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END


intra gnb intra freq pingpang ho
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END

inter rat pingpang ho
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
    END

intra gnb inter freq pingpang reestablish with VoNR
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${i}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
    END

inter gnb inter freq pingpang reestablish with VoNR
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[VoNR] == True
        make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
    END
    IF    ${case_test_info}[traffic] == True
        IF    ${case_test_info}[traffic_method] == shell_file
            run_sh_file_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
        ELSE IF    ${case_test_info}[traffic_method] == command
            make_traffic_via_commands    yml_file_path=${path}${test_info_file}    case_name=${name}
        END
    END
    FOR    ${i}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
    END

intra gnb inter freq pingpang reestablish with EMC call
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[EMC] == True
        make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
    END
    FOR    ${i}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
    END

inter gnb inter freq pingpang reestablish with EMC call
    [Timeout]    10 hour
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[EMC] == True
        make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
    END
    FOR    ${i}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
        ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
        ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
        Sleep    5s
        Set the attenuation value of ports simultaneously
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        Sleep    5s
    END

loop make and hang up VoNR call on FDD cell
    [Timeout]    10 hour
    Set the attenuation value of ports simultaneously
    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
    ...    values=${case_test_info}[source_cell][cell_ant_value]
    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    FOR    ${i}    IN RANGE    ${case_test_round}
        IF    ${case_test_info}[VoNR] == True
            make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
            ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${2}
        END
        Sleep    5s
        IF    ${case_test_info}[VoNR] == True
            hang_up_vonr_calls    ue_index_list=${ue_index_list}
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${0}
        END
    END

loop make and hang up EMC call on FDD cell
    [Timeout]    10 hour
    Set the attenuation value of ports simultaneously
    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
    ...    values=${case_test_info}[source_cell][cell_ant_value]
    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    FOR    ${i}    IN RANGE    ${case_test_round}
        IF    ${case_test_info}[EMC] == True
            make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${2}
        END
        Sleep    5s
        IF    ${case_test_info}[EMC] == True
            hang_up_emc_calls    ue_index_list=${ue_index_list}
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${0}
        END
    END

loop make and hang up VoNR call on TDD cell
    [Timeout]    10 hour
    Set the attenuation value of ports simultaneously
    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
    ...    values=${case_test_info}[source_cell][cell_ant_value]
    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    FOR    ${i}    IN RANGE    ${case_test_round}
        IF    ${case_test_info}[VoNR] == True
            make_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
            ...    mt_phone_num_list=${case_test_info}[make_vonr][mt_phone_num_list]
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${2}
        END
        Sleep    5s
        IF    ${case_test_info}[VoNR] == True
            hang_up_vonr_calls    ue_index_list=${ue_index_list}
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${0}
        END
    END

loop make and hang up EMC call on TDD cell
    [Timeout]    10 hour
    Set the attenuation value of ports simultaneously
    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
    ...    values=${case_test_info}[source_cell][cell_ant_value]
    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${attach_file_name}    yml_file_name=${test_info_file}
    FOR    ${i}    IN RANGE    ${case_test_round}
        IF    ${case_test_info}[EMC] == True
            make_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${2}
        END
        Sleep    5s
        IF    ${case_test_info}[EMC] == True
            hang_up_emc_calls    ue_index_list=${ue_index_list}
            Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${ue_index_list}    state_code=${0}
        END
    END
