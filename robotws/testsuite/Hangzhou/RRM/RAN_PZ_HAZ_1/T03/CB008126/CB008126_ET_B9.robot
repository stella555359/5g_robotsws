*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008126-SR B9 CRT cases script

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
# ...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20, TA_LEVEL_21, TA_LEVEL_22]


# Test Timeout       60 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}
# # ${DEBUG_MODE}          ${TRUE}
# # ${REMOTE_MODE}       ${TRUE}
# # ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# # ${PATH2}               /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone

# *** Test Cases ***
# case38_CB008126 interact with CB008124_01_Successful_5QI_Modification_initiated_by_5GC_for_an_existing_non_GBR_QoS_Flow
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B9
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

#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_add=14
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID

#     Airphone Start Traffic    dir=dl    qfi_id=2    mbps=5m
#     # Airphone Start Traffic    dir=ul    qfi_id=2    mbps=5m
#     Log To Console      ${\n}============= 5QI-8 is setup and DL traffic is also started =============${\n}

#     Log To Console      ${\n}============= Start to modify 5QI-8 to 5QI-7 and CG setup on 5QI-7. =============${\n}

#     Airphone Qosflow Modify    qos_flow=13    5qi=176    fiveqi_type=non-gbr
#     Airphone Qosflow Modify    qos_flow=14    5qi=7      fiveqi_type=non-gbr
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    qosflows_to_modify=14
#     ...    by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Log To Console      ${\n}============= Modification is done. =============${\n}
#     # Airphone Start Traffic    dir=ul    qfi_id=2    mbps=50m

#     Log To Console      ${\n}============= Wait for counters =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
#     Counter Check 5QI7 and CG Setup    starttime=${start_time}    endtime=${end_time}

# *** Keywords ***
# Counter Check 5QI7 and CG Setup
#     [Arguments]    ${starttime}    ${endtime}
#     PM_counters_collector
#     ${pi_list}    Create List    M55319C12007    M55166C00005
#     ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
#     ...    ${pi_list}
#     Log To Console    ${value1}
#     ${sum_M55319C12007}    Sum Counter Value Of Pi Value List    ${value1}    M55319C12007
#     ${sum_M55166C00005}    Sum Counter Value Of Pi Value List    ${value1}    M55166C00005
#     Should be true    ${sum_M55319C12007}!=${0}
#     Should be true    ${sum_M55166C00005}!=${0}