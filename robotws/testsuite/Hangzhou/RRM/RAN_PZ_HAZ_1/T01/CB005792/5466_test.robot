*** Settings ***
Documentation
...   Author: gcao
...   Contact: ge.cao@nokia-sbell.com
...   Description: This case describes the support of the activation and deactivation of PRACH format B4 per cell,
...                and the support of both starting symbol 0 and 2
...    Deprecated case removed by civen.chen
#
#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC
#
#Force Tags
#...                CA_RAN_PZ_HAZ_1
#...                RAN_PZ_HAZ1_SG02_ST_RRM
#...                TA_LEVEL_22
#...                CRT
#...                TRUNK
#
#
#Test Timeout    50 minutes
#
#Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
#
#
#
#*** Test Cases ***
#Test_uebox_10_times
#   FOR   ${i}   IN RANGE  1
#      log to console   the ${i} times
#      [1]single_ue_attach_and_check_tput
#   END
#*** Keywords ***
#[1]single_ue_attach_and_check_tput
#    @{UEs_info}=    pioneer.Detect UE and get UEs info
#    ${ue_index}    set variable    ${UEs_info[0]}[eqindex]
#    ${imei}        set variable    ${UEs_info[0]}[imei]
#    ${ue_alias}        set variable    ue_${ue_index}
#    @{ue_alias_list}  create list   ${ue_alias}
#    @{ue_ul_param_list}  create list   NR PUSCH BLER
#    @{ue_dl_param_list}  create list   NR PDSCH BLER
#    pioneer.Prepare UE    imei=${imei}    ue_alias=${ue_alias}
#    pioneer.UE Attach    ue_alias=${ue_alias}
#    sleep  5s
#    pioneer.Start UL Traffic    address=10.97.65.244     direction=${0}    ue_alias=${ue_alias}
#    sleep  15s
##    client.start_statistics    ues=${ue_alias_list}    service=pioneer
#    sleep   10s
##    client.get_param_statistics_result    paramname=${ue_param_list}    ue=${ue_alias}
##    client.get_param_summary_statistics_result   paramname=${ue_ul_param_list}    ue=${ue_alias}
#    sleep    5s
##    client.stop_statistics       ues=${ue_alias_list}    service=pioneer
#    pioneer.Check Throughput     direction=ul    ue_alias=${ue_alias}    expected_throughput=${30}
#    sleep  5s
#    pioneer.Stop UL Traffic   ue_alias=${ue_alias}
#    pioneer.Start DL Traffic    dl_time=60     dl_port=8018
#    ...                   dl_throughput=60M   dl_length=1024B
#    sleep  15s
##    client.get_param_summary_statistics_result   paramname=${ue_dl_param_list}    ue=${ue_alias}
#    pioneer.Check Throughput     direction=dl    ue_alias=${ue_alias}   expected_throughput=${60}
#    sleep  5s
#    pioneer.Stop DL Traffic
#    sleep  5s
#    pioneer.UE Detach    ue_alias=${ue_alias}
#    sleep  5s
#    client.teardown_service    service=pioneer
#
#pioneer.DL Traffic
#    [Arguments]     ${ue_addr}    ${dl_time}=60    ${dl_port}=8018    ${dl_throughput}=60M    ${dl_length}=1024B  ${connection}=APPserver
#    wait until keyword succeeds    1 min    10 sec    pioneer.Connect To Iperf Server    alias=${connection}
#    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=${connection}
#    csn.send command
#    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
#    ...    connection=APPserver
#    [Teardown]    csn.disconnect    connection=${connection}
#
#pioneer.Connect To Iperf Server
#    [Arguments]    ${hostname}=10.97.65.244    ${username}=ute   ${password}=ute    ${alias}=APPserver
#    [Documentation]    This kw is used to Connect to APPserver
#    ...    Author: Yang Mengli
#    ...    Contact: mengli.yang@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | alias | no | define the alias of connect |
#    ...
#    ...    | Return Value | Description |
#    ...    | None | NA |
#    ...
#    ...    Example
#    ...    | pioneer.Connect To Iperf Server | alias=APPserver |
#    ...
#    csn.Connect to
#    ...    hostname=${hostname}
#    ...    username=${username}
#    ...    password=${password}
#    ...    alias=${alias}
