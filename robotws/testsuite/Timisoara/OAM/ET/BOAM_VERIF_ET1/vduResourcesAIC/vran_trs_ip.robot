*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_trs_ip.robot



*** Variables ***



*** Keywords ***
Parse Ipv4 Address
    [Arguments]  ${content}
    [Documentation]    get ipv4 address and mask length from linux command 'ip address show dev eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | tafssh.execute      | ip address show dev fp0 |
    ...    | ${ipv4_addr} | ${ipv4_mask_len} | Parse ipv4 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+)/([0-9]{1,3})\\s.*   1    2
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip_addr}     ${ip_mask_len}


Parse Ipv6 Address
    [Arguments]  ${content}
    [Documentation]    get ip6 address and mask length from linux command 'ip address show dev eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 28.7.2020,Hefeng-Cookie.qu@nokia-sbell.com,add support  container.
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | tafssh.execute      | ip address show dev fp0 |
    ...    | ${ip6_addr} | ${ip6_mask_len} | Parse ipv6 address |   ${out} |
    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)/([0-9]{1,3}).+scope global   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}

    Return From Keyword If    ${ip6_addr.__len__()}>0    ${ip6_addr}    ${ip6_mask_len}

    ${matches}    Get Regexp Matches    ${content}    inet6 ([23]\\S+)\\s+prefixlen\\s+(\\d+)\\s+scopeid\\s+   1    2
    ${ip6_addr}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${ip6_mask_len}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    [Return]    ${ip6_addr}     ${ip6_mask_len}


Parse Ipv4 Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Ipv4 Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv4 address, net mask and broadcast ip
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${ip} | ${mask} | ${broadcast} | Parse Ipv4 Address From Ifconfig |   ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}     .*inet\\s+(\\S+)\\s+netmask\\s+(\\S+)\\s+broadcast\\s+(\\S+).*   1  2  3
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    ${broadcast}    Set Variable If    ${matches}    ${matches[0][2]}    ${EMPTY}

    Return From Keyword If     ${matches}     ${ip}     ${mask}   ${broadcast}

    ${matches}  Get Regexp Matches     ${content}     .*inet\\s+addr:(\\S+)\\s+Bcast:\\s*(\\S+)\\s+Mask:\\s*(\\S+).*   1  2  3
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    ${broadcast}    Set Variable If    ${matches}    ${matches[0][2]}    ${EMPTY}

    [Return]    ${ip}     ${mask}   ${broadcast}


Parse Ipv6 Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Ipv6 Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv6 address, prefixlen
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${ip} | ${prefixlen} | Parse Ipv6 Address From Ifconfig |   ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}     .*inet6\\s+([0-9]\\S+)\\s+prefixlen\\s+(\\S+)\\s+scopeid\\s+\\S+.*   1  2
    ${ip}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${mask}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    Return From Keyword If     ${matches}     ${ip}     ${mask}
    [Return]    ${ip}     ${mask}


Parse Ipv4 Address Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Ipv4 Address Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    ip v4 address
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc10.108.227.133def |
    ...    | ${ip} | Parse Ipv4 Address Only From Content | abc 10.108.227.133 def |
    ...
    ...    keyword fails
    ...    | ${ip} | String Should Be An Ip Address | abc10.108.227.abc |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9]*(\\d+\\.\\d+\\.\\d+\\.\\d+).*   1
    Should Be True  ${matches}
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${ip_addr}


Parse Mac Address From Ifconfig
    [Arguments]  ${content}
    [Documentation]    Parse Mac Address from the output of linux command 'ifconfig eth0'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ifconfig eth0' |
    ...    *RETURN VALUE*
    ...    IPv4 address, net mask and broadcast ip
    ...
    ...    Example
    ...    | ${out}      | tafssh.execute      | ifconfig fp0 |
    ...    | ${mac} | Parse Mac Address From Ifconfig | ${out} |
    ...
    ${matches}  Get Regexp Matches     ${content}
      ...   ether\\s+([0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2})     1
    ${mac}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}

    Return From Keyword If     ${matches}    ${mac}

    ${matches}  Get Regexp Matches     ${content}
      ...   HWaddr\\s+([0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2}:[0-9a-zA-F]{2})     1
    ${mac}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}

    [Return]    ${mac}


Host Should Be Pingable
    [Arguments]  ${target_ip}
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Check whether Host is Pingable or not from current running UTE server. If it's pingable, do nothing.
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2
    ...   sudo ping ${target_ip} -c 2

    ${alias}  get unique id
    connect to ute locally    alias=${alias}
    ${out}   issh.Execute   command=${cmd}   alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}<100


Get VDU Container Ip Address
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${network}=${EMPTY}   ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up, default is ${EMPTY}, if is ${EMPTY}, will be fetched from container name |
    ...    | container    | no | container, e.g, oamfh, l2hi,default is ${EMPTY} |
    ...    | network      | no | network. e.g, internal, f1, oam, default is ${EMPTY} |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   ( ip address, mask, broadcast address), e.g, ("10.71.164.18", "255.255.255.0", "10.71.164.255")
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=cprt | network=f1 |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=fhm |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=internal |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=oamfh | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | container=aic-simu4trs | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=oam |
    ...   | ${ip} | ${mask} | ${broadcast} | Get VDU Container Ip Address | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...   | Disconnect From K8s Master |
    ...
    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ...     vdu_index=${vdu_index}    connection=${connection}
    ${out}   Kubectl Exec   pod_abbr=${pod_abbr}   container=${container}   command=ifconfig ${oam_ifname}
    ...     vdu_index=${vdu_index}    connection=${connection}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    [Return]  ${ip}  ${mask}   ${broadcast}


Get VDU Container Ipv6 Address
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}    ${network}=${EMPTY}   ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | yes | pod abbreviation, e.g, oamcp, up |
    ...    | container    | yes | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   ( ipv6 address, prefixlen), e.g, ("1:1:1:1:1:1:1:1", "125")
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=oam | container=oamfh | network=oam |
    ...   | ${ip} | ${prefixlen} | Get VDU Container Ip Address | pod_abbr=simu6trs | container=aic-simu6trs | network=oam |
    ...   | Disconnect From K8s Master |
    ...
    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ...     vdu_index=${vdu_index}    connection=${connection}
    ${out}   Kubectl Exec   pod_abbr=${pod_abbr}   container=${container}   command=ifconfig ${oam_ifname}
    ...     vdu_index=${vdu_index}    connection=${connection}

    ${ip}  ${prefixlen}   Parse Ipv6 Address From Ifconfig    content=${out}
    [Return]  ${ip}  ${prefixlen}


Get VDU Container Interface Name
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}    ${network}=${EMPTY}    ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Interface Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up. If ${EMPTY}, will be fetched according container abbreviation |
    ...    | container    | no | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   interface name, e.g, f16, oam3, etc.
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${interface} | Get VDU Container Interface Name | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | container=aic-simu4trs | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...
    ${ifname}     _Get VDU Container Interface Name Guest Vlan
     ...   pod_abbr=${pod_abbr}   container=${container}    network=${network}  vdu_index=${vdu_index}   connection=${connection}
    [Return]  ${ifname}


_Get VDU Container Interface Name Guest Vlan
    [Arguments]  ${pod_abbr}=${EMPTY}    ${container}=${EMPTY}    ${network}=${EMPTY}    ${vdu_index}=0  ${connection}=default
    [Documentation]    Get VDU Container Interface Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr     | no | pod abbreviation, e.g, oam, up. if ${EMPTY}, it will be fetched according to container abbreviation |
    ...    | container    | no | container, e.g, oamfh, l2hi |
    ...    | network      | yes | network. e.g, internal, f1, oam |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   interface name, e.g, mcplane, fcplane, f1uplane, fhmplane, internal1, etc.
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oam  | network=oam |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=fhm |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=oam | container=oamfh | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=f1 |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=up    | container=l2hi | network=internal |
    ...   | ${interface} | Get VDU Container Interface Name | pod_abbr=simu4trs | container=aic-simu4trs | network=oam |
    ...

    #run keyword if   "${pod_abbr}"=="${EMPTY}" and "${container}"=="nwmgmt"  Fail  Please give pod_abbr for nwmgmt container!

#    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"   get pod abbreviation by container abbreviation   container_abbr=${container}
#    ...   ELSE  set variable   ${pod_abbr}

#    ${network}  run keyword if   'f1' in '''${network}'''   _Get Network Name For F1   pod_abbr=${pod_abbr}
#    ...   ELSE IF   "${network}"=="fhm"   _Get Network Name For fhm   pod_abbr=${pod_abbr}
#    ...   ELSE IF   "${network}"=="oam"   set variable   mcplane
#    ...   ELSE IF   "${network}"=="tracing"   set variable   tcplane
#    ...   ELSE      Fail   Unknown network:${network} !

    ${network}  run keyword if   'f1c'=='${network}'   Set Variable   f1cplane
    ...   ELSE IF  'f1u'=='${network}'   Set Variable   f1uplane
    ...   ELSE IF  'f1' in '''${network}'''   _Get Network Name For F1   pod_abbr=${pod_abbr}    container=${container}
    ...   ELSE IF   "${network}"=="fhm"   set variable  fhmplane
    ...   ELSE IF   "${network}"=="oam"   set variable   mcplane
    ...   ELSE IF   "${network}"=="tracing"   set variable   tcplane
    ...   ELSE      Fail   Unknown network:${network} !

    [Return]  ${network}


_Get Network Name For F1
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}
    run keyword if   "${pod_abbr}"=="${EMPTY}" and "${container}"=="${EMPTY}"  Fail  Please give pod_abbr or pod_container!
    ${pod_abbr}   run keyword if   "${pod_abbr}"=="${EMPTY}"   get pod abbreviation by container abbreviation   container_abbr=${container}
    ...   ELSE  set variable   ${pod_abbr}

    ${F1_network_name}   run keyword if   "${pod_abbr}"=="up"    set variable  f1uplane
    ...   ELSE IF    "${pod_abbr}"=="cprt"   set variable   f1cplane
    ...   ELSE    Fail   unknown pod_abbr for F1 Network:${pod_abbr} !
    [Return]  ${F1_network_name}


Get OAM Default Gateway By Additional Routing Table
    [Arguments]  ${ipversion}=4   ${connection}=default
    [Documentation]    Get VOAM Default Gateway By Additional Routing Table
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   oam network default gateway
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${oamgw} | Get OAM Default Gateway By Additional Routing Table | ipversion=4 | connection=default |
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route show table 2   ip -6 route show table 2
    ${out}   Kubectl Exec   pod_abbr=oam   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     .*default\\s+via\\s+(\\S+)\\s+dev\\s+\\S+.*   1
    ${gateway}   set variable   ${matches[0]}
    [Return]  ${gateway}


Get Pod Static Route Info via CLI
    [Arguments]  ${ipversion}=4   ${pod}=oamcp   ${ifname}=f1cplane  ${connection}=default
    [Documentation]    Get Pod Static Route Info via CLI
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | pod    | no | pod name abbr, default value is oamcp |
    ...    | ifname   | no | interface to check route, default value is f1cplane |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   OAMCP/UP pod certain interface route info
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${routeinfo} | Get Pod Static Route Info via CLI |ipversion=4|pod=oamcp|ifname=f1cplane|connection=default|
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route   ip -6 route
    ${out}   Kubectl Exec   pod_abbr=${pod}   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     (\\S+)\\s+via\\s+([0-9]\\S+)\\s+dev\\s+${ifname}.*  1  2
    Return From Keyword If     ${matches}     ${matches}
    [Return]    ${matches}

Get Pod Direct Route Info via CLI
    [Arguments]  ${ipversion}=4   ${pod}=oamcp   ${ifname}=f1cplane  ${connection}=default
    [Documentation]    Get Pod Direct Route Info via CLI
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ipversion     | yes | oam ip version default is 4 |
    ...    | pod    | no | pod name abbr, default value is oamcp |
    ...    | ifname   | no | interface to check route, default value is f1cplane |
    ...    | connection   | no | connection to ssh instance via tafssh, default value is default |
    ...
    ...    *RETURN VALUE*
    ...   OAMCP/UP pod certain interface route info
    ...
    ...    Example
    ...   | Connect To K8s master |
    ...   | ${destip}   ${mask}   ${srcip} | Get Pod Direct Route Info via CLI |ipversion=4|pod=oamcp|ifname=f1cplane|connection=default|
    ...   | Disconnect From K8s Master |
    ...
    ${cmd}   set variable if   '${ipversion}'=='4'   ip route   ip -6 route
    ${filter}   set variable if    '${ipversion}'=='4'   (\\S+)\\s+dev\\s+${ifname}\\s+proto\\s+kernel\\s+scope\\s+link\\s+src\\s+(\\S+).*
    ...   (\\S+)\\s+dev\\s+${ifname}\\s+proto\\s+kernel\\s+metric\\s+(\\S+)\\s+pref.*
    ${out}   Kubectl Exec   pod_abbr=${pod}   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     ${filter}  1   2
    ${destnet}    Set Variable If    ${matches}    ${matches[0][0]}    ${EMPTY}
    ${destnetinfo}=   Split String   ${destnet}   /
    ${destip}   set variable  ${destnetinfo[0]}
    ${mask}    Set Variable   ${destnetinfo[1]}
    ${srcip_or_prefixlen}    Set Variable If    ${matches}    ${matches[0][1]}    ${EMPTY}
    Return From Keyword If     ${matches}     ${destip}   ${mask}   ${srcip_or_prefixlen}
    [Return]    ${destip}   ${mask}   ${srcip_or_prefixlen}


Get Local IPv6
    [Documentation]    get local eth0 interface of UTE server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    IP address of eth0
    ...
    ...    Example
    ...    | ${ipv6} | ${mask_len} | Get Local IPv6 |
    ...
    ${rtn}   ${ipv6}  ${mask_len}    _Get Local IPv6 By Interface    interface=eth0
    [Return]    ${ipv6}   ${mask_len}


_Get Local IPv6 By Interface
    [Arguments]    ${interface}=eth0
    [Documentation]    Get Local IPv6 By Interface
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | intf | optional | interface name of linux,default is eth0 |
    ...    *RETURN VALUE*
    ...    IP address of eth0
    ...
    ...    Example
    ...    | Get Local IPv6 by Interface |
    ...
    ${out}     OperatingSystem.Run    ip addr show ${interface}
    ${ipv6}  ${ipv6_mask_len}   Parse Ipv6 Address  ${out}
    ${rtn}    Set Variable If    ${ipv6.__len__()}>0   True   False
    [Return]   ${rtn}  ${ipv6}   ${ipv6_mask_len}


DSCP Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${dscp}=0   ${xml_file_name_prefix}=prefix  ${operator}=eq
    [Documentation]    DSCP Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.7.2020,chris.l.cao@nokia-sbell.com, add operator parameter
    ...    3.8.2020,hefeng-cookie.qu@nokia-sbell.com, update operator=eq
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | dscp            | yes | dscp |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | DSCP Number Should Be Right      | pcapfile=/tmp/a.pcap | filter=${filter} | dscp=46 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_dscp_num_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=ip.dsfield.dscp   attrib_name=show   attrib_value=${dscp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=ip.dsfield.dscp   attrib_name=showname

    ${length}  Get Length    ${showname}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


DSCP Number Should Be Right Ipv6
    [Arguments]  ${pcapfile}   ${filter}   ${expected_number}=0   ${dscp}=0   ${xml_file_name_prefix}=prefix    ${operator}=eq
    [Documentation]    DSCP Number Should Be Right Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    28.7.2020,chris.l.cao@nokia-sbell.com, add operator parameter
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | dscp            | yes | dscp |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmpv6 and ipv6.src==2a::2 and ipv6.dst==2a::1 |
    ...  | DSCP Number Should Be Right Ipv6 | pcapfile=/tmp/a.pcap | filter=${filter} | dscp=46 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_dscp_num_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}   filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=ipv6.tclass.dscp   attrib_name=show   attrib_value=${dscp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=ipv6.tclass.dscp   attrib_name=showname

    ${length}  Get Length    ${showname}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


VLAN PCP Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}    ${vlanpcp}=2  ${vlanid}=295  ${xml_file_name_prefix}=prefix
    [Documentation]    VLAN ID AND PCP Should Be Right
    ...    *AUTHOR* hefeng-cookie.qu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    17.9.2020,hefeng-cookie.qu@nokia-sbell.com, add
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | vlan            | yes | vlan |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | VLAN PCP Should Be Right     | pcapfile=/tmp/a.pcap | filter=${filter} | vlanid=295 | vlanpcp=7 |
    ...  | ...                               |  xml_file_name_prefix=Step5 |


    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_vlan_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}   max_count=50
    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=vlan.priority   attrib_name=show   attrib_value=${vlanpcp}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=vlan.priority   attrib_name=showname
    ${length}  Get Length    ${showname}
    Should Be True   ${length}>0

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=vlan.id   attrib_name=show   attrib_value=${vlanid}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=vlan.priority   attrib_name=showname
    ${length}  Get Length    ${showname}
    Should Be True   ${length}>0


Payload Size Number Should Be Right Ipv6
    [Arguments]  ${pcapfile}   ${filter}   ${expected_number}   ${size}   ${xml_file_name_prefix}=prefix
    [Documentation]    Payload Size Number Should Be Right Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | size            | yes | size |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | filter | set variable | icmpv6 and ipv6.src==2a::1 and ipv6.dst==2a::2 |
    ...  | Payload Size Number Should Be Right Ipv6 | pcapfile=/tmp/a.pcap | filter=${filter} | size=16 | expected_number=5 |
    ...  | ...                              |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_payload_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}   filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=data.len   attrib_name=show   attrib_value=${size}
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries       pdml_entries=${entries}   field_name=data.len   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


ICMP Request Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${xml_file_name_prefix}=prefix
    [Documentation]    ICMP Request Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | ICMP Request Number Should Be Right | pcapfile=/tmp/a.pcap | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...  | ICMP Request Number Should Be Right | pcapfile=/tmp/a.pcap | filter=${filter} | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_icmp_req_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=8
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


ICMP Reply Number Should Be Right
    [Arguments]  ${pcapfile}  ${filter}=${EMPTY}   ${expected_number}=0   ${xml_file_name_prefix}=prefix
    [Documentation]    ICMP Reply Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    4.8.2020,chris.l.cao@nokia-sbell.com, change timestamp to more precise timestamp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | filter          | yes | filter |
    ...    | expected_number | yes | expected_number |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | ICMP Reply Number Should Be Right | pcapfile=/tmp/a.pcap | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...  | ICMP Reply Number Should Be Right | pcapfile=/tmp/a.pcap | filter=${filter} | expected_number=5 |  xml_file_name_prefix=Step5 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_icmp_rep_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=0
    ${showname}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type   attrib_name=showname

    ${length}  Get Length    ${showname}
    Should Be True   ${length}==${expected_number}


Packets Number Should Be Right
    [Arguments]  ${pcapfile}  ${field_name}   ${attrib_name}   ${attrib_value}  ${filter}=${EMPTY}   ${expected_number}=0
      ...   ${xml_file_name_prefix}=prefix   ${operator}=eq
    [Documentation]    Packets Number Should Be Right
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pcapfile         | yes | pcap file name which will be checked |
    ...    | field_name       | yes | field_name, e.g, icmp.type, vlan.id, data.len, etc. |
    ...    | attrib_name      | yes | attrib_name, e.g show, value, showname, size, pos etc. |
    ...    | attrib_alue      | yes | attrib_alue, it's the value of attrib_name |
    ...    | filter          | no | filter, default is empty |
    ...    | expected_number | no | expected_number, default is 0 |
    ...    | xml_file_name_prefix | no | xml_file_name_prefix, default is prefix |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${actual_number}==${expected_number},gt:${actual_number}>${expected_number}, it's similar for ge/lt/le/ne |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  | ${filter} | set variable | icmp and ip.src==1.1.1.1 and ip.dst==2.2.2.2 |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
   ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=vlan.etype | attrib_name=value | attrib_value=88cc | expected_number=5 |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
    ...  | ... | operator=eq |
    ...  | Packets Number Should Be Right | pcapfile=/tmp/a.pcap | field_name=icmp.type | attrib_name=show | attrib_value=8 | expected_number=5 |
    ...  | ... | filter=${filter} | operator=gt | xml_file_name_prefix=step4 |
    ...
    #${timestamp}   Get Timestamp
    ${time_stamp}   Get Unique Id   precise=LOW
    ${xml_file}   Get A File   XML   ${xml_file_name_prefix}_${timestamp}.xml
    Analyze Pcap2xml   src=${pcapfile}    dest=${xml_file}  filter=${filter}

    ${entries}  cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=${field_name}   attrib_name=${attrib_name}   attrib_value=${attrib_value}
    ${attrib_name_list}   cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=${field_name}   attrib_name=${attrib_name}

    ${length}  Get Length    ${attrib_name_list}
    ${operator}  Set Variable  ${operator.lower()}
    Run Keyword If   "${operator}"=="eq"   Should Be True   ${length}==${expected_number}
    ...   ELSE IF    "${operator}"=="gt"   Should Be True   ${length}>${expected_number}
    ...   ELSE IF    "${operator}"=="ge"   Should Be True   ${length}>=${expected_number}
    ...   ELSE IF    "${operator}"=="lt"   Should Be True   ${length}<${expected_number}
    ...   ELSE IF    "${operator}"=="le"   Should Be True   ${length}<=${expected_number}
    ...   ELSE IF    "${operator}"=="ne"   Should Be True   ${length}!=${expected_number}
    ...   ELSE   Fail   Unknown operator:${operator}!


Get Mplane Ip Of RU Proxy
    [Arguments]  ${vdu_index}=0   ${ru_index}=1  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=ta_comm_Get_Mplane_Ip_Of_RU_Proxy
    [Documentation]   Get Mplane Ip Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | ru_index | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...     Mplane ip information of RU proxy inside ruproxy container.  Return type is list, content is [ip, mask, broadcast]
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${cellTechnology}   Get CellTechnology From VDU SCF   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${fhgw_major_version}   Get FHGW Major Version   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip}  ${mask}   ${broadcast}   Run Keyword If   "${fhgw_major_version}"=="FHGW21A" or "${fhgw_major_version}"=="FHGW21B"
                    ...   _Get Mplane Ip Of RU Proxy FDD   vdu_index=${vdu_index}   ru_index=${ru_index}
    ...    ELSE IF   "${fhgw_major_version}"=="FHGW22R1" and "${cellTechnology}"=="FDD"    _Get Mplane Ip Of RU Proxy FDD
                    ...     vdu_index=${vdu_index}   ru_index=${ru_index}
    ...    ELSE IF   "${fhgw_major_version}"=="FHGW22R1" and "${cellTechnology}"=="TDD"    _Get Mplane Ip Of RU Proxy TDD
                    ...     vdu_index=${vdu_index}    gnb_index=${gnb_index}

    [Return]  ${ip}  ${mask}   ${broadcast}


_Get Mplane Ip Of RU Proxy FDD
    [Arguments]  ${vdu_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=ta_comm_Get_Mplane_Ip_Of_RU_Proxy
    [Documentation]   Get Mplane Ip Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | ru_index | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...     Mplane ip information of RU proxy inside ruproxy container.  Return type is list, content is [ip, mask, broadcast]
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${alias}   Set Variable  ta_comm_Get_Mplane_Ip_Of_RU_Proxy
    Connect To FHGW    vdu_index=${vdu_index}   alias=${alias}
    ${out}     Ruproxy Kubectl Exec   command=ifconfig mPlaneVlan   alias=${alias}   vdu_index=${vdu_index}    ru_index=${ru_index}
    ${ip}   ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig   content=${out}
    String Should Be An Ip Address  ${ip}
    [Return]  ${ip}  ${mask}   ${broadcast}


_Get Mplane Ip Of RU Proxy TDD
    [Arguments]  ${vdu_index}=0   ${ru_index}=1    ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Mplane Ip Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...    | ru_index | No | ru_index, default value is 1  |
    ...
    ...    *RETURN VALUE*
    ...     Mplane ip information of RU proxy inside ruproxy container.  Return type is list, content is [ip, mask, broadcast]
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}

    ${cmd}   Set Variable   { echo \\"aasyscomgw -r\\";sleep 1;echo quit; } | telnet 0 15067;
    ${with_pipeline_command}   Set Variable   |grep 192.168.254|awk '{print $7}'

    ${out}   Kubectl Exec Interactively   container=oamfh   command=${cmd}    alias=${alias}   check_result=False
       ...   vdu_index=${vdu_index}  with_bash=True   with_pipeline_command=${with_pipeline_command}

    ${ip}   Get Lines Matching Regexp    ${out}  192\.168\.254\..*
    log to console   ${out}

    ${alias2}   Get Unique ID
    Connect To K8s Master   alias=${alias2}
    ${dummy}  ${mask}   ${broadcast}   Get VDU Container Ip Address    container=oamfh   network=fhm   connection=${alias2}

#
#
#
#    ${alias}   Set Variable  ta_comm_Get_Mplane_Ip_Of_RU_Proxy
#    Connect To FHGW    vdu_index=${vdu_index}   alias=${alias}
#    ${out}     Ruproxy Kubectl Exec   command=ifconfig mPlaneVlan   alias=${alias}   vdu_index=${vdu_index}    ru_index=${ru_index}
#    ${ip}   ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig   content=${out}
#    String Should Be An Ip Address  ${ip}
    [Return]  ${ip}  ${mask}   ${broadcast}


Get Mplane Mac Of RU Proxy
    [Arguments]  ${vdu_index}=0   ${ru_index}=1
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=ta_comm_Get_Mplane_Mac_Of_RU_Proxy
    [Documentation]   Get Mplane Mac Of RU Proxy
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...     Mplane Mac Of RU Proxy
    ...
    ...    Example
    ...   | ${ip} | ${mask} | ${broadcast} | Get Mplane Ip Of RU Proxy |
    ...
    ${alias}   Set Variable  ta_comm_Get_Mplane_Mac_Of_RU_Proxy
    Connect To FHGW    vdu_index=${vdu_index}   alias=${alias}
    ${out}     Ruproxy Kubectl Exec   command=ifconfig mPlaneVlan   alias=${alias}   vdu_index=${vdu_index}    ru_index=${ru_index}
    ${mac}    Parse Mac Address From Ifconfig   content=${out}
    Should Be True  ${mac.__len__()}==17

    [Return]  ${mac}


Get Radio Unit Ip Address
    [Arguments]   ${ru_index}=1
    [Documentation]    Connect to Radio Unit/connect to RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ru_index         | No | ru_index, default value is 1, it's value of 'x' of 'radio-x' returned from command 'nokiacli radio list' |
    ...
    ...    *RETURN VALUE*
    ...    RU ip address , e.g, 169.254.1.2
    ...
    ...    Example
    ...    | ${ru_ip} | Get Radio Unit Ip Address |
    ...
    ${ip}   set variable   169.254.${ru_index}.2
    [Return]  ${ip}


Get LTE Gateway Ipv6
    [Teardown]   run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Get LTE Gateway Ipv6
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    LTE ipv6 gateway ip
    ...
    ...    Example
    ...    | ${gw_ipv6} | Get LTE Gateway Ipv6 |
    ...
    ${alias}   get unique id
    connect to LTE   alias=${alias}
    ${out}   issh.Execute   command=route -n6|grep br1|grep "::/0"|awk '{print $2}'  alias=${alias}
    ${out}   strip prompt   ${out}
    should be true    ${out.__len__()>0}
    [Return]  ${out}


Get LTE Gateway
    [Teardown]   run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Get LTE Gateway of ipv4
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias     |  no | alias, default is default  |

    ...
    ...    *RETURN VALUE*
    ...    LTE ipv6 gateway ip
    ...
    ...    Example
    ...    | ${gw_ipv6} | Get LTE Gateway |
    ...
    ${alias}   get unique id
    connect to LTE   alias=${alias}
    ${out}   issh.Execute   command=route -n|grep 0.0.0.0|grep br1|grep UG|awk '{print $2}'   alias=${alias}
    ${out}   strip prompt   ${out}
    should be true    ${out.__len__()>0}
    [Return]  ${out}


Get Guest Vlan Tag
    [Arguments]  ${connection}
    [Documentation]   Get Guest Vlan Tag
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    This KW to check whether VDU is guest vlan or host vlan configuration.
    ...    When guest vlan there won't be vlan configuraiont on ClusterNetwork.
    ...    When host vlan there will be vlan configuraiton on ClusterNetwork, so we use this to check.
    ...    | Input Parameters | Man. | Description |
    ...    | connection  |  no | The K8s master connection session name, none is default |
    ...    *RETURN VALUE*
    ...    Guest vlan tag ${True} or ${False}.
    ...    | Connect To K8s master |
    ...    | ${guesvlan_tag} | Get Guest Vlan Tag |
    ...    | Disconnect From K8s Master |
    ${kubectl_cmd}   set variable
    ${out}   tafssh.Execute    command=kubectl describe cn f1   connection=${connection}
    ${guestvlantag}  Set Variable If  'Vlan' in '''${out}'''   ${False}   ${True}
    [Return]  ${guestvlantag}


Get Vcu Ip address
    [Arguments]    ${pod_abbr}    ${container}  ${interface}
    [Documentation]    Vcu get ip address for container
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Vcu get ip address for container
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr    | yes | pod_abbr for vcu |
    ...    | container   | yes | container name |
    ...    | interface  | yes | interface to check ip address |

    ...    *RETURN VALUE*
    ...   ip address
    ...
    ...    Example
    ...    | ${ip} | Get Vcu Ip address | cpif | cpif |  f1cvlan |

    Log To Console    LOOP_pod_abbr=${pod_abbr}
    Log To Console    LOOP_container=${container}
    ${alias_cu}=    Connect To CU K8S Master With Admin
    ${out}=    CU Kubectl Exec    pod_abbr=${pod_abbr}    container=${container}
    ...    command=ifconfig ${interface}
    ...    alias=${alias_cu}
    ...    check_result=${False}
    Disconnect Interactive Connection   ${alias_cu}
    Should Contain  ${out}   inet
    ${match_ip}   Get Regexp Matches    ${out}    inet\\s+(\\S+)   1
    [Return]    ${match_ip[0]}


Get Vcu Ipv6 address
    [Arguments]    ${pod_abbr}    ${container}  ${interface}
    [Documentation]    Vcu get ip address for container
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Vcu get ip address for container
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr    | yes | pod_abbr for vcu |
    ...    | container   | yes | container name |
    ...    | interface  | yes | interface to check ip address |

    ...    *RETURN VALUE*
    ...   ip address
    ...
    ...    Example
    ...    | ${ip} | Get Vcu Ipv6 address | cpif | cpif |  f1cvlan |

    Log To Console    LOOP_pod_abbr=${pod_abbr}
    Log To Console    LOOP_container=${container}
    ${alias_cu}=    Connect To CU K8S Master With Admin
    ${out}=    CU Kubectl Exec    pod_abbr=${pod_abbr}    container=${container}
    ...    command=ifconfig ${interface}
    ...    alias=${alias_cu}
    ...    check_result=${False}
    Disconnect Interactive Connection   ${alias_cu}
    Should Contain  ${out}   inet6
    ${match_ip}   Get Regexp Matches    ${out}    inet6\\s+(\\S+).*global   1
    [Return]    ${match_ip[0]}


Vcu Check Static Route Index
    [Arguments]   ${dist}  ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8  ${index}=0
    [Documentation]    Static Route with specific index should exist in dist mo
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given static route with specific index exist in forwarding entries under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | static route distname |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength  | yes | PrefixLength for static route |
    ...    | gateway  | yes | gateway for static route |
    ...    | preference   | yes | preference for static route |
    ...    | index   | No | index for policy, default is the first one 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Cu Login |
    ...    | ${scf_full_path}  Get A File   |  SCF  |   vcu_scf.xml |
    ...    | cu.Get Current Plan File  |  path=${scf_full_path} | timeout=60 |
    ...    | scf.Load_Scf  file_path=${scf_full_path} |
    ...    | ${routeexistflag} | Vcu Check Static Route Index | ${dist} |
    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
    ...    | Cu Logout |
    ...
    ${destip_par}   set variable if  ':' in '''${gateway}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${gateway}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${gateway}'''   gatewayIpv6Addr   gateway

    ${destIpAddr1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=forwardingEntries
    ...  p_name=${destip_par}  index=${index}
    ${destIpAddr1}   Replace String Using Regexp   ${destIpAddr1}   :0+  :
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Should Be True   '${destIpAddr1}'=='${destIpAddr}'
    ${PrefixLength1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=forwardingEntries
    ...  p_name=${prefix_par}  index=${index}
    Should Be True   '${PrefixLength1}'=='${PrefixLength}'
    ${gateway1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=forwardingEntries
    ...   p_name=${gw_par}  index=${index}
    ${gateway1}   Replace String Using Regexp   ${gateway1}   :0+  :
    ${gateway}   Replace String Using Regexp   ${gateway}   :0+  :
    Should Be True   '${gateway1}'=='${gateway}'
    ${preference1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=forwardingEntries
    ...  p_name=preference  index=${index}
    Should Be True   '${preference1}'=='${preference}'


Vcu Get OAM Tracing Network Gateway
    [Documentation]    Vcu Get OAM Tracing Network Gateway
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   oam tracing network default gateway
    ...
    ...    Example
    ...   | ${oamgw} | Vcu Get OAM Tracing Network Gateway |
    ...
    ${alias_id}    Connect To CU K8S Master With Admin
    ${ns}    Get CU Namespace From Testline   gnb_index=0
    ${cmd}  catenate  helm list -n ${ns} | grep cnf |awk '{print $1}'
    ${out}  issh.Execute  command=${cmd}  check_result=${False}  alias=${alias_id}
    ${cnf_name}  Strip Prompt  ${out}
    ${cmd}  catenate  kubectl -n ${ns} get cm ${cnf_name}-oamcm-routeinit-configmap -o yaml | grep gateway
    ${out}  issh.Execute  command=${cmd}  check_result=${False}  alias=${alias_id}
    issh.disconnect   alias=${alias_id}
    ${matches}  Get Regexp Matches  ${out}   .*?(\\d+\\.\\d+\\.\\d+\\.\\d+).*   1
    ${gateway}   Set Variable  ${matches[0]}
    [Return]  ${gateway}


Get Interface Information For FHMplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For FHMplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For FHMplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${pod_abbr}   Set Variable   oamfh
    ${ctr_abbr}   Set Variable   oamfh
    ${ifname}   Get VDU Container Interface Name      network=fhm
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}     container=${ctr_abbr}   command=ifconfig ${ifname}
    ...     vdu_index=${vdu_index}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}


Get Interface Information For Mplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For Mplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For Mplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${pod_abbr}   Set Variable   oamext
    ${ctr_abbr}   Set Variable   oamagent
    ${ifname}   Get VDU Container Interface Name      network=oam
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}     container=${ctr_abbr}   command=ifconfig ${ifname}
    ...     vdu_index=${vdu_index}   alias=${alias}

    ${r}   ${ip_info}  Run Keyword And Ignore Error   Parse Ipv4 Address From Ifconfig    content=${out}
    ${rtn}   Run Keyword If  "${r}"=="PASS"   Create Dictionary   ip=${ip_info[0]}    mask=${ip_info[1]}   broadcast=${ip_info[2]}
    Return From Keyword If   "${r}"=="PASS"   ${rtn}

    ${ip}  ${mask}        Parse Ipv6 Address From Ifconfig    content=${out}
    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}
    [Return]  ${rtn}


Get Interface Information For F1-Cplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For F1-Cplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For F1-Cplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${pod_abbr}   Set Variable   cprt
    ${ctr_abbr}   Set Variable   cprt
    ${ifname}   Get VDU Container Interface Name      network=f1c
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}     container=${ctr_abbr}   command=ifconfig ${ifname}
    ...     vdu_index=${vdu_index}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}


Get Interface Information For F1-Uplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For F1-Uplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For F1-Uplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${pod_abbr}   Set Variable   up
    ${ctr_abbr}   Set Variable   l2hi
    ${ifname}   Get VDU Container Interface Name      network=f1u
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}     container=${ctr_abbr}   command=ifconfig ${ifname}
    ...     vdu_index=${vdu_index}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}


Get Interface Information For Tcplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For Tcplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For Tcplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${pod_abbr}   Set Variable   oamext
    ${ctr_abbr}   Set Variable   oamagent
    ${ifname}   Get VDU Container Interface Name     network=tracing
    ${alias}   Get Unique ID
    Connect To K8s Master Interactively   gnb_index=${gnb_index}   vdu_index=${vdu_index}   alias=${alias}
    ${out}   Kubectl Exec Interactively   pod_abbr=${pod_abbr}     container=${ctr_abbr}   command=ifconfig ${ifname}
    ...     vdu_index=${vdu_index}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}
    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}

Vcu Get OAM Tracing V6 Network Gateway
    [Documentation]   Vdu Get OAM Tracing V6 Network Gateway
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   oam tracing network default gateway
    ...
    ...    Example
    ...   | ${oamgw} | Vcu Get OAM Tracing V6 Network Gateway |
    ...
    ${alias_id}   Connect To CU K8S Master With Admin
    ${ns}  Get CU Namespace From Testline   gnb_index=0
    ${cmd}  Catenate   helm list -n ${ns} | grep cnf |awk '{print $1}'
    ${out}  issh.Execute   command=${cmd}  check_result=${False}  alias=${alias_id}
    ${cnf_name}   Strip Prompt   ${out}
    ${cmd}   Catenate   kubectl -n ${ns} get cm ${cnf_name}-oamcm-routeinit-configmap -o yaml | grep gateway
    ${out}  issh.Execute  command=${cmd}  check_result=${False}  alias=${alias_id}
    issh.Disconnect   alias=${alias_id}
    ${matches}  Get Regexp Matches   ${out}  gateway.*?(([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}).*   1
    ${gateway}  Set Variable   ${matches[0]}
    [Return]  ${gateway}
