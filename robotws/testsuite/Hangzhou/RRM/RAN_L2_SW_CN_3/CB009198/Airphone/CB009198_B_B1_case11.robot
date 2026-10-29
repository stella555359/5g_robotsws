# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BLLL_AP_LOO    owner_menzheng   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_CB009198_CASE11.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE_2CELL_APLO.xml
# ${WTS_NAME}    wts_2AEQE_aplo.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}         1
# ${UE_ID1}          1
# ${PDU_ID1}         1
# ${GW_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID2}         2
# ${GW_ID2}          2
# ${SLICE_ID}       1
# ${EGATE_TAG}      CB009198
# ${BIP_TAG}    9198_bip
# ${FILTER}    ((uldata_puschreceivereq) && !(3gpp.rnti == 65535))
# @{titles}        3gpp.sfn    3gpp.slot    3gpp.subcellid    3gpp.rnti    UlData_puschReceiveReqSubcell_t.sfnForProcessing
# ...    UlData_puschReceiveReqSubcell_t.slotForProcessing
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# 
# 
# *** Test Cases ***
# CB009198_B_B13_case11_Buffered_UL_C4_2S_1CC_Traffic_1UE_in_each_Cell_with_1116-3FS
#     Prepare gnb onair
#     #Execute AP Command before attach
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Set and enhence SRS power
#     Attach SA UE and send data
#     Wait '5s' for stabible
#     Check ul throughput
#     Check RRC log for attach precoder disable
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'SA_UE_no_pathloss'
#     Start collect bip log
#     Wait for '0s' to stop bip log with name'SA_UE_no_pathloss'
#     #run keyword and continue on failure    check bip'SA_UE_no_pathloss'
#     Start collect ttitrace
#     Set ue pathloss 110
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_110'
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'SA_UE_pathloss_110'
#     #run keyword and continue on failure    check bip'SA_UE_pathloss_110'
#     #run keyword and continue on failure    cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_110_ul.csv    19
#     Check RRC log for precoder enable	
#     Check ul throughput pathloss 1st	
#     Start collect ttitrace
#     Set ue pathloss 95
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_95'
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'SA_UE_pathloss_95'
#     #run keyword and continue on failure    check bip'SA_UE_pathloss_95'
#     run keyword and continue on failure    cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_95_ul.csv    19
#     Check RRC log for precoder disable	
#     Check ul throughput pathloss 2nd	
#     deactivate ue pathloss
#     Check ul throughput
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'SA_UE_no_pathloss_1'
#     Stop capture gnb and ap syslog in 'after_onair' file 
# 
# *** Keywords ***
# Set and enhence SRS power
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 
# Check RRC log for attach precoder disable
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_attachprecoderdisable    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_case11_attach_precoder_disable.ini 
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_attachprecoderdisable
#     airphone_cleanup_egate_console_log	
# 
# Check RRC log for precoder disable
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_precoderdisable    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_case11_precoder_disable.ini 
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_precoderdisable
# 	
# Check RRC log for precoder enable 
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_precoderenable    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_case11_precoder_enable.ini 
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_precoderenable
#     airphone_cleanup_egate_console_log
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach SA UE and send data
#     Airphone SA Attach    ${UE_ID1}
#     Wait '5s' for stabible
#     Airphone SA Attach    ${UE_ID2}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     SA send mutiple trf ul data    ${UE_ID1}    2   125M   ${UE_ID1}
#     SA send mutiple trf ul data    ${UE_ID2}    1   175M   ${UE_ID2}
# 	
# Set pathloss from low to high
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     wait '10s' for stable
# 
# Set ue pathloss 110
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# 
# Set ue pathloss 95
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=95
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
# 
# deactivate ue pathloss
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=deactivate profile_id\=1
# 
# from hign to low
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     wait '10s' for stable
# 
# Check transformPrecoder in rrc log
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_TransformPrecoderFlag.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check ul throughput 
#      Wait '10s' for stabible
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pusch    tput_type=ave
#      should be true    ${ue1_tp}>190000
#      should be true    ${ue2_tp}>145000
# 	 
# Check ul throughput pathloss 1st
#      Wait '10s' for stabible
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pusch    tput_type=ave
#      should be true    ${ue1_tp}>6000
#      should be true    ${ue2_tp}>5000
# 
# Check ul throughput pathloss 2nd
#      Wait '10s' for stabible
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pusch    tput_type=ave
#      should be true    ${ue1_tp}>100000
#      should be true    ${ue2_tp}>85000	 
# 
# check bip'${bip_title}'		
#     Log To Console   ${\n}---check bip---
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case11.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}
