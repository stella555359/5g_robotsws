*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot

*** Keywords ***
Start DCAP log via script
    [Documentation]   parameter ${gnb_custom_profile} is defined first
    [Arguments]    ${traces}=${gnb_custom_profile}
    ...  ${WEBUI_IP}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  ${WEBUI_USERNAME}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  ${WEBUI_PASSWORD}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Log To Console  Start DCAP log
    &{bts_info}   Create Dictionary    host=${WEBUI_IP}    username=${WEBUI_USERNAME}
    ...                                password=${WEBUI_PASSWORD}    port=443
    Start DCAP log    bts=&{bts_info}    gnb_custom_profile=${traces}




Stop DCAP log and get log path
    [Documentation]   parameter ${TS_CASE_LOG_PATH} is defined first    
    Log To Console  Stop DCAP log and get log path
    Stop DCAP log
    #sleep    15s    sleep for stop dcap stable
    sleep    600s
    Log To Console  get log path
    ${log_dir_ute}    rd.get_results    result_id=${result_id}    target_dir=${TS_CASE_LOG_PATH}
    run  command=cd ${TS_CASE_LOG_PATH};unzip ${log_dir_ute}
    ${syslog_dir}    Remove String    ${log_dir_ute}    .zip
    ${downloaded_log_path}  ${last}  Split String From Right  ${syslog_dir}  /  1
    [Return]  ${downloaded_log_path}
    
Create Bts On DCAP via script
    [Documentation]   parameter ${dcap_server_ip} is defined first
    [Arguments]    ${bts_mr_id}=${tl.gnbs[0].instance_id}    ${bts_host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  ${DCAP_host}=${dcap_server_ip}  ${DCAP_port}=443
    Log To Console  Create Bts On DCAP
    &{bts_classical}  Create Dictionary  alias=gnb_${bts_mr_id}    host=${bts_host}
    ...    username=Nemuadmin    password=nemuuser
    ...    port=443    bts_id=${bts_mr_id}
    Create Bts On DCAP  DCAP_host=${DCAP_host}  DCAP_port=${DCAP_port}  bts_mr_id=${bts_classical['bts_id']}  bts=${bts_classical} 

Stop DCAP log when case teardown    
    ${trace_before}    rd.get_trace_info_by_id    trace_id=${result_id}
    Log  ${trace_before}  
    run keyword if    "${trace_before['stop_time']}"=="${None}"    Stop DCAP log
    ${trace_after}    rd.get_trace_info_by_id    trace_id=${result_id}
    Dcap delete trace  trace_id=${result_id}
    DCAP.Delete_Bts_if_Exist

Stop DCAP log when case setup
    [Arguments]  ${WEBUI_IP}=${tl.gnbs[0].cu.oam_http_connection_details.addr}    
    ${bts_list}    rd.get_all_bts_info
    ${bts_count}   Get Length    ${bts_list}
    return from keyword if     ${bts_count}==0
    FOR  ${item}  IN  @{bts_list}
      Log  ${item}
      ${trace_id}    Run keyword if  "${item['host']}"=="${WEBUI_IP}"  set variable if  "${item['latest_trace']['stop_time']}"=="None"   
      ...  ${item['latest_trace']['id']}    ${None}
      ${is_bts_exist}  Run keyword if  "${item['host']}"=="${WEBUI_IP}"  set variable if  "${item['latest_trace']['stop_time']}"=="None"
      ...    true    false
      Exit For Loop If    '${is_bts_exist}'=='true'
    END
    run keyword if  not '${trace_id}'=='${None}'  wait until keyword succeeds    10min    30s   rd.stop_trace    trace_id=${trace_id}
    Dcap get trace info by id  trace_id=${trace_id}
