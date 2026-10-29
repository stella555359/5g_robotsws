*** Settings ***
Documentation
...   author: Dong Tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB009849-A ET NFTA cases

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
...                AND    Update bsr package
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       90 minutes

*** Variables ***
${cmd1}    trf_data_start
...    ue=1 pdu=1 qfi=2 dir=dl trf_id=2 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_7311}            faultId=${7311}
&{fault_7307}            faultId=${7307}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7311}    &{fault_7307}    &{fault_7529}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
UL MCS (DFT-s-OFDM and CP-OFDM) counter update for the VoNR call when CB009849-A is activated base on USCB009849-A#1
    [Documentation]
    ...    author: Dong Tony
    ...    Topology: CLOUD_5G_CLASSICAL_AP_CA_ASOE_RJO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15096;
    ...    Counter rule: max(M55302C15096)>=0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15101;
    ...    Counter rule: max(M55302C15101)>0;
#    ${rule3}    Catenate
#    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#    ...    Counter: M55300C12011;
#    ...    Counter rule: max(M55300C12011)>0;
#    ${rule4}    Catenate
#    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#    ...    Counter: M55300C12012;
#    ...    Counter rule: max(M55300C12012)>0;
#    ${rule5}    Catenate
#    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#    ...    Counter: M55302C15017;
#    ...    Counter rule: max(M55302C15017)>0;
#    ${rule6}    Catenate
#    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#    ...    Counter: M55302C15016;
#    ...    Counter rule: max(M55302C15016)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
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
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582
    Log To Console      ${\n}============= Release 5QI1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=1 by\=amf
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
    Log To Console      ${\n}============= Set UE back good radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=deactivate
    ...    pass_regexp=${None}
    sleep    2s
#    Log To Console      ${\n}============= Wait for counters =============${\n}
#    Sleep    10 min    reason=wait for counter ready
#    Log To Console      ${\n}============= Check counters =============${\n}
#    Counter Check CB012582


UL MCS (DFT-s-OFDM and CP-OFDM) counter update for the VoNR call when CB009849-A is activated base on Alternate HO scenario1 of USCB009849-A#2
    [Documentation]
    ...    author: Dong Tony
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A4
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
    sleep    2s

    Log To Console      ${\n}============= disable feature on cell2 =============${\n}
    disable actForcedDftSOfdmVonrUl
    sleep    2s
    Log To Console      ${\n}============= UE handover to cell2 with feature enable =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    2s

    Log To Console      ${\n}============= release 5QI1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=1 by\=amf
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
    Log To Console      ${\n}============= Set UE back good radio condition with high DL/UL BLER =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id\=2 action\=deactivate
    ...    pass_regexp=${None}

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

disable actForcedDftSOfdmVonrUl
    [Documentation]    disable actForcedDftSOfdmVonrUl
    @{para_list}   Create List   actForcedDftSOfdmVonrUl
    @{value_list}   Create List   false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-2
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin