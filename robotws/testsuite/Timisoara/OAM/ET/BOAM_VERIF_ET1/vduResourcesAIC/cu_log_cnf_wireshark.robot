*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_wireshark.robot



#*** Variables ***



*** Keywords ***
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
    ...    | ${handle} | End Wireshark F1 Log On CU | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
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
    ...    | ${handle} | End Wireshark F1 Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
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


Begin Wireshark X2 Uplane Log On CU
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]   Begin Wireshark X2 Uplane Log On CU
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
    ...    | ${handle} | Begin Wireshark X2 Uplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark X2 Uplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console   Begin Wireshark X2 Uplane Log On CU

    ${vcu_nf_type}   Get VCU NF Type

    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark X2 Uplane Log On CU CNF
    ...   ELSE     _Begin Wireshark X2 Uplane Log On CU VNF

    [Return]    ${handle}


End Wireshark X2 Uplane Log On CU
    [Arguments]    ${handle}    ${local_pcap_file_name}
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End Wireshark X2 Uplane Log On CU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | handle               | yes | a handler returned by '_Begin Wireshark X2 Uplane Log On CU CNF' |
    ...    | local_pcap_file_name | yes | locall pcap file where you want to save wireshark log  |
    ...
    ...    *RETURN VALUE*
    ...    the local captured pcap file name of X2 Uplane Wireshark Log On CU ,which is same as input parameter ${local_pcap_file_name}
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark X2 Uplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark X2 Uplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console   End Wireshark X2 Uplane Log On CU
    ${tmp}  Split String   ${handle}  _
    ${alias}   Set Variable   ${tmp[0]}
    ${tmpfile_pcap}   Set Variable   ${handle.replace("${alias}_","")}
#
#    End Wireshark     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}

    ${vcu_nf_type}   Get VCU NF Type
    run keyword if   "${vcu_nf_type}"=="CNF"
    ...           _End Wireshark VCUC     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ...   ELSE    _End Wireshark VCU VNF    log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}

    [Return]   ${local_pcap_file_name}



Begin Wireshark X2 Cplane Log On CU
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Arguments]  ${filter}=sctp
    [Documentation]   Begin Wireshark X2 Cplane Log On CU
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
    ...    | ${handle} | Begin Wireshark X2 Cplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark X2 Cplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    Begin Wireshark X2 Cplane Log On CU
    ${vcu_nf_type}   Get VCU NF Type

    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark X2 Cplane Log On CU CNF   filter=${filter}
    ...   ELSE    _Begin Wireshark X2 Cplane Log On CU VNF   filter=${filter}

    [Return]    ${handle}


End Wireshark X2 Cplane Log On CU
    [Arguments]    ${handle}    ${local_pcap_file_name}
    [Documentation]    End Wireshark X2 Cplane Log On CU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | handle               | yes | a handler returned by 'Begin Wireshark X2 Cplane Log On CU ' |
    ...    | local_pcap_file_name | yes | locall pcap file where you want to save wireshark log  |
    ...
    ...    *RETURN VALUE*
    ...    the local captured pcap file name of X2 Cplane Wireshark Log On CU CNF, which is same as input parameter ${local_pcap_file_name}
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark X2 Cplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark X2 Cplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    End Wireshark X2 Cplane Log On CU
    ${tmp}  Split String   ${handle}  _
    ${alias}   Set Variable   ${tmp[0]}
    ${tmpfile_pcap}   Set Variable   ${handle.replace("${alias}_","")}

#    End Wireshark     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ${vcu_nf_type}   Get VCU NF Type
    run keyword if   "${vcu_nf_type}"=="CNF"
    ...           _End Wireshark VCUC     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ...   ELSE    _End Wireshark VCU VNF    log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}

    [Return]   ${local_pcap_file_name}


Begin Wireshark Mplane Log On CU
    [Arguments]  ${filter}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin to capture wireshark log on Mplane interface, it supports VNF/CNF, NCS/OCP
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  filter  | no |  filter, e.g, tcp, filter=icmp and src host 1.1.1.1, etc. default is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  |
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  | tcp              |
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  | icmp and src host 1.1.1.1 |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark Mplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console   Begin Wireshark Mplane Log On CU

    ${vcu_nf_type}   Get VCU NF Type

    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark Mplane Log On CU CNF   filter=${filter}
    ...   ELSE     _Begin Wireshark Mplane Log On CU VNF    filter=${filter}

    [Return]    ${handle}


End Wireshark Mplane Log On CU
    [Arguments]    ${handle}    ${local_pcap_file_name}
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    End Wireshark Mplane Log On CU, it supports VNF/CNF, NCS/OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | handle               | yes | a handler returned by '_Begin Wireshark Mplane Log On CU CNF' |
    ...    | local_pcap_file_name | yes | locall pcap file where you want to save wireshark log  |
    ...
    ...    *RETURN VALUE*
    ...    the local captured pcap file name of Mplane Wireshark Log On CU CNF, which is same as input parameter ${local_pcap_file_name}
    ...
    ...    Example
    ...    | ${handle} | _Begin Wireshark Mplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark Mplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    End Wireshark Mplane Log On CU
    ${tmp}  Split String   ${handle}  _
    ${alias}   Set Variable   ${tmp[0]}
    ${tmpfile_pcap}   Set Variable   ${handle.replace("${alias}_","")}

#    End Wireshark     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ${vcu_nf_type}   Get VCU NF Type

    run keyword if   "${vcu_nf_type}"=="CNF"
    ...           _End Wireshark VCUC     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ...   ELSE    _End Wireshark VCU VNF    log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}

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
    ${alias}   Connect To CU K8S Master With Admin
#    ${tmpfile_pcap}   Begin Wireshark VCUC  interface=f1c   host_type=VCUC   pod_abbr=cpif   container=cpif  alias=${alias}
#             ...   filter=${filter}
    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=f1c  pod_abbr=cpif   container=cpif  alias=${alias}
             ...   filter=${filter}

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


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


_Begin Wireshark X2 Uplane Log On CU CNF
    [Documentation]   _Begin Wireshark X2 Uplane Log On CU CNF
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
    ...    | ${handle} | _Begin Wireshark X2 Uplane Log On CU CNF |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | _End Wireshark X2 Uplane Log On CU CNF | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    ${alias}   Connect To CU K8S Master With Admin
    ${tmpfile_pcap}   _Begin Wireshark VCUC   interface=x2cvlan    pod_abbr=cpif   container=cpif  alias=${alias}
             ...   filter=udp

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark X2 Uplane Log On CU VNF
    [Documentation]   _Begin Wireshark X2 Uplane Log On CU VNF
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
    ...    | ${handle} | _Begin Wireshark X2 Uplane Log On CU VNF |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | _End Wireshark X2 Uplane Log On CU CNF | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    ${alias}   Get Unique Id
    CU SSH To CPIF   alias=${alias}
#    ${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU     alias=${alias}
#       ...   filter=udp
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=x2     alias=${alias}
        ...   filter=udp
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark X2 Cplane Log On CU CNF
    [Arguments]  ${filter}=sctp
    [Documentation]   _Begin Wireshark X2 Cplane Log On CU CNF
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
    ...    | ${handle} | _Begin Wireshark X2 Cplane Log On CU CNF |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | _End Wireshark X2 Cplane Log On CU CNF | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    ${alias}   Connect To CU K8S Master With Admin
#    ${tmpfile_pcap}   Begin Wireshark   interface=x2cvlan   host_type=VCUC   pod_abbr=cpif   container=cpif  alias=${alias}
#              ...   filter=${filter}
    ${tmpfile_pcap}   _Begin Wireshark VCUC   interface=x2cvlan    pod_abbr=cpif   container=cpif  alias=${alias}
             ...   filter=${filter}

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark X2 Cplane Log On CU VNF
    [Arguments]  ${filter}=sctp
    [Documentation]   _Begin Wireshark X2 Cplane Log On CU VNF
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
    ...    | ${handle} | _Begin Wireshark X2 Cplane Log On CU VNF |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | _End Wireshark X2 Cplane Log On CU VNF | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    ${alias}   Get Unique Id
    CU SSH To CPIF   alias=${alias}

    ${tmpfile_pcap}    Begin Wireshark   interface=x2   host_type=VCU     alias=${alias}
      ...   filter=${filter}
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark Mplane Log On CU CNF
    [Arguments]  ${filter}=${EMPTY}
    [Documentation]    Begin to capture wireshark log on Mplane interface
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  filter  | no |  filter, e.g, tcp, filter=icmp and src host 1.1.1.1, etc. default is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  |
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  | tcp              |
    ...    | ${handle} | Begin Wireshark Mplane Log On CU  | icmp and src host 1.1.1.1 |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | ${handle} | End Wireshark Mplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    ${alias}   Connect To CU K8S Master With Admin
    ${container}  Set Variable  oamagent
   # ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation    container_abbr=${container}
#    ${tmpfile_pcap}   Begin Wireshark   interface=oamvlan   host_type=VCUC   pod_abbr=oamext   container=oamagent  alias=${alias}
#              ...   filter=${filter}
    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=oamvlan  pod_abbr=oamext  container=${container}  alias=${alias}
             ...   filter=${filter}

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark Mplane Log On CU VNF
    [Arguments]  ${filter}=${EMPTY}
    [Documentation]    Begin to capture wireshark log on Mplane interface
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  filter  | no |  filter, e.g, tcp, filter=icmp and src host 1.1.1.1, etc. default is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ${alias}   Get Unique ID
    CU SSH To OAM    alias=${alias}
#    ${tmpfile_pcap}    Begin Wireshark   interface=oam   host_type=VCU    filter=${filter}    alias=${alias}
    ${tmpfile_pcap}    _Begin Wireshark VNF  interface=oam    filter=${filter}     alias=${alias}
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


CU Get All VMs Hostame
    [Arguments]    ${gnb_index}=${0}
    [Documentation]  get all cu VMs hostname
    ...  return a list of cu VMs hostnames
    ...  author: rainie.wu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...       | gnb_index | No. | the gnb index config on TL |
    ...    *RETURN VALUE*
    ...    vm_hostname_list
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ${username}=  set variable if  '${username}'=='serviceuser'  root
    ${alias}=  get unique id
    CU SSH To OAM  gnb_index=${gnb_index}  alias=${alias}
    ${result}=  issh.Execute  command=sudo dvmcli -n  check_result=${False}  alias=${alias}
    issh.disconnect  alias=${alias}
    ${vm_hostname_list}=  create list
    ${vm_hostnames}=   Split String  ${result}   \r\n
    FOR    ${vm_hostname}    IN    @{vm_hostnames}
      ${num}=   get count    ${vm_hostname}   [
      run keyword if  ${num}==0  append to list  ${vm_hostname_list}  ${vm_hostname.strip()}
    END
    log to console  ${vm_hostname_list}
    [Return]   ${vm_hostname_list}