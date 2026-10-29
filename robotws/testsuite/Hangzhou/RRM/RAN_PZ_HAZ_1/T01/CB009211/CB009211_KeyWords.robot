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

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${10872_cell4_distname}=    MRBTS-10872/NRBTS-10872/NRCELL-4
${MRO_PING_PONG_counter}=     M55142C00535
${MRO_PING_PONG_counter_rule}=    max(M55142C00535)==1
${MRO_WRONG_counter}=     M55142C00533
${MRO_WRONG_counter_rule}=    max(M55142C00533)==1
${MRO_WRONG_counter_rule1}=    max(M55142C00533)==0
${MRO_EARLY_counter}=     M55142C00531,M55142C00532
${MRO_LATE_EXEC_counter}=     M55142C00529,M55142C00530
${MRO_LATE_MEAS_counter}=     M55142C00527,M55142C00528
${MRO_EARLY_counter_rule}=     max(M55142C00531)==0 and max(M55142C00532)==0
${MRO_EARLY_counter_rule1}=     max(M55142C00531)==1 and max(M55142C00532)==0
${MRO_LATE_EXEC_counter_rule}=    max(M55142C00529)==1 and max(M55142C00530)==0
${MRO_LATE_EXEC_counter_rule2}=    max(M55142C00529)==0 and max(M55142C00530)==0
${MRO_LATE_EXEC_counter_rule3}=    max(M55142C00529)==0 and max(M55142C00530)==1
${MRO_LATE_MEAS_counter_rule}=    max(M55142C00527)==1 and max(M55142C00528)==0
${MRO_LATE_MEAS_counter_rule2}=    max(M55142C00527)==0 and max(M55142C00528)==1
${MRO_LATE_MEAS_counter_rule3}=    max(M55142C00527)==0 and max(M55142C00528)==0
*** Keywords ***
Case Precondition
    OperatingSystem.Run    sudo iptables -F
    OperatingSystem.Run    sudo ip addr add 10.97.65.253/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.252/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.254/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/32 dev eth3
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
#    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${command} =  catenate   SEPARATOR=
    ...    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} action=invalid_short_mac_i
#    ...    \ send_after=measurement_report action=invalid_short_mac_i time_to_wait=${time}
    Log to console    ${time}
    Airphone Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}
    sleep    2s

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
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}
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

Start Email Collect
#    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil    product_type=vcu    bts_index=${0}    dict_argument=${dict_argument}

Stop Email Collect
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
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}