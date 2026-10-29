*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_wireshark.robot


*** Variables ***



*** Keywords ***



Analyze Pcap2txt
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}
    [Documentation]    Convert wireshark pcap file to TXT file according to filter
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target TXT file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe TXT file |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${local_file}     |  set variable        |  /home/ute/mypcap.pcap |                    |
    ...    | ${txt_file}       |   Get A File         |   Wireshark         |  mypcapfile_filter.txt |
    ...    | Analyze Pcap2txt  |   src=${local_file}  |    dest=${txt_file} |                        |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}   Set Variable If   '${filter}'==''   tshark -r ${src} -V -Q 2>/dev/null >${dest}
    ...    tshark -r ${src} -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}   ${out}   OperatingSystem.Run And Return Rc And Output    ${cmd}


Analyze Pcap2xml
    [Arguments]  ${src}   ${dest}    ${filter}=${EMPTY}  ${max_count}=100000
    [Documentation]    Convert wireshark pcap file to XML file according to filter
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | src  |  Yes | the pcap file to be converted in UTE server |
    ...    | dest | Yes | the target XML file to be generated in UTE server |
    ...    | filter | No | filter used to generate targe XML file |
    ...    | max_count | No | expected number |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${local_file}     |  set variable        |  /home/ute/mypcap.pcap |              |
    ...    | ${xml_file}       |  Get A File          |  Wireshark          |   mypcapfile.xml |
    ...    | Analyze pcap2xml  |   src=${local_file}  |   dest=${xml_file}  |   filter=icmp    |

    OperatingSystem.File Should Exist    ${src}
    ${cmd}    Set Variable If    '${filter}'==''    tshark -r "${src}" -c ${max_count} -T pdml -V -Q 2>/dev/null > "${dest}"
    ...    tshark -r "${src}" -c ${max_count} -T pdml -V -Q -Y "${filter}" 2>/dev/null >${dest}
    ${rc}    Process.Run Process    ${cmd}   shell=True



End Wireshark
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

    ${host_type}   Run Keyword If    "${host_type}"!="${EMPTY}"   Set Variable  ${host_type.upper()}
    Log To Console  End Wireshark, host_type:${host_type}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="FHGW"   _Get Wireshark From FHGW
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="FHGW"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="RUPROXY"   _Get Wireshark From RUPROXY
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="RUPROXY"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VDUC"   _Get Wireshark From VDUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VDUC"

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCUC"   _Get Wireshark From VCUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCUC"

    ${host_type}  Set Variable If   ${host_type.__len__()}>=3   ${host_type[0:3]}   ${host_type}
    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCU"   _Get Wireshark From VCU
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCU"

    Send CTRL_C Interactively   alias=${alias}
    Sleep  1

    ${host_type}    _Wireshark Get Host Type   alias=${alias}
    Run Keyword If  "${host_type}"=="OTHER"   _Get Wireshark From General Linux Server
             ...  initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}   alias=${alias}
       ...   ELSE   log  Unknown host to get wireshark!
    [Return]   ${log_dst_path}


Begin Wireshark General Sever
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     [Documentation]    Begin Wireshark General Sever
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | alias      | No | alias name  |
    ...
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be automatically deleted after calling 'End Wireshark'.
    ...
    ...    Example
    ...
    ...    For general linux server, including wireshark server/UTE server/CMP server/Classical OAM/NOM/OE server
    ...    | issh.Connect_To | ip=x.x.x.x |  username=myusername | password=mypassword |
    ...    | ${tmpfile_pcap} | Begin Wireshark General Sever  |  interface=eth0  |                |
    ...    | ${tmpfile_pcap} | Begin Wireshark General Sever |  interface=eth0  | filter=icmp    |
    ...    | ${tmpfile_pcap} | Begin Wireshark General Sever  |  interface=eth0  | filter=icmp and src host 1.1.1.1 |
    ...    | Sleep           |   3          |                 |                |
    ...    | ${local_file}   |   Get A File    |  Wireshark     |  mypcapfile.pcap  |
    ...    | End Wireshark General Sever  |  log_dst_path=${local_file}  |  log_src_path=${tmpfile_pcap} |
    ...    | ${xml_file}     |   Get A File     |   Wireshark    |  mypcapfile.xml |
    ...    | Analyze Pcap2xml |   ${local_file}  |   ${xml_file}  |                 |
    ...    | ${entries}       | cpdml.Get_Pdml_Entries |  ${xml_file}    | icmp.type   | show     | 8        |
    ...    | ${showname}      | cpdml.Get_Attrib_Value_From_Pdml_Entries |  ${entries} | icmp.type |   showname |
    ...    |  # Note: cpdml.Get_Attrib_Value_From_Pdml_Entries does not support XPATH! But pcap.get_field_value_by_xpath supports it |
    ...    | disconnect interactive connection |
    ...
    ...    For NOM
    ...    | SSH To NOM |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection  |
    ...
    ...    For NOM with alias
    ...    | SSH To NOM | alias=myalias |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp | alias=myalias |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ${tmpfilefullpath}     _Begin Tcpdump Wireshark In General Server  interface=${interface}   filter=${filter}  alias=${alias}

    [Return]     ${tmpfilefullpath}


End Wireshark General Sever
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
    Send CTRL_C Interactively   alias=${alias}
    Sleep  1

    _Get Wireshark From General Linux Server
             ...  initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}   alias=${alias}

    [Return]   ${log_dst_path}


Begin Wireshark F1 On VDU
    [Arguments]     ${filter}=${EMPTY}     ${including_vlan}=${False}    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark F1 On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.9.2021, chris.l.cao@nokia-sbell.com, add parameter filter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1 On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1 On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...

    ${handle}   _Begin Wireshark F1 On VDU For OCP  filter=${filter}     including_vlan=${including_vlan}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    [Return]   ${handle}


End Wireshark F1 On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark F1 On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1 On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1 On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    Log To Console    End Wireshark F1 On VDU
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}

    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    Disconnect Interactive Connection   alias=${node_alias}

    [Return]   ${log_dst_path}


Begin Wireshark F1U On VDU
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark F1U On VDU
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.11.2021, chris.l.cao@nokia-sbell.com, add parameter filter
    ...    9.3.2023, chris.l.cao@nokia-sbell.com, remove platform NCS code branch
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1U On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1U On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${handle}    _Begin Wireshark F1U On VDU For OCP   filter=${filter}   including_vlan=${including_vlan}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}

    [Return]   ${handle}


End Wireshark F1U On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark F1 On VDU
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1U On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1U On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    Log To Console    End Wireshark F1U On VDU
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
     Disconnect Interactive Connection   alias=${node_alias}
    [Return]   ${log_dst_path}


Begin Wireshark Mplane On VDU
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark Mplane On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | chris.l.cao@nokia-sbell.com | 2023-3-10 | get pod abbreviation from container oamagent to avoid POD split in future |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark Mplane On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark Mplane On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${handle}   _Begin Wireshark Mplane On VDU For OCP   filter=${filter}   including_vlan=${including_vlan}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    [Return]   ${handle}


End Wireshark Mplane On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark Mplane On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark Mplane On VDU |  filter=tcp |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark Mplane On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    Log To Console    End Wireshark Mplane On VDU
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    Disconnect Interactive Connection   alias=${node_alias}
    [Return]   ${log_dst_path}


Begin Wireshark FHM On VDU
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}   ${gnb_index}=${0}    ${vdu_index}=${0}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark FHM On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark FHM On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${platform}   Get Platform Name

    ${handle}  _Begin Wireshark FHM On VDU For OCP   filter=${filter}   including_vlan=${including_vlan}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    [Return]   ${handle}


End Wireshark FHM On VDU
    [Arguments]     ${log_dst_path}    ${handle}
    [Documentation]    End Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark FHM On VDU |  filter=tcp |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark FHM On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    Log To Console    End Wireshark F1 On VDU
    ${node_alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${node_alias}_","")}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    Disconnect Interactive Connection   alias=${node_alias}
    [Return]   ${log_dst_path}


_Begin Tcpdump Wireshark VDUC For OCP
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${gnb_index}  ${vdu_index}   ${alias}
    ${ctr_abbr}   Set Variable   ${container}

    ${host_type}  Set Variable  VDUC
    Log To Console   VDU index:${vdu_index}/${pod_abbr}/${ctr_abbr}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}   set variable   ${EMPTY}

    ${alias_create_tmp}  get unique id
    Connect To VDU Container With Tenant Interactively    pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}
    ...    alias=${alias_create_tmp}    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${out}  issh.Execute  command=mkdir -p ${pcap_folder}
            ...  alias=${alias_create_tmp}
    ${out}  issh.Execute  command=ls -l ${pcap_folder}
            ...  alias=${alias_create_tmp}

    ${tmpfilename}  _Get Temp File Name HIGH_WITH_FORMAT_DATETIME_EPOCH
      ...    host_type=${host_type}   fhgw_or_vdu_index=${vdu_index}   pod_abbr=${pod_abbr}  container_id=${ctr_abbr}
      ...    gnb_index=${gnb_index}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #start capture
     ${pid}   Get PID For Container From Pod Abbr  pod_abbr=${pod_abbr}   ctr_abbr=${ctr_abbr}  alias=${alias}
    ${full_cmd}   set variable  sudo nsenter -m -n -t ${pid} ${cmd}
    #sudo nsenter -m -n -t 748554 tcpdump -i mcplane  icmp -s 0 -w /tmp/chris1.pcap

    log to console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}
    Sleep   5s

    #process guard
    ${alias_process_guard}  Get Unique Id
    Connect To K8s Master Interactively    alias=${alias_process_guard}  vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${out}   issh.Execute     command=ps -ef|grep tcpdump|grep ${tmpfilenamefullpath}|wc -l   alias=${alias_process_guard}
    Log To Console  ${out}
    ${out}   Strip Prompt   ${out}
    ${out}   Evaluate   int(${out})
    Run Keyword If   ${out}<${2}    fail
    [Return]    ${tmpfilenamefullpath}
    [Teardown]    Run Keywords   Disconnect Interactive Connection   alias=${alias_create_tmp}   AND
    ...  Disconnect Interactive Connection   alias=${alias_process_guard}



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
    Disconnect Interactive Connection   alias=${alias}
    [Return]   ${log_dst_path}


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


_Begin Wireshark FHM On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}    ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]   _Begin Wireshark FHM On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | chris.l.cao@nokia-sbell.com | 2023-5-7 | change to 'Connect To K8s Master With Tenant Interactively' |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...
    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}    vdu_index=${vdu_index}  alias=${alias}

    ${container_abbr}   set variable   nwmgmt
    ${pod_abbr}     set variable   oamfh

    ${real_interface}   Set Variable If   "${including_vlan}"=="${False}"   fhmplane   fhm
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=${real_interface}   filter=${filter}   pod_abbr=${pod_abbr}
    ...      container=${container_abbr}     gnb_index=${gnb_index}    vdu_index=${vdu_index}     alias=${alias}

    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark F1 On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}   ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]    _Begin Wireshark F1 On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | chris.l.cao@nokia-sbell.com | 2023-3-10 | get pod abbreviation from container cprt to avoid POD split in future |
    ...    | chris.l.cao@nokia-sbell.com | 2023-5-7 | change to 'Connect To K8s Master With Tenant Interactively' |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1 On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1 On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...

    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively  gnb_index=${gnb_index}    vdu_index=${vdu_index}   alias=${alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=cprt  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${container_abbr}   set variable   nwmgmt

    ${real_interface}   Set Variable If   "${including_vlan}"=="${False}"   f1cplane   f1c
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=${real_interface}   filter=${filter}   pod_abbr=${pod_abbr}
    ...       container=${container_abbr}     gnb_index=${gnb_index}    vdu_index=${vdu_index}   alias=${alias}
    ${handle}   set variable   ${alias}_${tmp_file}

    [Return]   ${handle}


_Begin Wireshark Mplane On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}   ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]    _Begin Wireshark Mplane On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | chris.l.cao@nokia-sbell.com | 2023-5-7 | change to 'Connect To K8s Master With Tenant Interactively' |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle

    ...
    ...    Example
    ...
    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}    vdu_index=${vdu_index}  alias=${alias}

    ${container_abbr}   set variable   nwmgmt
#    ${pod_abbr}    set variable   oamext
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation  container_abbr=oamagent  vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${real_interface}   Set Variable If   "${including_vlan}"=="${False}"   mcplane   oam
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=${real_interface}   filter=${filter}   pod_abbr=${pod_abbr}
    ...     container=${container_abbr}     gnb_index=${gnb_index}    vdu_index=${vdu_index}     alias=${alias}
    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}


_End Wireshark VDUC
    [Arguments]     ${log_dst_path}    ${log_src_path}   ${alias}=default
    [Documentation]    _End Wireshark VDUC
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

    Should Be True   "${host_type}"=="VDUC"
    ${tmpfilefullpath}   _Get Wireshark From VDUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}

    [Return]   ${log_dst_path}


_Get Wireshark From VDUC
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From VDUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From FHGW | /tmp/tmp_wireshark/ws_VDUC_0_oamcp_bd257c6e4911_ec22b41be53342c7a9a3f20d0d8a1e8d.pcap | /home/ute/oam.pcap |
    ...
    ${platform}   Get Platform Name

    ${tmpfilenamefullpath}  _Get Wireshark From VDUC For Ocp  initial_log_path=${initial_log_path}
      ...   log_stored_path=${log_stored_path}  alias=${alias}

    [Return]    ${tmpfilenamefullpath}


_Get Wireshark From VDUC For Ocp
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias_container}
    [Documentation]   _Get Wireshark From VDUC
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | chris.l.cao@nokia-sbell.com | 2022-7-24 | connect to vdu container to execute command to fix occasional error |
    ...    | lingting.sun@nokia-sbell.com | 2023-5-6 | fix for /bin/gzip does not exist in container |
    ...    | chris.l.cao@nokia-sbell.com | 2023-5-7 | still exists 'Permission denied' |
    ...    |       |  | fix it by using ssh instance of parameter ${alias} to copy .pcap from container to OE server |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | _Get Wireshark From VDUC For Ocp | /tmp/tmp_wireshark/a.pcap | /home/ute/oam.pcap |
    ...
    ${out}   Send CTRL_C Interactively    alias=${alias}
    sleep  2
    ${out}   issh.Execute  command=sync     alias=${alias}

    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}   set variable  ${EMPTY}

    #parse vdu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${gnb_index}  Set Variable  ${tmp[-1]}
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${ns}    Get vDU Namespace From TestLine    vdu_index=${vdu_index}
    ${pod_full_name}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   vdu_index=${vdu_index}  alias=${alias}
    ${container_full_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${alias_container}   Get Unique Id
    Connect To VDU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=${container}  alias=${alias_container}
    ${out}   issh.Execute   command=sync;ls -l ${pcap_folder}   check_result=${False}  alias=${alias_container}

    ${out}    issh.Execute     command=mkdir -p ${pcap_folder}    alias=${alias}
    ${out}    issh.Execute     command=ls -l ${pcap_folder}   alias=${alias}

    ${remote_log_path}   set variable   ${initial_log_path}


    # oc exec -i po-cran1-oamext-0 -c ctr-cran1-nwmgmt  cat /tmp/1.cap > local.cap

#    ${alias_copy_file}  get unique id
#    Connect To K8s Master With Tenant Interactively    alias=${alias_copy_file}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${alias_copy_file}  Set Variable   ${alias}
    ${cp_cmd}   set variable
      ...  oc exec -i ${pod_full_name} -c ${container_full_name} -- cat ${initial_log_path} > ${remote_log_path}

    ${out}    Wait Until Keyword Succeeds  15x  2  issh.Execute     command=${cp_cmd}    alias=${alias_copy_file}

    ${out}    issh.Execute     command=sync    alias=${alias_copy_file}

    issh.Download File   remote_path=${remote_log_path}    local_path=${log_stored_path}   alias=${alias_copy_file}
    ${out}  issh.Execute  command=rm -f ${remote_log_path}     alias=${alias_copy_file}

    _Delete Old Wireshark File In VDUC Interactively   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias_container}

    _Delete Old Wireshark File In VDUC Master Node   initial_log_path=${initial_log_path}   alias=${alias}



###################### wireshark releated sub kw ################
_Begin Tcpdump Wireshark In General Server
    [Arguments]   ${interface}    ${filter}   ${alias}=default
    ${out}    issh.Execute     command=mkdir -p /tmp/tmp_wireshark    alias=${alias}
    ${out}    issh.Execute     command=ls /tmp/tmp_wireshark   alias=${alias}

    ${tmpfilename}    _Get Temp File Name
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    issh.Execute_Bare   command=${cmd}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${tmpfilenamefullpath}

_Get Wireshark From General Linux Server
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}=default
    [Documentation]    Get log to local from wireshark server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  initial_log_path  |  Yes |  Where is log stored on wireshark server |
    ...    |  log_stored_path | Yes | Where to save log on local PC  |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Get Wireshark From Server   |   /tmp/tmp_wireshark/ws_10.70.38.195_1514196349_69532.pcap   |  /home/ute/oam.pcap |
    issh.Execute  command=sync    check_result=${False}   alias=${alias}
    Sleep    1

    ${sudo}  Get Sudo Via Interactive SSH   alias=${alias}
    issh.Execute  command=${sudo} chmod 777 ${initial_log_path}   check_result=${False}   alias=${alias}

    issh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   alias=${alias}
    ${out}  issh.Execute  command=${sudo} rm -f ${initial_log_path}     alias=${alias}
    _Remove All Temp File If Needed From General Linux Server   FolderName=/tmp/tmp_wireshark/    alias=${alias}


_Delete Old Wireshark File In VDUC Interactively
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${out}  issh.Execute  command=rm -f ${initial_log_path}   check_result=${False}   alias=${alias}

    _Remove All Temp File If Needed From VDUC Interactively   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}


_Begin Wireshark F1U On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}   ${including_vlan}=${False}   ${gnb_index}=${0}    ${vdu_index}=${0}
    [Documentation]    _Begin Wireshark F1U On VDU For OCP
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    9.3.2023, chris.l.cao@nokia-sbell.com, adapt to UP pod split into l2rt and l2nrt
    ...    5.7.2023, chris.l.cao@nokia-sbell.com, change to 'Connect To K8s Master With Tenant Interactively'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...   | including_vlan  |  No | default is false |
    ...   | gnb_index  |  No | gnb index, default is 0 |
    ...   | vdu_index  |  No | vdu index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...   | ${handle} | Begin Wireshark F1U On VDU |  filter=tcp and port 8080 |
    ...   | sleep      |  350 |
    ...   | ${local_pcap} | Get A File  Wireshark |   step2.pcap  |
    ...   |  End Wireshark F1U On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...

    ${alias}  Get Unique ID
    Connect To K8s Master With Tenant Interactively    gnb_index=${gnb_index}    vdu_index=${vdu_index}    alias=${alias}

    ${container_abbr}   set variable   nwmgmt
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=l2hi  vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${real_interface}   Set Variable If   "${including_vlan}"=="${False}"   f1uplane   f1u
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=${real_interface}   filter=${filter}   pod_abbr=${pod_abbr}
    ...       container=${container_abbr}     gnb_index=${gnb_index}    vdu_index=${vdu_index}       alias=${alias}

    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}


Download And Extract Mcshark Package
    [Arguments]   ${mcshark_path}   ${package_name}=${EMPTY}
    [Documentation]    Download And Extract mcshark Package from WFT for each package
    ...    *AUTHOR* rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-3-30 | Update the method of download mcshark |
    ...    | r3li | 2022-7-11 | update saving path of tshark |
    ...    *Arguments Description*
    ...    |  Input Parameters | Man. | Description |
    ...    | mcshark_path  |  Yes |  A path to save mcshark |
    ...    | package_name | No | vdu package name, such as vDUCNF,vDUCNF22R2 |
    ...
    ...    Example
    ...    | ${luashark_path}   |   Get A Directory    |  mcshark  |
    ...    | Download And Extract Mcshark Package | mcshark_path=${mcshark_path} |  vdu_version=0.390.2090  |
    ${sw_version}    Get Current vDU Version
    ${package_name}   Get Package Prefix From Global Variables File   ${sw_version}
    ${all_file_url}   set variable    ${MCSHARK_LINK}/${package_name}_${sw_version}
    ${mcshark_filename}    _Get Mcshark File Name    ${all_file_url}   ${mcshark_path}   ${package_name}_${sw_version}
    ${download_url}   set variable    ${all_file_url}/${mcshark_filename}
    OperatingSystem.Run   command=wget -P ${mcshark_path} ${download_url}
    ${mcshark_file_path}   OperatingSystem.Join Path   ${mcshark_path}   ${mcshark_filename}
    ${file_name_list}    Split String     ${mcshark_filename}    -
    ${mcshark_version}    Set Variable     ${file_name_list[1]}
    ${mcshark_install_path}    Set Variable   /usr/lib/x86_64-linux-gnu/wireshark/plugins/${mcshark_version}/epan/mcshark.so
    OperatingSystem.Run    sudo cp ${mcshark_file_path} ${mcshark_install_path}
    OperatingSystem.File Should Exist    ${mcshark_install_path}

_Get Mcshark File Name
    [Arguments]    ${url}   ${file_path}    ${package_version_name}
    OperatingSystem.Run   command=wget -P ${file_path} ${url}
    ${file_name}    get_info_from_file_with_re    ${file_path}/${package_version_name}    >mcshark.+buster\.so
    ${file_name}    Get Substring   ${file_name}    1
    [Return]   ${file_name}


Convert BIP File To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    Convert Bip Log File to Csv File
    ...    *AUTHOR* rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-3-30 | Add |
    ...    | r3li | 2022-7-11 | Update the syntax of the For Loop |
    ...    |  Input Parameters | Man. | Description |
    ...    | bip_file  | Yes | bip file path |
    ...    | output_file | Yes | the file path of convert result saved |
    ...    | filter    |  Yes |  filter condition |
    ...    | csv_title_list | Yes |  csv title list |
    ...
    ...    *RETURN VALUE*
    ...    csv file path after convert
    ...
    ...    Example
    ...    | Convert BIP To CSV By MCShark | Bip_cell2.pcap | 1.csv | uldata_puschreceiverespps | [3gpp.sfn, 3gpp.slot] |
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    [Return]   ${output_file}


Download Luashark For VDU And Return Path
    [Arguments]    ${path}=${LUA_SCRIPT_PATH}
    [Documentation]  Download luashark script form artifactory and extract to /home/ute/lua_script/
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <22-Jun-2021>, <lingtsun>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  path       | No   |  extract dir of lua script, default is the global param ${LUA_SCRIPT_PATH} |
    ...    RETURN VALUE
    ...    the path of luashark.lua
    ...    Example
    ...    |  Download Luashark For VDU And Return Path |
    _Renew luashark
    ${vdu_release}=   Get Running Build Number
    _Download luashark from Artifactory    ${vdu_release}
    ${luashark_path}    _Extract Luashark    ${vdu_release}   ${path}
    ${cmd}    Catenate     SEPARATOR=    rm -rf luashark-    ${vdu_release}   .zip
    Run And Expect Command To Pass    command=${cmd}  msg=remove
    [Return]    ${luashark_path}


_Renew luashark
    log   ${LUA_SCRIPT_PATH}
    RUN   rm -rf ${LUA_SCRIPT_PATH}
    Run   mkdir ${LUA_SCRIPT_PATH}


_Download luashark from Artifactory
    [Arguments]   ${vdu_release}
    ${wget_command}    Catenate     SEPARATOR=    wget    ${SPACE}    ${LUA_SCRIPT_LINK}   ${vdu_release}
    ...     /luashark-    ${vdu_release}   .zip
    Run And Expect Command To Pass    command=${wget_command}   msg=Download of Luashark from Artifactory for ${vdu_release}


_Extract Luashark
    [Arguments]   ${vdu_release}    ${path_to_extract}
    ${unzip_luashark_command}    Catenate    SEPARATOR=    unzip luashark-    ${vdu_release}    .zip -d ${path_to_extract}
    Run And Expect Command To Pass    command=${unzip_luashark_command}   msg=Extract of Luashark Zip for ${vdu_release}
    ${luashark_path}    Catenate    SEPARATOR=    ${path_to_extract}    /generated_luashark/luashark.lua
    [Return]    ${luashark_path}

