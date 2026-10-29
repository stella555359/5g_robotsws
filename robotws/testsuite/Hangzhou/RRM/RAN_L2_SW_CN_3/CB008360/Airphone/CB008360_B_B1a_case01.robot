# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_B1a_case01_07_OP17_8DL8UL.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_OP17_1CELL.xml
# ${L1BYP_XML}    L1ByP_case01_07.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8360_B_case1_7.cfg
# ${BIP_TAG}    srs
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${ue_id_1}    1
# ${ue_id_2}    2
# 
# *** Test Cases ***
# CB008360_B_B1a_case01_two_rank2_Ues_8DL8UL_Max_2Layer_without_tapering
#     [Documentation]
#     ...    this UE1's Coma value
#     prepare AirPhone and wait gNB onair
#     Prepare X2 link
#     Start capture gnb and ap syslog in 'after_onair' file
#     #Attach one SA UE'1'
#     Attach SA ue to 5g cell    t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     SA send ue '1' mutiple trf '1' for each '170M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '50' to '60'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti1_1ue'
#     ##Attach one SA UE'2'
#     #run keyword and continue on failure    Start collect ttitrace
#     #Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     #SA send ue '2' mutiple trf '1' for each '170M' UL data
#     #run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '20' to '30'
#     #run keyword and continue on failure    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '20' to '30'
#     #run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti2_2ue'
#     run keyword and continue on failure    Start collect ttitrace
#     Attach one NSA UE'11'
#     NSA send ue '11' mutiple trf '1' for each '70M' UL data
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '50' to '60'
#     run keyword and continue on failure    check NSA UE'11' dl tput range is '0' to '100' and ul tput range is '20' to '30'
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti2_2ue'
#     Detach SA UE'1'
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti3_ue11'
#     #Detach SA UE'2'
#     #run keyword and continue on failure    Wait for '4s' to stop ttitrace with name'tti4_noue'
#     #run keyword and ignore error    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Modify Swconfig
#     Modify 8247 Swconfig
#     Add GNB swconfig    0x590103:1
#     #0x420062 =1  #enable_rdNewTddCellSlotModel of CB008940
#     Add GNB swconfig    0x420062:1
#     #rdSINRusedForRank1LA(0x37C) = 1
#     Add GNB swconfig    0x58037C:1
#         #enable 8360 debug log
#     Add GNB swconfig    0x58057a:0x4
#     Add GNB swconfig    0x58057e:0x1047552
# 
# Prepare X2 link
#     #airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# 
# prepare AirPhone and wait gNB onair
#     Upload airphone l1bypass to iphy
#     Modify Swconfig
#     Prepare gnb onair
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Attach one NSA UE'${ue_id}'
#     #airphone_cleanup_egate_console_log
#     Log To Console   ${\n}-----Attach NSA UE ${ue_id} ------
#     Airphone Nsa Attach    ${ue_id}     profile_id=None
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#     SA send mutiple trf dl data    ${ue_id}    number='${ul_data_size}'   ul_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number='${ul_data_size}'   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
# 
# NSA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#    NSA send ue '${ue_id}' mutiple trf '${dl_trf_num}' for each '${dl_data_size}' DL data
#    NSA send ue '${ue_id}' mutiple trf '${ul_trf_num}' for each '${ul_data_size}' UL data
# 
# collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
#     Start collect ttitrace
#     Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'
# 
# Multi UE NSA Attach with start ue id '${start_ue_id}' and ue num '${NSA_UE_NUM}'
#     : FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${NSA_UE_NUM}+1
# 
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${ue_id} ------
# 
#     \   Airphone Nsa Attach    ${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    Wait '3s' for stabible
# 
# Attach one SA UE'${ue_id}'
#     Log To Console   ${\n}-----register SA UE ${ue_id} ------
#     Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
# 
# Multi UE SA Register with start ue id '${start_ue_id}' and ue num '${SA_UE_NUM}'
#     : FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${SA_UE_NUM}+1
# 
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register SA UE ${ue_id} ------
# 
#     \    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    Wait '3s' for stabible
# 
# 
# check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Log To Console    ..Check throughput UE${ue_id}
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
# 
# check NSA UE'${UE_ID}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Log To Console    ..Check throughput UE${UE_ID}
#     ${dl_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${ul_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
#     ${dl_tput_Mb}    evaluate    ${dl_pcell_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_pcell_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
# 
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
# check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
#     log to console    start to check throughput ${ue_id}
#     should be true    ${dl_tput}>${dl_low}
#     should be true    ${dl_tput}<${dl_high}
#     should be true    ${ul_tput}>${ul_low}
#     should be true    ${ul_tput}<${ul_high}
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
#     ...    ini_path=${CURDIR}/ini/case5_rrc.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
#     #t4r4_n4:codebook
#     run keyword if    ${ue_id}==2   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case5_rrc.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case5_tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case5_tti_ul.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# collect and check PatternId in BIP
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_4}    (uldata_puschreceivereq)&&!(3gpp.rnti == 65535)
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
#     Log To Console   Check PatternId in bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdumpL2L1_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pucch_puschreceivereq.csv    ${FILTER_4}    ${titles_4}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case5_bip_pdcch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/case5_bip_pdsch.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
#     Log To Console   Check PatternId in bip finisged
# 
