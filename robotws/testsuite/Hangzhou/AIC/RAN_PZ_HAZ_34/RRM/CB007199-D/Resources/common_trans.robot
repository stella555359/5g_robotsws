*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB007199 in 5G22R3 program

Library             Collections
Library             taf.hw.fhgw.cli                       WITH NAME    issh
Library             OperatingSystem
Library             String
Library             taf.transport.ssh                     WITH NAME    tafssh
Library             Process
Library             taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    tl_info

#Library            ./kw_to_be_optimized_py.py


*** Variables ***

*** Keywords ***

Connect To UTE Locally
    [Arguments]    ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}   ${alias}=default
    [Documentation]   Connect To UTE Locally
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To UTE Locally     |
    ...    | ${out}                     | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection |
    ...
    Connect To UTE    hostname=127.0.0.1   username=${username}   password=${password}  alias=${alias}

Disconnect Interactive Connections
    [Documentation]   Disconnect Interactive Connections, disconnect all interactive ssh connection
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |  alias=alias2 |
    ...    | Disconnect Interactive Connections |
    ...
    issh.disconnect  alias=${None}

Send ENTER Interactively VCU CNF
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively VCU CNF | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    2s
    [Return]  ${out}

_CU SSH To OAM With Username Serviceuser
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to OAM VM with account serviceuser.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <15-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used |
    ...    |  alias  | No |  connection alias  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | _CU SSH To OAM With Username Serviceuser  |  ${0}  |  oam  |
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    issh.Connect to    ip=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                port=22
    ...                username=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                password=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                prompt=>
    ...                timeout=60
    ...                alias=${alias}
    issh.set prompt   assword:    alias=${alias}
    issh.Execute  command=set user username toor4nsn   check_result=${False}  alias=${alias}
    issh.set prompt   \\#   alias=${alias}
    issh.Execute   command=oZPS0POrRieRtu  check_result=${False}  alias=${alias}

    issh.set prompt   >      alias=${alias}
    issh.Execute  command=fsclish   check_result=${False}  alias=${alias}
    issh.Execute  command=set user-management configuration account fallback-deny no   check_result=${False}  alias=${alias}
    issh.set prompt   \\[root@.+-(oam|OAM)-\\d+:.+\\]       alias=${alias}
    issh.Execute  command=exit  check_result=${False}   alias=${alias}

CU SSH To OAM
    [Arguments]    ${gnb_index}=${0}    ${alias}=default
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <15-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To OAM  |    |
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    ${count_of_gnb}=  get length   ${gnbs}
    Run Keyword If    ${count_of_gnb}>=1 and "${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}"=="serviceuser"
    ...     _CU SSH To OAM With Username Serviceuser   ${gnb_index}    ${alias}
    ...     ELSE IF  ${gnbs}   issh.Connect to      ip=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                             username=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                                             password=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                                             prompt=$
    ...                                             timeout=20
    ...                                             alias=${alias}
    ...      ELSE    Fail    There is no CloudBts in testline.
    issh.set prompt   \[\w+@[A-Za-z0-9-:\/]+\]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   oam   ssh to oam vm failed!
    [Return]   ${alias}

_CU SSH To VM
    [Arguments]    ${gnb_index}  ${vm_type}  ${vm_index}   ${alias}=default
    [Documentation]    Create ssh connection to UPUE VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <14-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | Yes |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_type    | Yes |  vm type, can be cpif,cpcl,cpnb,cpnrt,cpue,db and upue |
    ...    |  vm_index   | Yes |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _CU SSH To VM |  0  |  cpif  |   0  |
    ${alias}=   CU SSH To OAM   ${gnb_index}   alias=${alias}
    ${gnbs}    tl_info.get_cloudbts_gnbs    ${tl}
    ${hostname} =    Set Variable     ${vm_type}-${vm_index}.local
    issh.execute    command=ssh ${hostname}   check_result=${False}  alias=${alias}
   # issh.set prompt   ]   alias=${alias}

    issh.set prompt   \\[root@\\S+:\\S+\\]   alias=${alias}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=   convert to lowercase   ${output}
    should contain   ${output}   ${vm_type}   ssh to vm ${vm_type} ${vm_index} failed!
    [Return]  ${alias}

CU SSH To CPIF
    [Arguments]    ${gnb_index}=${0}  ${vm_index}=${0}   ${alias}=default
    [Documentation]    Create ssh connection to CPIF VM.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-May-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  Indicate which gnb/cu will be used, 0 in default |
    ...    |  vm_index   | No |  Indicate which vm will be used, 0 in default |
    ...    |  alias  | No |  connection alias  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | CU SSH To CPIF |  1  |  0  |
    ${alias}=  _CU SSH To VM   ${gnb_index}   cpif    ${vm_index}   alias=${alias}
    [Return]  ${alias}

Current VM Is Master OAM
    [Arguments]   ${alias}=default     ${gnb_index}=0
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${current_host_name}   Strip Prompt  ${res}
    ${current_host_name}    Set Variable    ${current_host_name.upper()}

    ${alias_oam_master}  Get Unique Id
    CU SSH To OAM  alias=${alias_oam_master}  gnb_index=${gnb_index}
    ${res}     issh.Execute     command=hostname   alias=${alias_oam_master}
    ${master_host_name}   Strip Prompt  ${res}
    ${master_host_name}    Set Variable    ${master_host_name.upper()}

    Disconnect Interactive Connection  alias=${alias_oam_master}
    ${bRtn}   Set Variable If  "${current_host_name}"=="${master_host_name}"   1   0
    [Return]  ${bRtn}

_Wireshark Get Host Type Interactively
    [Arguments]  ${alias}=default     ${gnb_index}=0
    [Documentation]   _Wireshark Get Host Type from host. Please use it after keyword connect to ssh host using taf.hw.fhgw.cli.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...    *RETURN VALUE*
    ...    host type, e.g, OAM, CPIF, CPUE, etc.
    ...    Example
    ...    | _Wireshark Get Host Type |
    ${res}     issh.Execute     command=hostname   alias=${alias}
    ${res}    Set Variable    ${res.upper()}
    ${host_type}    Run Keyword If    "OAM" in """${res}"""    Set Variable    VCUOAM
    ...    ELSE    set variable    VCUOTHER
    Return From Keyword If   "${host_type}"!="VCUOAM"    ${host_type}
    ${bIsMasterOAM}    current VM Is Master OAM   alias=${alias}  gnb_index=${gnb_index}
    ${host_type}   Set Variable If  ${bIsMasterOAM}==1   VCUOAMMASTER   VCUOAMSLAVE
    [Return]    ${host_type}

Get Current Host Time By Linux Cmd Interactively
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd Interactively |
    ${out}    issh.Execute    command=date +%s    alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}

Check File Existed In Linux Server Via Interactive SSH
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]     Check File Existed In Linux Server Via Interactive SSH
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias name |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In Linux Server Via Interactive SSH |  filename=/root/a.txt | alias=default |
    ...
    ${out}    issh.Execute  command=ls ${filename}   alias=${alias}   check_result=${False}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}

Get Modified Time By Linux Cmd Interactively
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd Interactively | filename=/root/a.txt |
    ${out}    issh.Execute  command=stat --format=%Y ${filename}   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}

_Remove All Temp File If Needed
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}    tafssh.Execute       command=ls -F -1 ${FolderName}   connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd   alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True

    #delete Files 2 Hours Ago
    ${threshold}   Set Variable   7200

    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed    ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END

_Remove One Temp File If Needed
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   tafssh.Execute   command=${sudo} rm -rf ${fullname}    connection=${alias}

_Remove One Temp File If Needed Interactively
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively   filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${sudo}  Run Keyword If   ${bDeleteIt}==1   Get Sudo Via Interactive SSH   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute  command=${sudo} rm -rf ${fullname}   check_result=${False}  alias=${alias}

_Remove All Temp File If Needed From General Linux Server
    [Arguments]  ${FolderName}    ${alias}
    ${res}   issh.Execute  command=ls -l ${FolderName}   alias=${alias}
    Log To Console  ${res}
    ${out}     issh.Execute    command=ls -F -1 ${FolderName}   alias=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   Strip Prompt    content=${out}    return_list=True
    #delete Files 960 seconds Ago
    ${threshold}   Set Variable   960
    FOR   ${file}    IN    @{lines}
        #${file}  evaluate  ''.join(i for i in """${file}""" if ord(i)<128)
        ${matches}  Get Regexp Matches   ${file}   .*(ws_[a-zA-Z0-9_]+\.pcap).*   1
        ${file}  Set Variable If  ${matches}   ${matches[0]}   ${EMPTY}
        Log To Console  ${file}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In Linux Server Via Interactive SSH   filename=${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed Interactively   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END

Disconnect Interactive Connection
    [Arguments]  ${alias}=default
    [Documentation]   Disconnect Interactive Connection for specifical connection identified by alias name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |  alias=alias2 |
    ...    | Disconnect Interactive Connection |               |
    ...    | Disconnect Interactive Connection | alias=alias2 |
    ...
    should not be empty   ${alias}
    issh.disconnect  alias=${alias}

Get Sudo Via Interactive SSH
    [Arguments]  ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo Via Interactive SSH |
    ...
    ${out}  issh.Execute    command=which sudo ; echo $?     alias=${alias}

    ${out}   Strip Prompt  ${out}
    ${lines}   Split To Lines   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Set Variable  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="0"   sudo   ${EMPTY}
    [Return]  ${rtn}

Send ENTER Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends ENTER key
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send ENTER Interactively | alias=default |
    ${enter}    Evaluate    chr(int(13))
    ${out}   issh.Execute_Bare   command=${enter}     alias=${alias}
    Sleep    1.3s
    [Return]  ${out}

Connect To K8s Master
    [Arguments]   ${vdu_index}=0  ${alias}=default
    [Documentation]    Connect To K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=up     | container=l1hi  | command=ls -l /tmp |        |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide |           |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide -n mynamespace |
    ...    | ${out}      | tafssh.Execute | command=kubectl get namespace |
    ...    | Disconnect From K8s Master   |
    ...
    ...    | Connect To K8s master | alias=myalias |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl get pod -o wide | connection=myalias |
    ...    | ${out}      | tafssh.Execute | command=kubectl describe pod    | connection=myalias |
    ...    | Disconnect From K8s Master   | connection=myalias |
    ...
    tafssh.Connect_To
    ...   hostname=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  username=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  password=${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...  alias=${alias}

Disconnect From K8s Master
    [Arguments]   ${connection}=default
    [Documentation]    Disconnect From K8s Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | Disconnect From K8s Master |
    ...
    tafssh.Disconnect   connection=${connection}

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

_Get Version Number Of Remote
    [Arguments]    ${file_name}   ${connection}=default
    ${out}   tafssh.Execute   command=touch ${file_name}   connection=${connection}
    ${out}   tafssh.Execute  command=cat ${file_name}   connection=${connection}

    Return From Keyword If    """No such file or directory""" in """${out}"""   0

    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}

Connect To UTE
    [Arguments]  ${hostname}=${UTE_SSH_IP}   ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}  ${alias}=default
    [Documentation]   Connect To UTE
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | hostname  |  no | hostname, default value is ${UTE_SSH_IP} |
    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
    ...    | alias     |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect To UTE      |
    ...    | ${out}                            | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection |
    ...
    issh.connect_to   ip=${hostname}    username=${username}   password=${password}
       ...   prompt=ute@.*\\$   keyfile=/home/ute/.ssh/id_rsa
       ...   alias=${alias}   width=500

Host Should Be Pingable
    [Arguments]  ${target_ip}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Check whether Host is Pingable or not from current running UTE server. If it's pingable, do nothing.
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2
    ...   sudo ping ${target_ip} -c 2

    ${alias}    get unique id
    connect to ute locally    alias=${alias}
    ${out}   issh.Execute   command=${cmd}   alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100

_Get Version Number Of Local
    [Arguments]    ${file_name}
    Process.Run Process    command=touch ${file_name}   shell=True
    ${run_code}  ${out}     Run And Return RC And Output   command=cat ${file_name}
    ${out}   Set Variable  ${out.strip()}
    Run Keyword If    ${out.__len__()}==0    Return From Keyword    0
    Run Keyword If    """No such file or directory""" in """${out}"""    Return From Keyword    0

    ${version_num}    Get Line    ${out}    0
    [Return]    ${version_num}

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

Send CTRL_C
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key message and interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via hran_network library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send CTRL_C |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   tafssh.Write Input    data=${crtl_c}     connection=${alias}
    ${out}   tafssh.Write Input    data=sync   flush=${True}   connection=${alias}
    Sleep    1.3s
    [Return]  ${out}

Send CTRL_C Interactively
    [Arguments]  ${alias}=default
    [Documentation]    it sends CTRL+C key to interrupt current running command
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via issh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias name |
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | Send CTRL_C Interactively | alias=default |
    ${crtl_c}    Evaluate    chr(int(3))
    ${out}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
    Sleep    2.3s
    [Return]  ${out}

Get Sudo VDUC
    [Arguments]  ${container_id}   ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | container_id | yes | container id |
    ...    | alias        | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo VDUC | container_id=243445ab |
    ...
    tafssh.Send Command    command=sudo docker exec -it ${container_id} bash -c "sudo --help && echo CMD_SUCCESS"
       ...   connection=${alias}   get_pty=${True}
    Sleep  0.5
    ${out}   tafssh.Read Output    connection=${alias}

    ${lines}   Split To Lines   ${out}
    ${result}   Set Variable  ${lines[-1]}
    ${result}   Set Variable  ${result.strip()}
    ${rtn}   Set Variable If  "${result}"=="CMD_SUCCESS"   sudo  ${EMPTY}
    [Return]  ${rtn}

Get Sudo
    [Arguments]  ${alias}=default
    [Documentation]   if sudo is supported, return sudo, otherwise return ${EMPTY}
    ...    within current active ssh connection. it should be used
    ...    under active connection opened via tafssh library.
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | alias name, default value is 'default' |
    ...
    ...    *RETURN VALUE*
    ...    sudo or ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo |
    ...
    tafssh.Send Command    command=which sudo ; echo $?    get_pty=${TRUE}   connection=${alias}
    Sleep  0.5
    ${out}   tafssh.Read Output    connection=${alias}
    ${lines}   Split To Lines   ${out}
    ${exit_code}   Set Variable  ${lines[-1]}
    ${exit_code}   Set Variable  ${exit_code.strip()}
    ${rtn}   Set Variable If  "${exit_code}"=="1"  ${EMPTY}   sudo
    [Return]  ${rtn}

Parse Ipv4 Address Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Ipv4 Address Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    ip v4 address
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc10.108.227.133def |
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc 10.108.227.133 def |
    ...
    ...    keyword fails
    ...    | ${ip} | String Should Be An Ip Address | abc10.108.227.abc |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9]*(\\d+\\.\\d+\\.\\d+\\.\\d+).*   1
    Should Be True  ${matches}
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${ip_addr}

Parse Ipv6 Address
    [Arguments]  ${content}
    [Documentation]    get ip6 address and mask length from linux command 'ip address show dev eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 28.7.2020,Hefeng-Cookie.qu@nokia-sbell.com,add support  container.
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | tafssh.execute      | ip address show dev fp0 |
    ...    | ${ip6_addr} | ${ip6_mask_len} | Parse ipv6 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)/([0-9]{1,3}).+scope global   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}

    Return From Keyword If    ${ip6_addr.__len__()}>0    ${ip6_addr}    ${ip6_mask_len}

    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)\\s+prefixlen\\s+(\\d+)\\s+scopeid\\s+   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip6_addr}     ${ip6_mask_len}

_Kubectl Exec By Pod Abbreviation
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${command}=${EMPTY}   ${connection}=default   ${vdu_index}=0
    [Documentation]    Kubectl exec
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod       |  Yes | pod name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 |
    ...    | ${out}      | Kubectl Exec |  pod_abbr=oamcp  | container=oamfh | command=ls -l | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master   |
    ...

    ${container}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation   pod_abbr=${pod_abbr}    connection=${connection}  vdu_index=${vdu_index}
    ${kubectl_cmd}   Set Variable  kubectl exec -it ${pod_full_name} -c ${container} -n ${ns} -- ${command}
    ${out}   tafssh.Execute    command=${kubectl_cmd}   connection=${connection}
    [Return]  ${out}

Kubectl Exec
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${command}=${EMPTY}   ${connection}=default   ${vdu_index}=0
    [Documentation]    Kubectl exec
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod       |  Yes | pod name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | command  | yes | command, e.g, hostname, ifconfig oam3 |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Linux command execution result inside container.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${out}      | Kubectl Exec | container=oamfh | command=ls -l |
    ...    | ${out}      | Kubectl Exec | pod_abbr=oam | container=oamfh | command=ls -l |
    ...    | Disconnect From K8s Master   |
    ...
    run keyword if    "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail   Please give pod_abbr for container nwmgmt !

    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}
    ...   ELSE  Set Variable  ${pod_abbr}
    ${out}     _Kubectl Exec By Pod Abbreviation
    ...   pod_abbr=${pod_abbr}   container=${container}   command=${command}   connection=${connection}   vdu_index=${vdu_index}
    [Return]  ${out}

Connect To DCAP
    [Arguments]  ${alias}=default
    [Documentation]    Connect To DCAP
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias  |  no | aliase name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    connection instance
    ...
    ...    Example
    ...    | Connect To DCAP          |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection     |
    ...
    issh.Connect_To   ip=${DCAP_IP}
      ...   username=${DCAP_USER}
      ...   password=${DCAP_PASSWORD}
      ...   prompt=\\[lab5g@dcaprnd-mmwsg3\\s\\S+\\]\\$
      ...   alias=${alias}
      ...   width=200

