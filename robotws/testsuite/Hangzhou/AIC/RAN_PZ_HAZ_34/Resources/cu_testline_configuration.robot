*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   testline_configuration.robot
...   related to cu configuration from testline config



*** Variables ***



*** Keywords ***
Check If VCU OAM Is IPv6
    [Arguments]  ${gnb_index}=0
   [Documentation]   Check If VCU OAM Is IPv6
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    ${is_ipv6}    boolean
    ...
    ...   Example
    ...    | ${is_ipv6} | Check If VCU OAM Is IPv6 |
    ...
    ...
     ${vcu_oam_ip}   Get vCU OAM Ip   gnb_index=${gnb_index}
     ${is_ipv6}  set variable if   ":" in "${vcu_oam_ip}"  ${true}  ${false}
     [Return]  ${is_ipv6}


Get VCU NF Type
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU NF Type
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...	  | gnb_index | No | gnb_index, default is 0 |
    ...   *Return*
    ...   VNF or CNF
    ...   *Example*
    ...   | ${nf_type} | Get VCU NF Type |
    ${flavors}   Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.flavors}
    ${nf_type}  set variable if   "${flavors}"=="${None}"   CNF   VNF
    [Return]  ${nf_type}


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


Get VCU Scf File From Test Line
    [Arguments]  ${gnb_index}=0  ${file_name}=vCU_SCF_0.250.xml
    [Documentation]  Get VCU Scf File From Test Line
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${vcu_scf_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/${file_name}
    OperatingSystem.File Should Exist   ${vcu_scf_file_name}

    [Return]   ${vcu_scf_file_name}


Get VCU Tenant Name
    [Arguments]     ${gnb_index}=0
    [Documentation]   Get VCU Tenant Name
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    tenant_name
    ...
    ...    Example
    ...    | ${pvc_release_name} | Get VCU PVC Release Name |
    ...
    ${tenant_name}  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    [Return]   ${tenant_name}


Get VCU One Click Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VCU One Click Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of VCU One Click Config defined in cnf_parameters.yaml
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU One Click Config Yaml From TestLine  |
    ...
    #${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/cnf_parameters.yaml

    [Return]   ${yaml_file_name}


Get VCU One Click Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU One Click Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of cnf_parameters.yaml . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get VCU One Click Config Dictionary From TestLine |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get VCU One Click Config Yaml From TestLine  gnb_index=${gnb_index}
    ${r}   ${dummy}  run keyword and ignore error  OperatingSystem.File Should Exist   ${yaml_file}
    return from keyword if  "${r}"=="FAIL"   ${empty_dict}

    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}


Get vCU PVC Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Network Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU PVC Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU PVC Vnf Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/aic_pvc_values_override_0.yaml

    [Return]   ${yaml_file_name}


Get vCU Vnf Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Vnf Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU Vnf Config Yaml From TestLine  |
    ...
    ${yaml_file_name}    set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].yaml_file}
    [Return]   ${yaml_file_name}


Get vCU Cluster Prep Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get vCU Cluster Prep Config Yaml From TestLine
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vCU cluster prep Vnf Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vCU Cluster Prep Config Yaml From TestLine |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/aic_cluster_preparation_yaml_vCU_0.yaml

    [Return]   ${yaml_file_name}


Get VCU Release Name From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU Release Name From Testline
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU Release Name From Testline
    ...
    ...    Example
    ...    | ${vcu_release_name} | Get VCU Release Name From Testline |
    ...
    ${release_name}   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.vnfs[0].name}
    [Return]  ${release_name}


Get VCU Prerequisite Release Name From Testline
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get VCU PVC Release Name From Testline
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VCU PVC Release Name From Testline
    ...
    ...    Example
    ...    | ${vcu_pvc_release_name} | Get VCU PVC Release Name From Testline |
    ...
    ${vcu_prerequisite_release_name}   set variable  aic-vcu-prerequisite
    [Return]  ${vcu_prerequisite_release_name}


Get vCU Platform Name
    [Documentation]   This keywork only support aic product, Get vCU Platform Name
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...
    ...   *RETURN VALUE*
    ...    OSP or NCIR or NCS or OCP
    ...
    ...   Example
    ...   | ${platform} | Get vCU Platform Name|
    ...
    ${tl_cloud_topology}   set variable  ${tl.tl_cloud_topology}
    should be true  ${tl_cloud_topology.startswith("CLOUD_5G_AIC")}
    ${vcu_platform}   set variable  ${tl_cloud_topology.split("_")[3]}
    [Return]  ${vcu_platform}


Get vCU Platform Name From One Click Config
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get vCU Platform Name From One Click Config
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   22.9.2021,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...
    ...   *RETURN VALUE*
    ...    NCS or OCP, otherwise KW fails.
    ...
    ...   Example
    ...   | ${platform} | Get vCU Platform Name From One Click Config |
    ...
    ${conf}   Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${platform}   set variable if  "OCP" in "${conf["misc"]["platform_type"]}"    OCP
     ...   "NCS" in "${conf["misc"]["platform_type"]}"   NCS    UNKNOWN_PLATFORM

    Run Keyword If   "${platform}"=="UNKNOWN_PLATFORM"
         ...   Fail   VCU platform name should be OCP or NCS, they are defined in one click config file.

    [Return]  ${platform}
