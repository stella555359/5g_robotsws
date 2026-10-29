*** Settings ***
Resource          5GC002479_CP_Resource.robot

*** Variables ***

*** Keywords ***
TC.RF_Reset
    [Arguments]   ${kpiList}    ${times}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.RF_ResetWithRetry     retry_times=${times}
    KW.OAMKPICaseEnd    times=${times}

KW.RF_ResetWithRetry
    [Arguments]    ${retry_times}=3
    Set Test Variable    ${GnbReset}         True
    Set Test Variable    ${with_graceful}    False
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForRFReset    loop=${i+1}    with_graceful=${with_graceful}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForRFReset
    [Arguments]    ${loop}   ${with_graceful}
    wait until keyword succeeds   10x   1min    COAM_WebEM.Login
    WEBUI.ResetRU    ru_index=1    with_graceful=${with_graceful}
    sleep    60s
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${isCellOnair}

TC.Site_Reset
    [Arguments]   ${kpiList}    ${times}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.Site_ResetWithRetry     retry_times=${times}
    KW.OAMKPICaseEnd    times=${times}

KW.Site_ResetWithRetry
    [Arguments]    ${retry_times}=3
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForSiteReset    loop=${i+1}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForSiteReset
    [Arguments]    ${loop}
    wait until keyword succeeds   10x   1min    COAM_Admin.Login
    COAM_Admin.ResetSite     timeout=1800
    sleep    60s
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    run keyword and ignore error    COAM_Admin.Logout
    [Return]    ${isCellOnair}

TC.BaseBand_Reset
    [Arguments]   ${kpiList}    ${times}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.BaseBand_Reset_WithRetry     retry_times=${times}
    KW.OAMKPICaseEnd    times=${times}

KW.BaseBand_Reset_WithRetry
    [Arguments]    ${retry_times}=3
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForBaseBandReset    loop=${i+1}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForBaseBandReset
    [Arguments]    ${loop}
    wait until keyword succeeds   10x   1min    COAM_WebEM.Login
    selenium_coam.reset_abil    abil_index=1
    sleep    30s
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${isCellOnair}

TC.DeltaCommission
    [Arguments]   ${kpiList}    ${times}=1    ${type}=WithSiteReset
    [Documentation]  type: WithSiteReset    WithRATReset     WithoutReset
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.DeltaCommissionWithRetry     retry_times=${times}    type=${type}
    KW.OAMKPICaseEnd    times=${times}

KW.DeltaCommissionWithRetry
    [Arguments]    ${retry_times}=3    ${type}=WithSiteReset
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForDeltaCommission    loop=${i+1}    type=${type}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForDeltaCommission
    [Arguments]    ${loop}    ${type}=WithSiteReset    ${KPIMax}=10000
    run keyword if    '${type}'=='WithSiteReset'
    ...    KW.DeltaCommissionWithSiteReset
    ...    ELSE IF    '${type}'=='WithRATReset'
    ...    KW.DeltaCommissionWithRATReset
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    [Return]    ${isCellOnair}

KW.DeltaCommissionWithSiteReset
    [Documentation]
    ...   Purpose:test case is to check configuration file_delta plan(Site level service outage need)
    ...            can be validation/activation can be successful and duration meet requirement.
    ...   Precondition: No error after do validation.
    ...   Test tools:WebUI
    ...   Test Steps:
    ...     Step1: Modify parameter which will cause site reset has error when do validation.
    ...            eg:modify 'actNcYgMPlane' to a different value.
    ...     Step2: Validate and check error not exist on WebEM.
    ...     Step3: Do activation,caculate activation duration(duration is captured from system) and check validation
    ...            duration no more than requirement.
    COAM_WebEM.Login
    Log To Console    Step1:Modify parameter which will cause site reset has error when do validation.
    ${actNcYgMPlane_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1     filter_param=Activate NetConf/YANG M-Plane connection    abbr=actNcYgMPlane
    run keyword if    "${actNcYgMPlane_Value}"=="false"
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1              filter_param=Activate NetConf/YANG M-Plane connection
    ...    new_value=true   abbr=actNcYgMPlane
    ...    ELSE
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/MNL-1             filter_param=Activate NetConf/YANG M-Plane connection
    ...    new_value=false   abbr=actNcYgMPlane
    Log To Console    Step2: Validate and check error not exist on WebEM.
    selenium_coam.validate_plan
    ${error}    selenium_coam.get_relation_errors
    Should Be Empty     ${error}
    Log To Console    Step3: Do activation,caculate activation duration and check validation duration no more than requirement
    ${timestartTmp}   Get Current Date
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    ${timestart}      convert date    ${timestartTmp}    epoch
    ${timeendTmp}     Get Current Date
    ${timeend}        convert date    ${timeendTmp}     epoch
    ${duration_time_tmp_STEP2}    Evaluate    ${timeend}-${timestart}

KW.DeltaCommissionWithRATReset
    [Documentation]
    COAM_WebEM.Login
    Log To Console    Step1:Modify parameter which will cause 5G RAT reset.
    ${actNonBfAndBfCa_Value}    selenium_coam.get_parameter_value
    ...    dist_name=${distname}/NRDU-1    filter_param=Activate non beamforming and beamforming TDD FR1 CA    abbr=actNonBfAndBfCa
    run keyword if    "${actNonBfAndBfCa_Value}"=="false"
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}/NRDU-1              filter_param=Activate non beamforming and beamforming TDD FR1 CA
    ...    new_value=true   abbr=actNonBfAndBfCa
    ...    ELSE
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${distname}/NRDU-1              filter_param=Activate non beamforming and beamforming TDD FR1 CA
    ...    new_value=false   abbr=actNonBfAndBfCa
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    COAM_WebEM.Logout
#    run keyword and ignore error    BtsLog.StopBTSlogCollectionandGetlog
TC.SW_Upgrade
    [Arguments]   ${kpiList}   ${conditions}    ${times}    ${OriginalStream}=${TargetBTSStream}    ${OriginalStreamSCF}=None
        ...    ${TargetStreamSCF}=None
    log    ${OriginalStreamSCF}
    ${OriginalStreamSCF}    set variable if    '${OriginalStreamSCF}'=='None'    ${TargetStreamSCF}    ${OriginalStreamSCF}
    log    ${OriginalStreamSCF}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.sw_upgrade_WithRetry
    ...    retry_times=${times}
    ...    OriginalStream=${OriginalStream}
    ...    OriginalStreamSCF=${CFGFILE_PATH}${OriginalStreamSCF}
    ...    TargetStreamSCF=${CFGFILE_PATH}${TargetStreamSCF}
    ...    conditions=${conditions}
    KW.OAMKPICaseEnd    times=${times}

KW.sw_upgrade_WithRetry
    [Arguments]      ${OriginalStream}    ${OriginalStreamSCF}    ${TargetStreamSCF}    ${conditions}    ${retry_times}=3
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForUpgrade
        ...    loop=${i+1}
        ...    OriginalStream=${OriginalStream}
        ...    OriginalStreamSCF=${OriginalStreamSCF}
        ...    TargetStreamSCF=${TargetStreamSCF}
        ...    conditions=${conditions}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForUpgrade
    [Arguments]   ${loop}   ${OriginalStream}    ${OriginalStreamSCF}    ${TargetStreamSCF}    ${max_num}=500
    ...           ${conditions}=${condition_PS_same}
    ...           ${status}=[released ,released_with_restrictions]
    run    command=rm -rf ${UPDATE_FILE_PATH}
    sleep   10s
    run    command=mkdir ${UPDATE_FILE_PATH}
    Set Test Variable    ${GnbReset}    True
    Set Suite Variable    ${TARGETSW}        ${TargetBTSVersion}
    Set Suite Variable    ${TargetStream}    ${TargetBTSStream}
    ${TargetBuildVersion}=         Set Variable         ${TargetBTSVersion}

    ${CurrentStreamSCF}   COAM_Admin.BackupSCF
    Set Suite Variable     ${CurrentStreamSCF}     ${CurrentStreamSCF}
    Set Suite Variable     ${OriginalStreamSCF}    ${OriginalStreamSCF}
    Set Suite Variable     ${OldCommissionSCF}     ${TargetStreamSCF}

    ${OriginalBuildVersion}=       KW.SWM.FilterGetGNBSWVersion      Target_build=${TargetBuildVersion}   max_num=${max_num}
    ...               stream=${OriginalStream}    status=${status}       conditions=${conditions}
    KW.SWM.PrepareOriginalENVbyYAFT    build_version=${OriginalBuildVersion}
    ${Target_package_path}        SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    selenium_coam.software_update     is_activate=${True}
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    Wait until keyword succeeds    10min    10s    5GC002479_Resouce.gNB.CheckgNBReset
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    [Return]    ${isCellOnair}

TC.Cell_Block_Unblock
    [Arguments]   ${kpiList}    ${times}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.cell_block_unblock_WithRetry    retry_times=${times}
    KW.OAMKPICaseEnd    times=${times}

KW.cell_block_unblock_WithRetry
    [Arguments]     ${retry_times}=3
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForCellBlockAndUnblock    loop=${i+1}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForCellBlockAndUnblock
    [Arguments]    ${loop}
    wait until keyword succeeds   10x   1min    COAM_WebEM.Login
    COAM_WEBEM.BlockUnBlcokCell    action=block
    sleep    60s
    COAM_WEBEM.BlockUnBlcokCell    action=unblock
    ${isCellOnair}          Run Keyword And Return Status     Check all cells Should Be On Air
    run keyword and ignore error    COAM_WebEM.Logout
    [Return]    ${isCellOnair}


TC.Cell_Lock_Unlock
    [Arguments]    ${kpiList}    ${times}
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}
    KW.cell_lock_unlock_WithRetry    retry_times=${times}
    KW.OAMKPICaseEnd    times=${times}


KW.cell_lock_unlock_WithRetry
    [Arguments]     ${retry_times}=3

    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart
        KW.StartLogCollection
        ${isCellOnair}     Run Keyword And Continue On Failure    KW.LoopForCellLockAndUnlock    loop=${i+1}
        ${alarm_result}    KW.GetAndCheckAlarm
        KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${isCellOnair}
        ...   alarm_result=${alarm_result}
    END

KW.LoopForCellLockAndUnlock
    [Arguments]    ${loop}
    wait until keyword succeeds   10x   1min    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell    action=lock
    sleep    60s
    COAM_WEBEM.LockUnlcokCell    action=unlock
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    run keyword and ignore error    COAM_WebEM.Logout

KW.OAMKPICaseStart
    [Arguments]    ${KPIsList}    ${retry_times}=1
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
    ims_keywords.check_instance_connection   gnbbbu
    oam_kpi_calculations.clear_results

KW.OAMKPILoopEnd
    [Arguments]    ${loop}    ${isCellOnair}    ${alarm_result}

    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    ${kpiValue}  KW.Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    ims_keywords.instance_disconnect    gnbbbu

    KW.SendResultToToolCenter    isCellOnair=${isCellOnair}    loop=${loop+1}
    ...                          isUnexpectedAlarm=${alarm_status}    kpiValue=${kpiValue}


#    KW.SendResultToToolCenter    isCellOnair=${isCellOnair}
#    ...        isUnexpectedAlarm=${alarm_result}    loop=${loop}+1
#    ...        kpiValue=${kpiValue}

    ${kpiName}    set variable    ${kpi_list[0].replace('kpi', 'KPI')}
    KW.CaseStatusCaluate    duration=${kpiValue}    max=${CASE_INPUT_5GC002479['5GC002479_HA_${kpiName}']['${kpiName}_MAX']}
    log to console     Case loop ${loop+1} END
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
    ...    Please check unexpect Alarm



KW.OAMKPICaseEnd
    [Arguments]    ${times}
    Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    Run Keyword and Ignore Error   ute_reporting_portal.Set reference configuration ID  ref_configuration_id=${REFERENCE_CONFIGURATION_ID}
    Run Keyword and Ignore Error   report_oam_kpi.Report Oam Kpi   oam_kpi_results=${kpi_results}    oam_kpi_targets=${OAM_KPI_TARGETS}

    FOR  ${kpi}  IN  @{kpi_list}
        Run Keyword and Ignore Error   report_oam_kpi.Report OAM KPI Success Rate    kpi_name=${kpi}
        ...    passed_iterations=${CaseAVGLoop}    executed_iterations=${CaseMaxTime}
        ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['${kpi}']}

        ${kpi}    set variable    ${kpi.replace('kpi', 'KPI')}
        Run Keyword If  ${kpi_avg} > ${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_MAX']}   Fail
        ...   ${kpi} average is above Target ${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_MAX']}
        KW.CaseStatusFinnal    case_avg=${CASE_INPUT_5GC002479['5GC002479_HA_${kpi}']['${kpi}_AVG']}    max_loop=${times}
    END

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

KW.SendResultToToolCenter
    [Arguments]    ${kpiValue}    ${isCellOnair}    ${isUnexpectedAlarm}    ${loop}

    ${loopStatus}    set variable if    "${isCellOnair}"=="True"  AND  ${kpiValue}<1800  AND  "${isUnexpectedAlarm}"=="True"    pass    fail
#    ...      AND  "${isUnexpectedAlarm}"=="True"    pass    fail

    Run Keyword And Ignore error    Get common info
    ...    case_result=${loopStatus}    case_name=${kpi_list[0]}   loop_number=${loop}  duration_time=${kpiValue}
