*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes

#Library     ute_wtssim
#Library     String
#Library     OperatingSystem
#Library     Collections
#Library     ta5g_ue_measurements
#Library     taf.config.wts        WITH NAME    wts_conf

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${case_path}     /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB010559/config
*** Keywords ***
Case Precondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s

Config Eth Interface Internal
    [Arguments]    ${eth_config_path}
    ${context}    OperatingSystem.Get File    ${eth_config_path}
    ${eth_list}    json.Loads    ${context}
    ${eth_list_lenth}    Get Length    ${eth_list}
    FOR   ${index}    IN RANGE    ${eth_list_lenth}
        OperatingSystem.Run    ${eth_list[${index}]}
    END

Case Postcondition
    log to console    Case Postcondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    1s
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
    sleep    5s

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    ${cmd}    Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} Mbps=${traffic_rate}
    Airphone Execute Egate Command    cmd=${cmd}
    sleep    2s

Send A2 Measurement
    [Arguments]  ${ue_id}=1    ${carrier_freq}=628608   ${threshold}=67
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq}
    ...   threshold=${threshold}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${threshold}=10
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency   ${ue_id}
    ...    event_type=${event_type}   carrierfreq=${carrierfreq}    threshold=${threshold}
    #Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}
    [Return]    ${meas_id}

Get Measurement id without threshold
    [Arguments]  ${ue_id}=1   ${event_type}=A2  ${carrier_freq}=633216   ${carrierfreq_rat}=NR
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}
    ...    event_type=${event_type}   carrierfreq=${carrierfreq}   carrierfreq_rat=${carrierfreq_rat}
    [Return]     ${meas_id}

Send A3 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=721    ${carrier_freq}=643008    ${pass_regexp}=${None}
    ${meas_id}=    Get Measurement id without threshold    ue_id=${ue_id}    event_type=EventA3    carrier_freq=${carrier_freq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:20:59
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=Received HandoverNotify
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    100ms

Send A3 Measurement And Attempt Handover By RSRQ
    [Arguments]  ${ue_id}=1    ${phycell_id}=721    ${carrier_freq}=643008    ${pass_regexp}=${None}
    ${meas_id}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA3    carrier_freq=${carrier_freq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrq_nr=60 rs_type=ssb index=0 nrs_result=30:20:59
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=Received HandoverNotify
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    100ms

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   5s

Change UE${ue_id:\d+} Location To eNB${enb_id:\d+} Cell${cell_id:\d+}
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    sleep    3s

Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}


Stop Collect Wireshark For Cloud
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nWireshark log of VCU: ${local_file_path}
    Log To Console        \nWireshark log of VDU: ${local_file_path}

Trigger RRC Reestablish with cause
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=handoverFailure
    ${command} =  catenate   SEPARATOR=
    ...    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish
    ...    \ gnb=2 cell=${cell_id} cause=${cause} crnti=source
    Airphone Execute Egate Command    cmd=${command}
    sleep    2s

Trigger RRC Reestablish with invalid MAC-I
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=handoverFailure    ${pass_regexp}=${None}    ${time}=15
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} action=invalid_short_mac_i
#    ...    \ send_after=measurement_report action=invalid_short_mac_i time_to_wait=${time}
    Log to console    ${time}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

Trigger RRC Reestablish to other gNB
    [Arguments]    ${ue_id}=1  ${gnb}=4  ${cell_id}=1    ${cause}=handoverFailure    ${pass_regexp}=${None}    ${time}=15
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=${gnb} cell=${cell_id} cause=${cause}
    Log to console    ${time}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    15s

Configures path switch acknowledgement parameter AMF
    [Arguments]    ${amf_id}=1  ${ue_id}=1  ${action}=path_switch_failure  ${cause}=RN_invalid_qos_combination  ${pass_regexp}=${None}
    ${command} =  catenate   SEPARATOR=
    ...    amf_ue_path_switch_param id=${amf_id} ue=${ue_id} action=${action} cause=${cause}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

Configures ue retrieve failure parameter
    [Arguments]    ${gnb_id}=1  ${ue_id}=1  ${action}=send_retrieve_ue_ctxt_failure  ${cause}=no_radio_resources_available_in_target_cell
    ...   ${pass_regexp}=${None}
    ${command} =  catenate   SEPARATOR=
    ...    gnb_ue_retrieve_ue_context_resp_param gnb_id=${gnb_id} ue_id=${ue_id} action=${action} cause=${cause}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

Configures xn handover preparation response
#    [Arguments]    ${gnb_id}=1  ${action}=delayed_rsp  ${time_to_wait}=v20s
    [Arguments]    ${gnb_id}=1  ${action}=delayed_rsp
    ...   ${pass_regexp}=${None}
    ${command} =  catenate   SEPARATOR=
    ...    gnb_xn_handover_preparation_param id=${gnb_id} action=${action}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

Configures RRC Reconfiguration Complete
    [Arguments]    ${ue_id}=1   ${delay_time}=3000   ${contains}=any
#    [Arguments]    ${ue_id}=1   ${contains}=any  ${action}=drop
    ${cmd}    Catenate   ue_nr_rrc_reconf_param id=${ue_id} if_contains=${contains} delay=${delay_time}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}

Enable Disable XNHandover
    [Arguments]   ${handoverAllowedSA}=XnHoNotAllowed
    ...   ${mo_list_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4/NRREL-1    ${cudu_index}=${0}
     @{para_list}   Create List   handoverAllowedSA
     @{value_list}   Create List   ${handoverAllowedSA}
     @{mo_list}   Create List   ${mo_list_name}
     ${res}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
     ...      value_list=${value_list}   mo_list=${mo_list}   cudu_index=${cudu_index}

Disable XNhandover
     [Arguments]  ${delta_file_path}=${case_path}/config/handoverAllowedSA_XnHoNotAllowed.json
     Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Enable XNhandover
     [Arguments]  ${delta_file_path}=${case_path}/config/handoverAllowedSA_Allowed.json
     Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Set XN HO Report Parameter
    [Arguments]    ${ho_type}=HO_too_early    ${ho_cause}=handover_desirable_for_radio_reasons
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${command} =  catenate   SEPARATOR=
    ...    gnb_xn_ho_report_param t_gNB_id=3 s_gNB_id=2 ho_report_type=${ho_type} ho_cause=${ho_cause}
    ...    \ source_cell_cgi=311:489|4 target_cell_cgi=311:489|1
    Airphone Execute Egate Command    cmd=${command}
    sleep    2s

Trigger RRC Reestablish After Successful HO
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=otherFailure    ${time}=350
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=none
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    \ send_after=measurement_report time_to_wait=${time}
    Airphone Execute Egate Command    cmd=${command}
    sleep    2s

PDU Setup With 5QI5 and 5QI1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pass_regexp}=handled successfully
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    Airphone Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2
    Airphone Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}   timeout=10s

UE Register
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1   ${pass_regexp}=UE now in NG RM Registered state
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

PDU Modify to add DRB
    [Arguments]    ${ue_id}=1  ${pdu_id}=1  ${qosflows}=3  ${pass_regexp}=QosFlow
    Log To Console    ${ue_id}
    ${cmd}    Catenate   ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows} by=amf
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}   timeout=30s

PDU Setup to add DRB
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1  ${nwslice}=1   ${request_type}=initial-request
    ...    ${pass_regexp}=${None}
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw_id}  request_type=${request_type}
    Airphone Operation    send_common_command  gnb  cmd=${cmd}  pass_regexp=${pass_regexp}   timeout=30s

Trigger RRC Reestablish
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=otherFailure
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}

Set A3 Measurement Configuration
    [Arguments]    ${cell_id}=4    ${parameter}=a3MeasEnabled    ${value}=rsrq
    @{para_list}    Create List    ${parameter}
    @{mo_list}    Create List    ${cell_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Start Collect Mutli Counter
    [Arguments]    ${remove_counter_index}
    @{counter_list}    Create List
    FOR    ${index}    IN RANGE   ${20022}   ${20033}
        Append To List   ${counter_list}   M55350C${index}
    END
    ${rule_list}    Create List
    FOR    ${counter_id}    IN    @{counter_list}
    Continue For Loop If    "M55350C200${remove_counter_index}" == "${counter_id}"
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: ${counter_id};
    ...         Counter rule: avg(${counter_id})==0
    append to list  ${rule_list}    ${rule1}
    END
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55350C200${remove_counter_index};
    ...         Counter rule: avg(M55350C200${remove_counter_index})>=1
    append to list  ${rule_list}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu   bts_index=0

Start Collect Mutli Counter FOR DL
    [Arguments]    ${remove_counter_index}
    @{counter_list}    Create List
    FOR    ${index}    IN RANGE   ${20034}   ${20044}
        Append To List   ${counter_list}   M55350C${index}
    END
    ${rule_list}    Create List
    FOR    ${counter_id}    IN    @{counter_list}
    Continue For Loop If    "M55350C200${remove_counter_index}" == "${counter_id}"
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: ${counter_id};
    ...         Counter rule: avg(${counter_id})==0
    append to list  ${rule_list}    ${rule1}
    END
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55350C200${remove_counter_index};
    ...         Counter rule: avg(M55350C200${remove_counter_index})>=1
    append to list  ${rule_list}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu   bts_index=0

Start Collect Mutli Counter FOR DL-C
    [Arguments]    ${remove_counter_index}
    @{counter_list}    Create List
    FOR    ${index}    IN RANGE   ${2006}   ${20025}
        Append To List   ${counter_list}   M55310C${index}
    END
    ${rule_list}    Create List
    FOR    ${counter_id}    IN    @{counter_list}
    Continue For Loop If    "M55310C200${remove_counter_index}" == "${counter_id}"
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: ${counter_id};
    ...         Counter rule: avg(${counter_id})==0
    append to list  ${rule_list}    ${rule1}
    END
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55310C200${remove_counter_index};
    ...         Counter rule: avg(M55310C200${remove_counter_index})>=1
    append to list  ${rule_list}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu   bts_index=0

Start Collect Counter
    [Arguments]      ${counter_rule}=counter_rule.txt   ${bts_index}=1
    Log To Console      start counter collection time
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=${bts_index}
    ...                  counter_rule=${case_path}/config/${counter_rule}
    ...                  wait_for_next_counter_generate=${true}

Multi UE Detach
   [Arguments]    ${ue_id}=1   ${num}=6
   sleep  5s
   FOR  ${ue_id}    IN RANGE    1    ${num}
        UE Deregister From gNB    ue_id=${ue_id}
   END

Start Collect syslog
    [Arguments]    ${product_type}=vcu
    ${local_file_path}    Log Collection    start    syslog    product_type=${product_type}    bts_index=${0}    cudu_index=${0}
    Log To Console        \nSyslog log of VCU: ${local_file_path}

Start Emil Collect
#    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=vcu    bts_index=${0}    dict_argument=${dict_argument}

Stop Emil Collect
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=vcu    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}

Set Feature CB009211 Flag
    [Arguments]    ${product_type}=vcu    ${value}=true
    @{para_list}    Create List    actIntraNRMRO
    @{mo_list}    Create List    MRBTS-10872/NRBTS-10872
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=${product_type}
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Step1 Change PA
    Set PA Operation To Max
    PA Operation For 10872 Cell1

Set PA Operation To Max
    ${source_pa_port_list}     Create List     1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16
    ${source_pa_value_list}    Create List     0    127
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${127}    pa_type=16*16
    PA Operation    source=&{source}    target=none

PA Operation For 10872 Cell1
    ${source_pa_port_list}     Create List     7    8
    ${source_pa_value_list}    Create List     0    2
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*16
    PA Operation    source=&{source}    target=none

Step2 Attach UE and Start UDP Traffic
    Prepare UE0 And Attach UE0
    Start DL Call For UE0    Tput=20M

Step4 Trigger RRC Restablishment
    PA Operation For 10872 Cell2
    sleep    2

PA Operation For 10872 Cell2
    ${source_pa_port_list}     Create List     7    8
    ${source_pa_value_list}    Create List     0    127
    ${target_pa_port_list}     Create List    5    6
    ${target_pa_value_list}    Create List    127    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${127}    pa_type=16*16
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${127}    pa_type=16*16
    PA Operation    source=&{source}    target=&{target}

Common Case Postcondition For CB009211
    Run Keyword And Ignore Error    Stop UL Call For UE0
    Run Keyword And Ignore Error    Stop DL Call For UE0
    Common Case Postcondition

Common Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error  svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error  vDU Logout By Rest

    Run Keyword And Ignore Error    Case_Common_Resource.Detach UE0
    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
    ...                                                             conn=${conn}    timeout=${timeout}

Stop Collect Counter and verify PM counters
    [Arguments]      ${bts_index}=1   ${cudu_index}=0
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=${bts_index}
    ...   cudu_index=${cudu_index}
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Start DCAP logs
    [Arguments]     ${log_type}=emil    ${nrCells}=NRCELL_R-4   ${bts_index}=${0}
    ${dcap_argument}   Create Dictionary   nrCells=${nrCells}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start   log_type=${log_type}   product_type=vcu   bts_index=${bts_index}  dict_argument=${dict_argument}

Stop DCAP logs
    [Arguments]     ${log_type}=emil   ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    log_type=${log_type}    product_type=vcu    bts_index=${bts_index}

Start DCAP logs multi BTS
    [Arguments]     ${log_type}=muti_emil  ${nrCells_1}=NRCELL_R-4   ${nrCells_2}=NRCELL_R-1
    ${bts1_cell_argument}   Create Dictionary   nrCells=${nrCells_1}
    ${bts2_cell_argument}    Create Dictionary  nrCells=${nrCells_2}
    ${dict_argument}   Create Dictionary
    ...    dcap_server=${dcap_info}
    ...    bts1_cell_argument=${bts1_cell_argument}
    ...    bts2_cell_argument=${bts2_cell_argument}
    Log Collection    start   log_type=${log_type}   product_type=vcu   dict_argument=${dict_argument}

Stop DCAP logs multi BTS
    [Arguments]     ${log_type}=muti_emil
    ${local_file_path}    Log Collection    stop_and_download    log_type=${log_type}    product_type=vcu

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1  ${trace_ref_id}=1
    ...            ${trace_rec_session_ref_id}=1
    ...            ${trace_depth}=minimum
    ...            ${ifaces_to_trace}=Uu,NG-C,Xn-C,F1-C,E1
    ...            ${tce_ip}=10.56.197.7
    ...            ${trace_plmn}=311:489
    ${command} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on trace_plmn=${trace_plmn}
    ...           \ trace_ref_id=${trace_ref_id}
    ...           \ trace_rec_session_ref_id=${trace_rec_session_ref_id}
    ...           \ trace_depth=${trace_depth}
    ...           \ ifaces_to_trace=${ifaces_to_trace}
    ...           \ tce_ip=${tce_ip}
    Execute Egate Command      cmd=${command}

Trigger ICS With Trace Stop
    [Arguments]    ${ue_id}=1
    ${command_off} =  catenate   SEPARATOR=
    ...           amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=off
    Execute Egate Command    cmd=${command_off}