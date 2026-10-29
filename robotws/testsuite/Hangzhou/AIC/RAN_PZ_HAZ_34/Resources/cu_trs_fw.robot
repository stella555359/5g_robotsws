*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_fw.robot



*** Variables ***



*** Keywords ***
Add Blackhole For Mplane In VCU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Add Blackhole For Mplane In VCU, it supports both ipv4 and ipv6
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32 |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VCU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VCU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VCU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VCU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Add Blackhole For Mplane In VCU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number},
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}
    Log To Console     ${msg}

    ${alias}  Connect To VCU Container With Tenant Interactively   pod_abbr=oamext  ctr_abbr=nwmgmt  gnb_index=${gnb_index}

    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ip -6 route add blackhole ${network_address}/${mask_len} table ${table_number}
    ...    ip route add blackhole ${network_address}/${mask_len} table ${table_number}

    issh.Execute  command=${cmd}  alias=${alias}


Delete Blackhole For Mplane In VCU
    [Arguments]    ${network_address}   ${mask_len}=32   ${table_number}=2   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Delete Blackhole For Mplane In VCU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | network_address | yes | network_address |
    ...	  | mask_len       | no | mask_len, default is 32C |
    ...	  | table_number | no | table_number, default is 2 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...   | ${nom_sftp_server} | Set Variable | 1.2.3.4 |
    ...   | Add Blackhole For Mplane In VCU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VCU | network_address=${nom_sftp_server} | mask_len=32 | table_number=2 |
    ...
    ...   | ${nom_sftp_server_ipv6} | Set Variable | 2a:1:: |
    ...   | Add Blackhole For Mplane In VCU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...   | Delete Blackhole For Mplane In VCU | network_address=${nom_sftp_server_ipv6} | mask_len=64 | table_number=2 |
    ...
    ${msg}   Set Variable  Delete Blackhole For Mplane In VCU,network_address:${network_address}, mask_len:${mask_len}, table_number:${table_number}
    ${msg}   Set Variable  ${msg}, gnb_index:${gnb_index}
    Log To Console    ${msg}

    ${alias}  Connect To VCU Container With Tenant Interactively   pod_abbr=oamext  ctr_abbr=nwmgmt  gnb_index=${gnb_index}

    ${is_ipv6}  Set Variable If   ":" in "${network_address}"  1   0

    ${cmd}   Set Variable If  "${is_ipv6}"=="1"   ip -6 route del blackhole ${network_address}/${mask_len} table ${table_number}
    ...      ip route del blackhole ${network_address}/${mask_len} table ${table_number}

    issh.Execute  command=${cmd}  alias=${alias}

