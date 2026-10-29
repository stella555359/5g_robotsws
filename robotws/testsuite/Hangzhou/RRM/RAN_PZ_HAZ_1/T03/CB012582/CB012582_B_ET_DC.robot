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
# ${cmd1}    trf_data_start
# ...    ue=1 pdu=1 qfi=2 dir=dl trf_id=2 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1
# ...    rtp_sn_skip_count=9 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=10
# ${cmd2}    trf_data_start
# ...    ue=1 pdu=1 qfi=2 dir=ul trf_id=1 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1
# ...    rtp_sn_skip_count=9 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=10

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}

# *** Test Cases ***
# CB012582-B_UE view mute for VoNR with witnessed VoNR DL backhaul mute
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Topology: CLOUD_5G_I_MP_AP_LO
#     ...    Description:
#     ...    This case aims to monitor whether UE view VoNR muting counter can be pegged as expectation.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B_Muting
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55350C20049;
#     ...    Counter rule: sum(M55350C20049)==1;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55350C20048;
#     ...    Counter rule: sum(M55350C20048)==1;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
#     ...    Counter: M55350C20048;
#     ...    Counter rule: sum(M55350C20048)==1;
#     ${rule4}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
#     ...    Counter: M55350C20049;
#     ...    Counter rule: sum(M55350C20049)==1;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Config DL Air Interface Muting Testmode Profile =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=bler_testmode_nr profile_id\=1 vonr_lcid\=5 num_vonr_mac_sdus_to_drop\=50 arg_mute_duration_in_slots\=850
#     ...    pass_regexp=${None}
#     sleep    2s
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
#     Log To Console      ${\n}============= Trigger DL Air Interface Muting on cell-1 =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl trf_id=1 mbps\=10
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_testmode_set_nr id\=1 profile_id\=1 testmode\=bler scell\=0 action\=activate
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for 1st round counter on cell-1 =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_testmode_set_nr id\=1 profile_id\=1 testmode\=bler scell\=0 action\=deactivate
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger DL backhaul muting on cell-1 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for 2nd round counter on cell-1 =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Stop all traffic on UE =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=trf_data_stop ue\=1 pdu\=all
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Trigger intra-gNB intra-freq HO to cell-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_measurement_send_nr id\=1 meas_id\=2 event\=A3 srsrp_nr\=19 phycell_id\=51 nrsrp_nr\=100
#     ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#     sleep    3s
#     Log To Console      ${\n}============= Trigger UL Air Interface Muting on cell-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd2}
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for 3rd round counter on cell-2 =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Trigger DL backhaul muting on cell-2 =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=${cmd1}
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for 4th round counter on cell-2 =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check CB012582

# *** Keywords ***
# Counter Check CB012582
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}