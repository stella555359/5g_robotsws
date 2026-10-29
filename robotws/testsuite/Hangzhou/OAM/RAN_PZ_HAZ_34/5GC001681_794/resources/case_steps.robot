*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Variables   ../libraries/dcap_server_1.py
Variables    ../../libraries/global_vars.py
Resource   ./dcap.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/resources/coam.robot
Resource   ./call.robot
Resource   ./tshark.robot
Resource   ./common.robot
Resource   ./emil/emil.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot

*** Variables ***
${duration}   180
${tput}   5
${tput_expect}   1
${tput_unit}   M
${debug_mode}   N
${abil_index}   1
#${cell_id}   16388
${logout_res}   ${true}
#${ue_index}    1

#@{gnb_custom_type}    cp_5g   L2Ps_Sherpa    L2Lo_Sherpa    L2HiRlc_Sherpa    L2HiPdcp_Sherpa
@{gnb_custom_type}    cp_5g

*** Keywords ***
Stream Case Steps
    [Arguments]   ${stream}=sherpa   ${level}=l2_hi   ${exec_type}=${EMPTY}   ${call_mode}=signle
    ...    ${ip_mode}=ipv4   ${host}=${asik_addr}    ${trace_flag}=single    ${L3CALL}=${True}
    LOG    ${call_mode}
    COAM Login   alias=${coam_alias}
    ${gnb_release}   Get gnb release
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}   version=${gnb_release}
    COAM WEBUI Whether Close Start Up View Window
    common.Set Output Log Path
    run keyword and ignore error   Copy Luashark to Local
    run keyword and ignore errors
    ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${exec_type}    trace_flag=all
    Sleep   15s
    Start Stream Trace Action
    ...   level=${level}   exec_type=${exec_type}   stream=${stream}   ip_mode=${ip_mode}   host=${host}    trace_flag=${trace_flag}
    Start UDP Server Collecting   dcap_ip=${dcap_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
    COAM WEBUI Logout
    run keyword if  ${L3CALL}   L3 call Integration
    [Teardown]    Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}    host=${host}
    ...   trace_flag=${trace_flag}

L3 call Integration
    ${res}   Run Keyword and Ignore Error   Setup Call by mode   call_mode=single
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
    Set Suite Variable   ${call_alias}   ${res[1]}

Cplane and Uplane log Setup
    [Arguments]     ${operation}=call     ${gnb_custom_profile}=${gnb_custom_type}
    log to console   \n Cplane and Uplane log Setup
    COAM Login   alias=${coam_alias}
    ${gnb_release}   Get gnb release
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}   version=${gnb_release}
    COAM WEBUI Whether Close Start Up View Window
    common.Set Output Log Path
    Configure Logging Agent    uplane_destination=${EMPTY}    source_ip=${EMPTY}
    run keyword and ignore error    Delete Emil script and logs on sherpa
    Start Dcap Basic trace    gnb_custom_profile=${gnb_custom_profile}
    Gnb Operation During Flowtracer Trace    operation=${operation}
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    ${status}    ${nodeinfo}    run keyword and ignore error    Get GNB Node ID After BSH Removed
    set suite variable   ${nodeinfo}
    Upload Emil script and logs on sherpa
    Mkdir for EMil script and logs on sherpa
    run keyword if  ${operation.count('call')} > 0
    ...   run keywords    Convert emil log at sherpa   log_path_list=${emil_log_file_list}    end_file=5gm   AND
    ...    Convert Pcaps to CSV    local_sherpa_list=${sherpa_log_file_list}

Cplane and Uplane log Setup For Case
    [Arguments]     ${operation}=call     ${gnb_custom_profile}=${gnb_custom_type}
    log to console   \n Cplane and Uplane log Setup
    COAM Login   alias=${coam_alias}
#    ${gnb_release}   Get gnb release
#    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
#    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
    COAM WEBUI Whether Close Start Up View Window
    common.Set Output Log Path
    Configure Logging Agent    uplane_destination=${EMPTY}    source_ip=${EMPTY}
    run keyword and ignore error    Delete Emil script and logs on sherpa
    Start Dcap Basic trace    gnb_custom_profile=${gnb_custom_profile}
    Gnb Operation During Flowtracer Trace    operation=${operation}
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    ${status}    ${nodeinfo}    run keyword and ignore error    Get GNB Node ID After BSH Removed
    set suite variable   ${nodeinfo}
    Upload Emil script and logs on sherpa
    Mkdir for EMil script and logs on sherpa
    run keyword if  ${operation.count('call')} > 0
    ...   run keywords    Convert emil log at sherpa   log_path_list=${emil_log_file_list}    end_file=5gm   AND
    ...    Convert Pcaps to CSV    local_sherpa_list=${sherpa_log_file_list}

Cplane log Setup
    [Arguments]     ${operation}=call     ${gnb_custom_profile}=${gnb_custom_type}
    log to console   \n Cplane log Setup
    COAM Login   alias=${coam_alias}
#    ${gnb_release}   Get gnb release
#    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS21B
#    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
    COAM WEBUI Whether Close Start Up View Window
    common.Set Output Log Path
    Configure Logging Agent    uplane_destination=${EMPTY}    source_ip=${EMPTY}
    run keyword and ignore error    Delete Emil script and logs on sherpa
    Start Dcap Basic trace    gnb_custom_profile=${gnb_custom_profile}
    Gnb Operation During Flowtracer Trace    operation=${operation}
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    ${nodeinfo}    Get GNB Node ID After BSH Removed
    set suite variable   ${nodeinfo}
    Upload Emil script and logs on sherpa
    Mkdir for EMil script and logs on sherpa
    Convert emil log at sherpa   log_path_list=${emil_log_file_list}    end_file=5gm
    set suite variable     ${bbmod_reset_for_1808}    ${false}

Cplane and Uplane log Teardown
    log to console   \n Cplane and Uplane loge Teardown
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    Delete Emil script and logs on sherpa
    run keyword and ignore error    Stop DCAP log
    run keyword and ignore error    Dcap delete trace    trace_id=${result_id}
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Cplane and Uplane log Teardown For Case
    log to console   \n Cplane and Uplane loge Teardown
    robot_common_operations.Common Suite Teardown
    Collect Snapshot and Screenshot If Case Failed
    run keyword and ignore error    Delete Emil script and logs on sherpa
    run keyword and ignore error    Stop DCAP log
    run keyword and ignore error    Dcap delete trace    trace_id=${result_id}
    run keyword and ignore error    Dcap delete bts    bts_id=${dcap_create_id}
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Stream Case Teardown
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${host}=${asik_addr}   ${trace_flag}=single
    COAM WEBUI Login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
    Wait Until Keyword Succeeds   1min    5s
    ...    Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${exec_type}    trace_flag=${trace_flag}
    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Check Trace File Recieved   file_folder=${file_location}   host=${host}
    Get Streaming Files Current gNB   file_folder=${file_location}   source_ip=${host}
    Convert Pcaps to CSV    local_sherpa_path=${OUTPUT_DIR}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Release Resource Second Time
    [Arguments]   ${stream}=sherpa   ${level}=l2_hi   ${exec_type}=${EMPTY}    ${trace_flag}=single
#    Run Keyword If   '${debug_mode}'=='N'   selenium_coam.enable_virtual_display
    COAM WEBUI Login    url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}
    run keyword and ignore error
    ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${exec_type}    trace_flag=${trace_flag}
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   Clean Traffic Files   file_folder=${file_location}
    Run Keyword and Ignore Error   Clean Pcap Log in Sherpa Server
    Run Keyword and Ignore Error   Clean Pcap in Local
    Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Setup Call by mode
    [Arguments]   ${call_mode}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ini_port}    Get Variable Value    ${tl.ues[${ue_index}].iperf_details.port}
    ...    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    ${alias}   Run Keyword If   '${call_mode.lower()}'=='single'  L3_Call.Call Setup and check tput    port=${iperf_port}
    ...   duration=${duration}   tput=${tput}    tput_expect=${tput_expect}   ue_index=${ue_index}
    ...   ELSE   Setup MultiCell Call   duration=${duration}
    [Return]   ${alias}

Collect Snapshot and Screenshot If Case Failed
    [Documentation]   Collect Snapshot and Screenshot For Case Failed
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
