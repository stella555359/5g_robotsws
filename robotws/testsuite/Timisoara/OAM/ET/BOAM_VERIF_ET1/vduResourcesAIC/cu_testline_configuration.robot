*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   testline_configuration.robot
...   related to cu configuration from testline config



*** Variables ***



*** Keywords ***
Check if VCU OAM is IPv6
    [Arguments]  ${gnb_index}=0
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
     ${vcu_oam_ip}   Get vCU OAM Ip   gnb_index=${gnb_index}
     ${is_ipv6}  set variable if   ":" in "${vcu_oam_ip}"  ${true}  ${false}
     [Return]  ${is_ipv6}


Get VCU NF Type
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU NF Type
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    VNF or CNF
    ...
    ...   Example
    ...   | ${nf_type} | Get VCU NF Type |
    ...
    ${flavors}   Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.flavors}
    ${nf_type}  set variable if   "${flavors}"=="${None}"   CNF   VNF
    [Return]  ${nf_type}


Get VCU K8s Admin SSH Connection Info
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU K8s Admin SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cbis-admin', 'password': 'systeM!23', 'port': 22}
    ...
    ...    Example
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info |
    ...    | ${vcu_k8s_master_ssh_connection_info} | Get VCU K8s Admin SSH Connection Info | gnb_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH ip in __init__.py for gnb_index=${gnb_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH username in __init__.py for gnb_index=${gnb_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH password in __init__.py for gnb_index=${gnb_index}

    ${result}   ${port}        Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH port in __init__.py for gnb_index=${gnb_index}

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}   port=${port}
    [Return]  ${rtn}


Get VCU K8s Tenant SSH Connection Info
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU K8s Tenant SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cranuser7', 'password': 'systeM!23', 'port': 22}
    ...
    ...    Example
    ...    | ${vcu_k8s_tenant_ssh_connection_info} | Get VCU K8s Tenant SSH Connection Info |
    ...    | ${vcu_k8s_tenant_ssh_connection_info} | Get VCU K8s Tenant SSH Connection Info | gnb_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH ip in __init__.py for gnb_index=${gnb_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH username in __init__.py for gnb_index=${gnb_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH password in __init__.py for gnb_index=${gnb_index}

    ${result}   ${port}        Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    Should Be True  "${result}"=="PASS"    Please give vcu K8s Master SSH port in __init__.py for gnb_index=${gnb_index}

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}   port=${port}
    [Return]  ${rtn}


Get VCU OAM SSH Connection Info
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU OAM Http Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OAM connection information defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'serviceuser', 'password': 'Pl(FzaYj5~c5;q', 'port': 22}
    ...
    ...    Example
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM SSH Connection Info |
    ...

    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give vCU OAM ip in __init__.py for gnb_index=${gnb_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give vDU OAM username in __init__.py for gnb_index=${gnb_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give vDU OAM password in __init__.py for gnb_index=${gnb_index}

    ${port}  set variable  22

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}   port=${port}
    [Return]  ${rtn}


Get VCU F1-C V4 Route Information From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU F1-C V4 Route Information From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU F1-C Route Information
    ...
    ...    Example
    ...    | ${vdu_route_information} | Get VCU F1-C V4 Route Information From Testline |
    ...
    ${v4_dest}   set variable   ${tl.gnbs[${gnb_index}].cu.f1c.v4}
    ${v4_length}   set variable   ${tl.gnbs[${gnb_index}].cu.f1c.routing.ip_prefix_length}
    ${v4_gw}   set variable  ${tl.gnbs[${gnb_index}].cu.f1c.routing.gateway}
    ${rtn}   create dictionary  dest=${v4_dest}   length=${v4_length}   gw=${v4_gw}
    [Return]  ${rtn}


Get VCU F1-U V4 Route Information From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU F1-C V4 Route Information From Testline
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU F1-U Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VCU F1-U V4 Route Information From Testline |
    ...
    ${v4_dest}   set variable   ${tl.gnbs[${gnb_index}].cu.f1u.v4}
    ${v4_length}   set variable   ${tl.gnbs[${gnb_index}].cu.f1u.routing.ip_prefix_length}
    ${v4_gw}   set variable  ${tl.gnbs[${gnb_index}].cu.f1u.routing.gateway}
    ${rtn}   create dictionary  dest=${v4_dest}   length=${v4_length}   gw=${v4_gw}
    [Return]  ${rtn}


Get VCU F1-U V6 Route Information From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU F1-U V6 Route Information From Testline
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU F1-U Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VCU F1-U V6 Route Information From Testline |
    ...
    ${v6_dest}   set variable   ${tl.gnbs[${gnb_index}].cu.f1u.v6}
    ${v6_length}   set variable   ${tl.gnbs[${gnb_index}].cu.f1u.routing.ip_prefix_length}
    ${v6_gw}   set variable  ${tl.gnbs[${gnb_index}].cu.f1u.routing.gateway}
    ${rtn}   create dictionary  dest=${v6_dest}   length=${v6_length}   gw=${v6_gw}
    [Return]  ${rtn}


Get VCU F1-C V6 Route Information From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU F1-C V6 Route Information From Testline
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU F1-C Route Information
    ...
    ...    Example
    ...    | ${vdu_route_information} | Get VCU F1-C V6 Route Information From Testline |
    ...
    ${v6_dest}   set variable   ${tl.gnbs[${gnb_index}].cu.f1c.v6}
    ${v6_length}   set variable   ${tl.gnbs[${gnb_index}].cu.f1c.routing.ip_prefix_length}
    ${v6_gw}   set variable  ${tl.gnbs[${gnb_index}].cu.f1c.routing.gateway}
    ${rtn}   create dictionary  dest=${v6_dest}   length=${v6_length}   gw=${v6_gw}
    [Return]  ${rtn}


Get vCU OAM Ip
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get vCU OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU OAM ip
    ...
    ...    Example
    ...    | ${vcu_oam_ip} | Get vCU OAM Ip |
    ...    | ${vcu_oam_ip} | Get vCU OAM Ip | gnb_index=1 |
    ...

    ${vcu_oam_http_connection_info}   Get vCU OAM Http Connection Info    gnb_index=${gnb_index}
    ${vcu_oam_ip}   set variable  ${vcu_oam_http_connection_info["addr"]}

    [Return]  ${vcu_oam_ip}


Get VCU Heat Env Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU Heat Env Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of Get VCU Heat Env Config Yaml defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get VCU Heat Env Config Yaml From TestLine  |
    ...
    ${yaml_file_name}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].env_files[0]}
    [Return]   ${yaml_file_name}


Get VCU Heat Env Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU Heat Env Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of VCU Heat Env Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get VCU Heat Env Config Dictionary From TestLine  |
    ...
    ${yaml_file}     Get VCU Heat Env Config Yaml From TestLine   gnb_index=${gnb_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get VCU site configuration Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU site_configuration Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file name of site_configuration_0.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get VCU site configuration Yaml From TestLine  |
    ...
    ${yaml_file_name}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].env_files[0]}

    ${conf_path}   ${dummy}   OperatingSystem.Split Path   ${yaml_file_name}
    ${yaml_file_name_site_configuration}   OperatingSystem.Join Path    ${conf_path}   site_configuration_${gnb_index}.yaml
    [Return]   ${yaml_file_name_site_configuration}


Get VCU site configuration Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU site configuration Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of VCU site configuration defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get VCU site configuration Dictionary From TestLine  |
    ...
    ${yaml_file}    Get VCU site configuration Yaml From TestLine  gnb_index=${gnb_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get VCU Cell Number From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU Cell Number From TestLine
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  Cell number from test line configuration
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    ${site_config}  Get VCU site configuration Dictionary From TestLine  gnb_index=${gnb_index}
    ${cell_list}  set variable   ${site_config["CELL_LIST"]}
    ${cell_number}   get length  ${cell_list}
    [return]   ${cell_number}


CU Get F1 Cplane Ip Address
    [Arguments]  ${gnb_index}=0
    [Documentation]   CU Get F1 Cplane Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ip Address
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | CU Get F1 Cplane Ip Address |
    ...

    ${nf_type}   Get VCU NF Type   gnb_index=${gnb_index}
    ${f1_cplane_ip}   Run Keyword If   "${nf_type}"=="VNF"   _CU Get F1 Cplane Ip Address VNF   gnb_index=${gnb_index}
    ...   ELSE   _CU Get F1 Cplane Ip Address CNF   gnb_index=${gnb_index}
    [Return]  ${f1_cplane_ip}


_CU Get F1 Cplane Ip Address VNF
    [Arguments]  ${gnb_index}=0
    [Documentation]   _CU Get F1 Cplane Ip Address VNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ip Address
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | _CU Get F1 Cplane Ip Address VNF |
    ...

    ${conf_dict}  Get VCU Heat Env Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${f1_cplane_ip}   set variable   ${conf_dict["parameters"]["external_networks"]["f1c"]["fixed_ips"][0]["ip_address"]}
    [Return]  ${f1_cplane_ip}


_CU Get F1 Cplane Ip Address CNF
    [Arguments]  ${gnb_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}
    [Documentation]   _CU Get F1 Cplane Ip Address CNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ip Address
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | _CU Get F1 Cplane Ip Address CNF |
    ...
    ${alias}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${out}     CU Kubectl Exec   pod_abbr=cpif   container=cpif   command=ip address show dev f1c   alias=${alias}
    ${f1_cplane_ip}    ${ipv4_mask_len}     Parse ipv4 address   ${out}
    [Return]  ${f1_cplane_ip}


CU Get F1 Cplane Ipv6 Address
    [Arguments]  ${gnb_index}=0
    [Documentation]   CU Get F1 Cplane Ipv6 Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ip Address
    ...
    ...    Example
    ...    | ${F1_cplane_ipv6} | CU Get F1 Cplane Ipv6 Address |
    ...

    ${nf_type}   Get VCU NF Type   gnb_index=${gnb_index}
    ${f1_cplane_ipv6}   Run Keyword If   "${nf_type}"=="VNF"   _CU Get F1 Cplane Ipv6 Address VNF   gnb_index=${gnb_index}
    ...   ELSE   _CU Get F1 Cplane Ipv6 Address CNF   gnb_index=${gnb_index}
    [Return]  ${f1_cplane_ipv6}


_CU Get F1 Cplane Ipv6 Address VNF
    [Arguments]  ${gnb_index}=0
    [Documentation]   _CU Get F1 Cplane Ipv6 Address VNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ipv6 Address
    ...
    ...    Example
    ...    | ${F1_cplane_ipv6} | _CU Get F1 Cplane Ipv6 Address VNF |
    ...

    ${conf_dict}  Get VCU Heat Env Config Dictionary From TestLine  gnb_index=${gnb_index}
    print a dictionary  ${conf_dict}
    ${f1_cplane_ipv6}   set variable   ${conf_dict["parameters"]["external_networks"]["f1c"]["fixed_v6_ips"][0]["ip_address"]}
    [Return]  ${f1_cplane_ipv6}


_CU Get F1 Cplane Ipv6 Address CNF
    [Arguments]  ${gnb_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}
    [Documentation]   _CU Get F1 Cplane Ipv6 Address CNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  CU F1 Cplane Ipv6 Address
    ...
    ...    Example
    ...    | ${F1_cplane_ipv6} | _CU Get F1 Cplane Ipv6 Address CNF |
    ...
    ${alias}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${out}     CU Kubectl Exec   pod_abbr=cpif   container=cpif   command=ip address show dev f1c   alias=${alias}
    ${f1_cplane_ipv6}    ${ipv6_mask_len}     Parse Ipv6 Address   ${out}
    [Return]  ${f1_cplane_ipv6}



Get VCU X2C Ipv6
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU X2C Ipv6
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VCU X2C Ipv6
    ...
    ...    Example
    ...    | ${x2_cplane_ipv6} | Get VCU X2C Ipv6 |
    ...
    ${nf_type}   Get VCU NF Type   gnb_index=${gnb_index}
    ${x2_cplane_ipv6}   Run Keyword If   "${nf_type}"=="VNF"   _Get VCU X2C Ipv6 VNF   gnb_index=${gnb_index}
    ...   ELSE   _Get VCU X2C Ipv6 CNF   gnb_index=${gnb_index}

    [Return]  ${x2_cplane_ipv6}


_Get VCU X2C Ipv6 VNF
    [Arguments]  ${gnb_index}=0
    [Documentation]   _Get VCU X2C Ipv6 VNF
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VCU X2C Ip
    ...
    ...    Example
    ...    | ${x2_cplane_ipv6} | _Get VCU X2C Ipv6 VNF |
    ...
    ${conf_dict}      Get VCU Heat Env Config Dictionary From TestLine
    ${x2_cplane_ipv6}    set variable   ${conf_dict["parameters"]["external_networks"]["x2c"]["fixed_v6_ips"][0]["ip_address"]}
    [Return]  ${x2_cplane_ipv6}


_Get VCU X2C Ipv6 CNF
    [Arguments]  ${gnb_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}
    [Documentation]   _Get VCU X2C Ipv6 CNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    VCU X2C Ip
    ...
    ...    Example
    ...    | ${X2_cplane_ipv6} | _Get VCU X2C Ipv6 CNF |
    ...
    ${alias}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${out}     CU Kubectl Exec   pod_abbr=cpif   container=cpif   command=ip address show dev x2cvlan   alias=${alias}
    ${x2_cplane_ipv6}    ${ipv6_mask_len}     Parse Ipv6 Address   ${out}
    [Return]  ${x2_cplane_ipv6}


Get VCU X2C Ip
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU X2C Ip
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    VCU X2C Ip
    ...
    ...    Example
    ...    | ${X2_cplane_ip} | Get VCU X2C Ip |
    ...
    ${nf_type}   Get VCU NF Type   gnb_index=${gnb_index}
    ${x2_cplane_ip}   Run Keyword If   "${nf_type}"=="VNF"   _Get VCU X2C Ip VNF   gnb_index=${gnb_index}
    ...   ELSE   _Get VCU X2C Ip CNF   gnb_index=${gnb_index}
    [Return]  ${x2_cplane_ip}


_Get VCU X2C Ip VNF
    [Arguments]  ${gnb_index}=0
    [Documentation]   _Get VCU X2C Ip VNF
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VCU X2C Ip
    ...
    ...    Example
    ...    | ${X2_cplane_ip} | _Get VCU X2C Ip VNF |
    ...
    ${conf_dict}      Get VCU Heat Env Config Dictionary From TestLine
    ${x2c_ip}    set variable   ${conf_dict["parameters"]["external_networks"]["x2c"]["fixed_ips"][0]["ip_address"]}

    [Return]  ${X2_cplane_ip}


_Get VCU X2C Ip CNF
    [Arguments]  ${gnb_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}
    [Documentation]   _Get VCU X2C Ip CNF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    VCU X2C Ip
    ...
    ...    Example
    ...    | ${X2_cplane_ip} | _Get VCU X2C Ip CNF |
    ...
    ${alias}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${out}     CU Kubectl Exec   pod_abbr=cpif   container=cpif   command=ip address show dev x2cvlan   alias=${alias}
    ${x2_cplane_ip}    ${ipv4_mask_len}     Parse ipv4 address   ${out}
    [Return]  ${x2_cplane_ip}


#Get Global BTS Id
#    [Arguments]  ${gnb_index}=0
#    [Documentation]  Get Global BTS Id
#    ...  author: chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...  22.9.2021,chris.l.cao@nokia-sbell.com, initialization
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...	   | gnb_index | no | vdu_index, default is 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...     Global BTS Id
#    ...
#    ...    Example
#    ...    | ${global_bts_id} | Get Global BTS Id |
#    ...
#    ${global_bts_id}   Set Variable       ${tl.gnbs[${gnb_index}].global_bts_id}
#    [Return]   ${global_bts_id}
