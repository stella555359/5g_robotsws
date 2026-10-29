*** Settings ***
Documentation    This is for ASOD relate common keyword
...              Please do not modify the file without notification to author
...              Author: Tang Jiayi
...              Squard: HZ SG7

Library    Telnet
Library    taf.ue.tm500.asc      WITH NAME    asc
Library    taf.ue.tm500.rci      WITH NAME    rci
Library    OperatingSystem
Library    Collections
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.analyzer.pcap    WITH NAME    cap
Library    ../python/asod_common_pythonLib.py
Library    taf.config.testline.info.TestlineInfo      WITH NAME     TLINFO
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot

*** Variables ***
${Acceptable_Deviation}    10%
${TMA_PATH}     ${tl.ues[0].tma_path}
${APP_SERVER_ADDR}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${APP_SERVER_USERNAME}    ${tl.ues[0].iperf_details.ssh_connection_details.username}
${APP_SERVER_PASSWORD}    ${tl.ues[0].iperf_details.ssh_connection_details.password}
${IP_Data_Transfer}    ${tl.ues[0].iperf_details.network_interface_address}
${EPCSIM_ALIAS}  EPCSim
${APP_SERVER_ALIAS}  appserver
${lodin_sfp}    arb0p3
${asod_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asod_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asod_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
@{expand_headers}    RAP 1

*** Keywords ***
######Asod Common Keyword#######
Connect to ASOD
    [Arguments]    ${alias}=ASOD    ${proxy}=${null}
    Connect via root if passed username fails    hostname=${asod_addr}    username=${asod_username}    password=${asod_password}
    ...     alias=${alias}    proxy=${proxy}

Start Tcpdump
    [Documentation]    Author: Tang Jiayi
    ...                Description: Start to collect log by tcpdump command            
    [Arguments]    ${log_path}    ${log_name}    ${connection}    ${sudo}=${empty}    ${interface}=any    ${protocol}=${empty}    ${filter}=${empty}
    ${cmd}=  set variable  ${sudo} tcpdump -i ${interface} ${protocol} -s0 -w ${log_path}/${log_name} > /dev/null 2>&1 ${filter}& 
    ssh.Send Command    ${cmd}    connection=${connection}

Stop Tcpdump
    [Documentation]    Author: Tang Jiayi
    ...                Description: Stop collecting log by tcpdump command
    [Arguments]    ${connection}
    ssh.execute
    ...    command=kill -2 `ps -ef | grep tcpdump | grep -v grep | awk '{print $2}'`
    ...    connection=${connection}

Delete Log
    [Documentation]    Author: Tang Jiayi
    ...                Description: Delete the download log
    [Arguments]    ${log_path}    ${log_name}    ${connection}
    ssh.execute
    ...    command=rm -rf ${log_path}/${log_name}
    ...    connection=${connection}

Download Pcap Log
    [Documentation]    Author: Tang Jiayi
    ...                Description: Download log from remote
    [Arguments]       ${log_path}    ${log_name}    ${connection}    
    ssh.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${local_path}/${log_name}
    ...                  connection=${connection}

Read BIP Pcap Files
    [Documentation]    Author: Wang Ziwei
    ...                Description: use luashark to analyse file
    [Arguments]    ${filter}    ${bip_log_name}    ${bip_log_path}    ${lua_script_path}=${LUA_SCRIPT_PATH}
    Wait until keyword succeeds    3 min    7 s    cap.Read cap
    ...    cap_file=${bip_log_path}/${bip_log_name}    X=lua_script:${lua_script_path}    display_filter=${filter}

Connect to TM500 Control PC SSH
    [Documentation]    Author: Dong Tingting
    ...                Connect to TM500 Control PC via ssh
    ...              Precondition is that cygwin has been installed in control pc
    [Arguments]    ${tma_pc_ssh_alias}=tm500_pc
    csn.connect to    hostname=${TM500_IP} 
    ...               username=${TM500_USER}
    ...               password=${TM500_PW}
    ...               alias=${tma_pc_ssh_alias}

Connect to AppServer
    [Documentation]    Author: Zhang Yu 8
    ...                Connect to APPServer via ssh
    [Arguments]    ${app_server_alias}=${APP_SERVER_ALIAS}
    csn.connect to    hostname=${APP_SERVER_ADDR}
    ...               username=${APP_SERVER_USERNAME}
    ...               password=${APP_SERVER_PASSWORD}
    ...               alias=${app_server_alias}

Stop DL traffic
    [Documentation]    Author: Huang Jie
    ...                stop dl traffic with epcsim or appserver
    [Arguments]    ${port}=${DL_IPERF_PORT}
    ...            ${epc_sim_alias}=${EPCSIM_ALIAS}
    ...            ${app_server_alias}=${APP_SERVER_ALIAS}
    ${has_epcsim}  TLINFO.Has Epcsim  tl=${tl}
    Run Keyword If  ${has_epcsim}==True  Kill Iperf Process on EPCSim
    ...            port=${port}
    ...            epc_sim_alias=${epc_sim_alias}
    ...    ELSE    Kill Iperf Process on AppServer
    ...            port=${port}
    ...            app_server_alias=${app_server_alias}

Kill Iperf Process on EPCSim
    [Documentation]    Author: Zhang Yu 8
    ...                kill the Iperf process on EPCSIm
    [Arguments]    ${port}=${DL_IPERF_PORT}
    ...            ${epc_sim_alias}=${EPCSIM_ALIAS}
    wait until keyword succeeds    2 min    10 s    Connect to EPCSim
    csn.Execute    command=ps -ef |grep iperf |grep -v "grep" |grep ${port} |awk '{print $2}'|xargs kill -3    connection=${epc_sim_alias}
    sleep  5 s
    ${response}    csn.execute    command=ps -ef |grep "iperf" |grep -v "grep" |grep ${port} |awk '{print $2}'    connection=${epc_sim_alias}
    ${response}    Get length    ${response.strip()}
    should be true    ${response} == ${0}    msg=Iperf client process is not killed on ${epc_sim_alias} for port ${port}

Kill Iperf Process on AppServer
    [Documentation]    Author: Zhang Yu 8
    ...                kill Iperf process on AppServer
    [Arguments]    ${port}=${DL_IPERF_PORT}
    ...            ${app_server_alias}=${APP_SERVER_ALIAS}
    wait until keyword succeeds    2 min    10 s    Connect to AppServer
    csn.execute    command=ps -ef |grep "iperf" |grep -v "grep" |grep ${port} |awk '{print $2}' |xargs kill -2    connection=${app_server_alias}
    csn.execute    command=ps -ef |grep "iperf" |grep -v "grep" |grep ${UE_IP} |awk '{print $2}' |xargs kill -2    connection=${app_server_alias}
    
Kill Iperf Process on TM500
    [Documentation]    Author: Zhang Yu 8
    ...                kill Iperf process on TM500
    [Arguments]    ${tma_ssh_alias}=tm500_pc
    wait until keyword succeeds    2 min    10 s    Connect to TM500 Control PC SSH 
    csn.Execute    command=ps -Wef |grep "iperf" |grep -v "grep" |awk '{print $2}' |xargs kill -f    connection=${tma_ssh_alias}
    ${response}    csn.execute    command=ps -Wef |grep "iperf" |grep -v "grep" |awk '{print $2}'    connection=${tma_ssh_alias}
    ${response}    Get length    ${response.strip()}
    should be true    ${response} == ${0}    msg=Iperf client process is not killed on ${tma_ssh_alias}

Get timestamp
    [Documentation]    Author: Zhang Yu 8
    ...                Example return value is: 20181019073816
    @{time}    Get time    year month day hour min sec
    ${time_stamp}    Set variable    ${EMPTY}
    FOR    ${item}    IN    @{time}
        ${time_stamp}    Catenate    SEPARATOR=${EMPTY}    ${time_stamp}    ${item}
    END
    [Return]    ${time_stamp}
