*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_wireshark.robot



*** Variables ***



*** Keywords ***
#_Begin Tcpdump Wireshark VCUC
#    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
#    [Tags]    CLOUD_PLATFORM_SPECFIC
#    ${host_type}  Set Variable  VCUC
#    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}
#    ${pcap_folder}   set variable    /tmp/tmp_wireshark
#    ${sudo_outer}  Set Variable  ${EMPTY}
#
#    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
#    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${index}  alias=${alias}
#    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}
#
#    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}
#            ...  alias=${alias}
#    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}
#            ...  alias=${alias}
#
#    ${tmpfilename}    _Get Temp File Name
#      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
#    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap
#
#    #${sudo}    Get Sudo VCUC   pod_abbr=${pod_abbr}  container=${container}   gnb_index=${index}  alias=${alias}
#    ${sudo}  set variable   ${EMPTY}
#
#    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
#    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
#    ${cmd}   set variable if  "${sudo}"!="${EMPTY}"   sudo ${cmd}    ${cmd}
#
#    #prepare tcpdump_guard script
#    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_cnf"]}
#    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo
#
#   # ${out}  issh.Execute   command=ls ${tcpdump_guard}   check_result=False   alias=${alias}
#   # ${out2}   Run Keyword If     """No such file or directory""" in """${out}"""
#    #...  issh.Execute  command=rm -f ${version_file}  check_result=False   alias=${alias}
#    #Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To VCU Master Node
#    Upload Tools To VCU Master Node
#    ${out}  issh.Execute   command=ls -l ${tcpdump_guard}   alias=${alias}
#    Should Be True   """No such file or directory""" not in """${out}"""
#
#    #start capture
#    ${full_cmd}   set variable  ${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ${cmd}
#    log to console   ${full_cmd}
#    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
#    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
#    Sleep   6s
#
#    #process guard
#    ${alias_process_guard}   Connect To CU K8S Master With Admin   gnb_index=${index}
#    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
#    ${out}   issh.Execute    command=${sudo_outer} kubectl get pod ${full_pod_name} -o wide -n ${ns}|grep -v NAME|awk '{print $7}'
#      ...  alias=${alias_process_guard}
#    ${target_node}  strip prompt   ${out}
#    should be true  ${target_node.__len__()>0}
#
#    ${out}   issh.Execute     command=ps -ef|grep tcpdump   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_cnf"]} -a ${tmpfilename} -t ${target_node} &)   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    ${out}   issh.Execute     command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_cnf"]}   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VCUC
    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias2}
    ...   AND  Disconnect Interactive Connection   alias=${alias_process_guard}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]   _Begin Tcpdump Wireshark VCUC, there are many changes for this KW, so i think we should recoard change history on 2022.7.22
    ...  But lots of changes are lost, include the contributors.
    ...
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  22.7.2022,chris.l.cao@nokia-sbell.com, fix the occasional failure of starting bash
    ...            by changing to 'Connect To VCU Container With Tenant Interactively' to mkdir /tmp/tmp_wireshark_${ns} inside container
    ...  13.2.2023,chris.l.cao@nokia-sbell.com, add 'ps-ef|grep tcpdump' to debug occasional failure
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...
    ${host_type}  Set Variable  VCUC
    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}

    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark_${ns}

    ${alias2}   Connect To VCU Container With Tenant Interactively   ctr_abbr=${container}   gnb_index=${index}
    ...   pod_abbr=${pod_abbr}
    ${out}  issh.Execute   command=mkdir -p ${pcap_folder}  check_result=${False}   alias=${alias2}
    ${out}  issh.Execute   command=ls -l ${pcap_folder}     check_result=${False}   alias=${alias2}

    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap

#    ${pid}   Get PID For Container In VCU    pod_abbr=${pod_abbr}    ctr_abbr=${container}   alias=${alias}
    ${pid}   Get Container Pid via Appointed Pod in VCU   container_abbr=${container}   pod_abbr=${pod_abbr}
    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #start capture
    ${full_cmd}   set variable  sudo nsenter -m -n -t ${pid} ${cmd}
    Log To Console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   6s

    #process guard
    ${alias_process_guard}  Connect To CU Node    pod_abbr=${pod_abbr}   gnb_index=${index}

    ${out}   issh.Execute   command=ps -ef|grep tcpdump   check_result=${False}     alias=${alias_process_guard}
    ${out}   issh.Execute   command=ps -ef|grep tcpdump|grep ${tmpfilenamefullpath}|wc -l
                            ...   check_result=${False}   alias=${alias_process_guard}
    Log To Console  ${out}
    ${out}   Strip Prompt   ${out}
    ${out}   Evaluate   int(${out})
    Run Keyword If   ${out}<${2}    fail

    [Return]    ${tmpfilenamefullpath}


_Get Wireshark From VCUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Teardown]  Run Keywords   Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias_new}
     ...   AND   Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias_container}
    [Documentation]   _Get Wireshark From VCUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    18.2.2023,chris.l.cao@nokia-sbell.com, remove 'sync' command to fix 'block' issue
    ...
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
#    ${out}   issh.Execute  command=sync     alias=${alias}

    #parse vcu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vcu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${alias_new}    Connect To CU K8S Master With Tenant   gnb_index=${vcu_index}  width=300
    ${ns}     Get CU Namespace From Testline  gnb_index=${vcu_index}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark_${ns}
    ${pod_full_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${vcu_index}  alias=${alias_new}
    ${container_full_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    Log To Console   _Get Wireshark From VCUC's container:${container}

    ${alias_container}   Connect To VCU Container With Tenant Interactively   ctr_abbr=${container}    gnb_index=${vcu_index}
    ${out}  issh.Execute  command=sync;ls -l ${pcap_folder}   check_result=${False}   alias=${alias_container}

    ${out}    issh.Execute     command=mkdir -p ${pcap_folder}    alias=${alias_new}
    ${out}    issh.Execute     command=ls -l ${pcap_folder}   alias=${alias_new}

    ${out}  remove value info  value=${initial_log_path}  index=0  split_info=/
    ${out}  remove value info  value=${out}  index=0  split_info=/
    ${pcap_file_name}  remove value info  value=${out}  index=0  split_info=/
    ${remote_log_path}   set variable   ${pcap_folder}/${pcap_file_name}
    ${cp_cmd}   set variable
      ...  oc exec -i ${pod_full_name} -c ${container_full_name} -- cat ${initial_log_path} > ${remote_log_path}
#    ${cp_cmd}  Catenate   kubectl exec ${pod_full_name} -c ${container_full_name} -n ${ns}
#      ...     -- /bin/gzip -c ${initial_log_path} | gunzip > ${remote_log_path}
    ${out}    Wait Until Keyword Succeeds  15x  2  issh.Execute     command=${cp_cmd}    alias=${alias_new}

    ${out}  issh.Execute     command=sync    alias=${alias_new}

    issh.Download File   remote_path=${remote_log_path}    local_path=${log_stored_path}   alias=${alias_new}
    ${out}  issh.Execute  command=rm -f ${remote_log_path}     alias=${alias_new}

    Run Keyword And Ignore Error   _Delete Old Wireshark File In VCUC   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias_container}
    Run Keyword And Ignore Error   _Delete Old Wireshark File In VCUC Master Node   initial_log_path=${initial_log_path}
    ...   alias=${alias_new}  vcu_index=${vcu_index}


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
    [Arguments]  ${initial_log_path}   ${alias}=default  ${vcu_index}=0
    ${ns}     Get CU Namespace From Testline  gnb_index=${vcu_index}
    ${pcap_folder}  Set Variable   /tmp/tmp_wireshark_${ns}
    ${res}   issh.Execute   command=ls -l ${pcap_folder}   alias=${alias}
    Log   ${res}
#    issh.Execute   command=rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed In VCUC Master Node   FolderName=${pcap_folder}   alias=${alias}


_Delete Old Wireshark File In VDUC Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   issh.Execute   command=ls -l /tmp/tmp_wireshark   alias=${alias}
    Log   ${res}
    _Remove All Temp File If Needed In VCUC Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}


_Delete Old Wireshark File In VCUC
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
#    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${pcap_folder}   set variable    /tmp/tmp_wireshark_${ns}
    ${out}  issh.Execute  command=rm -f ${initial_log_path}   check_result=${False}   alias=${alias}
    _Remove All Temp File If Needed From VCUC   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}


Begin DPDK On CU
    [Arguments]  ${pod_abbr}=upue   ${container}=l2hicu  ${port_name}=bhu  ${alias}=default
    [Documentation]    Begin DPDK On CU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    modified by:   <26-Apr-2022>, <r3li>   adapt new env
    ...    |  Input Parameters | Man. | Description |
    ...    |  pod_abbr | No | pod addr, default is upue  |
    ...    |  container | No | container name, default is l2hicu  |
    ...    |  port_name | No | port name, default is bhu |
    ...    |  alias | No | connection alias |
    ...    *RETURN VALUE*
    ...    file path in container

    ...    Example
    ...    | ${alias} | Connect To CU K8S Master With Admin |
    ...    | Begin DPDK On CU| alias=${alias} |
    ...    | Sleep            | 3s |
    ...    | ${local_file_path} | End DPDK On CU | alias=${alias} |
    ...    | issh.disconnect | connection=${alias} |
    Log To Console  Begin DPDK On CU
    ${ns}   Get CU Namespace From Testline
    ${pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   alias=${alias}
    ${container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${command_str}    catenate   kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} --
    ...  bash -c "mkdir -p /tmp/dpdk"
    ${out}    issh.Execute     command=${command_str}    alias=${alias}
    ${tmpfilenamefullpath}    Set Variable    /tmp/${port_name}
    ${cmd}    Catenate    SEPARATOR=
    ...    kubectl exec -it ${pod_name} -c ${container_name} -n
    ...    ${ns} -- bash -c "dpdk-cli show port table | grep ${port_name}" | awk '{print $1}'
    ${port_id_tmp}    issh.Execute    command=${cmd}
    ...                                 alias=${alias}
    ${port_id_tmp}  Strip Prompt   ${port_id_tmp}
    Log To Console  Begin capture dpdk Log in OCP
    ${cmd}  catenate  kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- rm -f /tmp/${port_name}.pcap
    ${out}    issh.Execute     command=${cmd}
    ...                          alias=${alias}

    ${cmd}  catenate  kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- bash
    ...  -c "cd tmp; dpdk-cli pdump port ${port_id_tmp}"
    issh.Execute_bare
    ...     command=${cmd}
    ...     alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}

End DPDK On CU
    [Arguments]  ${alias}=default   ${pod_abbr}=upue   ${container}=l2hicu  ${port_name}=bhu
    [Documentation]   End DPDK On CU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  alias | No | connection alias |
    ...    |  pod_abbr | No | pod addr, default is upue  |
    ...    |  container | No | container name, default is l2hicu  |
    ...    |  port_name | No | port name, default is bhu |

    ...    *RETURN VALUE*
    ...    local pcap file path
    ...
    ...    Example
    ...    | ${alias} | Connect To CU K8S Master With Admin |
    ...    | Begin DPDK On CU| alias=${alias} |
    ...    | Sleep            | 3s |
    ...    | ${local_file_path} | End DPDK On CU | alias=${alias} |
    ...    | issh.disconnect | connection=${alias} |
    ...
    Send CTRL_C Interactively    alias=${alias}
    Sleep  3
    ${ns} =  Get CU Namespace From Testline
    ${pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   alias=${alias}
    ${container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${out}    issh.Execute   command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} sync  alias=${alias}
    ${cmd}  catenate  kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- chmod 777 /tmp/${port_name}.pcap
    ${out}    issh.Execute   command=${cmd}   alias=${alias}
    ${out}    issh.Execute     command=mkdir -p /tmp/dpdk   alias=${alias}
    ${out}    issh.Execute     command=ls -l /tmp/dpdk   alias=${alias}
    ${out}    Run Keyword And Ignore Error  issh.Execute   command=sudo chmod 777 /tmp/dpdk   alias=${alias}
    ${kubectl_cp}   catenate   kubectl cp -n ${ns} ${pod_name}:/tmp/${port_name}.pcap /tmp/dpdk/${port_name}.pcap
    ...  -c ${container_name}
    ${out}    issh.Execute     command=${kubectl_cp}  check_result=${False}  alias=${alias}
    ${out}    issh.Execute     command=sync    alias=${alias}
    ${time_stamp}   Get Unique Id   precise=LOW
    ${local_file_path}=  Get A File    dpdk  ${container}_${port_name}_${time_stamp}.pcap
    issh.Download File   remote_path=/tmp/dpdk/${port_name}.pcap    local_path=${local_file_path}   alias=${alias}
    ${res}   issh.Execute   command=ls -l /tmp/dpdk   alias=${alias}
    Log   ${res}
    issh.Execute   command=rm -f /tmp/dpdk/${port_name}.pcap     alias=${alias}
    [Return]  ${local_file_path}

Analysis NGU Application IP In Dpdk Packages
    [Arguments]  ${pcapfile}   ${filter}=gtp   ${ip}=0  ${expected_number}=0
    [Documentation]    Analysis NGU Application IP In Dpdk Packages
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | ip            | yes | ngu slice ip |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | Analysis NGU Application IP In Dpdk Packages | pcapfile=/tmp/a.pcap | filter=gtp  |
    ...
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   dpdk_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}   filter=${filter}
    ${filed_name}=   Set Variable If   ":" in "${ip}"   ipv6.host  ip.host
    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=${filed_name}   attrib_name=show
    ...   attrib_value=${ip}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries   pdml_entries=${entries}   field_name=${filed_name}
    ...  attrib_name=showname
    ${length}  Get Length    ${showname}
    Should Be True   ${length}>${expected_number}
