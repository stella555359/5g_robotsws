*** Settings ***
Documentation
...   Author: jinying.guo@nokia.com
...   Contact: jinying.guo@nokia.com
...   Description: This user scenario describes

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


*** Variables ***
${13367_cell1_distname}    MRBTS-1/NRBTS-1/NRCELL-1
${target_counter_B12}     M55143C00018,M55143C00005,M55143C00006
${target_counter_rule_B12}     max(M55143C00018)==1 and max(M55143C00005)==2 and max(M55143C00006)==1
${target_counter_B10}      M55143C00023,M55153C00003
${target_counter_rule_B10}     max(M55143C00023)==1 and max(M55153C00003)==1




${TL10872_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB014583/APCFG/wts_cloud.cfg

*** Test Cases ***
CB013367-B#B12_Successful Inter-gNB SA handover preparation via Xn at target gNB during MEDIUM
    [Tags]    QC_178139    QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Run Keywords    Case Precondition
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55143C00018;
    ...         Counter rule: max(M55143C00018)>=1
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55143C00005;
    ...         Counter rule: max(M55143C00005)>=2
    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55143C00006;
    ...         Counter rule: max(M55143C00006)>=1
    @{rule_list}    create list    ${rule1}    ${rule2}    ${rule3}
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    @{para_list}          Create List    actBadUlRadioHoRej
    @{value_list}         Create List    disabled
    @{mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}
    ${cmd_rim_alarm}    Catenate    SEPARATOR=    remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of
    ...  _symbols=32 noise_power_values=-55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,-115,
    ...  -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
    Airphone Execute Egate Command    cmd=${cmd_rim_alarm}
    ${cmd}    Catenate   cell_testmode_set_nr cell_id=1 gnb=2 testmode=remote_interference profile_id=7 action=activate
    Airphone Execute Egate Command    cmd=${cmd}
#    sleep    900s
    wait until keyword succeeds   30min  180s     Check expect alarm
    SA Handover Excution for B12
    Stop Collect Counter and verify PM counters
    [Teardown]    Case Postcondition

CB013367-B#B10_Xn based Inter-gNB SA handover preparation failure at target gNB during MEDIUM
    [Tags]    QC_178141    QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Run Keywords    Case Precondition
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55143C00023;
    ...         Counter rule: max(M55143C00023)>=1
#    ${rule2}    Catenate
#    ...         Distname: All;
#    ...         Counter: M55153C00003;
#    ...         Counter rule: max(M55153C00003)>=1
    @{rule_list}    create list    ${rule1}
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}
    UE Deregister From gNB      ue_id=1
    SA Handover Excution for B10
    sleep    50s
    Stop Collect Counter and verify PM counters
    [Teardown]    Case Postcondition

[1][1.0] CB013367-A#10 Feature activated and deactived
    [Tags]    QC_178145   QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Run Keywords    Case Precondition
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...         Counter: M55177C00037;
    ...         Counter rule: max(M55177C00037)>=1
    @{rule_list_1}    create list    ${rule1}
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...         Counter: M55177C00037;
    ...         Counter rule: max(M55177C00037)<=0
    ${rule3}    Catenate
    ...         Distname: All;
    ...         Counter: M55153C00002;
    ...         Counter rule: max(M55153C00002)>=1
    @{rule_list_2}    create list    ${rule2}
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    @{para_list}          Create List    actBadUlRadioHoRej
    @{value_list}         Create List    disabled
    @{mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list_1}
    ...                  wait_for_next_counter_generate=${true}
    ${cmd_rim_alarm}    Catenate    SEPARATOR=    remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of
    ...  _symbols=32 noise_power_values=-55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,-115,
    ...  -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
    Airphone Execute Egate Command    cmd=${cmd_rim_alarm}
    ${cmd}    Catenate   cell_testmode_set_nr cell_id=1 gnb=2 testmode=remote_interference profile_id=7 action=activate
    Airphone Execute Egate Command    cmd=${cmd}
#    sleep    900s
    wait until keyword succeeds   30min  180s     Check expect alarm
    SA Handover Excution for A10
    Stop Collect Counter and verify PM counters
    sleep    10s
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list_2}
    ...                  wait_for_next_counter_generate=${true}
    ${res}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=${para_list}    value_list=${value_list}    mo_list=${mo_list}
    Log To Console        VDU paramter update result: ${res}
    sleep    300s
    SA Handover Excution for A10
    Stop Collect Counter and verify PM counters
    [Teardown]    Case Postcondition


*** Keywords ***
SA Handover Excution for B12
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    1s
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=48 nrsrp_nr=45
    sleep    5s
    Airphone Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=50 nrsrp_nr=45
    sleep    5s
    Airphone Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=50 nrsrp_nr=55
    sleep    5s
    UE Deregister From gNB      ue_id=${ue_id}

Check expect alarm
    &{expected_alarms}        Create Dictionary    fault_id=7525    fault_name=Remote interference detected
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    fault_id=4001    fault_name=BTS reset required
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}

    ${res}    Alarm Operation    operation=check_active_alarms    product_type=vdu    bts_index=0    cudu_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}
    should be true    "${res['flag_expect_alarm']}"=="${True}"

SA Handover Excution for A10
    [Arguments]    ${ue_id}=2    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    1s
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command   cmd=ue_measurement_send_nr id=2 meas_id=1 event=A3 srsrp_nr=15 phycell_id=50 nrsrp_nr=45
    sleep    5s
    UE Deregister From gNB      ue_id=${ue_id}

_Set Iphy Ip
  [Documentation]  Distinguish general or multi cpif deployment
  Log To Console  \n===configure IPs on PC ===
#  OperatingSystem.Run  sudo ip addr add 10.0.2.121/24 dev eth4  #compatible with other team's lua
#  OperatingSystem.Run  sudo ip addr add 10.0.2.1/24 dev eth4  #already configured in AiC TL
  _Set Iphy X2 Ip Eth3 General
  Log  proxy server ip is 10.0.2.80  console=yes
  Log  10.0.2.90~93 is configured for more proxy servers  console=yes
  FOR  ${number}  IN RANGE  90  94
    OperatingSystem.Run  sudo ip addr add 10.0.2.${number}/24 dev eth4
  END
  _Set Iphy Ng Ip Eth7 General
  _Set Iphy Xn Ip Eth8 General
  OperatingSystem.Run  ip addr show eth3
  OperatingSystem.Run  ip addr show eth4
  OperatingSystem.Run  ip addr show eth7
  OperatingSystem.Run  ip addr show eth8


_Set Iphy X2 Ip Eth3 General
  Log  10.0.1.10,10.0.1.210,10.0.1.60 is reserved for real gNB2-X2c/X2u/S1-u within AiC deployment
  Log  10.0.1.131~137 is reserved for sim-MME/SGW/eNB-1
  Log  10.0.1.138~152 is configured for you to set more sim-(MME/sGW/eNB-x2/gNB-x2)  console=yes
  _Set Eth3 Ip

_Set Eth3 Ip
  FOR  ${number}  IN RANGE  131  153
    OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
  END

_Set Iphy Ng Ip Eth7 General
  Log  AMF ip is 10.0.11.1  console=yes
  Log  10.0.11.10,10.0.11.210 is reserved for real gNB2-NG-c/u within AiC deployment
  Log  10.0.11.2~9 is configured for you to set more AMFs  console=yes
  Log  10.0.11.11~30 is configured for you to set more sim-GNB-NGc/u  console=yes
  _Set Eth7 Ip

_Set Eth7 Ip
  FOR  ${number}  IN RANGE  2  10
    OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
  END
  FOR  ${number}  IN RANGE  11  31
    OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
  END

_Set Iphy Xn Ip Eth8 General
  Log  10.0.12.10,10.0.12.210 is reserved for real gNB2-Xnc/Xnu within AiC deployment
  Log  10.0.12.1~9 is pre-reserved
  Log  10.0.12.11~30 is configured for you to set more sim-GNB-Xnc/u  console=yes
  _Set Eth8 Ip

_Set Eth8 Ip
  FOR  ${number}  IN RANGE  11  31
    OperatingSystem.Run  sudo ip addr add 10.0.12.${number}/24 dev eth8
  END





UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   5

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

Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Start Collect syslog
    [Arguments]    ${product_type}=vcu
    ${local_file_path}    Log Collection    start    syslog    product_type=${product_type}    bts_index=${0}    cudu_index=${0}
    Log To Console        \nSyslog log of VCU: ${local_file_path}

Stop Collect Counter and verify PM counters
    Log To Console     \nStart to stop collect counter and verify PM counters
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}



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
    _Set Iphy Ip
#    OperatingSystem.Run    sudo iptables -F
#    OperatingSystem.Run    sudo ip addr add 10.0.11.2/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.11.1/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.12.11/32 dev eth3

    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s

Case Postcondition
    log to console    Case Postcondition
#    OperatingSystem.Run    sudo ip addr del 10.0.11.2/32 dev eth3
#    OperatingSystem.Run    sudo ip addr del 10.0.11.1/32 dev eth3
#    OperatingSystem.Run    sudo ip addr del 10.0.12.11/32 dev eth3
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

SA Handover Excution for B10
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    1s
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command   cmd=gnb_xn_handover_preparation_param id=3 action=force_failure cause=o_and_M_intervention
    sleep    5s
    Airphone Execute Egate Command   ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=48 nrsrp_nr=45


#SA Handover Excution for B12
#    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
#    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
#    sleep    2s
#    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
#    sleep    1s
#    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
#    sleep    5s
#    Airphone Execute Egate Command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=15 phycell_id=48 nrsrp_nr=45
#    sleep    5s
#    Airphone Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=50 nrsrp_nr=45
#    sleep    5s
#    Airphone Execute Egate Command   cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=15 phycell_id=50 nrsrp_nr=55
#    sleep    5s
#    Airphone Execute Egate Command   cmd=ue_deregister id=1 ue_deregister_type=switch_off
