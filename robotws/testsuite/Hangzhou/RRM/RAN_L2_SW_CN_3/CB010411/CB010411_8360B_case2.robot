# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    #AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     #AiC Common Test Teardown
# #Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    yang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${CELL_ID}        0
# ${UE_NUM}          2
# ${UE_ID}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# ${DU_SCF}        SCFC_DU_8D8U_AEQE_bsr_8360B_case2.xml
# ${CU_SCF}        SCFC_CU_8D8U_AEQE_bsr_8360B_case2.xml
# ${AIRPHONE_NAME}    iphy_2CELL_AEQE_8D8U_8360B_case2.xml
# ${WTS_CFG}       wts_8360B_case2.cfg
# @{LOG_NAME_LIST}    egatelog
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=2 trigger_puxch_update\=0
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
# ${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
# ${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5			
# ${SINR_3}         ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5			  
#   
# 
# *** Test Cases ***
# CB008360_B_B1a_case02_two_rank2_Ues_8DL8UL_Max_4Layer_without_tapering
# 	AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     
# 	AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}    
#     airphone_cleanup_egate_console_log
#     change ue location
#     Attach SA ue to 5g cell    t2r4_n2    ${UE_ID}
# 	  Wait '1s' for stabible
#     Attach SA ue to 5g cell    t2r4_n2   ${UE_ID2}    PDU_ID=2    GW_ID=2
#     Wait '2s' for stabible
# 	Set ue position
#   Start ul data 160M
# 	Wait '3s' for stabible
# 	run keyword and continue on failure    Check throughput
# #	${trace_id}     VDU Start TTiTrace Log
#   #  Wait '1s' for stabible
#   #  VDU Stop TTiTrace Log    ${trace_id}
#     Collet VDU and VCU syslog
#   #  VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos
# 	#reorder_csv_CB008360	${TEST_LOG_DIRECTORY()}/tti_UE12_diff_pos_ul.csv
#     Stop egate log and unzip with name'pair'
#    # run keyword and continue on failure    check bler and pair is correct in ttitrace  
# 
# *** Keywords ***
# change ue location
#     airphone_execute_egate_command	  ue_change_location cell\=2 id\=1	
#     airphone_execute_egate_command	  ue_change_location cell\=2 id\=2
# Start ul data 160M
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   80M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#   	Wait '1s' for stabible
#     Airphone SA Start Data Traffic    ${UE_ID2}   UL   80M   pdu_id=${UE_ID2}   duration=3600   trf_id=1
#     Wait '1s' for stabible
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   80M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Wait '1s' for stabible
#     Airphone SA Start Data Traffic    ${UE_ID2}   UL   80M   pdu_id=${UE_ID2}   duration=3600   trf_id=2
# check bler and pair is correct in ttitrace 
# 	Log To Console    ${\n}--check bler and pair is correct in ttitrace --
# 	Set test Variable    ${tti_title_tag}		tti_UE12_diff_pos_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_B_case02_vran.ini   i
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}
# Wait time to stable
#     sleep    2s
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# Verify throughput
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}     scell_id=0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}     scell_id=0    type=pusch    tput_type=ave    
#      should be true    ${ue1_tp}>150000
#      should be true    ${ue2_tp}>150000  
# 	
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}	
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
