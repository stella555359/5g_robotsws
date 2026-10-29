# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B102_CASE10_getAnUeForCheck__Different_distribution_of_UEs_8layers_performance
# 
# Test Timeout      150 minutes
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
# ${DU_SCF}        vDu_basic003_8D4U.xml
# ${CU_SCF}        CU_11169_9235.xml
# ${AIRPHONE_NAME}    iphy_AEQE_DC_advancedSRS.xml
# ${WTS_CFG}       wts_11169_9235_1cell_SA_NSA_case20.lua
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
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
# &{UPDATED_PARAS_DICT_1}    actMuAwareTdSch=true    dlMuAwareCorrThd=0.05
# @{UPDATED_PARAS_DICT_LIST_1}		${UPDATED_PARAS_DICT_1}
# &{UPDATED_PARAS_DICT_2}    dlMuAwareCorrThd=0.1
# @{UPDATED_PARAS_DICT_LIST_2}		${UPDATED_PARAS_DICT_2}
# &{UPDATED_PARAS_DICT_3}    dlMuAwareCorrThd=0.2
# @{UPDATED_PARAS_DICT_LIST_3}		${UPDATED_PARAS_DICT_3}
# &{UPDATED_PARAS_DICT_4}    actMuAwareTdSch=true    dlMuAwareCorrThd=0.1
# @{UPDATED_PARAS_DICT_LIST_4}		${UPDATED_PARAS_DICT_4}
# ${TP_PEAK_DL}    641000
# ${TP_PEAK_DL_MU}  1280000
# ${TP_PEAK_UL}    126000   #211mbps
# 
# *** Test Cases ***
# CB009235_A_B102_CASE10_getAnUeForCheck__Different_distribution_of_UEs_8layers_performance
# 	Step1:Commission And Reach Onair
#     Step2:attach 30 ues at 16 pos
# 	step3:online change MuAwareParameter 'true' ‘5’ ‘80’ and check counter '1'
# 	step3:online change MuAwareParameter 'true' ‘10’ ‘80’ and check counter '2'
#     step3:online change MuAwareParameter 'true' ‘20’ ‘80’ and check counter '3'
#     step3:online change MuAwareParameter 'false' ‘10’ ‘80’ and check counter '4'
#     step4:kpi and counter check
# 	#dettach UEs
# 
# *** Keywords ***
# Step1:Commission And Reach Onair
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001    
# 	AIC Perform Full Commission And Reach Onair DC    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# Step2:attach 30 ues at 16 pos
#     Attach '30' SA UEs
#     set '30' SA UEs Pos
# 	add UEs bler
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
# add UEs bler
#     Log To Console   add bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=95,2,3,4
#    : FOR    ${num}    IN RANGE    1    31
#    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# step3:online change MuAwareParameter '${actMuAwareTdSch}' ‘${dlMuAwareCorrThd}’ ‘${dlMuAwarePrbRatio}’ and check counter '${table_tag}'
#     Log To Console   \n---------step3:online change dlMuAwareCorrThd ${dlMuAwareCorrThd} and check counter----------
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_do_traffic_${table_tag}
# 	: FOR    ${i}    IN RANGE    1    31
# 	\   ${gw_pdu_r}    evaluate    ${i}%10+1
#     \    Airphone SA Start Data Traffic    ${i}    DL    10M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=1    pdu_id=${gw_pdu_r}    duration=${3600}
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti
# 	run keyword and continue on failure    VDU Online Change Parameters      ${MO_DN_LIST}     ${UPDATED_PARAS_DICT_LIST_${table_tag}}
# 	Wait '600s' for stabible
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/Case10_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure	   Get UEs TP for debug
# 	${8701_pair_counter_for_table}    Ideal line PRB_mulayer counter check
# 	${9235_kpi_list}    KPI counter check
# 	Record result for 9235 perfomance    ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}
#     ...    ${8701_pair_counter_for_table}    ${9235_kpi_list}
# 	
# 	run keyword and continue on failure    check_power_boosting    ${save_log}/tti_dl.csv
# 	#${tput_MuCounter}    get DL UL tput from PM counter and get MU counter
# 	#${mu_counter_sum_100}    evaluate    sum(${tput_MuCounter}[2:])
# 	#Set Global Variable    ${mu_counter_sum_100}    ${mu_counter_sum_100}
# 	#Log To Console    ${mu_counter_sum_100}
# 
# step4:kpi and counter check
#     Log To Console   \n--------step4:kpi and counter check-------
#     ${sum_prb_layer_X_layer1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    1
#     ${sum_prb_layer_X_layer2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    2
#     ${sum_prb_layer_X_layer3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    3
#     ${sum_prb_layer_X_layer4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    4
#     ${KPI_NR_5242b_cell_tp_avg1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    1
#     ${KPI_NR_5242b_cell_tp_avg2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    2
#     ${KPI_NR_5242b_cell_tp_avg3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    3
#     ${KPI_NR_5242b_cell_tp_avg4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    4
#     run keyword and continue on failure    should be true    ${sum_prb_layer_X_layer2}>${sum_prb_layer_X_layer4}
#     run keyword and continue on failure    should be true    ${KPI_NR_5242b_cell_tp_avg2}>${KPI_NR_5242b_cell_tp_avg4}
#     ${9235_sum_prb_layer_gain}    evaluate    (${sum_prb_layer_X_layer2}-${sum_prb_layer_X_layer4})/${sum_prb_layer_X_layer4}
#     log to console    sum_prb_layer_gain is ${9235_sum_prb_layer_gain}
#     run keyword and continue on failure    should be true    ${9235_sum_prb_layer_gain}>0
#     ${9235_cell_avg_gain}    evaluate    (${KPI_NR_5242b_cell_tp_avg2}-${KPI_NR_5242b_cell_tp_avg4})/${KPI_NR_5242b_cell_tp_avg4}
#     log to console    sum_prb_layer_gain is ${9235_cell_avg_gain}
#     run keyword and continue on failure    should be true    ${9235_cell_avg_gain}>0
# 
# Get UEs TP for debug
#     ${UEs_TP_DL_r1}   create list
#     ${UEs_TP_UL_r1}   create list
#     : FOR    ${num}    IN RANGE    1    31
#     \    ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL_MU}/30
#     \    ${TP_DL_perUE_target_nopairing}   evaluate  ${TP_PEAK_DL}/30
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    append to list    ${UEs_TP_DL_r1}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL_r1}    ${ul_throughput_pcell}
#     log to console    UE1 to UE30 DL_TP_result are ${UEs_TP_DL_r1}
#     log to console    UE1 to UE30 UL_TP_result are ${UEs_TP_UL_r1}
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
# Ideal line PRB_mulayer counter check
#     #[Arguments]    ${PM_counter_file}
#     ${8701_pair_counter}   create list
#     ${8701_pair_counter_for_table}   create list
#     : FOR    ${num}    IN RANGE    1    30
#     \    ${counter_1}   evaluate   4000+${num}
# 	#\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     #...    counter_id=M55308C3${counter_1}    cell_id=1
# 	\    ${result}=    VDU Get PM Counter Value    counter_id=M55308C3${counter_1}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${8701_pair_counter}    ${result}
#     log to console    8701_pair_counter all is = ${8701_pair_counter}
#     log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are = ${8701_pair_counter[0:4]}
#     log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are = ${8701_pair_counter[4:11]}
#     log to console    PRB_DL_MU_MIMO_layer2 is = ${8701_pair_counter[4]}
#     log to console    PRB_DL_MU_MIMO_layer3 is = ${8701_pair_counter[5]}
#     log to console    PRB_DL_MU_MIMO_layer4 is = ${8701_pair_counter[6]}
#     log to console    PRB_DL_MU_MIMO_layer5 is = ${8701_pair_counter[7]}
#     log to console    PRB_DL_MU_MIMO_layer6 is = ${8701_pair_counter[8]}
#     log to console    PRB_DL_MU_MIMO_layer7 is = ${8701_pair_counter[9]}
#     log to console    PRB_DL_MU_MIMO_layer8 is = ${8701_pair_counter[10]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_6_7_8 are = ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
#     log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are = ${8701_pair_counter[15:23]}
#     log to console    PRB_DL_MU_MIMO_layer_9 is = ${8701_pair_counter[15]}
#     log to console    PRB_DL_MU_MIMO_layer_10 is = ${8701_pair_counter[16]}
#     log to console    PRB_DL_MU_MIMO_layer_11 is = ${8701_pair_counter[17]}
#     log to console    PRB_DL_MU_MIMO_layer_12 is = ${8701_pair_counter[18]}
#     log to console    PRB_DL_MU_MIMO_layer_13 is = ${8701_pair_counter[19]}
#     log to console    PRB_DL_MU_MIMO_layer_14 is = ${8701_pair_counter[20]}
#     log to console    PRB_DL_MU_MIMO_layer_15 is = ${8701_pair_counter[21]}
#     log to console    PRB_DL_MU_MIMO_layer_16 is = ${8701_pair_counter[22]}
#     log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are = ${8701_pair_counter[27]} ${8701_pair_counter[28]}
#     ${sum_prb_layer1}    evaluate    ${8701_pair_counter[4]}*2+${8701_pair_counter[5]}*3+${8701_pair_counter[6]}*4
#     ${sum_prb_layer2}    evaluate    ${8701_pair_counter[7]}*5+${8701_pair_counter[8]}*6+${8701_pair_counter[9]}*7+${8701_pair_counter[10]}*8
#     ${sum_prb_layer3}    evaluate    ${8701_pair_counter[15]}*9+${8701_pair_counter[16]}*10+${8701_pair_counter[17]}*11+${8701_pair_counter[18]}*12
#     ${sum_prb_layer4}    evaluate    ${8701_pair_counter[19]}*13+${8701_pair_counter[20]}*14+${8701_pair_counter[21]}*15+${8701_pair_counter[22]}*16
#     ${sum_prb_layer_X_layer}    evaluate    ${sum_prb_layer1}+${sum_prb_layer2}+${sum_prb_layer3}+${sum_prb_layer4}
# 
#     log to console    sum_prb_layer_X_layer is ${sum_prb_layer_X_layer}
# 
#     ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
#     ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
#     ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
# #    ${pair_to_muelig}    evaluate    ${8701_pair_counter[27]}/${8701_pair_counter[28]}
#     run keyword and continue on failure   should be true
#     ...    ${PRB_DL_MU_paired_UE_total}-100000<=${PRB_DL_MU_MIMO_layer_total}<=${PRB_DL_MU_paired_UE_total}+100000
#     run keyword and continue on failure   should be true
#     ...    ${8701_pair_counter[11]}-1000000<=${PRB_DL_SU_MIMO_layer_total}<=${8701_pair_counter[11]}+1000000
#     run keyword and continue on failure   should be true
#     ...    ${PRB_DL_MU_paired_UE_total}-100000<=${PRB_DL_MU_MIMO_layer_total}<=${PRB_DL_MU_paired_UE_total}+100000
# #    run keyword and continue on failure   should be true   ${pair_to_muelig}>0.98
#     log to console    PRB_DL_SU_MIMO_layer_total is = ${PRB_DL_SU_MIMO_layer_total}
#     log to console    PRB_DL_MU_MIMO_layer_total is = ${PRB_DL_MU_MIMO_layer_total}
#     log to console    PRB_DL_MU_paired_UE_total is = ${PRB_DL_MU_paired_UE_total}
#     append to list    ${8701_pair_counter_for_table}    ${8701_pair_counter[4]}    ${8701_pair_counter[5]}    ${8701_pair_counter[6]}
#     ...    ${8701_pair_counter[7]}    ${8701_pair_counter[8]}    ${8701_pair_counter[9]}    ${8701_pair_counter[10]}
#     ...    ${8701_pair_counter[15]}    ${8701_pair_counter[16]}    ${8701_pair_counter[17]}    ${8701_pair_counter[18]}
#     ...    ${8701_pair_counter[19]}    ${8701_pair_counter[20]}    ${8701_pair_counter[21]}    ${8701_pair_counter[22]}
#     ...    ${sum_prb_layer_X_layer}    ${PRB_DL_SU_MIMO_layer_total}    ${PRB_DL_MU_MIMO_layer_total}
#     set global variable    ${8701_pair_counter}
#     set global variable    ${8701_pair_counter_for_table}
#     [Return]    ${8701_pair_counter_for_table}
# 
# KPI counter check
#     #[Arguments]    ${PM_counter_file}
#     ${PDSCH_UNSUCC_64TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
#     ${PDSCH_UNSUCC_256TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_2}   evaluate   2000+${num}
#     \    ${counter_3}   evaluate   3000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
#     \    ${counter_7}   evaluate   7000+${num}
# 	\    ${result}=    VDU Get PM Counter Value   counter_id=M55300C0${counter_2}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
# 	\    ${result}=    VDU Get PM Counter Value   counter_id=M55300C0${counter_3}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}
# 
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0${counter_6}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0${counter_7}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
# #    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
# #    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
# #    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
#     ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
#     ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
#     ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.001
# #    log to console    KPI NR_5055b residual bler is ${NR_5055b}
# 
#     ${PDSCH_INITX_64TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_64TBL_MCS}    create list
#     ${PDSCH_INI_256TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_256TBL_MCS}    create list
# 
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0000${counter_0}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    10    29
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C000${counter_0}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_1}   evaluate   1000+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0${counter_1}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
#     \    ${counter_4}   evaluate   4000+${num}
#     \    ${counter_5}   evaluate   5000+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0${counter_4}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55300C0${counter_5}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
# #    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
# 
#     ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
#     ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
#     ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
# 
# 
#     ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
#     ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_22}   evaluate   2000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55304C0${counter_22}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55304C0${counter_6}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
# #    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
# #    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}
# 
#     ${rt1}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C03005    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${rt1}=    Convert To Integer   ${rt1}
#     ${rt2}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C10001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${rt2}=    Convert To Integer   ${rt2}
#     ${rt3}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00008    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${rt3}=    Convert To Integer   ${rt3}
#     ${rt4}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00016    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${rt4}=    Convert To Integer   ${rt4}
#     ${rt5}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00018    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${rt5}=    Convert To Integer   ${rt5}
#     ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
#     ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
# #    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
# 
#     ${L_M55304C0400X}   create list
#     ${M55304C0400X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C0400${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C040${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     ${L_M55304C0800X}   create list
#     ${M55304C0800X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C0800${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C080${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     ${L_M55304C1000X}   create list
#     ${M55304C1000X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C1000${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    VDU Get PM Counter Value
#     ...    counter_id=M55304C100${num}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
#     ${L_M55308}   create list
#     ${M55308C03006}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C03006    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${M55308C03006}=    Convert To Integer   ${M55308C03006}
#     ${M55308C10002}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C10002    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${M55308C10002}=    Convert To Integer   ${M55308C10002}
#     ${M55308C00009}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00009    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${M55308C00009}=    Convert To Integer   ${M55308C00009}
#     ${M55308C00011}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00011    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${M55308C00011}=    Convert To Integer   ${M55308C00011}
#     append to list    ${L_M55308}    ${M55308C03006}
#     append to list    ${L_M55308}    ${M55308C10002}
#     append to list    ${L_M55308}    ${M55308C00009}
#     append to list    ${L_M55308}    ${M55308C00011}
#     ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
#     ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
# #    log to console    64qam:${L_M55304C0400X}
# #    log to console    dft_s_ofdm:${L_M55304C0800X}
# #    log to console    256qam:${L_M55304C1000X}
# #    log to console    ${L_M55308}
# #    log to console    SE_KPI_Value=${NR_5109d}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    VDU Get PM Counter Value
#     ...    counter_id=M55309C12001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    Convert To Integer   ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#     ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
# #    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_2}   evaluate   1000+${num}
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55304C0${counter_2}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55366C0${counter_3}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
#     : FOR    ${num}    IN RANGE    0    28
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    VDU Get PM Counter Value
#     ...    counter_id=M55304C0${counter_3}    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	\    ${result}=    Convert To Integer   ${result}
#     \    append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    VDU Get PM Counter Value
#     ...    counter_id=M55304C00001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    Convert To Integer   ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#     ${PRB_USED_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C10001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PRB_USED_PDSCH}=    Convert To Integer   ${PRB_USED_PDSCH}
#     ${PRB_AVAIL_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C10003    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${PRB_AVAIL_PDSCH}=    Convert To Integer   ${PRB_AVAIL_PDSCH}
# #    log to console    PDSCH_INI_VOL_64TBL_MCS_list 0_to_28 is ${PDSCH_INI_VOL_64TBL_MCS_list}
# #    log to console    PDSCH_INI_VOL_256TBL_MCS_list 0_to_27 is ${PDSCH_INI_VOL_256TBL_MCS_list}
# #    log to console    MEAS_PERIOD_NR_MAC_PDU_TPUT is ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
# #    log to console    PRB_USED_PDSCH is ${PRB_USED_PDSCH}
# #    log to console    PRB_AVAIL_PDSCH is ${PRB_AVAIL_PDSCH}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
#     ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
#     ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
#     ${NR_5242b_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
#     ${NR_5242b_fenzi2}    evaluate    ${NR_5242b_fenzi1}/${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#     ${NR_5242b_fenmu}    evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
#     ${NR_5242b}    evaluate    ${NR_5242b_fenzi2}/${NR_5242b_fenmu}
# #    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
# 
# 
#     ${DL_MAC_SDU_VOL_DTCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55309C01001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_MAC_SDU_VOL_DTCH}=    Convert To Integer   ${DL_MAC_SDU_VOL_DTCH}
#     ${DATA_SLOT_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00005    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DATA_SLOT_PDSCH}=    Convert To Integer   ${DATA_SLOT_PDSCH}
#     ${DATA_SLOT_PDSCH_TIME}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00008    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DATA_SLOT_PDSCH_TIME}=    Convert To Integer   ${DATA_SLOT_PDSCH_TIME}
#     ${ACC_UE_DL_DRB_DATA}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C02000    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${ACC_UE_DL_DRB_DATA}=    Convert To Integer   ${ACC_UE_DL_DRB_DATA}
#     ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})
# 
#     ${ACC_SCHED_UE_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C17001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${ACC_SCHED_UE_PDSCH}=    Convert To Integer   ${ACC_SCHED_UE_PDSCH}
#     ${TOTAL_COSCHED_UE_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C02004    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${TOTAL_COSCHED_UE_PDSCH}=    Convert To Integer   ${TOTAL_COSCHED_UE_PDSCH}
#     ${DL_DATA_SLOTS}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00001    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DL_DATA_SLOTS}=    Convert To Integer   ${DL_DATA_SLOTS}
#     ${DATA_SLOT_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00005    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${DATA_SLOT_PDSCH}=    Convert To Integer   ${DATA_SLOT_PDSCH}
#     ${SSB_SLOT_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00015    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${SSB_SLOT_PDSCH}=    Convert To Integer   ${SSB_SLOT_PDSCH}
#     ${TRS_SLOT_PDSCH}=    VDU Get PM Counter Value
#     ...    counter_id=M55308C00017    dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 	${TRS_SLOT_PDSCH}=    Convert To Integer   ${TRS_SLOT_PDSCH}
#     ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
#     ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
# 
#     log to console    KPI NR_5055b residual bler is = ${NR_5055b}
#     log to console    KPI NR_5054a iniBler is = ${NR_5054a}
#     log to console    KPI NR_5108d SE_downlink is = ${NR_5108d}
#     log to console    KPI NR_5109d SE_uplink is = ${NR_5109d}
#     log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
#     log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
#     log to console    KPI NR_5100b Avg MAC user thp DL = ${NR_5100b}
#     log to console    KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.005
#     ${9235_kpi_list}   create list    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}    ${NR_5242b}
#     ...    ${NR_5258a}    ${NR_5100b}    ${NR_5192c}
#     [return]     ${9235_kpi_list}
# 
# Record result for 9235 perfomance
#     [Arguments]     ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}    ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    ${table_tag}
#     ...    9235_${actMuAwareTdSch}_mucor_${dlMuAwareCorrThd}
#     : FOR    ${num}    IN RANGE    0    18
#     \    ${num_table}    evaluate    ${num}+1
#     \    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    ${table_tag}
#     ...    ${8701_pair_counter_for_table[${num}]}
#     : FOR    ${num}    IN RANGE    0    8
#     \    ${num_table}    evaluate    ${num}+19
#     \    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}     ${table_tag}
#     ...    ${9235_kpi_list[${num}]}
# 	
# dettach UEs
#     : FOR    ${num}    IN RANGE    1    17
#     \    airphone_execute_egate_command    ${delete_PROFILE${num}}
#     DeRegister UE from '1' to '30'
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
