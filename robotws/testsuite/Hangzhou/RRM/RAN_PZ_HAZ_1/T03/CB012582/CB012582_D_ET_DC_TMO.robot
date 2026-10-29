*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB012582-SR ET -D CRT in TMO configuration
...   Topology: CLOUD_5G_I_LOO_AP_LOOO

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       60 minutes

*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB012582_D_QosFlow Setup Fail due to ongoing Inter-gNB HO Xn handover
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor whether QoS setup will be rejected during handover process.
    ...    And counter should be pegged as expection.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B_Muting_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C13077;
    ...    Counter rule: max(M55125C13077)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C03505;
    ...    Counter rule: max(M55125C03505)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-7;
    ...    Counter: M55163C03015;
    ...    Counter rule: max(M55163C03015)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set gNBsim response for Handover request with delay =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id\=3 action\=delayed_rsp time_to_wait\=v20s
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=gnb_xn_status_transfer_param id\=3 action\=delayed_rsp time_to_wait\=v20s
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to trigger inter-gNB Handover and add 5QI-7 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 by\=ue
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_D_QosFlow Setup Fail due to ongoing Inter-gNB HO NG handover
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor whether QoS setup will be rejected during handover process.
    ...    And counter should be pegged as expection.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_NG_HO_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C13077;
    ...    Counter rule: max(M55125C13077)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C03505;
    ...    Counter rule: max(M55125C03505)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-5;
    ...    Counter: M55163C03015;
    ...    Counter rule: max(M55163C03015)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set gNBsim sending PDU session resource modification in HO =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ng_handover_param id\=1 action\=send_concurrent_msg msg\=ng_pdu_session_modification
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to trigger inter-gNB Handover and add 5QI-5 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}