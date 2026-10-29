# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown   # Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_G7_8D4U_AQQL_1208_100M_SBsize64_case3.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_1RF_8D4U_8192.xml
# ${WTS_NAME}    wts_8322_G7_SA_NSA.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
# ...   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'    NUMBER_OF_FILES=10
# ${UE_NUM}    4
# ${UE_ID}    1
# ${UE_ID2}    2
# ${UE_ID_11}       11
# ${UE_ID_12}       12
# ${RRC_Attach}    rrc_attach
# ${RRC_data_low}    lowchnl
# ${BIP_TAG}      databip
# ${RRC_data_high}    highchnl
# ${RRC_more_data}    moredata
# ${RRC_muchmore_data}    muchmoredata
# ${RRC_decrease_data}    decreasedata	
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1	
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE3}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1	
# ${SET_PROFILE4}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3	
# ${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbwvps) && !(3gpp.rnti == 65535)
# @{title_srsreceivereq}   3gpp.sfn   3gpp.slot   3gpp.rnti   
# ...   UlData_srsBwvReportRequest_t.rho 
# @{title_srsreceiverespbwvps}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item
# @{title_all}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item    UlData_srsBwvReportRequest_t.rho
# ...   UlData_srsBwvReport_t.correlation_item 
# *** Test Cases ***
# # from G14_Case1
# CB008322_G7_case03_multiple_ue_low_high_or_early_wb_srs_corr chnl_volatilen
# 	RD_G7
# 	Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
# 	#online act CB08322 debug flag
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 	SA Register UE 1
# 	SA Register UE 2
#     NSA Attach UE from '11' to '12'
#     Set UE1 position1
#    Set UE2 position1
#     Set UE11 position1
#     Set UE12 position1		
#    run keyword and continue on failure    Step10 high_chnl_volatilen high T1 0dot01 mode0
#   run keyword and continue on failure    Step9 send data to wb low chal low T1 0dot01 mode0
# 	Start sadl data
# 	Start nsadl data
# 	Start collect ttitrace
#   	Wait for '2s' to stop ttitrace with name'tti'
# 	check throughput
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace
# 	Stop capture gnb and ap syslog in 'after_onair' file
# *** Keywords ***
# RD_G7
# 	Add GNB swconfig   	0x58053e:1		# rdIncludeHighVolatileUe, default=false
# 	#Add GNB swconfig	0x58077a:1		# rdIncludeSrsVolatilityStatusMetric	# NIDD:enableSbSrsVolatilityCheck
# 	Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true,attach issue WA
# 	#Add GNB swconfig    0x58076a:1		# rdNumWbSrsMeas, default=5;
# 	#The minimum number of correlation metric before correlation is used for measure radio link variety,set to 1 ,corrAvg=current average.
# 	#Add GNB swconfig 	0x58077b:1		# rdNumSbSrsCorrCal, default=5
# 	#rdMmsePowerFactor  0x58026e  #default=0x64=100 #rdMmsePowerFactor=0.01
# 	#Add GNB swconfig    0x58026a:20     #rdMmseFactorHighVolatileStep1,default=0x14=20 
# 	#Add GNB swconfig    0x58026b:300     #rdMmseFactorHighVolatileStep2,default=0x12c=300 
#     #Add GNB swconfig    0x58026c:20     #rdMmseFactorLowVolatileStep1,default=0x14=20,2dB 
# 	#Add GNB swconfig    0x58026d:300     #rdMmseFactorLowVolatileStep2,default=0x12c=300 
#     Add GNB swconfig    0x580269:0     #rdMmseRegularizationMode,default=0# step1-6 use2; step7,8 use1; step9,10, use0 
# 	Add GNB swconfig    0x58077a:1#rdIncludeSrsVolatilityStatusMetric 0x58077a
#     Add GNB swconfig    0x80006A:2     #rdThermNoisFlag  
# 	Add GNB swconfig    0x800038:1    #enableNdmSrsBwvTrace
# 	#Add GNB swconfig    0x800043:1    #enableNdmSrsBfTrace
# 
# online_change_CorrThd
# 	Execute Aashell Command    rad -mw 0x58077c 80		#rdSbSrsVolatCorrThreshold,default=0.8
# 	Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
# 
# #==========SA=======================
# SA Register UE ${UE_ID}
# 	Airphone_cleanup_egate_console_log
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
# 
# Start dl data small
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   80M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID2}   DL   80M   pdu_id=${UE_ID2}   duration=3600   trf_id=1	
# 	NSA send ue '11' mutiple trf '1' for each '10M' DL data
# 	NSA send ue '12' mutiple trf '1' for each '10M' DL data
# Start sadl data
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     #Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3	
#     Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=2		
#     #Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=3	
# Start nsadl data	
# 	NSA send ue '11' mutiple trf '2' for each '160M' DL data
# 	NSA send ue '12' mutiple trf '2' for each '160M' DL data
# Step1 send data to wb low chal low T1 0dot01 
#     Airphone Cleanup Egate Console Log
#     Start collect bip log 
#     Start collect ttitrace
#     Start dl data sasmall nsa large
# 	Execute Aashell Command    rad -mw 0x58026c 400	
#   	Wait for '1s' to stop ttitrace with name'ttilowT1'
# 	Wait for '0s' to stop bip log with name'biplowT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplowT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biplowT1/biplowT1.csv    ${filter_csv}    ${title_all}
# 	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilowT1_dl.csv
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot01.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplowT1	
# Step2 low_chnl_volatilen low T2 0dot001
#     Execute Aashell Command    rad -mw 0x58026c 20
# 	Execute Aashell Command    rad -mw 0x58026d 400	
# 	Start collect bip log 
#     #Start collect ttitrace
#   	#Wait for '1s' to stop ttitrace with name'ttilowT2'
# 	Wait for '1s' to stop bip log with name'biplowT2'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplowT2/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biplowT2/biplowT2.csv    ${filter_csv}    ${title_all}
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilowT2_dl.csv
#     #run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot001.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplowT2	
# Step3 low_chnl_volatilen other 0dot0001	
# 	Execute Aashell Command    rad -mw 0x58026d 300	
# 	Start collect bip log 
#     #Start collect ttitrace
#   	#Wait for '1s' to stop ttitrace with name'ttilow'
# 	Wait for '1s' to stop bip log with name'biplow'
# 	Collect AP egate log    ${RRC_data_low}
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplow/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biplow/biplow.csv    ${filter_csv}    ${title_all}
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilow_dl.csv
#     #run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot0001.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplow	
# check throughput
#     Wait '10s' for stabible
#     Log To Console		=====tp=====
# 	${dl_throughput_pcell_sa1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# 	${dl_throughput_pcell_sa2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
# 	${dl_throughput_pcell_nsa1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_11}    scell_id=8    type=pdsch    tput_type=ave
# 	${dl_throughput_pcell_nsa2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_12}    scell_id=8    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa1}+${dl_throughput_pcell_sa2}+
# 	...    ${dl_throughput_pcell_nsa1}+${dl_throughput_pcell_nsa2}>=900000 	
# Step4 high_chnl_volatilen high T1 0dot01	
#     Airphone Cleanup Egate Console Log
#     Execute Aashell Command    rad -mw 0x58077d 100		#rdWbSrsVolatCorrThreshold,default=0.9
# 	Execute Aashell Command    rad -mw 0x58026a 400	
# 	Start collect bip log 
#     Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'ttihighT1'
# 	Wait for '0s' to stop bip log with name'biphighT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphighT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biphighT1/biphighT1.csv    ${filter_csv}    ${title_all}	
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttihighT1_dl.csv
# 	#check bler and beamtype is correct in ttitrace step2 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot01.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphighT1	
# Step5 high_chnl_volatilen high T2 0dot001	
# 	Execute Aashell Command    rad -mw 0x58026a 20	
# 	Execute Aashell Command    rad -mw 0x58026b 400	
# 	Start collect bip log 
#     #Start collect ttitrace
# 	#Wait for '1s' to stop ttitrace with name'ttihighT2'
# 	Wait for '1s' to stop bip log with name'biphighT2'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphighT2/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biphighT2/biphighT2.csv    ${filter_csv}    ${title_all}	
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttihighT2_dl.csv
# 	#check bler and beamtype is correct in ttitrace step2 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot001.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphighT2	
# Step6 high_chnl_volatilen other 0dot0001
# 	Execute Aashell Command    rad -mw 0x58026b 300	
# 	Start collect bip log 
#     #Start collect ttitrace	
# 	#Wait for '1s' to stop ttitrace with name'ttihigh'
# 	Wait for '1s' to stop bip log with name'biphigh'
# 	Collect AP egate log    ${RRC_data_high}
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphigh/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biphigh/biphigh.csv    ${filter_csv}    ${title_all}	
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/biphigh_dl.csv
# 	#check bler and beamtype is correct in ttitrace step2 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot0001.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphigh 	
# Step7 send data to wb low chal low T1 0dot01 mode1 
#     Airphone Cleanup Egate Console Log
#     Start collect bip log 
#     Start collect ttitrace
#     Start dl data 200M
#   	Wait for '1s' to stop ttitrace with name'ttilowT1'
# 	Wait for '0s' to stop bip log with name'biplowT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplowT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biplowT1/biplowT1.csv    ${filter_csv}    ${title_all}
# 	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilowT1_dl.csv
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot01.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplowT1	
# Step8 high_chnl_volatilen high T1 0dot1 mode1	
#     Airphone Cleanup Egate Console Log
#     Execute Aashell Command    rad -mw 0x58077d 100		#rdWbSrsVolatCorrThreshold,default=0.9
# 	Start collect bip log 
#     Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'ttihighT1'
# 	Wait for '0s' to stop bip log with name'biphighT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphighT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biphighT1/biphighT1.csv    ${filter_csv}    ${title_all}	
# 	#run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttihighT1_dl.csv
# 	#check bler and beamtype is correct in ttitrace step2 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot1.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphighT1	 
# Step9 send data to wb low chal low T1 0dot01 mode0 
#     Airphone Cleanup Egate Console Log
#     Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
#     Start collect bip log 
#     Start collect ttitrace
#   	Wait for '1s' to stop ttitrace with name'ttilowT1'
# 	Wait for '0s' to stop bip log with name'biplowT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplowT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biplowT1/biplowT1.csv    ${filter_csv}    ${title_all}
# 	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilowT1_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot01.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplowT1	
# Step10 high_chnl_volatilen high T1 0dot01 mode0	
#     Airphone Cleanup Egate Console Log
#     Execute Aashell Command    rad -mw 0x58077d 100		#rdWbSrsVolatCorrThreshold,default=0.9
# 	Start collect bip log 
#     Start collect ttitrace
#     	Start dl data small
# 	Wait for '1s' to stop ttitrace with name'ttihighT1'
# 	Wait for '0s' to stop bip log with name'biphighT1'
# 	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphighT1/tcpdump_L2L1_bip_filtering_off.pcap0
# 	...    ${TEST_LOG_DIRECTORY()}/All/biphighT1/biphighT1.csv    ${filter_csv}    ${title_all}	
# 	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttihighT1_dl.csv
#     run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot01_mod0.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphighT1		
# Set UE1 position1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# Set UE2 position1
#     #Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE2}	
# Set UE11 position1
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
# Set UE12 position1
#     #Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE4}		
# check bler and beamtype is correct in ttitrace step1                  
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/G7_step1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# check bler and beamtype is correct in ttitrace                
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/G7.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# #==========SA=======================
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register UE ${UE_ID} ------
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 
# SA Register UE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	#\	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      #\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
#      
# DL and UL data to '${UE_ID}' for dl_trf '${num}'
#     : FOR    ${i}    IN RANGE    1    ${num}+1
#     \	Airphone SA Start Data Traffic    ${UE_ID}   DL   60M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}     
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   1M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     #Wait '2s' for stabible
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
# 	\    Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	#\    airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '2s' for stabible
# 	#\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_attach   unzip=TRUE
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
