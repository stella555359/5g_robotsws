*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   Description: This is CB008234-SR ET -D#EC CRT cases script

Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Force Tags         CRT/CIT/CDRT     #Tag Item
# ...              PY39
...                RAN_5G                    #Product [RAN_5G]
...                SBTS00           # it is for auto trigger by ute cloud with the release
...                RAN_PZ_HAZ_1             #Competence Area
...                RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20, TA_LEVEL_21, TA_LEVEL_22]

Test Timeout       40 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__

&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_7300}            faultId=${7300}
&{fault_7523}            faultId=${7523}
&{fault_7107}            faultId=${7107}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_7300}    &{fault_7523}    &{fault_7107}
# ${DEBUG_MODE}          ${TRUE}
# ${REMOTE_MODE}       ${TRUE}
# ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2

*** Test Cases ***
CB008234_D_EC1_AMBR validation failure due to no UE AMBR during incoming NG handover
    [Documentation]
    ...    author: dong tony
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_NG
    ...    base_path=${CURDIR}/Airphone
#   Delete before PM counter file
#   ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#   ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Connect All VM
    Start tcpdump by command For Remote
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}

	Log To Console      ${\n}============= Change UE location to simgNB =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=ue_change_location id\=1 enb\=3 cell\=1
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

	Log To Console      ${\n}============= NgHO witout UEAMBR =============${\n}
	Airphone.Airphone Execute Egate Command    cmd=gnb_param id\=3 xn_listening_socket\=1 send_xn_setup\=false sa_ho\=ng_based
	...    pass_regexp=${None}
    sleep    3s
	Airphone.Airphone Execute Egate Command    cmd=amf_ue_ng_handover_request_param id\=1 exclude_ue_ambr\=true
	...    pass_regexp=${None}
    sleep    3s
	Airphone.Airphone Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
    ...    pass_regexp=${None}
    sleep    3s

#   ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Stop tcpdump And download by command For Remote
    ${capture_file_path_source}    Download wireshark log to testvm For Remote
    Log To Console      ${\n}============= Start to Check tcpdump log =============${\n}
    Check HOFAILURE In Wireshark Log    ${capture_file_path_source}
    Log To Console      ${\n}============= Check Pass =============${\n}


*** Keywords ***
Check HOFAILURE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    HandoverRequest
    Should Contain    ${output}    HandoverFailure

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap'
    ...    filter_expression='ngap.protocol == 1'
    ...    input_file=${capture_file_path}
