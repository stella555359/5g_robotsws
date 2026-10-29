# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# # Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_sasun    AP    SBTS00    RAN_5G_TDD    RAN_5G    
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_B_case13.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE2}    ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE11}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3
# ${PROFILE11_bad}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-500,-500,-500,-500
# ${SET_PROFILE11_bad}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4
# ${PROFILE1_bad}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-500,-500,-500,-500
# ${SET_PROFILE1_bad}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=5
# 
# ${deactive_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=2
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# 
# ${BLER1}        bler_testmode_nr profile_id\=1 dl_bler\=120,120,120,120,120   #add bler
# ${SET_BLER1}      ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# ${BLER2}        bler_testmode_nr profile_id\=2 dl_bler\=120,120,120,120,120   
# ${SET_BLER2}      ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
# ${BLER11}        bler_testmode_nr profile_id\=3 dl_bler\=120,120,120,120,120   
# ${SET_BLER11}      ue_testmode_set_nr id\=11 scell\=0 testmode\=bler profile_id\=3 action\=activate
# ${rank}    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
# ${set_rank}    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=2
# ${rank1}    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
# ${set_rank1}    ue_testmode_set_nr id=2 testmode=csi_override action=activate profile_id=3
# &{GNBMIRRORINGCONFIGS}    NUMBER_OF_FILES=30
# ${EGATE_TAG}       egate
# 
# *** Test Cases ***
# CB008322_B2_case013_3UEs_maxNumUeSrs_2_NSA_bad_SRS_power_fallback
#     Step1:Commission configuration and wait gNB onair
#     Step2:Attach 1 NSA UE and 2 SA UEs
#     Step3:Send DL data and check all UEs are RT beam
#     Step4:Change 1ue power from good to bad and check UE use DFT beam
#     Step5:Change 1ue power from bad to good and check UE use RT beam
#     Step6:Detach UEs
# 
# *** Keywords ***
# Step1:Commission configuration and wait gNB onair
#     Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Active GNB L2 feature debug traces
# 	Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# Step2:Attach 1 NSA UE and 2 SA UEs
#     NSA Attach UE from '11' to '11'
#     ${ue1_rnti}    Get NSA '11' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#     SA Register UE '1'
#     ${ue2_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue2_rnti}
#     SA Register UE '2'
#     ${ue3_rnti}    Get SA '2' crnti in RRC log
#     set suite variable     ${ue3_rnti}
#     Set UE1 position
#     Set UE2 position
#     Set UE11 position
# 
# Step3:Send DL data and check all UEs are RT beam
#     NSA send ue '11' mutiple trf '1' for each '175M' DL data
#     SA send dl and ul data    1    number=1    dl_data=175M    ul_data=10M
#     SA send dl and ul data    2    number=1    dl_data=175M    ul_data=10M    pdu_id=2
#     #Start collect bip log
#     Start collect ttitrace
#     Wait '4s' for stabible
#     ${pcap}=    Stop GNB Ttitrace With Streaming Mode    ${TEST_LOG_DIRECTORY()}/All
#     #Wait for '0s' to stop bip log with name'3ue'
#     Decoder Tttirace From Pcap To Csv    ${pcap}    ${TEST_LOG_DIRECTORY()}/All/tti_1
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_1_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_case13_1.ini'
# 
# 
# Step4:Change 1ue power from good to bad and check UE use DFT beam
#     Airphone Execute Egate Command    ${PROFILE1_bad}
#     Airphone Execute Egate Command    ${SET_PROFILE1_bad}
#     Wait '3s' for stabible
#     #Start collect bip log
#     Start collect ttitrace
#     Wait '4s' for stabible
#     ${pcap}=    Stop GNB Ttitrace With Streaming Mode    ${TEST_LOG_DIRECTORY()}/All
#     #Wait for '0s' to stop bip log with name'modify_power_good_to_bad'
#     Decoder Tttirace From Pcap To Csv    ${pcap}    ${TEST_LOG_DIRECTORY()}/All/tti_2
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_2_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_case13_2.ini'
# Step5:Change 1ue power from bad to good and check UE use RT beam
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '3s' for stabible
#     #Start collect bip log
#     Start collect ttitrace
#     Wait '4s' for stabible
#     ${pcap}=    Stop GNB Ttitrace With Streaming Mode    ${TEST_LOG_DIRECTORY()}/All
#     #Wait for '0s' to stop bip log with name'modify_power_bad_to_good'
#     Decoder Tttirace From Pcap To Csv    ${pcap}    ${TEST_LOG_DIRECTORY()}/All/tti_3
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/tti_3_dl.csv
#     run keyword and continue on failure	   Check ttitrace'tti_case13_3.ini'
# 
# Step6:Detach UEs
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_1   unzip=TRUE
# 
# 
# 
# SA send dl and ul data
#     [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1    ${protocol}=udp
#     SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}    ${protocol}
#     # SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}    ${protocol}
# 
# 
# NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}     UL    ${ul_data}    duration=6000s    trf_id=${num}    protocol=tcp
# 
# 
# SOS report LOAPLO start test
#     Log To Console    Run SOS start test...
#     ${output}=    Run    /opt/wts/latest/startTest.sh >/tmp/startSOS.log
#     File Should Exist    /tmp/startSOS.log
#     Log To Console    End Run SOS report start test...
# 
# SOS report LOAPLO Stop test
#     Log To Console    Run SOS Stop test...
#     ${output}=    Run    /opt/wts/latest/stopTest.sh >/tmp/stopSOS.log
#     File Should Exist    /tmp/stopSOS.log
#     Log To Console    End Run SOS report Stop test.....
# 
# Change rank4 to rank2
#     Airphone Execute Egate Command    ${rank}
#     Airphone Execute Egate Command    ${set_rank}
#     Airphone Execute Egate Command    ${rank1}
#     Airphone Execute Egate Command    ${set_rank1}
# 
# Set UE${id} position
#     Airphone Execute Egate Command    ${PROFILE${id}}
#     Airphone Execute Egate Command    ${SET_PROFILE${id}}
#     Wait '2s' for stabible
# Send bler to UE${id}
#     Airphone Execute Egate Command    ${BLER${id}} 
#     Airphone Execute Egate Command    ${SET_BLER${id}}
# 
# Change ues power
#     Airphone Execute Egate Command    ${PROFILE1_bad}
#     Airphone Execute Egate Command    ${SET_PROFILE1_bad}
#     Airphone Execute Egate Command    ${PROFILE11_bad}
#     Airphone Execute Egate Command    ${SET_PROFILE11_bad}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ${SET_PROFILE11}
#     Wait '2s' for stabible
# 
# Check ttitrace'${ini_file}'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all NSA ue crnti
# #    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_${ue_id}_egate   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}_attach/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# delete profile_1
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)	
# 	Add GNB swconfig    0x580434:0		#pdcch use best beam
# 	Add GNB swconfig    0x5901EB:0        #1:rdForceEnablingWidebandTasSrs
# 	# Add GNB swconfig    0x580556:0x834    #rdStartPatternId 0x834=2100	
#     Add GNB swconfig    0x5805ae:1    #rdEnableSrsSwitchScheduler -B enable
#     Add GNB swconfig    0x5805b0:70                                                                     
#     Add GNB swconfig    0x5805b1:70                                                                     
#     Add GNB swconfig    0x5805b2:50   
#     Add GNB swconfig    0x580763:1      #rdWbSrsRankTresh,3是rank>=3是RT ，<3切到dft
#     Add GNB swconfig    0x580434:0      #0:use DFT beam; 1:use SSB beam
#     Add GNB swconfig    0x580707:1   #rdRankForRtBeam
#     Add GNB swconfig    0x58076C:0x1   #rdWbSrsPrbTresh  buffer good thresh
#     Add GNB swconfig    0x58076d:0x1   #rdWbSrsPrbProh
#     Add GNB swconfig    0x800070:1    #rdRtBwvDowngradeMethod
#     Add GNB swconfig    0x580762:0xF
#     Add GNB swconfig    0x580766:0x8
# 
# get_egate_log_UE'${ue_id}'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
# get_bip_UE'${ue_id}'
# 	Start collect bip log
# 	Wait for '1s' to stop bip log with name'BIP_${ue_id}'
# 	
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/BIP_${ue_id}/bip_8322.csv    ${filter_csv}    ${title_all}
#     
# get_tti_UE'${ue_id}'
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti_${ue_id}'
# 	reorder_csv_CB008322  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
# #==========SA=======================
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register SA UE ${UE_ID} ------
#     airphone_cleanup_egate_console_log
#     Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE	
# 
# SA Register UE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	#\	airphone_cleanup_egate_console_log
#     \	Log To Console   ${\n}-----register UE ${ue} ------
#     \	SA Register UE ${ue}
#     \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   5M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
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
# #===========NSA======================
# NSA Attach UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\   Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	\   airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '2s' for stabible
# 	\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_attach   unzip=TRUE
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
# 
# switch to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
# ...    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1
# 
#     test_SA_UE1
# 	Start capture gnb and ap syslog in 'UE1' file
# 	airphone_cleanup_egate_console_log
# 	SA Register UE '1'
# 	#Set UE1 position
# 	DL and UL data to '1' for dl_trf '10'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s   check throughput from SA UE '1' to '1' with tp '1280'
# 	get_bip_UE'1'
# 	get_tti_UE'1'
# 	DeRegister UE from '1' to '1'
# 	delete profile_1
# 	get_egate_log_UE'1'
# 	Stop capture gnb and ap syslog in 'UE1' file
# 	
# test_NSA_UE11
# 	Start capture gnb and ap syslog in 'UE11' file
# 	airphone_cleanup_egate_console_log
# 	NSA Attach UE from '11' to '11'
# 	Set UE11 position
# 	NSA send ue '11' mutiple trf '10' for each '160M' DL data
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s   check throughput from NSA UE '11' to '11' with tp '1280'
# 	get_bip_UE'11'
# 	get_tti_UE'11'
# 	# Dettach UE from '11' to '11'
# 	delete profile_11
# 	get_egate_log_UE'11'
# 	Stop capture gnb and ap syslog in 'UE11' file
# 
# 
