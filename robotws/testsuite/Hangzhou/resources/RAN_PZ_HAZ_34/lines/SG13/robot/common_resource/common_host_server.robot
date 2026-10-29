*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library    json
Library    Collections
Library    OperatingSystem
Library    Process
Library    taf.transport.ssh    WITH NAME    ssh
Resource    base.robot

*** Variables ***
${kill_btslog}     timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_dpkg}     timeout 5 sudo kill -9 $(ps -ef|grep dpkg|grep tti-dec.deb|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1


*** Keywords ***
Clean Up Env
    [Arguments]    ${host_ip}=localhost
    [Documentation]    This keyword is to clean up testline process such as btslog and so on.
    ...    Examples:
    ...    | Clean Up Env |
	Run Keyword If     '${host_ip}'=='127.0.0.1' or '${host_ip}'=='localhost'    Run Keywords    Run     ${kill_btslog}
	...     AND     Run   ${kill_dpkg}
	...     AND     Run    rm /tmp/admin_api_*.txt -f
	...     AND     Run    rm /tmp/disconnect*.ims2 -f
	...     AND     Run    rm /tmp/*.pcap* -rf
	...     AND     Run    sudo rm /tmp/*.pcap* -rf
	...     ELSE    Run keywords    ssh.Connect To    ${host_ip}    ute    ute    alias=remote_connection
	...     AND     ssh.Execute    ${kill_btslog}    connection=remote_connection
    ...     AND     ssh.Disconnect    connection=remote_connection

Get Host IP
    [Documentation]    This keyword is to get testline control host intranet IP.
    ...    Examples:
    ...    | ${host_ip} | Get Host IP |
    ${command}    Set Variable    sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${rc}    ${output}=    OperatingSystem.Run and Return RC and Output    ${command}
    Log    [TL] Host IP:${output}
    Set Suite Metadata    Host IP    ${output}
	[Return]    ${output}

Get Host Name
    [Documentation]    This keyword is to get testline control host name.
    ...    Examples:
    ...    | ${host_name} | Get Host Name |
    ${rc}    ${output}=    OperatingSystem.Run and Return RC and Output    hostname
    Log    [TL] Host Name:${output}
    Set Suite Metadata    Host Name    ${output}
    ${testline_name}     Replace String  ${output}  -  _
    Set Global Variable    ${TL_NAME}    ${testline_name}
	[Return]    ${output}

Modify TL VM And AP SCTP Configuration
	[Documentation]    This keyword is to modify UTE and AP SCTP Timeout and Configure TL VM ETH3.
    ...    Examples:
    ...    | Modify TL VM And AP SCTP Configuration |
	Log To Console    Modify TL VM And AP SCTP Configuration...
	Modify TL VM SCTP Timeout
    Modify AP SCTP Timeout
    Configure TL VM ETH3

Modify TL VM SCTP Timeout
    [Documentation]    This keyword is to start AirPhone load 4.0.10852, The Sack Timeout In The WTS VM And AP ASIK Must Be
    ...    configured before cell setup.This Aims To Prevent Delayed Messaging Between AirPhone
    ...    and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    ...    Examples:
    ...    | Modify TL VM SCTP Timeout |
    OperatingSystem.Run    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_min=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_initial=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_max=800

Modify AP SCTP Timeout
    [Documentation]    This keyword is to Modify AP SCTP Timeout in Airphon ASIK
    ...      To Prevent Delayed Messaging Between AirPhone and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    ...    Examples:
    ...    | Modify AP SCTP Timeout |
    ssh.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}
    ${command}    Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...    sysctl -w net.sctp.rto_min=200 &&
    ...    sysctl -w net.sctp.rto_initial=200 &&
    ...    sysctl -w net.sctp.rto_max=800
    ssh.Execute    ${command}    ${AP_ASIK.connection}
    ssh.Disconnect    connection=${AP_ASIK.connection}

Configure TL VM ETH3
    [Documentation]    This keyword is to configure VM interfaces.
    ...    Examples:
    ...    | Configure TL VM ETH3 |
    Log To Console    Configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3

Get Test Line Type
    [Documentation]    This keyword is used to get testline type, CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD etc.
    ...    Examples:
    ...    | ${tl_type} | Get Test Line Type |
    ${reserve_file}=    Set Variable     /opt/ute/reservation.json
    ${file_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${reserve_file}
    return from keyword if    ${file_exist}==${False}    Local_Test_Line
    #${file_content}=    OperatingSystem.Get File    ${reserve_file}
    #&{testline_dict}=    json.Loads    ${file_content}
    #${testline_type}=    Collections.Get From Dictionary    ${testline_dict}    topology
	#Log To Console    testline_type=${testline_type}
	#Set Global Variable    ${testline_type}    ${testline_type}
    #@{words}=    String.Split String    ${testline_type}    _
    #${l1_type_1}=    Set Variable If    "FS" in @{words}      FS    L1b
    #${rf_type_1}=    Set Variable If    "ECPRI" in @{words}      eCPRI    CPRI
    #Set Global Variable    ${L1_TYPE}    ${l1_type_1}
    #Set Global Variable    ${RF_TYPE}    ${rf_type_1}
    #Set Global Variable    ${testline_type}    ${testline_type}
    [Return]    ${testline_type}

check ping is disabled
    [Arguments]   ${ip}    ${timeout}=60s
    [Documentation]    check unit cannot be pingable after reset, power off/on and so on
    ...    | Input Parameters | Man. | Description |
    ...    | ${ip} | Yes | host ip which need ping |
    ...    | ${timeout} | No | timeout, default is 60s |
    ...    Examples:
    ...    | check ping is disabled | 192.168.255.1 |
    ${ping}=    run process    ping -c 3 ${ip}    timeout=${timeout}    shell=True
    should contain    ${ping.stdout}    100% packet loss

check ping is enabled
    [Arguments]   ${ip}    ${timeout}=60s
    [Documentation]    check unit can be pingable after reset, power off/on and so on
    ...    | Input Parameters | Man. | Description |
    ...    | ${ip} | Yes | host ip which need ping |
    ...    | ${timeout} | No | timeout, default is 60s |
    ...    Examples:
    ...    | check ping is enabled| 192.168.255.1 |
    ${ping}=    run process    ping -c 3 ${ip}    timeout=${timeout}    shell=True
    should contain    ${ping.stdout}    3 received
