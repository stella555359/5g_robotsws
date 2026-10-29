*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_testline_configuration.robot
...   related to vdu configuration from testline config




*** Variables ***



*** Keywords ***
Get FHGW Misc
    Run keyword if   """${TRANS_PARA}"""=="""${NONE}"""    log to console   Please check _trans_para in __init__.py!
    return from keyword if   """${TRANS_PARA}"""=="""${NONE}"""  ${EMPTY}

    ${result}  ${fhgw_misc}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["fhgw_misc"]}
    run keyword if  """${result}"""=="""FAIL"""    log to console  Please check _trans_para->fhgw_misc in __init__.py!
    Return From Keyword If  """${result}"""=="""FAIL"""    ${EMPTY}
    [Return]  ${fhgw_misc}



Get vDU Number
    [Arguments]   ${gnb_index}=0
    [Documentation]  Get vDU Number
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vDU number
    ...
    ...    Example
    ...    | ${vDU_number} | Get vDU Number |
    ...
    ${vDU_number}  get length   ${tl.gnbs[${gnb_index}].dus}
    [Return]   ${vDU_number}


Get vDU OAM Ip
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU OAM ip
    ...
    ...    Example
    ...    | ${vdu_oam_ip} | Get vDU OAM Ip |
    ...    | ${vcu_oam_http_connection_info} | Get vDU OAM Ip | vdu_index=1 |
    ...

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    [Return]  ${vdu_oam_ip}

Check if OAM is IPv6
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
   [Documentation]   Check if OAM is IPv6
    ...   *AUTHOR* Shubin.Ren@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    ${is_ipv6}    boolean
    ...
    ...   Example
    ...    | ${is_ipv6} | Check if OAM is IPv6 |
    ...    | ${is_ipv6} | Check if OAM is IPv6 | vdu_index=1 |
    ...
    ...
     log to console   Check if OAM is IPv6
     ${vdu_oam_IP}  Get vDU OAM Ip  gnb_index=${gnb_index}   vdu_index=${vdu_index}
     ${is_ipv6}  set variable if   ":" in "${vdu_oam_IP}"  ${true}  ${false}
     [Return]  ${is_ipv6}


Get VDU K8s Master Node Ip
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Get VDU K8s Master Node Ip
    ...
    ...    Example
    ...    | ${vdu_k8s_master_node_ip} | Get VDU K8s Master Node Ip  |
    ...    | ${vdu_k8s_master_node_ip} | Get VDU K8s Master Node Ip  | vdu_index=1 |
    ...

    ${vdu_k8s_master_ssh_connection_info}  Get K8s Admin SSH Connection Info    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_k8s_master_node_ip}   set variable  ${vdu_k8s_master_ssh_connection_info["addr"]}

    [Return]  ${vdu_k8s_master_node_ip}


Get VDU F1-C V4 Route Information From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU F1-C V4 Route Information From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VDU F1-C V4 Route Information From Testline |
    ...
    ${v4_dest}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.v4}
    ${v4_length}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.ip_prefix_length}
    ${v4_gw}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.gateway}
    ${rtn}   create dictionary  dest=${v4_dest}   length=${v4_length}   gw=${v4_gw}
    [Return]  ${rtn}


Get VDU F1-C V6 Route Information From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU F1-C V6 Route Information From Testline
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VDU F1-C V6 Route Information From Testline |
    ...
    ${v6_dest}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.v6}
    ${v6_length}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.ip_prefix_length}
    ${v6_gw}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.gateway}
    ${rtn}   create dictionary  dest=${v6_dest}   length=${v6_length}   gw=${v6_gw}
    [Return]  ${rtn}


Get VDU F1-U V4 Route Information From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU F1-C V4 Route Information From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VDU F1-U V4 Route Information From Testline |
    ...
    ${v4_dest}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.v4}
    ${v4_length}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.routing.ip_prefix_length}
    ${v4_gw}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.routing.gateway}
    ${rtn}   create dictionary  dest=${v4_dest}   length=${v4_length}   gw=${v4_gw}
    [Return]  ${rtn}


Get VDU F1-U V6 Route Information From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU F1-U V6 Route Information From Testline
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Route Information
    ...
    ...    Example
    ...    | ${vcu_route_information} | Get VDU F1-U V6 Route Information From Testline |
    ...
    ${v6_dest}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.v6}
    ${v6_length}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.routing.ip_prefix_length}
    ${v6_gw}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_u_ip_addr.routing.gateway}
    ${rtn}   create dictionary  dest=${v6_dest}   length=${v6_length}   gw=${v6_gw}
    [Return]  ${rtn}


Get VDU OAM Gateway From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU OAM Gateway From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    OAM gateway
    ...
    ...    Example
    ...    | ${oam_gw} | Get VDU OAM Gateway From Testline |
    ...
    ${vdu_conf}   Get vDU Vnf Config Dictionary From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    evaluate  pprint.pprint(${vdu_conf})    modules=pprint
    ${OAM_info}   VDU Get Network OAM Information   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${oam_gw}    set variable  ${OAM_info["gateway"]}

    [Return]  ${oam_gw}


Get VDU OAM IPv6 Gateway From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU OAM IPv6 Gateway From Testline
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    OAM gateway
    ...
    ...    Example
    ...    | ${oam_gw} | Get VDU OAM IPv6 Gateway From Testline |
    ...
    ${vdu_conf}   Get vDU Vnf Config Dictionary From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    evaluate  pprint.pprint(${vdu_conf})    modules=pprint
    ${oam_gw}   set variable  ${vdu_conf["aic-vdu-oam"]["netConf"]["oam"]["oamDefaultRoute"]["gateway6"]}
    [Return]  ${oam_gw}


Get K8s Tenant SSH Connection Info
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get K8s Tenant SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cranuser1', 'password': 'systeM!23'}
    ...
    ...    Example
    ...    | ${vdu_k8s_tenant_ssh_connection_info} | Get K8s Tenant SSH Connection Info |
    ...    | ${vdu_k8s_tenant_ssh_connection_info} | Get K8s Tenant SSH Connection Info | vdu_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH password in __init__.py for vdu_index=${vdu_index}

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}
    [Return]  ${rtn}



Get vDU Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Vnf Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU Vnf Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    [Return]   ${yaml_file_name}


Get vDU Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Vnf Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vDU Vnf Config Yaml From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vDU Vnf Values Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU Vnf Values Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU values.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU Vnf Values Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ${conf_path}   ${dummy}   OperatingSystem.Split Path   ${yaml_file_name}
    ${yaml_file_name_DEBUG}   OperatingSystem.Join Path    ${conf_path}   aic_vdu_values_0.yaml
    [Return]   ${yaml_file_name_DEBUG}


Get vDU One Click Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU One Click Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU One Click Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU One Click Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/cnf_parameters.yaml

    [Return]   ${yaml_file_name}


Get vDU One Click Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU One Click Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of cnf_parameters.yaml . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU One Click Config Dictionary From TestLine |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get vDU One Click Config Yaml From TestLine  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${r}   ${dummy}  run keyword and ignore error  OperatingSystem.File Should Exist   ${yaml_file}
    return from keyword if  "${r}"=="FAIL"   ${empty_dict}

    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vDU Vnf Values Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU Vnf Values Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU values.yaml. If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU Vnf Values Config Dictionary From TestLine  |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get vDU Vnf Values Config Yaml From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${r}   ${dummy}  run keyword and ignore error  OperatingSystem.File Should Exist   ${yaml_file}
    return from keyword if  "${r}"=="FAIL"   ${empty_dict}

    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}



VDU Get F1 Cplane Ip Address
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get F1 Cplane Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  VDU F1 Cplane Ip Address
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | VDU Get F1 Cplane Ip Address |
    ...

    ${conf_dict}      Get vDU Vnf Config Dictionary From TestLine  gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${f1_cplane_ip}   set variable     ${conf_dict["aic-vdu-cprt"]["netConf"]["f1c"]["ippool"]["ipv4"]["start"]}
    [Return]  ${f1_cplane_ip}


VDU Get Vlan ID
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get Vlan ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  dictionary of Vlan ID
    ...
    ...    Dictionary of vlan id  information defined in cnf_parameters yaml file
    ...    example: {'oam': '11', 'f1': '12', 'l1bip': '13', 'l2bip': '14', 'f1u':'15', 'internal_range':'121-121' }
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | VDU Get Vlan ID |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${oam}   evaluate   str(${conf_dict["vlan"]["oam"]})
    ${f1}    evaluate    str(${conf_dict["vlan"]["f1"]})
    ${l1bip}   evaluate    str(${conf_dict["vlan"]["l1bip"]})
    ${l2bip}   evaluate    str(${conf_dict["vlan"]["l2bip"]})
    ${f1u}   evaluate    str(${conf_dict["vlan"]["xpbip"]})
    ${internal_range}   set variable     ${conf_dict["vlan"]["internal_range"]}

    ${rtn}   create dictionary
      ...   oam=${oam}
      ...   f1=${f1}
      ...   l1bip=${l1bip}
      ...   l2bip=${l2bip}
      ...   f1u=${f1u}
      ...   internal_range=${internal_range}
    [Return]  ${rtn}


VDU Get Network F1 Information
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get Network F1 Information
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  dictionary of F1 network
    ...
    ...    Dictionary of F1 network information defined in cnf_parameters yaml file
    ...    example: {'start': '1.1.1.1', 'end': '1.1.1.1', 'subnet': '1.1.1.0/24', 'gateway': '1.1.1.1'}
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | VDU Get Network F1 Information |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${subnet}   set variable    ${conf_dict["network"]["f1subnet"]}
    ${gateway}  increase_ip    ${subnet}
    ${start}  increase_ip    ${gateway}
    ${end}    set variable   ${start}

    ${rtn}   create dictionary
      ...   start=${start}
      ...   end=${end}
      ...   subnet=${subnet}
      ...   gateway=${gateway}

    [Return]  ${rtn}


VDU Get Network F1 Uplane Information
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get Network F1 Uplane Information
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  dictionary of F1 Uplane network
    ...
    ...    Dictionary of F1 Uplane network information defined in cnf_parameters yaml file
    ...    example: {'start': '1.1.1.1', 'end': '1.1.1.1', 'subnet': '1.1.1.0/24', 'gateway': '1.1.1.1'}
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | VDU Get Network F1 Uplane Information |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${subnet}   set variable    ${conf_dict["network"]["f1subnet"]}
    ${gateway}  increase_ip    ${subnet}
    ${start}  increase_ip    ${gateway}  step=2
    ${end}    set variable   ${start}

    ${rtn}   create dictionary
      ...   start=${start}
      ...   end=${end}
      ...   subnet=${subnet}
      ...   gateway=${gateway}

    [Return]  ${rtn}


VDU Get Network OAM Information
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get Network OAM Information
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   dictionary of OAM network
    ...
    ...   Dictionary of OAM network information defined in cnf_parameters yaml file
    ...   example: {'start': '1.1.1.1', 'end': '1.1.1.1', 'subnet': '1.1.1.0/24', 'gateway': '1.1.1.1'}
    ...
    ...    Example
    ...    | ${OAM_info} | VDU Get Network OAM Information |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${subnet}   set variable    ${conf_dict["network"]["oamsubnet"]}
    ${gateway}  increase_ip    ${subnet}
    ${start}  increase_ip    ${gateway}
    ${end}    set variable   ${start}

    ${rtn}   create dictionary
      ...   start=${start}
      ...   end=${end}
      ...   subnet=${subnet}
      ...   gateway=${gateway}

    [Return]  ${rtn}


VDU Get Network Tracing Information
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Get Network Tracing Information
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  dictionary of Tracing network
    ...
    ...    Dictionary of tracing  network information defined in cnf_parameters yaml file
    ...    example: {'start': '1.1.1.1', 'end': '1.1.1.1', 'subnet': '1.1.1.0/24', 'gateway': '1.1.1.1'}
    ...
    ...    Example
    ...    | ${F1_cplane_ip} | VDU Get Network Tracing Information |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${subnet}   set variable    ${conf_dict["network"]["tracingsubnet"]}
    ${gateway}  increase_ip    ${subnet}
    ${start}  increase_ip    ${gateway}
    ${end}    set variable   ${start}

    ${rtn}   create dictionary
      ...   start=${start}
      ...   end=${end}
      ...   subnet=${subnet}
      ...   gateway=${gateway}

    [Return]  ${rtn}



Get vDU Network Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Network Vnf Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU Network Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU Network Vnf Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.networks[0].yaml_file}
    [Return]   ${yaml_file_name}


Get vDU Network Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Network Vnf Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU Network Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vDU Network Vnf Config Yaml From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vDU PVC Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Network Vnf Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU PVC Vnf Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/aic_pvc_values_override_${vdu_index}.yaml

    [Return]   ${yaml_file_name}


Get vDU PVC Vnf Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU PVC Vnf Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU PVC Vnf Config Dictionary From TestLine   |
    ...
    ${yaml_file}      Get vDU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get TestLine Name From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get TestLine Name From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   test line name, e.g, 7_5_UTEAIC5G001T201
    ...
    ...    Example
    ...    | ${testline_name} |  Get TestLine Name From TestLine |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${testline_name}  set variable  ${cfg_dir.split("/")[-1]}
    [Return]  ${testline_name}


Get TestLine Config Directory From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get TestLine Config Directory From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   test line config directory name, e.g, /home/ute/config/7_5_UTE5GAIC001T041
    ...
    ...    Example


    ...    | ${testline_name} | Get TestLine Config Directory From TestLine |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    [Return]  ${cfg_dir}



Get VDU Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU Release Name From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Release Name From Testline
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU Release Name From Testline |
    ...
    ${release_name}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].name}
    [Return]  ${release_name}


Get VDU PVC Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU PVC Release Name From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU PVC Release Name From Testline
    ...
    ...    Example
    ...    | ${vdu_pvc_release_name} | Get VDU PVC Release Name From Testline |
    ...
    ${vdu_pvc_release_name}   set variable  aic-pvc
    [Return]  ${vdu_pvc_release_name}


Get VDU Network Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get VDU Network Release Name From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Network Release Name From Testline
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU Network Release Name From Testline |
    ...
    ${release_name}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.networks[0].name}
    [Return]  ${release_name}


Get VDU Infrastructure Type
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    ${vdu_config_dict}=   Get vDU Vnf Config Dictionary From TestLine  ${gnb_index}   ${vdu_index}
    Set Test Variable  ${VDU_Infra_Type}   ${vdu_config_dict['infraType']}
    [Return]  ${VDU_Infra_Type}


Modify vDU Chart Value Yaml File For NCIR
    [Arguments]  ${vdu_version}  ${vdu_index}=0  ${gnb_index}=0  ${vdu_chart_name}=aic-vdu
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${Download_Local_Dir}/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close


Get Platform Name
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error    disconnect interactive connection    alias=${alias}
    [Documentation]   Get Platform Name for VDU, which is defined in one click config file
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.9.2021,chris.l.cao@nokia-sbell.com, Fail the KW if platform is not NCIR/NCS/OCP
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...    | vdu_index     |  No | vdu_index, default value is 0 |
    ...
    ...   *RETURN VALUE*
    ...    NCIR or NCS or OCP, otherwise KW fails.
    ...
    ...   Example
    ...   | ${platform} | Get Platform Name |
    ...
    ${conf}   Get vDU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${platform}   set variable if  "NCIR" in "${conf["misc"]["platform_type"]}"    NCIR
     ...   "NCS" in "${conf["misc"]["platform_type"]}"   NCS
     ...   "OCP" in "${conf["misc"]["platform_type"]}"   OCP   UNKNOWN_PLATFORM

    Run Keyword If   "${platform}"=="UNKNOWN_PLATFORM"
         ...   Fail   VDU platform name should be NCIR, NCS, OCP, they are defined in one click config file.

    [Return]  ${platform}


Get RUPROXY DHCP Pool From Testline
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get RUPROXY DHCP Pool From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     dhcp pool
    ...
    ...    Example
    ...    |  ${dhcp_pool} |  Get RUPROXY DHCP Pool From Testline |
    ...
    ${conf_dict_vdu}     Get VDU Vnf Config Dictionary From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${dhcp_pool}   Set Variable   ${conf_dict_vdu["aic-vdu-oam"]["dhcp"]["service"]["v4Pools"]}
    [Return]  ${dhcp_pool}


Get VDU Scf File From Test Line
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${file_name}=vDU_SCF_0.300.xml
    [Documentation]  Get VDU Scf File From Test Line
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vdu_scf} | Get VDU Scf File From Test Line |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${vdu_scf_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/${file_name}
    OperatingSystem.File Should Exist   ${vdu_scf_file_name}

    [Return]   ${vdu_scf_file_name}


Get vDU Secret Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${file_name}=secret.yaml
    [Documentation]  Get vDU Secret Yaml From TestLine
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Secret file name
    ...
    ...    Example
    ...    | ${vdu_scf} | Get vDU Secret Yaml From TestLine |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${vdu_secret_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/${file_name}
    OperatingSystem.File Should Exist   ${vdu_secret_file_name}
    [Return]   ${vdu_secret_file_name}


Get FHGW Namespace From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
    [Documentation]  Get FHGW Namespace From Testline
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    namespace
    ${fhgw_namespace}   set variable  default
    [Return]   ${fhgw_namespace}


Get FHGW Account Info
    [Arguments]  ${gnb_index}=0    ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]  Get FHGW Account Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.9.2021,chris.l.cao@nokia-sbell.com, change root_username to 'root'
    ...   11.10.2021,chris.l.cao@nokia-sbell.com, add support to FHGW22R1
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of FHGW account information as below,
    ...    For FHGW_21
    ...    { 'addr':'1.1.1.1',
    ...               'root_username': 'root',
    ...               'root_password_plain': 'Fhgw@systeM!23',
    ...               'admin_user_name':'_nokfhgwoperator',
    ...               'admin_user_password_plain': 'Fhgw@systeM!23',
    ...               'admin_user_fallback_password_plain': 'Fhgw@systeM!23',
    ...               }
    ...
    ...    For FHGW22R1
    ...    { 'addr':'1.1.1.1',
    ...               'root_username': 'root',
    ...               'root_password_plain': 'Fhgw@systeM!23',
    ...               'admin_user_name': 'toor4nsn',
    ...               'admin_user_password_plain': 'Fhgw@systeM!23',
    ...               'admin_user_fallback_password_plain': '',
    ...               }
    ...
    ...    Example
    ...    | ${fhgw_account_info} | Get FHGW Account Info |
    ...
    ${fhgw_major_version}   Get FHGW Major Version   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ${fhgw_account_info}   Run Keyword If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
#          ...  _Get FHGW Account Info For FHGW_21   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ...   ELSE   _Get FHGW Account Info For 5G22R1
#    ...         gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${fhgw_extra_conf}    Get FHGW Extra Config Dictionary From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${dict_len}   Get Length   ${fhgw_extra_conf}
    Run Keyword If  ${dict_len}==0   Fail   fhgw_extra_config.yaml does not exist!

    ${fhgw_config}   Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${result}   ${ip}   Run Keyword And Ignore Error   Set Variable
      ...   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW ip!

    ${result}   ${root_username}   Run Keyword And Ignore Error   Set Variable   ${fhgw_extra_conf["users"]["root_user_name"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW root_user_name in fhgw_extra_conf!

    ${result}   ${root_password_plain}   Run Keyword And Ignore Error   Set Variable   ${fhgw_extra_conf["users"]["root_user_password"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW root_user_password in fhgw_extra_conf!

    ${admin_user_name}    Set Variable If    "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
       ...  ${fhgw_extra_conf["users"]["operator_user_name"]}   ${fhgw_extra_conf["users"]["service_user_name"]}

    ${admin_user_password_plain}    Set Variable If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
     ...   ${fhgw_extra_conf["users"]["operator_user_password"]}    ${fhgw_extra_conf["users"]["service_user_password"]}

    ${admin_user_fallback_password_plain}   Set Variable If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
          ...  ${fhgw_extra_conf["users"]["operator_user_2nd_password"]}    ${EMPTY}

    ${fhgw_account_info}   create dictionary  addr=${ip}    root_username=${root_username}   root_password_plain=${root_password_plain}
      ...   admin_user_name=${admin_user_name}   admin_user_password_plain=${admin_user_password_plain}
      ...   admin_user_fallback_password_plain=${admin_user_fallback_password_plain}

    [Return]  ${fhgw_account_info}
