*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -A#EC CRT cases script

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
CB008234_A_EC1_DL AMBR limitation handling with AMBR validation failure in NG because UE AMBR is not presented
    [Documentation]
    ...    author: Dacheng Zhang
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Connect All VM
    Start tcpdump by command For Remote
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
    sleep    5s
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Log To Console      ${\n}============= Start to Check tcpdump log =============${\n}
    Check INITIALCONTEXTSETUPFAILURE In Wireshark Log    ${capture_file_path_source}
    Log To Console      ${\n}============= Check Pass =============${\n}

CB008234_A_EC1_DL AMBR limitation handling with AMBR validation failure in NG because Session AMBR is not presented
    [Documentation]
    ...    author: Dacheng Zhang
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Connect All VM
    Start tcpdump by command For Remote
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Log To Console      ${\n}============= Remove Session AMBR in ICS. =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=smf_ue_pdu_param id\=1 ue\=1 pdu\=1 do_not_include_session_ambr\=on
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
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Log To Console      ${\n}============= Start to Check tcpdump log =============${\n}
    Check INITIALCONTEXTSETUPFAILURE In Wireshark Log Type2    ${capture_file_path_source}
    Log To Console      ${\n}============= Check Pass =============${\n}

*** Keywords ***
Check INITIALCONTEXTSETUPFAILURE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    InitialContextSetupRequest
    Should Contain    ${output}    InitialContextSetupFailure

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap'
    ...    filter_expression='ngap.protocol == 1'
    ...    input_file=${capture_file_path}

Check INITIALCONTEXTSETUPFAILURE In Wireshark Log Type2
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    InitialContextSetupRequest
    Should Contain    ${output}    InitialContextSetupFailure

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap'
    ...    filter_expression='ngap.protocol == 4'
    ...    input_file=${capture_file_path}