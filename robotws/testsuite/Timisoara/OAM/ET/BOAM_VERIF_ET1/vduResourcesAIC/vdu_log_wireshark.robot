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



Begin Wireshark
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     ...   ${host_type}=${EMPTY}   ${index}=0    ${ru_index}=1   ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}
     [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ...    Target server includes VCU VM/VDU container/FHGW/FHGW ruproxy container/wireshark server/UTE server/CMP server/Classical OAM/NOM.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | interface  |  Yes |  the interface name where wireshark log is captured |
    ...    | filter     | No | capturing filter |
    ...    | host_type   | No | Valid value is FHGW, VDUC, RUPROXY, VCU or ${EMPTY}. |
    ...    |            |    | when host_type is FHGW, it means to capture log in FHGW server |
    ...    |            |    | when host_type is RUPROXY, it means to capture log in FHGW RUPROXY container |
    ...    |            |    | when host_type is VDUC, it means to capture log in vDU Container, and pod_abbr/container/index are used |
    ...    |            |    | when host_type is ${EMPTY}, it means to capture wireshark log linux server except FHGW/VDUC |
    ...    |            |    | Default value is ${EMPTY}. Please see example as below |
    ...    | index     | No | when host_type is VDUC, it means vdu_index, default value is 0. Note: it's not used when host_type is FHGW |
    ...    | ru_index  | No | Radio Unit index, when host_type is RUPROXY, it is meanfull, default value is 1 |
    ...    | alias      | No | alias name  |
    ...    | pod_abbr  | No | when host_type is VDUC, it is used |
    ...    | container | No | when host_type is VDUC, it is used |
    ...
    ...    *RETURN VALUE*
    ...    Wireshark temporary file name in target server. It will be automatically deleted after calling 'End Wireshark'.
    ...
    ...    Example
    ...    For general linux server, including wireshark server/UTE server/CMP server/Classical OAM/NOM/OE server
    ...    | issh.Connect_To | ip=x.x.x.x |  username=myusername | password=mypassword |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |                        |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |    icmp                |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  eth0  |    icmp and src host 1.1.1.1 |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  |                |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  | filter=icmp    |
    ...    | ${tmpfile_pcap} | Begin Wireshark  |  interface=eth0  | filter=icmp and src host 1.1.1.1 |
    ...    | Sleep           |   3          |                 |                |
    ...    | ${local_file}   |   Get A File    |  Wireshark     |  mypcapfile.pcap  |
    ...    | End Wireshark   |  log_dst_path=${local_file}  |  log_src_path=${tmpfile_pcap} |
    ...    | ${xml_file}     |   Get A File     |   Wireshark    |  mypcapfile.xml |
    ...    | Analyze Pcap2xml |   ${local_file}  |   ${xml_file}  |                 |
    ...    | ${entries}       | cpdml.Get_Pdml_Entries |  ${xml_file}    | icmp.type   | show     | 8        |
    ...    | ${showname}      | cpdml.Get_Attrib_Value_From_Pdml_Entries |  ${entries} | icmp.type |   showname |
    ...    |  # Note: cpdml.Get_Attrib_Value_From_Pdml_Entries does not support XPATH! But pcap.get_field_value_by_xpath supports it |
    ...    | disconnect interactive connection |
    ...
    ...    For FHGW host
    ...    | Connect To FHGW |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | host_type=FHGW  | |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | filter=icmp | host_type=FHGW  | |
    ...    | Sleep           | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |  |
    ...    | disconnect interactive connection |
    ...
    ...    For FHGW host with alias
    ...    | Connect To FHGW | alias=myalias |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | host_type=FHGW  | alias=myalias |
    ...    | ${tmpfile_pcap} | Begin Wireshark | interface=eth0 | filter=icmp | host_type=FHGW | alias=myalias |
    ...    | Sleep           | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ...    For RUPROXY container in FHGW
    ...    | Connect To FHGW |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=eth0 | host_type=RUPROXY | ru_index=1 |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |  |
    ...    | Disconnect From FHGW |
    ...
    ...    For RUPROXY container in FHGW with alias
    ...    | Connect To FHGW | alias=myalias |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=eth0 | host_type=RUPROXY | alias=myalias |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | issh.Disconnect | alias=myalias |
    ...
    ...    For VDUC(VDU Container)
    ...    | Connect to vDU Node | pod_abbr=oamcp | vdu_index=0 | master_alias=alias1 | node_alias=alias2 |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=oamfh | host_type=VDUC | pod_abbr=oamcp | container=oamfh | alias=alias2 |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=alias2 |
    ...    | tafssh.disconnect | connection=alias2 |
    ...    | tafssh.disconnect | connection=alias1 |
    ...
    ...    For VCUC(VCU CNF Container)
    ...    | ${alias} | Connect To CU K8S Master With Admin | vdu_index=0  |
    ...    | ${tmpfile_pcap}  | Begin Wireshark | interface=f1c | host_type=VCUC | pod_abbr=cpif | container=cpif | alias=${alias} |
    ...    | Sleep            | 3 |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=${alias} |
    ...    | disconnct interactively connection | alias=${alias} |
    ...
    ...    For VCU VM
    ...    | CU SSH To OAM |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=oam | host_type=VCU | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | ${all_packets}   | pcap.load_pcap_file | pcap_file=${local_file} |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=ip.src==10.69.66.199 |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=x2ap |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//icmp.type |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//x2ap.X2AP_PDU//x2ap.pLMN_Identity/e212.mcc |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} |
    ...    |  ...   | xpath=.//x2ap.X2AP_PDU//x2ap.value_element/x2ap.SgNBAdditionRequest_element/x2ap.protocolIEs |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//e212.mcc                            |
    ...    | disconnect interactive connection |
    ...
    ...    For VCU CPIF
    ...    | CU SSH To CPIF |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=x2 | host_type=VCU |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection|
    ...
    ...    For VCU CPIF with alias
    ...    | CU SSH To CPIF | alias=myalias |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=x2 | host_type=VCU | alias=myalias |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} | alias=myalias |
    ...    | disconnect interactive connection | alias=myalias |
    ...
    ...    For LTE classical OAM
    ...    | Connect To LTE |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=br1 | filter=sctp |
    ...    | sleep           |  30   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | ${all_packets}   | pcap.load_pcap_file | pcap_file=${local_file} |
    ...    | ${pkts_after_filter} | pcap.filter_packets_by_expression | pdml_list=${all_packets} | filter_expression=ip.src==10.69.66.199 |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//x2ap.X2AP_PDU//x2ap.pLMN_Identity/e212.mcc |
    ...    | ${out} | pcap.get_field_value_by_xpath     | pdml_list=${pkts_after_filter} | xpath=.//e212.mcc                            |
    ...    | disconnect interactive connection  |
    ...
    ...    For UTE
    ...    | Connect To UTE |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=eth0 | filter=icmp |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | issh.Disconnect |
    ...
    ...    For OE server
    ...    |  Connect To K8s Master Interactively |
    ...    | ${tmpfile_pcap} |  Begin Wireshark | interface=ens11f0 |
    ...    | sleep           |  10   |
    ...    | ${local_file}   | Get A File  |   Wireshark  | mypcapfile.pcap |
    ...    | End Wireshark   | log_dst_path=${local_file} | log_src_path=${tmpfile_pcap} |
    ...    | disconnect interactive connection  |
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
    ${host_type}   Set Variable If    "${host_type}"!="${EMPTY}"     ${host_type.upper()}   ${EMPTY}
    Run Keyword If    "${host_type}"!="${EMPTY}"   Log To Console  Begin Wireshark, host_type:${host_type}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="FHGW"    _Begin Tcpdump Wireshark FHGW   index=${index}
      ...   interface=${interface}    filter=${filter}   alias=${alias}
    Return From Keyword If   "${host_type}"=="FHGW"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="RUPROXY"    _Begin Tcpdump Wireshark RUPROXY     index=${index}
      ...   interface=${interface}    filter=${filter}   alias=${alias}   ru_index=${ru_index}
    Return From Keyword If   "${host_type}"=="RUPROXY"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VDUC"    _Begin Tcpdump Wireshark VDUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}   index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VDUC"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCUC"    _Begin Tcpdump Wireshark VCUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}  index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCUC"   ${tmpfilefullpath}

    ${tmpfilefullpath}  Run Keyword If  "${host_type}"=="VCU"    _Begin Tcpdump Wireshark VCU    interface=${interface}    filter=${filter}
      ...    index=${index}   alias=${alias}
    Return From Keyword If   "${host_type}"=="VCU"   ${tmpfilefullpath}

    ${host_type}    _Wireshark Get Host Type   alias=${alias}
    Log To Console  Begin Wireshark, hostname:${host_type}

    ${tmpfilefullpath}   Run Keyword If  "OTHER"=="${host_type}"   _Begin Tcpdump Wireshark In General Server  interface=${interface}
      ...   filter=${filter}  alias=${alias}
    ...    ELSE   Log   Unknow linux server!

    [Return]     ${tmpfilefullpath}


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
    [Arguments]     ${filter}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark F1 On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.9.2021, chris.l.cao@nokia-sbell.com, add parameter filter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    ${platform}   Get Platform Name

#    ${handle}   runkeyword if    "${platform}"=="NCS"   _Begin Wireshark F1 On VDU For NCS  filter=${filter}
#    ...   ELSE    _Begin Wireshark F1 On VDU For OCP   filter=${filter}
    ${handle}   runkeyword if    "${platform}"=="NCS"   Fail  NCS platform is not supported!
    ...   ELSE    _Begin Wireshark F1 On VDU For OCP   filter=${filter}

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
#    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}


    [Return]   ${log_dst_path}


Begin Wireshark F1U On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark F1U On VDU
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.11.2021, chris.l.cao@nokia-sbell.com, add parameter filter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    ${platform}   Get Platform Name

#    ${handle}   runkeyword if    "${platform}"=="NCS"   _Begin Wireshark F1 On VDU For NCS  filter=${filter}
#    ...   ELSE    _Begin Wireshark F1U On VDU For OCP   filter=${filter}

    ${handle}   runkeyword if    "${platform}"=="NCS"   Fail  NCS platform is not supported!
    ...   ELSE    _Begin Wireshark F1U On VDU For OCP   filter=${filter}


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
#    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}

    [Return]   ${log_dst_path}


Begin Wireshark Mplane On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark Mplane On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    ${platform}   Get Platform Name

#    ${handle}   runkeyword if    "${platform}"=="NCS"   _Begin Wireshark Mplane On VDU For NCS   filter=${filter}
#    ...   ELSE    _Begin Wireshark Mplane On VDU For OCP   filter=${filter}
#
    ${handle}   runkeyword if    "${platform}"=="NCS"   Fail  NCS Platform is not supported!
    ...   ELSE    _Begin Wireshark Mplane On VDU For OCP   filter=${filter}

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
    #End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    [Return]   ${log_dst_path}


Begin Wireshark FHM On VDU
    [Arguments]     ${filter}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin Wireshark FHM On VDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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

#    ${handle}   runkeyword if    "${platform}"=="NCS"   _Begin Wireshark FHM On VDU For NCS  filter=${filter}
#    ...   ELSE    _Begin Wireshark FHM On VDU For OCP   filter=${filter}
    ${handle}   runkeyword if    "${platform}"=="NCS"   Fail  NCS Platform is not supported!
    ...   ELSE    _Begin Wireshark FHM On VDU For OCP   filter=${filter}

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
#    End Wireshark     log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}
    _End Wireshark VDUC    log_dst_path=${log_dst_path}   log_src_path=${log_src_path}   alias=${node_alias}

    [Return]   ${log_dst_path}


Download And Extract Luashark Package
    [Arguments]  ${luashark_path}  ${vdu_version}
     [Documentation]    Download And Extract Luashark Package from website, return luashark path
    ...    *AUTHOR* rainie.wu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | luashark_path  |  Yes |  the interface name where wireshark log is captured |
    ...    | vdu_version     | Yes | capturing filter |
    ...
    ...    *RETURN VALUE*
    ...    Path of Luashark
    ...
    ...    Example
    ...    | ${luashark_path}   |   Get A Directory    |  Luashark  |
    ...    | Download And Extract Luashark Package | luashark_path=${luashark_path} |  vdu_version=0.390.2090  |

    ${Luashark_Link}=  SET VARIABLE  https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
    OperatingSystem.Run   command=wget -P ${luashark_path} ${Luashark_Link}/${vdu_version}/luashark-${vdu_version}.zip
    OperatingSystem.Run
    ...  command=cd ${luashark_path};unzip luashark-${vdu_version}.zip -d luashark
    [Return]  ${luashark_path}


_Begin Tcpdump Wireshark VDUC
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}  ${alias}
    [Tags]  CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin wireshark in vDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.08.2020, gang.ni@nokia-sbell.com, add more delay time after start capture to improve robust
    ...    18.08.2020, chris.l.cao@nokia-sbell.com, add platform OCP support
    ...
    ${platform}   Get Platform Name

#    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
#    ...   _Begin Tcpdump Wireshark VDUC For NCIR OR NCS   interface=${interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=${container}
#    ...              index=${index}   alias=${alias}
#    ...   ELSE   _Begin Tcpdump Wireshark VDUC For OCP   interface=${interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=${container}
#    ...              index=${index}   alias=${alias}

    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...   Fail  NCIR and NCS platform for VDU are not supported!
    ...   ELSE   _Begin Tcpdump Wireshark VDUC For OCP   interface=${interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=${container}
    ...              index=${index}   alias=${alias}

    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VDUC For NCIR OR NCS
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}  ${alias}
    [Documentation]    Begin wireshark in vDU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    25.08.2020, gang.ni@nokia-sbell.com, add more delay time after start capture to improve robust

    ${host_type}  Set Variable  VDUC
    ${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${index}
    #${container_id}  Get VDU Container ID   container_name=${container}   connection=${alias}   vdu_index=${index}   pod_abbr=${pod_abbr}
    Log To Console   ${index}/${pod_abbr}/${container}:${container_id}

    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} ls /tmp/tmp_wireshark   connection=${alias}

    ${tmpfilename}    _Get Temp File Name
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container_id}
    ${tmpfilenamefullpath}    Set Variable    /tmp/tmp_wireshark/ws_${tmpfilename}.pcap

    ${sudo}    Get Sudo VDUC    container_id=${container_id}   alias=${alias}
    ${cmd}    Set Variable If    '${filter}'==''    ${sudo} tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    ${sudo} tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #prepare tcpdump_guard script
    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard"]}
    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo

    ${target}   Create List   ${pod_abbr}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""
    ...  tafssh.Execute  command=rm -f ${version_file}   connection=${alias}
    Run Keyword If     """No such file or directory""" in """${out}"""     Upload Tools To Vdu Nodes   target=${target}
    ${out}  tafssh.Execute  command=ls ${tcpdump_guard}   connection=${alias}
    Should Be True   """No such file or directory""" not in """${out}"""

    ${alias_process_guard}   Get Unique Id
    Connect To VDU Node Interactively   pod_abbr=${pod_abbr}     alias=${alias_process_guard}
    ${out}   issh.Execute     command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}

    #start capture
    tafssh.Send Command    command=sudo docker exec -it ${container_id} ${cmd}   connection=${alias}   get_pty=${True}
    Sleep   6s

    #process guard
    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard"]} -a ${tmpfilename} &)   alias=${alias_process_guard}
    ${out}   issh.Execute      command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard"]}   alias=${alias_process_guard}
    Log To Console  ${out}

    [Return]    ${tmpfilenamefullpath}

#
#_Begin Tcpdump Wireshark VDUC For OCP
#    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}   ${alias}
#    ${host_type}  Set Variable  VDUC
#    Log To Console   VDU index:${index}/${pod_abbr}/${container}
#    ${pcap_folder}   set variable    /tmp/tmp_wireshark
#    ${sudo_outer}   set variable   ${EMPTY}
#
#    ${ns}   Get vDU Namespace From TestLine  gnb_index=${index}  vdu_index=${index}
#    ${full_pod_name}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${index}  alias=${alias}
#
#    ${full_container_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${container}  vdu_index=${index}
#
#    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}
#            ...  alias=${alias}
#    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}
#            ...  alias=${alias}
#
#    ${tmpfilename}  _Get Temp File Name HIGH_WITH_FORMAT_DATETIME_EPOCH
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
#    Upload Tools To K8s Master
#
#    #prepare tcpdump_guard script
#    ${tcpdump_guard}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}
#    ${version_file}   OperatingSystem.Join Path   ${TOOLS_INFO["work_folder_tool"]}   version.repo
#    ${out}  issh.Execute   command=ls ${tcpdump_guard}   alias=${alias}
#    Should Be True   """No such file or directory""" not in """${out}"""
#
#    #start capture
#    ${full_cmd}   set variable  ${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ${cmd}
#    log to console   ${full_cmd}
#    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
#    ${out}   Send ENTER Interactively   alias=${alias}
#    Sleep   5s
#
#    #process guard
#    ${alias_process_guard}  Get Unique Id
#    Connect To K8s Master Interactively    alias=${alias_process_guard}  vdu_index=${index}
#    ${out}   issh.Execute    command=cd ${TOOLS_INFO["work_folder_tool"]}   alias=${alias_process_guard}
#    ${out}   issh.Execute    command=${sudo_outer} kubectl get pod ${full_pod_name} -o wide -n ${ns}|grep -v NAME|awk '{print $7}'
#      ...  alias=${alias_process_guard}
#
#    ${out}   issh.Execute     command=ps -ef|grep tcpdump   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    ${out}   issh.Execute     command=ps -ef|grep tcpdump|grep ${tmpfilename}|wc -l   alias=${alias_process_guard}
#    ${out}   Strip Prompt  ${out}
#    Run Keyword If   ${out}!=2  Fail  Failed to launch tcpdump, e.g, you should set privilege to true if run it in oamagent!
#
#    ${out}   issh.Execute     command=(./${TOOLS_INFO["tcpdump_guard_vdu_ocp"]} -a ${tmpfilename} &)   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    ${out}   issh.Execute     command=ps -ef|grep ${TOOLS_INFO["tcpdump_guard_vdu_ocp"]}   alias=${alias_process_guard}
#    Log To Console  ${out}
#
#    [Return]    ${tmpfilenamefullpath}


_Begin Tcpdump Wireshark VDUC For OCP
    [Arguments]   ${interface}    ${filter}   ${pod_abbr}   ${container}   ${index}   ${alias}
    ${host_type}  Set Variable  VDUC
    Log To Console   VDU index:${index}/${pod_abbr}/${container}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${sudo_outer}   set variable   ${EMPTY}

    ${ns}   Get vDU Namespace From TestLine  gnb_index=${index}  vdu_index=${index}
    ${full_pod_name}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${index}  alias=${alias}

    ${full_container_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${container}  vdu_index=${index}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}
            ...  alias=${alias}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  alias=${alias}

    ${tmpfilename}  _Get Temp File Name HIGH_WITH_FORMAT_DATETIME_EPOCH
      ...    host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap


    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}

    #start capture
#    ${full_cmd}   set variable  ${sudo_outer} kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ${cmd}
     ${pid}   Get PID For Container   container=${full_container_name}  alias=${alias}
    ${full_cmd}   set variable  sudo nsenter -m -n -t ${pid} ${cmd}
    #sudo nsenter -m -n -t 748554 tcpdump -i mcplane  icmp -s 0 -w /tmp/chris1.pcap

    log to console   ${full_cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}
    Sleep   5s

    #process guard
    ${alias_process_guard}  Get Unique Id
    Connect To K8s Master Interactively    alias=${alias_process_guard}  vdu_index=${index}

    ${out}   issh.Execute     command=ps -ef|grep tcpdump   alias=${alias_process_guard}
    Log To Console  ${out}

    ${out}   issh.Execute     command=ps -ef|grep tcpdump|grep ${tmpfilename}|wc -l   alias=${alias_process_guard}
    ${out}   Strip Prompt  ${out}
    Run Keyword If   ${out}!=2  Fail  Failed to launch tcpdump, e.g, you should set privilege to true if run it in oamagent!

    [Return]    ${tmpfilenamefullpath}


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
    Log To Console  Begin Wireshark, host_type:${host_type}

    ${tmpfilefullpath}    _Begin Tcpdump Wireshark VCUC    interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}  index=${index}   alias=${alias}

    [Return]     ${tmpfilefullpath}


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
    Log To Console  End Wireshark, host_type:${host_type}

    Should Be True   "${host_type}"=="VCUC"
    ${tmpfilefullpath}   _Get Wireshark From VCUC
      ...   initial_log_path=${log_src_path}  log_stored_path=${log_dst_path}
      ...   alias=${alias}

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


_Begin Wireshark FHM On VDU For NCS
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark FHM On VDU For NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    ${container_abbr}   set variable   oamfh
    ${network}    set variable   fhm
    Connect to vDU Node   container_abbr=${container_abbr}    master_alias=${master_alias}    node_alias=${node_alias}
    ${oam_interface}   Get VDU Container Interface Name   container=${container_abbr}  network=${network}   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
#    ${tmp_file}   Begin Wireshark  interface=${oam_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${node_alias}  filter=${filter}
    ${tmp_file}   _Begin Tcpdump Wireshark VDUC For NCIR OR NCS
     ...   interface=${oam_interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}   index=0  alias=${node_alias}
    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark FHM On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]   _Begin Wireshark FHM On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...
    ${alias}  Get Unique ID
    Connect To K8s Master Interactively  alias=${alias}

    ${container_abbr}   set variable   oamfh
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}

#    ${tmp_file}   Begin Wireshark  interface=fhmplane  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${alias}  filter=${filter}
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=fhmplane   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}
    ...          index=0       alias=${alias}

    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark F1 On VDU For NCS
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark F1 On VDU For NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    Connect to vDU Node   container_abbr=cprt    master_alias=${master_alias}    node_alias=${node_alias}
    ${f1_c_interface}   Get VDU Container Interface Name   container=cprt  network=f1   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=cprt
#    ${tmp_file}   Begin Wireshark  interface=${f1_c_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=cprt
#       ...   alias=${node_alias}  filter=${filter}
    ${tmp_file}   _Begin Tcpdump Wireshark VDUC For NCIR OR NCS
     ...   interface=${f1_c_interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=cprt   index=0  alias=${node_alias}

    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark F1 On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark F1 On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    Connect To K8s Master Interactively  alias=${alias}

    ${container_abbr}   set variable   cprt
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}

    #f1cplane
#    ${tmp_file}   Begin Wireshark  interface=f1cplane  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${alias}  filter=${filter}
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=f1cplane   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}
    ...          index=0       alias=${alias}
    ${handle}   set variable   ${alias}_${tmp_file}

    [Return]   ${handle}


_Begin Wireshark Mplane On VDU For NCS
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark Mplane On VDU For NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle
    ...
    ...    Example
    ...
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    ${container_abbr}   set variable   oam
    ${network}    set variable   oam
    Connect to vDU Node   container_abbr=${container_abbr}    master_alias=${master_alias}    node_alias=${node_alias}
    ${oam_interface}   Get VDU Container Interface Name   container=${container_abbr}  network=${network}   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
#    ${tmp_file}   Begin Wireshark  interface=${oam_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${node_alias}  filter=${filter}
    ${tmp_file}   _Begin Tcpdump Wireshark VDUC For NCIR OR NCS
     ...   interface=${oam_interface}   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}   index=0  alias=${node_alias}

    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}


_Begin Wireshark Mplane On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark Mplane On VDU For OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
    ...
    ...    *RETURN VALUE*
    ...    handle

    ...
    ...    Example
    ...
    ${alias}  Get Unique ID
    Connect To K8s Master Interactively  alias=${alias}

    ${container_abbr}   set variable   oamagent
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}

#    ${tmp_file}   Begin Wireshark  interface=mcplane  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${alias}  filter=${filter}
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=mcplane   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}
    ...          index=0       alias=${alias}
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

#    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
#    ...   _Get Wireshark From VDUC For NCIR Or NCS   initial_log_path=${initial_log_path}   log_stored_path=${log_stored_path}  alias=${alias}
#    ...   ELSE  _Get Wireshark From VDUC For Ocp   initial_log_path=${initial_log_path}   log_stored_path=${log_stored_path}  alias=${alias}

    ${tmpfilenamefullpath}   runkeyword if   "${platform}"=="NCIR" or "${platform}"=="NCS"
    ...   Fail  NCS platform is not supported!
    ...   ELSE  _Get Wireshark From VDUC For Ocp   initial_log_path=${initial_log_path}   log_stored_path=${log_stored_path}  alias=${alias}

    [Return]    ${tmpfilenamefullpath}


_Get Wireshark From VDUC For NCIR Or NCS
    [Arguments]   ${initial_log_path}   ${log_stored_path}   ${alias}
    [Documentation]   _Get Wireshark From VDUC For NCIR Or NCS
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
    Send CTRL_C    alias=${alias}
    Sleep  1

    #parse vdu_index, pod_appr, docker_id
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container_id}   Set Variable  ${tmp[4]}

    Log To Console   ${container_id}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} sync    connection=${alias}
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} chmod 777 ${initial_log_path}    connection=${alias}
    ${out}    tafssh.Execute     command=mkdir -p /tmp/tmp_wireshark    connection=${alias}
    ${out}    tafssh.Execute     command=ls -l /tmp/tmp_wireshark   connection=${alias}
    ${docker_cp}   Set Variable   sudo docker cp ${container_id}:${initial_log_path} /tmp/tmp_wireshark
    ${out}    tafssh.Execute     command=${docker_cp}    connection=${alias}
    ${out}    tafssh.Execute     command=sync    connection=${alias}

    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${alias}
    _Delete Old Wireshark File In VDUC   initial_log_path=${initial_log_path}   container_id=${container_id}   alias=${alias}
    _Delete Old Wireshark File In VDU Master Node   initial_log_path=${initial_log_path}   alias=${alias}
    #${sudo}   Get Sudo   alias=${alias}
    #tafssh.Execute   command=${sudo} rm -f ${initial_log_path}     connection=${alias}


_Get Wireshark From VDUC For Ocp
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
    ${out}   Send CTRL_C Interactively    alias=${alias}
    sleep  2
    ${out}   issh.Execute  command=sync     alias=${alias}

    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    #${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${sudo_outer}   set variable  ${EMPTY}

    #parse vcu_index, pod_abbr, container_abbr
    ${path}  ${pcap_file}  OperatingSystem.Split Path   ${initial_log_path}
    ${tmp}   Split String  ${pcap_file}  _
    ${vdu_index}  Set Variable  ${tmp[2]}
    ${pod_abbr}  Set Variable  ${tmp[3]}
    ${container}   Set Variable  ${tmp[4]}

    ${ns}    Get vDU Namespace From TestLine    vdu_index=${vdu_index}
    ${pod_full_name}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   vdu_index=${vdu_index}  alias=${alias}
    ${container_full_name}   Get Full Container Name By Container Abbreviation  ctr_abbr=${container}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -l ${pcap_folder}
            ...  check_result=False   alias=${alias}

    Log To Console   ${container}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- sync
            ...  check_result=False   alias=${alias}

    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- ls -l ${pcap_folder}
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

    _Delete Old Wireshark File In VDUC Interactively   initial_log_path=${initial_log_path}
     ...   pod_full_name=${pod_full_name}  container_full_name=${container_full_name}  ns=${ns}   alias=${alias}

    #reuse KW '_Delete Old Wireshark File In VCUC Master Node' to delete all files in vDU master node
    _Delete Old Wireshark File In VCUC Master Node   initial_log_path=${initial_log_path}   alias=${alias}


######################wireshark releated sub kw################
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

_Get Wireshark From Server
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
    tafssh.Execute  command=sync   connection=${alias}
    tafssh.Download File   remote_path=${initial_log_path}    local_path=${log_stored_path}   connection=${alias}
    _Delete Old Wireshark File   initial_log_path=${initial_log_path}   alias=${alias}


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




_Delete Old Wireshark File In VDUC For OCP
    [Documentation]    Delete Old Wireshark File In VDUC For OPC
    ...    *AUTHOR* mengli.yang@nokia-sbell.com
    [Arguments]  ${initial_log_path}    ${pod_name}    ${container_name}
    ...          ${alias}    ${FolderName}=/tmp/tmp_wireshark
    ${ns}   Get VDU Namespace From TestLine
    ${out}    issh.Execute     command=kubectl exec -it ${pod_name} -c ${container_name} -n ${ns} -- rm -f ${initial_log_path}
    ...                          alias=${alias}

_Delete Old Wireshark File In VDU Master Node
    [Arguments]  ${initial_log_path}   ${alias}=default
    ${res}   tafssh.Execute   command=ls -l /tmp/tmp_wireshark   connection=${alias}
    Log   ${res}
    tafssh.Execute   command=sudo rm -f ${initial_log_path}     connection=${alias}
    _Remove All Temp File If Needed In VDU Master Node   FolderName=/tmp/tmp_wireshark   alias=${alias}

_Delete Old Wireshark File In VDUC
    [Arguments]  ${initial_log_path}   ${container_id}  ${alias}    ${FolderName}=/tmp/tmp_wireshark
    ${out}    tafssh.Execute     command=sudo docker exec -it ${container_id} rm -f ${initial_log_path}    connection=${alias}
    _Remove All Temp File If Needed From VDUC   FolderName=${FolderName}   container_id=${container_id}  alias=${alias}


_Delete Old Wireshark File In VDUC Interactively
    [Arguments]  ${initial_log_path}   ${pod_full_name}  ${container_full_name}  ${ns}   ${alias}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    #${sudo_outer}  Get Sudo For VCU K8s Admin Command
    ${sudo_outer}   set variable   ${EMPTY}
    ${out}  issh.Execute  command=${sudo_outer} kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${ns} -- rm -f ${initial_log_path}
            ...  check_result=${False}   alias=${alias}
    #${create_time}   _Get EPOCH Time From String   ${initial_log_path}
    _Remove All Temp File If Needed From VDUC Interactively   FolderName=${pcap_folder}
      ...   pod_full_name=${pod_full_name}   container_full_name=${container_full_name}   ns=${ns}  alias=${alias}


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

_Renew luashark
    log   ${LUA_SCRIPT_PATH}
    RUN   rm -rf ${LUA_SCRIPT_PATH}
    Run   mkdir ${LUA_SCRIPT_PATH}



_Begin Wireshark F1U On VDU For OCP
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark F1U On VDU For OCP
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    Connect To K8s Master Interactively  alias=${alias}

    ${container_abbr}   set variable   l1hi
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}

    #f1cplane
#    ${tmp_file}   Begin Wireshark  interface=f1uplane  host_type=VDUC  pod_abbr=${pod_abbr}  container=${container_abbr}
#       ...   alias=${alias}  filter=${filter}
    ${tmp_file}  _Begin Tcpdump Wireshark VDUC For OCP   interface=f1uplane   filter=${filter}   pod_abbr=${pod_abbr}  container=${container_abbr}
    ...          index=0       alias=${alias}

    ${handle}   set variable   ${alias}_${tmp_file}
    [Return]   ${handle}



_Begin Wireshark F1U On VDU For NCS
    [Arguments]     ${filter}=${EMPTY}
    [Documentation]    _Begin Wireshark F1U On VDU For NCS
    ...    *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | filter  |  No | filter of tcpdump, e.g, tcp, sctp, etc. default is empty |
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
    ${master_alias}  get unique id  prefix=master
    ${node_alias}    get unique id  prefix=node

    Connect to vDU Node   container_abbr=l1hi    master_alias=${master_alias}    node_alias=${node_alias}
    ${f1_c_interface}   Get VDU Container Interface Name   container=l1hi  network=f1   connection=${master_alias}

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=l1hi
    ${tmp_file}   Begin Wireshark  interface=${f1_c_interface}  host_type=VDUC  pod_abbr=${pod_abbr}  container=l1hi
       ...   alias=${node_alias}  filter=${filter}
    ${handle}   set variable   ${node_alias}_${tmp_file}
    [Return]   ${handle}



