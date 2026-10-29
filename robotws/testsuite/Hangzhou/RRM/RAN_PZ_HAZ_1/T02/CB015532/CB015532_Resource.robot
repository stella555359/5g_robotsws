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
Setup_for_CB015532
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
    Run Keyword and Ignore Error  Update_BSR_Package
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

Teardown_for_CB015532
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
    # Run     wget ${dllink}/${filename} -P /home/ute --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C
    Run    wget ${dllink}/${filename} -P /home/ute
    # Run  sshpass -p 'Ut3pa5s#ff97' scp ute@10.56.218.196:/home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip /home/ute/
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

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}
    Log To Console    \nlog of gnb: ${local_file_path}

###########################################  gNB Operation  ################################################################
CB015532_Change_Parameter
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

CB015532_Change_UE_Capability
    [Arguments]  ${ue_capability}  ${ue_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability} capability_file=${CURDIR}/APCFG/ue_capability.cfg

CB015532_Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1

    ute_wtssim.Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}

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
    ...    pass_regexp=Initial Context Setup Successful
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
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

start_ue_ul_data_traffic
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

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

stop_ue_all_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop All Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id}

start_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${rtp_codec}=amr_12_2

    Log to Console  \nStart to establish UE-${ue_id} 5QI-5
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
    #   对于5QI-5/1的建立，必须加pass_regexp，否则会出错，原因待查！！！！！！！！！！！！！！！

    Log to Console  \nStart UE-${ue_id} ${rtp_codec} VoNR call
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=3 rtp_codec=${rtp_codec} dir=dl seconds=3600
    ...  pass_regexp=Started Downlink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu} Qfi:3
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=3 rtp_codec=${rtp_codec} dir=ul seconds=3600
    ...  pass_regexp=Started Uplink RTP Internal traffic over UDP on Ue:${ue_id}.*Pdu:${pdu} Qfi:3

release_ue_vonr_call
    [Arguments]  ${ue_id}=1  ${pdu}=1

    Log to Console  \nRelease UE-${ue_id} VoNR Call!
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=3 dir=dl
    # ...  pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}.*Pdu:${pdu} Qfi:3
    ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=3 dir=ul
    # ...  pass_regexp=Stopping Uplink Internal traffic on Ue:${ue_id}.*Pdu:${pdu} Qfi:3

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
    ...  cmd=amf_ue_pdu_modify_param ue=${ue_id} action=override_ie qos_flow_to_del_cause=NAS_normal_release
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=11 by=ue
    ...  pass_regexp=Ue ${ue_id} PduId ${pdu} Removed FiveQi:Qfi mapping fiveQi 5 qfi 2

CB015532_Get_UE_State
    [Arguments]    ${ue_id}
    ${ue_info}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ${ue_state}    Get Regexp Matches    ${ue_info}    state\\s+(\\S+)  1
    log to console  \n${ue_state}[0]
    [Return]    ${ue_state}[0]

CB015532_Get_UE_Location
    [Arguments]    ${ue_id}
    ${ue_info}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ${enb_id}    Get Regexp Matches    ${ue_info}    enb\\s+(\\d+)  1
    ${cell_id}   Get Regexp Matches    ${ue_info}    cell\\s+(\\d+)  1
    log to console  \nUE${ue_id} is located at eNB-${enb_id}[0] Cell-${cell_id}[0]
    [Return]    ${enb_id}[0]  ${cell_id}[0]