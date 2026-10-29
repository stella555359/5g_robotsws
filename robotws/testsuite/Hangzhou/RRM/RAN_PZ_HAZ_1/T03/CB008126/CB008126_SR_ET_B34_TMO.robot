*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB008126-SR B34
...   Default B34 WTS cfg file is wts_SA_TDD_2c_1gNBSim_B34_TMO
...   Default 5QI is 6
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot

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
# ...      CLOUD_5G_I_LOO_AP_LOOO   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS25R1           # it is for auto trigger by ute cloud with the release
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
${tput_15m}            16500000
# ${REMOTE_MODE}           ${TRUE}
${Ignore_Cell_Id_For_Sib}    5    6    9    12
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
    ...         NG_FLOW_MOD_ATT_TOT: M55125C00044
    ...         NG_FLOW_MOD_FAIL:M55125C00045
    ...         NG_FLOW_MOD_SUCC:M55125C00047
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_04.txt
    Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=4 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi9 and 7. =============${\n}
    sleep    1s
    Start Traffic Both DL and UL
    ${arg_tput_ul_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}

    Airphone Qosflow Modify    qos_flow=1    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=4    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=4
    ...    qosflows_to_del=2
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi9to6 release 5qi7. ============${\n}
    sleep    5s
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Start Traffic Both DL and UL
    # sleep    10s
    ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    Log To Console    ${\n}============ Checked Tput. ============${\n}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}


CB008126-A-B34 Successful 5QI modification of 2 flows in single PDU session
    [Documentation]    author:keli
    ...    case7
    ...    CRT case
    ...    Default Setup 5QI-5
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_07.txt

    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=1
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA

    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi5 and 6. =============${\n}
    Start Traffic Both DL and UL
    sleep    2s
    Start Traffic Both DL and UL    qfi_id=2
    sleep    10s
    ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=2    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    Airphone Qosflow Modify    qos_flow=2    5qi=176    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=3    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=5    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=8    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=5,1
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi5to7 5qi6to8. ============${\n}

    Airphone Qosflow Modify    qos_flow=5    5qi=178    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=179    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=5    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=5,1
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi7to8 5qi8to7. ============${\n}

    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    sleep    2s

    Airphone Qosflow Modify    qos_flow=5    5qi=5    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=5,1
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi8to5 5qi7to6. ============${\n}
    sleep    3s
    ${tput_v}    Airphone Get Average Throughput    qfi=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    qfi=2
    Should be true    ${tput_v}>=${tput_5m}
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    sleep    3s
    Airphone Qosflow Modify    qos_flow=5    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=8    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=5,1
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
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

CB008126-A-B34 Successful 5QI modification of 2 flows in two different PDU session
    [Documentation]    author:keli
    ...    case8 two PDU
    ...    CRT case
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_08.txt
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Log To Console      ${\n}============= Setup PDU1 5qi5. =============${\n}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Setup PDU2 5qi6. =============${\n}
    Start Traffic Both DL and UL    pdu_id=1
    sleep    1s
    Start Traffic Both DL and UL    pdu_id=2
    sleep    3s
    ${tput_v}    Airphone Get Average Throughput    pdu_id=1
    Should be true    ${tput_v}>=${tput_5m}
    ${tput_v}    Airphone Get Average Throughput    pdu_id=2
    Should be true    ${tput_v}>=${tput_5m}

    Airphone Qosflow Modify    qos_flow=2    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=3    5qi=178    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=5    5qi=7    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=8    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=5 pdu=2 qosflows_to_modify=1 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}========= Modified PDU1 5qi5to7 PDU2 5qi6to8. ==========${\n}
    sleep    2s
    Airphone Qosflow Modify    qos_flow=5    5qi=179    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=180    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=5    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=7    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=5 pdu=2 qosflows_to_modify=1 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}============ Modified 5qi7to8 5qi8to7. ============${\n}

    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    sleep    2s

    Airphone Qosflow Modify    qos_flow=5    5qi=5    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=6    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=5 pdu=2 qosflows_to_modify=1 by=amf
    ...    pass_regexp=${None}
    Log To Console    ${\n}============ Modified 5qi8to5 5qi7to6. ============${\n}
    sleep    3s
    ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=2    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    sleep    3s
    Airphone Qosflow Modify    qos_flow=5    5qi=8    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=7    fiveqi_type=non-gbr
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=5 pdu=2 qosflows_to_modify=1 by=amf
    ...    pass_regexp=${None}

    Log To Console    ${\n}============ Modified 5qi5to8 5qi6to7. ============${\n}
    sleep    3s
    Airphone Get Average Throughput
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

CB008126-A-B34 Successful 5QI modification with simultaneous failed qosflow addition
    [Documentation]    author:keli
    ...    case9
    ...    CRT case
    ...    default setup 5qi8
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_09.txt
    Set Param maxNumOfNonGBRBearersSA    ${1}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 1. ===========${\n}
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi8. =============${\n}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Start Traffic Both DL and UL
    ${arg_tput_ul_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    Airphone Qosflow Modify    qos_flow=1    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=3    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=3
    ...    qosflows_to_add=2
    ...    by=amf

    Log To Console    ${\n}============ Modified 5qi8to6 Added 5qi7. ============${\n}
    sleep    2s
    # Airphone Start Traffic    qfi_id=2    mbps=5m
    Airphone Get Average Throughput
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Sleep    2s
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

CB008126-A-B34 Successful 5QI modification with simultaneous qosflow addition when maxNumOfNonGBRBearersSA limit
    [Documentation]    author:keli
    ...    case11
    ...    CRT case
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B34_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_11.txt
    Set Param maxNumOfNonGBRBearersSA    ${2}
    Log To Console    ${\n}=========== Changed maxNumOfNoGBRBearSA to 2. ===========${\n}
    # Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Attach    ue_id=1    call_type=SA
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Attach is done. =============${\n}
    Start Traffic Both DL and UL
    sleep   2s

    ${tput_v}    Airphone Get Average Throughput
    Should be true    ${tput_v}>=${tput_5m}
    Airphone Qosflow Modify    qos_flow=2    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=1
    ...    qosflows_to_add=3
    ...    by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi6to7 Added 5qi8. ============${\n}
    sleep    2s
    Start Traffic Both DL and UL    qfi_id=2
    sleep    2s
    ${arg_tput_ul_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=2    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    Airphone Qosflow Modify    qos_flow=3    5qi=6    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=3
    ...    by=amf
    Log To Console    ${\n}============ Modified 5qi8to6. ============${\n}
    sleep    2s
    ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=2    dir=dl    expected_tput_max=${tput_15m}    expected_tput_min=${tput_5m}
    # stop tcpdump in sbts by command
    # ${capture_file_path}    Download wireshark log to testvm
    # Airphone Start Traffic    mbps=100m    dir=ul
    Airphone Stop Traffic
    Log To Console      ${\n}============= Wait for counters =============${\n}
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}


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

Set Param maxNumOfNonGBRBearersSA
    [Arguments]    ${target_value}=${0}
    @{cell_l}=    Create List    1    2    3    4    5    6
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

Check Ave Tput via bearer stats
    [Documentation]     check the average of two tput value
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${qfi_id}=1
    ...    ${dir}=dl   ${expected_tput_max}=10000000    ${expected_tput_min}=0
    ${tput_v1}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    sleep    2s
    ${tput_v2}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    ${arg_tput}=    Evaluate    (${tput_v1} + ${tput_v2})/2
    Should be true    ${arg_tput}<=${expected_tput_max}
    Should be true    ${arg_tput}>=${expected_tput_min}
    [Return]    ${arg_tput}

Set Pdu Param For Trf Data
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${trf_type}=internal
    Airphone Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_type=${trf_type}
    ...    pass_regexp=${None}
    sleep    1s

Start Traffic Both DL and UL
    [Arguments]    ${mbps}=5m    ${pdu_id}=1    ${qfi_id}=1
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=${mbps}    dir=dl
    ...    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=${mbps}    dir=ul
    ...    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
