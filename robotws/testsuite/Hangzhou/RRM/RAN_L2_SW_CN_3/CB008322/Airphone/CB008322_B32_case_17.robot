# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_case17.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case17.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA_case17.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
# ...   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'    NUMBER_OF_FILES=10
# ${UE_NUM}    4
# ${RRC_Attach}    rrc_attach
# ${RRC_fullbuffer}    fullbuffer
# ${RRC_4UEDFT}    4uedft
# ${RRC_4UESSB}    4uessb
# ${RRC_2UEDFT}    2uedft
# ${RRC_2UEDFT_repower}  2uedft_repower  
# ${RRC_2UEDFT_rank2}  2uedft_rank2 
# ${tti_tag}    ttitrace_fullbuffer
# ${RRC_data}    rrc_data
# ${BIP_TAG}      databip
# ${Power_CMD_1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS multi_path_config\=true
#                   ...     num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-550,-550,-700,-700
# ${Power_CMD_2}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS multi_path_config\=true
#                   ...     num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-800,-800,-800,-800	
# ${Power_CMD_3}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS multi_path_config\=true
#                   ...     num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-350,-350,-350,-350		
# ${Power_CMD_4}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS multi_path_config\=true
#                   ...     num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-300,-300,-550,-550	
# ${Power_CMD_5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS multi_path_config\=true
#                   ...     num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-350,-350,-350,-350				  
# *** Test Cases ***
# CB008322_B32_case017_4UE_T2R4_100Mhz_SubBandSize64_RANK_mixed_SRSperiod320_CLoseLoopMimo_frame1070
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 	SA RegisterUE from 1 to 4
# 	Log To Console		=====step1_2RT====
#     Step1 check 2UE RT beam
# 	Log To Console		=====step2_4DFT====
# 	Step2 check 4UE DFT beam
# 	Log To Console		=====step3_4SSB====
# 	Step3 check 4UE SSB beam
# 	Log To Console		=====step4_power_big_100_2DFT====
# 	Step4 check 2UE DFT beam
# 	Log To Console		=====step5_reconfipower_big100_2DFT====
# 	Step5 reconfigpower check 2UE DFT beam
# 	Log To Console		=====step6_RANK2 2DFT====
# 	Step6 configrank2 check 2UE DFT beam
# 	Stop capture gnb and ap syslog in 'after_onair' file
# *** Keywords ***
# Step1 check 2UE RT beam
#     Airphone Cleanup Egate Console Log
#     set power big than100 to RT
# 	Send '4' SA UE and data buffer sent
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti'
# 	#Wait for '0s' to stop bip log with name'bip2rtstep1'
#     Collect AP egate log    ${RRC_data}
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1            
# Step2 check 4UE DFT beam
#     Airphone Cleanup Egate Console Log
# 	set power small than100 big than120
# 	Wait '3s' for stabible
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'4uedft'
# 	#Wait for '0s' to stop bip log with name'bip4uedftstep2'
#     Collect AP egate log    ${RRC_4UEDFT}
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step2  
# Step3 check 4UE SSB beam
#     Airphone Cleanup Egate Console Log
# 	set power small than120
# 	Wait '3s' for stabible
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'4uessb'
# 	#Wait for '0s' to stop bip log with name'bip4uessbstep3'
#     Collect AP egate log    ${RRC_4UESSB}
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step3  	
# Step4 check 2UE DFT beam
#     Airphone Cleanup Egate Console Log
# 	set power big than100
# 	Wait '3s' for stabible
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'2uedft'
# 	#Wait for '0s' to stop bip log with name'bip2uedftstep4'
#     Collect AP egate log    ${RRC_2UEDFT}
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step4 	
# Step5 reconfigpower check 2UE DFT beam 
#     Airphone Cleanup Egate Console Log
# 	set power big than100_portd 
# 	Wait '3s' for stabible
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'2uedftrepower'
# 	#Wait for '0s' to stop bip log with name'bip2uedftrepowerstep5'
#     Collect AP egate log    ${RRC_2UEDFT_repower}
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step5
# Step6 configrank2 check 2UE DFT beam 
#     Airphone Cleanup Egate Console Log
# 	switch to rank2 
# 	Wait '3s' for stabible
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'2uedftrank2'
# 	#Wait for '0s' to stop bip log with name'bip2uedftrank2step6'
#     Collect AP egate log    ${RRC_2UEDFT_rank2}	
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace step6
# set power big than100 to RT
#     airphone_execute_egate_command    ${Power_CMD_5}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5    
# set power small than100 big than120
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5  
#     airphone_execute_egate_command    ${Power_CMD_1}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3	
# set power small than120  
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3	
#     airphone_execute_egate_command    ${Power_CMD_2}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4	
# set power big than100  
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4	
#     airphone_execute_egate_command    ${Power_CMD_3}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5	
# set power big than100_portd  
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5	
#     airphone_execute_egate_command    ${Power_CMD_4}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6	
# switch to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=8 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=csi_override action\=activate profile_id\=8 scell\=0	
# check bler and beamtype is correct in ttitrace step1                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_RT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step2                   
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_4UE_DFT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step3                  
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_4UE_SSB.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step4                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_DFT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All   
# check bler and beamtype is correct in ttitrace step5                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_DFP.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# check bler and beamtype is correct in ttitrace step6                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_R2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All 	
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	Add GNB swconfig    0x5901E6:0x140
# 	#pdcch use best beam
# 	#Add GNB swconfig    0x580434:0
# 	#Add GNB swconfig    0x580556:0x834        #rdStartPatternId
# 	#Add GNB swconfig    0x5901EB:1      #rdForceEnablingWidebandTasSrs use
#     Add GNB swconfig    0x5805AE:1  
#     Add GNB swconfig     0x5805b0:80                                                                     
#     Add GNB swconfig     0x5805b1:80                                                                     
#     Add GNB swconfig     0x5805b2:50  
#     Add GNB swconfig    0x58076c:10
#     Add GNB swconfig    0x58076d:10  	
# 	Add GNB swconfig    0x580763:2 
# #==========SA=======================
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 
# SA RegisterUE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	 \	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#      \  ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}/egate_console.log.001   crnti: (\\d+)
#      \  run keyword if    ${ue}==1   Set test Variable    ${ue1_rnti}    ${rnti_list[0]}
#      \  run keyword if    ${ue}==2   Set test Variable    ${ue2_rnti}    ${rnti_list[0]}   
#      \  run keyword if    ${ue}==3   Set test Variable    ${ue3_rnti}    ${rnti_list[0]}
#      \  run keyword if    ${ue}==4   Set test Variable    ${ue4_rnti}    ${rnti_list[0]} 	 
# DL and UL data to '${UE_ID}' for dl_trf ${num}
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
# 
# check throughput from SA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# Analyse odftbeam in rrclog
# 	check_log_with_au2anlysis    ${CURDIR}/ini/odftbeam.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_Attach}_egate
# 		
# UE '${num}' send RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	
# 
# 
# Send '${UE_NUM}' SA UE and data buffer sent
# 	: FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    2    160M   ${num}
#     #\   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001    crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# 
