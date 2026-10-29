*** Settings ***
Documentation    use gnb_logs to capture logs, include tti ,bip.
...              Author: Lin Stella
...              Squard: HZ SG6

Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library     taf.collectors.core    WITH NAME    core
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot

*** Variables ***
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_L2_PS_CONFIG}           &{TTITRACE_CONFIG_L2PS}
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1

*** Keywords ***
Capture Logs With gNB_logs
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ...            ${cell_index}=1
    ...            ${timeout}=1800
    ...            ${tti_log_option}=t
    log to console    --- start gnb_logs collection---
    Log    ${du_index}
    ${log_type_to_command_mapping}    Create Dictionary    TTI=${tti_log_option}    BIP=b   m=m    L2PS=o l2ps
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&sudo rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate    sudo ./gnb_logs ${gnb_ip} -c${bbmod_slots} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${start_l2ps_capture_command}     Catenate
    ...                     sudo ./gnb_logs ${gnb_ip} -c${bbmod_slots} -C ${cell_index} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${start_capture_command}    set variable if    "${log_type}"=="L2PS"    ${start_l2ps_capture_command}    ${start_capture_command}
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=${timeout}   connection=ute
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=ute    AND
    ...    Run Keyword And Ignore Error    run    command=killall *gnb_logs*

Capture Mix Logs With gNB_logs
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=15
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=-T -b -s
    ...            ${cell_index}=1
    ...            ${timeout}=600
    log to console    --- start gnb_logs collection---
    Log Many    ${du_index}    ${cell_index}
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&sudo rm *m.zip   connection=ute
    ${start_capture_command}     Catenate    sudo ./gnb_logs ${gnb_ip} -c${bbmod_slots} ${log_type} ${duration}
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=${timeout}   connection=ute
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=ute    AND
    ...    Run Keyword And Ignore Error    run    command=killall *gnb_logs*

Get Captured Mixed File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    log to console    --- start to Download mixed file result to specific folder ---
    Log    ${du_index}
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_m.zip    ${target_dir}
    [Teardown]    Run Keyword And Ignore Error    Run    sudo rm -rf ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_m.zip

Get Specific Direction TTItrace File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${direction}=ul
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ...            ${remove_files_needed}=${False}
    ...            ${move_tti_zip_file}=${True}
    ...            ${tti_package_file_name}=tti
    Log    ${du_index}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${specific_ttitrace_file_list}    Create List
    log to console    --- start to Download tti trace result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    @{ttitrace_files}    List Files In Directory	${gnb_logs_script_path}	   BTS*_${gnb_ip}_*_${log_type}.zip
    Run Keyword If    ${remove_files_needed}    Remove Directory    ${target_dir}    recursive=true
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*.zip    ${target_dir}
#    FOR    ${ttitrace_file}    IN    @{ttitrace_files}
#        ${file_name}    Set Variable    ${ttitrace_file.split('.zip')[0]}
#        Run    unzip ${target_dir}/${ttitrace_file} -d ${target_dir}
#        Run    cd ${target_dir}/${file_name}/tti_packed/fsp-*_ttiTrace/
#        Copy Files    *.${direction}__all.csv
#        ...           ${target_dir}/${direction}_ttitrace_result_${timestamp}
#    END
    ${all_fsp_files}    Create List
    FOR    ${ttitrace_file}    IN    @{ttitrace_files}
        ${file_name}    Set Variable    ${ttitrace_file.split('.zip')[0]}
        Run    unzip ${target_dir}/${ttitrace_file} -d ${target_dir}

        ${fsp_file}    List Directories In Directory	${target_dir}/${file_name}/${tti_package_file_name}/
        ...                                             *_ttiTrace
        ...                                             absolute=${True}
        ${all_fsp_files}    Combine Lists     ${fsp_file}    ${all_fsp_files}
    END
    FOR    ${fsp_file}    IN    @{all_fsp_files}
        ${specific_ttitrace_file}    List Files In Directory	${fsp_file}
        ...                                                     *.${direction}__all.csv
        ...                                                     absolute=${True}
        ${specific_ttitrace_file_list}    Combine Lists     ${specific_ttitrace_file}    ${specific_ttitrace_file_list}
    END
    log to console    specific ttitrace file list : ${specific_ttitrace_file_list}
    [Return]    ${specific_ttitrace_file_list}
    [Teardown]    Run Keyword And Ignore Error    Run Keyword If    ${move_tti_zip_file}
    ...                                           Run    sudo rm ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_${log_type}.zip

Get Captured BIP File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    Log    ${du_index}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    @{bip_files}    List Files In Directory	${gnb_logs_script_path}	   BTS*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*.zip    ${target_dir}
#    FOR    ${bip_file}    IN    @{bip_files}
#        ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
#        Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
#        Copy Files    ${target_dir}/${file_name}/*Bip*.pcap
#        ...           ${target_dir}/bip_result_${timestamp}
#    END
    FOR    ${bip_file}    IN    @{bip_files}
        ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
        Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
        @{internal_dir} =    OperatingSystem.List Directories In Directory    ${target_dir}/${file_name}
        ${isEmpty}    Run Keyword And Return Status       should be empty       ${internal_dir}
        ${bip_dir}    set variable if    ${isEmpty}      ${target_dir}/${file_name}   ${target_dir}/${file_name}/${internal_dir}[0]
        ${specific_bip_file}    List Files In Directory    ${bip_dir}
        ...                                                *Bip*.pcap*
        ...                                                absolute=${True}
        ${all_bip_file_list}     Combine Lists     ${specific_bip_file}    ${all_bip_file_list}
    END
    log to console    all captured bip file list : ${all_bip_file_list}
    [Return]    ${all_bip_file_list}
    [Teardown]    Run Keyword And Ignore Error    Run    sudo rm ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_${log_type}.zip

Get Deployment Result
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=GNB_${gnb_index}
    ${output}    ssh.execute    command=cat /ram/NrCellMappingInfo.txt    connection=GNB_${gnb_index}
    ${valid_lines}    Get Lines Matching Regexp    ${output}    DL    partial_match=true
    @{valid_lines}    Split To Lines    ${valid_lines}
    ${deployment_result}    Create Dictionary
    FOR    ${line}    IN    @{valid_lines}
        ${line}    Set Variable    ${line.strip()}
        ${elements}    Get Regexp Matches    ${line}    \\S+
        ${cell_index}    Set Variable    ${elements[0]}
        ${nrcell_identity}    Set Variable    ${elements[2]}
        ${pci}    Set Variable    ${elements[3]}
        ${l2ps}    Set Variable    ${elements[4].split('x')[-1]}
        ${L1}    Set Variable    ${elements[9].split('x')[-1]}
        ${sub_dict}    Create Dictionary    l2ps=${l2ps}    L1=${L1}    pci=${pci}    nrCellIdentity=${nrcell_identity}
        Set to Dictionary    ${deployment_result}   ${cell_index}    ${sub_dict}
    END
    [Return]    ${deployment_result}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=GNB_${gnb_index}

Get Specific TTItrace File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_index}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${direction}=ul
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=TTI
    ...            ${remove_files_needed}=${False}
    ...            ${move_tti_zip_file}=${True}
    ...            ${tti_package_file_name}=tti
    ${tti_file_list}    Get Specific Direction TTItrace File    gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                         target_dir=${target_dir}
    ...                                                         direction=${direction}
    ...                                                         gnb_index=${gnb_index}
    ...                                                         du_index=${du_index}
    ...                                                         log_type=${log_type}
    ...                                                         remove_files_needed=${remove_files_needed}
    ...                                                         move_tti_zip_file=${move_tti_zip_file}
    ...                                                         tti_package_file_name=${tti_package_file_name}
    ${deployment_ret}    Get Deployment Result    gnb_index=${gnb_index}    du_index=${du_index}
    ${l2_instance}    Set Variable    ${deployment_ret['${cell_index}']['l2ps']}
    ${specific_ttitrace_file_list}    Evaluate    list(filter(lambda x:'${l2_instance}_TTI' in x,${tti_file_list}))
    ${file_length}    Get Length    ${specific_ttitrace_file_list}
    Should Be True    ${file_length}>=${1}    msg=ttitrace is not captured properly.
    log to console    specific ttitrace file list : ${specific_ttitrace_file_list}
    [Return]    ${specific_ttitrace_file_list}

Get Specific BIP File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    ...            ${bbmod_slots}=1
    ...            ${cell_index}=1
    Log Many    ${du_index}    ${cell_index}
    ${bip_file_list}    Get Captured BIP File    gnb_logs_script_path=${gnb_logs_script_path}
    ...                                          target_dir=${target_dir}
    ...                                          gnb_index=${gnb_index}
    ...                                          du_index=${du_index}
    ...                                          log_type=${log_type}
#    ${deployment_ret}    Get Deployment Result    gnb_index=${gnb_index}    du_index=${du_index}
#    ${l1_instance}    Set Variable    ${deployment_ret['${cell_index}']['L1']}
    ${specific_bip_file_list}    Evaluate    list(filter(lambda x: 'ABIO${bbmod_slots}' or 'ABIL${bbmod_slots}' in x,${bip_file_list}))
    ${file_length}    Get Length    ${specific_bip_file_list}
    Should Be True    ${file_length}>=${1}    msg=BIP log is not captured properly.
    log to console    specific captured bip file list : ${specific_bip_file_list}
    [Return]    ${specific_bip_file_list}


Get Specific L2PS File
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_index}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${direction}=ul
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=L2Trace
    ...            ${remove_files_needed}=${False}
    Log Many    ${cell_index}    ${gnb_logs_script_path}    ${du_index}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${specific_l2trace_file_list}    Create List
    log to console    --- start to Download tti trace result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    @{l2trace_files}    List Files In Directory	${gnb_logs_script_path}	   BTS*_${gnb_ip}_*_${log_type}.zip
    Run Keyword If    ${remove_files_needed}    Remove Directory    ${target_dir}    recursive=true
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*.zip    ${target_dir}
    ${ul_l2ps_files_list}    Create List
    ${dl_l2ps_files_list}    Create List
    ${all_l2ps_files_list}    Create List
    FOR    ${l2trace_file}    IN    @{l2trace_files}
        ${file_name}    Set Variable    ${l2trace_file.split('.zip')[0]}
        Run    unzip ${target_dir}/${l2trace_file} -d ${target_dir}
        ${ul_l2ps_file}    List Files In Directory    ${target_dir}/${file_name}/L2_trace/tti_packed/
        ...                                             *.ul__all.csv
        ...                                             absolute=${True}
        ${ul_l2ps_files_list}    Combine Lists     ${ul_l2ps_file}    ${ul_l2ps_files_list}
        ${all_l2ps_files_list}    Combine Lists     ${ul_l2ps_file}    ${all_l2ps_files_list}
        ${dl_l2ps_file}    List Files In Directory    ${target_dir}/${file_name}/L2_trace/tti_packed/
        ...                                             *.dl__all.csv
        ...                                             absolute=${True}
        ${dl_l2ps_files_list}    Combine Lists     ${dl_l2ps_file}    ${dl_l2ps_files_list}
        ${all_l2ps_files_list}    Combine Lists     ${dl_l2ps_file}    ${all_l2ps_files_list}
    END
    log to console    specific L2PStrace file list : ${${direction}_l2ps_files_list}
    [Return]    ${${direction}_l2ps_files_list}
    [Teardown]    Run Keyword And Ignore Error    Run    sudo rm ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_${log_type}.zip

Capture TTI with gnb logs
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...              Description: Capturing event trace log,Also will check the tput value by tti trace
    [Arguments]     ${bbmod_slots}=1    ${duration}=30
    ...             ${cell_index}=1
    ...             ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${target_dir}=${TS_CASE_LOG_PATH}
    ...             ${direction}=ul
    ...            ${tti_log_option}=t
    ...            ${tti_package_file_name}=tti
    Log To Console    \nCapture TTI with gnb logs
    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=${duration}
    ...                           gnb_logs_script_path=${gnb_logs_script_path}
    ...                           gnb_index=${gnb_index}    du_index=${du_index}
    ...                           tti_log_option=${tti_log_option}
    ${specific_ttitrace_file_list}    Get Specific TTItrace File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             direction=${direction}
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                             tti_package_file_name=${tti_package_file_name}
    [Return]    ${specific_ttitrace_file_list[0]}

Capture BIP with gnb logs
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...              Description: Capturing bip via gnb logs
    [Arguments]     ${bbmod_slots}=1
    ...             ${duration}=2
    ...             ${cell_index}=1
    ...             ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${target_dir}=${TS_CASE_LOG_PATH}
    ...             ${log_type}=BIP
    Log To Console    \nCapture BIP with gnb logs
    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=${duration}
    ...                           gnb_logs_script_path=${gnb_logs_script_path}
    ...                           gnb_index=${gnb_index}    du_index=${du_index}
    ...                           log_type=${log_type}
    ${specific_bip_file_list}    Get Specific BIP File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             bbmod_slots=${bbmod_slots}    log_type=${log_type}
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    [Return]    ${specific_bip_file_list[0]}

Capture L2PS with gnb logs
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...              Description: Capturing event trace log,Also will check the tput value by tti trace
    [Arguments]     ${bbmod_slots}=1    ${duration}=30
    ...             ${cell_index}=1
    ...             ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${target_dir}=${TS_CASE_LOG_PATH}
    ...             ${direction}=ul
    ...             ${log_type}=L2PS
    Log To Console    \nCapture TTI with gnb logs
    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=${duration}
    ...                           gnb_logs_script_path=${gnb_logs_script_path}
    ...                           gnb_index=${gnb_index}    du_index=${du_index}
    ...                           log_type=${log_type}    cell_index=${cell_index}
    ${specific_ttitrace_file_list}    Get Specific L2PS File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             direction=${direction}
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    [Return]    ${specific_ttitrace_file_list[0]}

Start To Capture Mix Logs With gNB_logs
    [Arguments]    ${bbmod_slots}=1
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=-T -b -s
    ...            ${connection}=ute
    ...            ${timeout}=10 min
    ...            ${retry_interval}=15 sec
    Log To Console    --- start gnb_logs collection---
    Log    ${du_index}
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ${connection}    csn.get_connection_by_alias    alias=${connection}
    ${channel}    Call Method   ${connection}    invoke_shell
    Set Test Variable    ${gnb_logs_channel}    ${channel}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&sudo rm -rf *${gnb_ip}*m.zip\n
    Sleep   10s
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${start_capture_command}     Catenate    sudo ./gnb_logs ${gnb_ip} -c${bbmod_slots} ${log_type}
    Call Method    ${channel}    send    cd ${gnb_logs_script_path}&&${start_capture_command}\n
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Check The State Of gnb_logs Process    channel=${gnb_logs_channel}
    ...                                                                                                      message=monitoring

Stop Capture Mix Logs With gNB_logs
    [Arguments]    ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${connection}=ute
    ...            ${timeout}=25 min
    ...            ${retry_interval}=15 sec
    Log To Console    \***stop collect gnb logs***\
    Log Many    ${gnb_logs_script_path}    ${gnb_index}    ${du_index}    ${connection}    ${timeout}
    Verify the gnb_logs progress exist    connection=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
    Call Method    ${gnb_logs_channel}    send    \n
    Sleep    60 sec
    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}    Check The State Of gnb_logs Process    channel=${gnb_logs_channel}
    ...                                                                                                      message=finished
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=ute

Verify the gnb_logs progress exist
    [Arguments]    ${connection}=ute    ${gnb_index}=0    ${du_index}=0    ${gnb_ip}=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${pid}    Get the gnb_logs processID    connection=${connection}    gnb_index=${gnb_index}    du_index=${du_index}    gnb_ip=${gnb_ip}
    Should Be True    ${pid} > ${0}

Get the gnb_logs processID
    [Arguments]     ${connection}=ute
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${gnb_ip}=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${connection}
    ssh.send_command    command=ps -ef |grep gnb_logs |grep ${gnb_ip} |awk '{print $2}'    connection=${connection}    timeout=120
    ${output}    ssh.read_output    size=1000    connection=${connection}
    ${gnb_logs_pids}    Set Variable    ${output.split()}
    ${gnb_logs_pid}    evaluate    ${gnb_logs_pids[0].strip()}
    [Return]    ${gnb_logs_pid}

Check The State Of gnb_logs Process
    [Arguments]    ${channel}    ${message}=finished
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Should Contain    ${output}   ${message}

Capture TTI And Get All TTI File
    [Documentation]  Author: lei.jia@nokia-sbell.com
    ...              Description: Capturing event trace log,Also will check the tput value by tti trace
    [Arguments]     ${bbmod_slots}=1    ${duration}=4
    ...             ${cell_index}=1
    ...             ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${target_dir}=${TS_CASE_LOG_PATH}
    ...             ${tti_log_option}=t
    ...             ${tti_package_file_name}=tti
    ...             ${log_type}=TTI
    Log To Console    \nCapture TTI with gnb logs
    Log Many    ${cell_index}    ${tti_package_file_name}
    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=${duration}
    ...                           gnb_logs_script_path=${gnb_logs_script_path}
    ...                           gnb_index=${gnb_index}    du_index=${du_index}
    ...                           tti_log_option=${tti_log_option}
    log to console    --- start to Download tti trace result to specific folder ---
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    @{ttitrace_files}    List Files In Directory	${gnb_logs_script_path}	   BTS*_${gnb_ip}_*_${log_type}.zip
    Copy Files    ${gnb_logs_script_path}/BTS*_${gnb_ip}_*.zip    ${target_dir}
    [Teardown]    Run Keyword And Ignore Error    Run    sudo rm ${gnb_logs_script_path}/BTS*_${gnb_ip}_*_${log_type}.zip

Capture And Decode TTitrace Log
    [Documentation]    Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=5    ${direction}=ul
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${tti_file_path}    Decode Ttitrace Logs    file_path=${file_path}    direction=${direction}
    [Return]    ${tti_file_path}
    [Teardown]    Run Keyword And Ignore Error    Stop Ttitrace    collector_names=${collector_names}

Decode Ttitrace Logs
    [Documentation]    Migrate from ET
    [Arguments]    ${file_path}    ${direction}=ul
    ...            ${name}=converter
    ...            ${output_file_format}=excelCsv
    ...            ${eventdecoder_options}=--split 4000000
    ...            ${conversion_filter}=${None}
    log to console    Start to decode ${direction} ttitrace...
    ${output_file_path}   ${file_name}    OperatingSystem.Split Path    ${file_path}
    ${csv_file_path}    ${file_name}    Split String From Right  ${output_file_path}    /     1
    ${tti_file_path}    set variable    ${csv_file_path}/format_ttitrace_${direction}.csv
    ${r}   ${dummy}    run keyword and ignore error    OperatingSystem.File Should Exist   ${tti_file_path}
    return from keyword if  "${r}"=="PASS"
    EVENTDECODER.Create Eventdecoder Converter
    ...     name=${name}
    ...     input_file_path=${file_path}
    ...     output_file_path=${output_file_path}
    ...     output_file_format=${output_file_format}
    ...     conversion_filter=${conversion_filter}
    ...     excel_csv_options=-d ${direction}
    ...     eventdecoder_options=${eventdecoder_options}
    EVENTDECODER.Convert
    ...    name=converter
    log to console    Start format ${direction} ttitrace...
    ${r}   ${dummy}    run keyword and ignore error    OperatingSystem.File Should Exist   ${csv_file_path}/tcpdump_ttitrace_${direction}.csv
    ${input_file_name}    set variable if    "${r}"=="PASS"    ${csv_file_path}/tcpdump_ttitrace_${direction}.csv
    ...                                                        ${csv_file_path}/tcpdump_ttitrace_${direction}.0000.csv
    TtiSMConvert.Format Tti Stream Mode No Filters    input_file_name=${input_file_name}
    ...                                               output_file_name=${tti_file_path}
#    TtiSMConvert.Format Tti Stream Mode No Filters    ${csv_file_path}/tcpdump_ttitrace_ul.csv   ${csv_file_path}/format_ttitrace_ul.csv
    log to console    decode ttitrace finished.
    [Return]    ${tti_file_path}

Start Ttitrace With Streaming Mode
    [Documentation]
    ...    This keyword is used to start ttitrace with streaming mode.
    ...    Start Ttitrace With Streaming Mode
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${l2_stream_configuration}=${L2STREAM_COMPONENT_CONFIG}
    ...    ${gnb_index}=0   ${SW_BRANCH}=None
    ...    ${eth_port_on_ute}=eth0
    ...    ${eth_ip_addr_on_ute}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${localIpAddr}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='None'    Get Release Information From Active SW Version
    ${executor}=  Create Dictionary
    ...  host=${localIpAddr}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    tcpdump.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${eth_port_on_ute} udp and dst ${eth_ip_addr_on_ute} and dst port 5678
    ...  sudo_password=${tl.test_pc.default_ssh_connection_details.password}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${collector_names}
    ...  destination_ip_addr=${eth_ip_addr_on_ute}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${collector_names}
    core.setup_collectors
    ...  names=${collector_names}
    core.start_collectors
    ...  names=${collector_names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace
    [Documentation]    Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}
    log to console    stop catching ttitrace...
    core.stop_collectors
    ...  names=${collector_names}
    core.collect_collectors
    ...  names=${collector_names}    target_dir=${log_dir}
    core.teardown_collectors
    ...  names=${collector_names}
    ${file_path}    Set Variable    ${log_dir}/${collector_names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    [Return]   ${file_path}

Get Release Information From Active SW Version
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    ${SW_BRANCH}    get stream from version    ${Active_SW_version}
    Set Suite Variable     ${SW_BRANCH}
