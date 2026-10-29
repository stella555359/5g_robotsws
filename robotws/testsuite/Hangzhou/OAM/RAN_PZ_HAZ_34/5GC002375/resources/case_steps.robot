*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Variables    ../../libraries/global_vars.py
Variables   ../libraries/dcap_server_1.py
Resource   ./dcap.robot
Resource   ./coam.robot
Resource   ./call.robot
Resource   ./tshark.robot
Resource   ./sherpa.robot
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Variables   ../libraries/2375_qc_id.py
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/DCAP.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${duration}   15
${tput}   10
${tput_unit}   M
${debug_mode}   N
${abil_index}   1
#${cell_id}   16388
${logout_res}   ${true}
#${ue_index}    1

@{gnb_custom_profile}    cp_5g   L2Ps_Sherpa

${DCAP_host}    10.57.167.35
${DCAP_port}    ${EMPTY}



&{bts_classical}      alias=gnb_dcap    host=${LMP_ADDR}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}

*** Keywords ***
Suite Setup for CB007308
    robot_common_operations.Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair

Suite Teardown for CB007308
    robot_common_operations.Common Suite Teardown

Cplane and Uplane log Setup
    [Arguments]     ${vlan_ip}    ${operation}=call     ${gnb_custom_profile}=${gnb_custom_profile}
    log to console   \n Cplane and Uplane log Setup
    COAM Login   bts_host=${LMP_ADDR}    alias=${coam_alias}
    ${gnb_release}   wait until keyword succeeds    10min   30s   Get gnb release
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'      set variable   SBTS22R3
    ...   ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${LMP_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}    display=${false}   version=${gnb_release}
    COAM WEBUI Whether Close Start Up View Window
    Change Mplane to Internal IP    IPIF_NUM=4
    wait until keyword succeeds    10min   1min   coam.Check Cell Setup in COAM
    Configure Logging Agent    uplane_destination=${EMPTY}    source_ip=${EMPTY}
    sleep   1min
    Set To Dictionary    ${bts_classical}    host    ${vlan_ip}
    run keyword and ignore error   Dcap delete bts
    Create Bts On DCAP    DCAP_host=${DCAP_host}   DCAP_port=${DCAP_port}   bts_mr_id=${bts_classical['bts_id']}    bts=${bts_classical}
    ${downloaded_emil_file_path}    wait until keyword succeeds    3x    1min
     ...   Start and Stop Trace Operation    vlan_ip=${vlan_ip}
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    set suite variable     ${sherpa_log_file_list}
    set suite variable     ${emil_log_file_list}
#    Upload Emil script and logs on sherpa
#    Mkdir for EMil script and logs on sherpa
#    run keyword if  ${operation.count('call')} > 0
#    ...   run keywords    Convert emil log at sherpa   log_path_list=${emil_log_file_list}    end_file=5gm   AND
#    ...    Convert Pcaps to CSV    local_sherpa_list=${sherpa_log_file_list}

Start and Stop Trace Operation
    [Arguments]    ${vlan_ip}
    Set To Dictionary    ${bts_classical}    host    ${vlan_ip}
    Start DCAP log    bts=${bts_classical}    gnb_custom_profile=${gnb_custom_profile}
    Gnb Operation During Flowtracer Trace    operation=sleep
    ${downloaded_emil_file_path}    Stop Dcap Basic trace
    [Return]   ${downloaded_emil_file_path}

Cplane and Uplane log Teardown
    log to console   \n Cplane and Uplane loge Teardown
#    run keyword and ignore error    Delete Emil script and logs on sherpa
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    Wait until keyword succeeds  3x   1min    Dcap delete bts
    Check Extra Reset From Blackbox
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}

Stream Case Steps
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${call_mode}=multi
    ...    ${ip_mode}=ipv4   ${host}=${asik_addr}    ${trace_flag}=single    ${L3CALL}=${True}    ${dcap_ip}=${dcap_ip}
    COAM Login    bts_host=${LMP_ADDR}   alias=${coam_alias}
    ${gnb_release}   Get gnb release    host=${LMP_ADDR}
    ${gnb_release}    Run keyword if   '${gnb_release}'=='TRUNK'   set variable   SBTS21B
    ...    ELSE   set variable   ${gnb_release}
    COAM WEBUI Login   url=https://${LMP_ADDR}   display=${false}   version=${gnb_release}
#    run keyword and ignore error   Copy Luashark to Local
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error
    ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=${trace_flag}
    Sleep   15s
    run keyword and ignore error   Deactivate Internal Trace
    ${cells_list}   _Get Request Cell List   stream=${stream}   level=${level}   exec_type=${exec_type}
    Configure Logging Agent    uplane_destination=${dcap_ip}:1234   source_ip=${host}
    Start Stream Trace Action   level=${level}   exec_type=${exec_type}   stream=${stream}   ip_mode=${ip_mode}
    ...   host=${host}   trace_flag=${trace_flag}    cells_list=${cells_list}
    Start UDP Server Collecting   dcap_ip=${dcaps_ip}    dcap_username=${dcap_username}    dcap_password=${dcap_password}
    ...    host=${host}
    run keyword and ignore error    COAM WEBUI Logout
    sleep    2min
    #Run Keyword and Ignore Error   Setup Call by mode   call_mode=single
#    run keyword if  ${L3CALL}   L3 call Integration
    [Teardown]    Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}    host=${host}

Selectable VLAN Uplane Trace
    [Arguments]   ${vlan_id}    ${host}   ${dcap_ip}    ${level}     ${stream}=sherpa    ${exec_type}=${EMPTY}
#    COAM WEBUI Login   url=https://192.168.255.129   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
##    Run keyword and ignore error    Recover Mplane to Origin
#    COAM WEBUI Logout
    Stream Case Steps   stream=${stream}   level=${level}   exec_type=${exec_type}   host=${host}   call_mode=single
    ...    dcap_ip=${dcap_ip}
    Check Trace File Recieved   file_folder=${file_location}    host=${host}
    #Download Earlist CSV File in TAF    pcap_ip=${host}
    Log to console   VLAN ${vlan_id} PASS
    [Teardown]  Release Resource Second Time  stream=${stream}   level=${level}
    ...    exec_type=${exec_type}   host=${host}

L3 call Integration
    ${res}   Run Keyword and Ignore Error   Setup Call by mode   call_mode=single
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
    Set Suite Variable   ${call_alias}   ${res[1]}
    [Teardown]    Stream Case Teardown    stream=${stream}    level=${level}    exec_type=${exec_type}    host=${host}

Stream Case Teardown
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}   ${host}=${asik_addr}   ${trace_flag}=single
    COAM WEBUI Login   url=https://${LMP_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    COAM WEBUI Whether Close Start Up View Window
    Run Keyword and Ignore Error
    ...    Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=single
    COAM Logout   connection=${coam_alias}
    Check Trace File Recieved   file_folder=${file_location}   host=${host}
    #Get Streaming Files Current gNB   file_folder=${file_location}   source_ip=${host}
#    Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}
#    Run Keyword If   '${debug_mode}'=='N'   selenium_coam.disable_virtual_display
    [Teardown]    COAM WEBUI Logout

Release Resource Second Time
    [Arguments]   ${stream}   ${level}   ${exec_type}=${EMPTY}    ${trace_flag}=single    ${host}=${asik_addr}
#    Run Keyword If   '${debug_mode}'=='N'   selenium_coam.enable_virtual_display
    COAM WEBUI Login    url=https://${LMP_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error
    ...   Stop Stream Trace Action    stream=${stream}    level=${level}    exec_type=${EMPTY}    trace_flag=all
    run keyword and ignore error    COAM Logout   connection=${coam_alias}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   Clean Traffic Files   file_folder=${file_location}    source_ip=${host}
    Run Keyword and Ignore Error   Clean Pcap Log in Sherpa Server
    Run Keyword and Ignore Error   Clean Pcap in Local
    Run Keyword and Ignore Error   csn.Disconnect   connection=${dcap_alias}
    Run Keyword and Ignore Error   csn.Disconnect   connection=${call_alias}


Setup Call by mode
    [Arguments]   ${call_mode}
    ${alias}   Run Keyword If   '${call_mode.lower()}'=='single'  Call Setup and check tput   port=57295
    ...   duration=${duration}   tput_expect=10   ue_index=${ue_index}
    ...   ELSE   Setup MultiCell Call   duration=${duration}
    [Return]   ${alias}

