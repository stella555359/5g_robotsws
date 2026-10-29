*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   Description: This is CB011065-SR-B ET CRT in TMO configuration
...   Topology: CLOUD_5G_I_LOO_AP_LOOO

Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/common_resource.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       90 minutes

*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__
#${DEBUG_MODE}            ${TRUE}
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB011065-SR-B_03_NGAP Path Switch Failure during Xn HO
    [Documentation]
    ...    author: Sijia Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to check NG_PATH_SWITCH_FAIL_TIMER_EXP counter increments when NGAP PathSwitchRequestAcknowledge is not received
    ...    and NRBTS.timerNGSignalingConnGuard expires during inter-gNB Xn HO.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_B_TMO
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    Start tcpdump by command For Remote
    Counter Collection M55209C00014 for Xn Handover
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=6
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=XN Handover Successfully completed at Target
    sleep    15s
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
        Log To Console      ${\n}============= no path_switch ackknowledge =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_path_switch_param id\=1 ue\=1 action\=delay_path_switch_req_ack time_to_wait\=180000
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start inter-gNB UE handover to target AP cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=19 phycell_id\=51 nrsrp_nr\=100
    ...    pass_regexp=Unexpected timeout in UE CONTEXT RELEASE
    sleep    3s
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB011065

CB011065-SR-B_07_Incoming Inter RAT HO
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_B_TMO
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    Start tcpdump by command For Remote
    Counter Collection CB011065-B-07-IRAT
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=6
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger B2 Measurement Report and handover to LTE =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=10 event\=B2 phycell_id\=11 nrsrp_nr\=19 nrsrq_nr\=17
    ...    pass_regexp=IRAT Handover from NR to EUTRA completed
    sleep    2s
    Log To Console      ${\n}============= Trigger Handover back to 5G CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_request_ack_param id\=1 ue\=1 action\=send_alternate_response msg\=ng_ue_ctx_release_cmd
    ...    pass_regexp=${None}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_trigger_inter_rat_handover_to_5g ue\=1 target_gnb\=2 target_cell\=1 plmn\=310:260
    ...    pass_regexp=${None}
    sleep    5s
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_param id\=1 release_old_ue_context\=on
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB011065

*** Keywords ***
Counter Collection M55209C00013 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: sum(M55209C00013)==1;
    # ${rule2}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00014;
    # ...    Counter rule: sum(M55379C00014)==0;
    # ${rule3}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00015;
    # ...    Counter rule: sum(M55379C00015)==2;
    # ${rule4}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00022;
    # ...    Counter rule: sum(M55379C00022)==0;
    # ${rule5}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00023;
    # ...    Counter rule: sum(M55379C00023)==0;
    # ${rule6}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00024;
    # ...    Counter rule: sum(M55379C00024)>0;
    # ${rule7}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00028;
    # ...    Counter rule: sum(M55379C00028)>0;
    # ${rule8}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00029;
    # ...    Counter rule: sum(M55379C00029)==0;
    # ${rule9}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    # ...    Counter: M55379C00030;
    # ...    Counter rule: sum(M55379C00030)==0;
    ${rule_list}    Create List    ${rule1}
    # ...    ${rule2}     ${rule3}    ${rule4}    ${rule5}    ${rule6}
    # ...    ${rule7}    ${rule8}    ${rule9}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Collection M55209C00014 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: sum(M55209C00013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00014;
    ...    Counter rule: sum(M55209C00014)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    # ...    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    # ...    ${rule7}    ${rule8}    ${rule9}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Collection M55209C00015 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: sum(M55209C00013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00015;
    ...    Counter rule: sum(M55209C00015)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00016;
    ...    Counter rule: sum(M55209C00016)==0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Collection M55209C00016 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: sum(M55209C00013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00016;
    ...    Counter rule: sum(M55209C00016)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Collection M55209C00017 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00013;
    ...    Counter rule: sum(M55209C00013)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00017;
    ...    Counter rule: sum(M55209C00017)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Collection M55147C00040 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55147C00040;
    ...    Counter rule: sum(M55147C00040)==1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Collection M55143C00037 for Xn Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55143C00037;
    ...    Counter rule: sum(M55143C00037)==1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Check CB011065
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}
Start Capture Emil Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    ${local_file_path}    Log Collection    stop_and_download    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}

Case Precondition
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
    ...                   tag=D_IRAT
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1800s
Counter Collection CB011065-B-07-IRAT
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55209C00017;
    ...    Counter rule: sum(M55209C00017)==1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
ATTACH UE1
    Log To Console      ${\n}============= Start to Attach the UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
Start DL Traffic on UE
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
Trigger Xn Handover to GNB-2
    Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger A3 Measurement Report and handover to CELL-5 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A3 srsrp_nr\=19 phycell_id\=54 nrsrp_nr\=100
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to EXT_ENB-3.5 performed
    sleep    3s
Trigger inter-RAT Handover to LTE
    Log To Console      ${\n}============= Trigger A2 Measurement Report on CELL-5 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=8 event\=A2 srsrp_nr\=11 srsrq_nr\=11 srs_result\=0:11:11:0
    ...    pass_regexp=${None}
    sleep    1s
    Log To Console      ${\n}============= Trigger B2 Measurement Report and handover to LTE =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=14 event\=B2 phycell_id\=11 nrsrp_nr\=19 nrsrq_nr\=17
    ...    pass_regexp=IRAT Handover from NR to EUTRA completed
    sleep    2s

Trigger inter-RAT Handover back to 5G
    Log To Console      ${\n}============= Trigger Handover back to 5G CELL-1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_trigger_inter_rat_handover_to_5g ue\=1 target_gnb\=2 target_cell\=1 plmn\=311:489
    ...    pass_regexp=Inter-eNB handover
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_param id\=1 release_old_ue_context\=on
    sleep    2s
    Log To Console      ${\n}============= Handover is done, wait for counter update =============${\n}
    sleep    5 min    reason=wait for counter ready