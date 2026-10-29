*** Settings ***
Documentation
...    author: ChenXu
...    contact: xu.2.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_5_SG

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh    WITH NAME    csn
Library    Telnet

#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/qualcomm_common_keywords.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot

*** Variables ***
${ue_code}   *%23*%232846579159%23*%23*

*** Keywords ***

TL127 Start DL TCP traffic and check the TP on EPC
    [Documentation]    stat DL TCP traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=1200
    ...            ${interval}=1    ${traffic}=10.00M
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${process_num}=${4}    ${seg_size}=4880    ${window}=2M
	log to console    Start DL TCP traffic
    Get Commercial UE IP    ue_index=${ue_index}
	sleep    2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=pwd    connection=cygwin
	${tmp_output} =    csn.Read Output    connection=cygwin
	#log to console    This is ${tmp_output}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf -s -p ${DL_port} -i 1 -N -w 3M &
    ...    connection=cygwin
    sleep    3s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP TL127    ue_index=${ue_index}
	csn.send_command    command=pwd    connection=EPCAPP
	${tmp_output} =    csn.Read Output    connection=EPCAPP
	#log to console    This is ${tmp_output}
    csn.send_command    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep    5s
    FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i}
        csn.send_command
       ...   command=iperf -c ${UE_IP} -m -i 1 -t ${time} -p ${DL_port} -w 3M -P ${process_num} -M 1350 >/dev/null 2>/dev/null &
       ...   connection=EPCAPP
	   sleep    3s
       csn.send_command    command=ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
       ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
	log to console    \n .....UE_${ue_index} tcp dl iperf start.... \n
    #[Teardown]    csn.disconnect      connection=EPCAPP}

Connect to EPC APP TL127
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=EPCAPP

TL127 Start UL TCP traffic and check the TP on Commercial
    [Arguments]
    ...    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}    ${interval}=1
    ...    ${time}=1200
    ...    ${traffic}=10.00M    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${data_amount}=1M    ${process_num}=${5}
    log to console    Start UL TCP traffic
    Get Commercial UE IP    ue_index=${ue_index}
	sleep    2s
    Connect to control pc via cygwin    ue_index=${ue_index}
	csn.send_command    command=pwd    connection=cygwin
	${tmp_output} =    csn.Read Output    connection=cygwin
	#log to console    This is ${tmp_output}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=cygwin
    sleep    1s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP TL127    ue_index=${ue_index}
    sleep   1s
	csn.send_command    command=pwd    connection=EPCAPP
	${tmp_output} =    csn.Read Output    connection=EPCAPP
	#log to console    This is ${tmp_output}
    csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &   connection=EPCAPP
    sleep    5s
	FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i}
        csn.send_command
       ...   command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -R -w ${data_amount} -M 1350 -P ${process_num} >/dev/null 2>/dev/null &
       ...   connection=EPCAPP
	   sleep    2s
       csn.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}'
       ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
    log to console    \n .....UE_${ue_index} tcp ul iperf start.... \n
    #[Teardown]    csn.disconnect      connection=EPCAPP
