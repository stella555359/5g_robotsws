# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BLLL_AP_LOO    owner_changyli   AP    CRT
# ...    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_9198_case13_20M.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_ASIL_1CELL_20M.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_9198_AEQE_case01.cfg
# ${UE_ID_NSA}          11
# ${UE_ID}          2
# ${UE_ID1}          1
# ${PDU_ID1}         1
# ${GW_ID1}          1
# ${SLICE_ID1}       1
# 
# ${UE_ID2}          2
# ${PDU_ID2}         2
# ${GW_ID2}          2
# ${SLICE_ID2}       2
# 
# ${UE_ID3}          3
# ${PDU_ID3}         3
# ${GW_ID3}          3
# ${SLICE_ID}       1
# 
# ${UE_NUM_SA}         2
# ${UE_NUM_NSA}        2
# ${EGATE_TAG}      precoder
# ${TTI_TAG}      tti
# ${TTI_TAG_BLER}      tti_bler
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='false'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BIP_TAG}    precoder_bip
# ${FILTER_1}    uldata_puschreceivereq
# @{titles_1}    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
# 
# ${PROFILE1}    ul_sinr_testmode_nr profile_id\=1 pathloss\=60
# ${PROFILE2}    ul_sinr_testmode_nr profile_id\=1 pathloss\=70
# ${PROFILE3}    ul_sinr_testmode_nr profile_id\=1 pathloss\=80
# ${PROFILE4}    ul_sinr_testmode_nr profile_id\=1 pathloss\=90
# ${PROFILE5}    ul_sinr_testmode_nr profile_id\=1 pathloss\=100
# ${PROFILE6}    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
# ${PROFILE7}    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
# 
# 
# ${PROFILE14}    ul_sinr_testmode_nr profile_id\=1 pathloss\=50
# ${PROFILE13}    ul_sinr_testmode_nr profile_id\=1 pathloss\=40
# ${PROFILE12}    ul_sinr_testmode_nr profile_id\=1 pathloss\=30
# ${PROFILE11}    ul_sinr_testmode_nr profile_id\=1 pathloss\=20
# ${PROFILE10}    ul_sinr_testmode_nr profile_id\=1 pathloss\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE2}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE3}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE4}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE5}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE6}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# ${SET_PROFILE7}    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# 
# ${PROFILE_DEL}    ul_sinr_testmode_nr profile_id\=1 delete\=1
# 
# 
# *** Test Cases ***
# CB009198_B_B1_case13_Interaction_between_256QAM_and_FR1_DFT-s-OFDM_for_TDD_PUSCH_NSA
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in 'after_onair' file
# 
#     Attach NSA UE and send data
#     run keyword and continue on failure    Check NSA UE throughput
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace no bler
# 
#     Set pathloss from low to high
#     wait '10s' for stable
# #    log to console  DFTS enabled Start collect bip log
# #    Collect and convert bip    bip_name=bip_enable    cp_flag=1
#     Verify multi NSA UEs throughput    0
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_dfts'
#     run keyword and continue on failure    Check ttitrace dfts
# 
#     Set pathloss from hign to low
# #    log to console  DFTS disabled Start collect bip log
# #    Collect and convert bip    bip_name=bip_diabled    cp_flag=0
#     Collect AP egate log    ${EGATE_TAG}
#     Check transformPrecoder in rrc log
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_cp'
#     run keyword and continue on failure    Check ttitrace cp
# 
#     Delete pathloss
#     wait '20s' for stable
#     run keyword and continue on failure    Check NSA UE throughput
# 
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     [Arguments]    ${tput_peak}=1
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_NSA}    scell_id=8    type=pusch    tput_type=ave
#     log to console    ul tput =${ul_throughput_pcell}
#     Run Keyword If    ${tput_peak}==1    should_be_true    ${ul_throughput_pcell}>45000
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID_NSA}    scell_id=8    type=pdsch    tput_type=ave
#     log to console    dl tput =${dl_throughput_pcell}
#     Run Keyword If    ${tput_peak}==1    should_be_true    ${dl_throughput_pcell}>125000
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     log to console    ul tput =${ul_throughput_pcell}
# #    should_be_true    ${ul_throughput_pcell}>20000
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#      log to console    dl tput =${dl_throughput_pcell}
# #     should_be_true    ${dl_throughput_pcell}>20000
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     Airphone NSA Stop Data Traffic   ${UE_ID_NSA}    DL
#     Airphone NSA Stop Data Traffic   ${UE_ID_NSA}    UL
#     Airphone NSA Detach    ${UE_ID_NSA}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     Airphone SA Stop Data Traffic     ${UE_ID}     DL    ${UE_ID}
#     Airphone SA Stop Data Traffic     ${UE_ID}     UL    ${UE_ID}
#     Airphone SA Detach    ue_id=${UE_ID}
# 
# Attach '${UE_ID}' SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     Wait '2s' for stabible
#     Airphone Set Traffic Type    ue_id=${UE_ID}    pdu_id= ${UE_ID}    type=internal
#     Wait '2s' for stabible
#     Airphone Pdu Session Setup    ue_id=${UE_ID}   pdu_id=${UE_ID}   nwslice_id=1   gw_id=${UE_ID}
#     Wait '2s' for stabible
# 
# Attach NSA UE and send data
#     Airphone Nsa Attach    ${UE_ID_NSA}    profile_id=None
#     Wait '5s' for stable
#     NSA send mutiple trf ul data   ${UE_ID_NSA}    1    60M
#     NSA send mutiple trf dl data   ${UE_ID_NSA}    1    140M
#     wait '20s' for stable
# 
# Attach NSA 6 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM_NSA}+${UE_ID_NSA}+1
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
# 
# NSA send data 6 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM_NSA}+${UE_ID_NSA}+1
#     \   NSA send ue '${num}' mutiple trf '1' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '40M' UL data
# 
# 
# Collect and convert bip
#     [Arguments]    ${bip_name}=precoder    ${cp_flag}=0
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${bip_name}'
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_name}/tcpdump_L2L1_bip_filtering_1:0.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_name}/${bip_name}.csv    ${FILTER_1}    ${titles_1}
# 
#     run keyword if   ${cp_flag}==0    Check puschTransformPrecoderFlag Disabled in bip'${bip_name}'
#     ...    ELSE    Check puschTransformPrecoderFlag Enabled in bip'${bip_name}'
# 
# Check puschTransformPrecoderFlag Disabled in bip'${bip_name}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_TransformPrecoderFlagDisabled.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_name}/
# 
# Check puschTransformPrecoderFlag Enabled in bip'${bip_name}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_TransformPrecoderFlagEnable.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_name}/
# 
# 
# Check ttitrace no bler
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case01.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case01.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Capture and check ttitrace no bler
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check ttitrace no bler
# 
# Check ttitrace cp
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case13_cp.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Check ttitrace dfts
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case13_dfts.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
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
# 
# Set pathloss from hign to low
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
# 
# Set pathloss from hign to zero
#     airphone_execute_egate_command    ${PROFILE14}
#     airphone_execute_egate_command    ${SET_PROFILE14}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE13}
#     airphone_execute_egate_command    ${SET_PROFILE13}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE12}
#     airphone_execute_egate_command    ${SET_PROFILE12}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE11}
#     airphone_execute_egate_command    ${SET_PROFILE11}
#     wait '10s' for stable
#     airphone_execute_egate_command    ${PROFILE10}
#     airphone_execute_egate_command    ${SET_PROFILE10}
#     wait '10s' for stable
# 
# 
# 
# Check transformPrecoder in rrc log
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_TransformPrecoderFlag_case13.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Delete pathloss
#     airphone_execute_egate_command    ${PROFILE_DEL}
# 
# 
# 
