*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB012582-SR ET -C NFTA cases (Tester: Zhang Dacheng(NSB))
...   Topology: CLOUD_5G_I_MP_AP_LO

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
CB012582_C_VoNR DL and UL MCS counters
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_C_64QAM
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12087;
    ...    Counter rule: max(M55300C12087)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55308C24001;
    ...    Counter rule: max(M55308C24001)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12011;
    ...    Counter rule: max(M55300C12011)>0;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12012;
    ...    Counter rule: max(M55300C12012)>0;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15017;
    ...    Counter rule: max(M55302C15017)>0;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15016;
    ...    Counter rule: max(M55302C15016)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Set UE in bad radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id\=2 dl_bler\=800,200,100 ul_bler\=800,200,100
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=activate
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_C_VoNR DL and UL MCS counters 256QAM
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_C_64QAM
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12087;
    ...    Counter rule: max(M55300C12087)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55308C24001;
    ...    Counter rule: max(M55308C24001)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12043;
    ...    Counter rule: max(M55300C12043)>0;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12044;
    ...    Counter rule: max(M55300C12044)>0;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15043;
    ...    Counter rule: max(M55302C15043)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Enable 256QAM =============${\n}
    Enable 256QAM
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Set UE in bad radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id\=2 dl_bler\=400,200,100 ul_bler\=400,200,100
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=activate
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_C_VoNR DL and UL MCS counters with DFT-s-OFDM
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_C_64QAM
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12087;
    ...    Counter rule: max(M55300C12087)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55308C24001;
    ...    Counter rule: max(M55308C24001)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12039;
    ...    Counter rule: max(M55300C12039)>0;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15069;
    ...    Counter rule: max(M55302C15069)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Set UE in bad radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id\=1 pathloss\=128
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=deactivate
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

CB012582_C_VoNR DL and UL Residual BLER BIN counter
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO TMO configuration
    ...    Description:
    ...    This case aims to monitor whether residual BLER statistics can be distributed in correct BIN.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_C_BLER_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55300C12076;
    ...    Counter rule: max(M55300C12076)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15102;
    ...    Counter rule: max(M55302C15102)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=6
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Set UE in bad radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id\=2 dl_bler\=90,10,10,10,10,10,10,10 ul_bler\=90,10,10,10,10,10,10,10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=activate
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=deactivate
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Check Residual BLER BIN counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Enable 256QAM
    [Documentation]    Enable DL/UL 256QAM
    @{para_list}   Create List   actDl256Qam    actUl256Qam
    @{value_list}   Create List   true    true
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}