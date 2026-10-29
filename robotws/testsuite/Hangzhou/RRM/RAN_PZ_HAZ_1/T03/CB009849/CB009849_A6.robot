*** Settings ***
Documentation
...   author: Dong Tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB009849-A ET NFTA cases

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       90 minutes

*** Variables ***
${cmd1}    trf_data_start
...    ue=1 pdu=1 qfi=2 dir=dl trf_id=2 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1
&{fault_4334}            faultId=${4334}
&{fault_4681}            faultId=${4681}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61652}           faultId=${61652}
&{fault_61649}           faultId=${61649}
&{fault_4459}            faultId=${4459}
&{fault_4655}            faultId=${4655}
&{fault_4654}            faultId=${4654}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_7311}            faultId=${7311}
&{fault_7307}            faultId=${7307}
&{fault_7107}            faultId=${7107}
&{fault_61616}           faultId=${61524}
&{fault_7529}            faultId=${7529}
&{fault_4592}            faultId=${4592}
&{fault_4701}            faultId=${4701}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61524}    &{fault_7311}    &{fault_7307}    &{fault_7529}    &{fault_7107}    &{fault_61652}    &{fault_4655}
...    &{fault_4701}    &{fault_4592}    &{fault_7300}    &{fault_4654}    &{fault_61649}    &{fault_61510}    &{fault_4681}
${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
USCB009849-A#7 RRC re-establishment of UE with 5QI1 bearer
    [Documentation]
    ...    author: tdong
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to verify the RRC re-establishment of UE with 5QI1 bearer
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Counter Check CB009849 enable on cell1
    Log To Console      ${\n}============= Start UE VoNR call =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=5 by\=amf
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=6 by\=amf
    ...    pass_regexp=${None}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB009849 End
    sleep    2s
    Counter Check CB009849 enable on cell2
    Log To Console      ${\n}============= Start RRC re-establishment to cell2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=reconfigurationFailure
    ...    pass_regexp=${None}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB009849 End
    sleep    2s
    Log To Console      ${\n}============= disable feature on cell1 =============${\n}
    disable actForcedDftSOfdmVonrUl
    sleep    2s
    Counter Check CB009849 disable on target cell with 256QAM
    Log To Console      ${\n}============= Start RRC re-establishment to cell1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=1 cause\=reconfigurationFailure
    ...    pass_regexp=${None}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB009849 End
    sleep    2s
    Counter Check CB009849 enable on cell2
    Log To Console      ${\n}============= Start RRC re-establishment to cell2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=2 cause\=reconfigurationFailure
    ...    pass_regexp=${None}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB009849 End

CB009849_A Successful feature flag online modify
    [Documentation]
    ...    author: Dong Tony
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor whether used MCS counter for VoNR QoS flow is correctly updated.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= disable feature=============${\n}
    disable actForcedDftSOfdmVonrUl
    sleep    2s
    Log To Console      ${\n}============= Attach second UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=2
    ...    pass_regexp=UE NGAP ID 2 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=2 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=2
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= enable feature =============${\n}
    enable actForcedDftSOfdmVonrUl
    sleep    2s

*** Keywords ***
Counter Check CB009849 enable on cell1
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15092;
    ...    Counter rule: sum(M55302C15092)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15101;
    ...    Counter rule: sum(M55302C15101)>=0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
Counter Check CB009849 enable on cell2
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55302C15092;
    ...    Counter rule: sum(M55302C15092)>=0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-2;
    ...    Counter: M55302C15101;
    ...    Counter rule: sum(M55302C15101)>=0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Check CB009849 disable on target cell with 256QAM
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15060;
    ...    Counter rule: sum(M55302C15060)>0;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB009849 disable on target cell with 64QAM
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55302C15029;
    ...    Counter rule: sum(M55302C15029)>1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB009849 End
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

disable 256QAM
    [Documentation]    Enable DL/UL 256QAM
    @{para_list}   Create List   actDl256Qam    actUl256Qam
    @{value_list}   Create List   false    false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

disable actForcedDftSOfdmVonrUl
    [Documentation]    disable actForcedDftSOfdmVonrUl
    @{para_list}   Create List   actForcedDftSOfdmVonrUl
    @{value_list}   Create List   false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1
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

enable actForcedDftSOfdmVonrUl
    [Documentation]    enable actForcedDftSOfdmVonrUl
    @{para_list}   Create List   actForcedDftSOfdmVonrUl
    @{value_list}   Create List   true
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}