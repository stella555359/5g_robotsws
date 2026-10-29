# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case13_MP.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_APLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_LOAPLO.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# ${BIP_TAG}    srs
# ${FILTER}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER1}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# @{titles}    DlData_DciInfo.patternId_item
# @{titles1}    DlData_PdschGrant.patternId_item
# @{titles}   DlData_DciInfo.patternId_item    DlData_DciInfo.patternId_item
# ${patter_id1}    1306
# ${patter_id2}    1306       # not used
# 
# *** Test Cases ***
# CB008247_A_b3_case13_OL_4x4_90M_best_beam_determination_oneue_Codebook_SRS_oneue_TAS_SRS_SA
#     Modify 8247 Swconfig
#     Prepare gnb onair
#     Set ue srs sinr
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource4    ${UE_ID}
#     Attach SA ue to 5g cell    t4r4_n4    ${UE_ID2}    PDU_ID=2    GW_ID=2
#     SA send dl and ul data    ${UE_ID}    number=6    dl_data=175M    ul_data=20M
#     SA send dl and ul data    ${UE_ID2}    number=7    dl_data=175M    ul_data=20M    pdu_id=2
#     Start collect bip log
#     Start collect ttitrace
#     Wait '3s' for stabible
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Wait for '0s' to stop bip log with name'bip'
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/switch
#     run keyword and continue on failure    Wait Until Keyword Succeeds    30s    2s    Check ue tput is correct
#     Detach '2' UE
#     Stop egate log and unzip with name'egate'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check srs usage in rrc
#     run keyword and continue on failure    Check patter id is correct in ttitrace
#     run keyword and continue on failure    Check patter id is correct in bip
# 
# 
# 
# *** Keywords ***
# Set ue srs sinr
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_srs\=200 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=1
# 
# Check srs usage in rrc
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_srs_usage_case13.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_egate
# 
# Check patter id is correct in ttitrace
#     ${path}    List Files In Directory    ${TEST_LOG_DIRECTORY()}/All    switch_dl.*csv
#     ${path_tti}    set variable    ${path}[0]
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_dl_case13_APLO.ini    i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ${CURDIR}/ini/tti_ul_case13_APLO.ini    i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdcch.csv    ${FILTER}    ${titles}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip/bip_pdsch.csv    ${FILTER1}    ${titles1}
#     Check Log With Au2anlysis    ${CURDIR}/ini/bip_case13_pdcch_APLO.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
#     #Check Log With Au2anlysis    ${CURDIR}/ini/bip_case13_pdsch_APLO.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     should be true    ${dl_tput1}>560000
#     should be true    ${dl_tput2}>560000
#     should be true    ${ul_tput1}+${ul_tput2}>100000
