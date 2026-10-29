*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB012582-SR ET -A CRT and NFTA cases (Tester: Zhang Dacheng(NSB))
...   Topology: CLOUD_5G_I_MP_AP_LO or CLOUD_5G_I_[LO][LO]_AP_[LOO]

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common MultiBTS Suite Setup For RRM
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM

# Test Timeout       60 minutes

# *** Variables ***
# #Reduce global paramter as possilbe and automatically got from gNB or __init__
# ${cmd1}    ue_measurement_send_nr
# ...    id=1 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=50
# ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
# ${cmd2}    ue_measurement_send_nr
# ...    id=1 meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0 phycell_id=52
# ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}

# *** Test Cases ***
# CB012582_A_8_Xn based Inter-gNB HO Interruption time Target Range data forwarding ON
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether interruption time counter can be pegged as expectation in Xn HO.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_Xn_HO
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     # Interruption time duration is higher than uPlaneHoInterruptModRange
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00013;
#     ...    Counter rule: max(M55379C00013)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00014;
#     ...    Counter rule: max(M55379C00014)>0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00015;
#     ...    Counter rule: max(M55379C00015)>0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}     ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 1 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=Initial Context Setup Successful
#     sleep    3s
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Event A2 is triggered =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=19 phycell_id=52 nrsrp_nr=100
#     ...    pass_regexp=XN Handover Successfully completed at Target
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target AP cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
#     ...    pass_regexp=XN Handover Successfully completed at Source
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# CB012582_A_20_NG based Inter-gNB HO Interruption time Target Range data forwarding ON
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether interruption time counter can be pegged as expectation in NG HO.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_NG_HO
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     # Interruption time duration is higher than uPlaneHoInterruptModRange
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00016;
#     ...    Counter rule: max(M55379C00016)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00017;
#     ...    Counter rule: max(M55379C00017)==0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00018;
#     ...    Counter rule: max(M55379C00018)>1;
#     ${rule_list}    Create List    ${rule1}     ${rule2}     ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 1 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=Initial Context Setup Successful
#     sleep    3s
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Event A2 is triggered =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=19 phycell_id=52 nrsrp_nr=100
#     ...    pass_regexp=NG Handover successfully completed at Target
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target AP cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
#     ...    pass_regexp=NG Handover successfully completed at Source
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# CB012582_A_8_Xn based Inter-gNB HO VoNR Tunneling delay and Path Swith Delay
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether VoNR tunneling delay and path switch counter
#     ...    can be pegged as expectation in Xn HO.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_Xn_HO
#     ...    base_path=${CURDIR}/Airphone
#     # Interruption time duration is higher than uPlaneHoInterruptModRange
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00022;
#     ...    Counter rule: max(M55379C00022)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00023;
#     ...    Counter rule: max(M55379C00023)==0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00024;
#     ...    Counter rule: max(M55379C00024)>0;
#     ${rule4}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00028;
#     ...    Counter rule: max(M55379C00028)==0;
#     ${rule5}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00029;
#     ...    Counter rule: max(M55379C00029)>0;
#     ${rule6}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55379C00030;
#     ...    Counter rule: max(M55379C00030)==0;
#     ${rule_list}    Create List    ${rule1}     ${rule2}     ${rule3}    ${rule4}    ${rule5}    ${rule6}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 1 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=Initial Context Setup Successful
#     sleep    3s
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Event A2 is triggered =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=5 event=A3 srsrp_nr=19 phycell_id=52 nrsrp_nr=100
#     ...    pass_regexp=XN Handover Successfully completed at Target
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Start inter-gNB UE handover to target AP cell =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
#     ...    pass_regexp=XN Handover Successfully completed at Source
#     sleep    3s
#     Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# *** Keywords ***
# Counter Check CB012582
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}