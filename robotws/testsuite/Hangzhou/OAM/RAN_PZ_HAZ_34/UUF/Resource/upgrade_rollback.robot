*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/TestCaseRequirement.py
Library    String
Library    Collections
Library    DateTime
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_selenium.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_swing.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/webui_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/nom_swm.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/fallback_common.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/mcs_request.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Library   OperatingSystem
Library   XML
Library     Process
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/UUF_common.py

*** Variables ***


*** Keywords ***
COAM Webui Reset
    [Arguments]    ${reset_which_site}=gnb
    ${gnb_ips}    Create List    ${WEBUI_ADDR}
    Run Keyword If   '${bts_id}' in @{Multi_BTS_ID}   append to list   ${gnb_ips}   ${peer_asik_addr}
    ${login_ips}    Set Variable If    '${reset_which_site}'=='gnb'    ${gnb_ips}    ${enb_ip_list}
    ${operation}    Set Variable If    '${reset_which_site}'=='gnb'    GNB_reset    ENB_reset
    Run Keyword And Ignore Error  L3call for E2E site   dir=${operation}
    FOR     ${login_ip}    IN    @{login_ips}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${login_ip}
        continue for loop if     '${reset_which_site}'=='enb' and '${login_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        Site Reset by Webui    ${login_ip}
        Run Keyword    Check ${reset_which_site} site status for reset   login_ip=${login_ip}
    END

Check gnb site status for reset
    [Arguments]    ${login_ip}=${WEBUI_ADDR}
    wait until keyword succeeds    20 min    2 min   Coam Check Site Status   ip=${login_ip}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    run keyword if   '${bts_id}' in @{Concurrent_BTS_ID} or '${bts_id}' in @{Multi_BTS_ID}    wait until keyword succeeds   5 min  10 s
    ...    Check add enb cell status
    Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag
    repeat keyword  ${Wait_Time_After_Site_Reset}   Coam Check Site Status   ip=${login_ip}

Check enb site status for reset
    [Arguments]    ${login_ip}=${ENBs[1]['addr']}
    wait until keyword succeeds   20 min  2 min   Check add enb cell status
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA    SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    wait until keyword succeeds    5 min    10 s   Coam Check Site Status
    run keyword if   '${bts_id}' in @{Multi_BTS_ID}  wait until keyword succeeds    5 min    10 s   Coam Check Site Status
    ...   ip=${peer_asik_addr}
    repeat keyword  ${Wait_Time_After_Site_Reset}   Check add enb cell status
    Check if Unexpected Active Alarm Exist and Set Stop Flag   stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag

Check add enb cell status
    set suite variable    ${stop_flag}   0
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        Check eNB status for Concurrent   lte_addr=${enb_ip}    if_ignore_cablink=${False}
        Check if Unexpected Active Alarm Exist and Set Stop Flag   web_ip=${enb_ip}
        ...   stop_with_trunk_roll_fault=True    if_enb=True
        Check If Asik and Abil not detected and set stop flag    ${enb_ip}
    END

Webui Upgrade General Steps
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
    COAM Upgrade package    package=${upgrade_version}
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    Catch Realtime Log    operation=provision

Webui Upgrade General Check Steps
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    Validate PM Report Generated on gNB
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status

Moran NetAct Upgrade
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
    ${gNb_active_version}   ${gNb_passive_version}     Get gNB SW version
#    wait until keyword succeeds   3 times   5min   Trigger SW Provision from NetAct    taget_version=${upgrade_version}
    NetAct SW Operation Steps
    NetAct SW Operation Steps   host=${peer_asik_addr}   input_btsname=MRBTS-870
    Set Suite Variable   ${operation}   provision
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
    ${operation_status}   Check Operation Status in NetAct   operation=Activation
    run keyword and ignore error  should contain any    ${operation_status}   Successful    Timeout-Success
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    Check NetAct Operations

MultiGnb NetAct Upgrade
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}   tput=${tput}
    ${gNb_active_version}   ${gNb_passive_version}     Get gNB SW version
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Download
    should contain any    ${operation_status}   Successful    Timeout-Success
    ${rollback_status}   run keyword and return status   NetAct SW provision
    run keyword if  not ${rollback_status}   run keyword and ignore error   wait until keyword succeeds   10 min   20 s
    ...   Validate IP Reachability from Test PC   ip_addr=${cu_addr}  exp_status=${False}
    wait until keyword succeeds   15 min   20 s    Validate IP Reachability from Test PC    ip_addr=${cu_addr}  exp_status=${True}
    Concurrent NetAct Upgrade   gnb_ip=${peer_asik_addr}   mr_btsid=MRBTS-${slave_bts_id}
    ${operation_status}   Check Operation Status in NetAct   operation=Activation
    run keyword and ignore error  should contain any    ${operation_status}   Successful    Timeout-Success
    wait until keyword succeeds   10 min   30 s    Check If Active Software Version Updated    action=provision
    wait until keyword succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${True}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${True}


MutiGnb NetAct Rollback
    ${slave_bts_id}    run keyword if  '${bts_id}' in @{Multi_BTS_ID}   convert to string   ${PEER_BTS_ID}
    run keyword and continue on failure   NetAct SW rollback
    Concurrent NetAct Rollback   gnb_ip=${peer_asik_addr}   mr_btsid=MRBTS-${slave_bts_id}
    ${operation_status_slave}   Check Operation Status in NetAct   operation=Rollback
    wait until keyword succeeds   10 min   30 s    Check If Active Software Version Updated    action=rollback
    should contain any    ${operation_status_slave}   Successful    Timeout-Success
    wait until keyword succeeds  10min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${True}

Moran NetAct Rollback
    ${source_cmp}   UUF_common.compare_versions   ${origin_version}   ${enb_source_version}
    run keyword if  ${source_cmp}   NetAct SW Operation Steps   action=rollback
    ...   ELSE   NetAct SW Operation Steps   action=rollback   host=${peer_asik_addr}   input_btsname=MRBTS-870
    run keyword if  ${source_cmp}   NetAct SW Operation Steps   action=rollback   host=${peer_asik_addr}   input_btsname=MRBTS-870
    ...   ELSE   NetAct SW Operation Steps   action=rollback
    Set Suite Variable   ${operation}   rollback
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
    ${operation_status}   Check Operation Status in NetAct   operation=Rollback
    should contain any    ${operation_status}   Successful    Timeout-Success
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    Check NetAct Operations

Moran Webui Rollback
    ${source_cmp}   UUF_common.compare_versions   ${origin_version}   ${enb_source_version}
    run keyword if  ${source_cmp}   COAM Rollback and Verify
    ...   ELSE   COAM Rollback and Verify    host=${peer_asik_addr}
    run keyword if  ${source_cmp}   COAM Rollback and Verify    host=${peer_asik_addr}
    ...   ELSE   COAM Rollback and Verify
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=rollback
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    wait until keyword succeeds  15 min   10s   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status

Moran Webui Upgrade
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
    COAM Upgrade package    package=${upgrade_version}
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision
    Set Suite Variable   ${operation}   provision
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${WEBUI_ADDR}
    Wait Until Keyword Succeeds   10 min   30 s    Coam Check Site Status     if_ignore_cablink=${False}     ip=${peer_asik_addr}
#    Catch Realtime Log    operation=provision
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    ${current_version}   ${enb_passive_version}   Get eNB SW version   ${peer_asik_addr}
#    ${current_release}   ${current_version}   Split String   ${enb_active_version}   _   1
    ${target_release}   ${target_version}   Split String   ${enb_target_version}   _   1
    run keyword if  '${current_version}'!='${target_version}'   Upgrade Moran eNB and Check Cell Setup
    ...   eNB_ip=${peer_asik_addr}   eNB_package=${enb_target_version}
    ...   ELSE   log to console   eNB is on target build!
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  20 min   10s   Check Cell Status after SW Version Modified
    wait until keyword succeeds  20 min   10s   Coam Check Site Status    if_ignore_cablink=${False}   ip=${peer_asik_addr}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    ${call_status_list}   create list
#    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
#    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
#    Validate Config by WebEM
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status

COAM Webui Upgrade
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
    COAM Upgrade package    package=${upgrade_version}
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision
    Set Suite Variable   ${operation}   provision
#    Catch Realtime Log    operation=provision
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
#    Check Cell Setup in COAM
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    # it takes time to wait alarm raise when cell not onAir, for example, fault 1868 on AEQN
#    Check Alarm from Site
#    Get Downtime via Offline and Online Time
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    ${call_status_list}   create list
#    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
#    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
#    COAM check gNB state after cell setup
    Validate Config by WebEM
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
#    Varify CM Provsion in Bankend on NetAct via Change RollbackReject
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
#    COAM RollbackReject package
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=false

Concurrent Webui Upgrade
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    ${L3callBTS_status}   set variable if  '${bts_id}' in @{Multi_BTS_ID}   ${False}   ${L3callBTS_status}
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}   tput=${tput}
    ${operation_first}    Set Variable If    '${bts_id}' in @{ATT_BTS_ID}    ENB    GNB
    ${operation_second}    Set Variable If    '${bts_id}' in @{ATT_BTS_ID}    GNB    ENB
    Run Keyword    Upgrade ${operation_first} and check gnb and enb status for concurrent    ${gnb_ip}    webui
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision   ip=${gnb_ip}
    Set Suite Variable   ${operation}   provision
    ${enb_length}   Get Length   ${ENBs}
    ${enb_length}    Convert To Integer    ${enb_length}
    ${enb_number}   set variable   ${enb_length-1}
    Run Keyword    Upgrade ${operation_second} and check gnb and enb status for concurrent    ${gnb_ip}    webui
    wait until keyword succeeds  20 min   10s   Check Cell Status after SW Version Modified   login_ip=${gnb_ip}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}   ip=${gnb_ip}
#    ${call_status_list}   create list
#    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
#    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    Validate Config by WebEM   host=${gnb_ip}
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${gnb_ip}
#    Varify CM Provsion in Bankend on NetAct via Change RollbackReject
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
#    COAM RollbackReject package
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=false

Upgrade GNB and check gnb and enb status for concurrent
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}    ${method}=webui
    run keyword if    '${method}'=='webui'    COAM Upgrade package    package=${upgrade_version}   ip=${gnb_ip}
    ...    ELSE    Trigger SW Upgrade from NetAct
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${gnb_ip}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${gnb_ip}  exp_status=${True}
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated   ip=${gnb_ip}
    Check Gnb and Enb Status after Gnb Upgrade Rollback   ip=${gnb_ip}

Upgrade ENB and check gnb and enb status for concurrent
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}    ${method}=webui
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${enb_ip}
        continue for loop if     '${enb_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        ${current_version}   ${enb_passive_version}   Get eNB SW version   ${enb_ip}
        ${target_release}   ${target_version}   Split String   ${enb_target_version}   _   1
        run keyword if  '${current_version}'!='${target_version}'   Upgrade eNB and Check Cell Setup   enb_ip=${enb_ip}
        ...   ELSE   log to console   eNB is on target build!
    END

MultiGnb Webui Upgrade
    ${bts_id}   run keyword if   '${bts_id}' in @{Multi_BTS_ID}   convert to string   ${bts_id}
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}   tput=${tput}
    COAM Upgrade package   package=${upgrade_version}  type=gNB
    run keyword and ignore error    wait until keyword succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    wait until keyword succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    Concurrent Webui Upgrade   gnb_ip=${peer_asik_addr}
    wait until keyword succeeds   10 min   30 s    Check If Active Software Version Updated    action=provision
    wait until keyword succeeds  20 min   10s   Coam Check Site Status    if_ignore_cablink=${True}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${True}

MultiGnb Webui Rollback
    COAM rollback package
    wait until keyword succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    wait until keyword succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}    exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   wait until keyword succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback
    Concurrent Webui Rollback   gnb_ip=${peer_asik_addr}
    wait until keyword succeeds   10 min   30 s    Check If Active Software Version Updated    action=rollback
    wait until keyword succeeds  20 min   10s   Coam Check Site Status    if_ignore_cablink=${True}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   wait until keyword succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${True}


Check Gnb and Enb Status after Gnb Upgrade Rollback
    [Arguments]   ${action}=provision   ${ip}=${WEBUI_ADDR}    ${save_log}=${True}
    ${gnb_status}   run keyword and return status   Wait Until Keyword Succeeds    15 min    3min   Coam Check Site Status
    ...    if_ignore_cablink=${False}   ip=${ip}
    Wait Until Keyword Succeeds    15 min    2 min    Check if Unexpected Active Alarm Exist and Set Stop Flag
    ...    web_ip=${ip}    stop_with_trunk_roll_fault=True
    Check If Asik and Abil not detected and set stop flag    ${ip}
#    ${enb_status}   run keyword and return status   Wait Until Keyword Succeeds    10 min    3min   Check eNB Cell Status
    ${enb_status}   run keyword and return status   wait until keyword succeeds    10 min    10 s   Check add enb cell status
    Run keyword if   ${save_log} and ('${gnb_status}'=='False' or '${enb_status}'=='False')   Save logs   middle_status=True
    ...   folder=${TEST_NAME}/Middle/${action}
    Run keyword if    '${gnb_status}'=='False' or '${enb_status}'=='False'    Fail    gnb or enb status fail

COAM Webui Rollback
    COAM Rollback package
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=rollback
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    rollback
    wait until keyword succeeds  15 min   10s   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   both   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    check alarm in COAM
#    Check Alarm from Site
#    COAM check gNB state after cell setup
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status

COAM Webui Rollback Enb
    [Arguments]    ${enb_ip}=${ENBs[1]['addr']}
    COAM Rollback package    ${enb_ip}
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${eNB_ip}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${enb_ip}  exp_status=${True}
    #   ignore check enb software update, because switch enb to source build is ignore error. Avoid case failure in this case
    run keyword and continue on failure    Check If Active Software Version Updated    action=rollback   ip=${enb_ip}
    ...    upgrade_version=${enb_target_version}   source_build=${enb_source_version}
    Check Gnb and Enb Status after Gnb Upgrade Rollback   action=rollback

Concurrent Webui Rollback
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}
    ${active_version_before}   ${passive_version_before}     Get gNB SW version
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${enb_ip}
        continue for loop if     '${enb_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        ${current_version}   ${enb_passive_version_before}     Get eNB SW version   ${enb_ip}
        ${target_release}   ${target_version}   Split String   ${enb_target_version}   _   1
        ${source_release}   ${source_version}   Split String   ${enb_source_version}   _   1
        ${enb_status}    run keyword and return status  should be equal   ${current_version}   ${target_version}
        run keyword if  ${enb_status} and '${current_version}'!='${source_version}'  COAM Webui Rollback Enb    ${enb_ip}
    END
    COAM Rollback package   login_ip=${gnb_ip}
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${gnb_ip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${gnb_ip}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback    ip=${gnb_ip}
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=rollback
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    rollback   ip=${gnb_ip}
    wait until keyword succeeds  15 min   10s   Check Cell Status after SW Version Modified   login_ip=${gnb_ip}
    Check Gnb and Enb Status after Gnb Upgrade Rollback   action=rollback   ip=${gnb_ip}
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}   ip=${gnb_ip}
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${gnb_ip}

Trigger SW Upgrade from NetAct
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Download
    should contain any    ${operation_status}   Successful    Timeout-Success
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Activation   taget_version=${upgrade_version}

Check Some Netact Status
    [Arguments]    ${operation}
    ${operation_status}   Check Operation Status in NetAct   ${operation}
    should contain any    ${operation_status}   Successful    Timeout-Success
    Check NetAct Operations

COAM NetAct Upgrade
#    CM Upload in Netact
#    wait until keyword succeeds   3 times   5min   Trigger SW Provision from NetAct    taget_version=${upgrade_version}
#    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=true
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger SW Upgrade from NetAct
    ...   ELSE    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    run keyword if    '${NMS_TYPE}'=='netact'    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision
    Set Suite Variable   ${operation}   provision
#    Catch Realtime Log    operation=provision
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
#    Check Cell Setup in COAM
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
#    Check Alarm from Site
#    Get Downtime via Offline and Online Time
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    ${call_status_list}   create list
#    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
#    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
#    COAM check gNB state after cell setup
    Check If Active Software Version Updated
    Check Site Status After Upgrade or Rollback
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
    run keyword if    '${NMS_TYPE}'=='netact'    Check Some Netact Status    Activation
#    Validate Config by WebEM
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}
#    Run Keyword    Varify CM Provsion in Bankend on ${NMS_TYPE} via Change RollbackReject
#    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=true
#    run keyword if    '${NMS_TYPE}'=='netact'    COAM RollbackReject package
#    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=false

Concurrent NetAct Upgrade
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}   ${mr_btsid}=${input_btsname}
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    ${L3callBTS_status}   set variable if  '${bts_id}' in @{Multi_BTS_ID}   ${False}   ${L3callBTS_status}
    ${tput}   Set Variable If  '${bts_id}' in @{E2E_BTS_ID}  ${E2E_L3Call_tput}  ${Common_L3Call_tput}
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}   tput=${tput}
    ${gNb_active_version}   ${gNb_passive_version}     Get gNB SW version
    ${operation_first}    Set Variable If    '${bts_id}' in @{ATT_BTS_ID}    ENB    GNB
    ${operation_second}    Set Variable If    '${bts_id}' in @{ATT_BTS_ID}    GNB    ENB
#    wait until keyword succeeds   3 times   5min   Trigger SW Provision from NetAct    taget_version=${upgrade_version}
    Run Keyword    Upgrade ${operation_first} and check gnb and enb status for concurrent    ${gnb_ip}    netact
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision   ip=${gnb_ip}
    Set Suite Variable   ${operation}   provision
    Run Keyword    Upgrade ${operation_second} and check gnb and enb status for concurrent    ${gnb_ip}    netact
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified   login_ip=${gnb_ip}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${gnb_ip}
    ${operation_status}   Check Operation Status in NetAct   operation=Activation   input_btsname=${mr_btsid}
    run keyword and ignore error  should contain any    ${operation_status}   Successful    Timeout-Success
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}   ip=${gnb_ip}
#    ${call_status_list}   create list
#    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and continue on failure
#    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
#    ...   ELSE   run keyword and ignore error  add json to file   l3_call   ${call_status_list}
#    ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    Check NetAct Operations
#    Varify CM Provsion in Bankend on NetAct via Change RollbackReject
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=true
#    COAM RollbackReject package
#    Change RollbackReject by CM Provsion in Bankend on NetAct   bts=${input_btsname}   rollback_status=false


COAM NetAct Rollback
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger SW Rollback from NetAct
    ...   ELSE    Trigger SW Operation from Nom    operation=rollback   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    run keyword if    '${NMS_TYPE}'=='netact'    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=rollback
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    rollback
    wait until keyword succeeds  15min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status
    run keyword if    '${NMS_TYPE}'=='netact'    Check Some Netact Status    Rollback
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}

Concurrent NetAct Rollback
    [Arguments]    ${gnb_ip}=${WEBUI_ADDR}   ${mr_btsid}=${input_btsname}
    ${active_version_before}   ${passive_version_before}    Get gNB SW version
    FOR     ${enb_ip}    IN    @{enb_ip_list}
        ${count_index}    UUF_common.count_list_contain_sub_dict    ${ENBs}    addr    ${enb_ip}
        continue for loop if     '${enb_ip}' == '${ENBs[0]['addr']}' and '${count_index}' == '1'
        ${current_version}   ${enb_passive_version_before}     Get eNB SW version   ${enb_ip}
        ${target_release}   ${target_version}   Split String   ${enb_target_version}   _   1
        ${source_release}   ${source_version}   Split String   ${enb_source_version}   _   1
        ${enb_status}    run keyword and return status  should be equal   ${current_version}   ${target_version}
        run keyword if  ${enb_status} and '${current_version}'!='${source_version}'  COAM Webui Rollback Enb    ${enb_ip}
    END
    Trigger SW Rollback from NetAct   input_btsname=${mr_btsid}
    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC    ip_addr=${gnb_ip}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC    ip_addr=${gnb_ip}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback   ip=${gnb_ip}
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=provision
#    run keyword and ignore error  run keyword if   '${bts_id}' in @{enable_BTS_ID}   Enable ssh to RU for ControlPC
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    rollback   ip=${gnb_ip}
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified   login_ip=${gnb_ip}
    Check Gnb and Enb Status after Gnb Upgrade Rollback   action=rollback   ip=${gnb_ip}
    run keyword and ignore error   Check If GPS Upgrade Alarm Clear and GPS Status   ip=${gnb_ip}
    ${operation_status}   Check Operation Status in NetAct   operation=Rollback   input_btsname=${mr_btsid}
    should contain any    ${operation_status}   Successful    Timeout-Success
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}   ip=${gnb_ip}
    wait until keyword succeeds   10 min   30 s    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    Check NetAct Operations

COAM Nom Upgrade
    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/provision
    Set Suite Variable   ${operation}   provision
#    Catch Realtime Log    operation=provision
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
#    Check Cell Setup in COAM
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    # it takes time to wait alarm raise when cell not onAir, for example, fault 1868 on AEQN
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
#    Validate Config by WebEM
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}

COAM Nom Rollback
    Trigger SW Operation from Nom    operation=rollback   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    run keyword and ignore error    run keyword if  '${bts_id}' not in @{not_collect_log_when_alarm}
    ...   Wait Until Keyword Succeeds   3x   10 s    Enable collect logs when alarm report
    ...   ${OUTPUT_DIR}/${TEST_NAME}/rollback
    Set Suite Variable   ${operation}   rollback
#    Catch Realtime Log    operation=rollback
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated    rollback
    wait until keyword succeeds  15 min   10s   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   NSA   SA+NSA
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check X2 Link Status
    run keyword if   ${cellDepType_status}   Wait Until Keyword Succeeds    5 min    10s    Check if alarm of X2 is exist
    repeat keyword  5 min   Coam Check Site Status    if_ignore_cablink=${False}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType} or 'SA+NSA' in ${cellDepType}
    ...   Check AMF Status from WebEM   ${WEBUI_URL}

BTS upgrade via NetAct Upgrade
    Run Keyword    Change RollbackReject by CM Provsion in Bankend on ${NMS_TYPE}   bts=${input_btsname}   rollback_status=true
    ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
    ${cells}   run keyword if  ${L3callBTS_status}   set variable   ${BTS_L3call}[${bts_id}]
    run keyword if  ${L3callBTS_status} and '${l3_call}'=='Y'   run keyword and ignore error
    ...   Data Transfer Conducted for UUF   dir=${TEST_NAME}/provision   cells=${cells}
    run keyword if    '${NMS_TYPE}'=='netact'    Trigger SW Upgrade from NetAct
    ...   ELSE    Trigger SW Operation from Nom    operation=provision   nom_nodeip=${nom_nodeip}   bts_id=${bts_id}   version=${upgrade_version}
    run keyword if    '${NMS_TYPE}'=='netact'    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    Set Suite Variable   ${operation}   provision
#    Catch Realtime Log    operation=provision
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain any   ${cellDepType}   both   SA+NSA
    run keyword if   ${cellDepType_status}   sleep   5min
    repeat keyword  5 min   Coam Check Site Status
