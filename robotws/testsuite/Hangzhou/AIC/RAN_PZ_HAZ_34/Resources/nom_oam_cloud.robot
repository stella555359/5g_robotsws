*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_cloud.robot



*** Variables ***
${VDU_JSON_FILE_PATH}   ${CURDIR}/nom/nom_deploy_upgrade_vdu.json



*** Keywords ***
Import And Activate AutoConfiguration Plan To Nom
    [Arguments]  ${plan_path}   ${timeout}=${300}
    [Documentation]  import and activate scf plan file to nom, the playtype is AutoConfiguration.
    ...  author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_path        | yes  | the scf file path |
    ...    | timeout          | no   | the timeout for mon activate the autoconfiguration plan, default is 300s  |
    ...    *RETURN VALUE*   None
    ...    Example
    ...    |  Import And Activate AutoConfiguration Plan To Nom  | /home/ute/nom_2583/MRBTS-10703-CB2583.xml |
    log to console  ***** import and activate scf plan file in NOM *****
    ${plan_unique_id}=  Get Unique Id
    ${scf_plan_name}  set variable   Commission-${MRBTS_ID}-${plan_unique_id}
    nom_rest.import_plan   path_to_plan=${plan_path}  name=${scf_plan_name}   plan_type=AUTOCONFIGURATION  overwrite=${True}
    ${operation_result}  nom_rest.activate_autoconfiguration   plan_name=${scf_plan_name}  deploy_cnf=${False}
    ...  apply_templates=${True}   validate=${True}   overwrite=${True}   timeout=${timeout}
    Log  ${operation_result}


Get Scf or Chart Yaml File from Agent Server
    [Arguments]   ${testline_id}   ${build_version}   ${file_type}=scf   ${ne_type}=VDU  ${ne_index}=${0}
    [Documentation]  Get the related scf file or the chart value-override yaml file from agent server.
    ...    The server link is - http://10.109.2.147:8099/AGENT_AIC_VDU_SCF/
    ...                         http://10.109.2.147:8099/AGENT_AIC_VCU_SCF/
    ...                         http://10.109.2.147:8099/AGENT_AIC_VCU_YAML/
    ...                         http://10.109.2.147:8099/AGENT_AIC_VDU_YAML/
    ...    The file name format is <testline_id>_<build_version>_<file_type>_<ne_type vCU or VDU>_<ne_index>.<file_suff yaml or xml>
    ...    This keyword will generate the target file name, like 7_5_UTE5GAIC001T00037_0.250.3269_values_override_aic_vcu_yaml_vCU_0.yaml
    ...    *Author*: calla.wang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-4-28 | r3li | Check ne_type must be VDU or vCU |
    ...    | 2022-5-9  | huilxu | add file should exist check |
    ...    | 2022-7-4  | huilxu | add file_type: values_override_aic_cluster_preparation_yaml |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | testline_id      | yes  | the testline identification id, like 7_5_UTE5GAIC001T00037 |
    ...    | build_version    | yes  | software build version, like 14.300.430 |
    ...    | file_type        | yes  | the file type you want to get, the file type should be in the next value:
    ...                                (scf, values_override_aic_cluster_preparation_yaml, values_override_aic_prerequisite_yaml,
    ...                                 values_override_aic_vdu_yaml, values_override_aic_vcu_yaml)
    ...    | ne_type          | yes  | the ne type, it should be in the next value (VDU, vCU) |
    ...    | ne_index         | no   | the ne index, default is 0 |
    ...    *RETURN VALUE*
    ...    | the file path |
    ...    *Example*
    ...    |  ${prechart_yaml}= | Get scf or chart yaml file from agent server | testline_id=7_5_UTE5GAIC001T00037 |
    ...                                                                         build_version=14.300.430          |
    ...                                                                         file_type=values_override_aic_prerequisite_yaml|
    ...                                                                         ne_type=vDU                       |
    ${file_suffix}   run keyword if  'yaml' in '${file_type}'  set variable   yaml
    ...    ELSE   set variable  xml
    ${ne_type}  run keyword if  'vdu' in '${file_type}'  set variable   ${ne_type.upper()}
    ...    ELSE   set variable  ${ne_type}
    ${scf_yaml_save_path}   get a directory  ${build_version}-scf-yaml
    ${url}   catenate   SEPARATOR=  ${AGENT_LINK}/AGENT_AIC_${ne_type.upper()}_${file_type.split('_')[-1].upper()}/
    ...  ${testline_id}_${build_version}_${file_type}_${ne_type}_${ne_index}.${file_suffix}
    OperatingSystem.Run  command=wget -P ${scf_yaml_save_path} ${url}
    ${file_path}   set variable   ${scf_yaml_save_path}/${testline_id}_${build_version}_${file_type}_${ne_type}_${ne_index}.${file_suffix}
    File Should Exist   ${file_path}
    [Return]  ${file_path}

Terminated Cnfs via Nom
   [Arguments]  ${mrbts_id}    ${build_version}
   [Documentation]  Terminating cfns from NOM.
    ...  author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | mrbts_id        | yes  | MRBTS ID used for creating the terminating plan |
    ...    | build_version   | yes   | SW build version used for creating the terminating plan, like 14.300.430 |
    ...    *RETURN VALUE*
    ...    | the terminating operation api response |
    ...    Example
    ...    | Terminated cnfs via Nom | mrbts_id=10700 | build_version=14.300.430 |
   ${terminated_plan_name}   ${confid}    Create Terminated cnfs plan   ${mrbts_id}   ${build_version}
   ${time_out}   evaluate   int(20)*int(60)
   ${opration}   nom_rest.terminate_only_planned_cnfs    ${terminated_plan_name}    ${time_out}
   [Return]   ${opration}

Create Terminated Cnfs Plan
    [Arguments]   ${mrbts_id}   ${build_version}
    [Documentation]  Create terminating cfns plan.
    ...  author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | mrbts_id        | yes  | MRBTS ID used for creating the terminating plan |
    ...    | build_version   | yes   | SW build version used for creating the terminating plan, like 14.300.430 |
    ...    *RETURN VALUE*
    ...    | terminated_plan_name |
    ...    | plan config id |
    ...    Example
    ...    | ${terminated_plan_name} | ${confid}| Create Terminated cnfs plan | mrbts_id=10700 | build_version=14.300.430 |
    ${unique_id}   get unique id
    ${terminated_plan_name}   set variable    undeploy-${MRBTS_ID}-${unique_id}
    ${empty_plan}   nom_rest.create_empty_plan    ${terminated_plan_name}   undeploy-${MRBTS_ID}-${build_version}   PLAN
    ${confid}   set variable   ${empty_plan}[info][conf_id]
    ${moClass}  create dictionary    id=com.nokia.vran.lcm:CNF   version=${build_version}
    ${managed_object}   create dictionary   moId=CNF-${MRBTS_ID}    planOperation=DELETE   moClass=${moClass}
    ${managed_objects}   create list   ${managed_object}
    nom_rest.add_managed_objects   ${confid}   ${managed_objects}
    [Return]   ${terminated_plan_name}   ${confid}


Onboard PDL ZIP Build to NOM
    [Arguments]   ${release}    ${build_version}
    [Documentation]  upload PDL zip file to NOM.
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | release        | yes  | the build release version, like vDUCNF22R2 |
    ...    | build_version   | yes   | SW build versionlike 14.300.430 |
    ...    *RETURN VALUE*
    ...    | pdl_save_path in UTE|
    ...    Example
    ...    |${pdl_save_path_ute}= | Onboard PDL ZIP Build to NOM | release=vDUCNF22R2 | build_version=14.300.430 |
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list  ne_type=MRBTS
    ${flag}    set variable   ${0}
    ${pdl_zip_name}   set variable   ${release}_${build_version}_pdl_validation_service_plugin

    log to console  ***** Check Whether the pdl Build Existed in NOM *****
    FOR   ${sw_version}  IN   @{neSwVersion}
        ${flag}=   Set Variable If    '${swVersion}[ne_sw_version]'=='${pdl_zip_name}'   ${1}   ${flag}
        Exit For Loop If   '${swVersion}[ne_sw_version]'=='${pdl_zip_name}'
    END
    ${pdl_save_path}  Run Keyword If   ${flag}==${0}   Download Pdl to UTE  ${release}   ${build_version}
    Run Keyword If   ${flag}==${1}   log to console  SW pdl Already Existed in NOM
    ...   ELSE   nom_rest.import_sw_package   ${pdl_save_path}   ne_type=MRBTS
    Run Keyword If   ${flag}==${0}  PDL Build Should Be In NOM   release=${release}  build_version=${build_version}
    [Return]  ${pdl_save_path}

Onboard Chart ZIP Build to NOM
    [Arguments]   ${release}    ${build_version}   ${NOM_label}
    [Documentation]  Uploading chart zip file to NOM. The zip file will be stored in NOM edge node firstly by wget.
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | release        | yes  | the build release version, like vDUCNF22R2 |
    ...    | build_version  | yes   | SW build versionlike 14.300.430 |
    ...    | NOM_label | yes | the NOM label like NOM13 |
    ...    *RETURN VALUE*
    ...    | NONE |
    ...    Example
    ...    |${pdl_save_path_ute}= | Onboard Chart ZIP Build to NOM | release=vDUCNF22R2 | build_version=14.300.430 | NOM_label=NOM13 |
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list    ne_type=CNF
    ${flag}    set variable   ${0}
    ${zip_name}   set variable   ${release}_${build_version}

    log to console  *****Check Whether the SW Chart Build Existed in NOM*****
    FOR   ${sw_version}  IN   @{neSwVersion}
        ${flag}=   Set Variable If    '${swVersion}[ne_sw_version]'=='${zip_name}'   ${1}   ${flag}
         Exit For Loop If   '${swVersion}[ne_sw_version]'=='${zip_name}'
    END
    ${chart_save_path}   Run Keyword If   ${flag}==${0}   DownLoad SW Package To Nom By SSH   ${NOM_label}   ${release}   ${build_version}
    Run Keyword If   ${flag} == ${1}   log to console  SW Build Already Existed in NOM
    ...   ELSE   Import SW Package to Nom By SSH   ${NOM_label}   ${release}   ${build_version}   ${chart_save_path}    ne_type=CNF

PDL Build Should Be In NOM
    [Arguments]   ${release}   ${build_version}
    [Documentation]  Checking PDL build should be uploaded successfully to NOM.
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | release        | yes  | the build release version, like vDUCNF22R2 |
    ...    | build_version   | yes   | SW build versionlike 14.300.430 |
    ...    *RETURN VALUE*
    ...    | None |
    ...    Example
    ...    | PDL Build Should Be In NOM | release=vDUCNF22R2 | build_version=14.300.430 |
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list  ne_type=MRBTS
    ${flag}    set variable  ${0}
    ${pdl_zip_name}   set variable   ${release}_${build_version}_pdl_validation_service_plugin
    FOR   ${sw_version}  IN   @{neSwVersion}
        ${flag}=   Set Variable If    '${swVersion}[ne_sw_version]'=='${pdl_zip_name}'   ${1}   ${flag}
        Exit For Loop If    '${swVersion}[ne_sw_version]'=='${pdl_zip_name}'
    END
     Run keyword If   ${flag}==${1}    log to console  Import Success, SW Build Already Existed in NOM
    ...   ELSE   fail    log to console   Import Fail, PDL Build Not Existed in NOM

VDU Chart Build Should Be In NOM
    [Arguments]   ${release}   ${build_version}     ${ne_type}=MRBTS
    [Documentation]  Checking chart build should be uploaded successfully to NOM.
    ...    *Author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-5-25 | r3li | add parameter ne_type |
    ...    | 2022-6-08 | huilxu | add CNF in the ne_type_list |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | release        | yes  | the build release version, like vDUCNF22R2 |
    ...    | build_version   | yes   | SW build versionlike 14.300.430 |
    ...    | ne_type | No | ne type, must in MRBTS,SMM,FHGW, default is MRBTS |
    ...    *RETURN VALUE*
    ...    | None |
    ...    Example
    ...    | VDU Chart Build Should Be In NOM | release=vDUCNF22R2 | build_version=14.300.430 | ne_type=MRBTS |
    ${ne_type_list}    Create List    MRBTS    SMM    FHGW    CNF
    List Should Contain Value     ${ne_type_list}    ${ne_type}    ne_type should in ${ne_type_list}
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list   ne_type=${ne_type}
    ${flag}    set variable  ${0}
    ${zip_name}   set variable   ${release}_${build_version}

    FOR   ${sw_version}  IN   @{neSwVersion}
        ${flag}=   Set Variable If    '${swVersion}[ne_sw_version]'=='${zip_name}'   ${1}   ${flag}
        Exit For Loop If    '${swVersion}[ne_sw_version]'=='${zip_name}'
    END
    Run keyword If   ${flag}==${1}    log to console  Import Success, SW Build Already Existed in NOM
    ...   ELSE   fail    log to console  Import Fail, SW Build Not Existed in NOM

Download Pdl to UTE
    [Arguments]  ${release}  ${build_version}
    [Documentation]  Downloading the pdl package to UTE by wget command.
    ...    author: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-5-25 | r3li | initial create |
    ...    | 2022-11-17 | huilxu | remove the useless steps |
    ...    | Input Parameters | Man. | Description |
    ...    | release        | yes  | the build release version, like vDUCNF22R2 |
    ...    | build_version   | yes   | SW build versionlike 14.300.430 |
    ...    *RETURN VALUE*
    ...    | pdl package path in UTE |
    ...    Example
    ...    | ${pdl_path_ute}= | Download Pdl to UTE | release=vDUCNF22R2 | build_version=14.300.430 |
     log to console    ***** download pdl package to ute firstly and then import to NOM *****
     ${save_path}   get a directory  pdl_Package
     #${num_prefix}   Get Substring   ${release}   ${-2}
     #${r}  ${re}   Run Keyword And Ignore Error   Evaluate    int(${num_prefix})
     ${file_name}   Set Variable   ${release}_${build_version}_pdl_validation_service_plugin.zip
     ${pdl_url}    set variable    ${PACKAGE_LINK_ESPOO}/${release}/${release}_${build_version}/${file_name}
     OperatingSystem.Run  command=wget -P ${save_path} ${pdl_url}
     ${file_path}   set variable   ${save_path}/${release}_${build_version}_pdl_validation_service_plugin.zip
     File Should Exist   ${file_path}
     [Return]   ${file_path}

Delete Plan with Given Name
    [Arguments]  ${plan_name}
    [Documentation]  Deleting plan with the given plan name from NOM.
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name        | yes  | plan name in NOM |
    ...    *RETURN VALUE*
    ...    | None |
    ...    Example
    ...    | Delete plan with given name | plan_name=deploy_10700_vdu |
    log to console   *****Delete Old Plan With Plan Name*****
    ${all_plan_info}   nom_rest.get_plan_header_info   PLAN   ${None}
    ${all_plan_result}   set variable   ${all_plan_info}[result]
    FOR   ${plan}   IN    @{all_plan_result}
        ${plan_id}=   Set Variable If   '${plan}[name]'=='${plan_name}'   ${plan}[conf_id]
        Exit For Loop If   '${plan}[name]'=='${plan_name}'
    END
    Run Keyword And Ignore Error   nom_rest.delete_plan    ${plan_id}

Create Deploy Or Upgrade Plan In Nom
   [Arguments]  ${plan_name}  ${json_file_path}   ${build_version}  ${mrbts_id}   ${kubeconfig}   ${image_registry}
   ...    ${image_registry_pwd}   ${prechart_values}   ${mainchart_values}    ${release_name}
   ...    ${ne_type}=vdu  ${plan_operation}=CREATE  ${plan_type}=CNF_CREATE
   ...    ${clusterpreparation_values}=${EMPTY}
    [Documentation]  Creating plan in NOM for deploying or upgrading CNFS.
    ...    *Author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-5-25 | r3li | adapt new function of cnf plan |
    ...    | 2022-6-08 | huilxu | add plan_type parameter |
    ...    | 2022-7-04 | huilxu | add clusterpreparation_values parameter |
    ...    | 2022-7-18 | r3li | call import_cnf_plan without username due to lib taf.nms.nom updated |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name        | yes  | the deploy or upgrade plan name |
    ...    | json_file_path   | yes | json file path for updating the empty plan |
    ...    | build_version    | yes | SW build version like 14.300.430 |
    ...    | mrbts_id         | yes | MRBTS ID |
    ...    | kubeconfig       | yes | kubeconfig string that encoded to base64 |
    ...    | image_registry   | yes | image registry by oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}' |
    ...    | image_registry_pwd | yes | image_registry_pwd by oc whoami -t |
    ...    | clusterpreparation_values   | yes | cluster preparation value-override yaml string encoded to base64 |
    ...    | prechart_values   | yes | prechart value-override yaml string encoded to base64 |
    ...    | mainchart_values  | yes | mainchart value-override yaml string encoded to base64 |
    ...    | release_name      | yes | the SW release version, like vDUCNF22R2 |
    ...    | ne_type           | yes | the ne type, vcu or vdu |
    ...    | plan_operation    | yes | plan operation, only support create,update |
    ...    | plan_type         | yes | plan type, only support CNF_CREATE,CNF_DELETE,CNF_ROLLBACK,CNF_UPGRADE |
    ...    *RETURN VALUE*
    ...    | None |

   log to console    ***** create and construct deloy/upgrade plan in NOM *****
   ${managed_object}   Construct Managed Objects   json_path=${json_file_path}
   ...                                             mrbts_id=${mrbts_id}
   ...                                             build_version=${build_version}
   ...                                             plan_operation=${plan_operation}
   ...                                             kubeconfig=${kubeconfig}
   ...                                             image_registry=${image_registry}
   ...                                             image_registry_pwd=${image_registry_pwd}
   ...                                             clusterpreparation_values=${clusterpreparation_values}
   ...                                             prechart_values=${prechart_values}
   ...                                             mainchart_values=${mainchart_values}
   ...                                             release_name=${release_name}
   ...                                             ne_type=${ne_type}


   nom_rest.import_cnf_plan    plan_name=${Plan_Name}     plan_type=${plan_type}
    ...    cnf_data=${managed_object}



Construct Managed Objects
    [Arguments]   ${json_path}   ${mrbts_id}   ${build_version}  ${plan_operation}   ${kubeconfig}   ${image_registry}
    ...    ${image_registry_pwd}   ${prechart_values}   ${mainchart_values}    ${release_name}   ${ne_type}=vdu
    ...    ${clusterpreparation_values}=${EMPTY}
    [Documentation]  Creating plan in NOM for deploying or upgrading CNFS.
    ...    *Author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-5-22 | r3li | adapt new funcotion of cnf plan |
    ...    | 2022-7-4 | huilxu | add clusterpreparation_values parameter |
    ...    | Input Parameters | Man. | Description |
    ...    | plan_name        | yes  | the deploy or upgrade plan name |
    ...    | json_file_path   | yes | json file path for updating the empty plan |
    ...    | build_version    | yes | SW build version like 14.300.430 |
    ...    | mrbts_id         | yes | MRBTS ID |
    ...    | kubeconfig       | yes | kubeconfig string that encoded to base64 |
    ...    | image_registry   | yes | image registry by oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}' |
    ...    | image_registry_pwd | yes | image_registry_pwd by oc whoami -t |
    ...    | clusterpreparation_values   | yes | cluster preparation value-override yaml string encoded to base64 |
    ...    | prechart_values   | yes | prechart value-override yaml string encoded to base64 |
    ...    | mainchart_values  | yes | mainchart value-override yaml string encoded to base64 |
    ...    | release_name      | yes | the SW release version, like vDUCNF22R2 |
    ...    | ne_type           | yes | the ne type, vcu or vdu |
    ...    | plan_operation    | yes | CREATE for deloying cnfs, and UPDATE for upgrading cnfs |
    ...    *RETURN VALUE*
    ...    | the dict for updating the empty plan |
    ${json_content}   OperatingSystem.get file    ${json_path}
    ${dict_info}=  json.loads  ${json_content}
    ${managed_objects}   set variable    ${dict_info}[managedObjects][0]

    set_to_multiple_dictionary    ${managed_objects}    moId     CNF-${mrbts_id}
    ${plan_operation_list}    Split String     ${plan_operation}     _
    ${plan_operation}    Set Variable     ${plan_operation_list}[-1]
    set_to_multiple_dictionary    ${managed_objects}    planOperation     ${plan_operation}
    set_to_multiple_dictionary    ${managed_objects}    moClass.version   ${build_version}

    set_to_multiple_dictionary    ${managed_objects}    parameters.vim_details.kubeconfig    ${kubeconfig}

    set_to_multiple_dictionary    ${managed_objects}    parameters.vim_details.imageRegistry.addr    ${image_registry}
    set_to_multiple_dictionary    ${managed_objects}    parameters.vim_details.imageRegistry.credentials.password
    ...   ${image_registry_pwd}

    ${chart_info_1}    create dictionary   chart=aic-${ne_type}-cluster-preparation-${build_version}.tgz
    ...   releaseName=aic-${ne_type}-cluster-preparation   values=${clusterpreparation_values}   order=0

    ${chart_info_2}    create dictionary   chart=aic-${ne_type}-prerequisite-${build_version}.tgz
    ...   releaseName=aic-${ne_type}-prerequisite   values=${prechart_values}   order=1

    ${chart_info_3}    create dictionary   chart=aic-${ne_type}-${build_version}.tgz
    ...   releaseName=aic-${ne_type}   values=${mainchart_values}   order=2

    ${chart_infos}    create list    ${chart_info_1}    ${chart_info_2}  ${chart_info_3}
    set_to_multiple_dictionary    ${managed_objects}    parameters.deploymentProfile    ${chart_infos}
    set_to_multiple_dictionary    ${managed_objects}    parameters.cnfSwId   ${release_name}_${build_version}_SWPKG
    ${manage_object_list}    create List    ${managed_objects}
    ${manage_info_dict}    Create Dictionary      managedObjects=${manage_object_list}
    [Return]   ${manage_info_dict}

Get Rollback Plan Name
    [Arguments]  ${upgrade_plan_name}
    [Documentation]  get rollback plan name generated by upgrading operation
    ...    author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upgrade_plan_name | yes  | plan name that used to upgrade cnfs |
    ...    *RETURN VALUE*
    ...    | rollback plan name like 'upgrade_10700_cnfs_rollback_125566345' |
    ${all_plan_info}   nom_rest.get_plan_header_info   PLAN   ${None}
    ${all_plan_result}   set variable   ${all_plan_info}[result]
    FOR   ${plan}   IN    @{all_plan_result}
        ${rollback_plan_name}=   Set Variable If    '${upgrade_plan_name}_rollback_' in '${plan}[name]'  ${plan}[name]
        Exit For Loop If   '${upgrade_plan_name}_rollback_' in '${plan}[name]'
    END
    [Return]  ${rollback_plan_name}
