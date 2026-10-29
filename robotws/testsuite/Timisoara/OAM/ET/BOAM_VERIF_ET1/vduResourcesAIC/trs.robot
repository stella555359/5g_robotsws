*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   TRANS common keyword


#Resource    aic_common_resources.robot


*** Variables ***
######## testline related value ############



############### TRANS related specific configuration ###########
${TRANS_PARA}                   ${NONE}

&{TOOLS_INFO}    work_folder_root=/tmp/opt/
    ...    work_folder_tool=/tmp/opt/tools/trans_test/
    ...    work_folder_data=/tmp/opt/tools/trans_data/
    ...    work_folder_simu4trs=/tmp/opt/tools/trans_simu4trs/
    ...    arp_test_m=arp_test_m
    ...    icmp_test=icmp_test
    ...    pmtu=pmtu
    ...    send_ether_frame=send_ether_frame
    ...    TrafficGen_vDU=TrafficGen_vDU
    ...    process_guard=process_guard.sh
    ...    ifstats=ifstats
    ...    tcpdump_guard=tcpdump_guard.sh
    ...    tcpdump_guard_cnf=tcpdump_guard_cnf.sh
    ...    tcpdump_guard_vdu_ocp=tcpdump_guard_vdu_ocp.sh
    ...    dep_simu4trs=dep_simu4trs.sh
    ...    load_simu4trs_img=load_simu4trs_img.sh
    ...    fragment=fragment
    ...    pktplayer=pktplayer
    ...    unbinding_dpdk_driver=unbinding_dpdk_driver.sh
    ...    ru_checksum=ru_checksum.py
    ...    openssl_cnf=openssl.cnf


${VDU_CONF_FILE_oamfh.json}    /opt/nokia/SS_OAM/OAMFH/oamfh.json
${VDU_CONF_FILE_oamfh_RegisteredRU.json}    /mnt/services/SS_OAMDU/OAMFH/working_dir/fileHost/RegisteredRU.json

*** Keywords ***
############################## vCU TRS Start ##############################
====== VCU TRS Start ======
     Log To Console  \n*** only used for readable ***


CU Restart All VMs
    [Arguments]  ${gnb_index}=0
    [Teardown]    run keyword and ignore error  cu rest logout
    [Documentation]    CU Restart All VMs
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | CU Restart All VMs |
    ...
    ${r}  ${out}   run keyword and ignore error   CU Restart All VMs By SSH  gnb_index=${gnb_index}
    return from keyword if   "${r}"=="PASS"

    sleep  10
    cu rest login
    cu reset


CU Restart All VMs By SSH
    [Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    CU Restart Master VM
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | CU Restart All VMs |
    ...
    ${alias}  Get Unique Id
    CU SSH To OAM   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=dvmcli -r cluster   check_result=${False}   alias=${alias}


CU Get Master VM Index
    [Arguments]   ${vm_type}=oam  #${gnb_index}=0
    [Documentation]    CU Get Master VM Index
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...    | vm_type   | no | vm type, can be oam, cpif,cpcl,cpnb,cpnrt,cpue,db and upue, default is oam |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${master_vm_index} | CU Get Master VM Index| vm_type=oam |
    ...    | ${master_vm_index} | CU Get Master VM Index| gnb_index=0 | vm_type=cpif |
    ...
    ${vm_type}  Set Variable  ${vm_type.upper()}
    ${master_vm_index}   Set Variable  0
    [Return]  ${master_vm_index}


Get Sudo For VCU K8s Admin Command
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get Sudo For VCU K8s Admin Command
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   if admin account is cbis-admin, return sudo, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VCU K8s Admin Command |
    ...
    ${vcu_k8s_master_ssh_connection_info}   Get VCU K8s Admin SSH Connection Info   gnb_index=${gnb_index}
    ${sudo}   set variable if   "${vcu_k8s_master_ssh_connection_info["username"]}"=="cbis-admin"   sudo   ${EMPTY}
    [Return]   ${sudo}


Get Sudo For VDU K8s Admin Command
    [Arguments]  ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Get Sudo For VDU K8s Admin Command
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...    | vdu_index | no | vdu index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   if admin account is core return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VDU K8s Admin Command |
    ...
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${sudo}   set variable if   "${vdu_k8s_master_ssh_connection_info["username"]}"=="core"  ${EMPTY}   ${EMPTY}
    [Return]   ${sudo}


Get VCU Sudo For Current User
    [Arguments]  ${alias}=default
    [Documentation]   Get VCU Sudo For Current User
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default  |
    ...
    ...    *RETURN VALUE*
    ...   if current login name is cbis-admin, return sudo. if current login name is root, return ${EMPTY}, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get VCU Sudo For Current User | alias=myalias |
    ...
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}
    ${sudo}   set variable if   "${current_user_name}"=="cbis-admin"   sudo
        ...   "${current_user_name}"=="root"   ${EMPTY}
        ...   ${EMPTY}
    [Return]   ${sudo}


############################## vCU TRS end ##############################
====== VCU TRS End ======
     Log To Console  \n*** only used for readable ***



############################## vDU TRS Start ##############################
====== VDU TRS Start ======
     Log To Console  \n*** only used for readable ***

Parse Ipv4 Address
    [Arguments]  ${content}
    [Documentation]    get ipv4 address and mask length from linux command 'ip address show dev eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | tafssh.execute      | ip address show dev fp0 |
    ...    | ${ipv4_addr} | ${ipv4_mask_len} | Parse ipv4 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+)/([0-9]{1,3})\\s.*   1    2
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip_addr}     ${ip_mask_len}


Parse Ipv6 Address
    [Arguments]  ${content}
    [Documentation]    get ip6 address and mask length from linux command 'ip address show dev eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 28.7.2020,Hefeng-Cookie.qu@nokia-sbell.com,add support  container.
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | tafssh.execute      | ip address show dev fp0 |
    ...    | ${ip6_addr} | ${ip6_mask_len} | Parse ipv6 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)/([0-9]{1,3}).+scope global   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}

    Return From Keyword If    ${ip6_addr.__len__()}>0    ${ip6_addr}    ${ip6_mask_len}

    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)\\s+prefixlen\\s+(\\d+)\\s+scopeid\\s+   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip6_addr}     ${ip6_mask_len}


Parse Ipv4 Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Ipv4 Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv4 address, net mask and broadcast ip
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${ip} | ${mask} | ${broadcast} | Parse Ipv4 Address From Ifconfig |   ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}     .*inet\\s+(\\S+)\\s+netmask\\s+(\\S+)\\s+broadcast\\s+(\\S+).*   1  2  3
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    ${broadcast}    Set Variable If    ${matches}    ${matches[0][2]}    ${EMPTY}

    Return From Keyword If     ${matches}     ${ip}     ${mask}   ${broadcast}

    ${matches}  Get Regexp Matches     ${content}     .*inet\\s+addr:(\\S+)\\s+Bcast:\\s*(\\S+)\\s+Mask:\\s*(\\S+).*   1  2  3
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    ${broadcast}    Set Variable If    ${matches}    ${matches[0][2]}    ${EMPTY}

    [Return]    ${ip}     ${mask}   ${broadcast}

Parse Ipv6 Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Ipv6 Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address, prefixlen
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${ip} | ${prefixlen} | Parse Ipv6 Address From Ifconfig |   ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}     .*inet6\\s+([0-9]\\S+)\\s+prefixlen\\s+(\\S+)\\s+scopeid\\s+\\S+.*   1  2
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    Return From Keyword If     ${matches}     ${ip}     ${mask}
    [Return]    ${ip}     ${mask}

Parse Ipv4 Address Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Ipv4 Address Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    ip v4 address
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc10.108.227.133def |
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc 10.108.227.133 def |
    ...
    ...    keyword fails
    ...    | ${ip} | String Should Be An Ip Address | abc10.108.227.abc |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9]*(\\d+\\.\\d+\\.\\d+\\.\\d+).*   1
    Should Be True  ${matches}
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${ip_addr}


Parse Mac Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Mac Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv4 address, net mask and broadcast ip
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${mac} | Parse Mac Address From Ifconfig | ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}
      ...   ether\\s+([0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2})     1
    ${mac}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}

    Return From Keyword If     ${matches}    ${mac}

    ${matches}  Get Regexp Matches     ${content}
      ...   HWaddr\\s+([0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2})     1
    ${mac}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}

    [Return]    ${mac}


Parse Number Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Integer Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    Number inside content
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${number} | Parse Intege Only From Content | abc10def |
    ...    | ${number} | Parse Intege Only From Content | abc 11 def |
    ...
    ...    keyword fails
    ...    | ${number} | Parse Intege Only From Content | abcsdfxxxdf.abc |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9]*(\\d+).*   1
    ${number}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${number}


Parse Hex Number Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Hex Integer Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    Number inside content
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${hex_number} | Parse Hex Intege Only From Content | ggff00abc10defzz |
    ...    | ${hex_number} | Parse Hex Intege Only From Content | gg ff00abc10def zz |
    ...
    ...    keyword fails
    ...    | ${hex_number} | Parse Intege Only From Content | gghhiii |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9a-fA-F]*([0-9a-fA-F]+).*   1
    ${hex_number}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${hex_number}


Should Be A Numerical String
    [Arguments]  ${content}
    [Documentation]    Should Be A Numerical String
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    keyword succeeds
    ...    | Should Be A Numerical String | 123 |
    ...    keyword Fails
    ...    | Should Be A Numerical String | a123 |
    ...
    ${tmp_str}   Parse Number Only From Content   ${content}
    should not be empty   ${tmp_str}
    should be true    ${tmp_str.__len__()}==${content.__len__()}


Wait Until Process Disappear
    [Arguments]  ${pid}   ${alias}   ${duration}=1200  ${interval}=5
    [Documentation]    Wait Until Process Disappear
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pid       |  yes | pid |
    ...    | alias     |  yes | alias |
    ...    | duration     |  no | duration, default is 1200 |
    ...    | interval     |  no | interval, default is 5 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait Until Process Disappear | 123 |  alias=myalias |
    ...
    wait until keyword succeeds   ${duration}   ${interval}   _Wait Until Process Disappear Once   pid=${pid}   alias=${alias}


Wait Until Process Disappear With Expected String
    [Arguments]  ${expected_string}   ${alias}   ${duration}=1200  ${interval}=5
    [Documentation]    Wait Until Process Disappear
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pid       |  yes | pid |
    ...    | alias     |  yes | alias |
    ...    | duration     |  no | duration, default is 1200 |
    ...    | interval     |  no | interval, default is 5 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait Until Process Disappear With Expected String | 123 |  alias=myalias |
    ...
    wait until keyword succeeds   ${duration}   ${interval}   _Wait Until Process Disappear With Expected String Once
       ...   expected_string=${expected_string}   alias=${alias}



_Wait Until Process Disappear Once
    [Arguments]  ${pid}   ${alias}
    ${r}  ${out}  run keyword and ignore error  issh.Execute   command=ps -p ${pid} -f   alias=${alias}
    should be true  "${r}"=="FAIL"


_Wait Until Process Disappear With Expected String Once
    [Arguments]  ${expected_string}   ${alias}
    ${r}  ${out}  run keyword and ignore error  issh.Execute   command=ps -ef|grep "${expected_string}"|grep -v grep    alias=${alias}
    ${out}   strip prompt  ${out}
    should not contain  ${out}   ${expected_string}


Upload Tools To VDU Containers
    [Arguments]   ${target}=${EMPTY}   ${vdu_index}=0
    [Documentation]   Upload Tools To VDU Containers
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | target    | No | target container, default value is ${EMPTY}, means upload to all VDU containers |
    ...    |           |    | otherwise it should a dictionary to indicate containers where the tools will be uploaded |
    ...    |           |    | dictionary key is pod abbreviation, e.g oamcp, up, value is a list, please see examples |

    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To vDU Containers |
    ...    | ${containers} | create list | oamfh | oam |
    ...    | ${target}     | create dictionary | oamcp=${containers} |
    ...    | Upload Tools To vDU Containers | target=${target} |
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""


    Log To Console  Tools: tools repository ---> K8s master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}

    _Upload File From Master Node To Containers   vdu_index=${vdu_index}   para_tools_info=${TOOLS_INFO}  target=${target}


Upload Tools To K8s Master
    [Arguments]  ${vdu_index}=0
    [Documentation]   Upload Tools To K8s Master
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To K8s Master |
    ...
    log to console   Upload Tools To K8s Master
    run keyword If  """${TRANS_PARA}"""=="""${NONE}"""   Fail  Can't find TRANS_PARA variable!
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    run keyword If  """${result}"""=="""FAIL"""   Fail   Can't find TRANS_PARA->tools_repository variable!
    Return From Keyword If  """${result}"""=="""FAIL"""

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}


Upload Tools To VDU Nodes
    [Arguments]   ${target}=${EMPTY}   ${vdu_index}=0
    [Documentation]   Upload tools to UTE, containers.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | target    | No | target container, default value is ${EMPTY}, means upload to all VDU nodes |
    ...    |           |    | otherwise it should a list to indicate pod abbreviation name where the tools will be uploaded |
    ...    |           |    | e.g oamcp, up, value is a list, please see examples |

    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To vDU Nodes |
    ...    | ${target} | create list | oamcp | up |
    ...    | Upload Tools To vDU Nodes | target=${target} |
    ...
    run keyword if   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Log To Console  Tools: tools repository ---> K8s master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}

    #####################
    #upload file from master node to work node
    Log To Console  Tools: master node ---> work node
    ${pod_detailed_info_dict}        Create Dictionary
    #{"oamcp": {"work_node_ip":"1.1.1.1", "full_pod_name":"hquvdu-aic-vdu-oamcp-deployment-0" }
    #  "up": {"work_node_ip":"1.1.1.2", "full_pod_name":"hquvdu-aic-vdu-uprt-deployment-0" }
    #}

   ${pod_abbr_list}  Run Keyword If  "${target}"=="${EMPTY}"  Create List   oam   up   cprt
       ...   ELSE   set variable  ${target}
    Should Be True   ${pod_abbr_list.__len__()>0}

    ${alias}   Get Unique ID
    Connect To K8s Master   alias=${alias}
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${full_pod_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${work_node_ip}   Get Work Node Ip By Pod Abbreviation     pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       Should Be True  ${work_node_ip.__len__()}>0
       ${tmp}   Create Dictionary  full_pod_name=${full_pod_name}   work_node_ip=${work_node_ip}
       Set To Dictionary   ${pod_detailed_info_dict}    ${pod_abbr}   ${tmp}
    END

    ${ToBeUploadedWorkNode}   Create List
    FOR   ${pod_abbr}   IN   @{pod_abbr_list}
        ${tmp}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
        Append To List  ${ToBeUploadedWorkNode}   ${tmp}
    END
    ${ToBeUploadedWorkNode}  Remove Duplicates   ${ToBeUploadedWorkNode}

    FOR   ${work_node_ip}  IN   @{ToBeUploadedWorkNode}
        #run keyword and ignore error  disconnect from k8s master
        #connect to k8s master
       #   ${channel}  _upload file from master node to work node
       _Upload File From Master Node To Work Nodes
    ...   work_node_ip=${work_node_ip}
    ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
    ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
    ...   latest_version=${LATEST_VERSION_TOOLS}
    ...   connection=${alias}

       _Upload File From Master Node To Work Nodes
    ...   work_node_ip=${work_node_ip}
    ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
    ...   local_folder=${TOOLS_INFO["work_folder_data"]}
    ...   latest_version=${LATEST_VERSION_DATA}
    ...   connection=${alias}
    END


Upload Tools To VCU Master Nodes
    [Arguments]    ${gnb_index}=0
    [Documentation]   Upload Tools To VCU Active Master Nodes
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To VCU Master Nodes | |
    ...
    run keyword if   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Log To Console  Tools: tools repository ---> K8s vcu CNF master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To VCU Master Active Node  repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   gnb_index=${gnb_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}  _Copy Files From Repository To VCU Master Active Node   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   gnb_index=${gnb_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}


Upload Tools To UTE
    [Documentation]  Upload Tools To UTE
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To UTE |
    ...
    run keyword if   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""


    Log To Console  Tools: tools repository ---> UTE server
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To UTE Server  repo_folder=${tools_repository["repo_tool_folder"]}
       ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}  _Copy Files From Repository To UTE Server   repo_folder=${tools_repository["repo_data_folder"]}
       ...   local_folder=${TOOLS_INFO["work_folder_data"]}
    Set Suite Variable  ${LATEST_VERSION_DATA}


Upload Simu4trs Image To K8s Master
    [Arguments]  ${vdu_index}=0
    [Documentation]   Upload tools and simu4trs image to K8s master
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Simu4trs Image To K8s Master |
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_simu4trs_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_simu4trs"]}   vdu_index=${vdu_index}


Upload Tools To VCU
    [Arguments]  ${gnb_index}=0
    [Documentation]   Upload Tools To VCU
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To VCU |
    ...
    _Upload Tools To VCU OAM Master    gnb_index=${gnb_index}
    _Upload Tools From VCU OAM Master To Other VMs    gnb_index=${gnb_index}


_Upload Tools To VCU OAM Master
    [Arguments]  ${gnb_index}=0
    [Documentation]   _Upload Tools To VCU OAM Master
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Upload Tools To VCU OAM Master |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To VCU OAM Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   oam_master_folder=${TOOLS_INFO["work_folder_tool"]}   gnb_index=${gnb_index}
    set suite variable  ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}  _Copy Files From Repository To VCU OAM Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   oam_master_folder=${TOOLS_INFO["work_folder_data"]}   gnb_index=${gnb_index}
     set suite variable  ${LATEST_VERSION_DATA}


_Copy Files From Repository To VCU OAM Master
    [Arguments]   ${repo_folder}   ${oam_master_folder}   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias_oam_master}
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #get repository version number
    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${repo_ip}    username=${repo_username}    password=${repo_password}   alias=${alias}
    ${repo_version_file_name}   OperatingSystem.Join Path   ${repo_folder}   version.repo
    ${repo_version}   _Get Version Number Of Remote Repository   file_name=${repo_version_file_name}    connection=${alias}

    #get existence version number
    ${alias_oam_master}   Get Unique ID
    CU SSH To OAM  gnb_index=${gnb_index}   alias=${alias_oam_master}
    ${oam_master_version_file_name}   OperatingSystem.Join Path   ${oam_master_folder}   version.repo
    ${oam_version}   _Get Version Number Of Remote Interactively   file_name=${oam_master_version_file_name}   alias=${alias_oam_master}

    Return From Keyword If  ${oam_version}>=${repo_version}   ${repo_version}

    #download to UTE
    ${local_folder}   Set Variable  ${oam_master_folder}
    _Download File From Remote To Local   remote_ip=${repo_ip}
     ...   username=${repo_username}
     ...   password=${repo_password}
     ...   remote_folder=${repo_folder}
     ...   local_folder=${local_folder}

    #upload to VCU oam master
    ${vcu_oam_http_connection_info}    Get VCU OAM SSH Connection Info
    ${remote_ip}   set variable   ${vcu_oam_http_connection_info["addr"]}
    ${username}   set variable   ${vcu_oam_http_connection_info["username"]}
    ${password}   set variable   ${vcu_oam_http_connection_info["password"]}

    _Upload Folder From Local To OAM Master Interactively   remote_ip=${remote_ip}
     ...   username=${username}
     ...   password=${password}
     ...   remote_folder=${oam_master_folder}
     ...   local_folder=${local_folder}

    [Return]  ${repo_version}


_Upload Tools From VCU OAM Master To Other VMs
    #[Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]  _Upload Tools From VCU OAM Master To Other VMs
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Upload Tools From VCU OAM Master To Other VMs |
    ...
    ${all_vm_list}   CU Get VM Full Name List
    ${alias}   get unique id
    CU SSH To OAM  alias=${alias}
    ${hostname}   get host name  alias=${alias}
    Remove Values From List  ${all_vm_list}   ${hostname}

    ${basic_scp_cmd}    Set Variable    scp -r -q -oBatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2
    ${basic_ssh_cmd}   set variable  ssh -q -oBatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${remote_folder}   set variable  ${TOOLS_INFO["work_folder_tool"]}
    FOR    ${vm}    IN    @{all_vm_list}
        ${fqdn_name}   Get FQDN Name From VM Full Name   ${vm}
        ${ssh_cmd}    Set Variable    ${basic_ssh_cmd} ${fqdn_name} mkdir -p ${remote_folder}
        ${out}    issh.Execute   command=${ssh_cmd}    alias=${alias}
        ${scp_cmd}    Set Variable   ${basic_scp_cmd} ${remote_folder}* ${fqdn_name}:${remote_folder}
        ${out}    issh.Execute   command=${scp_cmd}    alias=${alias}
        ${ssh_cmd}    Set Variable    ${basic_ssh_cmd} ${fqdn_name} chmod -R 777 ${remote_folder}
        ${out}    issh.Execute   command=${ssh_cmd}    alias=${alias}
    END

    ${remote_folder}   set variable  ${TOOLS_INFO["work_folder_data"]}
    FOR    ${vm}    IN    @{all_vm_list}
        ${fqdn_name}   Get FQDN Name From VM Full Name   ${vm}
        ${ssh_cmd}    Set Variable    ${basic_ssh_cmd} ${fqdn_name} mkdir -p ${remote_folder}
        ${out}    issh.Execute   command=${ssh_cmd}    alias=${alias}
        ${scp_cmd}    Set Variable   ${basic_scp_cmd} ${remote_folder}* ${fqdn_name}:${remote_folder}
        ${out}    issh.Execute   command=${scp_cmd}    alias=${alias}
        ${ssh_cmd}    Set Variable    ${basic_ssh_cmd} ${fqdn_name} chmod -R 777 ${remote_folder}
        ${out}    issh.Execute   command=${ssh_cmd}    alias=${alias}
    END


_Download File From Remote To Local
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
      ...   ${folder_for_permission_setting}=${EMPTY}   ${permission}=777
    [Documentation]  Download remote folder From Remote To Local
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | remote_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    | username | Yes | username  |
    ...    | password | Yes | password  |
    ...    | remote_folder | Yes | remote_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...    | folder_for_permission_setting | no | folder_for_permission_setting of local server  |
    ...    | permission                    | no | permission  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Download File From Remote To Local  | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | _Download File From Remote To Local  | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/opt/tools/ | local_folder=/tmp/opt/tools/ | folder_for_permission_setting=/tmp/opt/ | permission=777 |
    ...
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    #create local folder if not exists
    #${run_code}  ${out}     Run And Return RC And Output   command=sudo mkdir -p ${local_folder}
    ${run_code}  ${out}     Run And Return RC And Output   command=mkdir -p ${local_folder}
    ${run_code}  ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   Run And Return RC And Output   command=sudo chmod 777 -R ${folder_for_permission_setting}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}   alias=${alias}
    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Repository   file_name=${remote_version_file_name}    connection=${alias}

    #run keyword if   ${local_version}>=${remote_version}    tafssh.disconnect  connection=${alias}
    Return From Keyword If    ${local_version}>=${remote_version}   ${remote_version}

    ${out}   tafssh.Execute  command=ls ${remote_folder}   connection=${alias}
    ${lines}  Split String   ${out}

    FOR  ${file}  IN  @{lines}
        ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
        ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
        tafssh.Download File   remote_path=${remote_folder_tmp}   local_path=${local_folder_tmp}   connection=${alias}
    END

    # tafssh.disconnect  connection=${alias}

    ${run_code}  ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   Run And Return RC And Output   command=sudo chmod ${permission} -R ${folder_for_permission_setting}
    [Return]  ${remote_version}


_Upload File From Local To Remote
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
        ...   ${folder_for_permission_setting}=${EMPTY}   ${permission}=777
    [Documentation]  _Upload File From Local To Remote
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | remote_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    | username | Yes | username  |
    ...    | password | Yes | password  |
    ...    | remote_folder | Yes | remote_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...    | folder_for_permission_setting | no | folder_for_permission_setting of remote server  |
    ...    | permission                    | no | permission  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | _Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ | folder_for_permission_setting=/tmp/opt/ | permission=777 |
    ...
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    File Should Exist   ${local_version_file_name}
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}   alias=${alias}

    #create remote folder if not exists
    ${out}    tafssh.Execute   command=mkdir -p ${remote_folder}   connection=${alias}
    ${out}    tafssh.Execute   command=chmod 777 -R ${remote_folder}  connection=${alias}

    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote    file_name=${remote_version_file_name}   connection=${alias}

    #run keyword if  ${remote_version}>=${local_version}   tafssh.disconnect   connection=${alias}
    Return From Keyword If    ${remote_version}>=${local_version}

    ${run_code}   ${out}   Run And Return RC And Output  command=ls ${local_folder}
    ${lines}  Split String   ${out}
    FOR  ${file}  IN  @{lines}
        ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
        ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
        tafssh.Upload File   local_path=${local_folder_tmp}    remote_path=${remote_folder_tmp}   connection=${alias}
    END

    ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   tafssh.Execute    command=chmod ${permission} -R ${folder_for_permission_setting}   connection=${alias}
    #  tafssh.disconnect   connection=${alias}


_Upload Folder From Local To OAM Master Interactively
    [Arguments]  ${remote_ip}   ${remote_folder}    ${local_folder}  #${username}    ${password}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]  _Upload Folder From Local To OAM Master Interactively
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | remote_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    | username | Yes | username  |
    ...    | password | Yes | password  |
    ...    | remote_folder | Yes | remote_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...    | folder_for_permission_setting | no | folder_for_permission_setting of remote server  |
    ...    | permission                    | no | permission  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Upload Folder From Local To OAM Master Interactively | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | _Upload Folder From Local To OAM Master Interactively | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ | folder_for_permission_setting=/tmp/opt/ | permission=777 |
    ...
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    File Should Exist   ${local_version_file_name}
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ${alias}   Get Unique ID
    CU SSH To OAM  alias=${alias}

    #create remote folder if not exists
    ${out}    issh.Execute   command=mkdir -p ${remote_folder}   alias=${alias}
    ${out}    issh.Execute   command=chmod 777 -R ${remote_folder}  alias=${alias}

    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Interactively   file_name=${remote_version_file_name}   alias=${alias}

    Return From Keyword If    ${remote_version}>=${local_version}
    Upload Folder From Local To OAM Master Interactively DO   local_folder=${local_folder}  remote_folder=${remote_folder}


Upload Folder From Local To OAM Master Interactively DO
    [Arguments]    ${remote_folder}   ${local_folder}
    [Teardown]   run keywords   run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_local_ute}
    [Documentation]    Upload Folder From Local To OAM Master Interactively DO
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | remote_folder | Yes | remote_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Upload Folder From Local To OAM Master Interactively DO | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...

    ${remote_folder}   set variable if   not ${remote_folder.endswith("/")}    ${remote_folder}/    ${remote_folder}
    ${local_folder}   set variable if   not ${local_folder.endswith("/")}    ${local_folder}/    ${local_folder}

    ${alias}   get unique id
    CU SSH To OAM  alias=${alias}

    ${vcu_oam_http_connection_info}    Get VCU OAM SSH Connection Info
    ${remote_ip}   set variable   ${vcu_oam_http_connection_info["addr"]}
    ${remote_ip}   set variable if  ':' in '''${remote_ip}'''   [${remote_ip}]   ${remote_ip}
    ${username}   set variable   ${vcu_oam_http_connection_info["username"]}
    ${password}   set variable   ${vcu_oam_http_connection_info["password"]}

    ${tmp}    Replace String    ${remote_folder}    /   ${EMPTY}    count=1
    ${tmp_ftp_folder}    OperatingSystem.Join Path   /home  ${username}   ${tmp}
    ${out}   issh.Execute    mkdir ${tmp_ftp_folder} -p     alias=${alias}
    ${out}   issh.Execute    chown -R ${username}:${username} ${/}home${/}${username}     alias=${alias}

    #sftp Upload Tools
    # Put Directory    ${local_folder}    ${/}home${/}${username}${/}tools    recursive=True     alias=${alias}
    ${alias_local_ute}  get unique id
    connect to ute locally  alias=${alias_local_ute}
    issh.is_dir   ${local_folder}   alias=${alias_local_ute}
    ${full_local_folder}   OperatingSystem.join Path   ${local_folder}   *
    log to console   local_folder:${full_local_folder}
    log to console   tmp_ftp_folder:${tmp_ftp_folder}
    log to console   remote_folder:${remote_folder}
    ${cmd}   set variable   scp -r -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${cmd}   set variable  ${cmd} ${full_local_folder} ${username}@${remote_ip}:${tmp_ftp_folder}
    ${old_prompt}  issh.Set Prompt   assword:     alias=${alias_local_ute}
    ${out}   issh.Execute   command=${cmd}    check_result=${False}   alias=${alias_local_ute}
    ${out}   issh.Set Prompt   ${old_prompt}     alias=${alias_local_ute}
    ${out}   issh.Execute   command=${password}    check_result=${False}   alias=${alias_local_ute}

    ${out}   issh.Execute   command=mkdir -p ${remote_folder}   alias=${alias}

    ${tmp_ftp_folder_2}   OperatingSystem.Join Path   ${tmp_ftp_folder}   *
    ${out}   issh.Execute   command=cp -r ${tmp_ftp_folder_2} ${remote_folder}   alias=${alias}
    ${out}   issh.Execute   command=chmod -R 777 ${remote_folder}      alias=${alias}

    ${out}   issh.Execute   command=rm -rf ${tmp_ftp_folder}      check_result=${False}          alias=${alias}
    ${parent_folder}   Get Parent Folder     ${remote_folder}
    ${out}   issh.Execute   command=rm -rf /home/${username}/${parent_folder}   check_result=${False}    alias=${alias}


_Upload File From Master Node To Containers
    [Arguments]  ${para_tools_info}  ${vdu_index}=0  ${target}=${EMPTY}
    ${oamcp_pod_containers}  Run Keyword If  "${target}"=="${EMPTY}"  Create List   oam   oamfh   nwmgmt  cprt
    ${uprt_pod_containers}   Run Keyword If  "${target}"=="${EMPTY}"  Create List   l2hi    l2rt  l2hi   l1hi  nwmgmt
    ${pod_and_container_abbr_dict}   Run Keyword If  "${target}"=="${EMPTY}"
       ...   create dictionary  oamcp=${oamcp_pod_containers}    up=${uprt_pod_containers}
       ...   ELSE   set variable  ${target}

    Log To Console  ${pod_and_container_abbr_dict}
    ${ns}   Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}

    ${pod_detailed_info_dict}        Create Dictionary
    #{"oamcp": {"work_node_ip":"1.1.1.1", "full_pod_name":"hquvdu-aic-vdu-oamcp-deployment-0" }
    #  "up": {"work_node_ip":"1.1.1.2", "full_pod_name":"hquvdu-aic-vdu-uprt-deployment-0" }
    #}

    ${alias}   Get Unique ID
    Connect To K8s Master   alias=${alias}
    ${pod_abbr_list}  Set Variable  ${pod_and_container_abbr_dict.keys()}
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${full_pod_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${work_node_ip}   Get Work Node Ip By Pod Abbreviation     pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${tmp}   Create Dictionary  full_pod_name=${full_pod_name}   work_node_ip=${work_node_ip}
       Set To Dictionary   ${pod_detailed_info_dict}    ${pod_abbr}   ${tmp}
    END

    #upload file from master node to work node
    Log To Console  Tools: master node ---> work node
    ${ToBeUploadedWorkNode}   Create List
    FOR   ${pod_abbr}   IN   @{pod_abbr_list}
        ${tmp}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
        Append To List  ${ToBeUploadedWorkNode}   ${tmp}
    END
    ${ToBeUploadedWorkNode}  Remove Duplicates   ${ToBeUploadedWorkNode}

    FOR   ${work_node_ip}  IN   @{ToBeUploadedWorkNode}
        #run keyword and ignore error  disconnect from k8s master
        #connect to k8s master
       _Upload File From Master Node To Work Nodes
       ...   work_node_ip=${work_node_ip}
       ...   remote_folder=${para_tools_info["work_folder_tool"]}
       ...   local_folder=${para_tools_info["work_folder_tool"]}
       ...   latest_version=${LATEST_VERSION_TOOLS}
       ...   connection=${alias}

       _Upload File From Master Node To Work Nodes
       ...   work_node_ip=${work_node_ip}
       ...   remote_folder=${para_tools_info["work_folder_data"]}
       ...   local_folder=${para_tools_info["work_folder_data"]}
       ...   latest_version=${LATEST_VERSION_DATA}
       ...   connection=${alias}
    END

    #upload file from work node to container
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${work_node_ip}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
       _Upload File From Work Node To Containers
          ...   ns=${ns}
          ...   pod_and_container_abbr_dict=${pod_and_container_abbr_dict}
          ...   pod_detailed_info_dict=${pod_detailed_info_dict}
          ...   pod_abbr=${pod_abbr}
          ...   work_node_ip=${work_node_ip}
          ...   para_tools_info=${para_tools_info}
          ...   connection=${alias}
          ...   vdu_index=${vdu_index}
    END


_Copy Files From Repository To Master
    [Arguments]   ${repo_folder}   ${k8s_master_folder}   ${vdu_index}=0
    [Documentation]    _Copy Files From Repository To Master
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | repo_folder | Yes | repo_folder  |
    ...    | k8s_master_folder | Yes | k8s_master_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Copy Files From Repository To Master | repo_folder=/opt/tools/trans_test/ | k8s_master_folder=/tmp/opt/tools/ |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #get repository version number
    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${repo_ip}    username=${repo_username}    password=${repo_password}   alias=${alias}
    ${repo_version_file_name}   OperatingSystem.Join Path   ${repo_folder}   version.repo
    ${repo_version}   _Get Version Number Of Remote Repository   file_name=${repo_version_file_name}    connection=${alias}

    #get existence version number
    ${alias_k8s_master}   Get Unique ID
    Connect To K8s Master    vdu_index=${vdu_index}   alias=${alias_k8s_master}

    ${k8s_master_version_file_name}   OperatingSystem.Join Path   ${k8s_master_folder}   version.repo
    ${k8s_version}   _Get Version Number Of Remote    file_name=${k8s_master_version_file_name}   connection=${alias_k8s_master}

    Return From Keyword If  ${k8s_version}>=${repo_version}   ${repo_version}

    #download to UTE
    ${local_folder}   Set Variable  ${k8s_master_folder}
    _Download File From Remote To Local   remote_ip=${repo_ip}
     ...   username=${repo_username}
     ...   password=${repo_password}
     ...   remote_folder=${repo_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${local_folder}
     ...   permission=777


    #upload to K8s master
    ${result}  ${mast_node}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True  "${result}"=="PASS"
    ${result}  ${username}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"
    ${result}  ${password}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"

    _Upload File From Local To Remote   remote_ip=${mast_node}
     ...   username=${username}
     ...   password=${password}
     ...   remote_folder=${k8s_master_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${k8s_master_folder}
     ...   permission=777

    [Return]  ${repo_version}


_Upload File From Master Node To Work Nodes
    [Arguments]   ${work_node_ip}    ${remote_folder}    ${local_folder}   ${latest_version}  ${connection}=default
    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Work Node
     ...   work_node_ip=${work_node_ip}  remote_version_file_name=${remote_version_file_name}   connection=${connection}
    Return From Keyword If  ${remote_version}>=${latest_version}

    ${base_ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    ${ssh_command}   Set Variable   ${base_ssh_command} -C mkdir -p ${remote_folder}
    ${out}    tafssh.Execute   command=${ssh_command}    connection=${connection}

    ${scp_command}   Set Variable  scp -r -o batchmode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${scp_command}   Set Variable  ${scp_command} ${local_folder}* ${work_node_ip}:${remote_folder}
    ${out}   tafssh.Execute  command=${scp_command}  connection=${connection}



_Copy Files From Repository To UTE Server
    [Arguments]   ${repo_folder}   ${local_folder}
    [Documentation]    _Copy Files From Repository To UTE Server
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | repo_folder | Yes | repo_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Copy Files From Repository To UTE Server | repo_folder=/opt/tools/trans_test/ | local_folder=/tmp/opt/tools/ |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #get repository version number
    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
   # ${alias}   Get Unique ID
   # tafssh.Connect_To    hostname=${repo_ip}    username=${repo_username}    password=${repo_password}   alias=${alias}
    #${repo_version_file_name}   OperatingSystem.Join Path   ${repo_folder}   version.repo
    #${repo_version}   _Get Version Number Of Remote Repository   file_name=${repo_version_file_name}    connection=${alias}

    #get existence version number
#    ${alias_k8s_master}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
#
#    ${k8s_master_version_file_name}   OperatingSystem.Join Path   ${k8s_master_folder}   version.repo
#    ${k8s_version}   _Get Version Number Of Remote Interactively
#       ...   file_name=${k8s_master_version_file_name}   alias=${alias_k8s_master}
#
#    Return From Keyword If  ${k8s_version}>=${repo_version}   ${repo_version}

    #download to UTE
    #${local_folder}   Set Variable  ${k8s_master_folder}
    _Download File From Remote To Local   remote_ip=${repo_ip}
     ...   username=${repo_username}
     ...   password=${repo_password}
     ...   remote_folder=${repo_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${local_folder}
     ...   permission=777



_Copy Files From Repository To VCU Master Active Node
    [Arguments]   ${repo_folder}   ${k8s_master_folder}   ${gnb_index}=0
    [Documentation]    _Copy Files From Repository To VCU Master Active Node
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | repo_folder | Yes | repo_folder  |
    ...    | k8s_master_folder | Yes | k8s_master_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Copy Files From Repository To VCU Master Active Node | repo_folder=/opt/tools/trans_test/ | k8s_master_folder=/tmp/opt/tools/ |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #get repository version number
    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${repo_ip}    username=${repo_username}    password=${repo_password}   alias=${alias}
    ${repo_version_file_name}   OperatingSystem.Join Path   ${repo_folder}   version.repo
    ${repo_version}   _Get Version Number Of Remote Repository   file_name=${repo_version_file_name}    connection=${alias}

    #get existence version number
    ${alias_k8s_master}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}

    ${k8s_master_version_file_name}   OperatingSystem.Join Path   ${k8s_master_folder}   version.repo
    ${k8s_version}   _Get Version Number Of Remote Interactively
       ...   file_name=${k8s_master_version_file_name}   alias=${alias_k8s_master}

    Return From Keyword If  ${k8s_version}>=${repo_version}   ${repo_version}

    #download to UTE
    ${local_folder}   Set Variable  ${k8s_master_folder}
    _Download File From Remote To Local   remote_ip=${repo_ip}
     ...   username=${repo_username}
     ...   password=${repo_password}
     ...   remote_folder=${repo_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${local_folder}
     ...   permission=777


    #upload to K8s master
    ${vcu_k8s_master_ssh_connection_info}   Get VCU K8s Admin SSH Connection Info   gnb_index=${gnb_index}
    ${mast_node}  set variable   ${vcu_k8s_master_ssh_connection_info["addr"]}
    ${username}  set variable   ${vcu_k8s_master_ssh_connection_info["username"]}
    ${password}  set variable   ${vcu_k8s_master_ssh_connection_info["password"]}

    _Upload File From Local To Remote   remote_ip=${mast_node}
     ...   username=${username}
     ...   password=${password}
     ...   remote_folder=${k8s_master_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${k8s_master_folder}
     ...   permission=777

    [Return]  ${repo_version}


_Upload File From Work Node To Containers
    [Arguments]  ${ns}  ${pod_and_container_abbr_dict}   ${pod_detailed_info_dict}  ${pod_abbr}  ${para_tools_info}  #${work_node_ip}
    ...   ${connection}  ${vdu_index}=0
    #Currently it's in master node, not in work node!
    Log To Console  Tools: work node ---> containers

    ${alias_worknode}   Get Unique Id
    Connect To VDU Node  pod_abbr=${pod_abbr}  vdu_index=${vdu_index}   master_alias=${connection}   node_alias=${alias_worknode}

    ${full_pod_name}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["full_pod_name"]}
    ${containers}      Set Variable  ${pod_and_container_abbr_dict["${pod_abbr}"]}
    Should Be True  ${containers.__len__()}>0

    Log To Console  ${containers}
    # Currently it's in work node, not in master node!
    FOR   ${container}  IN   @{containers}
       _Upload File From Work Node To Container
          ...  ns=${ns}  full_pod_name=${full_pod_name}  container=${container}  para_tools_info=${para_tools_info}  connection=${alias_worknode}
    END


_Upload File From Work Node To Container
    [Arguments]  ${ns}  ${full_pod_name}   ${container}    ${para_tools_info}   ${connection}
    ${container_id}   Get Container ID From Docker Ps Command  ns=${ns}  full_pod_name=${full_pod_name}  container=${container}
     ...   connection=${connection}
    Should Not Be Empty   ${container_id}

    #tool
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_tool"]}   version.repo
    ${version_inside_container}   _Get Version Number Of Container
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  connection=${connection}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_TOOLS}
     ...   _Upload file from work node to container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_tool"]}
     ...   remote_folder_name=${para_tools_info["work_folder_tool"]}
     ...   connection=${connection}

    #data
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_data"]}   version.repo
    ${version_inside_container}   _Get Version Number Of Container
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  connection=${connection}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_DATA}
     ...  _Upload file from work node to container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_data"]}
     ...   remote_folder_name=${para_tools_info["work_folder_data"]}
     ...   connection=${connection}


_Upload File From Work Node To Container DO
    [Arguments]  ${container_id}   ${local_folder_name}    ${remote_folder_name}    ${connection}
    ${parent_path}  ${dummy}   Split Path  ${remote_folder_name}
    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=mkdir -p ${parent_path}    connection=${connection}
    ${sudo}  Get Sudo For VDU Node for Linux Command According TO Current User   connection=${connection}
    ${ssh_command}   Set Variable  ${sudo} docker cp ${local_folder_name} ${container_id}:${parent_path}
    ${out}  tafssh.Execute   command=${ssh_command}  connection=${connection}
    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=chmod 777 -R ${remote_folder_name}    connection=${connection}


Get Container ID From Docker Ps Command
    [Arguments]  ${ns}  ${full_pod_name}   ${container}   ${connection}
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${sudo}   Get Sudo For VDU Node for Linux Command According To Current User  connection=${connection}
    ${ssh_command}   Set Variable  ${sudo} docker ps |grep ${full_pod_name}_${ns} |grep k8s_${container}_ |awk '{print $1}'
    ${out}  tafssh.Execute  command=${ssh_command}  connection=${connection}
    ${container_id}   _Get Container ID From Content   out=${out}

    ${out}   Set Variable  ${out.strip()}
    Log To Console   ${container}:${container_id}
    [Return]  ${container_id}


Get Container ID From Docker Ps Command By POD Abbreviation Interactively
    [Arguments]  ${ns}  ${pod_abbr}   ${container}   ${alias}=default
    [Documentation]    Get Container ID From Docker Ps Command By POD Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | pod_abbr   | yes | pod_abbr |
    ...    | container  | yes | container_abbr |
    ...    | alias   | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    get container id from docker via 'docker ps' command through channel
    ...
    ...    Example
    ...    | ${out}  | Get Container ID From Docker Ps Command By POD Abbreviation Interactively | ns=default | pod_abbr=oam |
    ...    | ...     | container=oamfh | channel=12343abc |
    ...
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
    #${sudo}   Get Sudo Via Interactive SSH   alias=${alias}
    ${sudo}  Get Sudo For VDU Node for Linux Command According To Current User Interactively  alias=${alias}
    ${ssh_command}   Set Variable   ${sudo} docker ps |grep \\\\-${pod_abbr}\\\\-|grep ${ns} |grep k8s_${container}_ |awk '{print $1}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${alias}
    ${container_id}   _Get Container ID From Content   out=${out}

    ${out}   Set Variable  ${out.strip()}
    Log To Console   ${container}:${container_id}
    [Return]  ${container_id}


Docker Exec
    [Arguments]  ${ns}  ${full_pod_name}   ${container}   ${command}  ${connection}=default
    [Documentation]    Docker Exec
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | full_pod_name   | yes | full_pod_name |
    ...    | container  | yes | container_abbr |
    ...    | command   | yes | command, e.g, hostname, ifconfig f12 |
    ...    | connection   | no | connection, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | ${out}      | Docker Exec | ns=default | full_pod_name=hquvdu-aic-vdu-oamcp-deployment-0 |
    ...    | ...         | container=oamfh |  connection=default| command=ls /tmp |
    ...
    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${ssh_command}   Set Variable  docker ps |grep ${full_pod_name}_${ns} |grep k8s_${container}_ |awk '{print $1}'
    ${out}  tafssh.Execute  command=${ssh_command}  connection=${connection}
    ${container_id}   _Get Container ID From Content   out=${out}

    ${out}   Set Variable  ${out.strip()}
    Log To Console   ${container}:${container_id}

    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=${command}
        ...   connection=${connection}   wait_time=${wait_time}

    [Return]  ${out}


Docker Exec By Pod Abbreviation
    [Arguments]  ${ns}  ${pod_abbr}   ${container}   ${connection}  ${command}
    [Documentation]    Docker Exec By Pod Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | pod_abbr   | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container  | yes | container name, e.g, oam, oamfh,etc. |
    ...    | connection   | yes | connection, alias connection to K8s work node |
    ...    | command     | yes | command, e.g, hostname, ifconfig f12 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container by 'docker exec'
    ...
    ...    Example
    ...   | ${alias_master}     |  get unique id |
    ...   | ${alias_node}       |  get unique id |
    ...   | Connect To vDU Node | pod_abbr=oam | master_alias=${alias_master} | node_alias=${alias_node} |
    ...   | ${ns}               | Get vDU Namespace From TestLine |
    ...   | ${out}   | Docker Exec By Pod Abbreviation | ns=${ns} | pod_abbr=oam | container=oam | command=ifconfig | connection=${alias_node} |
    ...
    ${sudo}   Get Sudo For VDU Node for Linux Command According To Current User  connection=${connection}

    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${ssh_command}   Set Variable  ${sudo} docker ps |grep ${pod_abbr}\\\\-|grep ${ns} |grep k8s_${container}_ |awk '{print $1}'
    ${out}  tafssh.Execute  command=${ssh_command}  connection=${connection}
    ${container_id}   _Get Container ID From Content   out=${out}

    ${out}   Set Variable  ${out.strip()}
    Log To Console   container(${container}):${container_id}

    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=${command}
        ...   connection=${connection}

    [Return]  ${out}


Docker Exec By Container ID
    [Arguments]  ${container_id}   ${command}   ${connection}
    [Documentation]    Docker Exec By Container ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_id | Yes | container id, e.g, 0c0a2ea28714 |
    ...    | command  | yes | command, e.g, hostname, ifconfig f12 |
    ...    | connection | yes | connection |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | ${out}      | Docker Exec By Container ID |  container_id=0c0a2ea28714 | command=ifconfig oam3 | connection=${connection} |
    ...
    ${sudo}   Get Sudo For VDU Node for Linux Command According To Current User  connection=${connection}
    ${out}  tafssh.Execute  command=${sudo} docker exec -it ${container_id} ${command}  connection=${connection}
    [Return]  ${out}


Docker Exec By Container ID Interactively
    [Arguments]  ${container_id}   ${command}   ${alias}=default   ${bWriteBare}=${False}   ${check_result}=${True}
    [Documentation]    Docker Exec By Container ID Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_id | Yes | container id, e.g, 0c0a2ea28714 |
    ...    | command  | yes | command, e.g, hostname, ifconfig f12 |
    ...    | alias    | no | alias, default value is default |
    ...    | bWriteBare  | no | if ${True}, write command and return without match the prompt |
    ...    |             |   | if ${False}, write command and return with the condition of matching the prompt, default value is ${False} |

    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | ${out}      | Docker Exec By Container ID Interactively |  container_id=0c0a2ea28714 | command=ifconfig oam3 | alias=${alias} |
    ...
    ${sudo}   Get Sudo Via Interactive SSH   alias=${alias}
    ${out}   Run Keyword If   "${bWriteBare}"=="${True}"
      ...    _Docker Exec By Container ID Interactively Write Bare  container_id=${container_id}  command=${command}  alias=${alias}
    ...   ELSE
      ...    issh.Execute  command=${sudo} docker exec -it ${container_id} ${command}   check_result=${check_result}  alias=${alias}
    [Return]  ${out}


_Docker Exec By Container ID Interactively Write Bare
    [Arguments]  ${container_id}   ${command}   ${alias}=default
    #${sudo}   Get Sudo Via Interactive SSH   alias=${alias}
    ${sudo}   Get Sudo For VDU Node for Linux Command According To Current User Interactively  alias=${alias}
    issh.Execute Bare  command=${sudo} docker exec -it ${container_id} ${command}   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}
    [Return]  ${out}


_Get Container ID From Content
    [Arguments]  ${out}
    ${container_id}   Set Variable  ${EMPTY}
    ${lines}   Split To Lines   ${out}
    FOR  ${line}  IN  @{lines}
        ${line}   Set Variable  ${line.strip()}
        Continue For Loop If    ${line.__len__()}==0
        Continue For Loop If    """docker ps""" in """${line}"""
        Continue For Loop If    """awk""" in """${line}"""
        Continue For Loop If    """Last login""" in """${line}"""
        ${matches}   Get Regexp Matches  ${line}   ^([a-fA-F0-9]{12}).*  1
        ${container_id}   Set Variable If   ${matches}   ${matches[0]}
        Return From Keyword If     ${matches}   ${container_id}
    END

    Fail   No container id found:${out}


_Get Version Number Of Local
    [Arguments]    ${file_name}
    Process.Run Process    command=touch ${file_name}   shell=True
    ${run_code}  ${out}     Run And Return RC And Output   command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    Run Keyword If    """No such file or directory""" in """${out}"""    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote
    [Arguments]    ${file_name}   ${connection}=default
    ${out}   tafssh.Execute   command=touch ${file_name}   connection=${connection}
    ${out}   tafssh.Execute  command=cat ${file_name}   connection=${connection}

    Return From Keyword If    """No such file or directory""" in """${out}"""   0

    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote Repository
    [Arguments]    ${file_name}   ${connection}
    [Documentation]   _Get Version Number Of Remote Repository, here remote repository means original SSH server where tools are stored.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | file_name  | yes |file_name |
    ...
    ...    *RETURN VALUE*
    ...    version number in remote repository.
    ...
    ...    Example
    ...    | ${version} | _Get Version Number Of Remote Repository |  file_name=/opt/tools/trans_test/version.repo |
    ...
    ${out}   tafssh.Execute   command=ls ${file_name}    connection=${connection}
    Should Be True  """No such file""" not in """${out}"""
    ${out}   tafssh.Execute  command=cat ${file_name}     connection=${connection}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    Run Keyword If    """No such file or directory""" in """${out}"""    Fail   ${file_name}: does not exist!

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote Work Node
    [Arguments]   ${work_node_ip}  ${remote_version_file_name}   ${connection}
    ${base_ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    ${remote_ssh_command}  Set Variable  cat ${remote_version_file_name}
    ${out}   tafssh.Execute  command=${base_ssh_command} -C "${remote_ssh_command}"   connection=${connection}

    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${lines}   Split To Lines   ${out}
    ${version_num_line}  Set Variable  ${lines[-1]}
    ${version_num}  Set Variable  ${version_num_line.strip()}
    [Return]    ${version_num}


_Get Version Number Of Container
    [Arguments]   ${container_id}  ${remote_version_file_name}   ${connection}
    ${out}  Docker Exec By Container ID  container_id=${container_id}   command=ls -l ${remote_version_file_name}   connection=${connection}
    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${out}  Docker Exec By Container ID  container_id=${container_id}   command=cat ${remote_version_file_name}   connection=${connection}

    ${version_num}  Set Variable   ${out.strip()}
    [Return]    ${version_num}


_Get Version Number Of Remote Interactively
    [Arguments]    ${file_name}   ${alias}=default
    [Documentation]   _Get Version Number Of Remote Interactively
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | file_name | Yes | file_name  |
    ...    | alias | no | alias, default value is 'default'  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${out}   issh.Execute   command=touch ${file_name}   check_result=${False}  alias=${alias}
    ${out}   issh.Execute  command=cat ${file_name}  check_result=${False}   alias=${alias}
    ${out}   strip prompt  ${out}
    Return From Keyword If    """No such file or directory""" in """${out}"""   0

    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


Host Should Be Pingable
    [Arguments]  ${target_ip}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Check whether Host is Pingable or not from current running UTE server. If it's pingable, do nothing.
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2
    ...   sudo ping ${target_ip} -c 2

    ${alias}  get unique id
    connect to ute locally    alias=${alias}
    ${out}   issh.Execute   command=${cmd}   alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100


RU Should Be Pingable
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0    ${ru_index}=1   ${count}=3   ${alias}=default
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   RU Should Be Pingable
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | count            | No | count, default value is 3 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | alias            | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | RU Should Be Pingable |
    ...
    ${ru_ip}   Get Radio Unit Ip Address  ru_index=${ru_index}
    ${alias}  get unique id
    connect to ruproxy  gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}  alias=${alias}
    ${out}   issh.Execute  command=setcapability ping ${ru_ip} -c ${count}   alias=${alias}
    log to console  ${out}


Host Should Be Pingable From VDU Container
    [Arguments]  ${pod_abbr}   ${container}    ${network}   ${target}   ${count}=3   ${vdu_index}=0  ${connection}=default
    [Documentation]    Host Should Be Pingable From VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | target       | yes | target ip.  |
    ...    | count        | no |  the ping number, default is 3 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | Host Should Be Pingable From VDU Container | pod_abbr=oam | container=oam | network=oam | target=10.108.229.90 |
    ...   | Disconnect From K8s Master |
    ...
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}

    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    #${ip}  ${mask}   ${broadcast}   Get VDU Container Ip Address   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ${sudo}  Get VDU Container Sudo    pod_abbr=${pod_abbr}   container=${container}    vdu_index=${vdu_index}    connection=${connection}
    ${out}   Kubectl Exec    pod_abbr=${pod_abbr}   container=${container}    command=${sudo} ping ${target} -c ${count} -I ${oam_ifname}
    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100


Get VDU Container Sudo
    [Arguments]    ${pod_abbr}   ${container}    ${vdu_index}=0    ${connection}=default
    [Documentation]   if sudo is supported in container, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | alias        | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    return type is string, value is 'sudo' or ${EMPTY}
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${sudo} | Get VDU Container Sudo | pod_abbr=oam | container=oam |
    ...   | Disconnect From K8s Master |
    ...
    ${out}   Kubectl Exec    pod_abbr=${pod_abbr}   container=${container}    command=bash -c "sudo --help && echo CMD_SUCCESS"
       ...   connection=${connection}   vdu_index=${vdu_index}

    ${lines}    Split To Lines   ${out}
    ${result}   Set Variable  ${lines[-1]}
    ${result}   Set Variable  ${result.strip()}
    ${rtn}      Set Variable If  "${result}"=="CMD_SUCCESS"   sudo  ${EMPTY}
    [Return]  ${rtn}


Get VDU Container Interface Name
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}    ${network}=${EMPTY}    ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Interface Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up. If ${EMPTY}, will be fetched according container abbreviation |
    ...    | container    | no | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   interface name, e.g, f16, oam3, etc.
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${interface} | Get VDU Container Interface Name | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | container=aic-simu4trs | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...
    ${guest_vlan_flag}   Get Guest Vlan Flag   vdu_index=${vdu_index}
    ${ifname}   run keyword if  "${guest_vlan_flag}"=="${True}"   _Get VDU Container Interface Name Guest Vlan
    ...   pod_abbr=${pod_abbr}   container=${container}    network=${network}  vdu_index=${vdu_index}   connection=${connection}
    return from keyword if   "${guest_vlan_flag}"=="${True}"    ${ifname}

    #${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    #${pod_full_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}   connection=${connection}   vdu_index=${vdu_index}
    #${ns}   Get VDU Namespace From TestLine    vdu_index=${vdu_index}
    #${kubectl_cmd}  Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} --
    #${kubectl_cmd}  Set Variable  ${kubectl_cmd} bash -c "cat /proc/net/dev" | grep ${network}|cut -d ':' -f 1 | tr --delete [:space:]
    #${out}   tafssh.Execute    command=${kubectl_cmd}   connection=${connection}

    #${ifname}  Set Variable  ${out.strip()}
    #should not be empty   ${ifname}

    [Return]  ${ifname}


_Get VDU Container Interface Name Guest Vlan
    [Arguments]  ${pod_abbr}=${EMPTY}    ${container}=${EMPTY}    ${network}=${EMPTY}    ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Interface Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up. if ${EMPTY}, it will be fetched according to container abbreviation |
    ...    | container    | no | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   interface name, e.g, mcplane, fcplane, f1uplane, fhmplane, internal1, etc.
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...

    run keyword if   "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail  Please give pod_abbr for nwmgmt container!

    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"   get pod abbreviation by container abbreviation   container_abbr=${container}
    ...   ELSE  set variable   ${pod_abbr}

    #${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}  vdu_index=${vdu_index}

    ${tmp_network}   set variable   ${network}
    ${network}  run keyword if   'f1' in '''${network}'''   _Get Network Name For F1   pod_abbr=${pod_abbr}
    ...   ELSE IF   "${network}"=="fhm"   _Get Network Name For fhm   pod_abbr=${pod_abbr}
    ...   ELSE IF   "${network}"=="oam"   set variable   mcplane
    ...   ELSE IF   "${network}"=="tracing"   set variable   tcplane
    ...   ELSE   set variable  ${network}

     run keyword if   'f1' in '''${tmp_network}'''   return from keyword  ${network}
    ...   ELSE IF   "${tmp_network}"=="fhm"   return from keyword  ${network}
    ...   ELSE IF   "${tmp_network}"=="oam"   return from keyword  ${network}
    ...   ELSE IF   "${tmp_network}"=="tracing"   return from keyword  ${network}

    ${pod_full_name}   run keyword if  "${pod_abbr}"!="${EMPTY}"   Get Full Pod Name By Pod Abbreviation
    ...       pod_abbr=${pod_abbr}   connection=${connection}   vdu_index=${vdu_index}
    ...   ELSE   Get Full Pod Name By Container Abbreviation
    ...       container_abbr=${container}   connection=${connection}   vdu_index=${vdu_index}
    ${ns}   Get VDU Namespace From TestLine    vdu_index=${vdu_index}

    ${container_full_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}  vdu_index=${vdu_index}
    ${kubectl_cmd}  Set Variable  kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} --
    ${kubectl_cmd}  Set Variable  ${kubectl_cmd} bash -c "cat /proc/net/dev" | grep ${network}|cut -d ':' -f 1 | tr --delete [:space:]
    ${out}   tafssh.Execute    command=${kubectl_cmd}   connection=${connection}

    ${ifname}  Set Variable  ${out.strip()}
    [Return]  ${ifname}


_Get Network Name For F1
    [Arguments]  ${pod_abbr}
    ${F1_network_name}   run keyword if   "${pod_abbr}"=="up"    set variable  f1uplane
    ...   ELSE IF    "${pod_abbr}"=="cprt"   set variable   f1cplane
    ...   ELSE    Fail   unknown pod_abbr for F1 Network:${pod_abbr} !
    [Return]  ${F1_network_name}


_Get Network Name For fhm
    [Arguments]  ${pod_abbr}
    ${fhm_network_name}   run keyword if   "${pod_abbr}"=="oam"    set variable  fhmplane
    ...   ELSE    Fail   unknown pod_abbr for fhm Network:${pod_abbr} !
    [Return]  ${fhm_network_name}


Get VDU Container Ip Address
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${network}=${EMPTY}   ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up, default is ${EMPTY}, if is ${EMPTY}, will be fetched from container name |
    ...    | container    | no | container, e.g, oamfh, l2hi,default is ${EMPTY} |
    ...    | network      | no | network. e.g, internal, f1, oam, default is ${EMPTY} |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   ( ip address, mask, broadcast address), e.g, ("10.71.164.18", "255.255.255.0", "10.71.164.255")
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=cprt | network=f1 |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=fhm |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=internal |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=aic-simu4trs | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...   | Disconnect From K8s Master |
    ...
    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ...     vdu_index=${vdu_index}    connection=${connection}
    ${out}   Kubectl Exec   pod_abbr=${pod_abbr}   container=${container}   command=ifconfig ${oam_ifname}
    ...     vdu_index=${vdu_index}    connection=${connection}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    [Return]  ${ip}  ${mask}   ${broadcast}

Get VDU Container Ipv6 Address
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}    ${network}=${EMPTY}   ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   ( ipv6 address, prefixlen), e.g, ("1:1:1:1:1:1:1:1", "125")
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=oam |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=simu6trs | container=aic-simu6trs | network=oam |
    ...   | Disconnect From K8s Master |
    ...
    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ...     vdu_index=${vdu_index}    connection=${connection}
    ${out}   Kubectl Exec   pod_abbr=${pod_abbr}   container=${container}   command=ifconfig ${oam_ifname}
    ...     vdu_index=${vdu_index}    connection=${connection}

    ${ip}  ${prefixlen}   Parse Ipv6 Address From Ifconfig    content=${out}
    [Return]  ${ip}  ${prefixlen}

Get OAM Default Gateway By Additional Routing Table
    [Arguments]  ${ipversion}=4   ${connection}=default
    [Documentation]    Get VOAM Default Gateway By Additional Routing Table
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   oam network default gateway
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${oamgw} | Get OAM Default Gateway By Additional Routing Table | ipversion=4 | connection=default |
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route show table 2   ip -6 route show table 2
    ${out}   Kubectl Exec   pod_abbr=oam   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     .*default\\s+via\\s+(\\S+)\\s+dev\\s+\\S+.*   1
    ${gateway}   set variable   ${matches[0]}
    [Return]  ${gateway}

Get Pod Static Route Info via CLI
    [Arguments]  ${ipversion}=4   ${pod}=oamcp   ${ifname}=f1cplane  ${connection}=default
    [Documentation]    Get Pod Static Route Info via CLI
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | pod    | no | pod name abbr, default value is oamcp |
    ...    | ifname   | no | interface to check route, default value is f1cplane |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   OAMCP/UP pod certain interface route info
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${routeinfo} | Get Pod Static Route Info via CLI |ipversion=4|pod=oamcp|ifname=f1cplane|connection=default|
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route   ip -6 route
    ${out}   Kubectl Exec   pod_abbr=${pod}   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     (\\S+)\\s+via\\s+([0-9]\\S+)\\s+dev\\s+${ifname}.*  1  2
    Return From Keyword If     ${matches}     ${matches}
    [Return]    ${matches}

Get Pod Direct Route Info via CLI
    [Arguments]  ${ipversion}=4   ${pod}=oamcp   ${ifname}=f1cplane  ${connection}=default
    [Documentation]    Get Pod Direct Route Info via CLI
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | pod    | no | pod name abbr, default value is oamcp |
    ...    | ifname   | no | interface to check route, default value is f1cplane |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   OAMCP/UP pod certain interface route info
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${destip}   ${mask}   ${srcip} | Get Pod Direct Route Info via CLI |ipversion=4|pod=oamcp|ifname=f1cplane|connection=default|
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route   ip -6 route
    ${filter}   set variable if    '${ipversion}'=='4'   (\\S+)\\s+dev\\s+${ifname}\\s+proto\\s+kernel\\s+scope\\s+link\\s+src\\s+(\\S+).*
    ...   (\\S+)\\s+dev\\s+${ifname}\\s+proto\\s+kernel\\s+metric\\s+(\\S+)\\s+pref.*
    ${out}   Kubectl Exec   pod_abbr=${pod}   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     ${filter}  1   2
    ${destnet}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${destnetinfo}=   Split String   ${destnet}   /
    ${destip}   set variable  ${destnetinfo[0]}
    ${mask}    Set Variable   ${destnetinfo[1]}
    ${srcip_or_prefixlen}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    Return From Keyword If     ${matches}     ${destip}   ${mask}   ${srcip_or_prefixlen}
    [Return]    ${destip}   ${mask}   ${srcip_or_prefixlen}

Get Static Route Info WebEM
    [Arguments]   ${distname}   ${instancedn}
    [Documentation]    Get Static Route Info WebEM
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the configured static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | Get Static Route Info WebEM | distname=MRBTS-5318/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1 |
    ...    | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${destip_par}   set variable if  'IPRTV6' in '''${distname}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  'IPRTV6' in '''${distname}'''    destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  'IPRTV6' in '''${distname}'''    gatewayIpv6Addr   gateway
    ${sr_par}   set variable if  'IPRTV6' in '''${distname}'''    staticIpv6Routes   staticRoutes
    ${gwaddr}   scf.get_all_values_from_scf   dist_name=${distname}   p_name=${gw_par}
    ${route_len}   get length  ${gwaddr}
    VDU Rest Login
    FOR    ${i}    IN RANGE    0    ${route_len}
        ${gateway}   scf.get_value_from_scf   dist_name=${distname}   p_name=${gw_par}   index=${i}
        ${destip}   scf.get_value_from_scf   dist_name=${distname}   p_name=${destip_par}   index=${i}
        ${prefixlen}   scf.get_value_from_scf   dist_name=${distname}   p_name=${prefix_par}   index=${i}
        ${status}   ${tmppref}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${distname}   ${sr_par}/${i}/preference
        ${preference}   set variable if  '${status}'=='PASS'   ${tmppref}   1
        ${exist}   Static Route Exist In Forwarding Entries   gateway=${gateway}   dstip=${destip}
        ...  prefixlength=${prefixlen}   preferenceid=${preference}   instancedn=${instancedn}
        should be true  '${exist}'=='${True}'   Configured static route is not exist in forwarding entries!
    END

Static Route Exist In Forwarding Entries
    [Arguments]   ${gateway}   ${dstip}   ${prefixlength}   ${instancedn}    #${preferenceid}
    [Documentation]    Static Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Static route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Static Route Exist In Forwarding Entries | gateway=2a00:8a00:8000:117:1:2:a47:a651 |
    ...    |   dstip=:: | prefixlength=0 | preferenceid=1 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${gateway}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${gateway}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${gateway}'''   gatewayIpv6Addr   gateway
    ${v6gateway}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${gateway}   :0   :
    ${finalgateway}   set variable if  ':' in '''${gateway}'''   ${v6gateway}   ${gateway}
    ${v6dstip}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${gateway}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${prefix_par}   index=${i}
        ${status}   ${gw_fw}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/${gw_par}
        ${dest_gw1}   set variable if  '${status}'=='PASS'   ${gw_fw}   ${None}
        ${dest_gw2}   run keyword if  ':' in '''${dest_gw1}'''   Remove String Using Regexp   ${dest_gw1}   :0   :
        ${dest_gw}   set variable if  ':' in '''${dest_gw1}'''   ${dest_gw2}   ${dest_gw1}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'indirect' and '${dest_gw}' == '${finalgateway}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag3}=   Set Variable If   '${indexflag2}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
    #\    ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}' and '${preference_fw}' == '${preferenceid}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}'   ${True}   ${False}
       exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}

Direct Route Exist In Forwarding Entries
    [Arguments]   ${dstip}   ${prefixlength}    ${preference}   ${instancedn}
    [Documentation]    Direct Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given direct route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | dstip   | yes | the given direct route destination ip |
    ...    | prefixlength   | yes | the given direct route prefix length |
    ...    | preferenceid   | yes | the given direct route preference for ipv6 route or source ip for ipv4 route |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Direct route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=2a00:8a00:8000:117:1:2:a47:a650 |
    ...    | prefixlength=125 | preferenceid=256 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=10.71.177.72 |
    ...    | prefixlength=29 | preferenceid=10.71.177.74 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV4-1/IPRTV4_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${dstip}'''   destIpv6Addr   destIpAddr
    ${preference_par}   set variable if  ':' in '''${dstip}'''   preference   preSrcIpv4Addr
    ${prefix_par}   set variable if  ':' in '''${dstip}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${v6dstip}   run keyword if  ':' in '''${dstip}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${dstip}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${ipv4flag}   set variable if  ':' not in '''${dstip}'''   ${True}   ${False}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${prefix_par}   index=${i}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'direct' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
        ${preferenceflag}=   Set Variable If   '${ipv4flag}'=='${True}' or '${preference_fw}' == '${preference}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag2}'=='${True}' and '${preferenceflag}' == '${True}'   ${True}   ${False}
       exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}

String Should Be An Ip Address
    [Arguments]  ${content}
    [Documentation]    String Should Be An Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | String Should Be An Ip Address | 10.108.227.133 | \# keyword succeeds |
    ...    | String Should Be An Ip Address | 10.108.227.abc |  \# keyword fails |
    ...
    ${matches}    Get Regexp Matches    ${content}    ^(\\d+\\.\\d+\\.\\d+\\.\\d+)$   1
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    Should Not Be Empty  ${ip_addr}


Ip Address Comparison Should Be True
    [Arguments]  ${ip1}  ${ip2}   ${operator}=eq
    [Documentation]    Ip Address Comparison Should Be True
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ip1            | Yes |  ip address you want to increase eg, 10.107.63.206 |
    ...    | ip2            | Yes |  ip address you want to increase eg, 10.107.63.206 |
    ...    | operator       | no  | operator, eq:==, ge:>=, gt:>, le:<=, lt:<, ne:!=, default is eq |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.2 | operator=le |
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.1 | operator=eq |
    ...    | Ip Address Comparison Should Be True | 1.1.1.2 | 1.1.1.1 | operator=ge |
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.1 | operator=ge |
    ...
    ${operator}   Set Variable  ${operator.lower()}
    ${result}  Compare_Ip  ip1=${ip1}  ip2=${ip2}   operator=${operator}
    Should Be True  ${result}


Check Pattern Exist
    [Arguments]     ${content}    ${pattern}
    [Documentation]    Check Pattern Exist
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | text to be searched |
    ...    | pattern | Yes | pattern, it's a regexp |
    ...    *RETURN VALUE*
    ...    it returns 1 if pattern exists in content, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check Pattern Exist |  Machine Model.................................. QUANTA LB9  |  .*QUANTA LB9.* |
    ${bExist}    Set Variable    0
    @{lines}    Split To Lines    ${content}
    FOR   ${line}    IN   @{lines}
       ${line}   Set Variable  ${line.strip()}
       Continue For Loop If   ${line.__len__()}==0
       ${match}    Get Regexp Matches   ${line}    ${pattern}
       ${len}    Get Length    ${match}
       ${bExist}   Set Variable If    ${len}>0    1     0
       Exit For Loop If    ${bExist}==1
    END
    [Return]   ${bExist}


Get Local IPv6
    [Documentation]    get local eth0 interface of UTE server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    IP address of eth0
    ...
    ...    Example
    ...    | ${ipv6} | ${mask_len} | Get Local IPv6 |
    ...
    ${rtn}   ${ipv6}  ${mask_len}    _Get Local IPv6 By Interface    interface=eth0
    [Return]    ${ipv6}   ${mask_len}


_Get Local IPv6 By Interface
    [Arguments]    ${interface}=eth0
    [Documentation]    Get Local IPv6 By Interface
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | intf | optional | interface name of linux,default is eth0 |
    ...    *RETURN VALUE*
    ...    IP address of eth0
    ...
    ...    Example
    ...    | Get Local IPv6 by Interface |
    ...
    ${out}     OperatingSystem.Run    ip addr show ${interface}
    ${ipv6}  ${ipv6_mask_len}   Parse Ipv6 Address  ${out}
    ${rtn}    Set Variable If    ${ipv6.__len__()}>0   True   False
    [Return]   ${rtn}  ${ipv6}   ${ipv6_mask_len}


DSCP Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${dscp}=0   ${xml_file_name_prefix}=prefix  ${operator}=eq
    [Documentation]    DSCP Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.7.2020,chris.l.cao@nokia-sbell.com, add operator parameter
    ...    3.8.2020,hefeng-cookie.qu@nokia-sbell.com, update operator=eq
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | dscp            | yes | dscp |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | DSCP Number Should Be Right      | pcapfile=/tmp/a.pcap | filter=${filter} | dscp=46 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_dscp_num_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=ip.dsfield.dscp   attrib_name=show   attrib_value=${dscp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=ip.dsfield.dscp   attrib_name=showname

    ${length}  Get Length    ${showname}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


DSCP Number Should Be Right Ipv6
    [Arguments]  ${pcapfile}   ${filter}   ${expected_number}=0   ${dscp}=0   ${xml_file_name_prefix}=prefix    ${operator}=eq
    [Documentation]    DSCP Number Should Be Right Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.7.2020,chris.l.cao@nokia-sbell.com, add operator parameter
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | dscp            | yes | dscp |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmpv6 and ipv6.src==2a::2 and ipv6.dst==2a::1 |
    ...  | DSCP Number Should Be Right Ipv6 | pcapfile=/tmp/a.pcap | filter=${filter} | dscp=46 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_dscp_num_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}   filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=ipv6.tclass.dscp   attrib_name=show   attrib_value=${dscp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=ipv6.tclass.dscp   attrib_name=showname

    ${length}  Get Length    ${showname}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


VLAN PCP Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}    ${vlanpcp}=2  ${vlanid}=295  ${xml_file_name_prefix}=prefix
    [Documentation]    VLAN ID AND PCP Should Be Right
    ...    *AUTHOR* hefeng-cookie.qu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    17.9.2020,hefeng-cookie.qu@nokia-sbell.com, add
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | vlan            | yes | vlan |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | VLAN PCP Should Be Right     | pcapfile=/tmp/a.pcap | filter=${filter} | vlanid=295 | vlanpcp=7 |
    ...  | ...                               |  xml_file_name_prefix=Step5 |


    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_vlan_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}   max_count=50
    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=vlan.priority   attrib_name=show   attrib_value=${vlanpcp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=vlan.priority   attrib_name=showname
    ${length}  Get Length    ${showname}
    Should Be True   ${length}>0

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=vlan.id   attrib_name=show   attrib_value=${vlanid}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=vlan.priority   attrib_name=showname
    ${length}  Get Length    ${showname}
    Should Be True   ${length}>0


Payload Size Number Should Be Right Ipv6
    [Arguments]  ${pcapfile}   ${filter}   ${expected_number}   ${size}   ${xml_file_name_prefix}=prefix
    [Documentation]    Payload Size Number Should Be Right Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | size            | yes | size |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmpv6 and ipv6.src==2a::1 and ipv6.dst==2a::2 |
    ...  | Payload Size Number Should Be Right Ipv6 | pcapfile=/tmp/a.pcap | filter=${filter} | size=16 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_payload_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}   filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=data.len   attrib_name=show   attrib_value=${size}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=data.len   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


ICMP Request Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${xml_file_name_prefix}=prefix
    [Documentation]    ICMP Request Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | ICMP Request Number Should Be Right | pcapfile=/tmp/a.pcap | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...  | ICMP Request Number Should Be Right | pcapfile=/tmp/a.pcap | filter=${filter} | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_icmp_req_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=8
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


ICMP Reply Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${xml_file_name_prefix}=prefix
    [Documentation]    ICMP Reply Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | ICMP Reply Number Should Be Right | pcapfile=/tmp/a.pcap | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...  | ICMP Reply Number Should Be Right | pcapfile=/tmp/a.pcap | filter=${filter} | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_icmp_rep_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=0
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


Packets Number Should Be Right
    [Arguments]  ${pcapfile}  ${field_name}   ${attrib_name}   ${attrib_value}  ${filter}=${EMPTY}   ${expected_number}=0
      ...   ${xml_file_name_prefix}=prefix   ${operator}=eq
    [Documentation]    Packets Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | field_name       | yes | field_name, e.g, icmp.type, vlan.id, data.len, etc. |
    ...    | attrib_name      | yes | attrib_name, e.g show, value, showname, size, pos etc. |
    ...    | attrib_alue      | yes | attrib_alue, it's the value of attrib_name |
    ...    | filter          | no | filter, default is empty |
    ...    | expected_number | no | expected_number, default is 0 |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix, default is prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
   ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=vlan.etype | attrib_name=value | attrib_value=88cc | expected_number=5 |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
    ...  | ... | operator=eq |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
    ...  | ... | filter=${filter} | operator=gt | xml_file_name_prefix=step4 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=${field_name}   attrib_name=${attrib_name}   attrib_value=${attrib_value}
    ${attrib_name_list}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=${field_name}   attrib_name=${attrib_name}

    ${length}  Get Length    ${attrib_name_list}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


Get Unique ID
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}   ${precise}=HIGH
    [Documentation]   Get Unique ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    03.30.2021,luofei.tu@nokia-sbell.com, add to support precise=FORMAT_DATETIME
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | prefix       | no | prefix, default is ${EMTPY} |
    ...    | suffix       | no | suffix, default is ${EMTPY} |
    ...    | precise      | no | precise, HIGH or LOW, default is HIGH |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${tmp_id} | Get Unique ID |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix |
    ...  | ${tmp_id} | Get Unique ID | prefix=myprefix | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH |
    ...  | ${tmp_id} | Get Unique ID | precise=LOW |
    ...  | ${tmp_id} | Get Unique ID | precise=FORMAT_DATETIME |
    ...  | ${tmp_id} | Get Unique ID | precise=HIGH_WITH_FORMAT_DATETIME_EPOCH |
    ...
    ${precise}  Set Variable  ${precise.upper()}
    ${rtn}  Run Keyword If  "${precise}"=="HIGH"  _Get Unique ID High Precise  prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF  "${precise}"=="LOW"    _Get Unique ID LOW Precise   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="FORMAT_DATETIME"   _Get Unique ID Format Datetime   prefix=${prefix}   suffix=${suffix}
    ...   ELSE IF   "${precise}"=="HIGH_WITH_FORMAT_DATETIME_EPOCH"
                 ...   _Get Unique ID Format High Precise Plus Datetime Epoch   prefix=${prefix}   suffix=${suffix}
    [Return]    ${rtn}


_Get Unique ID High Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id}    String.Replace String    ${unique_id}    -    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID LOW Precise
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id}    Evaluate    str(time.time())    modules=time
    ${unique_id}    String.Replace String    ${unique_id}    .    ${EMPTY}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format Datetime
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id_part2}    Evaluate     str(time.time())    modules=time
    ${unique_id_part2}   set variable  ${unique_id_part2.split(".")[-1]}

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}


_Get Unique ID Format High Precise Plus Datetime Epoch
    [Arguments]  ${prefix}=${EMPTY}   ${suffix}=${EMPTY}
    ${unique_id_part1}    Evaluate    str(uuid.uuid4())    modules=uuid
    ${unique_id_part1}    String.Replace String    ${unique_id_part1}    -    ${EMPTY}

    ${unique_id_part2}    Evaluate    time.strftime("%Y%m%d_%H%M%S", time.localtime())    modules=time

    ${unique_id}    set variable   ${unique_id_part1}_${unique_id_part2}
    [Return]    ${prefix}${unique_id}${suffix}


Two Numbers Substraction Should Be
    [Arguments]  ${number1}   ${number2}  ${op}=le  ${delta}=0
    [Documentation]    Two Numbers Substraction Should Be Less Than
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | number1         | yes | number1  |
    ...    | number2         | yes | number2 |
    ...    | op              | no | operator, le/lt/gt/ge/eq, le is <=, lt is <, gt is >, ge is >=, eq is =, default is le|
    ...    | delta           | no | delta value, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  |  # keyword executes successfully |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=le | delta=10 |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=ge | delta=5 |
    ...  |  # keyword executes unsuccessfully |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=le | delta=20 |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=ge | delta=15 |
    ...
    ${number1}  Set Variable  ${number1.strip()}
    ${number2}  Set Variable  ${number2.strip()}
    ${diff}  Evaluate  abs(int(float('${number1}'))-int(float('${number2}')))
    Run Keyword If   "${op}"=="le"  Should Be True  ${diff}<=${delta}
    ...   ELSE IF  "${op}"=="lt"  Should Be True  ${diff}<${delta}
    ...   ELSE IF  "${op}"=="ge"  Should Be True  ${diff}>=${delta}
    ...   ELSE IF  "${op}"=="gt"  Should Be True  ${diff}>${delta}
    ...   ELSE IF  "${op}"=="eq"  Should Be True  ${diff}==${delta}
    ...   ELSE     Fail   Unknown parameter op:${op}


Start Simu4trs Pod
    [Arguments]  ${vdu_index}=0
    [Documentation]    Start Simu4trs Pod
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index     | no | vdu_index |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | Start Simu4trs Pod    |
    ...   | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=simu4trs |
    ...   | ${out}           | Kubectl Exec | pod_abbr=simu4trs | container=aic-simu4trs | command=ping 10.71.164.18 -I oam3 -c 3 |
    ...   | Stop Simu4trs Pod |
    ...   | Disconnect From K8s Master |
    ...
    ${ns}   Get VDU Namespace From TestLine   vdu_index=${vdu_index}
    ${dep_path}   OperatingSystem.Join Path  ${TOOLS_INFO["work_folder_simu4trs"]}   ${TOOLS_INFO["dep_simu4trs"]}
    ${load_img_path}   OperatingSystem.Join Path  ${TOOLS_INFO["work_folder_simu4trs"]}   ${TOOLS_INFO["load_simu4trs_img"]}
    ${alias}   Get Unique ID

    Upload Simu4trs Image To K8s Master   vdu_index=${vdu_index}
    Run Keyword And Ignore Error  Stop Simu4trs Pod  vdu_index=${vdu_index}

    Connect To K8s Master  alias=${alias}  vdu_index=${vdu_index}

    ${command}  Set Variable   ${dep_path} -t QUERY -n ${ns}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}
    Should Contain  ${out}   simu4trs pod not exists

    ${command}  Set Variable   ${load_img_path}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}

    ${command}  Set Variable   ${dep_path} -t ADD -n ${ns}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}
    Should Contain  ${out}   pod:simu4trs creation: SUCCESS

    ${command}  Set Variable   ${dep_path} -t QUERY -n ${ns}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}
    Should Contain  ${out}   single simu4trs pod exists, status:OK


Stop Simu4trs Pod
    [Arguments]  ${vdu_index}=0
    [Documentation]    Stop Simu4trs Pod
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index     | no | vdu_index |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | Start Simu4trs Pod    |
    ...   | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=simu4trs |
    ...   | ${out}           | Kubectl Exec | pod_abbr=simu4trs | container=aic-simu4trs | command=ping 10.71.164.18 -I oam3 -c 3 |
    ...   | Stop Simu4trs Pod |
    ...   | Disconnect From K8s Master |
    ...
    ${ns}   Get VDU Namespace From TestLine   vdu_index=${vdu_index}
    ${alias}   Get Unique ID
    Connect To K8s Master  alias=${alias}  vdu_index=${vdu_index}
    ${dep_path}   OperatingSystem.Join Path  ${TOOLS_INFO["work_folder_simu4trs"]}   ${TOOLS_INFO["dep_simu4trs"]}
    ${command}  Set Variable   ${dep_path} -t DEL -n ${ns}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}
    Should Contain  ${out}   pod:simu4trs is deleted.

    ${command}  Set Variable   ${dep_path} -t QUERY -n ${ns}
    ${out}   tafssh.Execute   command=${command}  connection=${alias}
    Should Contain  ${out}   simu4trs pod not exists


Connect To VDU Switch
    [Arguments]  ${switch_index}=0
    [Documentation]  Connect To VDU Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_index     | no. | switch_index, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...
    ${conn}  Connect To Switch   switch_ip=${TRANS_PARA["du_switch"][${switch_index}]["du_switch_ip"]}
    ...   switch_user=${TRANS_PARA["du_switch"][${switch_index}]["username"]}
    ...   switch_password=${TRANS_PARA["du_switch"][${switch_index}]["password"]}
    ...   switch_en_password=${TRANS_PARA["du_switch"][${switch_index}]["en_password"]}
    ...   port=${TRANS_PARA["du_switch"][${switch_index}]["port"]}
    [Return]  ${conn}


Connect To Switch
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=15
    [Documentation]  Connect To Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip       | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user     | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...    Example
    ...    | ${conn1}  | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | # multiple Switch Connections |
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${conn2} | Connect To Switch | switch_ip=2.2.2.2 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | conn=${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | Close All Switch Connections |
    ...
    ${conn}  Wait Until Keyword Succeeds   1x   5s   _Connect To Switch One Time
    ...    switch_ip=${switch_ip}    switch_user=${switch_user}    switch_password=${switch_password}  switch_en_password=${switch_en_password}
    ...   port=${port}   prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}   timeout=${timeout}

    [Return]  ${conn}


_Connect To Switch One Time
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=300
    [Documentation]  _Connect To Switch One Time
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip     | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...
    ${conn}  Telnet.Open Connection    host=${switch_ip}   port=${port}      timeout=${timeout}
    ${dummy}   Telnet.Read Until Regexp     ogin:     ser:
    ${out}   Telnet.Write    ${switch_user}
    ${dummy}   Telnet.Read Until     expected=assword:
    ${out}  Telnet.Write    ${switch_password}

    #if no 'enable password', return directly
    Run Keyword If  '${switch_en_password}'==''   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}
    ${out}  Run Keyword If  '${switch_en_password}'==''   Telnet.Read Until Prompt
    Return From Keyword If  '${switch_en_password}'==''    ${conn}

    #if has 'enable password', enter it
    ${dummy}   Telnet.Read Until     expected=>
    ${dummy}   Telnet.Set Prompt  prompt=assword:
    Telnet.Write    enable
    ${dummy}   Telnet.Read Until     expected=assword:
    ${dummy}   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}

    ${out}     Telnet.Write    ${switch_en_password}
    ${dummy}   Telnet.Read Until Prompt

    [Return]  ${conn}

Connect To VDU Switch Via SSH
    [Arguments]    ${alias}=default   ${timeout}=15
    [Documentation]  Connect To Switch Via SSH
    ...    *AUTHOR* zhiqiang.q2.liu
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...    Example
    ...    | ${conn1}  | Connect To Switch Via SSH |
    ...
    ${switch_IP}  Set Variable  ${TRANS_PARA["du_switch"][0]["du_switch_ip"]}
    ${switch_user}  Set Variable  ${TRANS_PARA["du_switch"][0]["username"]}
    ${switch_passwd}  Set Variable  ${TRANS_PARA["du_switch"][0]["password"]}
    ${switch_prompt}  Set Variable  ${TRANS_PARA["du_switch"][0]["prompt"]}
    ${alias}  issh.connect_to  ip=${switch_IP}  port=22  username=${switch_user}  password=${switch_passwd}  prompt=${switch_prompt}
    ...    timeout=${timeout}

    [Return]  ${alias}

Close Switch Connection
    [Arguments]  ${conn}=${EMPTY}
    [Documentation]  Close Switch Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | conn     | Yes. | switch connection to be closed  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    | ${conn1}  | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | Close Switch Connection |
    ...
    ${old_conn}  Run Keyword If  "${conn}"!="${EMPTY}"   Telnet.Switch Connection   index_or_alias=${conn}
    Telnet.Close Connection
    Run Keyword If   "${conn}"!="${EMPTY}"   Run Keyword And Ignore Error  Telnet.Switch Connection   index_or_alias=${old_conn}



Close All Switch Connections
    [Documentation]  Close Switch Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | conn     | Yes. | switch connection to be closed  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | # multiple Switch Connections |
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${conn2} | Connect To Switch | switch_ip=2.2.2.2 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | conn=${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | ${old_conn} | Switch Switch Connection | conn=${conn2} |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/26 | vlanID=4 |
    ...    | Close All Switch Connections |
    ...
    Telnet.Close All Connections


Show Switch Version Information
    [Documentation]  Show Switch Version Information
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    swith version information
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${version_info} | Show Switch Version Information |
    ...
    ${old_prompt}   Telnet.Set Prompt  prompt=#|\\(q\\)uit   prompt_is_regexp=True
    Telnet.Write  text=show version
    ${out}   Telnet.Read Until Prompt
    Run Keyword If  """(q)uit""" in """${out}"""   Telnet.Write   text=q
    ${dummy}   Run Keyword If   """(q)uit""" in """${out}"""   Telnet.Read Until Prompt
    Telnet.Set Prompt  prompt=${old_prompt[0]}   prompt_is_regexp=False
    [Return]   ${out}


Get Switch Vendor
    [Documentation]  Get Switch Vendor
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Return type is string, return value will be swtich vendor, e.g, QUANTA, DELL
    ...
    ...    Example
    ...    | ${switch_vendor} | Get Switch Vendor |
    ${out}    Show Switch Version Information

    #check QUANTA
    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*QUANTA.*
    Return From Keyword If    ${bExist}==1   QUANTA

    #check Dell
    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*Dell Operating System.*
    Return From Keyword If    ${bExist}==1   DELL

    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*S[3-4]048-ON.*
    Return From Keyword If    ${bExist}==1   DELL

    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*Z9100-ON.*
    Return From Keyword If    ${bExist}==1   DELL

    ${vendor}    Set Variable    UNKNOWN
    Fail   Switch vendor should not be UNKNOWN!!!!

    [Return]   ${vendor}


Query Switch VLAN Tag Setting
    [Arguments]  ${interface}   ${vlanID}
    [Documentation]  Query Switch VLAN Tag Setting
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | vlanID   | yes | vlanid, e.g, 2, 3 |
    ...    None
    ...    *RETURN VALUE*
    ...    Return yes if it exists, otherwise return no
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Query Switch VLAN Tag Setting For GUANTA
       ...   interface=${interface}   vlanID=${vlanID}
    ...   ELSE IF  '${vendor}'=='DELL'  _Query Switch VLAN Tag Setting for DELL
       ...   interface=${interface}   vlanID=${vlanID}

    [Return]  ${rtn}


_Query Switch VLAN Tag Setting For GUANTA
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=show run interface ${interface}
    ${pattern}  Set Variable  switchport tagging ${vlanID}
    ${bExist}    Check Pattern Exist    content=${out}     pattern=\\s*${pattern}\\s*
    ${rtn}   Set Variable If  ${bExist}==1   yes    no
    [Return]  ${rtn}


_Query Switch VLAN Tag Setting For DELL
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=sh run interface vlan ${vlanID} | grep tagged
    ${out}   Set Variable  ${out.splitlines()}
    ${len}    Get Length    ${out}
    Return From Keyword If    ${len}<=1    no
    ${out}  Set Variable   ${out[0]}

    ${out}    Strip String    ${out}
    ${out_list}    Split String    ${out}    ${SPACE}
    ${tag_info}    Set Variable    ${out_list[2]}
    ${tag_list}    Split String    ${tag_info}    ,
    ${port_list}    Create List
    FOR    ${section}    IN    @{tag_list}
        Log To Console    ${section}
        Run Keyword If    "-" not in "${section}"    Append To List    ${port_list}    ${section}
        Continue For Loop If    "-" not in "${section}"
        ${tmp_list}    Get Port List    section=${section}
        ${port_list}    Combine Lists    ${port_list}    ${tmp_list}
    END

    ${found}    Get Index From List    ${port_list}    ${interface}
    ${rtn}    Set Variable If    ${found}!=-1    yes    no
    [Return]  ${rtn}


Set Switch ACL
    [Arguments]   ${interface}  ${peer_ip}   ${local_ip}    ${protocol_number}   ${acl_number}   ${direction}
    [Documentation]  Set Switch ACL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | peer_ip |  yes | peer_ip |
    ...    | local_ip |  yes | local_ip |
    ...    | protocol_number |  yes | protocol number, e.g, 132 for sctp, 6 for tcp, 17 for udp  |
    ...    | acl_number      |  yes | acl_number |
    ...    | direction      |  yes | direction |
    ...
    ...    *RETURN VALUE*
    ...    OK or ${None}. OK if successfully set ACL, otherwise return ${None}
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | Set Switch ACL | interface=1/1/2 | peer_ip=3.3.3.3 | local_ip=2.2.2.2 | protocol_number=132 | acl_number=188 |
    ...    | ... | direction=in |
    ...    | ${result} | Clear Switch ACL | interface=1/1/2 | acl_number=${acl_number} | direction=in |
    ...
    ${vendor}  Get Switch Vendor
    ${result}   Run Keyword If  '${vendor}'=='QUANTA'  _Set Switch ACL For GUANTA
       ...  interface=${interface}  peer_ip=${peer_ip}  local_ip=${local_ip}  protocol_number=${protocol_number}
       ...   acl_number=${acl_number}  direction=${direction}
    ...  ELSE IF  '${vendor}'=='DELL'  _Set Switch ACL for DELL
       ...  interface=${interface}  peer_ip=${peer_ip}  local_ip=${local_ip}  protocol_number=${protocol_number}
       ...  acl_number=${acl_number}   direction=${direction}

    [Return]  ${result}


_Set Switch ACL For GUANTA
    [Arguments]   ${interface}   ${peer_ip}   ${local_ip}    ${protocol_number}   ${acl_number}   ${direction}
    Return From Keyword If   '${interface}'=='${EMPTY}'
    Log To Console  acl_number:${acl_number}
    _Clear Switch ACL For GUANTA   interface=${interface}    acl_number=${acl_number}  direction=${direction}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=access-list ${acl_number} deny ${protocol_number} ${peer_ip} 0.0.0.0 ${local_ip} 0.0.0.0
    ${out}   Telnet.Execute Command  command=access-list ${acl_number} permit every
    ${out}   Telnet.Execute Command  command=interface ${interface}
    ${out}   Telnet.Execute Command  command=ip access-group ${acl_number} ${direction}
    ${out}   Telnet.Execute Command  command=exit
    [Return]  OK


_Set Switch ACL For DELL
    [Arguments]   ${interface}   ${peer_ip}   ${local_ip}   ${protocol_number}   ${acl_number}  ${direction}
    Return From Keyword If   '${interface}'=='${EMPTY}'
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    Log To Console  set acl_group:${acl_group}
    ${interface_type}   _Get Switch Interface Type DELL  ${interface}
    _Clear Switch ACL For DELL    interface=${interface}    acl_number=${acl_number}  direction=${direction}

    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=ip access-list extended ${acl_group}
    ${out}   Telnet.Execute Command  command=deny ${protocol_number} ${local_ip} 255.255.255.255 ${peer_ip} 255.255.255.255
    ${out}   Telnet.Execute Command  command=permit ip any any
    ${out}   Telnet.Execute Command  command=exit
    ${out}   Telnet.Execute Command  command=int ${interface_type} ${interface}
    ${out}   Telnet.Execute Command  command=ip access-group ${acl_group} ${direction}
    ${out}   Telnet.Execute Command  command=end
    [Return]  OK


_Get Dell ACL Group
    [Arguments]  ${acl_number}
    ${acl_group}   Set Variable   acl_aic_ta_${acl_number}
    [Return]   ${acl_group}


Clear Switch ACL
    [Arguments]   ${interface}   ${acl_number}    ${direction}
    [Documentation]  Clear Switch ACL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface        | yes | interface |
    ...    | acl_number     | yes | acl_number, it's defined in __init__.py  |
    ...    | direction      | yes | direction |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | Set Switch ACL | interface=1/1/2 | peer_ip=3.3.3.3 | local_ip=2.2.2.2 | protocol_number=132 | acl_number=188 |
    ...    | ... | direction=in |
    ...    | ${result} | Clear Switch ACL | interface=1/1/2 | acl_number=${acl_number} | direction=in |
    ...
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Clear Switch ACL For GUANTA
       ...   interface=${interface}    acl_number=${acl_number}   direction=${direction}
    ...   ELSE IF  '${vendor}'=='DELL'  _Clear Switch ACL for DELL
       ...   interface=${interface}    acl_number=${acl_number}     direction=${direction}

    [Return]  ${rtn}


_Clear Switch ACL For GUANTA
    [Arguments]   ${interface}    ${acl_number}   ${direction}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=interface ${interface}
    ${out}   Telnet.Execute Command  command=no ip access-group ${acl_number} ${direction}
    ${out}   Telnet.Execute Command  command=exit
    ${out}   Telnet.Execute Command  command=no access-list ${acl_number}
    ${out}   Telnet.Execute Command  command=exit


_Clear Switch ACL For DELL
    [Arguments]   ${interface}   ${acl_number}   ${direction}
    [Teardown]    Telnet.Execute Command  command=end
    Return From Keyword If   '${interface}'=='${EMPTY}'
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    Log To Console  clear acl_group:${acl_group}
    ${interface_type}  _Get Switch Interface Type DELL   ${interface}
    _Clear Switch Access Group For DELL   acl_number=${acl_number}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=no ip access-list extended acl_group
    ${out}   Telnet.Execute Command  command=int ${interface_type} ${interface}
    ${out}   Telnet.Execute Command  command=no ip access-group ${acl_group} ${direction}


_Clear Switch Access Group For DELL
    [Arguments]   ${acl_number}
    [Teardown]     Telnet.Execute Command  command=end
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=ip access-list extended ${acl_group}
    ${out}   Telnet.Execute Command  command=show config
    ${lines}  Split To Lines    ${out}
    Remove From List  ${lines}  0
    Remove From List  ${lines}  0
    FOR  ${line}  IN  @{lines}
        Exit For Loop If  ${line.endswith('#')}
        ${seq_num}    Set Variable  ${line.split()[1]}
        ${out}   Telnet.Execute Command   command=no seq ${seq_num}
    END


Get Switch Interface Type
    [Arguments]  ${interface}
    [Documentation]  Get Switch Interface Type
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    None
    ...    *RETURN VALUE*
    ...    Return interface type if it's DELL brand switch, e.g, twentyFiveGigE. Otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} |Get Switch Interface Type | interface=1/1/1 |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  Set Variable   ${EMPTY}
    ...   ELSE IF  '${vendor}'=='DELL'  _Get Switch Interface Type DELL
       ...   interface=${interface}

    [Return]  ${rtn}


_Get Switch Interface Type DELL
    [Arguments]  ${interface}
    [Documentation]   _Get Switch Interface Type DELL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface      | yes | interface |
    ...
    ...    *RETURN VALUE*
    ...    interface type, e.g, twentyFiveGigE
    ...
    ...    Example
    ...    | ${interface_type} | _Get Switch Interface Type DELL | 1/1/1 |
    ...
    ${out}   Telnet.Execute Command  command=show interfaces description|grep ${interface}
    ${lines}  Split To Lines   ${out}
    Remove From List   ${lines}  -1
    Should Be True  ${lines.__len__()}==1
    ${interface_type}   Set Variable  ${lines[0].split()[0]}
    [Return]  ${interface_type}


Clear ACL Config For VDU TOR
    [Teardown]  Run Keyword If    """${TRANS_PARA}"""!="""${NONE}"""   Run Keyword And Ignore Error  Close Switch Connection
    [Documentation]  Clear ACL Config For VDU TOR
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Clear ACL Config For VDU TOR |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""

    ${result}   ${acl_number}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["acl_number"]}
    Return From Keyword If  """${result}"""=="""FAIL"""
    ${acl_number}  Set Variable  ${acl_number.strip()}
    Return From Keyword If  ${acl_number.__len__()}==0

    ${result}   ${interface}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["switch_interface"]}
    Return From Keyword If  """${result}"""=="""FAIL"""
    ${interface}  Set Variable  ${interface.strip()}

    #${result}   ${interface_type}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["switch_interface_type"]}
    #Return From Keyword If  """${result}"""=="""FAIL"""
    #${interface_type}  Set Variable  ${interface_type.strip()}

    Connect To Vdu Switch
    Log To Console  Clear Switch ACL for direction:in
    Clear Switch ACL   interface=${interface}    acl_number=${acl_number}   direction=in

    Log To Console  Clear Switch ACL for direction:out
    Clear Switch ACL   interface=${interface}    acl_number=${acl_number}   direction=out


Get Host Name
    [Arguments]  ${alias}=default
    ${out}   issh.Execute   command=hostname   alias=${alias}
    ${lines}  Split To Lines  ${out}
    ${hostname}   Set Variable   ${lines[1].strip()}
    [Return]  ${hostname}


Strip Prompt
    [Arguments]  ${content}  ${remove_last_line}=${True}   ${remove_first_line}=${True}  ${return_list}=${False}
    [Documentation]  Strip Prompt according to different host type
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | content        | yes | content to be striped |
    ...    | remove_last_line  | no | remove_last_line,remove last line if true, else do not remove last line, default is True |
    ...    | remove_first_line | no | skip_first_line, remove first line if true, else do not remove first line, default is True |
    ...    | return_list       | no | if yes, return list, otherwise return string|
    ...
    ...    *RETURN VALUE*
    ...    list or string
    ...
    ...    Example
    ...    | connect to fhgw |
    ...    | ${out}          | issh.Execute | command=hostname |
    ...    | ${out}          | Strip Prompt | content=${out} |
    ...    | Disconnect Interactive Connection |
    ...
    ${lines}   Split To Lines  ${content}

    #process skip_first_line line
    Run Keyword If   ${lines.__len__()}>=1 and "${remove_first_line}"=="${True}"   Remove From List  ${lines}   index=0

    #process last line
    Run Keyword If   ${lines.__len__()}>=1 and "${remove_last_line}"=="${True}"   Remove From List  ${lines}   index=-1

    Return From Keyword If   "${return_list}"=="${True}"    ${lines}
    ${rtn}  Evaluate  "\\r\\n".join(${lines})
    [Return]   ${rtn}


Strip Last Line
    [Arguments]  ${content}    ${return_list}=${False}
    [Documentation]  Strip Last Line for content
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | content        | yes | content to be striped |
    ...    | return_list       | no | if yes, return list, otherwise return string|
    ...
    ...    *RETURN VALUE*
    ...    list or string
    ...
    ...    Example
    ...    | connect to fhgw |
    ...    | ${out}          | issh.Execute | command=hostname |
    ...    | ${out}          | Strip Last Line | content=${out} |
    ...    | Disconnect Interactive Connection |
    ...
    ${lines}   Split To Lines  ${content}
    Run Keyword If   ${lines.__len__()}>=1    Remove From List  ${lines}   index=-1
    Return From Keyword If   "${return_list}"=="${True}"    ${lines}
    ${rtn}  Evaluate  "\\r\\n".join(${lines})
    [Return]   ${rtn}


VDU Restart Container
    [Arguments]  ${pod_abbr}   ${container}    ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]    VDU Restart Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | VDU Restart Container| pod_abbr=oam | container=oamfh |
    ...
    ${alias}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}

    ${ns}   Get VDU Namespace From TestLine    vdu_index=${vdu_index}
    ${container_id}   Get Container ID From Docker Ps Command By POD Abbreviation Interactively    ns=${ns}
    ...     pod_abbr=${pod_abbr}    container=${container}    alias=${alias}
    ${cmd}   Set Variable  docker restart ${container_id}
    issh.Execute    ${cmd}   alias=${alias}
    Sleep   10


Disconnect All SSH Connections
    Run Keyword And Ignore Error   Disconnect Interactive Connections
    Run Keyword And Ignore Error   tafssh.Reset Cache


Get Packet Loss Rate
    [Arguments]  ${content}
    [Documentation]    Get Packet Loss Rate from ping result
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content     | yes | ping result |
    ...
    ...    *RETURN VALUE*
    ...    Number of loss rate, for example 0, or 10, or 100, etc. Note: it does not contain percentage character '%'
    ...
    ...    Example
    ...   | ${content}   | set variable |  3 packets transmitted, 3 received, 100% packet loss, time 2042ms |
    ...   | ${loss_rate} |  Get Packet Loss Rate | content=${content} |
    ...   | should be true | ${loss_rate}==100 |
    ...
    ${matches}  Get Regexp Matches  ${content}   .*\\s+(\\d+)\%\\s+packet\\s+loss,.*   1
    ${rtn}   Set Variable  ${matches[0]}
    [Return]  ${rtn}


Get Test Case Name
    [Documentation]   Get Test Case Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Test case name,  space and colon will be replaced by underline '_', e.g,
    ...    [1]OAM__vDU_Parameter_Relationships_NRBTS-NRSCTP-f1SctpProfileIdOfDu__5GC001662-M
    ...
    ...    Example
    ...    | ${case_name} | Get Test Case Name  |
    ...
    ${rtn}  Set Variable  ${TEST_NAME.replace(" ","_").replace(":","_")}
    [Return]  ${rtn}


Print A Dictionary
    [Arguments]  ${one_dict}
    [Documentation]   Print A Dictionary's keys/values
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | one_dict | yes   |  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Print A Dictionary | ${my_dict_var}   |
    ...
    ${debug_flag}   Set Variable  1
    Return From Keyword If  ${debug_flag}!=1
    Evaluate   pprint.pprint(${one_dict})   modules=pprint


Get Parameter Definition Error
    [Arguments]  ${errors_list}   @{para_list}
    [Documentation]   Get Parameter Definition Error
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | errors_list  | Yes | list of errors which are from vdu.Get_Staged_Plan_Validation_Results()["parameterDefinitionError"] |
    ...    | para_list  | Yes | key=value pair, e.g,  distname=xxx, parameter_path=f1SctpProfileIdOfDu, please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return list of dictionary that matched the filter.
    ...
    ...    Example
    ...    | ${distName}  | set variable | MRBTS-5240/NRBTS-2 |
    ...    | ${errors} | vdu.Get_Staged_Plan_Validation_Results | plan_id=<my_plan_id> | validation_id=<my_validation_id> |
    ...    | ${error}  | Set Variable | ${errors["parameterDefinitionError"]} |
    ...    | ${my_err} | Get Parameter Definition Error | ${error} | distname=${distName} | parameter_path=f1SctpProfileIdOfDu |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}

    #${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   Evaluate  list(${key_value_dict})
    Should Be True  ${key_value_dict_keys.__len__()}>=1

    ${comparision_keys}   Copy List   ${key_value_dict_keys}
    Run Keyword If   """nidd_id""" in """${comparision_keys}"""   Remove Values From List   ${comparision_keys}   nidd_id
    ${rtn_list}   Create List
    FOR    ${i}    IN   @{errors_list}
       Log To Console  ${i}
       Run Keyword If   """nidd_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["nidd_id"]}""" != """${i["nidd_id"]}"""
       ${matched}   Run Keyword If  ${comparision_keys.__len__()}>0   _Value Is In Another Dictionary   to_be_checked_dict=${key_value_dict}
            ...   comparision_keys=${comparision_keys}  another_dict=${i}
       ...   ELSE   set variable  Found
       Continue For Loop If  '${matched}'=='${None}'
       ${tmp}   Copy Dictionary   ${i}
       Append To List   ${rtn_list}   ${tmp}
    END

    [Return]     ${rtn_list}


_Value Is In Another Dictionary
    [Arguments]   ${to_be_checked_dict}   ${comparision_keys}   ${another_dict}
    [Documentation]  return 'Found' if specifised values give by comparision_keys is 'in' another dictionary, otherwise return '${None}'
    ...    It's 'AND' operation among all keys given in ${comparision_keys}
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | to_be_checked_dict  | Yes | to_be_checked_dict |
    ...    | comparision_keys  | Yes | comparision_keys |
    ...    | another_dict  | Yes | another_dict |
    ...
    ...    *RETURN VALUE*
    ...    Return 'Found' if matched, otherwise return ${None}
    ...
    ...    Example
    ...    | comparision_keys | create list | key1 | key2 |
    ...   | ${result} | _Value Is In Another Dictionary | to_be_checked_dict=${dict1} | comparision_keys=${comparision_keys} |
    ...   | ... | another_dict=${dict2} |
    ...
    ${rtn}   Set Variable   Found
    FOR    ${j}    IN   @{comparision_keys}
        Continue For Loop If  """${to_be_checked_dict["${j}"]}""" in """${another_dict["${j}"]}"""
       ${rtn}   Set Variable  ${None}
       Exit For Loop
    END
    [Return]  ${rtn}


Get Sudo For VDU Node for Linux Command According To Current User
    [Arguments]  ${connection}=default
    [Documentation]  Get Sudo For VDU Node for Linux Command According To Current User
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | connection       |  no | connection, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VDU Node for Linux Command According To Current User |
    ...
    ${current_user_name}  Get Current User Name  connection=${connection}
    ${sudo}  set variable if   "${current_user_name}"=="root"   ${EMPTY}
    ...   "${current_user_name}"=="cbis-admin"   sudo    ${EMPTY}
    [Return]  ${sudo}


Get Sudo For VDU Node for Linux Command According To Current User Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Sudo For VDU Node for Linux Command According To Current User Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | connection       |  no | connection, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VDU Node for Linux Command According To Current User |
    ...
    ${current_user_name}  Get Current User Name Interactively  alias=${alias}
    ${sudo}  set variable if   "${current_user_name}"=="root"   ${EMPTY}
    ...   "${current_user_name}"=="cbis-admin"   sudo    ${EMPTY}
    [Return]  ${sudo}


Get Current User Name
    [Arguments]  ${connection}=default
    [Documentation]  Get Current User Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | connection       |  no | connection, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    current user name who logins K8S node
    ...
    ...    Example
    ...    | ${current_user_name} | Get Current User Name Interactively |
    ...
    ${out}   tafssh.Execute   command=whoami   connection=${connection}
    #${whoami}   Strip Prompt  ${out}
    ${whoami}   set variable  ${out.strip()}
    [Return]   ${whoami}


Get Current User Name Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Current User Name Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias       |  no | alias, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    current user name who logins K8S node
    ...
    ...    Example
    ...    | ${current_user_name} | Get Current User Name Interactively |
    ...
    ${out}   issh.Execute   command=whoami   alias=${alias}
    ${whoami}   Strip Prompt  ${out}
    [Return]   ${whoami}


Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster
    [Arguments]    ${override_dict_vdu_pvc}    ${override_dict_vdu_network}   ${override_dict_vdu}     ${build_number}
    #[Teardown]   Run Keywords  issh.Execute   command=rm -rf ${ute_single_pkg_dir}   alias=${alias_ute}
    #...    AND   run keyword and ignore error  disconnect interactive connection   alias=${alias_k8s_tenant}
    [Teardown]    Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias_k8s_tenant}
    [Documentation]   Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | override_dict    | yes | override_dict content from __init__.py |
    ...    | vdu_chart_name    | yes | vdu_chart_namet you want to download , e.g, aic-vdu-mvp-0.390.1151|
    ...    | alias_k8s_tenant  | yes | alias_k8s_tenant |
    ...    | alias_ute         | yes | alias_ute |
    ...
    ...    *RETURN VALUE*
    ...      yaml full file name in K8s master
    ...    example:
    ...      /tmp/cranuser1/helm/aic-vdu-mvp/aic-vdu/values-override_mvp.yaml
    ...
    ...    Example
    ...    | Upload Tools To K8s Master |
    ...    | Connect To K8s Master With Tenant Interactively | alias=alias_k8s_tenant |
    ...    | ${vdu_chart_name} | Get VDU Chart Name |
    ...    | ${conf_dict}   | Get VDU Vnf Config Dictionary From TestLine |
    ...    | ${remote_yaml_file} | Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster | override_dict=${conf_dict} |
    ...    | ...  |  vdu_chart_name=${vdu_chart_name} |
    ...    | ${vdu_dep_cmd} |  OperatingSystem.Join Path | ${TOOLS_INFO["work_folder_tool"]} |  ${TOOLS_INFO["vdu_dep"]} |
    ...    | ${out} |  issh.Execute | command=${vdu_dep_cmd} -f ${remote_yaml_file} -r myvdu | alias=alias_k8s_tenant |
    ...    | Disconnect All SSH Connections |
    ...
    ...    Modify value according to special test purpose, here is an example of changing dhcp pool for mplane network towards ruproxy:
    ...    | Upload Tools To K8s Master |
    ...    | Connect To K8s Master With Tenant Interactively | alias=alias_k8s_tenant |
    ...    | ${vdu_chart_name} | Get VDU Chart Name |
    ...    | ${conf_dict}   | Get VDU Vnf Config Dictionary From TestLine |
    ...    | ${key_list}    | Create List | dhcp | service | v4Pools |
    ...    | Set Dictionary With Multiple Level Keys | value=192.168.254.45 - 192.168.254.60 | dict_name=${conf_dict} | keys=${key_list} |
    ...    | ${remote_yaml_file} | Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster | override_dict=${conf_dict} |
    ...    | ...  |  vdu_chart_name=${vdu_chart_name} |
    ...    | ${vdu_dep_cmd} |  OperatingSystem.Join Path | ${TOOLS_INFO["work_folder_tool"]} |  ${TOOLS_INFO["vdu_dep"]} |
    ...    | ${out} |  issh.Execute | command=${vdu_dep_cmd} -f ${remote_yaml_file} -r myvdu | alias=alias_k8s_tenant |
    ...    | Disconnect All SSH Connections |
    ...
    ${ute_single_pkg_dir}   Download Single Package To UTE   build_number=${build_number}
    #${ute_single_pkg_dir}   set variable  /tmp/TESTSUITE__Unittest2/TESTCASE__5G_Restore_Environment_To_Onair/2020_09_11_08_06_25/pkg_159980444562

    #---
    #vdu pvc
    ${to_be_changed_yaml_file_vdu_pvc}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-pvc    values-override.yaml
    ${to_be_changed_conf_dict_vdu_pvc}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_pvc}
    #override values for vdu network
    Update_Dictionary   src_dict=${override_dict_vdu_pvc}   dst_dict=${to_be_changed_conf_dict_vdu_pvc}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu_pvc}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu_pvc}    file_path=${to_be_changed_yaml_file_vdu_pvc}

    #vdu_network
    ${to_be_changed_yaml_file_vdu_network}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-intnet    values-override.yaml
    ${to_be_changed_conf_dict_vdu_network}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_network}
    #override values for vdu network
    Update_Dictionary   src_dict=${override_dict_vdu_network}   dst_dict=${to_be_changed_conf_dict_vdu_network}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu_network}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu_network}    file_path=${to_be_changed_yaml_file_vdu_network}

    #vdu
    ${to_be_changed_yaml_file_vdu}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-vdu    values-override.yaml
    ${to_be_changed_conf_dict_vdu}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu}
    #override values for vdu aic_vdu_values_override_0.yaml
    Update_Dictionary   src_dict=${override_dict_vdu}   dst_dict=${to_be_changed_conf_dict_vdu}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu}    file_path=${to_be_changed_yaml_file_vdu}

    ###################################################################
    #for docker image patch purpose, update parameter defined in values_0.yaml
    ${conf_values_dict_vdu}       Get vDU Vnf Values Config Dictionary From TestLine
    ${conf_values_dict_vdu_len}   get length  ${conf_values_dict_vdu}
    ${to_be_changed_yaml_file_vdu_values_yaml}   run keyword if  ${conf_values_dict_vdu_len}>0
       ...  OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-vdu    values.yaml
     ${to_be_changed_conf_dict_vdu_values_yaml}  run keyword if  ${conf_values_dict_vdu_len}>0
       ...    Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_values_yaml}
    #override values for vdu values.yaml
    #run keyword if  ${conf_values_dict_vdu_len}>0
    #   ...   Update_Dictionary   src_dict=${conf_values_dict_vdu}   dst_dict=${to_be_changed_conf_dict_vdu_values_yaml}
    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   update_dictionary_with_appending   dict1=${conf_values_dict_vdu}   dict2=${to_be_changed_conf_dict_vdu_values_yaml}

    #add additional value which does not exist in original value.yaml

    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   Print A Dictionary  ${to_be_changed_conf_dict_vdu_values_yaml}
    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   Dictionary_To_Yaml_File  dict_values=${to_be_changed_conf_dict_vdu_values_yaml}  file_path=${to_be_changed_yaml_file_vdu_values_yaml}

    #---

    #tar a file in local UTE server
    ${alias_ute}  Get Unique ID
    Connect To UTE Locally    alias=${alias_ute}
    ${out}   issh.Execute  command=cd ${ute_single_pkg_dir}    alias=${alias_ute}

    ${local_char_tgz_file_short_name}  Set Variable   single_pkg_modified_in_ute.tgz
    ${out}   issh.Execute  command=tar -czf ${local_char_tgz_file_short_name} *   alias=${alias_ute}
    ${local_char_tgz_file_full_name}   OperatingSystem.Join Path   ${ute_single_pkg_dir}   ${local_char_tgz_file_short_name}

    #upload to k8s master
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}
    ${whoami}   Get Current User Name Interactively   alias=${alias_k8s_tenant}
    ${random_name}   Get Unique ID   prefix=${whoami}_   precise=LOW
    ${helm_vdu_tmp_folder}  get a remote Directory   ${random_name}  single_pkg  alias=${alias_k8s_tenant}
    ${out}  issh.Upload_File   local_path=${local_char_tgz_file_full_name}   remote_path=${helm_vdu_tmp_folder}   alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=cd ${helm_vdu_tmp_folder}   alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=ls -l  alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=tar -xzf ${local_char_tgz_file_short_name}    alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=ls -l  alias=${alias_k8s_tenant}

    ${remote_vdu_chart_yaml_file}           OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-vdu       values-override.yaml
    ${remote_vdu_network_chart_yaml_file}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-intnet    values-override.yaml
    ${remote_vdu_pvc_chart_yaml_file}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-pvc   values-override.yaml

    ${remote_vdu_chart_yaml_folder}           OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-vdu
    ${remote_vdu_network_chart_yaml_folder}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-intnet
    ${remote_vdu_pvc_chart_yaml_folder}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-pvc

    ${rtn}   create dictionary
     ...   remote_vdu_pvc_chart_yaml_file=${remote_vdu_pvc_chart_yaml_file}
     ...   remote_vdu_pvc_chart_yaml_folder=${remote_vdu_pvc_chart_yaml_folder}
     ...   remote_vdu_network_chart_yaml_file=${remote_vdu_network_chart_yaml_file}
     ...   remote_vdu_network_chart_yaml_folder=${remote_vdu_network_chart_yaml_folder}
     ...   remote_vdu_chart_yaml_file=${remote_vdu_chart_yaml_file}
     ...   remote_vdu_chart_yaml_folder=${remote_vdu_chart_yaml_folder}

    print a dictionary  ${rtn}
    [Return]  ${rtn}


Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster NCS
    [Arguments]    ${override_dict_vdu_pvc}    ${override_dict_vdu_network}   ${override_dict_vdu}     ${build_number}
    #[Teardown]   Run Keywords  issh.Execute   command=rm -rf ${ute_single_pkg_dir}   alias=${alias_ute}
    #...    AND   run keyword and ignore error  disconnect interactive connection   alias=${alias_k8s_tenant}
    [Teardown]    Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias_k8s_tenant}
    [Documentation]   Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | override_dict    | yes | override_dict content from __init__.py |
    ...    | vdu_chart_name    | yes | vdu_chart_namet you want to download , e.g, aic-vdu-mvp-0.390.1151|
    ...    | alias_k8s_tenant  | yes | alias_k8s_tenant |
    ...    | alias_ute         | yes | alias_ute |
    ...
    ...    *RETURN VALUE*
    ...      yaml full file name in K8s master
    ...    example:
    ...      /tmp/cranuser1/helm/aic-vdu-mvp/aic-vdu/values-override_mvp.yaml
    ...
    ...    Example
    ...    | Upload Tools To K8s Master |
    ...    | Connect To K8s Master With Tenant Interactively | alias=alias_k8s_tenant |
    ...    | ${vdu_chart_name} | Get VDU Chart Name |
    ...    | ${conf_dict}   | Get VDU Vnf Config Dictionary From TestLine |
    ...    | ${remote_yaml_file} | Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster | override_dict=${conf_dict} |
    ...    | ...  |  vdu_chart_name=${vdu_chart_name} |
    ...    | ${vdu_dep_cmd} |  OperatingSystem.Join Path | ${TOOLS_INFO["work_folder_tool"]} |  ${TOOLS_INFO["vdu_dep"]} |
    ...    | ${out} |  issh.Execute | command=${vdu_dep_cmd} -f ${remote_yaml_file} -r myvdu | alias=alias_k8s_tenant |
    ...    | Disconnect All SSH Connections |
    ...
    ...    Modify value according to special test purpose, here is an example of changing dhcp pool for mplane network towards ruproxy:
    ...    | Upload Tools To K8s Master |
    ...    | Connect To K8s Master With Tenant Interactively | alias=alias_k8s_tenant |
    ...    | ${vdu_chart_name} | Get VDU Chart Name |
    ...    | ${conf_dict}   | Get VDU Vnf Config Dictionary From TestLine |
    ...    | ${key_list}    | Create List | dhcp | service | v4Pools |
    ...    | Set Dictionary With Multiple Level Keys | value=192.168.254.45 - 192.168.254.60 | dict_name=${conf_dict} | keys=${key_list} |
    ...    | ${remote_yaml_file} | Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster | override_dict=${conf_dict} |
    ...    | ...  |  vdu_chart_name=${vdu_chart_name} |
    ...    | ${vdu_dep_cmd} |  OperatingSystem.Join Path | ${TOOLS_INFO["work_folder_tool"]} |  ${TOOLS_INFO["vdu_dep"]} |
    ...    | ${out} |  issh.Execute | command=${vdu_dep_cmd} -f ${remote_yaml_file} -r myvdu | alias=alias_k8s_tenant |
    ...    | Disconnect All SSH Connections |
    ...
    ${ute_single_pkg_dir}   Download Single Package To UTE   build_number=${build_number}
    #${ute_single_pkg_dir}   set variable  /tmp/TESTSUITE__Unittest2/TESTCASE__5G_Restore_Environment_To_Onair/2020_09_11_08_06_25/pkg_159980444562

    #---
    #vdu pvc
    ${to_be_changed_yaml_file_vdu_pvc}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-pvc    values-override.yaml
    ${to_be_changed_conf_dict_vdu_pvc}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_pvc}
    #override values for vdu network
    Update_Dictionary   src_dict=${override_dict_vdu_pvc}   dst_dict=${to_be_changed_conf_dict_vdu_pvc}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu_pvc}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu_pvc}    file_path=${to_be_changed_yaml_file_vdu_pvc}

    #vdu_network
    ${to_be_changed_yaml_file_vdu_network}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-intnet    values-override.yaml
    ${to_be_changed_conf_dict_vdu_network}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_network}
    #override values for vdu network
    Update_Dictionary   src_dict=${override_dict_vdu_network}   dst_dict=${to_be_changed_conf_dict_vdu_network}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu_network}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu_network}    file_path=${to_be_changed_yaml_file_vdu_network}

    #vdu
    ${to_be_changed_yaml_file_vdu}   OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-vdu    values-override.yaml
    ${to_be_changed_conf_dict_vdu}   Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu}
    #override values for vdu aic_vdu_values_override_0.yaml
    Update_Dictionary   src_dict=${override_dict_vdu}   dst_dict=${to_be_changed_conf_dict_vdu}
    Print A Dictionary  ${to_be_changed_conf_dict_vdu}
    ${r}  ${valu}  run keyword and ignore error    set variable  ${to_be_changed_conf_dict_vdu["coredumpPath"]}
    run keyword if  "${r}"=="PASS"  set to dictionary  ${to_be_changed_conf_dict_vdu}  coredumpPath   /tmp/cdump
    run keyword if  "${r}"=="PASS"  Print A Dictionary  ${to_be_changed_conf_dict_vdu}
    Dictionary_To_Yaml_File    dict_values=${to_be_changed_conf_dict_vdu}    file_path=${to_be_changed_yaml_file_vdu}

    ################ values.yaml #####################
    #for docker image patch purpose, update parameter defined in values_0.yaml
    ${conf_values_dict_vdu}       Get vDU Vnf Values Config Dictionary From TestLine
    ${conf_values_dict_vdu_len}   get length  ${conf_values_dict_vdu}
    ${to_be_changed_yaml_file_vdu_values_yaml}   run keyword if  ${conf_values_dict_vdu_len}>0
       ...  OperatingSystem.Join Path  ${ute_single_pkg_dir}   HelmChart    aic-vdu    values.yaml
     ${to_be_changed_conf_dict_vdu_values_yaml}  run keyword if  ${conf_values_dict_vdu_len}>0
       ...    Yaml_File_To_Dictionary  ${to_be_changed_yaml_file_vdu_values_yaml}
    #override values for vdu values.yaml
    #run keyword if  ${conf_values_dict_vdu_len}>0
    #   ...   Update_Dictionary   src_dict=${conf_values_dict_vdu}   dst_dict=${to_be_changed_conf_dict_vdu_values_yaml}

    #add additional value which does not exist in original value.yaml
    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   update_dictionary_with_appending   dict1=${conf_values_dict_vdu}   dict2=${to_be_changed_conf_dict_vdu_values_yaml}
    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   Print A Dictionary  ${to_be_changed_conf_dict_vdu_values_yaml}
    run keyword if  ${conf_values_dict_vdu_len}>0
       ...   Dictionary_To_Yaml_File  dict_values=${to_be_changed_conf_dict_vdu_values_yaml}  file_path=${to_be_changed_yaml_file_vdu_values_yaml}
    ################ End of values.yaml #####################

    #tar a file in local UTE server
    ${alias_ute}  Get Unique ID
    Connect To UTE Locally    alias=${alias_ute}
    ${out}   issh.Execute  command=cd ${ute_single_pkg_dir}    alias=${alias_ute}

    ${local_char_tgz_file_short_name}  Set Variable   single_pkg_modified_in_ute.tgz
    ${out}   issh.Execute  command=tar -czf ${local_char_tgz_file_short_name} *   alias=${alias_ute}
    ${local_char_tgz_file_full_name}   OperatingSystem.Join Path   ${ute_single_pkg_dir}   ${local_char_tgz_file_short_name}

    #upload to k8s master
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}
    ${whoami}   Get Current User Name Interactively   alias=${alias_k8s_tenant}
    ${random_name}   Get Unique ID   prefix=${whoami}_   precise=LOW
    ${helm_vdu_tmp_folder}  get a remote Directory   ${random_name}  single_pkg  alias=${alias_k8s_tenant}
    ${out}  issh.Upload_File   local_path=${local_char_tgz_file_full_name}   remote_path=${helm_vdu_tmp_folder}   alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=cd ${helm_vdu_tmp_folder}   alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=ls -l  alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=tar -xzf ${local_char_tgz_file_short_name}    alias=${alias_k8s_tenant}
    ${out}  issh.Execute  command=ls -l  alias=${alias_k8s_tenant}

    ${remote_vdu_chart_yaml_file}           OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-vdu       values-override.yaml
    ${remote_vdu_network_chart_yaml_file}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-intnet    values-override.yaml
    ${remote_vdu_pvc_chart_yaml_file}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-pvc   values-override.yaml

    ${remote_vdu_chart_yaml_folder}           OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-vdu
    ${remote_vdu_network_chart_yaml_folder}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-intnet
    ${remote_vdu_pvc_chart_yaml_folder}   OperatingSystem.Join Path   ${helm_vdu_tmp_folder}   HelmChart   aic-pvc

    ${rtn}   create dictionary
     ...   remote_vdu_pvc_chart_yaml_file=${remote_vdu_pvc_chart_yaml_file}
     ...   remote_vdu_pvc_chart_yaml_folder=${remote_vdu_pvc_chart_yaml_folder}
     ...   remote_vdu_network_chart_yaml_file=${remote_vdu_network_chart_yaml_file}
     ...   remote_vdu_network_chart_yaml_folder=${remote_vdu_network_chart_yaml_folder}
     ...   remote_vdu_chart_yaml_file=${remote_vdu_chart_yaml_file}
     ...   remote_vdu_chart_yaml_folder=${remote_vdu_chart_yaml_folder}

    print a dictionary  ${rtn}
    [Return]  ${rtn}


Download Single Package To UTE
    [Arguments]  ${build_number}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Download Single Package To UTE
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_chart_name    | yes | vdu_chart_namet |
    ...
    ...    *RETURN VALUE*
    ...    return type is list, list content:
    ...    [ <vdu chart folder name in UTE server>, <chart sub folder> ]
    ...    example:
    ...     ["/tmp/myfolder", "aic-vdu"]
    ...
    ...    Example
    ...    | Download Single Package To UTE | build_number=0.390.1222 |
    ...
    log to console  BEGIN of Download Single Package To UTE.
    ${alias}  Get Unique ID
    Connect To UTE Locally    alias=${alias}

    ${dir_name}   Get Unique ID   prefix=pkg_   precise=LOW
    ${ute_single_pkg_dir}  Get A Directory   ${dir_name}

    #${zip_file_name}   set variable   vDU-NCIR-${build_number}.zip
    #${zip_file_name}   set variable if  "${build_number}"=="0.390.1222"   vDU-NCIR-${build_number}.zip    vDU-${build_number}.zip
    ${zip_file_name}   set variable   vDU-${build_number}.zip
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/${zip_file_name}

    ${old_timerout}   issh.Set Timeout    2100    alias=${alias}
    ${out}   issh.Execute   command=cd ${ute_single_pkg_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${out}   issh.Execute   command=zip -d ${zip_file_name} Images/*    alias=${alias}
    ${out}   issh.Execute   command=unzip ${zip_file_name}    alias=${alias}
    ${out}   issh.Execute   command=rm -rf ${zip_file_name}   alias=${alias}

    ${out}   issh.Execute   command=cd HelmChart   alias=${alias}

    ${aic_intnet_file_name}   set variable  aic-intnet-${build_number}.tgz
    ${aic_pvc_mvp_file_name}   set variable  aic-pvc-${build_number}.tgz
    ${aic_vdu_file_name}   set variable  aic-vdu-${build_number}.tgz

    ${aic_intnet_file_name_old}   set variable  aic-intnet-${build_number}-old.tgz
    ${aic_pvc_mvp_file_name_old}   set variable  aic-pvc-${build_number}-old.tgz
    ${aic_vdu_file_name_old}   set variable  aic-vdu-${build_number}-old.tgz

    ${out}   issh.Execute   command=tar -xzf ${aic_intnet_file_name}     alias=${alias}
    ${out}   issh.Execute   command=tar -xzf ${aic_pvc_mvp_file_name}     alias=${alias}
    ${out}   issh.Execute   command=tar -xzf ${aic_vdu_file_name}     alias=${alias}

    ${out}   issh.Execute   command=mv ${aic_intnet_file_name} ${aic_intnet_file_name_old}     alias=${alias}
    ${out}   issh.Execute   command=mv ${aic_pvc_mvp_file_name} ${aic_pvc_mvp_file_name_old}     alias=${alias}
    ${out}   issh.Execute   command=mv ${aic_vdu_file_name} ${aic_vdu_file_name_old}     alias=${alias}

    issh.set timeout     ${old_timerout}    alias=${alias}

    log to console  END of Download Single Package To UTE.
    [Return]  ${ute_single_pkg_dir}


Download onBoardApp Package To NCIR
    [Arguments]  ${build_number}   #${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Download VDU Chart To UTE
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number    | yes | build_number |
    ...    | vdu_index    | no | vdu_index , default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    return type is list, list content:
    ...    [ <vdu chart folder name in UTE server>, <chart sub folder> ]
    ...    example:
    ...     ["/tmp/myfolder", "aic-vdu"]
    ...
    ...    Example
    ...    | Download Single Package To UTE | build_number=0.390.1222 |
    ...
    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively    alias=${alias}

    ${dir_name}   Get Unique ID   prefix=onBoard_   precise=LOW
    ${onBoardApp_pkg_dir}  Get A Remote Directory   ${dir_name}  alias=${alias}

    ${zip_file_name}   set variable   onBoardingApp.tgz
    #${url}    set variable  ${PACKAGE_LINK}/${build_number}/vdu-dep-artifacts/${zip_file_name}
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/artifacts/${zip_file_name}

    ${old_timerout}   issh.Set Timeout    200    alias=${alias}
    ${out}   issh.Execute   command=cd ${onBoardApp_pkg_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${out}   issh.Execute   command=tar -xzf ${zip_file_name}    alias=${alias}

    issh.set timeout     ${old_timerout}    alias=${alias}
    [Return]  ${onBoardApp_pkg_dir}


Get Wireshark Log In VDU Container Within Given Time
    [Arguments]  ${pod_abbr}   ${container}   ${network}   ${filter}=${EMPTY}   ${vdu_index}=0   ${capture_time}=350
    [Documentation]   Get Wireshark Log in vDU Container within given time
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | filter       | no | filter, default value is ${EMPTY} |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | capture_time | no | capture_time, default is 350, unit is second |
    ...
    ...    *RETURN VALUE*
    ...   interface name, e.g, f16, oam3, etc.
    ...
    ...    Example
    ...   | ${pcap_file} | Get Wireshark Log in vDU Container within given time | pod_abbr=oam | container=oam | network=oam |
    ...   | ${pcap_file} | Get Wireshark Log in vDU Container within given time | pod_abbr=oam | container=oamfh | network=f1 |
    ...
    ${master_alias}  Get Unique Id
    ${node_alias}    Get Unique Id
    Connect To VDU Node   pod_abbr=oam   master_alias=${master_alias}  vdu_index=${vdu_index}  node_alias=${node_alias}
    ${interface}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}  container=${container}   network=${network}  connection=${master_alias}

    ${tmp_file}  Begin Wireshark  pod_abbr=${pod_abbr}  container=${container}   interface=${interface}
       ...   filter=${filter}   host_type=VDUC   index=${vdu_index}   alias=${node_alias}
    Sleep   ${capture_time}
    ${random_file_name}  Get Unique Id    prefix=wireshark    suffix=.pcap   precise=LOW
    ${local_pcap}  Get A File  Wireshark   ${random_file_name}
    End Wireshark     log_dst_path=${local_pcap}   log_src_path=${tmp_file}   alias=${node_alias}
    [Return]   ${local_pcap}


Make Sure Environment Is Ready From Transport Aspect
    [Arguments]   ${detection_time}=200  ${vdu_index}=0
    [Documentation]   Make Sure Environment Is Ready From Transport Aspect
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Make Sure Environment Is Ready From Transport Aspect |
    ...
    ${ip}  ${mask}   ${broadcast}   Wait Until Keyword Succeeds  ${detection_time}   15s   Get Mplane Ip Of RU Proxy   vdu_index=${vdu_index}
    String Should Be An Ip Address  ${ip}


Reboot Radio Unit
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0  ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Reboot Radio Unit/Reboot RU/Restart RU/Restart Radio Unit
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...    | ru_index   | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Reboot Radio Unit |
    ...
    ${alias}   Get Unique Id
    Connect To Radio Unit    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}     alias=${alias}   ru_index=${ru_index}
    ${cmd}  Set Variable    reboot
    ${out}   issh.Execute   command=${cmd}    check_result=${False}  alias=${alias}
    #sleep   240
    sleep   120

Reboot FHGW
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Reboot FHGW
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Reboot FHGW |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   issh.Execute   command=reboot    check_result=${False}  alias=${alias}


Redeploy RUPROXY
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Redeploy RUPROXY
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Redeploy RUPROXY |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${FHGW_misc_conf}   Get FHGW Misc

    #${out}   issh.Execute   command=python removePod_new.py 1       alias=${alias}
    ${out}   issh.Execute   command=python ${FHGW_misc_conf["ruproxy_delete_tool"]} 1       alias=${alias}
    wait until keyword succeeds   200   10s   Ruproxy Number should Be Expected   expted_number=0
    ${out}   issh.Execute   command=python ${FHGW_misc_conf["ruproxy_create_tool"]} 1 2      alias=${alias}
    wait until keyword succeeds   200   10s   Ruproxy Number should Be Expected   expted_number=1
    wait until keyword succeeds   200   10s   FHGW Special Pod Status And Container Number Should Be Expected


Ruproxy Number should Be Expected
    [Arguments]  ${expted_number}   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Ruproxy Number should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expted_number | No | expted_number  |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Ruproxy Number should Be Expected | 0 |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   issh.Execute   command=kubectl get pod|grep ruproxy|grep Running|wc -l       alias=${alias}
    ${out}   strip prompt  ${out}
    should be true  ${out}==${expted_number}


Redeploy rumoduleagent
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Redeploy rumoduleagent
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Redeploy rumoduleagent |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   issh.Execute   command= kubectl get pod|grep rumoduleagent |awk '{print $1}'   alias=${alias}
    ${pod_name}   strip prompt  ${out}

    ${out}   issh.Execute   command=kubectl delete pod ${pod_name}      alias=${alias}
    sleep   10

    wait until keyword succeeds   200   10s   rumoduleagent Number should Be Expected   expted_number=1
    wait until keyword succeeds   200   10s   FHGW Special Pod Status And Container Number Should Be Expected   pod_abbr=rumoduleagent


rumoduleagent Number should Be Expected
    [Arguments]  ${expted_number}   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Ruproxy Number should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expted_number | No | expted_number  |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Ruproxy Number should Be Expected | 0 |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   issh.Execute   command=kubectl get pod|grep rumoduleagent|grep Running|wc -l       alias=${alias}
    ${out}   strip prompt  ${out}
    should be true  ${out}==${expted_number}


FHGW Special Pod Status And Container Number Should Be Expected
    [Arguments]  ${pod_abbr}=ruproxy    ${status}=Running   ${vdu_index}=0     ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   vDU Special Pod Status And Container Number Should Be Expected Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, ruproxy |
    ...    | status          | yes | expected status, it is not case-sensitive, e.g, RUNNING, Running, etc. |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...    | fhgw_index      | No | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | FHGW Special Pod Status And Container Number Should Be Expected | pod_abbr=ruproxy | status=Running |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}

    # ${ns}   Get vDU Namespace From TestLine
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}

    ${actual_ready}   issh.Execute  command=kubectl get pod|grep ${pod_abbr}|awk '{print $2}'|grep -v READY    alias=${alias}
    ${actual_ready}   strip prompt  ${actual_ready}
    ${actual_ready}   Set Variable  ${actual_ready.strip()}

    ${actual_status}   issh.Execute  command=kubectl get pod|grep ${pod_abbr}|awk '{print $3}'|grep -v STATUS    alias=${alias}
    ${actual_status}   strip prompt  ${actual_status}
    ${actual_status}   Set Variable  ${actual_status.strip()}

    ${matches}   split string  ${actual_ready}   /
    should be true  ${matches.__len__()}==2
    ${running_num}  set variable   ${matches[0]}
    ${total_num}    set variable  ${matches[1]}
    should be true   ${running_num}==${total_num}

    ${actual_status}   Set Variable  ${actual_status.strip()}
    Should Be True   "${actual_status}"=="${status}"


Ruproxy State should Be Expected
    [Arguments]   ${vdu_index}=0   ${fhgw_index}=0  #${expted_state}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Ruproxy State should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expted_number | No | expted_number  |
    ...    | vdu_index  | No | vdu_index, default value is 0  |
    ...    | fhgw_index | No | fhgw_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Ruproxy Number should Be Expected | 0 |
    ...
    ${alias}   Get Unique Id
    Connect to FHGW  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   issh.Execute   command=kubectl get pod|grep ruproxy|wc -l       alias=${alias}
    ${out}   strip prompt  ${out}
    should be true  ${out}==${expted_number}


Get A Remote File
    [Arguments]   @{parameter_list}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias_admin}
    [Documentation]   create a temparary file in remote server and return full file name,
    ...    this file will keep 3 hours then it will be removed automatically
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_list    | yes | including subfolder name or file name, and alias, please see examples  |
    ...
    ...    *RETURN VALUE*
    ...   Full temparary file name with folders name
    ...
    ...    Example
    ...   | ${alias}   | Get Unique Id |
    ...   | connect to k8s master with tenant interactively | alias=${alias} |
    ...
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_a.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | a.txt | alias=${alias} |
    ...
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/a.log
    ...   | ${remote_file_name} | Get A Remote File | folder1 | xxxxxxx_a.log | alias=${alias} |
    ...
    ...
    ...   | Connect To vDU Node Interactively | pod_abbr=oam |
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_c.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | c.txt |
    ...

    ${non_key_value_pair_list}   ${key_value_dict}   run keyword if  ${parameter_list.__len__()}>0
       ...   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    ${non_key_value_pair_list}  run keyword if  "${non_key_value_pair_list}"=="${None}"   create list
       ...   ELSE   set variable  ${non_key_value_pair_list}
    ${key_value_dict}  run keyword if  "${key_value_dict}"=="${None}"   create dictionary
       ...   ELSE   set variable  ${key_value_dict}

    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    ${alias}   set variable if   "alias" in "${key_value_dict_keys}"   ${key_value_dict["alias"]}   default
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove From Dictionary   ${key_value_dict}   alias
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove Values From List   ${key_value_dict_keys}   alias

    #${base_folder0}  set variable   /tmp/tmp_taic
    ${ns}   get vdu namespace from testline
    ${base_folder0}  set variable   /tmp/tmp_taic_${ns}

    #set full permission
    ${alias_admin}   get unique id
    connect to k8s master interactively  alias=${alias_admin}
    ${out}  issh.Execute  command=sudo mkdir -p ${base_folder0}    alias=${alias_admin}
    ${out}  issh.Execute  command=sudo chmod -R 777 ${base_folder0}    alias=${alias_admin}

    ${base_folder}  _Get Remote Log Path   base_folder=${base_folder0}

    ${subfolders_or_file_name}  set variable  ${non_key_value_pair_list}
    ${length}   Get Length  ${subfolders_or_file_name}
    issh.Execute  command=mkdir -p ${base_folder}   check_result=${False}   alias=${alias}

#    Clear Unused Remote Files    folder_name=${base_folder0}  time_window=10800   alias=${alias}

    ${tmp_file}   Get Unique ID   precise=FORMAT_DATETIME
    ${full_file_name}   Run Keyword If  ${length}>0   OperatingSystem.Join Path   ${base_folder}   @{subfolders_or_file_name}
    ...   ELSE   OperatingSystem.Join Path   ${base_folder}   ${tmp_file}

    ${path}  ${file}   OperatingSystem.Split Path   ${full_file_name}
    issh.Execute  command=mkdir -p ${path}   check_result=${False}   alias=${alias}

    ${full_file_name}   Run Keyword If  ${length}>0   Operatingsystem.Join Path   ${path}   ${tmp_file}_${file}
       ...   ELSE   set variable   ${full_file_name}
    issh.Execute  command=touch ${full_file_name}   check_result=${False}   alias=${alias}
    #issh.Execute  command=chmod -R 777 ${base_folder}  check_result=${False}   alias=${alias}
    _Get A Remote File Set Full Permission    folder_name=${base_folder}   alias=${alias}

    [Return]   ${full_file_name}



_Get A Remote File Set Full Permission
    [Arguments]  ${folder_name}     ${alias}=default
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}

    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info

    ${host_type}  Get Host Type  alias=${alias}
    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"

    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}  alias=${alias}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"

    Fail   Unknown host type!


_Get A Remote File Set Full Permission On OE Server With Admin
    [Arguments]  ${folder_name}    ${alias}=${EMPTY}
    [Teardown]  run keyword if   "${alias}"=="${EMPTY}"   disconnect interactive connection  alias=${alias_new}
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${alias_new}   run keyword if   "${alias}"=="${EMPTY}"  get unique id
      ...   ELSE  set variable  ${alias}
    run keyword if   "${alias}"=="${EMPTY}"   connect to k8s master interactively  alias=${alias_new}
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${admin_username}  set variable  ${vdu_k8s_master_ssh_connection_info["username"]}
    issh.Execute  command=sudo chmod -R 777 ${folder_name}  check_result=${False}   alias=${alias_new}
    issh.Execute  command=sudo chown -R ${admin_username}:${admin_username} ${folder_name}  check_result=${False}   alias=${alias_new}


Get A Remote Directory
    [Arguments]   @{parameter_list}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias_admin}
    [Documentation]   create a temparary Directory in remote server and return full Directory name,
    ...    this file will keep 3 hours then it will be removed automatically
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_list    | yes | including subfolder name, and alias, please see examples  |
    ...
    ...    *RETURN VALUE*
    ...   Full temparary Directory name
    ...
    ...    Example
    ...   | ${alias}   | Get Unique Id |
    ...   | connect to k8s master with tenant interactively | alias=${alias} |
    ...
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2  | alias=${alias} |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   run keyword if  ${parameter_list.__len__()}>0
       ...   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    ${non_key_value_pair_list}  run keyword if  "${non_key_value_pair_list}"=="${None}"   create list
       ...   ELSE   set variable  ${non_key_value_pair_list}
    ${key_value_dict}  run keyword if  "${key_value_dict}"=="${None}"   create dictionary
       ...   ELSE   set variable  ${key_value_dict}

    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    ${alias}   set variable if   "alias" in "${key_value_dict_keys}"   ${key_value_dict["alias"]}   default
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove From Dictionary   ${key_value_dict}   alias
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove Values From List   ${key_value_dict_keys}   alias

    #${base_folder0}  set variable   /tmp/tmp_taic
    ${ns}   get vdu namespace from testline
    ${base_folder0}  set variable   /tmp/tmp_taic_${ns}

    #set full permission
    ${alias_admin}   get unique id
    connect to k8s master interactively  alias=${alias_admin}
    ${out}  issh.Execute  command=sudo mkdir -p ${base_folder0}    alias=${alias_admin}
    ${out}  issh.Execute  command=sudo chmod -R 777 ${base_folder0}    alias=${alias_admin}

    ${base_folder}  _Get Remote Log Path   base_folder=${base_folder0}

    ${subfolders_or_file_name}  set variable  ${non_key_value_pair_list}
    ${length}   Get Length  ${subfolders_or_file_name}
    issh.Execute  command=mkdir -p ${base_folder}   check_result=${False}   alias=${alias}

    #Clear Unused Remote Files    folder_name=${base_folder0}  time_window=10800   alias=${alias}

    ${tmp_folder}   Get Unique ID
    ${full_folder_name}   Run Keyword If  ${length}>0   OperatingSystem.Join Path   ${base_folder}   @{subfolders_or_file_name}
    ...   ELSE   OperatingSystem.Join Path   ${base_folder}   ${tmp_folder}

    #${path}  ${file}   OperatingSystem.Split Path   ${full_file_name}
    issh.Execute  command=mkdir -p ${full_folder_name}   check_result=${False}   alias=${alias}

    #${full_file_name}   Run Keyword If  ${length}>0   Operatingsystem.Join Path   ${path}   ${tmp_file}_${file}
    #   ...   ELSE   set variable   ${full_file_name}
    #issh.Execute  command=touch ${full_file_name}   check_result=${False}   alias=${alias}
    #issh.Execute  command=chmod -R 777 ${base_folder}  check_result=${False}   alias=${alias}
    _Get A Remote File Set Full Permission    folder_name=${base_folder}   alias=${alias}

    [Return]   ${full_folder_name}


Get Host Type
    [Arguments]  ${alias}=default
    [Documentation]   Get Host Type
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias            | no | alias, default is default|
    ...
    ...    *RETURN VALUE*
    ...  OE_SERVER_CONTROLLER or GENERAL_LINUX_SERVER
    ...
    ${prompt_oe_server_NCS}  set variable   \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$

    ${prompt_oe_server_OCP}  set variable   \\[core@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|${prompt_oe_server_OCP}

    ${out}   issh.Execute   command=hostname  alias=${alias}
    ${matches}   get regexp matches  ${out}   \\[root@controller\\(FHGW.*\\).*\\]
    return from keyword if  ${matches}   FHGW

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@controller-\\d.*\\]|\\[cranuser\\d+@controller-\\d.*\\]
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    #NCS:  [root@hz25ah0533r-ah05-3-3r-singlenodecluster-0 ~ ]#    , [cbis-admin@ncs-chris-ac06-1-1l-allinone-0 ~ (Master)]$
    #${matches}   get regexp matches  ${out}
    #  ...   \\[root@\\S+\\s\\S+\\]|\\[cbis-admin@\\S+\\s\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\s\\S+\\]
    ${matches}   get regexp matches  ${out}   ${prompt_oe_server_NCS}
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@compute-\\d+.*\\]
    return from keyword if  ${matches}   OE_SERVER_COMPUTER

    [Return]  GENERAL_LINUX_SERVER



_Get Remote Suite Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}     Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}    OperatingSystem.Join Path    ${base_folder}    ${concated_suite_name}   ${timestamp}
    [Return]    ${suite_log_path}


_Get Remote Case Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}

    ${concated_test_name}    Replace String    ${TEST NAME}    ${SPACE}    _
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("[1]", "")}
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    #${case_log_path}=    OperatingSystem.Join Path    ${base_folder}   ${concated_suite_name}    ${concated_test_name}   ${timestamp}
    ${case_log_path}=    OperatingSystem.Join Path    ${base_folder}     ${concated_test_name}   ${timestamp}
    [Return]    ${case_log_path}


_Get Remote Log Path
    [Arguments]  ${base_folder}=/tmp/tmp_taic
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}    Run Keyword If    "${result[0]}"=="PASS"    _Get Remote Case Log Path   base_folder=${base_folder}
    ...    ELSE    _Get Remote Suite Log Path     base_folder=${base_folder}
    [Return]    ${log_path}


Check VDU Network To Gateway Connection Should Be OK
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]     Check VDU Network To Gateway Connection Should Be OK
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Check VDU Network To Gateway Connection Should Be OK |
    log to console   Check VDU Network To Gateway Connection Should Be OK

    ${oam_gw}   Get VDU OAM Gateway From Testline   ${gnb_index}  ${vdu_index}

    Connect To K8s master
    Host Should Be Pingable From VDU Container   pod_abbr=oam   container=oam   network=oam   target=${oam_gw}

#    ${f1c_route_info}   Get VDU F1-C V4 Route Information From Testline
    ${f1c_route_info}    run keyword if   ':' in '${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.gateway}'
    ...   Get VDU F1-C V6 Route Information From Testline
    ...   ELSE  Get VDU F1-C V4 Route Information From Testline


    evaluate  pprint.pprint(${f1c_route_info})    modules=pprint
    ${f1_c_gw}   set variable  ${f1c_route_info["gw"]}
    Host Should Be Pingable From VDU Container   pod_abbr=oam   container=nwmgmt   network=f1   target=${f1_c_gw}

#    ${f1u_route_info}   Get VDU F1-U V4 Route Information From Testline
    ${f1u_route_info}    run keyword if    ':' in '${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.routing.gateway}'
    ...   Get VDU F1-U V6 Route Information From Testline
    ...   ELSE  Get VDU F1-U V4 Route Information From Testline
    evaluate  pprint.pprint(${f1u_route_info})    modules=pprint
    ${f1_u_gw}   set variable  ${f1u_route_info["gw"]}
    Host Should Be Pingable From VDU Container   pod_abbr=oam   container=nwmgmt   network=f1   target=${f1_u_gw}


Add Route For VDU Up
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias_k8s_tenant}
    [Documentation]   Add Route For VDU Up
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Add Route For VDU Up |
    ...
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}

    ${route}  run keyword if  ':' in '${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.gateway}'
    ...  Get VDU F1-C V6 Route Information From Testline
    ...  ELSE  Get VDU F1-C V4 Route Information From Testline
    ${dest}   set variable  ${route["dest"]}
    ${v4_length}   set variable  ${route["length"]}
    ${v4_gw}   set variable  ${route["gw"]}

    ${cmd}   set variable if  ':' in '${dest}'
    ...  ip -6 route add ${dest}/${v4_length} via ${v4_gw}
    ...  ip route add ${dest}/${v4_length} via ${v4_gw}
    #kubectl exec -it po-cran1-up-0 -c ctr-cran1-nwmgmt -- ip route add 10.97.117.0/24 via 10.71.164.9
    ${out}   Kubectl Exec Interactively    pod_abbr=up    container=nwmgmt   command=${cmd}   alias=${alias_k8s_tenant}
    sleep  2


Do Patch Before Deploy
    [Arguments]   ${remote_yaml_file_info}   ${vdu_index}=0   ${build_number}=${EMPTY}
    [Documentation]   Do Patch Before Deploy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | remote_yaml_file_info    |  Yes | remote_yaml_file_info |
    ...    | vdu_index                |  no | vdu_index, default is 0 |
    ...    | build_number             |  no | vdu_index, default is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Do Patch Before Deploy |
    ...
    log to console  Do Patch Before Deploy
    run keyword and ignore error  Make Docker Images  vdu_index=${vdu_index}   build_number=${build_number}
    run keyword and ignore error  Do Patch Before Deploy For ${build_number}   remote_yaml_file_info=${remote_yaml_file_info}
     ...   vdu_index=${vdu_index}


Do Patch After Deploy
    [Arguments]     ${vdu_index}=0   ${build_number}=${EMPTY}
    [Documentation]   Do Patch After Deploy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    1.09.2020,chris.l.cao@nokia-sbell.com, add 'Set RU Software Compability Flag   flag=${True}'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index                |  no | vdu_index, default is 0 |
    ...    | build_number             |  no | vdu_index, default is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Do Patch After Deploy |
    ...
    log to console  Do Patch After Deploy
    #Disable RU Software Upgrade Permission
    #${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=oamfh
    #VDU Restart Container  pod_abbr=oam   container=${container}

    run keyword and ignore error  Do Patch After Deploy For ${build_number}   vdu_index=${vdu_index}


Make Docker Images
    [Arguments]   ${build_number}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Make Docker Images
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number             |  yes | build_number |
    ...    | vdu_index                |  no | vdu_index, default is 0 |
    ...    | gnb_index                |  no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Docker Images | build_number=0.390.2497 |
    ...
    #for make docker image purpose, update parameter defined in values_0.yaml
    ${conf_vdu_patch_dict}       Get vDU Patch Config Dictionary From TestLine  vdu_index=${vdu_index}
    ${conf_vdu_patch_dict_len}   get length  ${conf_vdu_patch_dict}
    return from keyword if   ${conf_vdu_patch_dict_len}==0
    ${tag_name}  set variable    ${conf_vdu_patch_dict["global"]["tag"]}

    ${container_list}   Evaluate   list(${conf_vdu_patch_dict})
    Remove Values From List   ${container_list}   global

    Delete Images For Specific Tag For VDU   tag_name=${tag_name}    vdu_index=${vdu_index}   gnb_index=${gnb_index}

    FOR  ${container}  IN  @{container_list}
       ${patch_info_level_0}  Get From Dictionary      ${conf_vdu_patch_dict}   ${container}
       ${patch_info_level_1}  Get From Dictionary      ${patch_info_level_0}   dockerfile
       Make One Docker Image  build_number=${build_number}  tag_name=${tag_name}  container=${container}
       ...   dokerfile_content=${patch_info_level_1}
    END


Make One Docker Image
    [Arguments]   ${build_number}   ${tag_name}  ${container}   ${dokerfile_content}   #${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Make Docker Images
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number             |  yes | build_number |
    ...    | tag_name                |  yes | tag_name  |
    ...    | container                |  yes | container |
    ...    | dokerfile_content        |  yes | dokerfile_content |
    ...    | vdu_index                |  no | vdu_index, default is 0 |
    ...    | gnb_index                |  no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make One Docker Image | build_number=0.390.2497 | tag_name=knife | container=l2hi | dokerfile_content=.... |
    ...
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    log to console   --Make One Docker Image--
    log to console   build_number:${build_number}
    log to console   tag_name:${tag_name}
    log to console   container:${container}
    log to console   patch_info:${dokerfile_content}

    ${alias}   Get Unique Id
    connect to k8s master interactively  alias=${alias}
    ${dockerfile_root}  get a remote directory   ${container}_Dockerfile   alias=${alias}
    ${out}   issh.Execute  command=cd ${dockerfile_root}    alias=${alias}
    ${sub_folder_name}   set variable    files
    ${out}   issh.Execute  command=mkdir -p ${sub_folder_name}     alias=${alias}

    ${out}   issh.Execute  command=touch Dockerfile     alias=${alias}
    ${out}   issh.Execute  command=echo FROM registry.kube-system.svc.nokia.net:5555/dep/${container}:${build_number} >> Dockerfile
        ...   alias=${alias}

    ${lines}  Split To Lines   ${dokerfile_content}
    FOR  ${line}  IN   @{lines}
       ${line}   set variable   ${line.strip()}
       Continue For Loop If   ${line.__len__()==0}
       ${First_char}   set variable   ${line.startswith('#')}
       Continue For Loop If   "${First_char}"=="${True}"
       ${tmp}  Split String  ${line}   separator=http:   max_split=1
       ${tmp_len}  get length   ${tmp}
       ${url}   run keyword if   ${tmp_len}==2  _Get URL While making One Docker Image   url_info=${tmp[1]}
       ${base_file_name}  run keyword if   ${tmp_len}==2   _Get Base File Name From URL   url=${url}
       run keyword if   ${tmp_len}==2   _Download a file while making One Docker Image   url=${url}  sub_foldername=${sub_folder_name}
        ...  base_file_name=${base_file_name}   alias=${alias}
       ${actual_line}  run keyword if   ${tmp_len}==2  Replace String  ${line}    ${url}   ${sub_folder_name}/${base_file_name}
       ...   ELSE   set variable  ${line}
      ${out}   issh.Execute  command=echo ${actual_line}>> Dockerfile     alias=${alias}
    END

    ${out}   issh.Execute  command=chmod 754 ${sub_folder_name}/*    alias=${alias}
    ${out}   issh.Execute  command=ls -l ${sub_folder_name}    alias=${alias}
    ${out}   issh.Execute  command=sudo docker build -t registry.kube-system.svc.nokia.net:5555/dep/${container}:${tag_name} -f Dockerfile .
       ...   alias=${alias}


_Get URL While making One Docker Image
    [Arguments]  ${url_info}
    ${url_info}   set variable   ${url_info.strip()}
    ${actual_url_info}   set variable  ${url_info.split()[0]}
    log to console  http:${actual_url_info}
    [Return]  http:${actual_url_info}


_Download a file while making One Docker Image
    [Arguments]  ${url}   ${sub_foldername}   ${base_file_name}   ${alias}
    ${actual_filename}   OperatingSystem.Join Path  ${sub_foldername}   ${base_file_name}
    ${out}   issh.Execute  command=wget ${url} -O ${actual_filename}      alias=${alias}


_Get Base File Name From URL
    [Arguments]  ${url}
    ${base_file_name}   set variable   ${url.split('/')[-1]}
    [Return]  ${base_file_name}


Get Parent Folder
    [Arguments]  ${folder}
    should be true  "${folder}"!="/"
    ${tmp}   evaluate    [i for i in ${folder.split("/")} if len(i)>0]
    [Return]  ${tmp[0]}


Upper List
    [Arguments]  ${list_in}
    [Documentation]  make list elements to upper.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_in                |  yes | list_in |
    ...
    ...    *RETURN VALUE*
    ...    list which contains upper element
    ...
    ...    Example
    ...    | ${my_upper_list} | Upper List | ${my_list1} |
    ...
    ${tmp}   create list
    FOR   ${i}   IN   @{list_in}
       ${tmp_i}   set variable  ${i.upper()}
       append to list  ${tmp}   ${tmp_i}
    END
    [Return]  ${tmp}


List Substract
    [Arguments]  ${listA}  ${listB}
    [Documentation]  List Substract
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | listA | yes | listA |
    ...    | listB | yes | listB |
    ...
    ...    *RETURN VALUE*
    ...    result of listA-listB, type is list
    ...
    ...    Example
    ...    | ${listA} | create list | a | b | cc |
    ...    | ${listB} | create list | a | b |
    ...    | ${result} | List Substract | ${listA} | ${listB} |
    ...    | now ${result} is ['cc']  |
    ${rtn_list}   Evaluate   list(set(${listA})-set(${listB}))
    [Return]  ${rtn_list}


List Contain Another List
    [Arguments]  ${list1}   ${list2}   ${case_sensitive}=${False}
    [Documentation]  List Contain Another List, return ${True} if list1 contains list2, otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    1.27.2021,chris.l.cao@nokia-sbell.com, add QC_ID(QC_123456) as valid tag
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list1                |  yes | list1 |
    ...    | list2                |  yes | list2 |
    ...    | case_sensitive       |  no | default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | List Contain Another List | ${list1} | ${list2} |
    ...
    ${tmp_list1}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list1}
    ...   ELSE   set variable   ${list1}
    ${tmp_list2}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list2}
    ...   ELSE   set variable   ${list2}

    ${rtn}   set variable  ${True}
    FOR  ${i}   IN   @{tmp_list2}
        ${QC_UTE_ID_matches}   get regexp matches  ${i}   ^QC_\\d+$|UTE:ID:
        continue for loop if    ${QC_UTE_ID_matches}
        List Should Contain Value   ${tmp_list1}   ${i}
        #${r}  ${out}   run keyword and ignore error  List Should Contain Value   ${tmp_list1}   ${i}
        #run keyword if  "${r}"!="PASS"   log to console  ${i} is not found in ${tmp_list1}!!
        #${rtn}  set variable if  "${r}"!="PASS"   ${False}   ${rtn}
        #exit for loop if  "${r}"!="PASS"
    END

    [Return]  ${rtn}


List Member Appears In Content
    [Arguments]  ${list_name}   ${content}   ${case_sensitive}=${False}
    [Documentation]  List member appears in content, return ${True} , otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_name            |  yes | list_name |
    ...    | content              |  yes | content |
    ...    | case_sensitive       |  no | default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${list1} | create list  |  text | here |
    ...    | ${r}     | List Member Appears In Content | ${list1} | abcde aerr jkdjsfa here |
    ...    | should be true | "${r}"=="${True}" |
    ...
    ${tmp_list_name}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list_name}
    ...   ELSE   set variable   ${list_name}

    ${tmp_content}    run keyword if  "${case_sensitive}"=="${False}"   set variable  ${content.upper()}
    ...   ELSE   set variable   ${content}

    ${rtn}   set variable  ${False}
    FOR  ${i}   IN   @{tmp_list_name}
        return from keyword if  """${i}""" in """${tmp_content}"""   ${True}
    END

    [Return]  ${rtn}


Get A Random Value From List
    [Arguments]  ${list_name}
    [Documentation]  Get A Random Value From List
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_name            |  yes | list_name |
    ...
    ...    *RETURN VALUE*
    ...    random value in list
    ...
    ...    Example
    ...    | ${list1} | create list  |  1 | 2 | 3 |
    ...    | ${r}     | list_name | ${list1} | ${list1}  |
    ...    | should be true | ${r}>=1 and ${r}<=3 |
    ...
    ${list_len}   get length  ${list_name}
    should be true   ${list_len}>0

    ${list_len_tmp}  evaluate   int(${list_len})-1
    ${random_index}   Evaluate   random.randint(0,int(${list_len_tmp}))    modules=random
    should be true   ${random_index}>=0
    should be true   ${random_index}<${list_len}

    [Return]  ${list_name[${random_index}]}


Compare Version
    [Arguments]  ${v1}   ${v2}   ${operator}=gt
    [Documentation]    Compare Version
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | v1         | yes | version number1 |
    ...    | v2         | yes | version number2 |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${v1}==${v2},gt:${v1}>${v2}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...   Return ${True}
    ...  | ${r} | Compare Version | 0.390.1224 | 0.390.1223 | operator=gt |
    ...
    ...   Return ${False}
    ...  | ${r} | Compare Version | 0.390.1222 | 0.390.1223 | operator=gt |
    ...
    ...   Return ${True}
    ...  | ${r} | Compare Version | 0.390.1222 | 0.390.1223 | operator=le |
    ...
    ...   Return ${True}
    ...  | ${r} | Compare Version | 0.390.1223 | 0.390.1223 | operator=le |
    ...
    ${v1_list}   split string   ${v1}  .
    ${v2_list}   split string   ${v2}  .
    should be true  ${v1_list.__len__()}== ${v2_list.__len__()}
    should be true  ${v1_list.__len__()}==3

    ${operator}   set variable  ${operator.lower()}

    ${v1_sub_version}   set variable  ${v1_list[2]}
    ${v2_sub_version}   set variable  ${v2_list[2]}

    run keyword if  "${operator}"=="gt"   return from keyword if   ${v1_sub_version}>${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="ge"   return from keyword if   ${v1_sub_version}>=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="lt"   return from keyword if   ${v1_sub_version}<${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="le"   return from keyword if   ${v1_sub_version}<=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="ne"   return from keyword if   ${v1_sub_version}!=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="eq"   return from keyword if   ${v1_sub_version}==${v2_sub_version}  ${True}

    [Return]  ${False}


Compare Version Of RU
    [Arguments]  ${v1}   ${v2}   ${operator}=gt
    [Documentation]    Compare Version Of RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | v1         | yes | version number1 |
    ...    | v2         | yes | version number2 |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${v1}==${v2},gt:${v1}>${v2}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...   Return ${True}
    ...  | ${r} | Compare Version Of RU | FRM50.19.R01 | FRM50.10.R01 | operator=gt |
    ...
    ...   Return ${False}
    ...  | ${r} | Compare Version Of RU | FRM50.09.R01 | FRM50.10.R01 | operator=gt |
    ...
    ${operator}   set variable  ${operator.lower()}

    ${r}  run keyword if  "${operator}"=="gt"    Evaluate  "${v1}">"${v2}"
      ...   ELSE IF   "${operator}"=="ge"   Evaluate  "${v1}">="${v2}"
      ...   ELSE IF   "${operator}"=="lt"   Evaluate  "${v1}"<"${v2}"
      ...   ELSE IF   "${operator}"=="le"   Evaluate  "${v1}"<="${v2}"
      ...   ELSE IF   "${operator}"=="ne"   Evaluate  "${v1}"!="${v2}"
      ...   ELSE IF   "${operator}"=="eq"   Evaluate  "${v1}"=="${v2}"
      ...   Fail    Unknown operator:${operator}

    [Return]  ${r}


Load Image For VDU
    [Arguments]   ${build_number}   ${vdu_index}=0
    [Teardown]  run keywords   run keyword and ignore error   issh.set timeout     ${old_timerout2}    alias=${alias_master}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    ...   AND    run keyword and ignore error  issh.set timeout     ${old_timerout}    alias=${alias}
    ...   AND    run keyword and ignore error  issh.Execute   command=rm -rf ${single_pkg_dir}   alias=${alias}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Load Image For VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | build_number | yes | build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Load Image For VDU | build_number=0.390.1222 |
    ...
    ${platform_name}   Get Platform Name

    ${network_release_name}   run keyword if   "${platform_name}"=="NCIR"  Load Image For VDU NCIR
     ...  build_number=${build_number}  vdu_index=${vdu_index}
    ...   ELSE   Load Image For VDU NCS   build_number=${build_number}   vdu_index=${vdu_index}


Load Image For VDU NCIR
    [Arguments]   ${build_number}   #${vdu_index}=0
    [Teardown]  run keywords   run keyword and ignore error   issh.set timeout     ${old_timerout2}    alias=${alias_master}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    ...   AND    run keyword and ignore error  issh.set timeout     ${old_timerout}    alias=${alias}
    ...   AND    run keyword and ignore error  issh.Execute   command=rm -rf ${single_pkg_dir}   alias=${alias}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Load Image For VDU NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | build_number | yes | build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Load Image For VDU | build_number=0.390.1222 |
    ...
    log to console  Load Image For VDU build_number:${build_number}
    ${onBoardApp_pkg_dir}   Download onBoardApp Package To NCIR   build_number=${build_number}

    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively    alias=${alias}

    ${dir_name}   Get Unique ID   prefix=vdupkg_   precise=LOW
    ${single_pkg_dir}  Get A Remote Directory   ${dir_name}  alias=${alias}

    #${zip_file_name}   set variable   vDU-${build_number}.zip
    ${zip_file_name}   set variable if  "${build_number}"=="0.390.1222"   vDU-NCIR-${build_number}.zip    vDU-${build_number}.zip
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/${zip_file_name}

    ${old_timerout}   issh.Set Timeout    900    alias=${alias}
    ${out}   issh.Execute   command=cd ${single_pkg_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${out}   issh.Execute   command=unzip ${zip_file_name}    alias=${alias}

    log to console    ====display disk space after wget single package===
    ${out}   issh.Execute   command=df -h    alias=${alias}
    log to console   ${out}

    ${out}   issh.Execute   command=rm -rf ${zip_file_name}   alias=${alias}

    log to console    ====display disk space after extracting and removing single package===
    ${out}   issh.Execute   command=df -h    alias=${alias}
    log to console   ${out}

    ${out}   issh.Execute   command=cd Images   alias=${alias}

    ${load_image_sh}   OperatingSystem.Join Path  ${onBoardApp_pkg_dir}   onBoardingApp   loadImages.sh
    ${images_properties}   OperatingSystem.Join Path  ${onBoardApp_pkg_dir}   onBoardingApp   images.properties
    ${out}   issh.Execute   command=cp ${load_image_sh} .   alias=${alias}
    ${out}   issh.Execute   command=cp ${images_properties} .   alias=${alias}
    ${out}   issh.Execute   command=chmod 777 *   alias=${alias}

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   alias=${alias_master}
    ${image_folder}   OperatingSystem.Join Path   ${single_pkg_dir}     Images
    ${out}   issh.Execute   command=cd ${image_folder}   alias=${alias_master}
    ${old_timerout2}   issh.Set Timeout    1200    alias=${alias_master}
    ${out}   issh.Execute   command=./loadImages.sh    check_result=${False}   alias=${alias_master}

    log to console    ====display disk space after loading image===
    ${out}   issh.Execute   command=df -h    alias=${alias_master}
    log to console   ${out}

    issh.set timeout     ${old_timerout2}    alias=${alias_master}

    issh.set timeout     ${old_timerout}    alias=${alias}


Load Image For VDU NCS
    [Arguments]   ${build_number}   #${vdu_index}=0
    [Teardown]  run keywords     run keyword and ignore error  issh.set timeout     ${old_timerout}    alias=${alias}
    ...   AND    run keyword and ignore error  issh.Execute   command=rm -rf ${single_pkg_dir}   alias=${alias}
    ...   AND    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Load Image For VDU NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | build_number | yes | build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Load Image For VDU | build_number=0.390.1222 |
    ...
    log to console  Load Image For VDU build_number:${build_number}
    ${onBoardApp_pkg_dir}   Download onBoardApp Package To NCIR   build_number=${build_number}

    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively    alias=${alias}

    ${dir_name}   Get Unique ID   prefix=vdupkg_NCS_   precise=LOW
    ${single_pkg_dir}  Get A Remote Directory   ${dir_name}  alias=${alias}

    ${zip_file_name}   set variable   vDU-${build_number}.zip
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/${zip_file_name}

    ${old_timerout}   issh.Set Timeout    900    alias=${alias}
    ${out}   issh.Execute   command=cd ${single_pkg_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${out}   issh.Execute   command=unzip ${zip_file_name}    alias=${alias}

    log to console    ====display disk space after wget single package===
    ${out}   issh.Execute   command=df -h    alias=${alias}
    #log to console   ${out}

    ${out}   issh.Execute   command=rm -rf ${zip_file_name}   alias=${alias}

    log to console    ====display disk space after extracting and removing single package===
    ${out}   issh.Execute   command=df -h    alias=${alias}
    #log to console   ${out}

    ${out}   issh.Execute   command=cd Images   alias=${alias}

    ${load_image_sh}   OperatingSystem.Join Path  ${onBoardApp_pkg_dir}   onBoardingApp   loadImages.sh
    ${images_properties}   OperatingSystem.Join Path  ${onBoardApp_pkg_dir}   onBoardingApp   images.properties.NCS
    ${out}   issh.Execute   command=cp ${load_image_sh} .   alias=${alias}
    ${out}   issh.Execute   command=cp ${images_properties} .   alias=${alias}
    ${out}   issh.Execute   command=chmod 777 *   alias=${alias}

    issh.Set Timeout    1200    alias=${alias}
    ${out}   issh.Execute   command=./loadImages.sh    check_result=${False}   alias=${alias}
    log to console    ====display disk space after loading image===
    ${out}   issh.Execute   command=df -h    alias=${alias}
    #log to console   ${out}

    issh.set timeout     ${old_timerout}    alias=${alias}


Delete Image For VDU
    [Arguments]   ${except_for_build_number}   #${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}

    [Documentation]   Delete Image For VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Image For VDU | except_for_build_number=0.390.1222 |
    ...
    log to console  Delete Image For VDU except for build_number:${except_for_build_number}

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   alias=${alias_master}

    ${out}   issh.Execute   command=docker images|egrep "0.300.[0-9]+"|grep -v ${except_for_build_number}|awk '{print $3}'   alias=${alias_master}
    ${out}  strip prompt  ${out}
    ${images}   split to lines  ${out}
    FOR   ${image}  IN   @{images}
       log to console  ${image}
       ${out}   issh.Execute   command=docker image rmi ${image} -f   check_result=${False}   alias=${alias_master}
    END

    log to console    ====display disk space before wget single package===
    ${out}   issh.Execute   command=df -hl   check_result=${False}    alias=${alias_master}
    log to console  ${out}

    ${out}   issh.Execute   command=sudo du -sh /var/lib/docker/overlay2   check_result=${False}   alias=${alias_master}
    log to console  ${out}

   # ${out}   issh.Execute   command=sudo docker system prune -a -f   alias=${alias_master}
   # log to console  ${out}


Delete Images For Specific Tag For VDU
    [Arguments]   ${tag_name}   ${vdu_index}=0  #${gnb_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}

    [Documentation]   Delete Image For VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | tag_name | yes | tag_name |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Images For Specific Tag For VDU | tag_name=0.390.1222 |
    ...   | Delete Images For Specific Tag For VDU | tag_name=knife |
    ...
    log to console  Delete Images For Specific Tag For VDU tag:${tag_name}

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   alias=${alias_master}  vdu_index=${vdu_index}  vdu_index=${vdu_index}

    ${out}   issh.Execute   command=docker images|egrep "${tag_name}"|grep -v grep|awk '{print $3}'   alias=${alias_master}
    ${out}  strip prompt  ${out}
    ${images}   split to lines  ${out}
    FOR   ${image}  IN   @{images}
       log to console  ${image}
       ${out}   issh.Execute   command=docker image rmi ${image} -f   check_result=${False}   alias=${alias_master}
    END


Delete Image For VDU NCS
    [Arguments]   ${except_for_build_number}   #${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}

    [Documentation]   Delete Image For VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Image For VDU | except_for_build_number=0.390.1222 |
    ...
    log to console  Delete Image For VDU except for build_number:${except_for_build_number}

    ${alias_master}  get unique id
    Connect To K8s Master with tenant Interactively   alias=${alias_master}

    ${out}   issh.Execute   command=docker images|egrep "0.300.[0-9]+"|grep -v ${except_for_build_number}|awk '{print $3}'   alias=${alias_master}
    ${out}  strip prompt  ${out}
    ${images}   split to lines  ${out}
    FOR   ${image}  IN   @{images}
       log to console  ${image}
       ${out}   issh.Execute   command=docker image rmi ${image} -f   check_result=${False}   alias=${alias_master}
    END

    log to console    ====display disk space before wget single package===
    ${out}   issh.Execute   command=df -hl   check_result=${False}    alias=${alias_master}
    log to console  ${out}


Execute WA Command via CLI
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Execute WA Command via CLI
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Execute WA Command via CLI |
    ...
    log to console  Execute WA Command via CLI
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=sudo find /var/log/audit -name "audit.log.*" -exec setfattr -x system.posix_acl_access {} \\;
    ...   check_result=${False}   alias=${alias_master}
    log to console  ${out}

    ${out}   issh.Execute   command=sudo find /var/log/audit -name "audit.log.*" -exec rm -f {} \\;
    ...   check_result=${False}   alias=${alias_master}
    log to console  ${out}

    #${out}   issh.Execute   command=docker image prune -a -f
    #...   check_result=${False}   alias=${alias_master}
    #log to console  ${out}

    #${out}   issh.Execute   command=sudo docker system prune -a -f
    #...   check_result=${False}   alias=${alias_master}
    #log to console  ${out}

   # ${out}   issh.Execute   command=sudo systemctl restart sriov.service    check_result=${False}  alias=${alias_master}
   # log to console  ${out}

    # ${out}   issh.Execute   command=sudo systemctl restart vfio    check_result=${False}  alias=${alias_master}
    # log to console  ${out}

    return from keyword


    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}

    ${out}  issh.Execute  command=kubectl get pv -n ${ns}|grep "${ns}/"|grep Release|awk '{print $1}'|xargs kubectl delete persistentvolume -n ${ns}
     ...   check_result=${False}
     ...   alias=${alias_master}
    log to console  ${out}
    sleep   5

    ${out}   issh.Execute   command=sudo umount -v /mnt/caas_app/${ns}_*    check_result=${False}  alias=${alias_master}
    sleep   60

    ${cmd}   set variable   kubectl get pv -n ${ns}|grep "${ns}/"|grep Available|awk '{print $1}'
    ${cmd}   set variable  ${cmd} |xargs kubectl delete persistentvolume -n ${ns}
    ${out}  issh.Execute  command=${cmd}  check_result=${False}   alias=${alias_master}
    log to console  ${out}
    sleep   5

    ${out}   issh.Execute   command=sudo rm -rf /mnt/caas_app/${ns}_*    check_result=${False}  alias=${alias_master}
    log to console  ${out}
    sleep  5


Execute WA2 Command via CLI
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Execute WA2 Command via CLI
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Execute WA2 Command via CLI |
    ...
    log to console  Execute WA2 Command via CLI
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=sudo systemctl restart sriov.service    check_result=${False}  alias=${alias_master}
    log to console  ${out}

    ${cmd}   set variable   for i in `dpdk-devbind --status |grep -E "unused=iavf,vfio-pci|drv=vfio-pci"
    ${cmd}   set variable  ${cmd}| awk '{print $1}'`; do sudo driverctl set-override $i iavf; done
    ${out}   issh.Execute   command=${cmd}   check_result=${False}   alias=${alias_master}

    ${out}   issh.Execute   command=sudo systemctl restart vfio.service   check_result=${False}   alias=${alias_master}
    log to console  ${out}

    ${out}   issh.Execute   command=kubectl get po -n kube-system | grep sriovdp-ds|awk '{print $1}'  check_result=${False}  alias=${alias_master}
    ${sriovdp}   strip prompt  ${out}

    ${out}   issh.Execute   command=kubectl delete po ${sriovdp} -n kube-system    check_result=${False}  alias=${alias_master}
    log to console  ${out}

    _Execute WA2 Command via CLI Check sriovdp-ds Is Running   vdu_index=${vdu_index}

    #flannel work around
    ${out}   issh.Execute   command=sudo rm -rf /var/lib/cni/networks/cbr0/10.*   check_result=${False}   alias=${alias_master}
    log to console  ${out}

    sleep   15


_Execute WA2 Command via CLI Check sriovdp-ds Is Running
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    log to console  _Execute WA2 Command via CLI Check sriovdp-ds Is Running
    wait until keyword succeeds  300   15   _Execute WA2 Command via CLI Check sriovdp-ds Is Running Once   vdu_index=${vdu_index}


_Execute WA2 Command via CLI Check sriovdp-ds Is Running Once
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    log to console  _Execute WA2 Command via CLI Check sriovdp-ds Is Running Once
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}
    ${out}   issh.Execute   command=kubectl get po -n kube-system | grep sriovdp-ds|awk '{print $3}'  check_result=${False}  alias=${alias_master}
    ${sriovdp}   strip prompt  ${out}
    should be true  "${sriovdp}"=="Running"


VDU Sync State Should Be OK
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Documentation]   VDU Sync State Should Be OK
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Sync State Should Be OK |
    ...
    log to console  KW:VDU Sync State Should Be OK
    ${platform_name}   Get Platform Name

    run keyword if   "${platform_name}"=="NCIR"  _VDU Sync State Should Be OK NCIR
     ...   vdu_index=${vdu_index}   restart_sync_service=${restart_sync_service}
    ...   ELSE   _VDU Sync State Should Be OK NCS
     ...   vdu_index=${vdu_index}   restart_sync_service=${restart_sync_service}


_VDU Sync State Should Be OK NCIR
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _VDU Sync State Should Be OK NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _VDU Sync State Should Be OK NCIR |
    ...
    log to console  KW:VDU Sync State Should Be OK NCIR
    #${syncState}  Get VDU Sync State  vdu_index=${vdu_index}
    #should be true  "${syncState}"=="true"

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute  command=cat /etc/ptp4l.conf    alias=${alias_master}
    ${out}   issh.Execute  command=cat /etc/sysconfig/phc2sys    alias=${alias_master}
    ${out}   issh.is_dir   path=/var/run/ptp    alias=${alias_master}
    run keyword if  "${out}"=="${False}"    issh.Execute  command=sudo mkdir -p /var/run/ptp   alias=${alias_master}

    run keyword if   "${restart_sync_service}"=="${True}"   log to console  sudo systemctl restart ptp4l & phc2sys
    ${out}   run keyword if   "${restart_sync_service}"=="${True}"
       ...   issh.Execute   command=sudo systemctl restart ptp4l      alias=${alias_master}
    ${out}   run keyword if   "${restart_sync_service}"=="${True}"
       ...  issh.Execute   command=sudo systemctl restart phc2sys    alias=${alias_master}
    run keyword if   "${restart_sync_service}"=="${True}"    sleep  2

    ${out}   issh.Execute   command=systemctl status ptp4l|grep ptp4l|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $7}'
       ...   alias=${alias_master}
    ${freq}   strip prompt  ${out}
    ${freq}   Parse Number Only From Content   ${freq}
    should not be empty   ${freq}
    ${freq}   evaluate  int(${freq})
    should be true  ${freq}<500

    ${out}   issh.Execute   command=systemctl status ptp4l|grep ptp4l|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $11}'
       ...   alias=${alias_master}
    ${delay}   strip prompt  ${out}
    ${delay}   Parse Number Only From Content   ${delay}
    should not be empty   ${delay}
    ${delay}   evaluate  int(${delay})
    should be true  ${delay}<15

    ${out}   issh.Execute   command=systemctl status phc2sys|grep phc2sys|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $7}'
       ...   alias=${alias_master}
    ${freq}   strip prompt  ${out}
    ${freq}   Parse Number Only From Content   ${freq}
    should not be empty   ${freq}
    ${freq}   evaluate  int(${freq})
    should be true  ${freq}<10

    ${out}   issh.Execute   command=systemctl status phc2sys|grep phc2sys|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $11}'
       ...   alias=${alias_master}
    ${delay}   strip prompt  ${out}
    ${delay}   Parse Number Only From Content   ${delay}
    should not be empty   ${delay}
    ${delay}   evaluate  int(${delay})
    should be true  ${delay}<5


_VDU Sync State Should Be OK NCS
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _VDU Sync State Should Be OK NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _VDU Sync State Should Be OK NCS |
    ...
    log to console  KW:VDU Sync State Should Be OK NCS
    ${syncState}      Get VDU Sync State  vdu_index=${vdu_index}
    return from keyword if  "${syncState}"=="OK"

    return from keyword if   "${restart_sync_service}"=="${False}"

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute  command=kubectl get pod -n ncms|grep "linuxptp-daemon-"|awk '{print $1}'
    ...    alias=${alias_master}
    ${ptp_demon_pod_name}   strip prompt  ${out}

    log to console   kubectl delete pod ${ptp_demon_pod_name} -n ncms
    ${out}   issh.Execute  command=kubectl delete pod ${ptp_demon_pod_name} -n ncms
    ...    alias=${alias_master}

    sleep  5

    Wait Unitl VDU K8s Node Services Up     vdu_index=${vdu_index}


Get VDU Sync State
    [Arguments]    ${vdu_index}=0
    [Documentation]   Get VDU Sync State
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | Get VDU Sync State |
    ...
    log to console  Get VDU Sync State
    ${platform_name}   Get Platform Name

    ${syncState}   run keyword if   "${platform_name}"=="NCIR"    _Get VDU Sync State NCIR   vdu_index=${vdu_index}
    ...   ELSE   _Get VDU Sync State NCS   vdu_index=${vdu_index}

    [Return]  ${syncState}


_Get VDU Sync State NCIR
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _Get VDU Sync State NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | _Get VDU Sync State NCIR |
    ...
    log to console   _Get VDU Sync State NCIR
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=sudo pmc -u -b 0 -d 24 'GET TIME_STATUS_NP'|grep gmPresent|awk '{print $2}'
       ...   alias=${alias_master}

    ${syncState}   strip prompt  ${out}
    [Return]  ${syncState}


_Get VDU Sync State NCS
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _Get VDU Sync State NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | _Get VDU Sync State NCS |
    ...
    log to console  _Get VDU Sync State NCS
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=chronyc sources |grep "#* PTP"|wc -l
       ...   alias=${alias_master}

    ${out}   strip prompt  ${out}
    ${syncState}   set variable if   ${out}==1   OK   FAIL
    [Return]  ${syncState}


Get Guest Vlan Flag
    #[Arguments]    ${vdu_index}=0
    [Documentation]   Get Guest Vlan Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...   Example
    ...   | ${guest_vlan_flag} | Get Guest Vlan Flag |
    ...
    ${guest_vlan_flag}   set variable  ${True}
    [Return]  ${guest_vlan_flag}


Get RU Image File Name
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]  Get RU Image File Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     RU Image File Name
    ...
    ...    Example
    ...    | ${rf_image_file} | Get RU Image File Name |
    ...

    run Keyword If  """${TRANS_PARA}"""=="""${NONE}"""   FAIL   there is no ${TRANS_PARA} defined!
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    run Keyword If  """${result}"""=="""FAIL"""   Fail   there is no tools_repository defined in __init__.py!

    ${alias}  get unique id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=ls -l ${TOOLS_INFO["work_folder_data"]}|grep rfsw|wc -l   check_result=${False}   alias=${alias}
    ${count}  strip prompt  ${out}
    should be true  ${count}>=1   Only one rf image file is allowed!

    #${out}   issh.Execute   command=ls -l ${TOOLS_INFO["work_folder_data"]}|grep rfsw|awk '{print $9}'    alias=${alias}
    ${out}   issh.Execute   command=ls -lt ${TOOLS_INFO["work_folder_data"]}|grep rfsw|tail -n 1 |awk '{print $9}'    alias=${alias}

    ${rf_image_file}  strip prompt  ${out}

    [Return]  ${rf_image_file}


Get Case Running Duration
    [Arguments]  ${previous_time}=${EMPTY}
    [Documentation]  Get Case Running Duration
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | previous_time       |  no | previous_time, default value is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...     test case running time, caculate from (<current_time>-${previous_time} ), unit is minute.
    ...
    ...    Example
    ...    |  ${duration} |  Get Case Running Duration |
    ...    |  ${duration} |  Get Case Running Duration | previous_time=2020-12-15 05:53:28 |
    ...
    ${previous_time}   run keyword if  "${previous_time}"=="${EMPTY}"   set variable  ${START_TIME}
    ...   ELSE   set variable  ${previous_time}
    ${current_time}    Get time    exclude_millis=yes
    #${delta}   Subtract Date From Date   ${current_time}   ${START_TIME}    exclude_millis=yes
    ${delta}   Subtract Date From Date   ${current_time}   ${previous_time}    exclude_millis=yes
    ${delta}   evaluate  int(${delta}/60)
    ${delta}   set variable if  ${delta}<1   1   ${delta}
    ${delta}  evaluate  int(${delta})+1
    [Return]  ${delta}


_Clear Temp Directory
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    ${alias}  get unique id
    connect to k8s master interactively   alias=${alias}
    ${ns}  get vdu namespace from testline
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}

    ${sudo}  set variable  sudo
    #${vdu_platform}  Get Platform Name
    #${sudo}  set variable if  "${vdu_platform}"=="NCS"  sudo
    #...   "${vdu_platform}"=="OCP"   ${EMPTY}    ${EMPTY}

    ${out}   issh.Execute  command=${sudo} chmod 777 -R ${tmp_foler_name}   check_result=False  alias=${alias}

    ${is_folder}   issh.is_dir  path=${tmp_foler_name}   alias=${alias}
    return from keyword if  "${is_folder}"=="${False}"

    ${out}  issh.Execute   command=${sudo} rm -rf ${tmp_foler_name}   alias=${alias}
    #${out}   issh.Execute  command=sudo find ${tmp_foler_name} -type d -a -empty -print|xargs rm -rf    alias=${alias}


Disconnect vCU and vDU SCTP Link
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   VDU Get F1 Cplane Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...  CU F1 Cplane Ip Address
    ...    Example
    ...    | Disconnect vCU and vDU SCTP Link |
    ...
    ${cu_f1_cplane_ip}  CU Get F1 Cplane Ip Address   gnb_index=${gnb_index}
    ${vdu_f1_cplane_ip}   VDU Get F1 Cplane Ip Address   gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${cmd}   set variable
     ...   iptables -t mangle -I INPUT 1 -s ${vdu_f1_cplane_ip}/32 -d ${cu_f1_cplane_ip}/32 -p sctp --dport 38472 --sport 38472 -j DROP

    ${alias}   get unique id
    CU SSH To CPIF   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=${cmd}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle    alias=${alias}
    log to console  ${out}


Reconnect vCU and vDU SCTP Link
    #[Arguments]   ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Reconnect vCU and vDU SCTP Link
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Reconnect vCU and vDU SCTP Link |
    ...


    ${cmd}   set variable   iptables -t mangle -D INPUT 1

    ${alias}   get unique id
    CU SSH To CPIF   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle|head -n 5|grep DROP|tail -n 1|wc -l   alias=${alias}
    ${out}   strip prompt  ${out}

    run keyword if  ${out}==0   log to console   Need not reconnect vCU and vDU SCTP Link, becauses its previous SCTP link is OK.
    return from keyword if  ${out}==0

     log to console   Need reconnect vCU and vDU SCTP Link, becauses its previous SCTP link is NOT OK.
    ${out}   issh.Execute   command=${cmd}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle    alias=${alias}
    log to console  ${out}


Ping Result Should Be Expected In VDU WebEM
    [Arguments]    ${expected}
    [Documentation]   Ping Result Should Be Expected In VDU WebEM
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Ping Result Should Be Expected In VDU WebEM | PASSED |
    ...
    ${out}   svdu.Get Ip Connectivity Test Result

    run keyword if   "${expected}"=="EMPTY"   should be true  ${out.__len__()==0}
    return from keyword if   "${expected}"=="EMPTY"

    should be true  ${out.__len__()>=1}
    ${actual}   set variable  ${out[0]}
    ${Test_result}   set variable  ${actual["Test result"]}

    run keyword if   "${expected}"=="PASSED"   should be true  """${Test_result}"""=="""Successful"""
    ...   ELSE IF   "${expected}"=="FAILED"   should be true  """${Test_result}"""=="""Failed"""
    ...   ELSE    Fail   unknown expected value:${expected}


Get Source Address For oamcp oam
    [Documentation]   get source address for oamcp oam
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | ${source_address} | get source address for oamcp oam |
    ...
    ${pod_prefix}   Get Pod Name Prefix
    ${vdu_oam_ip}   Get vDU OAM Ip
    ${source_address}   set variable   OAM_${pod_prefix}oam-0_oam_certman-server ${vdu_oam_ip}
    [Return]  ${source_address}


Get Container File Name
    [Arguments]   ${container}  ${folder}  ${partial_file_name}   ${vdu_index}=0   #${gnb_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection    alias=${alias}
    [Documentation]   Get Container File Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container | yes | container, l1hi, oam, oamfh,etc. |
    ...    | folder | yes | folder, /tmp,etc. |
    ...    | partial_file_name | yes | partial_file_name, like LINUX_startup ,etc. |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${file_name} | Get Container File Name | pod_abbr=up | container=l1hi | folder=/tmp | partial_file_name=LINUX_startup. |
    ...
    ${alias}  get unique id
    connect to k8s master with tenant interactively  alias=${alias}
    ${out}  kubectl exec interactively     container=${container}
            ...   command=ls -l ${folder}|grep ${partial_file_name}|awk '{print $9}'   check_result=False
            ...   vdu_index=${vdu_index}   alias=${alias}
    ${out}  set variable   ${out.strip()}
    [Return]  ${out}


Wait With Logging To Console
    [Arguments]  ${wait_time}=60s  ${log_info}=${EMPTY}
    [Documentation]   Wait With Logging To Console
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | wait_time | no | wait_time, default is 60s |
    ...    | log_info | no | log_info, default is empty |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Wait With Logging To Console | wait_time=30s |
    ...   | Wait With Logging To Console | wait_time=30s | log_info=Wait clearance time passed |
    ...
    run keyword if   "${log_info}"!="${EMPTY}"  log to console  ${log_info}
    sleep  ${wait_time}


Get VDU Node State
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Get VDU Node State
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Ready or NotReady or other state
    ...
    ...    Example
    ...   | ${vdu_node_state} | Get VDU Node State |
    ...
    ${alias}   get unique id
    connect to k8s master interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${out}    issh.Execute   command=sudo kubectl get node|grep -v STATUS| awk '{print $2}'    alias=${alias}
    ${out}   strip prompt   ${out}
    [Return]   ${out}


VDU Node State Should Be OK
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Node State Should Be OK
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | VDU Node State Should Be OK |
    ...
    ${vdu_node_state}   Get VDU Node State   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    should be true   "${vdu_node_state}"=="Ready"


Reboot VDU Node If State Is Not Ready
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Reboot VDU Node If State Is Not Ready
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Reboot VDU Node If State Is Not Ready |
    ...
    ${r}  ${out}   run keyword and ignore error  VDU Node State Should Be OK   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    return from keyword if  "${r}"=="PASS"
    ${alias}   get unique id
    connect to k8s master interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${out}    issh.set_timeout   timeout=60   alias=${alias}
    ${r}   ${out}   run keyword and ignore error   issh.Execute   command=sudo systemctl reboot    check_result=False   alias=${alias}

    Wait Unitl VDU K8s Node Down   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    sleep  60
    Wait Unitl VDU K8s Node Up   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Wait Unitl VDU K8s Node Services Up   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    VDU Node State Should Be OK   gnb_index=${gnb_index}   vdu_index=${vdu_index}


Wait Unitl VDU K8s Node Down
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Wait Unitl VDU K8s Node Services Down
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Wait Unitl VDU K8s Node Down |
    ...
    wait until keyword succeeds   600  20   VDU K8s Node Should Be Down    gnb_index=${gnb_index}   vdu_index=${vdu_index}


VDU K8s Node Should Be Down
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   VDU K8s Node Should Be Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | VDU K8s Node Should Be Up |
    ...
    ${alias}   get unique id
    ${r}  ${out}   run keyword and ignore error
        ...   connect to k8s master interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    should be true   "${r}"=="FAIL"


Wait Unitl VDU K8s Node Up
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Wait Unitl VDU K8s Node Services Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Wait Unitl VDU K8s Node Up |
    ...
    wait until keyword succeeds   600  20   VDU K8s Node Should Be Up    gnb_index=${gnb_index}   vdu_index=${vdu_index}


VDU K8s Node Should Be Up
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   VDU K8s Node Should Be Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | VDU K8s Node Should Be Up |
    ...
    ${alias}   get unique id
    ${r}  ${out}   run keyword and ignore error
        ...   connect to k8s master interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    should be true   "${r}"=="PASS"


Wait Unitl VDU K8s Node Services Up
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Wait Unitl VDU K8s Node Services Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Wait Unitl VDU K8s Node Services Up |
    ...
    wait until keyword succeeds   1000  20   VDU K8s Node Services Should Be Up    gnb_index=${gnb_index}   vdu_index=${vdu_index}


VDU K8s Node Services Should Be Up
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   VDU K8s Node Services Should Be Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | VDU K8s Node Services Should Be Up |
    ...
    ${alias}   get unique id
    connect to k8s master interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}

    ################################ kube-system ################################
    ${out}   issh.Execute   command=kubectl get pod -n kube-system|grep -v Running|grep -v STATE|grep -v READY|wc -l     alias=${alias}
    ${out}   strip prompt  ${out}
    should be True   ${out}==0

    sleep  5
    ${out}   issh.Execute   command=kubectl get pod -n kube-system|grep -v Running|grep -v STATE|grep -v READY|wc -l     alias=${alias}
    ${out}   strip prompt  ${out}
    should be True   ${out}==0

    ${out}   issh.Execute   command=kubectl get pod -n kube-system     alias=${alias}
    log to console   ${out}

    ################################ ncms ################################
    ${out}   issh.Execute   command=kubectl get pod -n ncms|grep -v Running|grep -v STATE|grep -v READY|wc -l     alias=${alias}
    ${out}   strip prompt  ${out}
    should be True   ${out}==0

    sleep    5
    ${out}   issh.Execute   command=kubectl get pod -n ncms|grep -v Running|grep -v STATE|grep -v READY|wc -l     alias=${alias}
    ${out}   strip prompt  ${out}
    should be True   ${out}==0

    sleep    5
    ${out}   issh.Execute   command=kubectl get pod -n ncms|grep -v Running|grep -v STATE|grep -v READY|wc -l     alias=${alias}
    ${out}   strip prompt  ${out}
    should be True   ${out}==0

    ${out}   issh.Execute   command=kubectl get pod -n ncms     alias=${alias}
    log to console   ${out}


Genarate and install additional TA
    [Arguments]  ${cert_number}=15
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Generate Cert CSR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   history change: 11.8.2021, zhiqiang.q2.liu@nokia-sbell.com, add #generate ca.pem, add #install ca, delete vdu rest logout
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | cert_number  |  no  | cert_number, default is 15 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | Generate Cert CSR |
    ...
    ${alias}   get unique id
    connect to ute locally  alias=${alias}
    ${folder_root}   set variable   /opt/ca/root
    ${folder_key}    set variable   ${folder_root}/key
    ${folder_newcerts}   set variable  ${folder_root}/newcerts
    ${file_openssl_cnf_seed}  set variable  ${folder_root}/openssl_seed.cnf
    ${file_serial}       set variable    ${folder_root}/serial
    ${file_cakey_pem}    set variable    ${folder_key}/cakey.pem
    ${file_ca_csr}       set variable    ${folder_key}/ca.csr

    ${out}  issh.Execute  command=sudo rm -rf ${folder_root}   check_result=False   alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_root}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_key}    alias=${alias}
    ${out}  issh.Execute  command=sudo mkdir -p ${folder_newcerts}    alias=${alias}

    #sudo vim /opt/ca/root/openssl.cnf
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${folder_root}/index.txt.attr   alias=${alias}
    ${out}  issh.Execute  command=sudo touch ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo chmod 777 ${file_serial}   alias=${alias}
    ${out}  issh.Execute  command=sudo echo 01 > ${file_serial}   alias=${alias}

    #generate key
    ${out}  issh.Execute  command=sudo openssl genrsa -out ${file_cakey_pem} 2048   alias=${alias}

    #get file_openssl_cnf_seed
    Upload Tools To UTE
    ${file_openssl_cnf_from_tool_repository}   set variable   ${TOOLS_INFO["work_folder_data"]}/${TOOLS_INFO["openssl_cnf"]}
    ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_from_tool_repository} ${file_openssl_cnf_seed}   alias=${alias}

    ${old_prompt}  issh.Get Prompt   alias=${alias}
    ${new_prompt}  set variable   ${old_prompt}|\\s\\[y/n\\]
    issh.Set Prompt     prompt_str=${new_prompt}    alias=${alias}
    vDU Rest Login
    FOR  ${i}  IN RANGE  ${cert_number}
       ${file_openssl_cnf}  set variable  ${folder_root}/openssl_${i}.cnf
       ${file_cert}  set variable   ${folder_key}/cacert_${i}.pem
       log to console  ${file_openssl_cnf}, ${file_cert}
       ${out}  issh.Execute  command=sudo cp ${file_openssl_cnf_seed} ${file_openssl_cnf}   alias=${alias}
       #change CA subject
       ${out}  issh.Execute  command=sudo sed -i 's/iv2trans/iv2trans_${i}/g' ${file_openssl_cnf}   alias=${alias}
       #generate ca.csr
       ${out}  issh.Execute  command=sudo openssl req -new -key ${file_cakey_pem} -out ${file_ca_csr} -config ${file_openssl_cnf}   alias=${alias}
       #generate ca.pem
       ${out}  issh.Execute  command=sudo openssl req -x509 -key ${file_cakey_pem} -outform PEM -out ${file_cert} -config ${file_openssl_cnf}
        ...   alias=${alias}  check_result=False
       #install ca
       ${operationID}  vdu.install_vdu_certificates  cert_file_path=${file_cert}  cert_type=CA
       ${rtn}  wait until keyword succeeds  50   5
        ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    END

############################## vDU TRS end ##############################
====== VDU TRS End ======
     Log To Console  \n*** only used for readable **

############################## FHGW TRS Start ##############################
====== FHGW TRS Start ======
     Log To Console  \n*** only used for readable ***

Upload Tools To FHGW
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]   Upload Tools To FHGW
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | no | vdu_index, default is 0 |
    ...       | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To FHGW |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #Tools download: from tools repostory to FHGW
    Log To Console  Tools: Repostory ---> FHGW
    ${LATEST_VERSION_TOOLS}   _Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_tool_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777

    Set Suite Variable  ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_data_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_data"]}
     ...   permission=777

    Set Suite Variable  ${LATEST_VERSION_DATA}

    ${fhgw_account_info}  Get FHGW Account Info
    ${fhgw_ip}   Set Variable   ${fhgw_account_info["addr"]}
    ${fhgw_root_username}   Set Variable    ${fhgw_account_info["root_username"]}
    ${fhgw_root_password}   Set Variable    ${fhgw_account_info["root_password_plain"]}

    String Should Be An Ip Address  ${fhgw_ip}
    Should Not Be Empty  ${fhgw_root_username}
    Should Not Be Empty  ${fhgw_root_password}

    #from UTE to FHGW
    Log To Console  Tools: UTE ---> FHGW(vdu_index=${vdu_index} fhgw_index=${fhgw_index})
    _Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


    _Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


Upload Tools To Ruproxy
    [Arguments]   ${vdu_index}=0   ${fhgw_index}=0    ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=comm_ta_kw_UploadTools_To_Ruproxy
    [Documentation]   Upload Tools To Ruproxy
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | target    | No | target container, default value is ${EMPTY}, means upload to all VDU containers |
    ...    |           |    | otherwise it should a dictionary to indicate containers where the tools will be uploaded |
    ...    |           |    | dictionary key is pod abbreviation, e.g oamcp, up, value is a list, please see examples |

    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To vDU Containers |
    ...    | ${containers} | create list | oamfh | oam |
    ...    | ${target}     | create dictionary | oamcp=${containers} |
    ...    | Upload Tools To vDU Containers | target=${target} |
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Upload Tools To FHGW   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    Log To Console  Tools: tools repository ---> K8s master node

    ${alias}   Set Variable   comm_ta_kw_UploadTools_To_Ruproxy
    Connect To FHGW   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    ${container_id}  Get Ruproxy Container ID      ru_index=${ru_index}  alias=${alias}
    _Upload Tools From FHGW To Ruproxy    container_id=${container_id}   para_tools_info=${TOOLS_INFO}   alias=${alias}


_Upload Tools From FHGW To Ruproxy
    [Arguments]   ${container_id}    ${para_tools_info}   ${alias}
    Should Not Be Empty   ${container_id}

    #tool
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_tool"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_TOOLS}
     ...   _Upload File From FHGW Host To Container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_tool"]}
     ...   remote_folder_name=${para_tools_info["work_folder_tool"]}
     ...   alias=${alias}

    #data
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_data"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_DATA}
     ...   _Upload File From FHGW Host To Container DO   container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_data"]}
     ...   remote_folder_name=${para_tools_info["work_folder_data"]}
     ...   alias=${alias}


_Upload File From FHGW Host To Container DO
    [Arguments]  ${container_id}   ${local_folder_name}    ${remote_folder_name}    ${alias}
    ${parent_path}  ${dummy}   Split Path  ${remote_folder_name}
    ${out}  Docker Exec By Container ID Interactively   container_id=${container_id}   command=mkdir -p ${parent_path}    alias=${alias}
    ${out}  issh.Execute   command=docker cp ${local_folder_name} ${container_id}:${parent_path}   alias=${alias}


_Get Tools Version Number Inside Container Interactively
    [Arguments]   ${container_id}  ${remote_version_file_name}   ${alias}
    ${out}  Docker Exec By Container ID Interactively    container_id=${container_id}   command=ls -l ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${out}  Docker Exec By Container ID Interactively  container_id=${container_id}   command=cat ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${version_num}  Strip Prompt   content=${out}
    ${version_num}  Set Variable   ${version_num.strip()}
    [Return]    ${version_num}


Clear FHGW Mirror Setting
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=conn_Clear_FHGW_Mirror_Setting
    [Documentation]   Clear FHGW Mirror Setting, it will close all tafssh connections too.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Clear FHGW Mirror Setting |
    ...
    FHGW Switch Clear All Mirror Ports


FHGW Switch Clear All Mirror Ports
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]   FHGW Switch Clear All Mirror Ports
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias     | no | alias to FHGW, default value is default|
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Connect to FHGW |
    ...   | FHGW Switch Clear All Mirror Ports |               |
    ...   | Disconnect From FHGW |
    ...
    ${alias}   get unique id
    connect to fhgw   alias=${alias}
    FOR   ${port}   IN   xe1
       FHGW Switch Set Mirror Port   port=${port}   mode=off    alias=${alias}
    END


FHGW Switch Set Mirror Port
    [Arguments]   ${port}    ${mode}=all  ${alias}=default
    [Documentation]   FHGW Switch Set Mirror Port
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | port        | yes | port name, e.g, xe1, roe8 |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Connect to FHGW |
    ...   | FHGW Switch Clear All Mirror Ports |            |
    ...   | FHGW Switch Set Mirror Port        | ports=xe1 |
    ...   | FHGW Switch Set Mirror Port        | ports=xe1 | mode=All |
    ...   | Disconnect From FHGW |
    ...
    Wait Until Keyword Succeeds  1x   2   _FHGW Switch Set Mirror Port Once   port=${port}    mode=${mode}    alias=${alias}


_FHGW Switch Set Mirror Port Once
    [Arguments]   ${port}   ${alias}=default  ${mode}=all
    [Documentation]   _FHGW Switch Set Mirror Port Once
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | port        | yes | port name, e.g, xe1, roe8 |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | _FHGW Switch Set Mirror Port Once     | ports=xe1 |
    ...   | _FHGW Switch Set Mirror Port Once    | ports=xe1 | mode=All |
    ...
    Should Not Be Empty  ${port}
    ${command}  Set Variable  bcmcmd "dmirror ${port} mode=${mode} dp=xe9"
    ${out}  issh.Execute      command=${command}   alias=${alias}
    Should Not Contain  ${out}   Error:


FHGW Switch Set Mirror
    [Arguments]   ${mirror_type}=Mplane  ${mode}=all
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias_fhgw}
    [Documentation]   FHGW Switch Set Mirror
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | mirror_type      | no | mirror_type, e.g, Mplane, Uplane, default is Mplane |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | FHGW Switch Clear All Mirror Ports |            |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane | mode=off |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane | mode=off |
    ...   | Disconnect Interactive Connection  |
    ...
    #do not use old alias here, in order to imporve stability!
    ${alias_fhgw}   get unique id
    Connect To Fhgw   alias=${alias_fhgw}

    Run Keyword If   "${mirror_type}"=="Mplane"   FHGW Switch Set Mirror Port   port=xe1   mode=${mode}   alias=${alias_fhgw}
    ...   ELSE   fail  ${mirror_type} is not supported yet!


Get Mplane Ip Of RU Proxy
    [Arguments]  ${vdu_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=ta_comm_Get_Mplane_Ip_Of_RU_Proxy
    [Documentation]   Get Mplane Ip Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | ru_index | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...     Mplane ip information of RU proxy inside ruproxy container.  Return type is list, content is [ip, mask, broadcast]
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${alias}   Set Variable  ta_comm_Get_Mplane_Ip_Of_RU_Proxy
    Connect To FHGW    vdu_index=${vdu_index}   alias=${alias}
    ${out}     Ruproxy Kubectl Exec   command=ifconfig mPlaneVlan   alias=${alias}   vdu_index=${vdu_index}    ru_index=${ru_index}
    ${ip}   ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig   content=${out}
    String Should Be An Ip Address  ${ip}
    [Return]  ${ip}  ${mask}   ${broadcast}


Get Mplane Mac Of RU Proxy
    [Arguments]  ${vdu_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=ta_comm_Get_Mplane_Mac_Of_RU_Proxy
    [Documentation]   Get Mplane Mac Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...     Mplane Mac Of RU Proxy
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${alias}   Set Variable  ta_comm_Get_Mplane_Mac_Of_RU_Proxy
    Connect To FHGW    vdu_index=${vdu_index}   alias=${alias}
    ${out}     Ruproxy Kubectl Exec   command=ifconfig mPlaneVlan   alias=${alias}   vdu_index=${vdu_index}    ru_index=${ru_index}
    ${mac}    Parse Mac Address From Ifconfig   content=${out}
    Should Be True  ${mac.__len__()}==17

    [Return]  ${mac}


FHGW Restart Ruproxy
    [Arguments]      ${alias}=default   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Documentation]    FHGW Restart Ruproxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | fhgw_index | No | vdu_index. Default value is 0 |
    ...    | ru_index   | No | ru_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    output of command 'docker restart <docker_id>'
    ...
    ...    Example
    ...    | Connect To FHGW |
    ...    | FHGW Restart Ruproxy |
    ...    | Disconnect Interactive Connection |
    ...
    ${pod_full_name}  Get Ruproxy Full Pod Name      alias=${alias}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  ru_index=${ru_index}
    ${out}   issh.Execute    command=docker ps|grep ${pod_full_name}|grep -v POD|awk '{print $1}'  alias=${alias}
    ${docker_id}  Parse Hex Number Only From Content   content=${out}
    Log To Console  ruproxy(ru_index:${ru_index}):${docker_id}
    ${out}   issh.Execute    command=docker restart ${docker_id}   alias=${alias}
    [Return]  ${out}


Get FHGW Misc
    Run keyword if   """${TRANS_PARA}"""=="""${NONE}"""    log to console   Please check _trans_para in __init__.py!
    return from keyword if   """${TRANS_PARA}"""=="""${NONE}"""  ${EMPTY}

    ${result}  ${fhgw_misc}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["fhgw_misc"]}
    run keyword if  """${result}"""=="""FAIL"""    log to console  Please check _trans_para->fhgw_misc in __init__.py!
    Return From Keyword If  """${result}"""=="""FAIL"""    ${EMPTY}
    [Return]  ${fhgw_misc}


======= RU operation: START =========
     Log To Console   \n*** only used for readable **

Plugout RU Cable
    [Arguments]  ${key}=EQM-1/HWTOP-1/CABLINK-1   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Plugout RU Cable
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | key     | No | redis DB key, default is EQM-1/HWTOP-1/CABLINK-1  |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Plugout RU Cable | |
    ...    | Plugout RU Cable | key=EQM-1/HWTOP-1/CABLINK-2 |
    ...
    ${alias}  get unique id
    connect to fhgw   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}
    ${out}   Set Redis KEY Field   key=${key}  field=adminState   value=0   alias=${alias}
    should contain  ${out}   OK
    ${out}   Get Redis KEY Field   key=${key}  field=adminState     alias=${alias}


Plugin RU Cable
    [Arguments]  ${key}=EQM-1/HWTOP-1/CABLINK-1    ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Plugin RU Cable
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | key     | No | redis DB key, default is EQM-1/HWTOP-1/CABLINK-1  |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Plugin RU Cable |
    ...
    ${alias}  get unique id
    connect to fhgw   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   Set Redis KEY Field   key=${key}  field=adminState   value=1   alias=${alias}
    should contain  ${out}   OK
    ${out}   Get Redis KEY Field   key=${key}  field=adminState     alias=${alias}


Set Redis KEY Field
    [Arguments]  ${key}  ${field}  ${value}   ${alias}=default
    [Documentation]   Set Redis KEY Field
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | key       |  yes | redis DB key  |
    ...    | field     |  yes | field |
    ...    | value     |  yes | value  |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set Redis KEY Field |
    ...
    ${out}   issh.Execute   command=redis-cli -h redis hmset ${key} ${field} ${value}    check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    [Return]  ${out}


Get Redis KEY Field
    [Arguments]  ${key}  ${field}    ${alias}=default
    [Documentation]   Get Redis KEY Field
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | key       |  yes | redis DB key  |
    ...    | field     |  yes | field |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Get Redis KEY Field |
    ...
    ${out}   issh.Execute   command=redis-cli -h redis hmget ${key} ${field}    check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    [Return]  ${out}


Get Connected Ecpri Port
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Get Connected Ecpri Port
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Connected Ecpri Port
    ...
    ...    Example
    ...    | ${EcpriPort} | Get Connected Ecpri Port |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=redis-cli get radioConnectedCpriPort.1   check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    ${out}  strip prompt  ${out}  remove_first_line=False
    [Return]  ${out}


Set Connected Ecpri Port
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Set Connected Ecpri Port to 0
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set Connected Ecpri Port |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=redis-cli set radioConnectedCpriPort.1 0  check_result=${False}    alias=${alias}


Restart FHGW Services
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Restart FHGW Services
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Restart FHGW Services |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=systemctl restart sriov   check_result=${False}    alias=${alias}
    ${out}   issh.Execute   command=systemctl stop switch-manager cpri-switch-config-translator   check_result=${False}    alias=${alias}
    ${out}   issh.Execute   command=systemctl start switch-manager cpri-switch-config-translator   check_result=${False}    alias=${alias}
    [Return]  ${out}


Check Ecpri Port And Correct It If Necessary
    [Documentation]   Check Ecpri Port And Correct It If Necessary
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check Ecpri Port And Correct It If Necessary |
    ...
    ${out}  Get Connected Ecpri Port
    return from keyword if   "0" in ${out}
    Set Connected Ecpri Port
    Restart FHGW Services


Copy File From Ruproxy to RU
    [Arguments]  ${src}  ${dst}   ${alias}=${EMPTY}  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   ${timeout}=150
    [Teardown]   run keyword if   "${alias}"=="${EMPTY}"   run keyword and ignore error  disconnect interactive connection  alias=${proxy_alias}
    [Documentation]    Copy File From Ruproxy to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src            | No | source file name  |
    ...    | dst            | No | dst name |
    ...    | alias            | No | alias name, default value is ${EMPTY} |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 150 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    With giving alias name.
    ...    | Connect to RUPROXY | alias=aliasy |
    ...    | Copy File From Ruproxy to RU | src=/tmp/1.1 | dst=/tmp/1.2 |  alias=aliasy |
    ...    | Disconnect Interactive Connection |  alias=aliasy |
    ...
    ...    Without giving alias name.
    ...    | Copy File From Ruproxy to RU | src=/tmp/1.1 | dst=/tmp/1.2 |
    ...
    log to console  Copy File From Ruproxy to RU
    ${proxy_alias}   run keyword if   "${alias}"=="${EMPTY}"   get unique id
      ...   ELSE   set variable   ${alias}

    run keyword if   "${alias}"=="${EMPTY}"   connect to RUPROXY   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
       ...   alias=${proxy_alias}    ru_index=${ru_index}    timeout=${timeout}

    ${ru_ip}   Get Radio Unit Ip Address   ru_index=${ru_index}

    ${cmd}     set variable  scp -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    #${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=20 -o ServerAliveInterval=15 -l 3000 ${src} root@${ru_ip}:${dst}
    ${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=40 -o ServerAliveInterval=15 ${src} root@${ru_ip}:${dst}
    log to console  ${cmd}
    #${out}     issh.Execute  command=${cmd}   check_result=${False}   alias=${proxy_alias}
    ${out}     issh.Execute  command=${cmd}    alias=${proxy_alias}


Delete File In RU
    [Arguments]   ${dst}    ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   #${timeout}=150
    [Teardown]    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Copy File From Ruproxy to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | dst            | No | dst name |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 150 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    With giving alias name.
    ...    | Delete File In RU | dst=/run/a.txt |
    ...
    log to console  Delete File In RU
    ${alias}     get unique id
    Connect to Radio Unit   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  ru_index=${ru_index}   alias=${alias}
    ${out}   issh.Execute   command=rm -f ${dst}   check_result=${False}   alias=${alias}


Get Radio Unit Ip Address
    [Arguments]   ${ru_index}=1
    [Documentation]    Connect to Radio Unit/connect to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...    *RETURN VALUE*
    ...    RU ip address , e.g, 169.254.1.2
    ...
    ...    Example
    ...    | ${ru_ip} | Get Radio Unit Ip Address |
    ...
    ${ip}   set variable   169.254.${ru_index}.2
    [Return]  ${ip}


Wait Unitil RU IS Up
    [Arguments]   ${ru_index}=1   ${timeout}=300  #${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]   Wait Unitil RU IS Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Wait Unitil RU IS Up |
    ...    | Wait Unitil RU IS Up | timeout=600 |
    ...
    wait until keyword succeeds  ${timeout}  10s   _Wait Unitil RU IS Up Once    ru_index=${ru_index}


_Wait Unitil RU IS Up Once
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Wait Unitil RU IS Up Once
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Wait Unitil RU IS Up Once |
    ...
    ${alias}  get unique id
    connect to radio unit   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}   alias=${alias}

############################## RU operatoin end ##############################


############################## LSS Start ##############################
====== LSS: START ======
     Log To Console  \n*** only used for readable **

Connect To LSS Server
    [Arguments]   ${alias}=default
    [Documentation]   Connect to lss server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | Connect To LSS Server |
    ...
    issh.Connect_to   ip=${LSS_IP_ADDRESS}    username=${LSS_USERNAME}  password=${LSS_PASSWORD}  prompt=\\$   alias=${alias}   width=200
    [Return]  ${alias}

Disconnect From LSS Server
    [Arguments]  ${alias}=default
    [Documentation]    Disconnect From LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Disconnect From LSS Server |
    issh.Disconnect   alias=${alias}

Snapshot Should Exists On LSS Server
    [Arguments]  ${Snapshot_folder_name}   ${alias}=default
    [Documentation]    Snapshot Should Exists On LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | Snapshot_folder_name  |  yes | Snapshot folder name, support regexp |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...    | Snapshot Should Exists On LSS Server |  MRBTS\\-5240.* |
    ${res}=  issh.Execute   command=ls  check_result=${False}  alias=${alias}
    ${match}    Get Regexp Matches    ${res}   ${Snapshot_folder_name}
    Should Be True   ${match}   snapshot not found on lss server with regex match: ${Snapshot_folder_name}
    [Return]    ${match[-1]}

Remove Snapshot Folder On LSS Server
    [Arguments]  ${Snapshot_folder_name}   ${alias}=default
    [Documentation]    Remove Snapshot Folder On LSS Server
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | Snapshot_folder_name  |  yes | snapshot folder name to remove, support wildcard |
    ...    | alias  |  no | aliase name |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Remove Snapshot Folder On LSS Server |  MRBTS-5240* |
    issh.Execute   command=rm -rf ${Snapshot_folder_name}  check_result=${False}  alias=${alias}

############################## LSS End ##############################
====== LSS End ======
     Log To Console  \n*** only used for readable ***



############################## LTE Start ##############################
====== LTE: START ======
     Log To Console  \n*** only used for readable **

Get LTE Gateway Ipv6
    [Teardown]   run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Get LTE Gateway Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    LTE ipv6 gateway ip
    ...
    ...    Example
    ...    | ${gw_ipv6} | Get LTE Gateway Ipv6 |
    ...
    ${alias}   get unique id
    connect to LTE   alias=${alias}
    ${out}   issh.Execute   command=route -n6|grep br1|grep "::/0"|awk '{print $2}'  alias=${alias}
    ${out}   strip prompt   ${out}
    should be true    ${out.__len__()>0}
    [Return]  ${out}


Get LTE Gateway
    [Teardown]   run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Get LTE Gateway of ipv4
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    LTE ipv6 gateway ip
    ...
    ...    Example
    ...    | ${gw_ipv6} | Get LTE Gateway |
    ...
    ${alias}   get unique id
    connect to LTE   alias=${alias}
    ${out}   issh.Execute   command=route -n|grep 0.0.0.0|grep br1|grep UG|awk '{print $2}'   alias=${alias}
    ${out}   strip prompt   ${out}
    should be true    ${out.__len__()>0}
    [Return]  ${out}


############################## LTE End ##############################

Get FHGW Sync State via CLI
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get FHGW Sync State via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${syncStatus} | Get FHGW Sync State via CLI |
    ...
    ${alias}   get unique id
    connect to fhgw  gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}
    ${out}   issh.Execute   command=redis-cli get syncStatus   alias=${alias}
    ${syncStatus}   strip prompt  ${out}
    ${syncStatus}   set variable  ${syncStatus.strip("\"")}
    [Return]  ${syncStatus}


FHGW Sync State Should Be Locked
    #[Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   FHGW Sync State Should Be Locked
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | FHGW Sync State Should Be Locked |
    ...
    ${state}   Get FHGW Sync State via CLI
    should be true   "${state}"=="LOCKED"


Get Guest Vlan Tag
    [Arguments]  ${connection}
    [Documentation]   Get Guest Vlan Tag
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    This KW to check whether VDU is guest vlan or host vlan configuration.
    ...    When guest vlan there won't be vlan configuraiont on ClusterNetwork.
    ...    When host vlan there will be vlan configuraiton on ClusterNetwork, so we use this to check.
    ...    | Input Parameters | Man. | Description |
    ...    | connection  |  no | The K8s master connection session name, none is default |
    ...    *RETURN VALUE*
    ...    Guest vlan tag ${True} or ${False}.
    ...    | Connect To K8s master |
    ...    | ${guesvlan_tag} | Get Guest Vlan Tag |
    ...    | Disconnect From K8s Master |
    ${kubectl_cmd}   set variable
    ${out}   tafssh.Execute    command=kubectl describe cn f1   connection=${connection}
    ${guestvlantag}  Set Variable If  'Vlan' in '''${out}'''   ${False}   ${True}
    [Return]  ${guestvlantag}


Update vDU CMP Server Settings Should Be Successful
    [Arguments]  ${ref_number}   ${psk_key}
    [Documentation]   Update vDU CMP Server Settings Should Be Successful
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number    | yes | Reference Number |
    ...   | psk_key       | yes | Pre-shared Key |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${operationID}  vdu.update_vdu_cmp_server_settings   ref_number=${ref_number}  psk_key=${psk_key}
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}

_Check vDU CMP Operation Should Be Expected
    [Arguments]  ${operationID}  ${expected_status}
    [Documentation]    _Update vDU CMP Server Settings Should Be Expected
    ...   *AUTHOR* Shubin.ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | operationID      | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update vDU CMP Server Settings Should Be Expected |  | expected_status=success |
    ...
    ${out}  vdu.get_trs_api_operation_status  operation_id=${operationID}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Initialize Operator Certificate
    [Arguments]
    [Documentation]   Initialize Operator Certificate
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Initialize Operator Certificate |
    ...
    ${operationID}  vdu.initialize_certificate
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}

Install Operator Certificate on vDU
    [Arguments]
    [Documentation]   Install Operator Certificate on vDU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Install Operator Certificate on vDU |
    ...
    Configure CMP related parameters
    Log To Console    Configure PSK and Ref#
    vDU Rest Login
    Update vDU CMP Server Settings Should Be Successful  ref_number=${CA1_Ref_Num}  psk_key=${CA1_PSK}
    Log To Console    Enroll operator Certificate
    ${oldCertificate}  vdu.get_vdu_certificates
    Initialize Operator Certificate
    vDU Rest Logout
    wait until keyword succeeds  100   5    vDU Rest Login
    ${newCertificate}  vdu.get_vdu_certificates
    Log To Console     ${oldCertificate[0]["details"]["serial_number"]}
    Log To Console     ${newCertificate[0]["details"]["serial_number"]}
    Should Be True   ${oldCertificate[0]["details"]["serial_number"]}!=${newCertificate[0]["details"]["serial_number"]}



Trigger KUR IN Webui
    [Arguments]
    [Documentation]   CMP Key Update
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Initialize Operator Certificate |
    ...
    ${operationID}  vdu.update_cmp_server_key
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}

IF Current Certificate is Default
    [Arguments]
    [Documentation]   IF Current Certificate is Default
    ...   *AUTHOR* shubin.ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    out   Boolean
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | IF Current Certificate is Default |
    ...
    vDU Rest Login
    ${CurrentCertificate}  vdu.get_vdu_certificates
    ${out}  Set Variable If   ${CurrentCertificate[0]["details"]["serial_number"]}==${Default_Certificate_SN}
    ...  ${true}  ${false}
    [Return]  ${out}

Enable Certificate_extension CRL on vDU
    VDU Rest Login
    ${crl_para}    create dictionary     usageEnabled=Enabled  updatePeriod=24
    ...  distributionPointSource=Certificate_extension
    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=MRBTS-${VDU_CONF["mrbts_id"]}/MNL-1/CERTH-1/CRLH-1
    ...    updated_paras_list=${crl_para}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${False}
    ...    auto_lock_cells=${False}
    ...    timeout=60



Disable CRL on vDU
    VDU Rest Login
    ${crl_para}    create dictionary     usageEnabled=Disabled
    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=MRBTS-${VDU_CONF["mrbts_id"]}/MNL-1/CERTH-1/CRLH-1
    ...    updated_paras_list=${crl_para}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${False}
    ...    auto_lock_cells=${False}
    ...    timeout=60

Configure CMP related parameters
    [Arguments]  ${caSubjectName}=${CA1_SubjectName}  ${serverPort}=${CMP1_Server_SingleLayer_PORT}
    [Documentation]    Configure CMP related parameters
    ...   *AUTHOR* zhiqiang.q2.liu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | caSubjectName | no | caSubjectName, default value is DC=cmp, O=nokia, OU=ivtrans, CN=IPsecbackup |
    ...   | serverPort      | no | serverPort, default value is 8080 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Configure CMP related parameters | caSubjectName=${Three_layer_CA_SubjectName} | serverPort=${CMP1_Server_MultiLayer_PORT}
    ...
    Log To Console    Configure CMP related parameters
    ${conf}   Get VDU Conf From SCF
    ${BTS_ID}  set variable   ${conf["mrbts_id"]}
    ${isIPv6}  Check if OAM is IPv6
    ${CMP_Server_IP}  Set Variable If   ${isIPv6}    ${CMP1_Server_IPv6}  ${CMP1_Server_IP}
    ${target_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${BTS_ID}
    ...  caSubjectName=${caSubjectName}
    ...  serverHost=${CMP_Server_IP}
    ...  serverPort=${serverPort}
    ...  serverPath=${CMP1_Server_Path}
    ${CMP_para}  create list  eeSubjectName    caSubjectName    serverHost    serverPort    serverPath
    ${out}  Get Current Parameters Dict   para_list=${CMP_para}   mo=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    Return from keyword if   ${target_dict}==${out}

    vDU Rest Login
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${deleted_dict}   create dictionary
    ...  eeSubjectName=*
    ...  caSubjectName=*
    ...  serverHost=*
    ${add_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${BTS_ID}
    ...  caSubjectName=${caSubjectName}
    ...  serverHost=${CMP_Server_IP}
    ${replaced_dict}  create dictionary
    ...  serverPort=${serverPort}
    ...  serverPath=${CMP1_Server_Path}
    ${out}  Run Keyword And Ignore Error   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...   updated_paras_dict=${deleted_dict}  operation=remove
    ${out}   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...   updated_paras_dict=${add_dict}   operation=add
    ${out}   Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...   updated_paras_dict=${replaced_dict}   operation=replace

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
    Activate Delta Plan By REST  plan_id=${plan_id}

Deintegrate VDU which integration with plan
    log to console   Deintegrate VDU which integration with plan
    ${deintegrate_file_local_path}    Generate Deintegrate Config File which integrate via plan   MRBTS  ${NE_ID}
    ${path_of_config_file}     ${deintegrate_config_file_name}
    ...   Upload Integration Config File To NOM which integrte with plan    MRBTS  ${NE_ID}     ${deintegrate_file_local_path}
    Deintegrate NE From NOM which integrte with plan     MRBTS  ${NE_ID}   ${path_of_config_file}     ${deintegrate_config_file_name}

Check oamTLSstatus Status is Correct
    [Arguments]   ${scf_path}   ${tls_status}
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_path |  Yes   | The path to save scf file |
	...   | tls_status |   Yes   | The target status of oamTlsStatuss|
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Change tls mode  |  ${scf_path}  |  forced |
    Log to Console   Check oamTLSstatus status
    vDU Rest Login
    ${scf_file_with_fullpath}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=runtimescf.xml  include_runtime_data=${True}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    Set Test Variable   ${VDU_CONF}
    ${MPLANENW_R_DISTNAME}   Set Variable    MRBTS-${VDU_CONF["mrbts_id"]}/MNL-1/MNLENT-1/MPLANENW-1/MPLANENW_R-1
    ${oamTlsstatus}    scf.Get_Value_From_Scf     dist_name=${MPLANENW_R_DISTNAME}    p_name=oamTlsStatus
    Should be true   "${oamTlsstatus}"=="${tls_status}"

Change Tls Mode
    [Arguments]   ${scf_path}   ${target_oamTls}
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_path |  Yes   | The path to save scf file |
	...   | target_oamTls |   Yes   | The target value of oamTls|
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Change tls mode  |  ${scf_path}  |  forced |
    Log To Console  Change tls mode
    VDU Rest Login
    sleep   5s
    ${scf_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_fullpath}
    ${current_oamTls}   scf.get_value_from_scf   dist_name=${MPLANENW_DISTNAME}   p_name=oamTls
    Return from keyword if   "${current_oamTls}"=="${target_oamTls}"
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=ChangeTLsMode
    ${oamTls_dict}  create dictionary    oamTls=${target_oamTls}
    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${MPLANENW_DISTNAME}
    ...    updated_paras_list=${oamTls_dict}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${True}
    ...    auto_lock_cells=${False}
    ...    timeout=60
    Sleep   10s

Restore Default Certificates
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | NONE |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Restore Default Certificates |
    ...
    ${operationID}  vdu.restore_default_certificates
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


Import VDU TLS Integrate Plan To NOM
    [Arguments]    ${MRBTS_ID}    ${NE_ID}
    [Documentation]  Import VDU Integrate Plan To NOM.
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  MRBTS_ID  | YES |    |
    ...    |  NE_ID  | YES |    |
    ...   Example
    ...  | Import VDU TLS Integrate Plan To NOM |

    ${import_plantime}   _Get CNMS TimeStamp
    log to console    ${import_plantime}

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info
    ${VDU_OAM_IP}   set variable  ${vdu_oam_http_connection_info["addr"]}

    #${ca_file}=   get file   ${CURDIR}/../../resources/nom/ca1_cacert
    ${ca_file}=   get file    ${CURDIR}/nom/ca1_cacert

    ${Plan_name}   Set Variable    ${MRBTS_ID}-TLS-Integrate${import_plantime[1]}

    ${plan_file}    _Generate TLS Integrate xml File    ${Plan_name}   ${MRBTS_ID}    ${VDU_OAM_IP}   ${NE_ID}   ${ca_file}
    ${integrate_plan}   set variable   ${OUTPUT_DIR}/${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}

    nom_selenium.login     ${NOM_1_WEBUI_LINK}
    nom_selenium.import_plan       ${integrate_plan}    ${Plan_name}    integration_plan
    nom_selenium.logout
    [Return]   ${Plan_name}

_Generate TLS Integrate xml File
    [Arguments]   ${Plan_name}   ${MRBTS_ID}    ${OAM_IP}  ${NE_ID}   ${CACert}
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${MRBTS_ID}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   operation="create" version="1.0"><p name="host">${OAM_IP}</p><p name="port">8443</p>
    ${xml5}   set variable   <p name="neType">MRBTS</p><p name="neId">${NE_ID}</p><p name="username">wsuser</p><p name="password">A0zY~rP#8Mx@</p>
    ${xml6}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml7}   set variable   <p name="tlsHostNameCheck">False</p><p name="tlsCA"><![CDATA[${CACert}]]></p></managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml7}
    [Return]   ${xmlfile}

_Get CNMS TimeStamp
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection   ${connection}
    ${connection}   SSH To NOM
    ${timestamp}    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${connection}
    ${timestamp}    Strip String     ${timestamp}
    ${timestamp}    Split String     ${timestamp}
    log to console    ${timestamp}
    [Return]    ${timestamp}

Install CNMS CA Certificate on vDU
    [Documentation]   Install CNMS04 CA Certificate on vDU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   history change: 11.8.2021, zhiqiang.q2.liu@nokia-sbell.com, delete vdu rest logout
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install CNMS CA Certificate on vDU |
    vDU Rest Login
    ${Result}   _Check If CNMS Cert Exists
    Return from keyword if   ${Result}==True
    #${CNMS_CA_cert}=   set variable  ${CURDIR}/../../resources/nom/srncnms04_ca
    ${CNMS_CA_cert}=   set variable  ${CURDIR}/nom/srncnms04_ca
    ${operationID}  vdu.install_vdu_certificates    cert_file_path=${CNMS_CA_cert}    cert_type=CA
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vDU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}


_Check If CNMS Cert Exists

    @{vDU_Cert_list}  vdu.get_vdu_certificates
    FOR  ${Cert}  IN   @{vDU_Cert_list}
       ${serial_numer}   Set Variable    ${Cert["details"]["serial_number"]}
	   ${Cert_exists}=   run keyword and return if    "${serial_numer}"=="${NOM_1_CA_SN}"   set variable   True
       ${Cert_exists}=   set variable   False
    END
    [Return]    ${Cert_exists}

Get Remote Syslog Server Info
    [Documentation]    get the remote log server info such as server usermane/password
    ...     IP and port, current only one remote log server elastic server in our lab
    ...    So we set the fixed value in this KW, later if it's defined
    ...    in init file then we can update this KW
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Username, password, IP address and port of elastic server
    ...
    ...    Example
    ...    | ${user} | ${pwd} | ${ip} | ${port} | ${prompt} | Get Remote Syslog Server Info |
    ...
    ${user}   set variable   root
    ${pwd}   set variable   c19liu
    ${IP}   set variable   10.70.34.165
    ${port}   set variable   9200
    ${prompt}   set variable   \\[root@master\\S+\\s\\~\\]\\#
    [Return]    ${user}   ${pwd}   ${IP}   ${port}   ${prompt}

############################## VCU TLS start ##############################
Install Operator Certificate on VCU
    [Arguments]
    [Documentation]   Install Operator Certificate on VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Install Operator Certificate on vDU |
    ...
    Configure CMP related parameters on VCU
    Log To Console    Configure PSK and Ref#
    CU Login
    Update VCU CMP Server Settings Should Be Successful  ref_number=${CA1_Ref_Num}  psk_key=${CA1_PSK}
    Log To Console    Enroll operator Certificate
    ${oldCertificate}  cu.get_operator_certificate_list
    #Log To Console   ${oldCertificate}
    Initialize Operator Certificate On VCU
    CU Logout
    wait until keyword succeeds  100   5    CU Login
    ${newCertificate}  cu.get_operator_certificate_list
    #Log To Console     ${oldCertificate[0]["details"]["serial_number"]}
    #Log To Console     ${newCertificate[0]["details"]["serial_number"]}
    Should Be True   ${oldCertificate[0]["details"]["serial_number"]}!=${newCertificate[0]["details"]["serial_number"]}
    #Should Be True   ${oldCertificate[0]["details"].serial_number}!=${newCertificate[0]["details"].serial_number}

Configure CMP related parameters on VCU
    Log To Console    Configure CMP related parameters on VCU
    CU Login
    ${plan_file_path}=    Get A File    SCF    vcu_cmp_scf.xml
    ${SCF_FILE_FULLPATH}  cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    ${BTS_ID}  set variable   ${mrbts_id}

    ${isIPv6}  Check if VCU OAM is IPv6
    ${CMP_Server_IP}  Set Variable If   ${isIPv6}    ${CMP1_Server_IPv6}  ${CMP1_Server_IP}

    ${target_dict}  create dictionary
    ...  eeSubjectName=CN=MRBTS-${BTS_ID}
    ...  caSubjectName=${CA1_SubjectName}
    ...  serverHost=${CMP_Server_IP}
    ...  serverPort=${CMP1_Server_SingleLayer_PORT}
    ...  serverPath=${CMP1_Server_Path}
    ${CMP_para}  create list  eeSubjectName    caSubjectName    serverHost    serverPort    serverPath
    ${out}  Get VCU Current Parameters Dict   para_list=${CMP_para}   mo=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    Return from keyword if   ${target_dict}==${out}

	CU Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

    &{eeSubjectName}=   Create Dictionary    operation_type=remove    parameter_path=/eeSubjectName    value=${Empty}
    &{caSubjectName}=    Create Dictionary    operation_type=remove    parameter_path=/caSubjectName    value=${Empty}
    &{serverHost}=   Create Dictionary    operation_type=remove    parameter_path=/serverHost     value=${Empty}
    @{deleted_List}=    Create List    ${eeSubjectName}    ${caSubjectName}    ${serverHost}

    &{eeSubjectName}=   Create Dictionary    operation_type=add    parameter_path=/eeSubjectName    value=CN=MRBTS-${BTS_ID}
    &{caSubjectName}=    Create Dictionary    operation_type=add    parameter_path=/caSubjectName    value=${CA1_SubjectName}
    &{serverHost}=   Create Dictionary    operation_type=add    parameter_path=/serverHost     value=${CMP_Server_IP}
    @{add_List}=    Create List    ${eeSubjectName}    ${caSubjectName}    ${serverHost}

    &{serverPort}=   Create Dictionary    operation_type=replace    parameter_path=/serverPort    value=${CMP1_Server_SingleLayer_PORT}
    &{serverPath}=    Create Dictionary    operation_type=replace    parameter_path=/serverPath    value=${CMP1_Server_Path}
    @{replaced_List}=    Create List    ${eeSubjectName}    ${caSubjectName}    ${serverHost}

    ${cmp_dn}   set variable   MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${deleted_List}
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${add_List}
    CU Update Delta Plan Should Be Successful   plan_id=${delta_plan_id}  mo_dn=${cmp_dn}   parameter_change_list=${replaced_List}

	CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}


Get VCU Current Parameters Dict
    [Arguments]   ${para_list}    ${mo}    ${vcu_index}=0
    [Documentation]   Get VCU Current Parameters Dict
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}=    Get VCU Current Parameters Dict |
    ...   para_list=${para_list}    mo=${mo} |
    ...
    ${origin_para_value_dict}   create dictionary
    CU Login    gnb_index=${vcu_index}
    ${length}=    get length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${status}  ${value}   Run Keyword And Ignore Error   CU Get Online Parameter Value   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
        Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
    END
    [Return]  &{origin_para_value_dict}
    [Teardown]    CU LOGOUT    ${vcu_index}

Update VCU CMP Server Settings Should Be Successful
    [Arguments]  ${ref_number}   ${psk_key}
    [Documentation]   Update vCU CMP Server Settings Should Be Successful
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | ref_number    | yes | Reference Number |
    ...   | psk_key       | yes | Pre-shared Key |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${out}  cu.update_cmp_server_settings   ref_number=${ref_number}  psk_key=${psk_key}
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}

Initialize Operator Certificate On VCU
    [Arguments]
    [Documentation]   Initialize Operator Certificate On VCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | cu login |
    ...  | Initialize Operator Certificate |
    ...
    ${out}  cu.trigger_certificate_initialization
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}

Check if VCU OAM is IPv6
    #[Arguments]  ${gnb_index}=0
   [Documentation]   Check if VCU OAM is IPv6
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    ${is_ipv6}    boolean
    ...
    ...   Example
    ...    | ${is_ipv6} | Check if OAM is IPv6 |
    ...
    ...
     log to console   Check if VCU OAM is IPv6
     ${vcu_oam_ip}   Get vCU OAM Ip   gnb_index=0
     ${is_ipv6}  set variable if   ":" in "${vcu_oam_ip}"  ${true}  ${false}
     [Return]  ${is_ipv6}

Restore Default Certificates On vCU
    [Documentation]   Restore Default Certificates On vCU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <10-08-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | NONE |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | cu login |
    ...  | Restore Default Certificates On vCU |
    ...
    ${operationID}  cu.restore_default_certificates
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Check vCU CMP Operation Should Be Expected   operationID=${operationID}   expected_status=Successful
    [Return]  ${rtn}

Install Netact CA Certificate on vCU
    [Documentation]   Install CNMS04 CA Certificate on vDU
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Install CNMS CA Certificate on vDU |
    CU Login
    ${Result}   _Check If Netact CA Cert Exists
    Return from keyword if   ${Result}==True
    ${NETACT_CA_cert}=   set variable  ${CURDIR}/nom/clab3766ca.pem
    ${out}  cu.install_operators_certificate    certificate_file_path=${NETACT_CA_cert}   certificate_type=CA
    Should Be True  "${out["status"]}"=="Successful"
    [Return]  ${out}

_Check If Netact CA Cert Exists
    @{vCU_Cert_list}  cu.get_operator_certificate_list
    FOR  ${Cert}  IN   @{vCU_Cert_list}
       ${serial_numer}   Set Variable    ${Cert["details"]["serial_number"]}
       ${Cert_exists}=   run keyword and return if    "${serial_numer}"=="${NETACT_3766_CA_SN}"   set variable   True
       ${Cert_exists}=   set variable   False
    END
    [Return]    ${Cert_exists}

############################## vCU TLS End ##############################
