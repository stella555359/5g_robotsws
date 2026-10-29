*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     String
Library     BuiltIn
Library     Process
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    SSH
Resource    internal_logs_operate.robot


*** Keywords ***
VDU Collect Tgz Logs
    [Arguments]      ${host}     ${usr}     ${pwd}    ${log_save_path}    
	  ...    ${script_path}=/var/home/core/kuafu-v5.23.0/scenarios/vdu_l3call/
    ...    ${script_name}=90-collect-vdu-logs.sh
    SSH.connect_to    hostname=${host}   username=${usr}    password=${pwd}     alias=core_vdu
    ${ret}     ${version}     should match regexp      ${script_path}     /(kuafu-v.*)/scenarios
    #SSH.execute    command=rm /var/home/core/${version}/logs/vdu/*.tgz   connection=core_vdu  
    ${ret}     SSH.execute    command=cd ${script_path};sh ${script_name}   connection=core_vdu  
    log    ${ret}
    
    ${ret}    ${path}     should match regexp       ${ret}       stored in (.*) directory
    ${ret}     SSH.execute    command=ls ${path} |grep tgz    connection=core_vdu
    ${files}     split string    ${ret}
    SSH.download_file    remote_path=${path}/${files[-1]}   local_path=${log_save_path}/${files[-1]}   connection=core_vdu
    [Return]     ${log_save_path}/${files[-1]}  

VDU Start Collect Bip Logs
    [Arguments]    ${container_name}=All    ${pod_filter}=All
    Run Keyword If    '${container_name}'=='All'    _VDU Start Collect All Bip Log    /tmp/
    ...    ELSE    _VDU Start Collect Single Bip Log    ${container_name}    /tmp/    ${pod_filter}

VDU Stop Collect And Download Bip Logs
    [Arguments]    ${log_save_path}=${TEST_LOG_DIRECTORY()}    ${container_name}=All    ${pod_filter}=All
    Run Keyword If    '${container_name}'=='All'    _VDU Stop And Download All Bip Log    ${log_save_path}
    ...    ELSE    _VDU Stop And Download Single Bip Log    ${container_name}    ${log_save_path}    ${pod_filter}

VDU Start TTiTrace Log
    [Arguments]    ${cell_id_list}=All    ${ip}=172.16.2.10    ${port}=1024    ${dscp}=15
    ...            ${target_component}=L2Ps    ${save_dir}=/tmp/ttitrace.pcap
    [Documentation]    This keyword is to start ttitrace log for vran2.0
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_id_list}  | YES | it's a list. @{cell_id_list} | 1 | 2 | |
    ...    | ${ip}            | NO | dcap server ip |
    ...    | ${gateway}       | NO | F1-U gate way |
    ...    | ${port}          | NO | trace port |
    ...    | ${dscp}          | NO | dscp configuration |
    ...    | ${save_dir}      | NO | log saved path and the file name |
    ...
    ...    Examples:
    ...    | ${cell_id_list} | Create List | 1 |
    ...    | ${trace_id}  |  Start TTiTrace Log | ${cell_id_list} | 
	...    | sleep     | 3 | 
	...    | Stop TTiTrace Log | ${trace_id} |  |
	...    | VDU Decode TTiTrace Log  |
    # _Add Route For VDU Capture Ttitrace    ${ip}
    _VDU Update Uplane Configuration    ${ip}    ${port}    ${dscp}
    ${trace_id}=    internal_logs_operate._VDU Start Uplane Trace    ${target_component}    ${cell_id_list}
    Run Keyword and Ignore Error    Run    sudo rm -rf /tmp/ttitrace*
    # ${result}=    Process.Start Process    sudo tcpdump -v -ni eth8 port ${port} -C 100 -W 10 -w ${save_dir}    shell=True
    ${result}=    Process.Start Process    sudo tcpdump -i eth9 -s 0 -C 100 -w ${save_dir}    shell=True
    Log To Console    -->Start to capture ttitrace log ...
    [Return]    ${trace_id}

VDU Stop TTiTrace Log
    [Arguments]    ${trace_id}    ${port}=55900
    Log To Console    -->Stop to capture ttitrace log ...
    ${output}    Run    ps -ef|grep ttitrace
    # ${output}    Run    sudo ps aux|grep 'sudo tcpdump -v -ni eth8 port ${port}'|grep -v grep|awk '{print $2}'|xargs sudo kill -2
    ${output}    Run    sudo ps aux|grep 'sudo tcpdump -i eth9'|grep -v grep|awk '{print $2}'|xargs sudo kill -2
    ${output}    Run    ps -ef|grep ttitrace
    internal_logs_operate._VDU Stop Uplane Trace    ${trace_id}

VDU Decode TTiTrace Log
    [Arguments]    ${ttitrace_log}=/tmp/ttitrace.pcap    ${csv_dir}=${TEST_LOG_DIRECTORY()}
    Log To Console    -->Start to decode ttitrace log ...
    _VDU Download TtiTrace Decode Tool
    Run and Return RC and Output    ls -al /tmp | grep tti
    # ${rc}    ${output}    Run and Return RC and Output   sudo cp ${ttitrace_log}0 ${ttitrace_log}
    # Should Be Equal As Integers    ${rc}    0    msg=${output}
    @{chars}    Split String To Characters    ${csv_dir}
    ${csv_dir}    ${splash}    Run Keyword If    "${chars}[-1]"=="/"    Split String From Right    ${csv_dir}    /    1
    ...                        ELSE    Set Variable    ${csv_dir}    /
    ${path}    Decoder Tttirace From Pcap To Csv    ${ttitrace_log}    ${csv_dir}
    [Return]    ${path}

Vran Syslog Capture
    [Documentation]     Capture vran's vdu or vcu syslog
    ...    | Input Parameters | Man. | Description |
    ...    | ${hostname} | Yes | ie. "10.11.1.1" |
    ...    | ${username} | Yes | ie. "core" |
    ...    | ${password} | Yes | ie. "system123" |
    ...    | ${alias}    | Yes | ie. "vcu"   |
    ...    | ${local_path} | No | default as ${TEST_LOG_DIRECTORY()}/${alias}_syslog.txt.zip |
    ...    | ${remote_path}  | No | Default is /var/home/core/${alias}_syslog.txt.zip |
    ...
    ...    Examples:
	...    | Get TL Config |
    ...    | vran syslog capture | ${hostname} | ${username} | ${password} | ${alias}
    ...    | vran syslog capture | ${hostname}  | ${username} | ${password} | ${alias}

     [Arguments]        ${hostname}        ${username}         ${password}     ${alias}    
     ...   ${local_path}=${TEST_LOG_DIRECTORY()}/${alias}_syslog.txt.zip    ${remote_path}=/var/home/core/${alias}_syslog.txt.zip
     SSH.connect to       ${hostname}        ${username}         ${password}        alias=${alias}
     ${name}     set variable    ${NAMESPACE_CU}
     ${pod}    SSH.execute        kubectl get pod -n ${name}      connection=${alias}
     ${match}    ${service}     should match regexp         ${pod}     (${name}-logservice-\\w+-\\w+)\\s+.*    
     ${pre}     set variable    kubectl exec -n ${name} -c ctr-${name}
	 ${address}    SSH.execute    ${pre}-lwsd -ti ute-${name}-lwsd-0 -- lwsd get-services | grep "url" | awk -F \\" '{print $4}' |grep /log_data
     ...          connection=${alias}
     ${ret}    SSH.execute    ${pre}-logprocessor ute-${service} -- curl -X GET "{${address[:-2]}}" -H "Accept-Encoding: gzip" > ${remote_path}
      ...          connection=${alias}
      SSH.Download File    ${remote_path}    ${local_path}    connection=${alias}
      SSH.disconnect    connection=${alias}
