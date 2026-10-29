*** Settings ***
Documentation   The execution in UDP Trace Server
Library   taf.transport.ssh   WITH NAME   csn
Library   OperatingSystem
Library   String
Library   Collections
Variables    ../../libraries/global_vars.py
Variables    ../libraries/dcap_server_1.py
Resource     ../resources/emil/emil.robot

*** Variables ***
@{udptracer_start}    docker start udptracer
${dcap_alias}   dcap
${pcap_path}   /sharedvolume/flowtracer/traces/5G/
${docker_cmd}   docker exec -it flowtracer /bin/bash -c \'./fcmd
${session_param2}    pl=\[n:flowdiskwriter\]\[c:@ext/config/_diskwriter_TA.conf\]\[s:1\]
${session_param3}    docker exec -it flowtracer /bin/bash -c \'./fcmd
${session_param4}    m=[f5s:@ext/config/TraceFilter.txt][sh:CPUE20,CPRT00,CPNRT00,CPNB00,CPIF00,CPCL00][gnb:gNB5G]
#${provider_create}   ${docker_cmd} cp provider ${asik_addr}:20401\'
${dcaps_ipv4}    10.57.167.35
${dcaps_ipv6}    [2a00:8a00:8000:136:10:57:167:35]:1234
${dcap_1652}    192.168.101.35
${dcap_1655}    192.168.100.35
${flow_path1}    /sharedvolume/flowtracer/config/_controller_config.txt
${flow_path2}    /sharedvolume/flowtracer/config/_collector_config.txt
${dcap_ip_external}    10.57.167.35
${dcap_VLAN1655_ip}    192.168.100.35
${dcap_VLAN1652_ip}    192.168.101.35

*** Keywords ***
Start UDP Server Collecting
    [Arguments]   ${dcap_ip}    ${dcap_username}    ${dcap_password}   ${alias}=${dcap_alias}    ${host}=${asik_addr}
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}    alias=${alias}
    csn.Execute    command=docker stop udptracer    connection=${alias}
    Clean Traffic Files   file_folder=${file_location}    source_ip=${host}
    Sleep   5s
    ${res}   csn.Execute    command=docker start udptracer    connection=${alias}
    Should Contain   ${res}   udptracer
    Log To Console   Start UDP Server Collecting

Check Trace File Recieved
    [Arguments]   ${file_list}   ${host}=${asik_addr}
    FOR   ${file}   IN   @{file_list}
          should contain    container=${file}   item=${host}   msg=No Trace File Found for ${host}
     END
#    ${file_name}    strip string    ${file_name}
#    @{files}    split string    ${file_name}    \r\n
#    :FOR   ${file}   IN   @{files}
#        ${status}    run keyword and return status    Should Not Be Empty    container=${file_folder}/${file}   item=${host}
#        run keyword if  ${status}    exit for loop
#    END
#    run keyword if  '${status}' =='${False}'    FAIL    [ERROR]the captured sherpa log is empty!

Clean Traffic Files
    [Arguments]   ${file_folder}   ${source_ip}=${asik_addr}   ${alias}=${dcap_alias}
    ${search_regex}   Join Path   ${file_location}   ${source_ip}
    csn.Execute   command=sudo rm -f ${search_regex}*   connection=${alias}
    sleep   5s
    ${file_clear}   csn.Execute   command=ls ${search_regex}*   connection=${alias}
    ${cp1}   Run Keyword and Return Status   should be empty    ${file_clear}
    ${cp2}   Run Keyword and Return Status   should contain    ${file_clear}   No such file or directory
    Should Be True   ${cp1} or ${cp2}

Get Streaming Files Current gNB
    [Arguments]   ${file_folder}   ${source_ip}=${asik_addr}   ${alias}=${dcap_alias}
    ${files}    csn.Execute   command=cd ${file_location};ls ${source_ip}*   connection=${dcap_alias}
    ${file_list}   Set Variable   ${files.split()}
    FOR   ${file}   IN   @{file_list}
        ${size_value}    csn.Execute   command=cd ${file_location};du -sh ${file}  connection=${dcap_alias}
        ${size_value}    Fetch From Left    ${size_value}    \t
        run keyword if  '${size_value}'=='0'    run keywords    Remove Values From List    ${file_list}    ${file}
        ...    AND    exit for loop
    END
    FOR   ${file}   IN   @{file_list}
        ${local_pcap_path}   Join Path   ${OUTPUT_DIR}   ${file}
        ${dcap_file}   Join Path   ${file_location}   ${file}
        csn.Download File   remote_path=${dcap_file}   local_path=${local_pcap_path}   connection=${dcap_alias}
    END
    ${earlist_file}    Get Earlist Pcap File in Directory    ${file_list}
    set suite variable    ${local_pcap_path}    ${OUTPUT_DIR}/${earlist_file}
     [Teardown]   csn.Disconnect     connection=${dcap_alias}

Clean Pcap in Local
    ${files}    run   command=cd ${OUTPUT_DIR};ls ${source_ip}*
    ${file_list}   Set Variable   ${files.split()}
    FOR   ${file}   IN   @{file_list}
        run keyword if    ${file.count("${earlist_file}")} == 0    run    cd ${OUTPUT_DIR};rm -rf ${file}
    END

Get Earlist Pcap File in Directory
    [Arguments]    ${file_list}
    &{D}    Create Dictionary
    FOR   ${file}   IN   @{file_list}
        ${datevalue}    Fetch From Left    ${file}    .pcap
        ${datevalue}    Fetch From Right    ${datevalue}    T
        Set To Dictionary    ${D}    ${datevalue}    ${file}
    END
    ${datevalue_list}   Get Dictionary Keys    ${D}
    ${earlist_date}   Set Variable   ${datevalue_list[0]}
    FOR   ${datevalue}   IN   @{datevalue_list}
       ${earlist_date}   Run Keyword If  ${${datevalue}}<${${earlist_date}}   Set Variable   ${datevalue}
       ...   ELSE   Set Variable   ${earlist_date}
    END
    ${earlist_file}    Get From Dictionary    ${D}    ${earlist_date}
    [Return]     ${earlist_file}

Set Session Cmd Regarding Flag
    [Arguments]    ${session_flag}    ${dcapserv_ip}=${dcap_ip}
    ${session_param1}    run keyword if  '${session_flag}'=='zmq'    set variable
    ...    d=DataCollector\@${dcapserv_ip}:9999 m=[f5c:@ext/config/5gfilter.txt][su:GIVAXI-0][gnb:gNB5G]
    ...    ELSE IF  '${session_flag}'=='syscom'    set variable
    ...    d=DataCollector\@${dcapserv_ip}:9999 ${session_param4}
    set variable     ${session_param1}
    [Return]    ${session_param1}

Start Flowtracer
    [Arguments]   ${session_flag}=zmq    ${gnb_ip}=${asik_addr}    ${dcapserver_ip}=${dcaps_ipv4}
#    Stop Flowtracer
    ${session_param1}    Set Session Cmd Regarding Flag    session_flag=${session_flag}    dcapserv_ip=${dcapserver_ip}
     ${session_create}   set variable
    ...  ${session_param3} ${dcapserver_ip}:55001 cm n=session_${testline_name} p=provider_${testline_name} ${session_param1} ${session_param2}'
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}
    ...    password=${dcap_password}    alias=DCAP
    csn.Execute    command=docker start flowtracer   connection=DCAP
    ${res}=   csn.Execute    command=${docker_cmd} ${dcapserver_ip}:55001 cp provider_${testline_name} ${gnb_ip}:20401\'    connection=DCAP
    should contain    ${res}       success     msg=failure
    ${res}=   csn.Execute   command=${session_create}    connection=DCAP
    should contain    ${res}       success    msg=failure
    Log to console   Flow tracer start
    [Teardown]   run keywords     run keyword if   ${KEYWORD MESSAGE.count('failure')} > 0     Stop Flowtracer
    ...    dcapserver_ip=${dcapserver_ip}    dcap_alias=DCAP_STOP
    ...   AND    run keyword and ignore error    csn.Disconnect     connection=DCAP

Stop Flowtracer
    [Arguments]   ${dcapserver_ip}=${dcaps_ipv4}    ${dcap_alias}=DCAP
#    ${provider_list}    Query Existing Flowtracer Provider    ${dcap_alias}    dcapserver_ip=${dcapserver_ip}
#    ${session_list}     Query Existing Flowtracer Session    ${dcap_alias}    dcapserver_ip=${dcapserver_ip}
#    Delete Flowtracer Resource    provider_list=${provider_list}    session_list=${session_list}    dcap_alias=${dcap_alias}
#    ...   dcap_ip=${dcapserver_ip}
    Delete Flowtracer Resource single   dcap_alias=${dcap_alias}    dcap_ip=${dcapserver_ip}
    Log to console   Flow tracer stop

Delete Flowtracer Resource
    [Arguments]    ${provider_list}    ${session_list}   ${dcap_alias}=DCAP
    ...   ${dcap_ip}=${dcaps_ipv4}    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=${dcap_alias}
    csn.Execute    command=ls   connection=${dcap_alias}
    Run keyword and Ignore Error    run keyword if   ${session_list}   _Remove_Resource      ${session_list}    dm
    ...    ${dcap_ip}     ${dcap_alias}
    Run keyword and Ignore Error    run keyword if   ${provider_list}   _Remove_Resource      ${provider_list}    dp
    ...    ${dcap_ip}    ${dcap_alias}
    [Teardown]   csn.Disconnect     connection=${dcap_alias}

Delete Flowtracer Resource single
    [Arguments]    ${dcap_alias}=DCAP   ${dcap_ip}=${dcaps_ipv4}
    ...    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=${dcap_alias}
     run keyword and ignore error    _Remove_Resource_single   session_${testline_name}   dm   ${dcap_ip}     ${dcap_alias}
     run keyword and ignore error    _Remove_Resource_single   provider_${testline_name}   dp   ${dcap_ip}     ${dcap_alias}
    [Teardown]   csn.Disconnect     connection=${dcap_alias}

_Remove_Resource
    [Arguments]    ${resource_list}    ${cmd}    ${dcapserver_ip}=${dcaps_ipv4}    ${dcap_alias}=DCAP
    FOR    ${resource}   IN  @{resource_list}
        ${output}    csn.Execute   command=${docker_cmd} ${dcapserver_ip}:55001 ${cmd} ${resource}\'    connection=${dcap_alias}
        Sleep   2s
        should not contain    ${output}   failed
        should not contain    ${output}   command not found
    END

_Remove_Resource_single
    [Arguments]    ${resource}    ${cmd}    ${dcapserver_ip}=${dcaps_ipv4}    ${dcap_alias}=DCAP
    ${output}    csn.Execute   command=${docker_cmd} ${dcapserver_ip}:55001 ${cmd} ${resource}\'    connection=${dcap_alias}
    Sleep   2s
    should not contain    ${output}   failed
    should not contain    ${output}   command not found

Query Existing Flowtracer Provider
    [Arguments]   ${dcap_alias}=DCAP    ${dcapserver_ip}=${dcaps_ipv4}    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=${dcap_alias}
    ${provider_list_ori}    csn.Execute   command=${docker_cmd} ${dcapserver_ip}:55001 gp\'    connection=${dcap_alias}
    ${provider_list}    Fetch from right    ${provider_list_ori}    Provider controllers:
#    ${provider_list_ori}    strip string    ${provider_list_ori}
    ${provider_list_ori}    remove string    ${provider_list_ori}    '    \r\n
#    ${provider_list}    strip string     ${provider_list}
    ${provider_list_compare}    remove string    ${provider_list}    '    \r\n
    ${provider_new_list}    run keyword if  not '${provider_list_ori}'=='${provider_list_compare}'
    ...   dcap list operation    ${provider_list}
    [Return]     ${provider_new_list}
    [Teardown]   csn.Disconnect     connection=${dcap_alias}

Query Existing Flowtracer Session
    [Arguments]   ${dcap_alias}=DCAP    ${dcapserver_ip}=${dcaps_ipv4}    ${dcap_username}=${dcap_username}
     ...   ${dcap_password}=${dcap_password}    ${dcap_alias}=DCAP
    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=${dcap_alias}
    ${session_list_ori}    csn.Execute   command=${docker_cmd} ${dcapserver_ip}:55001 gm\'    connection=${dcap_alias}
    ${session_list}    Fetch from right    ${session_list_ori}    Monitoring sessions:
#    ${session_list_ori}    strip string    ${session_list_ori}
    ${session_list_ori}    remove string    ${session_list_ori}    '    \r\n
#    ${session_list}    strip string     ${session_list}
    ${session_list_compare}    remove string    ${session_list}    '    \r\n
    ${session_new_list}
     ...    run keyword if  not '${session_list_ori}'=='${session_list_compare}'    dcap list operation    ${session_list}
    [Return]     ${session_new_list}
    [Teardown]   csn.Disconnect     connection=${dcap_alias}

dcap list operation
    [Arguments]     ${element_list}
    ${element_list}    strip string    ${element_list}
    ${element_list}    Split string    ${element_list}    \r\n
    ${element_new_list}    create list
    FOR  ${element}  IN   @{element_list}
        ${element}    strip string    ${element}
        append to list    ${element_new_list}    ${element}
    END
    [Return]     ${element_new_list}

Configure Dcap Server to IPv6
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    csn.Execute    command=sudo sed -i "s/${dcaps_ipv4}/${dcaps_ipv6}/g" /sharedvolume/udptracer/config/_config.txt
    ...    connection=DCAP
    csn.Execute   command=docker restart udptracer   connection=DCAP
    sleep   10s
    log to console   "Configure DCAP server to IPV6"
    [Teardown]   csn.Disconnect     connection=DCAP

Recover Dcap to IPv4
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    csn.Execute    command=sudo sed -i "s/\[2a00:8a00:8000:136:10:57:167:35\]:1234/10.57.167.35:1234/g"
    ...    /sharedvolume/udptracer/config/_config.txt    connection=DCAP
    csn.Execute   command=docker restart udptracer   connection=DCAP
    sleep   10s
    log to console   "Recover DCAP server to IPV4"
    [Teardown]   csn.Disconnect     connection=DCAP

Configure Dcap Server to Internal IP
    [Arguments]    ${VLAN}=1652
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
#    Run Keyword If   '${VLAN}'=='1652'   csn.Execute
#    ...   command=sudo sed -i "s/${dcaps_ipv4}/${dcap_1652}/g" /sharedvolume/udptracer/_l2tracer.conf    connection=DCAP
#    ...   ELSE IF   '${VLAN}'=='1655'   csn.Execute
#    ...   command=sudo sed -i "s/${dcaps_ipv4}/${dcap_1655}/g" /sharedvolume/udptracer/_l2tracer.conf    connection=DCAP
#    ...   ELSE   FAIL
    csn.Execute
    ...   command=sudo sed -i 's/listenAddress="\\S*:1234"/listenAddress="${dcap_1655}:1234"/g' /sharedvolume/udptracer/_l2tracer.conf
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/tor@\\S*:/tor@${dcap_1655}:/g' /sharedvolume/flowtracer/config/_controller_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddr=\\S*:/IpAddr=${dcap_1655}:/g' /sharedvolume/flowtracer/config/_controller_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddress=\\S*:/IpAddress=${dcap_1655}:/g' /sharedvolume/flowtracer/config/_collector_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddr=\\S*/IpAddr=${dcap_1655}/g' /sharedvolume/flowtracer/config/_collector_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute   command=docker restart udptracer   connection=DCAP
    log to console   "Configure DCAP server to VLAN ${VLAN} Internal IP"
    [Teardown]   csn.Disconnect     connection=DCAP


Configure Flowtracer to Internal IP
    [Arguments]    ${VLAN}=1652
    csn.Connect to   hostname=${dcaps_ipv4}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    Run Keyword If   '${VLAN}'=='1652'   csn.Execute
    ...   command=sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN1652_ip}/g" ${flow_path1};sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN1652_ip}/g" ${flow_path2}
    ...   connection=DCAP
    ...   ELSE IF   '${VLAN}'=='1655'   csn.Execute
    ...   command=sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN1655_ip}/g" ${flow_path1};sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN1655_ip}/g" ${flow_path2}
    ...   connection=DCAP
    ...   ELSE IF   '${VLAN}'=='2806'   csn.Execute
    ...   command=sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN2806_ip}/g" ${flow_path1};sudo sed -i "s/${dcaps_ipv4}/${dcap_VLAN2806_ip}/g" ${flow_path2}
    ...   connection=DCAP
    ...   ELSE   FAIL
    csn.Execute   command=docker restart flowtracer   connection=DCAP
    sleep   10s
    ${flow_path1_value}   csn.Execute   command=sudo cat ${flow_path1}    connection=DCAP
    ${flow_path2_value}   csn.Execute   command=sudo cat ${flow_path2}    connection=DCAP
    should contain   ${flow_path1_value}    192.168
    should contain   ${flow_path2_value}    192.168
    log to console   "Configure flowtracer to ${dcap_VLAN${VLAN}_ip}"
    [Teardown]   csn.Disconnect     connection=DCAP
