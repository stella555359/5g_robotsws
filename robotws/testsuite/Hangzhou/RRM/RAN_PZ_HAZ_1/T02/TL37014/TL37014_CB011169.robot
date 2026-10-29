*** Settings ***
Documentation
...    Author: Zhao Lanhua
...    Contact: lanhua.zhao@nokia-sbell.com
...    this file is for CB011169.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen

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
#${TESTLINE_NAME}             7_5_UTE5GAIC0123T002
#
#*** Test Cases ***
#CB011169_15_CNI_78446_A_1_SA_Inital_RRC_Setup_with_dedicated_config_in_initialDownlinkBWP_with_large_BWP
#    [Tags]    CRT    CB011169     BWP
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    09.05.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Set Test Variable    ${dl_tput}    100M
#    Online Change Parameters In vDU
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for NRCELL2
#    Prepare And Attach UE    ue_index=0    ui_version=S21
#    Start Call For UE with Tput     ue_index=0    direction=dl    tput=110M
#    Sleep    180s    reason=time for doing DL and DL
#    Get DL Tput By K8s Log     duration=180
#    Show DL Tput report
#    Check 3 Counters in VDU
#    [Teardown]    Common Case Postcondition
#
#CB011169_18_CNI-80045_01_gNB BC selection based on allowedBC-ListMRDC order from eNB during EN-DC setup - FR1 NSA multi NR band
#    [Tags]    CRT    CB011169     ENDC
#    [Documentation]
#    ...    Author: lanhua.zhao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    15.05.2024, lanhua.zhao@nokia-sbell.com draft
#    [Setup]    Common Case Precondition
#    Set Library Search Order    AIC_UE    real_ue
#    Online Change VCU Parameter To Enable Feature
#    wait until keyword succeeds    10min    30s    Check All Cells On Air In vCU
#    Prepare PA Signal for LTECELL
#    Prepare And Attach UE    ue_index=1
#    Start Collect Wireshark Log In vCU
#    Change PA Signal To Add NRCELL For NSA
#    Sleep    5s     reason=Wait For wireshark capture
#    Stop Wireshark Log In vCU
#    Run Keyword And Ignore Error     Detach M80
#    Check Wireshark for SGNB ADD ACK
#    [Teardown]    Common Case Postcondition
#
#*** Keywords ***
#Common Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    ${NEW_PLAN_NAME}    Get Test Case Name
#    Set Test Variable    ${NEW_PLAN_NAME}
#
#Common Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    vDU Login By Rest
#    Run Keyword And Ignore Error    plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error    svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
#    Run Keyword And Ignore Error    vDU Logout By Rest
#    Run Keyword And Ignore Error    Detach UE0
#    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
#    ...                                                             conn=${conn}    timeout=${timeout}
##    Run Keyword And Ignore Error    Stop L1hi Bip Log
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
#Start Call For UE with Tput
#    [Arguments]    ${ue_index}=${0}        ${direction}=dl    ${tput}=110M
#    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
#	...              throughput=${tput}    duration=${600}
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
#Show DL Tput report
#    ${dl}    Get Tput from string  ${dl_tput}
#    ${dl_rate}  Evaluate  ${ave_dl_tput} / ${dl} *100
#    ${dl_rounded}  convert to number  ${dl_rate}  2
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
#Start VONR Call For UE
#    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_ANDROID_UE    ${duration}=60s
#    Log to Console    ***Prepare to start a VONR call.***
#    Start VONR Call    ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}    vc_alias=VC_1    call_number=004488    duration=${duration}
#    ...                capabilities=${capabilities}
#    Log to Console    \n***Started VONR call..***
#    #sleep    5s    reason=wait call sucessfully
#
#Stop VONR Call For UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_0_type}
#    Log To Console    ${ue_index}
#    Log to Console    ***Prepare to stop a ue VoNR call.***
#    Stop VONR Call    ue_type=${ue_type}    vc_alias=VC_1
#    Log to Console    \n***Stoped VONR call..***
#
############################### CNI_78446 ##############################
#Prepare PA Signal for NRCELL2
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=127    ${attenuation_channels[13]}=127
#    ...                                             ${attenuation_channels[2]}=127    ${attenuation_channels[3]}=127
#    ...                                             ${attenuation_channels[14]}=0    ${attenuation_channels[15]}=0
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Online Change Parameters In vDU
#    Log To Console    \nSet change Parameter
#    ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    &{parameter_dict}    Create Dictionary    ueConnectionEstablishmentMode=useInitialBwp
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
#
#Check 3 Counters in VDU
#    Log to Console    \nwait for counters pegged
#    Sleep    610s    reason=wait for counters pegged
#   ${counter_1}=    Check Counter For vDU    counter_id=M55166C00002
#    ...                                              dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    ...                                              expected_value=0
#    ...                                              get_number=3
#    ${counter_2}=    Check Counter For vDU    counter_id=M55166C00004
#    ...                                              dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    ...                                              expected_value=0
#    ...                                              get_number=3
#    ${counter_3}=    Check Counter For vDU    counter_id=M55139C02502
#    ...                                              dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    ...                                              expected_value=0
#    ...                                              get_number=3
############################### CNI_80045 ##############################
#Prepare PA Signal for LTECELL
#    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary      ${attenuation_channels[12]}=70    ${attenuation_channels[13]}=70
#    ...                                             ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
#    ...                                             ${attenuation_channels[14]}=55   ${attenuation_channels[15]}=55
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    PA Attenuation Changed.
#
#Online Change VCU Parameter To Enable Feature
#    Modify Parameters By Delta Plan In vCU    parameter=actAllowedBcListMrdcPrioBcSel    value=true
#	...                                       mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Log To Console    \nParameter Changed
#
#Change PA Signal To Add NRCELL For NSA
#    Log to console    \nChange PA Attenuation for NRCELL1 And NRCELL2
#    FOR    ${PA_Value}    IN RANGE    50    0    -5
#        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
#        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#        &{channels_to_modify}    create dictionary   ${attenuation_channels[12]}=${PA_Value}
#        ...                                          ${attenuation_channels[13]}=${PA_Value}
#        ...                                          ${attenuation_channels[14]}=${PA_Value}
#        ...                                          ${attenuation_channels[15]}=${PA_Value}
#        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#        sleep    2s
#    END
#
#Prepare M80
#    [Arguments]    ${ue_index}=${1}
#    Log to Console    \n***Prepare M80***
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=default
#    Log to Console    \n***UE Prepared...***
#    [Return]     ${ue_${ue_index}_type}
#
#Attach M80
#    [Arguments]    ${ue_index}=${1}
#    Log to Console    \n***M80 attach***
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
#    Log to Console    \n***UE Attached...***
#
#Detach M80
#    UE Detach    ${ue_1_type}    ue_index=${1}
#
#Check Wireshark for SGNB ADD ACK
#   [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
#    ${filter_list} =    Create list    x2ap
#    ${expect_message}=    Create list    SgNBAdditionRequestAcknowledge
#    ${filter_length}    get length    ${filter_list}
#    FOR    ${index}    IN RANGE    ${filter_length}
#        ${result} =    Analysis Wireshark Log    input_file=${input_file}
#        ...                                      filter_expression=${filter_list[${index}]}
#        should contain    ${result}    ${expect_message[${index}]}
#    END
