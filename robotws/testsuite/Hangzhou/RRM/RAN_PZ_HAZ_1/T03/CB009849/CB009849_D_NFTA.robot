*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB009849-SR ET -D NFTA in TMO configuration

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Run keywords    Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM

Test Timeout       120 minutes

*** Variables ***
#Reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
&{fault_61616}           faultId=${61616}
&{fault_7529}            faultId=${7529}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}    &{fault_8000}    &{fault_7300}
...    &{fault_61616}    &{fault_7529}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
Case_1_Online disable VoNR specific DRX profile in successful setup of VoNR call TDD
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor online activation of CB009849-D function.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TMO_D
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Collection CB009849
    Attach UE1
    Start traffic on UE1
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value1}    Counter Check CB009849
    Online deactivate CB009849-D
    Counter Collection CB009849 after feature deactivation
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value2}    Counter Check CB009849
    Log To Console      ${\n}============= Compare counter result =============${\n}
    Should be True    ${value2}>${value1}
    Detach UE1

Case_2_Online disable VoNR specific DRX profile in successful setup of VoNR call FDD
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor online activation of CB009849-D function.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TMO_D
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Collection CB009849 FDD
    Move UE1 to FDD cell
    Attach UE1
    Start traffic on UE1
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value1}    Counter Check CB009849
    Online deactivate CB009849-D
    Counter Collection CB009849 after feature deactivation FDD
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value2}    Counter Check CB009849
    Log To Console      ${\n}============= Compare counter result =============${\n}
    Should be True    ${value2}>${value1}
    Detach UE1

*** Keywords ***
Move UE1 to FDD cell
    Log To Console      ${\n}============= Move UE1 to FDD cell-7 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_change_location id\=1 enb\=2 cell\=7
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id\=1 pathloss\=40
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
    ...    pass_regexp=${None}
    sleep    1s

Attach UE1
    Log To Console      ${\n}============= Set 5QI-7 as default QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=2 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    # Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    # ...    pass_regexp=${None}
    # sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Add 5QI-1 QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=5 by\=amf
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=6 by\=amf
    ...    pass_regexp=${None}
    sleep    2s

Attach UE1 and UE2
    Log To Console      ${\n}============= Set 5QI-5 as default QoS flow and add 5QI-1 in ICS =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=11 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Set 5QI-7 as default QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=13 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=reset
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE2 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=2
    ...    pass_regexp=UE NGAP ID 2 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=2 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=2
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

Start traffic on UE1
    # Log To Console      ${\n}============= Start DL/UL Data traffic on UE1 =============${\n}
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    # Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=2
    # ...    pass_regexp=${None}
    # sleep    2s
    # Airphone.Airphone Execute Egate Command
    # ...    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=ul trf_id\=2 rtp_codec\=amr_wb_23_85 period_ms\=20 burst\=1
    # ...    pass_regexp=${None}
    # sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=dl trf_id\=1 period_ms\=20 burst\=1
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=ul trf_id\=2 period_ms\=20 burst\=1
    ...    pass_regexp=${None}
    sleep    2s


Start traffic on UE1 FDD
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=2
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=ul trf_id\=2 period_ms=20 burst=3
    ...    pass_regexp=${None}
    sleep    2s

Online activate CB009849-D
    Log To Console      ${\n}============= Online activate CB009849-D =============${\n}
    [Documentation]    Enable 40ms period of proactive grant for VoNR UE
    @{para_list}   Create List    actVonr40msProGrant
    @{value_list}   Create List   true
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Online deactivate CB009849-D
    Log To Console      ${\n}============= Online deactivate CB009849-D =============${\n}
    [Documentation]    Disable 40ms period of proactive grant for VoNR UE
    @{para_list}   Create List    actVonr40msProGrant    actVonr40msProGrant
    @{value_list}   Create List   false    false
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-7
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Setup 5QI-5 and 5QI-1 on UE2
    Log To Console      ${\n}============= Setup 5QI-5 and 5QI-1 on UE2 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=11 by\=amf
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=1 by\=amf
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=ul mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=3 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=3 dir\=ul mbps\=5
    ...    pass_regexp=${None}
    sleep    2s

Detach UE1
    Log To Console      ${\n}============= Detach all UEs =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=1 pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=1 ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s

Detach UE1 and UE2
    Log To Console      ${\n}============= Detach all UEs =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=1 pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=2 pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=1 ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=2 ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s

Adjust channel to bad condition
    Log To Console      ${\n}============= Deteriorate channel condition =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id\=1 pathloss\=128
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
    ...    pass_regexp=${None}
    sleep    2s

Recover channel condition
    Log To Console      ${\n}============= Deteriorate channel condition =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=deactivate
    ...    pass_regexp=${None}
    sleep    2s

Counter Collection CB009849
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55308C24002;
    ...    Counter rule: max(M55308C24002);
    ${rule_list}    Create List    ${rule1}
    Set Test Variable    ${rule1}    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Collection CB009849 after feature deactivation
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55308C24002;
    ...    Counter rule: max(M55308C24002);
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Collection CB009849 FDD
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-7;
    ...    Counter: M55308C24002;
    ...    Counter rule: max(M55308C24002);
    ${rule_list}    Create List    ${rule1}
    Set Test Variable    ${rule1}    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Collection CB009849 after feature deactivation FDD
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-7;
    ...    Counter: M55308C24002;
    ...    Counter rule: max(M55308C24002);
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    wait_for_next_counter_generate=${TRUE}
    ...    counter_rule=${rule_list}

Counter Check CB009849
    ${value}    Counter Operation    operation=collect_counter_and_calculate
    ...    product_type=gnb
    Log To Console    ${value}
    [Return]    ${value}[check_result][${rule1}]
