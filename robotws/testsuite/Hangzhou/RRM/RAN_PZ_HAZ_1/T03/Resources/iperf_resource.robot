*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

# Resource          common_resource.robot


*** Keywords ***
Start DL traffic via iperf on assign Appserver
    [Documentation]  This keyword connect to Appserver and start the iperf data.
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}    ${ue_index}=0    ${appserver}=assignAPPserver
    run keyword if    '${appserver}'=='assignAPPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to assign APPserver    alias=APPserver_${ue_index}    ue_index=${1}
    ...    ELSE IF    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver    alias=APPserversim_${ue_index}
    Log    APPserver_${ue_index}
#    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver_${ue_index}
    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver_${ue_index}
    [Teardown]    csn.disconnect    connection=APPserver_${ue_index}

Close the iperf process on assign APPserver
    [Arguments]    ${port}    ${ue_index}    ${appserver}=assignAPPserver
    log    APPserver_${ue_index}
    run keyword if    '${appserver}'=='assignAPPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to assign APPserver    alias=APPserver_${ue_index}    ue_index=${1}
    ...    ELSE IF    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver    alias=APPserver_${ue_index}
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=APPserver_${ue_index}
    [Teardown]    Csn.disconnect      connection=APPserver_${ue_index}

Connect to assign APPserver
    [Arguments]    ${alias}=APPserver    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...               username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=APPServer_${alias}

Connect To IperfServer From Appservers
    [Arguments]    ${index}=${0}
    csn.Connect to    hostname=${tl.appservers[${index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.appservers[${index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.appservers[${index}].iperf_details.ssh_connection_details.password}
    ...               alias=IperfServer${index}
    [Return]    IperfServer${index}

Start DL traffic By Iperf
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.appserver.iperf_details.port}    ${time}=10
    ...            ${traffic}=10.00M    ${buffer_size}=1024B    ${ue_ip}=${None}
    ...            ${dl_server}=APPserver    ${index_of_yaml}=${0}
    [Documentation]    This kw is used to Start DL traffic,will get ue ip by AT command
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Home_button | yes | UE home button keycode |
    ...    | swipe | yes | Swipe the phone screen up |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | DL_port | yes | set DL port |
    ...    | traffic | yes | Throughput of new data transfer |
    ...    | buffer_size | yes | buffer size of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start DL traffic | ue_index=${ue_index} | time=${time} | interval=${interval} | traffic=${traffic} |
    ...    | ...              | buffer_size=${buffer_size} | DL_port=${DL_port} |
    ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}    ${index_of_yaml}
    ${ue_ip}    Run Keyword If    '${ue_ip}'=='${None}'    ${ue_type}.Get UE IP    ue_index=${ue_index}
    ...    ELSE    Set Variable    ${ue_ip}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_ip}    dl_time=${time}    dl_port=${DL_port}
    ...    dl_throughput=${traffic}    dl_length=${buffer_size}    appserver=${dl_server}

Ping Check
    [Arguments]    ${ip}    ${intervalofpings}=5    ${numberofping}=20
    ${Ping_Command}=    Set variable    ping -c ${numberofping} -i ${intervalofpings} ${ip} | grep -E 'loss|rtt|unreachable'
    ${ret}    Run    ${Ping_Command}
    Verify ping is not losted    ping_result=${ret}