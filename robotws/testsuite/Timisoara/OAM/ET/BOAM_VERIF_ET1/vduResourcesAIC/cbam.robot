*** Settings ***
Documentation
...   author: fen.huang@nokia-sbell.com


*** Variables ***
${IMAGE_LINK}   https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-central-public-remote/System_Release/


*** Keywords ***
Connect To CBAM
    [Arguments]   ${cbam_version}=cbam19_5
    taf_cbam.connect     ip=${tl.cbam.addr}
    ...              client_id=${tl.cbam.client_id}
    ...              client_secret=${tl.cbam.client_secret}
    ...              version=${cbam_version}

Check CBAM Connection
    [Arguments]   ${cbam_version}=cbam19_5
    ${connection}=    taf_cbam.is_connected
    run keyword if    '${connection}'=='True'    return from keyword
    Connect To CBAM   ${cbam_version}

SSH To Controller
    [Arguments]   ${gnb_index}=0
    [Documentation]  SSH to controller.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <25-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...
    ...    *RETURN VALUE*
    ...    Connection alias and openrc file for current tenant user.
    ...    Example
    ...    |  SSH To Controller |      |
    ${alias}=  Get Unique ID
    tafssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.password}
    ...    alias=${alias}
    ...    timeout=10
    ${path_of_rc_file}=   set variable
    ...  /home/stack/users/${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
    ${env}   tafssh.Execute   command=find ${path_of_rc_file} -name '*openrc*'   connection=${alias}   timeout=10
    ${rc_file}   Set Variable   ${env.splitlines()[0]}
    [Return]   ${alias}   ${rc_file}

Check VM Image Exists
    [Arguments]     ${build_version}  ${gnb_index}=0
    [Documentation]     Check whether VM image is exist or not
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <25-Nov-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  build_version  | No |  gnb index to indicate which gnb will be used |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    True or False, True means image exists.
    ...    Example
    ...    | Check VM Image Exists |     |
    ${alias}  ${rc_file}=  SSH To Controller  ${gnb_index}
    ${image_list}   tafssh.execute   source ${rc_file}&&openstack image list   connection=${alias}
    ${image_list}    convert to string    ${image_list}
    ${image_name}=  set variable    AirFrameVirtualized-${build_version}
    ${image_existed}    run keyword and return status    should contain    ${image_list}    ${image_name}
    [Return]    ${image_existed}
    [Teardown]   Disconnect Controller  ${alias}

Disconnect Controller
    [Arguments]   ${alias}
    tafssh.Disconnect   connection=${alias}

Download and Create Image On Controller
    [Arguments]     ${build_version}    ${download_image_local_dir}=/tmp
    log to console  start download vm image
    ${download_image_local_dir}=   set variable   ${download_image_local_dir}/vm_images
    ${alias}  ${rc_file}=   SSH To Controller
    tafssh.execute  mkdir ${download_image_local_dir}    connection=${alias}
    ${image_name}=  set variable    AirFrameVirtualized-${build_version}
    ${exit_files}=   tafssh.Execute   command=cd ${download_image_local_dir}; ls   connection=${alias}
    Run Keyword Unless   ${exit_files.count("${build_version}")}>0
    ...   _Download Image   ${build_version}   ${download_image_local_dir}  ${alias}
    _Create VM Image   ${rc_file}   ${build_version}   ${download_image_local_dir}   ${alias}
    [Teardown]  Disconnect Controller    ${alias}

_Download Image
    [Arguments]     ${build_version}   ${download_image_local_dir}   ${alias}
    ${full_link_path_of_image}    set variable    ${IMAGE_LINK}/${build_version}/AirFrameVirtualized-${build_version}.qcow2
    tafssh.Execute   command=wget --no-proxy ${full_link_path_of_image} -P ${download_image_local_dir}    connection=${alias}
    ${exit_files}=   tafssh.Execute   command=cd ${download_image_local_dir}; ls   connection=${alias}
    Should Contain   ${exit_files}   AirFrameVirtualized-${build_version}.qcow2

_Create VM Image
    [Arguments]    ${rc_file}  ${build_version}   ${download_image_local_dir}   ${alias}
    ${qcow_file_path}    set variable     --file=${download_image_local_dir}/AirFrameVirtualized-${build_version}.qcow2
    ${commd_option}      set variable     --disk-format=qcow2 --container-format=bare --public
    ${exeute_result}     set variable     ${download_image_local_dir}/execute_result.txt
    tafssh.execute
    ...  source ${rc_file}&&openstack image create ${commd_option} ${qcow_file_path} AirFrameVirtualized-${build_version} > ${exeute_result}
    ...    connection=${alias}
    ${image_create_result}    tafssh.execute    command=cat ${exeute_result}     connection=${alias}
    should contain    ${image_create_result}    AirFrameVirtualized-${build_version}
    should contain    ${image_create_result}    active
    log to console    create image:AirFrameVirtualized-${build_version}.qcow2 successfully

Create Image To Controller
    [Arguments]     ${build_version}   ${gnb_index}=0
    ${flag}    Check VM Image Exists    ${build_version}     ${gnb_index}
    run keyword if    ${flag}
    ...    log to console     Image version:AirFrameVirtualized-${build_version}.qcow2 already created in controller
    ...    ELSE    Download and Create Image On Controller    ${build_version}

Check If VNF Exists
    [Arguments]    ${vnf_name}
    Check CBAM Connection
    @{vnfs_info}    taf_cbam.query_all_vnfs
    For  ${vnf}   IN  @{vnfs_info}
       ${vnf_exists}=   run keyword and return if    "${vnf["vnfInstanceName"]}"=="${vnf_name}"   set variable   True
       ${vnf_exists}=   set variable   False
    END
    [Return]    ${vnf_exists}

Terminate And Delete VNF
    [Arguments]   ${vnf_name}
    log to console  Terminate and delete VNF ${vnf_name} start!
    ${vnf_info_dict}=    Get VNF Instance Info Via VNF Name    ${vnf_name}
    run keyword unless    ${vnf_info_dict}    return from keyword
    ${operation_id}=  set variable  None
    ${operation_id}=  run keyword if  '${vnf_info_dict.instantiationState}'!='NOT_INSTANTIATED'  CBAM Terminate VNF  ${vnf_name}
    sleep  1min
    run keyword if  '${operation_id}'!='None'  Wait until keyword succeeds  5min  30s  Terminate VNF Should Be Successful  ${operation_id}
    CBAM Delete VNF  ${vnf_name}
    wait until keyword succeeds    3min    10s    VNF Should Be Deleted    ${vnf_name}

CBAM Delete VNF
    [Arguments]    ${vnf_name}
    Check CBAM connection
    ${operation_info}=  taf_cbam.delete_vnf    ${vnf_name}

CBAM Terminate VNF
    [Arguments]    ${vnf_name}
    Check CBAM connection
    ${operation_info}=    taf_cbam.terminate_vnf    ${vnf_name}    termination_type=FORCEFUL
    [Return]  ${operation_info["operationId"]}

Terminate And Delete Specific VNF With Tenant Name
    [Arguments]    ${vnf_type}  ${gnb_index}=0
    Check CBAM Connection
    ${tenant}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}
    @{vnfs_info}    taf_cbam.query_all_vnfs
    ${vnf_name}=  set variable  None
    For  ${vnf}   IN  @{vnfs_info}
       ${vnf_name}=   Get Lines Matching Regexp  ${vnf["vnfInstanceName"]}  ${tenant}.*(?i)${vnf_type}
       RUN KEYWORD IF  '${vnf_name}'!=''  Terminate And Delete VNF  ${vnf_name}
    END

Terminate VNF Should Be Successful
    [Arguments]    ${operation_id}
    Check CBAM connection
    ${operation_info}=    taf_cbam.get_operation_execution_info  operation_id=${operation_id}
    should be equal  ${operation_info["operationState"]}  COMPLETED

Get VNF Instance Info Via VNF Name
    [Arguments]     ${vnf_name}
    Check CBAM connection
    @{output}    taf_cbam.query_all_vnfs
    ${vnf_info_dict}=     create dictionary
    FOR    ${vnf_instance}    IN    @{output}
        ${vnf_id}=    get from dictionary    ${vnf_instance}    id
        ${vnf_instantiationState}=    Get from dictionary    ${vnf_instance}    instantiationState
        ${vnf_name_tmp}=    Get from dictionary    ${vnf_instance}    vnfInstanceName
        run keyword if    '${vnf_name_tmp}'=='${vnf_name}'
    ...  set to dictionary  ${vnf_info_dict}  id=${vnf_id}  name=${vnf_name_tmp}  instantiationState=${vnf_instantiationState}
        run keyword if    ${vnf_info_dict}    return from keyword    ${vnf_info_dict}
    END
    log to console  ${vnf_name} doesn't exist!

VNF Should Be Deleted
    [Arguments]     ${vnf_name}
    ${vnf_exists}=  Check If VNF Exists   ${vnf_name}
    should be true    "${vnf_exists}"!="True"     VNF ${vnf_name} still exists after detele opertion done!

Download And Extract Addons Package
    [Arguments]   ${build_version}     ${gnb_index}=0
    ${tenant}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}
    ${addons_package}=   set variable  Addons-${build_version}.txz
    ${STAR_TIME}    run    command=date +"%Y-%m-%d-%H:%M:%S"
    log to console   ${STAR_TIME}
    ${local_path_of_template}=   get a directory   ${tenant}-cbam-${STAR_TIME}
    OperatingSystem.Run    wget ${IMAGE_LINK}/${build_version}/${addons_package} -P ${local_path_of_template}
    file should exist     ${local_path_of_template}/${addons_package}   Download cbam template failed!
    ${platform_type}=   evaluate   type($tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting).__name__
    OperatingSystem.Run
    ...  command=cd ${local_path_of_template};tar -xvf ${addons_package} ./CBAM.tgz && tar xvf CBAM.tgz ./${platform_type}
    [Return]      ${local_path_of_template}/${platform_type}

Get Template Catalog Versions
    [Arguments]       ${dir_of_extracted_template_files}  ${deploy_mode}=redundancy  ${gnb_index}=0     #${build_version}
    ${platform_type}=   evaluate   type($tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting).__name__
    ${platform}=  run keyword if  "${platform_type}"=="OSP"    set variable    VCP
    ...  ELSE   set variable   NCIR
    ${path_of_flavor_package}=   set variable  ${dir_of_extracted_template_files}/5G_flavors_${platform}.csar
    ${path_of_nets_package}=   set variable  ${dir_of_extracted_template_files}/5G_nets_${platform}.csar
    ${path_of_security_group_package}=  set variable   ${dir_of_extracted_template_files}/5G_security_group_${platform}.csar
    ${path_of_vnf_package}=  run keyword if    "${deploy_mode}"=="redundancy"
    ...            set variable   ${dir_of_extracted_template_files}/5G_VNF_redundancy_${platform}.csar
    ...   ELSE     set variable   ${dir_of_extracted_template_files}/5G_VNF_basic_${platform}.csar
    ${extracted_flavor_dir_path}=  set variable   ${dir_of_extracted_template_files}/5G_flavors_${platform}
    ${extracted_nets_dir_path}=  set variable   ${dir_of_extracted_template_files}/5G_nets_${platform}
    ${extracted_sec_group_dir_path}=  set variable   ${dir_of_extracted_template_files}/5G_security_group_${platform}
    ${extracted_vnf_dir_path}=  set variable   ${dir_of_extracted_template_files}/5G_VNF_${platform}
    log to console  unzip start
    OperatingSystem.Run   command=unzip ${path_of_flavor_package} -d ${extracted_flavor_dir_path}
    OperatingSystem.Run   command=unzip ${path_of_nets_package} -d ${extracted_nets_dir_path}
    OperatingSystem.Run   command=unzip ${path_of_security_group_package} -d ${extracted_sec_group_dir_path}
    OperatingSystem.Run   command=unzip ${path_of_vnf_package} -d ${extracted_vnf_dir_path}
    log to console    Start to get catalog version information in addons package
    ${catalog_info}=   create dictionary
    ${flavor_content}=  get file  ${extracted_flavor_dir_path}/5grac.flavor.tosca.yaml
    ${flavor_dict}=  yaml.load   ${flavor_content}
    ${flavor}=  create dictionary  descriptor_version  ${flavor_dict["dsl_definitions"]["descriptor_version"]}
    ...   product_name  ${flavor_dict["dsl_definitions"]["product_name"]}
    ...   file_path  ${path_of_flavor_package}
    set to dictionary   ${catalog_info}    flavors=${flavor}

    ${nets_content}=  get file  ${extracted_nets_dir_path}/5grac.nets.tosca.yaml
    ${nets_dict}=  yaml.load   ${nets_content}
    ${nets}=  create dictionary  descriptor_version  ${nets_dict["dsl_definitions"]["descriptor_version"]}
    ...   product_name  ${nets_dict["dsl_definitions"]["product_name"]}
    ...   file_path  ${path_of_nets_package}
    set to dictionary   ${catalog_info}    nets=${nets}

    ${sec_group_content}=  get file  ${extracted_sec_group_dir_path}/5grac.securitygroup.tosca.yaml
    ${sec_group_dict}=  yaml.load   ${sec_group_content}
    ${sec_group}=  create dictionary  descriptor_version  ${sec_group_dict["dsl_definitions"]["descriptor_version"]}
    ...   product_name  ${sec_group_dict["dsl_definitions"]["product_name"]}
    ...   file_path  ${path_of_security_group_package}
    set to dictionary   ${catalog_info}    security-group=${sec_group}

    ${vnf_content}=  get file  ${extracted_vnf_dir_path}/5grac.vnfd.rigid.tosca.yaml
    ${vnf_dict}=  yaml.load   ${vnf_content}
    ${vnf}=  create dictionary  descriptor_version  ${vnf_dict["dsl_definitions"]["descriptor_version"]}
        ...   product_name  ${vnf_dict["dsl_definitions"]["product_name"]}
        ...   file_path  ${path_of_vnf_package}
    set to dictionary   ${catalog_info}    vnf=${vnf}
    log to console  ${catalog_info}
    [Return]  ${catalog_info}

Modify Json Files
    [Arguments]  ${template_files_dir}  ${user_config_index}  ${vnf_info_dict}  ${build_version}  ${gnb_index}=0
    ${user_config_file}=  set variable
    ...  ${tl.gnbs[${gnb_index}].dus[0].cloud_deployment.default_cfg_dir}/DEP_SCF_FILES/CU_0/CBAM/user_config_${user_config_index}.yaml
    ${result}=  OperatingSystem.Run  find ${template_files_dir} -name "*json" |sed 's#.*/##'
    ${json_list}=  create list
    ${jsons}=   Split String  ${result}   \n
     FOR    ${json}    IN    @{jsons}
      ${num}=   get count    ${json}   [
      run keyword if  ${num}==0  append to list  ${json_list}  ${json.strip()}
    END

    ${user_config_json}=  get file  ${user_config_file}
    ${user_config_json}=  yaml.load  ${user_config_json}

    FOR    ${json_name}     IN  @{json_list}
       ${tempate_json}=  get file  ${template_files_dir}/${json_name}
       ${tempate_json}=  json.loads  ${tempate_json}
       ${result}  RUN KEYWORD IF  '${json_name}'=='5G_instantiate_flavors_gui.json'
    ...     _Modify_Instantiate_Flavor_Nets_Secgroup_JSON    ${user_config_json}   ${tempate_json}  ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_instantiate_nets_gui.json'
    ...     _Modify_Instantiate_Flavor_Nets_Secgroup_JSON   ${user_config_json}   ${tempate_json}   ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_instantiate_security_group_gui.json'
    ...     _Modify_Instantiate_Flavor_Nets_Secgroup_JSON  ${user_config_json}   ${tempate_json}   ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_instantiate_vnf_gui.json'
    ...     _Modify_Instantiate_VNF_JSON   ${user_config_json}   ${tempate_json}  ${vnf_info_dict}  ${build_version}  ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_modify_nets_gui.json'
    ...     _Modify_Nets_JSON   ${user_config_json}   ${tempate_json}  ${vnf_info_dict}  ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_modify_vnf_gui_basic.json'
    ...     _Modify_VNF_JSON  ${user_config_json}   ${tempate_json}  ${vnf_info_dict}  basic   ${gnb_index}
    ...                        ELSE IF  '${json_name}'=='5G_modify_vnf_gui_redundant.json'
    ...     _Modify_VNF_JSON   ${user_config_json}   ${tempate_json}  ${vnf_info_dict}  redundancy   ${gnb_index}
       ${json_result}  json.dumps  ${result}
       ${new_file}=   create file   ${template_files_dir}/${json_name}  ${json_result}
    END

_Modify_Instantiate_Flavor_Nets_Secgroup_JSON
    [Arguments]    ${user_config_dict}   ${template_dict}  ${gnb_index}=0
    set to dictionary   ${template_dict["vimConnectionInfo"][0]["interfaceInfo"]}
    ...  endpoint  ${user_config_dict["osp_ip"]}
    set to dictionary   ${template_dict["vimConnectionInfo"][0]["accessInfo"]}
    ...  username  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
    set to dictionary   ${template_dict["vimConnectionInfo"][0]["accessInfo"]}
    ...  password  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.password}
    set to dictionary   ${template_dict["vimConnectionInfo"][0]["accessInfo"]}
    ...  tenant  ${user_config_dict["tenant_project_id"]}
    set to dictionary   ${template_dict["vimConnectionInfo"][0]["accessInfo"]}
    ...  project  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}
    [Return]   ${template_dict}

_Modify_Nets_JSON
   [Arguments]   ${user_config_dict}   ${template_dict}   ${vnf_info_dict}  ${gnb_index}=0
   ${username}=  set variable
   ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
   set to dictionary  ${template_dict["extensions"]["oam_network_opts"]}   number_of_networks     ${0}
   set to dictionary  ${template_dict["extensions"]["ext_network_opts"]}   number_of_networks     ${0}
   set to dictionary  ${template_dict["extensions"]}   vnf_name  ${username}-${vnf_info_dict["nets"]["descriptor_version"]}
   ${number}=  get length  ${template_dict["extensions"]["int_network_opts"]["networks"]}
   FOR  ${num}  IN RANGE  ${number}
     set to dictionary  ${template_dict["extensions"]["int_network_opts"]["networks"][${num}]}
   ...   tenant_id  ${user_config_dict["tenant_project_id"]}
   END
   [Return]  ${template_dict}


_Modify_Instantiate_VNF_JSON
    [Arguments]   ${user_dict}   ${temp_dict}    ${vnf_info_dict}  ${build_version}  ${gnb_index}=0
    ${username}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
    ${number}=  get length  ${temp_dict["computeResourceFlavours"]}
    ${name_list}=  create list  oam  cpif  cpnb  cpcl  cpnrt  db  cpue  upue  uvm
    ${name_number}=  get length  ${name_list}
    RETURN FROM KEYWORD IF  '${name_number}' != '${number}'   'vimFlavourId not fix'
    FOR  ${num}    IN RANGE    ${number}
      set to dictionary  ${temp_dict["computeResourceFlavours"][${num}]}
    ...  vimFlavourId  ${username}-${vnf_info_dict["flavors"]["descriptor_version"]}_${name_list[${num}]}
    END
    ${​​​​​​​​temp_dict["instantiationLevelId"]​​​​​​​​}   set variable   ${user_dict["instantiationLevelId"]}
    set to dictionary  ${temp_dict["extVirtualLinks"][0]}  id  ${user_dict["extVirtualLinks"][0]["id"]}
    set to dictionary  ${temp_dict["extVirtualLinks"][0]}  resourceId  ${user_dict["extVirtualLinks"][0]["resourceId"]}
    set to dictionary
    ...  ${temp_dict["extVirtualLinks"][0]["extCps"][0]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  subnetId
    ...  ${user_dict["extVirtualLinks"][0]["subnetId"]}
    set to dictionary
    ...  ${temp_dict["extVirtualLinks"][0]["extCps"][0]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  type
    ...  ${user_dict["extVirtualLinks"][0]["type"]}

    ${number}=  get length  ${temp_dict["extVirtualLinks"][1]["extCps"]}
    FOR  ${num}    IN RANGE    ${number}
      set to dictionary
    ...  ${temp_dict["extVirtualLinks"][1]["extCps"][${num}]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  subnetId
    ...  ${user_dict["extVirtualLinks"][1]["subnetId"]}
      set to dictionary
    ...  ${temp_dict["extVirtualLinks"][1]["extCps"][${num}]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  type
    ...  ${user_dict["extVirtualLinks"][1]["type"]}
    END
    set to dictionary  ${temp_dict["extVirtualLinks"][1]}  id  ${user_dict["extVirtualLinks"][1]["id"]}
    set to dictionary  ${temp_dict["extVirtualLinks"][1]}  resourceId  ${user_dict["extVirtualLinks"][1]["resourceId"]}

    ${number}=  get length  ${temp_dict["extVirtualLinks"][2]["extCps"]}
    FOR  ${num}    IN RANGE    ${number}
      set to dictionary
    ...  ${temp_dict["extVirtualLinks"][2]["extCps"][${num}]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  subnetId
    ...  ${user_dict["extVirtualLinks"][2]["subnetId"]}
      set to dictionary
    ...  ${temp_dict["extVirtualLinks"][2]["extCps"][${num}]["cpConfig"][0]["cpProtocolData"][0]["ipOverEthernet"]["ipAddresses"][0]}
    ...  type
    ...  ${user_dict["extVirtualLinks"][2]["type"]}
    END
    set to dictionary  ${temp_dict["extVirtualLinks"][2]}  id  ${user_dict["extVirtualLinks"][2]["id"]}
    set to dictionary  ${temp_dict["extVirtualLinks"][2]}  resourceId  ${user_dict["extVirtualLinks"][2]["resourceId"]}

    ${number}=  get length  ${temp_dict["softwareImages"]}
    FOR  ${num}    IN RANGE    ${number}
       set to dictionary  ${temp_dict["softwareImages"][${num}]}  vimSoftwareImageId    AirFrameVirtualized-${build_version}
    ${temp_dict}=  _Modify_Instantiate_Flavor_Nets_Secgroup_JSON      ${user_dict}   ${temp_dict}   ${gnb_index}
    END

    [Return]  ${temp_dict}

_Modify_VNF_JSON
    [Arguments]   ${user_config_dict}    ${template_dict}   ${vnf_info_dict}  ${deploy_mode}=redundancy   ${gnb_index}=0
    ${username}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
    set to dictionary  ${template_dict["extensions"]}
    ...  vnf_name     ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}
    set to dictionary  ${template_dict["extensions"]}   network-interface-enable  ${user_config_dict["vnf"]["network-interface-enable"]}
    set to dictionary  ${template_dict["extensions"]}   ext_port  ${user_config_dict["vnf"]["ext_port"]}
    set to dictionary  ${template_dict["extensions"]}
    ...  internal_network    ${username}-${vnf_info_dict["nets"]["descriptor_version"]}-internal_net-v4
    set to dictionary  ${template_dict["extensions"]}
    ...  internal_srv_network    ${username}-${vnf_info_dict["nets"]["descriptor_version"]}-internal_srv_net-v4
    set to dictionary  ${template_dict["extensions"]}
    ...  internal_e1_network     ${username}-${vnf_info_dict["nets"]["descriptor_version"]}-internal_e1_net-v4
    set to dictionary  ${template_dict["extensions"]}   oam_network     ${user_config_dict["vnf"]["oam_network"]}
    set to dictionary  ${template_dict["extensions"]}   oam_ip_0    ${user_config_dict["vnf"]["oam_ip_0"]}
    set to dictionary  ${template_dict["extensions"]}   oam_default_gw  ${user_config_dict["vnf"]["oam_default_gw"]}
    set to dictionary  ${template_dict["extensions"]}   oam_security_group
    ...  ${username}-${vnf_info_dict["security-group"]["descriptor_version"]}-oam-security-group
    set to dictionary  ${template_dict["extensions"]["external_networks"]}
    ...  extnet_a  ${user_config_dict["vnf"]["external_networks"]["extnet_a"]}
    set to dictionary  ${template_dict["extensions"]["external_networks"]}
    ...  extnet_b  ${user_config_dict["vnf"]["external_networks"]["extnet_b"]}
    RUN KEYWORD IF  '${deploy_mode}'=='redundancy'
    ...  set to dictionary  ${template_dict["extensions"]}  oam_ip_logical  ${user_config_dict["vnf"]["oam_ip_logical"]}
    RUN KEYWORD IF  '${deploy_mode}'=='redundancy'
    ...  set to dictionary  ${template_dict["extensions"]}  oam_ip_1  ${user_config_dict["vnf"]["oam_ip_1"]}
    RUN KEYWORD IF  '${deploy_mode}'=='redundancy'
    ...  set to dictionary  ${template_dict["extensions"]}  apigw_swm_password  ${user_config_dict["vnf"]["apigw_swm_password"]}
    [Return]   ${template_dict}

Check And Upload Catalogs On CBAM
    [Arguments]   ${build_version}   ${dir_of_extracted_template_files}   ${deploy_mode}=redundancy  ${gnb_index}=0
    check cbam connection
    ${new_catalog}=    Get Template Catalog Versions    ${build_version}   ${dir_of_extracted_template_files}   ${deploy_mode}   ${gnb_index}
    ${vnfd_id_dict}=  create dictionary
    ${list}=  get dictionary keys  ${new_catalog}
    FOR  ${type}   IN  @{list}
       ${result}=  Check If Catalog Exists On CBAM  ${new_catalog["${type}"]["product_name"]}  ${new_catalog["${type}"]["descriptor_version"]}
       log to console   ${type} exist ${result}
       RUN KEYWORD IF  '${result}'=='None'  taf_cbam.post_catalog_info  ${new_catalog["${type}"]["file_path"]}
       ${vnfd_id}=  Check If Catalog Exists On CBAM  ${new_catalog["${type}"]["product_name"]}
    ...   ${new_catalog["${type}"]["descriptor_version"]}
       SHOULD BE TRUE  '${vnfd_id}'!='None'    Upload catalog failed!
       set to dictionary  ${new_catalog["${type}"]}    vnfd_id  ${vnfd_id}
       set to dictionary    ${vnfd_id_dict}   ${type}=${new_catalog["${type}"]}
    END
    ${catalog_info}=   taf_cbam.get_catalog_info
    [Return]   ${vnfd_id_dict}

Check If Catalog Exists On CBAM
    [Arguments]  ${vnfProductName}   ${vnfdVersion}
    ${exist_cat}=   taf_cbam.get_catalog_info
    ${number}=  get length  ${exist_cat}
    FOR  ${num}    IN RANGE    ${number}
       RETURN FROM KEYWORD IF
    ...  '${exist_cat[${num}]["vnfProductName"]}'=='${vnfProductName}'and'${exist_cat[${num}]["vnfdVersion"]}'=='${vnfdVersion}'
    ...   ${exist_cat[${num}]["vnfdId"]}
    END

Create CBAM VNF
    [Arguments]   ${build_version}  ${user_config_index}    ${deploy_mode}=redundancy   ${gnb_index}=0
    ${tenant}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}
    log to console   ${tenant}
    check cbam connection
    ${dir_of_extracted_template_files}=    Download And Extract Addons Package     ${build_version}     ${gnb_index}
    log to console   ${dir_of_extracted_template_files}
    ${vnfd_id_dict}=   Check And Upload Catalogs On CBAM    ${build_version}  ${dir_of_extracted_template_files}  ${deploy_mode}  ${gnb_index}
    log to console    ${vnfd_id_dict}
    Modify Json Files  ${dir_of_extracted_template_files}/SAMPLE  ${user_config_index}    ${vnfd_id_dict}  ${build_version}   ${gnb_index}
    ${list}=    get dictionary keys  ${vnfd_id_dict}
    Terminate And Delete Specific VNF With Tenant Name    vnf   ${gnb_index}
    ${new_vnf_dict}=    create dictionary
    ${vnf_deploy_name}=  set variable   ${tenant}-${vnfd_id_dict["${list[3]}"]["descriptor_version"]}-${list[3]}
    log to console  ${vnf_deploy_name}
    log to console  start create vnf!
    FOR  ${type}   IN  @{list}
       ${vnf_name}=  set variable   ${tenant}-${vnfd_id_dict["${type}"]["descriptor_version"]}-${type}
       Create VNF On CBAM  ${vnf_name}  ${vnfd_id_dict["${type}"]["vnfd_id"]}
       Modify VNF On CBAM  ${vnf_name}    ${type}   ${dir_of_extracted_template_files}/SAMPLE  ${deploy_mode}  ${gnb_index}
       RUN KEYWORD IF  '${type}'!='vnf'
    ...    Instantiate Flavor Nets Secgroup On CBAM  ${vnf_name}  ${type}  ${dir_of_extracted_template_files}/SAMPLE
    END
    Instantiate VNF On CBAM  ${tenant}-${vnfd_id_dict["vnf"]["descriptor_version"]}-vnf  vnf  ${dir_of_extracted_template_files}/SAMPLE

    [Return]  ${new_vnf_dict}    ${vnf_deploy_name}     ${list}


Create VNF On CBAM
   [Arguments]   ${vnf_name}  ${vnfd_id}
   check cbam connection
   log to console  Start create vnf ${vnf_name}!
   Terminate And Delete VNF  ${vnf_name}
   taf_cbam.create_vnf  vnfd_id=${vnfd_id}    name=${vnf_name}    description=Initial create ${vnf_name}
   wait until keyword succeeds    3 min    10s    Check If VNF Exists    ${vnf_name}
   log to console  Create vnf ${vnf_name} success!

Modify VNF On CBAM
   [Arguments]   ${vnf_name}    ${vnf_type}   ${file_path}  ${deploy_mode}=redundancy   ${gnb_index}=0
   check cbam connection
   log to console  Start modify vnf ${vnf_name}!
   ${file}=   Generate Modify VNF JSON  ${vnf_type}  ${vnf_name}  ${gnb_index}
   RUN KEYWORD IF  '${vnf_type}'!='vnf'  taf_cbam.modify_vnf    ${vnf_name}   ${file}
   RUN KEYWORD IF  '${vnf_type}'=='nets'
   ...                taf_cbam.modify_vnf    ${vnf_name}   ${file_path}/5G_modify_nets_gui.json
   ...  ELSE IF  '${vnf_type}'=='vnf'and'${deploy_mode}'=='redundancy'
   ...                taf_cbam.modify_vnf    ${vnf_name}   ${file_path}/5G_modify_vnf_gui_redundant.json
   ...  ELSE IF  '${vnf_type}'=='vnf'and'${deploy_mode}'=='basic'
   ...                taf_cbam.modify_vnf    ${vnf_name}   ${file_path}/5G_modify_vnf_gui_basic.json
   log to console  Modify vnf ${vnf_name} finish!

Generate Modify VNF JSON
    [Arguments]    ${vnf_type}  ${vnf_name}  ${gnb_index}=0
    ${username}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
    ${tenant}=  set variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.tenant}

    ${flavor_prefix_json}=  get a file    ${tenant}-cbam    5G_modify_${vnf_type}_gui.json
#    ${vnf_name_split}=  evaluate  re.split('-','${vnf_name}')
    ${vnf_name_split}=   split_string    ${vnf_name}   -
    ${content}=  set variable  {"extensions": {"prefix_name": "${username}-${vnf_name_split[1]}" } }
    ${file}=   create file    ${flavor_prefix_json}      ${content}
    [Return]    ${flavor_prefix_json}

Instantiate Flavor Nets Secgroup On CBAM
   [Arguments]   ${vnf_name}  ${vnf_type}  ${file_path}  ${gnb_index}=0
   check cbam connection
   log to console  Start instantiate vnf ${vnf_name}!
   ${password}=  set variable
   ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.password}
   ${operation_id}=  RUN KEYWORD IF  '${vnf_type}'=='flavors'
   ...    taf_cbam.instantiate_vnf    ${vnf_name}   ${file_path}/5G_instantiate_flavors_gui.json  ${password}   5gbts_flavor
   ...  ELSE IF  '${vnf_type}'=='nets'
   ...    taf_cbam.instantiate_vnf    ${vnf_name}   ${file_path}/5G_instantiate_nets_gui.json  ${password}  5gbts_nets
   ...  ELSE IF  '${vnf_type}'=='security-group'
   ...    taf_cbam.instantiate_vnf    ${vnf_name}   ${file_path}/5G_instantiate_security_group_gui.json  ${password}  5gbts_oam_security_group
   sleep  30s
   wait until keyword succeeds    10 min    5s    Instantiate VNF Should Be Successful    ${vnf_name}
   log to console  Instantiate vnf ${vnf_name} success!

Instantiate VNF On CBAM
   [Arguments]   ${vnf_name}    ${file_path}  ${gnb_index}=0        #${vnf_type}
   check cbam connection
   log to console  Start instantiate vnf ${vnf_name}!
   ${password}=  set variable
   ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.password}
   ${operation_id}=  RUN KEYWORD
   ...    taf_cbam.instantiate_vnf    ${vnf_name}   ${file_path}/5G_instantiate_vnf_gui.json  ${password}  5gbts_vnf
   sleep  15min
   wait until keyword succeeds    20 min    15s    Instantiate VNF Should Be Successful    ${vnf_name}
   log to console  Instantiate vnf ${vnf_name} success!

Instantiate VNF Should Be Successful
    [Arguments]    ${vnf_name}
    ${vnf_info_dict}=    Get VNF Instance Info Via VNF Name  ${vnf_name}
    log to console  check instantiate status:${vnf_info_dict.instantiationState}
    should be equal    ${vnf_info_dict.instantiationState}    INSTANTIATED
