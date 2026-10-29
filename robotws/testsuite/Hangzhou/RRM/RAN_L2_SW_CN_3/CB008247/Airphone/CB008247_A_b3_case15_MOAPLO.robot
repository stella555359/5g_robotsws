# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CIT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case15_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_APLO_case15.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_A_b3_case15_APLO.cfg
# ${UE_ID}          1
# ${UE_ID2}         2
# ${BIP_TAG}    srs
# ${FILTER}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER1}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# @{titles}    DlData_DciInfo.patternId_item
# @{titles1}    DlData_PdschGrant.patternId_item
# ${patter_id1}    1400		#1373
# ${patter_id2}    1373
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# #...   srs_transmit_power_per_port\=-350,-350,-350,-350
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# #...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${delete_PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 delete\=true
# ${delete_PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 delete\=true
# *** Test Cases ***
# CB008247_A_b3_case15_CL_4x4_90M_Codebook_SRS_best_beam_determination_twoUE_SA
# 	Add GNB swconfig    0x580434:0	#rdDisableBestSrsBeamForPdcch
# 	#Add GNB swconfig    0x580264:7		#rdDlSrsLogControl,3:productH
# 	Get and Update BSR File		par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001 
# 	Prepare gnb onair
# 	#Set ue srs sinr
# 	airphone_cleanup_egate_console_log
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	#Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource2    ${UE_ID}
# 	#Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource4    ${UE_ID2}    PDU_ID=2    GW_ID=2
# 	SA Register UE '${UE_ID}'
# 	SA Register UE '${UE_ID2}'
# 	Set UE1 position
# 	Set UE2 position
# 	SA send dl and ul data    ${UE_ID}    number=3    dl_data=175M    ul_data=20M	    pdu_id=${UE_ID}
# 	SA send dl and ul data    ${UE_ID2}    number=3    dl_data=175M    ul_data=20M    pdu_id=${UE_ID2}
# 	Start collect bip log
# 	Start collect ttitrace
# 	Wait '2s' for stabible
# 	${pcap_path}    Stop GNB Ttitrace With Streaming Mode
# 	Wait for '0s' to stop bip log with name'bip'
# 	Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/switch
# 	run keyword and continue on failure    Check ue tput is correct
# 	DeRegister UE from '${UE_ID}' to '${UE_ID2}'
# 	Delete profile
# 	Stop egate log and unzip with name'egate'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# 	run keyword and continue on failure    Check srs usage is codebook in rrc
# 	run keyword and continue on failure    Check patter id is correct in ttitrace
# 	run keyword and continue on failure    Check patter id is correct in bip
# 
# *** Keywords ***
# SA Register UE '${UE_ID}'
# 	Log To Console   ${\n}-----register UE ${UE_ID} ------
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
# 	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
# 	Wait '2s' for stabible
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 	
# Delete profile
# 	Airphone Execute Egate Command    ${delete_PROFILE1}
# 	Airphone Execute Egate Command    ${delete_PROFILE2}70698
# 	
# Set UE${ueid} position
#     Airphone Execute Egate Command    ${PROFILE${ueid}}
#     Airphone Execute Egate Command    ${SET_PROFILE${ueid}}
#     Wait '2s' for stabible
# 	
# Set ue srs sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=1
# 
# Modify 8247 Swconfig
#     #Add GNB swconfig    0x580264:0x1F
#     #Add GNB swconfig    0x580477:1	#rdUlSrsLogMask
#     #Add GNB swconfig    0x590105:1	#rdSelectedBeamset
#     #Add GNB swconfig    0x590104:0
#     Add GNB swconfig    0x580434:0	#rdDisableBestSrsBeamForPdcch
#     Add GNB swconfig    0x580264:7		#rdDlSrsLogControl,3:productH
#     #Add AP swconfig    0x70698:-200
# 
# Check srs usage is codebook in rrc
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_srs_usage_codebook.ini    p    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_egate
# 
# Check patter id is correct in ttitrace
#     ${path}    List Files In Directory    ${TEST_LOG_DIRECTORY()}/All    switch_dl.*csv
#     ${path_tti}    set variable    ${path}[0]
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_dl_case15.ini    i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_ul_case15_LOAPLO.ini    i   
#    ...     save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdcch.csv    ${FILTER}    ${titles}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdsch.csv    ${FILTER1}    ${titles1}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdcch.ini     i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
#     #Check Log With Au2anlysis    ${CURDIR}/ini/bip_case15_pdsch_APLO.ini     i    
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     should be true    ${dl_tput1}>340000
#     should be true    ${dl_tput2}>340000
#     should be true    ${ul_tput1}+${ul_tput2}>10000
