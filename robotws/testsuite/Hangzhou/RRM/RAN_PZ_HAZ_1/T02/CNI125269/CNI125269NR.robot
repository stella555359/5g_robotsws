*** Settings ***
Documentation
...   author: Yongjie Liu
...   contact: yongjie.liu@nokia-sbell.com
...   this is a robot case about CNI-125269.

Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
Resource           ../../Resources/Classical/RRM_Common_Resource.robot
Resource           ../../Resources/Common/Airphone.robot
Suite Setup        Common MultiBTS Suite Setup For RRM
Test Setup         Common MultiBTS Test Setup For RRM
Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
Suite Teardown     Common MutliBTS Suite Teardown For RRM
Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG05_ST_RRM    TA_LEVEL_22


Test Timeout       30 minutes

*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}
# ${DEBUG_MODE}          ${TRUE}
# ${REMOTE_MODE}       ${TRUE}
# ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# ${PATH2}               /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ7/CB008126/Airphone

*** Test Cases ***
CNI-125269-ST-2 RNL Normal Release is used for the SgNB Release Request message in the UE triggered EN-DC takeback scenario-NR part
    [Tags]    QC_99348
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.08.2024,yongjie.liu@nokia-sbell.com,case template draft
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_FDDTDD_8c_1gNBSim
    ...    base_path=${CURDIR}/Airphone
    Delete before PM counter file
    # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # ${start_time}    Subtract Time From Date    ${start_time}    5 minutes

    # Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
    # Airphone Attach    ue_id=1    call_type=SA
    # Log To Console      ${\n}============= Attach is done. =============${\n}
    # Airphone Start Traffic    mbps=5m
    # Log To Console      ${\n}============= DL traffic is started. =============${\n}

    # ${ret}    airphone_pdu_session_modify    ue_id=1
    # ...    pdu_id=1
    # ...    qosflows_to_add=14
    # ...    by=amf
    # ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID

    # Airphone Start Traffic    dir=dl    qfi_id=2    mbps=5m
    # # Airphone Start Traffic    dir=ul    qfi_id=2    mbps=5m
    # Log To Console      ${\n}============= 5QI-8 is setup and DL traffic is also started =============${\n}

    # Log To Console      ${\n}============= Start to modify 5QI-8 to 5QI-7 and CG setup on 5QI-7. =============${\n}

    # Airphone Qosflow Modify    qos_flow=13    5qi=176    fiveqi_type=non-gbr
    # Airphone Qosflow Modify    qos_flow=14    5qi=7      fiveqi_type=non-gbr
    # ${ret}    airphone_pdu_session_modify    ue_id=1
    # ...    pdu_id=1
    # ...    qosflows_to_modify=14
    # ...    by=amf
    # ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    # Log To Console      ${\n}============= Modification is done. =============${\n}
    # # Airphone Start Traffic    dir=ul    qfi_id=2    mbps=50m

    # Log To Console      ${\n}============= Wait for counters =============${\n}
    # Sleep    10 min    reason=wait for counter ready
    # ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # Counter Check 5QI7 and CG Setup    starttime=${start_time}    endtime=${end_time}
