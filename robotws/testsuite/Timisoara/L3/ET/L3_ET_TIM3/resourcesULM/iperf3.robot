*** Settings ***
Documentation     
...    Keywords related to iperf3 handling
...
...    workaround for qualcomm UE (adb based)
...     

Resource    connect.robot
Resource    testline.robot
Library     taf.transport.ssh    WITH NAME    ssh

*** Keywords ***
Listen for throughput on appsrv
    [Documentation]
    ...     start iper3 server on appsrv
    ...
    [Arguments]     ${appsrv}    ${direction}    ${port}
    ${listen1}=     Catenate     nohup iperf3 -s -i 1 -p ${port} > /tmp/iperf3_${direction}_${port}.txt 2>&1 &
    ssh.Send command    ${listen1}    connection=${appsrv}
    ${command}=    Catenate   ps -aux | grep iperf3 | tr -s ' ' | grep -e '-p ${port}' | awk '{print $2}'
    ${pid}=        ssh.execute   ${command}    connection=${appsrv}
    ${pid}=        Fetch From Left    ${pid}  \r
    [Return]  ${pid}

Find free port on app server
    [Documentation]
    ...     discover a free port on appSvr
    ...
    [Arguments]    ${appsrv}
    FOR  ${i}  IN RANGE   1
        ${port}=       Evaluate    random.randint(1000, 9999)    random
        ${command}=    Catenate   ps -aux | grep iperf3 | tr -s ' ' | grep -e '-p ${port}' | awk '{print $2}'
        ${pid}=        ssh.execute   ${command}    connection=${appsrv}
        @{pid_list}=   Split String    ${pid}       \r\n
        ${pid_nr}=     Get length      ${pid_list}
        Exit For Loop If    ${pid_nr} <= 1
    END
    [Return]       ${port}

Kill iperf3 on appsrv
    [Documentation]
    ...     kill all iperf3 processes on appSvr
    ...
    [Arguments]    ${appsrv}
    ${kill}=       Catenate     pkill -9 iperf3
    ssh.execute     ${kill}    connection=${appsrv}

Kill Iperf3 on UEPC
    [Documentation]
    ...     kill all iperf3 processes on androidUE
    ...
    [Arguments]       ${ue_pc}
    ssh.Send command     adb shell su 0 "pkill -9 $(ps -A | grep "iperf3" | awk '{print $2}')"    connection=${ue_pc}

Start UL throughput
    [Documentation]
    ...     run iperf3 on androidUE and start UL traffic - UDP per default
    ...
    [Arguments]    ${uepc}  ${app_server_ip}  ${duration}  ${port}  ${bandwidth}  ${paralels}=1  ${udp}=True
    ${send_ul}=     Catenate    adb shell iperf3 -c ${app_server_ip} -i 1 -t ${duration}
    ${send_ul}=     Catenate    ${send_ul} -p ${port} -b ${bandwidth} -P ${paralels} -w 16M
    Run keyword if    ${udp}==True
    ...    ssh.Send command      ${send_ul} -u    connection=${uepc}
    ...    ELSE    ssh.Send command      ${send_ul}    connection=${uepc}

Start DL throughput
    [Documentation]
    ...     run iperf3 on androidUE and start DL traffic - TCP per default
    ...
    [Arguments]    ${uepc}  ${app_server_ip}  ${duration}  ${port}  ${bandwidth}  ${pkt_size}=1448  ${paralels}=1  ${udp}=True
    ${send_dl}=    Catenate      adb shell iperf3 -c ${app_server_ip} -i 1 -t ${duration}
    ${send_dl}=    Catenate      ${send_dl} -p ${port} -l ${pkt_size} -R -b ${bandwidth} -P ${paralels} -w 16M
    ${send_dl}=    Catenate      ${send_dl} > C:/iperf3_downloads/iperf3_DL_${port}.txt 2>&1
    ssh.Send command      mkdir C:/iperf3_downloads    connection=${uepc}
    Run keyword if    ${udp}==True
    ...    ssh.Send command      ${send_dl} -u    connection=${uepc}
    ...    ELSE    ssh.Send command      ${send_dl}    connection=${uepc}

Get IPerf3 UL results
    [Documentation]
    ...     copy iper3 output file from appSvr to testPC
    ...
    [Arguments]          ${app_server}    ${port}
    ${file_name}=        Catenate    iperf3_UL_${port}.txt
    ssh.download_file    remote_path=/tmp/${file_name}
    ...                  local_path=${OUTPUT DIR}/${file_name}
    ...                  connection=${app_server}

Get IPerf3 DL results
    [Documentation]
    ...     copy iper3 output file from uePC to testPC
    ...
    [Arguments]          ${ue_pc_server}    ${port}
    ${file_name}=        Catenate    iperf3_DL_${port}.txt
    ssh.download_file    remote_path=C:/iperf3_downloads/${file_name}
    ...                  local_path=${OUTPUT DIR}/${file_name}
    ...                  connection=${ue_pc_server}

Get Throughput Value
    [Documentation]
    ...     read Tput from iper3 output file
    ...
    [Arguments]        ${direction}    ${port}    ${remote}
    ${command}=  Catenate  cat ${OUTPUT DIR}/iperf3_${direction}_${port}.txt | grep receiver| tail -1|
    ${command}=  Catenate  ${command} awk -F ']' '{print $2}' | awk -F ' ' '{print $5}'
    ${throughput}=     ssh.Execute    ${command}    connection=${remote}
    ${throughput}=      Fetch From left    ${throughput}    \r
    [Return]           ${throughput}

Verify throupt value with variance
    [Documentation]
    ...     check if actual value is circa expected value +/- variance in percentage,
    ...     variance is a number between 0 and 100
    ...
    [Arguments]    ${actual}    ${expected}    ${variance}
    ${lower_limit}=    Evaluate    ${expected}*(1-(${variance}/100))
    ${upper_limit}=    Evaluate    ${expected}*(1+(${variance}/100))
    Should Be True     ${actual}>=${lower_limit}
    Should Be True     ${actual}<${upper_limit}

Start iperf3 traffic for UL and DL
    [Documentation]
    ...     example how to use iperf3 keywords,
    ...     it starts concurrent DL (TCP) and UL (UDP) traffic
    ...
    [Arguments]     ${ue_id}    ${expected_ul}    ${expected_dl}    ${pkt_size}
    ...    ${ul_duration}    ${dl_duration}    ${ul_bandwidth}    ${dl_bandwidth}    ${ul_Parallels}=1    ${dl_Parallels}=1
    ...    ${variance}=0    ${ul_udp}=True    ${dl_udp}=True
    ${ue_pc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    ${app_server_alias}=    connect.Connect to core application server    ue_id=${ue_id}
    ${app_server_ip}    Set Variable    ${tl.appserver.iperf_details.ssh_connection_details.addr}
    ${ul_tput_port}  Find free port on app server    ${app_server_alias}
    ${dl_tput_port}  Find free port on app server    ${app_server_alias}
	set test variable  ${dl_tput_port_${ue_id}}  ${dl_tput_port}
	set test variable  ${ul_tput_port_${ue_id}}  ${ul_tput_port}
    log to console   >>>>>>>>> Start UL throughput with iperf3 on UE${ue_id} <<<<<<<<<
    ${pid_ul}    Listen for throughput on appsrv      appsrv=${app_server_alias}  direction=UL  port=${ul_tput_port_${ue_id}}
    Start UL throughput    uepc=${ue_pc_alias}  app_server_ip=${app_server_ip}  duration=${ul_duration}
    ...    port=${ul_tput_port_${ue_id}}  bandwidth=${ul_bandwidth}
    ...    paralels=${ul_Parallels}  udp=${ul_udp}
    log to console   >>>>>>>>> Start DL throughput with iperf3 on UE${ue_id} <<<<<<<<<
    ${pid_dl}    Listen for throughput on appsrv      appsrv=${app_server_alias}  direction=DL  port=${dl_tput_port_${ue_id}}
    Start DL throughput    uepc=${ue_pc_alias}  app_server_ip=${app_server_ip}  duration=${dl_duration}
    ...    port=${dl_tput_port_${ue_id}}  bandwidth=${dl_bandwidth}  pkt_size=${pkt_size}
    ...    paralels=${dl_Parallels}  udp=${dl_udp}

Kill all iperf3 processes
    [Documentation]
    ...     kill all iperf3 processes on testpc and appserver
    ...
    ${app_server_alias}=    connect.Connect to core application server    ue_id=${0}
    Kill iperf3 on appsrv      appsrv=${app_server_alias}
    ${ue_count}  Get Length  ${tl.ues}
    FOR    ${ue_id}    IN RANGE    ${ue_count}
        ${ue_pc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
        Kill Iperf3 on UEPC    ue_pc=${ue_pc_alias}
    END

Verify Average iperf3 Throughput With Deviation
    [Documentation]
    ...     check if actual value is circa expected value +/- variance in percentage,
    ...     variance is a number between 0 and 100
    ...
    [Arguments]  ${expected_ul}      ${expected_dl}    ${variance}  ${ue_id}
    ${app_server_alias}=    connect.Connect to core application server    ue_id=${ue_id}
    ${test_pc_alias}=      Connect to TestPC
    ${ue_pc_alias}=    connect.Connect to UE PC    ue_id=${ue_id}
    Get IPerf3 UL results    app_server=${app_server_alias}    port=${ul_tput_port_${ue_id}}
    Get IPerf3 DL results    ue_pc_server=${ue_pc_alias}       port=${dl_tput_port_${ue_id}}
    ${ul_actual}=    Get Throughput Value     UL    ${ul_tput_port_${ue_id}}    ${test_pc_alias}
    ${dl_actual}=    Get Throughput Value     DL    ${dl_tput_port_${ue_id}}    ${test_pc_alias}
    Log to console   \n--> UL Throughput= ${ul_actual} Mbits
    Log to console   \n--> DL Throughput= ${dl_actual} Mbits
    run keyword and continue on failure    Verify throupt value with variance    expected=${expected_ul}    actual=${ul_actual}    
    ...  variance=${variance}
    run keyword and continue on failure    Verify throupt value with variance    expected=${expected_dl}    actual=${dl_actual}    
    ...  variance=${variance}
    ssh.Send command      rmdir /Q /S C:/iperf3_downloads    connection=${ue_pc_alias}

######## needs to be changed
Await iperf3 data Transfer Finish
    [Documentation]
    ...    wait until iperf is finished,
    ...    needs to be changed....
    ...
    Sleep   ${dl_duration}    reason=wait for finish tput on appsrv
    Sleep   5 sec   reason=wait for finish UL tput on appsrv
    ssh.execute      kill -9 ${pid_ul}    connection=${app_server_alias}
    Sleep   5 sec   reason=wait for finish DL tput on appsrv
    ssh.execute      kill -9 ${pid_dl}    connection=${app_server_alias}
