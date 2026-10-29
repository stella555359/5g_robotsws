*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is VoNR call on TDD mMIMO platform CRT cases script

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
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}
...    &{fault_8000}    &{fault_7300}    &{fault_61616}

${Ignore_Cell_Id_For_Sib}    5    6    9    12

*** Test Cases ***
VoNR on ABIP and TDD mMIMO platform
    [Documentation]
    ...    author: Dacheng Zhang
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C09517;
    ...    Counter rule: sum(M55125C09517)==5;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...    Counter: M55125C09518;
    ...    Counter rule: sum(M55125C09518)==5;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m
    Log To Console      ${\n}============= DL traffic is started on default 5QI-6. =============${\n}

    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=5
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID

    Airphone Start Traffic    dir=dl    qfi_id=2    mbps=5m
    Log To Console      ${\n}============= 5QI-5 is setup and DL traffic is also started =============${\n}

    FOR    ${i}    IN RANGE    5
        ${ret}    airphone_pdu_session_modify    ue_id=1
        ...    pdu_id=1
        ...    qosflows_to_add=6
        ...    by=amf
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
        Airphone Start Traffic    dir=dl    qfi_id=3    mbps=5m
        Log To Console      ${\n}============= 5QI-1 is setup and VoNR call is started. (Round ${i}) =============${\n}
        Sleep    15s
        ${ret}    airphone_pdu_session_modify    ue_id=1
        ...    pdu_id=1
        ...    qosflows_to_del=6
        ...    by=amf
        ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
        Log To Console      ${\n}============= 5QI-1 is released and VoNR call is dropped. (Round ${i}) =============${\n}
        Sleep    3s
    END

    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check counters =============${\n}
    Counter Check VoNR setup counter

*** Keywords ***
Counter Check VoNR setup counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}