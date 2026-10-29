*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_fw.robot



*** Variables ***



*** Keywords ***
Add Blackhole For Mplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Add Blackhole For Mplane In VDU, it supports both ipv4 and ipv6
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change:
    ...   15.6.2023,chris.l.cao@nokia-sbell.com, change to 'Connect To VDU Container With Tenant Interactively'
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Add Blackhole For Mplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number},
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console     ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To VDU Container With Tenant Interactively  pod_abbr=oamext  ctr_abbr=nwmgmt   alias=${alias}
    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0
    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ip -6 route add blackhole ${network_address}/${mask_len} table ${table_number}
    ...   ip route add blackhole ${network_address}/${mask_len} table ${table_number}
    issh.Execute  command=${cmd}  alias=${alias}


Delete Blackhole For Mplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Delete Blackhole For Mplane In VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change:
    ...   15.6.2023,chris.l.cao@nokia-sbell.com, change to 'Connect To VDU Container With Tenant Interactively'
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Delete Blackhole For Mplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number}
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console    ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To VDU Container With Tenant Interactively  pod_abbr=oamext  ctr_abbr=nwmgmt   alias=${alias}
    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0
    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ip -6 route del blackhole ${network_address}/${mask_len} table ${table_number}
    ...      ip route del blackhole ${network_address}/${mask_len} table ${table_number}

    issh.Execute  command=${cmd}  alias=${alias}


Add Blackhole For Cplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Add Blackhole For Cplane In VDU, it supports both ipv4 and ipv6
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2, if ${EMPTY}, means to add to main table |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${cu_f1c_ip} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Cplane In VDU | network_address=${cu_f1c_ip} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Cplane In VDU | network_address=${cu_f1c_ip} | mask_len=32 | table_number=2 |
    ...
    ...   | ${cu_f1c_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Cplane In VDU | network_address=${cu_f1c_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Cplane In VDU | network_address=${cu_f1c_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Add Blackhole For Cplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number},
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console     ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To K8s Master Interactively    alias=${alias}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=cprt   alias=${alias}  vdu_index=${vdu_index}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=nwmgmt

    ${cmd}   Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} --

    ${table}    Set Variable If   "${table_number}"!="${EMPTY}"   table ${table_number}   ${EMPTY}
    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ${cmd} ip -6 route add blackhole ${network_address}/${mask_len} ${table}
    ...    ${cmd} ip route add blackhole ${network_address}/${mask_len} ${table}

    issh.Execute  command=${cmd}  alias=${alias}


Delete Blackhole For Cplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Delete Blackhole For Cplane In VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2, if ${EMPTY}, means to add to main table  |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${cu_f1c_ip} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Cplane In VDU | network_address=${cu_f1c_ip} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Cplane In VDU | network_address=${cu_f1c_ip} | mask_len=32 | table_number=2 |
    ...
    ...   | ${cu_f1c_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Cplane In VDU | network_address=${cu_f1c_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Cplane In VDU | network_address=${cu_f1c_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Delete Blackhole For Cplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number}
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console    ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To K8s Master Interactively    alias=${alias}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=cprt   alias=${alias}  vdu_index=${vdu_index}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=nwmgmt

    ${table}    Set Variable If   "${table_number}"!="${EMPTY}"   table ${table_number}   ${EMPTY}
    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} --
    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ${cmd} ip -6 route del blackhole ${network_address}/${mask_len} ${table}
    ...      ${cmd} ip route del blackhole ${network_address}/${mask_len} ${table}

    issh.Execute  command=${cmd}  alias=${alias}


Get OE Server Deployment Information
    [Documentation]    Get OE Server Deployment Information
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    12.7.2022, chris.l.cao@nokia-sbell.com, draft
    ...    09.11.2022, huilin.xu@nokia-sbell.com, add trace ip
    ...    31.3.2023, chris.l.cao@nokia-sbell.com, remove 'Get CloudRAN Version' to set vran4.0 forcelly
    ...    29.6.2023, chris.l.cao@nokia-sbell.com, add f1u_vlan_id, add return value in KW description.
    ...                                In this KW: 'f1' means 'f1c'.
    ...                                In cnf_parameters.yaml->vlan: 'f1' means 'f1u' vlan id.
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...    *RETURN VALUE*
    ...   dictoinary of OE Server Deployment Information, e.g,
    ...         {'f1_link_oe': 'testvlan324',
    ...        'f1_spare_ip': '10.69.73.182',
    ...        'f1_vlan_id': 324,
    ...        'f1net_addr': '10.69.73.176',
    ...        'f1netmask': 29,
    ...        'f1u_link_oe': 'testvlan315',
    ...        'f1u_spare_ip': '10.71.164.142',
    ...        'f1u_vlan_id': 315,
    ...        'f1unet_addr': '10.71.164.136',
    ...        'f1unetmask': 29,
    ...        'fhm_link_oe': 'testvlan295',
    ...        'fhm_spare_ip': '192.168.254.62',
    ...        'fhm_vlan_id': '295',
    ...        'fhmnetmask': 26,
    ...        'interface': 'ens43f0',
    ...        'oam_link_oe': 'testvlan316',
    ...        'oam_spare_ip': '10.71.164.150',
    ...        'oam_vlan_id': 316,
    ...        'oamnet_addr': '10.71.164.144',
    ...        'oamnetmask': '29',
    ...        'trace_gateway': '10.71.164.153',
    ...        'trace_ip': '10.71.164.154',
    ...        'trace_link_oe': 'testvlan314',
    ...        'trace_vlan': 314,
    ...        'tracing_spare_ip': '10.71.164.158',
    ...        'tracingnet_addr': '10.71.164.152',
    ...        'tracingnetmask': '29'}
    ...
    ...    Example
    ...    | ${oe_server_deployment_info} | Get OE Server Deployment Information |
    ...
    Log To Console     Get OE Server Deployment Information
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine
    Log To Console   ${conf_dict}

    # mplane
    ${oam_ip_info}     Get Interface Information For Mplane
    ${oam_vlan}   set variable   ${oam_ip_info['vlan_id']}
    ${oam_vlan}    Convert To Integer    ${oam_vlan}
    ${oamnet_addr}   Set Variable  ${oam_ip_info["subnet_addr"]}
    ${oamnetmask}   Set Variable  ${oam_ip_info["mask"]}
    ${oam_ip}       set variable     ${oam_ip_info['ip']}
    ${broadcast}    set variable     ${oam_ip_info['broadcast']}
    ${oam_spare_ip}  increase ip   ${broadcast}   -1
    ${oam_link_oe}   Set Variable    testvlan${oam_vlan}

    # trace plane
    ${tracingsubnet}   set variable   ${conf_dict["network"]["tracingsubnet"]}
    ${tracingsubnet_list}   Split String  ${tracingsubnet}  /
    ${tracingnetmask}   Set Variable   ${tracingsubnet_list[1]}
    ${tracingnet_addr}   Set Variable   ${tracingsubnet_list[0]}
    ${trace_ip_info}     Get Interface Information For Tcplane
    ${trace_ip}     set variable     ${trace_ip_info['ip']}
    ${broadcast}   Evaluate    str(IPy.IP('${tracingsubnet}').broadcast())   modules=IPy
    ${tracing_spare_ip}  increase ip   ${broadcast}   -1
    ${trace_vlan}    set variable   ${conf_dict["vlan"]["tracing"]}
    ${trace_link_oe}     Set Variable    testvlan${trace_vlan}
    ${trace_gateway}     increase_ip     ${tracingnet_addr}    1

    #f1-c plane
    ${f1_ip_info}     Get Interface Information For F1-Cplane
    ${f1_vlan}   set variable   ${f1_ip_info['vlan_id']}
    ${f1_vlan}    Convert To Integer    ${f1_vlan}
    ${f1net_addr}   Set Variable  ${f1_ip_info["subnet_addr"]}
    ${f1netmask}   Set Variable  ${f1_ip_info["mask"]}
    ${f1_ip}       set variable     ${f1_ip_info['ip']}
    ${broadcast}    set variable     ${f1_ip_info['broadcast']}
    ${f1_spare_ip}  increase ip   ${broadcast}   -1
    ${f1_link_oe}     Set Variable    testvlan${f1_vlan}

    #f1-u plane
    ${f1u_ip_info}     Get Interface Information For F1-Uplane
    ${f1u_vlan}   set variable   ${f1u_ip_info['vlan_id']}
    ${f1u_vlan}    Convert To Integer    ${f1u_vlan}
    ${f1unet_addr}   Set Variable  ${f1u_ip_info["subnet_addr"]}
    ${f1unetmask}   Set Variable  ${f1u_ip_info["mask"]}
    ${f1u_ip}       set variable     ${f1u_ip_info['ip']}
    ${broadcast}    set variable     ${f1u_ip_info['broadcast']}
    ${f1u_spare_ip}  Run Keyword If  ${f1u_vlan}!=${f1_vlan}   increase ip   ${broadcast}   -1
    ...    ELSE   Set Variable   ${f1_spare_ip}
    ${f1u_link_oe}     Set Variable    testvlan${f1u_vlan}

    #FHM-mplane
    ${fhm_ip_info}     Get Interface Information For FHM-plane
    ${fhm_vlan}   set variable     ${fhm_ip_info['vlan_id']}
    ${fhm_ip}     set variable     ${fhm_ip_info['ip']}
    ${broadcast}    set variable     ${fhm_ip_info['broadcast']}
    ${fhm_spare_ip}  increase ip     ${broadcast}   -1
    ${string_mask}    set variable   ${fhm_ip_info['mask']}
    ${ip_with_netmask}   Evaluate    str(IPy.IP('${fhm_ip}').make_net('${string_mask}'))   modules=IPy
    ${fhmnet_split}   Split String  ${ip_with_netmask}  /
    ${fhmnetmask}  Set Variable  ${fhmnet_split[1]}
    ${fhmnetmask}   Convert To Integer   ${fhmnetmask}
    ${fhm_link_oe}  Set Variable    testvlan${fhm_vlan}

    # interface
    ${net_org}   Set Variable     ${conf_dict["network"]["slowPathCommonPool"]}

    ${net_split_1}   Split String  ${net_org}  /
    ${net_split_2}   Split String   ${net_split_1[1]}  _
    ${interface}    Set Variable    ${net_split_2[2]}

    ${rtn}  Create Dictionary  interface=${interface}
      ...   oam_spare_ip=${oam_spare_ip}  oamnet_addr=${oamnet_addr}  oamnetmask=${oamnetmask}  oam_link_oe=${oam_link_oe}  oam_vlan_id=${oam_vlan}
      ...   f1_spare_ip=${f1_spare_ip}  f1net_addr=${f1net_addr}  f1netmask=${f1netmask}   f1_link_oe=${f1_link_oe}  f1_vlan_id=${f1_vlan}
      ...   f1u_spare_ip=${f1u_spare_ip}  f1unet_addr=${f1unet_addr}  f1unetmask=${f1unetmask}   f1u_link_oe=${f1u_link_oe}  f1u_vlan_id=${f1u_vlan}
      ...   fhm_spare_ip=${fhm_spare_ip}    fhmnetmask=${fhmnetmask}   fhm_link_oe=${fhm_link_oe}  fhm_vlan_id=${fhm_vlan}
      ...   tracing_spare_ip=${tracing_spare_ip}  tracingnet_addr=${tracingnet_addr}  tracingnetmask=${tracingnetmask}
      ...   trace_link_oe=${trace_link_oe}  trace_vlan=${trace_vlan}  trace_gateway=${trace_gateway}  trace_ip=${trace_ip}
   [Return]  ${rtn}


Add All Network At OE
    [Arguments]  ${oe_server_deployment_info}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Add All Network At OE
    ...  author:      chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    12.7.2022, chris.l.cao@nokia-sbell.com, add parameter interface, oam_vlan_id, f1_vlan_id
    ...    29.6.2023, chris.l.cao@nokia-sbell.com, add network for f1c
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${oe_server_deployment_info}  | Get OE Server Deployment Information |
    ...    | Add All Network At OE | oe_server_deployment_info=${oe_server_deployment_info} |
    ...
    ${alias}   Get Unique Id
    Connect To K8s Master Interactively  alias=${alias}

    #oam
    ${interface}      Set Variable   ${oe_server_deployment_info["interface"]}
    ${oam_vlan_id}    Set Variable   ${oe_server_deployment_info["oam_vlan_id"]}
    ${oam_dev_name}   Set Variable   ${oe_server_deployment_info["oam_link_oe"]}
    ${oam_spare_ip}   Set Variable   ${oe_server_deployment_info["oam_spare_ip"]}
    ${oamnetmask}     Set Variable   ${oe_server_deployment_info["oamnetmask"]}
    issh.Execute    command=sudo ip link add link ${interface} name ${oam_dev_name} type vlan id ${oam_vlan_id}
    ...       alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip addr add ${oam_spare_ip}/${oamnetmask} dev ${oam_dev_name}
    ...      alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip link set ${oam_dev_name} up   alias=${alias}   check_result=${False}

    #f1-c
    ${f1_vlan_id}     Set Variable   ${oe_server_deployment_info["f1_vlan_id"]}
    ${f1_dev_name}   Set Variable   ${oe_server_deployment_info["f1_link_oe"]}
    ${f1_spare_ip}     Set Variable   ${oe_server_deployment_info["f1_spare_ip"]}
    ${f1netmask}     Set Variable   ${oe_server_deployment_info["f1netmask"]}
    issh.Execute    command=sudo ip link add link ${interface} name ${f1_dev_name} type vlan id ${f1_vlan_id}
    ...       alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip addr add ${f1_spare_ip}/${f1netmask} dev ${f1_dev_name}
    ...      alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip link set ${f1_dev_name} up   alias=${alias}   check_result=${False}

    #f1u
    ${f1u_vlan_id}     Set Variable   ${oe_server_deployment_info["f1u_vlan_id"]}
    ${add_f1u}   Set Variable If  ${f1u_vlan_id}!=${f1_vlan_id}  1  0
    ${f1u_dev_name}   Set Variable If  ${add_f1u}==1   ${oe_server_deployment_info["f1u_link_oe"]}
    ${f1u_spare_ip}   Set Variable If  ${add_f1u}==1   ${oe_server_deployment_info["f1u_spare_ip"]}
    ${f1unetmask}     Set Variable If  ${add_f1u}==1   ${oe_server_deployment_info["f1unetmask"]}
    Run Keyword If  ${add_f1u}==1  issh.Execute    command=sudo ip link add link ${interface} name ${f1u_dev_name} type vlan id ${f1u_vlan_id}
    ...       alias=${alias}   check_result=${False}
    Run Keyword If  ${add_f1u}==1  issh.Execute    command=sudo ip addr add ${f1u_spare_ip}/${f1unetmask} dev ${f1u_dev_name}
    ...      alias=${alias}   check_result=${False}
    Run Keyword If  ${add_f1u}==1  issh.Execute    command=sudo ip link set ${f1u_dev_name} up   alias=${alias}   check_result=${False}

    #FHM
    ${fhm_vlan_id}     Set Variable   ${oe_server_deployment_info["fhm_vlan_id"]}
    ${fhm_dev_name}   Set Variable   ${oe_server_deployment_info["fhm_link_oe"]}
    ${fhm_spare_ip}    Set Variable   ${oe_server_deployment_info["fhm_spare_ip"]}
    ${fhmnetmask}     Set Variable   ${oe_server_deployment_info["fhmnetmask"]}
    issh.Execute    command=sudo ip link add link ${interface} name ${fhm_dev_name} type vlan id ${fhm_vlan_id}
    ...       alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip addr add ${fhm_spare_ip}/${fhmnetmask} dev ${fhm_dev_name}
    ...      alias=${alias}   check_result=${False}
    issh.Execute    command=sudo ip link set ${fhm_dev_name} up   alias=${alias}   check_result=${False}


Delete All Network At OE
    [Arguments]  ${oe_server_deployment_info}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Delete All Network At OE
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    27.10.2022, chris.l.cao@nokia-sbell.com, initialization
    ...    29.6.2023, chris.l.cao@nokia-sbell.com, delete for f1c
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  oe_server_deployment_info |  yes  | oe_server_deployment_info  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${oe_server_deployment_info}  | Get OE Server Deployment Information |
    ...    | Delete All Network At OE | oe_server_deployment_info=${oe_server_deployment_info} |
    ...
    ${alias}   Get Unique Id
    Connect To K8s Master Interactively  alias=${alias}

    #oam
    ${interface}      Set Variable   ${oe_server_deployment_info["interface"]}
    ${oam_dev_name}   Set Variable   ${oe_server_deployment_info["oam_link_oe"]}
    ${f1_dev_name}   Set Variable   ${oe_server_deployment_info["f1_link_oe"]}
    ${f1u_dev_name}   Set Variable   ${oe_server_deployment_info["f1u_link_oe"]}
    ${fhm_dev_name}   Set Variable   ${oe_server_deployment_info["fhm_link_oe"]}

    #oam
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link set ${oam_dev_name} down    alias=${alias}   check_result=${False}
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link del link ${interface} name ${oam_dev_name}   alias=${alias}   check_result=${False}

    #f1
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link set ${f1_dev_name} down    alias=${alias}   check_result=${False}
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link del link ${interface} name ${f1_dev_name}   alias=${alias}   check_result=${False}

    #f1u
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link set ${f1u_dev_name} down    alias=${alias}   check_result=${False}
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link del link ${interface} name ${f1u_dev_name}   alias=${alias}   check_result=${False}

    #FHM
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link set ${fhm_dev_name} down    alias=${alias}   check_result=${False}
    Run Keyword And Ignore Error     issh.Execute
    ...   command=sudo ip link del link ${interface} name ${fhm_dev_name}   alias=${alias}   check_result=${False}


Add All Network At Traffic Server
    [Arguments]  ${oe_server_deployment_info}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Add All Network At Traffic Server
    ...  author:      chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${oe_server_deployment_info}  | Get OE Server Deployment Information |
    ...    | Add All Network At Traffic Server | oe_server_deployment_info=${oe_server_deployment_info} |
    ...
    ${alias}   Connect To Traffic Server

    #oam
    ${interface}      Set Variable   ${TRAFFIC_INTERFACE_VDU}
    ${oam_vlan_id}    Set Variable   ${oe_server_deployment_info["oam_vlan_id"]}
    ${oam_dev_name}   Set Variable   ${oe_server_deployment_info["oam_link_oe"]}
    ${oam_spare_ip}   Set Variable   ${oe_server_deployment_info["oam_spare_ip"]}
    ${oamnetmask}     Set Variable   ${oe_server_deployment_info["oamnetmask"]}
    issh.Execute    command=sudo ip link add link ${interface} name ${oam_dev_name} type vlan id ${oam_vlan_id}
    ...       alias=${alias}   check_result=${False}
    Sleep  2

    issh.Execute    command=sudo ip addr add ${oam_spare_ip}/${oamnetmask} dev ${oam_dev_name}
    ...      alias=${alias}   check_result=${False}
    Sleep  2

    issh.Execute    command=sudo ip link set ${oam_dev_name} up   alias=${alias}   check_result=${False}
    Sleep  2

    #FHM
    ${fhm_vlan_id}     Set Variable   ${oe_server_deployment_info["fhm_vlan_id"]}
    ${fhm_dev_name}   Set Variable   ${oe_server_deployment_info["fhm_link_oe"]}
    ${fhm_spare_ip}    Set Variable   ${oe_server_deployment_info["fhm_spare_ip"]}
    ${fhmnetmask}     Set Variable   ${oe_server_deployment_info["fhmnetmask"]}
    issh.Execute    command=sudo ip link add link ${interface} name ${fhm_dev_name} type vlan id ${fhm_vlan_id}
    ...       alias=${alias}   check_result=${False}
    Sleep  2

    issh.Execute    command=sudo ip addr add ${fhm_spare_ip}/${fhmnetmask} dev ${fhm_dev_name}
    ...      alias=${alias}   check_result=${False}
    Sleep  2

    issh.Execute    command=sudo ip link set ${fhm_dev_name} up   alias=${alias}   check_result=${False}
    Sleep  2


Delete All Network At Traffic Server
    [Arguments]  ${oe_server_deployment_info}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Delete All Network At Traffic Server
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  oe_server_deployment_info |  yes  | oe_server_deployment_info  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${oe_server_deployment_info}  | Get OE Server Deployment Information |
    ...    | Delete All Network At Traffic Server | oe_server_deployment_info=${oe_server_deployment_info} |
    ...
    ${alias}   Connect To Traffic Server

    ${out}   issh.Execute   command=ip -d a|grep testvlan|awk -F "@" '{print $1}'|awk '{print $2}'|grep testvlan --colour=never
    ...    alias=${alias}   check_result=${False}

    ${device_name}  Strip Prompt     ${out}
    ${device_name}  Split To Lines   ${device_name}
    FOR   ${device}  IN  @{device_name}
         Run Keyword And Ignore Error     issh.Execute
    ...      command=sudo ip link set ${device} down    alias=${alias}   check_result=${False}
         Run Keyword And Ignore Error     issh.Execute
    ...      command=sudo ip link del ${device}    alias=${alias}   check_result=${False}
    END


Connect To Traffic Server
    [Documentation]    Connect To Traffic Server
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   Connection instance to traffic server
    ...
    ...    Example
    ...    | ${alias} | Connect To Traffic Server   |
    ...
    ${alias}   Get Unique Id
    ${alias}   Connect To UTE  hostname=${TRAFFIC_SERVER_IP}  username=${TRAFFIC_SERVER_USERNAME}
     ...   password=${TRAFFIC_SERVER_PASSWORD}   alias=${alias}
    [Return]   ${alias}
