# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS00
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CB008322_8D4U_1070_80M_SBsize128_case20.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_1RF_9496.xml
# ${WTS_NAME}    wts_8322_B2_SA_NSA_case20.cfg
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
# ${BIP_temp}    8322_biptemp
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    BB_SLOT_6='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   
# ...    L2RT_MIRRORING='true'   CPRT_MIRRORING='false'    NUMBER_OF_FILES=10
# ${UE_ID}          1
# ${UE_ID_11}       11
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5
#    ...     trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3	
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# ${SET_PROFILE11}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4	
# *** Test Cases ***
# CB008322_B32_case020_2UE_T2R4_T1R4_80Mhz_SubBandSize128_RANK2_SRSperiod320_CLoseLoopMimo_frame1070
#  	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Active GNB L2 feature debug traces
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'syslog' file
#     Register_UE
# 	Log To Console		=====step1=====
#     Step1_UE1_small_UE11_big
# 	Log To Console		=====step2=====
# 	Step2_UE1_big_UE11_big
# 	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
# 	Log To Console		=====step3=====
#     Step3_UE1_big_UE11_small
# 	Log To Console		=====step4=====
# 	Step4_Low cqi check beam
#     Airphone NSA Detach    ${UE_ID_11}
# 	DeRegister UE1
#     Stop capture gnb and ap syslog in 'syslog' file
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_2UE   unzip=TRUE
# *** Keywords ***
# check bler and beamtype is correct in ttitrace attach                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c20.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step1                   
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c20_s1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step2                  
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c20_s2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check bler and beamtype is correct in ttitrace step3                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c20_s3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All   
# check bler and beamtype is correct in ttitrace step4                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_c20_s4.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All 
# Register_UE
#     airphone_cleanup_egate_console_log
# 	Start collect ttitrace
# 	#Start collect bip log
# 	NSA Attach UE11
# 	${ue1_rnti}    Get NSA '11' crnti in RRC log
#     set suite variable     ${ue1_rnti}
#      Set UE11 position1
# 	SA Register UE ${UE_ID}
# 	${ue2_rnti}    Get SA '1' crnti in RRC log
#     set suite variable     ${ue2_rnti}
#     Set UE1 position1
#     switch to rank2
#     Wait for '2s' to stop ttitrace with name'ttiattach'
# 	#Wait for '0s' to stop bip log with name'ue_register'
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace attach 
# 	get_egate_log'0'
# 	
# Step1_UE1_small_UE11_big
#     airphone_cleanup_egate_console_log
#    	#Start collect bip log
#   	Start collect ttitrace
#     NSA send ue '11' mutiple trf '3' for each '160M' DL data
#     Internal small DL data
#    	Wait for '2s' to stop ttitrace with name'ttitemp'
#     #Wait for '0s' to stop bip log with name'${BIP_temp}'
# 	Wait '2s' for stabible
#   	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1 
#     get_egate_log'1'
# Step2_UE1_big_UE11_big
#     airphone_cleanup_egate_console_log
# 	#Start collect bip log 
# 	Start collect ttitrace
#     Internal DL data
# 	Wait for '2s' to stop ttitrace with name'ttitempstep2'
#     #Wait for '0s' to stop bip log with name'biptempstep2'
# 	Start collect ttitrace
#  	Wait for '2s' to stop ttitrace with name'ttiagain'
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace step2
#     get_egate_log'2'
# Step3_UE1_big_UE11_small
#      airphone_cleanup_egate_console_log
# 	 #Start collect bip log 
#    	 Start collect ttitrace
#      NSA send ue11 10M
# 	 Wait for '2s' to stop ttitrace with name'ttitempstep3'
#      #Wait for '0s' to stop bip log with name'biptempstep3'
#    	 Start collect ttitrace
#  	 Wait for '2s' to stop ttitrace with name'ttiagain2'
# 	 run keyword and continue on failure    check bler and beamtype is correct in ttitrace step3 
#      get_egate_log'3'
# Step4_Low cqi check beam
# 	airphone_cleanup_egate_console_log
# 	Start collect ttitrace	
# 	switch to low cqi
# 	#Start collect bip log 
# 	Wait for '2s' to stop ttitrace with name'ttitempstep4'
#     #Wait for '0s' to stop bip log with name'biptempstep4'
#    	Start collect ttitrace
#  	Wait for '2s' to stop ttitrace with name'lowcqi'
# 	run keyword and continue on failure    check bler and beamtype is correct in ttitrace step4
#     get_egate_log'4'
# NSA send ue11 10M
#     airphone_execute_egate_command    trf_data_stop ue\=11 id\=2 dir\=dl trf_id\=2
#     airphone_execute_egate_command    trf_data_stop ue\=11 id\=2 dir\=dl trf_id\=3
#     NSA send ue '11' mutiple trf '1' for each '10M' DL data
# get_egate_log'${time}'
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${time}   unzip=TRUE
# 
# switch to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     Wait '1s' for stabible
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     Wait '1s' for stabible
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#  
# switch to low cqi 
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=10 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     Wait '1s' for stabible
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=2 scell\=8
#     Wait '1s' for stabible
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     Wait '1s' for stabible	
# Add RD
# 	#rdMinSrsUePeriodicity,default=80 slot(0x50)
# 	#rdMinSrsUePeriodicity=320ms
# 	Add GNB swconfig    0x5901E6:0x140
# 	#pdcch use best beam
# 	#Add GNB swconfig    0x580434:0
# 	#Add GNB swconfig    0x580556:0x834        #rdStartPatternId
# 	#Add GNB swconfig    0x5901EB:1      #rdForceEnablingWidebandTasSrs use -A
# 	#Add GNB swconfig     0x5805b0:80                                                                     
#     #Add GNB swconfig     0x5805b1:80                                                                     
#     #Add GNB swconfig     0x5805b2:50  
#     #Add GNB swconfig    0x5805ae:1
#     #Add GNB swconfig    0x580763:2
#     #Modify GNB swconfig     0x580763:3
# 	#Add GNB swconfig    0x58076c:10
#     #Add GNB swconfig    0x58076d:10
# Star ttitrace again
# 	Start collect bip log 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti2'
#     Wait for '1s' to stop bip log with name'${BIP_TAG_2}'
# #==========SA=======================
# SA Register UE ${UE_ID}
#     Log To Console   ${\n}--Attach SA UE--
# 	Airphone_cleanup_egate_console_log
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
# DeRegister UE1
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=5
# Internal small DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=50 seconds\=3000 trf_id\=1
#     #airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=2
#     #airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=3
# Internal DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=1
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=3    
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=4  
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=5
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=160 seconds\=3000 trf_id\=6
# #===========NSA======================
# NSA Attach UE11
# 	Log To Console   ${\n}--Attach NSA UE ${UE_ID_11} --
# 	Airphone_cleanup_egate_console_log
# 	Airphone Nsa Attach     ${UE_ID_11}    profile_id=None
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID_11}   unzip=TRUE
# check throughput
#     Log To Console		=====nsa_tp ${UE_ID_11}=====
#     ${dl_throughput_pcell_nsa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_11}    scell_id=8    type=pdsch    tput_type=ave
# 	Log To Console		=====sa_tp ${UE_ID}=====
# 	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# 	Log To Console		=====cell_tp_dl=====
# 	run keyword and continue on failure    should be true    ${dl_throughput_pcell_nsa}+${dl_throughput_pcell_sa}>=450
# #check tti
# Get SA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001    crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA '${ue_id}' crnti in RRC log
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Set UE1 position1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# Set UE11 position1
#     Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ${SET_PROFILE11}    
