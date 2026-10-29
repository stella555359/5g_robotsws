*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB009849-SR ET -D CRT in Reliance JIO configuration

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

*** Test Cases ***
Case_1_Online enable VoNR specific DRX profile in successful setup of VoNR call TDD
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_O_E_AP_LOOO
    ...    Description:
    ...    This case aims to monitor change of #(5QI-1 UL grant) after activating CB009849-D.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_D
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sa
    Counter Collection CB009849
    Attach UE    ue_id=1
    Start traffic on UE    ue_id=1
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value1}    Counter Check CB009849
    Online activate CB009849-D
    Counter Collection CB009849 after feature activation
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value2}    Counter Check CB009849
    Log To Console      ${\n}============= Compare counter result =============${\n}
    Should be True    ${value2}<${value1}
    Detach UE    ue_id=1

Case_2_Online enable VoNR specific DRX profile in successful setup of VoNR call FDD
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_O_E_AP_LOOO
    ...    Description:
    ...    This case aims to monitor change of #(5QI-1 UL grant) after activating CB009849-D.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_D
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sa
    Counter Collection CB009849    cell_id=4
    Attach UE    ue_id=41
    Start traffic on UE    ue_id=41
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value1}    Counter Check CB009849
    Online activate CB009849-D
    Counter Collection CB009849 after feature activation    cell_id=4
    Log To Console      ${\n}============= Wait for counter update =============${\n}
    sleep    10 min
    ${value2}    Counter Check CB009849
    Log To Console      ${\n}============= Compare counter result =============${\n}
    Should be True    ${value2}<${value1}
    Detach UE    ue_id=41

*** Keywords ***
Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Attach UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Set 5QI-7 as default QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=13 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    # Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    # ...    pass_regexp=${None}
    # sleep    2s
    Log To Console      ${\n}============= Start to Attach the UE1 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${ue_id}
    ...    pass_regexp=UE NGAP ID 1 is now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${ue_id} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${ue_id} nwslice\=1 gw\=1
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= Add 5QI-1 QoS flow =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=11 by\=amf
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=1 by\=amf
    ...    pass_regexp=${None}
    sleep    2s

Start traffic on UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Start DL/UL Data traffic on UE1 =============${\n}
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
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=3 dir\=dl trf_id\=1 period_ms\=20 burst\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=3 dir\=ul trf_id\=2 period_ms\=20 burst\=2
    ...    pass_regexp=${None}
    sleep    2s

Detach UE
    [Arguments]    ${ue_id}=1
    Log To Console      ${\n}============= Detach all UEs =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    ...    pass_regexp=${None}
    sleep    2s

Online activate CB009849-D
    Log To Console      ${\n}============= Online activate CB009849-D =============${\n}
    [Documentation]    Enable 40ms period of proactive grant for VoNR UE
    @{para_list}   Create List    actVonr40msProGrant    actVonr40msProGrant
    @{value_list}   Create List   true    true
    @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-4
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Counter Collection CB009849
    [Arguments]    ${cell_id}=1
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-${cell_id};
    ...    Counter: M55308C24002;
    ...    Counter rule: max(M55308C24002);
    ${rule_list}    Create List    ${rule1}
    Set Test Variable    ${rule1}    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Collection CB009849 after feature activation
    [Arguments]    ${cell_id}=1
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-${cell_id};
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