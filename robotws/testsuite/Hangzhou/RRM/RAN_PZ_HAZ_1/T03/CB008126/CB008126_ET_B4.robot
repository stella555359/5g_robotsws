*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008126-SR ET B4 CRT cases script

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
#reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}
# ${DEBUG_MODE}          ${TRUE}
# ${REMOTE_MODE}       ${TRUE}
# ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2

*** Test Cases ***
# CB008126-A-B4 Successfull 5QI and ARP and UL TNL modification for multiple qosflows in multiple PDU sessions
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B4
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     # Delete before PM counter file
#     # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     # ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
#     Counter collection CB008126_B4
#     Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Airphone Start Traffic    mbps=5m
#     Log To Console      ${\n}============= DL traffic is started on 5QI-9 PDU1. =============${\n}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=3
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Airphone Start Traffic    qfi_id=2    mbps=5m
#     Log To Console      ${\n}============= DL traffic is started on 5QI-3 PDU1. =============${\n}

#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=13 default\=on
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Default 5QI is modified to 5QI-7. =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=2 trf_type\=internal
#     ...    pass_regexp=${None}
#     Sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=2
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= 2nd PDU is setup. =============${\n}
#     Sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= DL traffic is started on 5QI-7 PDU2. =============${\n}
#     # Add some sleep interval in second PDU related operation to aviod error.
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=2 qosflows_to_add\=11 by\=amf
#     ...    pass_regexp=${None}
#     Sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=2 qfi\=2 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= DL traffic is started on 5QI-5 PDU2. =============${\n}
#     Sleep    3s

#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue\=1 pdu\=2 qosflows_to_add\=1 by\=amf
#     ...    pass_regexp=${None}
#     Sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=2 qfi\=3 dir\=dl mbps\=5
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= DL traffic is started on 5QI-1 PDU2. =============${\n}
#     # Add Sleep interval to make sure background has enough time to handle every modification command.
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=14    5qi=168    fiveqi_type=non-gbr
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=12    5qi=165    fiveqi_type=non-gbr
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=15    5qi=8      fiveqi_type=non-gbr    priority=14
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=13    5qi=6      fiveqi_type=non-gbr    priority=13
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=1     gfbr_dl=6100    gfbr_ul=6100      priority=8
#     Sleep    3s
#     Airphone Qosflow Modify    qos_flow=3     gfbr_dl=6200    gfbr_ul=6200      priority=12
#     Sleep    3s
#     # Add sleep interval to avoid incomplete tcpdump log capture.
#     Start tcpdump by command For Remote
#     Sleep    10s
#     ${cmd}    Catenate    ue=1 pdu=1 qosflows_to_modify=3,15 switch_ul_tunnel_endpoint=ip_teid
#     ...    pdu=2 qosflows_to_modify=1,13 switch_ul_tunnel_endpoint=ip_teid by=amf
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_pdu_session_modify ${cmd}
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Modification in PDU1 and PDU2 is done. =============${\n}
#     Sleep    10s
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check MultiPDU PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}
#     Log To Console      ${\n}============= TNL IP check is done. Wait for counters. =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     # ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Log To Console      ${\n}============= Check counters. =============${\n}
#     # Counter Check 5QI6 and 5QI8    starttime=${start_time}    endtime=${end_time}
#     Counter check CB008126_B4

CB008126-A-B4 Successfull 5QI and ARP and UL TNL modification for single qosflow
    [Documentation]
    ...    author: Dacheng Zhang
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B4
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sa
    # Delete before PM counter file
    # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Counter collection CB008126_B4
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Sleep    3s
    Airphone Qosflow Modify    qos_flow=12    5qi=176    fiveqi_type=non-gbr
    Sleep    3s
    Airphone Qosflow Modify    qos_flow=15    5qi=6      fiveqi_type=non-gbr    priority=14
    Sleep    3s
    Connect All VM
    Start tcpdump by command For Remote
    Sleep    5s
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=15
    ...    switch_ul_tunnel_endpoint=ip_teid
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console      ${\n}============= Modification is done. =============${\n}
    Sleep    10s
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}
    Log To Console      ${\n}============= TNL IP check is done. =============${\n}
    Log To Console      ${\n}============= EDA Improvement action, test 2nd UE with ARP and MFBR change =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_nr_rrc_setup_param id\=2 establishment_cause\=mo-VideoCall
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow\=11 default\=on
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow\=1 gfbr_dl\=72 gfbr_ul\=72 mfbr_dl\=72 mfbr_ul\=72 priority\=1
    ...    pass_regexp=${None}
    sleep    2s
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow\=2 gfbr_dl\=712 gfbr_ul\=712 mfbr_dl\=712 mfbr_ul\=712 priority\=2
    ...    pass_regexp=${None}
    sleep    2s
    Log To Console      ${\n}============= 2nd UE attach is started. =============${\n}
    Airphone.Airphone Execute Egate Command    cmd=ue_register id\=2
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=2 pdu\=1 trf_type\=internal
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=2
    ...    pass_regexp=Initial Context Setup Successful
    sleep    3s
    Log To Console      ${\n}============= UE attach is done. =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=1,2 by\=amf
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=trf_data_start ue\=2 pdu\=1 qfi\=3 dir\=dl mbps\=5
    ...    pass_regexp=${None}
    sleep    3s
    Log To Console      ${\n}============= VoNR/ViNR call setup is done. =============${\n}
    Airphone.Airphone Execute Egate Command
    ...    cmd=qosflow_modify qos_flow\=2 gfbr_dl\=1500 gfbr_ul\=1500 mfbr_dl\=1500 mfbr_ul\=1500 priority\=1
    ...    pass_regexp=${None}
    sleep    3s
    Airphone.Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_modify\=2 by\=amf
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Modification of 5QI-2 is done, wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    # ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Log To Console      ${\n}============= Check counters. =============${\n}
    # Counter Check 5QI6    starttime=${start_time}    endtime=${end_time}
    Counter check CB008126_B4

*** Keywords ***
Counter Check 5QI6 and 5QI8
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55319C12008    M55319C12006
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55319C12008}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12008
    ${sum_M55319C12006}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12006
    Should be true    ${sum_M55319C12008}!=${0}
    Should be true    ${sum_M55319C12006}!=${0}

Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap.PDUSessionResourceModifyListModRes == 1'
    ...    filter_expression='ngap.TransportLayerAddressIPv4 == 10.0.1.200'
    ...    input_file=${capture_file_path}

Check MultiPDU PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap.PDUSessionResourceModifyListModRes == 2'
    ...    filter_expression='ngap.TransportLayerAddressIPv4 == 10.0.1.200'
    ...    input_file=${capture_file_path}

Counter Check 5QI6
    [Arguments]    ${starttime}    ${endtime}
    PM_counters_collector
    ${pi_list}    Create List    M55319C12006
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55319C12006}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12006
    Should be true    ${sum_M55319C12006}!=${0}

Counter collection CB008126_B4
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12006;
    ...    Counter rule: max(M55319C12006)>0;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

Counter check CB008126_B4
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}