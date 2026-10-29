# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang 
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_case02_MPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_b_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8360_case1_LOAPLO.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${BIP_TAG}    srs
# ${FILTER}           uldata_puschreceivereq&&!(3gpp.rnti==65535)
# @{titles}   UlData.patternId_item
# @{Rdparameter}    0x58037C:1    0x58054D:1    0x58054B:A
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=2 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
# ${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
# ${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5			
# ${SINR_3}         ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5			  
#   
# *** Test Cases ***
# CB008360_B_B1a_case02_two_rank2_Ues_8DL8UL_Max_4Layer_without_tapering
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2    ${UE_ID}
#     Attach SA ue to 5g cell    t2r4_n2   ${UE_ID2}    PDU_ID=2    GW_ID=2
# 	  Set ue position
#     SA send dl and ul data    ${UE_ID}    number=2    dl_data=10M    ul_data=120M
#     SA send dl and ul data    ${UE_ID2}    number=2    dl_data=10M    ul_data=120M    pdu_id=2
# 	Wait '3s' for stabible
# 	run keyword and continue on failure    Check throughput
#     #Start collect bip log
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     #Wait for '0s' to stop bip log with name'bip'
#     #Detach '2' UE
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    check bler and pair is correct in ttitrace 
# 
# *** Keywords ***
# Wait time to stable
#     sleep    2s
# Prepare test
#     #Active GNB L2 feature debug traces
#     Modify 8360 Swconfig
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_B_case02.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# 
# Modify 8360 Swconfig
#     Add AP swconfig    0x70690:1
# 	Add GNB swconfig    0x58037C:1    
#     #Add GNB swconfig    @{Rdparameter}
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     run keyword and continue on failure    Should be true    ${ul_tput1}+${ul_tput2}>250000
# Verify throughput
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}     scell_id=0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}     scell_id=0    type=pusch    tput_type=ave    
#      should be true    ${ue1_tp}>200000
#      should be true    ${ue2_tp}>200000  
# Online change ulMaxMuMimoLayer to 4
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2    ulMaxMuMimoLayer    4    online
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4PAIR_UE     cell_id=1
# 	${PM_counter_value_Pcell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=4LAYER      cell_id=1
# 	${PM_counter_value_Pcell2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=subset4LAYER    cell_id=1
#     should be true    ${PM_counter_value_Pcell}==2
# 	should be true    ${PM_counter_value_Pcell1}==2
# 	should be true    ${PM_counter_value_Pcell2}==2
# Check counter value
#     Wait until keyword succeeds    120s    30s    counter value		
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}	