*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              author: Shi Zhihao
...              Contact: zhihao.shi@nokia-sbell.com
...              Verified equipment: cpe_lte

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot

*** Variables ***

*** Keywords ***
Prepare UE
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  reset_sol: <Boolean> Reset ue by adb command or not.
    Prepare At Cmd UE CPE    ue_index=${ue_index}

UE Attach
    [Arguments]    ${ue_index}=${0}    ${abil_index}=${1}    ${interval}=${1}    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for attach
    ...  :param  abil_index: <Int> [ABIL1 ABIL2 ABIL3] with abil index input to connect to
    ...  :param  interval: define the interval time(seconds) between with UE detach and attach
    ${status}    ${info}    run keyword and ignore error    ute_ue.Send At Cmd To Ue   UE_${ue_index}    at_cmd=AT+CFUN?
    run keyword if    '${status}'=='FAIL'    Reboot on ue manage ip    ue_index=${ue_index}
    ute_ue.attach_ue    ue_alias=UE_${ue_index}

Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${ue_index}=${0}    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic. E.G 120
    ...  :param  throughput: Throughput(M) of new data transfer, Unit in Mbps
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    ${default_port}    set variable if    '${direction.lower()}'=='ul'    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ...                                                           ${ue_config['data_transfer']['iperf_options']['qci']['6']}
    Start udp data via iperf    direction=${direction}    duration=${duration}    throughput=${throughput}M
    ...  iperf_port=${default_port}    ue_index=${ue_index}

Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    &{kwargs}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    ${default_port}    set variable if    '${direction.lower()}'=='ul'    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ...                                                           ${ue_config['data_transfer']['iperf_options']['qci']['6']}
    Stop udp data via iperf    direction=${direction}    iperf_port=${default_port}    ue_index=${ue_index}

Collect Tput
    [Arguments]    ${duration}=10m    ${ignore_time}=1min    ${ue_index}=${0}    ${log_dir}=${OUTPUT_DIR}    &{kwargs}
    sleep    ${ignore_time}
    sleep    ${duration}
    [Return]    ${log_dir}

Check Tput
    [Arguments]    ${direction}    ${target_throughput}    ${log}=${OUTPUT_DIR}    ${ue_index}=${0}    &{kwargs}
    ${full_log_path}    run keyword if    '${direction.lower()}'=='dl'
    ...  downlod iperf log on ue manage ip    log_path=${log}    ue_index=${ue_index}
    ...    ELSE IF    '${direction.lower()}' == 'ul'  downlod iperf log on appserver    log_path=${log}
    run keyword if    '${direction.lower()}' == 'dl'    check DL throughput for CPE
    ...                                         dl_expect=${target_throughput}
    ...                                         full_log_path=${full_log_path}
    ...    ELSE IF    '${direction.lower()}' == 'ul'    check UL throughput for CPE
    ...                                         ul_expect=${target_throughput}
    ...                                         full_log_path=${full_log_path}

UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    ute_ue.detach_ue    ue_alias=UE_${ue_index}
