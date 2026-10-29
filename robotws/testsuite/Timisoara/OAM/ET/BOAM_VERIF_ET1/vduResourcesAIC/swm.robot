*** Settings ***
Documentation
...  author: calla.wang@nokia-sbell.com

#Resource          aic_common_resources.robot
*** Variables ***
${PASS_RESULT}    True
${FAIL_RESULT}    False
#${VDU_DOCKER_IMAGE_COUNT}  9
#${testline}    7_5_CLOUD402T6666


*** Keywords ***
############################## CU Deployment + SWM Start ##############################
====== CU Deployment + SWM Start ======
     log to console  \n*** only used for readable ***


Get VCU NF Type
    [Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error    disconnect interactive connection    alias=${alias}
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
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info |
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


Get VCU OAM Http Connection Info
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU OAM Http Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OAM connection information defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': 8081}
    ...
    ...    Example
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info |
    ...    | ${vcu_oam_http_connection_info} | Get VCU OAM Http Connection Info | gnb_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give VCU OAM ip in __init__.py for gnb_index=${gnb_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give VCU OAM username in __init__.py for gnb_index=${gnb_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give VCU OAM password in __init__.py for gnb_index=${gnb_index}

    ${result}   ${port}        Run Keyword And Ignore Error
      ...   set variable     ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    Should Be True  "${result}"=="PASS"    Please give VCU OAM port in __init__.py for gnb_index=${gnb_index}

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
    ...    | ${yaml_file}     | Get vDU Patch Config Yaml From TestLine  |
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

    ${conf_dict}  Get VCU Heat Env Config Dictionary From TestLine  gnb_index=${gnb_index}
    print a dictionary  ${conf_dict}
    ${f1_cplane_ip}   set variable   ${conf_dict["parameters"]["external_networks"]["f1c"]["fixed_ips"][0]["ip_address"]}
    [Return]  ${f1_cplane_ip}


Get VCU X2C Ipv6
    #[Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU X2C Ipv6
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VCU X2C Ipv6
    ...
    ...    Example
    ...    | ${vcu_x2c_ipv6} | Get VCU X2C Ipv6 |
    ...
    ${conf_dict}      Get VCU Heat Env Config Dictionary From TestLine
    ${x2c_ipv6}    set variable   ${conf_dict["parameters"]["external_networks"]["x2c"]["fixed_v6_ips"][0]["ip_address"]}

    [Return]  ${x2c_ipv6}


Get VCU X2C Ip
    #[Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU X2C Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VCU X2C Ip
    ...
    ...    Example
    ...    | ${vcu_x2c_ip} | Get VCU X2C Ip |
    ...
    ${conf_dict}      Get VCU Heat Env Config Dictionary From TestLine
    ${x2c_ip}    set variable   ${conf_dict["parameters"]["external_networks"]["x2c"]["fixed_ips"][0]["ip_address"]}

    [Return]  ${x2c_ip}


Wait For VCU OAM Up With Long Period Time
    [Arguments]   ${gnb_index}=0   ${detection_time}=600
    [Documentation]   Wait For VCU OAM Up With Long Period Time
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | detection_time | no | detection_time, default is 600 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait For VCU OAM Up With Long Period Time |
    ...
    wait until keyword succeeds  ${detection_time}   30   _Wait For VCU OAM Up With Long Period Time Once    gnb_index=${gnb_index}


_Wait For VCU OAM Up With Long Period Time Once
    #[Arguments]   ${gnb_index}=0
    #${vcu_oam_http_connection_info}   Get VCU OAM Http Connection Info      gnb_index=${gnb_index}
    #${state}    check_host_service_state    ${vcu_oam_http_connection_info["addr"]}    ${vcu_oam_http_connection_info["port"]}
    #Should Be True    '${state}'=='True'
    ${r}   ${out}   run keyword and ignore error   vdu rest login
    ${state}   set variable if   "${r}"=="PASS"    ${True}   ${False}



############################## CU Deployment + SWM end ##############################
====== CU Deployment + SWM End ======
     log to console  \n*** only used for readable ***

############################## vDU Deployment + SWM Start ##############################
====== vDU Deployment + SWM Start ======
     log to console  \n*** only used for readable ***

Generate And Update Pod Container Name
    [Arguments]  ${vdu_index}=${0}   ${gnb_index}=${0}
    [Documentation]  Generate And Update Pod Container Name
    ...  return the value correct get from TL
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | vdu index | Yes. | the vdu index config on TL |
    ...       | gnb index | Yes. | the gnb index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ${OAM_CONTAINERS_NEW}=    Create List
    ${CPRT_CONTAINERS_NEW}=    Create List
    ${UP_CONTAINERS_NEW}=    Create List
    ${RCPSDL_CONTAINERS_NEW}=    Create List
    ${RCPFM_CONTAINERS_NEW}=    Create List
    ${LOGSERVICE_CONTAINERS_NEW}=    Create List
    ${LWSD_CONTAINERS_NEW}=    Create List
    ${PM_CONTAINERS_NEW}=    Create List
    ${TRSCONFIG_CONTAINERS_NEW}=    Create List
    ${RCPUM_CONTAINERS_NEW}=    Create List
    ${SECURESTORAGE_CONTAINERS_NEW}=    Create List
    ${HEALING-CONTROLLER_CONTAINERS_NEW}=    Create List
    ${KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS_NEW}=    Create List
    ${namespace}=  Get vDU Namespace From TestLine   ${vdu_index}   ${gnb_index}
    FOR  ${old_name}  IN  @{OAM_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${OAM_CONTAINERS}  ${old_name}
      append to list  ${OAM_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{CPRT_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${CPRT_CONTAINERS}  ${old_name}
      append to list  ${CPRT_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{UP_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${UP_CONTAINERS}  ${old_name}
      append to list  ${UP_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{RCPSDL_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${RCPSDL_CONTAINERS}  ${old_name}
      append to list  ${RCPSDL_CONTAINERS_NEW}   ${new_con_name}
    END
    for  ${old_name}  IN  @{RCPFM_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${RCPFM_CONTAINERS}  ${old_name}
      append to list  ${RCPFM_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{LOGSERVICE_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${LOGSERVICE_CONTAINERS}  ${old_name}
      append to list  ${LOGSERVICE_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{LWSD_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${LWSD_CONTAINERS}  ${old_name}
      append to list     ${LWSD_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{PM_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${PM_CONTAINERS}  ${old_name}
      append to list     ${PM_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{TRSCONFIG_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${TRSCONFIG_CONTAINERS}  ${old_name}
      append to list     ${TRSCONFIG_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{RCPUM_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${RCPUM_CONTAINERS}  ${old_name}
      append to list     ${RCPUM_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{SECURESTORAGE_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${SECURESTORAGE_CONTAINERS}  ${old_name}
      append to list     ${SECURESTORAGE_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS}  ${old_name}
      append to list     ${KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS_NEW}   ${new_con_name}
    END
    FOR  ${old_name}  IN  @{HEALING-CONTROLLER_CONTAINERS}
      ${new_con_name}=  set variable    ctr-${namespace}-${old_name}
      remove values from list  ${HEALING-CONTROLLER_CONTAINERS}  ${old_name}
      append to list     ${HEALING-CONTROLLER_CONTAINERS_NEW}   ${new_con_name}
    Set To Dictionary   ${AIC_VDU_PODS}   up=${UP_CONTAINERS_new}    oam=${OAM_CONTAINERS_NEW}
    ...  rcpsdl=${RCPSDL_CONTAINERS_new}   rcpfm=${RCPFM_CONTAINERS_new}    logservice=${LOGSERVICE_CONTAINERS_NEW}
    ...  lwsd=${LWSD_CONTAINERS_NEW}   pm=${PM_CONTAINERS_NEW}    trsconfig=${TRSCONFIG_CONTAINERS_NEW}
    ...  rcpum=${RCPUM_CONTAINERS_NEW}   securestorage=${SECURESTORAGE_CONTAINERS_NEW}
    ...  kubeapisymptomdataprovider=${KUBEAPISYMPTOMDATAPROVIDER_CONTAINERS_NEW}
    ...  cprt=${CPRT_CONTAINERS_NEW}
    ...  healing-controller=${HEALING-CONTROLLER_CONTAINERS_NEW}
    END

Get vDU Namespace From TestLine
    [Arguments]  ${vdu_index}=${0}   ${gnb_index}=${0}
    [Documentation]  get vdu namespace from testline init config file
    ...  return the value correct get from TL
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu index | Yes. | the vdu index config on TL |
    ...    *RETURN VALUE*
    ...    namespace
    ${vdu_namespace}=   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]   ${vdu_namespace}


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



Get vDU OAM Http Connection Info
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU OAM Http Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OAM connection information defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': 8081}
    ...
    ...    Example
    ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info |
    ...    | ${vdu_oam_http_connection_info} | Get vDU OAM Http Connection Info | vdu_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give vDU OAM ip in __init__.py for vdu_index=${vdu_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give vDU OAM username in __init__.py for vdu_index=${vdu_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give vDU OAM password in __init__.py for vdu_index=${vdu_index}

    #${result}   ${port}        Run Keyword And Ignore Error
    #  ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.port}
    #Should Be True  "${result}"=="PASS"    Please give vDU OAM port in __init__.py for vdu_index=${vdu_index}
    ${port}  set variable  443

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}   port=${port}
    [Return]  ${rtn}


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


Get K8s Admin SSH Connection Info
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get K8s Admin SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cloudadmin', 'password': 'system123', 'port': 22}
    ...
    ...    Example
    ...    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info |
    ...    | ${vdu_k8s_master_ssh_connection_info} | Get K8s Admin SSH Connection Info | vdu_index=1 |
    ...
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}   ${port}        Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}   port=${port}
    [Return]  ${rtn}


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


Get FHM Vlan Id From Testline
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get FHM Vlan Id From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vlanId of FHM
    ...
    ...    Example
    ...    | ${vlanId} | Get FHM Vlan Id From Testline |
    ...
    ${conf_dict_vdu}     Get VDU Vnf Config Dictionary From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vlanId}   Set Variable   ${conf_dict_vdu["aic-vdu-oam"]["netConf"]["fhm"]["vlanInfo"]["vlanId"]}
    ${vlanId}   Convert To String   ${vlanId}
    [Return]  ${vlanId}


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
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/one_click_ne_deploy.yaml

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
    ...   Dictionary of one_click_ne_deploy.yaml . If there is no this file, return {}
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


Get vDU Patch Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU Patch Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vdu_patch_0.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU Patch Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ${conf_path}   ${dummy}   OperatingSystem.Split Path   ${yaml_file_name}
    ${yaml_file_name_DEBUG}   OperatingSystem.Join Path    ${conf_path}   vdu_patch_0.yaml
    [Return]   ${yaml_file_name_DEBUG}


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


Get vDU Patch Config Dictionary From TestLine
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
    ...    | ${conf_dict}     | Get vDU Patch Config Dictionary From TestLine |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get vDU Patch Config Yaml From TestLine  gnb_index=${gnb_index}  vdu_index=${vdu_index}
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
    print a dictionary  ${conf_dict}
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
    ...    Dictionary of vlan id  information defined in one_click_ne_deploy yaml file
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
    ...    Dictionary of F1 network information defined in one_click_ne_deploy yaml file
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
    ...    Dictionary of F1 Uplane network information defined in one_click_ne_deploy yaml file
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
    ...   Dictionary of OAM network information defined in one_click_ne_deploy yaml file
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
    ...    Dictionary of tracing  network information defined in one_click_ne_deploy yaml file
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
    #[Arguments]    ${gnb_index}=0   ${vdu_index}=0
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


Get Running Build Number
    [Arguments]   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${platform_name}   Get Platform Name

    ${build_number}   run keyword if   "${platform_name}"=="NCIR"  _Get Running Build Number NCIR   vdu_index=${vdu_index}
    ...   ELSE   _Get Running Build Number NCS   vdu_index=${vdu_index}
    [Return]  ${build_number}


_Get Running Build Number NCIR
    [Arguments]   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${alias}  get unique id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   alias=${alias}
    ${out}  issh.Execute   command=helm list|grep aic-vdu|grep -v intnet|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    #should not be empty  ${build_number}
    [Return]  ${build_number}


_Get Running Build Number NCS
    [Arguments]   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${alias}  get unique id
    #Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   alias=${alias}
    Connect To K8s Master Interactively   vdu_index=${vdu_index}   alias=${alias}
    ${ns}   get vdu namespace from testline    vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 list -n ${ns}|grep aic-vdu-|grep -v intnet|grep -v rbac|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}


Get VDU Release Name
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get VDU release name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, e.g, aic-vdu
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name |
    ...
    ${platform_name}   Get Platform Name

    ${release_name}   run keyword if   "${platform_name}"=="NCIR"  _Get VDU Release Name NCIR  vdu_index=${vdu_index}
    ...   ELSE   _Get VDU Release Name NCS   vdu_index=${vdu_index}

    [Return]  ${release_name}


_Get VDU Release Name NCIR
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU release name NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, eg, aic-vdu
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name NCIR |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}

    ${out}  issh.Execute   command=helm list --all|grep aic-vdu|grep -v intnet|awk '{print $1}'   alias=${alias}
    ${release_name}  Strip Prompt  ${out}
    [Return]  ${release_name}


_Get VDU Release Name NCS
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU release name NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.8.2021,chris.l.cao@nokia-sbell.com, exclude prerequisite for latest vdu software
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, eg, aic-vdu
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name NCS |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}   get vdu namespace from testline   vdu_index=${vdu_index}
    ${out}  issh.Execute
     ...  command=sudo helm3 list -n ${ns}|grep aic-vdu-|grep -v intnet|grep -v prerequisite|grep -v rbac|awk '{print $1}'   alias=${alias}
    ${release_name}  Strip Prompt  ${out}

    ${tmp_list}  Split To Lines   ${release_name}
    ${tmp_list_length}   get length    ${tmp_list}
    should be true    ${tmp_list_length}==1

    [Return]  ${release_name}


Get VDU PVC Release Name
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get VDU PVC Release Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    pvc release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU PVC Release Name |
    ...
    ${platform_name}   Get Platform Name

    ${pvc_release_name}   run keyword if   "${platform_name}"=="NCIR"   _Get VDU PVC Release Name NCIR  vdu_index=${vdu_index}
    ...   ELSE   _Get VDU PVC Release Name NCS   vdu_index=${vdu_index}
    [Return]  ${pvc_release_name}


_Get VDU PVC Release Name NCIR
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU PVC Release Name NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    pvc release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU PVC Release Name |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm list --all|grep aic-pvc |awk '{print $1}'   alias=${alias}
    ${pvc_release_name}  Strip Prompt  ${out}
    [Return]  ${pvc_release_name}


_Get VDU PVC Release Name NCS
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU PVC Release Name NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    pvc release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU PVC Release Name |
    ...
    ${alias}  Get Unique Id
    #Connect To K8s Master with tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline  vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 list -n ${ns}|grep aic-pvc |grep -v aic-vdu|grep -v aic-intnet|awk '{print $1}'   alias=${alias}
    ${pvc_release_name}  Strip Prompt  ${out}
    [Return]  ${pvc_release_name}


Get VDU Network Release Name
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get VDU Network Release Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu Network release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU Network Release Name |
    ...
    ${platform_name}   Get Platform Name

    ${network_release_name}   run keyword if   "${platform_name}"=="NCIR"  _Get VDU Network Release Name NCIR  vdu_index=${vdu_index}
    ...   ELSE   _Get VDU Network Release Name NCS   vdu_index=${vdu_index}

    [Return]  ${network_release_name}


_Get VDU Network Release Name NCIR
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Get VDU Network Release Name NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu Network release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU Network Release Name |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm list --all|grep aic-intnet|grep -v aic-vdu|awk '{print $1}'   alias=${alias}
    ${network_release_name}  Strip Prompt  ${out}
    [Return]  ${network_release_name}


_Get VDU Network Release Name NCS
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU Network Release Name NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu Network release name
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU Network Release Name |
    ...
    ${alias}  Get Unique Id
    #Connect To K8s Master with tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline   vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 list -n ${ns}|grep aic-intnet|grep -v aic-vdu|grep -v aic-pvc|awk '{print $1}'   alias=${alias}
    ${network_release_name}  Strip Prompt  ${out}
    [Return]  ${network_release_name}


Get VDU Chart Name
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get VDU Chart name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...     VDU Chart Name, e.g, aic-vdu-0.300.1155
    ...
    ...    Example
    ...    | ${chart_name} | Get VDU Chart Name |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm3 list|grep aic-vdu|grep -v intnet|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    [Return]  ${out}


Get VDU Network Chart Name
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get VDU Network Chart name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU Network Chart Name, e.g, aic-intnet-0.300.1155
    ...
    ...    Example
    ...    | ${vdu_network_chart_name} | Get VDU Network Chart Name |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm3 list|grep aic-intnet|grep -v grep|awk '{print $9}'    alias=${alias}
    ${out}  Strip Prompt  ${out}
    [Return]  ${out}


Get BTSID From vDU
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout
    [Documentation]   Get VCU Cell Number From SCF
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...  MRBTS_ID from vDU Scf
    ...
    ...    Example
    ...    | ${MRBTS_ID} | Get BTSID From vDU |
    ...
    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${MRBTS_ID}  set variable      ${vdu_conf["mrbts_id"]}
    [Return]   ${MRBTS_ID}



Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]   run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    [Documentation]   Get VCU Cell Number From SCF
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
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${tmpid1}   get unique id  precise=LOW  prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}  Get A Directory  ${tmpid1}
    ${tmp_scf_file}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${scf_content}   OperatingSystem.Get File   ${tmp_scf_file}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}  Set Variable    ${result.__len__()}

    [Return]   ${cell_number}


Get VDU Infrastructure Type
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    ${vdu_config_dict}=   Get vDU Vnf Config Dictionary From TestLine  ${gnb_index}   ${vdu_index}
    Set Test Variable  ${VDU_Infra_Type}   ${vdu_config_dict['infraType']}
    [Return]  ${VDU_Infra_Type}


Modify vDU Chart Value Yaml File For NCIR
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0  ${vdu_chart_name}=aic-vdu    #${vdu_version}
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${Download_Local_Dir}/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close


Modify vDU Chart Value Yaml File For TPI
    [Arguments]  ${vdu_version}  ${vdu_index}=0  ${gnb_index}=0  ${vdu_chart_name}=aic-vdu   ${intnet_chart_name}=aic-intnet
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.execute_command_on_master_cluster
    ...  cd ${Download_Local_Dir}; mkdir ${intnet_chart_name}_${timestamp}; mkdir ${vdu_chart_name}_${timestamp}
    helm.helm_download_chart
    ...  ${Download_Local_Dir}/${intnet_chart_name}_${timestamp}   ${intnet_chart_name}  ${vdu_version}
    helm.helm_download_chart
    ...  ${Download_Local_Dir}/${vdu_chart_name}_${timestamp}   ${vdu_chart_name}    ${vdu_version}
    helm.helm_merge_values_file
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].yaml_file}
    ...  ${Download_Local_Dir}/${vdu_chart_name}_${timestamp}/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close


Create vDU intnet Release
    [Arguments]   ${vdu_version}   ${vdu_index}=0   ${gnb_index}=0  ${intnet_chart_name}=aic-intnet
    [Documentation]  create vDU intnet Release
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_version | Yes. | the vdu version needs to be deployed |
    ...    | vdu_index | No. | the vdu index, default value is 0 |
    ...    | intnet_chart_name | No. | the intnet chart name, default value is aic-intnet-mvp |
    ...    *RETURN VALUE*
    ...    None
    ${VDU_Infra_Type}=  Get VDU Infrastructure Type  ${gnb_index}  ${vdu_index}
    Run Keyword If  '${VDU_Infra_Type}'=='NCIR'  Create vDU intnet Release For NCIR
    ...  ${vdu_index}  ${gnb_index}  ${intnet_chart_name}
    ...  ELSE   Create vDU intnet Release For TPI
    ...  ${vdu_version}   ${vdu_index}  ${gnb_index}  ${intnet_chart_name}

Create vDU intnet Release For NCIR
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0  ${intnet_chart_name}=aic-intnet
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_install_wait_until_ready
    ...  release_name=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.networks[0].name}
    ...  chart_path=${Download_Local_Dir}/${intnet_chart_name}
    ...  namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  value_files=${Download_Local_Dir}/${intnet_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close


Create vDU intnet Release For TPI
    [Arguments]  ${vdu_version}   ${vdu_index}=0   ${gnb_index}=0  ${intnet_chart_name}=aic-intnet
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_install_wait_until_ready
    ...  release_name=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.networks[0].name}
    ...  chart_path=default/${intnet_chart_name}:${vdu_version}
    ...  namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  value_files=${Download_Local_Dir}/${intnet_chart_name}_${timestamp}/${intnet_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close

Create vDU Release
    [Arguments]   ${vdu_version}   ${vdu_index}=0   ${vdu_chart_name}=aic-vdu   ${gnb_index}=0
    [Documentation]  create vDU Release
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_version | Yes. | the vdu version needs to be deployed |
    ...    | vdu_index | No. | the vdu index, default value is 0 |
    ...    | vdu_chart_name | No. | the vdu chart name needs to be deployed, default value is aic-vdu |
    ...    *RETURN VALUE*
    ...    None
    ${VDU_Infra_Type}=  Get VDU Infrastructure Type  ${gnb_index}  ${vdu_index}
    Run Keyword If  '${VDU_Infra_Type}'=='NCIR'  Create vDU Release For NCIR
    ...  ${vdu_index}  ${vdu_chart_name}  ${gnb_index}
    ...  ELSE   Create vDU Release For TPI
    ...  ${vdu_version}   ${vdu_index}   ${vdu_chart_name}   ${gnb_index}

Create vDU Release For NCIR
    [Arguments]  ${vdu_index}=0   ${vdu_chart_name}=aic-vdu  ${gnb_index}=0
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_install_wait_until_ready
    ...  release_name=${tl.gnbs[${gnb_index}dus[${vdu_index}].cloud_deployment.vnfs[0].name}
    ...  chart_path=${Download_Local_Dir}/${vdu_chart_name}
    ...  namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  value_files=${Download_Local_Dir}/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close

Create vDU Release For TPI
    [Arguments]    ${vdu_version}   ${vdu_index}=0    ${vdu_chart_name}=aic-vdu  ${gnb_index}=0
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_install_wait_until_ready
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].name}
    ...  default/${vdu_chart_name}:${vdu_version}
    ...  namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  value_files=${Download_Local_Dir}/${vdu_chart_name}_${timestamp}/${vdu_chart_name}/values-override.yaml
    [Teardown]    helm.helm_master_close

vDU Get Current Namespace Release List
    [Arguments]   ${namespace}   ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get current namespace release list
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | namespace | Yes. | the namespace that the release needs to be installed |
    ...    *RETURN VALUE*
    ...    the release list belonged to the namespace
    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${release_list} =    helm.helm_get_release_list
    ${current_namespace_release_list}=    Create List
    #${length}    get Length    ${result}
    FOR    ${release}    IN    @{release_list}
        Run Keyword If    '${release['namespace']}' == '${namespace}'    Append to list    ${current_namespace_release_list}    ${release}
    END
    [Return]    ${current_namespace_release_list}
    [Teardown]    helm.helm_master_close

vDU Delete Release
    [Arguments]    ${release_name}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  delete the release with given release name
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | release_name | Yes. | the release name needs to be deleted |
    ...    *RETURN VALUE*
    ...    None
    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    helm.helm_delete    ${release_name}
    [Teardown]    helm.helm_master_close

Waiting for vDU Delete
    [Arguments]   ${vdu_index}=0
    [Documentation]  Waiting for vDU Delete
    ...  author: tina.luo@nokia-sbell.com
    vDU Cluster Login With Tenant  ${vdu_index}
    wait_vdu_delete


Get vDU And Intnet Release Name
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  get the vdu and intnet release name
    ...  author: calla.wang@nokia-sbell.com
    ...  | Input Parameters | Man. | Description |
    ...	 | namespace | Yes. | the namespace that the release has been installed |
    ...  *RETURN VALUE*
    ...  vdu release name | intnet release name
    ${release_list}=    vDU Get Current Namespace Release List
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...  ${vdu_index}  ${gnb_index}
    ${VDU_Release_Name}=   Set Variable    ${EMPTY}
    ${Intnet_Release_Name}=   Set Variable   ${EMPTY}
    FOR    ${release}    IN    @{release_list}
        Run Keyword If    "${release['name']}" == "${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.vnfs[0].name}"
    ...  set test variable    ${VDU_Release_Name}    ${release['name']}
        Run Keyword If    "${release['name']}" == "${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.networks[0].name}"
    ...  set test variable    ${Intnet_Release_Name}    ${release['name']}
    END
    [Return]    ${VDU_Release_Name}    ${Intnet_Release_Name}


Get vDU Specific Container Status
    [Arguments]    ${pod_name}   ${container_name}   ${namespace}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  get one specific container status
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | Yes. | the pods name that containers belong to |
    ...	   | container_name | Yes. | the container name |
    ...    | namespace | No. | the namespace that the pod belongs to |
    ...    *RETURN VALUE*
    ...    the container status
    Run Keyword If    '${namespace}' != '${EMPTY}'    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    ...    ELSE    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${result}=    get_vdu_containers_status    ${pod_name}    ${namespace}
    Set Test Variable    ${Container_Status}    ${result['${pod_name}']['${container_name}'][0]}
    [Return]  ${Container_Status}
    [Teardown]    helm.helm_master_close

vDU Get Pods Full Info
    [Arguments]    ${pod_name}=all    ${namespace}=${EMPTY}  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  get pods full infomation
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    *RETURN VALUE*
    ...    pods info dict
    Run Keyword If    '${namespace}' != '${EMPTY}'    vDU Cluster Login With Admin  ${vdu_index}  ${gnb_index}
    ...    ELSE    vDU Cluster Login With Tenant  ${vdu_index}  ${gnb_index}
    ${pods_info}=    get_vdu_pods_info    ${pod_name}    ${namespace}
    Set Test Variable    ${Pods_Info}    ${pods_info}
    [Return]  ${Pods_Info}
    [Teardown]    helm.helm_master_close

vDU Pod Status Should Be As Expected
    [Arguments]   ${expect_status}    ${pod_name}=all    ${namespace}=${EMPTY}   ${vdu_index}=0
    [Documentation]  judging pods status should be as expected
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expect_status | Yes. | the expected status of the pod |
    ...	   | pod_name | No. | the pods name that containers belong to, default value is all pods |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ${pods_info}=    vDU Get Pods Full Info    ${pod_name}    ${namespace}   ${vdu_index}
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    FOR  ${pod}  IN  @{pods_name_list}
        Should Be Equal As Strings    ${pods_info['${pod}']['status']}    ${expect_status}
    END

vDU Container Status Should Be As Expected
    [Arguments]  ${pod_name}  ${container_name}  ${expected_status}  ${namespace}=${EMPTY}   ${vdu_index}=0
    [Documentation]  judging vDU container status should be as expected
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | pod_name | Yes. | the pods name that containers belong to |
    ...	   | container_name | Yes. | the container name |
    ...    | namespace | No. | the namespace that the pod belongs to, if not given, using the tenant namespace |
    ...    | expect_status | Yes. | the expected status of container |
    ${container_status}=   Get vDU Specific Container Status   ${pod_name}  ${container_name}  ${namespace}  ${vdu_index}
    Should Be Equal As Strings    ${container_status}    ${expected_status}



Get Full Pod Name By Pod Abbreviation
    [Arguments]    ${pod_abbr}    ${connection}=default   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbrevation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master |
    ...
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}
    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    #${cmd}   run keyword if   "${pod_abbr}"!="securestorage"    set variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'
    #...   ELSE  set variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'

    ${full_pod_name}   tafssh.Execute    command=${cmd}   connection=${connection}
    ${full_pod_name}   Set Variable  ${full_pod_name.strip()}
    [Return]  ${full_pod_name}


Get Full Pod Name By Container Abbreviation
    [Arguments]    ${container_abbr}    ${connection}=default   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbrevation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  Yes | container appreviation, eg, oamfh, l1hi |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | container_abbr=oamfh |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | container_abbr=l1hi | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | container_abbr=l2hi | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master |
    ...

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}   connection=${connection}
      ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${full_pod_name}


Get Pod Abbreviation By Container Abbreviation
    [Arguments]    ${container_abbr}=oamfh
    [Documentation]   Get Pod Abbreviation By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container_abbr, eg, oamfh, l1hi |
    ...
    ...    *RETURN VALUE*
    ...    pod abbreviation, e.g, oam, cprt, up.
    ...
    ...    Example
    ...    | ${pod_abbr} | Get Pod Abbreviation By Container Abbreviation | container_abbr=oamfh |
    ...
    ${container_prefix}  Get Container Name Prefix
    ${start_with_prefix}   set variable  ${container_abbr.startswith("${container_prefix}")}
    ${container_abbr}  run keyword if   "${start_with_prefix}"=="${True}"   set variable  ${container_abbr.replace("${container_prefix}","")}
        ...   ELSE   set variable    ${container_abbr}

    ${pod_keys}   Evaluate    list(${AIC_VDU_PODS})

    ${pod_abbr}   set variable   ${EMPTY}
    FOR   ${pod}  IN   @{pod_keys}
        ${containers_list}    set variable    ${AIC_VDU_PODS["${pod}"]}
        ${number}   Count Values In List   ${containers_list}    ${container_abbr}
        run keyword if   ${number}>=2   Fail   There are two container whose names are same !
        Return From keyword if   ${number}==1   ${pod}
    END

    [Return]  ${pod_abbr}


Get Full Pod Name By Pod Abbreviation Interactively
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     #${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | disconnect interactive connection  |
    ...

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}

    ${out}   issh.Execute   command=${cmd}   alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}


Get Full Pod Name By Container Abbreviation Interactively
    [Arguments]    ${container_abbr}     ${vdu_index}=0     ${gnb_index}=0  #${alias}=default
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias_tmp}
    [Documentation]   Get Full Pod Name By Container Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container name appreviation, eg, oamfh, l1hi |
    ...    | alias             | No | alias. Default value is default. Now this parameter can be omitted! |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | ${full_pod_name} | Get Full Pod Name By Container Abbreviation Interactively | container_abbr=oamfh |
    ...
    run keyword if   "${container_abbr}"=="nwmgmt"   Fail  This KW can't be used for container nwmgmt !

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${alias_tmp}   get unique id
    connect to k8s master interactively  alias=${alias_tmp}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively
    ...   pod_abbr=${pod_abbr}   alias=${alias_tmp}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${full_pod_name}



Get Work Node Ip By Pod Abbreviation
    [Arguments]    ${pod_abbr}   ${connection}=default   ${vdu_index}=0
    [Documentation]   Get Work Node Ip By Pod Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=oamcp |
    ...    | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=up | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master |
    ...
    ${ns}    Get vDU Namespace From TestLine  vdu_index=${vdu_index}
    ${cmd}   set variable  kubectl get pods -n ${ns} -o wide
    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $7}'
    ${work_node_ip}   tafssh.Execute  command=${cmd}   connection=${connection}
    ${work_node_ip}   Set Variable  ${work_node_ip.strip()}
    should not be empty  ${work_node_ip}

    [Return]  ${work_node_ip}


Get Work Node Ip By Pod Abbreviation Interactively
    [Arguments]    ${pod_abbr}   ${alias}=default   ${vdu_index}=0
    [Documentation]   Get Work Node Ip By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | connect to k8s master interactively  |
    ...    | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=oamcp |
    ...    | ${work_node_ip} | Get Work Node Ip By Pod Abbreviation | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | disconnect interactive connection  |
    ...
    ${ns}    Get vDU Namespace From TestLine  vdu_index=${vdu_index}
    ${cmd}   set variable  kubectl get pods -n ${ns} -o wide
    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $7}'
    ${work_node_ip}   issh.Execute  command=${cmd}   alias=${alias}
    ${work_node_ip}   Set Variable  ${work_node_ip.strip()}
    ${work_node_ip}   strip prompt  ${work_node_ip}   remove_first_line=${FALSE}
    should not be empty  ${work_node_ip}

    [Return]  ${work_node_ip}


Get Full Container Name By Container Abbreviation
    [Arguments]    ${ctr_abbr}       ${vdu_index}=${0}    #${gnb_index}=${0}
    [Documentation]   Get Full Container Name By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ctr_abbr          |  Yes | container name abbreviation, eg, oamfh, oam, cprt, nwmgmt,etc |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full Container name, e.g, ctr_cran1_oamfh
    ...
    ...    Example
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=oamfh |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=nwmgmt | vdu_index=0 |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=cprt | vdu_index=0 |
    ...

    #@{ctr_list}  create list   appsecretinithttpd  appsecretinitne3sagent  appsecretinitprovidercontroller  httpdstunnel
    #...  ne3sagentstunnel  providercontrollerstunnel  httpdcredmediator  ne3sagentcredmediator  providercontrollercredmediator
    #: FOR    ${ctr}    IN    @{ctr_list}
    #\   return from keyword if   "${ctr_abbr}"=="${ctr}"   ${ctr_abbr}

    ${container_prefix}  Get Container Name Prefix   vdu_index=${vdu_index}
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${container_prefix}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${full_ctr_name}   set variable  ${container_prefix}${ctr_abbr}
    [Return]  ${full_ctr_name}


Get Pod Name Prefix
    #[Arguments]     ${vdu_index}=0
    [Documentation]   Get Pod Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...
    ...    Example
    ...    | ${pod_prefix} | Get Pod Name Prefix |
    ...    | ${pod_prefix} | Get Pod Name Prefix | vdu_index=0 |
    ...
    #${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}


    #${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    #${vdu_dict}   Get vDU Vnf Config Dictionary From TestLine  vdu_index=${vdu_index}

    #${r}   ${pod_prefix}   run keyword and ignore error  set variable  ${vdu_dict["global"]["name_convention"]["pod_prefix"]}
    #${pod_prefix}   set variable if  "${r}"=="PASS"   ${pod_prefix}   ${EMPTY}

    #return from keyword if  "${r}"!="PASS"   ${EMPTY}
    #${pod_prefix}   evaluate  "".join(${pod_prefix})
    #${pod_prefix}   Replace String   ${pod_prefix}   _NAMESPACE_   -${ns}-
    [Return]  ${_G_POD_PREFIX}


_Set Pod And Container Name Prefix
    ${_G_POD_PREFIX}   _Get Pod Name Prefix Internal Use
    set suite variable   ${_G_POD_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use
    set suite variable   ${_G_CONTAINER_PREFIX}


_Get Pod Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   _Get Pod Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.8.2021,chris.l.cao@nokia-sbell.com, change from tenant to admin account to adapt OCP
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...
    ...    Example
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use |
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use | vdu_index=0 |
    ...
    ${alias}   get unique id
    #Connect To K8s Master With Tenant Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Connect To K8s Master Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -n ${ns}|grep -E "\\-oam\\-"|awk -F "-oam-" '{print $1}'  alias=${alias}
    ${pod_prefix}  strip prompt  ${out}

    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}

    [Return]  ${pod_prefix}


Get Container Name Prefix
    #[Arguments]     ${vdu_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...
    ...    Example
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    ...

    #${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    #${vdu_dict}   Get vDU Vnf Config Dictionary From TestLine  vdu_index=${vdu_index}

    #${r}   ${container_prefix}   run keyword and ignore error  set variable  ${vdu_dict["global"]["name_convention"]["container_prefix"]}
    #${container_prefix}   set variable if  "${r}"=="PASS"   ${container_prefix}   ${EMPTY}
    #return from keyword if  "${r}"!="PASS"   ${EMPTY}

    #${container_prefix}   evaluate  "".join(${container_prefix})
    #${container_prefix}   Replace String   ${container_prefix}   _NAMESPACE_   -${ns}-
    [Return]  ${_G_CONTAINER_PREFIX}


_Get Container Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.8.2021,chris.l.cao@nokia-sbell.com, change from tenant to admin account to adapt OCP
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...
    ...    Example
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ...
    ${pod_prefix}   _Get Pod Name Prefix Internal Use

    ${alias}   get unique id
    #Connect To K8s Master With Tenant Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    Connect To K8s Master Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${out}   issh.Execute
    ...   command=kubectl describe pod ${pod_prefix}up-0 -n ${ns}|grep l1hi:|head -n 1|awk -F l1hi '{print $1}'
    ...    alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   set variable   ${out.strip()}
    ${container_prefix}   set variable   ${out}

    [Return]  ${container_prefix}


Get vDU Container ID
    [Arguments]  ${container_name}  ${connection}  ${vdu_index}=0
    [Documentation]  get the vdu container id by the giving container name
    ...   *AUTHOR* author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.11.2020,chris.l.cao@nokia-sbell.com, add container name prefix
    ...   17.6.2021,chris.l.cao@nokia-sbell.com, add 'sudo' for cbis_admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | container_name | Yes. | the container name |
    ...    | connection | Yes. | the connection of the node |
    ...
    ...    *RETURN VALUE*
    ...    the container id
    ...
    ...    Example
    ...    | ${node_alias} | Connect To vDU Node | node_ip=192.168.2.134 | vdu_index=0 |
    ...    | ${container_id} | Get vDU Container ID | container_name=oam | connection=${node_alias} |
    ...    | [Teardown]  tafssh.reset_cache |
    ...
    ${container_name}   get full container name by container abbreviation   ctr_abbr=${container_name}   vdu_index=${vdu_index}
    #${cmd}=  set variable  docker ps -q -f name=.*${container_name}_.*
    ${cmd}=  set variable   sudo docker ps -q -f name=.*${container_name}_.*
    ${output}=  tafssh.execute  command=${cmd}  connection=${connection}
    ${container_id}=  set variable  ${output.strip()}
    [Return]  ${container_id}


Get vDU Container ID Interactively
    [Arguments]  ${container_name}  ${alias}  ${vdu_index}=0
    [Documentation]  get the vdu container id by the giving container name with issh library.
    ...   *AUTHOR* author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.11.2020,chris.l.cao@nokia-sbell.com, add container name prefix
    ...   17.6.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | container_name | Yes. | the container name |
    ...    | alias | Yes. | the alias connection to the node |
    ...
    ...    *RETURN VALUE*
    ...    the container id
    ...
    ...    Example
    ...    | ${node_alias} | Connect To vDU Node | node_ip=192.168.2.134 | vdu_index=0 |
    ...    | ${container_id} | Get vDU Container ID | container_name=oam | connection=${node_alias} |
    ...    | [Teardown]  tafssh.reset_cache |
    ...
    ${container_name}   get full container name by container abbreviation   ctr_abbr=${container_name}   vdu_index=${vdu_index}
    #${cmd}=  set variable  docker ps -q -f name=.*${container_name}_.*
    ${cmd}  set variable   sudo docker ps -q -f name=.*${container_name}_.*
    ${output}  issh.execute  command=${cmd}  alias=${alias}
    ${output}  set variable  ${output.strip()}
    ${container_id}   set variable  ${output.split()[0]}

    [Return]  ${container_id}


Download File From VDU Container
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${filename}=${EMPTY}   ${local_filename}=${EMPTY}   ${gnb_index}=0     ${vdu_index}=0
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]    Download File From VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   3.8.2021,chris.l.cao@nokia-sbell.com, support to not-using pod_abbr
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr  |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | filename  | yes | filename, remote file absolute file name in VDU container |
    ...    | local_filename | No | local_filename. Default value is ${EMPTY}, it means a temporary file will be created and returned |
    ...    | gnb_index | No | gnb_index. Default value is 0 |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    local UTE's file name where is the content of remote file in vdu container
    ...
    ...    Example
    ...   | ${local_file} | Download File From VDU Container | container=logstorageserver | filename=/var/log/audit/auditlog |   |
    ...   | ${local_file} | Download File From VDU Container | pod_abbr=logservice | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ${local_file} | Download File From VDU Container | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ... |  local_filename=/tmp/abc.log |
    ...   | ${local_file} | Download File From VDU Container | pod_abbr=logservice | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ... |  local_filename=/tmp/abc.log |
    ...
    should not be empty  ${container}
    should not be empty  ${filename}

    ${container_full_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${alias}  get unique id
    Connect To K8s Master Interactively  alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_abbr}  run keyword if   "${pod_abbr}"=="${EMPTY}"  get pod abbreviation by container abbreviation   container_abbr=${container}
    ...    ELSE   set variable   ${pod_abbr}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}
    ${container_id}   Get Container ID From Docker Ps Command By POD Abbreviation Interactively    ns=${ns}
    ...     pod_abbr=${pod_abbr}    container=${container}    alias=${alias}

    ${path2} 	${file}  OperatingSystem.split path   ${filename}
    ${remote_filename}  get a remote file   ${file}  alias=${alias}
    ${out}    issh.Execute    command=docker cp ${container_id}:${filename} ${remote_filename}   alias=${alias}

    ${local_ute_filename}  run keyword if  "${local_filename}"=="${EMPTY}"   get a file   Download_File_From_VDU_Container   ${alias}
    ...   ELSE   set variable   ${local_filename}
    issh.download_file   remote_path=${remote_filename}   local_path=${local_ute_filename}   alias=${alias}

    [Return]  ${local_ute_filename}


Delete Terminating Pod
    [Arguments]    ${vdu_index}=0
    vDU Cluster Login With Admin    ${vdu_index}
    ${namespace}=    Get vDU Namespace From TestLine
    ${result}=    helm.Execute Command On Master Cluster    kubectl get pods -n ${namespace} |grep -i "Terminating" |awk '{print $1}'
    ${terminating_pod}=    Convert To String    ${result.stdout}
    ${terminating_pod}=    Strip String    ${terminating_pod}
    ${result}=    helm.Execute Command On Master Cluster    kubectl delete pods -n ${namespace} ${terminating_pod} --grace-period=0 --force
    ${delete_log}=    Convert To String    ${result.stdout}
    should contain    ${delete_log}    pod "${terminating_pod}" force deleted


Get Current vDU Version
    [Arguments]    ${vdu_index}=0
    [Documentation]  get current vDU version
    vDU Cluster Login With Admin    ${vdu_index}
    ${result}=    helm.Execute Command On Master Cluster    helm list |grep aic-vdu |awk '{print $9}'
    log    ${result.stdout}
    ${vdu_current_version}=    Convert To String    ${result.stdout}
    ${vdu_current_version}=    Strip String    ${vdu_current_version}
    #@{vdu_current_version}=    Split String    ${vdu_current_version}    -
    ${vdu_current_version}=    Set Variable    ${vdu_current_version[-1]}
    [Return]    ${vdu_current_version}


Delete System Pod And Wait It Up
    [Arguments]   ${pod_abbr}=dynamic-local-pv-provisioner-   ${ns}=kube-system
       ...       ${vdu_index}=0         #${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Delete System Pod And Wait It Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...	   | pod_abbr | No. | pod_abbr, default is dynamic-local-pv-provisioner-  |
    ...	   | ns     | No. | namespace, default is kube-system |
    ...	   | gnb_index    | No. | index for vdu |
    ...	   | vdu_index    | No. | index for vdu |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete System Pod And Wait It Up |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=kubectl get pod -n ${ns}|grep ${pod_abbr}|awk '{print $1}'    alias=${alias}
    ${full_pod_name}   strip prompt  ${out}
    ${out}  issh.Execute   command=kubectl delete pod ${full_pod_name} -n ${ns}   alias=${alias}

    sleep  5

    wait until keyword succeeds  60  3   vDU System Pod Status And Container Number Should Be Expected Interactively
    ...   pod_abbr=${pod_abbr}   status=Running    vdu_index=${vdu_index}   is_check_number=True   ns=${ns}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/   alias=${alias}
    log to console   ${out}


Delete VDU
    [Arguments]   ${vdu_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Delete VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU | vdu_release_name=aic-vdu |
    ...
    Log To Console   delete VDU:${vdu_release_name}

    ${platform_name}   Get Platform Name

    ${release_name}   run keyword if   "${platform_name}"=="NCIR"
       ...  _Delete VDU NCIR   vdu_release_name=${vdu_release_name}  vdu_index=${vdu_index}
    ...   ELSE   _Delete VDU NCS   vdu_release_name=${vdu_release_name}  vdu_index=${vdu_index}


_Delete VDU NCIR
    [Arguments]   ${vdu_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU | vdu_release_name=aic-vdu |
    ...
    Log To Console  helm delete ${vdu_release_name} --purge
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm delete ${vdu_release_name} --purge   alias=${alias}

    Wait Until Keyword Succeeds  900   10s    Make Sure VDU Is Deleted   vdu_index=${vdu_index}


_Delete VDU NCS
    [Arguments]   ${vdu_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU | vdu_release_name=aic-vdu |
    ...
    Log To Console  helm3 delete ${vdu_release_name}
    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    #Connect To K8s Master with tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}   get vdu namespace from testline   vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 delete ${vdu_release_name} -n ${ns}   alias=${alias}

    Wait Until Keyword Succeeds  900   10s    Make Sure VDU Is Deleted   vdu_index=${vdu_index}


Make Sure VDU Is Deleted
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure VDU Is Deleted
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.8.2020,chris.l.cao@nokia-sbell.com, change detecting method to 'kubectl get pod'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VDU Is Deleted |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}

    ${out}  issh.Execute   command=kubectl get pod   alias=${alias}
    Should Contain    ${out}   No resources found


VDU Should Not Exist
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  VDU Should Not ExistIs Deleted
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Should Not Exist |
    ...
    Wait Until Keyword Succeeds  120   10s  _VDU Should Not Exist Detect Once  gnb_index=${gnb_index}  vdu_index=${vdu_index}


_VDU Should Not Exist Detect Once
    #[Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ${alias}  Get Unique Id
    connect to k8s master with tenant interactively   alias=${alias}
    ${out}   issh.Execute  command=kubectl get pod   alias=${alias}
    should contain  ${out}   No resources found


Delete Default VDU PVC
    [Arguments]  ${vdu_index}=0
    [Documentation]   Delete Default VDU PVC
    ...   It will fetch SCF file automatically from SCF file server.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Default VDU Network |
    ...
    ${pvc_release_name}   Get VDU PVC Release Name   vdu_index=${vdu_index}
    return from keyword if  ${pvc_release_name.__len__()}==0
    Delete VDU PVC   pvc_release_name=${pvc_release_name}    vdu_index=${vdu_index}


Delete VDU PVC
    [Arguments]   ${pvc_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Delete VDU Network
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    ${platform_name}   Get Platform Name

    ${release_name}   run keyword if   "${platform_name}"=="NCIR"
       ...   _Delete VDU PVC NCIR   pvc_release_name=${pvc_release_name}  vdu_index=${vdu_index}
    ...   ELSE   _Delete VDU PVC NCS   pvc_release_name=${pvc_release_name}  vdu_index=${vdu_index}


_Delete VDU PVC NCIR
    [Arguments]   ${pvc_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU PVC NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    should not be empty  ${pvc_release_name}
    Log To Console  helm delete ${pvc_release_name} --purge
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm delete ${pvc_release_name} --purge   alias=${alias}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU PVC Is Deleted   vdu_index=${vdu_index}


_Delete VDU PVC NCS
    [Arguments]   ${pvc_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU PVC NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    should not be empty  ${pvc_release_name}
    Log To Console   delete pvc: ${pvc_release_name}
    ${alias}  Get Unique Id
    #Connect To K8s Master with tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline  vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 delete ${pvc_release_name} -n ${ns}    alias=${alias}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU PVC Is Deleted   vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  90   2s    Make Sure VDU PVC Is Deleted From Disk   vdu_index=${vdu_index}


Make Sure VDU PVC Is Deleted
    [Arguments]     ${vdu_index}=0
    [Documentation]  Make Sure VDU PVC Is Deleted
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VDU Network Is Deleted |
    ...
    ${pvc_release_name}    Get VDU PVC Release Name  vdu_index=${vdu_index}
    should be true  ${pvc_release_name.__len__()}==0


Make Sure VDU PVC Is Deleted From Disk
    [Arguments]     ${vdu_index}=0
    [Documentation]  Make Sure VDU PVC Is Deleted
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VDU Network Is Deleted |
    ...
#    ${alias}  Get Unique Id
#    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
#    ${ns}  get vdu namespace from testline  vdu_index=${vdu_index}
#    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/|grep ${ns}|wc -l   alias=${alias}
#    ${num}  strip prompt  ${out}
#    should be true  ${num}==0
     Make Sure VDU PVC Is As Expected From Disk   expected_number=0   vdu_index=${vdu_index}


Force Clear PVC Folder
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Force Clear PVC folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Force Clear PVC folder |
    ...

    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline  vdu_index=${vdu_index}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/   alias=${alias}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/|grep ${ns}|wc -l   alias=${alias}
    ${num}  strip prompt  ${out}

    return from keyword if   ${num}==0

    #need unmount firstly before remove
    #or delete dynamic-local-pv-provisioner-7d469dd57f-wn8td ?
    ${out}  issh.Execute   command=rm -rf /mnt/dynamic-local-storage/${ns}_*   alias=${alias}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/   alias=${alias}
    sleep   5


Make Sure VDU PVC Is As Expected From Disk
    [Arguments]   ${expected_number}=1   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure VDU PVC Is As Expected From Disk
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VDU PVC Is As Expected From Disk |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}  get vdu namespace from testline  vdu_index=${vdu_index}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/   alias=${alias}
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/|grep ${ns}|wc -l   alias=${alias}
    ${num}  strip prompt  ${out}
    should be true  ${num}==${expected_number}


Delete Default VDU Network
    [Arguments]  ${vdu_index}=0
    [Documentation]   Delete Default VDU Network
    ...   It will fetch SCF file automatically from SCF file server.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Default VDU Network |
    ...
    ${network_release_name}   Get VDU Network Release Name   vdu_index=${vdu_index}
    return from keyword if  ${network_release_name.__len__()}==0
    Delete VDU Network   network_release_name=${network_release_name}    vdu_index=${vdu_index}


Delete VDU Network
    [Arguments]   ${network_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Delete VDU Network
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    ${platform_name}   Get Platform Name

    ${release_name}   run keyword if   "${platform_name}"=="NCIR"
      ...   _Delete VDU Network NCIR   network_release_name=${network_release_name}  vdu_index=${vdu_index}
    ...   ELSE   _Delete VDU Network NCS   network_release_name=${network_release_name}  vdu_index=${vdu_index}


_Delete VDU Network NCIR
    [Arguments]   ${network_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU Network NCIR
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    should not be empty  ${network_release_name}
    Log To Console  helm delete ${network_release_name} --purge
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}  issh.Execute   command=helm delete ${network_release_name} --purge   alias=${alias}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU Network Is Deleted   vdu_index=${vdu_index}


_Delete VDU Network NCS
    [Arguments]   ${network_release_name}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  _Delete VDU Network NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_release_name          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | alias      | No | alias, default is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete VDU Network | vdu_release_name=aic-vdu |
    ...
    should not be empty  ${network_release_name}
    Log To Console   delete network: ${network_release_name}
    ${alias}  Get Unique Id
    #Connect To K8s Master with tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias}
    ${ns}   get vdu namespace from testline
    ${out}  issh.Execute   command=sudo helm3 delete ${network_release_name} -n ${ns}    alias=${alias}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU Network Is Deleted   vdu_index=${vdu_index}


Make Sure VDU Network Is Deleted
    [Arguments]     ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure VDU Network Is Deleted
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Make Sure VDU Network Is Deleted |
    ...
    ${network_release_name}    Get VDU Network Release Name  vdu_index=${vdu_index}
    should be true  ${network_release_name.__len__()}==0


Prepare To Reinstall VDU
    [Arguments]  ${vdu_index}=0
    [Documentation]   Prepare To Reinstall VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    build number of current running VDU
    ...
    ...   Example
    ...   | ${current_build_number} |  Prepare To Reinstall VDU |
    Upload SCF File To SCF File Server
    ${tmp_current_build_number}   Get Running Build Number   vdu_index=${vdu_index}
    [Return]  ${tmp_current_build_number}


Get Platform Name
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error    disconnect interactive connection    alias=${alias}
    [Documentation]   Get Platform Name
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  None
    ...
    ...   *RETURN VALUE*
    ...    NCIR or NCS
    ...
    ...   Example
    ...   | ${platform} | Get Platform Name |
    ...
    ${conf}   Get vDU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${platform}   set variable if  "NCIR" in "${conf["misc"]["platform_type"]}"    NCIR
     ...   "NCS" in "${conf["misc"]["platform_type"]}"   NCS   OCP
    [Return]  ${platform}


Reinstall VDU With Special Build
    [Arguments]  ${build_number}   ${load_image}=${True}  ${commission}=${True}   ${vdu_index}=0   ${remote_yaml_file_info}=${EMPTY}
    ...   ${need_check_on_air}=${True}   ${check_on_air_timeout}=1000   ${retries}=4x    ${override2override_dict_vdu}=${EMPTY}
    [Documentation]   Reinstall VDU With Special Build
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    history change: <date>,<who>,<what and how>
    ...   10.11.2020,chris.l.cao@nokia-sbell.com, initial version
    ...   15.6.2020,chris.l.cao@nokia-sbell.com, add support override2override_dict_vdu.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.390.1151 |
    ...	  | load_image | no | load_image, default is ${True} |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...   | override2override_dict_vdu  | no | override2override_dict_vdu, override of override-values.yaml, default is ${EMPTY} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Reinstall VDU With Special Build |  build_number=0.390.1111 |
    ...   | Reinstall VDU With Special Build |  build_number=0.390.1111 | load_image=${True} |
    ...   | Reinstall VDU With Special Build |  build_number=0.390.1111 | load_image=${False} |
    ...
    log to console   Reinstall VDU With Special Build: Set Agent Flag to 1

    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    run keyword and ignore error  swm._Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=1

    should not be empty  ${build_number}
    wait until keyword succeeds   ${retries}  30s  _Reinstall VDU With Special Build Once
       ...   build_number=${build_number}   load_image=${load_image}  vdu_index=${vdu_index}   remote_yaml_file_info=${remote_yaml_file_info}
       ...   commission=${commission}      need_check_on_air=${need_check_on_air}   check_on_air_timeout=${check_on_air_timeout}
       ...   override2override_dict_vdu=${override2override_dict_vdu}


_Reinstall VDU With Special Build Once
    [Arguments]  ${build_number}   ${load_image}=${True}   ${commission}=${True}   ${vdu_index}=0   ${remote_yaml_file_info}=${EMPTY}
    ...   ${need_check_on_air}=${True}   ${check_on_air_timeout}=1000    ${override2override_dict_vdu}=${EMPTY}
    [Documentation]   _Reinstall VDU With Special Build Once
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.390.1151 |
    ...	  | load_image | no | load_image, default is ${True} |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _Reinstall VDU With Special Build Once |  build_number=0.390.1111 |
    ...

    ${platform_name}   Get Platform Name

    run keyword if   "${platform_name}"=="NCIR"  _Reinstall VDU With Special Build Once NCIR     build_number=${build_number}
      ...  load_image=${load_image}   commission=${commission}   vdu_index=${vdu_index}   remote_yaml_file_info=${remote_yaml_file_info}
      ...  need_check_on_air=${need_check_on_air}   check_on_air_timeout=${check_on_air_timeout}
      ...  override2override_dict_vdu=${override2override_dict_vdu}
    ...   ELSE    _Reinstall VDU With Special Build Once NCS     build_number=${build_number}
      ...  load_image=${load_image}   commission=${commission}   vdu_index=${vdu_index}   remote_yaml_file_info=${remote_yaml_file_info}
      ...  need_check_on_air=${need_check_on_air}   check_on_air_timeout=${check_on_air_timeout}
      ...  override2override_dict_vdu=${override2override_dict_vdu}


_Reinstall VDU With Special Build Once NCIR
    [Arguments]  ${build_number}   ${load_image}=${True}   ${commission}=${True}   ${vdu_index}=0   ${remote_yaml_file_info}=${EMPTY}
    ...   ${need_check_on_air}=${True}   ${check_on_air_timeout}=1000   ${override2override_dict_vdu}=${EMPTY}
    [Documentation]   _Reinstall VDU With Special Build Once NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.390.1151 |
    ...	  | load_image | no | load_image, default is ${True} |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _Reinstall VDU With Special Build Once NCIR |  build_number=0.390.1111 |
    ...
    ${r}   run keyword and ignore error  VDU Sync State Should Be OK    vdu_index=${vdu_index}   restart_sync_service=${True}
    run keyword if   "${r[0]}"=="FAIL"   Fail   VDU Sync State is not OK!
    return from keyword if   "${r[0]}"=="FAIL"

    ${testline_name}   Get TestLine Name From TestLine
    should not be empty  ${testline_name}

    ${r}   ${scf_file}  run keyword and ignore error  Download SCF File From SCF File Server
     ...   tl_name=${testline_name}     build_number=${build_number}
    run keyword if   "${r}"=="FAIL"   Fail   No SCF file is found in SCF server or config repository!
    return from keyword if   "${r}"=="FAIL"

    Delete Default VDU   vdu_index=${vdu_index}
    Delete Default VDU Network   vdu_index=${vdu_index}
    Delete Default VDU PVC    vdu_index=${vdu_index}

    run keyword if  "${load_image}"=="${True}"   Delete Image For VDU   except_for_build_number=${build_number}
    run keyword if  "${load_image}"=="${True}"   Load Image For VDU   build_number=${build_number}   vdu_index=${vdu_index}

    VDU PVdelete   build_number=${build_number}   vdu_index=${vdu_index}

    Execute WA Command via CLI   vdu_index=${vdu_index}
    Execute WA2 Command via CLI  vdu_index=${vdu_index}

    ${conf_dict_vdu_pvc}       Get VDU PVC Vnf Config Dictionary From TestLine
    ${conf_dict_vdu_network}   Get VDU Network Vnf Config Dictionary From TestLine
    ${conf_dict_vdu}           Get VDU Vnf Config Dictionary From TestLine
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary   ${override2override_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"
       ...   Update_Dictionary   src_dict=${override2override_dict_vdu}   dst_dict=${conf_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}

    #for debug purse
    #${remote_yaml_file_info}   create dictionary     remote_vdu_chart_yaml_file=/home/cranuser1/1611/HelmChart/aic-vdu/values-override.yaml

    ${remote_yaml_file_info}    run keyword if   "${remote_yaml_file_info}"=="${EMPTY}"
      ...   Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster
      ...  override_dict_vdu_pvc=${conf_dict_vdu_pvc}
      ...  override_dict_vdu_network=${conf_dict_vdu_network}
      ...  override_dict_vdu=${conf_dict_vdu}
      ...  build_number=${build_number}
      ...  ELSE   set variable   ${remote_yaml_file_info}

    #deploy pvc,intnet, vdu
    ${vdu_release_name}   Get VDU Release Name From Testline
    ${vdu_release_name_prefix}   set variable  ${vdu_release_name.split("-")[0]}
    _Set Result Flag for Restore Environment To Onair   1
    Restore Environment To Onair    build_number=${build_number}   need_redeployment=${True}    commission=${commission}
    ...   vdu_release_name_prefix=${vdu_release_name_prefix}   remote_yaml_file_info=${remote_yaml_file_info}
    ...   need_check_on_air=${need_check_on_air}   check_on_air_timeout=${check_on_air_timeout}

    ${flag}   _Get Flag for Restore Environment To Onair
   # run keyword if   ${flag}==0   run keyword and ignore error   Get VDU POD Syslog
    #run keyword if   ${flag}==0   run keyword and ignore error   Collect vDU Kubectl Logs
    #run keyword if   ${flag}==0   run keyword and ignore error   Collect VDU Describe PODs Log
    run keyword if   ${flag}==0   Fail   'Restore Environment To Onair':FAIL!


_Reinstall VDU With Special Build Once NCS
    [Arguments]  ${build_number}   ${load_image}=${True}   ${commission}=${True}   ${vdu_index}=0   ${remote_yaml_file_info}=${EMPTY}
    ...   ${need_check_on_air}=${True}   ${check_on_air_timeout}=1000    ${override2override_dict_vdu}=${EMPTY}
    [Documentation]   _Reinstall VDU With Special Build Once NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.390.1151 |
    ...	  | load_image | no | load_image, default is ${True} |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _Reinstall VDU With Special Build Once NCS |  build_number=0.390.1111 |
    ...

    ${r}   run keyword and ignore error   FHGW Sync State Should Be Locked
    run keyword if   "${r[0]}"=="FAIL"   Fail   FHGW Sync State is not OK!
    return from keyword if   "${r[0]}"=="FAIL"

    run keyword and ignore error   Check Ecpri Port And Correct It If Necessary

    ${r}   run keyword and ignore error  VDU Sync State Should Be OK    vdu_index=${vdu_index}   restart_sync_service=${True}
    run keyword if   "${r[0]}"=="FAIL"   Fail   VDU Sync State is not OK!
    return from keyword if   "${r[0]}"=="FAIL"

    ${testline_name}   Get TestLine Name From TestLine
    should not be empty  ${testline_name}

    ${r}   ${scf_file}  run keyword and ignore error  Download SCF File From SCF File Server
     ...   tl_name=${testline_name}     build_number=${build_number}
    run keyword if   "${r}"=="FAIL"   Fail   No SCF file is found in SCF server or config repository!
    return from keyword if   "${r}"=="FAIL"

    Delete Default VDU   vdu_index=${vdu_index}
    Delete Default VDU Network   vdu_index=${vdu_index}
    #WA: sometimes there is /mnt/devxxxx/cran1_xxxx left
    run keyword and ignore error   Delete Default VDU PVC    vdu_index=${vdu_index}

    ${r}   ${out}  run keyword and ignore error   Reboot VDU Node If State Is Not Ready   vdu_index=${vdu_index}
    run keyword if   "${r}"=="FAIL"   Fail   Fail to reboot VDU K8s Node!

    Delete Available PV   vdu_index=${vdu_index}
    Delete System Pod And Wait It Up   pod_abbr=dynamic-local-pv-provisioner-   ns=kube-system

    #Force Clear PVC Folder
    Clear Name Space And Recreate It   build_number=${build_number}  vdu_index=${vdu_index}

    run keyword if  "${load_image}"=="${True}"   Delete Image For VDU NCS   except_for_build_number=${build_number}
    run keyword if  "${load_image}"=="${True}"   Load Image For VDU   build_number=${build_number}   vdu_index=${vdu_index}

    Execute WA Command via CLI   vdu_index=${vdu_index}
    #Execute WA2 Command via CLI  vdu_index=${vdu_index}

    ${conf_dict_vdu_pvc}       Get VDU PVC Vnf Config Dictionary From TestLine
    ${conf_dict_vdu_network}   Get VDU Network Vnf Config Dictionary From TestLine
    ${conf_dict_vdu}           Get VDU Vnf Config Dictionary From TestLine
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary   ${override2override_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"
       ...   Update_Dictionary   src_dict=${override2override_dict_vdu}   dst_dict=${conf_dict_vdu}
    run keyword if  "${override2override_dict_vdu}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}

    #for debug purse
    #${vdu_yaml}  set variable    /tmp/tmp_taic_cran1/5G_Reinstall/2021_06_01_13_34_01/
    #${vdu_yaml}  set variable   ${vdu_yaml}cranuser1_162252585764/single_pkg/HelmChart/aic-vdu/values-override.yaml
    #${remote_yaml_file_info}   create dictionary    remote_vdu_chart_yaml_file=${vdu_yaml}

    ${remote_yaml_file_info}    run keyword if   "${remote_yaml_file_info}"=="${EMPTY}"
      ...   Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster NCS
      ...  override_dict_vdu_pvc=${conf_dict_vdu_pvc}
      ...  override_dict_vdu_network=${conf_dict_vdu_network}
      ...  override_dict_vdu=${conf_dict_vdu}
      ...  build_number=${build_number}
      ...  ELSE   set variable   ${remote_yaml_file_info}

    #deploy pvc,intnet, vdu
    ${vdu_release_name}   Get VDU Release Name From Testline
    ${vdu_release_name_prefix}   set variable  ${vdu_release_name.split("-")[0]}
    _Set Result Flag for Restore Environment To Onair   1
    Restore Environment To Onair NCS   build_number=${build_number}   need_redeployment=${True}    commission=${commission}
    ...   vdu_release_name_prefix=${vdu_release_name_prefix}   remote_yaml_file_info=${remote_yaml_file_info}
    ...   need_check_on_air=${need_check_on_air}   check_on_air_timeout=${check_on_air_timeout}
    ...   scf_file=${scf_file}

    ${flag}   _Get Flag for Restore Environment To Onair
   # run keyword if   ${flag}==0   run keyword and ignore error   Get VDU POD Syslog
    #run keyword if   ${flag}==0   run keyword and ignore error   Collect vDU Kubectl Logs
    #run keyword if   ${flag}==0   run keyword and ignore error   Collect VDU Describe PODs Log
    run keyword if   ${flag}==0   Fail   'Restore Environment To Onair':FAIL!


Delete Available PV
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Delete Available PV
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Available PV |
    ...
    log to console  Delete Available PV
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}
    ${ns}   get vdu namespace from testline    vdu_index=${vdu_index}
    ${out}  issh.Execute  command=kubectl get pv -n ${ns}|grep Available|awk '{print $1}'
     ...   check_result=${False}
     ...   alias=${alias_master}
    ${out}   strip prompt  ${out}
    ${out}  issh.Execute  command=kubectl get pv -n ${ns}|grep Available|awk '{print $1}'|xargs kubectl delete persistentvolume
     ...   check_result=${False}
     ...   alias=${alias_master}

    sleep  2


Clear Name Space And Recreate It
    [Arguments]   ${build_number}   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Clear Name Space And Recreate It
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | build_number | yes | build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Execute WA Command via CLI |
    ...
    log to console    Clear Name Space And Recreate It
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${dir_name}   Get Unique ID   prefix=aicClusterResource_   precise=LOW
    ${aicClusterResource_dir}  Get A Remote Directory   ${dir_name}   alias=${alias_master}

    ${zip_file_name}   set variable   aicClusterResource.tgz
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/artifacts/${zip_file_name}

    ${out}   issh.Execute   command=cd ${aicClusterResource_dir}   alias=${alias_master}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias_master}
    ${out}   issh.Execute   command=tar -xzf ${zip_file_name}    alias=${alias_master}
    ${out}   issh.Execute   command=cd aicClusterResource        alias=${alias_master}

    ${container_network_file}   set variable   container_network.ini
    ${conf}   Get vDU One Click Config Dictionary From TestLine
    ${internal_vlanrange}  set variable   ${conf["vlan"]["internal_range"]}
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info
    ${ssh_username}   set variable   ${vdu_k8s_tenant_ssh_connection_info["username"]}

    ${out}   issh.Execute   command=sed -i 's@fhuc_device_pool=.*@fhuc_device_pool=nokia.k8s.io/sriov_vfio_ens1f1@g' ${container_network_file}
     ...   alias=${alias_master}
    ${out}   issh.Execute   command=sed -i 's@fhm_device_pool=.*@fhm_device_pool=nokia.k8s.io/sriov_ens1f1@g' ${container_network_file}
     ...   alias=${alias_master}
    ${out}   issh.Execute   command=sed -i 's@internal_vlanrange=.*@internal_vlanrange=${internal_vlanrange}@g' ${container_network_file}
     ...   alias=${alias_master}

    ${out}   issh.Execute   command=./aicClusterResourcePlus.sh -r       alias=${alias_master}     check_result=False

    ${out}   issh.Execute   command=sudo userdel -f ${ssh_username}      alias=${alias_master}     check_result=False
    ${out}   issh.Execute   command=cat /etc/passwd|grep ${ssh_username}|wc -l      alias=${alias_master}
    ${num}   strip prompt  ${out}
    #run keyword and ignore error   should be true   ${num}==0
    should be true   ${num}==0

    ${out}   issh.Execute   command=./aicClusterResourcePlus.sh -s       alias=${alias_master}


OAM Precondition Cell Should Be Onair For Deploy VDU
    [Documentation]   OAM Precondition Cell Should Be Onair For Deploy VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | OAM Precondition Cell Should Be Onair For Deploy VDU |
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair For Deploy VDU ... ***
    All DUs Container Status Should Be Normal
    vDU Verify All Cells Status Should Be Onair
   #    Should Have Power On All RUs
    Run Keyword And Ignore Error  Vdu Rest Logout
    run keyword and ignore error  Disconnect Interactive Connections


Deploy VDU
    [Arguments]  ${yaml_file}   ${vdu_release_name_prefix}=aic
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias_k8s_tenant}
    [Documentation]  Deploy VDU according to yaml file
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | yaml_file     |  Yes | yaml_file |
    ...    | vdu_release_name_prefix |  No | vdu_release_name prefix, default is aic |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deploy VDU | yaml_file=/tmp/my_yaml_file.yml |  |
    ...    | Deploy VDU | yaml_file=/tmp/my_yaml_file.yml | vdu_release_name=my_vdu_name |
    ...
    log to console   CU Restart All VMs
    run keyword and ignore error  CU Restart All VMs
    log to console   sleep 40
    sleep   40

    log to console   Wait For VCU OAM Up With Long Period Time(timeout:240s)
    Wait For VCU OAM Up With Long Period Time    detection_time=240

    wait until keyword succeeds   120   10s   VCU To LTE Network Connection should be OK

    ${ns}  Get VDU Namespace From TestLine
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}
    ${old}   issh.Set_Timeout  timeout=600   alias=${alias_k8s_tenant}

    ${yaml_path}   ${base_yaml_file}   OperatingSystem.Split Path   ${yaml_file}
    ${out}   issh.Execute   command=cd ${yaml_path}   alias=${alias_k8s_tenant}

    log to console   Begin to run 'helm install'...
    ${out}   issh.Execute    command=cd ../aic-pvc   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=helm install ./ -f values-override.yaml --name ${vdu_release_name_prefix}-pvc
        ...  alias=${alias_k8s_tenant}
    sleep   6

    ${out}   issh.Execute    command=cd ../aic-intnet   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=helm install ./ -f values-override.yaml --name ${vdu_release_name_prefix}-intnet
        ...  alias=${alias_k8s_tenant}
    sleep   6

    ${out}   issh.Execute    command=cd ../aic-vdu   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=helm install ./ -f values-override.yaml --name ${vdu_release_name_prefix}-vdu
        ...  alias=${alias_k8s_tenant}

    ${old}   Convert To Integer  ${old}
    issh.Set_Timeout   timeout=${old}   alias=${alias_k8s_tenant}

    log to console   sleep 30 after helm install
    sleep  30


Deploy VDU NCS
    [Arguments]  ${yaml_file}   ${vdu_release_name_prefix}=aic
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias_k8s_tenant}
    [Documentation]  Deploy VDU NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | yaml_file     |  Yes | yaml_file |
    ...    | vdu_release_name_prefix |  No | vdu_release_name prefix, default is aic |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deploy VDU | yaml_file=/tmp/my_yaml_file.yml |  |
    ...    | Deploy VDU | yaml_file=/tmp/my_yaml_file.yml | vdu_release_name_prefix=aic |
    ...
    log to console   CU Restart All VMs
    run keyword and ignore error  CU Restart All VMs
    log to console   sleep 40
    sleep   40

    log to console   Wait For VCU OAM Up With Long Period Time(timeout:240s)
    Wait For VCU OAM Up With Long Period Time    detection_time=240

    wait until keyword succeeds   120   10s   VCU To LTE Network Connection should be OK

    ${ns}  Get VDU Namespace From TestLine
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}

    ${ns}  get vdu namespace from testline
    ${old_prompt}   issh.Get Prompt    alias=${alias_k8s_tenant}
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info
    ${ssh_username}   set variable   ${vdu_k8s_tenant_ssh_connection_info["username"]}
    ${ssh_password}   set variable   ${vdu_k8s_tenant_ssh_connection_info["password"]}
    ${new_prompt}   set variable    password for ${ssh_username}:
    issh.Set Prompt   prompt_str=${old_prompt}|${new_prompt}   alias=${alias_k8s_tenant}

    ${yaml_path}   ${base_yaml_file}   OperatingSystem.Split Path   ${yaml_file}
    ${out}   issh.Execute   command=cd ${yaml_path}   alias=${alias_k8s_tenant}

    log to console   Begin to run 'sudo helm3 install'...
    #aic-pvc
    ${out}   issh.Execute    command=cd ../aic-pvc   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=sudo helm3 install ${vdu_release_name_prefix}-pvc ./ -f values-override.yaml -n ${ns}
        ...  check_result=False
        ...  alias=${alias_k8s_tenant}

    ${out}   run keyword if   "${new_prompt}" in """${out}"""
    ...   issh.Execute   command=${ssh_password}   check_result=False  alias=${alias_k8s_tenant}
    log to console   ${out}

    ${out}  issh.Execute   command=echo $?   check_result=False  alias=${alias_k8s_tenant}
    ${out}  strip prompt  ${out}
    should be true   ${out}==0

    sleep   2

    #aic-intnet
    ${out}  issh.Execute   command=ls -l /mnt/dynamic-local-storage/|grep ${ns}|wc -l   alias=${alias_k8s_tenant}
    ${out}  strip prompt  ${out}
    #should be true   ${out}==1

    ${out}   issh.Execute    command=cd ../aic-intnet   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=sudo helm3 install ${vdu_release_name_prefix}-intnet ./ -f values-override.yaml -n ${ns}
        ...  alias=${alias_k8s_tenant}
    sleep   5
    ${out}   run keyword if   "${new_prompt}" in """${out}"""
    ...   issh.Execute   command=${ssh_password}   check_result=False  alias=${alias_k8s_tenant}
    log to console   ${out}

    ${out}  issh.Execute   command=echo $?   check_result=False  alias=${alias_k8s_tenant}
    ${out}  strip prompt  ${out}
    should be true   ${out}==0

    #aic-vdu
    ${old}   issh.Set_Timeout  timeout=400   alias=${alias_k8s_tenant}

    ${out}   issh.Execute    command=cd ../aic-vdu   alias=${alias_k8s_tenant}
    ${out}   issh.Execute
        ...  command=sudo helm3 install ${vdu_release_name_prefix}-vdu ./ -f values-override.yaml -n ${ns}
        ...  alias=${alias_k8s_tenant}
    ${out}   run keyword if   "${new_prompt}" in """${out}"""
    ...   issh.Execute   command=${ssh_password}   check_result=False  alias=${alias_k8s_tenant}
    log to console   ${out}

    ${out}  issh.Execute   command=echo $?   check_result=False  alias=${alias_k8s_tenant}
    ${out}  strip prompt  ${out}
    should be true   ${out}==0

    ${old}   Convert To Integer  ${old}
    issh.Set_Timeout   timeout=${old}   alias=${alias_k8s_tenant}

    log to console   sleep 30 after helm install
    sleep  70

    run keyword and ignore error    _Set Pod And Container Name Prefix
    ${r}   ${container_prefix}   run keyword and ignore error   Get Container Name Prefix
    log to console    ${container_prefix}


Ping From LTE To VCU X2C should be OK
    [Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   VCU To LTE Network Connection should be OK
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  VCU To LTE Network Connection should be OK |
    ...
    log to console   Ping From LTE To VCU X2C should be OK
    ${alias}  get unique id
    Connect To LTE   alias=${alias}

    ${vcu_oam_ip}   Get vCU OAM Ip   gnb_index=${gnb_index}
    ${is_ipv6}  set variable if   ":" in "${vcu_oam_ip}"   1   0

    ${vcu_x2c_ip}   run keyword if  "${is_ipv6}"=="1"  Get VCU X2C Ipv6
    ...    ELSE   Get VCU X2C Ip

    ${out}   issh.Execute  command=ping ${vcu_x2c_ip} -c 3 -I br1     alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100


Ping From VCU X2C To LTE should be OK
    #[Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alais_vcu}
    [Documentation]   VCU To LTE Network Connection should be OK
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  VCU To LTE Network Connection should be OK |
    ...
    log to console   Ping From VCU X2C To LTE should be OK
    ${alais_vcu}   get unique id
    CU SSH To CPIF   alias=${alais_vcu}
    ${lte_ip}   Get LTE OAM Ip
    ${out}   issh.Execute  command=ping ${lte_ip} -c 3     alias=${alais_vcu}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100


VCU To LTE Network Connection should be OK
    [Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   VCU To LTE Network Connection should be OK
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  VCU To LTE Network Connection should be OK |
    ...
    log to console   VCU To LTE Network Connection should be OK
    ${alias}  get unique id
    Connect To LTE   alias=${alias}

    ${vcu_oam_ip}   Get vCU OAM Ip   gnb_index=${gnb_index}
    ${is_ipv6}  set variable if   ":" in "${vcu_oam_ip}"   1   0
    ${lte_gw}   run keyword if  "${is_ipv6}"=="1"  Get LTE Gateway Ipv6
    ...    ELSE   Get LTE Gateway

    ${out}   issh.Execute  command=ping ${lte_gw} -c 3 -I br1    alias=${alias}

    ${r}   ${out}    run keyword and ignore error   Ping From VCU X2C To LTE should be OK
    return from keyword if   "${r}"=="PASS"

    Ping From LTE To VCU X2C should be OK


Check VDU Critical POD Should Be Good And Return Immediately If Failed
    [Arguments]   ${retries_time}=8   ${interval}=10   ${console_msg}=Check VDU Critical POD Should Be Good
    [Documentation]   Check VDU Critical POD Should Be Good And Return Immediately If Failed
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | console_msg     |  No | console_msg |
    ...
    ...    *RETURN VALUE*
    ...    ${True} if pod is OK, otherwise return ${False}
    ...
    ...    Example
    ...    | ${r} | Check VDU Critical POD Should Be Good And Return Immediately If Failed  |
    ...
    log to console   ${console_msg}
    FOR   ${i}   IN RANGE  0   ${retries_time}
        log to console  Check VDU Critical POD Should Be Good And Return Immediately If Failed(${i})
        ${r}   run keyword and ignore error   All DUs Container Status Should Be Normal
        return from keyword if  "${r[0]}"=="PASS"    ${True}
        sleep   ${interval}
        ${has_error}   Check Whether All DUs Container Status Has Error   state_error_keywords=err crash
        run keyword if  "${has_error}"=="${True}"    log to console   POD state has error!
        return from keyword if   "${has_error}"=="${True}"   ${False}
    END

    log to console   Pod State is BAD!
    [Return]  ${False}


Check VDU Critical POD Should Be Good
    [Arguments]  ${console_msg}=Check VDU Critical POD Should Be Good
    [Documentation]  Check VDU Critical POD Should Be Good
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | console_msg     |  No | console_msg |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check VDU Critical POD Should Be Good  |
    ...
    log to console   ${console_msg}
    All DUs Container Status Should Be Normal


Deploy VDU PVC
   [Arguments]  ${yaml_file}   ${vdu_pvc_release_name}=aic-pvc
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias_k8s_tenant}
    [Documentation]  Deploy VDU PVC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | yaml_file     |  Yes | yaml_file |
    ...    | vdu_pvc_release_name |  No | vdu_pvc_release_name, default is aic-pvc |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deploy VDU PVC | yaml_file=/tmp/my_yaml_file.yml |  |
    ...    | Deploy VDU PVC | yaml_file=/tmp/my_yaml_file.yml | vdu_pvc_release_name=my_pvc_name |
    ...
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}

    ${path}  ${file}   OperatingSystem.Split Path   ${yaml_file}
    ${out}   issh.Execute   command=cd ${path}   alias=${alias_k8s_tenant}
    ${old}   issh.Set_Timeout  timeout=300   alias=${alias_k8s_tenant}
    #${out}   issh.Execute   command=helm install ./ --version ${build} -f ${yaml_file} --name ${vdu_intnet_release_name}   alias=${alias_k8s_tenant}
    ${out}   issh.Execute   command=helm install ./ -f ${yaml_file} --name ${vdu_pvc_release_name}   alias=${alias_k8s_tenant}

    ${old}   Convert To Integer  ${old}
    issh.Set_Timeout   timeout=${old}   alias=${alias_k8s_tenant}


VDU PVdelete
    [Arguments]    ${build_number}   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   VDU PVdelete
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.390.1151 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU PVdelete |
    ...
    log to console  VDU PVdelete
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}
    ${ns}    Get vDU Namespace From TestLine

    ${dir_name}   Get Unique ID   prefix=tmp_   precise=LOW
    ${tmp_dir}  Get A Remote Directory   ${dir_name}  alias=${alias_master}
    ${aicClusterResource_file_name}   set variable   aicClusterResource.tgz
    #${url}    set variable  ${PACKAGE_LINK}/${build_number}/vdu-dep-artifacts/${aicClusterResource_file_name}
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/artifacts/${aicClusterResource_file_name}
    ${out}   issh.Execute   command=cd ${tmp_dir}   alias=${alias_master}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias_master}
    ${out}   issh.Execute   command=tar -xzf ${aicClusterResource_file_name}    alias=${alias_master}

    ${out}   issh.Execute   command=pwd   alias=${alias_master}
    ${out}   issh.Execute   command=ls -l   alias=${alias_master}
    ${out}   issh.Execute   command=cd aicClusterResource   alias=${alias_master}

    #${tool_name}   set variable  ./vdutool.sh
    #${tool_name}   set variable  ./aicClusterResource.sh
    ${out}   issh.Execute   command=./aicClusterResource.sh pv delete -n ${ns}      alias=${alias_master}

    ${out}   issh.Execute   command=./aicClusterResource.sh sysctl allowed --param accept_ra      alias=${alias_master}
    ${out}   issh.Execute   command=./aicClusterResource.sh sysctl allowed --param disable_ipv6      alias=${alias_master}

    ${out}   issh.Execute   command=./aicClusterResource.sh psp update     alias=${alias_master}

    ${out}   issh.Execute   command=sync     alias=${alias_master}
    ${out}   issh.Execute   command=kubectl get pv     alias=${alias_master}
    ${out}   issh.Execute   command=ls -l /mnt/caas_app/     alias=${alias_master}
    log to console  ${out}

    #sleep   60
    sleep   20

Download vDU PDL Validation Plugin From WFT
    [Arguments]    ${build_number}   #${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Download vDU PDL Validation Plugin From WFT
    ...   *AUTHOR* jianlin.zhang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.300.900 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Download vDU PDL Validation Plugin From WFT |
    ...
    log to console  Download vDU PDL Validation Plugin From WFT
    ${alias}  get unique id
    Connect To UTE Locally    alias=${alias}
    ${dir_name}   Get Unique ID   prefix=tmp_   precise=LOW
    ${tmp_dir}  Get A Directory   ${dir_name}  alias=${alias}
    ${pdl_validation_file_name}   set variable   5G_${build_number}_pdl_validation_service_plugin.zip
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/${pdl_validation_file_name}
    ${out}   issh.Execute   command=cd ${tmp_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${result}  issh.Execute  command=ls -al ${tmp_dir}/5G_${build_number}_pdl_validation_service_plugin.zip  alias=${alias}
    should not be empty    ${result}
    ${package_local_path}   OperatingSystem.Join Path  ${tmp_dir}  5G_${build_number}_pdl_validation_service_plugin.zip
    log to console  ${package_local_path}
    [Return]  ${package_local_path}

VDU PVdelete For PV Bad Branch
    [Arguments]   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   VDU PVdelete
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU PVdelete |
    ...
    log to console   VDU PVdelete For PV Bad Branch

    log to console   download aicClusterResource.tgz of 1677 from tools server
    upload tools to k8s master  vdu_index=${vdu_index}

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}
    ${ns}    Get vDU Namespace From TestLine

    ${dir_name}   Get Unique ID   prefix=tmp_   precise=LOW
    ${tmp_dir}  Get A Remote Directory   ${dir_name}  alias=${alias_master}

    #${aicClusterResource_file_name}   set variable   aicClusterResource.tgz
    ${aicClusterResource_file_name}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_data"]}   aicClusterResource.tgz

    ${out}   issh.Execute   command=cd ${tmp_dir}   alias=${alias_master}

    #${out}   issh.Execute   command=wget ${url}    alias=${alias_master}
    ${out}   issh.Execute   command=cp ${aicClusterResource_file_name} .   alias=${alias_master}

    ${out}   issh.Execute   command=tar -xzf aicClusterResource.tgz     alias=${alias_master}
    ${out}   issh.Execute   command=pwd   alias=${alias_master}
    ${out}   issh.Execute   command=ls -l   alias=${alias_master}
    ${out}   issh.Execute   command=cd aicClusterResource   alias=${alias_master}
    ${out}   issh.Execute   command=./vdutool.sh -PVdelete ${ns}      alias=${alias_master}
    ${out}   issh.Execute   command=./vdutool.sh -PVdelete --clear     alias=${alias_master}
    #${out}   issh.Execute   command=./vdutool.sh -PSPupdate    alias=${alias_master}
    ${out}   issh.Execute   command=sudo rm -rf /mnt/caas_app/${ns}_*     alias=${alias_master}

    ${out}   issh.Execute   command=sync     alias=${alias_master}
    ${out}   issh.Execute   command=kubectl get pv     alias=${alias_master}
    ${out}   issh.Execute   command=ls -l /mnt/caas_app/     alias=${alias_master}
    log to console  ${out}

    sleep   60


Delete Default VDU
    [Arguments]  ${vdu_index}=0
    [Documentation]   Delete Default VDU
    ...   It will fetch SCF file automatically from SCF file server.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Delete Default VDU |
    ...
    ${vdu_release_name}   Get VDU Release Name   vdu_index=${vdu_index}
    return from keyword if  ${vdu_release_name.__len__()}==0
    ${alias}   get unique id
    Delete VDU   vdu_release_name=${vdu_release_name}    vdu_index=${vdu_index}


Connect To SCF File Server
    [Arguments]   ${alias}=default
    [Documentation]  Connect To SCF File Server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To SCF File Server      |
    ...    | ${out}                            | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection |
    ...
    issh.connect_to   ip=${SCF_FILE_SERVER_IP}    username=${SCF_FILE_SERVER_USERNAME}   password=${SCF_FILE_SERVER_PASSWORD}
       ...   prompt=ute@.*\\$    alias=${alias}   width=200


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


Get vDU Job
    #[Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Job
    ...  author: jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    job name
    ...
    ...    Example
    ...    | ${job_name} | Get vDU Job |
    ...
    ${ns}  Get VDU Namespace From TestLine
    ${alias_k8s_tenant}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}
    ${out}   issh.Execute    command=kubectl get job -n ${ns} |awk '{print $1}'   alias=${alias_k8s_tenant}
    ${job_name}  strip prompt  ${out}
    [Return]   ${job_name}
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
Download SCF File From SCF File Server
    [Arguments]    ${tl_name}   ${build_number}
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]  Download SCF File From SCF File Server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | tl_name      |  yes | tl_name, e.g. 7_5_UTEAIC5G001T201 |
    ...    | build_number |  yes | build_number, e.g. 0.390.928 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full path
    ...
    ...    Example
    ...    | ${testline_name} | Get TestLine Name From TestLine |
    ...    | ${build_number}  | Get Running Build Number |
    ...    | ${scf_file} | Download SCF File From SCF File Server | tl_name=${testline_name} | build_number=${build_number} |
    ...

    ${scf_file_name_of_current_branch}   Construct VDU Scf File Name   build_number=${build_number}
    ${r}  ${scf_file_name}  run keyword and ignore error  Get VDU Scf File From Test Line   file_name=${scf_file_name_of_current_branch}
    return from keyword if    "${r}"=="PASS"   ${scf_file_name}

    ${alias}  get unique id
    Connect To SCF File Server  alias=${alias}
    issh.Execute   command=cd ${SCF_FILE_SERVER_FOLDER}   alias=${alias}
    ${out}   issh.Execute   command=ls -l . |grep ${TL_name}_${build_number}|head -1|wc -l   check_result=${False}   alias=${alias}
    ${count}  strip prompt  ${out}
    should be true  ${count}==1

    ${out}   issh.Execute   command=ls -l . |grep ${TL_name}_${build_number}|head -1|awk '{print $9}'    alias=${alias}
    ${scf_file}  strip prompt  ${out}

    ${random_file_name}  Get Unique Id    prefix=scf_from_scf_server_    suffix=.xml   precise=LOW
    ${downloaded_file_name}   get a file   scf_server   ${random_file_name}
    ${remote_scf}   OperatingSystem.Join Path   ${SCF_FILE_SERVER_FOLDER}   ${scf_file}
    issh.download_file   remote_path=${remote_scf}   local_path=${downloaded_file_name}    alias=${alias}
    [Return]  ${downloaded_file_name}


Construct VDU Scf File Name
    [Arguments]  ${build_number}=0.300.2526
    ${sub_number_list}   set variable   ${build_number.split(".")}
    # vDU_SCF_0.300.xml
    ${scf_file_name}   set variable   vDU_SCF_${sub_number_list[0]}.${sub_number_list[1]}.xml
    [Return]    ${scf_file_name}


Upload SCF File To SCF File Server
    [Teardown]   run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]  Upload SCF File To SCF File Server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.11.2020,chris.l.cao@nokia-sbell.com, initial version
    ...   18.6.2021,chris.l.cao@nokia-sbell.com, change for S3 server is cancelled
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${scf_file} | Upload SCF File To SCF File Server | tl_name=${testline_name} | build_number=${build_number} |
    ...

    return from keyword

    ${tl_name}   Get TestLine Name From TestLine
    should be true  ${TL_name.__len__()>0}

    ${build_number}    Get Running Build Number
    should be true  ${build_number.__len__()>0}

    ${alias}  get unique id
    Connect To SCF File Server  alias=${alias}
    issh.Execute   command=cd ${SCF_FILE_SERVER_FOLDER}   alias=${alias}
    ${out}   issh.Execute   command=ls -l . |grep ${tl_name}_${build_number}|head -1|wc -l   check_result=${False}   alias=${alias}
    ${count}  strip prompt  ${out}
    return from keyword if  ${count}>=1

    should be true  ${SCF_IN_SETUP.__len__()>10}
    ${new_scf_file_name_in_scf_server}   set variable  ${tl_name}_${build_number}_scf_FROM_WEBUI.xml
    ${new_scf_file_full_name_in_scf_server}  OperatingSystem.Join Path   ${SCF_FILE_SERVER_FOLDER}   ${new_scf_file_name_in_scf_server}
    ${out}   issh.upload_file   local_path=${SCF_IN_SETUP}   remote_path=${new_scf_file_full_name_in_scf_server}     alias=${alias}


Is VDU OAM Up
    #[Arguments]    ${vdu_index}=0 ${gnb_index}=0
    [Documentation]   Is VDU OAM Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...    |  ${status} | Is VDU OAM Up |
    ...
    #${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info     vdu_index=${vdu_index}   gnb_index=${gnb_index}
    #${state}    check_host_service_state    ${vdu_oam_http_connection_info["addr"]}    ${vdu_oam_http_connection_info["port"]}
    ${r}   ${out}   run keyword and ignore error   vdu rest login
    ${state}   set variable if   "${r}"=="PASS"    ${True}   ${False}

    [Return]   ${state}


Clear Agent Flag
    [Documentation]   Clear Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Clear Agent Flag |
    ...
    log to console  Clear Agent Flag...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    Initialize Agent Flag File   agent_flag_file=${agent_flag_file}


Set Agent Flag
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    #return from keyword if  ${RECOVER}==0

    log to console  Set Agent Flag...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt

    ${redeploy_flag}    Need Redeploy VDU
    log to console  Need Redeploy VDU:${redeploy_flag}
    run keyword if  "${redeploy_flag}"=="${True}"    swm._Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=1
      ...   ELSE    swm._Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=0


Enable Redeploy For Agent Flag
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Enable Redeploy For Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Enable Redeploy For Agent Flag |
    ...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    ${alias}   get unique id
    connect to ute locally  alias=${alias}
    ${out}  issh.Execute   command=echo redeploy=1 > ${agent_flag_file}    alias=${alias}
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


_Set Agent Flag With Content
    [Arguments]  ${agent_flag_file}   ${redeploy}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    log to console  _Set Agent Flag With Content
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    should be true  ${found}

    #display old value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}

    #change file content
    ${out}  issh.Execute   command=echo redeploy=${redeploy} > ${agent_flag_file}    alias=${alias}

    #display new value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


Initialize Agent Flag File
    [Arguments]  ${agent_flag_file}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    ${out}   run keyword if  "${found}"=="${True}"   issh.Execute   command=cat ${agent_flag_file}   alias=${alias}
    return from keyword if  "${found}"=="${True}"

    ${out}  issh.Execute   command=echo redeploy=0 > ${agent_flag_file}    alias=${alias}
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


Need Redeploy VDU
    [Documentation]   Need Redeploy VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...   ${True} or ${False}
    ...
    ...   Example
    ...  | Need Redeploy VDU |
    ...
    ${redeploy_flag}   set variable    ${False}
    #return from keyword  ${False}

    ${r}  ${out}   run keyword and ignore error   OAM Precondition Cell Should Be Onair
    log to console  OAM Precondition Cell Should Be Onair:${r}
    return from keyword if  "${r}"!="PASS"   ${True}

    ${r}  ${out}   run keyword and ignore error   Should Have Power On All RUs
    log to console  Should Have Power On All RUs:${r}
    return from keyword if  "${r}"!="PASS"   ${True}

    [Return]  ${redeploy_flag}


Get UTE Type
    [Documentation]    Get UTE Type
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...   JENKINS  or  UTE_CLOUD
    ...
    ...   Example
    ...  | ${ute_type} | Get UTE Type |
    ...
     ${r}   ${out}   Run Keyword And Ignore Error    Environment Variable Should Be Set    JENKINS_URL
     return from keyword if   "${r}"=="PASS"   JENKINS

     ${a}   OperatingSystem.Run   ls -l /opt/ute/agent_env_py3/bin/activate
     return from keyword if   "No such file or directory" not in """${a}"""    JENKINS

     [Return]  UTE_CLOUD


############################## vDU Deployment + SWM end ##############################
====== vDU Deployment + SWM end ======
     log to console  \n*** only used for readable **


############################## FHGW Deployment + SWM Start ##############################
====== FHGW Deployment + SWM Start ======
     log to console  \n*** only used for readable ***

Get FHGW Config
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]  Get FHGW Config
    ...  author: chris.l.cao@nokia-sbell.com
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
    ${result}   ${rtn}     Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config}
    Should Be True  "${result}"=="PASS"    Please give FHGW config in __init__.py for vdu_index=${vdu_index},fhgw_index:${fhgw_index}
    [Return]   ${rtn}


Get FHGW Namespace From Testline
    #[Arguments]    ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
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
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of FHGW account information as below,
    ...    example: { 'addr':'1.1.1.1',
    ...               'root_username': 'root',
    ...               'root_password_plain': 'root',
    ...               'admin_user_name':'_nokfhgwoperator',
    ...               'admin_user_fallback_password_plain': 'root',
    ...               'admin_user_password_plain': 'root'
    ...               }
    ...
    ...    Example
    ...    | ${fhgw_account_info} | Get FHGW Account Info |
    ...
    ${fhgw_config}   swm.Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
    ${result}   ${ip}   Run Keyword And Ignore Error   Set Variable
      ...   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW ip!

    ${result}   ${root_password_plain}   Run Keyword And Ignore Error   Set Variable   ${fhgw_config["USERS"]["root_password_plain"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW root_password_plain!

    ${result}   ${admin_user_name}   Run Keyword And Ignore Error  Set Variable   ${fhgw_config["USERS"]["admin_user_name"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW admin_user_name!

    ${result}   ${admin_user_password_plain}   Run Keyword And Ignore Error  Set Variable    ${fhgw_config["USERS"]["admin_user_password_plain"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW admin_user_password_plain!

    ${result}   ${admin_user_fallback_password_plain}   Run Keyword And Ignore Error
     ...  Set Variable    ${fhgw_config["USERS"]["admin_user_fallback_password_plain"]}
    run keyword if   """${result}"""=="""FAIL"""   Fail   No FHGW admin_user_fallback_password_plain!

    ${rtn}   create dictionary  addr=${ip}    root_username=${root_password_plain}   root_password_plain=${root_password_plain}
      ...   admin_user_name=${admin_user_name}   admin_user_password_plain=${admin_user_password_plain}
      ...   admin_user_fallback_password_plain=${admin_user_fallback_password_plain}

    [Return]  ${rtn}


Get Ruproxy Full Pod Name
    [Arguments]    ${alias}=default     ${ru_index}=1   #${vdu_index}=0   ${fhgw_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbrevation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias             | No | alias. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | fhgw_index        | No | fhgw_index. Default value is 0 |
    ...    | ru_index          | No | ru_index. Default value is 1 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name of ruproxy.
    ...
    ...    Example
    ...    | Connect To FHGW |
    ...    | ${full_pod_name} | Get Ruproxy Full Pod Name |
    ...    | ${full_pod_name} | Get Ruproxy Full Pod Name | vdu_index=0 | ru_index=1 |
    ...    | ${full_pod_name} | Get Ruproxy Full Pod Name | vdu_index=0 | ru_index=1 | alias=default |
    ...    | Disconnect Interactive Connection |
    ...
    ${ns}   Get FHGW Namespace From Testline
    ${out}   issh.Execute  command=kubectl get pods -n ${ns}|grep ruproxy-${ru_index} |awk '{print $1}'
        ...   alias=${alias}
    ${lines}   split to lines  ${out}
    run keyword if  ${lines[0].__len__()}==0   remove from list  ${lines}   index=0
    ${line}  set variable  ${lines[0].strip()}
    ${full_pod_name}   Set Variable  ${line.split()[0]}
    [Return]  ${full_pod_name}


Get Ruproxy Container ID
    [Arguments]   ${ru_index}=1  ${alias}=default
    [Documentation]   Get Ruproxy Container ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_name    |  yes | container_name |
    ...    | ru_index         |  no | ru_index, default value is 1 |
    ...    | alias            | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    container id
    ...
    ...    Example
    ...    | Connect to FHGW |
    ...    | ${container_id} | Get Ruproxy Container ID |
    ...    | ${container_id} | Get Ruproxy Container ID | ru_index=1 | alias=default |
    ...    | Disconnect Interactive Connection |
    ...
    ${cmd}    set variable   docker ps |grep -v POD|grep ruproxy-${ru_index}-0|awk '{print $1}'
    ${out}   issh.execute  command=${cmd}  alias=${alias}
    ${lines}   split to lines  ${out}
    ${container_id}   set variable if  ${lines.__len__()}>=2   ${lines[1]}   ${EMPTY}
    [Return]  ${container_id}


Set VDU Conf Inside Container OAMFH
    [Arguments]    ${conf_dict}   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Set VDU Conf Inside Container OAMFH
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | conf_dict | yes | to be uploaded conf, which is a dictionary  |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | ${conf} |  Get VDU Conf Inside Container OAMFH  |
    ...   | ${key_list}  |  Create List  |  RuSwSwitch   | IsDisableRuSwUpgrade |
    ...   | Set_Dictionary_With_Multiple_Level_Keys  |  value=${False} | dict_name=${conf} | keys=${key_list} |
    ...   | Set VDU Conf Inside Container OAMFH  |   conf_dict=${conf}  |
    ...
    ${content}   json.dumps    ${conf_dict}  indent=${4}
    ${path}   ${conf_file}  OperatingSystem.Split Path   ${VDU_CONF_FILE_oamfh.json}
    ${local_file}   Get A File    conf_upload  vdu_oamfh   ${conf_file}
    OperatingSystem.Create Binary File   ${local_file}      ${content}

    ${alias}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=oamcp  vdu_index=${vdu_index}  alias=${alias}
    ${ns}   Get VDU Namespace From TestLine
    ${container_id}   Get Container ID From Docker Ps Command By POD Abbreviation Interactively    ns=${ns}   pod_abbr=oamcp    container=oamfh
    ...    alias=${alias}

    ${tmp_file}   Get A Remote File   conf_upload  vdu_oamfh   ${conf_file}  alias=${alias}
    issh.Upload File    local_path=${local_file}  remote_path=${tmp_file}     alias=${alias}

    ${command}  Set Variable   docker cp ${tmp_file} ${container_id}:${VDU_CONF_FILE_oamfh.json}
    ${out}   issh.Execute   command=${command}    alias=${alias}


Get RU Version via CLI
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get RU Version via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |

    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${ru_version} | Get RU Version via CLI |
    ...
    ${alias}  get unique id
    connect to radio unit    gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}   alias=${alias}
    ${out}   issh.Execute  command=cat /etc/version |awk '{print $1}'   alias=${alias}
    ${out}   strip prompt  ${out}
    ${unitBldVersion}   set variable  ${out.strip()}
    [Return]   ${unitBldVersion}


Get RU Version via REST
    [Arguments]   ${ru_index}=0   ${need_rest_login}=${True}
    [Documentation]   Get RU Version via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | No | ru_index, default value is 0  |
    ...    | need_rest_login | No | need_rest_login, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${ru_version} | Get RU Version via REST |
    ...

    run keyword if  "${need_rest_login}"=="${True}"   vdu rest login
    ${out}   vdu.get_rmods_status
    ${one_ru_info}   set variable  ${out[${ru_index}]}
    ${active_sw_version}   set variable  ${one_ru_info["active_sw_version"]}
    [Return]   ${active_sw_version}


Get RU Operational State via REST
    [Arguments]   ${ru_index}=0   ${need_rest_login}=${True}
    [Documentation]   Get RU Operational State via REST
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | No | ru_index, default value is 0  |
    ...    | need_rest_login | No | need_rest_login, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${operational_State} | Get RU Operational State via REST |
    ...

    run keyword if  "${need_rest_login}"=="${True}"   vdu rest login
    ${out}   vdu.get_rmods_status
    ${one_ru_info}   set variable  ${out[${ru_index}]}
    ${operational_state}   set variable  ${one_ru_info["operational_state"]}
    [Return]   ${operational_state}


############################## FHGW Deployment + SWM end ##############################
====== FHGW Deployment + SWM End ======
     log to console  \n*** only used for readable **


====== RU Deployment + SWM Start ======
     log to console  \n*** only used for readable ***


Downgrade RU To Pre-Defined RU Version
    [Arguments]    ${vdu_index}=0
    [Documentation]   Downgrade RU To Pre-Defined RU Version
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Downgrade RU To Pre-Defined RU Version |
    ...
    ${r}   ${out}   run keyword and ignore error
      ...   wait until keyword succeeds  3x  400   _Downgrade RU To Pre-Defined RU Version Once    vdu_index=${vdu_index}
    RU Should Be Pingable   count=10
    should be true  "${r}"=="PASS"


_Downgrade RU To Pre-Defined RU Version Once
    #[Arguments]    ${vdu_index}=0
    [Documentation]   _Downgrade RU To Pre-Defined RU Version Once
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | vdu_index | no | vdu_index, default is 0|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _Downgrade RU To Pre-Defined RU Version Once |
    ...
    log to console   _Downgrade RU To Pre-Defined RU Version Once

    Upload Tools To Ruproxy
    Wait Unitil RU IS Up   timeout=600
    Copy RU Image From Ruproxy to RU
    ${chksum}   ${file_version}  Get RU Image Chksum and File Version
    Install RU Image   ${chksum}   ${file_version}


Copy RU Image From Ruproxy to RU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Documentation]   Copy RU Image From Ruproxy to RU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Copy RU Image From Ruproxy to RU   |
    ...
    ${rf_image_file}   Get RU Image File Name
    ${src}  OperatingSystem.join Path   ${TOOLS_INFO["work_folder_data"]}    ${rf_image_file}
    ${dst}  OperatingSystem.join Path   /run    ${rf_image_file}

    Delete File In RU   dst=${dst}    ru_index=${ru_index}

    Copy File From Ruproxy to RU  src=${src}    dst=${dst}   timeout=600   gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}


Get RU Image Chksum and File Version
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Get RU Image Chksum and File Version
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${chksum} | ${file_version} | Get RU Image Chksum and File Version  |
    ...
    ${alias}   get unique id
    Connect to FHGW  alias=${alias}
    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_data"]}    alias=${alias}
    ${ru_image_file}   Get RU Image File Name

    ${ru_checksum_tool}   OperatingSystem.join Path   ${TOOLS_INFO["work_folder_tool"]}     ${TOOLS_INFO["ru_checksum"]}
    ${out}   issh.Execute   command=python ${ru_checksum_tool} ${ru_image_file}   alias=${alias}

    ${Chksum}  strip prompt  ${out}
    log to console  ${Chksum}

    ${matches}   get regexp matches   ${ru_image_file}   .*_(\\d+?)-.*   1
    ${file_version}   set variable if   ${matches}   ${matches[0]}
    log to console  ${file_version}

    [Return]  ${Chksum}   ${file_version}


Install RU Image
    [Arguments]  ${chksum}   ${file_version}  #${ru_index}=1
    [Teardown]   run keywords  run keyword and ignore error  issh.Execute    command=cat /etc/version   alias=${alias}
    ...   AND   run keyword and ignore error    disconnect interactive connection  alias=${alias}
    [Documentation]   Install RU Image
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Install RU Image | ${chksum} | ${file_version} |
    ...
    ${alias}   get unique id
    Connect to Radio Unit  alias=${alias}   timeout=180
    ${out}   issh.Execute    command=cat /etc/version   alias=${alias}

    ${ru_image_file}   Get RU Image File Name

    ${old_timeout}   issh.set_timeout   timeout=900   alias=${alias}
    ${cmd}   set variable    SWmanShellCommand -s /ram/${ru_image_file} 0x${chksum} ${file_version} ""
    #${out}   issh.Execute    command=${cmd}    alias=${alias}
    ${out}    wait until keyword succeeds   3x   5s   issh.Execute    command=${cmd}    alias=${alias}
    should contain   ${out}   OK

    ${cmd}   set variable    SWmanShellCommand -a ${ru_image_file} ${file_version} ${ru_image_file} ${file_version}
    #${out}   issh.Execute    command=${cmd}    alias=${alias}
    ${out}    wait until keyword succeeds   3x   5s     issh.Execute    command=${cmd}    alias=${alias}
    should contain   ${out}   OK

    issh.set_timeout   timeout=${old_timeout}   alias=${alias}
    ${out}   issh.Execute    command=cat /etc/version   alias=${alias}
    sleep   1


====== LTE Start ======
     log to console  \n*** only used for readable **

Get LTE OAM Ip
    #[Arguments]  ${gnb_index}=0
    [Documentation]   Get LTE OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    LTE OAM ip
    ...
    ...    Example
    ...    | ${lte_ip} | Get LTE OAM Ip |
    ...

    ${lte_oam_ip}   Set Variable  ${tl.enbs[0].oam_ip}

    [Return]  ${lte_oam_ip}

==========Common UnDeploy/Deploy/Upload Image Keywords For NCS================

UnDeploy Default vDU For NCS
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   UnDeploy Default vDU For NCS
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vDU For NCS |
    ...
    ${vdu_release_name}   Get VDU Release Name
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    vDU Cluster Login With Admin   ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${vdu_release_name}  ${ns}
    Wait Until Keyword Succeeds  300   10s    Make Sure VDU Is Deleted   vdu_index=${vdu_index}
    [Teardown]    helm.helm_master_close

UnDeploy Default vDU Network For NCS
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   UnDeploy Default vDU Network For NCS
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vDU Network For NCS |
    ...
    ${network_release_name}  Get VDU Network Release Name
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    vDU Cluster Login With Admin   ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${network_release_name}  ${ns}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU Network Is Deleted   vdu_index=${vdu_index}
    [Teardown]    helm.helm_master_close

UnDeploy Default vDU PVC For NCS
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   UnDeploy Default vDU PVC For NCS
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vDU PVC For NCS |
    ...
    ${pvc_release_name}  Get VDU PVC Release Name
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    vDU Cluster Login With Admin   ${vdu_index}  ${gnb_index}
    run keyword and ignore error     helm.helm3_delete    ${pvc_release_name}  ${ns}
    Wait Until Keyword Succeeds  120   2s    Make Sure VDU PVC Is Deleted   vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  90   2s    Make Sure VDU PVC Is Deleted From Disk   vdu_index=${vdu_index}
    [Teardown]    helm.helm_master_close

Upload Image To Repository For NCS
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0  ${image_check}=False  ${build_number}=0.300.903
    [Documentation]    Upload image to repository for NCS
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | image_check | no | image_check, default is False |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload image to repository for NCS | build_number=0.300.800|
    ...

    run keyword if  ${image_check}==False  Upload Image
    ...    vdu_index=${vdu_index}
    ...    gnb_index=${gnb_index}
    ...    build_number=${build_number}
    run keyword if  ${image_check}==True  log  images already exist  console=true

Upload Image
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${build_number}=0.300.903
    [Documentation]    Do some common thing for every postcondition of cases
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.300.800|

    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.download_onboard_app_tool    target_path=/home/cranuser1/${build_number}/Images    chart_version=${build_number}
    helm.execute_command_on_master_cluster
    ...    cp /home/cranuser1/${build_number}/Images/onBoardingApp/loadImages.sh /home/cranuser1/${build_number}/Images/
    helm.execute_command_on_master_cluster
    ...    cp /home/cranuser1/${build_number}/Images/onBoardingApp/images.properties.NCS /home/cranuser1/${build_number}/Images/
    helm.execute_command_on_master_cluster    cd /home/cranuser1/${build_number}/Images;chmod 777 *;./loadImages.sh
    log    upload images done    console=true
    [Teardown]    helm.helm_master_close

Create Intnet and Verify Intnet creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${remote_dst_file}=values-override.yaml
    ...    ${remote_dst_path}=/home/cranuser1/aic-intnet
    [Documentation]    Create Intnet and Verify Intnet creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create Intnet and Verify Intnet creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser1/aic-intnet |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${network_release_name}  Get VDU Network Release Name From Testline  ${gnb_index}  ${vdu_index}
    vDU Cluster Login With Tenant   ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...  ${network_release_name}
    ...  ${remote_dst_path}
    ...  ${ns}
    ...  value_files=${remote_dst_file}
    log    Deloy Internet done    console=true
    [Teardown]    helm.helm_master_close

Create PVC and Verify PVC creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${remote_dst_file}=values-override.yaml
    ...    ${remote_dst_path}=/home/cranuser1/aic-pvc
    [Documentation]    Create PVC and Verify PVC creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create PVC and Verify PVC creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser1/aic-pvc |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${pvc_release_name}  Get VDU PVC Release Name From Testline  ${gnb_index}  ${vdu_index}
    vDU Cluster Login With Tenant   ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   ${pvc_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    log    Deloy PVC done    console=true
    [Teardown]    helm.helm_master_close

Create VDU and Verify VDU creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml
    ...   ${remote_dst_path}=/home/cranuser1/aic-vdu   ${timeout}=${500}
    [Documentation]    Create VDU and Verify VDU creation
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | remote_dst_file | Yes | remote_dst_file on OE |
    ...	   | remote_dst_path | Yes | remote_dst_path on OE |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Create VDU and Verify VDU creation | remote_dst_file=values-override.yaml | remote_dst_path=home/cranuser1/aic-vdu |
    ...
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${vdu_release_name}   Get VDU Release Name From Testline  ${gnb_index}  ${vdu_index}
    vDU Cluster Login With Tenant   ${vdu_index}  ${gnb_index}
    helm.helm3_install_wait_until_ready
    ...   ${vdu_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   timeout=${timeout}
    log    Deloy vDU done    console=true
    [Teardown]    helm.helm_master_close

Deploy VDU For NCS
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${build_number}=0.300.903
    [Documentation]    Download vdu zip file and upload images and create intnet,pvc,vdu
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deploy VDU For NCS | build_number=0.300.903 |
    ...
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${output}=    helm.execute_command_on_master_cluster    test -d /home/cranuser1/${build_number}
    run keyword if    '${output.status}'=='1'    _Clean Old Releases And Download New Vdu Package  ${build_number}
    ...    ELSE   log    "VDU package already present at cluster"
    Upload Image To Repository For NCS   build_number=${build_number}

    ${pvc_yaml_file}      Get vDU PVC Vnf Config Yaml From TestLine   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${intnet_yaml_file}   Get vDU Network Vnf Config Yaml From TestLine  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vdu_yaml_file}    Get vDU Vnf Config Yaml From TestLine  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vdu_release_name}   Get VDU Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${network_release_name}  Get VDU Network Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pvc_release_name}  Get VDU PVC Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${alias_k8s_tenant}   Get Unique ID
    Connect To K8s Master With Tenant Interactively   alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${intnet_yaml_file}
    ...    remote_path=/home/cranuser1/${build_number}/${network_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${pvc_yaml_file}
    ...    remote_path=/home/cranuser1/${build_number}/${pvc_release_name}/
    ...    alias=${alias_k8s_tenant}
    issh.Upload File  local_path=${vdu_yaml_file}
    ...    remote_path=/home/cranuser1/${build_number}/${vdu_release_name}/
    ...    alias=${alias_k8s_tenant}

    Create Intnet and Verify Intnet creation
    ...    remote_dst_file=/home/cranuser1/${build_number}/${network_release_name}/aic_intnet_values_override_0.yaml
    ...    remote_dst_path=/home/cranuser1/${build_number}/${network_release_name}
    Create PVC and Verify PVC creation
    ...    remote_dst_file=/home/cranuser1/${build_number}/${pvc_release_name}/aic_pvc_values_override_0.yaml
    ...    remote_dst_path=/home/cranuser1/${build_number}/${pvc_release_name}
    Create VDU and Verify VDU creation
    ...    remote_dst_file=/home/cranuser1/${build_number}/${vdu_release_name}/aic_vdu_values_override_0.yaml
    ...    remote_dst_path=/home/cranuser1/${build_number}/${vdu_release_name}

    [Teardown]    helm.helm_master_close

Deploy VDU For NCS With Updated Yaml File
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${build_number}=0.300.903  ${updated_override_yaml_file}=${EMPTY}
    ...   ${timeout}=${500}
    [Documentation]    Download vdu zip file and upload images and create intnet,pvc,vdu
    ...    *AUTHOR* jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    | updated_override_yaml_file | no | tmp/vdu/charts/values-override.yaml |
    ...    * RETURN VALUE *
    ...    None
    ...
    ...    Example
    ...    | Deploy VDU For NCS With Updated Yaml File | build_number=0.300.903 | tmp/vdu/charts/values-override.yaml |
    ...
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${output}=    helm.execute_command_on_master_cluster    test -d /home/cranuser1/${build_number}
    run keyword if    '${output.status}'=='1'    _Clean Old Releases And Download New Vdu Package  ${build_number}
    ...    ELSE   log    "VDU package already present at cluster"
    Upload Image To Repository For NCS   build_number=${build_number}
    ${conf_dict_vdu_pvc}       Get VDU PVC Vnf Config Dictionary From TestLine
    ${conf_dict_vdu_network}   Get VDU Network Vnf Config Dictionary From TestLine
    ${conf_dict_vdu}           Get VDU Vnf Config Dictionary From TestLine
    ${vdu_release_name}   Get VDU Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${network_release_name}  Get VDU Network Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pvc_release_name}  Get VDU PVC Release Name From Testline  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    run keyword if  "${updated_override_yaml_file}"!="${EMPTY}"   Print A Dictionary   ${updated_override_yaml_file}
    run keyword if  "${updated_override_yaml_file}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    run keyword if  "${updated_override_yaml_file}"!="${EMPTY}"
       ...   Update_Dictionary   src_dict=${updated_override_yaml_file}   dst_dict=${conf_dict_vdu}
    run keyword if  "${updated_override_yaml_file}"!="${EMPTY}"   Print A Dictionary  ${conf_dict_vdu}
    ${remote_yaml_file_info}   Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster NCS
    ...  override_dict_vdu_pvc=${conf_dict_vdu_pvc}
    ...  override_dict_vdu_network=${conf_dict_vdu_network}
    ...  override_dict_vdu=${conf_dict_vdu}
    ...  build_number=${build_number}
    Create Intnet and Verify Intnet creation
    ...    remote_dst_file=${remote_yaml_file_info["remote_vdu_network_chart_yaml_file"]}
    ...    remote_dst_path=${remote_yaml_file_info["remote_vdu_network_chart_yaml_folder"]}
    Create PVC and Verify PVC creation
    ...    remote_dst_file=${remote_yaml_file_info["remote_vdu_pvc_chart_yaml_file"]}
    ...    remote_dst_path=${remote_yaml_file_info["remote_vdu_pvc_chart_yaml_folder"]}
    Create VDU and Verify VDU creation
    ...    remote_dst_file=${remote_yaml_file_info["remote_vdu_chart_yaml_file"]}
    ...    remote_dst_path=${remote_yaml_file_info["remote_vdu_chart_yaml_folder"]}
    ...    timeout=${timeout}
    [Teardown]    helm.helm_master_close
_Clean Old Releases And Download New Vdu Package
    [Arguments]   ${build_number}
    helm.execute_command_on_master_cluster    cd /home/cranuser1;rm -rf 0.300.*
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    helm.helm_download_vdu_ncir_package    /home/cranuser1/${build_number}  vDU  ${build_number}

UnDeploy VDU For NCS
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0
    [Documentation]    Undeploy VDU, PVC, Intnet
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | UnDeploy VDU For NCS |
    ...
    UnDeploy Default vDU For NCS  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    UnDeploy Default vDU PVC For NCS  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    UnDeploy Default vDU Network For NCS  vdu_index=${vdu_index}  gnb_index=${gnb_index}

