*** Settings ***
Documentation
...   Author: Nie Rong
...   Contact: rong.nie@nokia-sbell.com
...   Description: Verification of feature UCLPC activation/deactivation depending on activation settings for PUCCH,PUSCH and SRS.
...                CB007802_5GC000884_A_C_PUSCH_SRS_Feature_activation_deactivation
...                CB007802_5GC000884_B_C_PUCCH_Feature_activation_deactivation
...                CB007802-Non-requirement_CB007802_UL_Peak_TPUT_with_multi_features_on
...    Deprecated case removed by civen.chen
#
#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC
#
#Force Tags
#...                CA_RAN_PZ_HAZ_1
#...                RAN_PZ_HAZ1_SG02_ST_RRM
#...                TA_LEVEL_22
#...                CRT
#...                TRUNK
#
#
#Test Timeout    60 minutes
#
#Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
#
#
#
#
#*** Test Cases ***
#[1]CB007802_5GC000884_A_C_PUSCH_SRS_Feature_activation_deactivation
#    [Tags]    CRT    CB007802
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com, draft
#    Check both vDU and vCU cells should be onair
#    Prepare UE0
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#
#
#[1]CB007802_5GC000884_B_C_PUCCH_Feature_activation_deactivation
#    [Tags]    CRT    CB007802
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com, draft
#    Check both vDU and vCU cells should be onair
#    Set The Value of actUlClosedLoopPwrCtrl is pucch
#    Prepare UE0
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#
#[1]CB007802_UL_Peak_TPUT_with_multi_features_on
#    [Tags]    CRT    CB007802
#    [Documentation]
#    ...    Author: rong.nie@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.03.2022,rong.nie@nokia-sbell.com, draft
#    Check both vDU and vCU cells should be onair
#    Set The Value of actUlClosedLoopPwrCtrl is pucch
#    Prepare UE0
#    Attach UE0 And Start UL TPUT
#    Check UL Tput By K8s Log
#    Stop UL THPUT And Detach UE0
#
#
#*** Keywords ***
#Check both vDU and vCU cells should be onair
#    Log To Console    \n*** check on air state in cu ***
#    wait until keyword succeeds    900    20
#    ...        Check All Cells On Air In vCU
#    Log To Console    \n*** check on air state in du ***
#    wait until keyword succeeds    900    20
#    ...        vDU Check All Cells Status Should Be Onair
#
#Attach UE0 And Start UL TPUT
#    Log To Console    Attach UE0 And Start UL TPUT
#    Attach UE0
#    sleep    60s
#    Start UL TPUT for UE0
#    sleep    10s
#
#Prepare UE0
#    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    Set Test Variable    ${ue0_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue0_type}    ue_index=${0}
#
#Attach UE0
#    Log to Console    \n***UE Attach***
#    UE Attach    ${ue0_type}    ue_index=${0}
#
#Start UL TPUT for UE0
#    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
#    ...              throughput=100M    duration=${300}
#
#Stop UL THPUT And Detach UE0
#    log to console    Stop UL THPUT And Detach UE0
#    Stop UL THPUT for UE0
#    Detach UE0
#
#Stop UL THPUT for UE0
#    log to console    Stop UL THPUT for UE0
#    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul
#
#Detach UE0
#    Log to Console    \n***UE Detach***
#    UE Detach    ${ue0_type}    ue_index=${0}
#
#Check UL Tput By K8s Log
#    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
#    ...                                                     container_name=l2rt    pod_name=up   timeout=${10}
#    Set Test Variable    ${ul_l2rt_tput_local_file_path}
#    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
#    should be true  ${max_ul_tput}>20
#
#Set The Value of actUlClosedLoopPwrCtrl is ${value}
#   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#   &{parameter_dict_new}    Create Dictionary   actUlClosedLoopPwrCtrl=${value}
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict_new}
#    ...                                          operation=replace
#    ...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${True}
#    ...                                          wait_vdu_up=${False}
#    [Teardown]   vDU Logout By Rest
#
#
