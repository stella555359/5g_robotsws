# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# 
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_frame1208_100M_c63_b0_slots20_case4.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}    L1B_H5V5_1164_case4.xml
# ${WTS_NAME}    wts_8247_case4.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${hi}	8
# @{titles_1}    DlData_DciInfo.patternId_item    3gpp.rnti
# @{titles_2}    DlData_PdschGrant.patternId_item     3gpp.rnti
# @{titles_3}    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.density
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CB008247_A_b1_case4_CL_4x4_8DL4UL_multiUE_no_free_periodic_SRS_and_different_SRS_resource_config_SA
#     Upload airphone l1bypass to iphy
#     #Modify 8247 Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Multi UE SA Register and check
# 
# 	run keyword and continue on failure	check throughput
# 
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
#     #for tti_dl check patternid with different SW version, ${check_name} is in tti_dl.ini
#     Set test Variable    ${check_name}    dlBeamData.dlSrsBmBestBeamPatternId
#     Run Keyword If   '${SW_BRANCH}'=='SBTS22R3'   Set test Variable   ${check_name}   dlBeamData.dlSrsBmBestBeamPatternIdOnly
#     Check patternId and bler in tti
# 
#     collect and check PatternId in BIP
# 
# 	DeRegister UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# *** Keywords ***
# #UE_id: 1-7
# Multi UE SA Register and check
#     : FOR    ${num}    IN RANGE    1    ${hi}
# 
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   DL and UL data to '${num}'
# 
#     \   check UE '${num}' SRS in RRC log
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    DL*2 and UL*1 data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==7   Set test Variable	 ${rnti_7} 	${rnti_list[0]}
# 
#     #t4r4_n4:codebook+TAS
#     run keyword if    ${ue_id}<5   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue7_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     #t4r4_n4:codebook
#     run keyword if    ${ue_id}==5   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_t4r4_n4_NO_TAS_SRS_case4.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     # t2r4_n2:codebook+TAS
#     run keyword if    ${ue_id}==6   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue3_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
#     # t2r4_n2: NO periodic SRS
#     run keyword if    ${ue_id}==7   run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_t2r4_n2_NO_peridic_SRS_case4.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# #check throughput
# check throughput
#     : FOR    ${num}    IN RANGE    1    ${hi}
#     \   Log To Console    Check throughput UE${num}
#     #\   ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     #\     should be true    ${pcell_tp}>300
#      \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${num}  	pdu_id= ${num}
#      \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#      \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      \      Log To Console		dl ${dl_tput_Mb}
#      \      Log To Console		ul ${ul_tput_Mb}
#      \      should be true    ${dl_tput_Mb}>80
#      #\      should be true    ${ul_tput_Mb}>1
# 
# 
# #check tti
# Check patternId and bler in tti
#     Log To Console    --Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_case4.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    --Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_case4.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check BIP
# collect and check PatternId in BIP
#     Set test Variable   ${pdcch_patternId}		101
#     Set test Variable   ${pdsch_patternId}		1164,1169
# 
#     Set test Variable   ${FILTER_1}    (dldata_pdcchsendreq)&&!(3gpp.rnti == 65535)
#     Set test Variable   ${FILTER_2}    (dldata_pdschsendreq)&&!(3gpp.rnti == 65535)
# 
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP'
# 
#     Log To Console   Check PatternId in bip
#     #convert csv
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     #Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap0
#     #...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     #check bip
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_case4.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_case4.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_case4.ini     i
#     #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP
# 
#     Log To Console   Check PatternId in bip finisged
# 
# 
# DeRegister UEs
#     : FOR    ${num}    IN RANGE    1    ${hi}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
