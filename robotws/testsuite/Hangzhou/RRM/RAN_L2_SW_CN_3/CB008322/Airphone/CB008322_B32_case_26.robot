# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_yuqq    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_B32_case26.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M.xml
# ${WTS_NAME}    wts_SA_NSA_case28_20M.cfg
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
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# ${UE_NUM}    5 
# ${RRC_Attach}    rrc_attach
# ${RRC_fullbuffer}    fullbuffer
# ${tti_tag}    ttitrace_fullbuffer
# ${UE1}     1
# ${UE2}     2
# ${UE3}     3
# ${UE4}     4
# ${UE5}     5
# ${EGATE_TAG}       egate
# ${BIP_little}    bip_littledata
# *** Test Cases ***
# CB008322_B32_case026_8UE_T2R4_20Mhz_SubBandSize32_RANK4_SRSperiod160_openLoopMimo_frame1208
# 	Add RD
# #	Active GNB L2 feature debug traces
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	
# 	
# 	Attach '${UE1}' RANK4 SA UE
# 	${ue1_rnti}    Get SA '${UE1}' crnti in RRC log
# 	set suite variable     ${ue1_rnti}
# 	
# 	Attach '${UE2}' RANK4 SA UE
# 	${ue2_rnti}    Get SA '${UE2}' crnti in RRC log
# 	set suite variable     ${ue2_rnti}
# 	
# 	Attach '${UE3}' RANK4 SA UE
# 	${ue3_rnti}    Get SA '${UE3}' crnti in RRC log
# 	set suite variable     ${ue3_rnti}
# 	
#     Attach '${UE4}' RANK4 SA UE
# 	${ue4_rnti}    Get SA '${UE4}' crnti in RRC log
# 	set suite variable     ${ue4_rnti}
# 	
# 	Attach '${UE5}' RANK4 SA UE
# 	${ue5_rnti}    Get SA '${UE5}' crnti in RRC log
# 	set suite variable     ${ue5_rnti}
# 	
# 	#step1
# 	Send '${UE_NUM}' SA UE and data buffer sent
# 	Wait '5s' for stabible
# 	Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_1'
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'tti_1'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_1_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case26_1.ini'
# 	
# 	#step2
# 	Set UE '${UE1}' low power
#     Wait '2s' for stabible
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_2'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_2'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case26_2.ini'
# 	
# 	#step3
# 	Set UE '${UE1}' power deactivate
# 	Set UE '${UE2}' Rank1
# 	Wait '5s' for stabible
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_3'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_3'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_3_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case26_3.ini'
# 	
# 	#step4
# 	Set UE '${UE2}' Rank4
# 	Stop DL data transfer on UE '${UE3}'
# 	Wait '5s' for stabible
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'bip_4'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_4'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_4_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_rt_dft_case26_4.ini'
# 	
# 	Stop capture gnb and ap syslog in 'after_onair' file
# 	
#  
# *** Keywords ***
# Original Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# #	Add GNB swconfig    0x580264:0x3        #log productH
# #    Add GNB swconfig    0x580434:0      #pdcch use best beam
# 	Add GNB swconfig    0x5901EB:0        #rdForceEnablingWidebandTasSrs,-A set 1,-B set 0
#     Add GNB swconfig    0x580556:0x834    #rdStartPatternId 0x834=2100
#     Add GNB swconfig    0x5805ae:1      #rdEnableSrsSwitchScheduler -B enable
#     Add GNB swconfig    0x5805b0:0x7      #rdSrsBufPercent,50     default=70
#     Add GNB swconfig    0x5805b1:0x50       #rdSrsRlqGoodPercent,60     default=90
#     Add GNB swconfig    0x58076c:0x14
#     Add GNB swconfig    0x58076d:0x14        
#     Add GNB swconfig    0x5805bb:0x2   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB
#     Add GNB swconfig    0x580785:0x64   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB 
# 
# Add RD
# 	Add GNB swconfig    0x580434:0
# 	Add GNB swconfig    0x5805ae:1  #rdEnableSrsSwitchScheduler
# 	Add GNB swconfig    0x5805b0:80
# 	Add GNB swconfig    0x5805b1:80
# 	Add GNB swconfig    0x5805b2:50
# 	#Add GNB swconfig    0x580556:0x834    #rdStartPatternId 0x834=2100
# 	Add GNB swconfig    0x580763:0x2
# 	Add GNB swconfig    0x58076c:0x1                                 
# 	Add GNB swconfig    0x58076d:0x1
# 	Add GNB swconfig    0x590072:1 
# 	Add GNB swconfig    0x5805b5:10
# 	Add GNB swconfig    0x580762:0x20
# 	Add GNB swconfig    0x5901E6:0x28 #rdMinSrsUePeriodicity	
# 	
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check SA UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${ue_id}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 	
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-450,-500,-450,-500
#     airphone_execute_egate_command    ${cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
# 	
# Set UE '${UE_ID}' power deactivate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=10
# 	
# Set UE '${UE_ID}' Rank1
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=9 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=9 scell\=0
# 	
# Set UE '${UE_ID}' Rank4
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=8 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=8 scell\=0
# 	
# Override RANK4 for UE1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0
# 
# 
# Attach '${UE_NUM}' RANK4 SA UE
#     : FOR    ${num}    IN RANGE    ${UE_NUM}    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   UE '${num}' send RANK4
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 		
# UE '${num}' send RANK4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	
# 
# Send '${SA_UE_NUM}' SA UE and data buffer sent
# 	: FOR    ${num}    IN RANGE    1    ${SA_UE_NUM}+1
# #    \   airphone_cleanup_egate_console_log
# #    \   Airphone SA Attach    ue_id=${num}
# #    \   Wait '2s' for stabible
# #    \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
# #    \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
# #    \   Wait '3s' for stabible
#     \   SA send mutiple trf dl data    ${num}    1    100M   ${num}
# #    \   SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 	
# Override CQI1 to UE '${UE1}'
# 	airphone_execute_egate_command     csi_override_testmode_nr profile_id\=2 cqi\=1 cqi_mode\=fixed
# 	airphone_execute_egate_command     ue_testmode_set_nr id\=${UE1} testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 	
# Stop DL data transfer on UE '${UE_ID}'
# 	airphone_execute_egate_command     trf_data_start ue\=${UE_ID} pdu\=${UE_ID} dir\=dl trf_id\=1
# 	airphone_execute_egate_command     trf_data_start ue\=${UE_ID} pdu\=${UE_ID} dir\=dl trf_id\=2
# 	airphone_execute_egate_command     trf_data_start ue\=${UE_ID} pdu\=${UE_ID} dir\=dl trf_id\=3
# 
# Analyse odftbeam in rrclog
# 	check_log_with_au2anlysis    ${CURDIR}/ini/odftbeam.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_Attach}_egate
# 
# collect and check '${ue_id}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP_ue_${ue_id}'
# 
#     #   Check PatternId in bip
#     Log To Console   Check PatternId in bip
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     Set test Variable    ${pdcch_patternId}    101
#     #rank 3/4 UE
#     Set test Variable    ${csi_patternid}     1375,1375,1052,1052
#     #2022_7_22_patternid_changed to 1051,1401
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${csi_patternid}   1051,1051,1401,1401   
#     Set test Variable    ${pdsch_patternid}    1375,1052
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${pdsch_patternid}   1051,1401
#     #rank 1/2 UE
#     Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1024
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     Log To Console   Check PatternId in bip finisged
