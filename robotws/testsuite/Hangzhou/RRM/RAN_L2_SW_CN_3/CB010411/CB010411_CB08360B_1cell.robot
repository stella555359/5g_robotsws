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
# ${DU_SCF}        SCFC1cell_DU.xml
# ${CU_SCF}        SCFC1cell_CU.xml
# ${AIRPHONE_NAME}    iphy_1cell.xml
# ${WTS_CFG}       1cell.cfg
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
#     Attach SA ue to 5g cell    t2r4_n2    ${UE_ID}
# 	  Wait '1s' for stabible
#     Attach SA ue to 5g cell    t2r4_n2   ${UE_ID2}    PDU_ID=2    GW_ID=2
#     Wait '2s' for stabible
# 	Set ue position
#   Start ul data 160M
# 	Wait '3s' for stabible
# 	run keyword and continue on failure    Check throughput
#   #${trace_id}     VDU Start TTiTrace Log
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
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue throught    ${UE_ID2}    pdu_id=2
#     run keyword and continue on failure    Should be true    ${ul_tput1}+${ul_tput2}>250000
# Verify throughput
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}     scell_id=0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}     scell_id=0    type=pusch    tput_type=ave    
#      should be true    ${ue1_tp}>150000
#      should be true    ${ue2_tp}>150000  
# Online change ulMaxMuMimoLayer to 4
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2    ulMaxMuMimoLayer    4    online
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4PAIR_UE     cell_id=1
# 	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4LAYER      cell_id=1
# 	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=subset4LAYER    cell_id=1
#     should be true    ${PM_counter_value_Pcell}==2
# 	should be true    ${PM_counter_value_Pcell1}==2
# 	should be true    ${PM_counter_value_Pcell2}==2
# Check counter value
#     Wait until keyword succeeds    120s    30s    counter value		
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
