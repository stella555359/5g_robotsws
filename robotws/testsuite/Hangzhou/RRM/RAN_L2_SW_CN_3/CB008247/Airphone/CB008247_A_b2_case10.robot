# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_ny   AP    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case10.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}    L1ByP_case10.xml
# ${WTS_NAME}    wts_1086_7_TAS_ue1_t1r1.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${BIP_TAG}    srs
# ${FILTER}           dldata_pdcchsendreq
# @{titles}   DlData_DciInfo.patternId_item
# 
# *** Test Cases ***
# CB008247_A_b2_case10_OL_4x4_20Mhz_best_beam_Single_UE_t1r1_NSA
#     Upload airphone l1bypass to iphy
#     Prepare gnb onair
# 	Start WTS And Wait BTS Until Onair   ${WTS_NAME}  reload=${False}
#     Start capture gnb and ap syslog in 'after_onair' file
#     Start collect ttitrace
#     Start collect bip log
# 	Execute AP Command before attach
#     Attach LTE UE1
#     Wait for '2s' to stop bip log with name'${BIP_TAG}'
#     NSA send ue '${UE_ID}' mutiple trf '3' for each '175M' DL data
#     Wait for '2s' to stop ttitrace with name'tti'
#     Airphone NSA Detach    ${UE_ID}
# 	airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     check patter id is correct in ttitrace
# 
# *** Keywords ***
# Wait '${time}' for stabible
#     sleep    ${time}
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# 
# Attach LTE UE1
#     Airphone Nsa Attach    ${UE_ID}	
# check patter id is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case22.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/bip.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_patterid.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}	
