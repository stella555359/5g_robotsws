*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   pst.robot



*** Variables ***



*** Keywords ***
Deployment Type Should Be Expected
    [Arguments]  ${expected_deployment}   ${gnb_index}=0
    [Documentation]    Deployment Type Should Be Expected
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    29.7.2022, chris.l.cao@nokia-sbell.com, draft
    ...
    ...    | Input Parameters | Man. | Description |
    ...   | expected_deployment | yes | expected_deployment, e.g, SA or NSA |
    ...   | gnb_index | No | gnb_index ,default is 0 |
    ...
    ...    *RETURN VALUE*
    ...  None
    ...
    ...    Example
    ...    | Deployment Type Should Be Expected | Get OE Server expected_deployment=SA |
    ...    | Deployment Type Should Be Expected | Get OE Server expected_deployment=NSA |
    ...
    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${deploymentmode}  Set Variable   ${conf_dict["deploymentmode"]}
    Should Be True   "${deploymentmode}"=="${expected_deployment}"


Get OE Server Deployment Information VCU
    [Arguments]  ${gnb_index}=0
    [Documentation]    Get OE Server Deployment Information VCU
    ...  author:     chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    27.7.2022, chris.l.cao@nokia-sbell.com, draft
    ...
    ...    | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb_index ,default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   dictoinary of OE Server Deployment Information For VCU
    ...
    ...    Example
    ...    | ${oe_server_deployment_info} | Get OE Server Deployment Information VCU |
    ...
    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${deploymentmode}  Set Variable   ${conf_dict["deploymentmode"]}
    ${ret}   Run Keyword If   "${deploymentmode}"=="SA"   _Get OE Server Deployment Information VCU For SA  gnb_index=${gnb_index}
        ...   ELSE   _Get OE Server Deployment Information VCU For NSA  gnb_index=${gnb_index}
    [Return]  ${ret}


_Get OE Server Deployment Information VCU For SA
    [Arguments]  ${gnb_index}=0
    Log To Console     _Get OE Server Deployment Information VCU For SA
    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}

    # mplane
    ${oamsubnet}   set variable   ${conf_dict["vCU_network"]["oam_subnet"]}
    ${oamsubnet_list}   Split String  ${oamsubnet}  /
    ${oamnet_addr}   Set Variable   ${oamsubnet_list[0]}
    ${oamnetmask}   Set Variable   ${oamsubnet_list[1]}
    ${oam_ip}   Get vCU OAM Ip  gnb_index=${gnb_index}
    ${broadcast}   Evaluate    str(IPy.IP('${oamsubnet}').broadcast())   modules=IPy
    ${oam_spare_ip}  increase ip   ${broadcast}   -1
    ${oam_vlan}    set variable   ${conf_dict["vCU_network"]["oam"]}
    ${oam_link_oe}     Set Variable    testvlancu${oam_vlan}

    # trace plane
    ${tracingsubnet}   set variable   ${conf_dict["vCU_network"]["tracing_subnet"]}
    ${tracingsubnet_list}   Split String  ${tracingsubnet}  /
    ${tracingnetmask}   Set Variable   ${tracingsubnet_list[1]}
    ${tracingnet_addr}   Set Variable   ${tracingsubnet_list[0]}
    ${broadcast}   Evaluate    str(IPy.IP('${tracingsubnet}').broadcast())   modules=IPy
    ${tracing_spare_ip}  increase ip   ${broadcast}   -1
    ${trace_vlan}    set variable   ${conf_dict["vCU_network"]["tracing"]}
    ${trace_link_oe}     Set Variable    testvlancu${trace_vlan}
    ${trace_gateway}     increase_ip     ${tracingnet_addr}    1
    ${r}  ${trace_ip}  Run Keyword And Ignore Error   Set Variable  ${conf_dict["vCU_network"]["tracing_start"]}
    ${trace_ip}  Set Variable If   "${r}"=="PASS"   ${trace_ip}   ${EMPTY}

    #f1c plane
    ${f1csubnet}   set variable    ${conf_dict["vCU_network"]["f1c_subnet"]}
    ${subnet_list}   Split String  ${f1csubnet}  /
    ${f1cnet_addr}   Set Variable  ${subnet_list[0]}
    ${f1cnetmask}   Set Variable  ${subnet_list[1]}
    ${f1c_vlan}   set variable   ${conf_dict["vCU_network"]["f1c"]}

    ${f1c_ip_info}     Get Interface Information For F1-Cplane For VCU
    ${f1c_ip}     set variable     ${f1c_ip_info['ip']}
    ${broadcast}   Evaluate    str(IPy.IP('${f1csubnet}').broadcast())   modules=IPy
    ${f1c_spare_ip}  increase ip   ${broadcast}   -1
    ${f1c_link_oe}     Set Variable    testvlancu${f1c_vlan}

    #f1u plane
    ${f1usubnet}   set variable    ${conf_dict["vCU_network"]["f1u_subnet"]}
    ${subnet_list}   Split String  ${f1usubnet}  /
    ${f1unet_addr}   Set Variable  ${subnet_list[0]}
    ${f1unetmask}   Set Variable  ${subnet_list[1]}
    ${f1u_vlan}   set variable   ${conf_dict["vCU_network"]["f1u"]}

    ${f1u_ip_info}     Get Interface Information For F1-Uplane For VCU
    ${f1u_ip}     set variable     ${f1u_ip_info['ip']}
    ${broadcast}   Evaluate    str(IPy.IP('${f1usubnet}').broadcast())   modules=IPy
    ${f1u_spare_ip}  increase ip   ${broadcast}   -2
    ${f1u_link_oe}     Set Variable    testvlancu${f1u_vlan}

    #ngc
    ${ngcsubnet}   set variable    ${conf_dict["vCU_network"]["ngc_subnet"]}
    ${subnet_list}   Split String  ${ngcsubnet}  /
    ${ngcnet_addr}   Set Variable  ${subnet_list[0]}
    ${ngcnetmask}   Set Variable  ${subnet_list[1]}
    ${ngc_vlan}   set variable   ${conf_dict["vCU_network"]["ngc"]}
    ${ngc_ip}     set variable     ${conf_dict["vCU_network"]["ngc_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${ngcsubnet}').broadcast())   modules=IPy
    ${ngc_spare_ip}  increase ip   ${broadcast}   -1
    ${ngc_link_oe}     Set Variable    testvlancu${ngc_vlan}

    #ngu
    ${ngusubnet}   set variable    ${conf_dict["vCU_network"]["ngu_subnet"]}
    ${subnet_list}   Split String  ${ngusubnet}  /
    ${ngunet_addr}   Set Variable  ${subnet_list[0]}
    ${ngunetmask}   Set Variable  ${subnet_list[1]}
    ${ngu_vlan}   set variable   ${conf_dict["vCU_network"]["ngu"]}
    ${ngu_ip}     set variable     ${conf_dict["vCU_network"]["ngu_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${ngusubnet}').broadcast())   modules=IPy
    ${ngu_spare_ip}  increase ip   ${broadcast}   -1
    ${ngu_link_oe}     Set Variable    testvlancu${ngu_vlan}

    #xnc
    ${xncsubnet}   set variable    ${conf_dict["vCU_network"]["xnc_subnet"]}
    ${subnet_list}   Split String  ${xncsubnet}  /
    ${xncnet_addr}   Set Variable  ${subnet_list[0]}
    ${xncnetmask}   Set Variable  ${subnet_list[1]}
    ${xnc_vlan}   set variable   ${conf_dict["vCU_network"]["xnc"]}
    ${xnc_ip}     set variable     ${conf_dict["vCU_network"]["xnc_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${xncsubnet}').broadcast())   modules=IPy
    ${xnc_spare_ip}  increase ip   ${broadcast}   -1
    ${xnc_link_oe}     Set Variable    testvlancu${xnc_vlan}

    #xnu
    ${xnusubnet}   set variable    ${conf_dict["vCU_network"]["xnu_subnet"]}
    ${subnet_list}   Split String  ${xnusubnet}  /
    ${xnunet_addr}   Set Variable  ${subnet_list[0]}
    ${xnunetmask}   Set Variable  ${subnet_list[1]}
    ${xnu_vlan}   set variable   ${conf_dict["vCU_network"]["xnu"]}
    ${xnu_ip}     set variable     ${conf_dict["vCU_network"]["xnu_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${xnusubnet}').broadcast())   modules=IPy
    ${xnu_spare_ip}  increase ip   ${broadcast}   -1
    ${xnu_link_oe}     Set Variable    testvlancu${xnu_vlan}

    # interface
    ${net_org}   set variable   ${conf_dict["vCU_network"]["fastPathDevicePool"]}
    ${net_split_1}   Split String  ${net_org}  /
    ${net_split_2}   Split String   ${net_split_1[1]}  _
    ${interface}    Set Variable    ${net_split_2[2]}

    #timezone
    ${timezone}   Set Variable   ${conf_dict["misc"]["timezone"]}

   ${rtn}  Create Dictionary  interface=${interface}
      ...   oam_spare_ip=${oam_spare_ip}  oamnet_addr=${oamnet_addr}  oamnetmask=${oamnetmask}  oam_link_oe=${oam_link_oe}  oam_vlan_id=${oam_vlan}
      ...   f1c_spare_ip=${f1c_spare_ip}  f1cnet_addr=${f1cnet_addr}  f1cnetmask=${f1cnetmask}   f1c_link_oe=${f1c_link_oe}  f1c_vlan_id=${f1c_vlan}
      ...   f1u_spare_ip=${f1u_spare_ip}  f1unet_addr=${f1unet_addr}  f1unetmask=${f1unetmask}   f1u_link_oe=${f1u_link_oe}  f1u_vlan_id=${f1u_vlan}
      ...   ngc_spare_ip=${ngc_spare_ip}  ngcnet_addr=${ngcnet_addr}  ngcnetmask=${ngcnetmask}   ngc_link_oe=${ngc_link_oe}  ngc_vlan_id=${ngc_vlan}
      ...   ngc_ip=${ngc_ip}
      ...   ngu_spare_ip=${ngu_spare_ip}  ngunet_addr=${ngunet_addr}  ngunetmask=${ngunetmask}   ngu_link_oe=${ngu_link_oe}  ngu_vlan_id=${ngu_vlan}
      ...   ngu_ip=${ngu_ip}
      ...   xnc_spare_ip=${xnc_spare_ip}  xncnet_addr=${xncnet_addr}  xncnetmask=${xncnetmask}   xnc_link_oe=${xnc_link_oe}  xnc_vlan_id=${xnc_vlan}
      ...   xnc_ip=${xnc_ip}
      ...   xnu_spare_ip=${xnu_spare_ip}  xnunet_addr=${xnunet_addr}  xnunetmask=${xnunetmask}   xnu_link_oe=${xnu_link_oe}  xnu_vlan_id=${xnu_vlan}
      ...   xnu_ip=${xnu_ip}
      ...   tracing_spare_ip=${tracing_spare_ip}  tracingnet_addr=${tracingnet_addr}  tracingnetmask=${tracingnetmask}
      ...    trace_link_oe=${trace_link_oe}  trace_vlan=${trace_vlan}  trace_gateway=${trace_gateway}  trace_ip=${trace_ip}  timezone=${timezone}
   [Return]  ${rtn}


_Get OE Server Deployment Information VCU For NSA
    [Arguments]  ${gnb_index}=0
   Log To Console     _Get OE Server Deployment Information VCU For NSA
   ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}

    # mplane
    ${oamsubnet}   set variable   ${conf_dict["vCU_network"]["oam_subnet"]}
    ${oamsubnet_list}   Split String  ${oamsubnet}  /
    ${oamnet_addr}   Set Variable   ${oamsubnet_list[0]}
    ${oamnetmask}   Set Variable   ${oamsubnet_list[1]}
    ${oam_ip}   Get vCU OAM Ip  gnb_index=${gnb_index}
    ${broadcast}   Evaluate    str(IPy.IP('${oamsubnet}').broadcast())   modules=IPy
    ${oam_spare_ip}  increase ip   ${broadcast}   -1
    ${oam_vlan}    set variable   ${conf_dict["vCU_network"]["oam"]}
    ${oam_link_oe}     Set Variable    testvlancu${oam_vlan}

    # trace plane
    ${tracingsubnet}   set variable   ${conf_dict["vCU_network"]["tracing_subnet"]}
    ${tracingsubnet_list}   Split String  ${tracingsubnet}  /
    ${tracingnetmask}   Set Variable   ${tracingsubnet_list[1]}
    ${tracingnet_addr}   Set Variable   ${tracingsubnet_list[0]}
    ${broadcast}   Evaluate    str(IPy.IP('${tracingsubnet}').broadcast())   modules=IPy
    ${tracing_spare_ip}  increase ip   ${broadcast}   -1
    ${trace_vlan}    set variable   ${conf_dict["vCU_network"]["tracing"]}
    ${trace_link_oe}     Set Variable    testvlancu${trace_vlan}
    ${trace_gateway}     increase_ip     ${tracingnet_addr}    1
#    ${trace_ip}  Set Variable  ${conf_dict["vCU_network"]["tracing_start"]}
    ${r}  ${trace_ip}  Run Keyword And Ignore Error   Set Variable  ${conf_dict["vCU_network"]["tracing_start"]}
    ${trace_ip}  Set Variable If   "${r}"=="PASS"   ${trace_ip}   ${EMPTY}

    #f1c plane
    ${f1csubnet}   set variable    ${conf_dict["vCU_network"]["f1c_subnet"]}
    ${subnet_list}   Split String  ${f1csubnet}  /
    ${f1cnet_addr}   Set Variable  ${subnet_list[0]}
    ${f1cnetmask}   Set Variable  ${subnet_list[1]}
    ${f1c_vlan}   set variable   ${conf_dict["vCU_network"]["f1c"]}

    ${f1c_ip_info}     Get Interface Information For F1-Cplane For VCU
    ${f1c_ip}     set variable     ${f1c_ip_info['ip']}
    ${broadcast}   Evaluate    str(IPy.IP('${f1csubnet}').broadcast())   modules=IPy
    ${f1c_spare_ip}  increase ip   ${broadcast}   -1
    ${f1c_link_oe}     Set Variable    testvlancu${f1c_vlan}

    #f1u plane
    ${f1usubnet}   set variable    ${conf_dict["vCU_network"]["f1u_subnet"]}
    ${subnet_list}   Split String  ${f1usubnet}  /
    ${f1unet_addr}   Set Variable  ${subnet_list[0]}
    ${f1unetmask}   Set Variable  ${subnet_list[1]}
    ${f1u_vlan}   set variable   ${conf_dict["vCU_network"]["f1u"]}

    ${f1u_ip_info}     Get Interface Information For F1-Uplane For VCU
    ${f1u_ip}     set variable     ${f1u_ip_info['ip']}
    ${broadcast}   Evaluate    str(IPy.IP('${f1usubnet}').broadcast())   modules=IPy
    ${f1u_spare_ip}  increase ip   ${broadcast}   -2
    ${f1u_link_oe}     Set Variable    testvlancu${f1u_vlan}

    #x2c
    ${x2csubnet}   set variable    ${conf_dict["vCU_network"]["x2c_subnet"]}
    ${subnet_list}   Split String  ${x2csubnet}  /
    ${x2cnet_addr}   Set Variable  ${subnet_list[0]}
    ${x2cnetmask}   Set Variable  ${subnet_list[1]}
    ${x2c_vlan}   set variable   ${conf_dict["vCU_network"]["x2c"]}
    ${x2c_ip}     set variable     ${conf_dict["vCU_network"]["x2c_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${x2csubnet}').broadcast())   modules=IPy
    ${x2c_spare_ip}  increase ip   ${broadcast}   -1
    ${x2c_link_oe}     Set Variable    testvlancu${x2c_vlan}

    #x2u
    ${x2usubnet}   set variable    ${conf_dict["vCU_network"]["x2u_subnet"]}
    ${subnet_list}   Split String  ${x2usubnet}  /
    ${x2unet_addr}   Set Variable  ${subnet_list[0]}
    ${x2unetmask}   Set Variable  ${subnet_list[1]}
    ${x2u_vlan}   set variable   ${conf_dict["vCU_network"]["x2u"]}
    ${x2u_ip}     set variable     ${conf_dict["vCU_network"]["x2u_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${x2usubnet}').broadcast())   modules=IPy
    ${x2u_spare_ip}  increase ip   ${broadcast}   -1
    ${x2u_link_oe}     Set Variable    testvlancu${x2u_vlan}

    #s1u
    ${s1usubnet}   set variable    ${conf_dict["vCU_network"]["s1u_subnet"]}
    ${subnet_list}   Split String  ${s1usubnet}  /
    ${s1unet_addr}   Set Variable  ${subnet_list[0]}
    ${s1unetmask}   Set Variable  ${subnet_list[1]}
    ${s1u_vlan}   set variable   ${conf_dict["vCU_network"]["s1u"]}
    ${s1u_ip}     set variable     ${conf_dict["vCU_network"]["s1u_start"]}
    ${broadcast}   Evaluate    str(IPy.IP('${s1usubnet}').broadcast())   modules=IPy
    ${s1u_spare_ip}  increase ip   ${broadcast}   -1
    ${s1u_link_oe}     Set Variable    testvlancu${s1u_vlan}

    # interface
    ${net_org}   set variable   ${conf_dict["vCU_network"]["fastPathDevicePool"]}
    ${net_split_1}   Split String  ${net_org}  /
    ${net_split_2}   Split String   ${net_split_1[1]}  _
    ${interface}    Set Variable    ${net_split_2[2]}

   ${rtn}  Create Dictionary  interface=${interface}
      ...   oam_spare_ip=${oam_spare_ip}  oamnet_addr=${oamnet_addr}  oamnetmask=${oamnetmask}  oam_link_oe=${oam_link_oe}  oam_vlan_id=${oam_vlan}
      ...   f1c_spare_ip=${f1c_spare_ip}  f1cnet_addr=${f1cnet_addr}  f1cnetmask=${f1cnetmask}   f1c_link_oe=${f1c_link_oe}  f1c_vlan_id=${f1c_vlan}
      ...   f1u_spare_ip=${f1u_spare_ip}  f1unet_addr=${f1unet_addr}  f1unetmask=${f1unetmask}   f1u_link_oe=${f1u_link_oe}  f1u_vlan_id=${f1u_vlan}
      ...   x2c_spare_ip=${x2c_spare_ip}  x2cnet_addr=${x2cnet_addr}  x2cnetmask=${x2cnetmask}   x2c_link_oe=${x2c_link_oe}  x2c_vlan_id=${x2c_vlan}
      ...   x2c_ip=${x2c_ip}
      ...   x2u_spare_ip=${x2u_spare_ip}  x2unet_addr=${x2unet_addr}  x2unetmask=${x2unetmask}   x2u_link_oe=${x2u_link_oe}  x2u_vlan_id=${x2u_vlan}
      ...   x2u_ip=${x2u_ip}
      ...   s1u_spare_ip=${s1u_spare_ip}  s1unet_addr=${s1unet_addr}  s1unetmask=${s1unetmask}   s1u_link_oe=${s1u_link_oe}  s1u_vlan_id=${s1u_vlan}
      ...   s1u_ip=${s1u_ip}
      ...   tracing_spare_ip=${tracing_spare_ip}  tracingnet_addr=${tracingnet_addr}  tracingnetmask=${tracingnetmask}
      ...    trace_link_oe=${trace_link_oe}  trace_vlan=${trace_vlan}  trace_gateway=${trace_gateway}  trace_ip=${trace_ip}
   [Return]  ${rtn}


Generate DoS Traffic
    [Arguments]  ${DoS_server_ip}   ${command}  ${target_ip}  ${source_ip}=${EMPTY}  ${broadcast_address}=${EMPTY}  ${send_duration}=5
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Generate DoS Traffic
    ...  author:      chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    29.7.2022, chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  DoS_server_ip |  yes  | DoS_server_ip  |
    ...    |  command   |  yes  | command, eg. land, smurf,etc.  |
    ...    |  target_ip |  yes  | target_ip, e.g, f1u ip, f1c ip, etc.  |
    ...    |  source_ip |  no  | source_ip  |
    ...    |  broadcast_address |  no  | broadcast_address  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Generate DoS Traffic | DoS_server_ip=1.1.1.1 |  command=synflood | target_ip=1.2.2.2 |
    ...
    ${alias}  Connect To DoS Tool Server   ip=${DoS_server_ip}    username=root
    ${out}   issh.Execute   command=cd ${REMOTE_FOLDER}  check_result=${False}  alias=${alias}
    ${cmd}   Set Variable If   "${command}"=="synflood"   ./synflood ${target_ip}
     ...   "${command}"=="teardrop"   ./batch_sender.sh -T teardrop -s ${source_ip} -t ${target_ip} -c 9999
     ...   "${command}"=="land"   ./land ${target_ip} 10009
     ...   "${command}"=="pingofdeath"   ./pingofdeath ${target_ip}
     ...   "${command}"=="jolt2"   ./jolt2 ${target_ip}
     ...   "${command}"=="smurf"   ./batch_sender.sh -T smurf -t ${target_ip} -b ${broadcast_address}
     ...   unknown_command

    Run Keyword If   "${cmd}"=="unknown_command"   Fail   Unknown command: ${command} !
    Log To Console   ${cmd}

    ${out}   issh.Execute Bare   command=${cmd}   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}
    Sleep     ${send_duration}
    ${out}   Send CTRL_C Interactively   alias=${alias}


Remove All Interfaces In DoS Server
    [Arguments]  ${tool_ip}
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Remove All Interfaces In DoS Server
    ...  author:      chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    29.7.2022, chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  tool_ip |  yes  | DoS_server_ip  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Remove All Interfaces In DoS Server  tool_ip=1.2.2.2 |
    ...
    Log To Console  Remove All VCU Interface In DoS Server
    ${alias}  Connect To DoS Tool Server   ip=${tool_ip}    username=root
    ${out}   issh.Execute   command=ifconfig |grep testvlan|awk -F ":" '{print $1}'   check_result=${False}   alias=${alias}
    ${out}   Strip Prompt   ${out}
    ${device_name}   String.Split String   ${out}
    FOR  ${device}   IN   @{device_name}
       Log To Console   ${device}
       ${out}   issh.Execute   command=ip link set ${device} down   check_result=${False}    alias=${alias}
       ${out}   issh.Execute   command=ip link delete ${device}     check_result=${False}    alias=${alias}
    END


Add Device At DoS Tool Server
    [Arguments]   ${tool_ip}  ${interface}  ${device_name}  ${vlan_id}  ${ip}  ${mask_len}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
    [Documentation]    Add Device At DoS Tool Server
    ...  author:      winnie.su@nokia-sbell.com
    ...  modified by:
    ...    20.7.2022, chris.l.cao@nokia-sbell.com, initilization
    ...
    ...    | Input Parameters | Man. | Description |
    ...   None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...  | Add Device At DoS Tool Server | tool_ip=1.1.1.1 | interface=eno1 | device_name=testvlan101 | vlan_id=124 |  ip=1.1.1.253 | mask_len=24 |
    ...
   ${alias}  Connect To DoS Tool Server   ip=${tool_ip}    username=root
   issh.Execute    command=ip link add link ${interface} name ${device_name} type vlan id ${vlan_id}  alias=${alias}   check_result=${False}
   issh.Execute    command=ip addr add ${ip}/${mask_len} dev ${device_name}   alias=${alias}   check_result=${False}
   issh.Execute    command=ip link set ${device_name} up   alias=${alias}   check_result=${False}


Connect To DoS Tool Server
    [Arguments]  ${ip}  ${username}=root
    [Documentation]   Connect To DoS Tool Server
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   20.7.2022,chris.l.cao@nokia-sbell.com, initialization version

    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | ip  |  no  | gnb index, default is 0 |
    ...    | username  |  no  | ute or root, default is root |
    ...
    ...    *RETURN VALUE*
    ...    alias of connection.
    ...
    ...    Example
    ...    | Connect To DoS Tool Server|
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection  |
    ...
    ...    | ${alias} | Connect To DoS Tool Server  | username=root |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias}  |
    ...    | disconnect interactive connection     | alias=${alias} |
    ...
    ${alias}  Get Unique ID
    ${ute_username}  Set Variable     ute
    ${root_password}   set variable   uteadmin

    ${prompt}  set variable    \\[ute@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\]\\#


    issh.Connect_To   ip=${ip}    username=${ute_username}   password=${DOS_TOOL_UTE_PASSWORD}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=100
       ...   timeout=350

    Return From Keyword If   "${username}"=="ute"   ${alias}

    ${old_prompt}   issh.get_prompt    alias=${alias}
    issh.set_prompt    ${old_prompt}|Password:   alias=${alias}
    ${out}   issh.Execute   command=su -               check_result=${False}   alias=${alias}
    ${out}   issh.Execute   command=${root_password}   check_result=${False}   alias=${alias}
    issh.set_prompt    ${old_prompt}   alias=${alias}
    [Return]  ${alias}


Add All VDU Device At DoS Server
    ${oe_server_deployment_info}   Get OE Server Deployment Information

    ${oam_vlan_id}  Set Variable  ${oe_server_deployment_info["oam_vlan_id"]}
    ${f1_vlan_id}   Set Variable   ${oe_server_deployment_info["f1_vlan_id"]}
    ${trace_vlan_id}  Set Variable    ${oe_server_deployment_info["trace_vlan"]}
    ${fhm_vlan_id}  Set Variable   295

    ${oam_spare_ip}   Set Variable     ${oe_server_deployment_info["oam_spare_ip"]}
    ${trace_spare_ip}  Set Variable   ${oe_server_deployment_info["tracing_spare_ip"]}
    ${f1_spare_ip}   Set Variable    ${oe_server_deployment_info["f1_spare_ip"]}

    #get fhm_spare_ip
    ${FHM_interface_info}      Get Interface Information For FHM-plane
    ${fhm_net_mask}   Set Variable   ${FHM_interface_info["mask"]}
    ${vdu_fhm_ip}  Set Variable      ${FHM_interface_info["ip"]}
    ${broadcast}   Evaluate    str(IPy.IP('${vdu_fhm_ip}').make_net('${fhm_net_mask}').broadcast())   modules=IPy
    ${fhm_spare_ip}  increase ip   ${broadcast}   -1

    ${fhm_device_name}  Set Variable   testvlan${fhm_vlan_id}
    ${fhm_net_mask_len}   Evaluate    str(IPy.IP('${VDU_FHM_IP}').make_net('${fhm_net_mask}').prefixlen())   modules=IPy

    Add Device at DoS Tool Server  tool_ip=${VDU_DOS_TOOL_SERVER}  interface=${DOS_INTERFACE_VDU}
         ...   device_name=${oe_server_deployment_info["oam_link_oe"]}
         ...   vlan_id=${oam_vlan_id}  ip=${oam_spare_ip}  mask_len=${oe_server_deployment_info["oamnetmask"]}

    Add Device at DoS Tool Server  tool_ip=${VDU_DOS_TOOL_SERVER}  interface=${DOS_INTERFACE_VDU}
         ...   device_name=${oe_server_deployment_info["trace_link_oe"]}
         ...   vlan_id=${trace_vlan_id}  ip=${trace_spare_ip}  mask_len=${oe_server_deployment_info["tracingnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VDU}
         ...   device_name=${oe_server_deployment_info["f1_link_oe"]}
         ...   vlan_id=${f1_vlan_id}  ip=${f1_spare_ip}  mask_len=${oe_server_deployment_info["f1netmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VDU}
         ...   device_name=${fhm_device_name}
         ...   vlan_id=${fhm_vlan_id}  ip=${fhm_spare_ip}  mask_len=${fhm_net_mask_len}


Add All VCU Device At DoS Server NSA
    ${oe_server_deployment_info}   Get OE Server Deployment Information VCU

    ${oam_vlan_id_vcu}    Set Variable  ${oe_server_deployment_info["oam_vlan_id"]}
    ${f1c_vlan_id_vcu}    Set Variable   ${oe_server_deployment_info["f1c_vlan_id"]}
    ${f1u_vlan_id_vcu}     Set Variable  ${oe_server_deployment_info["f1u_vlan_id"]}
    ${trace_vlan_id_vcu}   Set Variable    ${oe_server_deployment_info["trace_vlan"]}
    ${x2c_vlan_id_vcu}    Set Variable    ${oe_server_deployment_info["x2c_vlan_id"]}
    ${x2u_vlan_id_vcu}    Set Variable    ${oe_server_deployment_info["x2u_vlan_id"]}
    ${s1u_vlan_id_vcu}    Set Variable    ${oe_server_deployment_info["s1u_vlan_id"]}

     ${oam_spare_ip_vcu}    Set Variable   ${oe_server_deployment_info["oam_spare_ip"]}
     ${f1c_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["f1c_spare_ip"]}
     ${f1u_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["f1u_spare_ip"]}
     ${trace_spare_ip_vcu}  Set Variable   ${oe_server_deployment_info["tracing_spare_ip"]}
     ${x2c_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["x2c_spare_ip"]}
     ${x2u_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["x2u_spare_ip"]}
     ${s1u_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["s1u_spare_ip"]}
    
    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["oam_link_oe"]}
         ...   vlan_id=${oam_vlan_id_vcu}  ip=${oam_spare_ip_vcu}  mask_len=${oe_server_deployment_info["oamnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["f1c_link_oe"]}
         ...   vlan_id=${f1c_vlan_id_vcu}  ip=${f1c_spare_ip_vcu}  mask_len=${oe_server_deployment_info["f1cnetmask"]}

    Run Keyword If  ${f1c_vlan_id_vcu}!=${f1u_vlan_id_vcu}
        ...   Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
        ...   device_name=${oe_server_deployment_info["f1u_link_oe"]}
        ...   vlan_id=${f1u_vlan_id_vcu}  ip=${f1u_spare_ip_vcu}  mask_len=${oe_server_deployment_info["f1unetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["trace_link_oe"]}
         ...   vlan_id=${trace_vlan_id_vcu}  ip=${trace_spare_ip_vcu}  mask_len=${oe_server_deployment_info["tracingnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["x2c_link_oe"]}
         ...   vlan_id=${x2c_vlan_id_vcu}  ip=${x2c_spare_ip_vcu}  mask_len=${oe_server_deployment_info["x2cnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["x2u_link_oe"]}
         ...   vlan_id=${x2u_vlan_id_vcu}  ip=${x2u_spare_ip_vcu}  mask_len=${oe_server_deployment_info["x2unetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}  interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["s1u_link_oe"]}
         ...   vlan_id=${s1u_vlan_id_vcu}  ip=${s1u_spare_ip_vcu}  mask_len=${oe_server_deployment_info["s1unetmask"]}


Add All VCU Device At DoS Server SA
    ${oe_server_deployment_info}   Get OE Server Deployment Information VCU
    ${oam_vlan_id_vcu}    Set Variable  ${oe_server_deployment_info["oam_vlan_id"]}
    ${f1c_vlan_id_vcu}    Set Variable    ${oe_server_deployment_info["f1c_vlan_id"]}
    ${f1u_vlan_id_vcu}     Set Variable  ${oe_server_deployment_info["f1u_vlan_id"]}
    ${trace_vlan_id_vcu}    Set Variable    ${oe_server_deployment_info["trace_vlan"]}
    ${ngc_vlan_id_vcu}     Set Variable   ${oe_server_deployment_info["ngc_vlan_id"]}
    ${ngu_vlan_id_vcu}      Set Variable  ${oe_server_deployment_info["ngu_vlan_id"]}
    ${xnc_vlan_id_vcu}     Set Variable   ${oe_server_deployment_info["xnc_vlan_id"]}
    ${xnu_vlan_id_vcu}      Set Variable  ${oe_server_deployment_info["xnu_vlan_id"]}

     ${oam_spare_ip_vcu}    Set Variable    ${oe_server_deployment_info["oam_spare_ip"]}
     ${f1c_spare_ip_vcu}    Set Variable   ${oe_server_deployment_info["f1c_spare_ip"]}
     ${f1u_spare_ip_vcu}    Set Variable   ${oe_server_deployment_info["f1u_spare_ip"]}
     ${trace_spare_ip_vcu}  Set Variable   ${oe_server_deployment_info["tracing_spare_ip"]}
     ${ngc_spare_ip_vcu}    Set Variable   ${oe_server_deployment_info["ngc_spare_ip"]}
     ${ngu_spare_ip_vcu}   Set Variable   ${oe_server_deployment_info["ngu_spare_ip"]}
     ${xnc_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["xnc_spare_ip"]}
     ${xnu_spare_ip_vcu}    Set Variable  ${oe_server_deployment_info["xnu_spare_ip"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["oam_link_oe"]}
         ...   vlan_id=${oam_vlan_id_vcu}  ip=${oam_spare_ip_vcu}  mask_len=${oe_server_deployment_info["oamnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["f1c_link_oe"]}
         ...   vlan_id=${f1c_vlan_id_vcu}  ip=${f1c_spare_ip_vcu}  mask_len=${oe_server_deployment_info["f1cnetmask"]}

    Run Keyword If  ${f1c_vlan_id_vcu}!=${f1u_vlan_id_vcu}
        ...   Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
        ...   device_name=${oe_server_deployment_info["f1u_link_oe"]}
        ...   vlan_id=${f1u_vlan_id_vcu}  ip=${f1u_spare_ip_vcu}  mask_len=${oe_server_deployment_info["f1unetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["trace_link_oe"]}
         ...   vlan_id=${trace_vlan_id_vcu}  ip=${trace_spare_ip_vcu}  mask_len=${oe_server_deployment_info["tracingnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["ngc_link_oe"]}
         ...   vlan_id=${ngc_vlan_id_vcu}  ip=${ngc_spare_ip_vcu}  mask_len=${oe_server_deployment_info["ngcnetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}   interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["ngu_link_oe"]}
         ...   vlan_id=${ngu_vlan_id_vcu}  ip=${ngu_spare_ip_vcu}  mask_len=${oe_server_deployment_info["ngunetmask"]}

    Add Device at DoS Tool Server   tool_ip=${VDU_DOS_TOOL_SERVER}  interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["xnc_link_oe"]}
         ...   vlan_id=${xnc_vlan_id_vcu}  ip=${xnc_spare_ip_vcu}  mask_len=${oe_server_deployment_info["xncnetmask"]}

    Add Device at DoS Tool Server    tool_ip=${VDU_DOS_TOOL_SERVER}  interface=${DOS_INTERFACE_VCU}
         ...   device_name=${oe_server_deployment_info["xnu_link_oe"]}
         ...   vlan_id=${xnu_vlan_id_vcu}  ip=${xnu_spare_ip_vcu}  mask_len=${oe_server_deployment_info["xnunetmask"]}
