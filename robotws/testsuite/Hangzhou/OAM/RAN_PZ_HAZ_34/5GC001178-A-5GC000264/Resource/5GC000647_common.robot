*** Settings ***
Documentation
...   author: annie.hu
...   contact: annie.hu@nokia-sbell.com

Library           taf.transport.ssh    WITH NAME    csn
Library           taf.analyzer.pcap     WITH NAME    cap
Resource          ../../common/coam_resource.robot

*** Variables ***
${test_Vlan_id}       2
${scf_file}        /home/nokia/scf/scf_backup.xml
${ASIK_log_path}     /user/toor4nsn/log/5GC000647/
${VM_log_path}     /home/nokia/log/

*** Keywords ***
Check Tcpdump IPv4 Log
    [Arguments]    ${vlan}    ${ip}    ${cap_file}    ${sctp}=${TRUE}
    cap.Read Cap    cap_file=${cap_file}
    run keyword if    ${sctp}==${TRUE}    Check IPv4 With Sctp    vlan=${vlan}    ip=${ip}
    run keyword if    ${sctp}==${False}    Check IPv4 Without Sctp    vlan=${vlan}    ip=${ip}

Check IPv4 Without Sctp
    [Arguments]    ${vlan}    ${ip}    
    ${output_0} =    cap.Get Element Value     element_expression=vlan.id
    ...    condition_expression=vlan.id==${vlan} and ip.dst==${ip} and vlan.dei==0 and vlan.priority == 0
    #eth.type==0x8100  
    ${result_0}    convert to hex    ${vlan}   
    should be equal      ${result_0}    ${output_0[0]}
    
Check IPv4 With Sctp
    [Arguments]    ${vlan}    ${ip}    
    ${output_1} =    cap.Get Element Value     element_expression=vlan.id
    ...    condition_expression=vlan.id == ${vlan} and ip.dst == ${ip} and sctp.dstport==38412 and vlan.dei==0 and vlan.priority == 0
    ${result_1}    convert to hex    ${vlan}
    should be equal      ${result_1}    ${output_1[0]}

Check Tcpdump IPv6 Log
    [Arguments]    ${vlan}    ${ip}    ${cap_file}    ${sctp}=${TRUE}
    cap.Read Cap    cap_file=${cap_file}
    run keyword if    ${sctp}==${TRUE}    Check IPv6 With Sctp    vlan=${vlan}    ip=${ip}
    run keyword if    ${sctp}==${False}    Check IPv6 Without Sctp    vlan=${vlan}    ip=${ip}

Check IPv6 Without Sctp
    [Arguments]    ${vlan}    ${ip}    
    ${output_0} =    cap.Get Element Value     element_expression=vlan.id
    ...    condition_expression=vlan.id==${vlan} and ipv6.dst==${ip} and vlan.dei==0 and vlan.priority == 0
    #eth.type==0x8100  
    ${result_0}    convert to hex    ${vlan}   
    should be equal      ${result_0}    ${output_0[0]}
    
Check IPv6 With Sctp
    [Arguments]    ${vlan}    ${ip}    
    ${output_1} =    cap.Get Element Value     element_expression=vlan.id
    ...    condition_expression=vlan.id == ${vlan} and ipv6.dst == ${ip} and sctp.dstport==38412 and vlan.dei==0 and vlan.priority == 0
    ${result_1}    convert to hex    ${vlan}
    should be equal      ${result_1}    ${output_1[0]}

Get Bts Id Info
    Wait Until Keyword Succeeds    10min    60s    Check ASIK Status
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    sleep    3s
    ${bts_id}    selenium_coam.get_bts_id
    set suite variable     ${bts_id}
    log to console    bts id: ${bts_id}
    run keyword and ignore error    selenium_coam.logout

Configure 16 VLANs
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=1
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=2
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=3
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=4
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=5
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=6
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=7
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=8
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=9
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=10
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=11
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=12
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=13
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=14
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=15
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=16
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    filter_param=VLAN ID    new_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2    filter_param=VLAN ID    new_value=2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-3    filter_param=VLAN ID    new_value=3
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-4    filter_param=VLAN ID    new_value=4
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-5    filter_param=VLAN ID    new_value=5
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-6    filter_param=VLAN ID    new_value=6
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-7    filter_param=VLAN ID    new_value=7
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-8    filter_param=VLAN ID    new_value=8
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-9    filter_param=VLAN ID    new_value=9
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-10   filter_param=VLAN ID    new_value=10
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-11   filter_param=VLAN ID    new_value=11
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-12   filter_param=VLAN ID    new_value=12
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-13   filter_param=VLAN ID    new_value=13
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-14   filter_param=VLAN ID    new_value=14
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-15   filter_param=VLAN ID    new_value=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-16   filter_param=VLAN ID    new_value=4094
    sleep    1s

Verify 16 VLANs
    csn.connect to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=ifconfig    connection=gNB
    sleep    3s
    ${output_log}    csn.read output    connection=gNB
    should match regexp    ${output_log}    fp0.1
    should match regexp    ${output_log}    fp0.2
    should match regexp    ${output_log}    fp0.3
    should match regexp    ${output_log}    fp0.4
    should match regexp    ${output_log}    fp0.5
    should match regexp    ${output_log}    fp0.6
    should match regexp    ${output_log}    fp0.7
    should match regexp    ${output_log}    fp0.8
    should match regexp    ${output_log}    fp0.9
    should match regexp    ${output_log}    fp0.10
    should match regexp    ${output_log}    fp0.11
    should match regexp    ${output_log}    fp0.12
    should match regexp    ${output_log}    fp0.13
    should match regexp    ${output_log}    fp0.14
    should match regexp    ${output_log}    fp0.15
    should match regexp    ${output_log}    fp0.4094
    csn.disconnect    connection=gNB

Verify Illegal Value
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-16
    ...    filter_param=VLAN ID    new_value=4095
    sleep    1s
    selenium_coam.get_error_info_after_set_parameter
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-16
    ...    filter_param=VLAN ID    new_value=4094
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...    filter_param=VLAN ID    new_value=0
    sleep    1s
    selenium_coam.get_error_info_after_set_parameter
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...    filter_param=VLAN ID    new_value=1
    sleep    1s

Verify 17th VLAN Can Not Be Configured
    ${output}    RUN KEYWORD AND IGNORE ERROR  selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF
    should be equal      ${output[0]}    FAIL

Delete 16 VLANs
    selenium_coam.remove_object    object_name=VLANIF-1
    selenium_coam.remove_object    object_name=VLANIF-2
    selenium_coam.remove_object    object_name=VLANIF-3
    selenium_coam.remove_object    object_name=VLANIF-4
    selenium_coam.remove_object    object_name=VLANIF-5
    selenium_coam.remove_object    object_name=VLANIF-6
    selenium_coam.remove_object    object_name=VLANIF-7
    selenium_coam.remove_object    object_name=VLANIF-8
    selenium_coam.remove_object    object_name=VLANIF-9
    selenium_coam.remove_object    object_name=VLANIF-10
    selenium_coam.remove_object    object_name=VLANIF-11
    selenium_coam.remove_object    object_name=VLANIF-12
    selenium_coam.remove_object    object_name=VLANIF-13
    selenium_coam.remove_object    object_name=VLANIF-14
    selenium_coam.remove_object    object_name=VLANIF-15
    selenium_coam.remove_object    object_name=VLANIF-16
    sleep    1s

Validate And Activate
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s
    #selenium_coam.check_activate_plan_status
    #sleep    3s

Import Scf File
    log to console    Import Scf File
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    sleep    5s
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_file}
    sleep    3s
    run keyword and ignore error    selenium_coam.validate_plan
    sleep    3s
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    3s
    #selenium_coam.check_activate_plan_status
    #sleep    3s
    run keyword and ignore error    selenium_coam.logout
    sleep    3min
    wait until keyword succeeds    10min    1min    ping
    log to console    ping successfully
    Wait Until Keyword Succeeds    10min    60s    Check ASIK Status
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...    password=${host_password}    alias=VM
    sleep    2s
    csn.execute    command=killall -9 /opt/firefox/firefox    connection=VM
    sleep    2s
    csn.disconnect    connection=VM

Check ASIK Status
    run keyword and ignore error    selenium_coam.logout
    sleep    3s
    selenium_coam.login    url=${WEBUI_URL}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    sleep    3s
    Check ABIL is UP
    Check ASIK is UP
    run keyword and ignore error    selenium_coam.logout
    sleep    3s

Ping
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...   password=${host_password}    alias=VM
    sleep    2s
    csn.send_command    command=ping ${asik_addr} -c 5 -i 2    connection=VM
    sleep    3s
    ${output_log_0}    csn.read output    connection=VM
    should match regexp    ${output_log_0}    ttl=
    csn.disconnect    connection=VM

Config A Inconsistent Vlan And A Correct IP
    [Arguments]    ${real_IP}
    log to console    Config A Inconsistent Vlan And A Correct IP
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2
    ...    filter_param=VLAN ID    new_value=${test_Vlan_id}
    selenium_coam.add_object    object_name=IPNO-1    object_class_name=IPIF    id_value=2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2
    ...    filter_param=Layer 2 interface reference
    ...    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2
    selenium_coam.add_object    object_name=IPIF-2    object_class_name=IPADDRESSV4    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ...    filter_param=IP address allocation method    new_value=MANUAL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ...    filter_param=Local IPv4 address    new_value=${real_IP}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
    ...    filter_param=Local IPv4 prefix length    new_value=29
    sleep    2s

Verify Inconsistent Vlan Configure
    [Arguments]    ${real_IP}
    log to console    Verify Inconsistent vlan configure:gNB ping ok and VM ping not ok
    csn.connect to    hostname=${asik_addr}    username=${asik_username}
    ...    password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=ifconfig    connection=gNB
    sleep    3s
    ${output_log}    csn.read output    connection=gNB
    should match regexp    ${output_log}    fp0.${test_Vlan_id}
    should match regexp    ${output_log}    ${real_IP}
    sleep    1s
    csn.send_command    command=ping ${real_IP} -c 5 -i 2    connection=gNB
    sleep    3s
    ${output_log_0}    csn.read output    connection=gNB
    should match regexp    ${output_log_0}    ttl=
    csn.disconnect    connection=gNB
    sleep    1s
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...     password=${host_password}    alias=VM
    sleep    5s
    csn.send_command    command=ping ${real_IP} -c 5 -i 2    connection=VM
    sleep    3s
    ${output_log_1}    csn.read output    connection=VM
    should not contain    ${output_log_1}    ttl=
    csn.disconnect    connection=VM

Config A Consistent Vlan And A Correct IP
    [Arguments]    ${real_Vlan_id}
    log to console    Config A Consistent Vlan And A Correct IP
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2
    ...    filter_param=VLAN ID    new_value=${real_Vlan_id}
    sleep    1s

Verify Consistent Vlan Configure
    [Arguments]    ${real_Vlan_id}    ${real_IP}
    log to console    Verify consistent vlan configure:gNB ping ok and VM ping ok
    csn.connect to    hostname=${asik_addr}    username=${asik_username}
    ...    password=${asik_password}    alias=gNB
    sleep    5s
    csn.send_command    command=ifconfig    connection=gNB
    sleep    3s
    ${output_log}    csn.read output    connection=gNB
    should match regexp    ${output_log}    fp0.${real_Vlan_id}
    should match regexp    ${output_log}    ${real_IP}
    sleep    1s
    csn.send_command    command=ping ${real_IP} -c 5 -i 2    connection=gNB
    sleep    3s
    ${output_log_0}    csn.read output    connection=gNB
    should match regexp    ${output_log_0}    ttl=
    csn.disconnect    connection=gNB
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...   password=${host_password}    alias=VM
    sleep    5s
    csn.send_command    command=ping ${real_IP} -c 5 -i 2    connection=VM
    sleep    3s
    ${output_log_1}    csn.read output    connection=VM
    should match regexp    ${output_log_1}    ttl=
    csn.disconnect    connection=VM

Config VLAN
    [Arguments]    ${vlanif_id}    ${vlanId}
    selenium_coam.add_object    object_name=ETHIF-1    object_class_name=VLANIF    id_value=${vlanif_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${vlanif_id}
    ...    filter_param=VLAN ID    new_value=${vlanId}

Config IPIF
    [Arguments]    ${ipif_id}    ${vlanif_id}
    selenium_coam.add_object    object_name=IPNO-1    object_class_name=IPIF    id_value=${ipif_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}
    ...    filter_param=Layer 2 interface reference    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-${vlanif_id}

Add IP And Config IPv4
    [Arguments]    ${ipif_id}    ${ip}
    selenium_coam.add_object    object_name=IPIF-${ipif_id}    object_class_name=IPADDRESSV4    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV4-1
    ...    filter_param=IP address allocation method    new_value=MANUAL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV4-1
    ...    filter_param=Local IPv4 address    new_value=${ip}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV4-1
    ...    filter_param=Local IPv4 prefix length    new_value=29
    sleep    2s

Add IP And Config IPv6
    [Arguments]    ${ipif_id}    ${ip}
    selenium_coam.add_object    object_name=IPIF-${ipif_id}    object_class_name=IPADDRESSV6    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV6-1
    ...    filter_param=IP address allocation method    new_value=MANUAL
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV6-1
    ...    filter_param=Local IPv6 address    new_value=${ip}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif_id}/IPADDRESSV6-1
    ...    filter_param=Local IPv6 prefix length    new_value=126
    sleep    2s

Config Amf IP
    [Arguments]    ${AMF_IP}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/SERVEDAMF-1    filter_param=AMF IPv4/v6 Address
    ...    new_value=${AMF_IP}

Config Plane IP
    [Arguments]    ${id}    ${ipif}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}    filter_param=IPv4 address 1 distinguished name
    ...    node_index=${id}    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV4-1

Config Mplane IP
    [Arguments]    ${id}    ${ipif}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=Management plane IPv4 IP address reference
    ...    node_index=${id}    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV4-1


Add TOP And Config Splane IP 
    [Arguments]    ${id}    ${ipif}
    selenium_coam.add_object    object_name=CLOCK-1    object_class_name=TOP    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=Synchronization plane IP address distinguished name    node_index=${id}
    ...    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV4-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=Synchronization plane DSCP    new_value=46
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=ToP domain number    new_value=0

Add TOP And Config Splane IPv6
    [Arguments]    ${id}    ${ipif}
    selenium_coam.add_object    object_name=CLOCK-1    object_class_name=TOP    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=Synchronization plane IP address distinguished name    node_index=${id}
    ...    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV6-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=Synchronization plane DSCP    new_value=46
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1
    ...    filter_param=ToP domain number    new_value=0

Config TOPP 
    [Arguments]    ${top_master}
    selenium_coam.add_object    object_name=TOP-1    object_class_name=TOPP    id_value=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Accepted clock class list    new_value=6
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Accepted clock class list    new_value=7
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Synchronization message rate    new_value=RATE_128
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Timing over Packet standard profile    new_value=Telecom2008
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Tuning profile for ToP with Phase Sync    new_value=Normal
    selenium_coam.add_element    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Timing over Packet master properties list
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Local priority of slave port towards ToP master    new_value=128
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=IP Address of the ToP master      new_value=${top_master}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Maximum network timing error    new_value=0
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Phase error compensation    new_value=0
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Port Type Reference    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1
	selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    filter_param=Top Master identifier    new_value=1
    
Config CLOCK
    [Arguments] 
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    filter_param=Sync input type    new_value=TOPP


Config SYNC
    [Arguments]    
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1    filter_param=Activate eCPRI Master clock
    ...    new_value=true    
#    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1    filter_param=Type of the profile\'s target node
#    ...    new_value=RAU
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SYNC-1    filter_param=Type of the profile&apos;s target node
    ...    new_value=RAU

Config Plane IPv6
    [Arguments]    ${id}    ${ipif}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}    filter_param=IPv6 address 1 distinguished name
    ...    node_index=${id}    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV6-1

Config Mplane IPv6
    [Arguments]    ${id}    ${ipif}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    filter_param=Management plane IPv6 IP address reference
    ...    node_index=${id}    new_value=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-${ipif}/IPADDRESSV6-1

Create GNB Log Path
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=ASIK
    csn.execute    command=ls ${ASIK_log_path} || mkdir -p ${ASIK_log_path}    connection=ASIK
    sleep    1s
    csn.execute    command=rm -rf ${ASIK_log_path}*    connection=ASIK
    csn.disconnect    connection=ASIK

Create VM Log Path
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...  password=${host_password}    alias=VM
    csn.execute    command=ls ${VM_log_path} || mkdir -p ${VM_log_path}    connection=VM
    sleep    1s
    csn.execute    command=rm -rf ${VM_log_path}*    connection=VM
    csn.disconnect    connection=VM

ASIK Tcpdump Setup
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=ASIK
    sleep    5s
    csn.send_command    command=tcpdump -i fp0 -s0 -G 1500 -w ${ASIK_log_path}5GC000647_%Y%m%d%H%M.pcap    connection=ASIK
    sleep    3s
    csn.disconnect    connection=ASIK
    sleep    1min

Ping Test
    [Arguments]    ${ip}
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...   password=${host_password}    alias=VM
    sleep    1s
    csn.execute    command=ping ${ip} -c 20 -i 2    connection=VM
    sleep    1s
    csn.disconnect    connection=VM

Ping6 Test
    [Arguments]    ${ip}
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...   password=${host_password}    alias=VM
    sleep    1s
    csn.execute    command=ping6 ${ip} -c 20 -i 2    connection=VM
    sleep    1s
    csn.disconnect    connection=VM

ASIK Tcpdump Complete
    sleep    30s
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=ASIK
    sleep    5s
    csn.execute    command=killall tcpdump    connection=ASIK
    sleep    2s
    csn.disconnect    connection=ASIK

ASIK Copy File
    csn.Connect to    hostname=${host_addr}    username=${host_username}
    ...    password=${host_password}    alias=VM
    sleep    3s
    csn.execute    command=sshpass -p ${asik_password} scp ${asik_username}@${asik_addr}:${ASIK_log_path}* ${VM_log_path}    connection=VM
    ${log_name1}    csn.execute    command=ls ${VM_log_path} | grep 5GC000647    connection=VM
    ${result}    should match regexp      ${log_name1}    (.*)\r\n
    ${log_name}    set variable      ${result}[1]
    set suite variable     ${log_name}
    sleep    5s
    csn.disconnect    connection=VM
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}
    ...   password=${asik_password}    alias=ASIK
    sleep    5s
    csn.execute    command=rm -rf ${ASIK_log_path}*    connection=ASIK
    csn.disconnect    connection=ASIK

Change List of static IPv4 routes
    [Arguments]    ${id}    ${Gateway}
    sleep    3s
    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1   filter_param=Destination IP address of the route
    ...    node_index=${0}    new_value=0.0.0.0
    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1   filter_param=Destination IP prefix length
    ...    node_index=${0}    new_value=0
    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1   filter_param=IP address of the next hop of the route
    ...    node_index=${0}    new_value=${Gateway}
    sleep    1s

Change List of static IPv6 routes
    [Arguments]    ${id}    ${Gateway}
    sleep    3s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1
    ...    filter_param=Destination IPv6 address of the static route    node_index=${0}    new_value=::
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1    filter_param=Destination IPv6 prefix length
    ...    node_index=${0}    new_value=0
    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1    filter_param=Gateway IPv6 address
    ...    node_index=${0}    new_value=${Gateway}
    sleep    1s
