*** Settings ***
Documentation


Library        taf.sw.dcap.rd		   WITH NAME	   DCAP


*** Keywords ***
Connect To DCAP Server
    [Arguments]    ${host}=10.56.221.45     ${port}=443    ${username}=dcapuser
    ...            ${password}=dcapadmin!    ${rd_version}=dcapv3
    ...            ${secure}=${True}    ${alias}=dcap
    [Documentation]    Used to connect to dcap server

    ...    |  Input Parameters | Man. | Description |
    ...    | host | yes | dcap server ip address  |
    ...    | port | yes | dcap server port  |
    ...    | username | no | user name to log in dcap server  |
    ...    | password | no | password to log in dcap server  |
    ...    | rd_version | no | dcap api version   If user wants to run keywords from v2 version please pass rd_version=`dcapv2`
    ...    If user wants to run keywords from v3 version please pass rd_version=`dcapv3`
    ...    would suggest to use the latest version as those provide more info.|
    ...    | secure | no | true for https, false for http |
    ...    | alias | no | the instance alias |
    ...    | Return Value | Description |
    ...    Example
    ...    | Connect To DCAP | ${host} | ${port} |
    ...
    DCAP.connect_to    host=${host}    port=${port}   username=${username}    password=${password}
    ...                rd_version=${rd_version}    secure=${secure}    alias=${alias}

Create Bts Under DCAP Server
    [Arguments]    ${bts_web_ip}=10.56.221.45     ${bts_web_port}=443    ${bts_username}=Nemuadmin
    ...            ${bts_password}=nemuuser    ${bts_alias}=dcap    ${alias}=dcap
    [Documentation]    create the bts under dcap server

    ...    |  Input Parameters | Man. | Description |
    ...    | bts_web_ip | yes | bts ip  |
    ...    | bts_web_port | yes | bts port  |
    ...    | bts_username | no | bts user name  |
    ...    | bts_password | no | bts password  |
    ...    | bts_alias | no | alias for bts
    ...    | alias | no | the instance alias, same as alias in Connect To DCAP Server
    ...    | Return Value | Description |
    ...    Example
    ...    | Connect To DCAP | ${host} | ${port} |
    ...
    ${ret_dict}    DCAP.create_bts    host=${bts_web_ip}    port=${bts_web_port}    username=${bts_username}    password=${bts_password}
    ...                bts_alias=${bts_alias}    connection=${alias}
    [RETURN]    ${ret_dict}


Get All Bts Info Under DCAP Server
    [Arguments]    ${alias}=dcap
    ${bts_all_info}    DCAP.get_all_bts_info    connection=${alias}
    [RETURN]    ${bts_all_info}


Make Sure BTS Added In DCAP
    [Arguments]    ${bts_dic}    ${alias}=dcap
    [Documentation]    Used to make sure the BTS is added in DCAP.

    ...    | Input Parameters | Man. | Description |
    ...    | bts_dic | yes | bts info as dict type |
    ...    | alias | No | the instance alias, same as alias in Connect To DCAP Server |
    ...    | Return Value | Description |
    ...    |  |  |
    ...    Example
    ...    | Make Sure BTS Added In DCAP | ${bts_dic}  | ${alias}
    ...
    ${bts_web_ip}      Set Variable    ${bts_dic['host']}
    ${bts_username}    Set Variable    ${bts_dic['username']}
    ${bts_password}    Set Variable    ${bts_dic['password']}
    ${bts_port}        Set Variable    ${bts_dic['port']}
    ${all_bts_info}    Get All Bts Info Under DCAP Server
    ${is_bts_exist}    set variable    ${false}
    FOR    ${info}    IN    @{all_bts_info}
        ${ip}     Set Variable    ${info['host']}
        Run Keyword If    '${ip}'=='${bts_web_ip}'    Set Test Variable  ${is_bts_exist}  ${true}
        Run Keyword If    ${is_bts_exist}    Exit For Loop
    END
    log to console    is_bts_exist=${is_bts_exist}
    Run Keyword If    not ${is_bts_exist}    Create Bts Under DCAP Server    bts_web_ip=${bts_web_ip}    bts_web_port=${bts_port}
    ...    bts_username=${bts_username}    bts_password=${bts_password}    bts_alias=${bts_web_ip}    alias=${alias}


Start Trace Log In DCAP
    [Arguments]    ${bts_dic}    ${tag}=start_trace    ${force}=${True}
    ...            ${gnb_trace_profile}=dcap-lite-default
    ...            ${vcu_trace_profile}=None
    ...            ${vdu_trace_profile}=None
    ...            ${enb_trace_profile}=None
    ...            ${bts_trace_profile}=None
    ...            ${gnb_custom_profile_list}=None
    ...            ${enb_custom_profile_list}=None
    ...            ${vdu_custom_profile}=None
    ...            ${vcu_custom_profile}=None
    ...            ${wait_for_activation}=${False}
    ...            ${alias}=dcap
    ...            ${timeout}=${400}
    [Documentation]    Used to start trace under DCAP.
    ...    | Input Parameters | Man. | Description |
    ...    | bts_dic | yes | bts info as dict type |
    ...    | tag | no | the tag of this StartTraceBody. |
    ...    | force | no | signifying whether the trace should
    ...      force a shutdown of any previously running traces.
    ...      Defaults to true.
    ...      If the trace startup finds an ongoing trace and 'force' is
    ...      set to false, the startup fails due to ongoing traces error.
    ...      If the 'force' flag is set to true, the startup first shuts
    ...      down any ongoing traces and then continues with the startup |
    ...    | gnb_trace_profile | no | the id or name of the gNB (5G) start trace |
    ...    | enb_trace_profile | no | the id or name of the LTE (ENB)  start trace|
    ...    | bts_trace_profile | no | the id or name of the BTS start trace|
    ...    | gnb_custom_profile_list | no | The gNB (5G) custom profile name list of the start trace to be started.
    ...      e.g : [cp_5g, controlPlane5g, pmFiles5g, condor5gSyslog, SCF5g,
    ...      L2Ps_Component, L2Lo_Component, L2HiRlc_Component, L2HiPdcp_Component,
    ...      L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa,
    ...      bip_interface_mirroring, L1stream, Tracer_5g, l1IqTracer] |
    ...    | enb_custom_profile_list | no | The LTE (ENB) custom profile name list of the start trace to be started.
    ...      e.g : [lteTracer_4g, condor4gTti, condor4gAa, condor4gSyslog,
    ...      pmFiles4g, scf4g, cp_4g, controlPlane4g, condor4gL2, l1Iq4g] |
    ...    | vdu_custom_profile | The VDU custom profile name list of the start trace to be started.
    ...      e.g : [snapshotVdu, L1StreamVdu, L2Ps_Component, L2Lo_Component, L2HiRlc_Component,
    ...      L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa] |
    ...    | vcu_custom_profile | no | The VCU custom profile name list of the start trace to be started.
    ...      e.g : [snapshotVcu, L2Ps_Component, L2Lo_Component, L2HiRlc_Component,
    ...      L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa, L2HiPdcp_Sherpa] |
    ...    | vcu_trace_profile | no | the id or name of the vCU start trace|
    ...    | vdu_trace_profile | no | the id or name of the vDU start trace|
    ...    | wait_for_activation | no | f user wants to confirm if the traces are started and it is in "running"
    ...    state. pass wait_for_activation=True |
    ...    | alias | No | the instance alias, same as alias in Connect To DCAP Server |
    ...    | Return Value | Description |
    ...    | trace_id | dcap trace id |
    ...    Example
    ...    | Start Trace Log In DCAP | ${bts_dic} | vcu_trace_profile=None
    ...        | vdu_trace_profile=dcap-lite-default
    ...
    ${trace_info}    DCAP.start_trace    bts=${bts_dic}    tag=${tag}    force=${force}    connection=${alias}
    ...    gnb_trace_profile=${gnb_trace_profile}
    ...    vcu_trace_profile=${vcu_trace_profile}
    ...    vdu_trace_profile=${vdu_trace_profile}
    ...    enb_trace_profile=${enb_trace_profile}
    ...    bts_trace_profile=${bts_trace_profile}
    ...    gnb_custom_profile_list=${gnb_custom_profile_list}
    ...    enb_custom_profile_list=${enb_custom_profile_list}
    ...    vdu_custom_profile=${vdu_custom_profile}
    ...    vcu_custom_profile=${vcu_custom_profile}
    ...    wait_for_activation=${wait_for_activation}
    ...    timeout=${timeout}
    [Return]    ${trace_info}[tracer_id]

Stop Trace Log In DCAP
    [Arguments]    ${btsip}    ${alias}=dcap
    [Documentation]    Used to stop trace under DCAP.
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | alias | No | the instance alias, same as alias in Connect To DCAP Server |
    ...    Example
    ...    | Stop Trace Log In DCAP | btsip=${0} | alias=dcap
    ...
    dcap.stop_trace    trace_id=${btsip}    connection=${alias}
