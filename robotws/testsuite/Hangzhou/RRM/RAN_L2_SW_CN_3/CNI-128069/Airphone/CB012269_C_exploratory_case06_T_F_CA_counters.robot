# *** Settings ***
# Test Timeout    120 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CB012269_C_T_F.xml
# ${AIRPHONE_NAME}    IPHY_2T2F_8_4.xml
# ${WTS_NAME}    WTS_8322_G8_case01.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog    
# 
# ${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
# @{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
# ${FILTER_pusch}    uldata_puschreceivereq||uldata_srsreceivereq
# @{titles_pusch}    UlData_puschReceiveReqGrant_t.numOfPuschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn
# ...    3gpp.slot
# ${FILTER_pdsch}    uldata_srsreceivereq||dldata_pdschsendreq
# @{titles_pdsch}    DlData_PdschGrant.numOfPdschSymbols    UlData_srsReceiveReqSubcell_t.srsBwvEnable    3gpp.subcellid    3gpp.sfn    3gpp.slot
# ...    3gpp.rnti
# ${EGATE_TAG}      MUmimo
# ${UE_NUM_SA}      7
# ${BIP_TAG}    8322_bip
# ${BIP_TAG_1}    8322_bip_1
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# ${PROFILE1}    ue_measurement_send_nr id\=1 meas_id\=4 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=80 nrsrq_nr\=80
# ${PROFILE2}    ue_measurement_send_nr id\=1 meas_id\=9 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=53 nrsrp_nr\=80 nrsrq_nr\=80
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
# 
# ${SET_UE1_SA}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_UE2_SA}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_UE3_SA}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# 
# ${PROFILE1_SRS}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-720,-720,-720,-720
# ${PROFILE2_SRS}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-720,-720,-720,-720
# 
# 
# 
# *** Test Cases ***
# CB012269_C_exploratory_case06_T_F_CA_counters
#     Add RD
#     rdEnableNidd For 8322
#     Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
# 	#change ue1to2 location
#     UE1 SA Register
#     UE2 SA Register
#     PM counter check1
#     Change UE1-UE2 SRS power and UE3 CQI less than dlMuMimoCqiTh
# 	
# *** Keywords ***
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	Add GNB swconfig    0x58079f:1		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) CB
# 	Add GNB swconfig	0x590179:1		# rdCsiRsReconfigCellToUE	
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 
# rdEnableNidd For 8322
# 	Add GNB swconfig    0x580789:1		#rdEnableNidd For 8322
# 	Add GNB swconfig    0x9D0000:15		#as PM counter period update to 15/15=1min
# 	Add GNB swconfig    0x5806B1:1		#rdActivatePmCounterMonitoring
# 	Add GNB swconfig    0x5806B2:0xd8220024		#PDSCH_INI_TX_DFTNTAP_BEAM
# 	Add GNB swconfig    0x5806B3:0xd8220025		#PDSCH_SUC_INI_TX_DFTNTAP_BEAM
# 	Add GNB swconfig    0x5806B4:0xd8220026		#PUSCH_INI_TX_DFTNTAP_BEAM
# 	Add GNB swconfig    0x5806B5:0xd8220027		#PUSCH_SUC_INI_TX_DFTNTAP_BEAM
#  
# UE1 SA Register
#     Start capture gnb and ap syslog in 'SA_ue1' file
#     UE from '1' to '1' SA Register	
#     DL and UL data to '1' for dl_trf '6'
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_UE1_SA}
# 	Wait '10s' for stabible 	
#     Start collect ttitrace	
#     Wait for '1s' to stop ttitrace with name'tti'
#     Stop capture gnb and ap syslog in 'SA_ue1' file	
# 
# UE2 SA Register
#     Start capture gnb and ap syslog in 'SA_ue2' file
#     UE from '2' to '2' SA Register	
#     DL and UL data to '2' for dl_trf '6'
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_UE2_SA} 	
# 	Wait '10s' for stabible
#     Start collect ttitrace		
#     Wait for '1s' to stop ttitrace with name'tti1'
#     Stop capture gnb and ap syslog in 'SA_ue2' file	
# 	
# PM counter check1
#     Start capture gnb and ap syslog in 'SA_ue3' file
#     #UE from '3' to '3' SA Register
#     #Airphone Execute Egate Command    ${PROFILE5}
#     #Airphone Execute Egate Command    ${SET_UE3_SA}	
#     #DL and UL data to '3' for dl_trf '6'
#     #Start collect ttitrace		
#     #Wait for '1s' to stop ttitrace with name'tti2'
# 	${dl_tput_ue1_pcell}=     airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
# 	${dl_tput_ue1_scell1}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
# 	${dl_tput_ue1_scell2}=    airphone_get_throughput_on_specific_scell    1    2    type=pdsch    tput_type=ave
# 	${ul_tput_ue1_pcell}=     airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
# 	${dl_tput_ue2_pcell}=     airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
# 	${dl_tput_ue2_scell1}=    airphone_get_throughput_on_specific_scell    2    1    type=pdsch    tput_type=ave
# 	${dl_tput_ue2_scell2}=    airphone_get_throughput_on_specific_scell    2    2    type=pdsch    tput_type=ave
# 	${ul_tput_ue2_pcell}=     airphone_get_throughput_on_specific_scell    2    0    type=pusch    tput_type=ave
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/SA_ue3/
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/SA_ue3${/}	
#     Check_CB009235_counters    ${PM_counter_file} 
#     Stop capture gnb and ap syslog in 'SA_ue3' file	
# 	
# 
# 
# Change UE1-UE2 SRS power and UE3 CQI less than dlMuMimoCqiTh
#     Start capture gnb and ap syslog in 'change_SRS_power' file	
#     Airphone Execute Egate Command    ${PROFILE1_SRS}
#     Airphone Execute Egate Command    ${PROFILE2_SRS}	
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6 scell\=0,1,2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7 scell\=0,1,2
#     #Wait Throughput Timer    2	
#     #airphone_execute_egate_command    csi_override_testmode_nr profile_id\=8 cqi\=3 cqi_mode\=fixed
#     #Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=10
#     Wait Throughput Timer    20
#     Start collect ttitrace		
#     Wait for '1s' to stop ttitrace with name'change_SRS_power'
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/change_SRS_power/
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/change_SRS_power${/}	
#     Check_CB009235_counters    ${PM_counter_file} 
#     Stop capture gnb and ap syslog in 'change_SRS_power' file	
# 	
# 	
# change ue1to2 location
#     airphone_execute_egate_command	  ue_change_location cell\=4 id\=1	
#     airphone_execute_egate_command	  ue_change_location cell\=4 id\=2	
# 	
# 	
# 	
# UE send RANK4
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-1
# 
# SA DeRegister UE '${ue}'
#     airphone_sa_detach    ue_id=${ue}    timeout=5
# 	
# #==========SA=======================
# UE from '${lo}' to '${hi}' SA Register
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
#     \  airphone_cleanup_egate_console_log
#     \  Log To Console   ${\n}-----register UE ${ue} ------
#     \  SA Register UE ${ue}
#     \  airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE	
# 	 
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 
# Get SA '${ue}' crnti in RRC log
#     Log To Console   check UE RRC log to get ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_HO/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1    20M   ${num}
#     \    SA send mutiple trf ul data    ${num}    1    50M    ${num}
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     Log To Console    DL*6 and UL*1 data  to UE ${UE_ID}
# 	airphone_cleanup_egate_console_log	
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   100M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '2s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 
# DL and UL data to '${UE_ID}' little
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     airphone_cleanup_egate_console_log	
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1  
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '2s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_data_UE_${UE_ID}   unzip=TRUE	
# 	
# check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
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
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #check tti
# Check ttitrace
#     Log To Console    Check Bler and beamtype in ttiTrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case41_2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# Start collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Start collect '${bip_file}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}
# 
# Stop collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Stop collect '${bip_file}' tcpdump
#     Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
# 	
# check UE f1ap bip
#     [Arguments]     ${bip_title}		
#     Log To Console   ${\n}---check bip---
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.csv    ${FILTER_f1ap}    ${titles_f1ap}
#     Check Log With Au2anlysis    ${CURDIR}/ini/f1ap_case41.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 
# Check FDD pusch shorten and pdsch shorten skip for CB UE1
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pusch.csv    ${FILTER_pusch}    ${titles_pusch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pusch_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pdsch.csv    ${FILTER_pdsch}    ${titles_pdsch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_skip_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue1_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check FDD pusch shorten and pdsch shorten skip for CB UE2
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pusch.csv    ${FILTER_pusch}    ${titles_pusch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pusch_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pdsch.csv    ${FILTER_pdsch}    ${titles_pdsch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_not_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_not_skip_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue2_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# Check FDD pusch shorten and pdsch shorten skip for CB UE3
#     [Arguments]     ${tti_title}	${bip_title}
# 	Merge_pcaps    ${bip_title}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    50
# 	Set test Variable    ${subcellid_tdd}    ${subcellid_}
# 	${subcellid_}=    getsubcellid    ${TEST_LOG_DIRECTORY()}/All/${tti_title}_dl.csv    53
# 	Set test Variable    ${subcellid_fdd}    ${subcellid_}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pusch.csv    ${FILTER_pusch}    ${titles_pusch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pusch_not_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
# 	...    ${test_log_directory()}/All/${bip_title}/bip_check_pdsch.csv    ${FILTER_pdsch}    ${titles_pdsch}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_shorten_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/fdd_pdsch_skip_G8.ini
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/beamtype_G8_ue3_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Merge_pcaps
#     [Arguments]     ${bip_title}	
# 	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
# 	TAF_SSH.Execute    cd    connection=bsh
# 	TAF_SSH.Send Command    cd ${test_log_directory()}/All/${bip_title};mergecap -w bip_out.pcap *.pcap    connection=bsh
# 
# Check handover
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_back   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/handover_case41.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO_back
# 	
# Check pcell beamtype for wideband and fake drx
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO   unzip=TRUE
#     ${ue1_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case41.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/fakedrx_on_case41.ini    log_need_to_check=pu
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_1_HO
# 
# Check pcell beamtype for subband and normal drx
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/8322_E3_case42_dft.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#      airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE1_2   unzip=TRUE
#      run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue1_fakedrx_off_case42.ini    log_need_to_check=p
# 
# 
# 
# 
# Check_CB009235_counters
#     [Arguments]    ${PM_counter_file}	
#     ${PRB_DL_MU_MIMO_16LAYER_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=1
#     ${PRB_DL_MU_MIMO_16LAYER_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=2
#     ${PRB_DL_MU_MIMO_16LAYER_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=3	
#     ${PRB_DL_MU_MIMO_16LAYER_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=4
# 
# 	
#     ${PRB_DL_MU_MIMO_12LAYER_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}   
# 	...    counter_id=M55308C34019    cell_id=1
#     ${PRB_DL_MU_MIMO_12LAYER_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}   
# 	...    counter_id=M55308C34019    cell_id=2
#     ${PRB_DL_MU_MIMO_12LAYER_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}   
# 	...    counter_id=M55308C34019    cell_id=3
#     ${PRB_DL_MU_MIMO_12LAYER_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}   
# 	...    counter_id=M55308C34019    cell_id=4	
# 	
#     ${PRB_DL_MU_MIMO_8LAYER_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34015    cell_id=1
#     ${PRB_DL_MU_MIMO_8LAYER_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34015    cell_id=2
#     ${PRB_DL_MU_MIMO_8LAYER_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34015    cell_id=3
#     ${PRB_DL_MU_MIMO_8LAYER_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34015    cell_id=4	
# 	
#     ${MU_MIMO_8layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=1
#     ${MU_MIMO_8layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=2	
#     ${MU_MIMO_8layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=3	
#     ${MU_MIMO_8layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=4	
# 	
# 	
#     ${MU_MIMO_6layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=1
#     ${MU_MIMO_6layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=2
#     ${MU_MIMO_6layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=3
#     ${MU_MIMO_6layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=4
# 	
#     ${MU_MIMO_4layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=1
#     ${MU_MIMO_4layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=2	
#     ${MU_MIMO_4layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=3	
#     ${MU_MIMO_4layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=4	
# 		
#     ${MU_MIMO_2layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=1	
#     ${MU_MIMO_2layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=2
#     ${MU_MIMO_2layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=3
#     ${MU_MIMO_2layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=4	
# 		
#     ${SU_MIMO_4layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=1
#     ${SU_MIMO_4layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=2	
#     ${SU_MIMO_4layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=3	
#     ${SU_MIMO_4layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=4	
# 	
#     ${SU_MIMO_2layer_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=1
#     ${SU_MIMO_2layer_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=2	
#     ${SU_MIMO_2layer_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=3
#     ${SU_MIMO_2layer_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=4	
# 	
#     ${MU_MIMO_NOPAIR_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=1	
#     ${MU_MIMO_NOPAIR_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=2	
#     ${MU_MIMO_NOPAIR_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=3	
#     ${MU_MIMO_NOPAIR_UE_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=4		
# 	
#     ${MU_MIMO_2PAIR_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=1	
#     ${MU_MIMO_2PAIR_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=2	
#     ${MU_MIMO_2PAIR_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=3	
#     ${MU_MIMO_2PAIR_UE_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=4		
# 	
#     ${MU_MIMO_3PAIR_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=1	
#     ${MU_MIMO_3PAIR_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=2
#     ${MU_MIMO_3PAIR_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=3
#     ${MU_MIMO_3PAIR_UE_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=4	
# 	
#     ${MU_MIMO_4PAIR_UE_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=1
#     ${MU_MIMO_4PAIR_UE_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=2
#     ${MU_MIMO_4PAIR_UE_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=3
#     ${MU_MIMO_4PAIR_UE_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=4	
# 	
# 
#     ${DL_SUCC_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=1 
#     ${DL_SUCC_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=2 
#     ${DL_SUCC_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=3 
#     ${DL_SUCC_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=4 	
# 	
# 	
#     ${FAIL_BWP_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34031    cell_id=1 
#     ${FAIL_BWP_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34031    cell_id=2 
#     ${FAIL_BWP_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34031    cell_id=3 
#     ${FAIL_BWP_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34031    cell_id=4 	
# 	
#     ${FAIL_TRAF_TYPE_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34032    cell_id=1
#     ${FAIL_TRAF_TYPE_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34032    cell_id=2
#     ${FAIL_TRAF_TYPE_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34032    cell_id=3
#     ${FAIL_TRAF_TYPE_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34032    cell_id=4	
# 		
#     ${FAIL_SRS_BEAM_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34033    cell_id=1
#     ${FAIL_SRS_BEAM_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34033    cell_id=2
#     ${FAIL_SRS_BEAM_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34033    cell_id=3
#     ${FAIL_SRS_BEAM_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34033    cell_id=4	
# 	
# 	
#     ${FAIL_LOW_CQI_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34034    cell_id=1
#     ${FAIL_LOW_CQI_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34034    cell_id=2	
#     ${FAIL_LOW_CQI_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34034    cell_id=3
#     ${FAIL_LOW_CQI_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34034    cell_id=4	
# 	
#     ${FAIL_LOW_PRB_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34035    cell_id=1
#     ${FAIL_LOW_PRB_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34035    cell_id=2	
#     ${FAIL_LOW_PRB_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34035    cell_id=3
#     ${FAIL_LOW_PRB_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34035    cell_id=4	
# 		
#     ${FAIL_HIGH_CORR_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34036    cell_id=1
#     ${FAIL_HIGH_CORR_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34036    cell_id=2	
#     ${FAIL_HIGH_CORR_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34036    cell_id=3	
#     ${FAIL_HIGH_CORR_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34036    cell_id=4	
# 	
#     ${FAIL_SE_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34037    cell_id=1
#     ${FAIL_SE_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34037    cell_id=2
#     ${FAIL_SE_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34037    cell_id=3
#     ${FAIL_SE_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34037    cell_id=4
# 	
#     ${FAIL_OTHER_counter_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34038    cell_id=1
#     ${FAIL_OTHER_counter_cell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34038    cell_id=2
#     ${FAIL_OTHER_counter_cell3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34038    cell_id=3
#     ${FAIL_OTHER_counter_cell4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34038    cell_id=4	
#     run keyword and continue on failure    should be true    ${DL_SUCC_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${DL_SUCC_counter_cell4}==0	
#     run keyword and continue on failure    should be true    ${FAIL_BWP_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_BWP_counter_cell4}==0		
#     run keyword and continue on failure    should be true    ${FAIL_TRAF_TYPE_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_TRAF_TYPE_counter_cell4}==0	
#     run keyword and continue on failure    should be true    ${FAIL_SRS_BEAM_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_SRS_BEAM_counter_cell4}==0	
#     run keyword and continue on failure    should be true    ${FAIL_LOW_CQI_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_LOW_CQI_counter_cell4}==0
#     run keyword and continue on failure    should be true    ${FAIL_LOW_PRB_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_LOW_PRB_counter_cell4}==0
#     run keyword and continue on failure    should be true    ${FAIL_HIGH_CORR_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_HIGH_CORR_counter_cell4}==0		
#     run keyword and continue on failure    should be true    ${FAIL_SE_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_SE_counter_cell4}==0
#     run keyword and continue on failure    should be true    ${FAIL_OTHER_counter_cell3}==0	
#     run keyword and continue on failure    should be true    ${FAIL_OTHER_counter_cell4}==0
# 	