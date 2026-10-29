# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00        RAN_5G    owner_ningyang    
# ...   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_CB010659_A_case14.xml
# ${AIRPHONE_NAME}    AHLOA.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    CB010659_A_case10_ue1rank2.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${PDU_ID}         1
# ${PDU_ID2}         2
# ${GW_ID}          1
# ${GW_ID2}          2
# ${SLICE_ID}       1
# ${PROFILE1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=120,120,120,120,0,0,0,0 ul_bler_bit_error_periodicity\=3 
#            ...      ul_bler_bit_error_duration\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=bler action\=activate profile_id\=1 scell\=0
# ${PROFILE2}    forced_dtx_testmode_nr profile_id\=1 force_dtx_pusch\=3000:10
# ${SET_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=forced_dtx profile_id\=1 action\=activate
# ${PROFILE3}    ul_mimo_switch_nr profile_id\=7 pusch_tx_mix_ratio\=90
# ${SET_PROFILE3}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_switch_nr action\=activate profile_id\=7
# *** Test Cases ***
# CB010659_A_b1_102_case14_FDD_UL_HARQ_Retrans_With_Regular_MSC_When_Received_Dtx_FeedBack
#     #mcs=14
#     Add GNB swconfig    0x580367:0x4000
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA UE
#     SA send dl and ul data    ${UE_ID}    number=1    dl_data=10M    ul_data=150M
# 	Wait '2s' for stabible
# 	Send some bler ue1
# 	Send some dtx ue1
# 	run keyword and continue on failure    Check throughput
#     #Start collect bip log
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     #Wait for '0s' to stop bip log with name'bip'
# 	Check reserved mcs in ttitrace is correct    tti
#     Detach '1' UE
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Send some bler ue1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# 	Wait '2s' for stabible
# Send some dtx ue1
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}	
# rank change ue2
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}		
# Attach SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal     
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# Attach SA UE2
#     Airphone SA Attach    ue_id=${UE_ID2}
#     airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal     
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
# Prepare test
#     #Active GNB L2 feature debug traces
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 	
# Modify 10659 Swconfig
# 	#Add GNB swconfig    0x580010:14  
#     Add GNB swconfig    0x580367:0x40000	
#     #Add GNB swconfig    @{Rdparameter}
# 
# Verify throughput
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}     scell_id=0    type=pusch    tput_type=ave   
#      should be true    ${ue1_tp}>30000
# SA send mutiple trf dl data
#     [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}=1    ${protocol}=udp
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    DL    ${dl_data}    pdu_id=${pdu_id}    duration=6000s    trf_id=${num}    
#     ...    protocol=${protocol}
# 
# SA send mutiple trf ul data
#     [Arguments]    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}=1    ${protocol}=udp
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    UL    ${ul_data}    pdu_id=${pdu_id}    duration=6000s    trf_id=${num}    
#     ...    protocol=${protocol}
# 
# SA send dl and ul data
#     [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1    ${protocol}=udp
#     SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}    ${protocol}
#     SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}    ${protocol}
# 
# NSA send mutiple trf dl data
#     [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${protocol}=udp
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    DL    ${dl_data}    duration=6000s    trf_id=${num}    
#     ...    protocol=${protocol}
