*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_wireshark.robot



*** Variables ***



*** Keywords ***
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


_Begin Tcpdump Wireshark VCUC
    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
    [Tags]    CLOUD_PLATFORM_SPECFIC
    ${host_type}  Set Variable  VCUC
    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command  gnb_index=${index}

    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${index}  alias=${alias}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}
            ...  alias=${alias}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  alias=${alias}

    ${tmpfilename}    _Get Temp File Name
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap

    #${sudo}    Get Sudo VCUC   pod_abbr=${pod_abbr}  container=${container}   gnb_index=${index}  alias=${alias}
    ${sudo}  set variable   ${EMPTY}

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    ${cmd}   set variable if  "${sudo}"!="${EMPTY}"   sudo ${cmd}    ${cmd}

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_cnf"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

   # ${out}  issh.Execute   command=ls ${tcpdump_guard}   check_result=False   alias=${alias}
   # ${out2}   Run Keyword If     """No such file or directory""" in """${out}"""
    #...  issh.Execute  command=rm -f ${version_file}  check_result=False   alias=${alias}
    #Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To VCU Master Nodes
    Upload Tools To VCU Master Nodes
    ${out}  issh.Execute   command=ls ${tcpdump_guard}   alias=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    #start capture
    ${full_cmd}   set variable  ${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ${cmd}
    log to console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   6s

    #process guard
    ${alias_process_guard}   Connect To CU K8S Master With Admin   gnb_index=${index}
    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
    ${out}   issh.Execute    command=${sudo_outer} kubectl get pod ${full_pod_name} -o wide -n ${ns}|grep -v NAME|awk '{print $7}'
      ...  alias=${alias_process_guard}
    ${target_node}  strip prompt   ${out}
    should be true  ${target_node.__len__()>0}

    ${out}   issh.Execute     command=ps -ef|grep tcpdump   alias=${alias_process_guard}
    Log To Console  ${out}

    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_cnf"]} -a ${tmpfilename} -t ${target_node} &)   alias=${alias_process_guard}
    Log To Console  ${out}

    ${out}   issh.Execute     command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_cnf"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}



_Get Wireshark From VCUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
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
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command

    #parse vcu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vcu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${ns}     Get CU Namespace From Testline  gnb_index=${vcu_index}
    ${pod_full_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${vcu_index}  alias=${alias}
    ${container_full_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    Log To Console   ${container}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- sync
            ...  check_result=False   alias=${alias}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- chmod 777 ${initial_log_path}
            ...  check_result=False   alias=${alias}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  check_result=False   alias=${alias}

    ${out}    issh.Execute     command=mkdir -p ${pcap_folder}    alias=${alias}
    ${out}    issh.Execute     command=ls -l ${pcap_folder}   alias=${alias}

    #${remote_log_path}   set variable   /tmp/tmp_wireshark/${initial_log_path}
    ${remote_log_path}   set variable   ${initial_log_path}
    ${cp_cmd}   set variable
      ...  ${sudo_outer} kubectl cp ${pod_full_name}:${initial_log_path} ${remote_log_path} -c ${container_full_name} -n ${ns}
    ${out}    issh.Execute     command=${cp_cmd}    alias=${alias}

    ${out}    issh.Execute     command=sync    alias=${alias}

    issh.Download File   remote_path=${remote_log_path}    local_path=${log_stored_path}   alias=${alias}
    ${out}  issh.Execute  command=rm -f ${remote_log_path}     alias=${alias}

    _Delete Old Wireshark File In VCUC   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias}
    _Delete Old Wireshark File In VCUC Master Node   initial_log_path=${initial_log_path}   alias=${alias}


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

_Delete Old Wireshark File In VCUC Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   issh.Execute   command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed In VCUC Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In VCUC
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -f ${initial_log_path}
            ...  check_result=False   alias=${alias}
    _Remove All Temp File If Needed From VCUC   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}


Start Wireshark F1 Log On CU
    [Arguments]    ${alias}=default
    [Documentation]    Begin to capture wireshark log on F1 interface for CPIF,
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be deleted after calling 'End Wireshark'.
    ...    Example
    ...    | Start Wireshark F1 Log On CU |
    Log To Console    Start Wireshark on F1 interface
#    ${tmpfile_pcap}    Begin Wireshark   interface=fronthaul   host_type=VCU    filter=sctp    alias=${alias}
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=fronthaul       alias=${alias}   filter=sctp

    [Return]    ${tmpfile_pcap}


Stop Wireshark F1 Log On CU
    [Arguments]    ${tmpfile_pcap}    ${pcap_name}    ${alias}=default
    [Documentation]    Stop wireshark log for F1 interface, and get log to local
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tmpfile_pcap | yes | a handler returned by 'Begin Wireshark' which stands for the source log location of wireshark server |
    ...    | pcap_name | yes | for this variable, keyword user named the captured pcap log  |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    the captured pcap log, to be analyzed further by keyword user.
    ...    Example
    ...    | Stop Wireshark F1 Log On CU |  /tmp/ws_cf8df.pcap  |  myf1pcapfile.pcap  |
    Log To Console    Stop wireshark log for specified interface and host type
    ${local_file}   Get A File   Wireshark   ${pcap_name}
#    End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ${tmpfilefullpath}    _Get Wireshark From VCU
      ...   initial_log_path=${tmpfile_pcap}  log_stored_path=${local_file}   alias=${alias}
    [Return]   ${local_file}


Stop Wireshark On CU
    [Arguments]    ${tmpfile_pcap}    ${pcap_name}    ${alias}=default
    [Documentation]    Stop wireshark log for F1 interface, and get log to local
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tmpfile_pcap | yes | a handler returned by 'Begin Wireshark' which stands for the source log location of wireshark server |
    ...    | pcap_name | yes | for this variable, keyword user named the captured pcap log  |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    the captured pcap log, to be analyzed further by keyword user.
    ...    Example
    ...    | Stop Wireshark F1 Log On CU |  /tmp/ws_cf8df.pcap  |  myf1pcapfile.pcap  |
    Log To Console    Stop wireshark log for specified interface and host type
    ${local_file}   Get A File   Wireshark   ${pcap_name}
#    End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ${tmpfilefullpath}    _Get Wireshark From VCU
      ...   initial_log_path=${tmpfile_pcap}  log_stored_path=${local_file}   alias=${alias}
    [Return]   ${local_file}


Start Wireshark X2 Uplane Log On CU
    [Arguments]  ${alias}=default
    [Documentation]    Begin to capture x2-U wireshark log, the return value is a temporary file name which exists in target server
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    #${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU    filter=udp   alias=${alias}
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=x2       alias=${alias}   filter=udp
    [Return]  ${tmpfile_pcap}

Stop Wireshark X2 Uplane Log On CU
    [Arguments]    ${tmpfile_pcap}    ${pcap_name}    ${alias}=default
    [Documentation]    Stop wireshark log for F1 interface, and get log to local
    ...    *AUTHOR* alisha.wu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | tmpfile_pcap | yes | a handler returned by 'Begin Wireshark' which stands for the source log location of wireshark server |
    ...    | pcap_name | yes | for this variable, keyword user named the captured pcap log  |
    ...    | alias      | No | alias name  |
    ...    *RETURN VALUE*
    ...    the captured pcap log, to be analyzed further by keyword user.
    ...    Example
    ...    | Stop Wireshark F1 Log On CU |  /tmp/ws_cf8df.pcap  |  myf1pcapfile.pcap  |
    Log To Console    Stop wireshark log for specified interface and host type
    ${local_file}   Get A File   Wireshark   ${pcap_name}
   # End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ${tmpfilefullpath}    _Get Wireshark From VCU
      ...   initial_log_path=${tmpfile_pcap}  log_stored_path=${local_file}   alias=${alias}
    [Return]   ${local_file}

Start Wireshark X2 Log On CU
    [Arguments]  ${alias}=default
    [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    #${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU    filter=sctp   alias=${alias}
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=x2       alias=${alias}   filter=sctp
    [Return]  ${tmpfile_pcap}

Stop Wireshark X2 Log On CU
    [Arguments]   ${tmpfile_pcap}   ${alias}=default
    [Documentation]    Stop capturing wireshark log and get log to local
    ...    *AUTHOR* peng.lin@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | yes | alias |
    ...    *RETURN VALUE*
    ...    No return value.
    ${local_file}   Get A File   Wireshark   mypcapfile.pcap
   # End Wireshark     log_dst_path=${local_file}   log_src_path=${tmpfile_pcap}   alias=${alias}
    ${tmpfilefullpath}    _Get Wireshark From VCU
      ...   initial_log_path=${tmpfile_pcap}  log_stored_path=${local_file}   alias=${alias}
    [Return]  ${local_file}


VCU Capture Wireshark Logs and check sctp dscp value on f1c
    [Arguments]    ${target_dscp_value}
    [Documentation]  VCU Capture Wireshark Logs and check sctp dscp value on f1c
    ...   *AUTHOR* ling.2.zhao@nokia-sbell.com
	...    modified by:        <08-09-2021>, <lingzhao>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   *RETURN VALUE*
    ...   string
    ...   Example
    ...   |VCU Capture Wireshark Logs and check sctp dscp value on f1c | ${target_dscp_value} |
    Log to Console  VCU Capture Wireshark Logs and check sctp dscp value on f1c
    ${hand_f1c}   Begin Wireshark F1 Log On CU
    sleep  30s
    ${local_pcap_file_f1}   Get A File   wireshark  f1c.pcap
    ${out}   End Wireshark F1 Log On CU    handle=${hand_f1c}   local_pcap_file_name=${local_pcap_file_f1}
    ${packets_f1c}    pcap.load_pcap_file  pcap_file=${local_pcap_file_f1}

    ${is_ipv6}   Check if OAM is IPv6
    ${vcu_f1c_ip}  Run Keyword If  "${is_ipv6}"=="${True}"    CU Get F1 Cplane Ipv6 Address
     ...   ELSE   CU Get F1 Cplane Ip Address

    ${filter_f1c}   Set Variable If   "${is_ipv6}"=="${True}"   sctp and ipv6.src==${vcu_f1c_ip}   sctp and ip.src==${vcu_f1c_ip}

    ${pkts_after_filter_f1c}  pcap.filter_packets_by_expression   pdml_list=${packets_f1c}  filter_expression=${filter_f1c}
    ${f1c_dscp_value}   Run Keyword If  "${is_ipv6}"=="${True}"     pcap.get_field_value_by_xpath   ${pkts_after_filter_f1c}
    ...   .//ipv6.tclass.dscp[contains(@show, "${target_dscp_value}")]  show
    ...   ELSE    pcap.get_field_value_by_xpath   ${pkts_after_filter_f1c}
    ...   .//ip.dsfield.dscp[contains(@show, "${target_dscp_value}")]  show

    should not be empty   ${f1c_dscp_value}


VCU Capture Wireshark Logs and check sctp dscp value on x2c
    [Arguments]    ${target_dscp_value}
    [Documentation]  VCU Capture Wireshark Logs and check sctp dscp value on x2c
    ...   *AUTHOR* ling.2.zhao@nokia-sbell.com
	...    modified by:        <08-09-2021>, <lingzhao>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   *RETURN VALUE*
    ...   string
    ...   Example
    ...   |VCU Capture Wireshark Logs and check sctp dscp value on x2c | ${target_dscp_value} |
    Log to Console  VCU Capture Wireshark Logs and check sctp dscp value on x2c
    ${hand_x2c}   Begin Wireshark X2 Cplane Log On CU
    sleep  30s
    ${local_pcap_file_x2}   Get A File   wireshark  x2c.pcap
    ${out}    End Wireshark X2 Cplane Log On CU    handle=${hand_x2c}   local_pcap_file_name=${local_pcap_file_x2}
    ${packets_x2c}    pcap.load_pcap_file  pcap_file=${local_pcap_file_x2}

    ${is_ipv6}   Check if OAM is IPv6
    ${vcu_x2c_ip}  Run Keyword If  "${is_ipv6}"=="${True}"    Get VCU X2C Ipv6
     ...   ELSE   Get VCU X2C Ip

    ${filter_x2c}   Set Variable If   "${is_ipv6}"=="${True}"   sctp and ipv6.src==${vcu_x2c_ipv6}   sctp and ip.src==${vcu_x2c_ip}

    ${pkts_after_filter_x2c}   pcap.filter_packets_by_expression   pdml_list=${packets_x2c}  filter_expression=${filter_x2c}
    ${x2c_dscp_value}     Run Keyword If  "${is_ipv6}"=="${True}"    pcap.get_field_value_by_xpath   ${pkts_after_filter_x2c}
    ...   .//ipv6.tclass.dscp[contains(@show, "${target_dscp_value}")]  show
     ...   ELSE   pcap.get_field_value_by_xpath   ${pkts_after_filter_x2c}
    ...   .//ip.dsfield.dscp[contains(@show, "${target_dscp_value}")]  show
    should not be empty   ${x2c_dscp_value}
