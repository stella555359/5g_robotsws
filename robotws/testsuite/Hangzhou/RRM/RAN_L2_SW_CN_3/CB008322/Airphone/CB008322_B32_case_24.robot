# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_l10wang    AP    SBTS00    RAN_5G_TDD    RAN_5G    
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_B32_case24_8DL4UL_20M.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA_20M.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
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
# 
# *** Test Cases ***
# CB008322_B32_case024_5UE_T1R4_20Mhz_SubBandSize8_RANK2_SRSperiod40_openLoopMimo_frame1208
# 	Add RD
# 	Add RD for CB009496
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Execute AP Command before attach
# 	#Start collect bip log
#     NSA Attach UE11 to UE15
#     NSA UE send RANK2
#     #Wait for '2s' to stop bip log with name'BIP1'
#     DL and UL data to 5 NSA UE
#     Wait '2s' for stabible
#     check throughput from NSA UE '11' to '15' with tp '120'
#     Start collect ttitrace
#     Wait '3s' for stabible
# 	Wait for '1s' to stop ttitrace with name'tti_rank2'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_rank2_dl.csv
#     Check ttitrace
#     UE1 send RANK1
#     Wait '3s' for stabible
#     Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_rank1'
# 	split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_rank1_dl.csv
# 	Check ttitrace again
#     #Dettach UE from '11' to '15'
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# *** Keywords ***
# Add RD
# 	Add GNB swconfig    0x580789:1
# 
# 	
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all NSA ue crnti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_${ue_id}_egate   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_${ue_id}_egate/egate_console.log  newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# DL and UL data to 5 NSA UE
#     NSA send ue '11' mutiple trf '1' for each '160M' DL data
# 	NSA send ue '12' mutiple trf '1' for each '160M' DL data
#     NSA send ue '13' mutiple trf '1' for each '160M' DL data
#     NSA send ue '14' mutiple trf '1' for each '160M' DL data
#     NSA send ue '15' mutiple trf '1' for each '160M' DL data
#     Wait '5s' for stabible
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
# #===========NSA======================
# NSA Attach UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '5s' for stabible
# 
# NSA Attach UE11 to UE15
#     Airphone Nsa Attach     11   profile_id=None
#     Wait '5s' for stabible
#     ${ue1_rnti}    Get NSA '11' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     airphone_cleanup_egate_console_log
#     Airphone Nsa Attach     12   profile_id=None
#     Wait '5s' for stabible
#     ${ue2_rnti}    Get NSA '12' crnti in RRC log
#     set suite variable     ${ue2_rnti}
#     airphone_cleanup_egate_console_log
#     Airphone Nsa Attach     13   profile_id=None
#     Wait '5s' for stabible
#     ${ue3_rnti}    Get NSA '13' crnti in RRC log
#     set suite variable     ${ue3_rnti}
#     airphone_cleanup_egate_console_log
#     Airphone Nsa Attach     14   profile_id=None
#     Wait '5s' for stabible
#     ${ue4_rnti}    Get NSA '14' crnti in RRC log
#     set suite variable     ${ue4_rnti}
#     airphone_cleanup_egate_console_log
#     Airphone Nsa Attach     15   profile_id=None
#     Wait '5s' for stabible
#     ${ue5_rnti}    Get NSA '15' crnti in RRC log
#     set suite variable     ${ue5_rnti}
# 
# check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
#     ${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	${pcell_tp}	Get cell dl throught	${num}    8
# 	\	${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_ul_tp ${dl_tput_Mb}M--
# 	\   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
# 	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
# 	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
# 
# Check ttitrace
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_case24_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace again
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_case24_2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check tti
# Check '${UE_ID}' PatternId and Bler in ttiTrace
#     Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
#     check dft_beam and bler in tti
# 
# check dft_beam and bler in tti
#     Log To Console    Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# 
# 
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
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-50 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=5
# 
# UE1 send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=3 scell\=8
# UE1 send RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=8
# UE1 send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8
# 
# NSA UE send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=15 testmode\=csi_override action\=activate profile_id\=1 scell\=8
# 
# SA UE send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=5 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 
# 
