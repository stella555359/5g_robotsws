*** Settings ***
Documentation    Run iperf with siso reuirements
...              Please do not modify the file without notification to author
...              Author: Zhou Qiang
...              Contact: qiang.1.zhou@nokia-sbell.com
...              Squard: HZ SRAN SISO

Library           Telnet
Library           taf.transport.ssh    WITH NAME    csn
Library    DateTime
Library    String
Library    taf.ul.mobile.ui.android    WITH NAME    android_ui




*** Keywords ***
Start UDP Iperf Client
    [Arguments]    ${client_pc_info}      ${server_addr}    ${port}    ${band_width}
    ...            ${duration}    ${bind_host}    ${ttl}=64    ${alias}=client
    [Documentation]    Run udp iperf client
    ${ip}     Set Variable    ${client_pc_info[0]}
    ${user_name}    Set Variable    ${client_pc_info[1]}
    ${password}   Set Variable    ${client_pc_info[2]}
    ${server_port}    Set Variable     ${client_pc_info[3]}
    csn.Connect to    hostname=${ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}
    csn.execute
    ...  command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=${alias}
    ${cmd_start_iperf_client}    Catenate    /usr/bin/nohup iperf -c ${server_addr} -u -p ${port} -b ${band_width}
    ...                                      -l 1024.0B -w 41.0K -t ${duration} -i 1 -P 1 -f k
    ...                                      -B ${bind_host} -T ${ttl} >None 2>&1 0</dev/null &

    csn.send_command    command=${cmd_start_iperf_client}       connection=${alias}
    [Teardown]    csn.disconnect    connection=${alias}


Start UDP Iperf Server
    [Arguments]    ${server_pc_info}   ${port}    ${log_file}     ${bind_host}
    ...            ${buffer_size}=82.0K    ${alias}=server
    [Documentation]    Run udp iperf
    ${ip}     Set Variable    ${server_pc_info[0]}
    ${user_name}    Set Variable    ${server_pc_info[1]}
    ${password}   Set Variable    ${server_pc_info[2]}
    ${server_port}    Set Variable     ${server_pc_info[3]}
    csn.Connect to    hostname=${ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}
    ...               timeout=120
    csn.execute
    ...  command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=${alias}
    ${cmd_start_iperf_server}    Catenate    	/usr/bin/nohup iperf -s -u -p ${port} -i 1 -P 0 -f k
    ...                                        -l 1024.0B -w ${buffer_size}
    ...                                        -B ${bind_host} >${log_file} 2>&1 0</dev/null &

    csn.send_command    command=${cmd_start_iperf_server}       connection=${alias}
    [Teardown]    csn.disconnect    connection=${alias}


Teardown Iperf
    [Arguments]    ${server_pc_info}   ${port}   ${alias}=server
    ${ip}     Set Variable    ${server_pc_info[0]}
    ${user_name}    Set Variable    ${server_pc_info[1]}
    ${password}   Set Variable    ${server_pc_info[2]}
    ${server_port}    Set Variable     ${server_pc_info[3]}
    csn.Connect to    hostname=${ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}

    csn.execute
    ...  command=ps -ef|grep iperf|grep -v grep|grep '\\-p ${port}'| awk '{print $2}' |xargs kill -9    connection=${alias}

    [Teardown]    csn.disconnect    connection=${alias}

Stop Iperf Server
    [Arguments]    ${server_pc_info}   ${port}   ${alias}=server
    Teardown Iperf    server_pc_info=${server_pc_info}    port=${port}    alias=${alias}


Stop Iperf Client
    [Arguments]    ${client_pc_info}      ${port}    ${alias}=client
    Teardown Iperf    server_pc_info=${client_pc_info}    port=${port}    alias=${alias}


Start Ping
    [Arguments]    ${pc_info}    ${ip}    ${logfile}    ${alias}=server_default
    ${pc_ip}     Set Variable    ${pc_info[0]}
    ${user_name}    Set Variable    ${pc_info[1]}
    ${password}   Set Variable    ${pc_info[2]}
    ${server_port}    Set Variable     ${pc_info[3]}
    csn.Connect to    hostname=${pc_ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}

    csn.send_command
    ...  command=/usr/bin/nohup ping ${ip} > ${logfile} 2>&1 0</dev/null&    connection=${alias}

    [Teardown]    csn.disconnect    connection=${alias}

Stop Ping
    [Arguments]    ${pc_info}    ${ip}    ${alias}=server_default
    ${pc_ip}     Set Variable    ${pc_info[0]}
    ${user_name}    Set Variable    ${pc_info[1]}
    ${password}   Set Variable    ${pc_info[2]}
    ${server_port}    Set Variable     ${pc_info[3]}
    csn.Connect to    hostname=${pc_ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}

    csn.execute
    ...  command=ps -ef|grep ping|grep -v grep|grep ${ip}| awk '{print $2}' |xargs kill -2    connection=${alias}

    [Teardown]    csn.disconnect    connection=${alias}

Remote Execute Cmd
    [Arguments]    ${pc_info}    ${cmd}    ${alias}=server_default
    ${ip}     Set Variable    ${pc_info[0]}
    ${user_name}    Set Variable    ${pc_info[1]}
    ${password}   Set Variable    ${pc_info[2]}
    ${port}    Set Variable     ${pc_info[3]}
    csn.Connect to    hostname=${ip}
    ...               username=${user_name}
    ...               password=${password}
    ...               alias=${alias}

    csn.execute    command=${cmd}    connection=${alias}
    [Teardown]    csn.disconnect    connection=${alias}
