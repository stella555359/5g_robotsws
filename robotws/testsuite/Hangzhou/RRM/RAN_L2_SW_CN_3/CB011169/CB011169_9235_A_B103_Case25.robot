# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B103_Case25_NumberOfCorrelationCalculation_more_than_NumberOfCorrelationCalculationTotal
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
# ${DU_SCF}        DU_11169_9235_case25.xml
# ${CU_SCF}        CU_11169_9235.xml
# ${AIRPHONE_NAME}    iphy_AEQE_DC.xml
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
# @{MO_DN_LIST}      ${MO_DN_1}
# &{UPDATED_PARAS_DICT_0}    dlMuMimoCqiThd=10
# @{UPDATED_PARAS_DICT_LIST}		${UPDATED_PARAS_DICT_0}
# &{UPDATED_PARAS_DICT_1}    dlMuPairingPrbRatio=0.3
# @{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
# &{UPDATED_PARAS_DICT_2}    dlMuPairingPrbRatio=0
# @{UPDATED_PARAS_DICT_LIST_2}		${UPDATED_PARAS_DICT_2}
# 
# *** Test Cases ***
# CB009235_A_B103_Case25_NumberOfCorrelationCalculation_more_than_NumberOfCorrelationCalculationTotal
# 	Step1:Commission And Reach Onair
# 	Step2:attach 10 ues at 10 pos
# 	Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
# 	Step4:check PM counter value
# 	#dettach UEs
# 	
# *** Keywords ***
# Step1:Commission And Reach Onair
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001    
# 	AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# Step2:attach 10 ues at 10 pos
#     Attach '10' SA UEs
#     set '10' SA UEs Pos
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
# 	: FOR    ${num}    IN RANGE    1    11
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
# Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
#     Log To Console    \n\r==================step3 do little tarffic==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_do_liitle_traffic
# 	: FOR    ${i}    IN RANGE    1    11
# 	\   ${gw_pdu_r}    evaluate    ${i}%10+1
#     \    Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
# 	#run keyword and continue on failure    check_power_boosting    ${save_log}/tti_dl.csv
# 
# Step4:check PM counter value
#     Log To Console    \n\r==================step4 check PM connter==================\n\r
# 	${Counter_list}    get DL UL tput from PM counter and get MU counter
# 	${DL_SUCC_counter}    Set Variable    ${Counter_list}[12]
# 	run keyword and continue on failure    should_be_true    ${DL_SUCC_counter}>0
# 	
# get DL UL tput from PM counter and get MU counter
#     Wait Throughput Timer    600
# 	${PM_counter_DL_value}    VDU Get PM Counter Value   counter_id=M55309C12001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}    VDU Get PM Counter Value   counter_id=M55309C12002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024	
# 	${PM_counter_8layers}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_8layers}=    Convert To Integer   ${PM_counter_8layers}
# 	${PM_counter_6layers}=    VDU Get PM Counter Value   counter_id=M55308C34009   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_6layers}=    Convert To Integer   ${PM_counter_6layers}
# 	${PM_counter_4layers}=    VDU Get PM Counter Value   counter_id=M55308C34007   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_4layers}=    Convert To Integer   ${PM_counter_4layers}
# 	${PM_counter_2layers}=    VDU Get PM Counter Value   counter_id=M55308C34005   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PM_counter_2layers}=    Convert To Integer   ${PM_counter_2layers}
# 	${SU_MIMO_4layer}=    VDU Get PM Counter Value   counter_id=M55308C34004   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${SU_MIMO_4layer}=    Convert To Integer   ${SU_MIMO_4layer}
# 	${SU_MIMO_2layer}=    VDU Get PM Counter Value   counter_id=M55308C34002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${SU_MIMO_2layer}=    Convert To Integer   ${SU_MIMO_2layer}
# 	${MU_MIMO_NOPAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34012   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MU_MIMO_NOPAIR_UE}=    Convert To Integer   ${MU_MIMO_NOPAIR_UE}
# 	${MU_MIMO_2PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34013   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MU_MIMO_2PAIR_UE}=    Convert To Integer   ${MU_MIMO_2PAIR_UE}
# 	${MU_MIMO_3PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34014   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MU_MIMO_3PAIR_UE}=    Convert To Integer   ${MU_MIMO_3PAIR_UE}
# 	${MU_MIMO_4PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C34015   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MU_MIMO_4PAIR_UE}=    Convert To Integer   ${MU_MIMO_4PAIR_UE}
# 	${DL_SUCC_counter}=    VDU Get PM Counter Value   counter_id=M55308C34030   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_SUCC_counter}=    Convert To Integer   ${DL_SUCC_counter}
#     [Return]    ${DL_throughput}    ${UL_throughput}    ${PM_counter_8layers}
# 	...    ${PM_counter_6layers}    ${PM_counter_2layers}    ${SU_MIMO_4layer}   ${SU_MIMO_2layer}    ${PM_counter_4layers}
# 	...    ${MU_MIMO_NOPAIR_UE}    ${MU_MIMO_2PAIR_UE}    ${MU_MIMO_3PAIR_UE}    ${MU_MIMO_4PAIR_UE}   ${DL_SUCC_counter}
# 	
# dettach UEs
#     : FOR    ${num}    IN RANGE    1    7
#     \    airphone_execute_egate_command    ${delete_PROFILE${num}}
#     DeRegister UE from '1' to '6'
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
