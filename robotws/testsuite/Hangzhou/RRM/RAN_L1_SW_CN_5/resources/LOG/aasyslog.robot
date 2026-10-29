*** Settings ***
Documentation    Used for AASysLog neccessary operations.
...              Please do not modify the file without notification to author
...              Author: Andy Cheng, Civen Chen
...              Contact: huimin.1.cheng@nokia-sbell.com, civen.chen@nokia-sbell.com

Library           ../python/aasyslog.py
Library           taf.transport.ssh    WITH NAME    csn
Library           BuiltIn

*** Variables ***
${port}    52000    # aa_sys_udp_port = 0xCB20 <-> 52000 from aasyslog.py (replaced 0xCB20)

*** Keywords ***
Get Host IP from gNB
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ${mplane_ip}   Set Variable   ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${host}   Set Variable If   '${mplane_ip}'=='None'
    ...      ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...      ${mplane_ip}
    [Return]   ${host}

Capturing Aasyslog with duration
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                Author: Civen Chen
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=20s    ${Teardown_after_finished}=${True}
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xCB20    ${filter}=${EMPTY}
    ...            ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${duration}
    sleep    ${duration}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'
    ...           Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                  host=${host}    username=${username}    password=${password}

Aasyslog precondition
    [Documentation]    Precondition to config the RD parameter on aisk to make aasyslog output directly.
    ...                Author: Andy Cheng, Civen Chen
    ...                Contact: huimin.1.cheng@nokia-sbell.com, civen.chen@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :aa_sys_mode: AaSysMode means the AaSysLog Output Mode,ex:2 means udp
    ...                :aa_sys_addr: AaSysLog Udp output Address change to Hex, if the first is 0 need add parameter like
    ...                 ex:0x0A39A747 should use 0xA39A747
    ...                :aa_sys_udp_port: AaSysLog Udp Port used for log output
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...    ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xCB20
    ...    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    ${response}    Wait until keyword succeeds    60s    500ms    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    [Return]    ${response}

Start the Aasyslog save progress
    [Documentation]    Start and save the Aasyslog in gnb with same checkpoint need check the before syslog.
    ...                Author: Andy Cheng
    ...                Contact: huimin.1.cheng@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :param filter: the save log can add filter to aviod too large
    ...                :param timeout: captrue timeout in backgroud.'s'for seconds,'m' for minutes,'h'for hours or 'd'for days
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${filter}=${EMPTY}    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${log_ip}=127.0.0.1    ${timeout}=15m
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    csn.connect_to    hostname=${host}   username=${username}    password=${password}    alias=ASIK Master
    csn.send_command    command=rm -rf ${gnb_path}${log_name}    connection=ASIK Master
    sleep   3s
    FOR    ${i}    IN RANGE    ${3}
        csn.send_command    command=(timeout ${timeout} nc -u -w 100 -l ${log_ip} ${port}| grep -a "${filter}">${gnb_path}${log_name} &)
        ...    connection=ASIK Master
        ${status}    run keyword and return status    wait_until_keyword_succeeds    5 sec   1 sec    Verify aasyslog process is started
        exit for loop if    ${status}
    END
    should be true    ${status}
    [Teardown]    csn.disconnect    connection=ASIK Master

Verify aasyslog process is started
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${connection}=ASIK Master
    ${nc_pid}    csn.execute    command=ps -ef|grep nc | grep ${port} | grep -v grep | tail -n 1|awk '{print $2}'   connection=${connection}
    ${nc_pid}    strip_string    ${nc_pid}
    should not be empty      ${nc_pid}

Teardown the Aasyslog save progress
    [Documentation]    Teardown the save Aasyslog progress in gnb.
    ...                Author: Andy Cheng
    ...                Contact: huimin.1.cheng@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    csn.connect_to    hostname=${host}   username=${username}    password=${password}    alias=ASIK Master
    ${nc_pid_old}    csn.execute    command=ps -ef | grep ${port}| grep -v grep| awk '{print $2}'    connection=ASIK Master
    csn.send_command    command=ps -ef |grep nc|grep ${port}| grep -v grep | awk '{print $2}'|xargs kill -9    connection=ASIK Master
    sleep   3s
    ${nc_pid}    csn.execute    command=ps -ef |grep nc|grep ${port}|grep -v grep| awk '{print $2}'    connection=ASIK Master
    should be empty  ${nc_pid}
    [Teardown]    csn.disconnect    connection=ASIK Master

Download aasyslog file from gNB
    [Arguments]    ${log_path}    ${local_path}    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    csn.connect_to    hostname=${host}   username=${username}    password=${password}    alias=ASIK Master
    csn.download_file    remote_path=${log_path}    local_path=${local_path}    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master
