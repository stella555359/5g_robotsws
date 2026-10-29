*** Settings ***
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com
...              Adb, AT common keywords for UE
...              iperf keywords
...              and ta_ue_plugin_android with Qualcomm


*** Variables ***
${IP_EXP_STRING}    ((25[0-5]\\.|2[0-5]\\d\\.|1\\d+\\.|[1-9]\\d?\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d))
${AT_RETURN_IP_EXP_STRING}    ,"?${IP_EXP_STRING}("|$|,)
# ${AT_RETURN_IMS_EXP_STRING}    CGDCONT: \\d+\\,\\"(?:IP|IPV4|IPV4V6)\\"\\,"ims"
${AT_RETURN_IP_INDEX_EXP_STRING}    CGPADDR: \\d+\\,
@{Qualcomm_END_Point}    720    2460
&{Qualcomm_Point}    END_Call=@{Qualcomm_END_Point}
${Current_UE}    ${0}
${FLAG_USE_UE_PROXY}    ${False}
${FLAG_USE_UE_MODULE}    ${False}
*** Keywords ***
AT.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${reboot_ue}=${False}    ${index_of_yaml}=${0}
    ...    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for AT
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | reboot_ue | contol ue reboot by this parameter  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Prepare UE | ue_index=${0} | reboot_ue=${False} |
    ...

    _Prepare Variables    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}    index=${index_of_yaml}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    Wait Until Keyword Succeeds    3x    10s    csn.connect_to    ${cpc_ip}    ${cpc_username}
    ...    ${cpc_password}
    ...    timeout=120s
    ...    alias=cpc_${ue_index}
    Run Keyword If    '${ue_index}'=='${0}' and '${index_of_yaml}' != '${0}'
    ...    Set Test Variable    ${current_ue_index}    ${index_of_yaml}
    ...    ELSE    Set Test Variable    ${current_ue_index}    ${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    AT.Reboot UE    connection=cpc_${ue_index}

AT.__Check Return Value
    [Arguments]    ${ret_string_list}
    [Documentation]    This kw is used to check at return string is ok
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ${status}    Set Variable    ${False}
    FOR    ${ret}    IN    @{ret_string_list}
        ${status}    Set Variable If    '${ret}'=='OK'    ${True}
        Exit For Loop If    ${status}
    END
    Should Be True    ${status}

AT.__Get All IP
    [Arguments]    ${ret_string_list}    ${ims_index}=${0}
    [Documentation]    This kw is used to get all ue ip from AT command
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    FOR    ${ret}    IN    @{ret_string_list}
        ${matches}    Get Regexp Matches    ${ret}    ${AT_RETURN_IP_EXP_STRING}
        ${matche_index}    Get Regexp Matches    ${ret}    ${AT_RETURN_IP_INDEX_EXP_STRING}
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${matches}
        ${index_status}    Run Keyword And Return Status    Should Not Be Empty    ${matche_index}
        Run Keyword If    ${status}    Log To Console     Get UE IP ${matches}[0]
        ${ue_ip}    Run Keyword If    ${status}    Get Regexp Matches    ${matches}[0]    ${IP_EXP_STRING}
        ${index}    Run Keyword If    ${index_status}    Get Regexp Matches    ${matche_index}[0]    \\d+
        ${index}=    Run Keyword If    ${index}
        ...    Set Variable    ${index}[0]
        ...    ELSE    Set Variable    ${0}
        Continue For Loop If    "${index}"=="${ims_index}"
        Return From Keyword if    ${status}    ${ue_ip}[0]
    END
    Return From Keyword if    ${None}

AT.UE Attach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to attach UE for inseego.
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.UE Attach | ue_index=${0} |
    ...
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=detach    ue_index=${ue_index}
    Sleep    5s
    AT Operation    operation=attach    ue_index=${ue_index}

AT.UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to attach UE for inseego.
    ...    Author: winnie he
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.UE Detach | ue_index=${0} |
    ...
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=detach    ue_index=${ue_index}

AT.End Call
    [Arguments]    ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=stop_call    ue_index=${ue_index}

AT.Voice Call
    [Arguments]    ${ue_index}=${0}    ${number}=10086
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=start_call    ue_index=${ue_index}    number=${number}

AT.UE Emergency Call
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to UE Emergency Call
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.UE Emergency Call | ue_index=${0} |
    ...
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}    command=ATD911;

AT.Get UE IP
    [Arguments]    ${ue_index}=${0}    ${use_module}=${FLAG_USE_UE_MODULE}    &{kwargs}
    [Documentation]    This kw is used to get UE IP
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Get UE IP | ue_index=${0} |
    ...
    # Log To Console    ${iperf_path}
    Log To Console    ${use_module}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    ${ue_ip}    AT Operation    operation=get    item=ueip    ue_index=${ue_index}
    [return]    ${ue_ip}

AT.PPPOE Call
    [Arguments]    ${ue_index}=${0}    ${use_module}=${FLAG_USE_UE_MODULE}   &{kwargs}
    [Documentation]    This kw is used to make pppoe call
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.PPPOE Call | ue_index=${0} |
    ...
    Log To Console    ${use_module}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}    command=AT$QCRMCALL=1,1

AT.Reboot UE
    [Arguments]    ${ue_index}=${0}    ${wait_reboot_time}=3 min    ${use_module}=${FLAG_USE_UE_MODULE}
    ...    &{kwargs}
    [Documentation]    This kw is used to make pppoe call
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.PPPOE Call | ue_index=${0} |
    ...
    Log To Console    ${use_module}
    Log To Console    ${wait_reboot_time}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=reboot    ue_index=${ue_index}

AT.Get IPV4 APN
    [Arguments]    ${ue_index}=${0}    ${pdu}=IP
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    ${apn}    AT Operation    operation=get    item=apn    ue_index=${ue_index}    pdp_type=${pdu}
    [Return]    ${apn}

AT.Set IPV4 APN
    [Arguments]    ${cid}    ${pdp_type}    ${apn_str}       ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+CGDCONT=${cid},\\"${pdp_type}\\",\\"${apn_str}\\"

AT.Switch To SA Mode
    [Arguments]    ${ue_index}=${0}
    _Prepare Variables Check    ${ue_index}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    ${i}    Get Index From List    ${capabilities}    x65
    Run Keyword If    ${i}==${-1}
    ...    AT.x55.Switch To SA Mode
    ...    ELSE
    ...    AT.x65.Switch To SA Mode

AT.x65.Switch To SA Mode
    [Arguments]    ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+QNWPREFCFG="mode_pref",NR5G

AT.x55.Switch To SA Mode
    [Arguments]    ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+GTSET="5GSACTR",1
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+GTACT=14

AT.Switch To NSA Mode
    [Arguments]    ${ue_index}=${0}
    _Prepare Variables Check    ${ue_index}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    ${i}    Get Index From List    ${capabilities}    x65
    Run Keyword If    ${i}==${-1}
    ...    AT.x55.Switch To NSA Mode
    ...    ELSE
    ...    AT.x65.Switch To NSA Mode

AT.x65.Switch To NSA Mode
    [Arguments]    ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    ${ret}    ute_ue.Send At Cmd To Ue    UE_${ue_index}
    ...    at_cmd=AT+QNWPREFCFG="mode_pref",NR5G
    AT.__Check Return Value    ${ret}

AT.x55.Switch To NSA Mode
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+GTSET="5GSACTR",0
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=AT+GTACT=17

AT.Lock Frequency
    [Arguments]    ${lock_parameter}    ${ue_index}=${0}
    ${ue_index}    Run Keyword If   '${ue_index}'=='${0}' and '${current_ue_index}'!='${0}'
    ...    Set Variable    ${current_ue_index}
    ...    ELSE
    ...    Set Variable    ${ue_index}
    AT Operation    operation=exec_at_command    ue_index=${ue_index}
    ...    command=at+gtcelllock=${lock_parameter}

Base.__Get Iperf Command
    [Arguments]    ${concord_type}    ${ue_ip}=${None}    ${server_ip}=${None}    ${iperf_path}=iperf
    ...    ${value}=1500M    ${time}=999    ${tput_port}=50001
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='UDP_DL_client'
    ...    ${iperf_path} -c ${ue_ip} -t ${time} -u -b ${value} -p ${tput_port} -i 1 -l 1024 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='UDP_UL_server'
    ...    ${iperf_path} -s -u -p ${tput_port} -i 1 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='UDP_UL_client'
    ...    ${iperf_path} -c ${server_ip} -B ${ue_ip} -t ${time} -u -b ${value} -p ${tput_port} -i 1 -l 1024 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='TCP_DL_server'
    ...    ${iperf_path} -s -B ${ue_ip} -p ${tput_port} -i 1 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='TCP_DL_client'
    ...    ${iperf_path} -c ${ue_ip} -P 10 -i 1 -p ${tput_port} -w 2000k -M ${value} -t ${time} -l 1024 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='TCP_UL_server'
    ...    ${iperf_path} -s -p ${tput_port} -i 1 &
    ${iperf_cmd}    Return From Keyword IF
    ...    '${concord_type}'=='TCP_UL_client'
    ...    ${iperf_path} -c ${server_ip} -B ${ue_ip} -t ${time} -b ${value} -p ${tput_port} -i 1 -l 1024 &

Base.__Stop Traffic
    [Arguments]    ${ue_index}=${0}
    ...    ${tput_type}=DL
    ...    ${concord_type}=UDP
    ...    ${client_connection}=cpc_${ue_index}
    ...    ${server_connection}=VM
    ...    ${iperf_port}=50001
    ...    ${serial}=${None}
    ${kill_cmd}    Set Variable    ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9
    csn.execute    command=${kill_cmd}
    ...    connection=${client_connection}
    Run Keyword If    "${serial}"!="${None}"    csn.execute    command=adb -s ${serial} shell ${kill_cmd}
    ...    connection=${client_connection}
    Run Keyword If    '${concord_type}_${tput_type}'!="UDP_DL"
    ...     csn.execute    command=${kill_cmd}
    ...    connection=${server_connection}

# =========================ADB=============================
_Prepare Variables Check
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Prepare UE for AT
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | reboot_ue | contol ue reboot by this parameter  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Prepare UE | ue_index=${0} | reboot_ue=${False} |
    ...
    Run Keyword If    ${ue_index}!=${Current_UE}
    ...    _Prepare Variables    ue_index=${ue_index}
    Set Suite Variable    ${Current_UE}    ${ue_index}

ADB.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${reboot_ue}=${False}    ${index_of_yaml}=${0}
    [Documentation]    This kw is used to Prepare UE for ADB
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | reboot_ue | contol ue reboot by this parameter  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.Prepare UE | ue_index=${0} | reboot_ue=${False} |
    ...
    _Prepare Variables    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}    index=${index_of_yaml}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    csn.connect_to    ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    Run Keyword If    '${ue_index}'=='${0}' and '${index_of_yaml}' != '${0}'
    ...    Set Test Variable    ${current_ue_index}    ${index_of_yaml}
    ...    ELSE    Set Test Variable    ${current_ue_index}    ${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    ADB.Reboot UE
    ...    ue_index=${ue_index}
    # wait until keyword succeeds    3x    1 min     ute_ue.require_ue    ue_alias=UE_${ue_index}
    # ...    capabilities=${capabilities[0]}

ADB._UE Available
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Check Ue is available by ADB
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB._UE Available  | ue_index=${0} |
    ...
    wait until keyword succeeds    3min    2s
    ...    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial}

ADB._UE Status Check
    [Arguments]    ${ue_index}=${0}
    ...    ${function}=persist.radio.airplane_mode_on    ${except_value}=0
    [Documentation]    This kw is used to Check Ue Statul by ADB command getprop
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | function | yes | function use to check, like airplane mode |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB._UE Status Check   | ue_index=${0} |
    ...
    ${check_cmd}    Set Variable
    ...   adb -s ${serial} shell getprop ${function}
    csn.send_command    command=${check_cmd}    connection=cpc_${ue_index}
    ${ret}    csn.read_output    connection=cpc_${ue_index}
    ${return_val}    Get Regexp Matches    ${ret}    \\d+
    Should Be Equal     ${return_val}[0]    ${except_value}

ADB._airplane operation
    [Arguments]    ${ue_index}=${0}   ${enable}=${True}    ${need_check}=${True}
    [Documentation]    This kw is used to open airplane or close airplane
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | enable | yes | enable airplane(True) or disable airplane |
    ...    | need_check | yes | if need to check the return value |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB._airplane operation   | ue_index=${0} | enable=${True} |
    ...
    ADB._UE Available    ${ue_index}
    # to get root permission
    ${root_cmd}    Set Variable
    ...    adb -s ${serial} root & adb -s ${serial} wait-for-device
    _Excute ADB Command On UE PC    command=${root_cmd}
    ...    connection=cpc_${ue_index}
    ...    timeout=3 min
    ADB._UE Available    ${ue_index}
    ${airplane_val}    Run Keyword If    ${enable}
    ...    Set Variable    1
    ...    ELSE
    ...    Set Variable    0
    ${attach_cmd}    Set Variable
    ...    adb -s ${serial} shell settings put global airplane_mode_on ${airplane_val}
    _Excute ADB Command On UE PC    command=${attach_cmd}    connection=cpc_${ue_index}
    ${attach_cmd}    Set Variable
    ...    adb -s ${serial} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state ${enable}
    _Excute ADB Command On UE PC    command=${attach_cmd}    connection=cpc_${ue_index}
    Return From Keyword If    '${need_check}'=='${False}'
    wait until keyword succeeds    2min    2s
    ...    ADB._UE Status Check    ue_index=${ue_index}    except_value=${airplane_val}

ADB.UE Attach
    [Arguments]    ${ue_index}=${0}    ${need_check}=${True}    &{kwargs}
    # to get root permission
    [Documentation]    This kw is used to attach UE for adb ue, need root permission
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | need_check | yes | if need the check the command succeed or fail |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.UE Attach | ue_index=${0} |
    ...
    _Prepare Variables Check    ${ue_index}
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Attach Ue    ue_alias=UE_${ue_index}
    ...    ELSE    Run Keywords
    ...    ADB._airplane operation    ue_index=${ue_index}    enable=${True}    need_check=${need_check}
    ...    AND
    ...    ADB._airplane operation    ue_index=${ue_index}    enable=${False}    need_check=${need_check}

ADB.UE Detach
    [Arguments]    ${ue_index}=${0}    ${need_check}=${True}    &{kwargs}
    [Documentation]    This kw is used to attach UE for adb ue, need root permission
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | need_check | yes | if need the check the command succeed or fail |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.UE Detach | ue_index=${0} |
    _Prepare Variables Check    ${ue_index}
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Detach Ue    ue_alias=UE_${ue_index}
    ...    ELSE
    ...    ADB._airplane operation    ue_index=${ue_index}    enable=${True}    need_check=${need_check}

ADB.Restart ADB
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to ADB.Restart ADB
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.Restart ADB | ue_index=${0} |
    ...
    ${adb_kill_cmd}    Set Variable    adb kill-server
    _Excute ADB Command On UE PC    command=${adb_kill_cmd}    connection=cpc_${ue_index}
    ${adb_start_cmd}    Set Variable    adb start-server
    _Excute ADB Command On UE PC    command=${adb_start_cmd}    connection=cpc_${ue_index}

ADB.Make A Call
    [Arguments]    ${number}    ${ue_index}=${0}    ${duration}=60s    &{kwargs}
    [Documentation]    This kw is used to Make A Call by ADB.
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | number | yes | the number need to call
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.Make A Call | 6688 | 0 |
    ...
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Start Voice Call    vc_alias=VoiceCall    ue_alias=UE_${ue_index}
    ...    to=${number}    duration=${duration}
    ...    ELSE
    ...    ADB.Legency.Make A Call    number=${number}    ue_index=${ue_index}    kwargs=${kwargs}

ADB.Legency.Make A Call
    [Arguments]    ${number}    ${ue_index}=${0}    &{kwargs}
    _Prepare Variables Check    ${ue_index}
    ${call_cmd}    Set Variable    adb -s ${serial} shell am start -a android.intent.action.CALL -d tel:${number}
    _Excute ADB Command On UE PC    command=${call_cmd}    connection=cpc_${ue_index}


ADB.Legency.End Call
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    _Prepare Variables Check    ${ue_index}
    ${call_cmd}    Set Variable    adb -s ${serial} shell input keyevent 6
    _Excute ADB Command On UE PC    command=${call_cmd}    connection=cpc_${ue_index}

ADB.End Call
    [Arguments]    ${ue_index}=${0}    ${number}=${6688}
    Log To Console    ${number}
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Stop Voice Call    VoiceCall
    ...    ELSE
    ...    ADB.Legency.End Call
    ...    ue_index=${ue_index}

ADB.Make Emergency Call
    [Arguments]    ${number}    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to Make Emergency Call by ADB.
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | number | Make Emergency Call number like 911 |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB.Make Emergency Call | number=911 | ue_index=0 |
    _Prepare Variables Check    ${ue_index}
    ${call_cmd}    Set Variable    adb -s ${serial} shell am start -a android.intent.action.CALL_PRIVILEGED -d tel:${number}
    _Excute ADB Command On UE PC    command=${call_cmd}    connection=cpc_${ue_index}

ADB.Click By Point
    [Arguments]    ${ue_index}=${0}    ${point_x}=${None}    ${point_y}=${None}    &{kwargs}
    [Documentation]    This kw is used to Click UE By Point by ute
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | point_x | yes | the x point need to click |
    ...    | point_y | yes | the y point need to click |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Click By Point | ue_index=${0} |
    ...
    _Prepare Variables Check    ${ue_index}
    ${call_cmd}    Set Variable    adb -s ${serial} shell input tap ${point_x} ${point_y}
    _Excute ADB Command On UE PC    command=${call_cmd}    connection=cpc_${ue_index}

ADB.Reboot UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to reboot UE by ute
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Reboot UE | ue_index=${0} |
    ...
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Reboot UE    UE_${ue_index}
    ...    ELSE
    ...    ADB.Legency.Reboot UE    ue_index=${ue_index}
    ADB._UE Available    ue_index=${ue_index}

ADB.Legency.Reboot UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to reboot UE by ute
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Reboot UE | ue_index=${0} |
    ...
    _Prepare Variables Check    ${ue_index}
    ${reboot_cmd}    Set Variable    adb -s ${serial} reboot
    _Excute ADB Command On UE PC    command=${reboot_cmd}    connection=cpc_${ue_index}
    ...    timeout=120
    ADB._UE Available    ue_index=${ue_index}

ADB.Teardown
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to teardown adb command, to close the ssh connection of ue pc
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Teardown | ue_index=${0} |
    ...
    csn.disconnect    connection=cpc_${ue_index}
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ADB.Teardown UE    ue_index=${ue_index}

ADB.Teardown All
    [Documentation]    Not Support UE PROXY
    ...    This kw is used to teardown adb command, to close the ssh connection of ue pc
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Teardown All |
    ...
    ${ue_number}    Get Length    ${tl.ues}
    FOR    ${ue_index}    IN RANGE    ${ue_number}
        Run Keyword And Ignore Error
        ...    ADB.Teardown    ue_index=${ue_index}
    END

ADB.Get UE IP
    [Documentation]    Not Support UE PROXY
    [Arguments]    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    _Prepare Variables Check    ${ue_index}
    ${command}     Set Variable
    # ...    adb -s ${serial} shell ip -f inet addr |grep inet |cut -d "/" -f 1 |tail -n -1 |head -1 |cut -d "t" -f 2 | sed "s/ //g"
    ...    adb -s ${serial} shell ip -f inet addr |grep inet |cut -d "/" -f 1 |tail -n -1 |cut -d "t" -f 2 | sed "s/ //g"
    csn.send_command    command=${command}
    ...                 connection=${connection}
    ${UE_IP}    csn.Read Output    connection=${connection}
    ${UE_IP}    Strip String    ${UE_IP}
    Set Suite Variable    ${UE_IP}    ${UE_IP}
    [Return]    ${UE_IP}

ADB.__Get Iperf Command
    [Arguments]    ${concord_type}    ${serial_number}=${serial}
    ...    ${ue_ip}=${None}    ${server_ip}=${None}    ${iperf_path}=iperf
    ...    ${value}=1500M    ${time}=999    ${tput_port}=50001
    ${cmd}    Base.__Get Iperf Command    concord_type=${concord_type}
    ...    ue_ip=${ue_ip}
    ...    value=${value}
    ...    time=${time}
    ...    tput_port=${tput_port}
    ...    server_ip=${server_ip}
    ...    iperf_path=${iperf_path}
    ${cmd}    Run Keyword If
    ...    "${concord_type}"=="UDP_UL_client" or "${concord_type}"=="TCP_UL_client" or "${concord_type}"=="TCP_DL_server"
    ...    Catenate    adb -s ${serial_number} shell    ${cmd}
    ...    ELSE
    ...    Set Variable    ${cmd}
    ${cmd}    Remove String Using Regexp    ${cmd}    -B ${IP_EXP_STRING}${SPACE}
    ${cmd}    Remove String Using Regexp    ${cmd}    -B ${SPACE}
    [Return]    ${cmd}

ADB.__Start Traffic By Iperf
    [Arguments]    ${ue_ip}=${None}    ${ue_index}=${0}
    ...    ${tput_type}=DL
    ...    ${concord_type}=TCP
    ...    ${client_connection}=cpc_${ue_index}
    ...    ${server_ip}=${cpc_ip}
    ...    ${server_connection}=VM
    ...    ${server_iperf_path}=iperf
    ...    ${client_iperf_path}=iperf
    ...    ${tput_value}=10M
    ...    ${tput_time}=120s
    ...    ${tput_port}=50001
    ${ue_ip}    Run Keyword If    "${ue_ip}"=="${None}"
    ...    ADB.Get UE IP
    ...    ELSE
    ...    Set Variable    ${ue_ip}
    ${iperf_cmd}    Run Keyword If    "${concord_type}_${tput_type}"=="UDP_DL"
    ...    ADB.__Get Iperf Command    concord_type=${concord_type}_${tput_type}_client
    ...    ue_ip=${ue_ip}
    ...    value=${tput_value}
    ...    time=${tput_time}
    ...    tput_port=${tput_port}
    ...    iperf_path=${client_iperf_path}
    Run Keyword If    "${concord_type}_${tput_type}"=="UDP_DL"
    ...    Run Keywords
    ...    csn.send_command    command=${iperf_cmd}    connection=${client_connection}
    ...    AND
    ...    Log to Console    Execute iperf command=${iperf_cmd}, connection=${client_connection}
    Return From Keyword If    "${concord_type}_${tput_type}"=="UDP_DL"
    ...    ${TRUE}
    Run Keyword If
    ...    "${concord_type}_${tput_type}"=="UDP_UL" or "${concord_type}_${tput_type}"=="TCP_UL"
    ...    csn.execute    command=adb -s ${serial} root    connection=${client_connection}
    ...    ELSE
    ...    csn.execute    command=adb -s ${serial} root    connection=${server_connection}
    ${iperf_cmd}    ADB.__Get Iperf Command    concord_type=${concord_type}_${tput_type}_server
    ...    ue_ip=${ue_ip}
    ...    tput_port=${tput_port}
    ...    iperf_path=${server_iperf_path}
    csn.send_command    command=${iperf_cmd}    connection=${server_connection}
    Log to Console    Execute iperf command=${iperf_cmd}, connection=${server_connection}
    ${iperf_cmd}    ADB.__Get Iperf Command    concord_type=${concord_type}_${tput_type}_client
    ...    ue_ip=${ue_ip}
    ...    value=${tput_value}
    ...    time=${tput_time}
    ...    tput_port=${tput_port}
    ...    server_ip=${server_ip}
    ...    iperf_path=${client_iperf_path}
    csn.send_command    command=${iperf_cmd}    connection=${client_connection}
    Log to Console    Execute iperf command=${iperf_cmd}, connection=${client_connection}
    ADB.__check iperf status    concord_type=${concord_type}_${tput_type}_client
    ...    connection=${client_connection}    tput_port=${tput_port}

ADB.__check iperf status
    [Arguments]    ${concord_type}    ${connection}    ${tput_port}
    ${check_iperf}    Run Keyword If
    ...    "${concord_type}"=="UDP_UL_client" or "${concord_type}"=="TCP_UL_client"
    ...    Set Variable    adb -s ${serial} shell ps -ef | grep iperf |grep ${tput_port} |grep -v grep |awk "{print $2}"
    ...    ELSE
    ...    Set Variable    ps -ef | grep iperf |grep ${tput_port} |grep -v grep |awk "{print $2}"
    csn.send_command    command=${check_iperf}
    ...    connection=${connection}    timeout=60
    ${output}    csn.read_output    size=1000    connection=${connection}
    # ${iperf_pid}    evaluate    ${output.strip()}
    # should be true    ${iperf_pid} > ${0}

ADB.Start Traffic
    [Arguments]    ${ue_ip}=${None}    ${ue_index}=${0}
    ...    ${tput_type}=DL
    ...    ${concord_type}=UDP
    ...    ${client_connection}=cpc_${ue_index}
    ...    ${server_ip}=${cpc_ip}
    ...    ${server_connection}=VM
    ...    ${server_iperf_path}=iperf
    ...    ${client_iperf_path}=iperf
    ...    ${iperf_path}=iperf
    ...    ${tput_value}=50M
    ...    ${tput_time}=120s
    ...    ${tput_port}=50001
    [Documentation]    Not Support UE PROXY
    ...    This kw is used to start dl traffic by iperf for udp or tcp
    ...    UDP UL:
    ...        step1 :pppoe call by AT in ue pc
    ...        step2 :start traffic server in the server connection, default is VM
    ...        step3 :start traffic client in the client connection, default is uepc
    ...    TCP UL:
    ...        step1 :pppoe call by AT in ue pc
    ...        step2 :start traffic server in the server connection, default is VM
    ...        step3 :start traffic client in the client connection, default is uepc
    ...    TCP DL:
    ...        step1 :pppoe call by AT in ue pc
    ...        step2 :start traffic server in the server connection, default is uepc
    ...        step3 :start traffic client in the client connection, default is VM
    ...    UDP DL:
    ...        step3 :start traffic client in the client connection, default is VM
    ...    Author: He Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_ip | No | the up ip of the ue need to do traffic
    ...    | ue_index | No | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | concord_type | No | UDP or TCP
    ...    | client_connection | No | iperf client run connection
    ...    | server_connection | No | iperf server run connection
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT.Start DL Traffic | ue_index=${0} | concord_type=TCP |
    Log To Console    ${iperf_path}
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Start Data Transfer
    ...    dt_name=DT_${tput_type}   ue_alias=UE_${ue_index}
    ...    direction=${tput_type}   duration=${tput_time}
    ...    throughput=${tput_value}   protocol=${concord_type}   packet_size=1024
    ...    ELSE
    ...    ADB.__Start Traffic By Iperf    ue_ip=${ue_ip}
    ...    ue_index=${ue_index}
    ...    tput_type=${tput_type}
    ...    concord_type=${concord_type}
    ...    server_ip=${server_ip}
    ...    client_connection=${client_connection}
    ...    server_connection=${server_connection}
    ...    server_iperf_path=${server_iperf_path}
    ...    client_iperf_path=${client_iperf_path}
    ...    tput_value=${tput_value}
    ...    tput_time=${tput_time}
    ...    tput_port=${tput_port}

ADB.Stop Traffic
    [Arguments]    ${ue_index}=${0}
    ...    ${tput_type}=DL
    ...    ${concord_type}=UDP
    ...    ${client_connection}=cpc_${ue_index}
    ...    ${server_connection}=VM
    ...    ${iperf_port}=50001
    Run Keyword If    ${FLAG_USE_UE_PROXY}
    ...    ute_ue.Stop Data Transfer    dt_name=UE_${ue_index}
    ...    ELSE
    ...    Base.__Stop Traffic    ue_index=${ue_index}
    ...    tput_type=${tput_type}
    ...    concord_type=${concord_type}
    ...    client_connection=${client_connection}
    ...    server_connection=${server_connection}
    ...    iperf_port=${iperf_port}
    ...    serial=${serial}

ADB.__Change Text Commands
    [Arguments]    ${apn}    ${delete_loop_times}=${25}
    Log To Console    ${delete_loop_times}
    ${change_cmd}    Create List
    FOR    ${i}    IN RANGE    ${30}
        Append To List    ${change_cmd}    adb -s ${serial} shell input keyevent 67
    END
    Append To List    ${change_cmd}    adb -s ${serial} shell input text ${apn}
    [Return]    ${change_cmd}

Qualcomm.Change APN
    [Arguments]    ${apn}    ${ue_index}=${0}    ${connection}=cpc_${ue_index}
    _Prepare Variables Check    ${ue_index}
    ${cmd_list}    Create List
    ...    adb root
    # press unlight screen
    ...    adb -s ${serial} shell input keyevent 26
    # press light screen
    ...    adb -s ${serial} shell input keyevent 82
    # unlock
    ...    adb -s ${serial} shell input swipe 500 2050 500 800
    # press home button
    ...    adb -s ${serial} shell input keyevent 3
    # click setting button
    ...    adb -s ${serial} shell input tap 722 672
    # click net setting button
    ...    adb -s ${serial} shell input tap 629 1088
    # click mobile net button
    ...    adb -s ${serial} shell input tap 708 1136
    # swipe to APN Set adb shell input swipe
    ...    adb -s ${serial} shell input swipe 1329 2699 274 460
    # click set apn
    ...    adb -s ${serial} shell input tap 611 2353
    # click existed apn
    ...    adb -s ${serial} shell input tap 620 867
    # click change apn name
    ...    adb -s ${serial} shell input tap 513 831
    ${change_txt_cmd}    ADB.__Change Text Commands    apn=${apn}
    ${cmd_list}    Combine Lists    ${cmd_list}    ${change_txt_cmd}
    Append To List    ${cmd_list}
    # click confirm
    ...    adb -s ${serial} shell input tap 1200 1039
    # click change apn
    ...    adb -s ${serial} shell input tap 381 1163
    ${cmd_list}    Combine Lists    ${cmd_list}    ${change_txt_cmd}
    Append To List    ${cmd_list}
    # click confirm
    ...    adb -s ${serial} shell input tap 1200 1039
    # click three dot
    ...    adb -s ${serial} shell input tap 1355 190
    # click save
    ...    adb -s ${serial} shell input tap 1027 393
    # click home button
    ...    adb -s ${serial} shell input keyevent 3
    FOR    ${cmd}    IN    @{cmd_list}
        Log To Console    ${cmd}
        csn.send_command    command=${cmd}
        ...    connection=${connection}    timeout=60
        sleep    4s
    END

Qualcomm.Set APN By Uiauto
    [Arguments]    ${apn}    ${ue_index}=${0}    ${ue_uiauto_path}=uiauto.py
    ...    ${connection}=cpc_${ue_index}
    _Prepare Variables Check    ${ue_index}
    csn.execute    python ${ue_uiauto_path} -s ${serial} set apn ${apn}
    ...    connection=${connection}

Qualcomm.Get APN By Uiauto
    [Arguments]    ${ue_index}=${0}    ${ue_uiauto_path}=uiauto.py
    ...    ${connection}=cpc_${ue_index}
    _Prepare Variables Check    ${ue_index}
    ${ret}    csn.execute    python ${ue_uiauto_path} -s ${serial} get apn test
    ...    connection=${connection}
    Log To Console    Current APN is ${ret}
    [Return]    ${ret}

Qualcomm.Start UL Traffic By Uiauto
    [Arguments]    ${ue_index}=${0}    ${tput_value}=50
    ...    ${tput_time}=60s    ${tput_port}=50002
    ...    ${server_ip}=${cpc_ip}
    ...    ${ue_uiauto_path}=uiauto.py
    ...    ${connection}=cpc_${ue_index}
    csn.force_reconnect
    ...    connection=${connection}
    _Prepare Variables Check    ${ue_index}
    ${ue_ip}    ADB.Get UE IP    ${ue_index}    ${connection}
    ${adb_cmd}    ADB.__Get Iperf Command
    ...    ue_ip=${ue_ip}
    ...    concord_type=UDP_UL_client
    ...    value=${tput_value}
    ...    time=${tput_time}
    ...    server_ip=${server_ip}
    ...    tput_port=${tput_port}
    ${adb_cmd}    Replace String    ${adb_cmd}    &    ${EMPTY}
    ${cmd_split}    Split String    ${adb_cmd}    iperf
    csn.execute    python ${ue_uiauto_path} -s ${serial} set iperf "${cmd_split}[-1]"
    ...    connection=${connection}

Qualcomm8350.Start UL Traffic By MagicIperf
    [Arguments]    ${ue_index}=${0}    ${tput_value}=50
    ...    ${tput_time}=60s    ${tput_port}=50002
    ...    ${server_ip}=${cpc_ip}
    ...    ${iperf_path}=iperf
    ...    ${connection}=cpc_${ue_index}
    Log To Console    ${iperf_path}
    csn.force_reconnect
    ...    connection=${connection}
    _Prepare Variables Check    ${ue_index}
    ${ue_ip}    ADB.Get UE IP    ${ue_index}    ${connection}
    ${adb_cmd}    ADB.__Get Iperf Command
    ...    ue_ip=${ue_ip}
    ...    concord_type=UDP_UL_client
    ...    value=${tput_value}
    ...    time=${tput_time}
    ...    server_ip=${server_ip}
    ...    tput_port=${tput_port}
    ${cmd_split}    Split String    ${adb_cmd}    iperf
    ${cmd_list}    Create List
    # press unlight screen
    ...    adb -s ${serial} shell input keyevent 26
    # press light screen
    ...    adb -s ${serial} shell input keyevent 82
    ...    adb -s ${serial} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    ...    adb -s ${serial} shell input tap 830 623
    # ...    adb -s ${serial} shell input keyevent 123
    FOR    ${cmd}    IN    @{cmd_list}
        Log To Console    ${cmd}
        csn.send_command    command=${cmd}
        ...    connection=${connection}    timeout=60
        sleep    4s
    END
    Log To Console    delete char
    FOR    ${i}    IN RANGE    ${60}
        csn.send_command
        ...    command=adb -s ${serial} shell input keyevent 67
        ...    connection=${connection}
    END
    ${iperf_str}    Replace String    ${cmd_split}[-1]    &    ${EMPTY}
    ${iperf_char}    Split String To Characters    ${iperf_str}
    Log To Console    input ${iperf_str}
    FOR    ${c}    IN    @{iperf_char}
        Run Keyword If    '${c}'==' '
        ...    csn.send_command    command=adb -s ${serial} shell input keyevent KEYCODE_SPACE
        ...    connection=${connection}    timeout=60
        ...    ELSE
        ...    csn.send_command    command=adb -s ${serial} shell input text ${c}
        ...    connection=${connection}    timeout=60
        sleep    1s
    END
    Log To Console    start iperf
    csn.send_command    command=adb -s ${serial} shell input tap 586 264
    ...    connection=${connection}    timeout=60

Qualcomm8350.Stop UL Traffic By MagicIperf
    [Arguments]    ${ue_index}=${0}
    ...    ${connection}=cpc_${ue_index}
    csn.force_reconnect
    ...    connection=${connection}
    _Prepare Variables Check    ${ue_index}
    ${cmd_list}    Create List
    # press unlight screen
    ...    adb -s ${serial} shell input keyevent 26
    # press light screen
    ...    adb -s ${serial} shell input keyevent 82
    # unlock
    ...    adb -s ${serial} shell input swipe 500 2050 500 800
    # press home button
    ...    adb -s ${serial} shell input keyevent 3
    ...    adb shell -s ${serial} input tap 586 264
    FOR    ${cmd}    IN    @{cmd_list}
        Log To Console    ${cmd}
        csn.send_command    command=${cmd}
        ...    connection=${connection}    timeout=60
        sleep    4s
    END

Qualcomm.Stop UL Traffic By Uiauto
    [Arguments]    ${ue_index}=${0}
    ...    ${ue_uiauto_path}=uiauto.py
    ...    ${connection}=cpc_${ue_index}
    _Prepare Variables Check    ${ue_index}
    csn.execute    python ${ue_uiauto_path} -s ${serial} set iperf "stop"
    ...    connection=${connection}

ADB.Teardown UE
    [Arguments]    ${ue_index}
    ute_ue.stop_using_ue    UE_${ue_index}
