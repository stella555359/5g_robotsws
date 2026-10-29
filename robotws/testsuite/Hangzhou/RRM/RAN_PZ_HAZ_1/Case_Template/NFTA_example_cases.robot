*** Settings ***
Documentation
...   Author: liu, renhui
...   Contact: renhui-david.liu@nokia-sbell.com
...   Description: This file shows example cases for new feature TA.


Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For NFTA
Test Teardown     Common Test Teardown For NFTA

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT

Test Timeout    600 minutes

Resource    ../Resources/Cloud/AIC_Common_Resource.robot



*** Test Cases ***
NFTA_Example_Case_01
    [Tags]    CRT
    [Documentation]
    ...    Author: renhui-david.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    07.10.2023, renhui-david.liu@nokia-sbell.com, draft
    Prepare UE0
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0


*** Keywords ***
Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue0_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue0_type}    ue_index=${0}    ui_version=MATE40PROUI1.0

Check UL Tput By K8s Log
    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...     container_name=l2rt    pod_name=l2rt   timeout=${10}
    Set Test Variable    ${ul_l2rt_tput_local_file_path}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
    should be true  ${max_ul_tput}>25

Attach UE0
    Log to Console    \n***UE Attach***
    UE Attach    ${ue0_type}    ue_index=${0}    verify_attach=True

Start UL Call For UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
    ...              throughput=500M    duration=${100}

Attach UE0 And Start UL TPUT
    Log To Console    Attach UE0 And Start UL TPUT
    Attach UE0
    sleep    60s
    Start UL TPUT for UE0
    sleep    10s

Stop UL THPUT And Detach UE0
    log to console    Stop UL THPUT And Detach UE0
    Stop UL THPUT for UE0
    Detach UE0

Stop UL THPUT for UE0
    log to console    Stop UL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul

Start UL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
    ...              throughput=100M    duration=${300}

Detach UE0
    Log to Console    \n***UE Detach***
    UE Detach    ${ue0_type}    ue_index=${0}
