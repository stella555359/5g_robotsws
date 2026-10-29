*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008126-SR ET B32, B33 and B4 CRT cases script

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common MultiBTS Suite Setup For RRM
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM
# Force Tags         CRT/CIT/CDRT     #Tag Item
# # ...              PY27
# ...                RAN_5G                    #Product [RAN_5G]
# # ...              CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...                SBTS00           # it is for auto trigger by ute cloud with the release
# # ...              STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
# ...                RAN_PZ_HAZ_1             #Competence Area
# ...                RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout       60 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}
# # ${DEBUG_MODE}          ${TRUE}
# # ${REMOTE_MODE}       ${TRUE}
# # ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# ${PATH2}               /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone

# ${parameter}           act5qiAndUlNguTnlQosFlowMod
# ${dist_name}           MRBTS-1/NRBTS-1
# ${dist_name2}          MRBTS-1/NRBTS-1/NRCELL-1

# *** Test Cases ***
# CB008126-A-B32 Rejected 5QI modification due to act5qiAndUlNguTnlQosFlowModification with simultaneous addition success
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B32
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     Delete before PM counter file
#     ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

#     Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Airphone Start Traffic    mbps=5m
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     Disable CB008126
#     Log To Console      ${\n}============= CB008126 is disabled. =============${\n}

#     Log To Console      ${\n}============= Start to add 5QI-7 and modify 5QI-9 to 5QI-6. =============${\n}

#     Airphone Qosflow Modify    qos_flow=12    5qi=176    fiveqi_type=non-gbr
#     Airphone Qosflow Modify    qos_flow=15    5qi=6      fiveqi_type=non-gbr
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=13
#     ...    qosflows_to_modify=15
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Log To Console      ${\n}============= Modification is done. =============${\n}
#     Airphone Start Traffic    qfi_id=2    mbps=5m

#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check 5QI7 and 5QI6    starttime=${start_time}    endtime=${end_time}


# CB008126-A-B33 Failed 5QI modification due to unsupported type with simultaneous addition and release
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B33_1
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     Delete before PM counter file
#     ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

#     Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    mbps=5m
#     Log To Console      ${\n}============= Attach is done and DL traffic is started on 5QI-9. =============${\n}

#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=14
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Log To Console      ${\n}============= Dedicated 5QI-8 is added. =============${\n}

#     Airphone Start Traffic    qfi_id=2    mbps=5m
#     Log To Console      ${\n}============= DL traffic is started on 5QI-8. =============${\n}

#     Log To Console      ${\n}============= Start to add 5QI-7, modify 5QI-9 to 5QI-3 and release 5QI-8. =============${\n}

#     Airphone Qosflow Modify    qos_flow=3     5qi=133    fiveqi_type=non-gbr
#     Airphone Qosflow Modify    qos_flow=15    5qi=3      fiveqi_type=gbr
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=13
#     ...    qosflows_to_del=14
#     ...    qosflows_to_modify=15
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Airphone Start Traffic1    qfi_id=3    mbps=5m

#     Log To Console      ${\n}============= Operation is done, wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check 5QI7 and 5QI3 2    starttime=${start_time}    endtime=${end_time}

# CB008126-A-B33 Successful 5QI modification with failed GBR QoS flow addition due to CB008379 disabled
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B33_2
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     Delete before PM counter file
#     ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

#     Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    qfi_id=1    mbps=5m
#     Log To Console      ${\n}============= Attach is done and DL traffic is started on 5QI-9. =============${\n}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=14
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Log To Console      ${\n}============= Dedicated 5QI-8 is added. =============${\n}
#     Airphone Start Traffic    qfi_id=2    mbps=5m
#     Log To Console      ${\n}============= DL traffic is started on 5QI-8. =============${\n}

#     Log To Console      ${\n}============= Start to add 5QI-3, modify 5QI-9 to 5QI-7 and release 5QI-8. =============${\n}

#     Airphone Qosflow Modify    qos_flow=13    5qi=177    fiveqi_type=non-gbr
#     Airphone Qosflow Modify    qos_flow=15    5qi=7      fiveqi_type=non-gbr
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=3
#     ...    qosflows_to_del=14
#     ...    qosflows_to_modify=15
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Airphone Start Traffic1    qfi_id=3    mbps=5m
#     Log To Console      ${\n}============= Operation is done, wait for counters =============${\n}

#     Sleep    10 min    reason=wait for counter ready
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check 5QI7 and 5QI3    starttime=${start_time}    endtime=${end_time}


# *** Keywords ***
# Disable CB008126     #Disable 5QI, UL TNL tunnel IP modification function
#     Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
#     ${value}    Set Variable    false
#     coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
#     ...    value=${value}    operation=update    connection=commission
#     [Teardown]    COAM_Admin.Logout    connection=commission


# Counter Check 5QI7 and 5QI6
#     [Arguments]    ${starttime}    ${endtime}
#     PM_counters_collector
#     ${pi_list}    Create List    M55319C12007    M55319C12006
#     ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
#     ...    ${pi_list}
#     Log To Console    ${value1}
#     ${sum_M55319C12007}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12007
#     ${sum_M55319C12006}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12006
#     Should be true    ${sum_M55319C12007}!=${0}
#     Should be true    ${sum_M55319C12006}==${0}


# Counter Check 5QI7 and 5QI3
#     [Arguments]    ${starttime}    ${endtime}
#     PM_counters_collector
#     ${pi_list}    Create List    M55319C12007    M55319C12003
#     ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
#     ...    ${pi_list}
#     Log To Console    ${value1}
#     ${sum_M55319C12007}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12007
#     ${sum_M55319C12003}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12003
#     Should be true    ${sum_M55319C12007}!=${0}
#     Should be true    ${sum_M55319C12003}==${0}


# Counter Check 5QI7 and 5QI3 2
#     [Arguments]    ${starttime}    ${endtime}
#     PM_counters_collector
#     ${pi_list}    Create List    M55319C12007    M55319C12003
#     ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
#     ...    ${pi_list}
#     Log To Console    ${value1}
#     ${sum_M55319C12007}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12007
#     ${sum_M55319C12003}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12003
#     Should be true    ${sum_M55319C12007}==${0}
#     Should be true    ${sum_M55319C12003}==${0}


# Airphone Start Traffic1          # Customize to cancel checking command return value
#     [Documentation]    Author: He winnie
#     ...                Contact: winnie.he@nokia-sbell.com
#     [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${dir}=dl
#     ...     ${pdu_id}=1    ${time_len}=5s
#     ...     ${trf_id}=1    ${mbps}=176m
#     ...     ${qfi_id}=1    ${call_type}=SA
#     ...     ${time}=999
#     ${tputvalue_unit}    Run Keyword If    'm' in '${mbps}'    Set Variable    m
#     ...    ELSE IF    'k' in '${mbps}'
#     ...    Set Variable    k
#     ...    ELSE    Set Variable    m
#     ${tput_value}    Get Regexp Matches    ${mbps}    \\d+
#     ${dir_upper}    Convert To Upper Case    ${dir}
#     Run Keyword     _airphone.Start ${dir_upper} Traffic1
#     ...    ue_id=${ue_id}    bearer_id=${bearer_id}    tput_value=${tput_value}[0]
#     ...    trf_id=${trf_id}
#     ...    unit=${tputvalue_unit}
#     ...    during=${time}
#     ...    call_type=${call_type}
#     ...    qfi_id=${qfi_id}
#     ...    pdu_id=${pdu_id}
#     Sleep    ${time_len}    reason=wait ${dir_upper} traffic is stable

# _airphone.Start DL Traffic1          # Customize to cancel checking command return value
#     [Documentation]    Author: He winnie
#     ...                Contact: winnie.he@nokia-sbell.com
#     ...    this keyword is to start big dl udp traffic which more than 175.
#     [Arguments]    ${ue_id}    ${bearer_id}    ${tput_value}    ${trf_id}=1    ${qfi_id}=1
#     ...    ${unit}=m    ${during}=9999    ${call_type}=NSA    ${pdu_id}=1
#     ${dl_times}    Run Keyword if    '${unit}'=='m'     Evaluate    int(${tput_value}/${175})
#     ...    ELSE    Set Variable     ${0}
#     FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
#         ${tmp_trf_id}    Evaluate    int(${trf_id})+${t_time}-1
#         ${cmd}     _airphone.get traffic cmd    ue_id=${ue_id}
#         ...     bearer_id=${bearer_id}
#         ...     dir=dl
#         ...     pdu_id=${pdu_id}
#         ...     trf_id=${tmp_trf_id}
#         ...     mbps=175
#         ...     qfi_id=${qfi_id}
#         ...     call_type=${call_type}
#         ute_wtssim.Execute Egate Command And Wait For Data
#         ...    cmd=${cmd} seconds\=${during}
#         ...    timeout=60
#         Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
#     END
#     ${last_tput_value}    Evaluate    ${tput_value}%${175}
#     ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
#     ${cmd}     _airphone.get traffic cmd    ue_id=${ue_id}
#         ...     bearer_id=${bearer_id}
#         ...     dir=dl
#         ...     pdu_id=${pdu_id}
#         ...     trf_id=${last_trf_id}
#         ...     mbps=${last_tput_value}
#         ...     qfi_id=${qfi_id}
#         ...     call_type=${call_type}
#     Run Keyword If    '${last_tput_value}'!='0'    ute_wtssim.Execute Egate Command And Wait For Data
#     ...    cmd=${cmd} seconds\=${during}
#     ...    timeout=60
#     Run Keyword If    '${last_tput_value}'!='0'    Log To Console
#     ...    \nUE${ue_id} Start DL ${last_tput_value}${unit} Traffic for trf_id=${last_trf_id}

# _airphone.Start UL Traffic1
#     [Documentation]    Author: He winnie
#     ...                Contact: winnie.he@nokia-sbell.com
#     ...    This keyword is to start traffic on eGate.
#     ...    Expected output is: "UE IS ACTIVE" on eGate.
#     ...    | Input Parameters | Man. | Description |
#     ...    | ue_id | Yes | ue id |
#     ...    | bearer_id | Yes | bearer_id |
#     ...    | mbps | Yes | mbps |
#     ...    | trf_id | No | trf_id, default is 1 |
#     ...    Example:
#     ...    | NSA Start UL Traffic | 1 | 2 | 10 |
#     [Arguments]    ${ue_id}    ${bearer_id}    ${tput_value}    ${trf_id}=1
#     ...    ${unit}=m    &{kwargs}
#     Log To Console    start UL traffic...
#     ${cmd}    Catenate    ue\=${ue_id} id\=${bearer_id} dir=ul ${unit}bps\=${tput_value}
#     ...    trf_id\=${trf_id} seconds=${kwargs}[during]
#     ute_wtssim.Execute Egate Command
#     ...    cmd=trf_data_start ${cmd}