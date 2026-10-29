*** Settings ***
Documentation   The execution in UDP Trace Server
Library   taf.transport.ssh   WITH NAME   csn
Library   OperatingSystem
Library   String
Library   Collections
Variables    ../../libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Variables    ../libraries/dcap_server_1.py

*** Variables ***
@{udptracer_start}    docker start udptracer
${dcap_alias}   dcap
${pcap_path}   /sharedvolume/flowtracer/traces/5G/
${docker_cmd}   docker exec -it flowtracer /bin/bash -c \'./fcmd ${dcap_ip}:55001
${session_param2}    pl=\[n:flowdiskwriter\]\[c:@ext/config/_diskwriter_TA.conf\]\[s:1\]
${provider_create}   ${docker_cmd} cp provider_${testline_name} ${asik_addr}:20401\'
${dcaps_ipv4}    10.57.167.44
${dcaps_ipv6}    \[2a00:8a00:8000:136:10:57:167:44\]

&{bts_classical}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}

*** Keywords ***
Start UDP Server Collecting
    [Arguments]   ${dcap_ip}    ${dcap_username}    ${dcap_password}   ${alias}=${dcap_alias}
    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}    alias=${alias}
    csn.Execute    command=docker stop udptracer    connection=${alias}
    Clean Traffic Files   file_folder=${file_location}
    Sleep   5s
    ${res}   csn.Execute    command=docker start udptracer    connection=${alias}
    Should Contain   ${res}   udptracer
    Log To Console   Start UDP Server Collecting

Check Trace File Recieved
    [Arguments]   ${file_list}   ${host}=${asik_addr}
    FOR   ${file}   IN   @{file_list}
         should contain    container=${file}   item=${host}   msg=No Trace File Found for ${host}
     END

Clean Traffic Files
    [Arguments]   ${source_ip}=${asik_addr}   ${alias}=${dcap_alias}     #${file_folder}
    ${search_regex}   Join Path   ${file_location}   ${source_ip}
    csn.Execute   command=sudo rm -f ${search_regex}*   connection=${alias}
    sleep   5s
    ${file_clear}   csn.Execute   command=ls ${search_regex}*   connection=${alias}
    ${cp1}   Run Keyword and Return Status   should be empty    ${file_clear}
    ${cp2}   Run Keyword and Return Status   should contain    ${file_clear}   No such file or directory
    Should Be True   ${cp1} or ${cp2}

Get Streaming Files Current gNB
    [Arguments]   ${source_ip}=${asik_addr}    #${alias}=${dcap_alias}      ${file_folder}
    ${files}    csn.Execute   command=cd ${file_location};ls ${source_ip}*   connection=${dcap_alias}
    run keyword if   ${files.count('No such file or directory')} <= 0
    ...    _handle_uplane_trace_files    files=${files}    alias=${dcap_alias}

_handle_uplane_trace_files
    [Arguments]    ${files}     #${alias}=${dcap_alias}
    ${file_list}   Set Variable   ${files.split()}
    FOR   ${file}   IN   @{file_list}
        ${size_value}    csn.Execute   command=cd ${file_location};du -sh ${file}  connection=${dcap_alias}
        ${size_value}    Fetch From Left    ${size_value}    \t
        run keyword if  '${size_value}'=='0'    run keywords    Remove Values From List    ${file_list}    ${file}
        ...    AND    exit for loop
    END
    FOR   ${file}   IN   @{file_list}
        ${local_pcap_path}   Join Path   ${OUTPUT_LOG_PATH}   ${file}
        ${dcap_file}   Join Path   ${file_location}   ${file}
        csn.Download File   remote_path=${dcap_file}   local_path=${local_pcap_path}   connection=${dcap_alias}
    END
#    ${earlist_file}    Get Earlist Pcap File in Directory    ${file_list}
    set suite variable    ${local_pcap_path}    ${OUTPUT_LOG_PATH}/*.pcap

Clean Pcap in Local
    ${files}    run   command=cd ${OUTPUT_DIR};ls ${asik_addr}*
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
    ${session_param1_zmq}    set variable
    ...    m=[f5c:@ext/config/5gfilter.txt][su:GIVAXI-0][gnb:gNB5G]
    ${session_param1_syscom}    set variable
    ...    m=[f5s:@ext/config/TraceFilter.txt][sh:CPUE20,CPRT00,CPNRT00,CPNB00,CPIF00,CPCL00][gnb:gNB5G]
    ${session_param1}    set variable     d=DataCollector\@${dcap_ip}:9999 ${session_param1_zmq} ${session_param1_syscom}
    [Return]    ${session_param1}




#Stop Flowtracer
#    ${provider_list}    Query Existing Flowtracer Provider
#    ${session_list}     Query Existing Flowtracer Session
#    Delete Flowtracer Resource    provider_list=${provider_list}    session_list=${session_list}
#
#Delete Flowtracer Resource
#    [Arguments]   ${provider_list}    ${session_list}
#    ...   ${dcap_ip}=${dcap_ip}    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
#    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
#    ...    alias=DCAP
#    csn.Execute    command=ls   connection=DCAP
#    run keyword if   ${session_list}   _Remove_Resource      ${session_list}    dm
#    run keyword if   ${provider_list}   _Remove_Resource      ${provider_list}    dp
#    [Teardown]   csn.Disconnect     connection=DCAP
#
#_Remove_Resource
#    [Arguments]    ${resource_list}    ${cmd}
#    :FOR    ${resource}   IN  @{resource_list}
#        ${output}    csn.Execute   command=${docker_cmd} ${cmd} ${resource}\'    connection=DCAP
#        Sleep   2s
#        should not contain    ${output}   failed
#        should not contain    ${output}   command not found
#    END
#
#Query Existing Flowtracer Provider
#    [Arguments]   ${dcap_ip}=${dcap_ip}    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
#    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
#    ...    alias=DCAP
#    ${provider_list}    csn.Execute   command=${docker_cmd} gp\'    connection=DCAP
#    ${provider_list}    Fetch from right    ${provider_list}    Provider controllers:
#    ${provider_list}    strip string    ${provider_list}
#    ${provider_list}    Split string    ${provider_list}    \r\n
#    ${provider_new_list}    create list
#    :FOR  ${provider}  IN   @{provider_list}
#        ${provider}    strip string    ${provider}
#        run keyword unless  "${provider}"== "${EMPTY}"    append to list    ${provider_new_list}    ${provider}
#    END
#    [Return]     ${provider_new_list}
#    [Teardown]   csn.Disconnect     connection=DCAP
#
#Query Existing Flowtracer Session
#    [Arguments]   ${dcap_ip}=${dcap_ip}    ${dcap_username}=${dcap_username}    ${dcap_password}=${dcap_password}
#    wait until keyword succeeds    3x    5s    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
#    ...    alias=DCAP
#    ${session_list}    csn.Execute   command=${docker_cmd} gm\'    connection=DCAP
#    ${session_list}    Fetch from right    ${session_list}    Monitoring sessions:
#    ${session_list}    strip string    ${session_list}
#    ${session_list}    Split string    ${session_list}    \r\n
#    ${session_new_list}    create list
#    :FOR  ${session}  IN   @{session_list}
#        ${session}    strip string    ${session}
#        run keyword unless  "${session}"== "${EMPTY}"   append to list    ${session_new_list}    ${session}
#    END
#    [Return]     ${session_new_list}
#    [Teardown]   csn.Disconnect     connection=DCAP


Configure Dcap Server to IPv6
    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    csn.Execute    command=sudo sed -i "s/${dcaps_ipv4}/${dcaps_ipv6}/g" /sharedvolume/udptracer/_l2tracer.conf
    ...    connection=DCAP
    csn.Execute   command=docker restart udptracer   connection=DCAP
    sleep   10s
    log to console   "Configure DCAP server to IPV6"
    [Teardown]   csn.Disconnect     connection=DCAP

Recover Dcap to IPv4
    csn.Connect to   hostname=${dcap_ip}    username=${dcap_username}    password=${dcap_password}
    ...    alias=DCAP
    csn.Execute
    ...   command=sudo sed -i 's/listenAddress="\\S*:1234"/listenAddress="${dcaps_ipv4}:1234"/g' /sharedvolume/udptracer/_l2tracer.conf
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/tor@\\S*:/tor@${dcaps_ipv4}:/g' /sharedvolume/flowtracer/config/_controller_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddr=\\S*:/IpAddr=${dcaps_ipv4}:/g' /sharedvolume/flowtracer/config/_controller_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddress=\\S*:/IpAddress=${dcaps_ipv4}:/g' /sharedvolume/flowtracer/config/_collector_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute
    ...   command=sudo sed -i 's/IpAddr=\\S*/IpAddr=${dcaps_ipv4}/g' /sharedvolume/flowtracer/config/_collector_config.txt
    ...    connection=DCAP
    sleep   5s
    csn.Execute   command=docker restart udptracer   connection=DCAP
    sleep   10s
    log to console   "Recover DCAP server to IPV4"
    [Teardown]   csn.Disconnect     connection=DCAP
