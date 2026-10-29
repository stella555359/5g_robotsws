# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case11.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_RRC_RES.xml
# ${L1BYP_XML}    L1ByP_case11_case25.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_RRC_RES.cfg
# ${UE_ID_1}          1
# ${BIP_TAG}    srs
# ${FILTER}           dldata_pdcchsendreq
# @{titles}   DlData_DciInfo.patternId_item
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# ${num}    1
# 
# *** Test Cases ***
# CB008247_A_b2_case11_OL_4x4_20Mhz_best_beam_Single_UE_t1r4_t4r4_rrc_reestablish_SA
#     [Documentation]
#     ...    this UE1's Coma value is H:15,V:5,pattern id is 1164
#     Upload airphone l1bypass to iphy
#     Modify 8247 Swconfig
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t1r4-t2r4_n2    ${UE_ID_1}    PDU_ID=1    GW_ID=1
#     Wait '2s' for stabible
#     SA send dl and ul data    ${UE_ID_1}    number=3    dl_data=175M    ul_data=20M    pdu_id=1
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=1
#     check ue ${UE_ID1} ${dl_tput1} range is 150000 to 160000 ${ul_tput1} range is 24000 to 30000
#     airphone_execute_egate_command    ue_rrc_reestablish id\=1 gnb\=2 cell\=1 cause\=otherFailure
#     Wait '3s' for stabible
#     SA send dl and ul data    ${UE_ID_1}    number=3    dl_data=175M    ul_data=20M    pdu_id=1
#     Start collect ttitrace
#     Wait '2s' for stabible
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=1
#     run keyword and continue on failure    check ue ${UE_ID1} ${dl_tput1} range is 150000 to 160000 ${ul_tput1} range is 24000 to 35000
#     check UE '${num}' SRS in RRC log
#     Wait for '1s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check patternId and bler in tti
#     Detach '1' UE
#     run keyword and ignore error    Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
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
#     run keyword if    ${ue_id}==1   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case11_rrc_t1r4_t2r4_n2_tas_srs.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case11_tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case11_tti_ul.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
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
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case11_bip_pdcch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case11_bip_pdsch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     Log To Console   Check PatternId in bip finisged