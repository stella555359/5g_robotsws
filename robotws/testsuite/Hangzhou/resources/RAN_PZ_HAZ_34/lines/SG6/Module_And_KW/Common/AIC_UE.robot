*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Lou Sudi;    Lv Feng
...    Email address: sudi.lou@nokia-sbell.com;    feng.1.lv@nokia-sbell.com;
...    Common KWs related to UE, and it supports devices such as: DX50, DX55,Huawei Meta30x,Xiao Mi,
...    Samsung S20,mifi, and ta_ue_plugin_android
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement

Library           taf.transport.ssh    WITH NAME    csn

*** Keywords ***
Get Iperf Info
    [Arguments]    ${ue_index}=${0}
    [Documentation]    this kw is used to get iperf info
    ${ue_config}    get_common_ue_config    ue_info=${tl.ues[${ue_index}]}    index=${ue_index}
    Set Suite Variable    ${IPERF_ADDRESS_CONFIG}    ${ue_config['iperf_address']}
    Set Suite Variable    ${IPERF_USER_CONFIG}    ${ue_config['iperf_user']}
    Set Suite Variable    ${IPERF_PASSWORD_CONFIG}    ${ue_config['iperf_password']}
    Set Suite Variable    ${IPERF_PORT_CONFIG}    ${ue_config['iperf_port']}

Prepare UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}
    ...            ${reset_sol}=none    ${detach_request}=${true}    ${ui_version}=default    ${reboot_ue}=${False}
    [Documentation]    This kw is used to Prepare UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...    | capatibility_index | The list index from ue.capabilities[], will use the index capability for reserve |
    ...    | reset_sol | for qctdx50 ue has three choose (none, pc_reset, pb_reset): |
    ...    | detach_request | for qctdx50 ue has the choose for ue with detach status contain in prepare progress. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | Prepare UE | ${ue0_type} | ue_index=${0} |
    ...
    Get Iperf Info    ${ue_index}
    ${output}    run keyword    ${ue_type}.Prepare Ue    ue_index=${ue_index}
    ...                                                  capatibility_index=${capatibility_index}
    ...                                                  ue_alias=${ue_alias}
    ...                                                  reset_sol=${reset_sol}
    ...                                                  detach_request=${detach_request}
    ...                                                  ui_version=${ui_version}
    ...                                                  reboot_ue=${reboot_ue}

UE Attach
    [Arguments]    ${ue_type}    ${attach_mode}=5G_NSA    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0
    ...            ${ue_alias}=UE_${ue_index}    ${verify_attach}=False
    [Documentation]    This kw is used to attach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Attach | ${ue0_type} | ue_index=${0} |
    ...
    ${output}    run keyword    ${ue_type}.UE Attach    ue_index=${ue_index}
    ...                                                 gnb_index=${gnb_index}
    ...                                                 ue_alias=${ue_alias}
    ...                                                 du_index=${du_index}
    ...                                                 attach_mode=${attach_mode}
    ...                                             verify_attach=${verify_attach}

UE Power On
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to UE Power On
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Power On | ${ue0_type} | ue_index=${0} |
    ...
    ${output}    run keyword    ${ue_type}.UE power on    ue_index=${ue_index}    ue_alias=${ue_alias}

Start traffic
    [Arguments]    ${ue_type}    ${direction}    ${throughput}
    ...            ${duration}=10    ${protocol}=udp    ${ue_index}=${0}
    ...            ${cap_index}=${0}    ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}    ${appserver}=APPserver
    ...            ${ul_option}=default     ${RemoteHost}=10.97.65.244    ${Port}=8018    ${Account}=ute
    ...            ${Password}=ute    ${RemoteFile}=/Download/10G
    ...            ${FileSize}=1024000
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | yes |  <str> store ue by ue_alias |
    ...    | direction | yes | The traffic direction, ul or dl |
    ...    | duration | yes | Duration of traffic |
    ...    | throughput | yes | Throughput of new data transfer |
    ...    | protocal | yes | Traffic protocal type. E.G udp/tcp |
    ...    | dt_index | yes | The new data transfer index alias |
    ...    | iperf_port | yes | port number used for traffic start via iperf |
    ...    | dt_name | yes | alias name for created data transfer |
    ...    | multidrb_QoS_dest | yes | <optional> default None |
    ...    | cap_index | yes | The list index from ue.capabilities[], will use the index capability for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} |
	...    | ...           | throughput=110M | duration=600 |
    ...
    ${direction}=    Convert To Lowercase    ${direction}
    ${output}    run keyword    AIC_UE.${ue_type}.Start traffic    direction=${direction}
    ...                                                            ue_index=${ue_index}
    ...                                                            dt_index=${dt_index}
    ...                                                            duration=${duration}
    ...                                                            throughput=${throughput}
    ...                                                            protocol=${protocol}
    ...                                                            iperf_port=${iperf_port}
    ...                                                            interval=${interval}
    ...                                                            buffer_size=${buffer_size}
    ...                                                            dt_name=${dt_name}
    ...                                                            ue_alias=${ue_alias}
    ...                                                            multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                                                            cap_index=${cap_index}
    ...                                                            appserver=${appserver}
    ...                                                            ul_option=${ul_option}
    ...                                                            RemoteHost=${RemoteHost}
    ...                                                            Port=${Port}
    ...                                                            Account=${Account}
    ...                                                            Password=${Password}
    ...                                                            RemoteFile=${RemoteFile}
    ...                                                            FileSize=${FileSize}

Stop traffic
    [Arguments]    ${ue_type}    ${direction}    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default    ${appserver}=APPserver
    [Documentation]    This kw is used for stop traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...    | direction | The traffic direction, ul or dl |
    ...    | dt_index | The new data transfer index alias |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | dt_name | alias name for created data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop traffic | ${ue0_type} | ue_index=${0} | direction=dl |
    ...
    ${direction}=    Convert To Lowercase    ${direction}
    ${output}    run keyword    AIC_UE.${ue_type}.Stop traffic    direction=${direction}
    ...                                                           ue_index=${ue_index}
    ...                                                           dt_index=${dt_index}
    ...                                                           dt_name=${dt_name}
    ...                                                           ue_alias=${ue_alias}
    ...                                                           iperf_port=${iperf_port}
    ...                                                           appserver=${appserver}

Start VONR Call
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${vc_alias}=VC_1    ${call_number}=004488
    ...            ${duration}=20s    ${capabilities}=huawei2
    [Documentation]    This kw is used for start VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | duration | Duration of traffic |
    ...    | vc_alias | store ue by ue_alias |
    ...    | call_number | You need to call which number |
    ...    | capabilities | Select which ue by capabilities |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start VONR Call | ue_index=${0} | vc_alias=VC_1 | call_number=004488 |
    ...    | ...             | duration=20s | capabilities=huawei2 |
    ...
    ${output}    run keyword    ${ue_type}.Start VONR Call    ue_index=${ue_index}
    ...                                                       vc_alias=${vc_alias}
    ...                                                       call_number=${call_number}
    ...                                                       duration=${duration}
    ...                                                       capabilities=${capabilities}


Stop VONR Call
    [Arguments]    ${ue_type}    ${vc_alias}=VC_1
    [Documentation]    This kw is used for stop VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vc_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop VONR Call | vc_alias=VC_1 |
    ...
    ${output}    run keyword    ${ue_type}.Stop VONR Call    vc_alias=${vc_alias}


UE Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to dettach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Detach | ${ue0_type} | ue_index=${0} |
    ...
    ${output}    run keyword    ${ue_type}.UE Detach    ue_index=${ue_index}
    ...                                                 ue_alias=${ue_alias}

UE Power Off
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to UE Power off
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Power Off | ${ue0_type} | ue_index=${0} |
    ...
    ${output}    run keyword    ${ue_type}.UE power off    ue_alias=${ue_alias}

Teardown UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to teardown UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Teardown UE | ${ue0_type} | ue_index=${0} |
    ...
    ${output}    run keyword    ${ue_type}.Teardown UE    ue_index=${ue_index}
    ...                                                   ue_alias=${ue_alias}

Get UE IP
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to get ue ip
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | UE ip address |
    ...
    ...    Example
    ...    | Get UE IP | ${ue0_type} | ue_index=${0} |
    ...
    ${UE_IP}    run keyword    ${ue_type}.Get UE IP address    ue_index=${ue_index}
    ...                                                   ue_alias=${ue_alias}
    [Return]    ${UE_IP}

Check VONR Call Status
    [Arguments]    ${vc_alias}=VC_1
    [Documentation]    This kw is used for check vonr call status
    ...    Author: Lou Sudi
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vc_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | ${vc_status} | Voice call status |
    ...
    ...    Example
    ...    | Retrieve VONR Call | vc_alias=VC_1 |
    ...
    ${output}    Run Keyword and Return Status    Retrieve Voice Call    vc_alias=${vc_alias}
    ${vc_status}    Set Variable If    ${output}==True    hold
    ...                                ${output}==False    unhold
    Log    Voice call with alias ${vc_alias} status: ${vc_status}
    [Return]    ${vc_status}

################################## Qualcomm common KW ##################################
Qualcomm.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${capatibility_index}=${0}    ${reset_sol}=none    ${detach_request}=${False}    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | capatibility_index | The list index from ue.capabilities[], will use the index capability for reserve |
    ...    | reset_sol | for qctdx50 ue has three choose (none, pc_reset, pb_reset): |
    ...    | detach_request | for qctdx50 ue has the choose for ue with detach status contain in prepare progress. |

    ...    | Return Value | Description |
    ...    | None | ${output} |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | Qualcomm.Prepare UE | ${ue0_type} | ue_index=${0} |
    ...
    Prepare for Android UE    ue_index=${ue_index}    cap_index=${capatibility_index}    reset_sol=${reset_sol}
    ...                       detach_request=${detach_request}

Qualcomm.UE Attach
    [Arguments]    ${ue_index}=${0}    ${verify_attach}=False    &{kwargs}
        [Documentation]    This kw is used to attach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.UE Attach | ${ue0_type} | ue_index=${0} |
    ...
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword if    '${attach_status}'=='False'    Ue reattach with index    ue_index=${ue_index}
    Run keyword if    '${verify_attach}'=='True'    Verify Attach Sucessful For Qualcomm UE    ue_index=${ue_index}

Qualcomm.Start traffic
    [Arguments]    ${direction}=dl    ${throughput}=60M    ${duration}=60    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${cap_index}=${0}    ${buffer_size}=1024B    ${appserver}=APPserver    &{kwargs}
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | duration | Duration of traffic |
    ...    | throughput | Throughput of new data transfer |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | cap_index | The list index from ue.capabilities[], will use the index capability for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    log    ${cap_index} is not used in this kw
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    ${port}    set variable if    '${iperf_port}' == 'default'    ${IPERF_PORT_CONFIG}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Start Call For Qualcomm    direction=ul
    ...                                                                    throughput=${throughput}
    ...                                                                    duration=${duration}
    ...                                                                    ue_index=${ue_index}
    ...                                                                    dt_index=${0}
    ...                                                                    buffer_size=${buffer_size}

Qualcomm.Start VONR Call
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=VC_1    ${call_number}=004488
    ...            ${duration}=20s    ${capabilities}=huawei2
    [Documentation]    This kw is used for start VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | duration | Duration of traffic |
    ...    | vc_alias | store ue by ue_alias |
    ...    | call_number | You need to call which number |
    ...    | capabilities | Select which ue by capabilities |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start VONR Call | ue_index=${0} | vc_alias=VC_1 | call_number=004488 |
    ...    duration=20s | capabilities=huawei2 |
    ...
    log    ${capabilities} is not used in this kw
    Start Voice Call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${call_number}    duration=${duration}

Qualcomm.Stop VONR Call
    [Arguments]    ${vc_alias}=VC_1
    [Documentation]    This kw is used for stop VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vc_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop VONR Call | vc_alias=VC_1 |
    ...
    Stop Voice Call    ${vc_alias}

Qualcomm.Stop traffic
    [Arguments]    ${direction}=dl    ${iperf_port}=default    ${ue_index}=${0}    ${appserver}=APPserver    &{kwargs}
    [Documentation]    This kw is used for stop traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | appserver | appserver type |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Stop traffic | ue_index=${0} | direction=dl |
    ...
    ${port}    set variable if    '${iperf_port}' == 'default'    ${IPERF_PORT_CONFIG}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Close the iperf process on APPserver    port=${port}    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${port}

Qualcomm.UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to dettach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.UE Detach | ${ue0_type} | ue_index=${0} |
    Ue detach with index    ue_index=${ue_index}

Qualcomm.Get UE IP address
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to get ue ip
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | UE ip address |
    ...
    ...    Example
    ...    | Qualcomm.Get UE IP | ${ue0_type} | ue_index=${0} |
    ...
    ${UE_IP}    Get the UE Ip address    ue_index=${ue_index}
    [return]    ${UE_IP}

Verify Attach Sucessful For Qualcomm UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used for Verify Attach Sucessful For Qualcomm UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | UE_IP_net | yes | check UP IP if eaqul this IP_net |
    ...    | UE_type | check UP IP if eaqul this IP_net |
    ...    | ue_index | The list index from tl.ues[] |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify Attach Sucessful For Qualcomm UE | ue_index=${0} |
    ...
    wait until keyword succeeds  120s  2s    Verify Qualcomm UE IP    ue_index=${ue_index}

Verify Qualcomm UE IP
    [Arguments]    ${ue_index}=${0}
    ${UE_IP}    Get the UE Ip address    ue_index=${ue_index}
    Should Not Contain    ${UE_IP}    127.0.0

Qualcomm.Teardown UE
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to teardown UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Teardown UE | ${ue0_type} | ue_index=${0} |
    log    ${ue_alias} is not used in this kw
    Ue detach with index    ue_index=${ue_index}

################################## Android common KW ##################################
Android.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_UE    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | capabilities | The list index from ue.capabilities[], will use the index capability for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | ${output} |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | Qualcomm.Prepare UE | ${ue0_type} | ue_index=${0} |
    ...
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}

Android.UE Attach
    [Arguments]    ${ue_index}=${0}    ${verify_attach}=False    &{kwargs}
    [Documentation]    This kw is used to attach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.UE Attach | ${ue0_type} | ue_index=${0} |
    ...
    log    ${verify_attach} is not used in this kw
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    should be equal    "${attach_status}"  "True"   attach UE failed!

Android.Start traffic
    [Arguments]    ${direction}=dl    ${throughput}=60M    ${duration}=60    ${iperf_port}=54015
    ...            ${ue_index}=${0}    ${cap_index}=${0}    ${buffer_size}=1024B    ${appserver}=iperf    &{kwargs}
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | duration | Duration of traffic |
    ...    | throughput | Throughput of new data transfer |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | cap_index | The list index from ue.capabilities[], will use the index capability for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    log    ${cap_index} is not used in this kw
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    run keyword if    '${direction}' == 'dl'    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${iperf_port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Start Call For Qualcomm    direction=ul
    ...                                                                    throughput=${throughput}
    ...                                                                    duration=${duration}
    ...                                                                    ue_index=${ue_index}
    ...                                                                    dt_index=${0}
    ...                                                                    buffer_size=${buffer_size}

Android.Start VONR Call
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=VC_1    ${call_number}=004488
    ...            ${duration}=20s    ${capabilities}=huawei2
    [Documentation]    This kw is used for start VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | duration | Duration of traffic |
    ...    | vc_alias | store ue by ue_alias |
    ...    | call_number | You need to call which number |
    ...    | capabilities | Select which ue by capabilities |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start VONR Call | ue_index=${0} | vc_alias=VC_1 | call_number=004488 |
    ...    duration=20s | capabilities=huawei2 |
    ...
    log    ${capabilities} is not used in this kw
    Start Voice Call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${call_number}    duration=${duration}

Android.Stop VONR Call
    [Arguments]    ${vc_alias}=VC_1
    [Documentation]    This kw is used for stop VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vc_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop VONR Call | vc_alias=VC_1 |
    ...
    Stop Voice Call    ${vc_alias}

Android.Stop traffic
    [Arguments]    ${direction}=dl    ${iperf_port}=default    ${ue_index}=${0}    ${appserver}=APPserver    &{kwargs}
    [Documentation]    This kw is used for stop traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | appserver | appserver type |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Stop traffic | ue_index=${0} | direction=dl |
    ...
    ${port}    set variable if    '${iperf_port}' == 'default'    ${IPERF_PORT_CONFIG}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Close the iperf process on APPserver    port=${port}    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${port}

Android.UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to dettach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.UE Detach | ${ue0_type} | ue_index=${0} |
    Ue detach with index    ue_index=${ue_index}

Android.Get UE IP address
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to get ue ip
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | UE ip address |
    ...
    ...    Example
    ...    | Qualcomm.Get UE IP | ${ue0_type} | ue_index=${0} |
    ...
    ${UE_IP}    Get the UE Ip address    ue_index=${ue_index}
    [return]    ${UE_IP}

Verify Attach Sucessful For Android UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used for Verify Attach Sucessful For Android UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | UE_IP_net | yes | check UP IP if eaqul this IP_net |
    ...    | UE_type | check UP IP if eaqul this IP_net |
    ...    | ue_index | The list index from tl.ues[] |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify Attach Sucessful For Android UE | ue_index=${0} |
    ...
    ${UE_IP}    Get the UE Ip address    ue_index=${ue_index}
    Should Contain    ${UE_IP}    10.

Android.Teardown UE
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to teardown UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Qualcomm.Teardown UE | ${ue0_type} | ue_index=${0} |
    log    ${ue_alias} is not used in this kw
    Ue detach with index    ue_index=${ue_index}
################################## Commercial Common KW ##################################
Commercial.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${is_need_to_kill_vysor}=${False}    ${ui_version}=default    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for Commercial
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | is_need_to_kill_vysor | set if need to kill vysor |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | Commercial.Prepare UE | ${ue0_type} | ue_index=${0} |
    ...
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get product brand    ue_index=${ue_index}
    Get all pointer variable    ui_version=${ui_version}
    Run keyword if    ${is_need_to_kill_vysor}    Kill vysor process

Commercial.UE Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0    ${verify_attach}=${True}    &{kwargs}
    [Documentation]    This kw is used to attach UE for L3 call test.
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | gnb_index | The list index from tl.gnbs[], it will use the index gnb for attach check |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Attach | ${ue0_type} | ue_index=${0} |
    ...
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Log    Turn off Airplane mode and ${gnb_index} and ${du_index} is not used in this kw
    Set Airplane Mode    ${serial_number}    OFF
    Run Keyword If    '${verify_attach}'=='True'
    ...    Wait Until Keyword Succeeds    1min    15sec
    ...    Verify Attaching Status    ${serial_number}    attached




Commercial.Start traffic
    [Arguments]    ${direction}=dl    ${duration}=60    ${throughput}=60M    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${ul_option}=default
    ...            &{kwargs}
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | duration | Duration of traffic |
    ...    | throughput | Throughput of new data transfer |
    ...    | iperf_port | Port number used for traffic start via iperf |
    ...    | interval | The inteval of send by iperf  |
    ...    | buffer_size | Send data package size |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial.Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    ${port}    set variable if    '${iperf_port}' == 'default'    ${IPERF_PORT_CONFIG}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic For Commercial    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     DL_port=${port}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL Traffic For Commercial    time=${duration}
    ...                                                                            traffic=${throughput}
    ...                                                                            ue_index=${ue_index}
    ...                                                                            ul_option=${ul_option}

Commercial.Stop traffic
    [Arguments]    ${direction}=dl    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used for stop traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial.Stop traffic | ue_index=${0} | direction=dl |
    ...
    run keyword if    '${direction}' == 'dl'    Stop DL traffic and check the TP on EPC    ue_index=${ue_index}
    ...    ELSE IF    '${direction}' == 'ul'    Stop UL traffic and delete command in iperf

Commercial.UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to dettach UE for L3 call test.
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial.UE Detach | ue_index |
    ...
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Log    Detaching UE ${ue_index}
    Set Airplane Mode    ${tl.ues[${ue_index}].serial_number}    ON


Commercial.Get UE IP address
    [Arguments]    ${serial_number}
    [Documentation]    This kw is used to get ue ip
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | UE_IP | UE ip address |
    ...
    ...    Example
    ...    | Commercial.Get UE IP | ue_index |
    ...
    ${ip_pattern}    Set Variable    (([0-9])+\\.){3}[0-9]+\\/[0-9]+.*([_a-z0-9]+)
    ${ip_cmd}    Catenate
    ...    adb -s ${serial_number} shell ip -f inet addr |
    ...    grep -P "inet ${ip_pattern}" |
    ...    grep -Po "${ip_pattern}"
    AIC_UE.Send Command And Check Output    command=adb -s ${serial_number} shell ip -f inet addr    connection=cygwin
    ${ip_str}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${ip_cmd}    connection=cygwin
    ...    allow_empty_output=${True}
    Log     UE IP address: ${ip_str}
    @{ip_list}    Split String    ${ip_str}    ${\n}
    Should Not Be Empty    ${ip_list}
    @{ims_ip}    Create List
    @{data_ip}    Create List
    FOR    ${ip_entry}    IN    @{ip_list}
        ${whole_ip}    Fetch From Left    ${ip_entry}    ${SPACE}
        ${ip}    Fetch From Left    ${whole_ip}    /
        ${interface}    Fetch From Right    ${ip_entry}    ${SPACE}
        Run Keyword IF    ${interface.find('_ims')} > -1    Append To List    ${ims_ip}    ${ip}
        ...    ELSE IF    "${interface}"=="lo"    No Operation
        ...    ELSE    Append To List    ${data_ip}    ${ip}
    END
    Log    obtained ims ips ${ims_ip}
    Log    obtained data ips ${data_ip}
    ${ims_ip_length}    Get Length    ${ims_ip}
    ${data_ip_length}    Get Length    ${data_ip}
    ${candidate_ims_ip}    Run Keyword If    ${ims_ip_length}>0    Get From List    ${ims_ip}    0
    ...    ELSE    Set Variable    ${EMPTY}
    ${ip}    Run Keyword If    ${data_ip_length}==0    Set Variable    ${candidate_ims_ip}
    ...    ELSE IF    ${data_ip_length}==1    Get From List    ${data_ip}    0
    ...    ELSE    Get IP From Active Network    ${serial_number}    ${data_ip}
    ${ip}    Set Variable    ${ip.strip()}
    Set Suite Variable    ${UE_IP}    ${ip}
    [Return]    ${ip}


Commercial.Teardown UE
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to teardown UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial.Teardown UE | ${ue0_type} | ue_index=${0} |
    log    ${ue_alias} is not used in this kw.
    Commercial.UE Detach    ${ue_index}
    csn.disconnect    connection=cygwin

Commercial.Start VONR Call
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=VC_1    ${call_number}=004488
    ...            ${duration}=20s    ${capabilities}=huawei2
    [Documentation]    This kw is used for start VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | duration | Duration of traffic |
    ...    | vc_alias | store ue by ue_alias |
    ...    | call_number | You need to call which number |
    ...    | capabilities | Select which ue by capabilities |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start VONR Call | ue_index=${0} | vc_alias=VC_1 | call_number=004488 |
    ...    duration=20s | capabilities=huawei2 |
    ...
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Sleep    5
    Start Voice Call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${call_number}    duration=${duration}

Commercial.Stop VONR Call
    [Arguments]    ${vc_alias}=VC_1
    [Documentation]    This kw is used for stop VONR call
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vc_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop VONR Call | vc_alias=VC_1 |
    ...
    Stop Voice Call    vc_alias=${vc_alias}

################################## Askey ##################################
inseego.Prepare UE
    [Arguments]    ${ue_index}=${0}    ${reboot_ue}=${False}    &{kwargs}
    [Documentation]    This kw is used to Prepare UE for inseego
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | reboot_ue | contol ue reboot by this parameter  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ${ue0_type} | translate_power_ue_type_from_testline | ue_index=${0} |
    ...    | set test variable | ${ue0_type} |
    ...    | inseego.Prepare UE | ${ue0_type} | ue_index=${0} | reboot_ue=${False} |
    ...
    _Prepare Variables    ue_index=${ue_index}
    csn.connect_to    ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    _Reboot_UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

_Prepare Variables
    [Documentation]    Author: Yang Mengli
    [Arguments]    ${ue_index}=${0}    ${index_of_yaml}=${0}
    ${ue_config}    get_common_ue_config    ue_info=${tl.ues[${ue_index}]}    index=${index_of_yaml}
    set suite variable    ${cpc_ip}    ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${appserver_addr}    ${ue_config['data_transfer']['ssh']['host']}
    set suite variable    ${appserver_username}    ${ue_config['data_transfer']['ssh']['user']}
    set suite variable    ${appserver_password}    ${ue_config['data_transfer']['ssh']['password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}
    set suite variable    ${qci}    ${ue_config['qci']}

inseego.UE Attach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=${0}
    ...    ${log_type}=Aasyslog    &{kwargs}
    [Documentation]    This kw is used to attach UE for inseego.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | gnb_index | The list index from tl.gnbs[], it will use the index gnb for attach check |
    ...    | hwcheck_index | The list index with mapping as 0->ASIB 1->ABIL1 2->ABIL2 3ABIL3, it will use the |
    ...    | ...           | mapping HW to check the ue attach status |
    ...    | du_index | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.UE Attach | ${ue0_type} | ue_index=${0} |
    ...
    ...    Last Update
    ...    |https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-280|
    log    ${gnb_index},${du_index},${log_type} and ${hwcheck_index} is not used in this kw.
    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CFUN=0
    Sleep    3s
    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CFUN=1
    Sleep    3s

inseego.UE Detach
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to dettach UE for L3 call test by AT cmd.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | yes | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.UE Detach | ${ue0_type} | ue_index=${0} |
    ...
    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CFUN=0

inseego.Start traffic
    [Arguments]    ${direction}=dl    ${throughput}=100    ${duration}=120
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${buffer_size}=1024B
    ...            &{kwargs}
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | duration | Duration of traffic |
    ...    | throughput | Throughput of new data transfer |
    ...    | buffer_size | Send data package size |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    ute_ue.Start Data Transfer    duration=${duration}s    throughput=${throughput}bits/sec    dt_name=DT_${dt_index}
    ...    ue_alias=UE_${ue_index}    protocol=udp    direction=${direction}    packet_size=${buffer_size}

inseego.Stop traffic
    [Arguments]    ${dt_index}=${0}    &{kwargs}
    [Documentation]    This kw is used for stop traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dt_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.Stop traffic | ue_index=${0} | direction=dl |
    ...
    ute_ue.stop data transfer    dt_name=DT_${dt_index}

_Set Iptables For askey
    [Arguments]    ${connection}=cpc_0    ${timeout}=${30}
    [Documentation]    This KW is for Set Iptables For askey
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | yes | set connect which devices |
    ...    | timeout | yes | execute the common timeout  |

    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Set Iptables For askey | connection==cpc_0 |
    ...
    _Excute ADB Command On UE PC
    ...    command=adb -s ${serial} root    connection=${connection}    timeout=${timeout}
    Sleep    2s
    _Excute ADB Command On UE PC
    ...    command=adb -s ${serial} shell iptables -I INPUT -i rmnet_data0 -j ACCEPT
    ...    timeout=${timeout}    connection=${connection}

_Excute ADB Command On UE PC
    [Arguments]    ${command}    ${connection}=cpc_0    ${timeout}=${10}
    [Documentation]    This KW is for _Excute ADB Command On UE PC
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | command | yes | you need to execute command |
    ...    | connection | yes | set connect which devices |
    ...    | timeout | yes | execute the common timeout  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Excute ADB Command On UE PC | command=${command} | connection=cpc_0 | timeout=${10} |
    ...
    ${output}=    csn.execute    command=${command}    connection=${connection}    timeout=${timeout}
    [Return]    ${output}

_Reboot UE
    [Arguments]    ${serial}=${serial}    ${connection}=cpc_0    ${timeout}=${10}
    [Documentation]    This KW is for Reboot UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial | yes | SN number of UE |
    ...    | connection | yes | set connect which devices |
    ...    | timeout | yes | execute the common timeout  |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Reboot UE | serial=${serial} | connection=cpc_0 | timeout=${10} |
    ...
    _Excute ADB Command On UE PC     command=adb -s ${serial} reboot    connection=${connection}    timeout=${timeout}
    wait until keyword succeeds    3 min    10s    _UE_Exist    connection=${connection}

_UE Exist
    [Arguments]    ${connection}=cpc_0    ${timeout}=${10}
    [Documentation]    This KW is used to confirm if UE Exist
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | yes | set connect which devices |
    ...    | timeout | yes | execute the common timeout  |
    ...
    ...    | Return Value | Description |
    ...    | ${ue_info} | return UE info |
    ...
    ...    Example
    ...    | _UE Exist| connection=cpc_0 | timeout=${10} |
    ...
    ${ue_info}=    _Excute ADB Command On UE PC    command=adb devices    connection=${connection}    timeout=${timeout}
    Should Contain    ${ue_info}    ${serial}
    [Return]    ${ue_info}

AT Teardown
    [Arguments]    ${connection}=cpc_0
    [Documentation]    This KW is used for teardown
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | yes | set connect which devices |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AT Teardown | connection=cpc_0 |
    ...
    csn.disconnect    connection=${connection}

inseego.Get UE IP address
    [Arguments]    ${ue_index}=${0}    &{kwargs}
    [Documentation]    This kw is used to get ue ip
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | UE ip address |
    ...
    ...    Example
    ...    | Get UE IP | ue_index=${0} |
    ...
    ${UE_IP}    Get the UE Ip address    ue_index=${ue_index}
    [return]    ${UE_IP}

Verify Attach Sucessful For Inseego UE
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used for Verify Attach Sucessful For Inseego UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | UE_IP_net | yes | check UP IP if eaqul this IP_net |
    ...    | UE_type | check UP IP if eaqul this IP_net |
    ...    | ue_index | The list index from tl.ues[] |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify Attach Sucessful For Inseego UE | ue_index=${0} |
    ...
    wait until keyword succeeds  120s  2s    Verify Qualcomm UE IP    ue_index=${ue_index}

At Cmd UE Detach
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to dettach UE for L3 call test.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Detach | ${ue0_type} | ue_index=${0} |
    ...
    ${status}    Run Keyword And Return Status    Ue Detach With Index    ue_index=${ue_index}
    Run Keyword If    '${status}'=='False'    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CFUN=0

inseego.Teardown UE
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    This kw is used to Teardown UE after test finished.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.Teardown UE | ue_index=${0} | ue_alias=UE_${ue_index} |
    ...
    log    ${ue_alias} is not used in this kw.
    ${status}    Run Keyword And Return Status    Ue Detach With Index    ue_index=${ue_index}
    Run Keyword If    '${status}'=='False'    ute_ue.Send At Cmd To Ue    UE_${ue_index}    at_cmd=AT+CFUN=0

################################## Verify attach and check tput ##################################
Start DL Traffic with check throughput
    [Arguments]    ${duration}    ${dl_data_transfer}
    ...            ${deviation}=5%  ${deviation_1}=0.05
    [Documentation]    author: mengli.yang@nokia-sbell.com
    log to console  Start DL Traffic with check throughput.${deviation} and ${deviation_1} is not used.
    AIC_UE.Connect To Iperf Server
    ${pods_info}=    vDU Get Pods Full Info
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    FOR    ${pod}    IN    @{pods_name_list}
        Run Keyword If    '-up-' in '${pod}'   Set Test Variable   ${pod_name}   ${pod}
    END
    FOR    ${container}    IN    @{AIC_VDU_PODS['up']}
        Run Keyword If    'l2rt' in '${container}'   Set Test Variable   ${container_name}   ${container}
    END
    ${container_name}    Get Full Container Name By Container Abbreviation    ctr_abbr=${container_name}
    start data transfer  dt_name=DT_DL   ue_alias=UE_0    direction=DL   duration=${duration}
    ...    throughput=${dl_data_transfer}   protocol=udp   packet_size=1024
    sleep    20s
    Run Keyword And Continue On Failure     Check Data Transfer Is Alive   dt_name=DT_DL
    vDU Cluster Login With Tenant
    Collect vDU K8S Logs In Given Pod    ${pod_name}    L2RT_DL    ${container_name}    duration=60s
    ${dl_tput}    get_dl_tput_from_l2_log    ${SUITE_LOG_DIRECTORY}/kubelog/${container_name}.log
    should be true  ${dl_tput}>=0
    [Return]    ${dl_tput}
################################## adb Common KW ##################################
Get product brand
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Get UE brand.
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | The list index from tl.ues[], it will use the index UE for check throughput. |
    ...    | serial_number | SN number of UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get product brand | ue_index=${0} | serial_number=${tl.ues[${ue_index}].serial_number} |
    ...
    ${brand_org}    wait until keyword succeeds    30s    3s
    ...    AIC_UE.Send Command And Check Output
    ...    command=adb -s ${serial_number} shell getprop ro.product.brand
    ...    connection=cygwin
    ${brand_org}    Fetch From Right    ${brand_org.strip()}    ${\n}
    Set Suite Variable    ${brand}    ${brand_org}

get product brand help
    [Arguments]    ${brand_org}
    [Documentation]    *DEPRECATED*This kw is used to get product brand help
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | brand_org | the value of output |
    ...
    ...    | Return Value | Description |
    ...    | ${brand} | UE brand |
    ...
    ...    Example
    ...    | get product brand help | ${brand_org} |
    ...
    ...
    @{brand_org_list}    split string    ${brand_org}    \n
    ${brand}=    Strip String    ${brand_org_list[2]}
    [Return]    ${brand}

Get all pointer variable
    [Arguments]    ${ui_version}=default
    [Documentation]    This kw is used to Get all pointer variable.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ui_version | The ui version from UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all pointer variabled | ui_version=default |
    ...
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='default'
    ...    Get all Samsung pointer variable
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S10UI2.1'
    ...    Get all Samsung pointer variable with S10UI2.1
    run keyword if    '${brand}'=='samsung' and '${ui_version}'=='S21'
    ...    Get all Samsung pointer variable with S21
    run keyword if    '${brand}'=='HUAWEI' and '${ui_version}'=='default'
    ...    Get all Huawei pointer variable
    run keyword if    '${brand}'=='HUAWEI' and '${ui_version}'=='MATE40PROUI1.0'
    ...    Get all Huawei pointer variable with MATE40PROUI1.0
    run keyword if    '${brand}'=='HUAWEI' and '${ui_version}'=='MATE30PROUI1.0'
    ...    Get all Huawei pointer variable with MATE30PROUI1.0
    run keyword if    '${brand}'=='HONOR'
    ...    Get all Huawei pointer variable
    run keyword if    '${brand}'=='Xiaomi'
    ...    Get all Xiaomi pointer variable
    run keyword if    '${brand}'=='Xiaomi' and '${ui_version}'=='XIAOMI12UI1.0'
    ...    Get all Xiaomi pointer variable with XIAOMI12UI1.0
    run keyword if    '${brand}'=='OPPO'
    ...    Get all Oppo pointer variable
    run keyword if    '${brand}'=='qti' and '${ui_version}'=='default'
    ...    Get Qualcomm8350 pointer variable
    run keyword if    '${ui_version}'=='MTP845'
    ...    Get all MTP845 pointer variable
    run keyword if    '${ui_version}'=='MATE40PROUI2.0'
    ...    Get all MTP40 pointer variable

    Set Suite Variable    ${ui_version}    ${ui_version}


Get Qualcomm8350 pointer variable
    [Documentation]    this kw is used to Get all Samsung pointer variable
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all QTI pointer variable |
    ...
    Set Suite Variable    ${airplane}    800 1400
    Set Suite Variable    ${close_task}    500 1200
    Set Suite Variable    ${swipe}    500 1400 500 400
    Set Suite Variable    ${iperf_button}    820 300

Get all MTP845 pointer variable
    [Documentation]    this kw is used to Get all Samsung pointer variable
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all MTP845 pointer variable |
    ...
    Set Suite Variable    ${airplane}    1300 1700
    Set Suite Variable    ${close_task}    700 2000
    Set Suite Variable    ${swipe}    750 1500 750 1500
    Set Suite Variable    ${swipe_notification}    600 15 600 2000
    Set Suite Variable    ${switch}    165 388
    Set Suite Variable    ${iperf_button}    1255 362

Get all MTP40 pointer variable
    [Documentation]    this kw is used to Get all huaweimate40pro pointer variable
    Set Suite Variable    ${airplane}    1197 450
    Set Suite Variable    ${close_task}    562 2169
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    216 606
    Set Suite Variable    ${5G}    960 850
    Set Suite Variable    ${mobile_data}    1000 510


Get all Samsung pointer variable
    [Documentation]    this kw is used to Get all Samsung pointer variable
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Samsung pointer variable |
    ...
    Set Suite Variable    ${airplane}    970 365
    Set Suite Variable    ${close_task}    535 1755
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    900 380

Get all Samsung pointer variable with S10UI2.1
    [Documentation]    this kw is used to Get all Samsung pointer variable with S10UI2.1
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Samsung pointer variable |
    ...
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    721 2345
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    1133 417

Get all Samsung pointer variable with S21
    [Documentation]    this kw is used to Get all Samsung pointer variable with S21
    ...    Author: Lou Sudi
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Samsung pointer variable with S21 |
    ...
    Set Suite Variable    ${airplane}    930 362
    Set Suite Variable    ${close_task}    548 1875
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    1133 417

Get all Huawei pointer variable
    [Documentation]    this kw is used to Get all Huawei pointer variable
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Samsung pointer variable |
    ...
    Set Suite Variable    ${airplane}    960 290
    Set Suite Variable    ${close_task}    538 1979
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    216 606
    Set Suite Variable    ${5G}    960 850

Get all Huawei pointer variable with MATE40PROUI1.0
    [Documentation]    this kw is used to get all pointer variable from Huawei Mate40 Pro
    ...    Author: Liu, Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Huawei pointer variable with MATE40PROUI1.0 |
    ...
    Set Suite Variable    ${airplane}    1000 380
    Set Suite Variable    ${close_task}    562 2169
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    216 606
    Set Suite Variable    ${5G}    960 850
    Set Suite Variable    ${mobile_data}    1000 510


Get all Huawei pointer variable with MATE30PROUI1.0
    [Documentation]    this kw is used to get all pointer variable from Huawei Mate30 Pro
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Huawei pointer variable with MATE30PROUI1.0 |
    ...
    Set Suite Variable    ${airplane}    1024 310
    Set Suite Variable    ${close_task}    586 2140
    Set Suite Variable    ${swipe}    586 2050 586 800
    Set Suite Variable    ${iperf_button}    1033 527


Get all Xiaomi pointer variable
    [Documentation]    this kw is used to Get all Xiaomi pointer variable
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Xiaomi pointer variable |
    ...
    Set Suite Variable    ${airplane}    908 1482
    Set Suite Variable    ${close_task}    535 2165
    Set Suite Variable    ${swipe}    500 800 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all Xiaomi pointer variable with XIAOMI12UI1.0
    [Documentation]    Get all Xiaomi-12 screen coordinates
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Xiaomi pointer variable with XIAOMI12UI1.0 |
    ...
    Set Suite Variable    ${airplane}    550 1647
    Set Suite Variable    ${close_task}    535 2165
    Set Suite Variable    ${swipe}    500 800 500 800
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 530
    Set Suite Variable    ${5G}    930 600


Get all Oppo pointer variable
    [Documentation]    this kw is used to Get all Oppo pointer variable
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get all Samsung pointer variable |
    ...
    Set Suite Variable    ${airplane}    930 357
    Set Suite Variable    ${close_task}    540 2156
    Set Suite Variable    ${swipe}    540 2130 540 1295
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    708 308
    Set Suite Variable    ${iperf_space}    216 606
    Set Suite Variable    ${5G}    960 850
    Set Suite Variable    ${mobile_data}    960 780

Preparation and execution for Commercial UE Attach
    [Arguments]    ${UE_type}=${brand}    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    *DEPRECATED*This kw is used for Preparation and execution for Commercial UE Attach
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | UE_IP_net | yes | check if UP IP equals to this IP_net |
    ...    | UE_type | check if UP IP equals to this IP_net |
    ...    | ue_index | The list index from tl.ues[] |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Preparation and execution for Commercial UE Attach | UE_IP_net=127.0.0 | UE_type=${brand} |
    ...    | ...                                                | ue_index=${0} |
    ...
    ${UE_IP}    Get Commercial UE IP    ue_index=${ue_index}
    ${detached}=    Run Keyword And Return Status    Should Be Empty    ${UE_IP}
    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    run keyword if    '${detached}'=='${True}'
    ...    Run Keywords    Commercial UE toggle AIRPLANE Mode   airplane=${airplane}
    ...                                                         close_task=${close_task}    serial_number=${serial_number}    AND
    ...                    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.
    ...       ELSE
    ...    Run Keywords    Commercial UE toggle AIRPLANE Mode    toggle_times=${2}    airplane=${airplane}
    ...                                                          close_task=${close_task}    serial_number=${serial_number}    AND
    ...                    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.
    csn.disconnect    connection=cygwin


Verify Attaching Status
    [Arguments]    ${serial_number}    ${status}
    [Documentation]    Verify Attaching Status of the UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...    | status | yes | Expected attaching status |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify Attaching Status | serial_number |
    ...
    Log    Verify if UE was ${status}
    ${ue_ip}    Commercial.Get UE IP address    ${serial_number}
    Log    UP IP: ${ue_ip}
    ${status}    Set Variable    ${status.upper()}
    Run Keyword If    "${status}"=="ATTACHED"    Should Not Be Empty    ${ue_ip}
    ...    ELSE IF    "${status}"=="DETACHED"    Should Be Empty    ${ue_ip}
    ...    ELSE    Fail    Unacceptable status value ${status}


Verify Commercial UE IP
    [Arguments]    ${ue_index}=${0}
    [Documentation]    *DEPRECATED*
    ${UE_IP}    Get Commercial UE IP    ue_index=${ue_index}
    Should Not Be Empty    ${UE_IP}


Commercial UE detach
    [Arguments]    ${UE_type}=${brand}    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${airplane}=${airplane}    ${close_task}=${close_task}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    *DEPRECATED*This kw is used for Commercial UE detach
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | UE_IP_net | yes | check UP IP if eaqul this IP_net |
    ...    | UE_type | yes | check UP IP if eaqul this IP_net |
    ...    | ue_index | yes | The list index from tl.ues[] |
    ...    | airplane | yes | airplane switch pointer variable |
    ...    | ue_index | yes | close all UE's task pointer variable |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial UE detach | ue_index=${0} |
    ...
    ${UE_IP}    Get Commercial UE IP    ue_index=${ue_index}
    ${detached}=    Run Keyword And Return Status    Should Be Empty    ${UE_IP}
    run keyword if    '${detached}'=='${True}'    Log    INFO:${UE_type} UE status is on detach.
    ...       ELSE    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
    ...                               Commercial UE toggle AIRPLANE Mode   airplane=${airplane}
    ...                                                                    serial_number=${serial_number}
    ...                                                                    close_task=${close_task}    AND
    ...                               Log    INFO:${UE_type} UE detach successfully.


Set Airplane Mode
    [Arguments]    ${serial_number}    ${status}
    [Documentation]    Set AIRPLANE Mode of a Commercial UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...    | status | yes | expected Airplane mode status of the UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Set Airplane Mode | serial_number | status |
    ...
    ...    Update
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-267 |
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-269 |
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-304 |
    # Process arguments
    ${status}=    Set Variable    ${status.upper()}
    Log  expected status: ${status}
    # Get current airplane status
    ${airplane_on}=    Get Airplane Mode    ${serial_number}
    Log    airplane_on: ${airplane_on}
    # Toggle air plane switch if necessary
    Run Keyword If    '${airplane_on}'=='${status}'    Toggle Airplane Mode    ${ui_version}    ${serial_number}    ${2}
    ...    ELSE    Toggle Airplane Mode    ${ui_version}    ${serial_number}
    # Double check current air plane status
    ${airplane_on}=    Get Airplane Mode    ${serial_number}
    Should Be Equal    ${airplane_on}    ${status}
    ...    msg=Failed to turn ${status} Airplane Mode
    ...    values=False
    ...    ignore_case=True
    Log    Successfully turned ${status} Airplane Mode


Get Airplane Mode
    [Arguments]    ${serial_number}
    [Documentation]    Get AIRPLANE Mode from a Commercial UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | airplane_on | Airplane Mode fetched from UE |
    ...
    ...    Example
    ...    | Toggle Airplane Mode | ue_index=0 | ${status}=OFF
    ${airplane_cmd}    Set Variable    adb -s ${serial_number} shell settings get global airplane_mode_on
    ${airplane_on}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${airplane_cmd}    connection=cygwin
    ${airplane_on}    Fetch From Right    ${airplane_on.strip()}    ${\n}
    ${airplane_on}    Set Variable If    "${airplane_on}" == "1"    ON    OFF
    Log    Fetched Airplane Mode [${airplane_on}] from UE ${serial_number}
    [Return]    ${airplane_on}


Toggle Airplane Mode
    [Arguments]    ${ui_version}    ${serial_number}    ${toggle_times}=${1}
    [Documentation]    toggling AIRPLANE Mode of a Commercial UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...    | toggle_times | yes | times for which the airplane mode should be toggled |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Toggle Airplane Mode | serial_number | toggle_times |
    Run Keyword If    '${ui_version}'=='MTP845'    Toggle MTP845 Airplane Mode    ${serial_number}    ${toggle_times}
    ...    ELSE    Toggle Universial Airplane Mode    ${serial_number}    ${toggle_times}


Toggle Universial Airplane Mode
    [Arguments]    ${serial_number}    ${toggle_times}
    [Documentation]    toggling AIRPLANE Mode of a Universial Commercial UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...    | toggle_times | yes | times for which the airplane mode should be toggled |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Toggle Airplane Mode | serial_number | toggle_times |
    ${awhile}    Set Variable    7s
    ##### Trying to unlock the phone
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU
    ...                                                 connection=cygwin
    sleep    2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME
    ...                                                 connection=cygwin
    sleep    2s    reason=Sleep shorter to prevent screen locking
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}
    ...                                                 connection=cygwin
    sleep    ${awhile}
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_APP_SWITCH    connection=cygwin
    sleep    ${awhile}
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
#    sleep    ${awhile}
    sleep    10s
    ##### Enter Airplane Setting Page #####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
    ...                 connection=cygwin
    sleep    ${awhile}
    FOR    ${i}    IN RANGE    ${toggle_times}
        #####Tap the airplane mode switch to enable airplane mode#####
        csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
        sleep    ${awhile}
    END
    #####return to home screen before clicking multi-task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    ${awhile}
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_APP_SWITCH    connection=cygwin
    sleep    ${awhile}
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    sleep    ${awhile}



Toggle MTP845 Airplane Mode
    [Arguments]    ${serial_number}    ${toggle_times}
    [Documentation]    toggling AIRPLANE Mode of a MTP845 Commercial UE
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...    | toggle_times | yes | times for which the airplane mode should be toggled |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Toggle Airplane Mode | serial_number | toggle_times |
    ${awhile}    Set Variable    7s
    ##### Trying to unlock the phone
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU
    ...                                                 connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU
    ...                                                 connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME
    ...                                                 connection=cygwin
    sleep    2s    reason=Sleep shorter to prevent screen locking
    #####Swipe up to open the drawer #####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe_notification}
    ...                                                 connection=cygwin
    sleep    ${awhile}
    FOR    ${i}    IN RANGE    ${toggle_times}
        #####Tap the airplane mode switch to enable airplane mode#####
        csn.send_command    command=adb -s ${serial_number} shell input tap ${switch}    connection=cygwin
        sleep    ${awhile}
    END
    #####return to home screen before clicking multi-task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    ${awhile}



Get Commercial UE IP
    [Arguments]    ${ue_index}
    [Documentation]    *DEPRECATED*This kw is used to Get Commercial UE IP
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | UE_IP | A string contains IP address fetched from UE. If IP address is not fetched, an empty string will be returned.|
    ...
    ...    Example
    ...    | Get Commercial UE IP | ue_index=${0} |
    ...
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${UE_IP}    Get Commercial UE IP with first UE    ue_index=${ue_index}
    set test variable    ${UE_IP}
    [Return]    ${UE_IP}


Get Serving Cell Id
    [Arguments]    ${serial_number}
    [Documentation]    Trying to get serving cell id from NAA log (PZ1HAZTA-285)
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | Cell ID | serving cell id if available |
    ...
    ...    Example
    ...    | Get Serving Cell Id |
    ...
    Log     Start getting serving cell id...
    ${airplane_mode}    Get Airplane Mode    ${serial_number}
    Should Be Equal As Strings    ${airplane_mode}    OFF
    ...    values=${False}
    ...    ignore_case=${True}
    ...    msg=Airplane Mode is currently ON
    ${pid}    Start NAA Application    ${serial_number}
    ${cell_id_cmd}    Catenate
    ...    adb -s ${serial_number} logcat -d --pid=${pid} |
    ...    grep 'serving cell' |
    ...    grep -Po '(\\bn?ci=)[0-9]+'|
    ...    tail -1
    ${cell_id}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${cell_id_cmd}    connection=cygwin
    ${cell_id}    Fetch From Right    ${cell_id}    =
    Log     fetched cell id ${cell_id}
    Exit NAA Application    ${serial_number}
    [Return]    ${cell_id}


Get Average Throughput
    [Arguments]    ${ue_index}    ${period}=1min
    [Documentation]    Trying to get throughput from NAA log (PZ1HAZTA-462)
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | Throughput UL, Throughput DL| uplink and downlink throughput |
    ...
    ...    Example
    ...    | Get Serving Cell Id |
    ...
    Log     Start getting throughput from NAA...
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    ${airplane_mode}    Get Airplane Mode    ${serial_number}
    Should Be Equal As Strings    ${airplane_mode}    OFF
    ...    values=${False}
    ...    ignore_case=${True}
    ...    msg=Airplane Mode is currently ON
    ${pid}    Start NAA Application    ${serial_number}
    ${pattern}    Set Variable    NetworkTrafficStats.*mobileAvgThrRx ([0-9]+), mobileAvgThrTx ([0-9]+)
    ${clear_throughput_cmd}    Catenate
    ...    adb -s ${serial_number} logcat --clear
    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${clear_throughput_cmd}    connection=cygwin
    ...    allow_empty_output=${True}
    Sleep    ${period}
    ${get_throughput_cmd}    Catenate
    ...    adb -s ${serial_number} logcat
    ...    --pid=${pid}
    ...    -d
    ...    --regex '${pattern}'
    ${log_result}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${get_throughput_cmd}    connection=cygwin
    ${result}    Get Regexp Matches    ${log_result}    ${pattern}    1    2
    ${size}    Get Length    ${result}
    ${dl_tp_sum}    Set Variable    ${0}
    ${ul_tp_sum}    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${size}
        ${sample}    Get From List    ${result}    ${i}

        ${dl}    Get From List    ${sample}    0
        ${dl_tp_sum}    Evaluate    ${dl_tp_sum}+${dl}

        ${ul}    Get From List    ${sample}    1
        ${ul_tp_sum}    Evaluate    ${ul_tp_sum}+${ul}
    END
    ${dl_tp_avg}    Evaluate    ${dl_tp_sum}/${size}
    ${ul_tp_avg}    Evaluate    ${ul_tp_sum}/${size}
    Exit NAA Application    ${serial_number}
    [Return]    ${dl_tp_avg}    ${ul_tp_avg}


Start NAA Application
    [Arguments]    ${serial_number}
    [Documentation]    Trying to start Nokia Android Application
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | PID | Process ID of NAA |
    ...
    ...    Example
    ...    | Start NAA Application |  serial_number |
    ...
    Log     Starting NAA...
    ${naa}    Set Variable    com.nokia.android.application/com.nokia.android.application.NaaActivity
    AIC_UE.Send Command And Check Output    command=adb -s ${serial_number} shell am start -S -n ${naa}
    ...    allow_empty_output=${True}
    ...    connection=cygwin
    ${ps_arg}    Set Variable if    "${brand}"=="Android"    ${EMPTY}    -A
    ${pid_cmd}    Catenate
    ...    adb -s ${serial_number} shell ps ${ps_arg} |
    ...    grep -P nokia\.android\.application |
    ...    head -1 |
    ...    awk '{print $2}'
    ${pid}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${pid_cmd}    connection=cygwin
    Log     NAA started, pid: ${pid}
    [Return]    ${pid}


Exit NAA Application
    [Arguments]    ${serial_number}
    [Documentation]    Trying to stop Nokia Android Application
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | N/A | N/A |
    ...
    ...    Example
    ...    | Start NAA Application |  serial_number |
    ...
    Log     Exiting NAA...
    ${naa}    Set Variable    com.nokia.android.application
    AIC_UE.Send Command And Check Output    command=adb -s ${serial_number} shell am force-stop ${naa}
    ...    allow_empty_output=${True}
    ...    connection=cygwin


Check Output
    [Arguments]    ${connection}     ${allow_empty_output}=${False}
    [Documentation]    Read output from a connection and fails if any error occured
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | the connection via which the output should be read |
    ...
    ...    | Return Value | Description |
    ...    | output | Output from connection |
    ...
    ...    Example
    ...    | Read Output | message |
    ...
    ${error}    csn.read_error    connection=${connection}
    ${error}    Set Variable    ${error.strip()}
    Should Be Empty    ${error}    msg=Error: ${error}
    ${output}    csn.read_output    connection=${connection}
    ${output}    Set Variable    ${output.strip()}
    Run Keyword Unless    ${allow_empty_output}    Should Not Be Empty    ${output}
    [Return]    ${output}


Send Command And Check Output
    [Arguments]    ${command}    ${connection}    ${allow_empty_output}=${False}
    [Documentation]    Send command to a connection and check if any error occured
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | command | command to be sent |
    ...    | connection | the connection via which command should be sent |
    ...
    ...    | Return Value | Description |
    ...    | output | Output from connection |
    ...
    ...    Example
    ...    | AIC_UE.Send Command And Check Output | message |
    ...
    csn.send_command    command=${command}    connection=${connection}
    ${output}    Check Output    connection=${connection}    allow_empty_output=${allow_empty_output}
    [Return]    ${output}


Send Command And Check Output Contains
    [Arguments]    ${command}    ${keyword}    ${connection}
    [Documentation]    Send command to a connection and check if the output contains the keywords
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | command | command to be sent |
    ...    | keyword | keyword to check |
    ...    | connection | the connection via which command should be sent |
    ...
    ...    | Return Value | Description |
    ...    | contain | whether the result contains the keywords |
    ...
    ...    Example
    ...    | Send Command And Check Output Contains| command | keyword | connection |
    ...
    csn.send_command    command=${command}    connection=${connection}
    ${output}    Check Output    connection=${connection}
    ${contain}    Set Variable If    ${output.find("${keyword}")} > -1    ${True}    ${False}
    [Return]    ${contain}


Reboot Android UE
    [Arguments]    ${ue_index}    ${timeout}=${1}
    [Documentation]    Reboot an Android UE and wait for it being rebooted
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | Yes |command to be sent |
    ...    | timeout | time period to wait before the UE has been booted |
    ...
    ...    | Return Value | Description |
    ...
    ...    Example
    ...    | Reboot Android UE | 0 |
    ...
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cygwin
    Sleep    5s
    Wait Until Keyword Succeeds    ${timeout}min    5s    Android UE Exists    ${serial_number}


Android UE Exists
    [Arguments]    ${serial_number}
    [Documentation]    Check if an Android UE are listed in adb devices
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | Yes | serial number of the UE |
    ...
    ...    | Return Value | Description |
    ...
    ...    Example
    ...    | Android UE Exists | serial_number |
    ...
    ${result}    Send Command And Check Output Contains
        ...    command=adb devices
        ...    keyword=${serial_number}
        ...    connection=cygwin
    Should Be True    ${result}


Get IP From Active Network
    [Arguments]    ${serial_number}    ${alternative_ip_list}
    [Documentation]    Send command to a connection and check if any error occured
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | Yes |ue serial number |
    ...
    ...    | Return Value | Description |
    ...    | IP | LinkAddress of the Active default network |
    ...
    ...    Example
    ...    | Get IP From Active Network | serial_number |
    ...
    ${ip_cmd}    Set Variable    adb -s ${serial_number} shell dumpsys connectivity
    ${dumped}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${ip_cmd}    connection=cygwin
    @{active_network}    Get RegExp Matches    ${dumped}    Active default network: (\\d+)    1
    ${active_network_value}    Get From List    ${active_network}    0
    ${ip_pattern}    Set Variable    (([0-9])+\\.){3}[0-9]+
    ${pattern}    Set Variable    network\\{${active_network_value}\\}.*?LinkAddresses:\\s*\\[\\s*(${ip_pattern})\\/\\d+.*\\]
    @{ip_list}    Get RegExp Matches    ${dumped}    ${pattern}    1
    ${ip_length}    Get Length    ${ip_list}
    ${ip}    Run Keyword If    ${ip_length}>0    Get From List    ${ip_list}    0
    ...    ELSE    Get From List    ${alternative_ip_list}    0
    [Return]    ${ip}



Start DL traffic For Commercial
    [Arguments]    ${ue_index}=${0}    ${time}=10
    ...            ${DL_port}=${IPERF_PORT_CONFIG}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    [Documentation]    This kw is used to Start DL traffic For Commercial
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | interval | yes | common which to get UE IP |
    ...    | traffic | yes | Throughput of new data transfer |
    ...    | buffer_size | yes | buffer size of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start DL traffic For Commercial | ue_index=${ue_index} | time=${duration} | interval=${interval} |
    ...    | ...                             | traffic=${throughput} | buffer_size=${buffer_size} | DL_port=${port} |
    ...
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    ${ue_ip}    Commercial.Get UE IP address    ${serial_number}
    Should Not Be Empty    ${ue_ip}
    wait until keyword succeeds    1 min    10 sec    Connect to iper APP    ue_index=${ue_index}
    sleep    2s
    ${iperf_cmd}    Catenate
    ...    ps -ef |
    ...    grep 'iperf' |
    ...    grep -v grep |
    ...    grep ${DL_port} |
    ...    awk '{print $2}' |
    ...    xargs kill -9
    csn.execute    command=${iperf_cmd}    connection=EPCAPP
    ${iperf_cmd}    Catenate
    ...    iperf -c ${ue_ip} -u -t ${time}
    ...    -i ${interval} -p ${DL_port}
    ...    -P 1 -f m -b ${traffic}
    ...    -l ${buffer_size} -T 64 &
    csn.send_command    command=${iperf_cmd}    connection=EPCAPP


Start DL traffic
    [Arguments]    ${swipe}=${swipe}
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${iperf_button}=${iperf_button}
    [Documentation]    *DEPRECATED*This kw is used to Start DL traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | swipe | yes | Swipe the phone screen up |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | DL_port | yes | set DL port |
    ...    | interval | yes | common which to get UE IP |
    ...    | traffic | yes | Throughput of new data transfer |
    ...    | buffer_size | yes | buffer size of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start DL traffic | ue_index=${ue_index} | time=${time} | interval=${interval} | traffic=${traffic} |
    ...    | ...              | buffer_size=${buffer_size} | DL_port=${DL_port} |
    ...
    log    ${swipe} and ${iperf_button} is not used
    ${UE_IP}    Get Commercial UE IP    ue_index=${ue_index}
    Should Not Be Empty    ${UE_IP}
    wait until keyword succeeds    1 min    10 sec    Connect to iper APP    ue_index=${ue_index}
    sleep    2s
    csn.execute
    ...    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
    ...    connection=EPCAPP

Stop DL traffic and check the TP on EPC
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${IPERF_PORT_CONFIG}    #${time}=10
    ...    ${connection}=EPCAPP
    [Documentation]    This kw is used to Stop DL traffic and check the TP on EPC
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | DL_port | yes | set DL port |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop DL traffic and check the TP on EPC | ue_index=${ue_index} | DL_port=${DL_port} |
    ...
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=${connection}
    csn.disconnect    connection=${connection}

Connect to iper APP
    [Arguments]    ${ue_index}=${0}    ${iperf_host}=${IPERF_ADDRESS_CONFIG}
    ...    ${iperf_user}=${IPERF_USER_CONFIG}
    ...    ${iperf_password}=${IPERF_PASSWORD_CONFIG}
    [Documentation]    This kw is used to Connect to iper APP
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to iper APP | ue_index=${ue_index} |
    ...
    csn.Connect to    hostname=${iperf_host}
    ...    username=${iperf_user}
    ...    password=${iperf_password}    alias=EPCAPP

Start UL Traffic For Commercial
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${ul_option}=default
    [Documentation]    This kw is used to Start UL Traffic For Commercial
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | traffic | yes | Throughput of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start UL Traffic For Commercial | ue_index=${ue_index} | time=${time} | traffic=${traffic} |
    ...
    ${retry_times}    Set Variable If    '${ul_option}' == 'retry'    ${10}    ${1}

    FOR    ${i}    IN RANGE    ${retry_times}
        run keyword    Start UL traffic    time=${time}    traffic=${traffic}
        ...            ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}
    END


Start UL traffic
    [Arguments]    ${swipe}=${swipe}
    ...    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${EPC_IP}=${IPERF_ADDRESS_CONFIG}
    ...    ${UL_port}=${IPERF_PORT_CONFIG}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${iperf_button}=${iperf_button}
    [Documentation]    This kw is used to Start UL traffic
    ...    Update: https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-213
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | swipe | yes | Swipe the phone screen up |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | UL_port | yes | set UL port |
    ...    | interval | yes | common which to get UE IP |
    ...    | traffic | yes | Throughput of new data transfer |
    ...    | buffer_size | yes | buffer size of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start UL traffic | ue_index=${ue_index} | time=${time} | interval=${interval} | traffic=${traffic} |
    ...    | ...              | buffer_size=${buffer_size} | UL_port=${UL_port} |
    ...
    sleep    2s
    ##### Try unlocking the phone #####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU    connection=cygwin
    sleep    3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    3s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin
    sleep    4s
    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    ...    connection=cygwin
    sleep    4s
    csn.send_command    adb -s ${serial_number} shell input keyevent KEYCODE_MOVE_END   connection=cygwin
    sleep    2.0
    FOR    ${i}    IN RANGE    7
        csn.send_command    adb -s ${serial_number} shell input keyevent KEYCODE_DEL    connection=cygwin
        sleep    1.0
    END
    csn.send_command    command=adb -s ${serial_number} shell input text iperf    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --client    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    @{chars}=    Split String To Characters    ${EPC_IP}
    FOR    ${char}    IN     @{chars}
        csn.send_command    command=adb -s ${serial_number} shell input text ${char}    connection=cygwin
        sleep    1.0s
    END
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --udp    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --port    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text ${UL_port}    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --time    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text ${time}    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --interval    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text 1    connection=cygwin
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --parallel   connection=cygwin
    sleep    2.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text 1    connection=cygwin
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --format    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text m    connection=cygwin
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --bandwidth    connection=cygwin
    sleep    2.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text ${traffic}    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --len    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text ${buffer_size}    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text --ttl    connection=cygwin
    sleep    1.5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_SPACE    connection=cygwin
    sleep    0.5s
    csn.send_command    command=adb -s ${serial_number} shell input text 64    connection=cygwin
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${iperf_button}    connection=cygwin

Start UL traffic With Retry
    [Arguments]    ${swipe}=${swipe}
    ...    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${iperf_button}=${iperf_button}
    [Documentation]    *DEPRECATED*This kw is used to Start UL traffic
    ...    Author: Liu, Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | swipe | yes | Swipe the phone screen up |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | time | yes | Duration of traffic |
    ...    | UL_port | yes | set UL port |
    ...    | interval | yes | common which to get UE IP |
    ...    | traffic | yes | Throughput of new data transfer |
    ...    | buffer_size | yes | buffer size of new data transfer |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start UL traffic | ue_index=${ue_index} | time=${time} | interval=${interval} | traffic=${traffic} |
    ...    | ...              | buffer_size=${buffer_size} | UL_port=${UL_port} |
    ...
    sleep    3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    3s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf
    Retry send command in cygwin
    ...  command=adb -s ${serial_number} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    sleep    2s
    #touch on the end of iperf input line
    Retry send command in cygwin
    ...  command=adb -s ${serial_number} shell input tap ${iperf_space}
    sleep    2s
    FOR    ${i}    IN RANGE    10
        Retry send command in cygwin    command=adb -s ${serial_number} shell input keyevent KEYCODE_DEL
        sleep    0.5
    END
    ${ul_cmd}    set variable
    ...  iperf\%s-c\%s${EPC_IP}\%s-u\%s-p\%s${UL_port}\%s-t\%s${time}\%s-i\%s1\%s-P\%s1\%s-f\%sm\%s-b\%s${traffic}\%s-l\%s${buffer_size}\%s-T\%s64\%s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input text ${ul_cmd}    ue_index=${ue_index}
    sleep   3s
    Retry send command in cygwin    command=adb -s ${serial_number} shell input tap ${iperf_button}

Retry send command in cygwin
    [Arguments]  ${command}     ${ue_index}=${0}
        [Documentation]    This kw is used to Start UL traffic
    ...    Author: Liu, Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | command | yes | the command to execute on remote machine |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start UL traffic | ue_index=${ue_index} | time=${time} | interval=${interval} | traffic=${traffic} |
    ...    | ...              | buffer_size=${buffer_size} | UL_port=${UL_port} |
    ...
    ${status}    Run keyword and return status    csn.send_command    command=${command}    connection=cygwin
    Run keyword if     '${status}' == '${False}'    run keywords
    ...   csn.force reconnect    connection=cygwin          AND
    ...   csn.send_command    command=${command}    connection=cygwin

Stop UL traffic and delete command in iperf
    [Arguments]    ${UL_port}=${tl.appserver.iperf_details.port}    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Stop UL traffic and delete command in iperf
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | UL_port | yes | set UL port |
    ...    | serial_number | yes | define SN number of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Stop UL traffic and delete command in iperf | ue_index=${ue_index} | UL_port=${UL_port} |
    ...    | ...                                         | ${serial_number} |
    ...
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am force-stop com.nextdoordeveloper.miperf.miperf    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin



Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${None}
    ...    ${hostname}=${appserver_addr}
    ...    ${username}=${appserver_username}
    ...    ${password}=${appserver_password}    ${alias}=cygwin
    [Documentation]    This kw is used to Connect to control pc via cygwin.
    ...    Author: Lv Feng
    ...    Contact: feng.1.lv@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | ue_index takes precedence of other parameters such as hostname, username and password |
    ...    | hostname | no | The host to be connected to |
    ...    | username | no | The username to connect the host with |
    ...    | password | no | The password to connect the host with |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to control pc via cygwin |
    ...
    ...    Updates
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-276 |
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-686 |
    Log    ue_index is ${ue_index}
    ${cpc_ip}    Set Variable If    '${ue_index}' == '${None}'
    ...    ${hostname}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_username}    Set Variable If    '${ue_index}' == '${None}'
    ...    ${username}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_password}    Set Variable If    '${ue_index}' == '${None}'
    ...    ${password}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.password}
    Wait Until Keyword Succeeds    10min    2min
    ...    csn.connect to    ${cpc_ip}    ${cpc_username}    ${cpc_password}    alias=${alias}    timeout=2 minutes


Commercial UE click 5G once
    [Arguments]    ${swipe}=${swipe}    ${5G}=${5G}    ${close_task}=${close_task}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Connect to Commercial UE click 5G once
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | swipe | yes | Swipe the phone screen up |
    ...    | airplane | yes | airplane switch pointer variable |
    ...    | close_task | yes | close all UE's task pointer variable |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Commercial UE click 5G once | swipe=${swipe} | 5G=${5G} |
    ...    | ...                         | close_task=${close_task} |
    ...
    ...    Update
    ...    | https://jiradc.ext.net.nokia.com/browse/PZ1HAZTA-267 |
    Connect to control pc via cygwin
    sleep    2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU    connection=cygwin
    sleep    2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start -n com.android.phone/.MobileNetworkSettings    connection=cygwin
    sleep    2s
    #####Tap the 5G mode switch to enable 5G mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${5G}    connection=cygwin
    sleep    5s
    #####return to home screen before clicking multi-task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cygwin
    sleep    2s
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_APP_SWITCH    connection=cygwin
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    sleep    2s
    csn.disconnect    connection=cygwin

Get Mobile Data status
    [Arguments]    ${serial_number}    ${connection}=cygwin
    [Documentation]    Get Mobile Data state
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | mobile_data_status | mobile data status fetched from UE |
    ...
    ...    Example
    ...    | Get Mobile Data state | serial_number | connection
    ${mobile_data_cmd}    Set Variable    adb -s ${serial_number} shell settings get global mobile_data
    ${mobile_data_info}    Wait Until Keyword Succeeds    1min    5sec
    ...    AIC_UE.Send Command And Check Output    command=${mobile_data_cmd}    connection=${connection}
    ${mobile_data_value}    Fetch From Right    ${mobile_data_info.strip()}    ${\n}
    ${mobile_data_status}    Set Variable If    "${mobile_data_value}" == "1"    ON    OFF
    Log    Fetched Mobile data [${mobile_data_status}] from UE ${serial_number}
    [Return]    ${mobile_data_status}

Unlock Phone
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ${awhile}    Set Variable    5s
    ##### Trying to unlock the phone
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_MENU
    ...                                                 connection=${connection}
    sleep    2s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME
    ...                                                 connection=${connection}
    sleep    2s    reason=Sleep shorter to prevent screen locking
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}
    ...                                                 connection=${connection}
    sleep    ${awhile}

Close Task List
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ${awhile}    Set Variable    5s
    #####return to home screen before clicking multi-task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=${connection}
    sleep    ${awhile}
    #####Click the task button#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_APP_SWITCH    connection=${connection}
    sleep    ${awhile}
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
    sleep    ${awhile}

Toggle Airplane Mode Setting
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ${awhile}    Set Variable    5s
    ##### Enter AIRPLANE MODE SETTINGS Page #####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
    ...                       connection=${connection}
    sleep    ${awhile}
    #####Tap the airplane mode switch to toggle airplane#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
    sleep    ${awhile}

Toggle Mobile Data Setting
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ${awhile}    Set Variable    5s
    ##### Enter Mobile DATA SETTINGS Page #####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.DATA_ROAMING_SETTINGS
    ...                 connection=${connection}
    sleep    ${awhile}
    #####Tap the mobile data switch to toggle mobile data#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${mobile_data}    connection=${connection}
    sleep    ${awhile}

Toggle Mobile Data
    [Arguments]    ${serial_number}    ${connection}=cygwin
    [Documentation]    toggling mobile data of a Commercial UE
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | serial_number | yes | Serial number of the commercial UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Toggle Mobile Data | serial_number | airplane_mode | connection
    Unlock Phone    ${serial_number}    ${connection}
    Toggle Mobile Data Setting    ${serial_number}    ${connection}
    Close Task List    ${serial_number}    ${connection}

Set Mobile Data
    [Arguments]    ${ue_index}    ${state}    ${connection}=cygwin
    [Documentation]    Set Mobile Data
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[]|
    ...    | state | yes | expected state of mobile data |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Set Mobile Data | serial_number | state | connection
    ${serial_number}    Set Variable   ${tl.ues[${ue_index}].serial_number}
    # Check current airplane mode
    ${airplane_mode}=    Get Airplane Mode    ${serial_number}
    Log    Current airplane mode status is: ${airplane_mode}
    Should Be Equal    ${airplane_mode}    OFF
    ...                Do not support to set mobile data when airplane mode status is ON!
    ${state}=    Set Variable    ${state.upper()}
    Log  expected state of mobile data: ${state}
    # Get current mobile data status
    ${mobile_data_status}=    Get Mobile Data status    ${serial_number}    ${connection}
    Log    Current mobile data status is: ${mobile_data_status}
    # Toggle mobile data switch if necessary
    run keyword if    '${mobile_data_status}'!='${state}'    Toggle Mobile Data
    ...                 ${serial_number}    ${connection}
    # Double check current mobile data status
    ${mobile_data_status}=    Get Mobile Data status    ${serial_number}    ${connection}
    Should Be Equal    ${mobile_data_status}    ${state}    Set mobile data ${state} failed

Kill vysor process
    [Documentation]    This kw is used to Kill vysor process
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Kill vysor process |
    ...
    Wait Until Keyword Succeeds    3x    5sec    Connect to control pc via cygwin
    csn.send_command    command=adb shell " ps -ef | grep vysor | grep -v grep | grep 'shell' | awk '{print $2}'| xargs kill -9"
    ...    connection=cygwin
    Sleep    1s
    ${check_process}    csn.Execute    ps -ef | grep vysor | grep -v grep | grep 'shell'    connection=cygwin
    Should be empty    ${check_process}
    #[Teardown]    csn.disconnect    connection=cygwin

################################## QCT relevant common KW ##################################
Prepare for Android UE
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${reset_sol}=none    ${detach_request}=${true}
    [Documentation]    This kw is used to Start the QPST progress
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | reset_sol | no | reset_sol has three choose (none, pc_reset, pb_reset) |
    ...    | detach_request | no | choose with ue with detach status contain in prepare progress |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start the QPST progress |  ue_index=${ue_index} | cap_index=${capatibility_index} |
    ...    | ...                     |  reset_sol=${reset_sol} | detach_request=${detach_request} |
    ...
    Start the QPST progress    ue_index=${ue_index}
    ${ue_status}    run keyword and return status    Check UE device status with adb recover    ue_index=${ue_index}
    run keyword if    '${reset_sol}'=='none'    should be true    ${ue_status}    msg=with adb server kill still cannot recover ue connect
    run keyword if    ${ue_status}==${False} and '${reset_sol}'=='pc_reset'    Check ue device after pc reset    ue_index=${ue_index}
    run keyword if    ${ue_status}==${False} and '${reset_sol}'=='pb_reset'    Check ue device after pb reset    ue_index=${ue_index}
    Reserve ue with index    ue_index=${ue_index}    cap_index=${cap_index}
    ${app_status}    run keyword and return status    Start the uemanager App    ue_index=${ue_index}
    run keyword if    ${app_status}==${False}    UE soft reboot    ue_index=${ue_index}    detach_request=${detach_request}
    run keyword if    ${app_status}==${True} and ${detach_request}==${true}    Ue detach with index    ue_index=${ue_index}

Start the QPST progress
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=3s
    [Documentation]    This kw is used to Start the QPST progress
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | sleep_time_before_read_output | no | define sleep time before read output |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start the QPST progress | ue_index=${0} | sleep_time_before_read_output=3s |
    ...
    Connect to control pc enhanced    ${ue_index}
    csn.Send Command    command=tasklist | grep "QPSTServer.exe" | grep -v grep    connection=cpc_${ue_index}    timeout=5
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    sleep    ${sleep_time_before_read_output}
    ${status}    ${result}    run keyword and ignore error    csn.read_output    connection=cpc_${ue_index}
    ${status_output}    run keyword and return status    should contain    ${result}    QPSTServer.exe
    run keyword if    ${status_output}== ${False}    csn.Send Command    command=${QPSTexe}    connection=cpc_${ue_index}    timeout=5
    sleep    3s
    csn.disconnect    connection=cpc_${ue_index}

Connect to control pc enhanced
    [Arguments]    ${ue_index}=${0}    ${telnet}=${true}
    [Documentation]    This kw is used to Connect to control pc enhanced
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | telnet | no | define telnet |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to control pc enhanced | ue_index=${0} | telnet=${true} |
    ...
    ${cpc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${cpc_usrname} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${cpc_passwd} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    ${cpc_status}    run keyword and return status
    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ...              alias=cpc_${ue_index}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               reset cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword if    '${cpc_status}'=='False' and ${telnet}
    ...               Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ...               alias=cpc_${ue_index}

Connect to control pc
    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    ${alias}=cpc
    [Documentation]    This kw is used to Connect to control pc
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cpc_ip | no | the ip address of control PC |
    ...    | cpc_usrname | no | the user name to login in control PC |
    ...    | cpc_passwd | no | the user password to login in control PC |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to control pc | ${cpc_ip} | ${cpc_usrname} | ${cpc_passwd} |
    ...
    Wait Until Keyword Succeeds    5min    20s
    ...    Csn.Connect to    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}

reset cpc sshd services
    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}
    [Documentation]    This kw is used to reset cpc sshd services
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cpc_ip | no | the ip address of control PC |
    ...    | cpc_usrname | no | the user name to login in control PC |
    ...    | cpc_passwd | no | the user password to login in control PC |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | reset cpc sshd services | ${cpc_ip} | ${cpc_usrname} | ${cpc_passwd} |
    ...
    Telnet.Open connection    ${cpc_ip}
    Telnet.set timeout    20 s
    Telnet.Login    ${cpc_usrname}    ${cpc_passwd}    login_timeout=10 s    password_prompt=password:
    Telnet.Write    sc stop cygsshd
    sleep    5s
    Telnet.Write    sc config cygsshd start= Auto
    sleep    5s
    Telnet.Write    sc start cygsshd
    sleep    5s
    Telnet.close connection
    sleep    5s

Check UE device status with adb recover
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Check UE device status with adb recover
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check UE device status with adb recover | ue_index=${0} |
    ...
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    run keyword if    ${status}==${False}    Restart adb server and wait until status ready    ue_index=${ue_index}

Check UE device exist
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Check UE device exist
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | serial_number | no | define SN number of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check UE device exist | ue_index=${0} | ${serial_number} |
    ...
    Connect to control pc enhanced    ${ue_index}
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    csn.disconnect    connection=cpc_${ue_index}

Check ue device after pc reset
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Check ue device after pc reset
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check ue device after pc reset | ue_index=${0} |
    ...
    Reset UE Control PC    ue_index=${ue_index}
    sleep    1min
    Connect to control pc enhanced    ue_index=${ue_index}
    Start the QPST progress    ue_index=${ue_index}
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    should be true    ${status}    msg=with control pc reset still cannot connect to ue device

Reset UE Control PC
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Reset UE Control PC
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Reset UE Control PC | ue_index=${0} |
    ...
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect    connection=cpc_${ue_index}

Check ue device after pb reset
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Check ue device after pb reset
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check ue device after pb reset | ue_index=${0} |
    ...
    ${ue_pdu_ip} =    set variable    ${tl.ues[${ue_index}].pdu_port.pdu.addr}
    ${ue_pdu_port} =    set variable    ${tl.ues[${ue_index}].pdu_port.port_no}
    Power off on ue    ue_index=${ue_index}    ue_pdu_ip=${ue_pdu_ip}    ue_pdu_port=${ue_pdu_port}
    sleep    30s
    ${status}    run keyword and return status    Check UE device exist    ue_index=${ue_index}
    should be true    ${status}    msg=with ue PB reset still cannot connect to ue device

Power off on ue
    [Arguments]    ${ue_index}=${0}    ${ue_pdu_ip}=${UE0_PDU_IP}    ${ue_pdu_port}=${UE0_PDU_PORT}
    [Documentation]    This kw is used to Power off on ue
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_pdu_ip | no | define ue pdu ip |
    ...    | ue_pdu_port | no | define ue pdu port |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Power off on ue | ue_index=${0} | ue_pdu_ip=${UE0_PDU_IP} | ue_pdu_port=${UE0_PDU_PORT} |
    ...
    Log to console    Power off and on ue
    pdu.setup_pdu    model=facom    host=${ue_pdu_ip}    alias=ue_${ue_index}
    pdu.power_off    port=${ue_pdu_port}    pdu_device=ue_${ue_index}
    BuiltIn.Sleep    5s
    pdu.power_on    port=${ue_pdu_port}    pdu_device=ue_${ue_index}

Start the uemanager App
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    Added check point for checking if ue manager app is started after sending out startup command
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | serial_number | no | define SN number of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start the uemanager App | ue_index=${0} | ${serial_number} |
    ...
    Check UE device exist    ${ue_index}
    Connect to control pc enhanced    ${ue_index}
    csn.execute
    ...    command=adb -s ${serial_number} shell monkey -p com.nokia.android.application -c android.intent.category.LAUNCHER 1
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    Verify if ue manager app is started    cpc_alias=cpc_${ue_index}    ue_index=${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Verify if ue manager app is started
    [Arguments]    ${cpc_alias}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This KW is used for Verify if ue manager app is started
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cpc_alias | no | define cpc alias |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | serial_number | no | define SN number of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify if ue manager app is started | ${cpc_alias} | ue_index=${0} | ${serial_number} |
    ...
    ${cmd_check_ue_manager_process}    Set variable    adb -s ${serial_number} shell ps -ef|grep "com.nokia.android.application"|grep -v "grep"
    ${output_check_ue_manager_process}    csn.execute    command=${cmd_check_ue_manager_process}    connection=${cpc_alias}    timeout=20
    Should contain    ${output_check_ue_manager_process}    application

UE soft reboot
    [Arguments]    ${ue_index}=${0}    ${detach_request}=${true}
    [Documentation]    This KW is used for UE soft reboot
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | detach_request | no | define detach request |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE soft reboot | ue_index=${0} | detach_request=${true} |
    ...
    Check UE device exist    ${ue_index}
    UE Forced Reboot    ue_index=${ue_index}    detach_request=${detach_request}

UE Forced Reboot
    [Arguments]    ${ue_index}=${0}    ${detach_request}=${true}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This KW is used for UE Forced Reboot
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | detach_request | no | define detach request |
    ...    | serial_number | no | define SN number of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | UE Forced Reboot | ue_index=${0} | detach_request=${true} | ${serial_number} |
    ...
    Restart adb server and wait until status ready    ue_index=${ue_index}    serial_number=${serial_number}
    ADB reboot ue    ue_index=${ue_index}    serial_number=${serial_number}
    Log to console    wait for adb startup
    sleep    30s
    wait until keyword succeeds    2min    5s    Start the uemanager App    ${ue_index}
    Run Keyword If    ${detach_request}    wait until keyword succeeds    5min    10s    Ue detach with index    ${ue_index}

Ue detach with index
    [Arguments]    ${ue_index}=${0}    ${timeout}=60
    [Documentation]    This KW is used for Ue detach with index
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Ue detach with index | ue_index=${0} |
    ...
    ute_ue.detach_ue    UE_${ue_index}    timeout=${timeout}

Restart adb server and wait until status ready
    [Arguments]    ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}    ${sleep_time_for_adb_devices}=3s
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This KW is used for Restart adb server and wait until status ready
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | cpc_alias | define cpc alias |
    ...    | sleep_time_for_adb_devices | define sleep time for adb devices |
    ...    | serial_number | define SN number of UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Restart adb server and wait until status ready | ue_index=${0} |  cpc_alias=cpc_${ue_index} |
    ...    | ...                                            | sleep_time_for_adb_devices=3s | ${serial_number} |
    ...
    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}
    wait until keyword succeeds    3min    2s    Connect to control pc enhanced    ${ue_index}
    ${cmd_kill_server}    Set variable    adb -s ${serial_number} kill-server
    csn.send_command    command=${cmd_kill_server}    connection=${cpc_alias}
    ${kill_server_result}    csn.read_output    connection=${cpc_alias}
    Should be empty    ${kill_server_result}    msg=adb kill-server command executed with error
    Sleep    1s
    ${cmd_start_server}    Set variable    adb -s ${serial_number} start-server
    csn.send_command    command=${cmd_start_server}    connection=${cpc_alias}
    wait until keyword succeeds    3min    2s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    ...                                                                 sleep_time=${sleep_time_for_adb_devices}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

ADB Reboot UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This KW is used for ADB Reboot UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | serial_number | define SN number of UE |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | ADB Reboot UE | ue_index=${0} | ${serial_number} |
    ...
    Connect to control pc enhanced    ${ue_index}
    csn.execute    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}


Ue attach with index
    [Arguments]    ${ue_index}=${0}    ${timeout}=60
    [Documentation]    This keyword's behavior are different when using different plugins.
    ...    If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Ue reattach with index | ue_index=0 |
    ...
    ute_ue.attach_ue    UE_${ue_index}    timeout=${timeout}

Ue reattach with index
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Ue reattach with index
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Ue reattach with index | ue_index=0 |
    ...
    UE soft reboot    ue_index=${ue_index}
    Ue attach with index    ue_index=${ue_index}

Reserve ue with index
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}
    [Documentation]    This kw is used to detect ue that connect to control PC by USB.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | cap_index | no | for multi ue, should use the different capability value's index here |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Reserve ue with index | ue_index=${0} | cap_index=${0} |
    ...
    ${ue_cap} =    set variable    ${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ute_ue.require Ue    ue_alias=UE_${ue_index}    capabilities=${ue_cap}

Get the UE Ip address
    [Arguments]    ${ue_index}=${0}
    [Documentation]    This kw is used to Get the UE Ip address
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | ${IP} | return UE ip address |
    ...
    ...    Example
    ...    | Get the UE Ip address | ue_index=${0} |
    ...
    ${IP}    Get Ue Info    UE_${ue_index}    IP
    [Return]    ${IP}

Start DL traffic via iperf on Appserver
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}    ${appserver}=APPserver
    [Documentation]    This kw is used to Start DL traffic via iperf on Appserver
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_addr | no | define ue address |
    ...    | dl_time | no | define dl time |
    ...    | dl_port | no | define dl port |
    ...    | dl_throughput | no | set dl throughput |
    ...    | dl_length | no | set dl length |
    ...    | serial_number | no | define SN mumber of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start DL traffic via iperf on Appserver | ue_addr=${ue_addr} | dl_time=${duration} |
    ...    | ...                                        | dl_port=${port} | dl_throughput=${throughput} |
    ...    | ...                                        | dl_length=${buffer_size} | appserver=${appserver} |
    ...
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    ...    ELSE IF    '${appserver}'=='iperf'
    ...    wait until keyword succeeds    1 min    10 sec    AIC_UE.Connect To Iperf Server
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9
    ...    connection=${appserver}
    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=${appserver}
    [Teardown]    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=APPserver

Connect To Iperf Server
    [Arguments]    ${alias}=APPserver    ${ue_index}=${0}
    [Documentation]    This kw is used to Connect to APPserver
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | define the alias of connect |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to APPserver | alias=APPserver |
    ...
    csn.Connect to
    ...    hostname=${tl.ues[${ue_index}].ANDROID_UE.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.app_servers.APP_1.host}
    ...    username=${tl.ues[${ue_index}].ANDROID_UE.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.app_servers.APP_1.user}
    ...    password=${tl.ues[${ue_index}].ANDROID_UE.CONSTRUCTOR_PARAMETERS.configuration.data_transfer.app_servers.APP_1.password}
    ...    alias=${alias}

Connect to APPserver
    [Arguments]    ${alias}=APPserver
    [Documentation]    This kw is used to Connect to APPserver
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | define the alias of connect |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect to APPserver | alias=APPserver |
    ...
    csn.Connect to    hostname=${PC_HOST}
    ...               username=${PC_USER}
    ...               password=${PC_PASSWORD}
    ...               alias=${alias}

Start UL traffic via iperf from andriod UE
    [Arguments]    ${ue_index}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Start UL traffic via iperf from andriod UE
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ul_time | no | define ul time |
    ...    | ul_port | no | define ul port |
    ...    | ul_throughput | no | set ul throughput |
    ...    | ul_length | no | set ul length |
    ...    | serial_number | no | define SN mumber of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Start UL traffic via iperf from andriod UE | ue_index=${ue_index} | ul_time=${duration} |
    ...    | ...                                        | ul_port=${port} | ul_throughput=${throughput} |
    ...    | ...                                        | ul_length=${buffer_size} | appserver=${appserver} |
    ...
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}    serial_number=${serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'    catenate    adb -s ${serial_number} shell
    ...    iperf -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${ul_port} |grep -v grep |awk '{print $2}'
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Close the iperf process on APPserver
    [Documentation]    Author: Yang Mengli
    ...    this kw is for Close the iperf process on APPserver
    [Arguments]    ${port}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserversim
     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=APPserver

Close the iperf process on android ue
    [Arguments]    ${ue_index}    ${iperf_port}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This kw is used to Close the iperf process on android ue
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | iperf_port | no | port number used for traffic start via iperf |
    ...    | serial_number | no | define SN mumber of ue |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Close the iperf process on android ue | ue_index=0| iperf_port=default | ${serial_number} |
    ...
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command
    ...    command=adb -s ${serial_number} shell "ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $2}'|xargs kill -9"
    ...    connection=cpc_${ue_index}
    sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $2}'
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    should be empty      ${output}
    [Teardown]    Csn.disconnect    connection=cpc_${ue_index}

Connect ADB devices
    [Arguments]    ${alias}    ${serial_number}    ${sleep_time}=10s
    [Documentation]    This kw is used to Connect ADB devices
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | store ue by ue_alias  |
    ...    | serial_number | no | define SN number of ue |
    ...    | sleep_time | no | set sleep time |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect ADB devices | ${alias} | ${serial_number} | sleep_time=10s |
    ...
    ${result}    Get UE device status    alias=${alias}    serial_number=${serial_number}    sleep_time=${sleep_time}
    should not contain    ${result}    connecting
    should not contain    ${result}    offline

Get UE device status
    [Arguments]    ${alias}    ${serial_number}    ${sleep_time}=10s
    [Documentation]    This kw is used to get UE device status,UE Status Reading from "adb devices" interface
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | store ue by ue_alias  |
    ...    | serial_number | no | define SN number of ue |
    ...    | sleep_time | no | set sleep time |
    ...
    ...    | Return Value | Description |
    ...    | ${ue_status} | return status of UE |
    ...
    ...    Example
    ...    | Get UE device status | ${alias} | ${serial_number} | sleep_time=10s |
    ...
    Csn.send_command    command=adb devices    connection=${alias}    timeout=5
    Sleep    ${sleep_time}
    ${result}    csn.read output    connection=${alias}
    Should contain    ${result}    ${serial_number}
    ${ue_status_info}    ${ue_status}    Should Match Regexp    ${result}    ${serial_number}\[\\s,\\t\]+(\\w+)
    [Return]    ${ue_status}


Start Call For Qualcomm
    [Arguments]    ${direction}=dl    ${throughput}=100    ${duration}=120
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${buffer_size}=1024B
    [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | yes | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | direction | The traffic direction, ul or dl |
    ...    | duration | Duration of traffic |
    ...    | throughput | Throughput of new data transfer |
    ...    | buffer_size | Send data package size |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | inseego.Start traffic | ${ue0_type} | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    ute_ue.Start Data Transfer    duration=${duration}s    throughput=${throughput}bits/sec    dt_name=DT_${dt_index}
    ...    ue_alias=UE_${ue_index}    protocol=udp    direction=${direction}    packet_size=${buffer_size}

################################## spark relevant common KW ##################################
spark.Prepare UE
    [Arguments]    ${ue_alias}    ${ue_index}=${0}    ${reset_sol}=${None}    ${power_reset}=true
    ...            ${detach_request}=true    &{kwargs}
    [Documentation]    This kw is used to Prepare UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | reset_sol | no | ue has three choose (none, pc_reset, pb_reset): |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | AIC_UE.spark.Prepare UE | ${ue_alias} | ue_index=${0} | reset_sol=${None} |
    ...
    log    ${power_reset} and ${detach_request} is not used.
#    SigSpark.require_ue    ue_alias=${ue_alias}    power_reset=${power_reset}    detach_request=${detach_request}
#    ...                    index=${ue_index}    reset_sol=${reset_sol}
    SigSpark.require_platform    ue_alias=${ue_alias}    index=${ue_index}    reset_sol=${reset_sol}

################################## UE ATTACH ##################################
spark.Ue Power Off And On
    [Arguments]    ${ue_alias}=UE_${0}    &{kwargs}
    [Documentation]    This kw is used to attach UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.UE Attach | ${ue_alias} |
    ...
    SigSpark.power_off    ue_alias=${ue_alias}
    sleep    10s
    SigSpark.power_on    ue_alias=${ue_alias}

################################## START DATA TRANSFER ##################################
spark.Start traffic
    [Arguments]    ${direction}=dl    ${duration}=60    ${throughput}=100    ${ue_index}=${0}
    ...            ${ue_alias}=UE_${0}    ${dt_name}=download
    ...            ${iperf_port}=default    ${protocal}=UDP    ${multidrb_QoS_dest}=${None}
    ...            ${connection_type}=APPserver    ${ue_mode}=none    ${RemoteHost}='10.97.65.244',
    ...            ${Port}='8018'    ${Account}='ute'    ${Password}='ute'    ${RemoteFile}='/Download/10G'
    ...            ${FileSize}='1024000'    ${EQIndex}=${None}    &{kwargs}
   [Documentation]    This kw is used for start traffic
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | direction | no | The traffic direction, ul or dl |
    ...    | duration | no | Duration of traffic |
    ...    | throughput | no | Throughput of new data transfer |
    ...    | protocal | no | Traffic protocal type. E.G udp/tcp |
    ...    | iperf_port | no | port number used for traffic start via iperf |
    ...    | dt_name | no | alias name for created data transfer |
    ...    | multidrb_QoS_dest | no |  <optional> default None |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.Start traffic | ue_index=${0} | direction=dl | dt_index=${0} | throughput=110M | duration=600 |
    ...
    log    ${Port} is not used.
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${new_port}    set variable if    '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${Receive_state}    SigSpark.start_data_transfer    ue_alias=${ue_alias}    direction=${direction}
    ...                          dt_name=${dt_name}    duration=${duration}    throughput=${throughput}/sec
    ...                          iperf_port=${new_port}    protocol=${protocal}    multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                          connectiontype=${connection_type}    ue_mode=${ue_mode}    RemoteHost=${RemoteHost}
    ...                          Port=${new_port}    Account=${Account}     Password=${Password}
    ...                          RemoteFile=${RemoteFile}     FileSize=${FileSize}    eqindex=${EQIndex}
    [Return]    ${Receive_state}

spark.Start VONR Call
    [Arguments]     ${ue_alias}=UE_${0}     ${index}=None    ${timeout}=${30}    ${command}=ATD006688;   &{kwargs}
   [Documentation]    This kw is used for start vonr call with spark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | index | no | define index |
    ...    | timeout | no | defind the timeout of send AT |
    ...    | command | no | define AT command you need to send |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.Start VONR Call | command=ATD+6688 |
	...
    SigSpark.start_vonr    ue_alias=${ue_alias}    index=${index}
    ...                    timeout=${timeout}    command=${command}
spark.Stop VONR Call
    [Arguments]     ${ue_alias}=UE_${0}     ${index}=None    ${timeout}=${30}    ${command}=ATH;   &{kwargs}
   [Documentation]    This kw is used for start vonr call with spark
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | index | no | define index |
    ...    | timeout | no | defind the timeout of send AT |
    ...    | command | no | define AT command you need to send |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.Stop VONR Call | command=ATD+6688 |
	...
    SigSpark.stop_vonr    ue_alias=${ue_alias}    index=${index}
    ...                    timeout=${timeout}    command=${command}
##################################  CHECK THROUGHPUT ##################################
spark.Check throughput
    [Arguments]    ${ue_alias}=UE_${0}    ${ue_index}=${0}    ${direction}=dl    ${expected_throughput}=100   &{kwargs}
    [Documentation]    This kw is used to Check throughput with spark
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | direction | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | expected_throughput | no |<str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.Check throughput | ue_alias=UE_${0} | direction=dl | expected_throughput=100 |
    ...
    log    ${ue_index} and ${expected_throughput} is not used
#    ${output}    SigSpark.check_throughput_on_ue    ue_alias=${ue_alias}
    ${output}    SigSpark.check_throughput    ue_alias=${ue_alias}
    run keyword if    '${direction}'=='ul'    set test variable     ${tput}    ${output[0]}
    ...            ELSE IF    '${direction}'=='dl'    set test variable    ${tput}    ${output[1]}
#    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
#    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
#    should be true    ${tput} > ${expected_throughput}
    [Return]    ${tput}

################################## STOP DATA TRANSFER ##################################
spark.Stop traffic
    [Arguments]    ${direction}=dl    ${ue_alias}=UE_${0}    ${ue_index}=${0}
    ...            ${iperf_port}=default    ${EQindex}=${None}    &{kwargs}
    [Documentation]    This kw is for Stop data transfer with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | direction | no | The traffic direction, ul or dl |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | dt_name | no | <str> store traffic by ue_alias |
    ...    | iperf_port | no | The port value of traffic, only used in stop DL traffic eg: 50001 |
    ...
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if    '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    SigSpark.stop_data_transfer    ue_alias=${ue_alias}    direction=${direction}
    ...     iperf_port=${port}    eqindex=${EQindex}


################################## power on ##################################
spark.UE power on
    [Arguments]    ${ue_alias}=UE_${0}    &{kwargs}
    [Documentation]    This kw is used to power on UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.UE power on | ue_alias=UE_${0} |
    ...
    SigSpark.power_on    ue_alias=${ue_alias}

################################## power off ##################################
spark.UE power off
    [Arguments]    ${ue_alias}=UE_${0}    &{kwargs}
    [Documentation]    This kw is used to power off UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.UE power off | ue_alias=UE_${0} |
    ...
    SigSpark.power_off    ue_alias=${ue_alias}

################################## start log##################################
spark.start log
    [Arguments]    ${ue_alias}=UE_${0}    ${cmd}=StartLog    &{kwargs}
    [Documentation]    This kw is used to start log with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.start log | ue_alias=UE_${0} |
    ...
    SigSpark.start_log    ue_alias=${ue_alias}    cmd=${cmd}

spark.start one log
    [Arguments]    ${ue_alias}=UE_${0}    ${cmd}=StartOneLog    &{kwargs}
    [Documentation]    This kw is used to start log with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.start log | ue_alias=UE_${0} |
    ...
    SigSpark.start_one_log    ue_alias=${ue_alias}    cmd=${cmd}

################################## stop log##################################
spark.stop log
    [Arguments]    ${ue_alias}=UE_${0}    ${logname}=UE_LOG.xml    ${stop_log_cmd}=StopLog    &{kwargs}
    [Documentation]    This kw is used to stop log with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | logname | no | define log name |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.stop log | ue_alias=UE_${0} | logname=${logname} |
    ...
    SigSpark.stop_log    ue_alias=${ue_alias}    logname=${logname}    stop_log_cmd=${stop_log_cmd}


spark.stop one log
    [Arguments]    ${ue_alias}=UE_${0}    ${logname}=UE_LOG.xml    ${stop_log_cmd}=StopOneLog    &{kwargs}
    [Documentation]    This kw is used to stop log with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | logname | no | define log name |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.stop log | ue_alias=UE_${0} | logname=${logname} |
    ...
    SigSpark.stop_one_log    ue_alias=${ue_alias}    logname=${logname}    stop_log_cmd=${stop_log_cmd}


################################## UE ATTACH ##################################
spark.UE Attach
    [Arguments]    ${ue_alias}=UE_${0}    ${attach_mode}=5G_SA    &{kwargs}
    [Documentation]    This kw is used to attach UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | attach_mode | 5G_SA/5G_NSA |
    ...
    ...    | Return Value | Description |
    ...    | ${attach_res} | return attach_res |
    ...
    ...    Example
    ...    | spark.UE Attach1 | ${ue_alias} |
    ...
    ${attach_res}    SigSpark.attach_ue    ue_alias=${ue_alias}    attach_mode=${attach_mode}
    [Return]    ${attach_res}

################################## UE DETACH ##################################
spark.UE Detach
    [Arguments]    ${ue_alias}=UE_${0}    &{kwargs}
    [Documentation]    This kw is used to dettach UE with spark.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | no | The type of target UE, given in lowercase. E.G  huawei / Huawei.sigspark |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | spark.UE Detach | ue_alias=UE_${0} |
    ...
    SigSpark.detach_ue    ue_alias=${ue_alias}

spark.Get UE IP address
    [Arguments]    ${ue_index}=${0}    ${apn}=wap1.nokia.com
    [Documentation]    This kw is used to Get UE IP address
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_index | no | he list index from tl.ues[], it will use the index UE for reserve |
    ...    | apn | no | define which apn is used for your UE |
    ...
    ...    | Return Value | Description |
    ...    | ${UE_IP} | return UE ip address |
    ...
    ...    Example
    ...    | spark.Get UE IP address | ue_alias=UE_${ue_index} | apn=${apn} |
    ...
    ${UE_IP}    create_pdu_session    ue_alias=UE_${ue_index}    apn=${apn}
    [Return]    ${UE_IP}
    [Teardown]    release_pdu_session    ue_alias=UE_${ue_index}

################################## dingli uebox ##################################
pioneer.Detect UE and get UEs info
    [Arguments]    ${alias}=pioneer    ${port}=30999   ${ue_index}=${0}
    [Documentation]    Prepare UEs resource.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | port | no |  ip address of control pc the pioneer service running on |
    ...    | ue_index | no |  The list index from tl.ues[], it will use the index UE for reserve |
    ...
    ...    | Return Value | Description |
    ...    | @{UEs_info} | summary information of ue |
    ...
    ...    Example
    ...    | pioneer.Pioneer Multi-UE L3 Call | ${ue_alias} | direction=${0} |
    ...
    log    ${port} is not used
    client.setup_service
    ...    host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    port=30999
    ...    ssh_username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ssh_password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${alias}
    @{UEs_info}    client.prepare_ues    service=${alias}
    [Return]    @{UEs_info}    ${alias}

pioneer.Start UL Traffic
    [Arguments]    ${protocol}=UDP     ${address}=10.106.104.168    ${port}=54015
    ...        ${duration}=60     ${buffersize}=0    ${packetsize}=1400
    ...        ${iperftype}=${0}    ${direction}=${0}     ${bandwidth}=2500000
    ...        ${ue_alias}=UE_${0}    ${ue_index}=${0}    ${iperf_port}=default
    [Documentation]    This kw is used for start ul traffic
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | protocol | yes | traffic protocol, e.g. 'UDP', 'TCP', 'UDP' by default |
    ...    | address | yes | target(e.g. app server) ip address |
    ...    | port | yes |  target port NO. |
    ...    | duration | yes |  time last for traffic in seconds |
    ...    | buffersize | yes |  buffersize in KB |
    ...    | packetsize | yes |  acketsize in Byte |
    ...    | iperftype | yes |  iperf type, e.g 0: iperf2, 1: iperf3. |
    ...    | direction | yes |  traffic direction, e.g 0: UpLink, 1: DownLink. |
    ...    | bandwidth | yes |  bandwidth in Kbps, optional if protocol is TCP.|
    ...    | ue_alias | yes |   <str> store ue by ue_alias |
    ...    | ue_index | yes |   The list index from tl.ues[], it will use the index UE for reserve |
    ...    | iperf_port | no |   port number used for traffic start via iperf |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | pioneer.Start traffic | ${ue_alias} | direction=${0} |
    ...
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if    '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    client.starttraffic     protocol=${protocol}    address=${address}    port=${port}
    ...                         testtime=${duration}      buffersize=${buffersize}   packetsize=${packetsize}
    ...                         iperftype=${iperftype}    direction=${direction}        bandwidth=${bandwidth}
    ...                         ue=${ue_alias}


pioneer.Stop UL Traffic
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is for Stop data transfer with pioneer.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | pioneer.Stop traffic | ${ue_alias} |
    ...
    client.stop_test     ue=${ue_alias}


pioneer.Start DL Traffic
    [Arguments]     ${dl_time}=60    ${dl_port}=8018    ${dl_throughput}=60M
    ...             ${dl_length}=1024B    ${connection}=APPserver   ${hostname}=10.97.65.244
    ...             ${username}=ute   ${password}=ute
    [Documentation]    This kw is used for start dl traffic
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | dl_time | yes | time last for traffic in seconds |
    ...    | dl_port | yes |  target port NO. |
    ...    | dl_throughput | yes |  time last for traffic in seconds |
    ...    | dl_length | yes |  buffersize in KB |
    ...    | connection | yes | define the alias of connect |
    ...    | hostname | no | Iperf Server IP |
    ...    | username | no | username to connect Iperf Server |
    ...    | password | no | password to connect Iperf Server |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | pioneer.Start DL Traffic | ${dl_time} | dl_port=8018 |
    ...
    wait until keyword succeeds    1 min    10 sec    pioneer.Connect To Iperf Server    hostname=${hostname}
    ...         username=${username}   password=${password}   alias=${connection}
    ${cmd}=    Catenate     ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9
    csn.execute    command=${cmd}    connection=${connection}
    csn.send command
    ...    command=iperf -c ${pioneer_ue_ip} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=${connection}
    [Teardown]    csn.disconnect    connection=${connection}


pioneer.Stop DL Traffic
    [Arguments]    ${port}=8018    ${alias}=APPserver
    [Documentation]    This kw is used for stop pioneer dl traffic
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | iperf_port | port number used for traffic start via iperf |
    ...    | alias | define the alias of connect |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.Stop DL Traffic | port=8018 | alias=APPserver |
    ...
    wait until keyword succeeds    1 min    10 sec    pioneer.Connect To Iperf Server    alias=${alias}
    ${cmd}=    Catenate    ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9
    csn.execute    command=${cmd}    connection=${alias}


pioneer.Check Throughput
    [Arguments]    ${ue_alias}=UE_${0}    ${direction}=dl    ${expected_throughput}=100    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | direction | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | expected_throughput | no |<str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.Check Throughput | ue_alias=UE_${0} | direction=dl | expected_throughput=100 |
    ...
    ${output}    client.getparammac    ue=${ue_alias}
    ${Tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output['Param']['MACUL']} / 1000 / 1000
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output['Param']['MACDL']} / 1000 / 1000
    should be true    ${Tput} > ${expected_throughput}
    [Return]    ${Tput}


################################## UE DETACH ##################################
pioneer.UE Detach
    [Arguments]    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to dettach UE with pioneer.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_type | no | The type of target UE, given in lowercase. E.G  huawei / Huawei.pioneer |
    ...    | ue_index | no | The list index from tl.ues[], it will use the index UE for reserve |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.UE Detach | ue_alias=UE_${0} |
    ...
    client.poweroff     ue=${ue_alias}   until_timeout=${30}
    sleep    10s

pioneer.Prepare UE
    [Arguments]    ${imei}    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to Prepare UE with pioneer.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | imei | yes | imei to specify the ue |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.Prepare UE |imei='865697040198084' | ue_alias=UE_${0} |
    ...
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue0_type}
    client.require_ue    imei=${imei}    service=pioneer    ue_alias=${ue_alias}


pioneer.UE Attach
    [Arguments]    ${apn}=stdata1    ${ue_alias}=UE_${0}
    [Documentation]    This kw is used to attach UE with pioneer.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...    | attach_mode | 5G_SA/5G_NSA |
    ...
    ...    | Return Value | Description |
    ...
    ...    Example
    ...    | pioneer.UE Attach | apn=stdata1 | ue_alias=UE_${0} |
    ...
    run keyword and ignore error    client.poweroff     ue=${ue_alias}   until_timeout=${30}
    sleep    10s
    client.poweron     ue=${ue_alias}   until_timeout=${30}
    sleep    10s
    &{ue_upd_info_dict}    client.getpduinfo   apn=${apn}    ue=${ue_alias}
    ${ue_ip}    Set Variable    ${ue_upd_info_dict}[Param]
    Set test variable     ${pioneer_ue_ip}    ${ue_ip}[IP]
    Should Not Be Empty    ${pioneer_ue_ip}

pioneer.Ue Power Off And On
    [Arguments]    ${ue_alias}=UE_${0}    &{kwargs}
    [Documentation]    This kw is used to attach UE with spark.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_alias | no | <str> store ue by ue_alias |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.Ue Power Off And On | ${ue_alias} |
    ...
    client.poweroff     ue=${ue_alias}   until_timeout=${30}
    sleep    10s
    client.poweron     ue=${ue_alias}   until_timeout=${30}
    sleep    2s


pioneer.Connect To Iperf Server
    [Arguments]    ${hostname}=10.97.65.244    ${username}=ute   ${password}=ute    ${alias}=APPserver
    [Documentation]    This kw is used to Connect to APPserver
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias | no | define the alias of connect |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | pioneer.Connect To Iperf Server | alias=APPserver |
    ...
    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}


pioneer.Get Parameter Summary Statistics Result
    [Arguments]    ${ue_param_list}    ${ue_alias}=ue_1
    [Documentation]    This kw is used for get parameter statistics result
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ue_param_list | yes | the list of parameter name |
    ...    | ue_alias | yes |  define the alias of connect |
    ...
    ...    | Return Value | Description |
    ...    | data_res | parameter statistics result|
    ...
    ...    Example
    ...    | pioneer.Get Parameter Summary Statistics Result | ${ue_param_list} | ${ue_alias}=ue_1 |
    ...
    ${data_res}    client.get_param_summary_statistics_result   paramname=${ue_param_list}    ue=${ue_alias}
    [Return]   ${data_res}
