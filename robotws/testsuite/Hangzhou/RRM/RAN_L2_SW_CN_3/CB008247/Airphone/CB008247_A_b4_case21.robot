# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_ny    AP    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case21.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}    L1ByP_case21.xml
# ${WTS_NAME}    wts_1086_7_TAS_ue1_t1r4.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    Tcpdump
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${BIP_TAG}    srs
# ${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
# @{titles}   DlData_DciInfo.patternId_item
# 
# 
# *** Test Cases ***
# CB008247_A_b4_case21_OL_4x4_1UE_t1r4_adaptation_SRS_and_GOB_beam_SA
#     Upload airphone l1bypass to iphy
#     Prepare gnb onair
# 	airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Start collect ttitrace
#     Start collect bip log
#     Attach SA UE
#     Internal DL data
#     Wait for '2s' to stop bip log with name'${BIP_TAG}'
#     Wait for '2s' to stop ttitrace with name'tti'
#     Detach UE
# 	airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     check bler is correct in ttitrace                    
#     check patter id is correct in bip
# 
# *** Keywords ***
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>200000
# Wait '${time}' for stabible
#     sleep    ${time}
# check bler is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case22.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/bip_case18.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case18.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}	
# 	
# Attach SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal     
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# Internal DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
