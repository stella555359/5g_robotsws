*** Settings ***
Documentation
...   author: Dong Feng
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB011065-SR-D in TMO configuration

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
CB011065-SR-D_02_Successful config of B1 meas on reception of PDUSessionResourceModifyRequest for 5QI-1
    [Documentation]
    ...    author: Dong Feng
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor CB011065-SR normal case.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_D1_TMO
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Log To Console      ${\n}============= Subfeature -D B1 mesurement related counters =============${\n}
    Counter collection CB011065_D1
    ATTACH UE    UE_ID=1
    Setup 5QI-5    UE_ID=1
    Setup 5QI-1    UE_ID=1
    Trigger B1 measurement report    UE_ID=1
    Log To Console      ${\n}============= Wait for -D1 counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=1

CB011065-SR-D_07_ Redirection to eutra RAT due to Bad UL Radio Conditions
    [Documentation]
    ...    author: Dong Feng
    ...    Topology: CLOUD_5G_I_LOO_AP_LOOO
    ...    Description:
    ...    This case aims to monitor CB011065-SR normal case.
    [Setup]
    ...    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_D2_TMO
    ...    base_path=${CURDIR}/APCFG
    ...    call_type=sansa
    Log To Console      ${\n}============= Subfeature -D counters of redirection due to bad UL condition =============${\n}
    Counter collection CB011065_D2
    ATTACH UE    UE_ID=1
    Setup 5QI-5    UE_ID=1
    Setup 5QI-1    UE_ID=1
    Start traffic on UE    UE_ID=1    TRAFFIC_RATE=5
    Make UE bad UL radio condition    profile_id=1
    Log To Console      ${\n}============= Wait for -D2 counter update =============${\n}
    sleep    5 min
    Counter check
    DETTACH UE    UE_ID=1

*** Keywords ***
Counter collection CB011065_D1
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01032;
    ...    Counter rule: max(M55124C01032)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C02501;
    ...    Counter rule: max(M55124C02501)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01033;
    ...    Counter rule: max(M55124C01033)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01502;
    ...    Counter rule: max(M55124C01502)==1;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00013;
    ...    Counter rule: max(M55145C00013)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter collection CB011065_D2
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00042;
    ...    Counter rule: max(M55124C00042)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C00522;
    ...    Counter rule: max(M55124C00522)==1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55124C01502;
    ...    Counter rule: max(M55124C01502)==1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55145C00015;
    ...    Counter rule: max(M55145C00015)==1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter check
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Set 5QI-5 and 5QI-1 as initial DRB
    Log To Console      ${\n}============= Set 5QI-5 as Default DRB and setup 5QI-1 during ICS =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    sleep    1s
    Airphone.Airphone Execute Egate Command
    ...    cmd=smf_param id=1 additional_qosflows_to_activate=6
    ...    pass_regexp=${None}
    sleep    1s


ATTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Attach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${UE_ID}
    ...    pass_regexp=now Registered
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${UE_ID} pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${UE_ID} nwslice\=1 gw\=${UE_ID}
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s

DETTACH UE
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Detach UE${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_stop ue\=${UE_ID} pdu\=all
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_deregister id\=${UE_ID}
    ...    pass_regexp=${None}
    sleep    2s

Setup 5QI-5
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Setup 5QI-5 =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=${None}
    sleep    1s

Setup 5QI-1
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Setup 5QI-1 as VoNR DRB =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=${None}
    sleep    1s

Trigger B1 measurement report
    [Arguments]    ${UE_ID}
    Log To Console      ${\n}============= Trigger UE${UE_ID} B1 Measurement Report and fallback to LTE cell =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=5 event=B1 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...    pass_regexp=Re-direction to 4G/LTE cell is not supported
    sleep    3s

Start traffic on UE
    [Arguments]    ${UE_ID}    ${TRAFFIC_RATE}
    Log To Console      ${\n}============= Start traffic on UE ${UE_ID} =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=dl mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi\=1 dir\=ul mbps\=${TRAFFIC_RATE}
    ...    pass_regexp=${None}
    sleep    2s

Make UE bad UL radio condition
    [Arguments]    ${profile_id}
    Log To Console      ${\n}============= make UE bad UL radio condition =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id\=${profile_id} dl_bler\=800,200,100 ul_bler=800,200,100
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=1 testmode\=bler profile_id=${profile_id} action=activate
    ...    pass_regexp=${None}
    sleep    2s