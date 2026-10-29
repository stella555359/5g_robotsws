*** Settings ***
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG1/Cloud_Base_Resource.robot
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
*** Keywords ***
KW.vDUTryRecovery
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=0
    log to console    Case Start PreCheck
    #Check RU Status
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${ru_infos}=  vdu.get_rmods_status    vdu_connection=${vdu_connection}
    FOR    ${ru_info}    IN    @{ru_infos}
        ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
        #${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
        run keyword if    '${administrative_state}'!='unlocked'
        ...    vdu.unlock_rmods    rmod_id_list=[${ru_info["id"]}]    vdu_connection=${vdu_connection}
        wait until keyword succeeds    5min    30s   RU Status Should Be Unlocked    ru_id=${ru_info["id"]}
        ...    vdu_index=${vdu_index}
    END
    #Check CellStatus
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${vdu_connection}
    FOR  ${cell}  IN  @{cells_status}
        ${administrative_state}=    Convert To Lowercase   ${cell["administrative_state"]}
        ${blocking_state}=    Convert To Lowercase   ${cell["blocking_state"]}
        run keyword if    '${administrative_state}'!='unlocked'
        ...    vdu.unlock_cells    cell_id_list=[${cell["id"]}]    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${cell["id"]}
        ...    administrative_state=Unlocked
        run keyword if    '${blocking_state}'!='unblocked'
        ...    vdu.unblock_cell    cell_id=${cell["id"]}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${cell["id"]}
        ...    blocking_state=Unblocked
    END
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

#KW.vCUTryRecovery
#    [Arguments]    ${gnb_index}=0
#    log to console    Case Start PreCheck
#    #Check RU Status
#    ${vdu_connection}    KW.vCULogin    gnb_index=${gnb_index}
#    #Check CellStatus
#    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${conn_alias}
#    FOR  ${cell}  IN  @{cells_status}
#        ${administrative_state}=    Convert To Lowercase   ${cell["administrative_state"]}
#        run keyword if    '${administrative_state}'!='unlocked'
#        ...    vdu.unlock_cells    cell_id_list=[${cell["id"]}]    vdu_connection=${conn_alias}
#        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${index}
#        ...    administrative_state=Unlocked
#        run keyword if    '${blocking_state}'!='unblocked'
#        ...    vdu.unblock_cell    cell_id=${cell["id"]}    vdu_connection=${conn_alias}
#        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${index}
#        ...    blocking_state=Unblocked
#    END
#    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.vDUCollectLog
    [Arguments]    ${gnb_index}=0  ${vdu_index}=${0}
    wait until keyword succeeds    10min    1min   KW.vDUGetSnapshot    gnb_index=${gnb_index}    vdu_index=${vdu_index}

KW.vCUCollectLog
    [Arguments]    ${gnb_index}=${0}
    wait until keyword succeeds    10min    1min   KW.vCUGetSnapshot    gnb_index=${gnb_index}

KW.OAMKPICaseStart
    [Arguments]    ${KPIsList}    ${retry_times}=1    ${gnb_index}=0    ${vdu_index}=0
    log to console    ${gnb_index}
    log to console    ${vdu_index}
    &{kpi_results}  Create Dictionary
    FOR    ${key}   IN    @{KPIsList}
        ${key}=  Set Variable  ${key.replace('KPI', 'kpi')}
        Set To Dictionary    ${kpi_results}    ${key}=@{EMPTY}
    END
    Set suite Variable  ${kpi_results}
    ${kpi_list}  Get Dictionary Keys  ${kpi_results}
    Set Test Variable  ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    Set Test Variable  ${target_kpis}    ${kpi_list}
    KW.CaseStatusInit    retry_times=${retry_times}

KW.OAMKPILoopStart
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    #ims_keywords.check_instance_connection   gnbbbu
    #oam_kpi_calculations.clear_results
    ${loopStartTime}    KW.GetCurrentTimeTick
    set test variable   ${loopStartTime}    ${loopStartTime}
    set test variable   ${loopStatus}    failed
    KW.vDUTryRecovery    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    No Operation

KW.OAMKPILoopEnd
    [Arguments]    ${loop}    ${isCellOnair}    ${alarm_result}    ${gnb_index}=0    ${vdu_index}=0
    log to console    ${loop}
    log to console    ${isCellOnair}
    log to console    ${alarm_result}
    log to console    ${gnb_index}
    log to console    ${vdu_index}
    run keyword and ignore error    KW.vDUGetAndCheckAlarm    gnb_index=${gnb_index}    vdu_index=${vdu_index}    startTimeStamp=${loopStartTime}
    run keyword and ignore error    KW.vCUGetAndCheckAlarm    gnb_index=${gnb_index}    startTimeStamp=${loopStartTime}
    run keyword and ignore error    KW.CheckvDUCoreDump
    run keyword and ignore error    KW.CheckvCUCoreDump
    run keyword if    '${loopStatus}'=='failed'    KW.vDUCollectLog    vdu_index=${vdu_index}
    run keyword if    '${loopStatus}'=='failed'    KW.vCUCollectLog    gnb_index=${gnb_index}
    No Operation
#    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
#    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
#    ${kpiValue}  KW.Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
#    ims_keywords.instance_disconnect    gnbbbu
#
#    KW.SendResultToToolCenter    isCellOnair=${isCellOnair}    loop=${loop+1}
#    ...                          isUnexpectedAlarm=${alarm_status}    kpiValue=${kpiValue}
#
#
##    KW.SendResultToToolCenter    isCellOnair=${isCellOnair}
##    ...        isUnexpectedAlarm=${alarm_result}    loop=${loop}+1
##    ...        kpiValue=${kpiValue}
#
#    ${kpiName}    set variable    ${kpi_list[0].replace('kpi', 'KPI')}
#    KW.CaseStatusCaluate    duration=${kpiValue}    max=${CASE_INPUT_5GC002479['5GC002479_HA_${kpiName}']['${kpiName}_MAX']}
#    log to console     Case loop ${loop+1} END
#    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
#    ...    Please check unexpect Alarm

KW.OAMKPICaseEnd
    [Arguments]    ${times}    ${gnb_index}=0    ${vdu_index}=0
    log to console    ${times}
    log to console    ${gnb_index}
    log to console    ${vdu_index}
    No Operation
#    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
#    Run Keyword and Ignore Error   ute_reporting_portal.Set reference configuration ID  ref_configuration_id=${REFERENCE_CONFIGURATION_ID}
#    Run Keyword and Ignore Error   report_oam_kpi.Report Oam Kpi   oam_kpi_results=${kpi_results}    oam_kpi_targets=${OAM_KPI_TARGETS}
#
#    FOR  ${kpi}  IN  @{kpi_list}
#        Run Keyword and Ignore Error   report_oam_kpi.Report OAM KPI Success Rate    kpi_name=${kpi}
#        ...    passed_iterations=${CaseAVGLoop}    executed_iterations=${CaseMaxTime}
#        ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['${kpi}']}
#
#        ${kpi}    set variable    ${kpi.replace('kpi', 'KPI')}
#        Run Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_MAX']}   Fail
#        ...   ${kpi} average is above Target ${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_MAX']}
#        KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_AVG']}    max_loop=${times}
#    END

KW.Analyse IMS File
    [Arguments]  ${kpi_list}   ${kpi_params}=${None}    ${loop}=0
    oam_kpi_calculations.Calculate Kpis  kpi_names=${kpi_list}   ims_file_path=${ims_file}    kpi_params=${kpi_params}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${LOG_PATH}/loop${loop}_ims2/results_${ext_json_name}.json
    ${result}  oam_kpi_calculations.get_results
    ims_keywords.save_kpi_to_csv_results  ${loop}  ${LOG_PATH}/loop${loop}_ims2  ${result}  ${active_alarms_list}
    FOR  ${kpi}  IN  @{kpi_list}
        ${kpi}=  Set Variable  ${kpi.replace('KPI', 'kpi')}
        ${x} = 	Combine Lists 	${kpi_results['${kpi}']} 	${result['${kpi}']}
        Set To Dictionary  ${kpi_results}  ${kpi}  ${x}
    END

    FOR  ${kpi}  IN  @{target_kpis}
        ${kpivalue}  oam_kpi_calculations.get_average_results  kpi_name=${kpi}
    END
    [Return]    ${kpivalue}

KW.AutoClearLog
    [Arguments]    ${loop}=0
    run keyword if     ${loop}>${20} and '${CASE_INPUT_5GC002479['5GC002479']['AutoClearLog']}'=='true'
    ...    KW.ClearLog    loop=${loop-20}

KW.ClearLog
    [Arguments]    ${loop}=0
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    run     cd ${LOG_PATH}&&rm *${filename}_${loop}*

KW.LMILogInit
    log to console    KW.LMILogInit
    run keyword and ignore error    Log.LMIConsoleLogInit   lmi=${TLCommonConfig['rus']['0']}
    Log.LMIBtsLogInit  lmi=${TLCommonConfig['rus']['0']}

KW.LMIEthOn
    log to console    KW.LMIEthOn
    Log.LMIEnableLMIOn    lmi=${TLCommonConfig['rus']['0']}

KW.LMILogCollect
    [Arguments]    ${loop}=0    ${result}=pass
    log to console    KW.LMILogCollect
    run keyword if    '${result}'!='pass'   run keyword and ignore error    Log.LMIRULogCollect
    ...    lmi=${TLCommonConfig['rus']['0']}    loop=${loop}
    run keyword and ignore error    Log.LMIBtsLogCollect  lmi=${TLCommonConfig['rus']['0']}    loop=${loop}
    run keyword and ignore error    Log.LMIConsoleLogCollect    lmi=${TLCommonConfig['rus']['0']}    loop=${loop}

KW.StartLogCollection
    [Arguments]    ${btslog}=${True}
    Run Keyword And Ignore error   KW.LMILogInit
    run keyword if     ${btslog}    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Run Keyword And Ignore error   KW.LMIEthOn

KW.StopLogCollection
    [Arguments]    ${isCellOnair}    ${alarm_result}    ${loop}    ${btslog}=${True}
    run keyword if     ${btslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop+1}
    Run Keyword if   '${isCellOnair}'!='True' or '${alarm_result}'=='False'
    ...    Run Keyword And Ignore error    WEBUI.Collect snapshot    loop=${loop+1}
    Run Keyword And Ignore error    KW.LMILogCollect   loop=${loop+1}

BtsLog.StopBTSlogCollectionandGetlog_setup
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/setup_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/setup_SYSLOG.tgz ${LOG_PATH}/.

WEBUI.Collect snapshot
    [Arguments]    ${loop}=0
    log to console    ${loop}
    No Operation
#    COAM_WebEM.Login
#    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
#    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
#    log    ${snapshot_file}
#    Run Keyword And Ignore Error    COAM_WebEM.Logout
#    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
#    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_${loop}.zip

KW.SendResultToToolCenter
    [Arguments]    ${kpiValue}    ${isCellOnair}    ${isUnexpectedAlarm}    ${loop}

    ${loopStatus}    set variable if    "${isCellOnair}"=="True"  AND  ${kpiValue}<1800  AND  "${isUnexpectedAlarm}"=="True"    pass    fail
#    ...      AND  "${isUnexpectedAlarm}"=="True"    pass    fail

    Run Keyword And Ignore error    Get common info
    ...    case_result=${loopStatus}    case_name=${kpi_list[0]}   loop_number=${loop}  duration_time=${kpiValue}

KW.CaseStatusInit
    [Arguments]           ${retry_times}=3
    Set Suite Variable    ${CasePassRateStatus}     NotExecute
    Set Suite Variable    ${CaseAVGLoop}     ${0}
    Set Suite Variable    ${CaseMaxTime}     ${retry_times}
    Set Suite Variable    ${CaseSUM}         ${0}

KW.CaseStatusCaluate
    [Arguments]       ${duration}=${0}    ${max}=${0}
    ${CaseSUM}        run keyword if    ${duration}<=${max}    Evaluate    ${CaseSUM}+${duration}
    ...    ELSE    Set Variable    ${CaseSUM}
    ${CaseAVGLoop}    run keyword if    ${duration}<=${max}    Evaluate    ${CaseAVGLoop}+${1}
     ...    ELSE    Set Variable    ${CaseAVGLoop}
    Set Suite Variable    ${CaseSUM}     ${CaseSUM}
    Set Suite Variable    ${CaseAVGLoop}         ${CaseAVGLoop}
    run keyword if    '${CasePassRateStatus}'=='NotExecute'    Set Suite Variable    ${CasePassRateStatus}    PASS
    run keyword if    ${duration}>${max}    Set Suite Variable    ${CasePassRateStatus}    FAIL

KW.CaseStatusFinnal
    [Arguments]        ${case_avg}=${0}    ${max_loop}=${0}
    log to console    ${max_loop}
    ${avg}    run keyword if     ${CaseAVGLoop}>0   Evaluate    ${CaseSUM}/${CaseAVGLoop}
    ...    ELSE    Fail    0 loop pass
    should be true    ${avg}<=${case_avg}
    [Return]    ${avg}

KW.PassRateStatusFinal
    run keyword if    '${CasePassRateStatus}'!='PASS'    Fail    case ${CaseAVGLoop} loop pass in ${CaseMaxTime} loop

KW.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459   61649    61618    61011    4590    4681
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

Start BTSlogs Collection
    run keyword and ignore error    run    command=cd /tmp/btslog2 ; rm -rf TRACE_*.bin ; rm -rf SYSLOG_*.LOG
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlogs Collection and get logs
    core.teardown_collectors      names=btslog
    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cp /tmp/${TEST NAME.replace(" ", "_")}_SYSLOG.tgz ${LOG_PATH}

Stop BTSlogs Collection and get logs for every loop
    [Arguments]   ${loop}
    core.teardown_collectors      names=btslog
    ${time}    Get time    epoch
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
#    run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
#    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${TEST NAME.replace(" ", "_")}${loop}_SYSLOG.tgz SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/BTSLOG_${filename}_${loop}_${time}.tgz SYSLOG_*.LOG
    run    command=cp /tmp/BTSLOG_${filename}_${loop}_${time}.tgz ${LOG_PATH}

Analyse IMS File
    [Arguments]  ${kpi_list}   ${kpi_params}=${None}    ${loop}=0
    oam_kpi_calculations.Calculate Kpis  kpi_names=${kpi_list}   ims_file_path=${ims_file}    kpi_params=${kpi_params}
    Run Keyword and Continue on Failure  oam_kpi_calculations.save_results_to_file
    ...    file_path=${LOG_PATH}/loop${loop}_ims2/results_${ext_json_name}.json
    ${result}  oam_kpi_calculations.get_results
    ims_keywords.save_kpi_to_csv_results  ${loop}  ${LOG_PATH}/loop${loop}_ims2  ${result}  ${active_alarms_list}
    FOR  ${kpi}  IN  @{kpi_list}
        ${x} = 	Combine Lists 	${kpi_results['${kpi}']} 	${result['${kpi}']}
        Set To Dictionary  ${kpi_results}  ${kpi}  ${x}
    END
    FOR  ${kpi_name}  IN  @{target_kpis}
        ${kpi}=  Set Variable  ${kpi_name.replace('KPI_', 'kpi')}
        ${kpi_avg}  oam_kpi_calculations.get_average_results  kpi_name=${kpi}
        ${duration_time_tmp}    Set test Variable   ${kpi_avg}
        Return From Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_${kpi_name}']['${kpi_name}_MAX']}  ${True}
    END

    Return From Keyword    ${False}

Collect IMS File
   [Arguments]   ${log_dir}   ${needprevIMS}=false
   ${ims_sesion_file_path}   run keyword if   '${needprevIMS}'=='true'   get_last_disconnected_ims_log  log_dir=${OUTPUT_DIR}
   ${ims_file_path}  gnb_log.Collect IMS Log From gNB  log_dir=${log_dir}  timeout=${600}
   @{ims_files}=  List Files In Directory  ${log_dir}  pattern=IMS_Log*.ims2
   ${allIMSs}   run keyword if   '${needprevIMS}'=='true'   create list    ${ims_file_path}   ${log_dir}${ims_files[-1]}
   ...    ELSE   Set Variable  ${log_dir}${ims_files[-1]}
   Set Suite Variable  ${ims_file}  ${allIMSs}
   #OperatingSystem.run  find ${log_dir} -name \"*.ims2\" -exec rm {} \\;

Collect Active Alarms
    [Arguments]    ${loop}=0
    ${active_alarms_list}=   ims_keywords.Get Active Alarms  allowed_alarms=${ALLOWED_ALARMS}
    Set Test Variable  ${active_alarms_list}
    ims_keywords.Save Alarms  ${active_alarms_list}  ${LOG_PATH}/loop${loop}_ims2
    Return From Keyword If  ${active_alarms_list} != @{EMPTY}   ${True}
    Return From Keyword    ${False}

Check all cells Should Be On Air
     wait until keyword succeeds    30min    1s    Check BTS Onair

Check all cells Should Be On Air and caputre snapshot if not on air
     ${cell_status}     Run Keyword And Return Status   wait until keyword succeeds    30min    1s    Check BTS Onair
     Run Keyword If    '${cell_status}'=='False'    Run Keyword And Ignore error    WEBUI.Collect snapshot
      ...    ELSE IF    '${cell_status}'=='True'      log     gnb is onair


Check BTS Onair
    Run Keyword If   '${BTSMOD}'=='5GOnly'    COAM_Admin.CheckAllCellsOnair    type=nr    bts_host=${5G_WEBUI_IP}
    ...    ELSE IF          '${BTSMOD}'=='ConCorrent'    run keywords
    ...    COAM_Admin.CheckAllCellsOnair    type=nr    bts_host=${5G_WEBUI_IP}    AND
    ...    COAM_Admin.CheckAllCellsOnair    type=lte   bts_host=${4G_WEBUI_IP}
    ...    ELSE    Fail

