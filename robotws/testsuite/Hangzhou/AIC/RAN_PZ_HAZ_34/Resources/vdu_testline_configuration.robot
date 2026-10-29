*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_testline_configuration.robot
...   related to vdu configuration from testline config




*** Variables ***



*** Keywords ***
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

    ${fhgw_major_version}   Get FHGW Major Version   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ${fhgw_account_info}   Run Keyword If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
#          ...  _Get FHGW Account Info For FHGW_21   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ...   ELSE   _Get FHGW Account Info For 5G22R1
#    ...         gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${fhgw_extra_conf}    Get FHGW Extra Config Dictionary From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${dict_len}   Get Length   ${fhgw_extra_conf}
    Run Keyword If  ${dict_len}==0   Fail   fhgw_extra_config.yaml does not exist!

    ${fhgw_config}   _Get FHGW Config Internal Usage   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${result}   ${ip}   Run Keyword And Ignore Error   Set Variable
      ...   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW ip!

    ${result}    ${id}    Run Keyword And Ignore Error    Set Variable    ${fhgw_config["FHGW"]["fhgwId"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW id!

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

    ${fhgw_account_info}   create dictionary  addr=${ip}    fhgw_id=${id}
      ...   root_username=${root_username}   root_password_plain=${root_password_plain}
      ...   admin_user_name=${admin_user_name}   admin_user_password_plain=${admin_user_password_plain}
      ...   admin_user_fallback_password_plain=${admin_user_fallback_password_plain}

    [Return]  ${fhgw_account_info}


Get FHGW Config
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]  Get FHGW Config
    ...  author: chris.l.cao@nokia-sbell.com
    ...    modified by:     <09-24-2021>, <hongysun>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of FHGW config defined in __init__.py
    ...
    ...    Example
    ...    | ${fhgw_config}     | Get FHGW Config |
    ...    | ${fhgw_config}     | Get FHGW Config | vdu_index=1 |
    ...
    Log To Console   'Get FHGW Config' is deprecated! Please use 'Get FHGW Account Info' ...
    ${result}   ${rtn}     Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config}
    Should Be True  "${result}"=="PASS"    Please give FHGW config in __init__.py for vdu_index=${vdu_index},fhgw_index:${fhgw_index}

    ${result_extra_username}   ${extra_username}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_username}

    ${result_extra_password}   ${extra_password}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_password}

    ${rtn_tmp}   run keyword if   "${result_extra_username}"=="PASS"
    ...   Set To Dictionary  ${rtn["USERS"]}  admin_user_name=${extra_username}  admin_user_password_plain=${extra_password}

    ${rtn}   run keyword if   "${result_extra_username}"=="PASS"  Set To Dictionary  ${rtn}  USERS=${rtn_tmp}
    ...   ELSE  set variable  ${rtn}

    [Return]   ${rtn}


_Get FHGW Config Internal Usage
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]    _Get FHGW Config Internal Usage
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   7.7.2022,chris.l.cao@nokia-sbell.com, clone from 'Get FHGW Config', plan to depreciate 'Get FHGW Config'
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of FHGW config defined in fhgw_user_config_0.yaml and fhgw_extra_config.yaml
    ...
    ...    Example
    ...    | ${fhgw_config}     | _Get FHGW Config Internal Usage |
    ...    | ${fhgw_config}     | _Get FHGW Config Internal Usage | vdu_index=1 |
    ...
    ${result}   ${rtn}     Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config}
    Should Be True  "${result}"=="PASS"    Please give FHGW config in __init__.py for vdu_index=${vdu_index},fhgw_index:${fhgw_index}

    ${result_extra_username}   ${extra_username}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_username}

    ${result_extra_password}   ${extra_password}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_password}

    ${rtn_tmp}   run keyword if   "${result_extra_username}"=="PASS"
    ...   Set To Dictionary  ${rtn["USERS"]}  admin_user_name=${extra_username}  admin_user_password_plain=${extra_password}

    ${rtn}   run keyword if   "${result_extra_username}"=="PASS"  Set To Dictionary  ${rtn}  USERS=${rtn_tmp}
    ...   ELSE  set variable  ${rtn}

    [Return]   ${rtn}


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


Get TestLine Config Folder Name
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get TestLine Config Folder Name
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   9.4.2023,chris.l.cao@nokia-sbell.com, change KW name to 'Get TestLine Config Folder Name'
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   test line name, e.g, /home/ute/config/7_5_UTEAIC5G001T201
    ...
    ...    Example
    ...    | ${testline_config_folder} |  Get TestLine Config Folder Name |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    [Return]  ${cfg_dir}


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
    ...    boolean ${True} or ${False}
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


#Get VDU F1-C V6 Route Information From Testline
#    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
#    [Documentation]   Get VDU F1-C V6 Route Information From Testline
#    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
#    ...    |  Input Parameters | Man. | Description |
#    ...	   | gnb_index | no | gnb_index, default is 0 |
#    ...	   | vdu_index | no | vdu_index, default is 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...    VDU Route Information
#    ...
#    ...    Example
#    ...    | ${vcu_route_information} | Get VDU F1-C V6 Route Information From Testline |
#    ...
#    ${v6_dest}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.v6}
#    ${v6_length}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.ip_prefix_length}
#    ${v6_gw}   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].f1_c_ip_addr.routing.gateway}
#    ${rtn}   create dictionary  dest=${v6_dest}   length=${v6_length}   gw=${v6_gw}
#    [Return]  ${rtn}


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


Get Prerequisite Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get Prerequisite Release Name From Testline
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Prerequisite Release Name From Testline
    ...
    ...    Example
    ...    | ${prerequisite_release_name} | Get Prerequisite Release Name From Testline |
    ...
    ${prerequisite_release_name}   set variable  prerequisite
    [Return]  ${prerequisite_release_name}


Get Cluster-preparation Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get Prerequisite Release Name From Testline
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Prerequisite Release Name From Testline
    ...
    ...    Example
    ...    | ${prerequisite_release_name} | Get Prerequisite Release Name From Testline |
    ...
    ${preparation_release_name}   set variable  preparation
    [Return]  ${preparation_release_name}


Get Platform Name
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
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


Get vDU MRBTS_ID From Testline
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get MRBTS ID from test line
    ...  author: lingting.sun@nokia-sbell.com
    ...  modified by:        <23-2-2022>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   mrbts_id, e.g, 10943
    ...
    ...    Example
    ...    | ${mrbts_id} |  Get vDU MRBTS_ID From Testline |
    ...
    ${mrbts_id_temp}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].global_bts_id}
    ${mrbts_id}   set variable if  ${mrbts_id_temp} == None   ${tl.gnbs[0].instance_id}
    ...      ${mrbts_id_temp} != None    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].global_bts_id}

    [Return]  ${mrbts_id}


Get PA port
    [Arguments]  ${pa_index}
    [Documentation]  Get PA port
    ...  author: calla.wang@nokia-sbell.com
    ...  modified by:        <21-7-2022>, <calla.wang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...	   | pa_index | yes | pa_index for vDU testline config|
    ...
    ...    *RETURN VALUE*
    ...   pa_port, e.g, 0
    ...
    ...    Example
    ...    | ${pa_port} |  Get PA port  ${pa_index}  |
    ...
    ${pa_port}=   Get Dictionary Keys   ${tl.attenuators[${pa_index}].attenuator_ports}
    [Return]  ${pa_port}

Get All PA ports number
    [Documentation]  Get All PA ports number
    ...  author: calla.wang@nokia-sbell.com
    ...  modified by:        <21-7-2022>, <calla.wang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   return value is like [[1,2,3,4,5,6,7,8,9,10], [1,2,3,4.5,6,7,8,9,10], [1,2,3,4,5,6,7,8]]
    ...
    ...    Example
    ...    | ${All_PA_Ports_Number_List} |  Get All PA ports number  |
    ...
    ${All_PA_Ports_Number_List}=   create list
    ${pa_amount}=   get length   ${tl.attenuators}
    FOR  ${index}  IN RANGE  ${pa_amount}
        ${pa_port}=  Get PA Port  ${index}
        Append To List  ${All_PA_Ports_Number_List}   ${pa_port}
    END
    [Return]  ${All_PA_Ports_Number_List}

Get RU Attenuation Ports
    [Arguments]  ${ru_index}=0    ${vdu_index}=0    ${gnb_index}=0  ${fhgw_index}=0
    [Documentation]  Get RU Attenuation Ports
    ...  author: calla.wang@nokia-sbell.com
    ...  modified by:        <21-7-2022>, <calla.wang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | no | ru_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   attenuation_port_numbers, e.g, [1,2,3,4]
    ...
    ...    Example
    ...    | ${attenuation_port_numbers} |  Get RU Attenuation Ports  |
    ...
    ${attenuation_ports_list}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].attenuation_ports}
    ${ports_amount}    Get Length    ${attenuation_ports_list}
    @{attenuation_port_numbers}    create list
    FOR    ${index}    IN RANGE    ${ports_amount}
        ${channel_port}  set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].attenuation_ports[${index}].port_no}
        Append To List    ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}


Get Preparation Release Name From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get Prerequisite Release Name From Testline
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Prerequisite Release Name From Testline
    ...
    ...    Example
    ...    | ${prerequisite_release_name} | Get Prerequisite Release Name From Testline |
    ...
    ${preparation_release_name}   set variable  preparation
    [Return]  ${preparation_release_name}
