# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:CB008701_A_B5_02_case502_interwork_with_ULMUMIMO_16DL8UL
# 
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# 
# ${SCFC_NAME}        gNB_scf_ASIB_ABIO_AQQL_TDD_eCPRI_cmwv_SANSA_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}          wts_config_AQQL_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM}         8
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|16DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# 
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                                   text|99|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                                  text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                             text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                            text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                 text|30dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}                     text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${actDl256Qam}                              text|true|//*[@name\="actDl256Qam"]
# #ulmumimo
# ${actUlMuMimoTapering}                          text|true|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUl256Qam}                                  text|true|//*[@name\="actUl256Qam"]
# 
# #1208
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# 
# 
# #bwp
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008701_A_B5_02_case502_interwork_with_ULMUMIMO_16DL8UL
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 8UEs
#     Step3:Push full buffer in DL and UL
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    13    7    6    0    6    0    6    0    0    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    10    8    6    0    6    0    6    0    1    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    6    7    6    0    6    0    6    0    2    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    2    8    6    0    6    0    6    0    3    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    25    7    6    0    6    0    6    0    4    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    21    8    6    0    6    0    6    0    5    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    17    7    6    0    6    0    6    0    6    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    14    8    6    0    6    0    6    0    7    
# 	...    UlRank1=2    UlRank1=2    UlRank1=2    UlRank1=2    ComaMultiplier=29
# 
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${prachConfigurationIndex}    ${ulDlDataSlotRatio}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${msg1FrequencyStart}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actDl256Qam}    ${dlMuMaxNumLayerPerMuRbg}    ${actUlSrsBm}
#     ...       ${actUlMuMimoTapering}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}
#     ...       ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${ulMuMimoLinkAdaptionSwitch}    ${actUl256Qam}
#     ...       ${bwp_profile5}    ${bwp_profile57}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}  
#     ...    L1b=True
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 8UEs
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${UE_ID}    SetVariable    ${ID}
#     ${GW_ID}    SetVariable    ${ID}
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ID} testmode\=csi_override action\=activate profile_id\=1
# 	END
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_list[5]}
# 	Set test Variable	 ${rnti_7} 	${rnti_list[6]}
# 	Set test Variable	 ${rnti_8} 	${rnti_list[7]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in DL and UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     FOR    ${ID}    IN RANGE    1    3
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    5    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    6    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    7    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    8    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
#     END
#     Wait Throughput Timer    40
# 	airphone_execute_egate_command    ue_disp id\=1,2,3,4,5,6,7,8
#     FOR    ${UE_ID}    IN RANGE    1    3    
# 	Wait Throughput Timer    1    
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     END
#     airphone_execute_egate_command    ue_disp id\=1,2,3,4,5,6,7,8
#     #run keyword and continue on failure    GET THP
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Wait Throughput Timer    60
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
# 	airphone_execute_egate_command    ue_disp id\=1,2,3,4,5,6,7,8
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case502_tti_pair_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case502_tti_pair_ul.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# GET THP
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
