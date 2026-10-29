*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}

*** Keywords ***
attach_ue_and_activate_pdu
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${trf_type}=internal
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_register id=${ue_id}
    ...    pass_regexp=REGISTRATION COMPLETE
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...    timeout=15s
    log to console  \nUE-${ue_id} PDU Setup Successfully!

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1

    Run Keyword And Ignore Error  ute_wtssim.Execute Egate Command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    # ...    pass_regexp=UE${ue_id}: detached
    # ...    timeout=1
    log to console  \nUE-${ue_id} Detached!

start_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1  ${dl_rate}=150
    Log to Console  \nUE-${ue_id} Start trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}


start_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}

stop_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}

stop_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_big_data_traffic
    [Arguments]  ${ue_id}=1  ${dl_rate}=450  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+1
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=3600
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//10+1
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=10 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=10 seconds=3600
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul

start_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${rtp_codec}=amr_12_2

    Log to Console  \nStart to establish UE-${ue_id} 5QI-5
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_im_exit id=${ue_id}
    sleep  1   # idle在connect状态转变需要大概0.5s，如果马上发data，可能idle在connect状态转换还没完成，导致数据发送失败

    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=11 by=ue
    #  Note QFI:2 not equal to qosflow_id
    ...  pass_regexp=Added QosFlow with QFI:2 fiveQI:5

    Log to Console  \nStart to establish UE-${ue_id} 5QI-1
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=1 by=ue
    #  Note QFI:3 not equal to qosflow_id
    ...  pass_regexp=Added QosFlow with QFI:3 fiveQI:1

    Log to Console  \nStart UE-${ue_id} ${rtp_codec} VoNR call
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 rtp_codec=${rtp_codec} dir=dl seconds=36000
    ...  pass_regexp=Started Downlink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu} Qfi:3
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 rtp_codec=${rtp_codec} dir=ul seconds=36000
    ...  pass_regexp=Started Uplink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu} Qfi:3

release_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu}=1

    Log to Console  \nRelease UE-${ue_id} VoNR Call!
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=3 dir=dl
    ...  pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}.*Pdu:${pdu} Qfi:3
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=3 dir=ul
    ...  pass_regexp=Stopping Uplink Internal traffic on Ue:${ue_id}.*Pdu:${pdu} Qfi:3

    Log to Console  \nStart to release UE-${ue_id} 5QI-1
    # 如果正常release只使用ue_pdu_session_modify, qosflow release的原因会是unspecific，会导致某些KPI(drop ratio)异常，所以通过amf_ue_pdu_modify_param将release原因改成normal release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=1 by=ue
    ...  pass_regexp=Ue ${ue_id} PduId ${pdu} Removed FiveQi:Qfi mapping fiveQi 1 qfi 3
    Log to Console  \nStart to release UE-${ue_id} 5QI-5
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify id=1 ue=${ue_id} pdu=${pdu_id} qosflows_to_del=11 by=ue
    ...  pass_regexp=Ue ${ue_id} PduId ${pdu_id} Removed FiveQi:Qfi mapping fiveQi 5 qfi 2

get_ue_dl_scell_status
    [Arguments]    ${ue_id}=1
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-9

    [Return]  ${scell_status}

get_ue_ul_scell_status
    [Arguments]    ${ue_id}=1
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pusch

    [Return]  ${scell_status}

verify_ue_dl_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    # ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
    #     ...           cmd=ue_stats_nr id=${ue_id} scell=0-9
    ${scell_status}=  get_ue_dl_scell_status  ue_id=${ue_id}
    ${cell_list}=  Get Regexp Matches  ${scell_status}  (CellIndex-[0-9][\\s]+[0-9].*\\n)
    ${cell_num}=  Get Length  ${cell_list}
    should be equal  ${num_of_cells}  ${cell_num}
    log to console  \n${scell_status}

verify_ue_ul_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=1
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    # ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
    #     ...           cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pusch
    ${scell_status}=  get_ue_ul_scell_status  ue_id=${ue_id}
    ${cell_list}=  Get Regexp Matches  ${scell_status}  (CellIndex-[0-9][\\s]+[0-9].*\\n)
    ${cell_num}=  Get Length  ${cell_list}
    should be equal  ${num_of_cells}  ${cell_num}
    log to console  \n${scell_status}

check_ue_dl_scell_schedule_status
    [Arguments]    ${ue_id}=1    ${scell_id}=1
    ${scell_status}=  get_ue_dl_scell_status  ue_id=${ue_id}
    ${scell_info}=  Get Regexp Matches  ${scell_status}  (CellIndex-${scell_id}\\s+0.*\\s+0.*\\s+0.*\\s+0.*\\n)
    ${length}   Get Length  ${scell_info}
    IF  ${length} == 0
        log to console  \nSCell-${scell_id} is activated
        ${result}    Set Variable    ${True}
    ELSE
        log to console  \nSCell-${scell_id} is deactivated
        ${result}    Set Variable    ${False}
    END

    [Return]  ${result}

check_ue_dl_scell_configured_status
    [Arguments]    ${ue_id}=1    ${scell_id}=1
    ${scell_status}=  get_ue_dl_scell_status  ue_id=${ue_id}
    ${scell_info}=  Get Regexp Matches  ${scell_status}  (CellIndex-${scell_id}\\s+[0-9].*\\n)
    ${length}   Get Length  ${scell_info}
    IF  ${length} == 0
        log to console  \nSCell-${scell_id} is released
        ${result}    Set Variable    ${False}
    ELSE
        log to console  \nSCell-${scell_id} is configured
        ${result}    Set Variable    ${True}
    END

    [Return]  ${result}

Setup_for_IntergNB
    [Arguments]  ${config_tag}=${None}
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s

    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=enb_x2_link_up enb=1 target=2
    ...    pass_regexp=X2AP Link with GNB-.* up
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=enb_x2_link_up enb=1 target=3
    ...    pass_regexp=X2AP Link with GNB-.* up
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace amf=1 protocol=ng on
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1 protocol=xn,s1,x2 on

Setup_for_NRDC
    [Arguments]  ${config_tag}=${None}
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s

Teardown_for_IntergNB
    Run Keyword And Ignore Error  stop_log_collection
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False  flag=Multiple

Setup_eGate_Env
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Wait_for_Next_5min_Period
    log to console  \nWait for Next 5min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  300 - (${current_time_in_seconds} % 300)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 5min period
    sleep  ${wait_time_to_next_5min}

Get_Current_Time
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}

    [Return]  ${current_time_in_seconds}

start_log_collection
    [Arguments]  ${cell_id}  ${log_type}=emil+syslog+snapshot  ${gNB2}=${False}

    ${dcap_argument}  Create Dictionary   nrCells=NRCELL_R-${cell_id}
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Run Keyword And Ignore Error
    ...    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}
    IF  ${gNB2} == ${True}
    Run Keyword And Ignore Error
    ...    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${1}  cudu_index=${0}  dict_argument=${dict_argument}
    END
    sleep  60s

stop_log_collection
    [Arguments]  ${log_type}=emil+syslog+snapshot  ${gNB2}=${False}

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}    cudu_index=${0}
    Log To Console    \nlog of gnb: ${local_file_path}

    IF  ${gNB2} == ${True}
        Log Collection    start  ${log_type}  product_type=gnb  bts_index=${1}  cudu_index=${1}  dict_argument=${dict_argument}
        Log To Console    \nlog of gnb: ${local_file_path}
    END

Change_Configuration
    [Arguments]  ${para_list}  ${mo_list}  ${value_list}  ${product_type}=gnb

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...              verify_status=CELL_ONAIR    timeout=180s

Change_UE_Capability
    [Arguments]  ${ue_capability}  ${ue_id}

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability} capability_file=${CURDIR}/APCFG/ue_capability.cfg

Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}

Delta_Commission
    [Arguments]  ${file_name}

    log to console  \nStart delta plan commission: ${file_name}
    ${detal_commission_result}   Parameter Operation  operation=delta_plan_update   product_type=gnb
    ...                          delta_file_path=${CURDIR}/APCFG/${file_name}
    Log To Console   \ndelta plan update result: ${detal_commission_result}
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR

trigger_reestablishment_procedure
    [Arguments]  ${ue_id}  ${gnb_id}=2  ${cell_id}=1  ${cause}=otherFailure

    Log to Console  \nTrigger UE-${ue_id} RRC Restablisment Procedure
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
    ...  pass_regexp=UE${ue_id}: NR RRC Reestablishment sucessfully completed

Send_RRC_Inactivate_Command
    [Arguments]  ${ue_id}

    ${cmd_1}  Set Variable  amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on
    ${cmd_2}  Set Variable  ue_identity_index_value=${ue_id} ue_specific_drx=64
    ${cmd_3}  Set Variable  periodic_registration_update_timer=1:30secs plmn_id=311:489 tac_id=788
    ${cmd}    Catenate  ${cmd_1}  ${cmd_2}  ${cmd_3}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=EGATE>

Get_UE_State
    [Arguments]    ${ue_id}
    ${ue_info}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ${ue_state}    Get Regexp Matches    ${ue_info}    state\\s+(\\S+)  1
    # log to console  \n${ue_state}[0]
    [Return]    ${ue_state}[0]

Get_UE_Location
    [Arguments]    ${ue_id}
    ${ue_info}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ${enb_id}    Get Regexp Matches    ${ue_info}    enb\\s+(\\d+)  1
    ${cell_id}   Get Regexp Matches    ${ue_info}    cell\\s+(\\d+)  1
    log to console  \nUE${ue_id} is located at eNB-${enb_id}[0] Cell-${cell_id}[0]
    [Return]    ${enb_id}[0]  ${cell_id}[0]

Get_UE_NR_Measurement_Configuraiton
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=on
    ${meas_conf}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    # log to console  \noutput: ${meas_conf}
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=off
    [Return]    ${meas_conf}

Get_NR_Meas_Obj_Id
    [Arguments]   ${meas_conf}  ${nrarfcn}
    ${obj_id}   Get Regexp Matches  ${meas_conf}  (\\d+)\\s+[NR,EUTRAN]+\\s+${nrarfcn}\\s+\-  1
    ${length}   Get Length  ${obj_id}
    IF  ${length} == 0
        log to console  \nMeasurement Object:${nrarfcn} not found
        Return From Keyword  ${None}
    ELSE
        ${result}    Set Variable    ${obj_id}[0]
    END
    [Return]  ${result}

Get_NR_Meas_Report_Id
    [Arguments]   ${meas_conf}  ${event_type}  ${report_on_leave}  ${rsrp}
    @{event_list}  Create List  A1  A2  A5
    IF  '${event_type}' in @{event_list}
        ${pattern}  Set Variable
        ...  UE\\d+ TRIGGER.*configuration (\\d+):[\\\r\\\n\\r\\n]+.*Type:.*ReportOnLeave: ${report_on_leave}, Event${event_type}:.*RSRP ${rsrp}?
        ${report_id}  Get Regexp Matches  ${meas_conf}  ${pattern}  1
        ${length}   Get Length  ${report_id}
    ELSE
        ${pattern}  Set Variable
        ...  UE\\d+ TRIGGER.*configuration (\\d+):[\\\r\\\n\\r\\n]+.*Type: event.*ReportOnLeave:.*Event${event_type}:.*?
        ${report_id}  Get Regexp Matches  ${meas_conf}  ${pattern}  1
        ${length}   Get Length  ${report_id}
    END
    IF  ${length} == 0
        log to console  \nMeasurement Report ID for ${event_type} not found
        Return From Keyword  ${None}
    ELSE
        ${result}    Set Variable    ${report_id}
    END
    [Return]  ${result}

Get_NR_Meas_Config_Id
    [Arguments]   ${ue_id}  ${nrarfcn}  ${event_type}  ${report_on_leave}  ${rsrp}

    ${meas_conf}  Get_UE_NR_Measurement_Configuraiton  ${ue_id}
    ${obj_id}  Get_NR_Meas_Obj_Id  ${meas_conf}  ${nrarfcn}
    ${report_id_list}  Get_NR_Meas_Report_Id  ${meas_conf}  ${event_type}  ${report_on_leave}  ${rsrp}
    IF  ${report_id_list} == ${None}
        Return From Keyword  ${None}
    END
    FOR  ${index}  ${report_id}  IN ENUMERATE  @{report_id_list}
        ${pattern}  Set Variable  (\\d+)\[ \]+${obj_id}\[ \]+${report_id}.*?
        ${meas_id}  Get Regexp Matches  ${meas_conf}  ${pattern}  1
        ${length}   Get Length  ${meas_id}
        Run Keyword if  ${length} != 0  Exit For Loop
    END
    ${length}   Get Length  ${meas_id}
    IF  ${length} == 0
        log to console  \nMeasurement ID not found
        Return From Keyword  ${None}
    ELSE
        ${result}    Set Variable    ${meas_id}[0]
    END
    [Return]  ${result}

send_ics_registration
    [Arguments]  ${flag}=on

    ute_wtssim.Execute Egate Command
    ...    cmd=amf_param id=1 send_ics_registration=${flag}

ue_modify_default_qosflow
    [Arguments]  ${ue_id}=all  ${qosflow}=35

    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=${qosflow} ue=${ue_id} default=on

ue_pdu_session_modify_add_qosflow
    [Arguments]  ${ue_id}  ${qosflow}=17,39

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflow} by=ue

ue_pdu_session_modify_modify_qosflow
    [Arguments]  ${ue_id}  ${qosflow}  ${5qi}

    ute_wtssim.Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=${qosflow} 5qi=${5qi}  fiveqi_type=non-gbr
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_modify=${qosflow} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message.*successfully
    ...    timeout=5s

smf_parameter_config_multi_qosflow
    [Arguments]  ${qosflow}=42,43,45

    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=1 additional_qosflows_to_activate=${qosflow}
    ...    pass_regexp=EGATE>

smf_parameter_config_reset
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=1 reset
    ...    pass_regexp=EGATE>

CB013365_Delta_Commission
    [Arguments]  ${file_name}
    log to console  \nStart delta plan commission: ${file_name}
    ${detal_commission_result}   Parameter Operation  operation=delta_plan_update   product_type=gnb
    ...                          delta_file_path=${CURDIR}/APCFG/${file_name}
    Log To Console   \ndelta plan update result: ${detal_commission_result}
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR

CB013365_Change_Parameter
    [Arguments]  ${para_list}  ${mo_list}  ${value_list}  ${product_type}=gnb

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    Run Keyword And Ignore Error
    ...  BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...                   verify_status=CELL_ONAIR    timeout=180s