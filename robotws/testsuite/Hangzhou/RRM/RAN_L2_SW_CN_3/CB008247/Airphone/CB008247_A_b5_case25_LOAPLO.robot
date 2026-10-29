# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CIT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS23R2
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case25_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_case11_25_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8247_A_case11_25_LOAPLO.cfg
# ${UE_NUM}    2
# ${BIP_TAG}    srs
# ${FILTER}           dldata_pdcchsendreq
# @{titles}   DlData_DciInfo.patternId_item
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# ${RI_SA_profile}    csi_override_testmode_nr profile_id\=4 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
# ${srs_beam_pos_profile1}    cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions=4 azimuth\=30,40,50,60
# ${active_srs_beam_pos_profile1}    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=cell_srs_beam_pos profile_id\=1 action\=activate
# 
# *** Test Cases ***
# CB008247_A_b5_case25_two_UE_t2r4_frequency_multiplexing_SA
#     [Documentation]
#     ...    this UE1's Coma value is H:15,V:5,pattern id is 1164
#     #Upload airphone l1bypass to iphy
#     Modify Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     LoAPLO Multi UE pos and sinr set
#     Multi UE SA Register and check rrc log
#     run keyword and continue on failure    check throughput
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check patternId and bler in tti
#     Detach '${UE_NUM}' UE
#     run keyword and ignore error    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Modify Swconfig
#     Modify 8247 Swconfig
#     Add GNB swconfig    0x590103:1
# 
# Multi UE SA Register and check rrc log
#     : FOR    ${ue_id}    IN RANGE    1    ${UE_NUM}+1
# 
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${ue_id} ------
# 
#     \    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    run keyword and continue on failure    check UE '${ue_id}' SRS in RRC log
#     \    Wait '3s' for stabible
# 
# LoAPLO Multi UE pos and sinr set
#     #azimuth=11(H1048),-30(H1032),50,60
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=1 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=200 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 
# DL and UL data to '${ue_id}'
#     Log To Console    DL*2 and UL*1 data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${ue_id}    DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${ue_id}    DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Airphone SA Start Data Traffic    ${ue_id}    UL   50M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
# 
# check throughput
#     : FOR    ${ue_id}    IN RANGE    1    ${UE_NUM}+1
#     \   Log To Console    Check throughput UE${ue_id}
#      \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#      \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#      \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      \      Log To Console    dl ${dl_tput_Mb}
#      \      Log To Console    ul ${ul_tput_Mb}
#      \      should be true    ${dl_tput_Mb}>470
#      \      should be true    ${ul_tput_Mb}>50
# 
# check patter id is correct in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case11_tti_dl_patterid.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/bip.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/case11_bip_pdcch_patterid.ini    i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}
# 
# check ue ${ue_id} ${dl_tput} range is ${dlthreshold_low} to ${dlthreshold_high} ${ul_tput} range is ${ulthreshold_low} to ${ulthreshold_high}
#     log to console    start to check throughput ${ue_id}
#     should be true    ${dl_tput}>${dlthreshold_low}
#     should be true    ${dl_tput}<${dlthreshold_high}
#     should be true    ${ul_tput}>${ulthreshold_low}
#     should be true    ${ul_tput}<${ulthreshold_high}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}
# 
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable    ${rnti_1}    ${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable    ${rnti_2}    ${rnti_list[0]}
# 
#     run keyword if    ${ue_id}==1   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case25_rrc_ue1_ue2_ue9_ue10.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
#     #t4r4_n4:codebook
#     run keyword if    ${ue_id}==2   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case25_rrc_ue1_ue2_ue9_ue10.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case25_tti_dl_LOAPLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     #Log To Console    --Check ttitrace UL
#     #run keyword and continue on failure     check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/ini/case25_tti_ul_LOAPLO.ini    log_need_to_check=i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# collect and check PatternId in BIP
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
#     Log To Console   Check PatternId in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap01
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
#     #Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     #...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case25_bip_pdcch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case25_bip_pdsch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     Log To Console   Check PatternId in bip finisged