# @Time    : 2023/4/14 10:42
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : multi_ue.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common robot keywords template
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Get UE IPS From Control PC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    special to get ue ips from cmd ipconfig
    [Arguments]    ${cpc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[0].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[0].ssh_connection_details.password}
    ...    ${local_path}=/home/ute/MMW_SG5/ipconfig.txt
    Connect to control pc enhanced    cpc_ip=${cpc_ip}
    ...    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=ipconfig > ipconfig.txt   connection=cpc_0
    Sleep    3s
    csn.download_file    remote_path=ipconfig.txt
    ...                  local_path=${local_path}
    ...                  connection=cpc_0
    ${ue_ips}    get_ue_ips_from_ipconfig    ${local_path}
    [Return]    ${ue_ips}

Multi-UE Start DL TCP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_names}
    # get all available ue ips from control pc
    ${ue_ips}    Get UE IPS From Control PC
    # close all iperf on control pc for dl tcp
    Connect to control pc enhanced    # default alia is cpc_0
    csn.send_command    command=ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9
    ...    connection=cpc_0
    Sleep    3s
    # start dl tcp for multi-ue
    FOR    ${name}    IN    @{ue_names}
        Spark PC Start TCP Server    ${ue_ips["${name}"]}
        sleep    3s
        Spark Start TCP DL Traffic    ${ue_ips["${name}"]}
    END

Multi-UE Stop DL TCP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    # get all available ue ips from control pc
    ${ue_ips}    Get UE IPS From Control PC
    # close all iperf on control pc for dl tcp
    Connect to control pc enhanced    # default alia is cpc_0
    csn.send_command    command=ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9
    ...    connection=cpc_0
    [Teardown]    csn.disconnect    connection=cpc_0

Spark PC Start TCP Server
    [Arguments]    ${ue_ip}    ${iperf_port}=45360
    Connect to control pc enhanced    # default alia is cpc_0
    csn.send_command    command=iperf -s -p ${iperf_port} -i 1 -w 16M -B ${ue_ip} &
    ...    connection=cpc_0
    [Teardown]    csn.disconnect    connection=cpc_0

Spark Start TCP DL Traffic
    [Arguments]    ${ue_ip}    ${iperf_port}=45360    ${traffic_time}=600    ${ue_index}=0
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.send_command
    ...   command=iperf -p ${iperf_port} -f 10m -i 1 -t ${traffic_time} -M 1400 -c ${ue_ip} >/dev/null 2>/dev/null &
    ...   connection=EPCAPP
