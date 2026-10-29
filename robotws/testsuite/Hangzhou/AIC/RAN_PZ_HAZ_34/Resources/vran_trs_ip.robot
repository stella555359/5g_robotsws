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
    [Documentation]    get ip6 address and mask length from linux command 'ip address show dev mcplane'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: 28.7.2020,Hefeng-Cookie.qu@nokia-sbell.com,add support  container.
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | content of output by executing 'ip address show dev eth0' |
    ...
    ...    *RETURN VALUE*
    ...    IPv6 address and net mask length
    ...
    ...    Example
    ...    | ${out}         | issh.execute      | command=ip address show dev mcplane |
    ...    | ${ip6_addr} | ${ip6_mask_len} | Parse ipv6 address |   ${out} |
    ...
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
    ...    | ${out}      | issh.execute      | ifconfig fp0 |
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
    ${msg}  Catenate   SEPARATOR=${SPACE}   `Get VDU Container Ip Address` is deprecated! Please use `Get Interface Information For F1-Uplane`,
    ...    `Get Interface Information For F1-Cplane`, `Get Interface Information For Mplane`, `Get Interface Information For Tcplane`
    ...    `Get Interface Information For FHMplane`
    Log To Console   ${msg}
    ${oam_ifname}   Get VDU Container Interface Name   pod_abbr=${pod_abbr}   container=${container}    network=${network}
    ...     vdu_index=${vdu_index}    connection=${connection}
#    Connect To K8s master
    ${out}   Kubectl Exec   pod_abbr=${pod_abbr}   container=${container}   command=ifconfig ${oam_ifname}
    ...     vdu_index=${vdu_index}    connection=${connection}
#    Disconnect From K8s Master
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
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=f1c |
    ...   | ${interface} | Get VDU Container Interface Name | container=oamfh | network=f1u |
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


Get VCU Container Interface Name
    [Arguments]    ${network}
    [Documentation]    Get VCU Container Interface Name
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
    ...   | ${interface} | Get VCU Container Interface Name| network=f1c |
    ...   | ${interface} | Get VCU Container Interface Name| network=f1u |
    ...
    ${network}  run keyword if   '${network}'=='f1c'   Set Variable   f1cplane
    ...   ELSE IF  '${network}'=='x2c'   Set Variable   x2c
    ...   ELSE IF  '${network}'=='f1u'   Set Variable   f1u
    ...   ELSE IF   "${network}"=="x2u"   set variable  x2u
    ...   ELSE IF   "${network}"=="s1u"   set variable   s1u
    ...   ELSE IF   "${network}"=="tracing"   set variable   tracing
    ...   ELSE IF   "${network}"=="oam"   set variable   oamvlan
    ...   ELSE      Fail   Unknown network:${network} !

    [Return]  ${network}


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
    ${out}   Kubectl Exec   pod_abbr=oamext   container=nwmgmt   command=${cmd}   connection=${connection}
    ${matches}  Get Regexp Matches     ${out}     .*default\\s+via\\s+(\\S+)\\s+dev\\s+\\S+.*   1
    ${gateway}   set variable   ${matches[0]}
    [Return]  ${gateway}


Get Pod Static Route Info via CLI
    [Arguments]  ${ipversion}=4   ${pod}=oamcp   ${ifname}=f1cplane  ${connection}=default
    [Documentation]    Get Pod Static Route Info via CLI
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    *MODIFY* zhong.1.chen@nokia-sbell.com
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
    #${out}   Kubectl Exec   pod_abbr=${pod}   container=nwmgmt   command=${cmd}   connection=${connection}
    ${alias}  Get Unique ID
    Connect To VDU Container With Tenant Interactively    pod_abbr=${pod}   ctr_abbr=nwmgmt   alias=${alias}
    ${out}    issh.Execute    command=${cmd}   alias=${alias}
    ${matches}  Get Regexp Matches     ${out}     (\\S+)\\s+via\\s+([0-9]\\S+)\\s+dev\\s+${ifname}.*  1  2
    Return From Keyword If     ${matches}     ${matches}
    [Return]    ${matches}
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}

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
    [Arguments]    ${pod_abbr}    ${container}  ${interface}   ${gnb_index}=0
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
    ${alias_cu}=    Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}
    ${out}=    CU Kubectl Exec    pod_abbr=${pod_abbr}    container=${container}
    ...    command=ifconfig ${interface}
    ...    alias=${alias_cu}
    ...    check_result=${False}
    Disconnect Interactive Connection   ${alias_cu}
    Should Contain  ${out}   inet
    ${match_ip}   Get Regexp Matches    ${out}    inet\\s+(\\S+)   1
    [Return]    ${match_ip[0]}


Get Interface Information For F1-Cplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For F1-Cplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    29.6.2023,chris.l.cao@nokia-sbell.com, get f1c vlan id from 'helm get values'
    ...
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
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine
#    ${f1_vlan}   set variable   ${conf_dict["vlan"]["f1"]}
    ${r}  ${f1c_vlan}  Run Keyword And Ignore Error   _VDU Get Vlan Id For F1-C From Runing Helm
#    ${f1subnet}   set variable    ${conf_dict["network"]["f1subnet"]}
    ${f1subnet}   set variable    ${conf_dict["network"]["f1csubnet"]}
    ${subnet_list}   Split String  ${f1subnet}  /
    ${f1net_addr}   Set Variable  ${subnet_list[0]}
    ${f1netmask}   Set Variable  ${subnet_list[1]}
    ${broadcast}   Evaluate    str(IPy.IP('${f1subnet}').broadcast())   modules=IPy

    vDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_state_data}=   vdu.get_vdu_state_data
    ${f1c_ip_info}   set variable  ${vdu_state_data['ip_addresses']['f1_c_ip_address']}
    ${ip}   Set Variable If    "${f1c_ip_info['ipv4']}"!="None"   ${f1c_ip_info['ipv4']}  ${f1c_ip_info['ipv6']}

    ${rtn}   Create Dictionary   ip=${ip}  vlan_id=${f1c_vlan}   subnet=${f1subnet}  subnet_addr=${f1net_addr}
      ...      mask=${f1netmask}   broadcast=${broadcast}

    [Return]  ${rtn}


_VDU Get Vlan Id For F1-C From Runing Helm
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    ${release_name}   Get VDU Release Name   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    ${tmp_yaml_file}   Get A Remote File   yaml   helm_get_values.yaml   alias=${alias}
    ${out}   issh.Execute   command=helm get values ${release_name} -o yaml >${tmp_yaml_file}   check_result=${False}   alias=${alias}

    ${temp_id}   Get Unique Id   prefix=yaml_   precise=FORMAT_DATETIME  suffix=.yaml
    ${local_yaml_file}   Get A File   ${temp_id}
    issh.download_file  remote_path=${tmp_yaml_file}  local_path=${local_yaml_file}   alias=${alias}
    ${dictionary_content}   yaml_file_to_dictionary   ${local_yaml_file}
    ${vlan_id}   Set Variable   ${dictionary_content["global"]["externalNetwork"]["f1c"]["vlanInfo"]["vid"]}
    [Return]  ${vlan_id}


Get Interface Information For F1-Uplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get Interface Information For F1-Uplane, support ipv4 and ipv6
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    7.3.2023,chris.l.cao@nokia-sbell.com, adapt to "UP pod split into l2rt and l2nrt"
    ...
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...	  | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast, vlan, etc. it support both ipv4 and ipv6
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For F1-Uplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...   | ${vlan_id} | Set Variable | ${interface_information["vlan_id"]} |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine
    ${f1_vlan}   set variable   ${conf_dict["vlan"]["f1"]}
    ${f1subnet}   set variable    ${conf_dict["network"]["f1subnet"]}
    ${subnet_list}   Split String  ${f1subnet}  /
    ${f1net_addr}   Set Variable  ${subnet_list[0]}
    ${f1netmask}   Set Variable  ${subnet_list[1]}

    ${broadcast}   Evaluate    str(IPy.IP('${f1subnet}').broadcast())   modules=IPy

    vDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_state_data}=   vdu.get_vdu_state_data
    ${uplane_index}   Set Variable   0
    ${f1u_ip_info}   set variable  ${vdu_state_data['ip_addresses']['f1_u_ip_address'][${uplane_index}]}
    ${ip}   Set Variable If    "${f1u_ip_info['ipv4']}"!="None"   ${f1u_ip_info['ipv4']}  ${f1u_ip_info['ipv6']}

    ${rtn}   Create Dictionary   ip=${ip}  vlan_id=${f1_vlan}   subnet=${f1subnet}  subnet_addr=${f1net_addr}
      ...      mask=${f1netmask}   broadcast=${broadcast}

    [Return]  ${rtn}


Get Interface Information For Mplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get Interface Information For Mplane, support ipv4 and ipv6
    ...   *AUTHOR* winnie.su@nokia-sbell.com
    ...    4.20.2023,winnie.su@nokia-sbell.com,
    ...    add new keyword according to Get Interface Information For F1-Uplane keyword to get Mplane interface info
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | gnb_index | no | gnb_index, default is 0 |
    ...   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast, vlan, etc. it support both ipv4 and ipv6
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For Mplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...   | ${vlan_id} | Set Variable | ${interface_information["vlan_id"]} |
    ...
    ${conf_dict}      Get vDU One Click Config Dictionary From TestLine
    ${oam_vlan}   set variable   ${conf_dict["vlan"]["oam"]}
    ${oamsubnet}   set variable    ${conf_dict["network"]["oamsubnet"]}
    ${subnet_list}   Split String  ${oamsubnet}  /
    ${oamnet_addr}   Set Variable  ${subnet_list[0]}
    ${oamnetmask}   Set Variable  ${subnet_list[1]}

    ${broadcast}   Evaluate    str(IPy.IP('${oamsubnet}').broadcast())   modules=IPy

    vDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_state_data}=   vdu.get_vdu_state_data
    ${mplane_index}   Set Variable   0
    ${oam_ip_info}   set variable  ${vdu_state_data['ip_addresses']['m_plane_ip_address']}

    ${ip}   Set Variable If    "${oam_ip_info['ipv4']}"!="None"   ${oam_ip_info['ipv4']}  ${oam_ip_info['ipv6']}

    ${rtn}   Create Dictionary   ip=${ip}  vlan_id=${oam_vlan}   subnet=${oamsubnet}  subnet_addr=${oamnet_addr}
      ...      mask=${oamnetmask}   broadcast=${broadcast}

    [Return]  ${rtn}

Get Interface Information For Tcplane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For Tcplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    8.3.2023,chris.l.cao@nokia-sbell.com, get cplane ip from REST api instead of CLI
    ...
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
    ${ifname}   Get VDU Container Interface Name     network=tracing
    ${alias}   Get Unique ID

    Connect To VDU Container With Tenant Interactively   ctr_abbr=oamagent   alias=${alias}
    ${out}   issh.Execute   command=ifconfig ${ifname}   check_result=${False}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}

    ${ip_v6}  ${mask_v6}     Run Keyword If  "${ip}"=="${EMPTY}"
      ...   Parse Ipv6 Address From Ifconfig    content=${out}

    ${rtn}  Run Keyword If  "${ip}"!="${EMPTY}"    Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    ...   ELSE    Create Dictionary   ip=${ip_v6}    mask=${mask_v6}   broadcast=${EMPTY}
    [Return]  ${rtn}


============ Start Of VCU =============
Get Interface Information For F1-Uplane For VCU
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get Interface Information For F1-Uplane For VCU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For F1-Uplane For VCU |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${f1_uplane_ip_info}   Get CU Specified Interface IP  interface_name=f1_interface   plane_type=u_plane_ip_address  gnb_index=${gnb_index}
    ${is_ipv6}   Check If VCU OAM Is IPv6  gnb_index=${gnb_index}
    ${f1_uplane_ip_info}  Evaluate   dict(${f1_uplane_ip_info[0]})
    ${f1_uplane_ip}  Set Variable If  "${is_ipv6}"=="${True}"        ${f1_uplane_ip_info["v6"]}   ${f1_uplane_ip_info["v4"]}

    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${f1c_subnet}  Set Variable  ${conf_dict["vCU_network"]["f1c_subnet"]}

    ${mask}   Evaluate    str(IPy.IP("${f1c_subnet}").netmask())  modules=IPy
    ${broadcast}   Evaluate    str(IPy.IP("${f1c_subnet}").broadcast())  modules=IPy

    ${rtn}   Create Dictionary   ip=${f1_uplane_ip}    mask=${mask}   broadcast=${broadcast}

    [Return]  ${rtn}


Get Interface Information For Tcplane For VCU
    [Arguments]  ${gnb_index}=0
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
    ...   | ${interface_information} | Get Interface Information For Tcplane For VCU |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${alias}   Connect To VCU Container With Tenant Interactively   ctr_abbr=oamagent
    ${out}   issh.Execute   command=ifconfig tracing   check_result=${False}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}

    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${tracing_subnet}  Set Variable  ${conf_dict["vCU_network"]["tracing_subnet"]}

    ${mask}   Evaluate    str(IPy.IP("${tracing_subnet}").netmask())  modules=IPy
    ${broadcast}   Evaluate    str(IPy.IP("${tracing_subnet}").broadcast())  modules=IPy

    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}


Get Interface Information For Xnc plane
    [Arguments]  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For Xnc plane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, type is dictionary, {'vlan_id': 310, 'ip': '10.110.77.20', 'mask': '255.255.255.128', 'broadcast': '10.110.77.127'}
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For Xnc plane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...   | ${vlan_id} | Set Variable | ${interface_information["vlan_id"]} |
    ...
    ${alias}   Connect To VCU Container With Tenant Interactively   ctr_abbr=cpif   gnb_index=${gnb_index}
    ${out}   issh.Execute   command=ifconfig xnc   check_result=${False}   alias=${alias}
    ${ip}  ${mask0}   ${broadcast0}  Parse Ipv4 Address From Ifconfig    content=${out}

    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${vlan}   Set Variable  ${conf_dict["vCU_network"]["xnc"]}
    ${subnet}  Set Variable  ${conf_dict["vCU_network"]["xnc_subnet"]}
    ${mask}   Evaluate    str(IPy.IP("${subnet}").netmask())  modules=IPy
    ${broadcast}   Evaluate    str(IPy.IP("${subnet}").broadcast())  modules=IPy

    ${rtn}   Create Dictionary   vlan_id=${vlan}   ip=${ip}    mask=${mask}   broadcast=${broadcast}
    [Return]  ${rtn}
