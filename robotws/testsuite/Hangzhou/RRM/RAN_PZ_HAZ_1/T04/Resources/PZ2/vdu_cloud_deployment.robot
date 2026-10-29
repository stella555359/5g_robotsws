*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_cloud_deployment.robot



*** Variables ***
${ns}    cran1

*** Keywords ***
Get vDU Releases Name List By Date
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Get VDU release name list by date
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    return release name list by date, i.e. ['preparation', 'prerequisite', 'vdu']
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  gnb_index=${gnb_index}  alias=${alias}
    ${cmd}  Set Variable  helm list -ad | awk '{print $1}' | tail -n +2
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${temp}  Strip Prompt  ${out}
    @{releases_name_list}=   Split To Lines   ${temp}
    [Return]    ${releases_name_list}
    [Teardown]    Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}

Make Sure vDU Pods Are Deleted
    [Arguments]    ${namespace}  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Deleting pods and jobs in vDU
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | namespace | yes | namespace |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    Success if pods and jobs are deleted
    ...    The keyword will be failed if pods still existed in vdu.
    ...
    vDU Cluster Login With Tenant    vdu_index=${vdu_index}  gnb_index=${gnb_index}
	${pods_name_list}=    get_vdu_pods_name_list   namespace=${namespace}
	Return from keyword if   "${pods_name_list}"=="${None}"  Success
	FOR  ${pod}  IN  @{pods_name_list}
	  ${cmd}=   set variable  kubectl delete pods ${pod} -n ${namespace}
	  helm.execute_command_on_master_cluster  cmd=${cmd}
	END
	${jobs_name_list}=  get_vdu_jobs_name_list  namespace=${namespace}
	Return from keyword if   "${jobs_name_list}"=="${None}"  Success
	FOR  ${job}  IN  @{jobs_name_list}
	  ${cmd}=   set variable  kubectl delete job ${job} -n ${namespace}
	  helm.execute_command_on_master_cluster  cmd=${cmd}
	END
	${pods_name_list}=    get_vdu_pods_name_list   namespace=${namespace}
	Should be True  "${pods_name_list}"=="${None}"
	[Return]   Success
	[Teardown]    run keyword and ignore error  helm.helm_master_close

Make Sure Release Is Deleted
    [Arguments]    ${ns}   ${release_name}
    ${cmd}=   Set Variable     helm list -n ${ns} -a |awk '$1 == "${release_name}" { print $1 }'
    ${res}=  helm.execute_command_on_master_cluster  cmd=${cmd}
    ${release_name}  Set Variable  ${res.stdout.strip()}
    should be empty   ${release_name}

Get vDU Pods Names
  [Arguments]    ${namespace}  ${vdu_index}=0  ${gnb_index}=0
  vDU Cluster Login With Tenant    vdu_index=${vdu_index}  gnb_index=${gnb_index}
  ${pods_name_list}=    get_vdu_pods_name_list   namespace=${namespace}
  [Return]  ${pods_name_list}
  [Teardown]  helm.helm_master_close


Undeploy vDU
  [Arguments]    ${vdu_index}=0  ${gnb_index}=0   ${login_account}=tenant
  [Documentation]   Uninstall vDU releases by release created reverse order.
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...    | login_account | no | core or tenant, default is tenant |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
  Log To Console  \n------------ Starting Undeploy vDU ----------
  ${ns}   Get vDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
  ${releases_name_list}=   Get vDU Releases Name List By Date    ${vdu_index}   ${gnb_index}
  ${status}  Run Keyword If  len(${releases_name_list})==0  Make Sure vDU Pods Are Deleted  namespace=${ns}
  ...  vdu_index=${vdu_index}  gnb_index=${gnb_index}
  Return from keyword if   "${status}"=="Success"

  Reverse List  ${releases_name_list}

  Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
  ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}

  FOR  ${release}  IN  @{releases_name_list}
    helm.helm_delete  release_name=${release}  namespace=${ns}
    Wait Until Keyword Succeeds  300   30s    Make Sure Release Is Deleted   ns=${ns}   release_name=${release}
  END

  Make Sure vDU Pods Are Deleted  namespace=${ns}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
  Log to console  \n------------ Finishing Undeploy vDU ----------
  [Teardown]    run keyword and ignore error  helm.helm_master_close


Get vDU Target Build Version From Agent Variable
    [Documentation]   Parsing environment variable CM_ARTIFACTS to get the vDU package version.
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...
    ...    *RETURN VALUE*
    ...    Return a tuple, i.e. ('vDUCNF00_0.300.15747', 'vDUCNF00', '0.300.15747')
    ...
    ${vdu_full_sw_version}    ${vcu_full_sw_version}   fetch_sw_version_from_cm_artifacts   %{CM_ARTIFACTS}
    @{vdu_build_number}    Split String   ${vdu_full_sw_version}   _
    [Return]    ${vdu_full_sw_version}   ${vdu_build_number[0]}   ${vdu_build_number[1]}

Get vDU Tenant Name
    [Arguments]    ${vdu_index}=0   ${gnb_index}=0
    ${tenant_ssh_conn_info}    get_k8s_tenant_ssh_connection_info    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    [Return]    ${tenant_ssh_conn_info}[username]

Prepare SW Package Path
    [Arguments]   ${build_number}  ${tenant_name}   ${vdu_index}=0   ${gnb_index}=0
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${fuzzy_name}   _Get Install Package Fuzzy Name   ${build_number}
    helm.execute_command_on_master_cluster    cd /var/home/${tenant_name};rm -rf ${fuzzy_name}
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    Set Test Variable   ${Target_Package_Path}    /var/home/${tenant_name}/${build_number}
    Set Test Variable  ${Target_Helm_Chart_Path}  /var/home/${tenant_name}/${build_number}/HelmChart
    Set Test Variable   ${Target_Image_Path}   /var/home/${tenant_name}/${build_number}/Image
    Set Test Variable   ${Target_OnBoardingAPP_Path}   /var/home/${tenant_name}/${build_number}/Image/onBoardingApp

    [Teardown]    Run Keyword And Ignore Error  helm.helm_master_close

Download And Decompress New Vdu Package
    [Arguments]     ${package_prefix}   ${build_number}   ${vdu_index}=0  ${gnb_index}=0
    Log To Console   \n------------ Start to downloand and decompress new vdu package ------------
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm_download_cnf_package    target_path=${Target_Package_Path}   package_name=${package_prefix}
    ...  package_version=${build_number}  repository=${PACKAGE_LINK}
    ${prerequisite_build_number}    _Get Prerequisite Build Number From Manifest   ${target_package_path}
    ${cluster-preparation_build_number}    _Get Cluster Preparation Build Number From Manifest    ${target_package_path}
    helm.execute_command_on_master_cluster
    ...  cd ${Target_Helm_Chart_Path};tar -xzvf aic-vdu-${build_number}.tgz;
    helm.execute_command_on_master_cluster
    ...  cd ${Target_Helm_Chart_Path};tar -xzvf aic-vdu-prerequisite-${prerequisite_build_number}.tgz
    helm.execute_command_on_master_cluster
    ...  cd ${Target_Helm_Chart_Path};tar -xzvf aic-vdu-cluster-preparation-${cluster-preparation_build_number}.tgz
    Log To Console   \n------------ Downloand and decompress new vdu package successful ------------
    [Teardown]    Run Keyword And Ignore Error  helm.helm_master_close

Onboard Images
    [Arguments]    ${full_sw_version}  ${namespace}   ${vdu_index}=0  ${gnb_index}=0
    Log To Console   \n------------ Start to onboarding docker images ------------
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.download_onboard_app_tool    target_path=${Target_Image_Path}    chart_version=${full_sw_version}
    helm.execute_command_on_master_cluster
    ...    cp ${Target_OnBoardingAPP_Path}/loadImages.sh ${Target_Image_Path}
    helm.execute_command_on_master_cluster
    ...    cp ${Target_OnBoardingAPP_Path}/images.properties* ${Target_Image_Path}
    helm.execute_command_on_master_cluster    cd ${Target_Image_Path};chmod 777 *;./loadImages.sh -n ${namespace}
    Log To Console   \n------------ Onboarding images finished ------------
    [Teardown]    Run Keyword And Ignore Error   helm.helm_master_close


Fetch Values Override Files From TL Config
    [Arguments]    ${vdu_index}=0   ${gnb_index}=0
    log to console
    ...  \n*------------ Values Override Files can't be fetched from S3, now fetching them from TL configuration ------------
    ${tl_config_dir}   Get TestLine Config Folder Name   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${preparation_yaml_file}   OperatingSystem.Join Path    ${tl_config_dir}   vdu-cluster-preparation.yaml
    ${prerequisite_yaml_file}   OperatingSystem.Join Path    ${tl_config_dir}   vdu-prerequisite.yaml
    ${vdu_cnf_yaml_file}   OperatingSystem.Join Path    ${tl_config_dir}   vdu-cnf.yaml
    [Return]    ${preparation_yaml_file}  ${prerequisite_yaml_file}  ${vdu_cnf_yaml_file}

Fetch Values Override Files From OE
    [Arguments]    ${namespace}   ${vdu_index}=0    ${gnb_index}=0
    vDU Cluster Login With Tenant    vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}=  Get Values-Override From Target OE  ${namespace}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  vdu_index=${vdu_index}  gnb_index=${gnb_index}  alias=${alias}
    issh.Download File   remote_path=${vdu_values_path}    local_path=/tmp/aic_vdu_yaml.yaml   alias=${alias}
    issh.Download File   remote_path=${prerequisite_values_path}    local_path=/tmp/aic_prerequisite_yaml.yaml  alias=${alias}
    issh.Download File   remote_path=${cluster_values_path}    local_path=/tmp/aic_cluster_preparation_yaml.yaml   alias=${alias}
    [Teardown]    Run Keywords  Run Keyword And Ignore Error   helm.helm_master_close  AND
    ...  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Return]  /tmp/aic_cluster_preparation_yaml.yaml  /tmp/aic_prerequisite_yaml.yaml  /tmp/aic_vdu_yaml.yaml

Fetch Values Override Files
    [Arguments]    ${tl_name}   ${build_number}   ${namespace}  ${vdu_index}=0   ${gnb_index}=0
    ${status}   ${res}   fetch_values_overrides_yaml_from_s3     ${tl_name}   ${build_number}   ${vdu_index}
    ${cluster_preparation_values_path}   ${prerequisite_values_path}   ${vdu_values_path}   Run Keyword If
    ...  "${status}"=="True"  set variable  ${res}
    ...  ELSE  Fetch Values Override Files From OE  namespace=${namespace}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    [Return]    ${cluster_preparation_values_path}   ${prerequisite_values_path}   ${vdu_values_path}

Update CNF Values Override YAML File
    [Arguments]    ${cnf_values_override_yaml}   ${prerequisite_values_overrids_yaml}   &{updated_param_dict}
    FOR  ${p_name}  IN  @{updated_param_dict}
      Run Keyword If  "${p_name}"!="restoreData"  yaml_modify_content    file_path=${cnf_values_override_yaml}   key=global
      ...  modify_content=${updated_param_dict}[${p_name}]  child_key=${p_name}   ELSE
      ...  yaml_modify_content    file_path=${prerequisite_values_overrids_yaml}   key=global
      ...  modify_content=${updated_param_dict}[${p_name}]  child_key=${p_name}
    END

Upload Values Override YAML To OE
    [Arguments]    ${values_override_yaml_list}
    ${values_override_yaml_files_list}   create list
    ${alias_cp}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias_cp}
    FOR  ${yaml_file}  IN   @{values_override_yaml_list}
      ${path}   ${file_name}     OperatingSystem.split_path    ${yaml_file}
      issh.Upload File   local_path=${yaml_file}   remote_path=${Target_Helm_Chart_Path}/${file_name}   alias=${alias_cp}
      append to list  ${values_override_yaml_files_list}  ${file_name}
    END
    [Return]  ${values_override_yaml_files_list}
    [Teardown]    Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias_cp}

Deploy vDU
    [Arguments]   ${full_sw_version}=${None}   ${local_vdu_yaml_path}=${None}
    ...  ${local_prerequisite_yaml_path}=${None}   ${local_cluster_preparation_path}=${None}
    ...  ${vdu_index}=0  ${gnb_index}=0   &{updated_params_dict}
    [Documentation]   Deploy vDU by tenant user.
    ...
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | total_pod_number | Yes | target pods number after deloyment, it should be set in case setup |
    ...    | full_sw_version | No | SW package needs to be deloyed, if not passed, it will be fetched from CM_ARTIFACTS.
    ...                             i.e. vDUCNF00_0.300.15747 |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...    | updated_params_dict | no | parameters need to be updated in value overrides yaml, passed by key=value |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    *Example*
    ...    | Deploy vDU | total_pod_number=30 | full_sw_version=vDUCNF00_0.300.15747 | cnfLayout=DRAN | upInstanceCount=${1}|
    ...
    ${ns}   Get vDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${tenant_name}=   Get vDU Tenant Name   ${vdu_index}  ${gnb_index}
    ${tl_name}    Get TestLine Name From TestLine
    ${vdu_full_sw_version}   ${vdu_package_prefix}   ${build_number}   Run Keyword If   "${full_sw_version}"=="None"
    ...  Get vDU Target Build Version From Agent Variable
    ...   ELSE   Set Variable   ${full_sw_version}    ${full_sw_version.split('_')[0]}    ${full_sw_version.split('_')[1]}
    Prepare SW Package Path   build_number=${build_number}    tenant_name=${tenant_name}
    ...  vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${Is_IPv6}    Check If vDU Host Is IPv6
    Run Keyword If   ${Is_IPv6}  helm.enable_proxy_for_pure_ipv6

    Download And Decompress New Vdu Package   package_prefix=${vdu_package_prefix}   build_number=${build_number}
    ...  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    Onboard Images   full_sw_version=${vdu_full_sw_version}    namespace=${ns}   vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${status}  ${local_cluster_preparation_path}   ${local_prerequisite_yaml_path}   ${local_vdu_yaml_path}    Run keyword if
     ...  "${local_vdu_yaml_path}"=="${None}" or "${local_prerequisite_yaml_path}"=="${None}" or "${local_cluster_preparation_path}"=="${None}"
     ...  fetch_values_overrides_yaml_from_s3   tl_name=${tl_name}  build_number=${build_number}    vdu_index=${vdu_index}
     ...  ELSE  Set Variable  ${None}  ${local_cluster_preparation_path}  ${local_prerequisite_yaml_path}  ${local_vdu_yaml_path}

    run keyword if  ${updated_params_dict}  Update CNF Values Override YAML File
    ...  ${local_vdu_yaml_path}   ${local_prerequisite_yaml_path}   &{updated_params_dict}

    ${values_override_yaml_list}   create list   ${local_cluster_preparation_path}   ${local_prerequisite_yaml_path}   ${local_vdu_yaml_path}
    ${cluster_preparation_yaml}  ${rerequisite_yaml}  ${vdu_yaml}  Upload Values Override YAML To OE   ${values_override_yaml_list}

    Create Preparation and Verify Preparation creation
    ...    remote_dst_file=${Target_Helm_Chart_Path}/${cluster_preparation_yaml}
    ...    login_account=${tenant_name}
    ...    remote_dst_path=${Target_Helm_Chart_Path}/aic-vdu-cluster-preparation
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create Prerequisite and Verify Prerequisite creation
    ...    remote_dst_file=${Target_Helm_Chart_Path}/${rerequisite_yaml}
    ...    login_account=${tenant_name}
    ...    remote_dst_path=${Target_Helm_Chart_Path}/aic-vdu-prerequisite
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create VDU and Verify VDU creation
    ...    remote_dst_file=${Target_Helm_Chart_Path}/${vdu_yaml}
    ...    login_account=${tenant_name}
    ...    remote_dst_path=${Target_Helm_Chart_Path}/aic-vdu
    ...    helm_cmd=helm



Get Current vDU Version
    [Arguments]    ${vdu_index}=0   ${login_account}=core
    [Documentation]  get current vDU version
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    #${result}=    helm.Execute Command On Master Cluster    helm list -n ${ns} |grep vdu |awk '{print $9}'
    ${result}=    helm.Execute Command On Master Cluster
    ...   helm list -n ${ns} |egrep "aic-vdu-[0-9]+\.[0-9]+\.[0-9]+"|awk '{print $9}'
    log    ${result.stdout}
    ${vdu_current_version1}=    Convert To String    ${result.stdout}
    ${vdu_current_version2}=    Strip String    ${vdu_current_version1}
    @{vdu_current_version3}=    Split String    ${vdu_current_version2}    -
    ${vdu_current_version}=    Set Variable    ${vdu_current_version3[-1]}
    [Return]    ${vdu_current_version}


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

Get VDU Release Name
    [Arguments]     ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Get VDU release name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   10.3.2023,chris.l.cao@nokia-sbell.com, remove NCIR code branch
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu release name, e.g, 'vdu' for environment deployed by jenkins agent.
    ...       or 'vdutest' for deployment by kuafu.
    ...
    ...    Example
    ...    | ${vdu_release_name} | Get VDU release name |
    ...
    ${release_name}     _Get VDU Release Name NCS   vdu_index=${vdu_index}  gnb_index=${gnb_index}

    [Return]  ${release_name}


_Get VDU Release Name NCS
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   _Get VDU release name NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.8.2021,chris.l.cao@nokia-sbell.com, exclude prerequisite for latest vdu software
    ...   10.3.2023,chris.l.cao@nokia-sbell.com, change from admin to tenant
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
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
#    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${out}  issh.Execute
     ...  command=helm list -n ${ns}|grep aic-vdu-|grep -v prerequisite|grep -v rbac|grep -v preparation|awk '{print $1}'
     ...  alias=${alias}
    ${release_name}  Strip Prompt  ${out}
    ${release_name}    Set Variable    ${release_name.replace("\x1b[?2004l\r","")}
    ${tmp_list}  Split To Lines   ${release_name}
    ${tmp_list_length}   Get Length    ${tmp_list}
    Should Be True    ${tmp_list_length}==1

    [Return]  ${release_name}


Get VDU Build Prefix
    [Arguments]    ${gnb_index}=0  ${vdu_index}=0
    [Documentation]   Get VDU Build Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default value is 0  |
    ...    | vdu_index | no | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    return vDUCNF, vDUCNF22R4, etc.
    ...
    ...    Example
    ...
    ...    | ${build_prefix} | Get VDU Build Prefix |
    ...    | ${build_prefix} | Get VDU Build Prefix | vdu_index=0 |
    ...
    ${build_number}   Get Running Build Number   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${build_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}

    [Return]   ${build_prefix}


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
    ${cmd}   Set Variable  kubectl get pods -n ${ns}
    ${cmd}   Set Variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    #${cmd}   Run Keyword If   "${pod_abbr}"!="securestorage"    Set Variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'
    #...   ELSE  Set Variable  ${cmd}|egrep "(${pod_abbr})" |awk '{print $1}'

    ${full_pod_name}   tafssh.Execute    command=${cmd}   connection=${connection}
    ${full_pod_name}   Set Variable  ${full_pod_name.strip()}
    [Return]  ${full_pod_name}


Get Pod Abbreviation By Container Abbreviation
    [Arguments]    ${container_abbr}=oamfh  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Pod Abbreviation By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   15.12.2021,chris.l.cao@nokia-sbell.com, Fix problem that some PODs have multiple containers whose name are simular,
    ...                                e.g, in oamconfig pod, there are two containers oamconfig and appsecretinitoamconfig.
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container_abbr, eg, oamfh, l1hi |
    ...
    ...    *RETURN VALUE*
    ...    pod abbreviation, e.g, oam, cprt, up.
    ...
    ...    Example
    ...    | ${pod_abbr} | Get Pod Abbreviation By Container Abbreviation | container_abbr=oamfh |
    ...
    ${container_prefix}  Get Container Name Prefix  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${start_with_prefix}   Set Variable  ${container_abbr.startswith("${container_prefix}")}
    ${container_abbr}  Run Keyword If   "${start_with_prefix}"=="${True}"   Set Variable  ${container_abbr.replace("${container_prefix}","")}
        ...   ELSE   Set Variable    ${container_abbr}

    ${pod_keys}   Evaluate    list(${AIC_VDU_PODS})

    ${pod_abbr}   Set Variable   ${EMPTY}
    FOR   ${pod}  IN   @{pod_keys}
#       ${containers_list}    Set Variable    ${AIC_VDU_PODS["${pod}"]}
#       ${number}   count_string_in_list   ${containers_list}    ${container_abbr}
        ${containers_list}    Set Variable    ${AIC_VDU_PODS_CONTAINER_ABBR["${pod}"]}
        ${number}   Collections.Count Values In List   ${containers_list}    ${container_abbr}
        Run Keyword If   ${number}>=2   Fail   There are two container whose names are same !
        Return From Keyword If   ${number}==1   ${pod}
    END
    [Return]  ${pod_abbr}


Get Full Pod Name By Pod Abbreviation Interactively
    [Arguments]  ${pod_abbr}  ${alias}=default  ${vdu_index}=0  ${gnb_index}=0  ${pod_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...    24.4.2022,hongysun, add pod_index parameter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | pod_index         | No | default is 0, e.g: if up-1, pod_index=1 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 |
    ...    | disconnect interactive connection |
    ...
    ...    | ${alias} | get_unique_id |
    ...    | Connect To K8s Master Interactively | alias=${alias} |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | alias=${alias} |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | pod_index=1 | alias=${alias} |
    ...    | disconnect interactive connection | alias=${alias} |
    ...
    Log    ${vdu_index}
    Log    ${gnb_index}
    #${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${ns}    Set Variable     cran1
    ${cmd}   Set Variable  kubectl get pods -n ${ns}

    ${out}   issh.Execute   command=${cmd}   alias=${alias}
    Should Be True   "No resources found" not in """${out}"""

    ${cmd}   Set Variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   Strip Prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    ${full_pod_name_tmp}  Get Regexp Matches  ${full_pod_name}  po-${ns}-${pod_abbr}-${pod_index}
    ${full_pod_name}  Set Variable If  ${full_pod_name_tmp}!=[]  ${full_pod_name_tmp}[0]
    ...  ${full_pod_name}
    [Return]  ${full_pod_name}


Get Full Pod Name By Pod Abbreviation Interactively In Python
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0   ${pod_index}=${EMPTY}
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively In Python
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <05-06-2022>, <lingtsun>, <add pod_index for cran multi-pod>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...  modified by:       <24-04-2023>, <r3li>, <update for multi pods has same abbr>
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
    ...    |  ${alias} |  Get Unique Id |
    ...    | fast_connect_to_k8s_master |   alias=${alias} |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | fast_disconnect  alias=${alias}
    ...

    ${command}  Set Variable  kubectl get pod

    ${out}  fast_execute   command=${command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    Should Be True   "No resources found" not in """${out}"""

    ${with_pipeline_command}  Set Variable  |egrep "(-${pod_abbr}-${pod_index})" |awk '{print $1}'
    ${full_pod_name}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${full_pod_list}    Split String   ${full_pod_name}   \n
    [Return]  ${full_pod_list}


Get Full Pod Name By Container Abbreviation Interactively
    [Arguments]    ${container_abbr}     ${vdu_index}=0     ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_tmp}
    [Documentation]   Get Full Pod Name By Container Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container name appreviation, eg, oamfh, l1hi |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | ${full_pod_name} | Get Full Pod Name By Container Abbreviation Interactively | container_abbr=oamfh |
    ...
    Run Keyword If   "${container_abbr}"=="nwmgmt"   Fail  This KW can't be used for container nwmgmt !

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${alias_tmp}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias_tmp}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively
    ...   pod_abbr=${pod_abbr}   alias=${alias_tmp}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${full_pod_name}

Get Full Container Name By Container Abbreviation
    [Arguments]    ${ctr_abbr}       ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Get Full Container Name By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
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
    #\   Return From Keyword If   "${ctr_abbr}"=="${ctr}"   ${ctr_abbr}

    ${container_prefix}  Get Container Name Prefix   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${start_with_prefix}   Set Variable  ${ctr_abbr.startswith("${container_prefix}")}
    Return From Keyword If   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${full_ctr_name}   Set Variable  ${container_prefix}${ctr_abbr}
    [Return]  ${full_ctr_name}

_Get CNF Release Values With Json Format
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error  fast_disconnect  alias=${alias}
    ${alias}  Get Unique Id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${cmd}   set variable   helm list
    ${with_pipeline_command}  set variable  | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release_name}  fast_execute  command=${cmd}   with_pipeline_command=${with_pipeline_command}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${cnf_release_name}    Set Variable    ${cnf_release_name.strip().replace("\x1b[?2004l\r","")}
    ${cmd}=  set variable  helm get values ${cnf_release_name} -o json
    ${response}  fast_execute  command=${cmd}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    [Return]    ${response}

Get Pod Name Prefix
    [Arguments]     ${vdu_index}=0
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
    Log    ${vdu_index}
    ${r}  ${out}  Run Keyword And Ignore Error   Set Variable   ${_G_POD_PREFIX}
    Return From Keyword If  "${r}"=="PASS"   ${_G_POD_PREFIX}

    ${_G_POD_PREFIX}   _Get Pod Name Prefix Internal Use
    Set Suite Variable   ${_G_POD_PREFIX}

    [Return]  ${_G_POD_PREFIX}


_Get Pod Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
    [Documentation]   _Get Pod Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*:
    ...    | date | who |what and how |
    ...    | 14.8.2021 | chris.l.cao@nokia-sbell.com | change from tenant to admin account to adapt OCP |
    ...    | 15.7.2022 | lingting.sun@nokia-sbell.com| adaption for multi gnb |
    ...    | 23.12.2022 | rui.3.li@nokia-sbell.com | adaption for multi pod |
    ...    *Argument Description*
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...
    ...    *Example*
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use |
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use | vdu_index=0 |
    ...
    ${ns}   get_vdu_namespace_from_testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${cnf_release_value_json_format}  _Get CNF Release Values With Json Format   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_prefix}=   parse_name_convention_from_json_cnf_release_values   ${cnf_release_value_json_format}  ${ns}  pod_prefix
    [Return]    ${pod_prefix}


Get Container Name Prefix
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 15.7.2022,lingting.sun@nokia-sbell.com, adaption for multi gnb
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...
    ...    *Example*
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    ...
#    ${r}  ${out}  Run Keyword And Ignore Error   Set Variable   ${_G_CONTAINER_PREFIX}
#    Return From Keyword If  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Set Suite Variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}


_Get Container Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *History Change*
    ...    | date | who | what and how |
    ...    | 14.8.2021 | chris.l.cao@nokia-sbell.com | change from tenant to admin account to adapt OCP |
    ...    | 15.7.2022 | lingting.sun@nokia-sbell.com| adaption for multi gnb |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    *Example*
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ...

    #${ns}   get_vdu_namespace_from_testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${cnf_release_value_json_format}  _Get CNF Release Values With Json Format   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${container_prefix}=   parse_name_convention_from_json_cnf_release_values
    ...    ${cnf_release_value_json_format.replace("\x1b[?2004l\r","")}  ${ns}  container_prefix
    [Return]    ${container_prefix}


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
    ${tmp_current_build_number}   Get Running Build Number   vdu_index=${vdu_index}
    [Return]  ${tmp_current_build_number}


Construct VDU Scf File Name
    [Arguments]  ${build_number}=None
    ${build_number}   Run Keyword If   '${build_number}'=='None'   Get Current vDU Version
    ...   ELSE   Set Variable   ${build_number}
    ${sub_number_list}   Set Variable   ${build_number.split(".")}
    # vDU_SCF_0.300.xml
    ${scf_file_name}   Set Variable   vDU_SCF_${sub_number_list[0]}.${sub_number_list[1]}.xml
    [Return]    ${scf_file_name}


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
    Log To Console  Clear Agent Flag...
    ${agent_flag_file}   OperatingSystem.Join Path   ${RESULT_DIR}   agent_flag.txt
    Initialize Agent Flag File   agent_flag_file=${agent_flag_file}


Initialize Agent Flag File
    [Arguments]  ${agent_flag_file}
    [Teardown]  Run Keyword And Ignore Error  disconnect interactive connection  alias=${alias}
    ${alias}   Get Unique Id
    Connect To UTE Locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    ${out}   Run Keyword If  "${found}"=="${True}"   issh.Execute   command=cat ${agent_flag_file}   alias=${alias}
    Return From Keyword If  "${found}"=="${True}"

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
    ${redeploy_flag}   Set Variable    ${False}

    ${r}  ${out}   Run Keyword And Ignore Error   OAM Precondition Cell Should Be Onair
    Log To Console  OAM Precondition Cell Should Be Onair:${r}
    Return From Keyword If  "${r}"!="PASS"   ${True}

    ${r}  ${out}   Run Keyword And Ignore Error   Should Have Power On All RUs
    Log To Console  Should Have Power On All RUs:${r}
    Return From Keyword If  "${r}"!="PASS"   ${True}

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
     Return From Keyword If   "${r}"=="PASS"   JENKINS

     ${a}   OperatingSystem.Run   ls -l /opt/ute/agent_env_py3/bin/activate
     Return From Keyword If   "No such file or directory" not in """${a}"""    JENKINS

     [Return]  UTE_CLOUD


Get Ruproxy Container ID
    [Arguments]   ${ru_index}=1  ${alias}=default
    [Documentation]   Get Ruproxy Container ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    modified by:       <10-14-2021>, <hongysun>, <initial created>
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
    ${cmd}    Set Variable   docker ps |grep -v POD|grep ruproxy-${ru_index}|awk '{print $1}'
    ${out}   issh.execute  command=${cmd}  alias=${alias}
    ${lines}   split to lines  ${out}
    ${container_id}   Set Variable If  ${lines.__len__()}>=2   ${lines[1]}   ${EMPTY}
    [Return]  ${container_id}


UnDeploy Default vDU For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default vDU For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-2-21 | yun.1.wang | init create |
    ...    | 2023-8-23 | chris.l.cao | remove sleep  2min to speed up debug work |
    ...    | 2023-8-24 | dan.1.li | no need to delete chart if chart name is empty |
    ...    | 2023-11-1 | chris.l.cao | delete pod force for remained pods, add NEED_SECOND_DEPLOY |
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default vDU For NCS |
    ...
    ${vdu_chart_name}   Get Chart Name    chart_name=vdu   login_account=${login_account}
    Run Keyword If    "${vdu_chart_name}"=="${EMPTY}"    Run Keywords
    ...    Wait Until Keyword Succeeds    300    30s    _Make Sure Pod Is Deleted
    ...    AND    Return from keyword
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_delete    ${vdu_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  300   30s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=vdu
    ...   ns=${ns}   login_account=${login_account}

    ${r}  ${out}   Run Keyword And Ignore Error   Wait Until Keyword Succeeds   300  30s  _Make Sure Pod Is Deleted

    Run Keyword If  "${r}"=="FAIL"   Delete Pod Force
    Run Keyword If  "${r}"=="FAIL"   Set Test Variable   ${NEED_SECOND_DEPLOY}   1
    Run Keyword If  "${r}"=="FAIL"   Fail   Failed to delete pod!!!

    [Teardown]    Run Keyword And Ignore Error  helm.helm_master_close


Need Second Deploy
    [Documentation]   Need Second Deploy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${need_second_deploy}  |  Need Second Deploy |
    ...    | Run Keyword If | ${need_second_deploy}==1  |  My Second Deploy   |
    ...
    ${r}   ${value}  Run Keyword And Ignore Error   Set Variable   ${NEED_SECOND_DEPLOY}
    Return From Keyword If   "${r}"=="FAIL"   0
    [Return]   ${value}


Delete Pod Force
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection   alias=${alias}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}

    ${out}   issh.Execute  command=oc get pod|awk '{print $1}'|grep -v NAME  alias=${alias}
    ${pods}  Strip Prompt  content=${out}  return_list=${True}
    FOR   ${pod}  IN  @{pods}
        Log To Console  ${pod}
        issh.execute   command=oc delete pod ${pod} --force   alias=${alias}
    END

    Wait Until Keyword Succeeds   300  30s  _Make Sure Pod Is Deleted


_Make Sure Pod Is Deleted
    ${pods_info}=    vDU Get Pods Full Info
    Should Be Empty  ${pods_info}


Delete Pod
    [Arguments]   ${pod_abbr}    ${pod_index}=0
    [Teardown]  Run Keyword And Ignore Error    issh.disconnect   alias=${alias}
    [Documentation]   Delete Pod
    ...    author: chris.l.cao@nokia-sbell.com
    ...   Change History
    ...   20.3.2024,  chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr   |  yes | pod abbreviation, e.g, l2rt|
    ...    | pod_index  |  no  | pod index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete Pod | pod_abbr=l2rt |
    ...    | Delete Pod | pod_abbr=l2rt | pod_index=1 |
    ...    | Delete Pod | pod_abbr=ahm |  pod_index=0 |
    ...    | Delete Pod | pod_abbr=ahm |  pod_index=1 |
    ...
    ${pod_prefix}   Get Pod Name Prefix
    ${alias}  get_unique_id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${full_pod_name}   Set Variable   ${pod_prefix}${pod_abbr}-${pod_index}
    ${cmd}   Set Variable  oc delete pod ${full_pod_name}
    issh.Execute    command=${cmd}  check_result=${False}   alias=${alias}


UnDeploy Default Prerequisite For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default Prerequisite For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2023-8-24 | dan.1.li | no need to delete chart if chart name is empty |
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default Prerequisite For OCP |
    ...
    ${prerequisite_chart_name}  Get Chart Name  chart_name=prerequisite   login_account=${login_account}
    Return From Keyword If    "${prerequisite_chart_name}"=="${EMPTY}"
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_delete    ${prerequisite_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  120   10s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=${prerequisite_chart_name}
    ...   ns=${ns}   login_account=${login_account}
    [Teardown]    Run Keyword And Ignore Error  helm.helm_master_close

UnDeploy Default Preparation For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]   UnDeploy Default Preparation For OCP
    ...   *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2023-8-24 | dan.1.li | no need to delete chart if chart name is empty |
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | UnDeploy Default Preparation For OCP |
    ...
    ${preparation_chart_name}  Get Chart Name  chart_name=preparation   login_account=${login_account}
    Return From Keyword If    "${preparation_chart_name}"=="${EMPTY}"
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_delete    ${preparation_chart_name}  ${ns}  helm_cmd=helm
    Wait Until Keyword Succeeds  120   10s    Make Sure Chart Is Deleted   vdu_index=${vdu_index}  chart_name=${preparation_chart_name}
    ...   ns=${ns}   login_account=${login_account}
    [Teardown]    Run Keyword And Ignore Error  helm.helm_master_close

Make Sure Chart Is Deleted
    [Arguments]     ${chart_name}    ${vdu_index}=0    ${ns}=cran1    ${login_account}=core
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Make Sure Chart Is Deleted
    ...   *AUTHOR* sophie.jiang@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-2-22 | sophie.jiang | init create |
    ...    | 2023-8-23 | chris.l.cao | need not assert if there is no chart release |
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Make Sure Chart Is Deleted |
    ...
    Log    ${vdu_index}
    Log    ${ns}
    ${chart_release_name}    Get Chart Name  chart_name=${chart_name}   login_account=${login_account}
    Run Keyword If   ${chart_release_name.__len__()}>0
    ...   should not contain  ${chart_release_name}   ${chart_name}


Get Chart Name
    [Arguments]     ${chart_name}    ${gnb_index}=0   ${vdu_index}=0   ${login_account}=core
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Chart Name
    ...   *AUTHOR* sophie.jiang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Get Prerequisite Name |
    ...
    ${platform_name}   Set Variable    OCP
    ${helm_name}    Set Variable If   "${platform_name}"=="NCS"  helm3    helm
    ${grep_name}    Set Variable If   "${chart_name}"=="vdu"  aic-vdu-[0-9]
    ...  "${chart_name}"=="prerequisite"   aic-vdu-prerequisite
    ...  "${chart_name}"=="preparation"  aic-vdu-cluster
    ${alias}  Get Unique Id
    Run Keyword If     "${login_account}"=="core"
    ...   Connect To K8s Master Interactively   vdu_index=${vdu_index}  gnb_index=${gnb_index}   alias=${alias}
    ...   ELSE   Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  gnb_index=${gnb_index}  alias=${alias}
    ${ns}   get vdu namespace from testline   vdu_index=${vdu_index}
    ${cmd}=   Set Variable     ${helm_name} list -n ${ns}|grep ${grep_name} |grep -v rbac|awk '{print $1}'
    Log To Console  ${cmd}
    ${out}  issh.Execute    command=${cmd}   alias=${alias}
    Log To Console  ${out}
    ${release_name}  Strip Prompt  ${out}
    ${tmp_list}  Split To Lines   ${release_name}
    ${tmp_list_length}   Get Length    ${tmp_list}

    [Return]  ${release_name}


Upload Image
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0  ${build_number}=0.300.903  ${namespace}=cran1  ${la}=core
    [Documentation]    Do some common thing for every postcondition of cases
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   17.1.2024,chris.l.cao@nokia-sbell.com, will not onboard image if it already onboarded
    ...
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Upload Image | build_number=0.300.800|
    ${images_are_onboarded_flag}   Get Images Onboard Flag   build_number=${build_number}    login_account=${la}
    Return From Keyword If   "${images_are_onboarded_flag}"=="${True}"

    Run Keyword If     "${la}"=="core"   vDU Cluster Login With Admin    ${vdu_index}  ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${Is_IPv6}    Check If vDU Host Is IPv6    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Run Keyword If  "${Is_IPv6}"=="${True}"    helm.enable_proxy_for_pure_ipv6

    ${package_prefix}    Get Package Prefix From Global Variables File    ${build_number}
    ${full_package_name}    Set Variable    ${package_prefix}_${build_number}
    helm.download_onboard_app_tool    target_path=/var/home/${la}/${build_number}/Image    chart_version=${full_package_name}
    helm.execute_command_on_master_cluster
    ...    cp /var/home/${la}/${build_number}/Image/onBoardingApp/loadImages.sh /var/home/${la}/${build_number}/Image/
    helm.execute_command_on_master_cluster
    ...    cp /var/home/${la}/${build_number}/Image/onBoardingApp/images.properties* /var/home/${la}/${build_number}/Image/
    Log To Console   Begin to upload image ...
    helm.execute_command_on_master_cluster    cd /var/home/${la}/${build_number}/Image;chmod 777 *;./loadImages.sh -n ${namespace}
    Log To Console    Upload images done

    helm.execute_command_on_master_cluster    touch /var/home/${la}/${build_number}/images_are_onboarded

    [Teardown]   Run Keywords   helm.disable_proxy_for_pure_ipv6   AND   helm.helm_master_close


Get Images Onboard Flag
    [Arguments]   ${build_number}    ${login_account}=core
    [Documentation]    Return ${True} if VDU images are already onboarded, otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   17.1.2024,chris.l.cao@nokia-sbell.com, will not download package if it exists
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number  |  no | build_number, eg, 0.300.16654 |
    ...    | login_account  |  no | login_account, default is core |
    ...
    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...    | ${images_are_onboarded_flag} | Get Images Onboard Flag | build_number=0.300.16654 | login_account=cranuser1 |
    ...
    [Teardown]  issh.disconnect    alias=${alias}
    ${alias}   get_unique_id
    Run Keyword If   "${login_account}"=="core"   Connect To K8s Master Interactively   alias=${alias}
    ...    ELSE   Connect To K8s Master With Tenant Interactively    alias=${alias}
    ${file_exist}   issh.is_file   path=/var/home/${login_account}/${build_number}/images_are_onboarded    alias=${alias}
    [Return]  ${file_exist}


Create Preparation and Verify Preparation creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu-cluster-preparation   ${fail_on_error}=false  ${helm_cmd}=helm
    [Documentation]    Create Preparation and Verify Preparation creation
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
    ...    | Create Preparation and Verify Preparation creation | remote_dst_file=values-override.yaml |
    ...     remote_dst_path=home/core/aic-vdu |
    Log    ${fail_on_error}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${preparation_release_name}   Get Preparation Release Name From Testline  ${gnb_index}  ${vdu_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   release_name=${preparation_release_name}
    ...   chart_path=${remote_dst_path}
    ...   namespace=${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    \n------------ Deploy Cluster Preparation done ------------    console=true
    [Teardown]    helm.helm_master_close


Create Prerequisite and Verify Prerequisite creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu-prerequisite   ${fail_on_error}=false  ${helm_cmd}=helm
    [Documentation]    Create Prerequisite and Verify Prerequisite creation
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
    ...    | Create Prerequisite and Verify Prerequisite creation | remote_dst_file=values-override.yaml |
    ...     remote_dst_path=home/core/aic-vdu |
    Log    ${fail_on_error}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${pre_release_name}   Get Prerequisite Release Name From Testline  ${gnb_index}  ${vdu_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   ${pre_release_name}
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    \n------------ Deloy Prerequisite done ------------    console=true
    [Teardown]    helm.helm_master_close


Create VDU and Verify VDU creation
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${remote_dst_file}=values-override.yaml   ${login_account}=core
    ...   ${remote_dst_path}=/home/core/HelmChart/aic-vdu   ${timeout}=${900}  ${pod_number}=21  ${helm_cmd}=helm
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
    ...    | Create VDU and Verify VDU creation | remote_dst_file=values-override.yaml | remote_dst_path=home/core/aic-vdu |
    ...
    Log    ${timeout}
    Log    ${pod_number}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}   ${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    helm.helm3_install
    ...   vdu
    ...   ${remote_dst_path}
    ...   ${ns}
    ...   value_files=${remote_dst_file}
    ...   helm_cmd=${helm_cmd}
    log    \n------------ Deloy vDU done ------------   console=true
    [Teardown]    helm.helm_master_close

Deploy VDU For OCP
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${build_number}=None  ${login_account}=core   ${pod_number}=21
    ...   ${cluster_values_path}=None    ${prerequisite_values_path}=None    ${vdu_values_path}=None
    [Documentation]    Download vdu zip file and upload images and create intnet,pvc,vdu
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    *RETURN VALUE*
    ...    None
    ...    |2022.6.23 jianlin.zhang@nokia-sbell.com update the kw to adaption for CRAN tenant login |
    ...    |2022.11.4 jinbo.yu@nokia-sbell.com use values-override.yaml from current helm release |
    ...
    ...    Example
    ...    | Deploy VDU For OCP | build_number=0.300.903 |
    ...
    ${build_number}   Run Keyword If   '${build_number}'=='None'  Get Current vDU Version   ${login_account}
    ...   ELSE   Set Variable   ${build_number}
    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${ns}  Get VDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    ${output}=    helm.execute_command_on_master_cluster    test -d /var/home/${login_account}/${build_number}
    Clean Old Releases And Download New Vdu Package  ${build_number}   ${login_account}
    Upload Image   build_number=${build_number}  namespace=${ns}    la=${login_account}

    ${knife_flag}   Get Knife Flag From TestLine
    Run Keyword If  ${knife_flag}==1   VDU Make Knife   login_account=${login_account}   build_number=${build_number}
      ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${vdu_release_name}   Set Variable    vdu
    ${pre_release_name}   Set Variable    prerequisite

    Set Test Variable  ${Build_folder}  /var/home/${login_account}/${build_number}/HelmChart

    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin    ${vdu_index}
    ...   ELSE   vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}

    ${cp_str}=    Set Variable    cp ${prerequisite_values_path} ${Build_folder}/aic-vdu-prerequisite/;
    ${cp_str}=    Set Variable    ${cp_str}cp ${vdu_values_path} ${Build_folder}/aic-vdu/;
    ${cp_str}=    Set Variable    ${cp_str}cp ${cluster_values_path} ${Build_folder}/aic-vdu-cluster-preparation/
    ${_}    ${prerequisite_file_name}=    Split Path	${prerequisite_values_path}
    ${_}    ${cluster_file_name}=    Split Path    ${cluster_values_path}
    ${_}    ${vdu_values_file_name}=    Split Path    ${vdu_values_path}
    ${prerequisite_file_path}=    Join Path    ${Build_folder}/aic-vdu-prerequisite/    ${prerequisite_file_name}
    ${cluster_file_path}=    Join Path    ${Build_folder}/aic-vdu-cluster-preparation/    ${cluster_file_name}
    ${vdu_values_path}=    Join Path    ${Build_folder}/aic-vdu/    ${vdu_values_file_name}

    ${output}=    helm.execute_command_on_master_cluster    ${cp_str}
    Should Be Empty  ${output.stderr}

    Create Preparation and Verify Preparation creation
    ...    remote_dst_file=${cluster_file_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-cluster-preparation
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create Prerequisite and Verify Prerequisite creation
    ...    remote_dst_file=${prerequisite_file_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu-prerequisite
    ...    fail_on_error=false
    ...    helm_cmd=helm
    Create VDU and Verify VDU creation
    ...    remote_dst_file=${vdu_values_path}
    ...    login_account=${login_account}
    ...    remote_dst_path=/var/home/${login_account}/${build_number}/HelmChart/aic-vdu
    ...    pod_number=${pod_number}
    ...    helm_cmd=helm


VDU Make Knife
    [Arguments]  ${login_account}   ${build_number}  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]   VDU Make Knife
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   27.10.2023,chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | login_account  |  no | login_account, default is core |
    ...    | build_number   |  no | build_number, eg, 0.300.16654 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | VDU Make Knife | login_account=cranuser1 | build_number=0.300.16654 |
    ...
    Log To Console   VDU Make Knife
    Log    ${gnb_index}
    Log    ${vdu_index}
    VDU Copy Testline Extra Config From Share File Server To OE Server  login_account=${login_account}   build_number=${build_number}
    ${knife_id}   VDU Build Knife Image   login_account=${login_account}   build_number=${build_number}
    VDU Update Chart For Knife Image Name    login_account=${login_account}   build_number=${build_number}   knife_id=${knife_id}


VDU Copy Testline Extra Config From Share File Server To OE Server
    [Arguments]  ${login_account}   ${build_number}
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_local}  AND
    ...   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_OE}
    [Documentation]   VDU Copy Testline Extra Config From Share File Server To OE Server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   27.10.2023,chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | login_account  |  no | login_account, default is core |
    ...    | build_number   |  no | build_number, eg, 0.300.16654 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | VDU Copy Testline Extra Config From Share File Server To OE Server | login_account=cranuser1 | build_number=0.300.16654 |
    ...
    Run Keyword If   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
    ${testline_extra_config}   Set Variable  ${tools_repository["testline_extra_config"]}

    ${alias_local}   Get Unique Id
    Connect To UTE Locally   alias=${alias_local}
    ${local_dir}  Set Variable   /home/ute/${login_account}_tmp_vdu_testline_config
    ${out}  issh.Execute   command=rm -rf ${local_dir}   alias=${alias_local}
    ${out}  issh.Execute   command=mkdir -p ${local_dir}   alias=${alias_local}

    ${alias_repo}   Get Unique Id
    Connect To UTE   hostname=${repo_ip}  username=${repo_username}  password=${repo_password}  alias=${alias_repo}
    ${tl_name}  Get TestLine Name From TestLine
    ${source}   Join Path   ${testline_extra_config}   ${tl_name}
    issh.download_directory  source=${source}   destination=${local_dir}   alias=${alias_repo}

    #upload from UTE VM to OE server
    Log To Console  Begin to upload testline config to OE server ...
    ${alias_OE}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_OE}

    ${remote_dir}  Set Variable   /var/home/${login_account}/${build_number}/
    issh.upload_directory   source=${local_dir}/${tl_name}     destination=${remote_dir}   alias=${alias_OE}
    Log To Console   Upload upload testline config to OE server was completed.
    ${out}  issh.Execute  command=ls -l ${remote_dir}   alias=${alias_OE}


VDU Build Knife Image
    [Arguments]  ${login_account}   ${build_number}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_OE}
    [Documentation]   VDU Build Knife Image
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   27.10.2023,chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | login_account  |  no | login_account, default is core |
    ...    | build_number   |  no | build_number, eg, 0.300.16654 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | VDU Build Knife Image | login_account=cranuser1 | build_number=0.300.16654 |
    ...
    Log To Console  Begin to VDU Build Knife Image ...
    ${alias_OE}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_OE}

    ${stream_number}    Evaluate    '.'.join(${build_number.split('.')[:2]})
    ${tl_name}  Get TestLine Name From TestLine
    ${remote_dir}  Set Variable   /var/home/${login_account}/${build_number}/${tl_name}/knife/${stream_number}
    ${out}  issh.Execute  command=cd ${remote_dir}   alias=${alias_OE}
    ${out}  issh.Execute  command=find . -type d -name "dockerfiles-*"   alias=${alias_OE}
    ${dockerfile_folders}   Strip Prompt  content=${out}    return_list=${True}
    ${ns}   Get vDU Namespace From TestLine  vdu_index=${vdu_index}  gnb_index=${gnb_index}

    ${knife_id}  Get Unique Id   precise=FORMAT_DATETIME
    Log To Console   knife_id:${knife_id}
    ${register}  Set Variable   image-registry.openshift-image-registry.svc:5000
    ${out}  issh.Execute  command=podman login ${register} -u admin -p $(oc whoami -t)    alias=${alias_OE}
    FOR  ${dockerfile_folder}   IN   @{dockerfile_folders}
        ${container_name}  Set Variable    ${dockerfile_folder.replace("./dockerfiles-","")}
        Log To Console   ${dockerfile_folder}<-->${container_name}
        ${out}  issh.Execute  command=cd ${dockerfile_folder}    alias=${alias_OE}
        ${first_line}  Set Variable  From ${register}/${ns}/${container_name}:${build_number}
        ${out}  issh.Execute  command=sed -i '1i ${first_line}' Dockerfile.dockerfile    alias=${alias_OE}
        ${command}  Set Variable   podman build -t ${register}/${ns}/${container_name}:${build_number}-dev-${knife_id} -f Dockerfile.dockerfile .
        ${out}  issh.Execute  command=${command}    alias=${alias_OE}
        ${out}  issh.Execute  command=podman push ${register}/${ns}/${container_name}:${build_number}-dev-${knife_id}   alias=${alias_OE}
        ${out}  issh.Execute  command=cd ..    alias=${alias_OE}
    END
    Log To Console   VDU Build Knife Image was completed.

    [Return]  ${knife_id}


VDU Update Chart For Knife Image Name
    [Arguments]  ${login_account}   ${build_number}  ${knife_id}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_OE}
    [Documentation]   VDU Update Chart For Knife Image Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   27.10.2023,chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | login_account  |  no | login_account, default is core |
    ...    | build_number   |  no | build_number, eg, 0.300.16654 |
    ...    | knife_id   |  no | knife_id, eg, 20231029_073944_2612665 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | VDU Update Chart For Knife Image Name | login_account=cranuser1 | build_number=0.300.16654 | knife_id=20231029_073944_2612665 |
    ...
    Log To Console  Begin to VDU Update Chart For Knife Image Name ...
    ${alias_OE}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_OE}

    ${stream_number}    Evaluate    '.'.join(${build_number.split('.')[:2]})
    ${tl_name}  Get TestLine Name From TestLine
    ${remote_dir}  Set Variable   /var/home/${login_account}/${build_number}/${tl_name}/knife/${stream_number}
    ${out}  issh.Execute  command=cd ${remote_dir}   alias=${alias_OE}
    ${out}  issh.Execute  command=find . -type d -name "dockerfiles-*"   alias=${alias_OE}
    ${dockerfile_folders}   Strip Prompt  content=${out}    return_list=${True}
    ${ns}   Get vDU Namespace From TestLine  vdu_index=${vdu_index}  gnb_index=${gnb_index}

    ${remote_dir}  Set Variable   /var/home/${login_account}/${build_number}/HelmChart/aic-vdu
    ${out}  issh.Execute  command=cd ${remote_dir}   alias=${alias_OE}
    FOR  ${dockerfile_folder}   IN   @{dockerfile_folders}
        ${container_name}  Set Variable    ${dockerfile_folder.replace("./dockerfiles-","")}
        Log To Console   ${dockerfile_folder}<-->${container_name}
        ${cmd}    Set Variable    sed -n '/repository: ["]*${container_name}\["\]*$/'= values.yaml
        ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias_OE}
        ${line_num}    Strip Prompt   ${out}
        Should Be True   ${line_num}>0
        ${line_num}   Evaluate   int(${line_num})+1
        ${cmd}    Set Variable    sed -ie '${line_num},${line_num} s/tag:.*/tag: "${build_number}-dev-${knife_id}"/' values.yaml
        ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias_OE}
    END

    Log To Console   VDU Update Chart For Knife Image Name was completed.


Undploy vDU And Deploy vDU Without Commission
    [Arguments]   ${build_number}  ${gnb_index}=0  ${vdu_index}=0   ${restoreData}=${EMPTY}
    [Documentation]    Undploy vDU And Deploy vDU Without Commission
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...   22.09.2023,lijuan.1.wang@nokia-sbell.com, new KW
    ...   12.10.2023  chris.l.cao@nokia-sbell.com, fail the KW if 'UnDeploy VDU For OCP' fails.
    ...   10.12.2023  liting.cao@nokia-sbell.com, add DC_Flag check if need to 'Set DC For fhmSiso In vDU Yaml'.
    ...   3.2.2024  chris.l.cao@nokia-sbell.com, add 'Add SWM Flag In vDU Yaml'
    ...   17.2.2024  chris.l.cao@nokia-sbell.com, delete parameter DC_Flag, this KW need work like a blind box despite of legacy, DC or SWN
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | build_number | Yes | build_number |
    ...    | restoreData | no | restoreData, true or false, default is ${EMPTY} which means use default value true |
    ...
    ...    * RETURN VALUE *
    ...    None
    ...
    ...    Example
    ...    | ${vdu_build} | VDU Get Build Number For Deployment |
    ...    | ${scf_file}  | VDU Get SCF For Deployment | build=${vdu_build}
    ...    | Undploy vDU And Deploy vDU without Commission | build_number=${vdu_build} | restoreData=false |
    ...    | Change Admin Password After Clean Deploy VDU |
    ...    | Wait Until Keyword Succeeds |  5min |  30s  |  VDU Pod Status Should Be Normal |
    ...    | VDU Wait Until Ready For Commission |
    ...    | Full Commission SCF On VDU | scf_file=${scf_file} | wait_vdu_up=${True} |
    ...
    Log To Console  Start UnDeploy vDU ...
    ${vdu_k8s_tenant_ssh}    Get K8s Tenant SSH Connection Info
    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}  VDU Get Deploy Yaml File   build_number=${build_number}
      ...   login_account=${vdu_k8s_tenant_ssh["username"]}

    Run Keyword If  '${restoreData}' != '${EMPTY}'   Set RestoreData Value
    ...   restoreData=${restoreData}   prerequisite_yaml_file_path=${prerequisite_values_path}

    ${secrets}    Get Values For ImagePullSecret
    Change Values For ImagePullSecret    secrets_name=${secrets}    vdu_values_path=${vdu_values_path}
    UnDeploy VDU For OCP    login_account=${vdu_k8s_tenant_ssh["username"]}
    Log To Console   UnDeploy vDU Successfully

    Log To Console   Start Deploy vDU ...
    Deploy VDU For OCP  gnb_index=${gnb_index}  vdu_index=${vdu_index}  build_number=${build_number}
    ...    login_account=${vdu_k8s_tenant_ssh["username"]}  pod_number=NA
    ...    cluster_values_path=${cluster_values_path}    prerequisite_values_path=${prerequisite_values_path}
    ...    vdu_values_path=${vdu_values_path}
    Log To Console   Deploy vDU Successfully


VDU Get Deploy Yaml File
    [Arguments]  ${build_number}   ${login_account}    ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    it will first get override yaml file from S3 server, if it fails then it will get it from VDU running instance.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   31.09.2023, chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | build_number | Yes | build_number |
    ...	   | login_account | Yes | login_account, e.g, cranuser1 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    * RETURN VALUE *
    ...    <vdu_file>, <prerequisite_file>, <clust_preparation_file>
    ...
    ...    Example
    ...    | ${vdu_path} | ${prerequisite_path} | ${cluster_path} | VDU Get Deploy Yaml File | build_number=0.300.903 | login_account=cranuser1 |
    ...
    #first get it from S3 server
    ${get_from_s3_times}  Set Variable   0
    FOR  ${i}  IN RANGE  0  ${get_from_s3_times}
        ${r}  ${out}   Run Keyword And Ignore Error   _VDU Download And Check Agent Values Override Files   build=${build_number}   local_path=/tmp
        ${download_result}           Set Variable  ${out[0]}
        ${clust_preparation_file}    Set Variable  ${out[1]}
        ${prerequisite_file}    Set Variable  ${out[2]}
        ${vdu_file}             Set Variable  ${out[3]}

        ${file_list}  Create List  ${clust_preparation_file}  ${prerequisite_file}    ${vdu_file}
        Run Keyword If   "${r}"=="PASS" and "${download_result}"=="${True}"  Upload File From UTE Server To VDU OE Server   file_list=${file_list}
        Run Keyword If   "${r}"=="PASS" and "${download_result}"=="${True}"  Log To Console  Download yaml file from S3 server successfully.
        Return From Keyword If   "${r}"=="PASS" and "${download_result}"=="${True}"   ${vdu_file}  ${prerequisite_file}   ${clust_preparation_file}
    END

    #secondly get it from VDU running instance
    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}     Get Values from OE
    ...    gnb_index=${gnb_index}  vdu_index=${vdu_index}    login_account=${login_account}

    Log To Console  Download yaml file from VDU running instance successfully.

    [Return]  ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}


Upload File From UTE Server To VDU OE Server
    [Arguments]  ${file_list}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection   alias=${alias}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}

    FOR   ${file}  IN  @{file_list}
        issh.execute   command=rm -f ${file}   alias=${alias}
        issh.upload_file  local_path=${file}   remote_path=${file}   alias=${alias}
    END


Change Admin Password After Clean Deploy VDU
    [Teardown]  Run Keyword And Ignore Error    vDU Rest Logout
    [Documentation]    Change admin password after Clean Deploy VDU
    ...    author: lijuan.1.wang@nokia-sbell.com
    VDU Rest Login   password=nemuuser


VDU Get Build Number For Deployment
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Try to get build from running vdu instance, if fails it will try to get it from environment,
    ...   if fails again it will get it from CIT_BUILD_LINK repository
    ...   https://ciwbts:Wxa2N8AG@gitlabe1.ext.net.nokia.com/jinbyu/cit_build_for_jenkins/-/raw/master/build_information
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  | gnb_index    | no | gnb_index, default value is 0 |
    ...	  | vdu_index    | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...   vdu build number, e.g, 0.300.12345, 19.300.12345
    ...
    ...    Example
    ...    | ${vdu_build} | VDU Get Build Number For Deployment |
    ...    | ${scf_file}  | VDU Get SCF For Deployment | build=${vdu_build}
    ...    | Undploy vDU And Deploy vDU without Commission | build_number=${vdu_build} | restoreData=false |
    ...    | Change Admin Password After Clean Deploy VDU |
    ...    | Wait Until Keyword Succeeds |  5min |  30s  |  VDU Pod Status Should Be Normal |
    ...    | VDU Wait Until Ready For Commission |
    ...    | Full Commission SCF On VDU | scf_file=${scf_file} | wait_vdu_up=${True} |
    ...
    #first get it from VDU instance
    ${r}  ${build_number}  Run Keyword And Ignore Error   Get Running Build Number   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Run Keyword If   "${r}"=="PASS" and "${build_number}"!="${EMPTY}"   Log To Console  Get build number from VDU instance successfully.
    Return From Keyword If   "${r}"=="PASS" and """${build_number}"""!="${EMPTY}"   ${build_number}

    #secondly get it from envirnoment variable
    ${r}  ${build_number}  Run Keyword And Ignore Error   VDU Get Build Number From CM_ARTIFACTS
    Run Keyword If   "${r}"=="PASS" and """${build_number}"""!="""${EMPTY}"""   Log To Console  Get build number from CM_ARTIFACTS successfully.
    Return From Keyword If   "${r}"=="PASS" and """${build_number}"""!="""${EMPTY}"""   ${build_number}

    #finally get it from CIT_BUILD_LINK repository
    ${Current_VDU_build}   Get Latest_Pre VDU_VCU Build Name   type=Current_VDU
    ${build_number}  Set Variable  ${Current_VDU_build.split("_")[-1]}
    Log To Console  Get build number from CIT_BUILD_LINK repository successfully.
    [Return]   ${build_number}


VDU Get Build Number From CM_ARTIFACTS
    [Documentation]   Try to get build from environment variable CM_ARTIFACTS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   vdu build number, e.g, 0.300.12345, 19.300.12345
    ...
    ...    Example
    ...    | ${build_number} | VDU Get Build Number From CM_ARTIFACTS |
    ...
    ${build_number}  Set Variable  ${EMPTY}
    ${cm_artifacts}    get_environ_value     CM_ARTIFACTS
    Return From Keyword If  ${cm_artifacts.__len__()==0}  ${build_number}
    ${dict_cm_artifacts}   Evaluate    json.loads("""${cm_artifacts}""")   modules=json
    ${member_0}  Set Variable  ${dict_cm_artifacts[0]}
    ${vdu_full_build}  Set Variable  ${member_0["name"]}

    ${matches}  Get Regexp Matches     ${vdu_full_build}     ([0-9]+\\.[0-9]+)\\.[0-9]+
    ${build_number}  Set Variable If   ${matches}    ${matches[0]}  ${build_number}

    [Return]  ${build_number}


VDU Get Configuration From Remote Yaml File
    [Arguments]   ${remote_yaml_file}   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]    Disconnect Interactive Connection    alias=${alias}
    [Documentation]   It downloads remote yaml file from VDU OE(with tenant username) server to local file,
    ...    then convert it to dictionary and return it.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...    8.24.2023, chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | remote_yaml_file | yes | /tmp/vdu_values-override.yaml |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    * RETURN VALUE *
    ...    configuration of yaml file, type is dictionary
    ...
    ...    Example
    ...    | ${conf} | VDU Get Configuration From Remote Yaml File | remote_yaml_file=/tmp/vdu_values-override.yaml |
    ...
    ${tmp_file}   Get Unique Id   prefix=tmp_  suffix=.yaml   precise=FORMAT_DATETIME
    ${local_tmp_file}  Get A File   local_tmp_file   ${tmp_file}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively    alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    issh.download_file  remote_path=${remote_yaml_file}   local_path=${local_tmp_file}   alias=${alias}

    ${configuration}   yaml_file_to_dictionary   ${local_tmp_file}
    Print A Dictionary  ${configuration}

    [Return]   ${configuration}


VDU Save Configuration To Remote Yaml File
    [Arguments]   ${configuration}   ${remote_yaml_file}   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]    Disconnect Interactive Connection    alias=${alias}
    [Documentation]   It will save dictionary to local yaml file and upload it to remote yaml file in VDU OE server with tenant name.
    ...       It's the reverse of 'VDU Get Configuration From Remote Yaml File'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...    8.24.2023, chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | configuration    | yes | configuration dictionary |
    ...    | remote_yaml_file | yes | /tmp/vdu_values-override.yaml |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    * RETURN VALUE *
    ...    None
    ...
    ...    Example
    ...    | ${conf_dictionary} | Create Dictionary | key1=val1 | key2=val2 |
    ...    | VDU Save Configuration To Remote Yaml File | configuration=${conf_dictionary} | remote_yaml_file=/tmp/vdu_values-override.yaml |
    ...
    ${tmp_file}   Get Unique Id   prefix=tmp_  suffix=.yaml   precise=FORMAT_DATETIME
    ${local_tmp_file}  Get A File   local_tmp_file   ${tmp_file}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively    alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Print A Dictionary  ${configuration}

    ${content}  Evaluate   yaml.dump(${configuration})   modules=yaml
    Log To Console  ${content}
    OperatingSystem.Create File  path=${local_tmp_file}   content=${content}

    issh.upload_file  local_path=${local_tmp_file}   remote_path=${remote_yaml_file}   alias=${alias}



_Get Install Package Fuzzy Name
    [Arguments]   ${build_number}
    ${info}   Split String    ${build_number}   .
    ${fuzzy_name}   Set Variable  *.${info}[1].*
    [Return]   ${fuzzy_name}

_Get Install Package Branch Pre Name
    [Arguments]   ${build_number}
    ${info}   Split String    ${build_number}   .
    ${Pre_name}   Set Variable  ${info}[0]
    [Return]   ${Pre_name}

_Get Prerequisite Build Number From Manifest
    [Arguments]   ${path}
    ${cmd}    Set Variable  cat ${path}/manifest.json | grep -o "aic-vdu-prerequisite-*.*.tgz"
    ${out}   helm.execute_command_on_master_cluster    ${cmd}
    ${prerequisite_build}  ${postfix}   Split String From Right    ${out.stdout.split('-')[-1]}   .    1
    [Return]   ${prerequisite_build}

_Get Cluster Preparation Build Number From Manifest
    [Arguments]   ${path}
    ${cmd}    Set Variable  cat ${path}/manifest.json | grep -o "aic-vdu-cluster-preparation-*.*.tgz"
    ${out}   helm.execute_command_on_master_cluster    ${cmd}
    ${prerequisite_build}  ${postfix}   Split String From Right    ${out.stdout.split('-')[-1]}   .    1
    [Return]   ${prerequisite_build}


Clean Old Releases And Download New Vdu Package
    [Arguments]   ${build_number}    ${login_account}=core
    [Documentation]    Clean Old Releases And Download New Vdu Package
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...   14.10.2023,chris.l.cao@nokia-sbell.com, support pure IPV6 OE server download
    ...   17.1.2024,chris.l.cao@nokia-sbell.com, will not download package if it exists
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number  |  no | build_number, eg, 0.300.16654 |
    ...    | login_account  |  no | login_account, default is core |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Clean Old Releases And Download New Vdu Package | build_number=0.300.16654 | login_account=cranuser1 |
    ...
    Set Test Variable  ${repository}  https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/

    ${package_is_downloaded_flag}   Get Package Download Flag   build_number=${build_number}    login_account=${login_account}
    Return From Keyword If   "${package_is_downloaded_flag}"=="${True}"

    ${fuzzy_name}   _Get Install Package Fuzzy Name   ${build_number}
    helm.execute_command_on_master_cluster    cd /var/home/${login_account};rm -rf ${fuzzy_name}
    helm.execute_command_on_master_cluster    mkdir ${build_number}
    ${Pre_name}  _Get Install Package Branch Pre Name   ${build_number}
    ${package_prifix}    Get Package Prefix From Global Variables File   ${build_number}

     ${Is_IPv6}    Check If vDU Host Is IPv6
     Run Keyword If  "${Is_IPv6}"=="${True}"  Download Cnf Package For IPv6 VDU Host
        ...   login_account=${login_account}  build_number=${build_number}  package_prefix=${package_prifix}
      ...  ELSE   helm.helm_download_cnf_package    /var/home/${login_account}/${build_number}   ${package_prifix}   ${build_number}  ${repository}

    ${prerequisite_build_number}    _Get Prerequisite Build Number From Manifest    /var/home/${login_account}/${build_number}
    ${cluster-preparation_build_number}    _Get Cluster Preparation Build Number From Manifest    /var/home/${login_account}/${build_number}
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-${build_number}.tgz;
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-prerequisite-${prerequisite_build_number}.tgz
    helm.execute_command_on_master_cluster
    ...  cd /var/home/${login_account}/${build_number}/HelmChart;tar -xzvf aic-vdu-cluster-preparation-${cluster-preparation_build_number}.tgz

    helm.execute_command_on_master_cluster    touch /var/home/${login_account}/${build_number}/package_is_downloaded


Get Package Download Flag
    [Arguments]   ${build_number}    ${login_account}=core
    [Documentation]    Return ${True} if VDU package is already downloaded, otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   17.1.2024,chris.l.cao@nokia-sbell.com, will not download package if it exists
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number  |  no | build_number, eg, 0.300.16654 |
    ...    | login_account  |  no | login_account, default is core |
    ...
    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...    | ${package_is_downloaded_flag} | Get Package Download Flag | build_number=0.300.16654 | login_account=cranuser1 |
    ...
    [Teardown]  issh.disconnect    alias=${alias}
    ${alias}   get_unique_id
    Run Keyword If   "${login_account}"=="core"   Connect To K8s Master Interactively   alias=${alias}
    ...    ELSE   Connect To K8s Master With Tenant Interactively    alias=${alias}
    ${is_file_flag}   issh.is_file   path=/var/home/${login_account}/${build_number}/package_is_downloaded    alias=${alias}
    [Return]  ${is_file_flag}


Download Cnf Package For IPv6 VDU Host
    [Arguments]  ${login_account}   ${build_number}   ${package_prefix}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   issh.Execute  command=rm -rf ${local_dir}   alias=${alias}   AND
    ...   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}  AND
    ...   Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_OE}
    [Documentation]    Download Cnf Package For IPv6 VDU Host
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   14.10.2023,chris.l.cao@nokia-sbell.com, support pure IPV6 OE server download
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | login_account  |  no | login_account, default is core |
    ...    | build_number   |  no | build_number, eg, 0.300.16654 |
    ...    | package_prefix | no | package_prefix, eg. vDUCNF00 |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...   | Download Cnf Package For IPv6 VDU Host | login_account=cranuser1 | build_number=0.300.16654 | package_prefix=vDUCNF00 |
    ...
    ${alias}   Get Unique Id
    Connect To UTE Locally   alias=${alias}
    ${local_dir}  Set Variable   /home/ute/${login_account}_tmp_vdu_package
    ${out}  issh.Execute   command=rm -rf ${local_dir}   alias=${alias}
    ${out}  issh.Execute   command=mkdir -p ${local_dir}   alias=${alias}

    #vDUCNF00_0.300.16654.zip
    Log To Console   Begin to download ${package_prefix}_${build_number}.zip to UTE server ...
    ${command}  Set Variable  nohup wget --no-check-certificate
    ${command}  Set Variable  ${command} https://ca_5gauto:AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc
    ${command}  Set Variable  ${command}@artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/${package_prefix}
    ${command}  Set Variable  ${command}/${package_prefix}_${build_number}/${package_prefix}_${build_number}.zip -P ${local_dir} 2>&1 &
    ${out}  issh.Execute   command=${command}   alias=${alias}
    ${out}  issh.Execute  command=echo $!   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${pid}  Parse Number Only From Content  ${out}
    Wait Until Process Disappear   pid=${pid}  duration=6000  interval=60   alias=${alias}
    Log To Console   Download ${package_prefix}_${build_number}.zip to UTE server was completed.

    #7za.tar
    Log To Console   Begin to download 7za.tar to UTE server ...
    ${command}  Set Variable  nohup wget --no-check-certificate
    ${command}  Set Variable  ${command} http://10.109.2.191:8888/view/Tool/job/Tool_share_for_agent_5g_aic/ws/7za.tar -P ${local_dir} 2>&1 &
    ${out}  issh.Execute   command=${command}   alias=${alias}
    ${out}  issh.Execute  command=echo $!   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${pid}  Parse Number Only From Content  ${out}
    Wait Until Process Disappear   pid=${pid}  duration=120   interval=10  alias=${alias}
    Log To Console   Download 7za.tar to UTE server was completed.
    ${out}  issh.Execute  command=ls -l ${local_dir}   alias=${alias}

    #upload from UTE VM to OE server
    Log To Console  Begin to upload ${package_prefix}_${build_number}.zip and 7za.tar to OE server ...
    ${alias_OE}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias_OE}
    ${out}   issh.Execute   command=rm -rf ${build_number}  check_result=${False}  alias=${alias_OE}
    ${out}   issh.Execute   command=mkdir -p ${build_number}   alias=${alias_OE}
    ${remote_dir}  Set Variable   /var/home/${login_account}/${build_number}/
    issh.upload_file   local_path=${local_dir}/*.*     remote_path=${remote_dir}   alias=${alias_OE}
    Log To Console   Upload ${package_prefix}_${build_number}.zip and 7za.tar to OE server was completed.
    ${out}  issh.Execute  command=ls -l ${remote_dir}   alias=${alias_OE}

    #extract them in OE server
    Log To Console  Begin to extract ${package_prefix}_${build_number}.zip in OE server ...
    ${out}  issh.Execute  command=cd ${remote_dir}   alias=${alias_OE}
    ${out}  issh.Execute  command=tar -xf 7za.tar && rm -rf taf_cache_dir && mkdir taf_cache_dir   alias=${alias_OE}
    ${out}  issh.Execute  command=./7za x ${package_prefix}_${build_number}.zip -r -o./taf_cache_dir   alias=${alias_OE}
    ${out}  issh.Execute  command=rm -f ${package_prefix}_${build_number}.zip   alias=${alias_OE}
    ${out}  issh.Execute  command=mv -f ./taf_cache_dir/* .    alias=${alias_OE}
    ${out}  issh.Execute  command=rm -rf ./taf_cache_dir      alias=${alias_OE}

    ${out}  issh.Execute  command=nohup ./7za x ${package_prefix}_${build_number}.zip -r 2>&1 &     alias=${alias_OE}
    ${out}  issh.Execute  command=echo $!   alias=${alias_OE}
    ${out}  Strip Prompt  ${out}
    ${pid}  Parse Number Only From Content  ${out}
    Wait Until Process Disappear   pid=${pid}   duration=1500   interval=30  alias=${alias_OE}

    ${out}  issh.Execute  command=rm -f ${package_prefix}_${build_number}.zip          alias=${alias_OE}
    ${out}  issh.Execute  command=ls -l ${remote_dir}   alias=${alias_OE}
    Log To Console   Extract ${package_prefix}_${build_number}.zip in OE server was completed.


UnDeploy VDU For OCP
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0   ${login_account}=core
    [Documentation]    Undeploy VDU, PVC, Intnet
    ...    *AUTHOR* yun.1.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...    |2022.6.23 jianlin.zhang@nokia-sbell.com update the kw to adaption for CRAN tenant login|
    ...
    ...    Example
    ...    | UnDeploy VDU For NCS |
    ...
    UnDeploy Default vDU For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}   login_account=${login_account}
    UnDeploy Default Prerequisite For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}  login_account=${login_account}
    UnDeploy Default Preparation For OCP  vdu_index=${vdu_index}  gnb_index=${gnb_index}  login_account=${login_account}


All DUs Container Status Should Be Normal
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   fast_disconnect  alias=${alias}
    ${pod_abbr_list}   Set Variable  ${AIC_VDU_PODS.keys()}
    ${alias}  Get Unique Id
    fast_connect_to_k8s_master   vdu_index=${vdu_index}    alias=${alias}   gnb_index=${gnb_index}

    FOR   ${pod_abbr}  IN  @{pod_abbr_list}
       vDU Special Pod Status And Container Number Should Be Expected   pod_abbr=${pod_abbr}    status=Running  vdu_index=${vdu_index}
       ...   alias=${alias}
    END


FhmSiso Should Be Expected
    [Arguments]  ${fhmsiso}=legacy    ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection   alias=${alias}
    [Documentation]   FhmSiso Should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    4.2.2024   chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    | fhmsiso Parameters | Man. | Description |
    ...    | gnb_index | no | fhmsiso, legacy, direct-connect or switch-network, default is legacy |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | FhmSiso Should Be Expected | fhmsiso=legacy |
    ...    | FhmSiso Should Be Expected | fhmsiso=direct-connect |
    ...    | FhmSiso Should Be Expected | fhmsiso=switch-network |
    ...
    ${vdu_release_name}   Get VDU Release Name   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias}    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${out}  issh.Execute  command=helm get values ${vdu_release_name} -n ${ns}|grep -E "fhmSiso:\\s*${fhmsiso}"|wc -l
      ...    alias=${alias}
    ${out}    Set Variable    ${out.replace("\x1b[?2004l\r","")}
    ${line_number}  Strip Prompt   ${out}
    Should Be True   ${line_number}==1


Get vDU Vnf Config Dictionary From Agent
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU Vnf Config Dictionary From Agent
    ...  author: hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of vDU Vnf Config
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU Vnf Config Dictionary From Agent   |
    ...
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  vdu_index=${vdu_index}  alias=${alias}   gnb_index=${gnb_index}
    ${vdu_info}  get_k8s_tenant_ssh_connection_info  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${lcm_path}=  Set Variable
    ...  /var/home/${vdu_info['username']}/One_Click_Deployment_WS/Kuashaw-oneClick/Kuashaw-oneClick-lcm/
    issh.execute    command=cd ${lcm_path}   alias=${alias}
    ${remote_cnf}  Set Variable   ${lcm_path}cnf/values-override.aic-cnf.yaml
    issh.execute  command=python kuashaw_lcm.py convert   alias=${alias}
    ${local_path_to_cnf}   Get A File   cnf  vdu_cnf_${alias}.xml
    issh.download_file  remote_path=${remote_cnf}
    ...  local_path=${local_path_to_cnf}   alias=${alias}
    disconnect interactive connection   ${alias}
    File Should Exist   ${local_path_to_cnf}
    ${dictionary_content}   yaml_file_to_dictionary   ${local_path_to_cnf}
    [Return]   ${dictionary_content}

Get Package Prefix From Global Variables File
    [Arguments]    ${build_number}
    [Documentation]  Get Package Prefix From Global Variables File
    ...    author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | build_number | Yes | build_number. eg: 0.300.001 or 14.300.001|
    ...
    ...    *RETURN VALUE*
    ...    package_prefix
    ...
    ...    Example
    ...    | ${package_prefix} | Get Package Prefix From Global Variables File | ${build_number} |

    ${SW_version_list1}    split string  ${build_number}    .
    ${trunk_or_branch}    Set Variable    ${SW_version_list1}[:2]
    ${trunk_or_branch}    Evaluate    '.'.join(${trunk_or_branch})
    ${package_prefix}    Set Variable   ${PACKAGE_PRE_MAPPING}[${trunk_or_branch}]
    [Return]    ${package_prefix}


Get Capability From K8S
    [Arguments]  ${ctr_abbr}=oambb
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Capability From K8S
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ctr_abbr  | No | contrainer abbreviation, default value is oambb  |
    ...
    ...    *RETURN VALUE*
    ...   list of Capability
    ...
    ...    Example
    ...   | ${cap_list} | Get Capability From K8S | ctr_abbr=oambb |
    ...
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${full_pod_name}   Get Full Pod Name By Container Abbreviation Interactively   container_abbr=${ctr_abbr}
    ${out}   issh.Execute   command=kubectl get pods ${full_pod_name} -o json | jq -M '.spec.containers[].securityContext'   alias=${alias}

    ${out}  Strip Prompt  ${out}
    ${r}  ${out}  Run Keyword And Ignore Error  Evaluate   json.loads("""${out}""")  modules=json
    Log To Console  ${out}
    ${cap_list}  Set Variable  ${out["capabilities"]["add"]}
    Sort List  ${cap_list}
    [Return]  ${cap_list}


Get Capability From Container
    [Arguments]  ${ctr_abbr}=oambb   ${program}=/opt/nokia/SS_OAM/HAS/HAS
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Get Capability From Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ctr_abbr  | No | contrainer abbreviation, default value is oambb  |
    ...    | program  | No | program name, default value is /opt/nokia/SS_OAM/HAS/HAS  |
    ...
    ...    *RETURN VALUE*
    ...   list of Capability
    ...
    ...    Example
    ...   | ${cap_list} | Get Capability From Container | program=/opt/nokia/SS_OAM/HAS/HAS |
    ...
    ${alias}   Get Unique Id
    Connect To VDU Container With Tenant Interactively   ctr_abbr=${ctr_abbr}     alias=${alias}
    ${out}   issh.Execute
    ...   command=getcap ${program} |cut -d ' ' -f2 |cut -d '=' -f 1 |sed s/cap_//g
    ...   alias=${alias}

    ${out}  Strip Prompt  ${out}
    ${out}  Set Variable  ${out.upper()}
    ${cap_list}  String.Split String  string=${out}   separator=,
    Sort List  ${cap_list}
    [Return]  ${cap_list}

Get L2HI mac address
    [Arguments]    ${pod_abbr}=up   ${container}=l2hi   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  judging pod restart time should be as expected
    ...    *Author*: tingting.xiao@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | tixiao | 02-23-2023 | create |
    ...    *Parameter Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | pod name |
    ...	   | container | No. | container name |
    ...    | vdu_index | No | int, gnb index. |
    ...    | gnb_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get L2HI mac address |
    Log    ${vdu_index}
    Log    ${gnb_index}
    ${alias_l2hi}  Get Unique Id
    Connect To VDU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=${container}  alias=${alias_l2hi}
    ${out}   issh.Execute  command=hal-cli show port table   check_result=${False}  alias=${alias_l2hi}
    ${matches}  Get Regexp Matches   ${out}   l2biphi\\s+BIP\\s+(\\w+:)+\\w+\\.\\d+\\s+(\\w+:)+\\w+
    ${mac_l2hi}  Get Regexp Matches   ${matches}[0]   (\\w+:){5}\\w+
    [Return]    ${mac_l2hi}    ${alias_l2hi}


Get Values from OE
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0   ${login_account}=${EMPTY}
    [Teardown]    helm.helm_master_close
    [Documentation]   Get Values from OE
    ...   *AUTHOR* unknown
    ...  history change:
    ...   20.9.2023, lijuan.1.wang@nokia-sbell.com, add parameter restoreData
    ...   21.9.2023, chris.l.cao@nokia-sbell.com, add KW description, fix bug of vdu_index/gnb_index usage,
    ...                              change to 'vdu_index=${vdu_index}  gnb_index=${gnb_index}', change login_account default to ${EMPTY}
    ...                              move restoreData to other KW
    ...
    ...   | Input Parameters | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...	  | login_account | no | we suggest use tenant as login_account, default is ${EMPTY}, it means to use tenant name automatically |
    ...
    ...   *RETURN VALUE*
    ...   The yaml file path of aic-vdu, aic-vdu-cluster-preparation, aic-vdu-prerequisite. Return type is list, e.g,
    ...   ['/tmp/vdutest_values-overrride.yaml',
    ...   '/tmp/vdutest-prerequisite_values-overrride.yaml',
    ...   '/tmp/vdutest-cluster-preparation_values-overrride.yaml']
    ...
    ...   Example
    ...   |  ${vdu_values_path} | ${prerequisite_values_path} | ${cluster_values_path} | Get Values from OE |
    ...
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${login_account}  Set Variable If   "${login_account}"=="${EMPTY}"  ${vdu_k8s_tenant_ssh_connection_info["username"]}    ${login_account}

    Run Keyword If     "${login_account}"=="core"   vDU Cluster Login With Admin   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ...   ELSE   vDU Cluster Login With Tenant     vdu_index=${vdu_index}  gnb_index=${gnb_index}

    ${namespace}  Get VDU Namespace From TestLine  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}=    Get Values-Override From Target OE  namespace=${namespace}

    [Return]    ${vdu_values_path}    ${prerequisite_values_path}    ${cluster_values_path}


Set RestoreData Value
    [Arguments]   ${restoreData}   ${prerequisite_yaml_file_path}
    [Teardown]   issh.disconnect  alias=${alias}
    [Documentation]   Set RestoreData to true or false in prerequisite yaml file
    ...   *AUTHOR* unknown
    ...  history change: lijuan.1.wang@nokia-sbell.com
    ...   20.9.2023, lijuan.1.wang@nokia-sbell.com, add parameter restoreData
    ...   27.10.2023, chris.l.cao@nokia-sbell.com, add restoreData when it not exist in yaml file
    ...
    ...   | Input Parameters | Man. | Description |
    ...	  | restoreData      | yes | restoreData, true or false |
    ...	  | prerequisite_yaml_file_path | yes | yaml file name of prerequisite |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | Set RestoreData Value | restoreData=false | prerequisite_yaml_file_path=/tmp/prerequisite.yaml |
    ...   | Set RestoreData Value | restoreData=true  | prerequisite_yaml_file_path=/tmp/prerequisite.yaml |
    ...
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${cmd}    Set Variable    grep restoreData ${prerequisite_yaml_file_path}|wc -l
    ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias}
    ${out}    Strip Prompt   ${out}

    #replace
    ${cmd}  Run Keyword If  ${out}>0   Set Variable    sed -i -e "s/restoreData:.*/restoreData: ${restoreData}/" ${prerequisite_yaml_file_path}
    Run Keyword If  ${out}>0   issh.execute   command=${cmd}   check_result=${False}    alias=${alias}
    Return From Keyword If   ${out}>0

    #add
    ${cmd}    Set Variable    sed -n '/^global:/'= ${prerequisite_yaml_file_path}
    ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias}
    ${line_num}    Strip Prompt   ${out}
    ${line_num}   Evaluate   int(${line_num})+1
    ${cmd}    Set Variable    sed -i '${line_num} s/^/${SPACE}${SPACE}restoreData: ${restoreData}\\n/' ${prerequisite_yaml_file_path}
    ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias}


_VDU Download And Check Agent Values Override Files
    [Arguments]  ${s3_server_dir}=${AGENT_LINK}/AGENT_AIC_VDU_YAML  ${build}=0.300.17046  ${local_path}=/tmp
    ...   ${vdu_index}=0
    [Documentation]   _VDU Download And Check Agent Values Override Files
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  | s3_server_dir | no | default value is http://10.109.2.147:8099/AGENT_AIC_VDU_YAML |
    ...	  | build         | no | build, default value is 0.300.17046 |
    ...	  | local_path    | no | local_path, default value is /tmp |
    ...
    ...    *RETURN VALUE*
    ...   <download_result>, <clust_preparation_file>, <prerequisite_file>, <vdu_file>
    ...
    ${tl}  Get TestLine Name From TestLine    vdu_index=${vdu_index}
    ${local_file_prerequisite}  Set Variable  ${local_path}/aic_prerequisite_yaml_VDU_${vdu_index}.yaml
    ${local_file_vdu}  Set Variable  ${local_path}/aic_vdu_yaml_VDU_${vdu_index}.yaml
    ${local_file_cluster}  Set Variable  ${local_path}/aic_cluster_VDU_${vdu_index}.yaml

    Run Keyword And Ignore Error   Run  rm -rf ${local_file_prerequisite}
    Run Keyword And Ignore Error   Run  rm -rf ${local_file_vdu}
    Run Keyword And Ignore Error   Run  rm -rf ${local_file_cluster}

#    ${remote_file_cluster}  Set Variable  ${s3_server_dir}/${tl}_${build}_values_override_aic_cluster_preparation_yaml_VDU_${vdu_index}.yaml
#    ${remote_file_prerequisite}  Set Variable  ${s3_server_dir}/${tl}_${build}_values_override_aic_prerequisite_yaml_VDU_${vdu_index}.yaml
#    ${remote_file_vdu}  Set Variable  ${s3_server_dir}/${tl}_${build}_values_override_aic_vdu_yaml_VDU_${vdu_index}.yaml
    ${remote_file_cluster}  Set Variable
       ...   ${s3_server_dir}/${tl}_${build}_values_override_aic_cluster_preparation_yaml_VDU_${vdu_index}_deploy_success.yaml
    ${remote_file_prerequisite}
       ...   Set Variable  ${s3_server_dir}/${tl}_${build}_values_override_aic_prerequisite_yaml_VDU_${vdu_index}_deploy_success.yaml
    ${remote_file_vdu}  Set Variable  ${s3_server_dir}/${tl}_${build}_values_override_aic_vdu_yaml_VDU_${vdu_index}_deploy_success.yaml

    #detect it
    ${remote_cluster_preparation_out}   OperatingSystem.Run   wget ${remote_file_cluster} --no-check-certificate --spider
    ${remote_prerequisite_out}          OperatingSystem.Run   wget ${remote_file_prerequisite} --no-check-certificate --spider
    ${remote_cnf_out}                   OperatingSystem.Run   wget ${remote_file_vdu} --no-check-certificate --spider
    ${cluster_preparation_exist}    Set Variable If   '200 OK' in """${remote_cluster_preparation_out}"""   True    False
    ${prerequisite_exist}    Set Variable If   '200 OK' in """${remote_prerequisite_out}"""   True    False
    ${cnf_exist}    Set Variable If   '200 OK' in """${remote_cnf_out}"""   True    False

    #download it
    ${res1}  Run Keyword If    "${cluster_preparation_exist}"=="${True}"  run keyword and return status
      ...  OperatingSystem.Run  wget ${remote_file_cluster} -O ${local_file_cluster}
      ...  ELSE   Set Variable   ${False}

    ${res2}  Run Keyword If    "${prerequisite_exist}"=="${True}"   run keyword and return status
      ...   OperatingSystem.Run  wget ${remote_file_prerequisite} -O ${local_file_prerequisite}
      ...  ELSE   Set Variable   ${False}

    ${res3}  Run Keyword If    "${cnf_exist}"=="${True}"  run keyword and return status
      ...   OperatingSystem.Run  wget ${remote_file_vdu} -O ${local_file_vdu}
      ...  ELSE   Set Variable   ${False}

    ${res_final}   Run Keyword And Return Status   Should Be True   ${res1} and ${res2} and ${res3}

    [Return]   ${res_final}  ${local_file_cluster}  ${local_file_prerequisite}   ${local_file_vdu}


Get Values-Override From Target OE
    [Arguments]    ${namespace}
    [Documentation]    download values-override and return from current VDU/VCU
    ...    *AUTHOR* jinbo.yu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.11.2023,chris.l.cao@nokia-sbell.com, fix the prefix name of override yaml file to support second time deploy
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | namespace | yes | namespace of VDU, e.g, cran1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Cluster Login With Tenant |
    ...    | ${vdu_values-override_path} | ${prerequisite_values-override_path} | ${cluster_values-override_path} |
    ...    | ... | Get Values-Override From Target OE | namespace=cran1 |
    ...
    ${cnf_release}=   helm.execute_command_on_master_cluster
    ...    helm list -n ${namespace} | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release_name}=    Strip String    ${cnf_release.stdout}
    ${cnf_cluster_release}=   helm.execute_command_on_master_cluster    helm list -n ${namespace} | grep cluster-preparation | awk '{print $1}'
    ${cnf_cluster_release_name}=    Strip String    ${cnf_cluster_release.stdout}
    ${cnf_prerequisite}=   helm.execute_command_on_master_cluster    helm list -n ${namespace} | grep prerequisite | awk '{print $1}'
    ${cnf_prerequisite_name}=    Strip String    ${cnf_prerequisite.stdout}

    ${cnf_release_name_yaml}    Set Variable           /tmp/VDU_instance_cnf_${namespace}_values-overrride.yaml
    ${cnf_cluster_release_name_yaml}    Set Variable   /tmp/VDU_instance_preparation_${namespace}_values-overrride.yaml
    ${cnf_prerequisite_name_yaml}    Set Variable      /tmp/VDU_instance_prerequisite_${namespace}_values-overrride.yaml

    Return From Keyword If
      ...   ${cnf_release_name.__len__()==0} or ${cnf_cluster_release_name.__len__()==0} or ${cnf_prerequisite_name.__len__()==0}
      ...    ${cnf_release_name_yaml}    ${cnf_prerequisite_name_yaml}   ${cnf_cluster_release_name_yaml}

    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_release_name} -n ${namespace} > ${cnf_release_name_yaml}
    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_cluster_release_name} -n ${namespace} > ${cnf_cluster_release_name_yaml}
    helm.execute_command_on_master_cluster
    ...    helm get values ${cnf_prerequisite_name} -n ${namespace} > ${cnf_prerequisite_name_yaml}
    [Return]     ${cnf_release_name_yaml}    ${cnf_prerequisite_name_yaml}
    ...    ${cnf_cluster_release_name_yaml}


Get Values For ImagePullSecret
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0
    [Teardown]    helm.helm_master_close
    Log To Console    Get Values For ImagePullSecret
    vDU Cluster Login With Tenant    ${vdu_index}  ${gnb_index}
    ${cnf_release}=   helm.execute_command_on_master_cluster
    ...    helm list | grep -v cluster | grep -v prerequisite | grep -v NAME | awk '{print $1}'
    ${cnf_release_name}=    Strip String    ${cnf_release.stdout}
    ${secrets_output}=    helm.execute_command_on_master_cluster
    ...    kubectl get secrets|grep -i default-docker | awk '{print $1}'
    ${secrets_name}=    Strip String    ${secrets_output.stdout}
    Log To Console    ${secrets_name}
    [Return]    ${secrets_name}


Change Values For ImagePullSecret
    [Arguments]     ${secrets_name}    ${vdu_values_path}
    [Documentation]   Change imagePullSecret value
    ...    *AUTHOR* unknown
    ...    *Change History*
    ...    17.2.2024   chris.l.cao@nokia-sbell.com, insert line for imagePullSecret
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | secrets_name    | No | secrets like default-dockercfg-gbc8x  |
    ...    | vdu_values_path | No | vdu_values_path |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    Log To Console    Change Values For ImagePullSecret
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}

    ${cmd}    Set Variable   sed -n '/^${SPACE}${SPACE}image:/'= ${vdu_values_path}
    ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias}
    ${line_num}    Strip Prompt   ${out}
    ${line_num}   Evaluate   int(${line_num})+1
    ${cmd}    Set Variable   sed -i '${line_num} s/^/${SPACE}${SPACE}${SPACE}${SPACE}imagePullSecret: ${secrets_name}\\n/' ${vdu_values_path}
    Log To Console    ${cmd}
    ${out}    issh.execute   command=${cmd}   check_result=${False}    alias=${alias}
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}


Get VDU Pod Number
    [Arguments]    ${vdu_index}=0  ${gnb_index}=0
    [Documentation]   Get VDU Pods Number
    ...    *AUTHOR* sophie.jiang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | No | vdu index, default value is 0  |
    ...    | gnb_index  | No | gnb index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   number of vdu pod
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${ns}   Get vDU Namespace From TestLine  ${vdu_index}  ${gnb_index}
    vDU Cluster Login With Tenant  ${vdu_index}
    ${pods_name_list}=  get_vdu_pods_name_list    namespace=${ns}
    ${pod_number}=    Get Length    ${pods_name_list}
    helm.helm_master_close
    [Return]  ${pod_number}


VDU Get Ready For Commission Flag
    [Teardown]  Disconnect Interactive Connection    alias=${alias}
    [Documentation]   VDU Get Ready For Commission Flag
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   true or false
    ...
    ${full_pod_name}   Get Full Pod Name By Container Abbreviation Interactively   container_abbr=oamagent
    ${full_container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=oamagent

    ${command}  Set Variable  kubectl exec -it ${full_pod_name} -c ${full_container_name}
    ${command}  Set Variable  ${command} -- /usr/bin/curl -X GET http://oam-agent:9003/api/agent/v1/readyForCommissioning
    ${command}  Set Variable  ${command} -H "accept: application/json" | jq -r -M '.readyForCommissioning'

    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   alias=${alias}
    ${out}     issh.Execute  command=${command}   check_result=${False}   alias=${alias}
    ${out}   Strip Prompt  ${out}
    [Return]   ${out}


VDU Should Be Ready For Commission
    ${ready}  VDU Get Ready For Commission Flag
    Should Be True  "${ready}"=="true"


VDU Wait Until Ready For Commission
    [Arguments]  ${timeout}=8min
    [Documentation]   VDU Wait Until Ready For Commission
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | timeout  | No | timeout, default value is 3min |

    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    Wait Until Keyword Succeeds  5min  10   VDU Rest Login
    Wait Until Keyword Succeeds  ${timeout}  20   VDU Should Be Ready For Commission


Get Knife Flag From TestLine
    [Documentation]  Get Knife Flag From TestLine
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   1-knife flag is set in __init__.py, 0-knife flag is not set in __init__.py
    ...   If this flag is not given, default value is 0
    ...
    ...    Example
    ...    | ${knife_flag} | Get Knife Flag From TestLine |
    ...
    ${misc_config}   Get Misc Config From TestLine_netact
    Return From Keyword If   ${misc_config.__len__()==0}    0

    ${result}  ${knife_flag}    Run Keyword And Ignore Error   Set Variable  ${misc_config["knife"]}

    Return From Keyword If   "${result}"=="FAIL"    0

    Run Keyword If   "${knife_flag}"!="0" and "${knife_flag}"!="1"
       ...   Fail
       ...   knife value should be 0 or 1, but your given value is ${knife_flag}

    [Return]  ${knife_flag}


Get Kubeconfig File From DU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${is_tenant}=${True}
    [Documentation]  Get Kubeconfig File From DU
    ...    *Author:* rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2023-8-16 | r3li | add keyword |
    ...    | 2023-10-26 | r3li | support get with core |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | int, gnb index. |
    ...    | vdu_index | No | int, vdu index. |
    ...    | is_tenant | No | whether using tenant user, default is True with tenant. |
    ...    *Example*
    ...    | Get Kubeconfig File From DU | 0 | 0 |
    ...    *Return*
    ...    - string, Kubeconfig file saved path
    ${alias}   Get Unique Id
    Run Keyword If   '${is_tenant}'=='${True}'  Connect To K8s Master With Tenant Interactively
    ...   gnb_index=${gnb_index}   alias=${alias}   vdu_index=${vdu_index}
    ...   ELSE   Connect To K8s Master Interactively   gnb_index=${gnb_index}   alias=${alias}   vdu_index=${vdu_index}
    ${cran_user}    Set Variable If    '${is_tenant}'=='${True}'
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  core
    ${file_name}    Get Unique Id
    ${file_name}    Set Variable    du_kube_config_${file_name}
    ${local_filename}    Get A File   kube_config    ${file_name}
    ${out}    issh.execute    command=cat /var/home/${cran_user}/.kube/config > ${file_name}  alias=${alias}
    issh.download_file   remote_path=/var/home/${cran_user}/${file_name}   local_path=${local_filename}   alias=${alias}
    [Teardown]   Run keywords   issh.execute   command=rm -rf /var/home/${cran_user}/${file_name}   alias=${alias}
    ...   AND  disconnect interactive connection   ${alias}
    [Return]   ${local_filename}
