# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_zhang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_frame1116_3ms_80M_c49_b1_slots40_case9.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}    L1B_H10V10_1284_case9.xml
# ${WTS_NAME}    wts_1086_7_TAS.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# 
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CB008247_A_b2_case9_CL_4x4_8DL4UL_80M__best_beam_two_UE_t2r2_NSA
#     Upload airphone l1bypass to iphy
#     Modify 8247 Swconfig
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
# 
#     UE NSA Attach
# 
#     Send DL data to UE and check throughput
# 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     Check PatternId and Bler in ttiTrace
# 
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP_data'
# 
#     Detach NSA UEs
# 
#     Check RRC LOG
# 
#     Check PatternId in bip
# 
# *** Keywords ***
# 
# UE NSA Attach
#     : FOR    ${num}    IN RANGE    12    14
#     \   Log To Console   ${\n}Attach UE ${num}
#     \   Airphone Nsa Attach    ue_id=${num}
#     \   Wait '4s' for stabible
# 
# Send DL data to UE and check throughput
#     Log To Console    Check throughput
#     : FOR    ${num}    IN RANGE    12    14
#     \   NSA send ue '${num}' mutiple trf '3' for each '165M' DL data
#     \   Wait '3s' for stabible
# 
#     : FOR    ${num}    IN RANGE    12    14
#     \   ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    8    type=pdsch    tput_type=ave
#     \   Log To Console    UE ${num} dl throughput: ${pcell_tp}
#     \   should be true    ${pcell_tp}>270000
# 
# Check RRC LOG
#    Log To Console    check RRC log
#    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE
#    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_case9.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Detach NSA UEs
#     : FOR    ${num}    IN RANGE    12    14
#     \   Airphone NSA Detach    ue_id=${num}
#     \   Wait '3s' for stabible
# 
# #check 2============================================
# Check PatternId and Bler in ttiTrace
#     Log To Console    Check PatternId and Bler in ttiTrace
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case9.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case9.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check PatternId in bip
#     Log To Console   Check PatternId in bip
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_data/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_data/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_data/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_data/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_data/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_data/bip_csi.csv    ${FILTER_3}    ${titles_3}
# 
#     Set test Variable	 ${pdcch_patternId}    1304
#     Set test Variable	 ${pdsch_patternId}    1304
#     Set test Variable	 ${csi_patternId}    1252,1252,1247,1247,1252,1252,1247,1247
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_case9.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_data
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_case9.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_data
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case9.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_data
# 
#     Log To Console   Check PatternId in bip finisged
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
