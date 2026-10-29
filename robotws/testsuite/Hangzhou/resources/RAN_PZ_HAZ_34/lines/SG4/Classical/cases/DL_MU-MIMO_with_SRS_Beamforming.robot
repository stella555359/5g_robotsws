*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       taf.ul.power_ue    WITH NAME    ul_power_ue
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/mcs_config.py
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/log_analysis.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
DL_MU-MIMO_with_SRS_Beamforming
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to validate MU-MIMO interaction, check maximal perfromance on RFM
    ...    with maximal Beam steams.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.06.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${scf_path}=${Case_SCF_Path}
    check_mcs_by_csv    scf_path=${scf_path}
    Download and Unzip Gnb Logs Tool
    ${cell_id}    Get Ues Attached Cell    ue_num_each_call=2
    ${cell_list}    Create List    ${cell_id}
    ${ue_index_list}    ${cell_id_list}    Get UE List For Given Cell List    cell_list=${cell_list}
    ...    scf_path=${Case_SCF_Path}    ue_num_each_call=2
    UE L3 CAll and Verfify Tti Log With Loop    ue_index_list=${ue_index_list}    cell_id_list=${cell_id_list}


Download and Unzip Gnb Logs Tool
    [Arguments]    ${tool_path}=/home/ute/
    ${download_file_path}    Set Variable    ${tool_path}/gnb_logs.zip
    log to console    \n Download and Unzip Gnb Logs Tool
    Remove Directory    ${tool_path}/gnb_logs    recursive=${True}
    Remove File    ${tool_path}/gnb_logs.zip
    ${file_url}    Set Variable    https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool/-/raw/main/gnb_logs.zip
    OperatingSystem.Run    cd ${tool_path};wget -O ${download_file_path} ${file_url}
    OperatingSystem.Run    unzip ${tool_path}/gnb_logs.zip -d ${tool_path}
    OperatingSystem.Run    chmod +x ${tool_path}/gnb_logs/*
    OperatingSystem.Run    sed -i 's/^Tti_raw_logs_only = .*/Tti_raw_logs_only = no/' ${tool_path}/gnb_logs/config.ini

Start to captured tti log
    [Arguments]    ${captured_time}=3    ${tool_path}=/home/ute/    ${gnb_index}=0    ${cell_id}=1
    ...    ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    log to console    \n start to captured tti log
    Sleep    5
    ${file_path}    set variable    ${tool_path}/gnb_logs/
    ${cmd}    set variable
    ...    cd ${file_path};./gnb_logs ${gnb_ip} -t ${captured_time} -C ${cell_id}
    ${result}    OperatingSystem.Run    ${cmd}
    ${matches}    Get Regexp Matches    ${result}    Log file:[\\S\\s]*\/(.*zip)    1
    ${zip_log_file_path}    Join Path    ${file_path}    ${matches}[0]
    OperatingSystem.Run    scp ${zip_log_file_path} ${SAVE LOG DIRECTORY}
    [Return]    ${zip_log_file_path}

Verfiy tti log
    [Arguments]    ${zip_log_file_path}    ${pair_percent}=${0.8}    ${direction}=dl
    log to console    \n start to verify tti log ${direction} pair
    ${path}    ${ext}    Split Extension    ${zip_log_file_path}
    ${unzip_path}    ${name}    Split Path    ${path}
    Remove Directory    ${path}    recursive=${True}
    ${result}    OperatingSystem.Run    unzip ${zip_log_file_path} -d ${unzip_path}
    ${matches}    Get Regexp Matches    ${result}    inflating: (.*${direction}__all.csv)    1
    ${tti_log_file}    Set Variable    ${matches[0]}
    check_tti_log_file     tti_log_file=${tti_log_file}    pair_percent=${pair_percent}    direction=${direction}

Generate MUMIMO Peak Information
    [Arguments]    ${cell_list}    ${cell_and_peak_info}    ${mumimo_pair_num}=2    ${duration}=${300}
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_id}    Convert To String    ${cell_id}
        ${peak_info}    Get From Dictionary    ${cell_and_peak_info}    ${cell_id}
        ${peak_dl_tp}    Evaluate    ${peak_info['peak_dl_tp']}*${mumimo_pair_num}
        ${peak_ul_tp}    Evaluate    ${peak_info['peak_ul_tp']}*${mumimo_pair_num}
        Set To Dictionary    ${peak_info}    dl_exp=${peak_dl_tp}
        Set To Dictionary    ${peak_info}    ul_exp=${peak_ul_tp}
        Set To Dictionary    ${peak_info}    peak_dl_tp=${peak_dl_tp}
        Set To Dictionary    ${peak_info}    peak_ul_tp=${peak_ul_tp}
        Set To Dictionary    ${peak_info}    duration=${duration}
        Set To Dictionary    ${cell_and_peak_info}    ${cell_id}=${peak_info}
        Log To Console    new cell_and_peak_info: ${cell_and_peak_info}
    END
    [Return]    ${cell_and_peak_info}

UE L3 CAll and Verfify Tti Log
    [Arguments]  ${ue_index_list}    ${cell_id_list}    ${scf_path}=${Case_SCF_Path}    ${captured_time}=3    ${tool_path}=/home/ute/
    ...    ${duration}=${300}    ${direction}=both    ${reboot_limit_time}=${1}
    ${testline_name}    Get Testline Name
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${path}    ${scf_name}    split path    path=${scf_path}
    ${ue_dl_layer}    get_ue_dl_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_name}
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    scf_name=${scf_name}
    ${cell_and_peak_info}    Generate Peak Information    cell_list=${cell_id_list}
    ...    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}
    ${cell_and_peak_info}    Generate MUMIMO Peak Information    cell_list=${cell_id_list}    cell_and_peak_info=${cell_and_peak_info}
    ...    mumimo_pair_num=2
    ${status}    ${ue_and_cell}    run keyword and ignore error    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    cell_and_peak_info=${cell_and_peak_info}
    ...    scf_path=${scf_path}    attach_cell_id=${cell_id_list[0]}    direction=${direction}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${False}    ${True}
    should be equal as strings    ${status}    PASS    msg=attach failed
    ${zip_log_file_path}    Start to captured tti log    tool_path=${tool_path}    cell_id=${cell_id_list[0]}
    ${status}    ${all_tput}    run keyword and ignore error    UE Verify Peak Throughput    ue_index_list=${ue_index_list}
    ...    ue_and_cell=${ue_and_cell}    cell_and_peak_info=${cell_and_peak_info}
    ...    scf_path=${scf_path}    direction=${direction}    duration=${duration}
    ${ue_reboot_flag}    set variable if    '${status}'=='PASS'    ${ue_reboot_flag}    ${True}
    should be equal as strings    ${status}    PASS    msg=verify throughput failed
    Run Keyword If    '${direction}'=='both'    Run Keywords
    ...    Verfiy tti log    zip_log_file_path=${zip_log_file_path}    direction=dl    AND
    ...    Verfiy tti log    zip_log_file_path=${zip_log_file_path}    direction=ul
    ...    ELSE    Verfiy tti log    zip_log_file_path=${zip_log_file_path}    direction=${direction}
    [Teardown]    run keywords    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
    ...    reboot_ue=${ue_reboot_flag}    reboot_limit_time=${reboot_limit_time}     AND
    ...    Teardown UEs    ue_index_list=${ue_index_list}

UE L3 CAll and Verfify Tti Log With Loop
    [Arguments]  ${ue_index_list}    ${cell_id_list}    ${scf_path}=${Case_SCF_Path}    ${captured_time}=3    ${tool_path}=/home/ute/
    ...    ${duration}=${300}    ${direction}=both    ${reboot_limit_time}=${1}    ${loop_times}=${2}
    ${status}    set variable    PASS
    FOR    ${i}    IN RANGE    ${loop_times}
        log to console    \n***UE L3 CAll and Verfify Tti Log Loop ${i+1}***
        ${status}    ${repr}    run keyword and ignore error    UE L3 CAll and Verfify Tti Log    ue_index_list=${ue_index_list}
        ...    cell_id_list=${cell_id_list}    scf_path=${scf_path}    captured_time=${captured_time}
        ...    tool_path=${tool_path}    duration=${duration}    direction=${direction}
        ...    reboot_limit_time=${reboot_limit_time}
        exit for loop if    '${status}'=='PASS'
    END
    should be true    '${status}'=='PASS'    msg=${repr}
