*** Settings ***
Documentation      author: Gao Ge
...                contact: ge.gao@nokia-sbell.com
...                feature: CB008430

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource         ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py

Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
#Library           timing.py
Library           Collections

*** Variables ***
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT
${WTS_FILE_PATH}       ${tl.core.dir_path}

${UTE_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP_Secondary}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${model}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}

#######################################     #######################################
*** Keywords ***
TC.CB008430_General_SiSo_RF_module_reset_from_GUI
    Set Test Variable    ${GnbReset}    False
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        ${RMOD}=  Set Variable    ${RU['productName']}
        log to console  prepare to reset ${RMOD}
        ${config}=    Split String From Right    ${RU['id']['configuration']}     /
        ${tmp}=    Split String From Right    ${config[-1]}    -
        ${RU_Reset_INDEX}    Set Variable   ${tmp[-1]}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
        WEBUI.ResetRU    ru_index=${RU_Reset_INDEX}
        sleep    60s
        COAM_WebEM.Logout
        ${reset_status_Tmp}    Run Keyword And Return Status    wait until keyword succeeds    6min    1s    COAM_Admin.CheckAllCellsOnair
        ...    type=both    bts_host=${WEBUI_IP}
        ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True"    pass    fail
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${RU_Reset_INDEX}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        Run Keyword if   '${reset_status}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${RU_Reset_INDEX}
        Run Keyword And Continue On Failure    Run keyword if    '${reset_status}'!='pass'    Fail
    END

TC.CB008430_Manual_SiSo_SM_BTS_Site_Reset
    Set Test Variable    ${GnbReset}    True
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    sleep   20s
    ${reset_status_Tmp}    Run Keyword And Return Status    wait until keyword succeeds    12min    5s    COAM_Admin.CheckAllCellsOnair
        ...    type=both    bts_host=${WEBUI_IP}
    ${reset_status}	   Set Variable If	  "${reset_status_Tmp}"=="True"    pass    fail
    run keyword and ignore error    COAM_Admin.Logout
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
    ...    Please check unexpect Alarm
    Run Keyword if   '${reset_status}'!='pass' or '${alarm_result}'=='False'
    ...    Run Keyword And Ignore error    WEBUI.Collect snapshot
    Run Keyword And Continue On Failure    Run keyword if    '${reset_status}'!='pass'    Fail

TC.CB008430_Baseband_module_reset_from_BTSSM_WebEM
    Set Test Variable    ${GnbReset}    False
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    FOR    ${BBMOD}   IN    @{BTSInfo['basebandModules']}
        ${BBMOD_config}=    Split String From Right    ${BBMOD['id']['configuration']}     /
        ${BBMOD_ID}    Set Variable     ${BBMOD_config[-1]}
        ${tmp}=    Split String From Right   ${BBMOD_config[-1]}      -
        ${BBMOD_INDEX}    Set Variable   ${tmp[-1]}
        log to console  prepare to reset BBMOD_${BBMOD_INDEX}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
        selenium_coam.reset_abil    abil_index=${BBMOD_INDEX}
        sleep    20s
        ${reset_status_Tmp1}     Run Keyword And Return Status    wait until keyword succeeds  10min  1min
        ...    KW.CheckBBModStatus  bbModNum=${BBMOD_INDEX}  Operational_State=Enabled
        ${reset_status_Tmp2}     Run Keyword And Return Status    wait until keyword succeeds  10min  1min
        ...    KW.CheckAllRusStatus     Operational_State=Enabled
        ${reset_status_Tmp3}    Run Keyword And Return Status    wait until keyword succeeds   10min   1s
        ...    COAM_Admin.CheckAllCellsOnair    type=both    bts_host=${WEBUI_IP}
        ${reset_status}	   Set Variable If	  "${reset_status_Tmp1}"=="True" and "${reset_status_Tmp2}"=="True" and "${reset_status_Tmp3}"=="True"
        ...    pass    fail
        Run Keyword And Ignore error    COAM_WebEM.Logout
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${BBMOD_INDEX}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        Run Keyword if   '${reset_status}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${BBMOD_INDEX}
        Run Keyword And Continue On Failure    Run keyword if    '${reset_status}'!='pass'    Fail
    END

TC.CB008430_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    @{NR_UE}    create list    0
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    ${band}    Set Variable    ${TLCommonConfig['MultiUECFG']['0']['band']}
    ${cmd_lockNR}    Set Variable   AT+GTACT=14,,,50${band}
    log to console   prepare to NR L3call
    MultiRATUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}    cmd=${cmd_lockNR}
    sleep    30s
    @{LTE_UE}    create list    1
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${LTE_UE}
    ${cmd_lockLTE}    Set Variable   at+gtact=2
    log to console   prepare to LTE L3call
    MultiRATUE.L3Call    UECFG=${TLCommonConfig['MultiUECFG']}    cmd=${cmd_lockLTE}

TC.CB008430_General_SiSo_Cell_block_and_unblock
    Set Test Variable    ${GnbReset}    False
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    FOR    ${CELL}   IN    @{BTSInfo['cells']['nr']}
        ${cell_config}=    Split String From Right    ${CELL['id']['configuration']}     /
        ${nrcell}   Set Variable     ${cell_config[-1]}
        ${tmp_cell}=    Split String From Right    ${nrcell}     -
        ${cell_index}   Set Variable     ${tmp_cell[-1]}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
        log to console  prepare to block CELL_${cell_index}
        selenium_sbts.block_cell     cell_idx=${cell_index}
        sleep    10s
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_index}
        ${blockcell_status}     Run Keyword And Return Status    wait until keyword succeeds    5min    10s
        ...    Should Be Equal As Strings    ${cell_info['Status']['Blocking state']}    Blocked    ignore_case=${True}
        ${Cell_blocked_fault}   Set Variable    49
        ${fault_result}    KW.CheckFault    fault_id=${Cell_blocked_fault}

        log to console  prepare to unblock CELL_${cell_index}
        selenium_sbts.unblock_cell    cell_idx=${cell_index}
        sleep    10s
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_index}
        ${unblockcell_status}     Run Keyword And Return Status    wait until keyword succeeds    5min    10s
        ...    Should Be Equal As Strings    ${cell_info['Status']['Blocking state']}    Unblocked    ignore_case=${True}

        ${status}	   Set Variable If	  "${blockcell_status}"=="True" and "${unblockcell_status}"=="True" and "${fault_result}"=="True"
        ...    pass    fail
        Run Keyword And Ignore error    COAM_WebEM.Logout
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${cell_index}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        Run Keyword if   '${status}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${cell_index}
        Run Keyword And Continue On Failure    Run keyword if    '${status}'!='pass'    Fail
    END

TC.CB008430_Manual_SiSo_SM_RF_Module_lock_unlock
    Set Test Variable    ${GnbReset}    False
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    FOR    ${RU}   IN    @{BTSInfo['radioModules']['rmod']}
        ${RMOD}=  Set Variable    ${RU['productName']}
        ${config}=    Split String From Right    ${RU['id']['configuration']}     /
        ${tmp}=    Split String From Right    ${config[-1]}    -
        ${ru_index}    Set Variable   ${tmp[-1]}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        wait until keyword succeeds    10min    10s    COAM_WebEM.Login
        log to console  prepare to lock RU_${ru_index}
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  30
        ${rmode_info}    selenium_coam.get_ru_info   ru_index=${ru_index}
        ${lockRU_status}     Run Keyword And Return Status    wait until keyword succeeds    5min    20sec
        ...    Should Be Equal As Strings    ${rmode_info["Status"]["Administrative state"]}    Locked    ignore_case=${True}

        log to console  prepare to unlock RU_${ru_index}
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  30
        ${rmode_info}    selenium_coam.get_ru_info   ru_index=${ru_index}
        ${unlockRU_status}     Run Keyword And Return Status    wait until keyword succeeds    5min    20sec
        ...    Should Be Equal As Strings    ${rmode_info["Status"]["Administrative state"]}    Unlocked    ignore_case=${True}
        ${cell_status}    Run Keyword And Return Status    wait until keyword succeeds   10min   1s
        ...    COAM_Admin.CheckAllCellsOnair    type=both    bts_host=${WEBUI_IP}

        ${status}	   Set Variable If	  "${lockRU_status}"=="True" and "${unlockRU_status}"=="True" and "${cell_status}"=="True"
        ...    pass    fail
        Run Keyword And Ignore error    COAM_WebEM.Logout
        Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${ru_index}
        ${alarm_result}=    KW.GetAndCheckAlarm
        Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
        Run Keyword if   '${status}'!='pass' or '${alarm_result}'=='False'
        ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${ru_index}
        Run Keyword And Continue On Failure    Run keyword if    '${status}'!='pass'    Fail
    END

TC.CB008430_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot    is_get_snapshot_via_selenium=${True}

KW.CheckFault
    [Arguments]    ${fault_id}=NULL
    COAM_WebEM.Login
    ${active_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{active_alarm}
        ${fault}    get from dictionary    ${item}    Fault ID
        append to list    ${fault_id_list}    ${fault}
    END
    log    ${fault_id_list}
    ${fault_result}=    Run Keyword And Return Status    list should contain value     ${fault_id_list}    ${fault_id}
    [Return]    ${fault_result}

MultiRATUE.L3Call
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0    ${cmd}=NULL
    Run Keyword And Continue On Failure    MultiUE.PrepareUE
    ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=1
    ${return}    spark.send_at_command_on_ue    command=${cmd}    ue_alias=UE_${default_ue_index}
    Should Contain    ${return}    OK
    sleep   10
    Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
    sleep   10
    Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}

KW.CheckBBModStatus
    [Documentation]  Check the status of the reset BBMod
    [Arguments]  ${bbModNum}  ${Operational_State}
    ${bbmode_info}    selenium_coam.get_abil_info    abil_index=${bbModNum}
    Should Be Equal As Strings    ${bbmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}

KW.CheckAllRusStatus
    [Arguments]  ${Operational_State}=Enabled
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    FOR    ${CABLE}   IN    @{BTSInfo['cables']}
        ${RMOD_config}   Split String From Right    ${CABLE['secondEndPointId']['configuration']}     /
        ${RMOD_ID}   Set Variable     ${RMOD_config[-2]}
        ${tmp}=    Split String From Right   ${RMOD_ID}    -
        ${RMOD_INDEX}    Set Variable   ${tmp[-1]}
        ${rmode_info}    selenium_coam.get_ru_info  ru_index=${RMOD_INDEX}
        Should Be Equal As Strings    ${rmode_info["Status"]["Operational state"]}    ${Operational_State}    ignore_case=${True}
    END

WEBUI.ResetRU
      [Documentation]   Reset ru on webui.
      [Arguments]      ${ru_index}=1
      selenium_coam.reset_ru_from_site_view       ru_index=${ru_index}

WEBUI.Collect snapshot
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_${loop}.zip

Stop BTSlogs Collection and get logs for every loop
    [Arguments]   ${loop}
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME}_SYSLOG_${loop}.tgz SYSLOG_*.LOG
    run    command=cp /tmp/${TEST NAME}_SYSLOG_${loop}.tgz ${LOG_PATH}

KW.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459   61649    61618    61011     10
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
    COAM_WebEM.Login
    ${active_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}=    Wait Until Keyword Succeeds    3X    1min    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}

Setup Suite
    TestSuilt.Start
    Import Variables     ${CFGFILE_PATH}/TLConfiguration.py

Teardown Suite
    TestSuilt.Stop

TestCase Setup
    TestCase.Start

TestCase Teardown
    TestCase.Stop