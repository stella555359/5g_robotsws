*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

*** Variables ***
&{dcap_info}    host=127.0.0.1   port=9443    username=${None}    password=${None}

*** Keywords ***
################################  Env Setup and Logging  ##############################################################
Setup_for_RJIO
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
    IF  '${config_tag}' == 'rjio'
        Run Keyword and Ignore Error  Update_BSR_Package
    END
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s

    ute_wtssim.Execute Egate Command
    ...    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=XnAP Link with GNB.* up
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace amf=1 protocol=ng on

Setup_for_TMOUS
    [Arguments]  ${config_tag}
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
    ...                   customer=TMO_65

    # Cell-5/6/9/12 are MPLANE CELL
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=enb_x2_link_up enb=1 target=5
    ...    pass_regexp=X2AP Link with GNB-.* up
    ute_wtssim.Execute Egate Command
    ...    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=gnb_xn_link_up gnb=3 target=2
    ...    pass_regexp=XnAP Link with GNB.* up
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace amf=1 protocol=ng on
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_trace enb=1 protocol=xn,s1,x2 on

Teardown_for_CB013365
    # Airphone Operation    operation=edaemon_egate_teardown
    # ...                   product_type=gnb
    # ...                   traffic_info_dic=${None}
    # ...                   tag=${None}
    # ...                   cmd=${None}
    # ...                   pass_regexp=${None}
    # ...                   timeout=100s

    ####################### Log Collection ####################################
    # ${current_time}=  Get Current Date  result_format=%H:%M:%S
    Run Keyword And Ignore Error  stop_log_collection
    Run Keyword and Ignore Error  HAZ TC02 Get SCF Internal Id By Scout  no_ute=False

Setup_eGate_Env
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Update_BSR_Package
    ${dllink}   Set Variable    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run    wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Wait_for_Next_5min_Period
    log to console  \nWait for Next 5min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  300 - (${current_time_in_seconds} % 300)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 5min period
    sleep  ${wait_time_to_next_5min}

Wait_for_Next_15min_Period
    log to console  \nWait for Next 15min Period...
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}
    ${wait_time_to_next_5min}=  Evaluate  900 - (${current_time_in_seconds} % 900)
    log to console  \nNeed Wait for ${wait_time_to_next_5min} secnods to next 15min period
    sleep  ${wait_time_to_next_5min}

Get_Current_Time
    ${current_time}=  Get Current Date  result_format=%H:%M:%S
    log to console  \nCurrent Time: ${current_time}
    ${current_time_in_seconds}=  Convert Time  ${current_time}

    [Return]  ${current_time_in_seconds}

start_log_collection
    # [Arguments]  ${cell_id}  ${log_type}=emil+syslog+snapshot
    [Arguments]  ${log_type}=syslog+emil+snapshot

    Run  DCAP_Basic_controller start
    sleep  5
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Run Keyword And Ignore Error
    ...    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}
    sleep  30s

stop_log_collection
    [Arguments]  ${log_type}=syslog+emil+snapshot

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}    cudu_index=${0}
    Log To Console    \nlog of gnb: ${local_file_path}

###########################################  gNB Operation  ################################################################
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

CB013365_Change_UE_Capability
    [Arguments]  ${ue_capability}  ${ue_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability} capability_file=${CURDIR}/APCFG/ue_capability.cfg

CB013365_Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}

CB013365_Delta_Commission
    [Arguments]  ${file_name}  ${bts_index}=0
    log to console  \nStart delta plan commission: ${file_name}
    ${detal_commission_result}   Parameter Operation  operation=delta_plan_update   product_type=gnb
    ...                          delta_file_path=${CURDIR}/APCFG/${file_name}
    Log To Console   \ndelta plan update result: ${detal_commission_result}
    Run Keyword And Ignore Error
    ...  BTS Operation    operation=verify    product_type=gnb    bts_index=${bts_index}    verify_status=SITE_ONAIR

CB013365_Change_gNB_Handover_Type
    [Arguments]  ${gnb_id}=3  ${ho_type}=xn_based

    ute_wtssim.Execute Egate Command
    ...    cmd=gnb_param id=${gnb_id} sa_ho=${ho_type}

####################################  UE Operation   ######################################################################
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

ue_create_and_activate_2nd_pdu
    [Arguments]  ${ue_id}=1  ${pdu_id}=2  ${trf_type}=internal
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...    timeout=15s
    log to console  \nUE-${ue_id} PDU Setup Successfully!

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1

    Run Keyword And Ignore Error  ute_wtssim.Execute Egate Command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    pass_regexp=UE${ue_id}: detached
    ...    timeout=1
    log to console  \nUE-${ue_id} Detached!

start_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    # ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    # ...  timeout=1s

start_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    # ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    # ...  timeout=1s

start_ue_dl_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    # ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    # ...  timeout=3s
    sleep  2
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    # ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    # ...  timeout=3s

stop_ue_dl_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}

stop_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

stop_ue_dl_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${rtp_codec}=amr_12_2

    Log to Console  \nStart to establish UE-${ue_id} 5QI-5
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_im_exit id=${ue_id}
    sleep  1   # idle在connect状态转变需要大概0.5s，如果马上发data，可能idle在connect状态转换还没完成，导致数据发送失败

    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=31 by=ue
    #  Note QFI:2 not equal to qosflow_id
    ...  pass_regexp=Added QosFlow with QFI:2 fiveQI:5

    Log to Console  \nStart to establish UE-${ue_id} 5QI-1
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=1 by=ue
    #  Note QFI:3 not equal to qosflow_id
    ...  pass_regexp=Added QosFlow with QFI:3 fiveQI:1

    Log to Console  \nStart UE-${ue_id} ${rtp_codec} VoNR call
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 rtp_codec=${rtp_codec} dir=dl seconds=36000
    ...  pass_regexp=Started Downlink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu_id} Qfi:3
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 rtp_codec=${rtp_codec} dir=ul seconds=36000
    ...  pass_regexp=Started Uplink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu_id} Qfi:3

release_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu_id}=1

    Log to Console  \nRelease UE-${ue_id} VoNR Call!
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=3 dir=dl
    ...  pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}.*Pdu:${pdu_id} Qfi:3
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=3 dir=ul
    ...  pass_regexp=Stopping Uplink Internal traffic on Ue:${ue_id}.*Pdu:${pdu_id} Qfi:3

    Log to Console  \nStart to release UE-${ue_id} 5QI-1
    # 如果正常release只使用ue_pdu_session_modify, qosflow release的原因会是unspecific，会导致某些KPI(drop ratio)异常，所以通过amf_ue_pdu_modify_param将release原因改成normal release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=1 by=ue
    ...  pass_regexp=Ue ${ue_id} PduId ${pdu_id} Removed FiveQi:Qfi mapping fiveQi 1 qfi 3
    Log to Console  \nStart to release UE-${ue_id} 5QI-5
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=31 by=ue
    ...  pass_regexp=Ue ${ue_id} PduId ${pdu_id} Removed FiveQi:Qfi mapping fiveQi 5 qfi 2

create_bler_profile
    [Arguments]  ${profile_id}  ${dl_bler}  ${ul_bler}
    Log to Console  \nCreate Radio Condition Profile- profile_id=${profile_id} DL_BLER: ${dl_bler} UL_BLER: ${ul_bler}
    ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler} ul_bler=${ul_bler}
    ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=${profile_id}


delete_bler_profile
    [Arguments]  ${profile_id}
    Log to Console  \nDelete DL BLER Profile: bler_testmode_nr profile_id=${profile_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=${profile_id} delete=yes

activate_bler_test_mode
    [Arguments]  ${ue_id}  ${profile_id}
    Log to Console  \nActivate UE-${ue_id} DL/UL BLER: profile_id=${profile_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=${profile_id}

deactivate_bler_test_mode
    [Arguments]  ${ue_id}  ${profile_id}
    Log to Console  \nDeactivate UE-${ue_id} DL/UL BLER: profile_id=${profile_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=deactivate profile_id=${profile_id}

activate_csi_report_test_mode
    [Arguments]  ${ue_id}  ${profile_id}
    Log to Console  \nActivate UE-${ue_id} CSI Report Override Mode: profile_id=${profile_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=${profile_id}

deactivate_csi_report_test_mode
    [Arguments]  ${ue_id}  ${profile_id}
    Log to Console  \nDeactivate UE-${ue_id} CSI Report Override Mode: profile_id=${profile_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=csi_override action=deactivate profile_id=${profile_id}

get_ue_dl_scell_status
    [Arguments]    ${ue_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=on
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pdsch
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=off
    [Return]  ${scell_status}

get_ue_ul_scell_status
    [Arguments]    ${ue_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=on
    ${scell_status}=  ute_wtssim.Execute Egate Command And Wait For Data
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-9 type=pusch
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=off
    [Return]  ${scell_status}

get_ue_dl_scell_tput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    ${scell_status}=  get_ue_dl_scell_status  ue_id=${ue_id}
    ${scell_tput}=  Get Regexp Matches  ${scell_status}  CellIndex-${scell_id}\\s+(\\d+.\\d+).*?  1

    [Return]  ${scell_tput}[0]

get_ue_ul_scell_tput
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    ${scell_status}=  get_ue_ul_scell_status  ue_id=${ue_id}
    ${scell_tput}=  Get Regexp Matches  ${scell_status}  CellIndex-${scell_id}\\s+(\\d+.\\d+).*?  1

    [Return]  ${scell_tput}[0]

attach_ue_nsa
    [Arguments]  ${ue_id}=51
    log to console  \nStart NSA UE-${ue_id} Attach!
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_attach id=${ue_id}
    ...  pass_regexp=UE${ue_id}: === UE IS ACTIVE

activate_endc_nsa
    [Arguments]  ${ue_id}=51  ${target_gnb_id}=2  ${target_cell_id}=1  ${bearer}=2
    log to console  \nStart to activate ENDC for UE-${ue_id}!
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb_id} target_cells=${target_cell_id} bearer=${bearer} type=split_scg
    ...  pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity

ue_bearer_add_nsa
    [Arguments]  ${ue_id}=51  ${bearer}=2  ${filter}=1  ${precedence}=1
    log to console  \nStart to add bearer-${bearer} for UE-${ue_id}!
    ute_wtssim.Execute Egate Command
    ...  cmd=bearer_add ue=${ue_id} by=pgw id=${bearer} filter=${filter} precedence=${precedence}
    ...  pass_regexp= UE${ue_id}:.*Bearer-\\d+.* created

modify_endc_nsa
    [Arguments]  ${ue_id}=51  ${action}=bearer_to_add  ${bearer}=2
    log to console  \nStart to modify ENDC ${action}=${bearer} for UE-${ue_id}!
    ute_wtssim.Execute Egate Command
    ...  cmd=enb_ue_dc_modify ue=${ue_id} ${action}=${bearer} by=enb cause=MISC_CauseMisc_unspecified
    ...  pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity

detach_ue_nsa
    [Arguments]  ${ue_id}=51
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_detach id=${ue_id}
    ...  pass_regexp=UE${ue_id}: detached
    ...  timeout=1
    log to console  \nNSA UE-${ue_id} Detached!

start_ue_dl_data_traffic_nsa
    [Arguments]  ${ue_id}  ${bearer}=2  ${dl_rate}=150  ${trf_id}=1  ${duration}=3600
    Log to Console  \nNSA UE-${ue_id} Start Data Service: DL_Rate=${dl_rate}mbps
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} id=${bearer} dir=dl trf_id=${trf_id} mbps=${dl_rate} seconds=${duration}
    ...  pass_regexp=UE ${ue_id}: UDP DL TRF

start_ue_ul_data_traffic_nsa
    [Arguments]  ${ue_id}  ${bearer}=2  ${ul_rate}=20  ${trf_id}=1  ${duration}=36000
    Log to Console  \nNSA UE-${ue_id} Start Data Service: UL_Rate=${ul_rate}mbps
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} id=${bearer} dir=ul trf_id=${trf_id} mbps=${ul_rate} seconds=${duration}
    ...  pass_regexp=UE ${ue_id}: UDP UL TRF

start_ue_dl_ul_data_traffic_nsa
    [Arguments]  ${ue_id}  ${bearer}=2  ${dl_rate}=150  ${ul_rate}=20  ${trf_id}=1  ${duration}=36000
    Log to Console  \nNSA UE-${ue_id} Start Data Service: DL_Rate=${dl_rate}mbps  UL_Rate=${ul_rate}mbps
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} id=${bearer} dir=dl trf_id=${trf_id} mbps=${dl_rate} seconds=${duration}
    ...  pass_regexp=UE ${ue_id}: UDP DL TRF
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} id=${bearer} dir=ul trf_id=${trf_id} mbps=${ul_rate} seconds=${duration}
    ...  pass_regexp=UE ${ue_id}: UDP UL TRF

stop_ue_data_traffic_nsa
    [Arguments]  ${ue_id}  ${bearer}=2
    Log to Console  \nNSA UE-${ue_id} Stop Data Service
    ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_stop ue=${ue_id} id=${bearer} dir=dl
    ...   pass_regexp=Traffic was stopped
    ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_stop ue=${ue_id} id=${bearer} dir=ul
    ...   pass_regexp=Traffic was stopped

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

ue_history_information_reset
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list id=1 action=reset

ue_history_information_add
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=310:260|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_history_information_list id=1 action=commit

ue_add_ue_history_information
    [Arguments]  ${ue_id}=1
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_enb_param id=${ue_id} ue_history_list=1

CB013365_Get_UE_NR_Measurement_Configuraiton
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=on
    ${meas_conf}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    # log to console  \noutput: ${meas_conf}
    ute_wtssim.Execute Egate Command
    ...    cmd=sim_param_set disable_events_on_telnet_session=off
    [Return]    ${meas_conf}

CB013365_Get_NR_Meas_Obj_Id
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

CB013365_Get_NR_Meas_Report_Id
    [Arguments]   ${meas_conf}  ${event_type}  ${report_on_leave}  ${rsrp}
    @{event_list}  Create List  A1  A2  A5  B2
    IF  '${event_type}' in @{event_list}
        ${pattern}  Set Variable
        ...  UE\\d+ TRIGGER.*configuration (\\d+):[\\\r\\\n\\r\\n]+.*Type:.*ReportOnLeave: ${report_on_leave}, Event${event_type}:.*RSRP ${rsrp}?
        ${report_id}  Get Regexp Matches  ${meas_conf}  ${pattern}  1
        ${length}   Get Length  ${report_id}
    ELSE
        ${pattern}  Set Variable
        ...  UE\\d+ TRIGGER.*configuration (\\d+):[\\\r\\\n\\r\\n]+.*Type: event.*ReportOnLeave:.*Event${event_type}: offset choice=1.*?
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

CB013365_Get_NR_Meas_Config_Id
    [Arguments]   ${ue_id}  ${nrarfcn}  ${event_type}  ${report_on_leave}  ${rsrp}

    ${meas_conf}  CB013365_Get_UE_NR_Measurement_Configuraiton  ${ue_id}
    ${obj_id}  CB013365_Get_NR_Meas_Obj_Id  ${meas_conf}  ${nrarfcn}
    ${report_id_list}  CB013365_Get_NR_Meas_Report_Id  ${meas_conf}  ${event_type}  ${report_on_leave}  ${rsrp}
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
################################################  MUE Operation #########################################################
mue_attach_and_activate_pdu
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        attach_ue_and_activate_pdu  ue_id=${ue_id}
        sleep  1
    END

mue_detach_with_power_off
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        detach_ue_with_power_off  ue_id=${ue_id}
    END

mue_start_dl_data_service
    [Arguments]  @{ue_list}  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150
    FOR  ${ue_id}  IN  @{ue_list}
        start_ue_dl_data_traffic  ue_id=${ue_id}  pdu=${pdu}  qfi=${qfi}  trf_id=${trf_id}  dl_rate=${dl_rate}
        # 如果data+vonr，mcs/rank会受vonr参数设置影响，导致mcs降低，data tput也会下降
        sleep  1
    END

mue_start_ul_data_service
    [Arguments]  @{ue_list}  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${ul_rate}=10
    FOR  ${ue_id}  IN  @{ue_list}
        start_ue_ul_data_traffic  ue_id=${ue_id}  pdu=${pdu}  qfi=${qfi}  trf_id=${trf_id}  ul_rate=${ul_rate}
        sleep  1
    END

mue_stop_data_service
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        stop_ue_dl_data_traffic  ue_id=${ue_id}
        stop_ue_ul_data_traffic  ue_id=${ue_id}
    END

mue_start_vonr_service
    [Arguments]  @{ue_vonr_list}
    FOR  ${ue_vonr}  IN  @{ue_vonr_list}
        start_ue_vonr_call  ue_id=${ue_vonr}  rtp_codec=amr_wb_23_85
        sleep  1
    END

mue_stop_vonr_service
    [Arguments]  @{ue_vonr_list}
    FOR  ${ue_vonr}  IN  @{ue_vonr_list}
        release_ue_vonr_call  ue_id=${ue_vonr}
        sleep  1
    END

mue_change_ue_location
    [Arguments]  @{ue_list}  ${enb_id}  ${cell_id}
    FOR  ${ue_id}  IN  @{ue_list}
        CB013365_Change_UE_Location  ue_id=${ue_id}  enb_id=${enb_id}  cell_id=${cell_id}
    END

mue_attach_nsa
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        attach_ue_nsa  ue_id=${ue_id}
        sleep  1
    END

mue_activate_endc_nsa
    [Arguments]  @{ue_list}  ${target_gnb_id}=2  ${target_cell_id}=1  ${bearer}=2
    FOR  ${ue_id}  IN  @{ue_list}
        activate_endc_nsa  ue_id=${ue_id}  target_gnb_id=${target_gnb_id}  target_cell_id=${target_cell_id}    bearer=${bearer}
        sleep  1
    END

mue_bearer_add_nsa
    [Arguments]  @{ue_list}  ${bearer}=2  ${filter}=1  ${precedence}=1
    FOR  ${ue_id}  IN  @{ue_list}
        ue_bearer_add_nsa  ue_id=${ue_id}  bearer=${bearer}  filter=${filter}  precedence=${precedence}
        sleep  1
    END

mue_detach_nsa
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        detach_ue_nsa  ue_id=${ue_id}
        sleep  1
    END

mue_start_dl_data_service_nsa
    [Arguments]  @{ue_list}  ${bearer}=2  ${dl_rate}=${50}
    FOR  ${ue_id}  IN  @{ue_list}
        start_ue_dl_data_traffic_nsa  ue_id=${ue_id}  bearer=${bearer}  dl_rate=${dl_rate}
        sleep  1
    END

mue_start_ul_data_service_nsa
    [Arguments]  @{ue_list}  ${bearer}=2  ${ul_rate}=${10}
    FOR  ${ue_id}  IN  @{ue_list}
        start_ue_ul_data_traffic_nsa  ue_id=${ue_id}  bearer=${bearer}  ul_rate=${ul_rate}
        sleep  1
    END

mue_start_dl_ul_data_service_nsa
    [Arguments]  @{ue_list}  ${bearer}=2  ${dl_rate}=${50}  ${ul_rate}=${10}
    FOR  ${ue_id}  IN  @{ue_list}
        start_ue_dl_ul_data_traffic_nsa  ue_id=${ue_id}  bearer=${bearer}  dl_rate=${dl_rate}  ul_rate=${ul_rate}
        sleep  1
    END

mue_stop_data_service_nsa
    [Arguments]  @{ue_list}  ${bearer}=2
    FOR  ${ue_id}  IN  @{ue_list}
        stop_ue_data_traffic_nsa  ue_id=${ue_id}  bearer=${bearer}
        sleep  1
    END

create_multiple_bler_profile
    # bler值个数不要超过SCF里maxDlHarqTx的值
    create_bler_profile  profile_id=2  dl_bler=20,10,5,0  ul_bler=20,10,5,0
    create_bler_profile  profile_id=3  dl_bler=80,50,20,10  ul_bler=80,50,20,10
    create_bler_profile  profile_id=4  dl_bler=200,150,100,100  ul_bler=200,150,100,100

delete_multiple_bler_profile
    delete_bler_profile  profile_id=2
    delete_bler_profile  profile_id=3
    delete_bler_profile  profile_id=4

create_multiple_csi_report_profile
    Log to Console  \nCreate CSI Report Override Profiles
    # Fix Profile
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=12 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3
    ...    pass_regexp=EGATE>
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=12
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=13 cqi_mode=fixed cqi=8 ri_mode=fixed ri=1
    ...    pass_regexp=EGATE>
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=13
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=14 cqi_mode=fixed cqi=1 ri_mode=fixed ri=0
    ...    pass_regexp=EGATE>
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=14
    ...    pass_regexp=EGATE>

    # Variable Profile
    ${cmd_1}  Set Variable  csi_override_testmode_nr profile_id=22
    ${cmd_2}  Set Variable  cqi_mode=varying cqi=11,12,13,14,15 cqi_period=20
    ${cmd_3}  Set Variable  ri_mode=varying ri=2,3 ri_period=20
    ${cmd}    Catenate  ${cmd_1}  ${cmd_2}  ${cmd_3}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=EGATE>

    ${cmd_1}  Set Variable  csi_override_testmode_nr profile_id=23
    ${cmd_2}  Set Variable  cqi_mode=varying cqi=6,7,8,9,10 cqi_period=10
    ${cmd_3}  Set Variable  ri_mode=varying ri=1,2 ri_period=10
    ${cmd}    Catenate  ${cmd_1}  ${cmd_2}  ${cmd_3}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=EGATE>

    ${cmd_1}  Set Variable  csi_override_testmode_nr profile_id=24
    ${cmd_2}  Set Variable  cqi_mode=varying cqi=1,2,3,4,5 cqi_period=5
    ${cmd_3}  Set Variable  ri_mode=varying ri=0,1 ri_period=5
    ${cmd}    Catenate  ${cmd_1}  ${cmd_2}  ${cmd_3}
    ute_wtssim.Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=EGATE>

delete_multiple_csi_report_profile
    Log to Console  \nDelete CSI Report Override Profiles
    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=12 delete=yes
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=13 delete=yes
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=14 delete=yes
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=22 delete=yes
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=23 delete=yes
    ...    pass_regexp=EGATE>

    ute_wtssim.Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=24 delete=yes
    ...    pass_regexp=EGATE>

mue_activate_bler_test_mode
    [Arguments]  @{ue_list}  ${profile_id}
    FOR  ${ue_id}  IN  @{ue_list}
        activate_bler_test_mode  ue_id=${ue_id}  profile_id=${profile_id}
    END

mue_deactivate_bler_test_mode
    [Arguments]  @{ue_list}  ${profile_id}
    FOR  ${ue_id}  IN  @{ue_list}
        deactivate_bler_test_mode  ue_id=${ue_id}  profile_id=${profile_id}
    END

mue_activate_csi_report_test_mode
    [Arguments]  @{ue_list}  ${profile_id}
    FOR  ${ue_id}  IN  @{ue_list}
        activate_csi_report_test_mode  ue_id=${ue_id}  profile_id=${profile_id}
    END

mue_deactivate_csi_report_test_mode
    [Arguments]  @{ue_list}  ${profile_id}
    FOR  ${ue_id}  IN  @{ue_list}
        deactivate_csi_report_test_mode  ue_id=${ue_id}  profile_id=${profile_id}
    END

mue_add_ue_history_information
    [Arguments]  @{ue_list}
    FOR  ${ue_id}  IN  @{ue_list}
        ue_add_ue_history_information  ue_id=${ue_id}
    END

mue_pdu_session_modify_add_qosflow
    [Arguments]  @{ue_list}  ${qosflow}=17,39
    FOR  ${ue_id}  IN  @{ue_list}
        ue_pdu_session_modify_add_qosflow  ue_id=${ue_id}  qosflow=${qosflow}
        sleep  1
    END
