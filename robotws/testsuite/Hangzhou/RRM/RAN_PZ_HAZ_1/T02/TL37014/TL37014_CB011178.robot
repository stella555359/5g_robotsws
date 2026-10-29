*** Settings ***
Documentation
...    Author: Zou Shuang
...    Contact: shuang.zou@nokia-sbell.com
...    this file is for CB010411.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen
#
#Suite Setup    Common Suite Setup For AIC
#Suite Teardown     Custom Suite Teardown For AIC
#
#Force Tags
#...      CRT             #Tag Item
#...      RAN_PZ_HAZ_1             #Competence Area
#...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
#...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]
#
#Test Timeout    60 minutes
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#
#*** Variables ***
#${TESTLINE_NAME}                  7_5_UTE5GAIC0123T002
#${testline_configuration_path}    ~${/}testline_configuration
#
#*** Test Cases ***
## CB011178_Successful_Inter-frequency_Inter-gNB_handover_between_FDD_TDD_cells_based_on_A3_A5_measurements
##     [Tags]    CB011178    4.0    RAN_PZ_HAZ_1
##     [Documentation]
##     ...    Author: shuang.zou@nokia-sbell.com
##     ...    history change: <date>,<who>,<what and how>
##     ...    22.03.2022, shuang.zou@nokia-sbell.com, draft
##     [Setup]    Common Case Precondition
##     [Timeout]    1h
##     Change PA to NR1CELL
##     Prepare And Attach UE    ue_index=0
##     Change PA to NR2CELL
##     wait until keyword succeeds   30min  30s   Check CU Counter Update For HO
##     [Teardown]    Common Case Postcondition
#
#CB010413_02_CB008159_NR_Additional_PM_counters_Verify_on_FDD_NSA
#    [Tags]        CRT      CB008159
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    29.2.2024,juan.liu@nokia-sbell.com, draft
#    [Setup]        Common Case Precondition
#    Set Library Search Order    AIC_UE    real_ue
#	Prepare And Attach UE    ue_index=1
#	Start Call For UE    ue_index=1    direction=dl
#	Check Counter For CB008159
#    [Teardown]        Case Postcondition
#
#5GC000545_01_dynamic_transform_precoder_switching_successfully
#    [Tags]    CRT    5GC000545
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    16.04.2024, lanhua.zhao@nokia-sbell.com, move from TL36956 to TL37014
#    [Setup]    Common Case Precondition
#    Set Test Variable    ${traffic_period}    20s
#    Online Change Parameters For 5GC000545
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for 5GC000545
#    Start L1 Bip Log
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Set Mobile Data    ue_index=0    state=on    connection=cygwin
#    Start Call For UE    ue_index=0    direction=ul
#    Sleep    10s    reason=Wait For Capture BipLog
#    ${bip_local_file_path}=    Stop L1 Bip Log And Download To K8s Master
#    Check Biplog DFT-S-OFDM Not Activated
#    Start L1 Bip Log
#    Change PA For Poor Radio Condition
#    Sleep    60s    reason=Wait For Capture BipLog
#    ${bip_local_file_path}=    Stop L1 Bip Log And Download To K8s Master
#    Check Biplog DFT-S-OFDM Activated
#    Stop UL Call for UE0
#    Start L1 Bip Log
#    Change PA For Good Radio Condition
#    Start Call For UE    ue_index=0    direction=ul
#    Sleep    60s    reason=Wait For Capture BipLog
#    ${bip_local_file_path}=    Stop L1 Bip Log And Download To K8s Master
#    Check Biplog DFT-S-OFDM Not Activated
#    [Teardown]    Common Case Postcondition
#
#CB010411_FDD_NSA_Handover_latency_Intra_gNB_intra_DU_HO_without_SRB3
#    [Tags]    CRT    LATENCY
#    [Timeout]    45min
#    [Setup]    Common Case Precondition
#    [Documentation]
#    ...    Author: jieting.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    2024-Jan-02,jieting.zhan@nokia-sbell.com, draft
#	...    2024-Aug-10,lanhua.zhao@nokia-sbell.com move it from 11073 to 37014
#    Prepare PA for NSA with NRCELL2
#    Set Library Search Order    AIC_UE    real_ue
#	Prepare And Attach UE    ue_index=2
#    Start Call For UE        ue_index=2    direction=dl
#    Sleep    5s    reason=Wait For DL
#    Start Collect Wireshark Log In vCU
#    FOR    ${ID}    IN RANGE   5
#        Adjust PA for NRCELL1     PA_Value=${55}
#        Adjust PA for NRCELL1     PA_Value=${50}
#        Adjust PA for NRCELL1     PA_Value=${45}
#        Adjust PA for NRCELL1     PA_Value=${40}
#        Adjust PA for NRCELL1     PA_Value=${35}
#        Adjust PA for NRCELL1     PA_Value=${30}
#        Adjust PA for NRCELL1     PA_Value=${25}
#        Adjust PA for NRCELL1     PA_Value=${20}
#        Adjust PA for NRCELL1     PA_Value=${15}
#        Adjust PA for NRCELL1     PA_Value=${10}
#        Adjust PA for NRCELL1     PA_Value=${5}
#        Adjust PA for NRCELL1     PA_Value=${0}
#        Adjust PA for NRCELL1     PA_Value=${5}
#        Adjust PA for NRCELL1     PA_Value=${10}
#        Adjust PA for NRCELL1     PA_Value=${15}
#        Adjust PA for NRCELL1     PA_Value=${20}
#        Adjust PA for NRCELL1     PA_Value=${25}
#        Adjust PA for NRCELL1     PA_Value=${30}
#        Adjust PA for NRCELL1     PA_Value=${35}
#        Adjust PA for NRCELL1     PA_Value=${40}
#        Adjust PA for NRCELL1     PA_Value=${45}
#        Adjust PA for NRCELL1     PA_Value=${50}
#        Adjust PA for NRCELL1     PA_Value=${55}
#    END
#    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
#    ${compare_result}    Calculate Handover Latency based on vCU wireshark log        local_file_path=${local_file_path}
#    Should be True    ${compare_result}
#    [Teardown]    Stop traffic    ${ue_2_type}     ue_index=2    direction=dl
#
#*** Keywords ***
#
#Common Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${NEW_PLAN_NAME}   Get Test Case Name
#    Set Test Variable  ${NEW_PLAN_NAME}
#    ${file_path}    Set Variable    ${testline_configuration_path}${/}${TestLine_Name}${/}testline_check_threshold.yml
#    ${latency_target}    Get TestLine Threshold From File    ${file_path}    FDD_NSA_Handover_latency_Intra_gNB_intra_DU_HO_without_SRB3
#    Set Test Variable        ${latency_target}
#
#Common Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    vDU Login By Rest
#    Run Keyword And Ignore Error  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error  vDU Logout By Rest
#    Run Keyword And Ignore Error    Detach UE0
#    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
#    ...                                                             conn=${conn}    timeout=${timeout}
##    Run Keyword And Ignore Error    Stop L1hi Bip Log
#
#
#Prepare And Attach UE
#    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
#    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
##    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
##    Sleep    60s    reason=wait attach UE Successfully
#    [Return]     ${ue_${ue_index}_type}
#
#Detach UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
#    UE Detach    ${ue_type}    ue_index=${ue_index}
#    sleep    60s    reason=wait detach UE Successfully
#
#Detach UE0
#    [Arguments]    ${ue_index}=${0}
#    Log To Console    ${ue_index}
#    UE Detach    ${ue0_type}    ue_index=${0}
#
#Start Call For UE
#    [Arguments]    ${ue_index}=${0}        ${direction}=dl
#    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
#	...              throughput=110M    duration=${600}
#	sleep    5s    reason=wait call sucessfully
#
#Stop DL Call for UE0
#    Log To Console    \nStop the DL TPUT
#    Stop traffic    ${ue_0_type}    ue_index=${0}    direction=dl
#
#Stop UL Call for UE0
#    Log To Console    \nStop the UL TPUT
#    Stop traffic    ${ue_0_type}    ue_index=${0}    direction=ul
#
#Get DL Tput By K8s Log
#    [Arguments]    ${duration}=${3600}
#    Download K8s Log from vDU    duration=${duration}
#    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
#    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
#    Log To Console    Max DL TPUT is: ${max_dl_tput}
#    Log To Console    Min DL TPUT is: ${min_dl_tput}
#    Set Test Variable    ${ave_dl_tput}
#
#Get UL Tput By K8s Log
#    [Arguments]    ${duration}=${3600}
#    Download K8s Log from vDU    duration=${duration}
#    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
#    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
#    Log To Console    Max UL TPUT is: ${max_ul_tput}
#    Log To Console    Min UL TPUT is: ${min_ul_tput}
#    Set Test Variable    ${ave_ul_tput}
#
#Get DL and UL Tput By K8s Log
#    [Arguments]    ${duration}=${3600}
#    Download K8s Log from vDU    duration=${duration}
#    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
#    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
#    Log To Console    Max UL TPUT is: ${max_ul_tput}
#    Log To Console    Min UL TPUT is: ${min_ul_tput}
#    Set Test Variable    ${ave_ul_tput}
#    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
#    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
#    Log To Console    Max DL TPUT is: ${max_dl_tput}
#    Log To Console    Min DL TPUT is: ${min_dl_tput}
#    Set Test Variable    ${ave_dl_tput}
#
#Download K8s Log from vDU
#    [Arguments]    ${duration}=${3600}
#    ${pod_name}=    set variable    l2rt
#    ${local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}    container_name=l2rt
#    ...                                    pod_name=${pod_name}   timeout=${10}    duration=${duration}
#    Set Test Variable    ${local_file_path}
#
#Check DL Tput By K8s Log
#    [Arguments]    ${required_ave_dl_tput}=5M
#    ${required}    Get Tput from string  ${required_ave_dl_tput}
#    should be true  ${ave_dl_tput}>=${required}
#
#Check UL Tput By K8s Log
#    [Arguments]    ${required_ave_ul_tput}=5M
#    ${required}    Get Tput from string  ${required_ave_ul_tput}
#    should be true  ${ave_ul_tput}>=${required}
#
#Get Tput from string
#    [Arguments]    ${str}
#    ${lst}    Get Regexp Matches    ${str}    (\\d+)\\w+   1
#    ${tput}    Convert To Integer  @{lst}[0]
#    [Return]    ${tput}
#
#Show Tput report
#    ${ul}    Get Tput from string  ${ul_tput}
#    ${dl}    Get Tput from string  ${dl_tput}
#    ${ul_rate}  Evaluate  ${ave_ul_tput} / ${ul} *100
#    ${dl_rate}  Evaluate  ${ave_dl_tput} / ${dl} *100
#    ${ul_rounded}  convert to number  ${ul_rate}  2
#    ${dl_rounded}  convert to number  ${dl_rate}  2
#    Log To Console    \n iperf UL TPUT is: ${ul} \nAve UL TPUT is: ${ave_ul_tput} \nUL TPUT Rate is: ${${ul_rounded}}\%
#    Log To Console    \n iperf DL TPUT is: ${dl} \nAve DL TPUT is: ${ave_dl_tput} \nDL TPUT Rate is: ${${dl_rounded}}\%
#
#Custom Suite Teardown For AIC
#    Common Suite Teardown For AIC
#    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
#    ${result}    Run Process    ${cmd}    shell=True
#    log to console    ${result.stdout}
#
#    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
#    ${result}    Run Process    ${cmd_new}    shell=True
#    log to console    ${result.stdout}
#    log to console    ${result.stderr}
#    log to console    ${result.rc}
#
#Prepare PA
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=15    ${attenuation_channels[9]}=15
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Modify Parameters By Delta Plan In vDU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If    &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST
#    ...                                          mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict}
#    ...                                          operation=replace
#    ...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest
#
#Start L1 Bip Log
#    Log To Console    \n start Bip log
#    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
#    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1
#    ...            ${timeout}=${10}
#    ${is_rannic}    Check if vDU Use Rannic
#    ${container_to_capture_L1_bip}=   Run Keyword If    '${is_rannic}'=='True'
#    ...               set variable    l2rt
#    ...       ELSE    set variable    l1hi
#    ${port_name}=   Run Keyword If    '${is_rannic}'=='True'
#    ...               set variable    l1up
#    ...       ELSE    set variable    l1bipl1
#    ${pod_to_capture_L1_bip}=    set variable    l2rt
#    Set Test Variable    ${is_rannic}
#    Set Test Variable    ${pod_to_capture_L1_bip}
#    Set Test Variable    ${container_to_capture_L1_bip}
#    Start Bip Log    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ...              container_name=${container_to_capture_L1_bip}
#    ...              pod_name=${pod_to_capture_L1_bip}    pod_prefix=${pod_prefix}
#    ...              container_prefix=${container_prefix}    port_name=${port_name}
#    ...              timeout=${timeout}
#
#Stop L1 Bip Log And Download To K8s Master
#    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
#    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1    ${timeout}=${10}
#    ${l1_bip_local_file_path}=    Stop Bip Log And Download To K8s Master
#    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ...    container_name=${container_to_capture_L1_bip}    pod_name=${pod_to_capture_L1_bip}
#    ...    pod_prefix=${pod_prefix}    container_prefix=${container_prefix}
#    ...    timeout=${timeout}
#    [Return]   ${l1_bip_local_file_path}
#
#Start Collect Wireshark Log
#    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}    ${index}=${0}
#    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           index=${index}
#    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           vdu_pod_name=cprt
#    ...                                                           vcu_pod_name=cpif
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log Inter vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           gnb2_index=${gnb_index}
#    ...                                                           index=${index}
#
#Start Collect Wireshark Log In vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt
#    Log to Console    \n***Start Wireshark Log In vDU***
#    Start Wireshark Log In vDU   gnb_index=${0}
#    ...                          container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#
#Start Collect Wireshark Log In vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif
#    Log To Console    ${container_name}
#    Log To Console    ${pod_name}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vCU
#
#Stop Wireshark Log In vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vdu_log_name}=vdu_wireshark
#    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
#    ...                                                                    container_name=${container_name}
#    ...                                                                    pod_name=${pod_name}
#    ...                                                                    timeout=${10}
#    ...                                                                    log_name=${vdu_log_name}
#    Set Test Variable    ${wireshark_local_file_path_vDU}
#
#Stop Wireshark Log In vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vcu_log_name}=vcu_wireshark
#    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
#    ...                                                                    container_name=${container_name}
#    ...                                                                    pod_name=${pod_name}
#    ...                                                                    timeout=${10}
#    ...                                                                    log_name=${vcu_log_name}
#    Set Test Variable    ${wireshark_local_file_path_vCU}
#
#Start Collect Wireshark Log Both vCU And vDU
#    [Arguments]    ${vdu_container_name}=cprt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
#    ...            ${gnb_index}=${0}    ${index}=${0}
#    Log To Console    ${vdu_container_name}
#    Log To Console    ${vdu_pod_name}
#    Log To Console    ${vcu_pod_name}
#    Log To Console    ${gnb_index}
#    Log To Console    ${index}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vCU
#    Start Wireshark Log In vDU
#
#Start Collect Wireshark Log Inter vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}
#    ...            ${gnb2_index}=${0}    ${index}=${0}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb2_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb2_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb2_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb2_index}_vdu_ns'][${index}]}
#
#Stop Wireshark Log
#    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU
#    ...            ${vcu_log_name}=vcu_wireshark    ${vdu_log_name}=vdu_wireshark
#    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log In vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           vdu_log_name=${vdu_log_name}
#    ...    ELSE IF    '${NE}'=='vCU'    Stop Wireshark Log In vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           vcu_log_name=${vcu_log_name}
#    ...    ELSE IF    '${NE}'=='all'    Stop Wireshark Log Both vCU And vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           vcu_log_name=${vcu_log_name}
#    ...                                                           vdu_log_name=${vdu_log_name}
#
#Check Wireshark Log
#    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
#    ${filter_list} =    Create list    f1ap.service_state == 0
#    ${expect_message}=    Create list    UEContextReleaseCommand
#    ${filter_length}    get length    ${filter_list}
#    FOR    ${index}    IN RANGE    ${filter_length}
#        ${result} =    Analysis Wireshark Log    input_file=${input_file}
#        ...                                      filter_expression=${filter_list[${index}]}
#        should contain    ${result}    ${expect_message[${index}]}
#    END
#
############################### CB008124 ##############################
#Online Set VCU Parameters For HO
#    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#    ${value_actRedirect}    Set Variable    true
#    &{param_actRedirect}    create dictionary    oactInterRatHoFromEutraToSA=true    nonContentRachAcFullConfigHo=true
#    ...                                          tNgRelocExecDeltL=5000
#    @{updated_actRedirect}    Create List    ${param_actRedirect}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actRedirect
#    ...                                                   updated_paras_dict=${updated_actRedirect}
#    ...                                                   compare_value=${value_actRedirect}
#    ...                                                   mo_dn=${mo_dn1}
#
#Online Set VDU Parameters For HO
#    Log To Console    \nActive HO
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID_vDU}/NRBTS-${NRBTS_ID}
#    &{parameter_dict}    Create Dictionary   actInterRatHoFromEutraToSA=true    nonContentRachAcFullConfigHo=true
#    ...                                      t304=ms2000
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict1} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#
#Change PA to NR1CELL
#    [Arguments]    ${PA_Value_NR}=0
#    ${attenuation_channels}     Get Attenuation port    RU_id=2    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary   ${attenuation_channels[2]}=127    ${attenuation_channels[3]}=127
#    ...                                          ${attenuation_channels[14]}=${PA_Value_NR}
#    ...                                          ${attenuation_channels[15]}=${PA_Value_NR}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=2    du_id=0
#    sleep    1s
#    Log to console    cell Attenuation Changed.
#
#Change PA to NR2CELL
#    [Arguments]    ${PA_Value_NR}=0
#    ${attenuation_channels}     Get Attenuation port    RU_id=2    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary   ${attenuation_channels[2]}=${PA_Value_NR}
#    ...                                          ${attenuation_channels[3]}=${PA_Value_NR}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=2    du_id=0
#    sleep    1s
#    Log to console    cell Attenuation Changed.
#    FOR   ${PA_Value2}   IN RANGE   5   50   5
#        ${attenuation_channels}     Get Attenuation port    RU_id=2    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[14]}=${PA_Value2}
#        ...                                          ${attenuation_channels[15]}=${PA_Value2}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=2    du_id=0
#        sleep    2s
#    END
#
#Check CU Counter Update For HO
#   ${value_14}=   Check Counter For vCU    counter_id=M55125C09014
#    ...                                              measurement_id=55125
#    ...                                              dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...                                              expected_value=-1
#    ...                                              get_number=5
#    ${value_13}=   Check Counter For vCU    counter_id=M55125C09013
#    ...                                              measurement_id=55125
#    ...                                              dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...                                              expected_value=0
#    ...                                              get_number=5
#
#Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
#    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
#    Set Test Variable    ${vdu_hostname_dict}
#    Set Test Variable    ${vdu_username_dict}
#    Set Test Variable    ${vdu_password_dict}
#    Set Test Variable    ${vdu_ns_dict}
#    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
#    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
#    Set Test Variable    ${vcu_hostname_list}
#    Set Test Variable    ${vcu_username_list}
#    Set Test Variable    ${vcu_password_list}
#    Set Test Variable    ${vcu_ns_list}
#    ${NEW_PLAN_NAME}     Get Test Case Name
#    Set Test Variable    ${NEW_PLAN_NAME}
#
#Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    run keyword and ignore error  Detach UE    ue_index=1
#
#Modify Parameters By Delta Plan
#    [Arguments]   ${ne}=vDU    ${parameter}=actCDrx    ${value}=true
#    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    Run Keyword If    '${ne}'=='vDU'    Modify Parameters By Delta Plan In vDU    parameter=${parameter}
#    ...                                                                           value=${value}
#    ...                                                                           mo_dn=${mo_dn}
#    ...            ELSE IF   '${ne}'=='vCU'    Modify Parameters By Delta Plan In vCU    parameter=${parameter}
#    ...                                                                                  value=${value}
#    ...                                                                                  mo_dn=${mo_dn}
#    ...            ELSE IF   '${ne}'=='all'    Modify Parameters By Delta Plan In vCU And vDU    parameter=${parameter}
#    ...                                                                                   value=${value}
#    ...                                                                                   mo_dn=${mo_dn}
#
#Modify Parameters By Delta Plan In vCU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
##    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
#    ...                                                                         value=${value}
#    @{updated_vcu_param}    Create List    ${vcu_param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
#    ...                                                   updated_paras_dict=${updated_vcu_param}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn}
#
#Modify Parameters By Delta Plan In vCU And vDU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
##    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
#    ...                                                                         value=${value}
#    @{updated_vcu_param}    Create List    ${vcu_param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
#    ...                                                   updated_paras_dict=${updated_vcu_param}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn}
#    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict1} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#
#Check Counter For CB008159
#    Sleep    600s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55306C09006,M55306C09013,M55306C09015
#    ...                                           dimDN=${dim_dn}/NRCELL-2
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55180C00007
#    ...                                           dimDN=${dim_dn}/NRCELL-2/MCC-262/MNC-03/ECI-2660903/MCC-262/MNC-03
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${type1_counter_list}    Create List    ${type1_counter_dict}
#    ${type2_counter_list}    Create List    ${type2_counter_dict}
#
#    FOR    ${counter}    IN    @{type1_counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#    FOR    ${counter}    IN    @{type2_counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Counter In vDU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check counter in vDU***
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        Check Counter For vDU   counter_id=${counter_id}
#        ...                     dimension_dn=${dim_dn}
#        ...                     comparison=${comparison}
#        ...                     expected_value=${expected_value}
#        ...                     get_number=${get_number}
#        ...                     gnb_index=${gnb_index}
#    END
#
#Check Counter In vCU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check counter in vCU***
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        @{words}=    split string    ${counter_id}   C
#        ${mea_id}=   Fetch From Right    ${words[0]}  M
#
#        Check Counter For vCU   counter_id=${counter_id}
#        ...                     measurement_id=${mea_id}
#        ...                     dimension_dist_name=${dim_dn}
#        ...                     comparison=${comparison}
#        ...                     expected_value=${expected_value}
#        ...                     get_number=${get_number}
#        ...                     gnb_index=${gnb_index}
#    END
#
###########    5GC000545_01_dynamic_transform_precoder_switching_successfully    ##########
#Prepare PA Signal for 5GC000545
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=15    ${attenuation_channels[13]}=15
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Change PA For Poor Radio Condition
#    Log to Console     \n***change PA for poor radio condition
#    FOR    ${PA_Value}    IN RANGE    15    71    5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[12]}=${PA_Value}
#        ...                                          ${attenuation_channels[13]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
#Change PA For Good Radio Condition
#    Log to Console     \n***change PA for good radio condition
#    # @{values}    Create List    65    55    45    35    25    15    10
#    # FOR    ${value}     IN    @{values}
#    #     ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    #     ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    #     &{channels_to_modify}    create dictionary    ${attenuation_channels[12]}=${value}
#    #     ...                                           ${attenuation_channels[13]}=${value}
#    #     Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    #     sleep    2s
#    FOR    ${PA_Value}    IN RANGE    70    10    -5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[12]}=${PA_Value}
#        ...                                          ${attenuation_channels[13]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
#Online Change Parameters For 5GC000545
#    Log To Console    \nSet Parameters For 5GC000545
#    ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{parameter_dict}    Create Dictionary    actUlDftSOfdm=true
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified     mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict1} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict}
#    ...                                          operation=replace
#    ...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${True}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#    &{ulData_delta_dict}   create dictionary     ulTransPrecodeCtl=${None}
#    ...                                   ulTransPrecodeCtl/0/ulSlotAggOffTotPwrThresh=15
#    ...                                   ulTransPrecodeCtl/1/ulSlotAggOnTotPwrThresh=12
#    ...                                   ulTransPrecodeCtl/2/ulTransPrePi2BpskPwrBoost=false
#    ...                                   ulTransPrecodeCtl/3/ulTransPrecodeOffSinrThrRedCap=17
#    ...                                   ulTransPrecodeCtl/4/ulTransPrecodeOffSinrThresh=17
#    ...                                   ulTransPrecodeCtl/5/ulTransPrecodeOnSinrThrRedCap=11
#    ...                                   ulTransPrecodeCtl/6/ulTransPrecodeOnSinrThresh=11
#    ...                                   ulTransPrecodeCtl/7/ulTransPrecodePi2Bpsk=true
#    VDU Online Modify Staged Parameters By Rest    mo_dn=${mo_dn}
#    ...                                          updated_paras_dict=${ulData_delta_dict}
#
#Check Biplog DFT-S-OFDM Not Activated
#    [Arguments]    ${name}=l1hi_befor
#    Log To Console    Check McShark BIP Log
#    ${filter}=    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#    ${csv_title}=    Set Variable    -e UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#    Convert BIP To CSV By MCShark    local_file_path=${bip_local_file_path}
#    ...                              output_file=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
#    ...                              filter=${filter}
#    ...                              csv_title=${csv_title}
#    ${csv_matrix}=    Read Csv File Into Matrix    file_path=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
#    ${column_list_rank}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${2}
#    Remove From List    ${column_list_rank}    0
#    ${len_rank}=    get length    ${column_list_rank}
#    Should Be True    ${len_rank}>0
#    FOR    ${index}    IN RANGE    ${len_rank}
#        ${VAL1}    Set Variable If    ${column_list_rank[${index}]} == 0    ${True}    ${False}
#        Set Test Variable    ${VAL1}
#        Exit For Loop If  ${VAL1}
#    END
#    Should Be True  ${VAL1}==${True}
#
#Check Biplog DFT-S-OFDM Activated
#    [Arguments]    ${name}=l1hi_after
#    Log To Console    Check McShark BIP Log
#    ${filter}=    Set Variable    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#    ${csv_title}=    Set Variable    -e UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
#    Convert BIP To CSV By MCShark    local_file_path=${bip_local_file_path}
#    ...                              output_file=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
#    ...                              filter=${filter}
#    ...                              csv_title=${csv_title}
#    ${csv_matrix}=    Read Csv File Into Matrix    file_path=${TEST_LOG_DIRECTORY}/bip/csv_${name}.csv
#    ${column_list_rank}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${2}
#    Remove From List    ${column_list_rank}    0
#    ${len_rank}=    get length    ${column_list_rank}
#    Should Be True    ${len_rank}>0
#    FOR    ${index}    IN RANGE    ${len_rank}
#        ${VAL1}    Set Variable If    ${column_list_rank[${index}]} == 1    ${True}    ${False}
#        Set Test Variable    ${VAL1}
#        Exit For Loop If  ${VAL1}
#    END
#    Should Be True  ${VAL1}==${True}
#
###########    CB010411_FDD_NSA_Handover_latency_Intra_gNB_intra_DU_HO_without_SRB3    ##########
#Prepare UE by index
#    [Arguments]    ${ue_index}=${0}
#    Log to Console    \n***Prepare M80***
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=default
#    Log to Console    \n***UE Prepared...***
#    [Return]     ${ue_${ue_index}_type}
#
#Attach UE by index
#    [Arguments]    ${ue_index}=${0}
#    Log to Console    \n***M80 attach***
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
#    Log to Console    \n***UE Attached...***
#
#Start DL traffic by index
#    [Arguments]    ${ue_index}=${0}
#    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl   dt_index=${0}
#	...              throughput=10M    duration=${600}
#
#Prepare PA for NSA with NRCELL2
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=127    ${attenuation_channels[13]}=127
#    ...                                             ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
#    ...                                             ${attenuation_channels[14]}=10   ${attenuation_channels[15]}=10
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    NSA with NRCELL2 is Ready.
#
#Adjust PA for NRCELL1
#    [Arguments]    ${PA_Value}=${127}
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=${PA_Value}   ${attenuation_channels[13]}=${PA_Value}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    Prepare NRCELL1.
#
#Calculate Handover Latency based on vCU wireshark log
#    [Arguments]    ${local_file_path}=/home/ute/test_results/
#
#    ${average_latency}    Set Variable    ${0}
#    @{latency_list}    Create List
#    ${measurement_report_filter}    Set Variable        x2ap.procedureCode == 35
#    ${second_time}=    Run
#    ...    tshark -Y "${measurement_report_filter}" -T fields -e frame.time -r ${local_file_path}
#    @{measurement_report_time}    Split String      ${second_time}    ${\n}
#    ${SgNBModificationConfirm_filter}    Set Variable    x2ap.procedureCode ==30 && ip.src ==10.107.92.142
#    ${second_time}=    Run
#    ...    tshark -Y "${SgNBModificationConfirm_filter}" -T fields -e frame.time -r ${local_file_path}
#    @{SgNBModificationConfirm_time}    Split String      ${second_time}    ${\n}
#    FOR    ${item}    IN    @{measurement_report_time}
#        Continue For Loop if    '${item}'==''
#        ${latency}    Check Time GAP with List    ${item}    @{SgNBModificationConfirm_time}
#        Append to List      ${latency_list}   ${latency}
#        ${cal_num}    Get Length     ${latency_list}
#        Exit FOR Loop If      ${cal_num}>30
#    END
#    Remove Values From List    ${latency_list}    ${-1}
#    ${result}    Check Latency with threshold    @{latency_list}
#    [Return]    ${result}
#
#Get TestLine Threshold From File
#    [Arguments]    ${file_path}    ${threshold}
#    ${json_content}    get_content_from_yml    ${file_path}
#    [Return]    ${json_content}[${threshold}]
#
#Check Latency with threshold
#    [Arguments]    @{latency_list}
#    ${cal_times}    Set Variable    ${0}
#    FOR    ${item}    IN    @{latency_list}
#        ${count}    Set Variable If     ${item}<${latency_target}/1000    ${1}    ${0}
#        ${cal_times}    Evaluate    ${cal_times}+${count}
#    END
#    [Return]    ${cal_times}>0
#
#Check Time GAP with List
#    [Arguments]    ${fix_time}    @{time_list}
#    ${latency}    Set Variable    ${-1}
#    ${time}=   Get Regexp Matches    ${fix_time}   ([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])
#    ${time_patten}    Convert Time    ${time[0]}
#    ${ms_time}=       Get Regexp Matches    ${fix_time}      ([0-9][0-9][0-9][0-9][0-9][0-9])
#    ${ms_time_s}    Convert To String    ${ms_time[0]}
#    ${ms_time_value}    Convert To Integer     ${ms_time_s}
#    ${sg_list_length}    Get Length    ${time_list}
#    FOR    ${item}    IN      @{time_list}
#        Continue For Loop if    '${item}'==''
#        ${end_time}=   Get Regexp Matches    ${item}   ([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])
#        ${end_time_patten}    Convert Time    ${end_time[0]}
#        ${end_ms_time}=       Get Regexp Matches    ${item}      ([0-9][0-9][0-9][0-9][0-9][0-9])
#        ${end_s}    Convert To String    ${end_ms_time[0]}
#        ${end_ms_time_value}        Convert To Integer    ${end_s}
#        #${status}    Run Keyword And Return Status    Should be equal     ${time}    ${end_time}
#        ${time_differ_too_much}    Evaluate    ${end_time_patten}-${time_patten}
#        Exit FOR Loop If    ${time_differ_too_much}>1
#        Continue FOR Loop If    ${time_differ_too_much}<0
#        ${latency}    Evaluate     (${end_ms_time_value}-${ms_time_value})/1000+${time_differ_too_much}*1000
#        #Remove Values From List     @{time_list}    @{item}
#        Exit FOR Loop If     ${latency}>0
#    END
#    [Return]     ${latency}
