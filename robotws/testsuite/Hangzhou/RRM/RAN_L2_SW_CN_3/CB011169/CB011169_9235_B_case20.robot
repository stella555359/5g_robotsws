# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_B_B201_CASE20_dlMuAware_dlMuPairingPrbRatio_algo_and_bundary_value_check
# 
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           ../CB009235/Airphone/py_check/power_boosting_check.py
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${DU_SCF}        DU_11169_9235.xml
# #${DU_SCF}        DU_9235_srs.xml
# ${CU_SCF}        CU_11169_9235.xml
# ${AIRPHONE_NAME}    iphy_AEQE_DC.xml
# #${AIRPHONE_NAME}    iphy_AEQE_DC_srs.xml
# #${WTS_CFG}       basic_setup_8360.cfg
# ${WTS_CFG}       wts_11169_9235_1cell_SA_NSA_case20.lua
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
# ${SET_PROFILE12}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12
# ${SET_PROFILE13}    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
# ${SET_PROFILE14}    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14
# ${SET_PROFILE15}    ue_testmode_set_nr id\=15 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
# ${SET_PROFILE16}    ue_testmode_set_nr id\=16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE1_2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# ${delete_PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 delete\=true
# ${delete_PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 delete\=true
# ${delete_PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 delete\=true
# ${delete_PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 delete\=true
# ${delete_PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 delete\=true
# ${delete_PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 delete\=true
# ${delete_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 delete\=true
# ${delete_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 delete\=true
# ${delete_PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 delete\=true
# ${delete_PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 delete\=true
# ${delete_PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 delete\=true
# ${delete_PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 delete\=true
# ${delete_PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 delete\=true
# ${delete_PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 delete\=true
# # online change param
# ${MO_DN_1}    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
# &{UPDATED_PARAS_DICT_0}    dlMuPairingPrbRatio=0.51
# @{MO_DN_LIST}      ${MO_DN_1} 
# @{UPDATED_PARAS_DICT_LIST}		${UPDATED_PARAS_DICT_0}
# &{UPDATED_PARAS_DICT_1}    dlMuPairingPrbRatio=0.3
# @{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
# &{UPDATED_PARAS_DICT_2}    dlMuPairingPrbRatio=0
# @{UPDATED_PARAS_DICT_LIST_2}		${UPDATED_PARAS_DICT_2}
# 
# *** Test Cases ***
# CB009235_B_B201_CASE20_dlMuAware_dlMuPairingPrbRatio_algo_and_bundary_value_check
# 	Step1:Commission And Reach Onair
# 	#Step2:4 UEs attach to cell1 and set positions
# 	Step2:attach 64 ues at 16 pos
# 	#Step3:do tarffic and check TTI
# 	Step3:Do Traffic for dlMuPairingPrbRatio100 benchmark
# 	Step4:Online change dlMuPairingPrbRatio into '51'
# 	Step5:Online change dlMuPairingPrbRatio into '30'
# 	Step6:Online change dlMuPairingPrbRatio into '0'
# 	#Step4:dettach UEs
# 	#dettach UEs
# 
# *** Keywords ***
# Step1:Commission And Reach Onair
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001    
# 	AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 	
# Step2:4 UEs attach to cell1 and set positions
#     Register_UE1
# 	Register_UE2
# 	Register_UE3
# 	Register_UE4
# 
# Step2:attach 64 ues at 16 pos
#     Attach '64' SA UEs
#     set '64' SA UEs Pos
# 
# Attach '${UE_NUM_SA}' SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Attach SA ue with capability    ${num}    CA_P2_8x4_t2r4_n2
# 	#\    Airphone SA Attach    ue_id=${num}
# 	\    ${gw_pdu_r}    evaluate    ${num}%10+1
# 	\    airphone_set_traffic_type   ${num}    ${gw_pdu_r}    internal
# 	\    Airphone Pdu Session Setup    ${num}    ${gw_pdu_r}    1    ${gw_pdu_r}
# 	\    Wait Throughput Timer    0.1    
# 
# set '${UE_NUM}' SA UEs Pos   #per position 4ues
#     log to console    ste ues pos
# 	: FOR    ${num}    IN RANGE    1    17
#     \    airphone_execute_egate_command    ${PROFILE${num}}
#     : FOR    ${num}    IN RANGE    1    65
#     \    ${num_r}    evaluate    ${num}%16+1
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
#     
# 	
# Step3:do tarffic and check TTI
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/tti
# 	run keyword and continue on failure    check_power_boosting    ${TEST_LOG_DIRECTORY()}/tti_dl.csv
# 
# Step3:Do Traffic for dlMuPairingPrbRatio100 benchmark
#     Log To Console    \n\r==================step3 do tarffic==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_do_traffic
# 	: FOR    ${i}    IN RANGE    1    65
# 	\   ${gw_pdu_r}    evaluate    ${i}%10+1
#     \    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	#${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
# 	#run keyword and continue on failure    check_power_boosting    ${save_log}/tti_dl.csv
# 	${tput_MuCounter}    get DL UL tput from PM counter and get MU counter
# 	${mu_counter_sum_100}    evaluate    sum(${tput_MuCounter}[2:])
# 	Set Global Variable    ${mu_counter_sum_100}    ${mu_counter_sum_100}
# 	Log To Console    ${mu_counter_sum_100}
# 
# Step4:Online change dlMuPairingPrbRatio into '51'
#     Log To Console    \n\r==================step4 dlMuPairingPrbRatio 51========${mu_counter_sum_100}==========\n\r
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_dlMuPairingPrbRatio51
#     #online change dlMuPairingPrbRatio into '51'
# 	VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST}
# 	Wait '10s' for stabible
# 	#${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
#     ${tput_MuCounter}    get DL UL tput from PM counter and get MU counter
# 	${mu_counter_sum_51}    evaluate    sum(${tput_MuCounter}[2:])
# 	Set Global Variable    ${mu_counter_sum_51}   ${mu_counter_sum_51}
# 	Log To Console    ${mu_counter_sum_100},${mu_counter_sum_51}
# 	
# Step5:Online change dlMuPairingPrbRatio into '30'
#     Log To Console    \n\r==================step5 dlMuPairingPrbRatio 30==================\n\r
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_dlMuPairingPrbRatio30
#     #online change dlMuPairingPrbRatio into '30'
# 	VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST_1}
# 	Wait '10s' for stabible
# 	#${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
#     ${tput_MuCounter}    get DL UL tput from PM counter and get MU counter
# 	${mu_counter_sum_30}    evaluate    sum(${tput_MuCounter}[2:])
# 	Set Global Variable    ${mu_counter_sum_30}   ${mu_counter_sum_30}
# 	Log To Console    ${mu_counter_sum_100},${mu_counter_sum_51},${mu_counter_sum_30}
# 
# Step6:Online change dlMuPairingPrbRatio into '0'
#     Log To Console    \n\r==================step6 dlMuPairingPrbRatio 0==================\n\r
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_dlMuPairingPrbRatio0
#     #online change dlMuPairingPrbRatio into '0'
# 	VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST_2}
# 	Wait '10s' for stabible
# 	#${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     #VDU Stop TTiTrace Log    ${trace_id}
#     #VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
#     ${tput_MuCounter}    get DL UL tput from PM counter and get MU counter
# 	${mu_counter_sum_0}    evaluate    sum(${tput_MuCounter}[2:])
#     Set Global Variable    ${mu_counter_sum_0}    ${mu_counter_sum_0}
# 	Log To Console    ${mu_counter_sum_100},${mu_counter_sum_51},${mu_counter_sum_30},${mu_counter_sum_0}
# 	run keyword and continue on failure    Should Be True    ${mu_counter_sum_0} >= ${mu_counter_sum_30}
# 	run keyword and continue on failure    Should Be True    ${mu_counter_sum_0} >= ${mu_counter_sum_51}
# 	run keyword and continue on failure    Should Be True    ${mu_counter_sum_0} >= ${mu_counter_sum_100}
# 
# online change dlMuPairingPrbRatio into '${ratio}'
# 	#${corrthd_scf}     evaluate    ${corrThd}*100
#     Log To Console    ${\n}=======online_change_corrThd_${ratio}========
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuPairingPrbRatio
#     ...    operation=update    value=${ratio}    skip_parameter_relation_errors=True    should_activate=True    connection=online    
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# get DL UL tput from PM counter and get MU counter
#     Wait Throughput Timer    300
# 	${PM_counter_DL_value}    VDU Get PM Counter Value   counter_id=M55309C12001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}    VDU Get PM Counter Value   counter_id=M55309C12002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
# 	${PM_counter_16layers}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_16layers}=    Convert To Integer   ${PM_counter_16layers}
# 	${PM_counter_14layers}=    VDU Get PM Counter Value   counter_id=M55308C34021   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_14layers}=    Convert To Integer   ${PM_counter_14layers}
# 	${PM_counter_12layers}=    VDU Get PM Counter Value   counter_id=M55308C34019   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_12layers}=    Convert To Integer   ${PM_counter_12layers}
# 	${PM_counter_10layers}=    VDU Get PM Counter Value   counter_id=M55308C34017   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_10layers}=    Convert To Integer   ${PM_counter_10layers}
# 	${PM_counter_8layers}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_8layers}=    Convert To Integer   ${PM_counter_8layers}
# 	${PM_counter_6layers}=    VDU Get PM Counter Value   counter_id=M55308C34009   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_6layers}=    Convert To Integer   ${PM_counter_6layers}
# 	${PM_counter_4layers}=    VDU Get PM Counter Value   counter_id=M55308C34007   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_4layers}=    Convert To Integer   ${PM_counter_4layers}
#     [Return]    ${DL_throughput}    ${UL_throughput}    ${PM_counter_16layers}    ${PM_counter_14layers}    ${PM_counter_12layers}
# 	...    ${PM_counter_10layers}    ${PM_counter_8layers}    ${PM_counter_6layers}   ${PM_counter_4layers}
# 	
# Step4:dettach UEs
#     DeRegister UE from '1' to '4'
# 	
# dettach UEs
#     : FOR    ${num}    IN RANGE    1    17
#     \    airphone_execute_egate_command    ${delete_PROFILE${num}}
#     DeRegister UE from '1' to '64'
# 	
# Add FreeRbg RD to swconfig
#     ${vdu_version}    Get VDU SW version
# 	Log To Console    ${vdu_version}
# 	${hostname}    Get Host Name
# 	Log To Console    ${hostname}
# 	${host_name}    Replace String    ${hostname}    -    _
# 	Log To Console    ${host_name} 
# 	VDU Master Login
#     ${swconfig_l2rt}    SSH.Execute
#     ...    command=sed -i '$a\0x5805c3=1 #free RBGs RD' /var/home/core/${host_name}/vDUCNF00_${vdu_version}/0/l2rt/swconfig_l2rt.txt
# 	...    connection=vdu_master
# 	Log To Console    ${swconfig_l2rt}
# 	SSH.Disconnect    connection=vdu_master
# 	
# 
# Register_UE1
# 	UE from '1' to '1' SA Register
# 	Set UE1 position_1
# 	Wait '2s' for stabible
# 	send DLUL data from UE '1' to '1'
# 	
# Register_UE2	
# 	UE from '2' to '2' SA Register
# 	Set UE2 position
# 	Wait '2s' for stabible
# 	send DLUL data from UE '2' to '2'
# 
# Register_UE3	
# 	UE from '3' to '3' SA Register
# 	Set UE3 position
# 	Wait '2s' for stabible
# 	send DLUL data from UE '3' to '3'
# 
# Register_UE4	
# 	UE from '4' to '4' SA Register
# 	Set UE4 position
# 	Wait '2s' for stabible
# 	send DLUL data from UE '4' to '4'
# 
# Set UE1 position_1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     
# Set UE2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     
# Set UE3 position
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     
# Set UE4 position
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
# 
# delete profile_1_2_3_4
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}
# 	Airphone Execute Egate Command    ${delete_PROFILE3}
# 	Airphone Execute Egate Command    ${delete_PROFILE4}
# 
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
# 	\   Wait '1s' for stabible
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     #\   get UE '${num}' rnti in RRC log
# 
# send DLUL data from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data to '${num}'    
#     
# DL and UL data to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   60M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     Log To Console		UE${UE_ID}_dl_ul ${dl_tput_Mb} ${ul_tput_Mb}
# 
# check throughput from UE '${low}' to '${hi}' with tp '${lo_tp}' to '${hi_tp}'
# 	Wait '5s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${lo_tp}
# 	run keyword and continue on failure    should be true    ${cell_tp_ul}<${hi_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
