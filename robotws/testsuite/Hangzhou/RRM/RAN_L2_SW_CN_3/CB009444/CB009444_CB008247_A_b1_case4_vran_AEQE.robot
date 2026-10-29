# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# #zhang
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}          2
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# ${DU_SCF}        SCFC_VDU_1208_100M_8247_case4_AEQE.xml
# ${CU_SCF}        SCFC_VCU_8247_case4.xml
# 
# ${AIRPHONE_NAME}   iphy_2CELL_8247_case4_AEQE.xml
# ${WTS_CFG}       WTS_8247_case4_VRAN.cfg
# @{LOG_NAME_LIST}    egatelog
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-250,-250,-260,-260
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${deactive_PROFILE1}	ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}	ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}	ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}	ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# ${deactive_PROFILE5}	ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
# ${deactive_PROFILE6}	ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
# ${deactive_PROFILE7}	ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=7
# 
# ${tti_title_tag}    tti
# *** Test Cases ***
# 8247_A_b1_case4_9444
# #CB008247_A_b1_case4_CL_4x4_8DL4UL_multiUE_no_free_periodic_SRS_and_different_SRS_resource_config_SA
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     
# 	AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# 	Multi UE SA Register and check
# 	set_7UE_position
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '7' with tp '1145'
# 	run keyword and continue on failure   Wait Until Keyword Succeeds    240s    60s   collect and check tti
# 
# 	deactive profile_1_7
# 	DeRegister UEs
# 
# *** Keywords ***
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# Set UE2 position
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
# Set UE3 position
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
# Set UE4 position
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
# Set UE5 position
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
# Set UE6 position
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
# Set UE7 position
#     Airphone Execute Egate Command    ${PROFILE7}
#     Airphone Execute Egate Command    ${SET_PROFILE7}
# set_7UE_position
# 	Set UE1 position
# 	Set UE2 position
# 	Set UE3 position
# 	Set UE4 position
# 	Set UE5 position
# 	Set UE6 position
# 	Set UE7 position
# 	Wait '3s' for stabible
# deactive profile_1_7
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}
# 	Airphone Execute Egate Command    ${deactive_PROFILE5}
# 	Airphone Execute Egate Command    ${deactive_PROFILE6}
# 	Airphone Execute Egate Command    ${deactive_PROFILE7}
# 
# Multi UE SA Register and check
#     : FOR    ${num}    IN RANGE    1    8
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   DL'165M' and UL data to '${num}'
#     \   check UE '${num}' SRS in RRC log
# 
# DL'${dl_data}' and UL data to '${UE_ID}'
#     Log To Console    DL*2 and UL*1 data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   ${dl_data}   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '3s' for stabible
# 
# collect and check tti
# 	${tti_title_tag}    VDU Start TTiTrace Log
# 	Wait '1s' for stabible
# 	VDU Stop TTiTrace Log    ${tti_title_tag}
#     VDU Decode TTiTrace Log
# 
#     Set test Variable  ${best_patternId}    1075	#1102    #1103
#     Set test Variable  ${1st_patternId}     1103	#not used
#     Set test Variable  ${2nd_patternId}     1082	#not used
#     
#     Log To Console    Check ttitrace DL
#     Set test Variable    ${tti_title_tag}		ttiTrace_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_8247_case4_VRAN.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}
# 
#     #Log To Console    Check ttitrace UL
#     #Set test Variable    ${tti_title_tag}		ttiTrace_ul.csv
#     #run keyword and continue on failure     check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/ini/tti_ul_8247_case4_VRAN.ini    log_need_to_check=i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}
# 
#     reorder_csv_CB008247	${TEST_LOG_DIRECTORY()}/ttiTrace_dl.csv
# 	Wait '3s' for stabible
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==7   Set test Variable	 ${rnti_7} 	${rnti_list[0]}
# 	Log To Console   UE ${ue_id}__rnti_${rnti_list[0]}
#     #t2r4_n4:codebook+TAS
#     run keyword if    ${ue_id}<6   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue3_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     #t2r4_n4:codebook
#     run keyword if    ${ue_id}==6   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_t4r4_n4_NO_TAS_SRS_case4.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     # t2r4_n2: NO periodic SRS
#     run keyword if    ${ue_id}==7   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_t2r4_n2_NO_peridic_SRS_case4.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
# 	${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     \      Log To Console		dl ${dl_tput_Mb}
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
#     Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# #check BIP
# collect and check PatternId in BIP
#     Set test Variable   ${pdcch_patternId}		1103
#     Set test Variable   ${pdsch_patternId}		1103,1082
# 
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
# 
#     #Start collect bip log
#     #Wait for '1s' to stop bip log with name'BIP'
#     VDU Start Collect Bip Logs    l2rt
#     Wait '1s' for stabible
#     VDU Stop Collect And Download Bip Logs    container_name=l2rt
# 
#     Log To Console   Check PatternId in bip
#     #convert csv
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     #Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     #...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     #check bip
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_case4.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     Log To Console   Check PatternId in bip finisged
# 
# DeRegister UEs
#     : FOR    ${num}    IN RANGE    1    8
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# copy
# 	#airphone_cleanup_egate_console_log
#     #Set UE1 and UE2 Pos
#     #Attach SA UE1 and UE2
#     #Internal send DL data
#     Wait '30s' for stabible
#     run keyword and continue on failure    Check ue tput is correct
#     Collet VDU and VCU syslog
#     ${id}    VDU Start TTiTrace Log
#     Wait '5s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log
#     #bip, default to capture l1,l2bip
#     VDU Start Collect Bip Logs    l2rt
#     VDU Stop Collect And Download Bip Logs    container_name=l2rt
