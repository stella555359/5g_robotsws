*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -C CRT cases (Tester: Zhang Dacheng(NSB))

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
CB008234_C_B102_UE AMBR limitation modification for UE Context modification request Before PDU Session Setup
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    Modification of UE AMBR through UE Context Modification Request Message
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>1125000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)<1312500;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: max(M55319C16006)>750000;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: max(M55319C16006)<937500;
    # The DL/UL peak throughput of 5QI-9 after modification should be 30Mbps/20Mbps.
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Default DL/UL UE AMBR as 1Gbps/1Gbps. =============${\n}
    Log To Console      ${\n}============= Set DL/UL Session AMBR as 50Mbps/30Mbps. =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id\=1 ue\=1 pdu\=1 session_ambr_ul\=30:Mbps session_ambr_dl\=50:Mbps
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Set 5GC transmit UE AMBR in ICS =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_param id\=1 ambr_remove\=pdu_setup,nas_transport send_ics_registration\=on
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Start to Attach UE without PDU session setup =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Modify DL/UL UE AMBR to 30Mbps/20Mbps =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_ctx_modify_param id\=1 ue\=1 ue_ambr_ul\=20:Mbps ue_ambr_dl\=30:Mbps
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Trigger UE context modification request =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_ctx_ng_mod id\=1
    ...    pass_regexp=Received UE Context Modification Response
    sleep    3s
    Log To Console      ${\n}============= UE Context Modification Response is received. =============${\n}
    Log To Console      ${\n}============= Setup PDU session and start DL/UL traffic =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    sleep    5s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=80
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=50
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for throughput counter generation =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check DL and UL of 5QI9

CB008234_C_PM_QoS Flow Setup Fail due to missing AMBR
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description: Check PM counter M55125C13034 update for ICS failure due to missing UE AMBR
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C13034;
    ...    Counter rule: sum(M55125C13034)==1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Log To Console      ${\n}============= Remove UE AMBR in ICS. =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=amf_param id\=1 ambr_remove\=ics
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for next round counter update =============${\n}
    sleep    5 min    reason=wait for counter ready
    Counter Check DL and UL of 5QI9
    Log To Console      ${\n}============= Check Pass =============${\n}

*** Keywords ***
Counter Check DL and UL of 5QI9
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}
