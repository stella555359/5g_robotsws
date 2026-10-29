# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_ningyang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS00
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_AQQY_4D4U_ABIP.xml 
# ${AIRPHONE_NAME}    IPHY_AQQY_1CELL_APLO.xml
# ${WTS_NAME}    wts_8322_B1_SA_NSA.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    Tcpdump
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${BIP_TAG}    srs
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# ${FILTER0}    (itf_l2_ps_cell_cellsetupreq)||(itf_l2_ps_cell_cellsetupresp)||(itf_l2_ps_cell_dlsubbandbfconfig)||(ulcell_setupreq)
# @{title0}    itf_l2_ps_cell_BfSetup.actDlSrsBm    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs    itf_l2_ps_cell_DlSubbandBmConfig.srsQualityThreshold  
# 
# *** Test Cases ***
# CB008322_B1_case001_32TRX_testing_for_cell_setup
#  	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#   Step1 cell setup
# 	Start capture gnb and ap syslog in 'syslog' file	
#   Step2 register T2R4 ue
# 	Step3 Online change bfSubbandSize to 32
# 	#Step4 Check bip log again for cell setup
#   check bler and beamtype is correct in ttitrace step3
# 	DeRegister UE 1
#   Stop capture gnb and ap syslog in 'syslog' file
# 
# *** Keywords ***
# Step1 cell setup
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQY_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001 
# 	Prepare gnb onair
# Step2 register T2R4 ue	
# 	SA Register UE 1
# 	Internal DL data
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
# 	Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	Wait for '0s' to stop bip log with name'bip'
# 	split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/tti_dl.csv
# Step3 Online change bfSubbandSize to 32
#     Run Keyword And Ignore Error    Start collect 'cellSetup' tcpdump
#     Wait '10s' for stabible	
#     Online recommissioning with delta json file    ${CURDIR}/JSON/8322_change_bfsubbandsize.json
# 	 #Run Keyword And Ignore Error    Start collect 'cellSetup' tcpdump
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     Wait '15s' for stabible	
# 	Run Keyword And Ignore Error    Stop collect 'cellSetup' tcpdump 
# Step4 Check bip log again for cell setup
# 	  Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${cellSetup.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_B1_case1step4.csv    ${FILTER0}    ${title0}
# 	  run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/B1_bip_sbsize32.ini    log_need_to_check=i
# 	check bler and beamtype is correct in ttitrace step2  
# check bler and beamtype is correct in ttitrace step2                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/B1_case2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step3
# 	SA Register UE 1
# 	Internal DL data
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
# 	Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ttisize32'
# 	Wait for '0s' to stop bip log with name'bipsize32'
# 	split_8322_tti        ${TEST_LOG_DIRECTORY()}/All/ttisize32_dl.csv                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/B1_case1_size32.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Add RD
# 	#Add GNB swconfig    0x5901E6:80			#rdMinSrsUePeriodicity,default=80 slot(0x50)		
# 	#Add GNB swconfig    0x580434:0			#pdcch use best beam	
# 	#Add GNB swconfig    0x5805ae:1			#rdEnableSrsSwitchScheduler -B enable
# 	Add GNB swconfig    0x5805b0:60			#rdSrsBufPercent,60		default=70
# 	Add GNB swconfig    0x5805b1:60			#rdSrsRlqGoodPercent,60 	default=90
# 	#Add GNB swconfig    0x5805b2:50		#rdSrsRlqBadPercent,50	default=50=0x32
# 	#Add GNB swconfig    0x5805b5:10		#rdNumSrsCheck deafault=1
# 	Add GNB swconfig    0x58076c:10			#rdWbSrsPrbTresh default=45(0.45)
# 	#Add GNB swconfig    0x58076d:10		#rdWbSrsPrbProh deafault=20(0.2),bufferlo=0.2*45%=9%, buferlo=o.2*20%=4%
# 	#Add GNB swconfig    0x590072:1			#CPRT log
# 	#Add GNB swconfig    0x580264:0x03		#rdDlSrsLogControl,3:productH
# #==========SA=======================
# SA Register UE ${UE_ID}
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# Internal DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=3    
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=4  
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=5
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=6
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=7
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=8
# 	Wait '5s' for stabible	
# SA Register UE from ${lo} to ${hi}
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	#\	airphone_cleanup_egate_console_log
#      \	Log To Console   ${\n}-----register UE ${ue} ------
#      \	SA Register UE ${ue}
#      \	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
# check throughput
#     Log To Console		=====tp=====
# 	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=1100000     
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
# DeRegister UE ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=5
#     Wait '1s' for stabible	
# #===========NSA======================
# NSA Attach UE from '${lo}' to '${hi}'
# 	: FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
# 	\    Log To Console   ${\n}--Attach NSA UE ${ue} --
# 	#\    airphone_cleanup_egate_console_log
# 	\	Airphone Nsa Attach     ${ue}    profile_id=None
# 	\	Wait '2s' for stabible
# 	\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
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
