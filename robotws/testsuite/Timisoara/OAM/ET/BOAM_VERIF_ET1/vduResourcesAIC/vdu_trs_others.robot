*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_others.robot
...




#*** Variables ***



*** Keywords ***

Upload Tools To VDU Containers
    [Arguments]   ${target}=${EMPTY}   ${vdu_index}=0
    [Documentation]   Upload Tools To VDU Containers
    ...    *AUTHOR* chris.l.cao
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
    ...   Note: this KW does not work in OCP !!!
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""


    Log To Console  Tools: tools repository ---> K8s master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}

    _Upload File From Master Node To Containers   vdu_index=${vdu_index}   para_tools_info=${TOOLS_INFO}  target=${target}


Upload Tools To K8s Master
    [Arguments]  ${vdu_index}=0
    [Documentation]   Upload Tools To K8s Master
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To K8s Master |
    ...
    log to console   Upload Tools To K8s Master
    run keyword If  """${TRANS_PARA}"""=="""${NONE}"""   Fail  Can't find TRANS_PARA variable!
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    run keyword If  """${result}"""=="""FAIL"""   Fail   Can't find TRANS_PARA->tools_repository variable!
    Return From Keyword If  """${result}"""=="""FAIL"""

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}


Upload Tools To VDU Nodes
    [Arguments]   ${target}=${EMPTY}   ${vdu_index}=0
    [Documentation]   Upload tools to UTE, containers.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | target    | No | target container, default value is ${EMPTY}, means upload to all VDU nodes |
    ...    |           |    | otherwise it should a list to indicate pod abbreviation name where the tools will be uploaded |
    ...    |           |    | e.g oamcp, up, value is a list, please see examples |

    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Tools To vDU Nodes |
    ...    | ${target} | create list | oamcp | up |
    ...    | Upload Tools To vDU Nodes | target=${target} |
    ...
    run keyword if   """${TRANS_PARA}"""=="""${NONE}"""   Fail   Please config tl._trans_para in __init__.py
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    Log To Console  Tools: tools repository ---> K8s master node
    ${LATEST_VERSION_TOOLS}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}
    Set Suite Variable   ${LATEST_VERSION_TOOLS}

    ${LATEST_VERSION_DATA}   _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}
    Set Suite Variable  ${LATEST_VERSION_DATA}

    #####################
    #upload file from master node to work node
    Log To Console  Tools: master node ---> work node
    ${pod_detailed_info_dict}        Create Dictionary
    #{"oamcp": {"work_node_ip":"1.1.1.1", "full_pod_name":"hquvdu-aic-vdu-oamcp-deployment-0" }
    #  "up": {"work_node_ip":"1.1.1.2", "full_pod_name":"hquvdu-aic-vdu-uprt-deployment-0" }
    #}

   ${pod_abbr_list}  Run Keyword If  "${target}"=="${EMPTY}"  Create List   oam   up   cprt
       ...   ELSE   set variable  ${target}
    Should Be True   ${pod_abbr_list.__len__()>0}

    ${alias}   Get Unique ID
    Connect To K8s Master   alias=${alias}
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${full_pod_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${work_node_ip}   Get Work Node Ip By Pod Abbreviation     pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       Should Be True  ${work_node_ip.__len__()}>0
       ${tmp}   Create Dictionary  full_pod_name=${full_pod_name}   work_node_ip=${work_node_ip}
       Set To Dictionary   ${pod_detailed_info_dict}    ${pod_abbr}   ${tmp}
    END

    ${ToBeUploadedWorkNode}   Create List
    FOR   ${pod_abbr}   IN   @{pod_abbr_list}
        ${tmp}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
        Append To List  ${ToBeUploadedWorkNode}   ${tmp}
    END
    ${ToBeUploadedWorkNode}  Remove Duplicates   ${ToBeUploadedWorkNode}

    FOR   ${work_node_ip}  IN   @{ToBeUploadedWorkNode}
        #run keyword and ignore error  disconnect from k8s master
        #connect to k8s master
       #   ${channel}  _upload file from master node to work node
       _Upload File From Master Node To Work Nodes
    ...   work_node_ip=${work_node_ip}
    ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
    ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
    ...   latest_version=${LATEST_VERSION_TOOLS}
    ...   connection=${alias}

       _Upload File From Master Node To Work Nodes
    ...   work_node_ip=${work_node_ip}
    ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
    ...   local_folder=${TOOLS_INFO["work_folder_data"]}
    ...   latest_version=${LATEST_VERSION_DATA}
    ...   connection=${alias}
    END


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


Upload Simu4trs Image To K8s Master
    [Arguments]  ${vdu_index}=0
    [Documentation]   Upload tools and simu4trs image to K8s master
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Upload Simu4trs Image To K8s Master |
    ...

    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_tool_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_tool"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_data_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_data"]}   vdu_index=${vdu_index}

    _Copy Files From Repository To Master   repo_folder=${tools_repository["repo_simu4trs_folder"]}
       ...   k8s_master_folder=${TOOLS_INFO["work_folder_simu4trs"]}   vdu_index=${vdu_index}



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


_Upload File From Local To Remote
    [Arguments]  ${remote_ip}  ${username}    ${password}   ${remote_folder}    ${local_folder}
        ...   ${folder_for_permission_setting}=${EMPTY}   ${permission}=777
    [Documentation]  _Upload File From Local To Remote
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
    ...    | _Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
    ...    | ... | remote_folder=/tmp/opt/tools/ | local_folder=/tmp/opt/tools/ |
    ...    |     |
    ...    | _Upload File From Local To Remote | remote_ip=10.97.120.118 |  username=myusername | password=mypassword |
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

    #run keyword if  ${remote_version}>=${local_version}   tafssh.disconnect   connection=${alias}
    Return From Keyword If    ${remote_version}>=${local_version}

    ${run_code}   ${out}   Run And Return RC And Output  command=ls ${local_folder}
    ${lines}  Split String   ${out}
    FOR  ${file}  IN  @{lines}
        ${remote_folder_tmp}   OperatingSystem.Join Path   ${remote_folder}     ${file}
        ${local_folder_tmp}   OperatingSystem.Join Path   ${local_folder}     ${file}
        tafssh.Upload File   local_path=${local_folder_tmp}    remote_path=${remote_folder_tmp}   connection=${alias}
    END

    ${out}   Run Keyword If  "${folder_for_permission_setting}"!="${EMPTY}"
    ...   tafssh.Execute    command=chmod ${permission} -R ${folder_for_permission_setting}   connection=${alias}
    #  tafssh.disconnect   connection=${alias}



_Upload File From Master Node To Containers
    [Arguments]  ${para_tools_info}  ${vdu_index}=0  ${target}=${EMPTY}
    ${oamcp_pod_containers}  Run Keyword If  "${target}"=="${EMPTY}"  Create List   oam   oamfh   nwmgmt  cprt
    ${uprt_pod_containers}   Run Keyword If  "${target}"=="${EMPTY}"  Create List   l2hi    l2rt  l2hi   l1hi  nwmgmt
    ${pod_and_container_abbr_dict}   Run Keyword If  "${target}"=="${EMPTY}"
       ...   create dictionary  oamcp=${oamcp_pod_containers}    up=${uprt_pod_containers}
       ...   ELSE   set variable  ${target}

    Log To Console  ${pod_and_container_abbr_dict}
    ${ns}   Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}

    ${pod_detailed_info_dict}        Create Dictionary
    #{"oamcp": {"work_node_ip":"1.1.1.1", "full_pod_name":"hquvdu-aic-vdu-oamcp-deployment-0" }
    #  "up": {"work_node_ip":"1.1.1.2", "full_pod_name":"hquvdu-aic-vdu-uprt-deployment-0" }
    #}

    ${alias}   Get Unique ID
    Connect To K8s Master   alias=${alias}
    ${pod_abbr_list}  Set Variable  ${pod_and_container_abbr_dict.keys()}
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${full_pod_name}   Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${work_node_ip}   Get Work Node Ip By Pod Abbreviation     pod_abbr=${pod_abbr}    vdu_index=${vdu_index}  connection=${alias}
       ${tmp}   Create Dictionary  full_pod_name=${full_pod_name}   work_node_ip=${work_node_ip}
       Set To Dictionary   ${pod_detailed_info_dict}    ${pod_abbr}   ${tmp}
    END

    #upload file from master node to work node
    Log To Console  Tools: master node ---> work node
    ${ToBeUploadedWorkNode}   Create List
    FOR   ${pod_abbr}   IN   @{pod_abbr_list}
        ${tmp}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
        Append To List  ${ToBeUploadedWorkNode}   ${tmp}
    END
    ${ToBeUploadedWorkNode}  Remove Duplicates   ${ToBeUploadedWorkNode}

    FOR   ${work_node_ip}  IN   @{ToBeUploadedWorkNode}
        #run keyword and ignore error  disconnect from k8s master
        #connect to k8s master
       _Upload File From Master Node To Work Nodes
       ...   work_node_ip=${work_node_ip}
       ...   remote_folder=${para_tools_info["work_folder_tool"]}
       ...   local_folder=${para_tools_info["work_folder_tool"]}
       ...   latest_version=${LATEST_VERSION_TOOLS}
       ...   connection=${alias}

       _Upload File From Master Node To Work Nodes
       ...   work_node_ip=${work_node_ip}
       ...   remote_folder=${para_tools_info["work_folder_data"]}
       ...   local_folder=${para_tools_info["work_folder_data"]}
       ...   latest_version=${LATEST_VERSION_DATA}
       ...   connection=${alias}
    END

    #upload file from work node to container
    FOR   ${pod_abbr}  IN   @{pod_abbr_list}
       ${work_node_ip}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["work_node_ip"]}
       _Upload File From Work Node To Containers
          ...   ns=${ns}
          ...   pod_and_container_abbr_dict=${pod_and_container_abbr_dict}
          ...   pod_detailed_info_dict=${pod_detailed_info_dict}
          ...   pod_abbr=${pod_abbr}
          ...   work_node_ip=${work_node_ip}
          ...   para_tools_info=${para_tools_info}
          ...   connection=${alias}
          ...   vdu_index=${vdu_index}
    END


_Copy Files From Repository To Master
    [Arguments]   ${repo_folder}   ${k8s_master_folder}   ${vdu_index}=0
    [Documentation]    _Copy Files From Repository To Master
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
    ${result}  ${mast_node}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Should Be True  "${result}"=="PASS"
    ${result}  ${username}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Should Be True  "${result}"=="PASS"
    ${result}  ${password}  Run Keyword And Ignore Error
      ...  set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Should Be True  "${result}"=="PASS"

    _Upload File From Local To Remote   remote_ip=${mast_node}
     ...   username=${username}
     ...   password=${password}
     ...   remote_folder=${k8s_master_folder}
     ...   local_folder=${local_folder}
     ...   folder_for_permission_setting=${k8s_master_folder}
     ...   permission=777

    [Return]  ${repo_version}


_Upload File From Master Node To Work Nodes
    [Arguments]   ${work_node_ip}    ${remote_folder}    ${local_folder}   ${latest_version}  ${connection}=default
    ${remote_version_file_name}   OperatingSystem.Join Path   ${remote_folder}   version.repo
    ${remote_version}   _Get Version Number Of Remote Work Node
     ...   work_node_ip=${work_node_ip}  remote_version_file_name=${remote_version_file_name}   connection=${connection}
    Return From Keyword If  ${remote_version}>=${latest_version}

    ${base_ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    ${ssh_command}   Set Variable   ${base_ssh_command} -C mkdir -p ${remote_folder}
    ${out}    tafssh.Execute   command=${ssh_command}    connection=${connection}

    ${scp_command}   Set Variable  scp -r -o batchmode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${scp_command}   Set Variable  ${scp_command} ${local_folder}* ${work_node_ip}:${remote_folder}
    ${out}   tafssh.Execute  command=${scp_command}  connection=${connection}


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


_Upload File From Work Node To Containers
    [Arguments]  ${ns}  ${pod_and_container_abbr_dict}   ${pod_detailed_info_dict}  ${pod_abbr}  ${para_tools_info}  #${work_node_ip}
    ...   ${connection}  ${vdu_index}=0
    #Currently it's in master node, not in work node!
    Log To Console  Tools: work node ---> containers

    ${alias_worknode}   Get Unique Id
    Connect To VDU Node  pod_abbr=${pod_abbr}  vdu_index=${vdu_index}   master_alias=${connection}   node_alias=${alias_worknode}

    ${full_pod_name}   Set Variable  ${pod_detailed_info_dict["${pod_abbr}"]["full_pod_name"]}
    ${containers}      Set Variable  ${pod_and_container_abbr_dict["${pod_abbr}"]}
    Should Be True  ${containers.__len__()}>0

    Log To Console  ${containers}
    # Currently it's in work node, not in master node!
    FOR   ${container}  IN   @{containers}
       _Upload File From Work Node To Container
          ...  ns=${ns}  full_pod_name=${full_pod_name}  container=${container}  para_tools_info=${para_tools_info}  connection=${alias_worknode}
    END


_Upload File From Work Node To Container
    [Arguments]  ${ns}  ${full_pod_name}   ${container}    ${para_tools_info}   ${connection}
    ${container_id}   Get Container ID From Docker Ps Command  ns=${ns}  full_pod_name=${full_pod_name}  container=${container}
     ...   connection=${connection}
    Should Not Be Empty   ${container_id}

    #tool
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_tool"]}   version.repo
    ${version_inside_container}   _Get Version Number Of Container
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  connection=${connection}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_TOOLS}
     ...   _Upload file from work node to container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_tool"]}
     ...   remote_folder_name=${para_tools_info["work_folder_tool"]}
     ...   connection=${connection}

    #data
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_data"]}   version.repo
    ${version_inside_container}   _Get Version Number Of Container
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  connection=${connection}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_DATA}
     ...  _Upload file from work node to container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_data"]}
     ...   remote_folder_name=${para_tools_info["work_folder_data"]}
     ...   connection=${connection}


_Upload File From Work Node To Container DO
    [Arguments]  ${container_id}   ${local_folder_name}    ${remote_folder_name}    ${connection}
    ${parent_path}  ${dummy}   Split Path  ${remote_folder_name}
    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=mkdir -p ${parent_path}    connection=${connection}
    ${sudo}  Get Sudo For VDU Node for Linux Command According TO Current User   connection=${connection}
    ${ssh_command}   Set Variable  ${sudo} docker cp ${local_folder_name} ${container_id}:${parent_path}
    ${out}  tafssh.Execute   command=${ssh_command}  connection=${connection}
    ${out}  Docker Exec By Container ID   container_id=${container_id}   command=chmod 777 -R ${remote_folder_name}    connection=${connection}




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


_Get Version Number Of Remote Work Node
    [Arguments]   ${work_node_ip}  ${remote_version_file_name}   ${connection}
    ${base_ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    ${remote_ssh_command}  Set Variable  cat ${remote_version_file_name}
    ${out}   tafssh.Execute  command=${base_ssh_command} -C "${remote_ssh_command}"   connection=${connection}

    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${lines}   Split To Lines   ${out}
    ${version_num_line}  Set Variable  ${lines[-1]}
    ${version_num}  Set Variable  ${version_num_line.strip()}
    [Return]    ${version_num}


_Get Version Number Of Container
    [Arguments]   ${container_id}  ${remote_version_file_name}   ${connection}
    ${out}  Docker Exec By Container ID  container_id=${container_id}   command=ls -l ${remote_version_file_name}   connection=${connection}
    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${out}  Docker Exec By Container ID  container_id=${container_id}   command=cat ${remote_version_file_name}   connection=${connection}

    ${version_num}  Set Variable   ${out.strip()}
    [Return]    ${version_num}


_Get Version Number Of Remote Interactively
    [Arguments]    ${file_name}   ${alias}=default
    [Documentation]   _Get Version Number Of Remote Interactively
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | file_name | Yes | file_name  |
    ...    | alias | no | alias, default value is 'default'  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${out}   issh.Execute   command=touch ${file_name}   check_result=${False}  alias=${alias}
    ${out}   issh.Execute  command=cat ${file_name}  check_result=${False}   alias=${alias}
    ${out}   strip prompt  ${out}
    Return From Keyword If    """No such file or directory""" in """${out}"""   0

    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

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
    _Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   local_folder=${TOOLS_INFO["work_folder_tool"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


    _Upload File From Local To Remote   remote_ip=${fhgw_ip}
     ...   username=${fhgw_root_username}
     ...   password=${fhgw_root_password}
     ...   remote_folder=${TOOLS_INFO["work_folder_data"]}
     ...   local_folder=${TOOLS_INFO["work_folder_data"]}
     ...   folder_for_permission_setting=${TOOLS_INFO["work_folder_root"]}
     ...   permission=777


Upload Tools To Ruproxy
    [Arguments]   ${vdu_index}=0   ${fhgw_index}=0    ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=comm_ta_kw_UploadTools_To_Ruproxy
    [Documentation]   Upload Tools To Ruproxy
    ...    *AUTHOR* chris.l.cao
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

    Log To Console  Tools: tools repository ---> K8s master node

    ${alias}   Set Variable   comm_ta_kw_UploadTools_To_Ruproxy
    Connect To FHGW   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    ${container_id}  Get Ruproxy Container ID      ru_index=${ru_index}  alias=${alias}
    _Upload Tools From FHGW To Ruproxy    container_id=${container_id}   para_tools_info=${TOOLS_INFO}   alias=${alias}


_Upload Tools From FHGW To Ruproxy
    [Arguments]   ${container_id}    ${para_tools_info}   ${alias}
    Should Not Be Empty   ${container_id}

    #tool
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_tool"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_TOOLS}
     ...   _Upload File From FHGW Host To Container DO  container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_tool"]}
     ...   remote_folder_name=${para_tools_info["work_folder_tool"]}
     ...   alias=${alias}

    #data
    ${remote_version_file_name}   OperatingSystem.Join Path   ${para_tools_info["work_folder_data"]}   version.repo
    ${version_inside_container}   _Get Tools Version Number Inside Container Interactively
     ...   container_id=${container_id}   remote_version_file_name=${remote_version_file_name}  alias=${alias}

    Run Keyword If  ${version_inside_container}<${LATEST_VERSION_DATA}
     ...   _Upload File From FHGW Host To Container DO   container_id=${container_id}
     ...   local_folder_name=${para_tools_info["work_folder_data"]}
     ...   remote_folder_name=${para_tools_info["work_folder_data"]}
     ...   alias=${alias}


_Upload File From FHGW Host To Container DO
    [Arguments]  ${container_id}   ${local_folder_name}    ${remote_folder_name}    ${alias}
    ${parent_path}  ${dummy}   Split Path  ${remote_folder_name}
    ${out}  Docker Exec By Container ID Interactively   container_id=${container_id}   command=mkdir -p ${parent_path}    alias=${alias}
    ${out}  issh.Execute   command=docker cp ${local_folder_name} ${container_id}:${parent_path}   alias=${alias}


_Get Tools Version Number Inside Container Interactively
    [Arguments]   ${container_id}  ${remote_version_file_name}   ${alias}
    ${out}  Docker Exec By Container ID Interactively    container_id=${container_id}   command=ls -l ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${version_num}   Set Variable If    """No such file or directory""" in """${out}"""    0
    Return From Keyword If    """No such file or directory""" in """${out}"""    ${version_num}

    ${out}  Docker Exec By Container ID Interactively  container_id=${container_id}   command=cat ${remote_version_file_name}   alias=${alias}
    ...   check_result=${False}
    ${version_num}  Strip Prompt   content=${out}
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


Get Connected Ecpri Port
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Get Connected Ecpri Port
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Connected Ecpri Port
    ...
    ...    Example
    ...    | ${EcpriPort} | Get Connected Ecpri Port |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=redis-cli get radioConnectedCpriPort.1   check_result=${False}    alias=${alias}
    ${out}  strip prompt  ${out}
    ${out}  strip prompt  ${out}  remove_first_line=False
    [Return]  ${out}


Set Connected Ecpri Port
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   Set Connected Ecpri Port to 0
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set Connected Ecpri Port |
    ...
    ${alias}  get unique id
    Connect to FHGW Gracefully  alias=${alias}
    ${out}   issh.Execute   command=redis-cli set radioConnectedCpriPort.1 0  check_result=${False}    alias=${alias}


Check Ecpri Port And Correct It If Necessary
    [Documentation]   Check Ecpri Port And Correct It If Necessary
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check Ecpri Port And Correct It If Necessary |
    ...
    ${out}  Get Connected Ecpri Port
    return from keyword if   "0" in ${out}
    Set Connected Ecpri Port
    Restart FHGW Services


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

    ${cmd}     set variable  scp -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    #${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=20 -o ServerAliveInterval=15 -l 3000 ${src} root@${ru_ip}:${dst}
    ${cmd}     set variable  ${cmd} -o TCPKeepAlive=yes -o ServerAliveCountMax=40 -o ServerAliveInterval=15 ${src} root@${ru_ip}:${dst}
    log to console  ${cmd}
    #${out}     issh.Execute  command=${cmd}   check_result=${False}   alias=${proxy_alias}
    ${out}     issh.Execute  command=${cmd}    alias=${proxy_alias}


Delete File In RU
    [Arguments]   ${dst}    ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0   ${ru_index}=1   #${timeout}=150
    [Teardown]    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Copy File From Ruproxy to RU
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
    [Arguments]   ${ru_index}=1   ${timeout}=300   #${fhgw_index}=0  ${gnb_index}=0  ${vdu_index}=0
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
