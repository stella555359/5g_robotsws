*** Settings ***
Documentation
...   Migrate keywords from AIC
...   author:yixiang.x.wang@nokia-sbell.com

Resource          common_trans.robot

*** Variables ***

*** Keyword ***
######## Bip Keywords #########
Get Current Host Time By Linux Cmd VDUC
    [Arguments]  ${container_id}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}

Check File Existed In VDUC
    [Arguments]  ${filename}   ${container_id}   ${alias}=default
    [Documentation]   Check File Exist or not inside VDU container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls ${filename}    connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}

_Delete Old Wireshark File In VDUC
    [Arguments]  ${initial_log_path}   ${container_id}  ${alias}    ${FolderName}=/tmp/tmp_wireshark
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} rm -f ${initial_log_path}    connection=${alias}
    _Remove All Temp File If Needed From VDUC   FolderName=${FolderName}   container_id=${container_id}  alias=${alias}

_Delete Old Wireshark File In VDUC For OCP
    [Documentation]    Delete Old Wireshark File In VDUC For OPC
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    [Arguments]  ${initial_log_path}    ${pod_name}    ${container_name}
    ...          ${alias}    ${FolderName}=/tmp/tmp_wireshark
    ${ns}   Get VDU Namespace From TestLine
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- rm -f ${initial_log_path}
    ...                          alias=${alias}

_Delete Old Bip File
    [Arguments]  ${initial_log_path}   ${alias}=default    ${FolderName}=/tmp/tmp_wireshark
    ${res}   issh.Execute   command=ls -l ${FolderName}   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}

_Delete Old Wireshark File
    [Arguments]  ${initial_log_path}   ${alias}=default    ${FolderName}=/tmp/tmp_wireshark
    ${res}   tafssh.Execute   command=ls -l ${FolderName}   alias=${alias}
    Log   ${res}
    tafssh.Execute   command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed    FolderName=${FolderName}   alias=${alias}

_Remove One Temp File If Needed VDUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${container_id}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VDUC   filename=${fullname}  container_id=${container_id}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    Run Keyword If   ${bDeleteIt}==1
      ...  tafssh.Execute     command=sudo docker exec -it ${container_id} rm -rf ${fullname}    connection=${alias}

_Remove All Temp File If Needed From VDUC
    [Arguments]  ${FolderName}    ${container_id}  ${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls -F -1 ${FolderName}    connection=${alias}
    ${curr_time}    Get Current Host Time By Linux Cmd VDUC  container_id=${container_id}  alias=${alias}
    ${lines}   split to lines   ${out}
    ${threshold}   Set Variable   7200
    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VDUC   ${fullname}   container_id=${container_id}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VDUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   container_id=${container_id}  alias=${alias}
    END

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

Check File Existed
    [Arguments]  ${filename}    ${alias}=default
    [Documentation]    Check File Existed or not in general linux server with taf.transport.ssh library
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | alias    | no | alias name |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed |  /root/a.txt |
    ${out}    tafssh.Execute     command=ls ${filename}   connection=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    [Return]   ${bExist}

Get Modified Time By Linux Cmd
    [Arguments]    ${filename}   ${alias}=default
    [Documentation]    Get Modified Time By Linux Cmd inside general linux server with taf.transport.ssh library
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
    ...    | ${sec} | Get Modified Time By Linux Cmd | /root/a.txt |
    ${out}    tafssh.Execute   command=stat --format=%Y ${filename}   connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}

Get Current Host Time By Linux Cmd
    [Arguments]  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${out}    tafssh.Execute    command=date +%s    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}

Get Modified Time By Linux Cmd VDUC
    [Arguments]    ${filename}   ${container_id}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd VDUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} stat --format=%Y ${filename}    connection=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}

_Begin BIP Log Capture OCP
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    ...          ${mbuf}=False  ${mbuf-size}=10000  ${total-num-mbufs}=2048
    [Documentation]    Begin BIP Log Capture in vDU
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...    modified by:   <04-Jan-2022>, <r3li>   adapt new env
    ...    how to use:
    ...    | ${alias} |  GET UNIQUE ID |
    ...    | Connect To vDU Node Interactively | pod_abbr=up | alias=${alias} |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=fhuc | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias |
    ...    | issh.disconnect | connection=alias |
    Log To Console  _Begin BIP Log Capture OCP
    ${ns}   Get VDU Namespace From TestLine
    ${pod_name} =    Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=up    alias=${alias}    vdu_index=${vdu_index}
    ${container_name} =   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    #${command_str}    Set Variable    kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- bash -c "mkdir -p /tmp/dpdk"
    #${out}    issh.Execute     command=${command_str}    alias=${alias}
    ${tmpfilenamefullpath}    Set Variable    /tmp/${port_name}
    ${cmd}    Catenate    SEPARATOR=
    ...    kubectl exec -it ${pod_name} -c ${container_name} -n
    ...    ${ns} -- bash -c "dpdk-cli show port table | grep ${port_name}"
    ${bip_port_id_tmp}    issh.Execute    command=${cmd}    alias=${alias}
    ##prepare dpdk_guard script
    ${bip_port_id}  Get Regexp Matches  ${bip_port_id_tmp}   (\\d).*BIP  1
    #${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}
    #${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo
    #${target}   Create List   ${pod_abbr}
    #${out}  issh.Execute  command=ls ${tcpdump_guard}   check_result=${False}   alias=${alias}
    #Run Keyword If     """No such file or directory""" in """${out}"""
    #...  issh.Execute  command=${sudo} rm -f ${version_file}   alias=${alias}
    #Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To VDU Master Node
    #${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}    check_result=${False}
#
    #Should Be True   """No such file or directory""" not in """${out}"""
    #${alias_process_guard}   Get Unique Id
    #Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    #${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
    ##start capture
#
    ##process guard
    #${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_vdu_ocp"]} -a ${port_name}.pcap &)   alias=${alias_process_guard}
    #${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}   alias=${alias_process_guard}
    #Log To Console  ${out}
    #Sleep   6s
    Log To Console  Begin capture BIP Log in OCP
    issh.Execute_bare
    ...     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- bash -c "cd tmp; dpdk-cli pdump port ${bip_port_id[0]}"
    ...     alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}

_Stop BIP Capture And Download For OCP
    [Arguments]  ${alias}   ${k8s_log_path}=/tmp/dpdk/l1bipl1
    ...          ${initial_log_path}=/tmp/l1bipl1   ${container}=l1hi
    ...          ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   _Stop BIP Capture And Download For OCP
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...    modified by:   <04-Jan-2022>, <r3li>   adapt new env
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  alias | Yes | alias  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Stop BIP Capture And Download For OCP | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e491.pcap | alias |
    ...
    Send CTRL_C Interactively    alias=${alias}
    Sleep  1
    ${ns} =   Get vDU Namespace From TestLine   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${up_pod_name} =    Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=up    alias=${alias}    vdu_index=${vdu_index}
    ${container_name} =   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${out}    issh.Execute     command=kubectl exec -it ${up_pod_name} -c ${container_name} -n ${ns} sync    alias=${alias}
    ${out}    issh.Execute     command=kubectl exec -it ${up_pod_name} -c ${container_name} -n ${ns} -- chmod 777 ${initial_log_path}.pcap
    ...                          alias=${alias}
    ${out}    issh.Execute     command=mkdir -p /tmp/dpdk   alias=${alias}
    ${out}    issh.Execute     command=ls -l /tmp/dpdk   alias=${alias}
    ${kubectl_cp}   Set Variable   kubectl cp -n ${ns} ${up_pod_name}:${initial_log_path}.pcap ${k8s_log_path}.pcap -c ${container_name}
    ${out}    issh.Execute     command=${kubectl_cp}    alias=${alias}
    ${out}    issh.Execute     command=sync    alias=${alias}
    ${local_file_path}=  Get A File    BIP  ${container}_${vdu_index}.pcap
    issh.Download File   remote_path=/tmp/dpdk/l1bipl1.pcap    local_path=${local_file_path}   alias=${alias}
    _Delete Old Wireshark File In VDUC For OCP   initial_log_path=${initial_log_path}.pcap
    ...                                          pod_name=${up_pod_name}
    ...                                          container_name=${container_name}
    ...                                          alias=${alias}    FolderName=/tmp/dpdk
    _Delete Old Bip File    initial_log_path=${k8s_log_path}.pcap   alias=${alias}    FolderName=/tmp/dpdk
    [Return]  ${local_file_path}

_Stop BIP Capture And Download For NCIR Or NCS
    [Arguments]  ${alias}   ${initial_log_path}   ${container}=l1hi   ${vdu_index}=0
    [Documentation]   _Get BIP Log Capture From VDU
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  alias | Yes | alias  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Stop BIP Capture And Download | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e491.pcap | alias |
    ...
    Send CTRL_C    alias=${alias}
    Sleep  1

    ${bip_log_path}  set variable   /tmp/l1bipl1
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${vdu_index}

    Log To Console   ${container_id}
    ${sudo}    Get Sudo VDUC    container_id=${container_id}   alias=${alias}
    ${out}    tafssh.Execute     command=${sudo} docker exec -it ${container_id} sync    connection=${alias}
    ${out}    tafssh.Execute     command=${sudo} docker exec -it ${container_id} chmod 777 ${bip_log_path}.pcap    connection=${alias}
    ${out}    tafssh.Execute     command=${sudo} mkdir -p /tmp/dpdk   connection=${alias}
    ${out}    tafssh.Execute     command=ls -l /tmp/dpdk   connection=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${bip_log_path}.pcap /tmp/dpdk/
    ${out}    tafssh.Execute     command=${docker_cp}    connection=${alias}
    ${out}    tafssh.Execute     command=sync    connection=${alias}

    ${local_file_path}=  Get A File    BIP  ${container}_${vdu_index}.pcap

    tafssh.Download File   remote_path=${initial_log_path}.pcap    local_path=${local_file_path}   connection=${alias}
    _Delete Old Wireshark File In VDUC   initial_log_path=${bip_log_path}.pcap   container_id=${container_id}
    ...    alias=${alias}    FolderName=/tmp/dpdk
    _Delete Old Wireshark File   initial_log_path=${initial_log_path}.pcap   alias=${alias}    FolderName=/tmp/dpdk
    ${sudo}   Get Sudo   alias=${alias}
    tafssh.Execute   command=${sudo} rm -f ${initial_log_path}.pcap     connection=${alias}
    [Return]  ${local_file_path}

Begin BIP Log Capture
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    ...          ${mbuf}=False  ${mbuf-size}=10000  ${total-num-mbufs}=2048
    [Documentation]  get file from pmcore container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...    modified by:   <04-Jan-2022>, <r3li>   adapt new env
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod_abbr(eg: up)|
    ...    how to use:
    ...    | ${alias} |  GET UNIQUE ID |
    ...    | Connect To vDU Node Interactively | pod_abbr=up | alias=${alias} |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=fhuc | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias |
    ...    | issh.disconnect | connection=alias |

    ...    *RETURN VALUE*
    ...    ${tmpfilenamefullpath}
    ${platform}   Get Platform Name
#    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
#    ...             _Begin BIP Log Capture NCS    pod_abbr=${pod_abbr}    container=${container}
#    ...                                           port_name=${port_name}    vdu_index=${vdu_index}
#    ...                                           alias=${alias}    mbuf=${mbuf}
#    ...                                           mbuf-size=${mbuf-size}    total-num-mbufs=${total-num-mbufs}
#    ...     ELSE    _Begin BIP Log Capture OCP    pod_abbr=${pod_abbr}    container=${container}
#    ...                                           port_name=${port_name}    vdu_index=${vdu_index}
#    ...                                           alias=${alias}    mbuf=${mbuf}
#    ...                                           mbuf-size=${mbuf-size}    total-num-mbufs=${total-num-mbufs}
    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...            Fail  Not support NCIR or NCS!
    ...     ELSE    _Begin BIP Log Capture OCP    pod_abbr=${pod_abbr}    container=${container}
    ...                                           port_name=${port_name}    vdu_index=${vdu_index}
    ...                                           alias=${alias}    mbuf=${mbuf}
    ...                                           mbuf-size=${mbuf-size}    total-num-mbufs=${total-num-mbufs}

    [Return]    ${tmpfilenamefullpath}

Stop BIP Capture And Download
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${alias}   ${initial_log_path}   ${container}=l1hi   ${vdu_index}=0
    [Documentation]    Stop BIP Capture And Download from VDU
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...    modified by:   <04-Jan-2022>, <r3li>   adapt new env
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  alias | Yes | alias  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Stop BIP Capture And Download | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e491.pcap | alias |
    ...
    ${platform}   Get Platform Name
    ${local_file_path}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...             _Stop BIP Capture And Download For NCIR Or NCS    initial_log_path=${initial_log_path}
    ...                                                               alias=${alias}
    ...     ELSE    _Stop BIP Capture And Download For OCP    initial_log_path=${initial_log_path}
    ...                                                       alias=${alias}
    ...                                                       container=${container}
    [Return]    ${local_file_path}
##### TTI trace Keywords ######
Get f1uplane Ipv4 Address For vDU
    [Documentation]    Get f1uplane Ipv4 Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <03-Aug-2021>, <rifeng>, <Initial creation>
    Connect To K8s master
    ${out}    Kubectl Exec    pod_abbr=up    container=nwmgmt    command=ip addr show f1uplane
    ${f1u_ip}    Parse Ipv4 Address Only From Content    ${out}
    Disconnect From K8s Master
    [Return]    ${f1u_ip}
Get f1uplane Ipv6 Address For vDU
    [Documentation]    Get f1uplane Ip Address for vDU
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    Connect To K8s master
    ${out}    Kubectl Exec    pod_abbr=up    container=nwmgmt    command=ip addr show f1uplane
    ${f1u_ip}    ${f1u_mask}    Parse Ipv6 Address    ${out}
    Disconnect From K8s Master
    [Return]    ${f1u_ip}
Start TTI Trace Capture
    [Arguments]     ${gnb_index}=${0}    ${vdu_index}=${0}   ${nr_cell_list}=${None}   ${dscp}=0
    log to console    start capture ttitrace log
    ${oam_ip}   Get vDU OAM Ip   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_type}   check ip type    ${oam_ip}
    ${cell_list}   vDU Get Cells ID list
    ${cell_list_copy}    get slice from list  ${cell_list}   end=1
    ${nr_Cell_list_copy}  set variable if   ${nr_cell_list} is ${None}   ${cell_list_copy}   ${nr_cell_list}
    ${dcap_server_ip}=   run keyword if  "${ip_type}"=="ipv4"   set variable   ${DCAP_IP}
    ...  ELSE    set variable   ${DCAP_IPv6}
    set test variable    ${ip_type}
    set test variable    ${dcap_server_ip}
    _Online Add DCAP Server Route    ${dcap_server_ip}
    _Start TTI Trace Via UPTrace       ip_type=${ip_type}    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...    nr_cell_list=${nr_Cell_list_copy}   dscp=${dscp}
Stop TTI Trace Capture
    log to console    stop capture ttitrace log
    ${vdu_version}=    Get Running Build Number
    set test variable    ${vdu_version}
    ${trace_path_list}=    Stop And Download TTI Trace     #${up_pod_name}
    ${local_dl_csv}  ${local_ul_csv}=    Decoder TTITrace With Linux Server     ${ttitrace_server_ip}
    ...    ${TTI_username}  ${TTI_password}  ${vdu_version}  ${trace_path_list}
    set test variable    ${local_dl_csv}
    set test variable    ${local_ul_csv}
Decoder TTITrace With Linux Server
    [Arguments]  ${ttitrace_server_ip}  ${username}  ${password}  ${vdu_version}  ${ttiTrace_files_list}=${EMPTY}
    ...  ${alias}=ttiTrace_linux_server
    ...  ${tool_base_repo}=https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    ...  ${package_name}=vDUCNF
    [Documentation]  decode the tti trace bin.tar.gz files, the ttitrace file name is like 'L2TtiTrace_EventsSnapshot.bin.4.tar.gz'
    ...    author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ttitrace_server_ip | Yes |  the ttitrace decoded server ip |
    ...    | username | Yes |  the server username |
    ...    | password | Yes |  the server password |
    ...    | vdu_version | Yes |  vdu build version |
    ...    | ttiTrace_files_list | Yes | ttitrace bin gz files list, returned from kw-Stop And Download TTI Trace|
    ...    | alias | NO | the server connection alias, default is ttiTrace_linux_server |
    ...    | tool_base_repo | NO | the repo of download the ttitrace tool |
    ...    *RETURN VALUE*
    ...    the ul csv files folder, the dl csv fils folder
    ...    Example
    ...    | Decoder TTITrace With Linux Server | 10.108.229.50 |ute | ute | 0.390.1222 | ${tti_files_list}
    tafssh.connect_to
    ...  hostname=${ttitrace_server_ip}
    ...  username=${username}
    ...  password=${password}
    ...  alias=${alias}
    tafssh.Execute  command=rm -rf /home/ute/ttiTrace_*    connection=${alias}
    _Create Related Folders  ${alias}
    _Get Decode Tool And Untar  ${tool_base_repo}  ${vdu_version}  ${alias}    ${package_name}
    ${local_dl_csv}  ${local_ul_csv}  _Decode TTITRACE Bin Files And Download csv To Local  ${ttiTrace_files_list}  ${alias}
    [Return]  ${local_dl_csv}  ${local_ul_csv}
    [Teardown]  tafssh.disconnect  connection=${alias}
_Online Add DCAP Server Route
    [Arguments]    ${destIpAddr}
    vDU Login
    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    set test variable    ${mrbts_id}
    set test variable    ${nrbts_id}
    set test variable    ${scf_full_path}
    ${route_name}  Set Variable If  "${ip_type}"=="ipv4"  IPRT  IPRTV6
    ${dist}   set variable    MRBTS-${mrbts_id}/TNLSVC-1/TNL-3/IPNO-1/${route_name}-1
    ${add_route}   ${gateway}=   _Check Dcap Server Route Exist    ${destIpAddr}    ${dist}
    run keyword if  "${add_route}"=="PASS"  run keywords  log to console   Route to DCAP server is needed, add the route
    ...   AND  Vdu Add Route  ${dist}    ${destIpAddr}  32  ${gateway}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout
_Check Dcap Server Route Exist
    [Arguments]    ${destIpAddr}    ${dist}
    scf.Load Scf   ${scf_full_path}
    ${route_dstip_name}  Set Variable If  "${ip_type}"=="ipv4"  destIpAddr  destIpv6Addr
    ${route_gateway_name}  Set Variable If  "${ip_type}"=="ipv4"  gateway   gatewayIpv6Addr
    ${res}  ${dest_ip}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_dstip_name}
    ${res}  ${gateway}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_gateway_name}
    ${res}  ${out}  Run Keyword And Ignore Error   Should Not Contain Match   ${dest_ip}    ${destIpAddr}
    [return]    ${res}    ${gateway[0]}
_Start TTI Trace Via UPTrace
    [Arguments]    ${ip_type}     ${gnb_index}    ${vdu_index}   ${nr_cell_list}   ${dscp}=0
    ${f1u_ip}=   run keyword if  "${ip_type}"=="ipv4"   Get f1uplane Ipv4 Address For vDU
    ...  ELSE    Get f1uplane Ipv6 Address For vDU
    Delete Uplane Trace File On Dcap Server For Certain vDU Site    ${f1u_ip}
    ${cell_list}    create list
    FOR   ${cell_id}    IN    @{nr_cell_list}
          ${cell_id}    set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
          append to list   ${cell_list}    ${cell_id}
    END
    vDU Login   vdu_index=${vdu_index}
    Update User Plane Trace Configuration For vDU    uplane_ip_addr=${dcap_server_ip}      uplane_port=55900   dscp=${dscp}
    ${trace_id}=   Start Uplane Trace For vDU    target_component=L2Ps     nr_cell_dn_list=${cell_list}    trace_type=Component
    set test variable    ${trace_id}
    set test variable    ${f1u_ip}
    [Teardown]  vDU Logout
Update User Plane Trace Configuration For vDU
    [Arguments]    ${uplane_ip_addr}    ${uplane_port}      ${dscp}=0
    [Documentation]   Update User Plane Trace Configuration
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | uplane_ip_addr      | yes | destination ip for dcap |
    ...   | uplane_port       | yes | user plane trace port in dcap |
    ...   | dscp              | yes | default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    return vdu_connection.update_uplane_configuration(uplane_ip_addr=uplane_ip_addr,
    ...                                   uplane_port=uplane_port,dscp=dscp,timeout=timeout)
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Update User Plane Trace Configuration | uplane_ip_addr=10.110.95.16  |  uplane_port=55900 |
    ...   | VDU Rest Logout |
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    ${res1}    vdu.update_uplane_configuration
    ...    uplane_ip_addr=${uplane_ip_addr}    uplane_port=${uplane_port_1}    dscp=${dscp_1}
    sleep    10s
    ${res2}    vdu.get_trs_api_operation_status    operation_id=${res1}
    [Return]    ${res2}
Start Uplane Trace For vDU
    [Arguments]    ${target_component}    ${nr_cell_dn_list}    ${trace_type}=Component
    [Documentation]   Start uplane Trace
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | target_component    | yes | which component trace: L2HiRlc/L2Lo/L2Ps|
    ...   | nr_cell_dn_list     | yes | which cell |
    ...   | trace_type          | yes | which trace type:Component/Sherpa |
    ...
    ...   *RETURN VALUE*
    ...   return vdu_connection.start_uplane_trace_stream(trace_type=trace_type,
    ...    target_component=target_component, nr_cell_dn_list=nr_cell_dn_list,timeout=timeout)
    ${res1}    vdu.start_uplane_trace_stream
    ...    target_component=${target_component}    nr_cell_dn_list=${nr_cell_dn_list}    trace_type=${trace_type}
    Log To Console    ${res1}
    sleep    3s
    ${res2}    vdu.get_active_trace_streams
    Log To Console    ${res2[0]['trace_id']}
    [Return]    ${res2[0]['trace_id']}
Delete Uplane Trace File On Dcap Server For Certain vDU Site
    [Arguments]    ${ip}
    [Documentation]  Delete Uplane Trace File On Dcap Server For Certain vDU Site
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ...    modified by:        <4-Aug-2021>, <rifeng>, <add argument ip>
    ...    modified by:        <18-Dec-2021>, <huilxu>, <add docker restart UDPTracer>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Delete Uplane Trace File On Dcap Server For Certain vDU Site    ${ip}|
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_UP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" -exec rm -rfv {} \\;    alias=${alias}
    sleep    10s
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\"    alias=${alias}
    ${trace_files}   convert to string    ${trace_files}
    Should Not Contain    ${trace_files}    ${ip}
    issh.Execute  command=docker restart UDPTracer   check_result=${False}  alias=${alias}
    sleep  10s
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
Stop And Download TTI Trace
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]  Stop and downlaod all the tti trace files
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <24-Dec-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnd_index  | No   |  the index of cu,  ${0} in default  |
    ...    |  vdu_index  | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  ${0}  |  ${0}  |
    log to console    Stop L2PS TTI trace and download the pcap file from DCAP server
    vDU Login   vdu_index=${vdu_index}
    Stop Uplane Trace For vDU    trace_id=${trace_id}
    ${TTI_local_path}=    Download Newest Uplane Trace Files for vDU From Dcap Server    ${f1u_ip}
    ${TTI_local_path_list}  create list  ${TTI_local_path}
    [Return]   ${TTI_local_path_list}
    [Teardown]  vDU Logout
Stop Uplane Trace For vDU
    [Arguments]    ${trace_id}
    [Documentation]   Stop uplane Trace
    ...   *AUTHOR* rita.feng@nokia-sbell.com
    ...   modified by:        <27-Jul-2021>, <rifeng>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | trace_id            | yes | which component trace |
    ${res1}    vdu.stop_uplane_trace_stream    trace_id=${trace_id}
    sleep    3s
    Log To Console    ${res1}
Get Latest Uplane Trace File Name for vDU On Dcap Server
    [arguments]    ${ip}
    [Documentation]  Get Latest Uplane Trace File Name for vDU On Dcap Server
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <4-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}|
    ${alias}    get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}    issh.Execute    command=cd ${DCAP_UP_LOG_DIR}    alias=${alias}
    ${trace_files}    issh.Execute    command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" | xargs ls --sort=time   alias=${alias}
    ${trace_files}  set variable  ${trace_files.replace("\r\n"," ")}
    ${trace_files}   Set Variable   ${trace_files.split()}
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Return From Keyword If    len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    [Return]    ${trace_files[0]}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}
Download Newest Uplane Trace Files for vDU From Dcap Server
    [arguments]    ${ip}
    [Documentation]  Download Newest Uplane Trace Files for vDU From Dcap Server
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <4-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Uplane Trace Files for vDU From Dcap Server    ${ip}|
    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
    ${local_dir}    Get A Directory    dcap_log    log_${curr_date}
    ${trace_file}    Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}
    Return From Keyword If    """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}    ${trace_file_name}    Split Path    ${trace_file}
    ${trace_file_name}    Set Variable    ${trace_file_name.replace(":", "")}
    ${alias}  get unique id
    Connect To DCAP    alias=${alias}
    issh.download file    remote_path=${trace_file}    local_path=${local_dir}/${trace_file_name}   alias=${alias}
    [Return]    ${local_dir}/${trace_file_name}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}
_Create Related Folders
    [Arguments]  ${conn_alias}
    ${home_dir}=  tafssh.execute  command=pwd   connection=${conn_alias}
    ${timestamp}=    Get Time    epoch
    ${home_dir}=  Strip String  ${home_dir}
    Set test Variable   ${ttiTrace_Dir}   ${home_dir}/ttiTrace_${timestamp}
    set test variable  ${tti_bins_dir}   ${ttiTrace_Dir}/tti-dec-bin/ttitrace_bins
    set test variable   ${decoded_csv}   ${ttiTrace_Dir}/tti-dec-bin/decoded_csv
    tafssh.Execute  command=mkdir ${ttiTrace_Dir} && mkdir -p ${tti_bins_dir} && mkdir -p ${decoded_csv}
    ...  connection=${conn_alias}
_Get Decode Tool And Untar
    [Arguments]   ${tool_base_repo}  ${vdu_version}  ${conn_alias}  ${package_name}=vDUCNF
    ${decoder_tool_name}=  set variable  ${package_name}_${vdu_version}_tti-dec_qemux86-64-static.txz
    ${tool_url}=  set variable  ${tool_base_repo}${vdu_version}/${decoder_tool_name}
    tafssh.Execute  command=wget --no-check-certificate ${tool_url} -P ${ttiTrace_Dir}  connection=${conn_alias}
    tafssh.Execute  command=cd ${ttiTrace_Dir} && tar -xJvf ${ttiTrace_Dir}/${decoder_tool_name} && rm -f ${decoder_tool_name}
    ...  connection=${conn_alias}
_Decode TTITRACE Bin Files And Download csv To Local
    [Arguments]   ${ttiTrace_files_list}   ${conn_alias}
    ${local_dl_csv}=  Get A Directory  ttiTrace_DL_CSV
    ${local_ul_csv}=  Get A Directory  ttiTrace_UP_CSV
    FOR    ${ttitrace_file}    IN    @{ttiTrace_files_list}
        ${path}  ${gz_file_name}=  OperatingSystem.Split Path  ${ttitrace_file}
        ${bin_file_name}=  Fetch From Left  ${gz_file_name}  marker=.tar.gz
        ${rest}  ${bin_file_index}=  Split String From Right  ${bin_file_name}  separator=.  max_split=1
        tafssh.upload_file  local_path=${ttitrace_file}
        ...  remote_path=${tti_bins_dir}/${gz_file_name}  connection=${conn_alias}
        tafssh.Execute  command=cd ${tti_bins_dir} && tar -zxvf ${gz_file_name} && rm -f ${gz_file_name}
        ...  connection=${conn_alias}
        ${decode_cmd}  Catenate  cd ${ttiTrace_Dir}/tti-dec-bin;
        ...  python3 TtiTraceDecoder.py ${tti_bins_dir}/${bin_file_name} excelCsv -o ${decoded_csv}/tti_${bin_file_index}
        tafssh.execute  command=${decode_cmd}   connection=${conn_alias}
        ${dl_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_dl.csv   connection=${conn_alias}
        ${ul_file_exists}=  tafssh.file exists   ${decoded_csv}/tti_${bin_file_index}_ul.csv   connection=${conn_alias}
        run keyword if    "${dl_file_exists}"=="True"    tafssh.download file    remote_path=${decoded_csv}/tti_${bin_file_index}_dl.csv
        ...  local_path=${local_dl_csv}/tti_${bin_file_index}_dl.csv  connection=${conn_alias}
        run keyword if    "${ul_file_exists}"=="True"    tafssh.download file    remote_path=${decoded_csv}/tti_${bin_file_index}_ul.csv
        ...  local_path=${local_ul_csv}/tti_${bin_file_index}_ul.csv  connection=${conn_alias}
    END
    [Return]  ${local_dl_csv}  ${local_ul_csv}
Begin Wireshark F1 Log On CU
    [Arguments]  ${filter}=sctp
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin to capture wireshark log on F1 interface
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark F1 Log On CU |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | End Wireshark F1 Log On CU | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    Begin Wireshark F1 Log On CU
    ${vcu_nf_type}   Get VCU NF Type
    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark F1 Log On CU CNF   filter=${filter}
    ...   ELSE     _Begin Wireshark F1 Log On CU VNF   filter=${filter}
    [Return]    ${handle}
End Wireshark F1 Log On CU
    [Arguments]    ${handle}    ${local_pcap_file_name}
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End Wireshark F1 Log On CU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | handle               | yes | a handler returned by 'Begin Wireshark F1 Log On CU ' |
    ...    | local_pcap_file_name | yes | locall pcap file where you want to save wireshark log  |
    ...
    ...    *RETURN VALUE*
    ...    the local captured pcap file name of F1 Wireshark Log On CU CNF, which is same as input parameter ${local_pcap_file_name}
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark F1 Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | End Wireshark F1 Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    End Wireshark F1 Log On CU
    ${tmp}  Split String   ${handle}  _
    ${alias}   Set Variable   ${tmp[0]}
    ${tmpfile_pcap}   Set Variable   ${handle.replace("${alias}_","")}
    ${vcu_nf_type}   Get VCU NF Type
    run keyword if   "${vcu_nf_type}"=="CNF"
      ...          _End Wireshark VCUC     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
      ...   ELSE   _End Wireshark VCU VNF    log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    [Return]   ${local_pcap_file_name}
_Begin Wireshark F1 Log On CU CNF
    [Arguments]  ${filter}=sctp
    [Documentation]    _Begin Wireshark F1 Log On CU CNF
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...
    ${pod_abbr}   Set Variable   cpif
    ${container}  Set Variable   cpif
    ${alias}   Connect To CU Node   pod_abbr=${pod_abbr}
    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=f1c  pod_abbr=${pod_abbr}   container=${container}  alias=${alias}
             ...   filter=${filter}
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}
_Begin Wireshark VCUC
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     ...     ${index}=0      ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}
     [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    Target server includes VCU VM/VDU container/FHGW/FHGW ruproxy container/wireshark server/UTE server/CMP server/Classical OAM/NOM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | index     | No | when host_type is VDUC, it means vdu_index, default value is 0. Note: it's not used when host_type is FHGW |
    ...    | alias      | No | alias name  |
    ...    | pod_abbr  | No | when host_type is VDUC, it is used |
    ...    | container | No | when host_type is VDUC, it is used |
    ...
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be automatically deleted after calling 'End Wireshark'.
    ...
    ...    Example
    ...
    ...    For VCUC(VCU CNF Container)
    ...    | ${alias} | Connect To CU K8S Master With Admin | vdu_index=0  |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=f1c | host_type=VCUC | pod_abbr=cpif | container=cpif | alias=${alias} |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=${alias} |
    ...    | disconnct interactively connection | alias=${alias} |
    ...
    ${host_type}   Set Variable   VCUC
    ${tmpfilefullpath}    _Begin Tcpdump Wireshark VCUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}  index=${index}   alias=${alias}
    [Return]     ${tmpfilefullpath}
_Begin Wireshark F1 Log On CU VNF
    [Arguments]  ${filter}=sctp
    [Documentation]   _Begin Wireshark F1 Log On CU VNF
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ${alias}   Get Unique ID
    CU SSH To CPIF    alias=${alias}
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=fronthaul    filter=${filter}   alias=${alias}
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}
_Begin Tcpdump Wireshark VCUC
    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
    [Teardown]  Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias2}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    ${host_type}  Set Variable  VCUC
    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${alias2}   Connect To CU K8S Master With Admin
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${index}  alias=${alias2}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}  alias=${alias2}
    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}  alias=${alias2}
    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap
    ${pid}   Get PID For Container In VCU    pod_abbr=${pod_abbr}    ctr_abbr=${container}   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    #start capture
    ${full_cmd}   set variable  sudo nsenter -m -n -t ${pid} ${cmd}
    Log To Console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   6s
    ${out}   issh.Execute    command=ps -ef|grep tcpdump   alias=${alias2}
    Log To Console  ${out}
    [Return]    ${tmpfilenamefullpath}
_Begin Wireshark VNF
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     ...     ${index}=0
     [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    Target server includes VCU VM/VDU container/FHGW/FHGW ruproxy container/wireshark server/UTE server/CMP server/Classical OAM/NOM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | index     | No | when host_type is VDUC, it means vdu_index, default value is 0. Note: it's not used when host_type is FHGW |
    ...    | alias      | No | alias name  |
    ...    | pod_abbr  | No | when host_type is VDUC, it is used |
    ...    | container | No | when host_type is VDUC, it is used |
    ...
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be automatically deleted after calling 'End Wireshark'.
    ...
    ...    Example
    ...
    ...
    ${host_type}   Set Variable   VCU
    Log To Console  Begin Wireshark, host_type:${host_type}
    ${tmpfilefullpath}   _Begin Tcpdump Wireshark VCU    interface=${interface}    filter=${filter}
      ...    index=${index}   alias=${alias}
    [Return]     ${tmpfilefullpath}
_Begin Tcpdump Wireshark VCU
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   _Wireshark Get Host Type Interactively   alias=${alias}   gnb_index=${index}
    Log To Console  Begin Wireshark, hostname:${host_type}
    ${tmpfilefullpath}   Run Keyword If  "VCUOAMMASTER"=="${host_type}"
         ...   _Begin Tcpdump Wireshark VCU OAM  interface=${interface}  filter=${filter}  alias=${alias}   index=${index}
    ...    ELSE IF   "VCUOTHER"=="${host_type}"
         ...   _Begin Tcpdump Wireshark VCU Other  interface=${interface}  filter=${filter}  alias=${alias}    index=${index}
    [Return]    ${tmpfilefullpath}
_Begin Tcpdump Wireshark VCU OAM
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   Set Variable  VCUOAMMASTER
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}
    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap
    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}
_Begin Tcpdump Wireshark VCU Other
    [Arguments]    ${interface}    ${filter}   ${alias}   ${index}=0
    ${host_type}   Set Variable  VCUOTHER
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}
    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap
    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}
_Get Temp File Name
    [Arguments]  ${host_type}=${EMPTY}   ${fhgw_or_vdu_index}=0   ${pod_abbr}=${EMPTY}  ${container_id}=${EMPTY}
    ${unique_id}  Get Unique ID
    ${host_type}   Set Variable If   "${host_type}"=="${EMPTY}"   z   ${host_type}
    ${pod_abbr}   Set Variable If   "${pod_abbr}"=="${EMPTY}"   z   ${pod_abbr}
    ${container_id}   Set Variable If   "${container_id}"=="${EMPTY}"   z   ${container_id}
    ${file_name}   Set Variable   ${host_type}_${fhgw_or_vdu_index}_${pod_abbr}_${container_id}_${unique_id}
    [Return]  ${file_name}
_End Wireshark VCUC
    [Arguments]     ${log_dst_path}    ${log_src_path}   ${alias}=default
    [Documentation]    Stop capturing wireshark log and get log to local.
    ...    Target server includes VDU container/FHGW/wireshark server/UTE server/CMP server/Classical OAM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | log_dst_path  |  Yes | the destination log location in DebianVM |
    ...    | log_src_path | Yes | the source log location of VM, RAP,wireshark server, compute node, or other SERVER |
    ...    | alias       | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    Please refer to examples of 'Begin Wireshark'
    ...
    Sleep  2
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${log_src_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${host_type}  Set Variable  ${tmp[1]}
    ${host_type}    Set Variable  ${host_type.upper()}
    Should Be True   "${host_type}"=="VCUC"
    ${tmpfilefullpath}   _Get Wireshark From VCUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    [Return]   ${log_dst_path}
_Get Wireshark From VCUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Teardown]  Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias_new}
    [Documentation]   _Get Wireshark From VCUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From VCUC | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e4911_ec22b41be53342c7a9a3f20d0d8a1e8d.pcap | /home/ute/oam.pcap |
    ...
    ${out}   Send CTRL_C Interactively    alias=${alias}
    sleep  2
    ${out}   issh.Execute  command=sync     alias=${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    #parse vcu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vcu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}
    ${alias_new}  Connect To CU K8S Master With Admin   gnb_index=${vcu_index}
    ${ns}     Get CU Namespace From Testline  gnb_index=${vcu_index}
    ${pod_full_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${vcu_index}  alias=${alias_new}
    ${container_full_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}
    Log To Console   _Get Wireshark From VCUC's container:${container}
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- sync
            ...  check_result=False   alias=${alias_new}
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- chmod 777 ${initial_log_path}
            ...  check_result=False   alias=${alias_new}
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  check_result=False   alias=${alias_new}
    ${out}    issh.Execute     command=mkdir -p ${pcap_folder}    alias=${alias_new}
    ${out}    issh.Execute     command=ls -l ${pcap_folder}   alias=${alias_new}
    #${remote_log_path}   set variable   /tmp/tmp_wireshark/${initial_log_path}
    ${remote_log_path}   set variable   ${initial_log_path}
    #${cp_cmd}   set variable   kubectl cp ${pod_full_name}:${initial_log_path} ${remote_log_path} -c ${container_full_name} -n ${ns}
	${cp_cmd}   set variable   
    ...    kubectl exec ${pod_full_name} -c ${container_full_name} -n ${ns} -- /bin/gzip -c ${pcap_folder}/${pcap_file}|gunzip > ${remote_log_path}
    ${out}    issh.Execute     command=${cp_cmd}    alias=${alias_new}
    ${out}    issh.Execute     command=sync    alias=${alias_new}
    issh.Download File   remote_path=${remote_log_path}    local_path=${log_stored_path}   alias=${alias_new}
    ${out}  issh.Execute  command=rm -f ${remote_log_path}     alias=${alias_new}
    _Delete Old Wireshark File In VCUC   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias_new}
    _Delete Old Wireshark File In VCUC Master Node   initial_log_path=${initial_log_path}   alias=${alias_new}
_Delete Old Wireshark File In VCUC
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -f ${initial_log_path}
            ...  check_result=False   alias=${alias}
    _Remove All Temp File If Needed From VCUC   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}
_Remove All Temp File If Needed From VCUC
    [Arguments]  ${FolderName}   ${pod_full_name}   ${container_full_name}  ${ns}  ${alias}
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${FolderName}
            ...  check_result=False   alias=${alias}
    ${out}  strip prompt   ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd VCUC   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}
      ...   alias=${alias}
    ${lines}   split to lines   ${out}
    ${threshold}   Set Variable   3600
    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        ${bExist}   Check File Existed In VCUC   ${fullname}
        ...  pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC   foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}
        ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}    alias=${alias}
    END
Check File Existed In VCUC
    [Arguments]  ${filename}  ${pod_full_name}  ${container_full_name}   ${alias}=default
    [Documentation]   Check File Exist or not inside VCU container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename      | yes | file name |
    ...    | container_id | yes | container_id |
    ...    | alias        | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return 1 if file exists, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check File Existed In VDUC |  filename=/root/a.txt | container_id=123adadf23 | alias=default |
    ...
    ${ns}   get cu namespace from testline
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls ${filename}
            ...  check_result=False   alias=${alias}
    ${bExist}   Set Variable If     """No such file or directory""" in """${out}"""     0     1
    Return From Keyword If  ${bExist}==0   0
    ${bExist}   Set Variable If     """syntax error near unexpected token""" in """${out}"""     0     1
    [Return]   ${bExist}
_Remove One Temp File If Needed VCUC
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}  ${pod_full_name}   ${container_full_name}  ${alias}
    # ${foldername}:  /tmp/tmp_wireshark
    ${ns}  get cu namespace from testline
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd VCUC   filename=${fullname}  pod_full_name=${pod_full_name}
    ...   container_full_name=${container_full_name}  alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    ${out}  Run Keyword If   ${bDeleteIt}==1
    ...   issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -rf ${fullname}
    ...  check_result=False   alias=${alias}
Get Modified Time By Linux Cmd VCUC
    [Arguments]    ${filename}   ${pod_full_name}   ${container_full_name}  ${alias}=default
    [Documentation]     Get Modified Time By Linux Cmd inside VCU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filename | yes | file name |
    ...    | container_id  | yes | container_id |
    ...    | alias    | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Modified Time By Linux Cmd VCUC | filename=/root/a.txt | container_id=${conainer_id} |
    ${ns}  get cu namespace from testline
    ${out}  issh.Execute
            ...  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- stat --format=%Y ${filename}
            ...  check_result=False   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{8,20}
    [Return]   ${lines}
_Delete Old Wireshark File In VCUC Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   issh.Execute   command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed In VCUC Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}
_Remove All Temp File If Needed In VCUC Master Node
    [Arguments]  ${FolderName}    ${alias}=default
    ${out}   issh.Execute  command=ls -F -1 ${FolderName}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${curr_time}    Get Current Host Time By Linux Cmd Interactively  alias=${alias}
    ${lines}   split to lines   ${out}
    ${threshold}   Set Variable   7200
    FOR   ${file}    IN    @{lines}
        Continue For Loop If   '${file}'==''
        ${fullname}   Join Path   ${FolderName}   ${file}
        #${bExist}   Check File Existed    ${fullname}   alias=${alias}
        ${bExist}     Check File Existed In Linux Server Via Interactive SSH   ${fullname}   alias=${alias}
        Continue For Loop If   ${bExist}==0
        _Remove One Temp File If Needed VCUC Master Node    foldername=${FolderName}   filename=${file}
        ...   curr_time=${curr_time}     thrashold=${threshold}   alias=${alias}
    END
_Remove One Temp File If Needed VCUC Master Node
    [Arguments]    ${foldername}   ${filename}    ${curr_time}    ${thrashold}   ${alias}=default
    # ${foldername}:  /tmp/tmp_wireshark
    ${fullname}    Join Path    ${foldername}     ${filename}
    ${filemtime}    Get Modified Time By Linux Cmd Interactively  filename=${fullname}   alias=${alias}
    ${delta}    Evaluate   ${curr_time}-${filemtime}
    ${bDeleteIt}    Set Variable If    ${delta}>${thrashold}    1      0
    #${sudo}   Get Sudo   alias=${alias}
    Run Keyword If   ${bDeleteIt}==1   issh.Execute   command=rm -rf ${fullname}    alias=${alias}
_End Wireshark VCU VNF
    [Arguments]     ${log_dst_path}    ${log_src_path}   ${alias}=default
    [Documentation]    Stop capturing wireshark log and get log to local.
    ...    Target server includes VDU container/FHGW/wireshark server/UTE server/CMP server/Classical OAM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | log_dst_path  |  Yes | the destination log location in DebianVM |
    ...    | log_src_path | Yes | the source log location of VM, RAP,wireshark server, compute node, or other SERVER |
    ...    | alias       | No | alias name, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    Please refer to examples of 'Begin Wireshark'
    ...
    Sleep  2
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${log_src_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${host_type}  Set Variable  ${tmp[1]}
    ${host_type}    Set Variable  ${host_type.upper()}
    Log To Console  End Wireshark, host_type:${host_type}
    ${host_type}   Set Variable  ${host_type[0:3]}
    Should Be True   "${host_type}"=="VCU"
    ${tmpfilefullpath}   _Get Wireshark From VCU   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}    alias=${alias}
    [Return]   ${log_dst_path}
_Get Wireshark From VCU
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]   _Get Wireshark From VCU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU  |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap  |
    ...
    Send CTRL_C Interactively    alias=${alias}
    ${out}   issh.Execute  command=sync     alias=${alias}
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${hosttype}  Set Variable  ${tmp[1]}
    ${gnb_index}  Set Variable  ${tmp[2]}
    Run Keyword If  "${host_type}"=="VCUOAMMASTER"
         ...   _Get Wireshark From VCU OAM Master  initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${alias}  gnb_index=${gnb_index}  capture_on_master_oam=${True}
         ...   ELSE   _Get Wireshark From VCU Other  initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${alias}  gnb_index=${gnb_index}
_Get Wireshark From VCU Other
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default  ${gnb_index}=0
    [Documentation]   _Get Wireshark From VCU OAM Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap |
    ...
    ${tmp_alias}  Get Unique Id
    CU SSH To OAM   gnb_index=${gnb_index}   alias=${tmp_alias}
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${serviceuser_home_folder}  Set Variable  /home/serviceuser
    ${pcap_file_under_serviceuser_home_folder}   OperatingSystem.Join Path  ${serviceuser_home_folder}   ${pcap_file}
    issh.Execute   command=mkdir -p ${serviceuser_home_folder}    alias=${tmp_alias}
    issh.Execute   command=chown serviceuser:serviceuser ${serviceuser_home_folder}  alias=${tmp_alias}
    issh.Execute   command=chmod 777 ${serviceuser_home_folder}   alias=${tmp_alias}
    ${master_oam_index}   CU Get Master VM Index   gnb_index=${gnb_index}   vm_type=OAM
    issh.Execute   command=scp ${initial_log_path} oam-${master_oam_index}.local:${pcap_file_under_serviceuser_home_folder}   alias=${alias}
    _Get Wireshark From VCU OAM Master    initial_log_path=${initial_log_path}  log_stored_path=${log_stored_path}
         ...   alias=${tmp_alias}  gnb_index=${gnb_index}  capture_on_master_oam=${False}
    issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=/tmp/tmp_wireshark/    alias=${alias}
    Disconnect Interactive Connection  alias=${tmp_alias}
_Get Wireshark From VCU OAM Master
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default  ${gnb_index}=0   ${capture_on_master_oam}=${True}
    [Teardown]  run keyword and ignore error  Disconnect Interactive Connection  alias=${tmp_alias}
    [Documentation]   _Get Wireshark From VCU OAM Master
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap |
    ...
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${serviceuser_home_folder}  Set Variable  /home/serviceuser
    ${pcap_file_under_serviceuser_home_folder}   OperatingSystem.Join Path  ${serviceuser_home_folder}   ${pcap_file}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute   command=mkdir -p ${serviceuser_home_folder}    alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute
                     ...   command=chown serviceuser:serviceuser ${serviceuser_home_folder}  alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"
                     ...   issh.Execute   command=chmod 777 ${serviceuser_home_folder}  alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute
                     ...  command=cp ${initial_log_path} ${pcap_file_under_serviceuser_home_folder}  alias=${alias}
    issh.Execute   command=chown serviceuser:serviceuser ${pcap_file_under_serviceuser_home_folder}  alias=${alias}
    issh.Execute  command=chmod 777 ${pcap_file_under_serviceuser_home_folder}   alias=${alias}
    ${tmp_alias}  Get Unique Id
    # connect to ute   hostname=127.0.0.1    alias=${tmp_alias}
    Connect To UTE Locally    alias=${tmp_alias}
    Download File From VCU OAM Via SCP     remote_file=${pcap_file_under_serviceuser_home_folder}  local_file=${log_stored_path}
      ...   gnb_index=${gnb_index}   alias=${tmp_alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"  issh.Execute  command=rm -f ${initial_log_path}     alias=${alias}
    issh.Execute  command=rm -f ${pcap_file_under_serviceuser_home_folder}     alias=${alias}
    Run Keyword If   "${capture_on_master_oam}"=="${True}"   _Remove All Temp File If Needed From General Linux Server
        ...   FolderName=/tmp/tmp_wireshark/   alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=${serviceuser_home_folder}   alias=${alias}
Download File From VCU OAM Via SCP
    [Arguments]  ${remote_file}   ${local_file}   ${alias}=default  ${gnb_index}=0
    [Documentation]   Download File From VCU OAM Via SCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  remote_file  |  Yes |  Where is log stored on wireshark server |
    ...    |  local_file | Yes | Where to save log on local PC  |
    ...    |  alias           | no | default value is default |
    ...    |  gnb_index       | no |  default is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${alias} | Get Unique ID |
    ...    |  Connect To UTE Locally  |  alias=${alias} |
    ...    |  _Get Wireshark From VCU OAM Master | /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap | /home/ute/oam.pcap | alias=${alias} |
    ...
    ${gnbs}    tl_info.Get_Cloudbts_Gnbs    ${tl}
    ${addr}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${username}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${password}   Set Variable  ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ${bIpV6Address}    Set Variable If    ":" in """${addr}"""    1      0
    ${option}   Set Variable  -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${old_prompt}   issh.Set Prompt   prompt_str=assword:    alias=${alias}
    ${cmd}   Set Variable If   ${bIpV6Address}==0    sudo scp -r ${option} ${username}@${addr}:${remote_file} ${local_file}
    ...    sudo scp -6 -r ${option} ${username}@[${addr}]:${remote_file} ${local_file}
    ${out}  issh.Execute   command=${cmd}    check_result=${False}   alias=${alias}
    issh.Set Prompt   prompt_str=${old_prompt}    alias=${alias}
    ${out}  issh.Execute   command=${password}  check_result=${False}  alias=${alias}
Get Current Host Time By Linux Cmd VCUC
    [Arguments]  ${pod_full_name}  ${container_full_name}  ${alias}=default
    [Documentation]    Get Current Host Time By Linux Cmd
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    No input parameter.
    ...
    ...    *RETURN VALUE*
    ...     time with unit of second.
    ...
    ...    Example
    ...    | ${sec} | Get Current Host Time By Linux Cmd |
    ${ns}  get cu namespace from testline
    ${out}  issh.Execute  command=kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- date +%s
            ...  check_result=False   alias=${alias}
    ${lines}  Get Lines Matching Regexp   ${out}   \\d{5,20}
    [Return]   ${lines}
