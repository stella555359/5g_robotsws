*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   5gc001997.robot



*** Variables ***



*** Keywords ***
Begin DPDK pdump fhuc With VLAN On VDU
    [Documentation]    Begin DPDK pdump fhuc With VLAN On VDU
    ...  *AUTHOR*      chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   21.6.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...   14.10.2022,chris.l.cao@nokia-sbell.com, change .pcap file location fro /tmp/ to /tmp/dpdkdump/, because the latter has bigger disk size
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    handle

    ...    Example
    ...    | ${handle} | Begin DPDK pdump fhuc With VLAN On VDU |
    ...    | sleep  | 5 |
    ...    | ${local_pcap} | Get A File | Wireshark |   my.pcap  |
    ...   |  End DPDK pdump fhuc With VLAN On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${container}  Set Variable   l1hi
    ${port_name}  Set Variable   fhuc
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}

    ${alias}  Get Unique Id
    Connect To VDU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=${container}  alias=${alias}

    ${out}   issh.Execute  command=rm -f /tmp/dpdkdump/*.pcap   check_result=${False}  alias=${alias}
    ${out}   issh.Execute  command=dpdk-cli show port table|grep -E "[0-9]+\\s+${port_name}"|awk '{print $1}'
        ...   check_result=${False}  alias=${alias}
    ${port_id}   Strip Prompt   ${out}

    ${tmpfilenamefullpath}    Set Variable    /tmp/dpdkdump
    ${tmpfilenamefullpathname}    Set Variable    ${tmpfilenamefullpath}/${port_name}.pcap

    issh.Execute_bare   command=cd /tmp/dpdkdump; dpdk-cli pdump port ${port_id} path ${tmpfilenamefullpath}   alias=${alias}
    Send ENTER Interactively   alias=${alias}
    [Return]    ${alias}_${tmpfilenamefullpathname}


End DPDK pdump fhuc With VLAN On VDU
    [Arguments]  ${log_dst_path}  ${handle}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
     ...   AND    Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias_cp}
    [Documentation]   End DPDK pdump fhuc With VLAN On VDU
    ...  *AUTHOR*       chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   21.6.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...   14.10.2022,chris.l.cao@nokia-sbell.com, change .pcap file location fro /tmp/ to /tmp/dpdkdump/, because the latter has bigger disk size
    ...    |  Input Parameters | Man. | Description |
    ...    | local_pcap  |  Yes | local_pcap file name|
    ...    | handle  |  Yes | handle return from 'Begin DPDK pdump fhuc On VDU' |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${handle} | Begin DPDK pdump fhuc With VLAN On VDU |
    ...    | sleep  | 5 |
    ...    | ${local_pcap} | Get A File | Wireshark |   my.pcap  |
    ...   |  End DPDK pdump fhuc With VLAN On VDU | log_dst_path=${local_pcap}  |  handle=${handle} |
    ...
    ${alias}   set variable    ${handle.split('_')[0]}
    ${log_src_path}   set variable    ${handle.replace("${alias}_","")}

    ${container}  Set Variable   l1hi
    ${gnb_index}  Set Variable   0
    ${vdu_index}  Set Variable   0
    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container}   gnb_index=${gnb_index}
    ...   vdu_index=${vdu_index}
    Send CTRL_C Interactively    alias=${alias}
    Sleep  1

    ${alias_cp}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  alias=${alias_cp}

    ${ns}    Get vDU Namespace From TestLine   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${pod_name}    Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}    alias=${alias_cp}
    ${container_name}    Get Full Container Name By Container Abbreviation   ctr_abbr=${container}

    ${out}    issh.Execute     command=sync   check_result=${False}    alias=${alias}

    ${out}    issh.Execute     command=ls -l /tmp/dpdkdump/*.pcap    check_result=${False}  alias=${alias}

    ${remote_file_name}   Get A Remote File   DPDK_wireshark   ${container}_fhuc.pcap   alias=${alias_cp}

    ${kubectl_cp}   Set Variable   kubectl cp ${pod_name}:${log_src_path} ${remote_file_name} -c ${container_name}
    ${out}    issh.Execute     command=${kubectl_cp}  check_result=${False}     alias=${alias_cp}
    ${out}    issh.Execute     command=rm -f /tmp/dpdkdump/*.pcap    check_result=${False}  alias=${alias}
    ${out}    issh.Execute     command=sync   check_result=${False}   alias=${alias_cp}

    issh.Download File   remote_path=${remote_file_name}    local_path=${log_dst_path}   alias=${alias_cp}


