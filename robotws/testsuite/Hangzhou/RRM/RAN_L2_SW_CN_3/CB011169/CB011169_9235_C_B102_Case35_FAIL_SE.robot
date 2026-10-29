# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_C_B102_Case35_Enhanced_PM_counters_MU_MIMO_PAIR_DL_FAIL_SE
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
# ${DU_SCF}        DU_11169_9235_case35.xml
# ${CU_SCF}        CU_11169_9235.xml
# ${AIRPHONE_NAME}    iphy_AEQE_DC.xml
# ${WTS_CFG}       wts_11169_9235_1cell_SA_NSA_case20.lua
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# # online change param
# ${MO_DN_1}    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
# @{MO_DN_LIST}      ${MO_DN_1}
# &{UPDATED_PARAS_DICT_0}    dlMuMimoRankAdaption=disabled    dlMuMimoSpectralEffThd=2
# @{UPDATED_PARAS_DICT_LIST}		${UPDATED_PARAS_DICT_0}
# &{UPDATED_PARAS_DICT_1}    dlMuPairingPrbRatio=0.3
# @{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
# &{UPDATED_PARAS_DICT_2}    dlMuPairingPrbRatio=0
# @{UPDATED_PARAS_DICT_LIST_2}		${UPDATED_PARAS_DICT_2}
# 
# *** Test Cases ***
# CB009235_C_B102_Case35_Enhanced_PM_counters_MU_MIMO_PAIR_DL_FAIL_SE
# 	Step1:Commission And Reach Onair
# 	Step2:attach 2 ues at 2 pos
# 	Step3:UE1 1layer UE2 3layer DL MU
# 	Step4:Change UE position to low correlation
# 	#dettach UEs
# 	
# *** Keywords ***
# Step1:Commission And Reach Onair
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001    
# 	AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# Step2:attach 2 ues at 2 pos
#     Attach '2' SA UEs
#     set '2' SA UEs Pos
# 	#VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST}
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
# 	: FOR    ${num}    IN RANGE    1    3
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
# Step3:UE1 1layer UE2 3layer DL MU
#     [Documentation]    counter calculation:
# 	...    14Downlink_slot*2Ues*5mins*60sec*100sfn/2+11Downlink_slot*2Ues*5mins*60sec*100sfn/2=750000.
# 	...    1116_3ms framestructure has 14 downlink slots per SFN in half duration,
#     ...    in the other half duration there is 11 downlink slots per SFN.
#     ...    Counter check has difficulty to be very exact, it is ok the result, more than 720000, is close to the expected value, 750000.
#     Log To Console    \n\r==================step3 UE1 1layer UE2 3layer DL MU==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_1layer_2layer_MU
# 	csi_override_testmode_active    1    1    0
#     csi_override_testmode_active    2    2    2
# 	: FOR    ${i}    IN RANGE    1    3
# 	\   ${gw_pdu_r}    evaluate    ${i}%10+1
#     \    Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    150M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    175M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    150M    trf_id=2    pdu_id=${gw_pdu_r}    duration=${3600}
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
#     ${Counter_list}    get DL UL tput from PM counter and get MU counter
# 	${FAIL_HIGH_CORR_counter}    Set Variable    ${Counter_list}[8]
# 	run keyword and continue on failure    should be true    ${FAIL_HIGH_CORR_counter}> 720000
# 
# Step4:Change UE position to low correlation
#     [Documentation]    counter calculation:
# 	...    14Downlink_slot*2Ues*5mins*60sec*100sfn/2+11Downlink_slot*2Ues*5mins*60sec*100sfn/2=750000.
# 	...    1116_3ms framestructure has 14 downlink slots per SFN in half duration,
#     ...    in the other half duration there is 11 downlink slots per SFN.
#     ...    Counter check has difficulty to be very exact, it is ok the result, more than 720000, is close to the expected value, 750000.
#     Log To Console    \n\r==================step4 Change UE position to low correlation==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_low_corr
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=3    sub=2    step=5    scell=0
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
#     ${Counter_list}    get DL UL tput from PM counter and get MU counter
# 	${FAIL_SE_counter}    Set Variable    ${Counter_list}[9]	
# 	run keyword and continue on failure    should be true    ${FAIL_SE_counter}> 720000
# 	
# 
# get DL UL tput from PM counter and get MU counter
#     Log To Console    \n\r==================wait 10mins for counters print out==================\n\r
#     Wait Throughput Timer    600
# 	${PM_counter_DL_value}    VDU Get PM Counter Value   counter_id=M55309C12001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}    VDU Get PM Counter Value   counter_id=M55309C12002   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
# 	${DL_SUCC_counter}=    VDU Get PM Counter Value   counter_id=M55308C34030   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_SUCC_counter}=    Convert To Integer   ${DL_SUCC_counter}
# 	${FAIL_BWP_counter}=    VDU Get PM Counter Value   counter_id=M55308C34031   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_BWP_counter}=    Convert To Integer   ${FAIL_BWP_counter}
# 	${FAIL_TRAF_TYPE_counter}=    VDU Get PM Counter Value   counter_id=M55308C34032   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_TRAF_TYPE_counter}=    Convert To Integer   ${FAIL_TRAF_TYPE_counter}
# 	${FAIL_SRS_BEAM_counter}=    VDU Get PM Counter Value   counter_id=M55308C34033   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_SRS_BEAM_counter}=    Convert To Integer   ${FAIL_SRS_BEAM_counter}
# 	${FAIL_LOW_CQI_counter}=    VDU Get PM Counter Value   counter_id=M55308C34034   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_LOW_CQI_counter}=    Convert To Integer   ${FAIL_LOW_CQI_counter}
# 	${FAIL_LOW_PRB_counter}=    VDU Get PM Counter Value   counter_id=M55308C34035   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_LOW_PRB_counter}=    Convert To Integer   ${FAIL_LOW_PRB_counter}
# 	${FAIL_HIGH_CORR_counter}=    VDU Get PM Counter Value   counter_id=M55308C34036   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_HIGH_CORR_counter}=    Convert To Integer   ${FAIL_HIGH_CORR_counter}
# 	${FAIL_SE_counter}=    VDU Get PM Counter Value   counter_id=M55308C34037   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_SE_counter}=    Convert To Integer   ${FAIL_SE_counter}
# 	${FAIL_OTHER_counter}=    VDU Get PM Counter Value   counter_id=M55308C34038   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${FAIL_OTHER_counter}=    Convert To Integer   ${FAIL_OTHER_counter}
#     [Return]    ${DL_throughput}    ${UL_throughput}    ${DL_SUCC_counter}
# 	...    ${FAIL_BWP_counter}    ${FAIL_TRAF_TYPE_counter}    ${FAIL_SRS_BEAM_counter}    ${FAIL_LOW_CQI_counter}   ${FAIL_LOW_PRB_counter}
# 	...    ${FAIL_HIGH_CORR_counter}    ${FAIL_SE_counter}    ${FAIL_OTHER_counter}
# 	
# dettach UEs
#     : FOR    ${num}    IN RANGE    1    2
#     \    airphone_execute_egate_command    ${delete_PROFILE${num}}
#     DeRegister UE from '1' to '2'
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible