*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_other.robot



#*** Variables ***



*** Keywords ***
######## Bip Keywords #########
_Begin BIP Log Capture NCS
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    #...          ${mbuf}=False  ${mbuf-size}=10000  ${total-num-mbufs}=2048
    [Documentation]    Begin BIP Log Capture in vDU
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    how to use:
    ...    | Connect to vDU Node | pod_abbr=up | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=l1bipl1 | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |

    Log To Console  _Begin BIP Log Capture NCS
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${vdu_index}
    Log To Console   ${vdu_index}/${pod_abbr}/${container}:${container_id}

    ${sudo}    Get Sudo VDUC     container_id=${container_id}    alias=${alias}
    ${out}    tafssh.Execute     command=${sudo} docker exec -it ${container_id} mkdir -p /tmp/dpdk    connection=${alias}
    ${out}    tafssh.Execute     command=${sudo} docker exec -it ${container_id} ls /tmp/dpdk   connection=${alias}

    #${tmpfilename}=
    #...  _Get Temp File Name  host_type=${container}  fhgw_or_vdu_index=${vdu_index}  pod_abbr=${pod_abbr}  container_id=${container_id}
    #${tmpfilename}=  Get Substring  ${tmpfilename}  0  30
    #${tmpfilenamefullpath}    Set Variable    /tmp/dpdk/${tmpfilename}
    ${tmpfilenamefullpath}    Set Variable    /tmp/dpdk/${port_name}
    #${cpu_out}    tafssh.Execute     command=docker exec -it ${container_id} env | grep -i SHARED_CPUS   connection=${alias}
    #${cpu_out}=  strip string  ${cpu_out}  characters=\r\n
    #${SHARED_CPUS}=    evaluate  re.split('=','${cpu_out}')  re
    #${cpu}=  set variable  ${SHARED_CPUS[1]}
    #${DPDK_out}    tafssh.Execute     command=docker exec -it ${container_id} env | grep EM_DPDK_FILEPREFIX   connection=${alias}
    #${DPDK_out}=  strip string  ${DPDK_out}  characters=\r\n
    #${EM_DPDK_FILEPREFIX}=    evaluate  re.split('=','${DPDK_out}')  re
    #${file-prefix}=  set variable  ${EM_DPDK_FILEPREFIX[1]}
    #log to console  ${cpu} ${file-prefix}
    ${bip_port_id}    tafssh.Execute    ${sudo} docker exec -it ${container_id} dpdk-cli show port table | grep ${port_name} | awk '{print $1}'
    ...    connection=${alias}
    #${cmd}=  set variable  dpdk-pdump -l${cpu} -n4 --proc-type=secondary --file-prefix=${file-prefix} --
    #${cmd}=  set variable  ${cmd} --pdump port=${port},queue=*,rx-dev=${tmpfilenamefullpath}_rx.pcap,tx-dev=${tmpfilenamefullpath}_tx.pcap
    #${cmd}=  set variable if  '${mbuf}'=='True'  ${cmd},mbuf-size=${mbuf-size},total-num-mbufs=${total-num-mbufs}    ${cmd}

    ${cmd}=  set variable    dpdk-cli pdump port ${bip_port_id}
    ${cmd}    Set Variable     ${sudo} ${cmd}
    log to console  ${cmd}

    #prepare dpdk_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

    ${target}   Create List   ${pod_abbr}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  tafssh.Execute  command=${sudo} rm -f ${version_file}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    tafssh.Send Command    command=${sudo} docker exec -it ${container_id} bash -c "cd /tmp/dpdk && ${cmd}"   connection=${alias}   get_pty=${True}
    Sleep   6s

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${port_name}.pcap &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}

_Begin BIP Log Capture OCP
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    #...          ${mbuf}=False  ${mbuf-size}=10000  ${total-num-mbufs}=2048
    [Documentation]    Begin BIP Log Capture in vDU
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...    how to use:
    ...    | Connect to vDU Node | pod_abbr=up | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=l1bipl1 | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |

    Log To Console  _Begin BIP Log Capture OCP
    ${ns}   Get VDU Namespace From TestLine
    ${pod_name} =    Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=up    alias=${alias}    vdu_index=${vdu_index}
    ${container_name} =   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${command_str}    Set Variable    kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} bash -- mkdir -p /tmp/dpdk    alias=${alias}
    ${out}    issh.Execute     command=${sudo} ${command_string}
    ${tmpfilenamefullpath}    Set Variable    /tmp/dpdk/${port_name}
    ${cmd}    Catenate    SEPARATOR=
    ...    ${sudo} kubectl exec -it ${pod_name} -c ${container_name} -n
    ...    ${ns} bash -- dpdk-cli show port table | grep ${port_name} | awk '{print $1}'
    ${bip_port_id}    issh.Execute    command=${cmd}
    ...                                 alias=${alias}
#    ${sudo}    Get Sudo VDUC    container_id=${container_id}   alias=${alias}
#    ${cmd}=  set variable    dpdk-cli pdump port ${bip_port_id}
#    ${cmd}    Set Variable     ${sudo} ${cmd}
#    log to console  ${cmd}
    #prepare dpdk_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo
    ${target}   Create List   ${pod_abbr}
    ${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  tafssh.Execute  command=${sudo} rm -f ${version_file}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  issh.Execute  command=ls ${tcpdump_guard}   alias=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""
    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
    #start capture

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_vdu_ocp"]} -a ${port_name}.pcap &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}   alias=${alias_process_guard}
    Log To Console  ${out}
    Sleep   6s
    Log To Console  Begin capture BIP Log in OCP
    issh.Execute    command=${sudo} kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- bash -c "cd tmp; dpdk-cli pdump port 1"
    ...                    alias=${alias}
    [Return]    ${tmpfilenamefullpath}

Begin BIP Log Capture
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${pod_abbr}=up   ${container}=l1hi  ${port_name}=l1bipl1  ${vdu_index}=0  ${alias}=default
    ...          ${mbuf}=False  ${mbuf-size}=10000  ${total-num-mbufs}=2048
    [Documentation]  get file from pmcore container to local UTE. The file will be stored under UTE
    ...  ${OUTPUT_DIR}/${TEST_NAME}/${START_TIME}/pm_related directory.
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod_abbr(eg: up)|
    ...    how to use:
    ...    | Connect to vDU Node | pod_abbr=up | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | {tmpfile_pcap}=  | Begin BIP Log Capture | pod_abbr=up | container=l1hi | port_name=l1bipl1 | vdu_index=0| alias=alias2 |
    ...    | Sleep            | 3min |
    ...    | Stop BIP Capture And Download | initial_log_path={tempfile_path} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |

    ...    *RETURN VALUE*
    ...    ${tmpfilenamefullpath}
    ${platform}   Get Platform Name
    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...             _Begin BIP Log Capture NCS    pod_abbr=${pod_abbr}    container=${container}
    ...                                           port_name=${port_name}    vdu_index=${vdu_index}
    ...                                           alias=${alias}    mbuf=${mbuf}
    ...                                           mbuf-size=${mbuf-size}    total-num-mbufs=${total-num-mbufs}
    ...     ELSE    _Begin BIP Log Capture OCP    pod_abbr=${pod_abbr}    container=${container}
    ...                                           port_name=${port_name}    vdu_index=${vdu_index}
    ...                                           alias=${alias}    mbuf=${mbuf}
    ...                                           mbuf-size=${mbuf-size}    total-num-mbufs=${total-num-mbufs}
    [Return]    ${tmpfilenamefullpath}

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

    #parse vdu_index, pod_appr, docker_id
    #${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    #${tmp}   Split String  ${pcap_file}  _
    #${container}  Set Variable  ${tmp[0]}
    #${vdu_index}  Set Variable  ${tmp[1]}
    #${pod_abbr}  Set Variable  ${tmp[2]}
    #${container_id}   Set Variable  ${tmp[3]}
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

_Stop BIP Capture And Download For OCP
    [Arguments]  ${alias}   ${k8s_log_path}=/tmp/dpdk/l1bipl1
    ...          ${initial_log_path}=/tmp/l1bipl1   ${container}=l1hi
    ...          ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   _Stop BIP Capture And Download For OCP
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
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
    ${out}    issh.Execute     command=${sudo} kubectl exec -it ${up_pod_name} -c ${container_name} -n cran1 sync    alias=${alias}
    ${out}    issh.Execute     command=${sudo} kubectl exec -it ${up_pod_name} -c ${container_name} -n cran1 -- chmod 777 ${initial_log_path}.pcap
    ...                          alias=${alias}
    ${out}    issh.Execute     command=${sudo} mkdir -p /tmp/dpdk   alias=${alias}
    ${out}    issh.Execute     command=ls -l /tmp/dpdk   alias=${alias}
    ${kubectl_cp}   Set Variable   ${sudo} kubectl cp -n ${ns} ${up_pod_name}:${initial_log_path}.pcap ${k8s_log_path}.pcap -c ${container_name}
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

Stop BIP Capture And Download
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${alias}   ${initial_log_path}   #${container}=l1hi   ${vdu_index}=0
    [Documentation]    Stop BIP Capture And Download from VDU
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
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
    [Return]    ${local_file_path}


_Delete Old Bip File
    [Arguments]  ${initial_log_path}   ${alias}=default    ${FolderName}=/tmp/tmp_wireshark
    ${res}   issh.Execute   command=ls -l ${FolderName}   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}

##### TTI trace Keywords ######
Stop And Download TTI Trace
    [Arguments]    ${pod_name}=${up_pod_name}    ${container_name}=${l2_rt_container}    ${vdu_index}=${0}
    [Documentation]  Stop and downlaod all the tti trace files
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    Log To Console     connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}   vdu_index=${vdu_index}
    Log To Console     stop the tti trace collection
    Execute Command In Container    kill -9 ${process_id}   bash
    Execute Command In Container    cd /var/eventsTrace/
    ${output} =    Execute Command In Container    ls   bash
    ${tti_files} =     Get Regexp Matches     ${output}     \\w+EventsSnapshot\.bin\.\\d+\.tar\.gz
    ${tti_files_number} =     Get Length     ${tti_files}
    ${trace_path_list}=    Download TTI Trace Directory From VDU    pod_name=up     container_name=l2rt
    ...      file_path=/var/eventsTrace    file_name_list=${tti_files}     vdu_index=${vdu_index}
    log    ${trace_path_list}
    [return]    ${trace_path_list}
    [teardown]    Exit From Container


Download TTI Trace Directory From VDU
    [Arguments]    ${pod_name}    ${container_name}    ${file_path}
    ...            ${file_name_list}    ${vdu_index}=${0}   ${gnb_index}=${0}
    [Tags]  CLOUD_PLATFORM_SPECFIC
    [Documentation]  Download all the files in specific dir to ute
    ...    author: xianbiao.cheng@nokia-sbell.com
    ...    modified by:        <17-Aug-2021>, <lingtsun>, <Initial creation for ocp adaption>
    ...    modified by:        <30-sep-2021>, <hongysun>, <Initial creation for ocp adaption>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the abbr name of pod, such as up |
    ...    |  container_name   | No   |  the container name, such as l2rt |
    ...    |  file_path        | No   |  file_path in OE |
    ...    |  file_name_list   | No   |  tti trace file name list |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    |  gnb_index        | No   |  the index of vcu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    ${platform_name}   Get Platform Name   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${trace_path_list}   run keyword if   "${platform_name}"=="NCS"
    ...  _Download TTI Trace Directory From VDU NCS   pod_name=${pod_name}  container_name=${container_name}   file_path=${file_path}
    ...            file_name_list=${file_name_list}    vdu_index=${vdu_index}
    ...   ELSE IF   "${platform_name}"=="OCP"
    ...  _Download TTI Trace Directory From VDU OCP   pod_name=${pod_name}  container_name=${container_name}   file_path=${file_path}
    ...            file_name_list=${file_name_list}    vdu_index=${vdu_index}
    [return]   ${trace_path_list}

Start To Collect TTI Trace
    [Arguments]     ${vdu_index}=${0}
    [Documentation]  Start to collect L2RT TTI trace
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Start To Collect TTI Trace |  ${0}  |
    vDU Cluster Login With Tenant     vdu_index=${vdu_index}
    log to console    start to collect the tti trace
    ${up_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=up    vdu_index=${vdu_index}
    set test variable    ${up_pod_name}
    FOR  ${container}  IN  @{AIC_VDU_PODS['up']}
       run keyword if    'l2rt' in '${container}'   set test variable   ${l2_rt_container}   ${container}
    END
    ${l2_rt_container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${l2_rt_container}
    set test variable    ${l2_rt_container}
    Collect TTI Trace in L2RT    pod_name=${up_pod_name}    container_name=${l2_rt_container}    vdu_index=${vdu_index}


Collect TTI Trace in L2RT
    [Arguments]    ${pod_name}    ${container_name}    ${vdu_index}=${0}
    [Documentation]  Login to L2RT and run eventsCollect.sh
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | Yes   |  the full name of up |
    ...    |  container_name   | Yes   |  the full name of l2rt |
    ...    |  vdu_index        | No    |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Collect TTI Trace in L2RT |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    log to console    connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}    vdu_index=${vdu_index}
    #log to console    modify eventsCollect.sh
    #execute command in container     sed -i 's/WAIT_TIME=0.2s/WAIT_TIME=0.1s/g' /opt/nokia/tools/ttiTrace/eventsCollect.sh
    log to console    empty /var/eventsTrace
    Execute Command In Container     rm -rf /var/eventsTrace, \#
    log to console    run eventsCollect.sh
    ${output} =    Execute Command In Container     nohup bash /opt/nokia/tools/ttiTrace/eventsCollect.sh > /tmp/tti_logs 2>&1 &    bash
    ${process_id_temp} =     Get Regexp Matches     ${output}     \\s\\d+
    ${process_id_temp} =     Get Regexp Matches     ${process_id_temp[0]}    \\d+
    Set Test Variable     ${process_id}     ${process_id_temp[0]}
    [teardown]    Exit From Container


Stop And Download Recent 3 TTI Trace
    [Arguments]    ${pod_name}=${up_pod_name}    ${container_name}=${l2_rt_container}    ${vdu_index}=${0}
    [Documentation]  Stop and downlaod recent 3 tti trace files
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <21-Apr-2020>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    | ${Trace_log}    Stop And Download Recent 3 TTI Trace|
    Log To Console     connect to l2rt container
    Connect To vDU Container    ${pod_name}    ${container_name}   vdu_index=${vdu_index}
    Log To Console     stop the tti trace collection
    Execute Command In Container    kill -9 ${process_id}   bash
    Execute Command In Container    cd /var/eventsTrace/
    ${output} =    Execute Command In Container    ls   bash
    ${tti_files_number} =     Get Regexp Matches     ${output}     \\w+EventsSnapshot\.bin\.(\\d+)\.tar\.gz     1
	${max_tti_files_number}    Evaluate    max([int(i) for i in ${tti_files_number}])
    log to console    ${max_tti_files_number}
    ${second_tti_files_number}    Evaluate    ${max_tti_files_number}-1
	${third_tti_files_number}    Evaluate    ${max_tti_files_number}-2
	${tti_files}   Create List   _L2TtiTrace_EventsSnapshot.bin.${max_tti_files_number}.tar.gz
	...  _L2TtiTrace_EventsSnapshot.bin.${second_tti_files_number}.tar.gz
    ...  _L2TtiTrace_EventsSnapshot.bin.${third_tti_files_number}.tar.gz
	${trace_path_list}=    Download TTI Trace Directory From VDU     pod_name=up     container_name=l2rt
    ...    file_path=/var/eventsTrace    file_name_list=${tti_files}     vdu_index=${vdu_index}
    log    ${trace_path_list}
    [return]    ${trace_path_list}
    [teardown]    Exit From Container

Kubectl CP Directory Files From Container To Cass Host
    [Arguments]    ${pod_abbr}    ${container_abbr}    ${container_directory_path}
    ...            ${host_directory_path}    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]  Download all the files in specific dir to ute for cloud platform OCP
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <17-Aug-2021>, <lingtsun>, <Initial creation
    ...                        for ocp adaption docker cp --> kubectl cp>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_abbr         | No   |  the abbr name of pod, such as up |
    ...    |  container_abbr   | No   |  the container name, such as l2rt |
    ...    |  container_directory_path        | No   |  file_path in container |
    ...    |  host_directory_path     |  Yes  |  file path in oe host  |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    |  vdu_index        | No   |  the index of vcu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    file_path in Cass Host
    ...    Example
    ...    |  Copy Directory Files From Container To Cass Host |  up  |  l2rt |
    ...    /var/eventsTrace  |  /home/cloudadmin/eventTrace  |
    tafssh.Reset Cache
    ${ns} =   Get vDU Namespace From TestLine   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    Connect To K8s master   alias=k8s_file_download
    ${up_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=${pod_abbr}
    ...    connection=k8s_file_download    vdu_index=${vdu_index}
    ${container_name} =   Get Full Container Name By Container Abbreviation   ctr_abbr=${container_abbr}   vdu_index=${vdu_index}
    log to console    empty directory in OE host ${host_directory_path}
    tafssh.Execute    command=sudo rm -rf ${host_directory_path}   connection=k8s_file_download
    tafssh.Execute    command=kubectl cp -n ${ns} ${up_pod_name}:${container_directory_path} ${host_directory_path} -c ${container_name}
    ...      connection=k8s_file_download
    tafssh.Reset Cache
    [return]     ${host_directory_path}


_Download TTI Trace Directory From VDU OCP
    [Arguments]    ${container_name}    ${file_path}
    ...            ${file_name_list}    ${vdu_index}=${0}    ${gnb_index}=${0}    #${pod_name}
    [Documentation]  Download all the files in specific dir to ute for cloud platform OCP
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <17-Aug-2021>, <lingtsun>, <Initial creation for ocp
    ...    adaption docker cp --> kubectl cp>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the abbr name of pod, such as up |
    ...    |  container_name   | No   |  the container name, such as l2rt |
    ...    |  file_path        | No   |  file_path in OE |
    ...    |  file_name_list   | No   |  tti trace file name list |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    |  vdu_index        | No   |  the index of vcu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    tafssh.Reset Cache
    ${ns} =   Get vDU Namespace From TestLine   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    Connect To K8s master   alias=ttiTrace_l2rt
    ${up_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=up
    ...                 connection=ttiTrace_l2rt    vdu_index=${vdu_index}
    ${container_name} =   Get Full Container Name By Container Abbreviation   ctr_abbr=${container_name}   vdu_index=${vdu_index}
    log to console    empty /home/cloudadmin/eventsTrace
    tafssh.Execute    command=rm -rf /home/cloudadmin/eventsTrace   connection=ttiTrace_l2rt
    tafssh.Execute    command=kubectl cp -n ${ns} ${up_pod_name}:${file_path} /home/cloudadmin/eventsTrace -c ${container_name}
    ...        connection=ttiTrace_l2rt
    @{file_path_list}=    create list
    FOR    ${file_name}  IN  @{file_name_list}
        ${local_log_file_path} =     Get A File     eventsTrace     ${file_name}
        append to list    ${file_path_list}     ${local_log_file_path}
        tafssh.File Exists     /home/cloudadmin/eventsTrace/${file_name}     connection=ttiTrace_l2rt
        tafssh.Download File     remote_path=/home/cloudadmin/eventsTrace/${file_name}
        ...        local_path=${local_log_file_path}    connection=ttiTrace_l2rt
    END
    [return]     ${file_path_list}
    tafssh.Reset Cache

_Download TTI Trace Directory From VDU NCS
    [Arguments]    ${pod_name}    ${container_name}    ${file_path}
    ...            ${file_name_list}    #${vdu_index}=${0}
    [Documentation]  Download all the files in specific dir to ute
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <21-Aug-2020>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the abbr name of pod, such as up |
    ...    |  container_name   | No   |  the container name, such as l2rt |
    ...    |  file_path        | No   |  file_path in OE |
    ...    |  file_name_list   | No   |  tti trace file name list |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    *RETURN VALUE*
    ...    trace_path_list in ute
    ...    Example
    ...    |  Stop And Download TTI Trace |  aic-vdu-aic-vdu-mvp-up-0  |  ${0}  |
    tafssh.Reset Cache
    ${alias} =    Connect To vDU Node     pod_abbr=${pod_name}     master_alias=MASTER     node_alias=NODE
    ${container_id} =     Get vDU Container ID     ${container_name}     ${alias}
    log to console    empty /home/cloudadmin/eventsTrace
    tafssh.Execute    command=rm -rf /home/cloudadmin/eventsTrace   connection=NODE
    tafssh.Execute    command=sudo docker cp ${container_id}:${file_path} /home/cloudadmin   connection=NODE   timeout=20
    @{file_path_list}=    create list
    FOR    ${file_name}  IN  @{file_name_list}
        ${local_log_file_path} =     Get A File     eventsTrace     ${file_name}
        append to list    ${file_path_list}     ${local_log_file_path}
        tafssh.File Exists     /home/cloudadmin/eventsTrace/${file_name}     connection=NODE
        tafssh.Download File     remote_path=/home/cloudadmin/eventsTrace/${file_name}
        ...        local_path=${local_log_file_path}    connection=NODE
    END
    tafssh.Reset Cache
    [return]     ${file_path_list}


Decoder TTITrace With Linux Server
    [Arguments]  ${ttitrace_server_ip}  ${username}  ${password}  ${vdu_version}  ${ttiTrace_files_list}=${EMPTY}
    ...  ${alias}=ttiTrace_linux_server
    ...  ${tool_base_repo}=https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    ...  ${package_name}=5G22R1_GNB_0000_000300_00
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
    _Create Related Folders  ${alias}
#    _Get Decode Tool And Untar  ${tool_base_repo}  ${vdu_version}  ${alias}
    _Get Decode Tool And Untar  ${tool_base_repo}  ${vdu_version}  ${alias}    ${package_name}
    ${local_dl_csv}  ${local_ul_csv}  _Decode TTITRACE Bin Files And Download csv To Local  ${ttiTrace_files_list}  ${alias}
    [Return]  ${local_dl_csv}  ${local_ul_csv}
    [Teardown]  tafssh.disconnect  connection=${alias}

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
    [Arguments]   ${tool_base_repo}  ${vdu_version}  ${conn_alias}  ${package_name}=5G22R1_GNB_0000_000300_00
    ${ret}  ${version}=  Split String From Right  ${vdu_version}  separator=300.  max_split=1
#    ${decoder_tool_name}=  set variable  5G22R1_GNB_0000_000300_00${version}_tti-dec_qemux86-64-static.txz
    ${decoder_tool_name}=  set variable  ${package_name}_${version}_tti-dec_qemux86-64-static.txz
    ${tool_url}=  set variable  ${tool_base_repo}/${vdu_version}/${decoder_tool_name}
    tafssh.Execute  command=wget --no-check-certificate ${tool_url} -P ${ttiTrace_Dir}  connection=${conn_alias}
    tafssh.Execute  command=cd ${ttiTrace_Dir} && tar -xJvf ${ttiTrace_Dir}/${decoder_tool_name} && rm -f ${decoder_tool_name}
    ...  connection=${conn_alias}

_Decode TTITRACE Bin Files And Download csv To Local
    [Arguments]   ${ttiTrace_files_list}   ${conn_alias}
    ${local_dl_csv}=  Get A Directory  ttiTrace_DL_CSV
    ${local_ul_csv}=  Get A Directory  ttiTrace_UP_CSV
    FOR  ${ttitrace_file}  IN  @{ttiTrace_files_list}
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
      run keyword if    "${dl_file_exists}"=="True"  tafssh.download file  remote_path=${decoded_csv}/tti_${bin_file_index}_dl.csv
    ...  local_path=${local_dl_csv}/tti_${bin_file_index}_dl.csv  connection=${conn_alias}
      run keyword if    "${ul_file_exists}"=="True"  tafssh.download_file  remote_path=${decoded_csv}/tti_${bin_file_index}_ul.csv
    ...  local_path=${local_ul_csv}/tti_${bin_file_index}_ul.csv  connection=${conn_alias}
    END
    [Return]  ${local_dl_csv}  ${local_ul_csv}


Get Dptrace Flag
    [Arguments]  ${container}  ${flag}  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Dptrace Flag
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container       | yes | container: l1hi, l2hi, l2rt |
    ...    | flag            | yes | flag: trace, dump-payload.  trace: 'Dptrace flag',  dump-payload:'Dptrace dump_palyload flag' |
    ...    | vdu_index       | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    disable or enable
    ...
    ...    Example
    ...   | ${value}    | Get Dptrace Flag | container=l1hi | flag=trace |
    ...   | ${value}    | Get Dptrace Flag | container=l2hi | flag=dump-payload |
    ...
    ${flag}  set variable  ${flag.lower()}
    ${actual_flag_name}  run keyword if  "${flag}"=="trace"   set variable  Dptrace flag
    ...   ELSE IF    "${flag}"=="dump-payload"     set variable  Dptrace dump_palyload flag
    ...   ELSE   Fail   Unknown flag name, it should be trace or dump-payload

    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=up   vdu_index=${vdu_index}   alias=${alias}

    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${command}  set variable   bash -c "dptrace-cli show|grep -i '${actual_flag_name}'"

    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${container} -n ${ns} -- ${command}|awk -F ":" '{print $2}'  alias=${alias}
    ${out}  strip prompt  ${out}

    [Return]  ${out}


Set Dptrace Flag
    [Arguments]  ${container}  ${flag}  ${value}   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    Set Dptrace Flag
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | flag   | yes | flag: trace, dump-payload.  trace: 'dptrace-cli trace ${value}',  dump-payload:'dptrace-cli dump-payload ${value}' |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    disable or enable
    ...
    ...    Example
    ...   | ${value}    | Set Dptrace Flag | container=l1hi | flag=trace        | value=disable |
    ...   | ${value}    | Set Dptrace Flag | container=l2hi | flag=dump-payload | value=enable |
    ...
    ${flag}  set variable  ${flag.lower()}
    run keyword if  "${flag}"!="trace" and "${flag}"!="dump-payload"
     ...   Fail   Unknown flag name, it should be trace or dump-payload

    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}

    ${command}  set variable  dptrace-cli ${flag} ${value}
    ${out}   Kubectl Exec Interactively   pod_abbr=up   container=${container}   command=${command}   alias=${alias}  vdu_index=${vdu_index}

    [Return]  ${out}


Enable Timing Tracing Via CLI
    [Arguments]  ${container}    #${vdu_index}=0
    [Documentation]    Enable Timing Tracing Via CLI
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${value}    | Enable Timing Tracing Via CLI | container=l1hi |
    ...
    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    return from keyword if   "${flag_trace_value}"=="enable" and "${flag_dump-payload_value}"=="enable"    Enabled

    ${out}  run keyword if  "${flag_trace_value}"=="disable"   Set Dptrace Flag   container=${container}   flag=trace   value=enable
    ${out}  run keyword if  "${flag_dump-payload_value}"=="disable"   Set Dptrace Flag   container=${container}   flag=dump-payload   value=enable

    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    should be true  "${flag_trace_value}"=="enable" and "${flag_dump-payload_value}"=="enable"

    [Return]  Enabled


Disable Timing Tracing Via CLI
    [Arguments]  ${container}    #${vdu_index}=0
    [Documentation]    Disable Timing Tracing Via CLI
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${value}    | Disable Timing Tracing Via CLI | container=l1hi |
    ...
    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    return from keyword if   "${flag_trace_value}"=="disable" and "${flag_dump-payload_value}"=="disable"    Disabled

    ${out}  run keyword if  "${flag_trace_value}"=="enable"   Set Dptrace Flag   container=${container}   flag=trace   value=disable
    ${out}  run keyword if  "${flag_dump-payload_value}"=="enable"   Set Dptrace Flag   container=${container}   flag=dump-payload   value=disable

    ${flag_trace_value}  Get Dptrace Flag   container=${container}   flag=trace
    ${flag_dump-payload_value}  Get Dptrace Flag   container=${container}   flag=dump-payload

    should be true  "${flag_trace_value}"=="disable" and "${flag_dump-payload_value}"=="disable"

    [Return]  Disabled


Get Current Timing Trace Log Size
    [Arguments]  ${container}    ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get Current Timing Trace Log Size
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | container | yes | container: l1hi, l2hi, l2rt |
    ...    | vdu_index | no | vdu_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Enabled or KW fails
    ...
    ...    Example
    ...   | ${size}    | Get Current Timing Trace Log Size | container=l1hi |
    ...
    ${alias}  get unique id
    connect to k8s master with tenant interactively   vdu_index=${vdu_index}  alias=${alias}
    ${out}   Kubectl Exec Interactively  pod_abbr=up  container=${container}   check_result=${False}
     ...   command=ls -l /var/run/dptrace/dptrace-data     alias=${alias}
    return from keyword if  "No such file or directory" in """${out}"""    0
    ${size}  set variable  ${out.split()[4]}
    [Return]  ${size}


_Delete Core Dump Files
    [Teardown]    run keywords    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ...    AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_root}
    [Documentation]   _Delete Core Dump Files
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Delete Core Dump Files |
    ...
    ${alias}  get unique id
    connect to k8s master interactively  alias=${alias}

    #delete tmp folder
    ${ns}  get vdu namespace from testline
    ${cu_ns}   Get CU Namespace From TestLine
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}_${cu_ns}
    ${out}   issh.Execute  command=sudo chmod 777 -R ${tmp_foler_name}   check_result=False  alias=${alias}
    ${out}   Run Keyword If   ${ns.__len__()}>0 and ${cu_ns.__len__()}>0
    ...   issh.Execute   command=sudo rm -rf ${tmp_foler_name}   alias=${alias}

    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec chmod 777 {} \\;   alias=${alias}  check_result=False
    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec rm -f {} \\;   alias=${alias}  check_result=False

    ${platform_name}   Get Platform Name

    Run Keyword If     "${platform_name}"=="OCP"  _VDU Environment WA For OCP   ${alias}
    return from keyword if   "${platform_name}"=="NCIR" or "${platform_name}"=="OCP"

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
    ...   | Update User Plane Trace Configuration | uplane_ip_addr=10.110.95.16    uplane_port=55900 |
    ...   | VDU Rest Logout |
    ${uplane_port_1}    Convert To Integer    ${uplane_port}
    ${dscp_1}    Convert To Integer    ${dscp}
    ${res1}    vdu.update_uplane_configuration
    ...    uplane_ip_addr=${uplane_ip_addr}    uplane_port=${uplane_port_1}    dscp=${dscp_1}
    sleep    10s
    ${res2}    vdu.get_trs_api_operation_status    operation_id=${res1}
    [return]    ${res2}


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


Delete Uplane Trace File On Dcap Server For Certain vDU Site
    [Arguments]    ${ip}
    [Documentation]  Delete Uplane Trace File On Dcap Server For Certain vDU Site
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ...    modified by:        <4-Aug-2021>, <rifeng>, <add argument ip>
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
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}

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


Uplane Trace File Existed On Dcap Server
    [Arguments]    ${ip}
    [Documentation]  Delete Uplane Trace File On Dcap Server For Certain vDU Site
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <03-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Trace File Name On Dcap Server    ${ip}|
    log to console    check uplane trace existed
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_UP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\"    alias=${alias}
    ${trace_files}   convert to string    ${trace_files}
    Should Contain    ${trace_files}    ${ip}
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}


###### syslog Keywords #######
Start To Storage New Syslog
    [Arguments]    ${vdu_index}=${0}   #${backup_file}=syslog
    [Documentation]  Login to logstorageserver, backup the syslog, and new a syslog
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <18-Mar-2021>, <lingtsun>, <Initial creation>
    ...    modified by:  14.04.2021, sophie.jiang@nokia-sbell.com, debug pass
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index        | No    |  the index of vdu,  ${0} in default   |
    ...    |  backup_file      | No    |  backup file name, default is syslog  |
    ...    RETURN VALUE
    ...    None
    ...    Example
    ...    | Start To Storage New Syslog |  ${0}  |  syslog  |
    vDU Cluster Login With Tenant     vdu_index=${vdu_index}
    ${log_pod_name} =    Get Full Pod Name By Pod Abbreviation      pod_abbr=logservice    vdu_index=${vdu_index}
    set test variable    ${log_pod_name}
    FOR  ${container}  IN  @{AIC_VDU_PODS['logservice']}
       run keyword if    'logstorageserver' in '${container}'   set test variable   ${log_container}   ${container}
    END
    set test variable    ${log_container}
    ${status}=  run keyword and return status  Get Container Name Prefix
    run keyword if  ${status}==True  set test variable  ${log_container}  ctr-cran1-logstorageserver
    run keyword if  ${status}==False  set test variable  ${log_container}  logstorageserver
    Connect To vDU Container    ${log_pod_name}    ${log_container}   vdu_index=${vdu_index}
    Execute Command In Container    cd /var/log/syslog
    ${output} =    Execute Command In Container    ls -al
    Execute Command In Container    rm -rf syslog.*
    Execute Command In Container    > syslog
    ${output} =    Execute Command In Container    ls -al
    [teardown]    Exit From Container

Download Syslog From LogStorageServer
    [Arguments]    ${container_name}=logstorageserver
    ...            ${file_path}=/var/log/syslog/    ${vdu_index}=${0}   #${file_name}=syslog    ${pod_name}=logservice
    [Documentation]  Downloas syslog from logstorage server to local
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <18-Mar-2021>, <lingtsun>, <Initial creation>
    ...    modified by:  14.04.2021, sophie.jiang@nokia-sbell.com, debug pass
    ...    | Input Parameters | Man. | Description |
    ...    |  pod_name         | No   |  the full name of up |
    ...    |  container_name   | No   |  the full name of l2rt |
     ...   |  file_path        | No   |  the full name of up |
    ...    |  file_name   | No   |  the full name of l2rt |
    ...    |  vdu_index        | No   |  the index of vdu,  ${0} in default |
    ...    RETURN VALUE
    ...    syslog path in ute
    ...    Example
    ...    |  Download Syslog From LogStorageServer |  logservice  |  ${0}  |

    Log To Console     connect to logstorageserver
    tafssh.Reset Cache
    Connect To K8s Master  ${vdu_index}  alias=Master
    ${container_id} =     Get vDU Container ID     ${container_name}     Master
    tafssh.Execute    command=rm -rf /home/cloudadmin/syslog_CIT    connection=Master
    tafssh.Execute    command=sudo docker cp ${container_id}:${file_path} /home/cloudadmin/syslog_CIT   connection=Master   timeout=100
    tafssh.Execute    command=sudo chmod 777 -R /home/cloudadmin/syslog_CIT   connection=Master
    ${syslog_file_info}=  tafssh.Execute  command=ls /home/cloudadmin/syslog_CIT/*    connection=Master
    ${syslog_file_info}=  replace string  ${syslog_file_info}  \r\n  ${EMPTY}
    Log To Console    ${syslog_file_info}
    ${local_log_file_dir} =    Get A Directory    storage_syslog
    Log To Console    ${local_log_file_dir}
    @{syslog_list}    split string    ${syslog_file_info}  ${EMPTY}
    Log To Console  @{syslog_list}
    tafssh.Download File     remote_path=@{syslog_list}
        ...        local_path=${local_log_file_dir}    connection=Master
    tafssh.Reset Cache
    [return]     ${local_log_file_dir}


