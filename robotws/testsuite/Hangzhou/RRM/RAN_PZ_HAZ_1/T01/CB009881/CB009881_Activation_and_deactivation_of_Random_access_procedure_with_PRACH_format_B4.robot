*** Settings ***
Documentation
...   Author: Xiang Liang
...   Contact: liang.xiang@nokia-sbell.com
...   Description: This case describes the support of the activation and deactivation of PRACH format B4 per cell,
...                and the support of both starting symbol 0 and 2

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    50 minutes

Resource    ../../Resources/Cloud/AIC_Common_Resource.robot



*** Test Cases ***
[1]5GC001304_Activation_and_deactivation_of_Random_access_procedure_with_PRACH_format_B4
    [Tags]    QC_504869           QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: liang.xiang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.11.2021,liang.xiang@nokia-sbell.com
    Adjust PA Signal To Attach
    sleep   5
#    Set The Value of PrachConfigurationIndex To 159
#    Start Wireshark Log In vDU
    Prepare UE0
    Attach UE0
    Start DL Call For UE0
    Start UL Call For UE0
    sleep    30
    Check DL Tput By K8s Log
    Check UL Tput By K8s Log
#    Stop Wireshark Log And Check Prachindex 159
    Detach UE0
#    Set the value of prachConfigurationIndex to 89
#    Start Wireshark Log In vDU
#    Stop Wireshark Log And Check Prachindex 89

#



[1]CB007802_5GC000884_A_C_PUSCH_SRS_Feature_activation_deactivation
    [Tags]    QC_504874           QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: rong.nie@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.03.2022,rong.nie@nokia-sbell.com
    Check both vDU and vCU cells should be onair
    Prepare UE0
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0


[1]CB007802_5GC000884_B_C_PUCCH_Feature_activation_deactivation
    [Tags]    QC_504873            QCD_MN_RAN      QCP_RAN_ST
    [Documentation]
    ...    Author: rong.nie@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.03.2022,rong.nie@nokia-sbell.com
    Check both vDU and vCU cells should be onair
#    Set The Value of actUlClosedLoopPwrCtrl is pucch
    Prepare UE0
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is pucchPuschSrs
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0
#    Set The Value of actUlClosedLoopPwrCtrl is disabled
    Attach UE0 And Start UL TPUT
    Check UL Tput By K8s Log
    Stop UL THPUT And Detach UE0


*** Keywords ***
Adjust PA Signal To Attach
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TOPYOUNG    du_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=20    ${attenuation_channels[1]}=20    ${attenuation_channels[2]}=40
    ...    ${attenuation_channels[3]}=40    ${attenuation_channels[4]}=40    ${attenuation_channels[5]}=40
    ...    ${attenuation_channels[6]}=40    ${attenuation_channels[7]}=40    ${attenuation_channels[8]}=40
    ...    ${attenuation_channels[9]}=40    ${attenuation_channels[10]}=40   ${attenuation_channels[11]}=40
    ...    ${attenuation_channels[12]}=40   ${attenuation_channels[13]}=40   ${attenuation_channels[14]}=40
    ...    ${attenuation_channels[15]}=40
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    attenuation change complete

Set The Value of PrachConfigurationIndex to ${value}
   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
   &{parameter_dict_new}    Create Dictionary   prachConfigurationIndex=${value}
   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
   vDU Login By Rest
   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict_new}
	...                                          operation=replace
	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${True}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Prepare UE0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	Set Test Variable    ${ue0_type}
	Log to Console    \n***Prepare UE***
    Prepare UE    ${ue0_type}    ue_index=${0}    ui_version=MATE40PROUI1.0

Stop Wireshark Log And Check prachindex ${value}
    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    vdu_index=${0}
    ...                                                                    container_name=nwmgmt
    ...                                                                    pod_name=cprt
    ...                                                                    timeout=${10}
    ...                                                                    log_name=prach_${value}
    ${_filter} =    catenate    nr-rrc.prach_ConfigurationIndex == ${value}
    ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
	...                                      filter_expression=${_filter}
	should contain    ${result}    RRC Setup Request
    should contain    ${result}    UEContextModificationResponse
    ${measgap_filter} =    catenate    nr-rrc.c1 == 2
    ${result2} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
	...                                        filter_expression=${measgap_filter}


Start Collect Wireshark Log In vDU
    [Arguments]    ${container_name}=cprt    ${pod_name}=cprt
    Log To Console    ${container_name}
    Log To Console    ${pod_name}
    Start Wireshark Log In vDU   gnb_index=${0}
    ...                          vdu_index=${0}
    ...                          container_name=cprt
    ...                          pod_name=cprt
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any

Check DL Tput By K8s Log
    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                      container_name=l2rt    pod_name=l2rt   timeout=${10}
    Set Test Variable    ${dl_l2rt_tput_local_file_path}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
    should be true  ${max_dl_tput}>100

Check UL Tput By K8s Log
    ${ul_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                                     container_name=l2rt    pod_name=l2rt   timeout=${10}
    Set Test Variable    ${ul_l2rt_tput_local_file_path}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${ul_l2rt_tput_local_file_path}
    should be true  ${max_ul_tput}>25

Attach UE0
    Log to Console    \n***UE Attach***
    UE Attach    ${ue0_type}    ue_index=${0}    verify_attach=True

Start DL Call For UE0
    [Arguments]    ${throughput}=800M    ${duration}=${100}
    Log To Console    \nStart the DL TPUT
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=${throughput}    duration=${duration}

Start UL Call For UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=500M    duration=${100}

Set The Value of actUlClosedLoopPwrCtrl is ${value}
   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
   &{parameter_dict_new}    Create Dictionary   actUlClosedLoopPwrCtrl=${value}
   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
   vDU Login By Rest
   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict_new}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${True}
    ...                                          wait_vdu_up=${False}
    [Teardown]   vDU Logout By Rest

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

Check both vDU and vCU cells should be onair
    Log To Console    \n*** check on air state in cu ***
    wait until keyword succeeds    900    20
    ...        Check All Cells On Air In vCU
    Log To Console    \n*** check on air state in du ***
    wait until keyword succeeds    900    20
    ...        vDU Check All Cells Status Should Be Onair

Stop UL THPUT for UE0
    log to console    Stop UL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul

Start UL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
    ...              throughput=100M    duration=${300}

Detach UE0
    Log to Console    \n***UE Detach***
    UE Detach    ${ue0_type}    ue_index=${0}

Stop Wireshark Log And Check CiPHER
    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=nwmgmt
    ...                                                                    pod_name=cpif
    ...                                                                    timeout=${10}
    ...                                                                    log_name=5QI
    ${cipher_filter} =    catenate    nr-rrc.cipheringAlgorithm == 2
    ${integrity_filter} =    catenate    nr-rrc.integrityProtAlgorithm == 2
    ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
	...                                      filter_expression=${cipher_filter}
	${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
	...                                      filter_expression=${integrity_filter}

Stop call
    Stop traffic    ue_type=${ue0_type}       direction=dl
    UE Detach    ${ue0_type}    ue_index=${0}
