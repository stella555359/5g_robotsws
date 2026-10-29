*** Settings ***
Documentation
...    Module containing all log keywords.

Library    taf.transport.ssh              WITH NAME    ssh
Library    taf.collectors.btslog          WITH NAME    btslog
Library    taf.sbts.oam.coam.admin         WITH NAME    coam
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.collectors.core
# Library    ${CURDIR}/../python/log_collector.py
Library    ${CURDIR}/python/aasyslog.py

*** Variables ***
@{VM_list}                oam    cpue    upue    cpif    cpnb    cpcl    cpnrt

*** Keywords ***

# ------------------------------------ AASYSLOG KEYWORDS ------------------------------------
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
    ...    ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}


    #fix robocop
    ${gnb_index}=    Set Variable    ${gnb_index}
    ${du_index}=    Set Variable    ${du_index}
    ${response}    aasyslog realtime output configuration
    ...    host=${host}    username=${username}    password=${password}    type=${type}
    ...    aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    BuiltIn.Set Global Variable    ${Aasyslog_capture_flag}    'True'
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
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...    ${log_ip}=127.0.0.1    ${timeout}=15m

    #fix robocop
    ${gnb_index}=    Set Variable    ${gnb_index}
    ${du_index}=    Set Variable    ${du_index}
    ssh.connect_to      hostname=${host}    username=${username}    password=${password}    alias=ASIK Master
    ssh.send_command    command=rm -rf ${gnb_path}${log_name}    connection=ASIK Master
    Sleep               3s
    ssh.send_command    command=timeout ${timeout} nc -u -w 100 -l ${log_ip} 51000| grep -a "${filter}">${gnb_path}${log_name}
    ...                 connection=ASIK Master
    Sleep               3s
    ${nc_pid}           ssh.execute    command=ps -ef | grep nc | grep 51000 | grep -v grep | tail -n 1 | awk '{print $2}'
    ...                                connection=ASIK Master
    Should not Be Empty     ${nc_pid}
    [Teardown]    ssh.disconnect    connection=ASIK Master

Aasyslog precondition with retry
    [Documentation]
    ...            Description: Retry aasyslog precondition until it successfull
    ...         author: jie.yin
    FOR   ${index}   IN RANGE   4
         ${aasyslog_status}    Run keyword and return status    log_collector.Aasyslog precondition    gnb_index=${0}   du_index=0
         Exit For Loop If    '${aasyslog_status}'=='${True}'
    END
    Should be True    ${aasyslog_status}



Teardown the Aasyslog save progress
    [Documentation]    Teardown the save Aasyslog progress in gnb.
    ...                Author: Andy Cheng
    ...                Contact: huimin.1.cheng@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    #fix robocop
    ${gnb_index}=    Set Variable    ${gnb_index}
    ${du_index}=    Set Variable    ${du_index}
    ssh.connect_to      hostname=${host}    username=${username}    password=${password}    alias=ASIK Master
    ${nc_pid_old}       ssh.execute    command=ps -ef | grep 51000| grep -v grep| tail -n 1| awk '{print $2}'
    ...                                connection=ASIK Master
    ssh.send_command    command=ps -ef | grep nc | grep 51000 | grep -v grep | tail -n 1 | awk '{print $2}' | xargs kill -9
    ...                 connection=ASIK Master
    Sleep               3s
    ${nc_pid}           ssh.execute    command=ps -ef | grep nc | grep 51000 | grep -v grep | awk '{print $2}'
    ...                                connection=ASIK Master
    should be empty     ${nc_pid}
    [Teardown]    ssh.disconnect    connection=ASIK Master

Download ${L3call_stage} Aasyslog on ${RF}
    ${timestamp}      Get Timestamp
    Connect to Common Unit    alias=smod
    Run Keyword and Continue on Failure    ssh.download_file    remote_path=/tmp/5Grach_RF${RF}.txt
    ...                                 local_path=${LOG_PATH}/${tl.tl_cloud_topology}_5Grach_${L3call_stage}_RF${RF}_${timestamp}.txt
    ...                                  connection=smod

# ---------------------------------END OF AASYSLOG KEYWORDS ---------------------------------
