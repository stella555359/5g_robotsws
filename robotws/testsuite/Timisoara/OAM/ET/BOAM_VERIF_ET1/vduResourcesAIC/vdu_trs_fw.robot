*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_fw.robot



*** Variables ***



*** Keywords ***
Disconnect vCU and vDU SCTP Link
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   VDU Get F1 Cplane Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...  CU F1 Cplane Ip Address
    ...    Example
    ...    | Disconnect vCU and vDU SCTP Link |
    ...
    ${cu_f1_cplane_ip}  CU Get F1 Cplane Ip Address   gnb_index=${gnb_index}
    ${vdu_f1_cplane_ip}   VDU Get F1 Cplane Ip Address   gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${cmd}   set variable
     ...   iptables -t mangle -I INPUT 1 -s ${vdu_f1_cplane_ip}/32 -d ${cu_f1_cplane_ip}/32 -p sctp --dport 38472 --sport 38472 -j DROP

    ${alias}   get unique id
    CU SSH To CPIF   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=${cmd}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle    alias=${alias}
    log to console  ${out}


Reconnect vCU and vDU SCTP Link
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Reconnect vCU and vDU SCTP Link
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Reconnect vCU and vDU SCTP Link |
    ...


    ${cmd}   set variable   iptables -t mangle -D INPUT 1

    ${alias}   get unique id
    CU SSH To CPIF   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle|head -n 5|grep DROP|tail -n 1|wc -l   alias=${alias}
    ${out}   strip prompt  ${out}

    run keyword if  ${out}==0   log to console   Need not reconnect vCU and vDU SCTP Link, becauses its previous SCTP link is OK.
    return from keyword if  ${out}==0

     log to console   Need reconnect vCU and vDU SCTP Link, becauses its previous SCTP link is NOT OK.
    ${out}   issh.Execute   command=${cmd}    alias=${alias}
    ${out}   issh.Execute   command=iptables -nvL INPUT -t mangle    alias=${alias}
    log to console  ${out}


Add Blackhole For Mplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Add Blackhole For Mplane In VDU, it supports both ipv4 and ipv6
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Add Blackhole For Mplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number},
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console     ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To K8s Master Interactively    alias=${alias}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${pod}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=oamext  alias=${alias}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=nwmgmt

    ${cmd}   Set Variable  kubectl exec -it ${pod} -c ${container} -n ${ns} --

    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ${cmd} ip -6 route add blackhole ${network_address}/${mask_len} table ${table_number}
    ...    ${cmd} ip route add blackhole ${network_address}/${mask_len} table ${table_number}

    issh.Execute  command=${cmd}  alias=${alias}


Delete Blackhole For Mplane In VDU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Delete Blackhole For Mplane In VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VDU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Delete Blackhole For Mplane In VDU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number}
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}, vdu_index:${vdu_index}
    Log To Console    ${msg}

    ${ns}  Get VDU Namespace From TestLine

    ${alias}  get unique id
    Connect To K8s Master Interactively    alias=${alias}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${pod}   Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=oamext  alias=${alias}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=nwmgmt

    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable  kubectl exec -it ${pod} -c ${container} -n ${ns} --
    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ${cmd} ip -6 route del blackhole ${network_address}/${mask_len} table ${table_number}
    ...      ${cmd} ip route del blackhole ${network_address}/${mask_len} table ${table_number}

    issh.Execute  command=${cmd}  alias=${alias}
