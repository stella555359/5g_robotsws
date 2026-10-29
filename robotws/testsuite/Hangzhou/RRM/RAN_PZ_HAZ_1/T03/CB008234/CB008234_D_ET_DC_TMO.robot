*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -D CRT cases (Tester: Zhang Dacheng(NSB))

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
CB008234_D_AMBR limitation handling when CB006457 ARP based QoS profiling is enabled
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Description:
    ...    Based on CB006457 theory, when it is activated, new schedulweight is equal
    ...    to schedulweight * schedulingWeightSF, others are same as CB008234-A#B4/CB008234-B#B4.
    ...    Pre-condition:
    ...    CB008234 is enabled (NRBTS.actDlAmbr = 'SA' and NRBTS.actUlAmbr = 'SA')
    ...    NRBTS.actNonGbrServiceDiff = true: Enable non-GBR service differentiation(5GC000776/5GC001926)
    ...    NRBTS.NRCELL.actNbrForNonGbrBearers = false: Disable Nominal bitrate (CB008227)
    ...    NRBTS.actArpBasedQosScaling = true: Enable ARP based QoS scaling: (CB006457)
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_CB006457_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009,M55319C12006;
    ...    Counter rule: max(M55319C12009)/max(M55319C12006)>7.8;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12009,M55319C12006;
    ...    Counter rule: max(M55319C12009)/max(M55319C12006)<8.2;
    # The ratio of peak throughput of 5QI-9 and 5QI-6 should be 8:1
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set 5QI-9 and 5QI-6 are setup with ICS. =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=1
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Modify 5QI-9 ARP to 2. =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=4 priority\=2
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
    sleep    5s
    Log To Console      ${\n}============= Start traffic on 5QI-9 and 5QI-6 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=20
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=20
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Wait for throughput counter generation =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check 5QI9 and 5QI6

CB008234_D_AMBR limitation handling during intra-gNB Reestablishment
    [Documentation]
    ...    author: Dacheng Zhang
    ...    Description:
    ...    UE AMBR (DL&UL) which is provided from AMF shall be enforced by gNB after intra-gNB Reestablishment
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>185000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: max(M55319C16006)>185000;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= Set Initial DL/UL UE-AMBR as 5Mbps/5Mbps =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue\=1 ue_ambr_ul\=5:Mbps ue_ambr_dl\=5:Mbps
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
    sleep    5s
    Log To Console      ${\n}============= Start DL/UL traffic on 5QI-6 =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=10
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= Trigger intra-gNB Re-establishment =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_rrc_reestablish id\=1 gnb\=2 cell\=1 cause\=reconfigurationFailure
    ...    pass_regexp=NR RRC Reestablishment sucessfully completed
    Log To Console      ${\n}============= Re-establishment is completed. =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check 5QI9 and 5QI6
    Log To Console      ${\n}============= Check is done. Case is passed. =============${\n}

*** Keywords ***
Counter Check 5QI9 and 5QI6
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}
