*** Settings ***
Documentation      author: Lixia Wang
...                contact: n5liu@nokia-sbell.com
...                History: Do some adaption for CB006443 by LiuNing
...                This robot file is for 5GC002479 C&P,inculding -AA,BA,CA,DA,FA subfeatures.

Resource          ./CB006443_KW1_5GR22.robot
Resource          ./CB006443_KW2_5GR22.robot
Resource          ./CB006443_KW_interface.robot
Resource          ./CB006443_Call_Common_Keyword.robot
Variables          ./OAMKPI_Target_CB008962.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


######## KeyWords for CB006443 #######
*** Keywords ***

TC.OAM_KPI_16_Cell_lock_Unlock
    [Documentation]  This is for KPI16a and KPI16b
    [Arguments]    ${KPI16a}=${KPI_8962['KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI_8962['KPI16']['KPI16b']}
    ...    ${repeat_times}=${KPI_8962['KPI16']['test_loops']}
    ...    ${Check_Call}=${False}    ${call_loop}=${2}
    ...    ${UE_TYPE}=samsung    ${ue_index}=${0}    ${NR_cell_id}=${15024129}    ${throuthput_ul}=120M
    ...    ${throuthput_dl}=600M       ${exepected_ul_tp}=${95}    ${exepected_dl_tp}=${450}
    ...    ${duration_ul}=300    ${duration_dl}=300

	&{kpi_results}=    Create Dictionary    kpi16a=@{EMPTY}    kpi16b=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_16a  KPI_16b
    Set Test Variable  ${target_kpis}
    ${connection}    Connect to DU by ADMIN API
    DU_WebEM.Get NR Cell distname and id
    KW.lock cell and unlock cell one by one
    ...    cell_id_list=${cell_id_list}    connection=${connection}
    ...	   KPI16a=${KPI16a}    KPI16b=${KPI16b}
    ${cellid}    evaluate    random.choice(${cell_id_list})    random
    log to console      ${cellid}
    FOR    ${i}    IN RANGE    ${repeat_times}
        Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   KW.lock cell and unlock cell
        ...    cell_id=${cellid}     connection=${connection}
        ...    loop=${i+1}    KPI16a=${KPI16a}    KPI16b=${KPI16b}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
        ${remainder}    Evaluate    (${i}+1)%${call_loop}
        Run Keyword If    '${case_status}'=='${True}' and '${Check_Call}'=='${True}' and '${remainder}'=='${0}'
        ...    RUN KEYWORD AND CONTINUE ON FAILURE    Verify UE send full UDP UL data and full UDP DL data
        ...    UE_TYPE=${UE_TYPE}     ue_index=${ue_index}     NR_cell_id=${NR_cell_id}     throuthput_ul=${throuthput_ul}
        ...    throuthput_dl=${throuthput_dl}    exepected_ul_tp=${exepected_ul_tp}
        ...    exepected_dl_tp=${exepected_dl_tp}    duration_ul=${duration_ul}    duration_dl=${duration_dl}
    END
    [Teardown]    Run Keywords      run keyword and ignore error  TC.teardown
			   ...    AND    run keyword and ignore error     Report KPI    kpi16a
			   ...    AND    run keyword and ignore error     Report KPI    kpi16b


KW.lock cell and unlock cell
    [Documentation]  This KW is for locking one cell and unlocking one cell by cell distname
    [Arguments]    ${cell_id}    ${connection}
    ...    ${KPI16a}=${KPI_8962['KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI_8962['KPI16']['KPI16b']}
	ims_keywords.check_instance_connection    gnbbbu
    oam_kpi_calculations.clear_results
    log to console    lock cell start
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
    ${referrence_time}      convert date    ${timestamp_log}    epoch

    wait until keyword succeeds   1min   2s    DU_Rest.lock
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}

    ${lock_cell_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min    3s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}
    ...    timeout=30   operational_State=Disabled    procedural_Status=initialization required
    ...    blockingState=Unblocked     administrative_State=Locked

   log to console    unlock cell start

    Run Keyword and Continue on Failure
    ...    wait until keyword succeeds   15s   5s    DU_Rest.unlock
    ...    dist_name=${cell_id['configuration']}    timeout=60    connection=${connection}
    ${unlock_cell_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min    3s    DU_WebEM.Check NR Cell status
    ...    cell_internal_id=${cell_id['internal']}    timeout=30   operational_State=Enabled
    ...    procedural_Status=configured
    ...    blockingState=Unblocked    administrative_State=Unlocked

    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms
    ...    loop=${timestamp_log}    ALLOWED_ALARMS=${ALLOWED_ALARMS}    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status_kpi}  Run Keyword And Continue On Failure    Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}
    ${status}  Evaluate  ${status_kpi} or ${alarm_status} or ${history_alarm_status}
    ${cell_status}  Evaluate  ${lock_cell_status} or ${unlock_cell_status}
    #${duration_time_tmp}    Set Variable    ${kpi_avg}
	${lock_duration}    Run Keyword And Continue On Failure
	...    oam_kpi_calculations.get_average_results    kpi_name=${kpi_list}[0]
	${unlock_duration}    Run Keyword And Continue On Failure
	...    oam_kpi_calculations.get_average_results    kpi_name=${kpi_list}[1]


    ${test_status}	   Set Variable If
    ...    "${cell_status}"=="True" and "${status}"=="False" and ${1}<${lock_duration}<${KPI16a} and ${0}<${unlock_duration}<${KPI16b}
    ...    pass      fail
     ${snapshot_file}    Run Keyword If    '${test_status}'=='fail'
     ...    Run keywords   sleep    60s
    ...    AND    Run Keyword And Ignore error    WEBUI.Collect snapshot
     ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop
     Run Keyword If    '${test_status}'=='pass'    Run Keyword And Ignore Error
     ...    Run keywords      Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
     ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${timestamp_log}_ims2/

     Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
     Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
     RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${test_status}    pass
     RUN KEYWORD AND CONTINUE ON FAILURE     log to console    KPI16 is ${test_status}
     RUN KEYWORD AND CONTINUE ON FAILURE     log to console    KPI16 avg is ${lock_duration} and ${unlock_duration}
    [Teardown]     run keyword and ignore error     ims_keywords.instance_disconnect  gnbbbu
    #[Teardown]    run keyword and ignore error     DU_WebEM.TearDown.unlock one cell
    #...    cell=${cell_id}     connection=${connection}

KW.lock cell and unlock cell one by one
    [Documentation]  This KW is for locking cell and unlocking cell one by one
    [Arguments]    ${cell_id_list}    ${connection}
    ...    ${KPI16a}=${KPI_8962['KPI16']['KPI16a']}
    ...    ${KPI16b}=${KPI_8962['KPI16']['KPI16b']}
    FOR    ${cell}    IN    @{cell_id_list}
        ${case_status}    RUN KEYWORD AND RETURN STATUS
        ...    RUN KEYWORD AND CONTINUE ON FAILURE   KW.lock cell and unlock cell
        ...    cell_id=${cell}     connection=${connection}
        ...    KPI16a=${KPI16a}    KPI16b=${KPI16b}
        RUN KEYWORD AND CONTINUE ON FAILURE    should be equal    ${case_status}    ${True}    ignore_case=true
    END


KW.KPI12_modify_parameter_with_site_reset
    [Documentation]  This KW is for KPI12
    [Arguments]        ${loop}=0     ${connection_AdminApi}=${connection}
    ...   ${KPI12_AVG}=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
    ...    ${min_duration}=3       ${max_duration}=18
    ...    ${Snapshot}=${False}
    ...    ${KPI12_MAX}=9999
    ${KPI12_MAX_not_used}       Set Variable        ${KPI12_MAX}
    oam_kpi_calculations.clear_results
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    ims_keywords.check_instance_connection    gnbbbu
	Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
	log to console    start modify parameter to test KPI12

    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
    ####start_operation######
	 ${out_parameters_list}     taf.sbts.oam.coam.admin.get_managed_objects
        ...    class_name=FEATCADM_A    connection=${connection_AdminApi}
    ${out_parameter}    Get From Dictionary    ${out_parameters_list[0]}    parameters
    ${parameter_value}    Get From Dictionary    ${out_parameter}     actTimeErrorManagement
    ${expected_value}	   Set Variable If	  "${parameter_value}"=="${False}" 	    ${true}      ${false}
    Run Keyword If    '${Snapshot}'=='${True}'
    ...    Run Keyword And Ignore error    KW.Collect_snapshot_for_in_parallel
    ...    min_duration=${min_duration}        max_duration=${max_duration}
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.perform_parameter_recommissioning
    ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
	 ...    parameter=actTimeErrorManagement   operation=update    value=${expected_value}
     ...   connection=${connection_AdminApi}   skip_parameter_relation_errors=True    timeout=900
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    ${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...    "${reset_status_Tmp}"=="True" and "${status}"=="False" and ${30}<${duration_time_tmp}<${KPI12_AVG}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'     Run Keywords
    ...     sleep    45s
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
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
    Run Keyword And Ignore error     log to console    this loop${loop} is ${reset_status} and KPI12 is ${duration_time_tmp}

    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API    connection_AdminApi=COAM1

KW.KPI12_modify_parameter_with_site_reset_loop
    [Arguments]      ${case_name}     ${retry_times}=${KPI_8962['KPI12']['CNF_5G_18']['test_loops']}
    ...   ${KPI12_MAX}=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
    ...   ${KPI12_AVG}=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
    ...   ${fail_loops}=${KPI_8962['KPI12']['CNF_5G_18']['fail_loops']}
    ...    ${min_duration}=3       ${max_duration}=18
    ...    ${Snapshot}=${False}
    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE    KW.KPI12_modify_parameter_with_site_reset  loop=${i+1}
        ...     KPI12_MAX=${KPI12_MAX}    KPI12_AVG=${KPI12_AVG}
        ...     min_duration=${min_duration}        max_duration=${max_duration}    Snapshot=${Snapshot}
        ${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI12_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}

        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loops}
        #${random_num}=    Evaluate    random.randint(5, 12)    random
        #log to console    wait ${random_num} mins and go to the next loop
        #sleep    ${random_num}m
    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi12']}
    Run Keyword If  ${kpi_avg} > ${KPI12_MAX}   Fail
    ...   KPI12 average is above Target ${KPI12_MAX}
    KW.CaseStatusFinnal    case_avg=${KPI12_AVG}   max_loop=${retry_times}

TC.OAM_KPI_12_Commission_with_Site_Reset
    [Arguments]   ${WebUI_reset_times}=${KPI_8962['KPI12']['CNF_5G_18']['test_loops']}
    ...   ${fail_loops}=${KPI_8962['KPI12']['CNF_5G_18']['fail_loops']}
    ...   ${KPI12_MAX}=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_MAX']}
    ...   ${KPI12_AVG}=${KPI_8962['KPI12']['CNF_5G_18']['KPI12_AVG']}
    ...   ${Snapshot}=${False}
    ...   ${min_duration}=3       ${max_duration}=18
	&{kpi_results}=    Create Dictionary    kpi12=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_12
    Set Test Variable  ${target_kpis}
    KW.KPI12_modify_parameter_with_site_reset_loop   case_name=OAM_KPI_12_Commission_with_Site_Reset   retry_times=${WebUI_reset_times}
    ...   KPI12_MAX=${KPI12_MAX}    KPI12_AVG=${KPI12_AVG}    min_duration=${min_duration}        max_duration=${max_duration}
    ...   fail_loops=${fail_loops}     Snapshot=${Snapshot}
    [Teardown]     Run Keyword And Ignore error      Report KPI    kpi12

KW.KPI13_rollback
    [Documentation]  This KW is for KPI13
    [Arguments]        ${KPI13_Target}
    &{kpi_results}=    Create Dictionary    kpi13=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_13
    Set Test Variable  ${target_kpis}
    oam_kpi_calculations.clear_results
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    ims_keywords.check_instance_connection    gnbbbu
    Check all cells Should Be On Air
	Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    ####start_operation######
    ${connection_AdminApi}    wait until keyword succeeds   5x   1min    Connect to DU by ADMIN API
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.rollback_software
    ...   connection=${connection_AdminApi}    timeout=600
    Log To Console   Software Rollback Finished, Waiting For Resetting...
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait until keyword succeeds    10min    10s    CB006443_Resouce.gNB.CheckgNBReset
    ${reset_status_Tmp}          Run Keyword And Return Status     Check all cells Should Be On Air
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${timestamp_log}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${timestamp_log}_ims2/
    ${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${timestamp_log}
    ${status}  Evaluate  ${alarm_status} or ${history_alarm_status}
    ${duration_time_tmp}    Set Variable   ${kpi_avg}
    ${reset_status}	   Set Variable If
    ...    "${reset_status_Tmp}"=="True" and "${status}"=="False" and ${30}<${duration_time_tmp}<${KPI13_Target}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'     Run Keywords
    ...     sleep    45s
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${timestamp_log}
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/${timestamp_log}_ims2/
    #Run Keyword If    '${reset_status}'=='pass'
    #...    Run Keyword And Ignore Error    KW.cancel_Collect_snapshot_for_in_parallel
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    Test is ${reset_status} and KPI13 is ${duration_time_tmp}
    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API


KW.KPI2_Prepare_SW_Update
    [Arguments]     ${SW1_name}
    run keyword if    ${SW1_name.count('${TargetStream}')}>0    Set Suite Variable    ${gSCF}    ${CurrentStreamSCF}
    ...    ELSE       Set Suite Variable    ${gSCF}    ${OriginalStreamSCF}
    Run Keyword And Ignore Error    log to console      SCF is ${gSCF}
    ${connection_AdminApi}    Wait until keyword succeeds   6x   1min    Connect to DU by ADMIN API
    ${Current_SW_name}    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.get_sw_version
    ...   connection=${connection_AdminApi}    timeout=120
    Run Keyword And Ignore Error     Log to console    Current SW name is ${Current_SW_name}

    ${SW1_path}        Run Keyword If    '${Current_SW_name}'!='${SW1_name}'
    ...    SoftwareUpdate.Download_gNB_Package    build_version=${SW1_name}
    Run Keyword And Ignore Error    Log to console    SW Path is ${SW1_path}
    ${SW_Update_Status}    Run Keyword If    '${Current_SW_name}'!='${SW1_name}'      taf.sbts.oam.coam.admin.update_software
    ...     sw_package=${SW1_path}     timeout=1800    connection=${connection_AdminApi}
    Run Keyword And Ignore Error    Log to console    ${SW_Update_Status}
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Should Contain     ${SW_Update_Status}    Software update has been completed
    Log To Console   Software Update Finished, Waiting For Resetting...
    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    Wait until keyword succeeds    8min    10s    CB006443_Resouce.gNB.CheckgNBReset
    Run keyword and ignore error     DisConnect to DU by ADMIN API
    Log to console    Check do commission or not
    ${connection_AdminApi}    wait until keyword succeeds    12min    10s    Connect to DU by ADMIN API
    ${gnb_status}   Run Keyword and Continue on Failure      KW.SWM.GetGNBStatus   connection=${connection_AdminApi}
    Run Keyword If   '${gnb_status}'=='NotCommissioned'    wait until keyword succeeds    8min    10s
    ...    gNB.Commission   scf_file=${gSCF}
    Run keyword and ignore error     DisConnect to DU by ADMIN API
    wait until keyword succeeds    12min    10s    Check all cells Should Be On Air
    Log to console    Sync SW to passive
    ${connection_AdminApi}    Run Keyword and Continue on Failure      Connect to DU by ADMIN API
    ${Sync_status}    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.passive_synchronize
    ...   connection=${connection_AdminApi}    timeout=600
    Run Keyword And Ignore Error    Log to console    Sync status is ${Sync_status}
    Run Keyword and Continue on Failure     Should Contain      ${Sync_status}     Succeed
   [Teardown]      run keyword and ignore error     DisConnect to DU by ADMIN API

KW.KPI11_remote_power_reset
    [Documentation]  This KW is for KPI11
    [Arguments]        ${loop}=0     ${connection_AdminApi}=${connection}
    ...   ${KPI11_AVG}=${KPI_8962['KPI11']['CNF_5G_18']['KPI11_MAX']}
    ...   ${KPI11_MAX}=9999
    ${KPI11_MAX_not_used}      set Variable       ${KPI11_MAX}
    oam_kpi_calculations.clear_results
    &{kpi_results}=    Create Dictionary    kpi11=@{EMPTY}
    Set Suite Variable    ${kpi_results}
    ${kpi_list}=    Get Dictionary Keys    ${kpi_results}
    Set Test Variable    ${kpi_list}
    ${ext_json_name}=   Evaluate  "_".join(${kpi_list})
    Set Test Variable  ${ext_json_name}
    ${target_kpis}  Create List  KPI_11
    Set Test Variable  ${target_kpis}
    ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${0}
    ${timestamp_log}    DateTime.Get Current Date    result_format=%Y%m%d_%H%M%S
	${referrence_time}      convert date    ${timestamp_log}    epoch
    ims_keywords.check_instance_connection    gnbbbu
	Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
	log to console    start to test KPI11_remote_power_reset
    wait until keyword succeeds   10x   1min    Connect to DU by ADMIN API
    ####start_operation######
    Run Keyword and Continue on Failure    taf.sbts.oam.coam.admin.power_reset
	...   reset_with_snapshot=${true}
    ...   connection=${connection_AdminApi}
    Run Keyword and Continue on Failure      Check all cells Should Be On Air
    ${alarm_status}  Run Keyword and Continue on Failure   Collect Active Alarms    loop=${loop}_${timestamp_log}
    ${history_alarm_status}  Run Keyword and Continue on Failure   Collect new history Alarms    loop=${loop}_${timestamp_log}
    ...    referrence_time=${referrence_time}
    Run Keyword And Continue On Failure    Collect IMS File  ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    ${status}  Run Keyword and Continue on Failure     Analyse IMS File   kpi_list=${kpi_list}    loop=${loop}_${timestamp_log}
    ${alarm_check}  Run Keyword and Continue on Failure     Evaluate  ${alarm_status} or ${history_alarm_status}
    ${duration_time_tmp}    Run Keyword and Continue on Failure     Set Variable   ${kpi_avg}
    ${reset_status}	   Run Keyword and Continue on Failure     Set Variable If
    ...    "${status}"=="False" and "${alarm_check}"=="False" and ${30}<${duration_time_tmp}<${KPI11_AVG}
    ...     pass      fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${reset_status}    pass
    ${snapshot_file}    Run Keyword If    '${reset_status}'=='fail'     Run Keywords
    ...     sleep    45s
    ...    AND    Run Keyword And Ignore error     wait until keyword succeeds   30x   2min    WEBUI.Collect snapshot
    ${BTS_syslog}    Run Keyword And Ignore error    Stop BTSlogs Collection and get logs for every loop    loop=${loop}
    Run Keyword And Ignore Error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${BTS_zip_path}
    ...      check_diff=True      Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=3
    ...      Clear_log=True     Max_used_space_ratio=0.8
    Run Keyword If    '${reset_status}'=='pass'     Run Keyword And Ignore Error
    ...    Run keywords     Run    sudo rm -f ${LOG_PATH}/'${BTS_syslog[1]}'
    ...    AND    Run    sudo rm -rf ${LOG_PATH}/loop${loop}_${timestamp_log}_ims2/
    Run Keyword And Ignore Error    Run    sudo rm -f /tmp/*_SYSLOG_*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/tmp*
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/btslog2/*
    Run Keyword And Ignore Error    Run    sudo rm -rf ${snapshot_in_parallel}
    Run Keyword And Ignore Error    Run    sudo rm -rf /tmp/*.zip
    Run Keyword And Ignore error     log to console    this loop${loop} is ${reset_status} and KPI11 is ${duration_time_tmp}

    [Return]    ${reset_status}   ${duration_time_tmp}
    [Teardown]    run keywords     Run Keyword And Ignore error    ims_keywords.instance_disconnect  gnbbbu
    ...    AND    run keyword and ignore error     DisConnect to DU by ADMIN API

KW.KPI11_remote_power_reset_loop
    [Arguments]      ${case_name}    ${Fault_exit_loop}=${None}
    ...    ${retry_times}=${KPI_8962['KPI11']['CNF_5G_18']['test_loops']}
    ...   ${KPI11_MAX}=${KPI_8962['KPI11']['CNF_5G_18']['KPI11_MAX']}
    ...   ${KPI11_AVG}=${KPI_8962['KPI11']['CNF_5G_18']['KPI11_MAX']}
    ...   ${fail_loops}=${KPI_8962['KPI11']['CNF_5G_18']['fail_loops']}

    KW.CaseStatusInit    retry_times=${retry_times}
    @{result_list}    create list
    FOR    ${i}    IN RANGE    ${retry_times}
        ${res}    RUN KEYWORD AND CONTINUE ON FAILURE    KW.KPI11_remote_power_reset  loop=${i+1}
        ...     KPI11_MAX=${KPI11_MAX}    KPI11_AVG=${KPI11_AVG}
        ${reset_status}         set variable if    '${res[0]}'=='fail'      fail    ${res[0]}
        ${duration_time_tmp}    set variable if    '${res[0]}'=='fail'      1800    ${res[1]}
        KW.CaseStatusCaluate    duration=${duration_time_tmp}    max=${KPI11_MAX}
        log to console     Case loop ${i+1} END
        Run Keyword And Ignore error     Get common info     case_result=${reset_status}
        ...    case_name=${case_name}   loop_number=${i+1}  duration_time=${duration_time_tmp}

        Append To List    ${result_list}    ${reset_status}
        ${fail_num}    Count Values In List    ${result_list}     fail
        Exit for loop if    ${fail_num}>=${fail_loops}
        ${check_exit}    Run keyword if     '${Fault_exit_loop}'!='${None}'
        ...    RUN KEYWORD AND RETURN STATUS
        ...    List Should Not Contain Value    ${active_alarms_list}    ${Fault_exit_loop}
        ...    msg=check if exit loop because some fault is raised
        Exit for loop if      '${check_exit}'=='${False}'
        ${random_num}=    Evaluate    random.randint(5, 20)    random
        Run Keyword And Ignore error     log to console    wait ${random_num}s and go to the next loop
        Run Keyword And Ignore error     sleep    ${random_num}s

    END
	Run Keyword and Continue on Failure   ims_keywords.save_results  ${kpi_results}  ${LOG_PATH}/results_all_${ext_json_name}.json
    ${kpi_avg}  ims_keywords.calculate_kpi_average  ${kpi_results['kpi11']}
    Run Keyword If  ${kpi_avg} > ${KPI11_MAX}   Fail
    ...   KPI11 average is above Target ${KPI11_MAX}
    KW.CaseStatusFinnal    case_avg=${KPI11_AVG}   max_loop=${retry_times}

TC.KPI11_remote_power_reset
    [Arguments]   ${Fault_exit_loop}=${None}     ${WebUI_reset_times}=${KPI_8962['KPI11']['CNF_5G_18']['test_loops']}
    ...   ${KPI11_MAX}=${KPI_8962['KPI11']['CNF_5G_18']['KPI11_MAX']}
    ...   ${KPI11_AVG}=${KPI_8962['KPI11']['CNF_5G_18']['KPI11_MAX']}
    ...    ${fail_loops}=9999       ${KPI11_MAX}=9999
    ${KPI11_MAX_not_used}      set Variable       ${KPI11_MAX}
    ${fail_loops_not_used}      set Variable       ${fail_loops}
    KW.KPI11_remote_power_reset_loop   case_name=KPI11_remote_power_reset_loop  retry_times=${WebUI_reset_times}
    ...   KPI11_MAX=${KPI11_MAX}    KPI11_AVG=${KPI11_AVG}    Fault_exit_loop=${Fault_exit_loop}
    [Teardown]     Run Keyword And Ignore error      Report KPI    kpi11


KW.get_all_unit_status_from_sbts
    ${connection_AdminApi}    Wait until keyword succeeds   6x   1min    Connect to DU by ADMIN API
    &{sbts_hw_dict}      Wait until keyword succeeds   6x   5s
    ...      taf.sbts.oam.coam.admin.get_detected_hw_info
    ...      timeout=60      connection=${connection_AdminApi}
    [Return]     ${sbts_hw_dict}
    [Teardown]      run keyword and ignore error     DisConnect to DU by ADMIN API

KW.check_rmod_status
    [Arguments]     ${sbts_hw_dict}
    ...     ${operationalState}=enabled        ${proceduralStatus}=configured
    ...     ${administrativeState}=Unlocked
    @{rmod_info_list}       Run Keyword and Continue on Failure
    ...      set Variable     ${sbts_hw_dict['radioModules']['rmod']}
    FOR    ${rmod_info}     IN      @{rmod_info_list}
    ${rmod_id}      set Variable     ${rmod_info['id']['configuration']}
    ${rmod_name}      set Variable     ${rmod_info['productName']}
    ${rmod_sn}      set Variable     ${rmod_info['serialNumber']}
    ${rmod_operationalState}      Run Keyword and Continue on Failure
    ...      set Variable     ${rmod_info['status']['operationalState']}
    ${rmod_proceduralStatus}      Run Keyword and Continue on Failure
    ...      set Variable     ${rmod_info['status']['proceduralStatus']}
    ${rmod_administrativeState}         Run Keyword and Continue on Failure
    ...      set Variable     ${rmod_info['status']['administrativeState']}
    run keyword and ignore error      log to console
    ...      check ${rmod_name}_${rmod_sn}:${rmod_id}:${rmod_operationalState}
    Run Keyword and Continue on Failure
    ...     Should be equal    ${rmod_operationalState}
    ...    ${operationalState}    ignore_case=true
    Run Keyword and Continue on Failure
    ...     Should be equal    ${rmod_proceduralStatus}
    ...    ${proceduralStatus}    ignore_case=true
    Run Keyword and Continue on Failure
    ...     Should be equal    ${rmod_administrativeState}
        ...    ${administrativeState}    ignore_case=true
    END

KW.check_bbmod_status
    [Arguments]     ${sbts_hw_dict}
    ...     ${operationalState}=enabled        ${proceduralStatus}=configured
    ...     ${administrativeState}=Unlocked
    @{bbmod_info_list}       Run Keyword and Continue on Failure
    ...      set Variable     ${sbts_hw_dict['basebandModules']}
    FOR    ${bbmod_info}     IN      @{bbmod_info_list}
    ${bbmod_id}      set Variable     ${bbmod_info['id']['configuration']}
    ${bbmod_name}      set Variable     ${bbmod_info['productName']}
    ${bbmod_sn}      set Variable     ${bbmod_info['serialNumber']}
    ${bbmod_operationalState}      Run Keyword and Continue on Failure
    ...      set Variable     ${bbmod_info['status']['operationalState']}
    ${bbmod_proceduralStatus}      Run Keyword and Continue on Failure
    ...      set Variable     ${bbmod_info['status']['proceduralStatus']}
    ${bbmod_administrativeState}         Run Keyword and Continue on Failure
    ...      set Variable     ${bbmod_info['status']['administrativeState']}
    run keyword and ignore error      log to console    check ${bbmod_name}_${bbmod_sn}:${bbmod_id}
    Run Keyword and Continue on Failure
    ...     Should be equal    ${bbmod_operationalState}
    ...    ${operationalState}    ignore_case=true
    Run Keyword and Continue on Failure
    ...     Should be equal    ${bbmod_proceduralStatus}
    ...    ${proceduralStatus}    ignore_case=true
    Run Keyword and Continue on Failure
    ...     Should be equal    ${bbmod_administrativeState}
        ...    ${administrativeState}    ignore_case=true
    END

KW.get_and_check_rmod_status
    ${sbts_hw_dict}      Run Keyword and Continue on Failure
    ...      KW.get_all_unit_status_from_sbts
    Run Keyword and Continue on Failure
    ...      KW.check_rmod_status    sbts_hw_dict=${sbts_hw_dict}

KW.get_and_check_rmod_status_loop
    [Arguments]     ${timeout}=100s
    wait until keyword succeeds     ${timeout}    10s
    ...      KW.get_and_check_rmod_status


KW.get_and_check_rmod_and_bbmod_status
    ${sbts_hw_dict}      Run Keyword and Continue on Failure
    ...      KW.get_all_unit_status_from_sbts
    Run Keyword and Continue on Failure
    ...      KW.check_rmod_status    sbts_hw_dict=${sbts_hw_dict}
    Run Keyword and Continue on Failure
    ...      KW.check_bbmod_status     sbts_hw_dict=${sbts_hw_dict}
