*** Settings ***
Documentation
...  author:   Jagoda Kubacka
...  contact:  jagoda.kubacka@nokia.com

Library  Collections
Library  String
Library  XML   True

Resource  ../../../../common_resources/admin/admin.robot
Resource  ../../../../common_resources/commissioning/commissioning.robot
Resource  ../../../../common_resources/netact/netact_operations.robot
Resource  ../../../../common_resources/emssim/emssim.robot
Resource  ../../../../common_resources/emssim/emssim_setup.robot
Resource  ../../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource  ../../../../common_resources/ip_traffic/ip_traffic.robot

Library   ./NESAS-C_resources.py
Library     taf.transport.ssh          WITH NAME   ssh

*** Variables ***
${EMSSIM_USERNAME}=                     cnumuser12
${EMSSIM_PASSWORD}=                     YT_xk39b
${BTS_ID}=                              ${tl.gnbs[0].global_bts_id}
${M_PLANE_IP}=                          ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${M_PLANE_IPV6}=                        ${tl.gnbs[0].cu.backhaul_site_oam_ip.v6}
${S_PLANE_IP}=                          ${tl.gnbs[0].cu.s1u.v4}
${S_PLANE_IPv6}=                        ${tl.gnbs[0].cu.s1u.v6}
${C_PLANE_IP}=                          ${tl.gnbs[0].cu.xnc.v4}
${LMP_IP}=                              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBEM_PASSWORD}=                      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${OAM_USERNAME}=                        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${OAM_PASSWORD}=                        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}


${SECADM_DN}=          MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SECADM-1

*** Keywords ***
Check mount options
    [Arguments]       @{lines}
    FOR  ${line}  IN  @{lines}
        ${bracket}=               Fetch From Right    ${line}    ${SPACE}
        ${contains_user_id}=      Run Keyword and Return Status    Should Contain    ${bracket}    user_id
        Should Not Contain Any    ${bracket}    user,    users,    user)    users)
        Run Keyword If            ${contains_user_id}    Should Contain    ${bracket}    user_id=0
    END

Check_usage_of_system_resources
    Log    Logging to BTS    console=true
    ${conn}=    ssh.Connect to    hostname=${LMP_IP}
    ...               username=toor4nsn
    ...               password=oZPS0POrRieRtu
    ...               alias=toor4nsn_connection
    Log    Getting the CPU and memory values    console=true
    ${cpu}=    ssh.execute     command=top -n 1 |grep Cpu     connection=${conn}
    ${memory}=    ssh.execute    command=top -n 1 |grep "MiB Mem"    connection=${conn}
    Log    Checking if the system has cpu bigger than ${cpu} and memory than ${memory}    console=true
    ${result}=    check_if_system_is_not_overloaded    cpu=${cpu}    memory=${memory}
    Should be True    ${result}

Get hash value of password for toor4nsn user
    [Arguments]     ${connection}
    ${cmd}=             Set Variable    cat /etc/shadow | grep toor4nsn
    ${output}=          ssh.execute     command=${cmd}  connection=${connection}
    ${reg_results}=     Get Regexp Matches     ${output}   toor4nsn:(.*)   1
    ${hash_value}=      Get From List    ${reg_results}    0
    Log   Hash value of password: ${hash_value}   console=yes
    [Return]            ${hash_value}

Get hash value of password for Nemuadmin
    [Arguments]         ${connection}
    ${cmd}=             Set Variable    cat /ffs/run/config/users.json | grep -A 6 Nemuadmin | grep "hashedPassword"
    ${output}=          ssh.execute     command=${cmd}  connection=${connection}
    ${reg_results}=     Get Regexp Matches     ${output}   "hashedPassword" : "(.*)"   1
    ${hash_value}=      Get From List    ${reg_results}    0
    Log                 Hash value of password: ${hash_value}   console=yes
    [Return]            ${hash_value}

Get hash value of password for local user
    [Arguments]         ${user}    ${connection}
    ${cmd}=             Set Variable    cat /ffs/run/config/users.json | grep -A 6 ${user} | grep "hashedPassword"
    ${output}=          ssh.execute     command=${cmd}  connection=${connection}
    ${output}=          Split String    ${output}    :
    ${hash_value}      Replace String     ${output}[1]    "    ${EMPTY}
#    ${reg_results}=     Get Regexp Matches     ${output}   "hashedPassword"\s*:\s*([^"]+)"   1
#    ${reg_results}=     Get Regexp Matches     ${output}   "hashedPassword" : "(.*)"   1
#    ${hash_value}=      Get From List    ${reg_results}    0
    Log   Hash value of password: ${hash_value}   console=yes
    [Return]            ${hash_value}

Get hash value of password for service user
    [Arguments]     ${connection}
    ${cmd}=             Set Variable    cat /etc/shadow | grep serviceuser
    ${output}=          ssh.execute     command=${cmd}  connection=${connection}
    ${reg_results}=     Get Regexp Matches     ${output}   serviceuser:(.*)   1
    ${hash_value}=      Get From List    ${reg_results}    0
    Log   Hash value of password: ${hash_value}   console=yes
    [Return]           ${hash_value}

Delete VLANIF
    [Arguments]   ${vlan_number}
    ${empty_list}=  Create List
    ${connection}=  Connect To Admin
    @{parameters}=  Create List
    Perform Object Recommissioning
    ...                     connection=${connection}
    ...                     dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${vlan_number}
    ...                     parameter=${parameters}
    ...                     operation=delete
    ...                     skip_parameter_relation_errors=${TRUE}
    ...                     should_activate=${TRUE}
    [Teardown]  Disconnect from ADMIN  ${connection}

Delete IPIF
    [Arguments]   ${ip_number}
    ${empty_list}=  Create List
    ${connection}=  Connect To Admin
    @{parameters}=  Create List
    Perform Object Recommissioning
    ...                     connection=${connection}
    ...                     dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ip_number}
    ...                     parameter=${parameters}
    ...                     operation=delete
    ...                     skip_parameter_relation_errors=${TRUE}
    ...                     should_activate=${TRUE}
    [Teardown]  Disconnect from ADMIN  ${connection}

Add VLANIF
    [Arguments]   ${vlan}   ${vlan_index}
    ${connection}=  Connect To Admin
    &{dict1}=       Create Dictionary
    ...             parameterName=vlanId
    ...             value=${vlan}
    ...             operation=update
    @{list_parameter}=  Create List  ${dict1}
    Perform Object Recommissioning
    ...                     dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${vlan_index}
    ...                     parameter=${list_parameter}
    ...                     operation=create
    ...                     connection=${connection}
    ...                     skip_parameter_relation_errors=${TRUE}
    ...                     should_activate=${TRUE}
    [Teardown]    Disconnect from ADMIN    ${connection}


Add IPIF With userLabel and VLANIF
    [Arguments]   ${ipif_id}   ${vlan_id}   ${value}
    ${connection}=  Connect To Admin
    &{dict1}=       Create Dictionary
    ...             parameterName=interfaceDN
    ...             value=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${vlan_id}
    ...             operation=update
    &{dict2}=       Create Dictionary
    ...             parameterName=ipMtu
    ...             value=1496
    ...             operation=update
    &{dict3}=       Create Dictionary
    ...             parameterName=userLabel
    ...             value=${value}
    ...             operation=update
    @{list_parameter}=  Create List  ${dict1}  ${dict2}  ${dict3}
    Perform Object Recommissioning
    ...                     dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}
    ...                     parameter=${list_parameter}
    ...                     operation=create
    ...                     connection=${connection}
    ...                     skip_parameter_relation_errors=${TRUE}
    ...                     should_activate=${TRUE}
    [Teardown]  Disconnect from ADMIN    ${connection}

Add IPADDRESS
    [Arguments]   ${ip}   ${value}   ${version}   ${ipif_number}
    ${connection}=  Connect To Admin
    &{dict1}=       Create Dictionary
    ...             parameterName=ipAddressAllocationMethod
    ...             value=MANUAL
    ...             operation=update
    &{dict2}=       Create Dictionary
    ...             parameterName=localIpAddr
    ...             value=${ip}
    ...             operation=update
    &{dict3}=       Create Dictionary
    ...             parameterName=localIpPrefixLength
    ...             value=${value}
    ...             operation=update
    @{list_parameter}=  Create List  ${dict1}  ${dict2}  ${dict3}
    Perform Object Recommissioning
    ...                     dist_name=MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_number}/${version}
    ...                     parameter=${list_parameter}
    ...                     operation=create
    ...                     connection=${connection}
    ...                     skip_parameter_relation_errors=${TRUE}
    ...                     should_activate=${TRUE}
    [Teardown]    Disconnect from ADMIN    ${connection}

Run Tcpdump On BTS And Check Response
    [Arguments]   ${vlan_id}   ${ip}
    Log    Collecting the PCAP    console=true
    Log  Ping ${ip} and check on vlan ${vlan_id}  console=True
    Start Tcpdump
    Sleep   5
    Run     ping -c 10 ${ip}
    Sleep   5
    Log    Collecting the PCAP    console=true
    ${tcpdump_path}=    Stop Tcpdump And Download Pcap    tcpdump_filename=response.pcap
    Verify Pcap File From BTS   ${tcpdump_path}    ${ip}   ${vlan_id}


Verify pcap file from BTS
    [Arguments]   ${local_pcap_path}   ${ip}   ${vlan_id}
    Log    Checking the state of IP Vlan    console=true
    ${state}=   Check IP Vlan   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                         toor4nsn
    ...                         ${OAM_PASSWORD}
    ...                         ${ip}
    ...                         ${vlan_id}
    Log    Runnging the tshark filer to check PCAP file    console=true
    ${output}=   Run   tshark -r ${local_pcap_path} icmp.type == 8 and ip.dst==${ip}
    Log  ${output}  console=True
    ${end}=       Run Keyword and Return Status    Should Contain    ${output}    cut short in the middle of a packet
    ${output}=    Run Keyword If    ${end}    Fetch From Left    ${output}    \ntshark: The file
    ...           ELSE    Set Variable    ${output}
    Run Keyword If   '${state}' == 'True'   Should Not Be Empty     ${output}
    ...              ELSE                   Should Be Empty         ${output}

Get CPU Usage per Time
    [Arguments]  ${time}=1800
    ssh.connect to    ${LMP_IP}    ${OAM_USERNAME}    ${OAM_PASSWORD}    alias=cpu_usage
    ${command}=  Catenate  timeout ${time}s top -b | grep 'Cpu(s)'
    ${output}=  ssh.execute  ${command}  connection=cpu_usage
    ssh.disconnect  connection=cpu_usage
    @{output_splitted_lines}=  Split To Lines  ${output}
    ${average_cpu_usage}=  Set Variable  0
    FOR  ${line}  IN  @{output_splitted_lines}
        @{splitted_line}=  Split String  ${line}  separator=,
        ${cpu_usage_value_plus}=    Get From List    ${splitted_line}    3
        ${cpu_usage_value}=    Split String    ${cpu_usage_value_plus}    ${SPACE}
        ${average_cpu_usage}=  Evaluate  ${average_cpu_usage} + ${cpu_usage_value}[1]
    END
    ${number_of_top_hops}=  Get length  ${output_splitted_lines}
    ${average_cpu_usage}=  Evaluate  ${average_cpu_usage} / ${number_of_top_hops}
    [Return]  ${average_cpu_usage}

Disconnect for WebEM limit test
    [Arguments]    ${limit_session}    ${alias}
    FOR    ${nr}    IN RANGE    1    ${limit_session}
        Disconnect from ADMIN    ${alias}${nr}
    END
