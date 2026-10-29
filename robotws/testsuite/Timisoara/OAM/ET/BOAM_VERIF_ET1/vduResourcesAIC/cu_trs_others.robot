*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_others.robot
...




#*** Variables ***



*** Keywords ***
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


_Upload Folder From Local To OAM Master Interactively
    [Arguments]  ${remote_ip}   ${remote_folder}    ${local_folder}    #${password}  ${username}
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



Download File From VDU Container
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${filename}=${EMPTY}   ${local_filename}=${EMPTY}   ${gnb_index}=0     ${vdu_index}=0
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]    Download File From VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   3.8.2021,chris.l.cao@nokia-sbell.com, support to not-using pod_abbr
    ...   26.10.2021,hongyuan.sun@nokia-sbell.com,
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
    ${pod_abbr}  Run Keyword If  "${pod_abbr}"=="${EMPTY}"  get pod abbreviation by container abbreviation   container_abbr=${container}
    ...    ELSE   set variable   ${pod_abbr}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}

    ${path2} 	${file}  OperatingSystem.split path   ${filename}
    ${remote_filename}  Get A Remote File   ${file}  alias=${alias}

#    ${cmd}  Set Variable If   "${container}"=="logstorageserver"
#       ...   kubectl exec ${pod_full_name} -c ${container_full_name} -n ${ns} -- /bin/gzip -c ${file_name}|gunzip> ${remote_filename}
#       ...   kubectl cp ${pod_full_name}:${file_name} -c ${container_full_name} ${remote_filename} -n ${ns}
    ${local_ute_filename}  Run Keyword If   "${container}"=="logstorageserver"
    ...   _Download File From VDU Container Misc  ${ns}  ${pod_full_name}  ${remote_filename}  ${local_filename}  ${alias}
    Return From Keyword if  "${container}"=="logstorageserver"  ${local_ute_filename}

    ${cmd}  Set Variable   kubectl cp ${pod_full_name}:${file_name} -c ${container_full_name} ${remote_filename} -n ${ns}
    ${out}  issh.Execute  command=${cmd}    alias=${alias}

    ${local_ute_filename}  Run Keyword If  "${local_filename}"=="${EMPTY}"   get a file   Download_File_From_VDU_Container   ${alias}
    ...   ELSE   Set Variable   ${local_filename}
    issh.download_file   remote_path=${remote_filename}   local_path=${local_ute_filename}   alias=${alias}

    [Return]  ${local_ute_filename}


_Download File From VDU Container Misc
    [Arguments]  ${ns}=${ns}  ${pod_full_name}=${pod_full_name}  ${remote_filename}=${remote_filename}
    ...  ${local_filename}=${local_filename}  ${alias}=${alias}
    ${pvc_volume_cmd}  Set Variable   kubectl get pvc -n ${ns} | grep -i logservice-auditlog |awk '{print $3}'
    ${pvc_volume}  issh.Execute  command=${pvc_volume_cmd}    alias=${alias}
	${pvc_volume}   Get Regexp Matches      ${pvc_volume}    \\S+-pv-\\S+
    ${pod_uid_cmd}  Set Variable   kubectl get pod ${pod_full_name} -n ${ns} -o yaml | grep -i uid | tail -1
    ${pod_uid_tmp}  issh.Execute  command=${pod_uid_cmd}    alias=${alias}
    ${pod_uid_tmp}  Get Regexp Matches      ${pod_uid_tmp}   \\S+\\r
    ${pod_uid}  Set Variable  ${pod_uid_tmp[0].strip('\r')}

    ${cmd}   Catenate  SEPARATOR=  sudo cp -r /var/lib/kubelet/pods/${pod_uid}/volumes/kubernetes.io~local-v
    ...  olume/${pvc_volume[0]}/auditlog ${remote_filename}
    ${out}  issh.Execute  command=${cmd}    alias=${alias}

    ${local_ute_filename}  Run Keyword If  "${local_filename}"=="${EMPTY}"   get a file   Download_File_From_VDU_Container   ${alias}
    ...   ELSE   Set Variable   ${local_filename}
    issh.download_file   remote_path=${remote_filename}   local_path=${local_ute_filename}   alias=${alias}

    [Return]  ${local_ute_filename}