*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB012582-SR ET -D CRT and NFTA cases (Tester: Zhang Dacheng(NSB))
...   Topology: CLOUD_5G_I_MP_AP_LO

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

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}

# *** Test Cases ***
# CB012582_D_RRC reestablishment fails for a VoNR call with invalid shortMAC-I
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether RRE fallback counter can be pegged as expectation RRE failure scenario.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_RRE
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55124C09016;
#     ...    Counter rule: max(M55124C09016)==0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55124C00502;
#     ...    Counter rule: max(M55124C00502)>0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
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
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    10s
#     Log To Console      ${\n}============= Start to trigger RRE failure due to invalid short MAC-I =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=1 cause\=reconfigurationFailure action\=invalid_short_mac_i
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# CB012582_D_QosFlow Setup Fail due to ongoing Inter-gNB HO Xn handover
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether QoS setup will be rejected during handover process.
#     ...    And counter should be pegged as expection.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_Xn_HO
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C13077;
#     ...    Counter rule: max(M55125C13077)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C03505;
#     ...    Counter rule: max(M55125C03505)>0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-3;
#     ...    Counter: M55163C03015;
#     ...    Counter rule: max(M55163C03015)>0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set gNBsim response for Handover request with delay =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=delayed_rsp time_to_wait\=v20s
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_xn_status_transfer_param id\=3 action\=delayed_rsp time_to_wait\=v20s
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
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to trigger inter-gNB Handover and add 5QI-7 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A3 srsrp_nr\=19 phycell_id\=52 nrsrp_nr\=100
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=13 by\=ue
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# CB012582_D_QosFlow Setup Fail due to ongoing Inter-gNB HO NG handover
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether QoS setup will be rejected during handover process.
#     ...    And counter should be pegged as expection.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_NG_HO
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C13077;
#     ...    Counter rule: max(M55125C13077)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55125C03505;
#     ...    Counter rule: max(M55125C03505)>0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-5;
#     ...    Counter: M55163C03015;
#     ...    Counter rule: max(M55163C03015)>0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set gNBsim sending PDU session resource modification in HO =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=amf_ue_ng_handover_param id\=1 action\=send_concurrent_msg msg\=ng_pdu_session_modification
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
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to trigger inter-gNB Handover and add 5QI-7 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=5 event\=A3 srsrp_nr\=19 phycell_id\=52 nrsrp_nr\=100
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# CB012582_D_RRC reestablishment fails for a VoNR call during inter-gNB Xn handover
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether RRE fallback counter can be pegged as expectation RRE failure scenario.
#     ...    Counter Update cannot be always triggered because order of gNB retrieves UE context and decides to fallback
#     ...    cannot be determined in the process.
#     ...    When UE context retrival is before deciding to fallback, then this counter M55124C09016 will be updated.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_RRE_2
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55124C09016;
#     ...    Counter rule: max(M55124C09016)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55124C00502;
#     ...    Counter rule: max(M55124C00502)>0;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Change UE location to gNB-3 cell-1 =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_change_location id\=1 enb\=3 cell\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Modify gNB-3 configuration =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_cell_param id\=1 gnb\=3 enable_anr\=on neighbor_pci\=16:2
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_param id\=3 ciphering_algorithm\=nea0 integrityprotection_algorithm\=nia2
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_xn_handover_preparation_param id\=3 include_security_config\=true sec_config_nea\=nea0 sec_config_nia\=nia2
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_xn_handover_preparation_param id\=3 reestab_info\=1:valid
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=gnb_param id\=3 delay_proc_measurement_report\=v1s
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
#     ...    pass_regexp=${None}
#     sleep    1s
#     Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
#     ...    pass_regexp=${None}
#     sleep    1s
#     Log To Console      ${\n}============= Start to Attach the UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=UE NGAP ID 1 is now Registered
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=setup/reestablishment complete
#     sleep    3s
#     Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=5
#     ...    pass_regexp=${None}
#     sleep    5s
#     Log To Console      ${\n}============= Let UE send RRE request after measurement report =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=handoverFailure send_after=measurement_report time_to_wait=972ms
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start to trigger inter-gNB Xn Handover =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
#     ...    pass_regexp=Unsuccessful outcome for XnAP::HandoverPreparation is received. Handover canceled.
#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# *** Keywords ***
# Counter Check CB012582
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}