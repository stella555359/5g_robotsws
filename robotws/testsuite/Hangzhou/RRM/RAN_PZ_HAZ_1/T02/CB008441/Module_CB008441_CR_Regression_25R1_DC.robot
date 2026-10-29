*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Library     ../../Resources/Classical/python/plibm/pkw_cb008441.py

Test Setup          Setup_for_CB008441_CR
Test Teardown       Teardown_for_CB008441_CR

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC

*** Variables ***
${bler_cmd_str1}    bler_testmode_nr profile_id=2 target_mcs=3
${bler_cmd_str2}    target_bler=100,100,100,98,95,90,50,10,5,1,0.5,0.1,0,0,0 mcs_table=qam256
${bler_cmd_str3}    delete=yes
${tcp_congestion_alg}    sudo sysctl -w net.ipv4.tcp_congestion_control=cubic

@{tcp_command_list}
...    iperf3 -c 10.12.2.2 -p 7070 -P1 -i1 -t2 -B 10.0.2.1
...    iperf3 -c 10.12.2.2 -p 7070 -P1 -i1 -t20 -B 10.0.2.1
...    iperf3 -c 10.12.2.2 -p 7070 -P10 -i1 -t2 -B 10.0.2.1
...    iperf3 -c 10.12.2.2 -p 7070 -P10 -i1 -t20 -B 10.0.2.1

${repeat_count}  10
${interval}  5

${ue_id_1}    51
${ue_id_2}    52

${trf_duration}  180
${tcp_command}  iperf3 -c 10.12.2.3 -p 7071 -P3 -i1 -t${trf_duration} -B 10.0.2.1

*** Test Cases ***
CB008441-CR-A_ET_Case01_PI2_Discard_TCP_Regular_Latency_SA
    [Documentation]
    ...    author:
    [Tags]    QC_32693

    FOR  ${tcp_command}  IN  @{tcp_command_list}

        Modify_CB008441_CoDel_Regular_Latency
        attach_ue_and_activate_pdu  ue_id=${ue_id_1}   trf_type=external
        log to console  \nPerform TCP download using "CoDel" Algorithm Started - ${tcp_command}!================
        ${result1}=  repeat_do_download_service_for_cb008441  need_attach=NO
        ...    repeat_count=${repeat_count}  interval=${interval}  tag=CoDel  command=${tcp_command}  use_ap=YES
        log to console  \nPerform TCP download using "CoDel" Algorithm Completed - ${tcp_command}!==============
        detach_ue_with_power_off  ue_id=${ue_id_1}

        Modify_CB008441_PI2_Regular_Latency
        attach_ue_and_activate_pdu  ue_id=${ue_id_1}   trf_type=external
        log to console  \nPerform TCP download using "PI2" Algorithm Started - ${tcp_command}!=================
        ${result2}=  repeat_do_download_service_for_cb008441  need_attach=NO
        ...    repeat_count=${repeat_count}  interval=${interval}  tag=PI2  command=${tcp_command}  use_ap=YES
        log to console  \nPerform TCP download using "PI2" Algorithm Completed - ${tcp_command}!===============
        detach_ue_with_power_off  ue_id=${ue_id_1}

        log to console  Start to compare "CoDel" and "PI2" results
        ${tput_diff}=  evaluate  abs(${result1}[0]-${result2}[0])/${result1}[0]*100
        ${rtt_diff}=  evaluate  abs(${result1}[2]-${result2}[2])/${result1}[2]*100
        #Should Be True  (${result1}[0]<=${result2}[0]) | (${tput_diff}<=20)
        #Should Be True  (${result1}[2]>=${result2}[2]) | (${rtt_diff}<=20)
    END
    show_summary

CB008441-CR-A_ST_Case01_Counter_PDCP_Discarted_SDUs_due_to_Delay_Based_Discarding_PI2
    [Documentation]
    ...    author: LAA
    [Tags]    QC_32694

    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-3;
    ...         Counter: M55350C00035;
    ...         Counter rule: sum(M55350C00035)
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1;
    ...         Counter: M55323C00006;
    ...         Counter rule: sum(M55323C00006)
    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1;
    ...         Counter: M55327C01006;
    ...         Counter rule: sum(M55327C01006)
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1;
    ...         Counter: M55320C20006,M55320C02006,M55320C04006,M55320C06006,M55320C09006;
    ...         Counter rule: sum(M55320C20006+M55320C02006+M55320C04006+M55320C06006+M55320C09006)
    ${rule5}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1;
    ...         Counter: M55319C12006;
    ...         Counter rule: sum(M55319C12006)
    ${rule6}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/MCC-311/MNC-489/SST-1/SD-13714341;
    ...         Counter: M55328C00006;
    ...         Counter rule: sum(M55328C00006)
    ${rule7}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/MCC-311/MNC-489/SST-1/SD-13714341;
    ...         Counter: M55328C00002;
    ...         Counter rule: sum(M55328C00002)
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    ...                            ${rule5}    ${rule6}    ${rule7}

    Modify_CB008441_PI2_Default

    # Wait for Counter Start
    log to console  \nWait for Current Counter Generated
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${TRUE}

    log to Console  \nPlan to perform TCP Download with PI2 Algorithm
    attach_ue_and_activate_pdu  ue_id=${ue_id_1}   trf_type=internal
    attach_ue_and_activate_pdu  ue_id=${ue_id_2}  trf_type=external
    log to console  \nDownlink Traffic with UE${ue_id_1}(UDP) and UE${ue_id_2}(TCP-IPerf3) Started!
    log to console  \nUE${ue_id_1} start to run trf_data_start ue=${ue_id_1} pdu=1 qfi=1 trf_id=1 mbps=10 dir=dl seconds=${trf_duration}
    ute_wtssim.execute_egate_command  cmd=trf_data_start ue=${ue_id_1} pdu=1 qfi=1 trf_id=1 mbps=15 dir=dl seconds=${trf_duration}
    ...    pass_regexp=UE${ue_id_1}: Started Downlink Internal traffic Receiver on Ue:${ue_id_1} Pdu:1 Qfi:1 TrfId:1
    log to console  \nUE${ue_id_2} Start to run - ${tcp_command}
    ${timeout}=  evaluate  ${trf_duration}
    run process  ${tcp_command}  timeout=${timeout}  shell=true  stdout=true  alias=tcp_dl
    ${output}=  get process result  tcp_dl  stdout=true
    log to console  \n${output}
    log to console  \nDownlink Traffic with UE${ue_id_1}(UDP) and UE${ue_id_2}(TCP-IPerf3) Completed!
    detach_ue_with_power_off  ue_id=${ue_id_1}
    detach_ue_with_power_off  ue_id=${ue_id_2}

    # Wait for Counter End
    log to console  \nWait for New Counter Generated
    ${result}  Counter Operation  operation=collect_counter_and_calculate
    ...                           product_type=vcu    bts_index=0    cudu_index=0
    log to console  \n${result}
    ${pi2_pdcp_discard_num}  Set Variable  ${result}[check_result][${rule1}]
    ${f1u_pdcp_number}  Set Variable  ${result}[check_result][${rule2}]
    ${total_pdcp_sdu_num}  Set Variable  ${result}[check_result][${rule3}]
    ${total_pdcp_discard_num_exclude_pi2}  Set Variable  ${result}[check_result][${rule4}]
    ${total_pdcp_discard_num_include_pi2}  evaluate  ${total_pdcp_discard_num_exclude_pi2}+${pi2_pdcp_discard_num}
    log to console  \nPDCP discard SDU due to PI2: ${pi2_pdcp_discard_num}
    log to console  \nPDCP PDU number sent over F1-U: ${f1u_pdcp_number}
    log to console  \nPDCP SDU number received over NR NG-U DL GTP-U: ${total_pdcp_sdu_num}
    log to console  \nPDCP discard SDU total number excluded pi2: ${total_pdcp_discard_num_exclude_pi2}
    log to console  \nPDCP discard SDU total number included pi2: ${total_pdcp_discard_num_include_pi2}
    ${discard_ratio_exclude_pi2}  evaluate  ${total_pdcp_discard_num_exclude_pi2}/${total_pdcp_sdu_num}*100
    ${discard_ratio_include_pi2}  evaluate  ${total_pdcp_discard_num_include_pi2}/${total_pdcp_sdu_num}*100
    ${throughput}  evaluate  8*${result}[check_result][${rule5}]/${trf_duration}
    ${delay}   evaluate  ${result}[check_result][${rule6}]/${result}[check_result][${rule7}]/1000
    log to console  \nPDCP discard ratio exclude PI2: ${discard_ratio_exclude_pi2}%
    log to console  \nPDCP discard ratio include PI2: ${discard_ratio_include_pi2}%
    log to console  \nPDCP Throughput: ${throughput}kbps
    log to console  \nPDCP Delay: ${delay}ms

    Should Be True  ${pi2_pdcp_discard_num}>0
    #Should Be True  ${total_pdcp_discard_num_include_pi2}+${f1u_pdcp_number}==${total_pdcp_sdu_num}


*** Keywords ***
Modify_CB008441_Parameters
    [Arguments]    ${product_type}  ${para_list}  ${mo_list}  ${value_list}

    Log To Console  \n Before Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

    Log To Console  \n After Online Change
    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}    timeout=${180}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}    timeout=${120}
    Log To Console    \nGNB Parameter Check Result: ${out}

Modify_CB008441_CoDel_Regular_Latency
    @{para_list}      Create List    queuingDelayDiscarding  queuingDelaySduDiscardThreshold
    ...                              sduDiscardIntervalTmr  numSduDiscard  discardTimer
    @{mo_list}        Create List    MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    ...                              MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    ...                              MRBTS-1/NRBTS-1/NRDRB-11
    @{value_list}     Create List    Controlled Delay (CoDel)  750  500  1  infinity
    Modify_CB008441_Parameters  product_type=vcu  para_list=@{para_list}
    ...                         mo_list=@{mo_list}  value_list=@{value_list}

Modify_CB008441_PI2_Regular_Latency
    @{para_list}      Create List    queuingDelayDiscarding  pi2TargetDelay
    ...                              pi2TargetSize  discardTimer
    @{mo_list}        Create List    MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    ...                              MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    @{value_list}     Create List    PI2  600  500  infinity
    Modify_CB008441_Parameters  product_type=vcu  para_list=@{para_list}
    ...                         mo_list=@{mo_list}  value_list=@{value_list}

Modify_CB008441_PI2_Default
    @{para_list}      Create List    queuingDelayDiscarding  pi2TargetDelay
    ...                              pi2TargetSize  discardTimer
    @{mo_list}        Create List    MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    ...                              MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRDRB-11
    @{value_list}     Create List    PI2  1200  500  1500ms
    Modify_CB008441_Parameters  product_type=vcu  para_list=@{para_list}
    ...                         mo_list=@{mo_list}  value_list=@{value_list}

Setup_for_CB008441_CR
    # run    sudo mv /opt/iphy /opt/iphy_old
    # run    sudo cp -r /opt/wts /opt/iphy
    # run    sudo chown -R ute:ute /opt/iphy

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
    ...                   product_type=vcu
    ...                   traffic_info_dic=${None}
    ...                   tag=25r1_dc
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=600s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu_dc
    ...                   traffic_info_dic=${None}
    ...                   tag=25r1_dc
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s


    @{vcu_para_list}      Create List    drbInactivityTimerSA  actServiceAwarePDCPConfig
    ...                                  queuingDelayDiscardStart  miNrPDCPCell
    @{vcu_mo_list}        Create List    MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    ...                                  MRBTS-1/NRBTS-1/NRDRB-11  MRBTS-1/NRBTS-1/NRPMRNL-1
    @{vcu_value_list}     Create List    3600  true  1  5min
    Modify_CB008441_Parameters  para_list=@{vcu_para_list}  mo_list=@{vcu_mo_list}
    ...                         value_list=@{vcu_value_list}  product_type=vcu

    @{vdu_para_list}      Create List    actServiceAwarePDCPConfig
    @{vdu_mo_list}        Create List    MRBTS-1/NRBTS-1
    @{vdu_value_list}     Create List    true
    Modify_CB008441_Parameters  para_list=@{vdu_para_list}  mo_list=@{vdu_mo_list}
    ...                         value_list=@{vdu_value_list}  product_type=vdu

    ${bler_test_cmd}    Catenate    ${bler_cmd_str1}    ${bler_cmd_str2}
    log to console  \nset bler test mode: ${bler_test_cmd}
    ute_wtssim.Execute Egate Command  cmd=${bler_test_cmd}
    ute_wtssim.Execute Egate Command  cmd=ue_testmode_set_nr id=51 testmode=bler action=activate profile_id=2
    ute_wtssim.Execute Egate Command  cmd=ue_testmode_set_nr id=52 testmode=bler action=activate profile_id=2
    run process  ${tcp_congestion_alg}  shell=true  alias=tcp_congestion_alg
    ${output}=  get process result  tcp_congestion_alg
    log to console  \n${output.stdout}

    Prepare iperf3

Teardown_for_CB008441_CR
    run  sudo pkill iperf3

    ${bler_test_cmd}    Catenate    ${bler_cmd_str1}    ${bler_cmd_str2}    ${bler_cmd_str3}
    log to console  \ndelete bler test mode: ${bler_test_cmd}
    ute_wtssim.Execute Egate Command  cmd=${bler_test_cmd}

Prepare iperf3
    run  sudo pkill iperf3
    run  iperf3 -s -D -p 7070 -B 10.0.2.1
    run  iperf3 -s -D -p 7071 -B 10.0.2.1

attach_ue_and_activate_pdu
    [Arguments]  ${ue_id}=1  ${pdu_id}=1  ${trf_type}=internal  ${max_retry_number}=3
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    FOR  ${num}  IN RANGE  ${max_retry_number}
        log to console  \nTry to attach UE${ue_id} ${num} time
        ${status}  run keyword and return status
        ...    ute_wtssim.Execute Egate Command
        ...    cmd=ue_register id=${ue_id}
        ...    pass_regexp=REGISTRATION COMPLETE
        run keyword if  ${status}==True  Exit For Loop
    END
    run keyword if  ${status}==False
    ...    log to console  UE ${ue_id} REGISTRATION FAILURE for ${max_retry_number} times
    ...    ELSE  log to console  \nUE${ue_id} Registration Success
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
    ...    pass_regexp=Initial Context Setup Successful

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ...    pass_regexp=UE${ue_id}: detached
    log to console  \nUE${ue_id} Detached!
