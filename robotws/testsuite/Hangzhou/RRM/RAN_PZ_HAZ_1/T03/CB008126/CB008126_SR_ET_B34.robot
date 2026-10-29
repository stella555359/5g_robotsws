*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB008126-SR B34
...   Default B34 WTS cfg file is wts_SA_TDD_2c_1gNBSim_B34
...   Default 5QI is 9
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Setup       Common Suite Setup For RRM
Test Setup            Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
Test Teardown     Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Test Teardown    Common Test Teardown For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    60 minutes
*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61616}           faultId=${61616}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_61616}
...    &{fault_4459}    &{fault_8000}    &{fault_7300}
# ${DEBUG_MODE}            ${TRUE}
${parameter}           act5qiAndUlNguTnlQosFlowMod
${parameter_8379}      actNonVoNRGbrService
${dist_name}           MRBTS-1/NRBTS-1
${tput_5m}             4900000
# ${REMOTE_MODE}           ${TRUE}
${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone

*** Test Cases ***
CB008126-A-B34 Successful 5QI modification with simultaneous QoS flow release
    [Documentation]    author:keli
    ...    Case 4
    ...    CRT case
    ...    1. The purpose of this test case is to check following scenarios:
    ...    The purpose of this test case is to verify successful 5QI Modification
    ...    with establishment/release of other QoS flow simultaneously initiated
    ...    by 5GC for an existing non-GBR QoS Flow.
    ...    2. Test Case Steps:
    ...         Step A. Trigger 5QI-9 to 5QI-6 modification while in the same message trigger release of 5QI-7
    ...         Step B. E1AP messages check between gNB CU-CP to CU-UP
    ...         Step C. F1AP message check between gNB CU-CP to gNB DU
    ...    3. Expected Results:
    ...         Step A: 5GC sends the NGAP: PDU Session Resource Modify Request message to the gNB-CU-CP
    ...         Step B: E1AP: BEARER CONTEXT MODIFICATION REQUEST Contain Release old DRB corresponding
    ...                 to the QoS Flows (5QI9 and 5QI7) and setup one new DRB (5QI6) with new DRBID
    ...         Step C: gNB-CU-CP sends the F1AP:
    ...                 UE CONTEXT MODIFICATION REQUEST message to requesting the release old DRB corresponding to the QoS Flows
    ...                 and setup one new DRB with new DRBID
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=13
    ...    by=amf
    Log To Console    ${\n}============= Added 5qi7. =============${\n}

    Airphone Qosflow Modify    qos_flow=12    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=15    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=15
    ...    qosflows_to_del=13
    ...    by=amf

    Log To Console    ${\n}============ Modified 5qi9to6 release 5qi7. ============${\n}
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=9
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.fiveQI == 6'
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.QosFlowListWithCause == 1'
    ...    filter_expression='ngap.qosFlowIdentifier == 2'
    Log To Console    ${\n}============Checked NGAP. ============${\n}
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.qoS_Flow_Identifier == 1'
    ...    filter_expression='e1ap.dRB_Setup_List_NG_RAN == 1 && e1ap.dRB_ID == 6'
    # DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.dRB_Released_In_Session == 0'
    ...    filter_expression='e1ap.dRB_ID == 4'
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.dRB_Released_In_Session == 1'
    ...    filter_expression='e1ap.dRB_ID == 5'
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_Identity == 6 && nr-rrc.drb_ToReleaseList == 2'
    ...    filter_expression='nr-rrc.drb_ToAddModList == 1 && nr-rrc.drb_Identity == 6'
    Log To Console    ${\n}============ Checked Wireshark Log. ============${\n}
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    12 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${1}     fail_val=${0}


CB008126-A-B34 Successful 5QI modification of 2 flows in single PDU session
    [Documentation]    author:keli
    ...    case7
    ...    CRT case
    ...    Default Setup 5QI-5
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_case7
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=12
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============= Added 5qi6. =============${\n}
    sleep    2s
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    qfi_id=2
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=13    5qi=176    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=14    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=11    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=8    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=11,12
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi5to7 5qi6to8. ============${\n}

    Airphone Qosflow Modify    qos_flow=11    5qi=178    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=179    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=11    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=11,12
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi7to8 5qi8to7. ============${\n}

    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    sleep    2s

    Airphone Qosflow Modify    qos_flow=11    5qi=5    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=11,12
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi8to5 5qi7to6. ============${\n}
    sleep    3s
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    sleep    3s
    Airphone Qosflow Modify    qos_flow=11    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=8    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=11,12
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi5to7 5qi6to8. ============${\n}

    sleep    3s
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=5
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.fiveQI == 6'
    #  check failure after change maxNumOfNonGBRBearerSA
    Log    check ngap.radioNetwork radio-resourece not available 22
    Check NGAP PDUSESSIONMODIFY Failed In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    num=22
    Log To Console    ${\n}============Checked NGAP. ============${\n}
    Log    check drb-Id 6 7 in DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 2 && e1ap.dRB_ID == 6'
    ...    filter_expression='e1ap.dRB_ID == 7'
    Log    check drb-Id 8 9 in DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 2 && e1ap.dRB_ID == 8'
    ...    filter_expression='e1ap.dRB_ID == 9'
    Log    check drb-Id 10 11 in DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 2 && e1ap.dRB_ID == 10'
    ...    filter_expression='e1ap.dRB_ID == 11'
    Log To Console    ${\n}============Checked E1AP. ============${\n}
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_ToReleaseList == 2 && nr-rrc.DRB_Identity == 8'
    ...    filter_expression='nr-rrc.drb_ToReleaseList == 2 && nr-rrc.DRB_Identity == 9'
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # Counter Check NG_FLOW_MOD success   ${start_time}    ${end_time}
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${6}     fail_val=${2}


CB008126-A-B34 Successful 5QI modification of 2 flows in two different PDU session
    [Documentation]    author:keli
    ...    case8 two PDU
    ...    CRT case
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_case8
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi5. =============${\n}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=12 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Setup PDU2 5qi6. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=2
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    sleep    3s
    ${tput_v}    Airphone Get Average Throughput    pdu_id=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    pdu_id=2
    Should be true    ${tput_v}>=${tput_5m}

    Airphone Qosflow Modify    qos_flow=13    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=14    5qi=178    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=11    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=8    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=11 pdu=2 qosflows_to_modify=12 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}========= Modified PDU1 5qi5to7 PDU2 5qi6to8. ==========${\n}
    sleep    2s
    Airphone Qosflow Modify    qos_flow=11    5qi=179    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=180    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=11    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=7    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=11 pdu=2 qosflows_to_modify=12 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}============ Modified 5qi7to8 5qi8to7. ============${\n}

    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    sleep    2s

    Airphone Qosflow Modify    qos_flow=11    5qi=5    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=6    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=11 pdu=2 qosflows_to_modify=12 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}============ Modified 5qi8to5 5qi7to6. ============${\n}
    sleep    3s
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput    qfi=1    pdu_id=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=1    pdu_id=2
    Should be true    ${tput_v}>=${tput_5m}
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    sleep    3s
    Airphone Qosflow Modify    qos_flow=11    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=7    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=11 pdu=2 qosflows_to_modify=12 by=amf
    ...    pass_regexp=${None}

    Log To Console    ${\n}============ Modified 5qi5to8 5qi6to7. ============${\n}
    sleep    3s
    Airphone Get Average Throughput
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    # Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    # ...    5qi=5
    # # Check E1AP PDUSESSIONMODIFY In Wireshark Log    ${capture_file_path}
    # Check NGAP PDUSESSIONSETUP By Expression In Wireshark Log
    # ...    capture_file_path=${capture_file_path}
    # ...    filter='ngap.PDUSessionResourceSetupListSUReq == 1'
    # ...    filter_expression='ngap.fiveQI == 6'
    # Log    check ngap.radioNetwork radio-resourece not available 22
    # Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    # ...    capture_file_path=${capture_file_path}
    # ...    filter='ngap.PDUSessionResourceFailedToModifyListModRes == 2'
    # ...    filter_expression='ngap.cause == 0 && ngap.radioNetwork == 22'
    # Log To Console    ${\n}============Checked NGAP. ============${\n}
    # Log    check drb-Id 6,7 in each DRB-Removed-Item
    # Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    # ...    capture_file_path=${capture_file_path}
    # ...    filter='e1ap.dRB_Modified_List_NG_RAN == 1 && e1ap.dRB_ID == 6'
    # ...    filter_expression='e1ap.dRB_ID == 7'
    # Log    check drb-Id 8,9 in each DRB-Removed-Item
    # Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    # ...    capture_file_path=${capture_file_path}
    # ...    filter='e1ap.dRB_Modified_List_NG_RAN == 1 && e1ap.dRB_ID == 8'
    # ...    filter_expression='e1ap.dRB_ID == 9'
    # Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    # ...    capture_file_path=${capture_file_path}
    # ...    filter='e1ap.dRB_Modified_List_NG_RAN == 1 && e1ap.dRB_ID == 10'
    # ...    filter_expression='e1ap.dRB_ID == 11'
    # Log To Console    ${\n}============Checked E1AP. ============${\n}
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${6}     fail_val=${2}


CB008126-A-B34 Successful 5QI modification with simultaneous failed qosflow addition
    [Documentation]    author:keli
    ...    case9
    ...    CRT case
    ...    default setup 5qi8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=14 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi8. =============${\n}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}

    Airphone Qosflow Modify    qos_flow=12    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=14    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=14
    ...    qosflows_to_add=13
    ...    by=amf

    Log To Console    ${\n}============ Modified 5qi8to6 Added 5qi7. ============${\n}
    sleep    2s
    # Airphone Start Traffic    qfi_id=2    mbps=5m
    Airphone Get Average Throughput
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=8
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.fiveQI == 6'
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.qosFlowAddOrModifyResponseList == 1 && ngap.qosFlowFailedToAddOrModifyList == 1'
    ...    filter_expression='ngap.cause == 0 && ngap.radioNetwork == 22'
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${1}     fail_val=${0}


CB008126-A-B34 Successful 5QI modification with simultaneous qosflow addition when maxNumOfNonGBRBearersSA limit
    [Documentation]    author:keli
    ...    case11
    ...    CRT case
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_case11
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    sleep   2s

    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=13    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=12
    ...    qosflows_to_add=14
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi6to7 Added 5qi8. ============${\n}
    sleep    2s
    Airphone Start Traffic    qfi_id=2    mbps=5m
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=14    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=14
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi8to6. ============${\n}
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=6
    Log    Check Modified 5qi6 to7 Added 5qi8 in same msg
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.fiveQI == 8'
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.fiveQI == 7'
    Log    Check Modified 5qi8to6
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.fiveQI == 6'
    Sleep    2s
    Log    check drb-Id 5 6
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 2 && e1ap.dRB_ID == 5'
    ...    filter_expression='e1ap.dRB_ID == 6'
    Log    check drb-Id 7
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 1 && e1ap.dRB_ID == 7'
    ...    filter_expression='e1ap.dRB_ID == 7'
    Log To Console    ${\n}============Checked E1AP. ============${\n}
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 6'
    ...    filter_expression='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 6'
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check For NG_FLOW_Setup   ${start_time}    ${end_time}
    ...     success_val=${2}
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${2}     fail_val=${0}


CB008126-A-B34 Successful 5QI modification with additional NAS-PDU
    [Documentation]    author:keli
    ...    Case 5
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=13
    ...    by=amf
    Log To Console    ${\n}============= Added 5qi7. =============${\n}

    Airphone Qosflow Modify    qos_flow=14    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=15    5qi=8    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=15
    ...    by=amf

    Log To Console    ${\n}============ Modified 5qi9to5qi8. ============${\n}
    sleep    2s
    # Airphone Start Traffic    qfi_id=2    mbps=5m
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=9
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.fiveQI == 8'
    Log To Console    ${\n}============Checked NGAP. ============${\n}
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.qoS_Flow_Identifier == 1'
    ...    filter_expression='e1ap.dRB_Setup_List_NG_RAN == 1 && e1ap.dRB_ID == 6'
    # frame[169:2] DRB-Removed-Item
    #Log    check drb-Id 4 in DRB-Removed-Item
    # DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.dRB_Released_In_Session == 0'
    ...    filter_expression='e1ap.dRB_ID == 4'
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 4'
    ...    filter_expression='nr-rrc.drb_ToAddModList == 1 && nr-rrc.drb_Identity == 6'
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check For NG_FLOW_Setup   ${start_time}    ${end_time}
    ...     success_val=${2}
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${1}     fail_val=${0}


CB008126-A-B34 Successful 5QI-5 modification with simultaneous 5QI-1 release
    [Documentation]    case6
    ...    Default Setup 5QI-5
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=11 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi5. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=1
    ...    by=amf
    Log To Console    ${\n}============= Added 5qi1. =============${\n}

    Airphone Qosflow Modify    qos_flow=12    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=11    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=11
    ...    qosflows_to_del=1
    ...    by=amf

    Log To Console    ${\n}============ Modified 5qi5to6 release 5qi1. ============${\n}
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=5
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.fiveQI == 6'
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowListWithCause == 1 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.QosFlowListWithCause == 1 && ngap.qosFlowIdentifier == 2'
    Log    check ngap.radioNetwork not supported 5QI value 34
    Check NGAP PDUSESSIONMODIFY Failed In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    num=34
    Log To Console    ${\n}============Checked NGAP. ============${\n}
    Log    checked qfi2 with drb-index 5
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && e1ap.qoS_Flow_Identifier == 2'
    ...    filter_expression='e1ap.dRB_ID == 5'
    # frame[142:2] == 02:04 DRB-Removed-Item
    Log    check drb-Id 5 in DRB-Removed-Item
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.PDU_Session_Resource_Modified_List == 1 && frame[142:2] == 02:04'
    ...    filter_expression='e1ap.dRB_ID == 5'
    Log To Console    ${\n}============Checked E1AP. ============${\n}
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 5'
    ...    filter_expression='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 5'
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check For NG_FLOW_Setup   ${start_time}    ${end_time}
    ...     success_val=${2}
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${0}     fail_val=${1}


CB008126-A-B34 Successful 5QI modification with simultaneous addition and release of other flows
    [Documentation]    author:keli
    ...    case10
    ...    Default Setup 5QI-6
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_case11
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    sleep   2s

    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=13    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=12    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=12
    ...    qosflows_to_add=14
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi6to7 Added 5qi8. ============${\n}
    sleep    2s
    Airphone Start Traffic    qfi_id=2    mbps=5m
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=14    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=14
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi8to6. ============${\n}
    sleep    2s
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=6
    Log    Check Modified 5qi6 to7 Added 5qi8 in same msg
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.fiveQI == 8'
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 2 && ngap.qosFlowIdentifier == 1'
    ...    filter_expression='ngap.fiveQI == 7'
    Log    Check Modified 5qi8to6
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.QosFlowAddOrModifyRequestList == 1 && ngap.qosFlowIdentifier == 2'
    ...    filter_expression='ngap.fiveQI == 6'
    Sleep    2s
    Log    check drb-Id 5 6
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 2 && e1ap.dRB_ID == 5'
    ...    filter_expression='e1ap.dRB_ID == 6'
    Log    check drb-Id 7
    Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.dRB_Modified_List_NG_RAN == 1 && e1ap.dRB_ID == 7'
    ...    filter_expression='e1ap.dRB_ID == 7'
    Log To Console    ${\n}============Checked E1AP. ============${\n}
    Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 6'
    ...    filter_expression='nr-rrc.drb_ToReleaseList == 1 && nr-rrc.DRB_Identity == 6'
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${2}     fail_val=${0}


CB008126-A-B34 5QI modification for 5QI-2 without GBR resType
    [Documentation]    author:keli
    ...    case12
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_case12
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    Disable CB008379
    Log To Console    ${\n}=========== Disabled CB008479. ===========${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=dl
    ...    pdu_id=1
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Airphone Start Traffic    mbps=5m    dir=ul
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=11
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============= Added 5qi5. =============${\n}
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_add=1,2
    ...    by=amf
    Log To Console    ${\n}============= Added 5qi1,2. =============${\n}
    sleep    2s
    Airphone Qosflow Modify    qos_flow=12    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=2    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=2
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi2to6. ============${\n}

    sleep    5s
    # Airphone Start Traffic    qfi_id=2    mbps=5m
    Airphone Get Average Throughput
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
    ...    5qi=9
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    10 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check For NG_FLOW_Setup   ${start_time}    ${end_time}
    ...     success_val=${4}
    Counter Update Check For NG_FLOW_MOD   ${start_time}    ${end_time}
    ...     success_val=${0}     fail_val=${1}


*** Keywords ***
Disable CB008126
    [Documentation]    Disable 5QI, UL TNL tunnel IP modification function
    @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
    @{value_list}   Create List   false
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Enable CB008126
    [Documentation]    Enable 5QI, UL TNL tunnel IP modification function
    @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
    @{value_list}   Create List   true
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Disable CB008379
    @{cell_list}=    Create List    1    2
    @{para_list}   Create List   ${parameter_8379}
    @{value_list}   Create List   false
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END


Set Param maxNumOfNonGBRBearersSA
    [Arguments]    ${target_value}=${0}
    @{cell_l}=    Create List    1    2
    Change Param maxNumOfNonGBRBearersSA    @{cell_l}    target_value=${target_value}

Change Param maxNumOfNonGBRBearersSA
    [Arguments]    @{cell_list}    ${target_value}
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict1}=    create dictionary    parameterName=maxNumOfNonGBRBearersSA
    ...                              operation=update
    ...                              value=${target_value}
    ${parameter_list}    Create List    ${dict1}
    FOR   ${cell_i}    IN    @{cell_list}
        coam_admin.perform_object_recommissioning
        ...    dist_name=${dist_name}/NRCELL-${cell_i}
        ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    END
    [Teardown]    COAM_Admin.Logout    connection=commission


Check 5QI Initial Setup In NGAP
    [Arguments]  ${capture_file_path}    ${5qi}=9
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.qosFlowIdentifier == 1'
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.fiveQI == ${5qi}'

Check NGAP InitialContextSetup By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    InitialContextSetupRequest
    Should Contain    ${output}    InitialContextSetupResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}


Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=e1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    BearerContextSetupRequest
    Should Contain    ${output}    BearerContextModificationRequest
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    UEContextModificationRequest
    Should Contain    ${output}    UEContextModificationResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    RRC Reconfiguration Complete
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP RRC Reconfiguration In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    RRC Reconfiguration Complete


Check NGAP PDUSESSIONMODIFY Failed In Wireshark Log
    [Documentation]    check ngap.radioNetwork
    ...    ngap.radioNetwork == 22 radio resources not available
    ...    ngap.radioNetwork == 34 not supported 5QI value
    [Arguments]  ${capture_file_path}    ${num}=22
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceFailedToModifyListModRes == 1'
    ...    filter_expression='ngap.cause == 0 && ngap.radioNetwork == ${num}'

Check NGAP PDUSESSIONSETUP By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceSetupRequest
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Counter Check For NG_FLOW_Setup
    [Documentation]     NG_FLOW_Setup_ATT_TOT: M55125C08501
    ...                 NG_FLOW_Setup_SUCC:M55125C08502
    [Arguments]    ${starttime}    ${endtime}    ${success_val}=${0}
    PM_counters_collector
    ${pi_list}    Create List    M55125C08501    M55125C08502
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55125C08501}    Sum Counter Value Of Pi Value List    ${value1}    M55125C08501
    ${sum_M55125C08502}    Sum Counter Value Of Pi Value List    ${value1}    M55125C08502
    Should be true    ${sum_M55125C08501}>${0}
    Should be true    ${sum_M55125C08502}==${success_val}

Counter Update Check For NG_FLOW_MOD
    [Documentation]     NG_FLOW_MOD_ATT_TOT: M55125C00044
    ...                 NG_FLOW_MOD_FAIL:M55125C00045
    ...                 NG_FLOW_MOD_SUCC:M55125C00047
    [Arguments]    ${starttime}    ${endtime}    ${success_val}=${0}    ${fail_val}=${0}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55125C00044}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044
    ${sum_M55125C00045}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045
    ${sum_M55125C00047}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047
    ${sum_M55125C00047_45} =    Evaluate    ${sum_M55125C00045} + ${sum_M55125C00047}
    Should be true    ${sum_M55125C00045}==${fail_val}
    Should be true    ${sum_M55125C00047}==${success_val}
    Should be true    ${sum_M55125C00044}==${sum_M55125C00047_45}
