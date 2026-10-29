# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags    owner_zhang    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# #...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8247_case3_AEQE_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_case3_LO.xml
# ${WTS_NAME}    wts_1086_7_TAS_LO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# ${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
# @{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
# ${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# ${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
# @{titles_1}    DlData_DciInfo.patternId_item
# @{titles_2}    DlData_PdschGrant.patternId_item
# @{titles_3}    DlData_CsiRsResource_t.patternId_item
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CB008247_A_b1_case3_CL_4x4_8DL4UL_100M_Single_UE_with_different_TAS_and_not_reuse_codebook_SA_LO  
#     Prepare gnb onair
#     
#     #for tti_dl check patternid with different SW version, ${check_name} is in tti_dl.ini
#     Set test Variable    ${check_name}    dlBeamData.dlSrsBmBestBeamPatternId
#     Run Keyword If   '${SW_BRANCH}'=='SBTS22R3'   Set test Variable   ${check_name}   dlBeamData.dlSrsBmBestBeamPatternIdOnly
#     Start capture gnb and ap syslog in 'after_onair' file
#     Multi UE SA Register and check
#     Stop capture gnb and ap syslog in 'after_onair' file
# *** Keywords ***
# 
# Multi UE SA Register and check
#     : FOR    ${num}    IN RANGE    1    8
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     #tcpdump for f1ap:TxSwitch
#     \   Start collect UE'${num}' tcpdump
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     \   Stop collect UE'${num}' tcpdump
#     
#     \   Check UE'${num}' TxSwitch in attach_tcpdump
#     
#     \   DL and UL data to '${num}'
#     \   run keyword and continue on failure     check '${num}' throughput
# 
#     \   Start collect ttitrace
#     \   Wait for '2s' to stop ttitrace with name'tti'
#     \   Check '${num}' PatternId and Bler in ttiTrace
# 
#     #BIP for pdsch patternid
#     \   collect and check '${num}' BIP
# 
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
#     \   check UE '${num}' SRS in RRC log
# 
# start collect UE'${ue_id}' attach tcpdump
#     Log To Console   start collect UE'${ue_id}' attach tcpdump
#     ${executor_oam_vm}    Create Dictionary   host=192.168.255.1   user=toor4nsn   password=oZPS0POrRieRtu
#     Start Tcpdump    name=tcpdump_UE    options=-i any -c 10000    remote_info=${executor_oam_vm}
# 
# DL and UL data to '${UE_ID}'
#     Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=3
#     Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Wait '4s' for stabible
# 
# #check tti
# Check '${UE_ID}' PatternId and Bler in ttiTrace
#     Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
#     check dft_beam and bler in tti
# 
# check dft_beam and bler in tti
#     Log To Console    Check ttitrace DL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_dl_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
#     Log To Console    Check ttitrace UL
#     run keyword and continue on failure     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/tti_ul_dft_1024_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #check RRC
# check UE '${ue_id}' SRS in RRC log
#     Log To Console   check UE ${ue_id} SRS in RRC log
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_case3.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
# 
# 
# #check throughput
# check '${UE_ID}' throughput
#      Log To Console    Check throughput UE${UE_ID}
#      #${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave
#      #should be true    ${pcell_tp}>300
#      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      Log To Console		dl ${dl_tput_Mb}
#      Log To Console		ul ${ul_tput_Mb}
#      should be true    ${dl_tput_Mb}>400
#      should be true    ${ul_tput_Mb}>8
# 
# collect and check '${ue_id}' BIP
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'BIP_ue_${ue_id}'
# 
#     #   Check PatternId in bip
#     Log To Console   Check PatternId in bip
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}
# 
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap0
#     ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_csi.csv    ${FILTER_3}    ${titles_3}
#     
#     Set test Variable    ${pdcch_patternId}    101
#     #rank 3/4 UE
#     Set test Variable    ${csi_patternid}     1375,1375,1052,1052
#     #2022_7_22_patternid_changed to 1051,1401
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${csi_patternid}   1051,1051,1401,1401   
#     Set test Variable    ${pdsch_patternid}    1375,1052
#     Run Keyword If   '${SW_BRANCH}'!='SBTS22R3'   Set test Variable   ${pdsch_patternid}   1051,1401
#     #rank 1/2 UE
#     Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1024
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}
# 
#     Log To Console   Check PatternId in bip finisged
# 
# 
# #tcpdump
# Start collect UE'${ue_id}' tcpdump
#     Log To Console    Start collect UE'${ue_id}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=tcp_attach_ue${ue_id}    options= -i any -C 100   remote_info=${executor_oam_vm}
# 
# Stop collect UE'${ue_id}' tcpdump
#     Log To Console    Stop collect UE'${ue_id}' tcpdump
#     Stop Tcpdump    tcp_attach_ue${ue_id}    ${TEST_LOG_DIRECTORY()}/All/tcpdump
# 
# Check UE'${ue_id}' TxSwitch in attach_tcpdump
#     Log To Console   Check UE'${ue_id}' TxSwitch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/tcp_attach_ue${ue_id}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/f1ap.csv    ${FILTER_f1ap}    ${titles_f1ap}
# 
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tcpdump_attach_ue${ue_id}_case3.ini    i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tcpdump
