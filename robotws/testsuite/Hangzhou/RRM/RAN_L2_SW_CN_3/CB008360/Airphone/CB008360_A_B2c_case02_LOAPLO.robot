# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang 
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_case02_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D4U_LOAPLO.xml
# ${WTS_NAME}    case02_LOAPLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          1
# ${UE_ID2}          2
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${BIP_TAG}    srs
# ${FILTER}           uldata_puschreceivereq&&!(3gpp.rnti==65535)
# @{titles}   UlData.patternId_item
# @{Rdparameter}    0x58037C:1    0x58054D:1
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
# ${SET_SAPROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_SAPROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
# ${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
# ${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5	
# ${SINR_3}         ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5						  
# 					  
# *** Test Cases ***
# CB008360_A_B2c_case02_two_rank1_Ues_blindly_paired_and_MU_SINR_estimation
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     #Test NSA ue
# 	Test SA ue
# *** Keywords ***
# Ttitrace
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure    check SAthroughput
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace  
# Test NSA ue
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Execute AP Command before attach
# 	Start collect ttitrace
#     Attach LTE 2UE
# 	Set ue position
# 	NSA send ue 100M UL data 100M DL data
# 	Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    check throughput
#     Airphone NSA Detach    ${UE_ID}
#     Airphone NSA Detach    ${UE_ID_2}
# 	run keyword and continue on failure    airphone_cleanup_egate_console_log
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     check bler and pair is correct in ttitrace   
# Test SA ue
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file		
#     Regist SA 2ue	
#   	Set SAue position
# 	  SA send ue 100M UL data 100M DL data
#     Start collect ttitrace
#   	Wait for '2s' to stop ttitrace with name'tti'
# 	  run keyword and continue on failure    check SAthroughput
# 	  run keyword and continue on failure    check bler and pair is correct in ttitrace  
#     Online change ulMuMimoSinrThd to 40
# 	  Start collect ttitrace
#   	Wait for '2s' to stop ttitrace with name'ttilowsinr'
#     Detach '2' UE
#     run keyword and continue on failure    airphone_cleanup_egate_console_log
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     check lowsinr in ttitrace   	
#     Online change ulMuMimoSinrThd to 10         		
# NSA send ue 100M UL data 100M DL data
#     airphone_execute_egate_command     trf_data_start ue\=11,12 id\=2 dir\=ul mbps\=100 trf_id\=1
# 	airphone_execute_egate_command     trf_data_start ue\=11,12 id\=2 dir\=dl mbps\=100 trf_id\=1
# #Prepare test
#     #Active GNB L2 feature debug traces
#     #Modify 8360 Swconfig
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000	
# Check SAthroughput
#     Wait until keyword succeeds    60s    5s    Verify SAthroughput
# Verify SAthroughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000		
# Wait '${time}' for stabible
#     sleep    ${time}
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# Attach LTE 2UE
#     Airphone Nsa Attach    ${UE_ID}	
# 	Airphone Nsa Attach    ${UE_ID2}	
# Regist SA 2ue	
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${UE_ID}
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${UE_ID2}    PDU_ID=2    GW_ID=2	
# SA send ue 100M UL data 100M DL data	
#     SA send dl and ul data    ${UE_ID}    number=1   ul_data=80M    dl_data=100M
#     SA send dl and ul data    ${UE_ID2}    number=1  ul_data=80M    dl_data=100M    pdu_id=2	
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check lowsinr in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02_lowsinr.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 		
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}		
# Set SAue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_SAPROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_SAPROFILE2}
# Modify 8360 Swconfig
#     #Add GNB swconfig    @{Rdparameter}
# Online change ulMuMimoSinrThd to ${value}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0   ulMuMimoSinrThd    ${value}    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '10s' for stabible
