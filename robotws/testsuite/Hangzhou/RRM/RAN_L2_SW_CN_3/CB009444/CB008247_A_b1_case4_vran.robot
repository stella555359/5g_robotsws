# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# #zhang		CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
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
# 
# ${DU_SCF}     SCFC_DU_8D8U_AEQE_bsr_8247_case4.xml   
# ${CU_SCF}     SCFC_CU_8D8U_AEQE_bsr_8247_case4.xml   
# ${AIRPHONE_NAME}   iphy_2CELL_AEQE_8D8U_8247_case4.xml
# ${WTS_CFG}       wts_8247_case4.cfg
# 
# @{LOG_NAME_LIST}    egatelog
# 
# *** Test Cases ***
# 8247_A_b1_case4_9444
# #CB008247_A_b1_case4_CL_4x4_8DL4UL_multiUE_no_free_periodic_SRS_and_different_SRS_resource_config_SA
# 	AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
# 
# 	Multi UE SA Register and check
# 	run keyword and continue on failure	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '1' to '7' with tp '1300'
#     ##Collet VDU and VCU syslog
# 	#run keyword and continue on failure     collect and check tti
# 
# 	DeRegister UEs
# 	
# *** Keywords ***
# Multi UE SA Register and check
# 	#positionH:azimuth=0,15,30,40
# 	airphone_execute_egate_command	ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 	
# 	#increase SRS power to make 1st and 2nd beam stable
# 	#airphone_execute_egate_command	ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100
# 	#noise_srs\=-1053
# 	#airphone_execute_egate_command	ue_testmode_set_nr id\=1-7 testmode\=ul_sinr action\=activate profile_id\=5
# 	#set pucch sinr
#     
#     : FOR    ${num}    IN RANGE    1    8
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   DL and UL data to '${num}'
# 
#     \   check UE '${num}' SRS in RRC log
# 
# set pucch sinr
# 	Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=1 sinr_target_pucch\=-300 noise_srs\=-1053
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-7 testmode\=ul_sinr profile_id\=1 action\=activate
# 	Wait '2s' for stabible
# deactive pucch sinr
# 	Airphone Execute Egate Command	ue_testmode_set_nr id\=1-7 testmode\=ul_sinr profile_id\=1 action\=deactivate
# 	Wait '2s' for stabible
# DL and UL data to '${UE_ID}'
#     Log To Console    DL*2 and UL*1 data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '3s' for stabible
# 
# collect and check tti
# 	${trace_id}     VDU Start TTiTrace Log
#     Wait '1s' for stabible
#     VDU Stop TTiTrace Log    ${trace_id}
#     Collet VDU and VCU syslog
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/ttiTrace
# 	
#     Set test Variable  ${best_patternId}    1325
#     Set test Variable  ${1st_patternId}     1326
#     Set test Variable  ${2nd_patternId}     1322
#     
#     Log To Console    Check ttitrace DL
#     Set test Variable    ${tti_title_tag}		ttiTrace_dl.csv
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_8247_case4_VRAN.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}
# 
#     #Log To Console    Check ttitrace UL
#     #Set test Variable    ${tti_title_tag}
#    ...    		CB008247_A_b1_case4_CL_4x4_8DL4UL_multiUE_no_free_periodic_SRS_and_different_SRS_resource_config_SA_ul.csv
#     #run keyword and continue on failure     check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/ini/tti_ul_8247_case4_VRAN.ini    log_need_to_check=i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}
# 
#     reorder_csv_CB008247	${TEST_LOG_DIRECTORY()}/ttiTrace_dl.csv
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
#     \      Log To Console		ul ${dl_tput_Mb}
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
#     Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>${dl_cell_tp}
# 
# #check BIP
# collect and check PatternId in BIP
#     Set test Variable   ${pdcch_patternId}		1050
#     Set test Variable   ${pdsch_patternId}		1024,1028
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
#     \   Wait '4s' for stabible
