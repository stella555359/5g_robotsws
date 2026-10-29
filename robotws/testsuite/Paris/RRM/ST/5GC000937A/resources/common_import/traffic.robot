*** Settings ***

Documentation     Keywords related to traffic handling
...               :Author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com
...


#Library    ute_ue
Library    taf.transport.ssh    WITH NAME    ssh
Library    ./python//iperf_throughput_evaluator.py    WITH NAME    throughput
Library    ./python/testline.py           WITH NAME    testline

Resource    ./connect.robot
Resource    ./testline.robot

*** Variables ***

&{real_core_bearer_default}    port=${50000}
&{real_core_bearer_two}    port=${50005}
&{real_core_bearer_three}    port=${50006}
&{real_core_bearer_four}    port=${50007}
&{real_core_bearer_five}    port=${50008}
&{real_core_bearer_six}    port=${50069}
&{real_core_bearer_seven}    port=${50070}
&{real_core_bearer_dict}    1=&{real_core_bearer_default}    2=&{real_core_bearer_two}    3=&{real_core_bearer_three}
...    4=&{real_core_bearer_four}    5=&{real_core_bearer_five}    6=&{real_core_bearer_six}    7=&{real_core_bearer_seven}
${P_console}        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***

Start iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start DL/UL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param dl_rate: DL bandwidth to send at in bits/sec (e.g. 20 Mbit/sec)
    ...    :param ul_rate: UL bandwidth to send at in bits/sec (e.g. 2 Mbit/sec)
    ...    :param bearer_id: ID of bearer
    ...    :param dl_streams: DL number of parallel client threads to run
    ...    :param ul_streams: UL number of parallel client threads to run
    ...    :param dl_interval: DL seconds between periodic bandwidth reports
    ...    :param ul_interval: UL seconds between periodic bandwidth reports
    ...    :param dl_buffer_len: DL length of buffer to read or write
    ...    :param ul_buffer_len: UL length of buffer to read or write
    ...    :param dl_duration: DL traffic duration
    ...    :param ul_duration: UL traffic duration
    ...
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv    ${core_appserv_alias}=core-appserv
    ...    ${dl_rate}=${EMPTY}    ${ul_rate}=${EMPTY}    ${bearer_id}=${1}    ${dl_streams}=${1}    ${ul_streams}=${1}
    ...    ${dl_interval}=${1}    ${ul_interval}=${1}    ${dl_buffer_len}=${1000}    ${ul_buffer_len}=${1000}
    ...    ${dl_duration}=${7200}    ${ul_duration}=${7200}

    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    connect.Connect to core application server    alias=${core_appserv_alias}

    Run keyword if    '${dl_rate}'!='${EMPTY}'    Start DL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    dl_streams=${dl_streams}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    dl_rate=${dl_rate}    bearer_id=${bearer_id}    dl_interval=${dl_interval}
    ...    dl_buffer_len=${dl_buffer_len}    dl_duration=${dl_duration}

    Run keyword if    '${ul_rate}'!='${EMPTY}'    Start UL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ul_streams=${ul_streams}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    ul_rate=${ul_rate}    bearer_id=${bearer_id}    ul_interval=${ul_interval}
    ...    ul_buffer_len=${ul_buffer_len}    ul_duration=${ul_duration}

    ssh.disconnect    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${core_appserv_alias}


Start DL iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start DL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param dl_rate: DL bandwidth to send at in bits/sec (e.g. 20 Mbit/sec)
    ...    :param bearer_id: ID of bearer
    ...    :param dl_streams: DL number of parallel client threads to run
    ...    :param dl_interval: DL seconds between periodic bandwidth reports
    ...    :param dl_buffer_len: DL length of buffer to read or write
    ...    :param dl_duration: DL traffic duration
    ...
    [Arguments]    ${dl_rate}    ${ue_id}=${0}    ${dl_streams}=${1}    ${ue_appserv_alias}=ue-appserv
    ...    ${core_appserv_alias}=core-appserv    ${mue_id}=${0}    ${bearer_id}=${1}    ${dl_interval}=${1}
    ...    ${dl_buffer_len}=${1000}    ${dl_duration}=${7200}

    ${port}=    Get iperf port    base_port=${49999}    mue_id=${mue_id}    bearer_id=${bearer_id}
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    ${ue_ip}=    Run keyword if    '${ue_type}'=='viavi'    Get UE IP from PPPoE interface
    ...    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    ELSE IF    '${ue_type}'=='qualcomm'    BuiltIn.Log    ToDo
    ...    ELSE    BuiltIn.Log    ToDo

    Kill iperf process    ip=${ue_ip}    port=${port}    connection=${ue_appserv_alias}
    Kill iperf process    ip=${ue_ip}    port=${port}    connection=${core_appserv_alias}

    ssh.execute    command=rm /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${ue_appserv_alias}
    ssh.execute    command=rm /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${core_appserv_alias}

    ${cmdStr}=    Catenate    ${tl.ues[${ue_id}].iperf_details.iperf_path} -B ${ue_ip} -s -u -i ${dl_interval} -p ${port}
    ...    > /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ${dl_traffic}=  Evaluate  ${dl_rate[:-1]} * ${dl_streams}
    BuiltIn.Log     Start DL ${dl_traffic}${dl_rate[-1]} traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id}  console=${P_console}
    ssh.send_command    command=${cmdStr}    connection=${ue_appserv_alias}
    ${cmdStr}=    Catenate    ${tl.appserver.iperf_details.iperf_path} -c ${ue_ip} -b ${dl_rate} -u -P ${dl_streams}
    ...    -i ${dl_interval} -p ${port} -l ${dl_buffer_len} -t ${dl_duration} > /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ssh.send_command    command=${cmdStr}    connection=${core_appserv_alias}
    BuiltIn.Log     DL ${dl_traffic}${dl_rate[-1]} traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id} is started!
    ...  console=${P_console}


Get UE IP from PPPoE interface
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${mue_id}    ${ue_appserv_alias}
    ${response}=    ssh.execute    command=sudo ifconfig ppp${mue_id}    connection=${ue_appserv_alias}
    ${ue_ip}=    testline.extract_ip  text=${response}
    [Return]    ${ue_ip}


Start UL iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start UL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param ul_rate: UL bandwidth to send at in bits/sec (e.g. 2 Mbit/sec)
    ...    :param bearer_id: ID of bearer
    ...    :param ul_streams: UL number of parallel client threads to run
    ...    :param ul_interval: UL seconds between periodic bandwidth reports
    ...    :param ul_buffer_len: UL length of buffer to read or write
    ...    :param ul_duration: UL traffic duration
    ...
    [Arguments]    ${ul_rate}    ${ue_id}=${0}    ${ul_streams}=${1}    ${ue_appserv_alias}=ue-appserv
    ...    ${core_appserv_alias}=core-appserv    ${mue_id}=${0}    ${bearer_id}=${1}    ${ul_interval}=${1}
    ...    ${ul_buffer_len}=${1000}    ${ul_duration}=${7200}

    ${port}=    Get iperf port    base_port=${59999}    mue_id=${mue_id}    bearer_id=${bearer_id}
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    ${binding_ip}=    testline.increment_ip    ${tl.appserver.iperf_details.network_interface_address}    ${mue_id}
    ${client_ip}=    testline.increment_ip    ${tl.ues[${ue_id}].iperf_details.network_interface_address}    ${mue_id}

    Kill iperf process    ip=${client_ip}    port=${port}    connection=${ue_appserv_alias}
    Kill iperf process    ip=${binding_ip}    port=${port}    connection=${core_appserv_alias}

    ssh.execute    command=rm /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${ue_appserv_alias}
    ssh.execute    command=rm /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${core_appserv_alias}

    ${cmdStr}=    Catenate    ${tl.appserver.iperf_details.iperf_path} -B ${binding_ip}
    ...    -s -u -i ${ul_interval} -p ${port} > /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ${ul_traffic}=  Evaluate  ${ul_rate[:-1]} * ${ul_streams}
    BuiltIn.Log     Start UL ${ul_traffic}${ul_rate[-1]} traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id}
    ...  console=${P_console}
    ssh.send_command    command=${cmdStr}    connection=${core_appserv_alias}
    ${cmdStr}=    Catenate    ${tl.ues[${ue_id}].iperf_details.iperf_path} -c ${client_ip}
    ...    -b ${ul_rate} -u -P ${ul_streams}  -i ${ul_interval} -p ${port} -l ${ul_buffer_len} -t ${ul_duration}
    ...    > /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ssh.send_command    command=${cmdStr}    connection=${ue_appserv_alias}
    BuiltIn.Log     UL ${ul_traffic}${ul_rate[-1]} traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id} is started!
    ...  console=${P_console}


Stop iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop DL/UL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param bearer_id: ID of bearer
    ...    :param direction: traffic direction (dl or ul)
    ...
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${bearer_id}=${1}    ${direction}=${EMPTY}
    ...    ${ue_appserv_alias}=ue-appserv    ${core_appserv_alias}=core-appserv

    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    connect.Connect to core application server    alias=${core_appserv_alias}

    Run keyword if    '${direction}'=='dl'    Stop DL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    bearer_id=${bearer_id}

    Run keyword if    '${direction}'=='ul'    Stop UL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    bearer_id=${bearer_id}

    Run keyword if    '${direction}'=='${EMPTY}'  Stop UL and DL Traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    bearer_id=${bearer_id}

    ssh.disconnect    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${core_appserv_alias}


Stop DL iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop DL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param bearer_id: ID of bearer
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_appserv_alias}=ue-appserv    ${core_appserv_alias}=core-appserv
    ...    ${mue_id}=${0}    ${bearer_id}=${1}

    ${port}=    Get iperf port    base_port=${49999}    mue_id=${mue_id}    bearer_id=${bearer_id}
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    ${ue_ip}=    Run keyword if    '${ue_type}'=='viavi'    Get UE IP from PPPoE interface
    ...    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    ELSE IF    '${ue_type}'=='qualcomm'    BuiltIn.Log    ToDo
    ...    ELSE    BuiltIn.Log    ToDo

    Kill iperf process    ip=${ue_ip}    port=${port}    connection=${ue_appserv_alias}
    Kill iperf process    ip=${ue_ip}    port=${port}    connection=${core_appserv_alias}

    BuiltIn.Log     DL traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id} is stopped!     console=${P_console}


Stop UL iperf traffic
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop UL iperf traffic using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param mue_id: (default=0) UE Id in case of multiple Viavi UEs
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...    :param bearer_id: ID of bearer
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_appserv_alias}=ue-appserv    ${core_appserv_alias}=core-appserv
    ...    ${mue_id}=${0}    ${bearer_id}=${1}

    ${port}=    Get iperf port    base_port=${59999}    mue_id=${mue_id}    bearer_id=${bearer_id}
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    ${binding_ip}=    testline.increment_ip    ${tl.appserver.iperf_details.network_interface_address}    ${mue_id}
    ${client_ip}=    testline.increment_ip    ${tl.ues[${ue_id}].iperf_details.network_interface_address}    ${mue_id}

    Kill iperf process    ip=${client_ip}    port=${port}    connection=${ue_appserv_alias}
    Kill iperf process    ip=${binding_ip}    port=${port}    connection=${core_appserv_alias}

    BuiltIn.Log     UL traffic for ${ueType}${ue_id} and MUE${mue_id} in bearer${bearer_id} is stopped!     console=${P_console}


Stop all traffic threads
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop all iperf traffic threads using the following arguments
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param ue_appserv_alias: alias of ue application server
    ...    :param core_appserv_alias: alias of core application server
    ...
    [Arguments]    ${ue_id}=${0}    ${ue_appserv_alias}=ue-appserv    ${core_appserv_alias}=core-appserv

    BuiltIn.Log     Stop all traffic threads    console=${P_console}
    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    connect.Connect to core application server    alias=${core_appserv_alias}
    Wait until keyword succeeds    3 min    3 sec    Kill all iperf processes    connection=${ue_appserv_alias}
    Wait until keyword succeeds    3 min    3 sec    Kill all iperf processes    connection=${core_appserv_alias}
    ssh.disconnect    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${core_appserv_alias}
    BuiltIn.Log     All traffic threads are stopped!    console=${P_console}


Get iperf traffic stats
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${ue_appserv_alias}=ue-appserv
    ...    ${core_appserv_alias}=core-appserv    ${num_of_bearers}=${1}    ${target_dir}=None
    connect.Connect to UE application server    ue_id=${ue_id}    alias=${ue_appserv_alias}
    connect.Connect to core application server    alias=${core_appserv_alias}
    FOR    ${bearer_id}    IN RANGE    ${1}    ${num_of_bearers}+${1}
        Get iperf log files    ue_id=${ue_id}    mue_id=${mue_id}    bearer_id=${bearer_id}
        ...    ue_appserv_alias=${ue_appserv_alias}    core_appserv_alias=${core_appserv_alias}
        ...    target_dir=${target_dir}
    END
    ssh.disconnect    connection=${ue_appserv_alias}
    ssh.disconnect    connection=${core_appserv_alias}


Get iperf log files
    [Documentation]    :Author: Vasileios Papoutsis
    [Arguments]    ${ue_id}=${0}    ${mue_id}=${0}    ${bearer_id}=${1}    ${ue_appserv_alias}=ue-appserv
    ...    ${core_appserv_alias}=core-appserv    ${target_dir}=None
    ${resultTestDir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get testcase log directory
    ...    ELSE    Set variable    ${target_dir}
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    Run keyword and ignore error    ssh.download_file    remote_path=/tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    local_path=${resultTestDir}/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${core_appserv_alias}
    ssh.execute    command=rm /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${core_appserv_alias}

    Run keyword and ignore error    ssh.download_file    remote_path=/tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    local_path=${resultTestDir}/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${ue_appserv_alias}
    ssh.execute    command=rm /tmp/ul_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${ue_appserv_alias}

    Run keyword and ignore error    ssh.download_file    remote_path=/tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    local_path=${resultTestDir}/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${core_appserv_alias}
    ssh.execute    command=rm /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_client.log
    ...    connection=${core_appserv_alias}

    Run keyword and ignore error    ssh.download_file    remote_path=/tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    local_path=${resultTestDir}/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${ue_appserv_alias}
    ssh.execute    command=rm /tmp/dl_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...    connection=${ue_appserv_alias}

    [Return]    ${resultTestDir}


Evaluate ue throughput
    [Documentation]    :Author: Srihari Janardhan
    ...    Evaluate throughput using the following arguments and returns the observed average throughput
    ...    If params analysis_start and analysis_end are not specified the average throughput of the entire server logs
    ...    is computed
    ...
    ...    :param ue_id: (default=0) UE Id in __init__.py
    ...    :param expected_throughput: Expected throughput value in desired_unit(e.g. 20)
    ...    :param data_direction: Direction of traffic (dl or ul)
    ...    :param resultTestDir: Directory of test logs
    ...    :param bearer_id: Id of UE bearer
    ...    :param mue_id: Viavi UE mue id
    ...    :param permitted_variance_percentage: Permitted percentage variance of throughput (e.g. 10)
    ...    :param analysis_start: Time in seconds from where the analysis should begin
    ...    :param analysis_end: Time in seconds from where the analysis should end
    ...    :param desired_unit: Unit bandwidth M (Mbps) K (Kbps) G(Gbps)  |  Default Value is M
    ...
    [Arguments]    ${expected_throughput}    ${data_direction}    ${resultTestDir}    ${ue_id}=${0}
    ...    ${bearer_id}=${1}    ${mue_id}=${0}    ${permitted_variance_percentage}=${10}  ${analysis_start}=${0}
    ...    ${analysis_end}=${0}  ${desired_unit}=M
    ${ueType}=    testline.Get UE type    ue_id=${ue_id}
    ${observed_average_throughput}=  Run keyword and continue on failure
    ...  Evaluate throughput    file_path=${resultTestDir}/${data_direction}_${ueType}${ue_id}_mue${mue_id}_bearer${bearer_id}_server.log
    ...  expected_throughput=${expected_throughput}  desired_unit=${desired_unit}
    ...  percentage_variance_permitted=${permitted_variance_percentage}
    ...  analysis_start=${analysis_start}  analysis_end=${analysis_end}
    [Return]  ${observed_average_throughput}


Evaluate throughput
    [Documentation]    :Author: Srihari Janardhan
    [Arguments]    ${file_path}    ${expected_throughput}    ${percentage_variance_permitted}
    ...  ${analysis_start}=${0}  ${analysis_end}=${0}  ${desired_unit}=${EMPTY}
    ${observed_average_throughput}=  Get average throughput  file_path=${file_path}
    ...  analysis_start=${analysis_start}  analysis_end=${analysis_end}  desired_unit=${desired_unit}
    ${verdict}=    throughput.verdict_generator    expected_throughput=${expected_throughput}
    ...  actual_throughput=${observed_average_throughput}
    ...  allowed_variance=${percentage_variance_permitted}
    Run keyword and continue on failure  Should contain    Pass    ${verdict}
    [Return]  ${observed_average_throughput}


Get average throughput
    [Documentation]    :Author: Srihari Janardhan
    ...    Returns average throughput from iperf server logs
    ...
    ...    :param file_path: (default=0) UE Id in __init__.py
    ...    :param analysis_start: Time in seconds from where the analysis should begin
    ...    :param analysis_end: Time in seconds from where the analysis should end
    [Arguments]    ${file_path}    ${analysis_start}=${0}    ${analysis_end}=${0}  ${desired_unit}=${EMPTY}
    ${observed_average_throughput}=    throughput.compute_average    ${file_path}  ${analysis_start}  ${analysis_end}  ${desired_unit}
    [Return]  ${observed_average_throughput}



### Private ###
Kill iperf process
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${ip}    ${port}    ${connection}
    ssh.execute    command=pkill -9 -f 'iperf.*${ip}.*${port}'    connection=${connection}


Get iperf port
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${base_port}    ${mue_id}=${0}    ${bearer_id}=${1}
    ${bearer_id}=    Convert to string    ${bearer_id}
    ${bearer}=    Get From Dictionary    ${real_core_bearer_dict}    ${bearer_id}
    ${coreType}=    Get Core type
    ${port}=    Run keyword if    '${coreType}'=='epcsim'    Evaluate    ${base_port}+10*${mue_id}+${bearer_id}
    ...    ELSE    Get From Dictionary    ${bearer}    port
    [Return]    ${port}


Kill all iperf processes
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${connection}
    ${output}=    ssh.execute    command=sudo killall -9 iperf    connection=${connection}
    Should contain    ${output}    no process found


Stop UL and DL Traffic
    [Arguments]  ${ue_appserv_alias}  ${core_appserv_alias}  ${bearer_id}  ${ue_id}=0  ${mue_id}=0
    Stop DL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    bearer_id=${bearer_id}

    Stop UL iperf traffic
    ...    ue_id=${ue_id}    mue_id=${mue_id}    ue_appserv_alias=${ue_appserv_alias}
    ...    core_appserv_alias=${core_appserv_alias}    bearer_id=${bearer_id}
