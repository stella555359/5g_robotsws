# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown   # Common Test Teardown
# Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G    
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_B32_8D4U_AQQL_1208_20M_SBsize0.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA_20M.cfg
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
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    BB_SLOT_6='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
# ...   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'    NUMBER_OF_FILES=10
# ${UE_ID_11}       11
# ${UE_ID_12}       12
# ${UE_ID_13}       13
# ${UE_ID_14}       14
# *** Test Cases ***
# CB008322_B32_case023_4UE_T1R4_20Mhz_SubBandSize0_RANK2_SRSperiod20_openLoopMimo_frame1208
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
#     Start capture gnb and ap syslog in 'NSA_ue' file
# 	airphone_execute_egate_command    enb_x2_link_up enb\=1 target\=2
# 	NSA Attach UE from '11' to '14'
#     switch to rank2
# 	Log To Console		=====check step1 4RT=====
# 	#Start collect bip log
# 	Start collect ttitrace
# 	NSA send ue '11' mutiple trf '1' for each '50M' DL data
# 	NSA send ue '12' mutiple trf '1' for each '50M' DL data
# 	NSA send ue '13' mutiple trf '1' for each '50M' DL data
# 	NSA send ue '14' mutiple trf '1' for each '100M' DL data
#     Wait for '2s' to stop ttitrace with name'ue_register'
# 	#Wait for '0s' to stop bip log with name'ue_register'
# 	Wait '2s' for stabible
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s    check throughput
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace 4RT 
# 	split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
# 	Log To Console		=====check step2 1RT=====
# 	#Start collect bip log 
# 	Start collect ttitrace
# 	switch to low cqi
# 	Wait for '0s' to stop ttitrace with name'templowcqi'
#     #Wait for '0s' to stop bip log with name'templowcqi'
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'lowcqi'
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace 1RT 
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s    check throughputlow
# 	split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/lowcqi_dl.csv
# 	Log To Console		=====check step3 4RT=====
# 	#Start collect bip log 
# 	Start collect ttitrace	
# 	switch to good cqi
# 	Wait for '2s' to stop ttitrace with name'tempgoodcqi'
#     #Wait for '0s' to stop bip log with name'tempgoodcqi'	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'goodcqi'
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s    check throughput
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace 4RT goodcqi 	
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    30s    2s    check throughput
# 	Dettach UE from '11' to '14'
#     Stop capture gnb and ap syslog in 'NSA_ue' file
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_4UE   unzip=TRUE
#     
# *** Keywords ***
# check bler and beamtype is correct in ttitrace 4RT goodcqi                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c23_4RTg.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace 4RT                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c23_4RT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace 1RT                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c23_1RT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# switch to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11-14 testmode\=csi_override action\=activate profile_id\=1 scell\=8
# 
# switch to low cqi
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=5 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8
#     Wait '2s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=5 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=csi_override action\=activate profile_id\=3 scell\=8
#     Wait '2s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=5 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=csi_override action\=activate profile_id\=4 scell\=8	
# switch to good cqi
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=csi_override action\=activate profile_id\=3 scell\=8
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=csi_override action\=activate profile_id\=4 scell\=8	
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	Add GNB swconfig    0x5901E6:0x14 
# 	#crash when open    not crash when rdMinSrsUePeriodicity=80,srsUePeriodicity=160
# 	#pdcch use best beam
# 	#Add GNB swconfig    0x580434:0
# 	#Add GNB swconfig    0x580556:0x834        #rdStartPatternId
# 	Add GNB swconfig    0x5901EB:0     #rdForceEnablingWidebandTasSrs use -A
#   Add GNB swconfig    0x5805AE:1       #-B
#   Add GNB swconfig     0x5805b0:80                                                                     
#   Add GNB swconfig     0x5805b1:80                                                                     
#   Add GNB swconfig     0x5805b2:50    
#   Add GNB swconfig    0x580763:2 
#   Add GNB swconfig    0x58076c:10
#   Add GNB swconfig    0x58076d:10  
#   #Add GNB swconfig    0x580762:0x46  #rdWbSrsSeTresh 0x5b
#   Add GNB swconfig    0x5805ba:0     #small prb
#   Add GNB swconfig    0x5805bb:273   #small prb distance
#   Add GNB swconfig    0x5805b5:2   #rdnumsrscheck 
# #==========SA=======================
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '3s' for stabible	
# 
# SA Register UE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#      
# DL and UL data to '${UE_ID}' for dl_trf ${num}
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
#     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
# check throughput
#     Log To Console		=====nsa_tp=====
#     ${ue11}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_11}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue12}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_12}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue13}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_13}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue14}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_14}    scell_id=8    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${ue11}+${ue12}+${ue13}+${ue14}>=115000
# check throughputlow
#     Log To Console		=====lowcqi_tp=====
#     ${ue11}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_11}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue12}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_12}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue13}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_13}    scell_id=8    type=pdsch    tput_type=ave
# 	${ue14}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_14}    scell_id=8    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${ue11}+${ue12}+${ue13}+${ue14}<80000	
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# #===========NSA======================
# NSA Attach UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	\    airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '3s' for stabible
# 	\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#     \  ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}/egate_console.log.001   newUE-Identity (\\d+)
#   run keyword if    ${ue}==14   Set test Variable    ${ue4_rnti}    ${rnti_list[0]} 	 
# check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
#     ${cell_tp_dl}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	${pcell_tp}	Get cell dl throught	${num}    8
# 	\	${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
# 	\	Log To Console    UE${num}_dl_tp ${dl_tput_Mb}M--
# 	\   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
# 	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
# 	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}
# 
# Dettach UE from '${low}' to '${hi}'
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\	Airphone NSA Detach    ue_id= ${num}
# 	\   Wait '3s' for stabible
# 
# 
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
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
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
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}     DL    ${dl_data}    duration=6000s    trf_id=${num}    protocol=tcp
#     #Wait Throughput Timer    5s
