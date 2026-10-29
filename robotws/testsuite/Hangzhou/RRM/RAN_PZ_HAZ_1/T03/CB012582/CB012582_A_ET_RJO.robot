*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB012582-SR ET -A CRT in Reliance JIO configuration

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
#Reduce global paramter as possilbe and automatically got from gNB or __init__
${cmd1}    trf_data_start
...    ue=1 pdu=1 qfi=2 dir=dl trf_id=2 rtp_codec=custom rtp_send_silence_period=500 period_ms=500 burst=1

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
CB012582_A_20_NG based Inter-gNB HO Interruption time Target Range data forwarding ON
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_CLASSICAL_AP_CA_ASOE_RJO
    ...    Description:
    ...    This case aims to monitor interruption time, tunneling delay during inter-gNB NG HO.
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_1gNBSim_RJO_NG
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sa
    Counter Collection CB012582 for NG Handover
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
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command    cmd=${cmd1}
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= Start inter-gNB UE handover to target sim cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=19 phycell_id\=7 nrsrp_nr\=100
    ...    pass_regexp=NG Handover successfully completed at Target
    sleep    10s
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. =============${\n}
    Log To Console      ${\n}============= Start inter-gNB UE handover to target AP cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=19 phycell_id\=50 nrsrp_nr\=100
    ...    pass_regexp=NG Handover successfully completed at Source
    sleep    3s
    Log To Console      ${\n}============= Event A3 is triggered and handover is done. Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Update bsr package
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}     coam.Update Software      /home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    coam.teardown admin

Counter Collection CB012582 for NG Handover
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00016;
    ...    Counter rule: sum(M55379C00016)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00017;
    ...    Counter rule: sum(M55379C00017)==0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00018;
    ...    Counter rule: sum(M55379C00018)==2;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00025;
    ...    Counter rule: sum(M55379C00025)==0;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00026;
    ...    Counter rule: sum(M55379C00026)==0;
    ${rule6}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55379C00027;
    ...    Counter rule: sum(M55379C00027)>0;
    ${rule_list}    Create List    ${rule1}     ${rule2}     ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}