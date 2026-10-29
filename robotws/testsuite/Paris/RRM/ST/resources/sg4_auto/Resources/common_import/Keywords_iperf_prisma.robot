*** Settings ***
Documentation
...      27.05.21    Annie Wong, resources file for iperf traffic (on Prisma) allow multi UE

*** Variables ***
#dl alias
${iperfCore_cnx}                     iperf_core_cnx
#ul_alias
${iperfUe_cnx}                       iperf_ue_cnx

*** Keywords ***
Start UL traffic process for List UEs
    #@{UE_LIST}    0   1
    [Arguments]      ${list_of_ues}      ${tput}=100M     ${duration}=10    ${len}=1000
    FOR    ${index}    IN    @{list_of_ues}
        Start UL traffic process for UE Index   tput=${tput}   duration=${duration}  len=${len}   ueid=${index}
    END


Start DL traffic process for List UEs
    #@{UE_LIST}    0   1
    [Arguments]      ${list_of_ues}      ${tput}=100M     ${duration}=10    ${len}=1000
    FOR    ${index}    IN    @{list_of_ues}
        Start DL traffic process for UE Index   tput=${tput}   duration=${duration}  len=${len}   ueid=${index}
    END


Start UL traffic process for UE Index
    [Documentation]  Launch traffic with iperf command (UDP).
    ...              This keyword take as argument:
    ...                . ${tput} by default 100M     UL Tput
    ...                . ${duration} by default 10   duration of traffic
    ...                . ${len} by default 1000, length
    ...                . ${ueid} by default 0
    [Arguments]    ${tput}=100M     ${duration}=10    ${len}=1000   ${ueid}=${0}
    ${port}=       Get UL traffic port       ueid=${ueid}
    ${alias_cnx_send}=       set variable     ${iperfUe_cnx}
    ${alias_cnx_recv}=       set variable     ${iperfCore_cnx}
    ${server_send_ip}=       set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.addr}
    ${server_send_login}=    set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.username}
    ${server_send_pwd}=      set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.password}
    ${dst}=                  set variable     ${tl.appserver.iperf_details.network_interface_address}
    # bind on iperf client
    ${bind}                  set variable     ${tl.ues[${ueid}].iperf_details.iperf_bind_ue_ip}
    ${server_recv_ip}=       set variable     ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ${server_recv_login}=    set variable     ${tl.appserver.iperf_details.ssh_connection_details.username}
    ${server_recv_pwd}=      set variable     ${tl.appserver.iperf_details.ssh_connection_details.password}
    # server
    ${cmd_svr}=   set variable   iperf -s -u -i 1 -p ${port}
    # client : coté client, bind: this sets the outbound interface
    ${cmd_clt}=   run keyword if   '${bind}'!='None' and '${bind}'!='' and '${bind}'!='True' and '${bind}'!='False'
    ...       set variable       iperf -c ${dst} -u -i 1 -P 1 -l ${len} -b ${tput} -t ${duration} -p ${port} -B ${bind}
    ...    ELSE     set variable    iperf -c ${dst} -u -i 1 -P 1 -l ${len} -b ${tput} -t ${duration} -p ${port}
    Log     traffic iperf UL (server) ueid=${ueid} cmd=${cmd_svr}      console=${DEBUG_MODE_CONSOLE}
    Log     traffic iperf UL (client) ueid=${ueid} cmd=${cmd_clt}      console=${DEBUG_MODE_CONSOLE}
    ssh.Connect To      ${server_send_ip}     ${server_send_login}     ${server_send_pwd}     alias=${alias_cnx_send}
    ssh.Connect To      ${server_recv_ip}     ${server_recv_login}     ${server_recv_pwd}     alias=${alias_cnx_recv}
    ssh.send command    ${cmd_svr}        connection=${alias_cnx_recv}
    ssh.disconnect      ${alias_cnx_recv}
    ssh.send command    ${cmd_clt}        connection=${alias_cnx_send}
    ssh.disconnect      ${alias_cnx_send}


Start DL traffic process for UE Index
    [Documentation]  Launch traffic with iperf command (UDP).
    ...              This keyword take as argument:
    ...                 . ${tput} by default 100M     DL Tput
    ...                 . ${duration} by default 10   duration of traffic
    ...                 . ${len} by default 1000, length
    ...                 . ${ueid} by default 0
    [Arguments]     ${tput}=100M     ${duration}=10    ${len}=1000   ${ueid}=${0}
    ${port}=        Get DL traffic port       ueid=${ueid}
    ${alias_cnx_send}=       set variable     ${iperfCore_cnx}
    ${alias_cnx_recv}=       set variable     ${iperfUe_cnx}
    ${server_send_ip}=       set variable     ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ${server_send_login}=    set variable     ${tl.appserver.iperf_details.ssh_connection_details.username}
    ${server_send_pwd}=      set variable     ${tl.appserver.iperf_details.ssh_connection_details.password}
    ${dst}=                 set variable     ${tl.ues[${ueid}].iperf_details.network_interface_address}
    # bind on iperf server
    ${bind}                  set variable     ${tl.ues[${ueid}].iperf_details.iperf_bind_ue_ip}
    ${server_recv_ip}=       set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.addr}
    ${server_recv_login}=    set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.username}
    ${server_recv_pwd}=      set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.password}

    # server: coté server, bind: incoming interface
    ${cmd_svr}=   run keyword if   '${bind}'!='None' and '${bind}'!='' and '${bind}'!='True' and '${bind}'!='False'
    ...                             set variable    iperf -s -i 1 -p ${port} -B ${bind}
    ...        ELSE                 set variable    iperf -s -i 1 -p ${port}
    # client:
    ${cmd_clt}=   set variable    iperf -c ${dst} -u -i 1 -P 1 -l ${len} -b ${tput} -t ${duration} -p ${port}
    Log     traffic iperf DL (server) ueid=${ueid} cmd=${cmd_svr}      console=${DEBUG_MODE_CONSOLE}
    Log     traffic iperf DL (client) ueid=${ueid} cmd=${cmd_clt}      console=${DEBUG_MODE_CONSOLE}
    ssh.Connect To      ${server_send_ip}     ${server_send_login}     ${server_send_pwd}     alias=${alias_cnx_send}
    ssh.Connect To      ${server_recv_ip}     ${server_recv_login}     ${server_recv_pwd}     alias=${alias_cnx_recv}
    ssh.send command    ${cmd_svr}        connection=${alias_cnx_recv}
    ssh.disconnect      ${alias_cnx_recv}
    ssh.send command    ${cmd_clt}        connection=${alias_cnx_send}
    ssh.disconnect      ${alias_cnx_send}


Stop UL iperf pids for List UEs
    #@{UE_LIST}    0   1
    [Arguments]      ${list_of_ues}
    FOR    ${index}    IN    @{list_of_ues}
        Stop UL iperf pids for UE Index      ueid=${index}
    END


Stop DL iperf pids for List UEs
    #@{UE_LIST}    0   1
    [Arguments]      ${list_of_ues}
    FOR    ${index}    IN    @{list_of_ues}
        Stop DL iperf pids for UE Index      ueid=${index}
    END


Stop UL iperf pids for UE Index
    [Documentation]  Stop traffic by killing Iperf process on port numbered based on ueid.
    [Arguments]      ${ueid}=${0}
    ${port}=          Get UL traffic port        ueid=${ueid}
    ${alias_cnx_send}=       set variable     ${iperfUe_cnx}
    ${alias_cnx_recv}=       set variable     ${iperfCore_cnx}
    ${server_send_ip}=       set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.addr}
    ${server_send_login}=    set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.username}
    ${server_send_pwd}=      set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.password}
    ${server_recv_ip}=       set variable     ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ${server_recv_login}=    set variable     ${tl.appserver.iperf_details.ssh_connection_details.username}
    ${server_recv_pwd}=      set variable     ${tl.appserver.iperf_details.ssh_connection_details.password}

    ssh.Connect To      ${server_send_ip}     ${server_send_login}     ${server_send_pwd}     alias=${alias_cnx_send}
    # command to retrieve directly pid from combination iperf and port. and kill signal of process
    ${pid}         ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_send}
    Log            iperf pid=${pid}      console=${DEBUG_MODE_CONSOLE}
    ${pid}         Strip String    ${pid}      characters=\\r\\n\\0xA0\\0xD0
    Log            iperf pid=${pid}      console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${pid}'!='${EMPTY}'       ssh.execute      kill -9 ${pid}     connection=${alias_cnx_send}
    ssh.disconnect     ${alias_cnx_send}

    ssh.Connect To      ${server_recv_ip}     ${server_recv_login}     ${server_recv_pwd}     alias=${alias_cnx_recv}
    ${pid}              ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_recv}
    ${pid}              Replace String  ${pid}     \r\n        ${SPACE}
    #Log                 iperf pid=${pid}      console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${pid}'!='${EMPTY}'       ssh.execute     kill -9 ${pid}  connection=${alias_cnx_recv}
    ssh.disconnect     ${alias_cnx_recv}


Stop DL iperf pids for UE Index
    [Documentation]  Stop traffic by killing Iperf process on port numbered based on ueid.
    [Arguments]      ${ueid}=${0}
    ${port}=          Get DL traffic port        ueid=${ueid}
    ${alias_cnx_send}=       set variable     ${iperfCore_cnx}
    ${alias_cnx_recv}=       set variable     ${iperfUe_cnx}
    ${server_send_ip}=       set variable     ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ${server_send_login}=    set variable     ${tl.appserver.iperf_details.ssh_connection_details.username}
    ${server_send_pwd}=      set variable     ${tl.appserver.iperf_details.ssh_connection_details.password}
    ${server_recv_ip}=       set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.addr}
    ${server_recv_login}=    set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.username}
    ${server_recv_pwd}=      set variable     ${tl.ues[${ueid}].iperf_details.ssh_connection_details.password}

    ssh.Connect To      ${server_send_ip}     ${server_send_login}     ${server_send_pwd}     alias=${alias_cnx_send}
    # command to retrieve directly pid from combination iperf and port. and kill signal of process
    ${pid}         ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_send}
    ${pid}         Strip String    ${pid}      characters=\\r\\n\\0xA0\\0xD0
    Log            iperf pid=${pid}      console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${pid}'!='${EMPTY}'       ssh.execute      kill -9 ${pid}     connection=${alias_cnx_send}
    ssh.disconnect     ${alias_cnx_send}

    ssh.Connect To      ${server_recv_ip}     ${server_recv_login}     ${server_recv_pwd}     alias=${alias_cnx_recv}
    ${pid}              ssh.execute    pgrep -f 'iperf -p ${port}'       connection=${alias_cnx_recv}
    ${pid}              Replace String  ${pid}     \r\n        ${SPACE}
    Log            iperf pid=${pid}      console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${pid}'!='${EMPTY}'       ssh.execute     kill -9 ${pid}  connection=${alias_cnx_recv}
    ssh.disconnect     ${alias_cnx_recv}


# Get traffic port
#    [Arguments]      ${direction}     ${ueid}=${0}
#    ${_ul}        Evaluate         33201 + ${ueid}
#    ${_dl}        Evaluate         34201 + ${ueid}
#    ${port}       set variable if   '${direction}' == 'UL'     ${_ul}       ${_dl}
#    Log       direction=${direction}, ueid=${ueid} port=${port}      console=${DEBUG_MODE_CONSOLE}
#    Return from Keyword           ${port}

Get DL traffic port
    [Arguments]        ${ueid}=${0}
    ${_dl}           Evaluate          34203 + ${ueid}
    ${_dl_port}      set variable      ${tl.ues[${ueid}].iperf_details.port}
    ${final_port}    set variable if    '${_dl_port}'=='' or '${_dl_port}'=='None'      ${_dl}       ${_dl_port}
    Log        UE ${ueid} DL Port=${final_port}        #console=${DEBUG_MODE_CONSOLE}
    Return from Keyword           ${final_port}

Get UL traffic port
    [Arguments]        ${ueid}=${0}
    ${_ul}           set variable      33203
    ${_ul_port}      set variable      ${tl.appserver.iperf_details.port}
    ${port}          set variable if   '${_ul_port}'=='' or '${_ul_port}'=='None'      ${_ul}       ${_ul_port}
    ${final_port}    Evaluate           ${port} + ${ueid}
    Log        UE ${ueid} UL Port=${final_port}        console=${DEBUG_MODE_CONSOLE}
    Return from Keyword           ${final_port}
