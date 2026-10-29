*** Settings ***
Documentation      author: Lixia Wang
...                contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                This robot file is for 5GC002479 C&P,inculding -AA,BA,CA,DA,FA subfeatures.

Resource          ./CB006443_KW1_5GR22.robot
Resource          ./CB006443_KW2_5GR22.robot
Resource          ./CB006443_KW_interface.robot
Resource          ./OAM_KPI_KW1.robot
Variables          ./OAMKPI_Target_CB008962.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***

######## KeyWords for CB006443 #######
*** Keywords ***


KW.modify_parameter_with_5G_RAT_reset
    [Documentation]  modify_parameter_with_5G_RAT_reset
    [Arguments]        ${loop}=0    ${KPI12_MAX}=${468}     ${KPI12_AVG}=${390}     ${connection_AdminApi}=${connection}
    ...   ${min_duration}=3       ${max_duration}=18
    oam_kpi_calculations.clear_results
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    ims_keywords.check_instance_connection    gnbbbu
	Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
	log to console    start reset RAT triggrred by modify parameter

    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
    log to console    login OK ${NRBTS_ID}
    ####start_operation######
	 ${out_parameters_list}     taf.sbts.oam.coam.admin.get_managed_objects
        ...    class_name=NRBTS_A    connection=${connection_AdminApi}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
    ${parameter_value}    Get From Dictionary    ${out_parameter}     trsBurstSize
    ${expected_value}	   Set Variable If	  "${parameter_value}"=="b6440000" 	  b8400000    b6440000
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ...    min_duration=${min_duration}        max_duration=${max_duration}
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    dist_name=${MRBTS_ID}/${NRBTS_ID}
	...    parameter=trsBurstSize   operation=update    value=${expected_value}
    ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=False    timeout=900
    Timer.Start
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    sleep    1s
    #Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    #${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}
    #${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...    "${reset_status_Tmp}"=="True" and "${status}"=="False" and ${30}<${duration_1}<${KPI12_MAX}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'     Run Keywords
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    ...    sleep     45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    #Run Keyword If    '${reset_status}'=='pass'
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    log to console    this loop${loop} modify parameter is ${reset_status} and KPI is ${duration_1}

    [Return]    ${reset_status}   ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

KW.modify_parameter_with_5G_RAT_reset_loop
    [Arguments]      ${case_name}     ${retry_times}=2     ${KPI12_MAX}=${468}     ${KPI12_AVG}=${390}
    ...     ${min_duration}=3       ${max_duration}=18
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE    KW.modify_parameter_with_5G_RAT_reset    loop=${i+1}
        ...     KPI12_MAX=${KPI12_MAX}    KPI12_AVG=${KPI12_AVG}
        ...     min_duration=${min_duration}        max_duration=${max_duration}
        ${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        #${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        #KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI12_MAX}
        log to console     Case loop ${i+1} END
        #Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        #...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}

        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=5
        #${random_num}=    Evaluate    random.randint(5, 12)    random
        #log to console    wait ${random_num} mins and go to the next loop
        #sleep    ${random_num}m
    END


TC.OAM_modify_parameter_with_5G_RAT_reset
    [Arguments]   ${WebUI_reset_times}=${2}
    ...   ${KPI12_MAX}=${468}
    ...   ${KPI12_AVG}=${390}
    ...     ${min_duration}=3       ${max_duration}=18
    &{kpi_results}=    Create Dictionary    kpi10=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_10
    Set Test Variable  ${target_kpis}
    KW.modify_parameter_with_5G_RAT_reset_loop   case_name=OAM_modify_parameter_with_5G_RAT_reset   retry_times=${WebUI_reset_times}
    ...   KPI12_MAX=${KPI12_MAX}    KPI12_AVG=${KPI12_AVG}
    ...   min_duration=${min_duration}        max_duration=${max_duration}



#####RAT_RESET######
TC.OAM_KPI_HA_01_OAM_RAT_reset
    [Arguments]   ${WebUI_reset_times}=${10}
    ...   ${KPI10_MAX}=${468}
    ...   ${KPI10_AVG}=${390}
    ...    ${rat_type}=NR
    ...    ${reset_typ}=Hard
	&{kpi_results}=    Create Dictionary    kpi10=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_10
    Set Test Variable  ${target_kpis}
    KW.reset_RAT_loop   case_name=RAT_reset    retry_times=${WebUI_reset_times}
    ...     rat_type=${rat_type}     reset_typ=${reset_typ}

KW.reset_RAT_loop
    [Arguments]      ${case_name}  ${retry_times}=2   ${KPI10_MAX}=${468}
    ...   ${KPI10_AVG}=${390}
    ...    ${rat_type}=NR
    ...    ${reset_typ}=Hard
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    Start reset RAT loop${i}
        ims_keywords.check_instance_connection    gnbbbu
	    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE     KW.reset_RAT    loop=${i+1}
        ...     KPI10_MAX=${KPI10_MAX}    KPI10_MAX=${KPI10_MAX}
        ...     rat_type=${rat_type}     reset_typ=${reset_typ}
        ${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI10_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=10
        #${random_num}=    Evaluate    random.randint(5, 12)    random
        #log to console    wait ${random_num} mins and go to the next loop
        #sleep    ${random_num}m
    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi10']}
    Run Keyword If  ${kpi_avg} > ${KPI10_MAX}   Fail
    ...   KPI10 average is above Target ${KPI10_MAX}
    KW.CaseStatusFinnal    case_avg=${KPI10_AVG}   max_loop=${retry_times}

KW.reset_RAT
    [Arguments]    ${loop}=0
    ...    ${KPI10_MAX}=${468}
    ...    ${KPI10_AVG}=${390}
    ...    ${rat_type}=NR
    ...    ${reset_typ}=Hard
    oam_kpi_calculations.clear_results
    &{kpi_results}=    Create Dictionary    kpi10=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_10
    Set Test Variable  ${target_kpis}
    ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${0}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
	${reset_rat_status}     Run Keyword And Return Status     Run Keyword and Continue on Failure
	...    DU_Rest.rat_reset   rat_type=${rat_type}     reset_type=${reset_typ}
	...    timeout=900    connection=${connection}
	Run Keyword and Continue on Failure    Check all cells Should Be On Air
	#${reset_status}  Evaluate  ${reset_rat_status} or ${reset_status_Tmp}
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_ims2/
    Run Keyword and Continue on Failure    Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}
    ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${kpi_avg}
    ${status}  Run Keyword and Continue on Failure     Evaluate  ${alarm_status} or ${history_alarm_status}
    ${reset_status}	   Set Variable If
    ...    "${reset_rat_status}"=="True" and "${status}"=="False" and ${60}<${duration_time_tmp}<${KPI10_MAX}
    ...    pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    Run Keyword And Ignore error
    ...    log to console    The testing result of this loop${loop} reset rat is ${reset_status} and KPI is ${duration_time_tmp}
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'    Run keywords
    ...     sleep    45s
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}       Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword And Ignore Error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${BTS_zip_path}
    ...      check_diff=True      Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=3
    ...      Clear_log=True     Max_used_space_ratio=0.8
    Run Keyword If    '${reset_status}'=='pass'     Run keywords
    ...    Run Keyword And Ignore Error    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run Keyword And Ignore Error    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_ims2/
    #...    AND    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
    ...    AND    Run Keyword And Ignore Error     COAM_WebEM.Logout
#######RAT_RESET######
#######CB009395 TC end#############################





#######config_parameter_with_site_reset#######

TC.OAM_KPI_block_unblock_site
    [Arguments]   ${WebUI_reset_times}=${100}
    ...   ${KPI_MAX}=${510}
    ...   ${KPI_AVG}=${390}    ${min_duration}=3       ${max_duration}=18
	&{kpi_results}=    Create Dictionary    kpi10=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_10
    Set Test Variable  ${target_kpis}
    KW.block_unblock_site_loop   case_name=block_unblock_site    retry_times=${WebUI_reset_times}
    ...     min_duration=${min_duration}        max_duration=${max_duration}
    [Teardown]     Run Keyword And Ignore error     ims_keywords.instance_disconnect  gnbbbu

KW.block_unblock_site_loop
    [Arguments]      ${case_name}  ${retry_times}=3   ${KPI_MAX}=${468}
    ...   ${KPI_AVG}=${390}      ${min_duration}=3       ${max_duration}=18
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        log to console    Start block site loop${i}
        ims_keywords.check_instance_connection    gnbbbu
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE     KW.block_unblock_site    loop=${i+1}
        ...     KPI_MAX=${KPI_MAX}    min_duration=${min_duration}        max_duration=${max_duration}
        ${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        #KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI_MAX}
        log to console     Case block_unblock site loop ${i+1} END
        #Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        #...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}
        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=5
        #${random_num}=    Evaluate    random.randint(5, 12)    random
        #log to console    wait ${random_num} mins and go to the next loop
        #sleep    ${random_num}m
    END


KW.block_unblock_site
    [Arguments]    ${loop}=0
    ...    ${KPI_MAX}=${320}    ${min_duration}=3       ${max_duration}=18
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    RUN KEYWORD AND CONTINUE ON FAILURE     wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
	RUN KEYWORD AND CONTINUE ON FAILURE     DU_Rest.block     timeout=600    connection=${connection}
	Run Keyword And Ignore error     KW.Collect_snapshot_for_in_parallel_REMOTE
	...   min_duration=${min_duration}        max_duration=${max_duration}
    RUN KEYWORD AND CONTINUE ON FAILURE      DU_Rest.unblock     timeout=600    connection=${connection}
    Timer.Start
	${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
	${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    #${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}
    ${reset_status}	   Set Variable If
    ...    "${reset_status_Tmp}"=="True" and ${30}<${duration_1}<${KPI_MAX} and "${status}"=="False"
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND     Run Keyword And Ignore error     wait until keyword succeeds   20x   1min     WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword And Ignore Error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${BTS_zip_path}
    ...      check_diff=True      Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=3
    ...      Clear_log=True     Max_used_space_ratio=0.8
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    log to console    The testing result of this loop${loop} block_unblock_site is ${reset_status} and KPI is ${duration_1}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    #Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    run keyword and ignore error    DisConnect to DU by ADMIN API
    [Return]    ${reset_status}   ${duration_1}


KW.reset_all_cell
    [Arguments]    ${loop}=0
    ...    ${KPI5_MAX}=${200}
    oam_kpi_calculations.clear_results
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
	DU_Rest.reset_all_cells    technology=NR    timeout=600    connection=${connection}
    Timer.Start
	Run Keyword and Continue on Failure     Check all cells Should Be On Air
	${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    #Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    #${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}

    ${reset_status}	   Set Variable If
    ...    "${status}"=="False" and ${2}<${duration_1}<${KPI5_MAX}
    ...    pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    log to console    The testing result of this loop${loop} reset all cell is ${reset_status} and KPI is ${duration_1}
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}     Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore error       ims_keywords.instance_disconnect  gnbbbu
    run keyword and ignore error    DisConnect to DU by ADMIN API
    [Return]    ${reset_status}   ${duration_1}

TC.reset_all_cell_loop
    [Arguments]     ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
   	&{kpi_results}=    Create Dictionary    kpi19=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_19
    Set Test Variable  ${target_kpis}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
        ${reset_status}    RUN KEYWORD AND CONTINUE ON FAILURE   KW.reset_all_cell
        ...     KPI5_MAX=${KPI5_MAX}    loop=${i+1}
        Append To List    ${result_list}    ${reset_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END


##########End keyword for CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration#############
KW.reset_all_BBMOD
    [Documentation]  This is for test case CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Arguments]    ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${loop}=${1}     ${reset_type}=Warm
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    reset all BBMOD loop${loop}
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get BBMOD distname and id
    #Run Keyword And Ignore error     wait until keyword succeeds    8min   45s     COAM_WebEM.Login
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    FOR    ${BBMOD}    IN    @{BBMOD_id_list}
        ${random_num}=    Evaluate    random.randint(2, 6)    random
        Run Keyword And Ignore error
        ...    DU_Rest.reset_unit
        ...    dist_name=${BBMOD['internal']}    reset_type=${reset_type}
        ...    timeout=${random_num}   connection=${connection}
    END
    log to console    check all cell status start
    Run Keyword and Continue on Failure
    ...   Wait Until Keyword Succeeds    8min    3s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}     all_flag=False
    ...    operational_State=Disabled    procedural_Status=not initialized
    ...    blockingState=Unblocked    administrative_State=Unlocked
    log to console    check all cell status start
     Timer.Start
     Run Keyword and Continue on Failure
     ...   Wait Until Keyword Succeeds    30min    1s     DU_WebEM.Check all NR Cell status
     ...    cell_id_list=${cell_id_list}    all_flag=True
     ...    operational_State=Enabled    procedural_Status=configured
     ...    blockingState=Unblocked    administrative_State=Unlocked
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${loop}_${timestamp_log}    referrence_time=${referrence_time}
    ${reset_status}	   Set Variable If
        ...     ${10}<${duration_1}<${KPI5_MAX} and "${alarm_status}"=="False" and "${history_alarm_status}"=="False"
        ...     pass      fail
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'    Run keywords
    ...     sleep    45s
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword And Ignore Error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${BTS_zip_path}
    ...      check_diff=True      Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=3
    ...      Clear_log=True     Max_used_space_ratio=0.8
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
        ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    #Run Keyword If    '${reset_status}'=='pass'
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
    log to console    The testing result of this reset all BBMOD loop${loop} is ${reset_status} and KPI is ${duration_1}
    [Return]    ${reset_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1
    #...    AND    Run Keyword And Ignore Error     COAM_WebEM.Logout

TC.reset_all_BBMOD_loop
    [Arguments]     ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
    ...    ${reset_type}=Warm
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
        ${reset_status}    RUN KEYWORD AND CONTINUE ON FAILURE   KW.reset_all_BBMOD
        ...     KPI5_MAX=${KPI5_MAX}    loop=${i+1}    reset_type=${reset_type}
        Append To List    ${result_list}    ${reset_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END

KW.reset_all_RMOD
    [Documentation]  This is for test case CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Arguments]    ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${loop}=${1}     ${snapshot_flag}=True
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    reset all RMOD loop${loop}
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get RMOD ID
    #Run Keyword And Ignore error     wait until keyword succeeds    8min   45s     COAM_WebEM.Login
    Run Keyword If    '${snapshot_flag}'=='True'
    ...     Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    FOR    ${RMOD}    IN    @{RMOD_id_list}
        ${random_num}=    Evaluate    random.randint(5, 15)    random
        Run Keyword And Ignore error     DU_Rest.reset_unit
        ...    dist_name=${RMOD['internal']}    timeout= ${random_num}    connection=${connection}
    END
    log to console    check all cell status start
    Wait Until Keyword Succeeds    5min    3s     DU_WebEM.Check all NR Cell status
        ...    cell_id_list=${cell_id_list}     all_flag=False
        ...    operational_State=Disabled    procedural_Status=not initialized
        ...    blockingState=Unblocked    administrative_State=Unlocked
    log to console    check all cell status start
    Timer.Start
    Run Keyword and Continue on Failure
    ...    Wait Until Keyword Succeeds    15min    1s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${loop}_${timestamp_log}    referrence_time=${referrence_time}
    ${reset_status}	   Set Variable If
        ...     ${10}<${duration_1}<${KPI5_MAX} and "${alarm_status}"=="False" and "${history_alarm_status}"=="False"
        ...     pass      fail
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
        ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
    log to console    The testing result of this reset all RMOD loop${loop} is ${reset_status} and KPI is ${duration_1}
    [Return]    ${reset_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

TC.reset_all_RMOD_loop
    [Arguments]     ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
    ...    ${snapshot_flag}=True
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
        ${reset_status}    RUN KEYWORD AND CONTINUE ON FAILURE   KW.reset_all_RMOD
        ...     KPI5_MAX=${KPI5_MAX}    loop=${i+1}     snapshot_flag=${snapshot_flag}
        Append To List    ${result_list}    ${reset_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END


TC.power_reset_all_RMOD_loop
    [Documentation]   This is for all RU cold reset
    [Arguments]    ${KPI54A_MAX}=${CASE_INPUT_CB006443['CB006443_KPI54A']['KPI54A_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_KPI54A']['ru_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_KPI54A']['fail_loop_max']}
     ${Fault_ID} =    Set Variable   10
     ${Fault_ID1} =    Set Variable   4590
     ${Fault_ID2} =    Set Variable   1815
     Set suite variable     ${ALLOWED_ALARMS_KPI54a}      ${ALLOWED_ALARMS}
     Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID}
     Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID1}
     Append to list   ${ALLOWED_ALARMS_KPI54a}    ${Fault_ID2}
     @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
         ${case_status}    RUN KEYWORD AND CONTINUE ON FAILURE
         ...    KW.power_reset_all_RMOD    KPI54A_MAX=${KPI54A_MAX}
        Append To List    ${result_list}    ${case_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     False
        log to console    This cold reset RMOD loop${i} is ${case_status[0]} and kpi is ${case_status[1]}
        Exit for loop if    ${fail_num}>=${fail_loop_max}
    END
    [Teardown]    run keywords   run keyword and ignore error  DisConnect to DU by ADMIN API    AND     TC.teardown

KW.power_reset_all_RMOD
    [Arguments]    ${KPI54A_MAX}=${KPI54A_MAX}
     ims_keywords.check_instance_connection    gnbbbu
     Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
     ${connection}    Connect to DU by ADMIN API
     DU_WebEM.Get NR Cell distname and id
    ${length}=   Get Length     ${tl.gnbs[0].dus[0].rus}
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    FOR    ${i}    IN RANGE    ${length}
         RUN KEYWORD AND CONTINUE ON FAILURE
         ...    PB.PowerOnOff     pdu_ip=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
         ...    Port_Number=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
         ...    model=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
         ...    Action=both
    END
    Timer.Start
	log to console    check all cell status start
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait Until Keyword Succeeds    15min    3s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
     ${duration_1}     Timer.Stop
     ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
     ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
     ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS_KPI54a}    referrence_time=${referrence_time}
     ${test_status}	   Set Variable If
    ...    "${history_alarm_status}"=="False" and "${alarm_status}"=="False" and ${10}<${duration_1}<${KPI54A_MAX}
    ...    pass      fail
    ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
    ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
     Run Keyword If    '${test_status}'=='pass'     Run Keyword And Ignore Error
     ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
     RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
    [Return]    ${test_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1


KW.reset_all_BBMOD_and_reset_RAT
    [Documentation]  This is for test case CB006443_HA_06_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
    [Arguments]    ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${loop}=${0}
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console      all BBMOD and reset RAT loop${loop}
    ims_keywords.check_instance_connection    gnbbbu
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    DU_WebEM.Get BBMOD distname and id
    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    FOR    ${BBMOD}    IN    @{BBMOD_id_list}
        Run Keyword And Ignore error
        ...     DU_Rest.reset_unit
        ...    dist_name=${BBMOD['internal']}    reset_type=Warm   timeout=2    connection=${connection}
    END
    ${random_num}=    Evaluate    random.randint(155, 188)    random
    sleep    ${random_num}s
    ${reset_rat_status}     Run Keyword And Return Status     Run Keyword and Continue on Failure
    ...    DU_Rest.rat_reset   rat_type=NR    timeout=600    connection=${connection}
    log to console    check all cell status start
    Timer.Start
    Wait Until Keyword Succeeds    8min    1s     DU_WebEM.Check all NR Cell status
    ...    cell_id_list=${cell_id_list}    all_flag=True
    ...    operational_State=Enabled    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked
    ${duration_1}     Timer.Stop
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${loop}_${timestamp_log}    referrence_time=${referrence_time}
    ${alarm_raised}  Evaluate  ${alarm_status} or ${history_alarm_status}
    ${reset_status}	   Set Variable If
        ...     ${10}<${duration_1}<${KPI5_MAX} and "${alarm_raised}"=="False" and "${reset_rat_status}"=="True"
        ...     pass      fail
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'        Run keywords
    ...     sleep    45s
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
        ...    Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${reset_status}    pass    ignore_case=true
    log to console    The testing result of this reset all BBMOD and reset RAT loop${loop} is ${reset_status} and KPI is ${duration_1}
    [Return]    ${reset_status}    ${duration_1}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API

TC.reset_all_BBMOD_and_reset_RAT_loop
    [Arguments]     ${KPI5_MAX}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['KPI5_MAX']}
    ...    ${repeat_times}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['BBMOD_reset_times']}
    ...    ${fail_loop_max}=${CASE_INPUT_CB006443['CB006443_HA_KPI5']['fail_loop_max']}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${repeat_times}
        ${reset_status}    RUN KEYWORD AND CONTINUE ON FAILURE   KW.reset_all_BBMOD_and_reset_RAT
        ...     KPI5_MAX=${KPI5_MAX}    loop=${i+1}
        Append To List    ${result_list}    ${reset_status[0]}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loop_max}
        #${random_num}=    Evaluate    random.randint(5, 12)    random
        #log to console    wait ${random_num} mins and go to the next loop
        #sleep    ${random_num}m
    END


KW.Collect_snapshot_for_in_parallel
     [Arguments]       ${min_duration}=2       ${max_duration}=5
    #selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=${location}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${snapshot_file}    set variable    ${MRBTS_ID}_Snapshot_${timestamp_log}.zip
    ${random_num}=    Evaluate    random.randint(${min_duration}, ${max_duration})     random
    log to console    timeout is ${random_num}s
    Connect to DU by ADMIN API    connection_AdminApi=COAM1
    Run Keyword And Ignore Error   DU_Rest.collect_snapshot
    ...    target_file_name=/tmp/${snapshot_file}      timeout=${random_num}     connection=COAM1
    #${snapshot_name_o}    Fetch From Right    ${snapshot_file}    /
    #${snapshot_path}    Remove String    ${snapshot_file}    ${snapshot_name_o}
    #${snapshot_name}    Run Keyword And Ignore Error    Remove String    ${snapshot_name_o}     ${SPACE}
    #Run Keyword And Ignore Error    run
    #...    command=mv '${snapshot_file}' ${LOG_PATH}/
    ${snapshot_in_parallel}    set variable  /tmp/${snapshot_file}
    Set Suite Variable     ${snapshot_in_parallel}
    #[Teardown]       run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

KW.cancel_Collect_snapshot_for_in_parallel
    #Connect to DU by ADMIN API    connection_AdminApi=COAM1
    Run Keyword And Ignore Error    DU_Rest.snapshot_cancel     timeout=600   connection=COAM1

    #[Teardown]       run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

KW.Collect_snapshot_for_in_parallel_REMOTE
    [Arguments]       ${min_duration}=3       ${max_duration}=50
    #selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=${location}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    #${snapshot_file}    set variable    ${MRBTS_ID}_Snapshot_${timestamp_log}.zip
    ${random_num}=    Evaluate    random.randint(${min_duration}, ${max_duration})    random
    log to console    timeout is ${random_num}s
    Connect to DU by ADMIN API    connection_AdminApi=COAM1
    Run Keyword And Ignore Error   DU_Rest.get_remote_snapshot
    ...    timeout=${random_num}     connection=COAM1
    #Set Suite Variable     ${snapshot_in_parallel}
    #[Teardown]       run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

#KW.delete_snapshot_in_netact
#    taf.transport.ssh.connect     hostname=${host}    username=${username}    password=${password}    alias=netact
#    taf.transport.ssh.Execute   command=sudo rm -rf /d/oss/global/diagsnap/ne3sws/${MRBTS_ID}*   connection=netact
#    [Teardown]    taf.transport.ssh.disconnect      connection=netact
