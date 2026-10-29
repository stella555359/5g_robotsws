*** Settings ***
Documentation
...    author: Yan Xin
...    contact: xin.yan@nokia-sbell.com
...    squad group: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS <I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02@internal.nsn.com>

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library       ./CB008021_Counter_Keywords.py
Variables     ./CB008021_Parameters.py

*** Variables ***
${tl_undertest_index}             0
${gnb_undertest_connection}       GNB_OAM_${tl_undertest_index}
${ue_undertest_type}              ${tl.ues[${tl_undertest_index}].capabilities[0]}
${gnb_undertest_ip}               ${tl.gnbs[${tl_undertest_index}].dus[0].f1_m_ip_addr}
${gnb_undertest_username}         ${tl.gnbs[${tl_undertest_index}].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_undertest_password}         ${tl.gnbs[${tl_undertest_index}].dus[0].airscale.common_units[0].lmp_connection.password}
${tl_noise_index}                 1
${gnb_noise_connection}           GNB_OAM_${tl_noise_index}
${ue_noise_type}                  ${tl.ues[${tl_noise_index}].capabilities[0]}
${gnb_noise_ip}                   ${tl.gnbs[${tl_noise_index}].dus[0].f1_m_ip_addr}
${period}                         ${5}    # min, same with minNrRip set
${file_count}                     ${3}
${throughput_undertest}           100M
${throughput_noise}               20M
${throughput_multi_cell}          5M
${infinite_duration}              ${9999}
${wait_counter_generate_time}     30s
${wait_parameter_update_time}     ${360}  # seconds
${gnb_path}                       /tmp
${local_path}                     /home/ute
${avg_counter_high_std_limit}     ${-112}  # dBm
${max_counter_high_std_limit}     ${-92}  # dBm
${max_counter_high_ext_limit}     ${-87}  # dBm
${max_avg_diff_limit}             ${15}  # dBm
${tdd_counter_low_limit}          ${-118.5}  # dBm
${filter_out_of_range}            ${0.05}

*** Keywords ***
Test Suite Setup
    CI_interface.Common Suite Setup    gnb_index=${tl_undertest_index}
    CI_interface.Common Suite Setup    gnb_index=${tl_noise_index}
    Connect to gnb coam via ssl    connection=${gnb_undertest_connection}    gnb_index=${tl_undertest_index}
    Connect to gnb coam via ssl    connection=${gnb_noise_connection}    gnb_index=${tl_noise_index}
    power_ue.Prepare UE    ue_index=${tl_undertest_index}    ue_type=${ue_undertest_type}
    power_ue.Prepare UE    ue_index=${tl_noise_index}    ue_type=${ue_noise_type}

Test Suite Teardown
    COAM Teardown gnb connections    connection=${gnb_undertest_connection}
    COAM Teardown gnb connections    connection=${gnb_noise_connection}
    Run Keyword And Ignore Error    run    rm -rf ${local_path}/PM.BTS-${gnb_undertest_mrbtsid}.*
    Run Keyword And Ignore Error    run    rm -rf ${local_path}/PM.BTS-${gnb_noise_mrbtsid}.*
    CI_interface.Common Case Teardown

UE attach and verify for TL
    [Arguments]    ${tl_index}=${tl_undertest_index}
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${tl_index}    ue_type=${ue_type}
    power_ue.Verify attach    ue_index=${tl_index}    ue_type=${ue_type}    gnb_index=${tl_index}
    ...                       5Grach_ed=${5Grach_ed_0}    4G_check=False

UE detach for TL
    [Arguments]    ${tl_index}=${tl_undertest_index}
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    power_ue.UE Detach    ue_index=${tl_index}    ue_type=${ue_type}

Start traffic for TL
    [Arguments]    ${throughput}=${throughput_undertest}    ${tl_index}=${tl_undertest_index}    ${direction}=both
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    Run Keyword If    '${direction}' == 'both'    Run Keywords
    ...               power_ue.Start traffic    ue_index=${tl_index}    ue_type=${ue_type}    direction=ul
    ...                                         throughput=${throughput}    iperf_type=via_command
    ...                                         duration=${infinite_duration}    protocol=udp
    ...        AND    power_ue.Start traffic    ue_index=${tl_index}    ue_type=${ue_type}    direction=dl
    ...                                         throughput=${throughput}    iperf_type=via_command
    ...                                         duration=${infinite_duration}    protocol=udp
    ...       ELSE    power_ue.Start traffic    ue_index=${tl_index}    ue_type=${ue_type}    direction=${direction}
    ...                                         throughput=${throughput}    iperf_type=via_command
    ...                                         duration=${infinite_duration}    protocol=udp

Stop traffic for TL
    [Arguments]    ${tl_index}=${tl_undertest_index}    ${direction}=both
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    Run Keyword If    '${direction}' == 'both'    Run Keywords
    ...               power_ue.Stop traffic    direction=ul   ue_index=${tl_index}
    ...                                        ue_type=${ue_type}    iperf_type=via_command
    ...        AND    power_ue.Stop traffic    direction=dl   ue_index=${tl_index}
    ...                                        ue_type=${ue_type}    iperf_type=via_command
    ...       ELSE    power_ue.Stop traffic    direction=${direction}    ue_index=${tl_index}
    ...                              ue_type=${ue_type}    iperf_type=via_command

Ue attach and Make traffic for TL
    [Arguments]    ${throughput}=${throughput_undertest}    ${tl_index}=${tl_undertest_index}    ${direction}=both
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    UE attach and verify for TL    tl_index=${tl_index}
    Start traffic for TL    tl_index=${tl_index}    direction=${direction}    throughput=${throughput}

Stop traffic and Detach UE for TL
    [Arguments]    ${tl_index}=${tl_undertest_index}    ${direction}=both
    ${ue_type}    Set Variable If    ${tl_index} == ${tl_undertest_index}    ${ue_undertest_type}    ${ue_noise_type}
    Stop traffic for TL    tl_index=${tl_index}    direction=${direction}
    power_ue.UE Detach    ue_index=${tl_index}    ue_type=${ue_type}

Sleep to wait for counter generate
    [Arguments]    ${interval}=${period}    ${is_add_one_period}=False
    ${sleep_time}    get_sleep_time_waiting_for_counter_create    interval=${interval}
    ${sleep_time}=    Run Keyword If    '${is_add_one_period}' == 'True'    Evaluate    ${sleep_time}+${interval}
    ...               ELSE    Evaluate    ${sleep_time}+0
    log to console    sleep ${sleep_time} mins to wait for expected counter generate...
    Sleep    ${sleep_time}min

Get SCF path as stream
    [Arguments]    ${connection}=${gnb_undertest_connection}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}

    @{result}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    Set Variable If    '${result[2]}' == '9999'    SBTS00    ${result[0]}
    ${short_pucch_scf_path}    Set Variable    ${commissionings_path}/HGZ/${testline_name}/SCF_${stream}_gnb1_SF.xml
    [return]    ${short_pucch_scf_path}

Get PM counter value list
    [Arguments]    ${target_list}    ${pm_file}
    ${counter_value_dict}    get_counter_value_from_counter_file    ${pm_file}    ${target_list}
    ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
    [return]    ${counter_value_list}

Get list average value
    [Arguments]    ${target_list}    ${pm_file}
    ${plan_number}    Get Length    ${target_list}
    ${counter_value_list}    Get PM counter value list    target_list=${target_list}    pm_file=${pm_file}
    ${average_value}    ${scheduled_number}    calculate_average_except_zero_value    value_list=${counter_value_list}
    log to console    avg value is ${average_value}, plan prb number is ${plan_number}, scheduled prb number is ${scheduled_number}
    [return]    ${average_value}

Get list value and sorted
    [Arguments]    ${target_list}    ${pm_file}
    ${plan_number}    Get Length    ${target_list}
    ${counter_value_list}    Get PM counter value list    target_list=${target_list}    pm_file=${pm_file}
    ${sorted_value_list}    ${scheduled_number}    sorted_list_except_zero_value    value_list=${counter_value_list}
    log to console   list sorted from largest to smallest, plan prb number is ${plan_number}, scheduled prb number is ${scheduled_number}
    [return]    ${sorted_value_list}

Download and unzip counter file
    [Arguments]    ${zip_file}
    ...            ${hostname}=${gnb_undertest_ip}
    csn.Connect To    hostname=${hostname}     username=${gnb_undertest_username}
    ...               password=${gnb_undertest_password}    alias=gnb
    Wait Until Keyword Succeeds    1min    10sec    csn.download_file    remote_path=${gnb_path}/${zip_file}
    ...                                             local_path=${local_path}/${zip_file}    connection=gnb
    csn.Disconnect    connection=gnb
    unzip_counter_file    ${local_path}/${zip_file}

Get PM counter file
    [Arguments]    ${mrbtsid}=${gnb_undertest_mrbtsid}
    ...            ${interval}=${period}
    ...            ${hostname}=${gnb_undertest_ip}
    ${target_time}    get_pm_counter_time_for_file    interval=${interval}
    Sleep    ${wait_counter_generate_time}    # counter may not be generated on BTS when just pass target time
    ${filename}=    Catenate    SEPARATOR=    PM.    BTS-    ${mrbtsid}.    ${target_time}    .ANY.xml
    log to console    get file name is ${filename}
    ${zipfilename}=    Catenate    SEPARATOR=    ${filename}    .gz
    Download and unzip counter file    zip_file=${zipfilename}    hostname=${hostname}
    [return]    ${filename}

Get PM counter avg value
    [Arguments]    ${interval}=${period}
    ...            ${avg_counter_list}=${AVG_COUNTER_LIST}
    ...            ${max_counter_list}=${MAX_COUNTER_LIST}
    ...            ${mrbtsid}=${gnb_undertest_mrbtsid}
    ${hostname}    Set Variable If    ${mrbtsid} == ${gnb_undertest_mrbtsid}    ${gnb_undertest_ip}    ${gnb_noise_ip}
    ${filename}    Get PM counter file    mrbtsid=${mrbtsid}    interval=${interval}    hostname=${hostname}
    ${avg_counter_avg_value}    Get list average value    target_list=${avg_counter_list}    pm_file=${local_path}/${filename}
    ${max_counter_avg_value}    Get list average value    target_list=${max_counter_list}    pm_file=${local_path}/${filename}
    [return]    ${avg_counter_avg_value}    ${max_counter_avg_value}

Get sorted list from PM counter list
    [Arguments]    ${interval}=${period}
    ...            ${mrbtsid}=${gnb_undertest_mrbtsid}
    ${hostname}    Set Variable If    ${mrbtsid} == ${gnb_undertest_mrbtsid}    ${gnb_undertest_ip}    ${gnb_noise_ip}
    ${filename}    Get PM counter file    mrbtsid=${mrbtsid}    interval=${interval}    hostname=${hostname}
    log to console    begin to get average counters max value ...
    ${avg_counter_list}    Get list value and sorted    target_list=${AVG_COUNTER_LIST}    pm_file=${local_path}/${filename}
    log to console    begin to get maximum counters max value ...
    ${max_counter_list}    Get list value and sorted    target_list=${MAX_COUNTER_LIST}    pm_file=${local_path}/${filename}
    [return]    ${avg_counter_list}    ${max_counter_list}

Check counter max value in range
    [Arguments]    ${avg_counter_list}    ${max_counter_list}
    ${avg_counter_len}    Get Length    ${avg_counter_list}
    ${max_counter_len}    Get Length    ${max_counter_list}
    Should Not Be Equal    ${avg_counter_len}    ${0}
    Should Not Be Equal    ${max_counter_len}    ${0}
    Should Be True    ${avg_counter_len} == ${max_counter_len}
    ${filter_counter_index}    Evaluate    int(${avg_counter_len}*${filter_out_of_range}-1)
    ${max_counter_diff_limit}    Evaluate    ${avg_counter_list[${filter_counter_index}]}+${max_avg_diff_limit}
    Should Be True    ${max_counter_diff_limit} <= ${max_counter_high_ext_limit}
    Run Keyword If    ${avg_counter_list[${filter_counter_index}]} > ${avg_counter_high_std_limit}
    ...               Should Be True    ${max_counter_list[${filter_counter_index}]} <= ${max_counter_diff_limit}
    ...       ELSE    Should Be True    ${max_counter_list[${filter_counter_index}]} <= ${max_counter_high_std_limit}
    Should Be True    ${avg_counter_list[-1]} >= ${tdd_counter_low_limit}
    Should Be True    ${max_counter_list[-1]} >= ${tdd_counter_low_limit}
