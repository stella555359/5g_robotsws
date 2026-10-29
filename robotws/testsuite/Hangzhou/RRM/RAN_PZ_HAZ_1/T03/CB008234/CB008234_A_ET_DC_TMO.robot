*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -A CRT cases (Tester: Zhang Dacheng(NSB))
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
#reduce global paramter as possilbe and automatically got from gNB or __init__

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
CB008234_A_B6_DL AMBR limitation handling with PDU Session Modify Success for PDU session AMBR modification
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    Modification of UE AMBR through PDU session resource Modification Request Message
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>500000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12007;
    ...    Counter rule: max(M55319C12007)>500000;
    # The peak throughput of 5QI-6 and 5QI-7 should be same due to same scheduling weight
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
    Log To Console      ${\n}============= Single PDU DL session AMBR modification =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 session_ambr_dl\=60:Mbps by\=amf
    ...    pass_regexp=Received Pdu Session Resource Modify Response Message
    sleep    3s
    Log To Console      ${\n}============= Start DL traffic on QoS flow 1 5QI-6 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=50
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console
    ...    ${\n}============= PDU DL session AMBR modification with adding QoS flow 5QI-7 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 session_ambr_dl\=80:Mbps by=amf
    ...    pass_regexp=Received Pdu Session Resource Modify Response Message
    sleep    3s
    Log To Console      ${\n}============= Start DL traffic on QoS flow 2 5QI-7 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=50
    ...    pass_regexp=${None}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check DL throughput

CB008234_A_B7_DL AMBR limitation handling with PDU Session release
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_MP_AP_LO
    ...    Description:
    ...    Re-calculated DL UE-AMBR should be distributed after PDU session release
    ...    Re-calculated rule: Min(the sum of Session-DL AMBR of all PDU Sessions, DL UE AMBR).
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>375000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12007;
    ...    Counter rule: max(M55319C12007)>0;
    # The peak throughput of 5QI-9 should be 10Mbps after 2nd PDU session releasing
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Initial DL UE-AMBR is set as 15Mbps =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue\=1 ue_ambr_dl\=15:Mbps
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
    Log To Console      ${\n}============= Start DL traffic on PDU1 5QI-6 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=20
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Setup 2nd PDU with default 5QI-7 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=2 default\=on
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=2 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=2
    ...    pass_regexp=${None}
    sleep    5s
    Log To Console      ${\n}============= Start DL traffic on PDU2 5QI-7 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl mbps\=20
    ...    pass_regexp=${None}
    sleep    1min
    Log To Console      ${\n}============= Release PDU2 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_release ue\=1 pdu\=2 by\=amf
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Release is done. Wait for checking PDU1 throughput =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput of PDU1 =============${\n}
    Counter Check DL throughput

*** Keywords ***
Counter Check DL throughput
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}