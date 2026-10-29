*** Settings ***
Documentation      author: Kong Xiangli
...                contact: Xiangli.Kong@nokia-sbell.com
...                feature: CB010823

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
TC.CB010823_1_Run RF and SW Diagnostic check online from WebEM
    Set Test Variable    ${GnbReset}    False
    Log    ${AF_PATH}
    ${release}      String.Split String    ${AF_PATH}   _
    ${release}      set variable           ${release}[0]
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login    version=${release}
    sleep   180s
    ${autoreport}   selenium_sbts.get_report
    ${RUAutoReport}    set variable    ${autoreport['RU diagnostic check report']}

    #KW.CheckRUReport    RUreport=${RUAutoReport}    ID=40    CheckPoint=RU SW package and NVM integrity    TriggerType=Automatic
    KW.CheckRUReport    RUreport=${RUAutoReport}    CheckPoint=41    CheckPointName=RU Memory usage    TriggerType=Automatic
    KW.CheckRUReport    RUreport=${RUAutoReport}    CheckPoint=42    CheckPointName=RU Temperature sensor    TriggerType=Automatic

    ${date1}   Get Current Date   exclude_millis=True

    selenium_sbts.start_diagnostic_check   scope=Customized diagnostic check    timeout=1200
    sleep   60s
    #checkpoint 43 will cause RU reset
    Log To Console   waitAllCellsOnair
    Wait Until Keyword Succeeds    10min   10s    COAM_Admin.CheckAllCellsOnair
    ${customizedreport}   selenium_sbts.get_report
    ${RUcustomizedreport}    set variable    ${customizedreport['RU diagnostic check report']}
    #KW.CheckRUReport    RUreport=${RUcustomizedreport}    ID=40    CheckPoint=RU SW package and NVM integrity    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUcustomizedreport}    CheckPoint=41    CheckPointName=RU Memory usage    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUcustomizedreport}    CheckPoint=42    CheckPointName=RU Temperature sensor    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUcustomizedreport}    CheckPoint=43    CheckPointName=Extended RU DDR tests    TriggerType=WebEM
    Set Test Variable    ${UpdateTime1}    ${RUcustomizedreport[0]['Execution time GMT+0800']}

    selenium_sbts.start_diagnostic_check   scope=Full diagnostic check   allow_service_impact=True   timeout=1200
    sleep   60s
    #allow service impact site will reset
    Log To Console   waitAllCellsOnair
    Wait Until Keyword Succeeds    30min   10s    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Ignore error    COAM_WebEM.Logout
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login    version=${release}
    ${FullReport}   selenium_sbts.get_report
    ${RUFullreport}    set variable    ${FullReport['RU diagnostic check report']}
    #KW.CheckRUReport    RUreport=${RUFullreport}    ID=40    CheckPoint=RU SW package and NVM integrity    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUFullreport}    CheckPoint=41    CheckPointName=RU Memory usage    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUFullreport}    CheckPoint=42    CheckPointName=RU Temperature sensor    TriggerType=WebEM
    KW.CheckRUReport    RUreport=${RUFullreport}    CheckPoint=43    CheckPointName=Extended RU DDR tests    TriggerType=WebEM
    Set Test Variable    ${UpdateTime2}    ${RUFullreport[0]['Execution time GMT+0800']}

    Should Be True    '${UpdateTime1}'!='${UpdateTime2}'

    Run Keyword And Ignore error    COAM_WebEM.Logout
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    ${alarm_result}=    KW.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
    ...    Please check unexpect Alarm
    Run Keyword And Ignore error    WEBUI.Collect snapshot


KW.CheckRUReport
    [Arguments]    ${RUreport}    ${CheckPoint}    ${CheckPointName}    ${TriggerType}
    FOR  ${item}  IN  @{RUreport}
        run keyword if     '${item['Target distinguished name']}'!='${Target_distinguished_name}'     Continue For Loop
        run keyword if     '${item['Check point']}'!='${CheckPoint}'     Continue For Loop
        should be true     '${item['Check point name']}'=='${CheckPointName}'
        should be true     '${item['Trigger type']}'=='${TriggerType}'
        should be true     '${item['Check status']}'=='Check point successful'
    END

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
    @{Fault_whitelist}    Create list    4681   4655   4654   61524   61652   4459   61649    61618    61011
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
