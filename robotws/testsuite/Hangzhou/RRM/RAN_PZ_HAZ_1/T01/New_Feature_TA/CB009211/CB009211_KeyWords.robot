*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This user scenario describes

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${counter}=     M55200C00005,M55142C00531   # MRO_EARLY_HO_RSRP_NB   MRO_EARLY_HO_RSRP

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

Case Postcondition
    log to console    Case Postcondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    ${cmd}    Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} Mbps=${traffic_rate}
    Airphone Execute Egate Command    cmd=${cmd}
    sleep    5s

Send A2 Measurement
    [Arguments]  ${ue_id}=1    ${carrier_freq}=628608
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${trigger}=rsrp
    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas
    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${carrier_freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}
    #Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}
    [Return]    ${meas_id}

Send A3 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=721    ${carrier_freq}=643008    ${pass_regexp}=${None}
    ${meas_id}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA3    carrier_freq=${carrier_freq}
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
    Log To Console    ${ue_id}
    Log To Console    ${cell_id}
    Log To Console    ${cause}
    Log To Console    ${pass_regexp}
    Log To Console    ${time}
    Log To Console    ${time}
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} action=invalid_short_mac_i
#    ...    \ send_after=measurement_report action=invalid_short_mac_i time_to_wait=${time}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

Trigger RRC Reestablish After Successful HO
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=otherFailure    ${time}=350
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=none
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    ...    \ send_after=measurement_report time_to_wait=${time}
    Airphone Execute Egate Command    cmd=${command}
    sleep    2s

Trigger RRC Reestablish
    [Arguments]    ${ue_id}=1    ${cell_id}=4    ${cause}=otherFailure
    Log To Console    ${cell_id}
    Airphone Execute Egate Command    cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=${ue_id} cause=${cause}

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
    [Arguments]     ${counter_list}
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: ${counter_list};
    ...         Counter rule: avg(${counter_list})>=1
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}

Multi UE Detach
   [Arguments]    ${ue_id}=1   ${num}=6
   sleep  5s
   FOR  ${ue_id}    IN RANGE    1    ${num}
        UE Deregister From gNB    ue_id=${ue_id}
   END

