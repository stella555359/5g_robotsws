*** Settings ***
Documentation
...   author:Jiang Johnny
...   contact: johnny.1.jiang@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Library   taf.transport.ssh   WITH NAME   csn
Resource   ../../common/NetAct_selenium.robot
Resource   ../../common/NetAct_swing.robot
Resource   ../../5GI000114/Resource/FM_common.robot
Resource    case_steps.robot
Variables    ../../libraries/global_vars.py
Resource   decode.robot
Resource    snapshot.robot
Resource   ../../common/taf_coam.robot

*** Variables ***
${NetAct_page}   https://kungfulbwas.kungfu.srnhz.nsn-rdnet.net/
${NetAct_user}   omc
${NetAct_password}  Nokia126_
${MO_NAME}  ${tl.gnbs[0].global_bts_id}
${ALARM_LIST_COMPONENT}    DesktopViewTable
${BBMOD}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${NetAct_ip}    10.106.161.25
${LMP_ADDR}    ${du_0.airscale.common_units[0].lmp_connection.addr}
${dist_name}   MNL-1/MNLENT-1/TRBLCADM-1
${instance_id}    ${tl.gnbs[0].instance_id}

*** Keywords ***
Case Setup
    selenium_coam.enable_virtual_display
    selenium_netact.enable_virtual_display
    wait until keyword succeeds   10min    30s    COAM WEBUI Login
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    Reset Env Parameter

Case Teardown
    selenium_coam.Logout
    selenium_coam.disable_virtual_display
    selenium_netact.disable_virtual_display
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword and Ignore Error   COAM Logout

Step1: modify L1 configuration files in gnb
    csn.Connect to    hostname=${ASIx_ADDR}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.Connect to    hostname=${Abil_ADDR}    username=${asik_username}    password=${asik_password}    proxy=asik    alias=abil
    csn.Download File   remote_path=${abil_path}${filename}   local_path=${local_path}${filename}   connection=abil
    csn.Upload File   local_path=${local_path}${filename}   remote_path=/ffs/run/boardcfg/1/C/mcu-aspa/boot/${filename}   connection=asik
    csn.execute    command=sed -i "s/prach_snapshot_test_mode = 0/prach_snapshot_test_mode = 1/g" /ffs/run/boardcfg/1/C/mcu-aspa/boot/${filename}
    ...   connection=asik

Step2: reset site
    COAM Login   alias=coam
    selenium_coam.reset_site
    wait until keyword succeeds   5min    20s    Wait for Site Unavailability

Check alarm id in list
     [Arguments]     ${exp_alarm_id}
     ${alarm_id_list} =    Get active alarm ids
     FOR  ${alarm_id}  IN  @{alarm_id_list}
         Return From Keyword If    '${alarm_id}' == '${exp_alarm_id}'     ${TRUE}
     END
     [Return]    ${FALSE}

Get active alarm ids
     ${active_alarms_details}=     Fetch active alarms
     ${alarm_id_list}=    Create list
     FOR  ${alarm}  IN  @{active_alarms_details}
         ${alarm_id}=    Get From Dictionary    ${alarm}    Alarm ID
         append to list    ${alarm_id_list}     ${alarm_id}
     END
     [Return]    ${alarm_id_list}

Fetch active alarms
    ${active_alarms} =     selenium_coam.get_active_alarm_info
    [Return]    ${active_alarms}

Get Snapshot List
    csn.Connect to   hostname=${NetAct_ip}   username=root   password=arthur   alias=Netact
    ${snapshot}   csn.Execute   command=ls /d/oss/global/diagsnap/ne3sws/   connection=Netact
    ${snapshot_list}   set variable  ${snapshot.splitlines()}
    [Return]    ${snapshot_list}

Download Snapshot to VM
    [Arguments]     ${snapshot_name}
    csn.Connect to   hostname=${NetAct_ip}   username=root   password=arthur   alias=Netact
    csn.Download File   remote_path=/d/oss/global/diagsnap/ne3sws/${snapshot_name}
    ...   local_path=${OUTPUT_DIR}/${snapshot_name}     connection=Netact

L3 Call
    sleep  2min
    ${res}   Run Keyword and Ignore Error   Setup Call by mode   call_mode=single
#    Should Be Equal   ${res[0]}   PASS
    Run Keyword Unless	'${res[0]}' == 'PASS'    log    L3 CALL FAILED!    WARN
    Set Suite Variable   ${call_alias}   ${res[1]}
    sleep  30s

Reset Env Parameter
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    ${bts_info}   COAM Get BTS Info
    Run Keyword If   ${bts_info.has_key('mrbtsID')}    Set Suite Variable   ${BTS_ID}   ${bts_info['mrbtsID']}
    ...   ELSE   Set Suite Variable   ${BTS_ID}   ${bts_info['requestMessage']['mrbtsID']}
    ${return_delay}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}
    ...   filter_param=Snapshot upload delay for fault 6450
    Run Keyword If   '${return_delay}'=='0'   selenium_coam.set_parameter_value
    ...     dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=Snapshot upload delay for fault 6450   new_value=99
    ${return_drb}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${instance_id}
    ...   filter_param=Stand alone UE DRB inactivity timer
    Run Keyword If   '${return_delay}'!='5'   selenium_coam.set_parameter_value
    ...     dist_name=MRBTS-${BTS_ID}/NRBTS-${instance_id}   filter_param=Stand alone UE DRB inactivity timer   new_value=5
    run keyword and ignore error   selenium_coam.validate_plan
    sleep  5s
    run keyword and ignore error   selenium_coam.activate_plan   activate_plan_despite_errors=True