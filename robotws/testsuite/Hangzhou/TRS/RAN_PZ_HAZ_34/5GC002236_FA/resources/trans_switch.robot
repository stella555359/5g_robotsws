*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   common switch keyword

Library     String
Library     Collections
Library     Telnet

Resource    trans_comm.robot



*** Variables ***


*** Keyword ***
Connect To Switch
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=150
    [Documentation]  Connect To Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip     | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...    *RETURN VALUE*
    ...    Connection id
    ...    Example
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | Switch Switch Connection |
    ...    | # multiple Switch Connection |
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${conn2} | Connect To Switch | 2.2.2.2 | nokia | nokia123 | nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | ${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | Switch Close All Connections |
    ${conn}  Wait Until Keyword Succeeds   6x   5s   Connect To Switch One Time
    ...    switch_ip=${switch_ip}    switch_user=${switch_user}    switch_password=${switch_password}  switch_en_password=${switch_en_password}
    ...   port=${port}   prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}   timeout=${timeout}

    [Return]  ${conn}


Connect To Switch One Time
    [Arguments]    ${switch_ip}     ${switch_user}=nokia    ${switch_password}=nokia123  ${switch_en_password}=nokia123
    ...   ${port}=23   ${prompt}=#   ${prompt_is_regexp}=False   ${timeout}=300
    [Documentation]  Connect To Switch
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | switch_ip     | Yes. | switch_ip, default is nokia123  |
    ...    | switch_user | No. | switch_user, default is nokia123  |
    ...    | switch_password | No. | switch_password, default is nokia123  |
    ...    | switch_en_password | No. | switch_en_password, default is nokia123 |
    ...    *RETURN VALUE*
    ...    Connection id
    ...    Example
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | Switch Switch Connection |
    ...    | # multiple Switch Connection |
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${conn2} | Connect To Switch | 2.2.2.2 | nokia | nokia123 | nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | ${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | Switch Close All Connections |
    ${conn}  Telnet.Open Connection    host=${switch_ip}   port=${port}   prompt=assword:
    ...  timeout=${timeout}
    Sleep  0.2
    Telnet.Write    ${switch_user}
    Sleep  0.2
    Telnet.Write    ${switch_password}

    #if no 'enable password', return directly
    Run Keyword If  '${switch_en_password}'==''   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}
    Run Keyword If  '${switch_en_password}'==''   Telnet.Read Until Prompt
    Return From Keyword If  '${switch_en_password}'==''    ${conn}

    #if has 'enable password', enter it
    ${dummy}   Telnet.Read Until     expected=>
    ${dummy}   Telnet.Set Prompt  prompt=assword:
    Telnet.Write    enable
    Sleep  0.2
    ${dummy}   Telnet.Set Prompt  prompt=${prompt}   prompt_is_regexp=${prompt_is_regexp}

    Telnet.Write    ${switch_en_password}
    ${dummy}   Telnet.Read Until Prompt

    [Return]  ${conn}


Switch Close Connection
    [Arguments]  ${conn}=${EMPTY}
    [Documentation]  Switch Close Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | conn     | Yes. | switch connection to be closed  |
    ...    *RETURN VALUE*
    ...   None
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | Switch Close Connection |
    ${old_conn}  Run Keyword If  "${conn}"!="${EMPTY}"   Telnet.Switch Connection   index_or_alias=${conn}
    Telnet.Close Connection
    Run Keyword If   "${conn}"!="${EMPTY}"   Run Keyword And Ignore Error  Telnet.Switch Connection   index_or_alias=${old_conn}


Switch Close All Connections
    [Documentation]  Switch Close Connection
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | conn     | Yes. | switch connection to be closed  |
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | # multiple Switch Connection |
    ...    | ${conn1} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
    ...    | ${conn2} | Connect To Switch | 2.2.2.2 | nokia | nokia123 | nokia123 |
    ...    | ${old_conn} | Switch Switch Connection | ${conn1} |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
    ...    | ${old_conn} | Switch Switch Connection | ${conn2} |
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/17 | 4 |
    ...    | Switch Close All Connections |
    Telnet.Close All Connections


Show Switch Version
    [Documentation]  Show Switch Version
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    swith version information
    ...    Example
    ...    | ${switch_conn} | Connect To Switch | 1.1.1.1 | nokia | nokia123 | nokia123 |
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
    ...    Example
    ...    | ${switch_vendor} | Get Switch Vendor |
    ${out}    Show Switch Version

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
    ...    Example
    ...    | ${result} | Query Switch VLAN Tag Setting | 0/16 | 3 |
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


Query Switch VLAN Untag Setting
    [Arguments]  ${interface}   ${vlanID}
    [Documentation]  Query Switch VLAN Untag Setting
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | vlanID   | yes | vlanid, e.g, 2, 3 |
    ...    None
    ...    *RETURN VALUE*
    ...    Return yes if it exists, otherwise return no
    ...    Example
    ...    | ${result} | Query Switch VLAN Untag Setting | 0/16 | 3 |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Query Switch VLAN Untag Setting For GUANTA
       ...   interface=${interface}   vlanID=${vlanID}
    ...   ELSE IF  '${vendor}'=='DELL'  _Query Switch VLAN Untag Setting for DELL
       ...   interface=${interface}   vlanID=${vlanID}

    [Return]  ${rtn}


_Query Switch VLAN Untag Setting For GUANTA
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=show run interface ${interface}
    ${pattern}  Set Variable  switchport untagging ${vlanID}
    ${bExist}    Check Pattern Exist    content=${out}     pattern=\\s*${pattern}\\s*
    ${rtn}   Set Variable If  ${bExist}==1   yes    no
    [Return]  ${rtn}


_Query Switch VLAN Untag Setting For DELL
    [Arguments]  ${interface}   ${vlanID}
    ${out}   Telnet.Execute Command  command=sh run interface vlan ${vlanID} | grep untagged
    ${out}   Set Variable  ${out.splitlines()}
    ${len}    Get Length    ${out}
    Return From Keyword If    ${len}<=1    no
    ${out}  Set Variable   ${out[0]}

    ${out}    Strip String    ${out}
    ${out_list}    Split String    ${out}    ${SPACE}
    Log    untagged for vlanid(${vlanID}):${out_list}
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
    Log To Console   _Query Switch VLAN Untag Setting For DELL result(${interface},${vlanID}):${rtn}
    [Return]  ${rtn}

Get Port List
    [Arguments]    ${section}
    ${tmp_list}    Split String    ${section}    -
    ${len}    Get Length    ${tmp_list}
    Should Be True    ${len}==2
    ${start}    Set Variable    ${tmp_list[0]}
    ${end}    Set Variable    ${tmp_list[1]}
    ${tmp}    Split String    ${start}    /
    ${stack_num}    Set Variable    ${tmp[0]}
    ${start_port_num}    Set Variable    ${tmp[1]}
    ${tmp}    Split String    ${end}    /
    ${end_port_num}    Set Variable    ${tmp[1]}
    ${end_port_num}    Evaluate    ${end_port_num}+1
    ${rtn}    Create List
    FOR    ${i}    IN RANGE    ${start_port_num}    ${end_port_num}
         Log    ${i}
         Append To List    ${rtn}    ${stack_num}/${i}
    END
    [Return]    ${rtn}


Add Switch VLAN Tag With Hybrid Mode
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    [Documentation]  Add Switch VLAN Tag With Hybrid Mode
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | list_vlan_tag   | yes | vlan tag list |
    ...    | list_vlan_native   | yes | vlan native id list |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${list_vlan_tag} | create list | 2 | 3 |
    ...    | ${list_vlan_native} | create list | 4 | 5 |
    ...    | ${result} | Add Switch VLAN Tag With Hybrid Mode | 0/16 | ${list_vlan_tag} |    ${list_vlan_native} |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Add Switch VLAN Tag With Hybrid Mode For GUANTA
       ...   interface=${interface}   list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}
    ...   ELSE IF  '${vendor}'=='DELL'  _Add Switch VLAN Tag With Hybrid Mode for DELL
       ...   interface=${interface}   list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}


_Add Switch VLAN Tag With Hybrid Mode For GUANTA
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    ${out}   Telnet.Execute Command  command=conf
    ${out}   Telnet.Execute Command  command=int ${interface}
    ${out}   Telnet.Execute Command  command=no switchport access vlan
    ${out}   Telnet.Execute Command  command=no switchport mode access

    ${list_vlan_tag}   Unique List  ${list_vlan_tag}
    ${list_vlan_native}   Unique List  ${list_vlan_native}
    FOR   ${tag_vlan_id}   IN   @{list_vlan_tag}   @{list_vlan_native}
         ${out}   Telnet.Execute Command  command=switchport allowed vlan add ${tag_vlan_id}
    END

    FOR   ${vlan_id}   IN    @{list_vlan_tag}
        ${out}   Telnet.Execute Command  command=switchport tagging ${vlan_id}
    END

    FOR   ${vlan_id}   IN    @{list_vlan_native}
        ${out}   Telnet.Execute Command  command=switchport native vlan ${vlan_id}
    END

    ${out}   Telnet.Execute Command  command=do show run int ${interface}
    ${out}   Telnet.Execute Command  command=end


_Add Switch VLAN Tag With Hybrid Mode For DELL
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}

    ${hybrid_setting}   _Get Hybrid Setting For DELL  interface=${interface}
    Log To Console  hybrid_setting:${hybrid_setting}
    Run Keyword If  '${hybrid_setting}'=='no'    _Set Hybrid Setting For DELL   interface=${interface}
    ...   list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}

    ${out}   Telnet.Execute Command  command=conf

    FOR   ${vlan_id}   IN    @{list_vlan_tag}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=do sh run int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=exit
    END

    FOR   ${vlan_id}   IN    @{list_vlan_native}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=do sh run int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=exit
    END

    ${out}   Telnet.Execute Command  command=end
    ${out}   Telnet.Execute Command  command=show run int tengigabitethernet ${interface}



_Get Hybrid Setting For DELL
    [Arguments]  ${interface}
    ${out}  Telnet.Execute Command  command=sh run interface tengigabitethernet ${interface}
    ${pattern}   Set Variable   portmode hybrid
    ${bExist}    Check Pattern Exist    content=${out}     pattern=.*${pattern}.*
    ${rtn}   Set Variable If  ${bExist}==1   yes    no
    [Return]  ${rtn}


_Set Hybrid Setting For DELL
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    ${out}   Telnet.Execute Command  command=conf

    FOR   ${vlan_id}   IN    @{list_vlan_tag}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=exit
    END

    FOR   ${vlan_id}   IN    @{list_vlan_native}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=exit
    END

    ${out}   Telnet.Execute Command  command=int tengigabitethernet ${interface}
    ${out}   Telnet.Execute Command  command=no switchport
    ${out}   Telnet.Execute Command  command=portmode hybrid
    ${out}   Telnet.Execute Command  command=switchport
    ${out}   Telnet.Execute Command  command=end

    ${out}   Telnet.Execute Command  command=sh run int tengigabitethernet ${interface}


Delete Switch VLAN Tag With Hybrid Mode
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    [Documentation]  Delete Switch VLAN Tag With Hybrid Mode
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | list_vlan_tag   | yes | vlan tag list |
    ...    | list_vlan_native   | yes | vlan native id list |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${list_vlan_tag} | create list | 2 | 3 |
    ...    | ${list_vlan_native} | create list | 4 | 5 |
    ...    | ${result} | Delete Switch VLAN Tag With Hybrid Mode | 0/16 | ${list_vlan_tag} |    ${list_vlan_native} |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'  _Delete Switch VLAN Tag With Hybrid Mode For GUANTA
       ...   interface=${interface}   list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}
    ...  ELSE IF  '${vendor}'=='DELL'  _Delete Switch VLAN Tag With Hybrid Mode for DELL
       ...   interface=${interface}   list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}


_Delete Switch VLAN Tag With Hybrid Mode For GUANTA
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    [Documentation]  delete interface from ${list_vlan_tag}, enable interface from ${list_vlan_native} with access mode
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | list_vlan_tag   | yes | vlan tag list |
    ...    | list_vlan_native   | yes | vlan native id list |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ${out}   Telnet.Execute Command  command=conf
    ${out}   Telnet.Execute Command  command=int ${interface}
    ${out}   Telnet.Execute Command  command=no switchport native vlan
    ${out}   Telnet.Execute Command  command=no switchport tagging

    ${list_vlan_tag}   Unique List  ${list_vlan_tag}
    ${list_vlan_native}   Unique List  ${list_vlan_native}

    FOR   ${vlan_id}   IN    @{list_vlan_tag}
        ${out}   Telnet.Execute Command  command=no switchport tagging ${vlan_id}
        ${out}   Telnet.Execute Command  command=switchport allowed vlan remove ${vlan_id}
    END

    FOR   ${vlan_id}   IN    @{list_vlan_native}
        ${out}   Telnet.Execute Command  command=switchport access vlan ${vlan_id}
    END

    ${out}   Telnet.Execute Command  command=switchport mode access
    ${out}   Telnet.Execute Command  command=do show run int ${interface}
    ${out}   Telnet.Execute Command  command=end


_Delete Switch VLAN Tag With Hybrid Mode For DELL
    [Arguments]  ${interface}    ${list_vlan_tag}   ${list_vlan_native}
    [Documentation]  delete interface from ${list_vlan_tag}, enable interface from ${list_vlan_native} with untagged
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | list_vlan_tag   | yes | vlan tag list |
    ...    | list_vlan_native   | yes | vlan native id list |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ${out}   Telnet.Execute Command  command=conf

    #_Remove Hybrid Setting for DELL   interface=${interface}  list_vlan_tag=${list_vlan_tag}   list_vlan_native=${list_vlan_native}

    FOR   ${vlan_id}   IN    @{list_vlan_tag}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=do sh run int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=exit
    END

    ${out}   Telnet.Execute Command  command=end
    ${out}   Telnet.Execute Command  command=show run int tengigabitethernet ${interface}
    Log To Console  ---------------
    Log To Console  After _Delete Switch VLAN Tag With Hybrid Mode For DELL
    Log To Console  ${out}
    Log To Console  ---------------


Add Switch VLAN Untagged
    [Arguments]  ${interface}   ${list_vlan_untagged}   ${list_vlan_old}=${EMPTY}
    [Documentation]  Add Switch VLAN Untagged, remove vlans contained in ${list_vlan_old} whatmater thery are tagged or untagged
    ...   and add ${list_vlan_untagged} as untagged vlan to interface
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | interface | yes | interface |
    ...    | list_vlan_tag   | yes | vlan tag list |
    ...    | list_vlan_native   | yes | vlan native id list |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${list_vlan_untagged} | create list | 100 |
    ...    | ${list_vlan_old} | create list | 20 |
    ...    | ${result} | Add Switch VLAN Tag With Hybrid Mode | 1/4 | ${list_vlan_untagged} | list_vlan_old=${list_vlan_old} |
    ${vendor}  Get Switch Vendor
    ${rtn}   Run Keyword If  '${vendor}'=='QUANTA'   _Add Switch VLAN Untagged For GUANTA
       ...   interface=${interface}   list_vlan_untagged=${list_vlan_untagged}  list_vlan_old=${list_vlan_old}
    ...   ELSE IF  '${vendor}'=='DELL'  _Add Switch VLAN Untagged For Dell
       ...   interface=${interface}   list_vlan_untagged=${list_vlan_untagged}  list_vlan_old=${list_vlan_old}


_Add Switch VLAN Untagged For GUANTA
    [Arguments]  ${interface}    ${list_vlan_untagged}   ${list_vlan_old}
    ${len}  Get Length    ${list_vlan_untagged}
    Should Be True  ${len}==1

    ${out}   Telnet.Execute Command  command=conf

    Telnet.Execute Command  command=int ${interface}
    ${out}   Telnet.Execute Command  command=no switchport native vlan
    ${out}   Telnet.Execute Command  command=no switchport mode access

    FOR   ${vlan_id}   IN    @{list_vlan_old}
        ${out}   Telnet.Execute Command  command=switchport allowed vlan remove ${vlan_id}
        ${out}   Telnet.Execute Command  command=no switchport tagging ${vlan_id}
    END
    ${out}   Telnet.Execute Command  command=switchport mode access

    FOR   ${vlan_id}   IN    @{list_vlan_untagged}
        ${out}   Telnet.Execute Command  command=switchport access vlan ${vlan_id}
    END

    #${out}   Telnet.Execute Command  command=do show vlan id ${list_vlan_untagged[0]} | in ${interface}
    ${out}   Telnet.Execute Command  command=do sh run int ${interface}
    Log To Console  ${out}
    ${out}   Telnet.Execute Command  command=end


_Add Switch VLAN Untagged For Dell
    [Arguments]  ${interface}    ${list_vlan_untagged}   ${list_vlan_old}
    ${len}  Get Length    ${list_vlan_untagged}
    Should Be True  ${len}==1

    ${out}   Telnet.Execute Command  command=conf

    FOR   ${vlan_id}   IN    @{list_vlan_old}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=no untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=exit
    END
    FOR   ${vlan_id}   IN    @{list_vlan_untagged}
        ${out}   Telnet.Execute Command  command=int vlan ${vlan_id}
        ${out}   Telnet.Execute Command  command=no tagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=untagged tengigabitethernet ${interface}
        ${out}   Telnet.Execute Command  command=exit
    END

    ${out}   Telnet.Execute Command  command=do show vlan
    Log To Console  ${out}
    ${out}   Telnet.Execute Command  command=end


Unique List
    [Arguments]  ${input_list}
    [Documentation]  Unique List, make list member unique
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | input_list | yes | input_list |
    ...    *RETURN VALUE*
    ...    list
    ...    Example
    ...    | ${input_list} | create list | 2 | 3 | 3 |4
    ...    | ${result} | Unique List | ${input_list} |
    ...    | #now ${result} is ['2', '3', '4']  |
    ${rtn_list}   Evaluate   list(set(${input_list}))
    [Return]  ${rtn_list}


Check Pattern Exist
    [Arguments]     ${content}    ${pattern}
    [Documentation]    Check Pattern Exist
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | text to be searched |
    ...    | pattern | Yes | pattern, it's a regexp |
    ...    *RETURN VALUE*
    ...    it returns 1 if pattern exists in content, otherwise return 0
    ...    Example
    ...    | ${bExit} | Check Pattern Exist |  Machine Model.................................. QUANTA LB9  |  .*QUANTA LB9.* |
    ${bExist}    Set Variable    0
    @{lines}    Split To Lines    ${content}
    For   ${line}    IN   @{lines}
        ${line}   Set Variable  ${line.strip()}
        Continue For Loop If   ${line.__len__()}==0
        ${match}    Get Regexp Matches   ${line}    ${pattern}
        ${len}    Get Length    ${match}
        ${bExist}   Set Variable If    ${len}>0    1     0
        Exit For Loop If    ${bExist}==1
    END
    [Return]   ${bExist}
