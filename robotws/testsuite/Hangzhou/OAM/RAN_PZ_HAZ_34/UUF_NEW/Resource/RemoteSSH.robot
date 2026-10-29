*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# SSH To Testline
UUF Get SW Release From SSH
    [Arguments]   ${testline}   ${needConnect}=${True}
    ${ssh_addr}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    Run Keyword If   ${needConnect}
    ...   csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${sw_file_name}   csn.Execute   command=ls /ffs/run | grep TargetBD.*.xml | grep -v .xml.   connection=${testline}
    @{sw_version_list}   Get Regexp Matches   ${sw_file_name}   TargetBD_(.*?)_   1
    Run Keyword And Ignore Error   Remove values From List   ${sw_version_list}   BSR
    ${sw_release}    Strip String   ${sw_version_list[0]}
    [Return]   ${sw_release}
    [Teardown]   Run Keyword If   ${needConnect}
    ...   Run Keyword And Ignore Error   csn.disconnect   connection=${testline}


UUF Get Hostname And Container ID
    [Arguments]   ${testline}   ${needConnect}=${True}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    &{return_dict}   Create Dictionary


    Run Keyword If   ${needConnect}
    ...   csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    ${output}   csn.Execute   command=hostname   connection=${testline}
    ${primary_host}   Strip String   ${output}
    ${secondary_host}   Set Variable If
    ...   '${primary_host}'=='fct-0a'   fct-4a
    ...   '${primary_host}'=='fct-4a'   fct-0a
    ...   NONE

    ${primary_container_id}   Set Variable If
    ...   '${primary_host}'=='fct-0a'   0x1018
    ...   "${primary_host}"=="asc-0a"   0x1018
    ...   '${primary_host}'=='fct-4a'   0x2018
    ...   0x1018

    ${secondary_container_id}   Set Variable If
    ...   '${secondary_host}'=='fct-0a'   0x1018
    ...   '${secondary_host}'=='fct-4a'   0x2018
    ...   NONE

    ${module_type}   csn.Execute
    ...   command=sysinfo 2>&1 | head -n10 | grep "ID_00_MODULE_ID_\\[0\\]" | awk -F "'" '{print $2}'   connection=${testline}
    ${module_type}   Strip String   ${module_type}
    Log To Console   module_type: ${module_type}

    Set To Dictionary   ${return_dict}   primary_host   ${primary_host}
    Set To Dictionary   ${return_dict}   secondary_host   ${secondary_host}
    Set To Dictionary   ${return_dict}   primary_container_id   ${primary_container_id}
    Set To Dictionary   ${return_dict}   secondary_container_id   ${secondary_container_id}
    Set To Dictionary   ${return_dict}   module_type   ${module_type}

    [Return]   ${return_dict}
    [Teardown]   Run Keyword If   ${needConnect}
    ...   Run Keyword And Ignore Error   csn.disconnect   connection=${testline}




# Get NetAct IP List From NetAct Config File
Get NetAct Host IP List From Config File
    @{HOST_LIST_CONFIG}   Create List

    Log To Console   netact_global_configuration: ${netact_global_configuration}
    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"   ${HOST_LIST_CONFIG}

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    csn.Download File   remote_path=/etc/ClusterConfig.xml   local_path=${OUTPUT_DIR}/ClusterConfig.xml   connection=NETACT_VM
    ${Cluster_XML}   Parse XML    ${OUTPUT_DIR}/ClusterConfig.xml
    ${hosts_eles}   XML.Get Elements   ${Cluster_XML}   xpath=Hosts/Host

    FOR   ${host_ele}   IN   @{hosts_eles}
        ${host_name_text}   XML.Get Element Attribute   ${host_ele}   name=Hostname   xpath=.
        ${host_ip_text}   XML.Get Element Attribute   ${host_ele}   name=IP   xpath=.
        Append To List   ${HOST_LIST_CONFIG}   ${host_ip_text}
    END
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM
    [Return]   ${HOST_LIST_CONFIG}


# Get NetAct IP List From WebEM
Get NetAct Host IP List From WebEM
    [Arguments]   ${testline}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    @{HOST_LIST_WEBEM}   Create List
    ${nms_info}   coam.get_nms_state   connection=${testline}
    @{managerInfo}   Get Variable Value   ${nms_info["managerInfo"]}   @{EMPTY}
    FOR   ${managerConnection}   IN   @{managerInfo}
        ${managerIpAddress}   Set Variable   ${managerConnection["managerIpAddress"]}
        Append To List   ${HOST_LIST_WEBEM}   ${managerIpAddress}
    END
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    [Return]   ${HOST_LIST_WEBEM}


Block or Recovery NetAct Connection By iptables
    [Arguments]   ${testline}   ${HOST_LIST}=${NetAct_HOST_LIST}   ${action}=Recovery

    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}

    ${param}   Set Variable If
    ...   "${action}"=="Block"   -I
    ...   "${action}"=="Recovery"   -D
    ...   -D

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline}
    FOR   ${ip_addr}   IN   @{HOST_LIST}
        csn.Execute   command=iptables ${param} INPUT -s ${ip_addr} -j DROP   connection=${testline}
        csn.Execute   command=iptables ${param} OUTPUT -s ${ip_addr} -j DROP   connection=${testline}
        csn.Execute   command=iptables ${param} INPUT -d ${ip_addr} -j DROP   connection=${testline}
        csn.Execute   command=iptables ${param} OUTPUT -d ${ip_addr} -j DROP   connection=${testline}
    END
    [Teardown]   csn.Disconnect   connection=${testline}


Check Connection Status
    [Arguments]   ${ip_address}   ${status}=disconnect
    Log To Console   Check Connection Status: ${status}
    ${result}   OperatingSystem.Run   command=timeout 5s ping -c 1 ${ip_address} > /dev/null 2>&1; echo $?
    ${result}   Strip String   ${result}
    Run Keyword If   "${status}"=="disconnect"   Should Not Be True   "${result}"=="0"
    Run Keyword If   "${status}"=="connect"   Should Be True   "${result}"=="0"
