*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_others.robot
...




*** Variables ***



*** Keywords ***
Upload Tools To VDU Master Node
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Upload Tools To VDU Containers
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To VDU Master Node |
    ...
    ...   Note: this KW does work in OCP !!!
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Log To Console  Tools: tools repository ---> K8s VDU master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}


Upload Tools From VDU Master Node To Container
    [Arguments]   ${pod_abbr}   ${ctr_abbr}   ${gnb_index}=0   ${vdu_index}=0   ${upload_folder_data}=${True}
    [Documentation]   Upload Tools From VCU Master Node To Container
    ...    *AUTHOR* chris.l.cao
    ...  history change:
    ...  31.1.2023,chris.l.cao@nokia-sbell.com, add parameter upload_folder_data
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools From VDU Master Node To Container | pod_abbr=oamfh | ctr_abbr=oamfh |
    ...
    Upload Tools To VDU Master Node  gnb_index=${gnb_index}

    Log To Console  Tools: K8s VDU CNF master node--->K8s VDU container

    ${full_container_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}   vdu_index=${vdu_index}
    ${alias}   Get Unique Id
    Connect To K8s Master Interactively  alias=${alias}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}
    ${ns}   Get VDU Namespace From Testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}

    #delete parent folder
    _Delete Tools Parent Folder In VDU Container
      ...   pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}
      ...   tools_folder=${TOOLS_INFO["work_folder_tool"]}
      ...   alias=${alias}

    _Upload File From VDU Master Node To Container  pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}
      ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
      ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
      ...   alias=${alias}

    Return From Keyword If  "${upload_folder_data}"=="${False}"

    _Upload File From VDU Master Node To Container  pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}
      ...   local_folder=${TOOLS_INFO["work_folder_data"]}
      ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
      ...   alias=${alias}


_Delete Tools Parent Folder In VDU Container
    [Arguments]   ${pod_abbr}    ${ctr_abbr}   ${tools_folder}  ${alias}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   _Delete Tools Parent Folder In VCU Container
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${tools_folder} | Set Variable  | /tmp/opt/tools/trans_test |
    ...    | _Delete Tools Parent Folder In VDU Container | pod_abbr=upue | ctr_abbr=l2hicu | local_folder=${local_folder} | alias=myalias |
    ...
    ${full_container_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}
    #${alias}    Connect To CU K8S Master With Admin
    ${pod_full_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${ns}   Get VDU Namespace From Testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${base_cmd}  Set Variable   kubectl exec -it ${pod_full_name} -c ${full_container_name} -n ${ns} --

    #create parent
    ${tmp0}  Set Variable   ${tools_folder.split('/')[1:]}
    Remove Values From List  ${tmp0}  ${EMPTY}
    ${folder_level}  Get Length  ${tmp0}
    ${dummy}  Set Variable   ${tmp0.pop(-1)}

    ${tools_folder_parent}  Evaluate    "/".join(${tmp0})
    ${tools_folder_parent}  Set Variable  /${tools_folder_parent}
    ${out}  issh.Execute   command=${base_cmd} rm -rf ${tools_folder_parent}   check_result=${False}    alias=${alias}
    ${out}  issh.Execute   command=${base_cmd} mkdir -p ${tools_folder_parent}    alias=${alias}


_Upload File From VDU Master Node To Container
    [Arguments]   ${pod_abbr}    ${ctr_abbr}   ${local_folder}  ${remote_folder}  ${alias}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   _Upload File From VDU Master Node To Container
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${local_folder} | Set Variable  | /tmp/opt/tools/trans_test |
    ...    | ${remote_folder} | Set Variable  | /tmp/opt/tools/trans_test |
    ...    | _Upload File From VDU Master Node To Container | pod_abbr=upue | ctr_abbr=l2hicu | local_folder=${local_folder} |
    ...    | ...  | remote_folder=${remote_folder} | alias=myalias |
    ...
    ${full_container_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}
    #${alias}    Connect To CU K8S Master With Admin
    ${pod_full_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}
    ${ns}   Get VDU Namespace From Testline   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${base_cmd}  Set Variable   kubectl exec -it ${pod_full_name} -c ${full_container_name} -n ${ns} --
    ${tmp1}  Set Variable   ${remote_folder.split('/')[1:]}
    ${remote_folder_without_root_mark}  Evaluate    "/".join(${tmp1})
    ${cmd}  Set Variable
        ...  kubectl cp ${local_folder} ${pod_full_name}:${remote_folder_without_root_mark} -c ${full_container_name} -n ${ns}
    ${out}  issh.Execute   command=${cmd}     alias=${alias}


Upload Tools To UTE
    [Documentation]  Upload Tools To UTE
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To UTE |
    ...
    run keyword if   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""


    Log To Console  Tools: tools repository ---> UTE server
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To UTE Server  repo_folder=${tools_repository["repo_tool_folder"]}
       ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}  _Copy Files From Repository To UTE Server   repo_folder=${tools_repository["repo_data_folder"]}
       ...   local_folder=${TOOLS_INFO["work_folder_data"]}
    Set Suite Variable  ${LATEST_VERSION_DATA}


_Download File From Remote To Local
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
      ...   ${folder_for_permission_setting}=${EMPTY}   ${permission}=777
    [Documentation]  Download remote folder From Remote To Local
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | remote_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    | username | Yes | username  |
    ...    | password | Yes | password  |
    ...    | remote_folder | Yes | remote_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...    | folder_for_permission_setting | no | folder_for_permission_setting of local server  |
    ...    | permission                    | no | permission  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | _Download File From Remote To Local  | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | _Download File From Remote To Local  | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/opt/tools/ | local_folder=/tmp/opt/tools/ | folder_for_permission_setting=/tmp/opt/ | permission=777 |
    ...
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    #create local folder if not exists
    #${run_code}  ${out}     Run And Return RC And Output   command=sudo mkdir -p ${local_folder}
    ${run_code}  ${out}     Run And Return RC And Output   command=mkdir -p ${local_folder}
    ${run_code}  ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   Run And Return RC And Output   command=sudo chmod 777 -R ${folder_for_permission_setting}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}   alias=${alias}
    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Repository   file_name=${remote_version_file_name}    connection=${alias}

    #run keyword if   ${local_version}>=${remote_version}    tafssh.disconnect  connection=${alias}
    Return From Keyword If    ${local_version}>=${remote_version}   ${remote_version}

    ${out}   tafssh.Execute  command=ls ${remote_folder}   connection=${alias}
    ${lines}  Split String   ${out}

    FOR  ${file}  IN  @{lines}
        ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
        ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
        tafssh.Download File   remote_path=${remote_folder_tmp}   local_path=${local_folder_tmp}   connection=${alias}
    END

    # tafssh.disconnect  connection=${alias}

    ${run_code}  ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   Run And Return RC And Output   command=sudo chmod ${permission} -R ${folder_for_permission_setting}
    [Return]  ${remote_version}


Upload File From Local To Remote
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
        ...   ${folder_for_permission_setting}=${EMPTY}   ${permission}=777
    [Teardown]  Run Keyword And Ignore Error   tafssh.disconnect   connection=${alias}
    [Documentation]  Upload File From Local To Remote
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...  history change:
    ...  9.6.2023,chris.l.cao@nokia-sbell.com, remark "Return From Keyword If    ${remote_version}>=${local_version}"
    ...
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
    ...    | Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ | folder_for_permission_setting=/tmp/opt/ | permission=777 |
    ...
    Wait Until Keyword Succeeds    10x     2s   Host Should Be Pingable   target_ip=${remote_ip}

    ${local_version_file_name}   OperatingSystem.Join Path   ${local_folder}   version.repo
    File Should Exist   ${local_version_file_name}
    ${local_version}   _Get Version Number Of Local   file_name=${local_version_file_name}

    ${alias}   Get Unique ID
    tafssh.Connect_To    hostname=${remote_ip}    username=${username}    password=${password}   alias=${alias}

    #create remote folder if not exists
    ${out}    tafssh.Execute   command=mkdir -p ${remote_folder}   connection=${alias}
    ${out}    tafssh.Execute   command=chmod 777 -R ${remote_folder}  connection=${alias}

    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote    file_name=${remote_version_file_name}   connection=${alias}

#    Return From Keyword If    ${remote_version}>=${local_version}

    ${run_code}   ${out}   Run And Return RC And Output  command=ls ${local_folder}
    ${lines}  Split String   ${out}
    FOR  ${file}  IN  @{lines}
        ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
        ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
        tafssh.Upload File   local_path=${local_folder_tmp}    remote_path=${remote_folder_tmp}   connection=${alias}
    END

    ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   tafssh.Execute    command=chmod ${permission} -R ${folder_for_permission_setting}   connection=${alias}


_Copy Files From Repository To Master
    [Arguments]   ${repo_folder}   ${k8s_master_folder}   ${vdu_index}=0
    [Documentation]    _Copy Files From Repository To Master
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change:
    ...  9.6.2023,chris.l.cao@nokia-sbell.com, remark "Return From Keyword If    ${remote_version}>=${local_version}"
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | repo_folder | Yes | repo_folder  |
    ...    | k8s_master_folder | Yes | k8s_master_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Copy Files From Repository To Master | repo_folder=/opt/tools/trans_test/ | k8s_master_folder=/tmp/opt/tools/ |
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
    ${alias_k8s_master}   Get Unique ID
    Connect To K8s Master    vdu_index=${vdu_index}   alias=${alias_k8s_master}

    ${k8s_master_version_file_name}   OperatingSystem.Join Path   ${k8s_master_folder}   version.repo
    ${k8s_version}   _Get Version Number Of Remote    file_name=${k8s_master_version_file_name}   connection=${alias_k8s_master}

#    Return From Keyword If  ${k8s_version}>=${repo_version}   ${repo_version}

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
    ${result}  ${mast_node}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True  "${result}"=="PASS"
    ${result}  ${username}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"
    ${result}  ${password}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"

    Upload File From Local To Remote   remote_ip=${mast_node}
     ...   username=${username}
     ...   password=${password}
     ...   remote_folder=${k8s_master_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${k8s_master_folder}
     ...   permission=777

    [Return]  ${repo_version}


_Copy Files From Repository To UTE Server
    [Arguments]   ${repo_folder}   ${local_folder}
    [Documentation]    _Copy Files From Repository To UTE Server
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | repo_folder | Yes | repo_folder  |
    ...    | local_folder | Yes | local_folder  |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Copy Files From Repository To UTE Server | repo_folder=/opt/tools/trans_test/ | local_folder=/tmp/opt/tools/ |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #get repository version number
    ${repo_ip}   Set Variable  ${tools_repository["ip"]}
    ${repo_username}  Set Variable  ${tools_repository["username"]}
    ${repo_password}  Set Variable  ${tools_repository["password"]}
   # ${alias}   Get Unique ID
   # tafssh.Connect_To    hostname=${repo_ip}    username=${repo_username}    password=${repo_password}   alias=${alias}
    #${repo_version_file_name}   OperatingSystem.Join Path   ${repo_folder}   version.repo
    #${repo_version}   _Get Version Number Of Remote Repository   file_name=${repo_version_file_name}    connection=${alias}

    #get existence version number
#    ${alias_k8s_master}   Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
#
#    ${k8s_master_version_file_name}   OperatingSystem.Join Path   ${k8s_master_folder}   version.repo
#    ${k8s_version}   _Get Version Number Of Remote Interactively
#       ...   file_name=${k8s_master_version_file_name}   alias=${alias_k8s_master}
#
#    Return From Keyword If  ${k8s_version}>=${repo_version}   ${repo_version}

    #download to UTE
    #${local_folder}   Set Variable  ${k8s_master_folder}
    _Download File From Remote To Local   remote_ip=${repo_ip}
     ...   username=${repo_username}
     ...   password=${repo_password}
     ...   remote_folder=${repo_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${local_folder}
     ...   permission=777


_Get Version Number Of Local
    [Arguments]    ${file_name}
    Process.Run Process    command=touch ${file_name}   shell=True
    ${run_code}  ${out}     Run And Return RC And Output   command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    Run Keyword If    """No such file or directory""" in """${out}"""    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote
    [Arguments]    ${file_name}   ${connection}=default
    ${out}   tafssh.Execute   command=touch ${file_name}   connection=${connection}
    ${out}   tafssh.Execute  command=cat ${file_name}   connection=${connection}

    Return From Keyword If    """No such file or directory""" in """${out}"""   0

    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}


_Get Version Number Of Remote Repository
    [Arguments]    ${file_name}   ${connection}
    [Documentation]   _Get Version Number Of Remote Repository, here remote repository means original SSH server where tools are stored.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | file_name  | yes |file_name |
    ...
    ...    *RETURN VALUE*
    ...    version number in remote repository.
    ...
    ...    Example
    ...    | ${version} | _Get Version Number Of Remote Repository |  file_name=/opt/tools/trans_test/version.repo |
    ...
    ${out}   tafssh.Execute   command=ls ${file_name}    connection=${connection}
    Should Be True  """No such file""" not in """${out}"""
    ${out}   tafssh.Execute  command=cat ${file_name}     connection=${connection}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    Run Keyword If    """No such file or directory""" in """${out}"""    Fail   ${file_name}: does not exist!

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}




Upload Tools To FHGW
    [Arguments]  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]   Upload Tools To FHGW
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...       | vdu_index | no | vdu_index, default is 0 |
    ...       | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To FHGW |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    #Tools download: from tools repostory to FHGW
    Log To Console  Tools: Repostory ---> FHGW
    ${LATEST_VERSION_TOOLS}   _Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_tool_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777

    Set Suite Variable  ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Download File From Remote To Local   remote_ip=${tools_repository["ip"]}
     ...   username=${tools_repository["username"]}
     ...   password=${tools_repository["password"]}
     ...   remote_folder=${tools_repository["repo_data_folder"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_data"]}
     ...   permission=777

    Set Suite Variable  ${LATEST_VERSION_DATA}

    ${fhgw_account_info}  Get FHGW Account Info
    ${fhgw_ip}   Set Variable   ${fhgw_account_info["addr"]}
    ${fhgw_root_username}   Set Variable    ${fhgw_account_info["root_username"]}
    ${fhgw_root_password}   Set Variable    ${fhgw_account_info["root_password_plain"]}

    String Should Be An Ip Address  ${fhgw_ip}
    Should Not Be Empty  ${fhgw_root_username}
    Should Not Be Empty  ${fhgw_root_password}

    #from UTE to FHGW
    Log To Console  Tools: UTE ---> FHGW(vdu_index=${vdu_index} fhgw_index=${fhgw_index})
    Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


    Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


Upload Tools To Ruproxy
    [Arguments]   ${vdu_index}=0   ${fhgw_index}=0    ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Upload Tools To Ruproxy
    ...    *AUTHOR* chris.l.cao
    ...  history change:
    ...  11.2.2022,chris.l.cao@nokia-sbell.com, add disconnect ssh session in Teardown
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | target    | No | target container, default value is ${EMPTY}, means upload to all VDU containers |
    ...    |           |    | otherwise it should a dictionary to indicate containers where the tools will be uploaded |
    ...    |           |    | dictionary key is pod abbreviation, e.g oamcp, up, value is a list, please see examples |

    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To vDU Containers |
    ...    | ${containers} | create list | oamfh | oam |
    ...    | ${target}     | create dictionary | oamcp=${containers} |
    ...    | Upload Tools To vDU Containers | target=${target} |
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Upload Tools To FHGW   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${alias}   Get Unique Id

#    Connect To FHGW   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    Connect to FHGW With Root   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    ${container_id}  Get Ruproxy Container ID      ru_index=${ru_index}  alias=${alias}

    _Upload Tools From FHGW To Ruproxy    container_id=${container_id}   para_tools_info=${TOOLS_INFO}    alias=${alias}


_Upload Tools From FHGW To Ruproxy
    [Arguments]   ${container_id}    ${para_tools_info}   ${alias}
    Should Not Be Empty   ${container_id}

    #tool
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["ruproxy_work_folder_tool"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}


    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_TOOLS}
     ...   _Upload File From FHGW Host To Container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_tool"]}
     ...   remote_folder_name=${para_tools_info["ruproxy_work_folder_tool"]}
     ...   alias=${alias}
     ...   delete_ruproxy_work_folder_root=1

    #data
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["ruproxy_work_folder_data"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_DATA}
     ...   _Upload File From FHGW Host To Container DO   container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_data"]}
     ...   remote_folder_name=${para_tools_info["ruproxy_work_folder_data"]}
     ...   alias=${alias}


_Upload File From FHGW Host To Container DO
    [Arguments]  ${container_id}   ${local_folder_name}    ${remote_folder_name}    ${alias}   ${delete_ruproxy_work_folder_root}=0
    ${parent_path}  ${dummy}   Split Path  ${remote_folder_name}
    ${host_folder}  _Get Host Folder   container_id=${container_id}    alias=${alias}
    Should Not Be Empty    ${host_folder}

    ${remote_folder_name_without_root}   Evaluate   "/".join("${parent_path}".split("/")[1:])
    ${parent_path_in_host}   OperatingSystem.Join Path   ${host_folder}   ${remote_folder_name_without_root}

    ${ruproxy_work_folder_without_root}   Evaluate   "/".join("${TOOLS_INFO["ruproxy_work_folder_root"]}".split("/")[1:])
    ${ruproxy_work_folder_root_in_host}    OperatingSystem.Join Path   ${host_folder}   ${ruproxy_work_folder_without_root}

    #delete old folder
    ${out}  Run Keyword If  "${delete_ruproxy_work_folder_root}"=="1"
       ...   issh.Execute   command=rm -rf ${ruproxy_work_folder_root_in_host}   alias=${alias}

    #copy new content
    ${out}   issh.Execute   command=mkdir -p ${parent_path_in_host}   alias=${alias}
    ${out}  issh.Execute   command=cp -a ${local_folder_name} ${parent_path_in_host}   alias=${alias}

    #add permission
    ${out}  issh.Execute   command=chmod 777 -R ${ruproxy_work_folder_root_in_host}   alias=${alias}


_Get Host Folder
    [Arguments]  ${container_id}    ${alias}
    ${out}   issh.Execute   command=docker inspect ${container_id}|grep MergedDir|awk -F ":" '{print $2}'|awk -F "\\"" '{print $2}'
                   ...      alias=${alias}
    ${out}   Strip Prompt   ${out}
    ${out}   Strip Prompt   ${out}   remove_first_line=${False}
    [Return]  ${out}


_Get Tools Version Number Inside Container Interactively
    [Arguments]   ${container_id}  ${remote_version_file_name}   ${alias}
    ${out}  Docker Exec By Container ID Interactively    container_id=${container_id}   command=ls -l ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
                    ...    """Permission denied""" in """${out}"""    0   0
    Return From Keyword If    """No such file or directory""" in """${out}""" or """Permission denied""" in """${out}"""     ${version_num}

    ${out}  Docker Exec By Container ID Interactively  container_id=${container_id}   command=cat ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${out}  Strip Prompt   content=${out}
    ${version_num}  Strip Prompt   content=${out}  remove_first_line=${False}
    ${version_num}  Set Variable   ${version_num.strip()}
    [Return]    ${version_num}


Plugout RU Cable
    [Arguments]  ${key}=EQM-1/HWTOP-1/CABLINK-1   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Plugout RU Cable
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | key     | No | redis DB key, default is EQM-1/HWTOP-1/CABLINK-1  |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Plugout RU Cable | |
    ...    | Plugout RU Cable | key=EQM-1/HWTOP-1/CABLINK-2 |
    ...
    ${alias}  get unique id
    connect to fhgw   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${alias}
    ${out}   Set Redis KEY Field   key=${key}  field=adminState   value=0   alias=${alias}
    should contain  ${out}   OK
    ${out}   Get Redis KEY Field   key=${key}  field=adminState     alias=${alias}


Plugin RU Cable
    [Arguments]  ${key}=EQM-1/HWTOP-1/CABLINK-1    ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Plugin RU Cable
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | key     | No | redis DB key, default is EQM-1/HWTOP-1/CABLINK-1  |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Plugin RU Cable |
    ...
    ${alias}  get unique id
    connect to fhgw   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    ${out}   Set Redis KEY Field   key=${key}  field=adminState   value=1   alias=${alias}
    should contain  ${out}   OK
    ${out}   Get Redis KEY Field   key=${key}  field=adminState     alias=${alias}


Set Redis KEY Field
    [Arguments]  ${key}  ${field}  ${value}   ${alias}=default
    [Documentation]   Set Redis KEY Field
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | key       |  yes | redis DB key  |
    ...    | field     |  yes | field |
    ...    | value     |  yes | value  |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set Redis KEY Field |
    ...
    ${out}   issh.Execute   command=redis-cli -h redis hmset ${key} ${field} ${value}    check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    [Return]  ${out}


Get Redis KEY Field
    [Arguments]  ${key}  ${field}    ${alias}=default
    [Documentation]   Get Redis KEY Field
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | key       |  yes | redis DB key  |
    ...    | field     |  yes | field |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Get Redis KEY Field |
    ...
    ${out}   issh.Execute   command=redis-cli -h redis hmget ${key} ${field}    check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    [Return]  ${out}


Copy File From Ruproxy to RU
    [Arguments]  ${src}  ${dst}   ${alias}=${EMPTY}  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   ${timeout}=150
    [Teardown]   run keyword if   "${alias}"=="${EMPTY}"   run keyword and ignore error  disconnect interactive connection  alias=${proxy_alias}
    [Documentation]    Copy File From Ruproxy to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src            | No | source file name  |
    ...    | dst            | No | dst name |
    ...    | alias            | No | alias name, default value is ${EMPTY} |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 150 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    With giving alias name.
    ...    | Connect to RUPROXY | alias=aliasy |
    ...    | Copy File From Ruproxy to RU | src=/tmp/1.1 | dst=/tmp/1.2 |  alias=aliasy |
    ...    | Disconnect Interactive Connection |  alias=aliasy |
    ...
    ...    Without giving alias name.
    ...    | Copy File From Ruproxy to RU | src=/tmp/1.1 | dst=/tmp/1.2 |
    ...
    log to console  Copy File From Ruproxy to RU
    ${proxy_alias}   run keyword if   "${alias}"=="${EMPTY}"   get unique id
      ...   ELSE   set variable   ${alias}

    run keyword if   "${alias}"=="${EMPTY}"   connect to RUPROXY   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
       ...   alias=${proxy_alias}    ru_index=${ru_index}    timeout=${timeout}

    ${ru_ip}   Get Radio Unit Ip Address   ru_index=${ru_index}

#    ${cmd}     set variable  scp -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
#    #${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=20 -o ServerAliveInterval=15 -l 3000 ${src} root@${ru_ip}:${dst}
#    ${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=40 -o ServerAliveInterval=15 ${src} root@${ru_ip}:${dst}

    ${cmd}   Set Variable   scp -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-rsa
    ${cmd}   Set Variable   ${cmd} -oPubkeyAcceptedKeyTypes=+ssh-rsa -o TCPKeepAlive=yes -o ServerAliveCountMax=40 -o ServerAliveInterval=15
    ${cmd}   Set Variable   ${cmd} ${src} root@${ru_ip}:${dst}

    log to console  ${cmd}
    #${out}     issh.Execute  command=${cmd}   check_result=${False}   alias=${proxy_alias}
    ${out}     issh.Execute  command=${cmd}    alias=${proxy_alias}


Delete File In RU
    [Arguments]   ${dst}    ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   ${timeout}=150
    [Teardown]    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Delete File In RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | dst            | No | dst name |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 150 seconds |
    ...
    ...    *RETURN VALUE*
    ...    connection instance to RU
    ...
    ...    Example
    ...    With giving alias name.
    ...    | Delete File In RU | dst=/run/a.txt |
    ...
    log to console  Delete File In RU
    ${alias}     get unique id
    Connect to Radio Unit   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  ru_index=${ru_index}   alias=${alias}
    ${out}   issh.Execute   command=rm -f ${dst}   check_result=${False}   alias=${alias}


Wait Unitil RU IS Up
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   ${timeout}=300
    [Documentation]   Wait Unitil RU IS Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...    | timeout          | No | timeout, default value is 300 seconds |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Wait Unitil RU IS Up |
    ...    | Wait Unitil RU IS Up | timeout=600 |
    ...
    wait until keyword succeeds  ${timeout}  10s   _Wait Unitil RU IS Up Once    ru_index=${ru_index}


_Wait Unitil RU IS Up Once
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Wait Unitil RU IS Up Once
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Wait Unitil RU IS Up Once |
    ...
    ${alias}  get unique id
    connect to radio unit   gnb_index=${gnb_index}  vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   ru_index=${ru_index}   alias=${alias}
