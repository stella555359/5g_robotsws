*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_trs_switch.robot



#*** Variables ***



*** Keywords ***
Connect To VDU Switch
    [Arguments]  ${switch_index}=0
    [Documentation]  Connect To VDU Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_index     | no. | switch_index, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...
    ${conn}  Connect To Switch   switch_ip=${TRANS_PARA["du_switch"][${switch_index}]["du_switch_ip"]}
    ...   switch_user=${TRANS_PARA["du_switch"][${switch_index}]["username"]}
    ...   switch_password=${TRANS_PARA["du_switch"][${switch_index}]["password"]}
    ...   switch_en_password=${TRANS_PARA["du_switch"][${switch_index}]["en_password"]}
    ...   port=${TRANS_PARA["du_switch"][${switch_index}]["port"]}
    [Return]  ${conn}


Connect To Switch
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=15
    [Documentation]  Connect To Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip       | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user     | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...    Example
    ...    | ${conn1}  | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | # multiple Switch Connections |
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${conn2} | Connect To Switch | switch_ip=2.2.2.2 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | conn=${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | Close All Switch Connections |
    ...
    ${conn}  Wait Until Keyword Succeeds   1x   5s   _Connect To Switch One Time
    ...    switch_ip=${switch_ip}    switch_user=${switch_user}    switch_password=${switch_password}  switch_en_password=${switch_en_password}
    ...   port=${port}   prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}   timeout=${timeout}

    [Return]  ${conn}


_Connect To Switch One Time
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=300
    [Documentation]  _Connect To Switch One Time
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip     | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...
    ${conn}  Telnet.Open Connection    host=${switch_ip}   port=${port}      timeout=${timeout}
    ${dummy}   Telnet.Read Until Regexp     ogin:     ser:
    ${out}   Telnet.Write    ${switch_user}
    ${dummy}   Telnet.Read Until     expected=assword:
    ${out}  Telnet.Write    ${switch_password}

    #if no 'enable password', return directly
    Run Keyword If  '${switch_en_password}'==''   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}
    ${out}  Run Keyword If  '${switch_en_password}'==''   Telnet.Read Until Prompt
    Return From Keyword If  '${switch_en_password}'==''    ${conn}

    #if has 'enable password', enter it
    ${dummy}   Telnet.Read Until     expected=>
    ${dummy}   Telnet.Set Prompt  prompt=assword:
    Telnet.Write    enable
    ${dummy}   Telnet.Read Until     expected=assword:
    ${dummy}   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}

    ${out}     Telnet.Write    ${switch_en_password}
    ${dummy}   Telnet.Read Until Prompt

    [Return]  ${conn}

Connect To VDU Switch Via SSH
    [Arguments]    ${alias}=default   ${timeout}=15
    [Documentation]  Connect To Switch Via SSH
    ...    *AUTHOR* zhiqiang.q2.liu
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Connection id
    ...
    ...    Example
    ...    | ${conn1}  | Connect To Switch Via SSH |
    ...
    ${switch_IP}  Set Variable  ${TRANS_PARA["du_switch"][0]["du_switch_ip"]}
    ${switch_user}  Set Variable  ${TRANS_PARA["du_switch"][0]["username"]}
    ${switch_passwd}  Set Variable  ${TRANS_PARA["du_switch"][0]["password"]}
    ${switch_prompt}  Set Variable  ${TRANS_PARA["du_switch"][0]["prompt"]}
    ${alias}  issh.connect_to  ip=${switch_IP}  port=22  username=${switch_user}  password=${switch_passwd}  prompt=${switch_prompt}
    ...    timeout=${timeout}

    [Return]  ${alias}

Close Switch Connection
    [Arguments]  ${conn}=${EMPTY}
    [Documentation]  Close Switch Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | conn     | Yes. | switch connection to be closed  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    | ${conn1}  | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ...    | Close Switch Connection |
    ...
    ${old_conn}  Run Keyword If  "${conn}"!="${EMPTY}"   Telnet.Switch Connection   index_or_alias=${conn}
    Telnet.Close Connection
    Run Keyword If   "${conn}"!="${EMPTY}"   Run Keyword And Ignore Error  Telnet.Switch Connection   index_or_alias=${old_conn}



Show Switch Version Information
    [Documentation]  Show Switch Version Information
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    swith version information
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${version_info} | Show Switch Version Information |
    ...
    ${old_prompt}   Telnet.Set Prompt  prompt=#|\\(q\\)uit   prompt_is_regexp=True
    Telnet.Write  text=show version
    ${out}   Telnet.Read Until Prompt
    Run Keyword If  """(q)uit""" in """${out}"""   Telnet.Write   text=q
    ${dummy}   Run Keyword If   """(q)uit""" in """${out}"""   Telnet.Read Until Prompt
    Telnet.Set Prompt  prompt=${old_prompt[0]}   prompt_is_regexp=False
    [Return]   ${out}


Get Switch Vendor
    [Documentation]  Get Switch Vendor
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Return type is string, return value will be swtich vendor, e.g, QUANTA, DELL
    ...
    ...    Example
    ...    | ${switch_vendor} | Get Switch Vendor |
    ${out}    Show Switch Version Information

    #check QUANTA
    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*QUANTA.*
    Return From Keyword If    ${bExist}==1   QUANTA

    #check Dell
    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*Dell Operating System.*
    Return From Keyword If    ${bExist}==1   DELL

    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*S[3-4]048-ON.*
    Return From Keyword If    ${bExist}==1   DELL

    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*Z9100-ON.*
    Return From Keyword If    ${bExist}==1   DELL

    ${vendor}    Set Variable    UNKNOWN
    Fail   Switch vendor should not be UNKNOWN!!!!

    [Return]   ${vendor}



Query Switch VLAN Tag Setting
    [Arguments]  ${interface}   ${vlanID}
    [Documentation]  Query Switch VLAN Tag Setting
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | vlanID   | yes | vlanid, e.g, 2, 3 |
    ...    None
    ...    *RETURN VALUE*
    ...    Return yes if it exists, otherwise return no
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | interface=0/16 | vlanID=3 |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Query Switch VLAN Tag Setting For GUANTA
       ...   interface=${interface}   vlanID=${vlanID}
    ...   ELSE IF  '${vendor}'=='DELL'  _Query Switch VLAN Tag Setting for DELL
       ...   interface=${interface}   vlanID=${vlanID}

    [Return]  ${rtn}


_Query Switch VLAN Tag Setting For GUANTA
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=show run interface ${interface}
    ${pattern}  Set Variable  switchport tagging ${vlanID}
    ${bExist}    Check Pattern Exist    content=${out}     pattern=\\s*${pattern}\\s*
    ${rtn}   Set Variable If  ${bExist}==1   yes    no
    [Return]  ${rtn}


_Query Switch VLAN Tag Setting For DELL
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=sh run interface vlan ${vlanID} | grep tagged
    ${out}   Set Variable  ${out.splitlines()}
    ${len}    Get Length    ${out}
    Return From Keyword If    ${len}<=1    no
    ${out}  Set Variable   ${out[0]}

    ${out}    Strip String    ${out}
    ${out_list}    Split String    ${out}    ${SPACE}
    ${tag_info}    Set Variable    ${out_list[2]}
    ${tag_list}    Split String    ${tag_info}    ,
    ${port_list}    Create List
    FOR    ${section}    IN    @{tag_list}
        Log To Console    ${section}
        Run Keyword If    "-" not in "${section}"    Append To List    ${port_list}    ${section}
        Continue For Loop If    "-" not in "${section}"
        ${tmp_list}    Get Port List    section=${section}
        ${port_list}    Combine Lists    ${port_list}    ${tmp_list}
    END

    ${found}    Get Index From List    ${port_list}    ${interface}
    ${rtn}    Set Variable If    ${found}!=-1    yes    no
    [Return]  ${rtn}


Set Switch ACL
    [Arguments]   ${interface}  ${peer_ip}   ${local_ip}    ${protocol_number}   ${acl_number}   ${direction}
    [Documentation]  Set Switch ACL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | peer_ip |  yes | peer_ip |
    ...    | local_ip |  yes | local_ip |
    ...    | protocol_number |  yes | protocol number, e.g, 132 for sctp, 6 for tcp, 17 for udp  |
    ...    | acl_number      |  yes | acl_number |
    ...    | direction      |  yes | direction |
    ...
    ...    *RETURN VALUE*
    ...    OK or ${None}. OK if successfully set ACL, otherwise return ${None}
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | Set Switch ACL | interface=1/1/2 | peer_ip=3.3.3.3 | local_ip=2.2.2.2 | protocol_number=132 | acl_number=188 |
    ...    | ... | direction=in |
    ...    | ${result} | Clear Switch ACL | interface=1/1/2 | acl_number=${acl_number} | direction=in |
    ...
    ${vendor}  Get Switch Vendor
    ${result}   Run Keyword If  '${vendor}'=='QUANTA'  _Set Switch ACL For GUANTA
       ...  interface=${interface}  peer_ip=${peer_ip}  local_ip=${local_ip}  protocol_number=${protocol_number}
       ...   acl_number=${acl_number}  direction=${direction}
    ...  ELSE IF  '${vendor}'=='DELL'  _Set Switch ACL for DELL
       ...  interface=${interface}  peer_ip=${peer_ip}  local_ip=${local_ip}  protocol_number=${protocol_number}
       ...  acl_number=${acl_number}   direction=${direction}

    [Return]  ${result}


_Set Switch ACL For GUANTA
    [Arguments]   ${interface}   ${peer_ip}   ${local_ip}    ${protocol_number}   ${acl_number}   ${direction}
    Return From Keyword If   '${interface}'=='${EMPTY}'
    Log To Console  acl_number:${acl_number}
    _Clear Switch ACL For GUANTA   interface=${interface}    acl_number=${acl_number}  direction=${direction}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=access-list ${acl_number} deny ${protocol_number} ${peer_ip} 0.0.0.0 ${local_ip} 0.0.0.0
    ${out}   Telnet.Execute Command  command=access-list ${acl_number} permit every
    ${out}   Telnet.Execute Command  command=interface ${interface}
    ${out}   Telnet.Execute Command  command=ip access-group ${acl_number} ${direction}
    ${out}   Telnet.Execute Command  command=exit
    [Return]  OK


_Set Switch ACL For DELL
    [Arguments]   ${interface}   ${peer_ip}   ${local_ip}   ${protocol_number}   ${acl_number}  ${direction}
    Return From Keyword If   '${interface}'=='${EMPTY}'
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    Log To Console  set acl_group:${acl_group}
    ${interface_type}   _Get Switch Interface Type DELL  ${interface}
    _Clear Switch ACL For DELL    interface=${interface}    acl_number=${acl_number}  direction=${direction}

    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=ip access-list extended ${acl_group}
    ${out}   Telnet.Execute Command  command=deny ${protocol_number} ${local_ip} 255.255.255.255 ${peer_ip} 255.255.255.255
    ${out}   Telnet.Execute Command  command=permit ip any any
    ${out}   Telnet.Execute Command  command=exit
    ${out}   Telnet.Execute Command  command=int ${interface_type} ${interface}
    ${out}   Telnet.Execute Command  command=ip access-group ${acl_group} ${direction}
    ${out}   Telnet.Execute Command  command=end
    [Return]  OK


_Get Dell ACL Group
    [Arguments]  ${acl_number}
    ${acl_group}   Set Variable   acl_aic_ta_${acl_number}
    [Return]   ${acl_group}


Clear Switch ACL
    [Arguments]   ${interface}   ${acl_number}    ${direction}
    [Documentation]  Clear Switch ACL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface        | yes | interface |
    ...    | acl_number     | yes | acl_number, it's defined in __init__.py  |
    ...    | direction      | yes | direction |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | Set Switch ACL | interface=1/1/2 | peer_ip=3.3.3.3 | local_ip=2.2.2.2 | protocol_number=132 | acl_number=188 |
    ...    | ... | direction=in |
    ...    | ${result} | Clear Switch ACL | interface=1/1/2 | acl_number=${acl_number} | direction=in |
    ...
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Clear Switch ACL For GUANTA
       ...   interface=${interface}    acl_number=${acl_number}   direction=${direction}
    ...   ELSE IF  '${vendor}'=='DELL'  _Clear Switch ACL for DELL
       ...   interface=${interface}    acl_number=${acl_number}     direction=${direction}

    [Return]  ${rtn}


_Clear Switch ACL For GUANTA
    [Arguments]   ${interface}    ${acl_number}   ${direction}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=interface ${interface}
    ${out}   Telnet.Execute Command  command=no ip access-group ${acl_number} ${direction}
    ${out}   Telnet.Execute Command  command=exit
    ${out}   Telnet.Execute Command  command=no access-list ${acl_number}
    ${out}   Telnet.Execute Command  command=exit


_Clear Switch ACL For DELL
    [Arguments]   ${interface}   ${acl_number}   ${direction}
    [Teardown]    Telnet.Execute Command  command=end
    Return From Keyword If   '${interface}'=='${EMPTY}'
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    Log To Console  clear acl_group:${acl_group}
    ${interface_type}  _Get Switch Interface Type DELL   ${interface}
    _Clear Switch Access Group For DELL   acl_number=${acl_number}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=no ip access-list extended acl_group
    ${out}   Telnet.Execute Command  command=int ${interface_type} ${interface}
    ${out}   Telnet.Execute Command  command=no ip access-group ${acl_group} ${direction}


_Clear Switch Access Group For DELL
    [Arguments]   ${acl_number}
    [Teardown]     Telnet.Execute Command  command=end
    ${acl_group}   _Get Dell ACL Group   acl_number=${acl_number}
    ${out}   Telnet.Execute Command  command=configure
    ${out}   Telnet.Execute Command  command=ip access-list extended ${acl_group}
    ${out}   Telnet.Execute Command  command=show config
    ${lines}  Split To Lines    ${out}
    Remove From List  ${lines}  0
    Remove From List  ${lines}  0
    FOR  ${line}  IN  @{lines}
        Exit For Loop If  ${line.endswith('#')}
        ${seq_num}    Set Variable  ${line.split()[1]}
        ${out}   Telnet.Execute Command   command=no seq ${seq_num}
    END


Get Switch Interface Type
    [Arguments]  ${interface}
    [Documentation]  Get Switch Interface Type
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    None
    ...    *RETURN VALUE*
    ...    Return interface type if it's DELL brand switch, e.g, twentyFiveGigE. Otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${conn1} | Connect To Switch | switch_ip=1.1.1.1 | switch_user=nokia | switch_password=nokia123 | switch_en_password=nokia123 |
    ...    | ${result} |Get Switch Interface Type | interface=1/1/1 |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  Set Variable   ${EMPTY}
    ...   ELSE IF  '${vendor}'=='DELL'  _Get Switch Interface Type DELL
       ...   interface=${interface}

    [Return]  ${rtn}


_Get Switch Interface Type DELL
    [Arguments]  ${interface}
    [Documentation]   _Get Switch Interface Type DELL
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface      | yes | interface |
    ...
    ...    *RETURN VALUE*
    ...    interface type, e.g, twentyFiveGigE
    ...
    ...    Example
    ...    | ${interface_type} | _Get Switch Interface Type DELL | 1/1/1 |
    ...
    ${out}   Telnet.Execute Command  command=show interfaces description|grep ${interface}
    ${lines}  Split To Lines   ${out}
    Remove From List   ${lines}  -1
    Should Be True  ${lines.__len__()}==1
    ${interface_type}   Set Variable  ${lines[0].split()[0]}
    [Return]  ${interface_type}


Clear ACL Config For VDU TOR
    [Teardown]  Run Keyword If    """${TRANS_PARA}"""!="""${NONE}"""   Run Keyword And Ignore Error  Close Switch Connection
    [Documentation]  Clear ACL Config For VDU TOR
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Clear ACL Config For VDU TOR |
    ...
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""

    ${result}   ${acl_number}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["acl_number"]}
    Return From Keyword If  """${result}"""=="""FAIL"""
    ${acl_number}  Set Variable  ${acl_number.strip()}
    Return From Keyword If  ${acl_number.__len__()}==0

    ${result}   ${interface}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["switch_interface"]}
    Return From Keyword If  """${result}"""=="""FAIL"""
    ${interface}  Set Variable  ${interface.strip()}

    #${result}   ${interface_type}   Run Keyword And Ignore Error    Set Variable   ${TRANS_PARA["du_switch"][0]["switch_interface_type"]}
    #Return From Keyword If  """${result}"""=="""FAIL"""
    #${interface_type}  Set Variable  ${interface_type.strip()}

    Connect To Vdu Switch
    Log To Console  Clear Switch ACL for direction:in
    Clear Switch ACL   interface=${interface}    acl_number=${acl_number}   direction=in

    Log To Console  Clear Switch ACL for direction:out
    Clear Switch ACL   interface=${interface}    acl_number=${acl_number}   direction=out


FHGW Switch Set Mirror Port
    [Arguments]   ${port}    ${mode}=all  ${alias}=default
    [Documentation]   FHGW Switch Set Mirror Port
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | port        | yes | port name, e.g, xe1, roe8 |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Connect to FHGW |
    ...   | FHGW Switch Clear All Mirror Ports |            |
    ...   | FHGW Switch Set Mirror Port        | ports=xe0 |
    ...   | FHGW Switch Set Mirror Port        | ports=xe0 | mode=All |
    ...   | Disconnect From FHGW |
    ...
    Wait Until Keyword Succeeds  1x   2   _FHGW Switch Set Mirror Port Once   port=${port}    mode=${mode}    alias=${alias}


_FHGW Switch Set Mirror Port Once
    [Arguments]   ${port}   ${alias}=default  ${mode}=all
    [Documentation]   _FHGW Switch Set Mirror Port Once
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | port        | yes | port name, e.g, xe1, roe8 |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | _FHGW Switch Set Mirror Port Once     | ports=xe0 |
    ...   | _FHGW Switch Set Mirror Port Once    | ports=xe0 | mode=All |
    ...
    Should Not Be Empty  ${port}
    ${command}  Set Variable  bcmcmd "dmirror ${port} mode=${mode} dp=xe8"
    ${out}  issh.Execute      command=${command}   alias=${alias}
    Should Not Contain  ${out}   Error:


FHGW Switch Set Mirror
    [Arguments]   ${mirror_type}=Mplane  ${mode}=all
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias_fhgw}
    [Documentation]   FHGW Switch Set Mirror
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | mirror_type      | no | mirror_type, e.g, Mplane, Uplane, default is Mplane |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | FHGW Switch Clear All Mirror Ports |            |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane | mode=off |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane | mode=off |
    ...   | Disconnect Interactive Connection  |
    ...
    #do not use old alias here, in order to imporve stability!
    ${alias_fhgw}   get unique id
    Connect To Fhgw   alias=${alias_fhgw}

    Run Keyword If   "${mirror_type}"=="Mplane"   FHGW Switch Set Mirror Port   port=xe0   mode=${mode}   alias=${alias_fhgw}
    ...   ELSE   fail  ${mirror_type} is not supported yet!

