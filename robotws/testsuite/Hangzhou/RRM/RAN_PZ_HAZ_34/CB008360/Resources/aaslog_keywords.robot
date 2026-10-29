*** Settings ***
Documentation    This is for check err/wrn from aaslog.
...              Please do not modify the file without notification to author
...              Author: xiaoxia.hao@nokia-sbell.com

*** Variables ***
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog

*** Keywords ***
Recover Collect Syslog On Control PC
    [Documentation]    Author: xiaoxia.hao@nokia-sbell.com
    ...   after L3 call, execute  keyword to recover collecting syslog on control pc
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...    ${aa_sys_mode}=5    ${aa_sys_addr}=0xC0A8FF7E    ${aa_sys_udp_port}=0xC738
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${response}    Wait until keyword succeeds    60s    500ms    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect   connection=${connection}

Check L1/L2 Error From Syslog
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${btslog_path}=${TS_CASE_LOG_PATH}
    ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    log to console    --- start check ERR/l1_application_rt from syslog--
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
