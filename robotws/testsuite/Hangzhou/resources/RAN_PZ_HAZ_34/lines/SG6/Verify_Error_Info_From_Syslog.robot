*** Settings ***
Documentation    This is for logs related common keywords.
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot


*** Variables ***
@{btslog_dirs}    /opt/btslog    /opt/ute/tools/btslog


*** Keywords ***
Start To Check L1L2 Error Info From Syslog
    [Arguments]    ${capture_time}=1min
    Log To Console    Start to Check L1L2 Error Info From Syslog
    Set Test Variable    @{btslog_dirs}
    Recover Collect Syslog For Gnb
    Start Btslog With Path Check
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Sleep    ${capture_time}
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Check L1L2 Error Info From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}

Recover Collect Syslog For Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                after L3 call, execute  keyword to recover collecting syslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...    ${aa_sys_mode}=5    ${aa_sys_addr}=0xC0A8FF7E    ${aa_sys_udp_port}=0xC738
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${response}    Wait until keyword succeeds    60s    500ms    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}

Check L1L2 Error Info From Syslog
    [Arguments]    ${btslog_path}=${TS_CASE_LOG_PATH}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    log to console    --- start check ERR/l1_application_rt from syslog---
    ${btslog_full_path}    set variable    ${btslog_path}/btslog/syslog_files.tgz
    ssh.send command    command=zgrep -a "ERR/l1_application_rt" ${btslog_full_path}   connection=ute    timeout=120
    ${l1_application_rt_infor}    csn.read_output    size=1000    connection=ute
    ${l1_application_rt_infor} =    split string    ${l1_application_rt_infor}    \n
    ${l1_application_rt_len}=      get length     ${l1_application_rt_infor}
    Run Keyword if    ${l1_application_rt_len}>1    Run Keyword And Continue On Failure    Fail    it has l1_application_rt_len error
    ssh.send command    command=zgrep -a "WRN/l1" ${btslog_full_path}   connection=ute    timeout=120
    ${l1_application_rt_infor}    csn.read_output    size=1000    connection=ute
    ${l1_application_rt_infor} =    split string    ${l1_application_rt_infor}    \n
    ${l1_application_rt_len}=      get length     ${l1_application_rt_infor}
    Run Keyword if    ${l1_application_rt_len}>1    Run Keyword And Continue On Failure    Fail    it has WRN/l1 error
    log to console    --- start check WRN/L2-PS from syslog---
    ssh.send command    command=zgrep -a "WRN/L2-PS" ${btslog_full_path}   connection=ute    timeout=120
    ${l2_PS_wrn_infor}    csn.read_output    size=1000    connection=ute
    ${l2_PS_wrn_infor} =    split string    ${l2_PS_wrn_infor}    \n
    ${l2_PS_wrn_len}=      get length     ${l2_PS_wrn_infor}
    Run Keyword if    ${l2_PS_wrn_len}>1    Run Keyword And Continue On Failure    Fail    it has WRN/L2-PS error
    log to console    --- start check ERR/L2-PS from syslog---
    ssh.send command    command=zgrep -a "ERR/L2-PS" ${btslog_full_path}   connection=ute    timeout=120
    ${l2_PS_error_infor}    csn.read_output    size=1000    connection=ute
    ${l2_PS_error_infor} =    split string    ${l2_PS_error_infor}    \n
    ${l2_PS_error_len}=      get length     ${l2_PS_error_infor}
    Run Keyword if    ${l2_PS_error_len}>1    Run Keyword And Continue On Failure    Fail    it has ERR/L2-PS error
    [Teardown]    run keyword and ignore error    ssh.disconnect    connection=ute

Check AVQL Err and WRN Log On RF
    [Documentation]  Author: Hao Xiaoxia
    [Arguments]  ${connection}=GNB_OAM    ${ru_dfe_ip}=192.168.100.17    ${asik_connection}=ASIK Master    ${ru_index}=${1}
    ...    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${ru_username}=${tl.gnbs[${gnb_index}].dus[${du_index}0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...    ${ru_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].default_ssh_connection_details.password}
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_connection}
	${container_id}    Get FHNET Container ID    asik_alias=${asik_connection}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}

    ${smod_connection}    csn.get_connection_by_alias    alias=${asik_connection}
    ${channel}    Call Method    ${smod_connection}    invoke_shell
    ${output}    csn.execute    lxc-ls    connection=${asik_connection}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    IF    ${feature_1834_opened}
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    ssh ${ru_username}@${ru_ip_addr} -o StrictHostKeyChecking\=no\n
    Sleep    1 sec
    ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    IF    "password:" in """${password_prompt_output}"""
        Call Method    ${channel}    send    ${ru_password}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Sleep    2sec
    Call Method    ${channel}    send     ssh ${ru_dfe_ip}\n
    Call Method    ${channel}    send     cat /var/log/l1_runtime.log |grep -i "/ERR"\n
    sleep  2sec
    Call Method    ${channel}    send     cat /var/log/l1_runtime.log |grep -i "/WRN"\n
    sleep  2sec
    ${error_output}    Call Method    ${channel}    recv    ${65535}
    Log    ${error_output}
    ${error_output}    convert to string    ${error_output}
    ${error_infor_regexp}    set variable    .*ERR.*
    ${wrn_infor_regexp}    set variable    .*WRN.*
    ${error_infor_value}    Get Regexp Matches    ${error_output}    ${error_infor_regexp}
    ${err_len}   Get Length   ${error_infor_value}
    Run Keyword And Continue On Failure    should be true    ${err_len}<4
    log    ${error_infor_value}
    ${exp_error_infor_regexp}    set variable    WRN.*Got stop notification without collection request, ignored
    ${wrn_infor_value}    Get Regexp Matches    ${error_output}    ${wrn_infor_regexp}
    ${wrn_len}   Get Length   ${wrn_infor_value}
    ${exp_wrn_infor_value}    Get Regexp Matches    ${error_output}    ${exp_error_infor_regexp}
    ${exp_wrn_infor_len}   Get Length   ${exp_wrn_infor_value}
    ${need_checked_wrn_len}    Evaluate    ${wrn_len}-${exp_wrn_infor_len}
    Run Keyword And Continue On Failure    should be true    ${need_checked_wrn_len}<2
     log    ${wrn_infor_value}
    [Teardown]    Run Keywords    Call Method    ${channel}    close    AND
    ...                           run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                           run keyword and ignore error    csn.disconnect    connection=RU_${ru_index}    AND
    ...                           run keyword and ignore error    csn.disconnect    connection=${asik_connection}
