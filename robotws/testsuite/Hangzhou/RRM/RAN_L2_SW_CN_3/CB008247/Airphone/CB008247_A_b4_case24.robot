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
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_frame1208_50M_c32_b2_slots40_case24.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}    L1B_H0V0_switch_to_coma0_case24.xml
# ${WTS_NAME}    wts_1086_7_TAS.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# ${FILTER}   (dldata_pdcchsendreq)&& !(3gpp.rnti == 65535)
# @{titles}   DlData_DciInfo.patternId_item
# 
# *** Test Cases ***
# CB008247_A_b4_case24_CL_4x4_4DL4UL_50Mhz_1UE_t1r4_adaptation_SRS_and_GOB_beam_NSA
#     Upload airphone l1bypass to iphy
#     Modify 8247 Swconfig
#     Prepare gnb onair
# 
#     airphone_cleanup_egate_console_log
# 
#     Start capture gnb and ap syslog in 'after_onair' file
# 
#     UE NSA Attach
#     Send DL data to UE
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
#     check t1r4 SRS in RRC log
# 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     check bler in ttitrace
# 
#     Start collect bip log
#     Wait for '2s' to stop bip log with name'BIP'
#     Check dft-GoB switch in bip
# 
#     Check throughput
#     Detach NSA UE
# 
# *** Keywords ***
# 
# UE NSA Attach
#     Log To Console   ${\n}Attach UE 14
#     Airphone Nsa Attach    ue_id=14
#     Wait '3s' for stabible
# 
# check t1r4 SRS in RRC log
#     Log To Console   check t1r4 SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_NSA_t1r4_case24.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Send DL data to UE
#     Log To Console   Send DL data 165*2
#     NSA send ue '14' mutiple trf '2' for each '165M' DL data
#     Wait '2s' for stabible
# 
# Check throughput
#     Log To Console   check throughput
#     ${pcell_tp}=    airphone_get_throughput_on_specific_scell    14    8    type=pdsch    tput_type=ave
#     Log To Console   dl:${pcell_tp}
#     should be true    ${pcell_tp}>300000
# 
# check bler in ttitrace
#     run keyword and continue on failure   check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case22.ini
#     ...   log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check dft-GoB switch in bip
#     Log To Console   Check patternId in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_case24.csv    ${FILTER}    ${titles}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_case24.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
# Detach NSA UE
#     Log To Console      Detach NSA UE
#     Airphone NSA Detach    ue_id=14
#     Wait '3s' for stabible
# 
