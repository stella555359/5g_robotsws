*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_log_wireshark.robot



*** Variables ***



*** Keywords ***
Begin Wireshark F1 Log On CU
    [Arguments]  ${filter}=sctp
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin to capture wireshark log on F1 interface
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filter | No | filter, filter=sctp, filter=sctp and src host 1.1.1.1, etc. default value is sctp |
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

#    ${vcu_nf_type}   Get VCU NF Type

#    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark F1 Log On CU CNF   filter=${filter}
#    ...   ELSE     _Begin Wireshark F1 Log On CU VNF   filter=${filter}
    ${handle}      _Begin Wireshark F1 Log On CU CNF   filter=${filter}
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


Begin Wireshark F1 Uplane Log On CU
    [Arguments]  ${filter}=udp
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Documentation]    Begin to capture wireshark log on F1 interface
    ...    the return value is a temporary file name which exists in target server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | filter | No | filter, filter=udp, filter=udp and src host 1.1.1.1, etc., default value is udp |
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...    | ${handle} | Begin Wireshark F1 Uplane Log On CU |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | End Wireshark F1 Uplane Log On CU | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
    ...
    Log To Console    Begin Wireshark F1 Uplane Log On CU

    ${vcu_nf_type}   Get VCU NF Type

    ${handle}  run keyword if   "${vcu_nf_type}"=="CNF"     _Begin Wireshark F1 Uplane Log On CU CNF   filter=${filter}
    ...   ELSE     Fail    Not support VNF!

    [Return]    ${handle}


End Wireshark F1 Uplane Log On CU
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
    ...    | ${handle} | Begin Wireshark F1 Uplane Log On CU  |
    ...    | sleep     |  30 |
    ...    | ${local_pcap_file} | Get A File | wireshark | mywireshark.pcap |
    ...    | End Wireshark F1 Uplane Log On CU  | handle=${handle} |  local_pcap_file_name=${local_pcap_file} |
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
    ${handle}   _Begin Wireshark Mplane Log On CU CNF   filter=${filter}
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
    ...    *Change History*
    ...    21.4.2022,chris.l.cao@nokia-sbell.com, support 2N and 1N deployment
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   Handle of wireshark instance
    ...
    ...    Example
    ...
    ${pod_abbr}   Set Variable    cpif
    ${container}  Set Variable    nwmgmt
    ${alias}   Connect To CU Node   pod_abbr=${pod_abbr}

    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=f1c  pod_abbr=${pod_abbr}   container=${container}  alias=${alias}
             ...   filter=${filter}

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


_Begin Wireshark F1 Uplane Log On CU CNF
    [Arguments]  ${filter}=udp
    [Documentation]    _Begin Wireshark F1 Uplane Log On CU CNF
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
#    ${alias}   Connect To CU K8S Master With Admin
    ${pod_abbr}   Set Variable   upue
    ${container}  Set Variable   nwmgmt
    ${alias}   Connect To CU Node   pod_abbr=${pod_abbr}

    ${f1u_interface_name}   Get VCU Container Interface Name   network=f1u
    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=${f1u_interface_name}   pod_abbr=${pod_abbr}   container=${container}
             ...   alias=${alias}
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
#    ${alias}   Connect To CU K8S Master With Admin
    ${pod_abbr}   Set Variable   oamext
    ${container}  Set Variable   nwmgmt
    ${alias}   Connect To CU Node   pod_abbr=${pod_abbr}

    ${tmpfile_pcap}   _Begin Wireshark VCUC  interface=oamvlan  pod_abbr=${pod_abbr}  container=${container}  alias=${alias}
             ...   filter=${filter}

    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


