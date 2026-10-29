*** Settings ***
Documentation    author: Heng Liangliang
   ...    contact: liangliagn.heng@nokia-sbell.com
   ...   squad group: SG_07
   ...   feature : CB007732

Resource   Common.robot


*** Variables ***
@{gnb_ip_list}      ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WTS_IP}           ${tl.test_pc.default_ssh_connection_details.addr}
${WTS_USERNAME}     ${tl.test_pc.default_ssh_connection_details.username}
${WTS_PASSWORD}     ${tl.test_pc.default_ssh_connection_details.password}
${WTS_ALIAS}        WTS_ALIAS

${WTS_DIR}          /home/ute/WTS_2601/
${WTS_CFG}          TL845.cfg

${tce_ip}   10.57.195.83
${tce_ip_backup}   10.57.195.82


*** Keywords ***
Connet to WTS VM
    [Documentation]  Establish a ssh connection to the WTS machine where the simulator is present
    csn.Connect to     hostname=${WTS_IP}
    ...                username=${WTS_USERNAME}
    ...                password=${WTS_PASSWORD}
    ...                alias=${WTS_ALIAS}


Disconnect to WTS VM
    csn.Disconnect    connection=${WTS_ALIAS}


Start WTS on UTE
    [Arguments]    ${WTS_CFG}
    Log To Console    Starting WTS ... with WTS_Config '${WTS_CFG}'
    ${cfg_pattern}    Set Variable     CHANGE STATE: CONFIGURED
#    ${cfg_pattern}    Set Variable     Script completed
#    ${start_pattern}    Set Variable     NG link is Up
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}   ssh_pass=${WTS_PASSWORD}   alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}   ssh_pass=${WTS_PASSWORD}
    ute_wtssim.Start Egate Process
    ${cfg_output}    ute_wtssim.Execute Egate Command And Wait For Data    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=${cfg_pattern}
    ...   timeout=2min
    Wait Until Keyword Succeeds    120s    15s
    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is CONFIGURED
#    ${start_output}    ute_wtssim.Execute Egate Command And Wait For Data    start    pass_regexp=${start_pattern}   timeout=5min
    ${start_output}    ute_wtssim.Execute egate command and wait for data    start    return_output=True     pass_regexp=SimMode is ready now
    ...  timeout=5min


Check NG link Up
    Log To Console    start to check NG link ...
    # sleep  5min
    ute_wtssim.Execute Egate Command    sim_log_set flush  timeout=1min
    ${value}    run     command=cat ${WTS_DIR}/egate_console.log |grep "NG link is Up"
    FOR  ${var}   IN    @{gnb_ip_list}
       Should Contain   ${value}   IP:${var} NG link is Up
    END
    Log   NG Link to gNB are all now Active

Restart WTS on UTE VM
      Log to console    start egate again ......
      Connet to WTS VM
      Kill egate and edaemon
      Start WTS on UTE     WTS_CFG=${WTS_CFG}
      Check NG link Up

UE Status Checking
    [Arguments]  ${id}=1
    ${output}   Wait Until Keyword Succeeds    120s    15s  ute_wtssim.Execute Egate Command
    ...   return_output=True   pass_regexp=${SPACE}ACTIVE ${SPACE}  cmd=ue_disp id=${id}

AMF Disp Trace Info
    [Arguments]  ${id}=1
    ${output}   ute_wtssim.Execute Egate Command   return_output=True   fail_regexp=OFF
     ...  cmd=amf_disp_trace_info id=${id}

Trace Start
     [Arguments]  ${id}=1   ${trace_plmn}=460:02   ${trace_ref_id}=1   ${trace_rec_session_ref_id}=1   ${ifaces_to_trace}=Xn-C,NG-C,Uu
                  ...   ${trace_depth}=maximum   ${tce_ip}=${tce_ip}
     ${command_pre}   Set Variable   ng_ue_trace_start id=${id} trace_plmn=${trace_plmn} trace_ref_id=${trace_ref_id}
     ${command_middle}    Set Variable    ${SPACE}trace_rec_session_ref_id=${trace_rec_session_ref_id}
     ${command_last}    Set Variable    ${SPACE}ifaces_to_trace=${ifaces_to_trace} trace_depth=${trace_depth} tce_ip=${tce_ip}
     ${output}   ute_wtssim.Execute Egate Command   return_output=True   fail_regexp=OFF
     ...  cmd=${command_pre}${command_middle}${command_last}

Trace Stop
     [Arguments]  ${id}=1   ${trace_plmn}=460:02   ${trace_ref_id}=1   ${trace_rec_session_ref_id}=1
     ${command_pre}   Set Variable   ng_ue_trace_stop id=${id} trace_plmn=${trace_plmn} trace_ref_id=${trace_ref_id}
     ${output}   ute_wtssim.Execute Egate Command   return_output=True   fail_regexp=OFF
     ...  cmd=${command_pre}${SPACE}trace_rec_session_ref_id=${trace_rec_session_ref_id}

Initial Context Setp Request
    [Arguments]  ${id}=1   ${object_id}=1   ${location_reporting_reference_id}=1  ${trace_activation}=on   ${trace_plmn}=460:02
    ...   ${trace_ref_id}=1   ${trace_rec_session_ref_id}=1   ${ifaces_to_trace}=Xn-C,NG-C,Uu   ${trace_depth}=maximum
    ...   ${tce_ip}=${tce_ip}
    Log To Console   Initial Context Setp Request

    ${command_1}   Set Variable   amf_ue_ics_param id=${id} object_id=${object_id}
    ${command_2}   Set Variable   ${SPACE}location_reporting_reference_id=${location_reporting_reference_id} trace_activation=${trace_activation}
    ${command_3}   Set Variable   ${SPACE}trace_plmn=${trace_plmn} trace_ref_id=${trace_ref_id} trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ${command_4}   Set Variable   ${SPACE}trace_depth=${trace_depth} ifaces_to_trace=${ifaces_to_trace} tce_ip=${tce_ip}
    ${output}   ute_wtssim.Execute Egate Command     return_output=True   fail_regexp=OFF
    ...   cmd=${command_1}${command_2}${command_3}${command_4}

Stop Subscriber trace for ICS
    [Arguments]  ${id}=1   ${object_id}=1   ${location_reporting_reference_id}=1  ${trace_activation}=off
    Log To Console   Stop Subscriber trace for ICS

    ${command_1}   Set Variable   amf_ue_ics_param id=${id} object_id=${object_id}
    ${command_2}   Set Variable   ${SPACE}location_reporting_reference_id=${location_reporting_reference_id} trace_activation=${trace_activation}
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   fail_regexp=OFF
     ...   cmd=${command_1}${command_2}

NGAP Handover Request
     [Arguments]  ${id}=1   ${ue}=1   ${trace_activation}=on   ${trace_plmn}=460:02  ${trace_ref_id}=1   ${trace_rec_session_ref_id}=1
     ...   ${ifaces_to_trace}=NG-C,Uu   ${trace_depth}=maximum  ${tce_ip}=${tce_ip}
     ${command_1}   Set Variable   amf_ue_ng_handover_request_param id=${id} ue=${ue} trace_activation=${trace_activation}
     ${command_2}   Set Variable   ${SPACE}trace_plmn=${trace_plmn} trace_ref_id=${trace_ref_id}
     ${command_3}   Set Variable   ${SPACE}trace_rec_session_ref_id=${trace_rec_session_ref_id} trace_depth=${trace_depth} tce_ip=${tce_ip}
     ${command_4}   Set Variable   ${SPACE}ifaces_to_trace=${ifaces_to_trace}
     ${output}   ute_wtssim.Execute Egate Command      return_output=True   fail_regexp=OFF
     ...   cmd=${command_1}${command_2}${command_3}${command_4}

Stop Trace of NGAP Handover Request
     [Arguments]  ${id}=1   ${ue}=1   ${trace_activation}=off
     ${command_1}   Set Variable   amf_ue_ng_handover_request_param id=${id} ue=${ue} trace_activation=${trace_activation}
     ${output}   ute_wtssim.Execute Egate Command      return_output=True   fail_regexp=OFF
     ...   cmd=${command_1}

Location Reporting Control
     [Arguments]  ${ue}=1   ${event_type}=direct
     ${command}   Set Variable   ue_send_location_reporting_control ue=${ue} event_type=${event_type}
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   fail_regexp=OFF   cmd=${command}

AMF Status Indication
     [Arguments]  ${id}=1   ${guami_index}=1  ${timer_guami_removal}=on
     ${command}   Set Variable   send_amf_status_indication id=${id} guami_index=${guami_index} timer_guami_removal=${timer_guami_removal}
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   fail_regexp=OFF   cmd=${command}

UE Tnla Binding Release Request
     [Arguments]  ${id}=1     ${ue}=1
     ${command}   Set Variable   send_ue_tnla_binding_release id=${id} ue=${ue}
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   fail_regexp=OFF   cmd=${command}

AMF Restore Guamis
     [Arguments]  ${id}=1  ${guami_index}=1
     ${command}   Set Variable  amf_restore_guamis id=${id} guami_index=${guami_index}
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   pass_regexp=Acknowledge   cmd=${command}

Restart the Session
     [Arguments]    ${WTS_CFG}=SA_AZQL_classical_158.cfg
     ${command}   Set Variable   re
     ${output}   ute_wtssim.Execute Egate Command     return_output=True   pass_regexp=INIT   cmd=${command}
     ${cfg_output}    ute_wtssim.Execute Egate Command And Wait For Data    cfg file\=${WTS_DIR}/${WTS_CFG}    pass_regexp=${cfg_pattern}
     ...    timeout=2min
     Wait Until Keyword Succeeds    120s    15s
    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is CONFIGURED
#    ${start_output}    ute_wtssim.Execute Egate Command And Wait For Data    start    pass_regexp=${start_pattern}   timeout=5min
    ${start_output}    ute_wtssim.Execute egate command and wait for data    start    return_output=True     pass_regexp=SimMode is ready now
    ...  timeout=5min

Kill egate and edaemon
     Log To Console     kill egate and edaemon start...
     Run Keyword And Ignore Error   run     command=sudo killall edaemon egate
     BuiltIn.sleep  1s
     Run Keyword And Ignore Error   run     command=ps -ef|grep -v grep|grep -iE 'edaemon|egate'
     Run Keyword And Ignore Error    ute_wtssim.Teardown Edaemon    alias=edaemon
     Run Keyword And Ignore Error    ute_wtssim.Teardown Egate
     Log To Console    kill egate and edaemon done...

Start Android UE L3 Call with core-sim
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}   ${abil_index}=1
    ...   ${4G_check}=${true}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    Log  '${port}'   '${abil_index}'
    Run Keyword and Ignore Error   Restart adb server and wait until status ready   ue_index=${ue_index}
    run keyword if  not ${ue_${ue_index}_required}   UE precondition   ue_index=${ue_index}
    Run Keyword If   ${bip_request}   Run Keyword and Continue on Failure   Start BIP Collection New
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=${4G_check}
    Return From Keyword If   $tput=='0'
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    Run Keyword If   '${method}'=='PEAK'   Start Peak Traffic Testing UL DL both
    ...   ue_type=${ue_${ue_index}_type}   dl_throughput=${tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${tput_expect}   ul_expect=${ul_expect}   cell_list=${cell_id_list}
    ...   ELSE   Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cell_list=${cell_id_list}
    ...   throughput=${tput}   expect=${tput_expect}    traffic_stop=${traffic_stop}    duration=${duration}
    ${bip_log}   Run Keyword If   ${bip_request}   Stop BIP Collection New
    [Return]   ${cell_id_list}   ${bip_log}


Start then Stop Android UE L3 Call with core-sim without Attach
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}   ${abil_index}=1
    ...   ${4G_check}=${true}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    Log   port='${port}' bip_request='${bip_request}' abil_index='${abil_index}' 4G_check='${4G_check}' method='${method}'   ul_expect='${ul_expect}'
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cell_list=${cell_id_list}
    ...   throughput=${tput}   expect=${tput_expect}    traffic_stop=${traffic_stop}    duration=${duration}
    power_ue.Stop Traffic   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL

Start Android UE L3 Call with core-sim without Attach
    [Arguments]   ${ue_index}=${ue_index}   ${port}=${tl.ues[${ue_index}].iperf_details.port}
    ...   ${duration}=180   ${tput}=100   ${tput_expect}=${tput}   ${bip_request}=${false}   ${abil_index}=1
    ...   ${4G_check}=${true}    ${traffic_stop}=${true}   ${method}=normal   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ...   ${gnb_index}=${0}
    Log   port='${port}' bip_request='${bip_request}' abil_index='${abil_index}' 4G_check='${4G_check}' method='${method}'   ul_expect='${ul_expect}'
    ${nr_cellid}   Get Attached Cell Indentity    gnb_index=${gnb_index}
    ${cell_id_list}    Create List    ${nr_cellid}
    Wait Until Keyword Succeeds   10m   60s   Start Traffic With Throughput Check with gNB Index
    ...   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   direction=DL   cell_list=${cell_id_list}
    ...   throughput=${tput}   expect=${tput_expect}    traffic_stop=${traffic_stop}    duration=${duration}    gnb_index=${gnb_index}

Start Traffic With Throughput Check with gNB Index
    [Documentation]   Use this keyword instead the previous 2 keywords, because the power_ue require ue_type input
    [Arguments]   ${ue_type}   ${direction}   ${throughput}   ${expect}=${throughput}   ${cell_list}=${EMPTY}    ${gnb_index}=${0}
    ...  ${ue_index}=${0}   ${mode}=None    ${traffic_stop}=${true}    ${duration}=90s
    ${duration}   Run Keyword If   '${mode.lower()}'=='peak'   Set Variable   600s
    ...   ELSE   Set Variable   ${duration}
	Log   	traffic_stop='${traffic_stop}'
    power_ue.Start traffic   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}
    ...   throughput=${throughput}M   duration=${duration}
    Run Keyword If   len(${cell_list})==${0}   Wait Until Keyword Succeeds   ${duration}   10s   power_ue.Check throughput
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=${direction}   throughput=${expect}
    ...   ELSE   Wait Until Keyword Succeeds   ${duration}   10s   Check Tput l3call   ue_type=${ue_type}   direction=${direction}
    ...   expect=${expect}   cells=${cell_list}   ue_index=${ue_index}   gnb_index=${gnb_index}