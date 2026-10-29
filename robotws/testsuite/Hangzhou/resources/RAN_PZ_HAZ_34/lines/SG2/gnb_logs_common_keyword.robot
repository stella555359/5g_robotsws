*** Settings ***
Documentation    This is for TTI log capture and Analysis
...              Contacts: tong.chen@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot

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
    ...            ${timeout}=600
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    log to console    --- start gnb_logs collection---
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${log_type_to_command_mapping}    Create Dictionary    TTI=T    BIP=b   m=m    L2PS=o l2ps
    ${gnb_ip}    Set Variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ssh.send command    command=cd ${gnb_logs_script_path}&&rm *${log_type}.zip   connection=ute
    ${start_capture_command}     Catenate    ./gnb_logs ${gnb_ip} -c${bbmod_slots} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${start_l2ps_capture_command}     Catenate
    ...                     sudo ./gnb_logs ${gnb_ip} -c${bbmod_slots} -C ${cell_index} -${log_type_to_command_mapping['${log_type}']} ${duration}
    ${start_capture_command}    set variable if    "${log_type}"=="L2PS"    ${start_l2ps_capture_command}    ${start_capture_command}
    ssh.send command    command=cd ${gnb_logs_script_path}&&${start_capture_command}   connection=ute
    ${stop_capture}    ssh.read output until    finished    timeout=${timeout}   connection=ute
    Run    unzip ${gnb_logs_script_path}/*${log_type}.zip -d ${target_dir}/gnblogs_${timestamp}
    ${file_path}    ssh.execute    command=realpath ${target_dir}/gnblogs_${timestamp}/BTS-*   connection=ute
    ${file_path}    Strip String    ${file_path}    characters=\r\n
    [Return]    ${file_path}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=ute    AND
    ...    Run Keyword And Ignore Error    run    command=killall *gnb_logs*

