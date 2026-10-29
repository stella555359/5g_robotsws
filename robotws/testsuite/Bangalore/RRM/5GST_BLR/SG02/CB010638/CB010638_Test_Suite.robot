*** Settings ***
Documentation    Author: Arunkumar A
...              Maintainer:  MN RAN Pz BLR 2 SG
...              CB010638-POWER SAVING AVOIDANCE DURING PRIORITY ACCESS CALLS.
...              Feature Requirements: 5G_RAN_USR_RRM_20339, 5G_RAN_USR_RRM_20340, 5G_RAN_USR_RRM_20341, 5G_RAN_USR_RRM_20342,
...    	         5G_PM_1090, 5G_PM_1091,	5G_PM_1092, 5G_PM_1093
Library   String
Library   Collections
Library   DateTime
Library   OperatingSystem
Library   Process
Library   Screenshot
Library   XML
Library   Telnet
Library   taf.sbts.oam.coam.admin    WITH NAME    admin
Library   taf.sw.dcap.rd    WITH NAME    rd
Library   taf.collectors.core   WITH NAME   core
Library   taf.collectors.btslog  WITH NAME   btslog
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library   testsuite.Bangalore.ORAN.resources.python.ta_ultracaller  WITH NAME  uc
Library   testsuite/Bangalore/ORAN/resources/python/SysValidation.py  WITH NAME  Validation
Library   taf.selenium.sbts    WITH NAME  Selenium_Sbts
Library   OperatingSystem
Library   DateTime
Resource   ./Common_Variables_5G.robot
Variables  ./powersavingalgorithmconfig.py


*** Variables ***

# CB010638
${NRPGRP_ID}=     ${1}
${TS_CASE_LOG_PATH}=    /home/ute/Testlogpath/

*** Keywords ***
CB010638_A_Verification_of_Power_saving_avoidance_for_Cell_with_RRC_established_PA_call_with_feature_enable_disable
    Log To Console  \n**** Test is started ****     
    start Btslogs from Local machine
    Powersaving_configuration_CB010638  
    priority call onging for Powersaving avoidance   
    Stops Btslogs from Local machine    ${BTSLOG}
    verify power saving avoidance
    power saving avoidance disabled
    start Btslogs from Local machine
    normal call via ultracaller
    Stops Btslogs from Local machine    ${BTSLOG}
    verify power saving algorithm
    
CB010638_A_Verification_of_Cell_with_ongoing_PA_call_with_DRB_established_via_PDU_Session_Setup_excluded_from_PS
    Log To Console  \n**** Test is started ****
    start Btslogs from Local machine 
    Powersaving_configuration_CB010638  
    priority call onging for Powersaving avoidance   
    Stops Btslogs from Local machine    ${BTSLOG}
    verify power saving avoidance
       

CB010638_A_Verification_of_counter_update_when_PCell_and_SCell_with_ongoing_carrier_aggregation_PA_call_excluded_from_PS
    Log To Console  \n**** Test is started ****   
    start Btslogs from Local machine  
    Powersaving_configuration_CB010638  
    priority call onging for Powersaving avoidance   
    Stops Btslogs from Local machine    ${BTSLOG}
    verify power saving avoidance
    PM_Counter_Check_Validation  ${counters_CB010638}

CB010638_A_Verification_of_counter_update_for_the_number_of_Cell_exclusions_from_Power_saving_due_to_high_priority_events
    Log To Console  \n**** Test is started ****    
    start Btslogs from Local machine  
    Powersaving_configuration_CB010638  
    priority call onging for Powersaving avoidance   
    Stops Btslogs from Local machine    ${BTSLOG}
    verify power saving avoidance
    PM_Counter_Check_Validation  ${counters_CB010638}

Scf_moc_creation
    [Documentation]   This Keywords Used for Scf moc creation 
    ...         Author: arunkumar.a@nokia.com

    [Arguments]    ${dist_name}=${moc_item}    ${parameter}=${NRPGRP_Parameters}    
    ...    ${operation}=create    ${skip_parameter_relation_errors}=True
    
    admin.perform_parameter_recommissioning    ${dist_name}
    admin.perform_object_recommissioning    ${dist_name}
    ...    ${parameter}    ${operation}  
    Get Time

Get_Post_Active_alarms
    ${Post_Active_Alarm}    admin.get_active_alarms    
    Log    ${Post_Active_Alarm}

Geting_BTS_IDs_for_cb010638
    [Documentation]    author: arunkumar.a@nokia.com
    [Arguments]   ${cell_id}=${cellid_4}
    Log To Console    \n**** getting MRBTS/NRBTS ID ****
    ${MRBTSID_NRBTSID}    OperatingSystem.Run    cat ${scf_commission} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell_id}" | head -n 1
    ${length}    Get Length     ${MRBTSID_NRBTSID}
    ${MRBTSID_NRBTSID}     Run Keyword If  ${length}==0  
    ...    OperatingSystem.Run   cat ${scf_commission} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]" | head -n 1
    ...    ELSE     set variable    ${MRBTSID_NRBTSID}   
    ${mrbtsID}  OperatingSystem.Run  echo ${MRBTSID_NRBTSID}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${nrbtsID}  OperatingSystem.Run  echo ${MRBTSID_NRBTSID}|grep -oE "NRBTS-[0-9]+"| awk -F '-' '{print $2}'
    Log To Console   MRBTS ID:${mrbtsID}  NRBTS ID:${nrbtsID} 
    Set Suite Variable   ${BTS_name}    MRBTS-${mrbtsID}
    Log to console   \n**** BTS Name: ${BTS_name} ****
    Set Suite Variable    ${nrpgrp_object_name}   MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    Log to console   \n**** nrpgrp object name : ${nrpgrp_object_name}
    Set Suite Variable    ${nrpgrp_object_class_name_with_id}    NRPGRP-${nrpgrp_id}
    Set Suite Variable    ${nrpgrp_object_class_name}    NRPGRP
    Set Suite Variable    ${nrcell_4_moc}    ${nrpgrp_object_name}/NRCELL-${cellid_4}
    Log to console   \n**** nrpgrp object class name: ${nrpgrp_object_class_name}
    Set Suite Variable    ${nrpgrp_object_class_instance}    ${nrpgrp_object_name}/${nrpgrp_object_class_name_with_id}
    Log to console   \n**** nrpgrp moc: ${nrpgrp_object_class_instance}
Powersaving_configuration_CB010638
    [Documentation]    author: arunkumar.a@nokia.com
    ...    Using Taf.selenium.sbts 
    [Arguments]   ${id_value}=${NRPGRP_ID}   ${bts_configuration}=current 
    Log    \n**** Getting Date and Time ****
    ${date_time}  DateTime.Get Current Date   result_format=%Y%m%d%H%M%S   exclude_millis=True
    Log To Console   \n**** Current date&time: ${date_time} ****
    Log To Console    \n**** checking NRPGRP is existing or not ****
    Sbts_Login_And_Disable_Screen_Lock_CB010638
    ${NRPGRP_moc}    Selenium_Sbts.get_object_name_list    object_name=${nrpgrp_object_class_instance}
    ${NRPGRP_moc_length}    Get Length    ${NRPGRP_moc}
    Log To Console    \n**** If NRPGRP is exist then remove object form system configuration ****
    Run Keyword If    ${NRPGRP_moc_length}!=${0}    Selenium_Sbts.remove_object
    ...    object_name=${nrpgrp_object_class_instance}  
    sleep  10s
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_name}  
    ...     filter_param=${actNrLBPowerSaving_param}
    ...     new_value=false
    ...     abbr=${actNrLBPowerSaving_abbr}
    ...     bts_configuration=${bts_configuration}
    ${NRPGRP_Object_deletion}    Selenium_Sbts.get_object_name_list    object_name=${nrpgrp_object_class_instance}
    ${NRPGRP_Object_deletion_length}    Get Length    ${NRPGRP_Object_deletion}
    Sleep   5s
    Run Keyword If    ${NRPGRP_Object_deletion_length}!=${0}     Selenium_Sbts.validate_plan
    Run Keyword If    ${NRPGRP_Object_deletion_length}!=${0}     Selenium_Sbts.activate_plan     
    ...    activate_plan_despite_errors=${True}
    
    Log To Console    \n**** Adding Object:NRPGRP ****
    Selenium_Sbts.add_object  object_name=${nrpgrp_object_name} 
    ...     object_class_name=${nrpgrp_object_class_name}  
    ...     id_value=${id_value}    is_load_default_values=${True} 
    ${NRPGRP_Object_Creation}    Selenium_Sbts.get_object_name_list    object_name=${nrpgrp_object_class_instance}
    ${NRPGRP_Object_Creation_length}    Get Length    ${NRPGRP_Object_Creation}
    Sleep   5s
    Run Keyword If    ${NRPGRP_Object_Creation_length}!=${0}    powersaving_avoidance_parameter_cb010638    
    Log To Console    \n**** If NRPGRP exist Validate & activate Plane ****
    Run Keyword If    ${NRPGRP_Object_Creation_length}!=${0}     Selenium_Sbts.validate_plan
    Run Keyword If    ${NRPGRP_Object_Creation_length}!=${0}     Selenium_Sbts.activate_plan
    ...    activate_plan_despite_errors=${True}
    Sleep    10s
    
    Log To Console  \n**** Site reset initiated ****
    ${site_reset_status}    Selenium_Sbts.reset_site
    Sleep    4 minutes
    ${bts_status_after_site_reset}    Selenium_Sbts.get_bts_status    technology='NR'
    Sbts_Logout_And_Close_Browser_Cb010638
Getting bts on air
    Sbts_Login_And_Disable_Screen_Lock_CB010638
    ${bts_status_after_site_reset}    Selenium_Sbts.get_bts_status    technology='NR'
    Sbts_Logout_And_Close_Browser_Cb010638

power saving avoidance disabled
    [Documentation]    Author:arunkumar.a@nokia.com
    [Arguments]    ${bts_configuration}=current  
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${powerSavingAvoidanceForPACalls_param}
    ...     new_value=${powerSavingAvoidanceForPACalls_value_diabled}
    ...     abbr=${powerSavingAvoidanceForPACalls_abbr}
    ...     bts_configuration=${bts_configuration}
    Selenium_Sbts.validate_plan
    Selenium_Sbts.activate_plan  activate_plan_despite_errors=${True}

powersaving_avoidance_parameter_cb010638
    [Documentation]    Author:arunkumar.a@nokia.com
    [Arguments]    ${bts_configuration}=current  
    Selenium_Sbts.set_parameter_value   dist_name=${nrcell_4_moc}  
    ...     filter_param=${actPriorityAccess_param}
    ...     new_value=${actPriorityAccess_value}
    ...     abbr=${actPriorityAccess_abbr}
    ...     bts_configuration=${bts_configuration}
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${nr_cell_config_param}
    ...     new_value=${nr_cell_config_value}
    ...     abbr=${nr_cell_config_abbr}
    ...     bts_configuration=${bts_configuration}
    Log To Console  \n**** Setting NR cell ID:${nr_cell_config_value} in NRPGRP ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${lbpslast_cell_switch_off_param}
    ...     new_value=${lbpsLastCellSOEnabled_Value}
    ...     abbr=${lbpsLastCellSOEnabled_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** Setting Last cell switch off = ${lbpsLastCellSOEnabled_Value} ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${lbps_day_of_week_param}
    ...     new_value=${lbpsDayOfWeek_value}
    ...     abbr=${lbpsDayOfWeek_abbr}
    ...     bts_configuration=${bts_configuration}
    Log To Console    \n**** Setting Day of week:${lbpsDayOfWeek_value} in NRPGRP  ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${lbps_duration_param}
    ...     new_value=${lbpsDuration_value}
    ...     abbr=${lbpsDuration_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** Setting lbps duration = ${lbpsDuration_value} ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${lbps_starttimehour_param}
    ...     new_value=${lbpsStartTimeHour_value}
    ...     abbr=${lbpsStartTimeHour_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** Setting lbps start hour= ${lbpsStartTimeHour_value} ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_class_instance}  
    ...     filter_param=${lbps_start_time_minute_param}
    ...     new_value=${lbpsStartTimeMinute_value}
    ...     abbr=${lbpsStartTimeMinute_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** Setting lbps start minuets= ${lbpsStartTimeMinute_value} ****

    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_name}  
    ...     filter_param=${actNrLBPowerSaving_param}
    ...     new_value=${actNrLBPowerSaving_value}
    ...     abbr=${actNrLBPowerSaving_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** Enabled actNrLBPowerSaving = ${actNrLBPowerSaving_value} ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_name}  
    ...     filter_param=${MimoRTXPowerSaving_param}
    ...     new_value=${MimoRTXPowerSaving_value}
    ...     abbr=${MimoRTXPowerSaving_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** diabled actNrLBmMimoRTXPowerSaving= ${lbpsStartTimeMinute_value} ****
    Selenium_Sbts.set_parameter_value   dist_name=${nrpgrp_object_name}  
    ...     filter_param=${TXPowerSaving_param}
    ...     new_value=${TXPowerSaving_value}
    ...     abbr=${TXPowerSaving_abbr}
    ...     bts_configuration=${bts_configuration}
    Log to console   \n**** diabled actNrLBRTXPowerSaving = ${TXPowerSaving_value} ****
Sbts_Login_And_Disable_Screen_Lock_CB010638
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

#    Selenium_Sbts.enable_virtual_display
    Selenium_Sbts.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    # ...                    version=${version}
    # ...                    browser=${browser}
    Selenium_Sbts.disable_message_box
    Selenium_Sbts.disable_screen_lock

Sbts_Logout_And_Close_Browser_Cb010638
#    Run Keyword And Ignore Error    Selenium Close StartUp View    timeout=5
    Run Keyword And Ignore Error    Selenium_Sbts.logout
    Run Keyword And Ignore Error    Selenium_Sbts.disable_virtual_display
    Run Keyword And Ignore Error    Selenium_Sbts.close_browser

Powersaving_avoidance_enable
    [Documentation]   perform_object_recommissioning(dist_name,
    ...     parameter, operation, skip_parameter_relation_errors=False,
    ...     should_activate=True, timeout=300, connection=None)

    [Arguments]    ${distName_object}=${power_saving_dict}   ${Dict_PA_Feature_Enable}=${Dict_PA_Feature_Enable_} 
    ...    ${should_activate_parameter}=False
    # ${PA_Paramerters}    time_Config.Powersaving Avoidance Feature


    ${parameters}  time_Config.powersaving_parameters
    Get_Feature_Activation   Dict_Name=${Dict_PA_Feature_Enable}   parameter=powerSavingAvoidanceForPACalls 
    ...    value=PA avoidance PCell enabled
    ...    should_activate=${should_activate_parameter}

    Get_Feature_Activation   Dict_Name=${Dict_PA_Feature_Enable}   parameter=actNrLBPowerSaving 
    ...    value=True
    ...    should_activate=${should_activate_parameter}
    
    admin.perform_object_recommissioning  ${distName_object}  ${parameters}  ${operation}=create
    # admin.reset    ${reset_coverage}=Site

Get_Feature_Activation
    [Arguments]    ${Dict_Name}=${None}    
    ...            ${parameter}=${None} 
    ...            ${operation}=update    ${value}=${None} 
    ...            ${should_activate}=True    ${timeout}=350  
    admin.perform_parameter_recommissioning
    ...    dist_name=${Dict_Name}
    ...    parameter=${parameter}
    ...    operation=${operation}   
    ...    value=${value}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
FTP_dl_data_transfer
    [Arguments]    ${ue_alias}    ${protocol_type}    ${direction}
    uc.start_datatransfer    ue_alias=${ue_alias}    protocoltype=${protocol_type}   direction=${direction}
    uc.await_data_transfer_finish    ue_alias=${ue_alias}    direction=${direction}
SCF_Commission
    [Arguments]      ${Commission_file}=${scf_commission}
    Directory Should Exist    ${SCF_PATH}   
    admin.perform_commissioning    ${BTS_ID}    skip_parameter_relation_errors=true
    ...        scf_file=${Commission_file}   timeout=200
Test_Setup_keywords  
    admin.Connect to    bts_host=${BTS_Details.bts_host}   bts_port= ${BTS_Details.bts_port} 
    ...    username=${BTS_Details.username}    password=${BTS_Details.password}   admin_api_log_dir=${BTS_Details.admin_api_log_dir}
    # ...        release=${BTS_Details.release}
    SCF_Commission     ${scf_commission}
    Sleep    100s
    Geting_BTS_IDs_for_cb010638
    Require ue for ue functions
    Run Keyword And Ignore Error    Start_Dcap

Require ue for ue functions
    [Arguments]     ${alias}=${UE_alias}[0]   ${capability}=${capabilities}
    uc.Require UE    alias=${alias}    capability=${capability}

initial ue attach via ultracaller
    [Arguments]     ${alias}=${UE_alias}[0]
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    alias=${alias}

detach ue via ultracaller
    [Arguments]     ${alias}=${UE_alias}[0]
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE     alias=${alias}

Test_Teardown_Keywords
    Run Keyword And Ignore Error    Stop_Dcap
    admin.teardown_admin
Start_Dcap
    rd.connect_to      host=${Dcap_Server_Details.host}    port=${Dcap_Server_Details.port}
    ...             secure=${True}  
    ${out_put}    rd.start_trace     duration=-1     bts=&{Dcap_User_Details}
    ...        gnb_custom_profile=@{Only_Gnb_custom_profile}    bts_custom_profile=@{Bts_custom_profile}
    ...        wait_for_activation=True
    Log To Console    ${out_put}
    ${trace_id}     Get From Dictionary     ${out_put}    tracer_id
    Set Suite Variable    ${trace_id} 
Stop_Dcap
    [Arguments]        ${Dcap_Trace_ID}=${trace_id}
    Log To Console    ${Dcap_Trace_ID}
    rd.stop_trace    ${Dcap_Trace_ID}
    Sleep    3m    DCAP log stopping take more then expected.To avoid unwanted interfrence
    ${DCAP_results_path}    OperatingSystem.Join Path    ${OUT_SUITE_LOGS_DIR_PATH}    DCAP_Logs
    Create Directory  ${DCAP_results_path}
    rd.get_results     target_dir=${DCAP_results_path}    timeout=200
Voice_call_start
    [Arguments]       ${alias}=${UE_alias}[0]    ${test_case_name}=${VOICE_CALL}[0]
    uc.start_voice_call    alias=${alias}    test_case_name=${test_case_name}
Voice_call_stop
    [Arguments]       ${alias}=${UE_alias}[0]
    uc.stop_voice_call    alias=${alias}

priority call onging for Powersaving avoidance
    detach ue via ultracaller
    initial ue attach via ultracaller
    Voice_call_start    ${UE_alias}    ${VoNR_TESTCASE_IN_ULTRACALLER}
    Sleep  20 minutes  Purpose:To check power saving avodance
    Voice_call_stop    ${UE_alias}

normal call via ultracaller
    detach ue via ultracaller
    initial ue attach via ultracaller
    Voice_call_start    ${UE_alias}    ${VoNR_TESTCASE_IN_ULTRACALLER}
    Sleep  5 minutes  Purpose:To check power saving avodance
    Voice_call_stop    ${UE_alias}
start Btslogs from Local machine
    [Arguments]    ${log_alias}    
    btslog.create_btslog_collector    ${log_alias}    
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias} 
    core.Set Suite Alias    ${log_alias}
Stops Btslogs from Local machine
    [Arguments]    ${log_alias}   
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}   
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias}   
verify power saving avoidance
    FOR  ${i}  IN RANGE  0  1
        Verification_btslog    search_string=${verify_priority_drb}
        Verification_btslog    search_string=${verify_lbps_avoidance}
        Verification_btslog    search_string=${notenergysaving_state}
    END

verify power saving algorithm
    FOR  ${i}  IN RANGE  0  1
        Verification_btslog    search_string=${energysaving}
    END
Verification_btslog
    [Arguments]    ${dir_path}=${BTSLOG_Path_for_validation}   
    Run Keyword And Ignore Error
    ...     Validation.validate_syslog_file_contents  dir_path=${dir_path}

PM_Counter_Check_Validation
    [Arguments]    ${dist_name}
    ${counter_List}    admin.get_counters_info  ${dist_name}  
    log    ${counter_List}
    FOR  ${count1}	   IN    @{Counters_list}
        IF  ${counter_List} != 0  CONTINUE
            log    ${counter_List}
    END   
verify the bts required status
    [Arguments]    ${Required_BTS_Status}
    ${bts_status}   admin.get_bts_statuses
    Set Suite Variable    ${bts_status}
    Should Be Equal     first="${bts_status}[proceduralState]"  second="${Required_BTS_Status}"
verify the bts required status onair
    [Arguments]    ${Required_BTS_Status}=OnAir
    ${bts_status}   admin.get_bts_statuses
    Set Suite Variable    ${bts_status}
    Should Be Equal     first="${bts_status}[proceduralState]"  second="${Required_BTS_Status}"

