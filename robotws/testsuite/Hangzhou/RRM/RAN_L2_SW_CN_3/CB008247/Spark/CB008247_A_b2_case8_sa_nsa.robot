# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       NSA Spark Common Suite Setup
# Suite Teardown    NSA Spark Common Suite Teardown
# Test Setup        Spark Common Test Setup
# Test Teardown     Spark Common Test Teardown
# Force Tags    spark
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# @{LOG_NAME_LIST}    gnb_snapshot
# ${GNB_SWCONFIG_QUAL_NAME}    8247_overlap_swconfig.txt
# ${SCFC_NAME}    SCFC_8247_spark_case8_gnb10302.xml
# ${INPUT_LTE_BTS_SCFC_PATH}     SCFC_8247_spark_case8_fdd_lte_bts6176.xml
# ${ATT}    ${CONFIG_DIR_PATH}/mcs/8ue_att_nsa_ue3_958M.csv
# ${PHASE}    ${CONFIG_DIR_PATH}/mcs/8ue_phase_sa_nsa_ue3_peak_958M.csv
# #ue1 use B1,B2,B3,B4
# #ue3 use gNB:B9,B10,B11,B12   FDD ant1 and ant2
# ${sa_ue_id_list}       1
# ${nsa_ue_id_list}       2
# ${BIP_TAG}    srs
# ${PORT}    5002
# &{GNBMIRRORINGCONFIG}    BB_SLOT_5='true'    BB_SLOT_1='false'    L2_L1_BIP='true'    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30    CPRT_MIRRORING='true'
# ${LTE_BTS_S1_IP}    10.108.231.215
# ${alias_tdd_enb}    enb1
# ${alias_fdd_enb}    enb2
# ${USE_SSL}        True
# ${BTS_PORT}       443
# ${FILTER}           dldata_pdcchsendreq
# @{titles}   DlData_DciInfo.patternId_item
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# 
# 
# *** Test Cases ***
# CB008247_A_b2_case8_CL_4x4_80Mhz_best_beam_two_UE_with_NSA_t1r2_and_t2r4_SA
#     prepare environment and get cell setup tcp dump
#     Start capture only gnb syslog in 'after_onair' file
#     Wait for '60s' to setup NSA sctp
#     ${sa_ue_ip_list}    Attach SA ue    ${sa_ue_id_list}
#     ${nsa_ue_ip_list}    Attach NSA ue    ${nsa_ue_id_list}
#     Start spark average log
#     Start spark dl and ul traffic    ${sa_ue_ip_list}    ${PORT}    5000    1400    ${sa_ue_id_list}
#     Start spark dl and ul traffic    ${nsa_ue_ip_list}    ${PORT}    5000    1400    ${nsa_ue_id_list}
#     ${sa_ue1_dl}    ${sa_ue1_ul}    Get dl and ul instant throughput    ${sa_ue_id_list[0]}
#     run keyword and continue on failure    should_be_true    ${sa_ue1_dl} > 450
#     run keyword and continue on failure    should_be_true    ${sa_ue1_ul} > 40
#     ${nsa_ue1_dl}    ${nsa_ue1_ul}    Get dl and ul instant throughput    ${nsa_ue_id_list[0]}
#     run keyword and continue on failure    should_be_true    ${nsa_ue1_dl} > 450
#     run keyword and continue on failure    should_be_true    ${nsa_ue1_ul} > 18
#     #Start collect bip log
#     #Wait for '8s' to stop bip log with name'bip'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '8s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check patternId and bler in tti
#     run keyword and continue on failure   collect and check PatternId in BIP
#     #average tput
#     Stop spark dl and ul traffic    ${sa_ue_id_list}    ${sa_ue_ip_list}    ${PORT}
#     Stop spark dl and ul traffic    ${nsa_ue_id_list}    ${nsa_ue_ip_list}    ${PORT}
#     Detach spark ue    ${sa_ue_id_list}
#     Detach spark ue    ${nsa_ue_id_list}
#     Stop capture only gnb syslog in 'after_onair' file
#     #run keyword and continue on failure    check patter id is correct in ttitrace
#     #run keyword and ignore error    check patter id is correct in bip
# 
# 
# 
# *** Keywords ***
# Prepare environment
#     Set Mcs Channel Phase And Attenuation    ${ATT}    ${PHASE}    2610
#     Qualcomm prepare gnb onair
# 
# NSA Spark Common Suite Setup
#     Spark Common Suite Setup
#     #fdd bts6176 perform commission
# 
# NSA Spark Common Suite Teardown
#     run keyword and ignore error    Block all 4G cell
#     Spark Common Suite Teardown
# 
# fdd bts6176 perform commission
#     Perform full commissioning to another gnb    ${LTE_BTS_S1_IP}    ${INPUT_LTE_BTS_SCFC_PATH}
# 
# Block all 4G cell
#     [Arguments]    ${bts_ip}=${LTE_BTS_S1_IP}    ${alias}=block
#     TAF_ADMIN.connect to    bts_host=${bts_ip}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.blockingState}'=='Unblocked'    TAF_ADMIN.Lock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     Wait '5s' for stabible
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock all 4G cell
#     [Arguments]    ${bts_ip}=${LTE_BTS_S1_IP}    ${alias}=unblock
#     TAF_ADMIN.connect to    bts_host=${bts_ip}    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.blockingState}'=='Blocked'    TAF_ADMIN.Unlock cell    ${nrcel.id}    timeout=60    connection=${alias}
#     TAF_ADMIN.teardown    connection=${alias}
# 
# check patter id is correct in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case8_tti_dl_patterid.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case8_tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case8_tti_ul.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# check patter id is correct in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}/bip.csv    ${FILTER}    ${titles}
#     Check Log With Au2anlysis    ${CURDIR}/ini/case8_bip_patterid.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${BIP_TAG}
# 
# collect and check PatternId in BIP
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
#     Log To Console   Check PatternId in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
#     #Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     #...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case8_bip_pdcch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case8_bip_pdsch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     Log To Console   Check PatternId in bip finisged
# 
# Wait for '${time}' to setup NSA sctp
#     sleep   ${time}
# 
# prepare environment and get cell setup tcp dump
#     #run keyword and continue on failure    Start Tcpdump    cellsetup    -i any -C 500M
#     Prepare environment
#     #run keyword and continue on failure    Stop Tcpdump    cellsetup    ${TEST_LOG_DIRECTORY()}/All