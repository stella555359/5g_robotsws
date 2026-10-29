*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB012582-B ET cases script

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
&{fault_7300}            faultId=${7300}
&{fault_8000}            faultId=${8000}
&{fault_7523}            faultId=${7523}
&{fault_7107}            faultId=${7107}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_7300}    &{fault_7523}    &{fault_4459}
...    &{fault_7107}    &{fault_61510}    &{fault_8000}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
CB012582-B_SA in-session 5QI-1 QoS Flow duration update during normal VoNR call
    [Documentation]
    ...    author: Dong Tony, Dacheng Zhang
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO TMO configuration
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55350C20050;
    ...    Counter rule: max(M55350C20050)>120000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55350C20050,M55357C00001;
    ...    Counter rule: max(M55357C00001)==max(M55350C20050);
    ${rule_list}    Create List    ${rule1}     ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    # Connect All VM
    # Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    # Airphone.Airphone Execute Egate Command    cmd=gnb_xn_link_up gnb\=3 target\=2
    # ...    pass_regexp=${None}
    # sleep    3s
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
    Log To Console      ${\n}============= setup 5QI1 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=5 by\=amf
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=6 by\=amf
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=3 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= release UE =============${\n}
    Sleep    2 min    reason=wait some time to release UE
    Airphone.Airphone Execute Egate Command    cmd=ue_deregister id\=1 ue_deregister_type\=switch_off

    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check CB012582

*** Keywords ***
Counter Check CB012582
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}