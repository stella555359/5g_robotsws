# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_B32_8D4U_AQQL_1208_20M_SBsize16_case28.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M.xml
# ${WTS_NAME}    wts_SA_NSA_case28_20M.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog    
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    8322_bip
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# 
# *** Test Cases ***
# CB008322_B32_case028_5UE_T2R4_20Mhz_SubBandSize16_RANK_switch_SRSperiod40_closeLoopMimo_frame1208
#     #Add RD
#     #Add RD for CB009496
#     rdEnableNidd For 8322
#     Active GNB L2 feature debug traces
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'SA_ue' file
#     Start collect bip log
#     UE from '1' to '5' SA Register
#     Wait for '0s' to stop bip log with name'ue_register'
#     SA send data '5' UEs
#     ${ue1_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     ${ue2_rnti}    Get SA '2' crnti in RRC log
#     set suite variable     ${ue2_rnti}
#     ${ue3_rnti}    Get SA '3' crnti in RRC log
#     set suite variable     ${ue3_rnti}
#     ${ue4_rnti}    Get SA '4' crnti in RRC log
#     set suite variable     ${ue4_rnti}
#     ${ue5_rnti}    Get SA '5' crnti in RRC log
#     set suite variable     ${ue5_rnti}	
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     #reorder_csv_CB008322  	${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_dl.csv	
#     Wait '5s' for stabible
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG}'
#     run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput from SA UE '1' to '5' with tp '170'
#     Start collect ttitrace
#     UE1 send RANK1
#     Wait for '2s' to stop ttitrace with name'tti_1'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_1_dl.csv
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'8322_bip_1'
#     Start collect ttitrace
#     UE2 send RANK3
#     UE3 send RANK2
#     UE4 send RANK1
#     Wait for '2s' to stop ttitrace with name'tti_2'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_2_dl.csv
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'8322_bip_2'
#     Start collect ttitrace
#     UE1 send RANK2
#     Wait for '2s' to stop ttitrace with name'tti_3'
#     split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_3_dl.csv
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'8322_bip_3'
#     DeRegister UE from '1' to '5'
#     Check ttitrace
#     Stop capture gnb and ap syslog in 'SA_ue' file
#     
# *** Keywords ***
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	#Add GNB swconfig    0x5901E6:0x50
# 	#pdcch use best beam
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
# rdEnableNidd For 8322
# 	Add GNB swconfig    0x580789:1		#rdEnableNidd For 8322
# 
# #==========SA=======================
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
#     \	airphone_cleanup_egate_console_log
#     \	Log To Console   ${\n}-----register UE ${ue} ------
#     \	SA Register UE ${ue}
#     \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1   60M   ${num}
# #    \    SA send mutiple trf ul data    ${num}    1    175M   ${num}
# 	 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 
# Get SA '${ue}' crnti in RRC log
#     Log To Console   check UE RRC log to get ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 	
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     airphone_cleanup_egate_console_log	
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 
# check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
#     ${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     \      Log To Console		dl ${dl_tput_Mb}
#     \      ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
#     Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
#     run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #check tti
# #check tti
# Check ttitrace
#     Log To Console    Check Bler and beamtype in ttiTrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case28.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case28_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case28_2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case28_3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# UE3 send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=3 scell\=0
# 	
# UE2 send RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=4 scell\=0
# 
# UE1 send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 
# UE1 send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 
# UE4 send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=5 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=5 scell\=0
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
