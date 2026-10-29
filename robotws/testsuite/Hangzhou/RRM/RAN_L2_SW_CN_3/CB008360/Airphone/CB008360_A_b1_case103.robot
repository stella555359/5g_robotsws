# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B1b_case_103_2 Rank1 UEs blindly paired in one subcells with power limit users
# 
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lily
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${UE_NUM}         100
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|100|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots10|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|1|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# 
# ${bwp_profile57}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//managedObject
# ${bwp_profile57_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//p
# ${bwp_duration1}    text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_periodicity_1}    text|sl5|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl5|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='periodicity']
# ${slotOffset_1}    text|0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='slotOffset']
# ${slotOffset_3}    text|0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='slotOffset']
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id=1 phr_mode=Fixed
# ...          phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=1 phr_period=20 pc_max=30
# 
# *** Test Cases ***
# CB008360_A_B1b_case_103_2 Rank1 UEs blindly paired in one subcells with power limit users
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Step3:Push full buffer in UL
# 	Step4:Override UE1’s PHR trigger UE1 UL power limited
# 	Step5:Override UE2’s PHR trigger UE2 UL power limited
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    22    0    17    0    22    0    17    0    1
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    none    none    rdSINRusedForRank1LA
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${actUlMuMimoTapering}
#     ...       ${bwp_profile57}    ${bwp_profile57_p}    ${bwp_duration1}    ${bwp_duration3}    ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_3}    ${nPdcchCandidatesInAL4_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Override UE1’s PHR trigger UE1 UL power limited
#     Start Collect GNB and AP Syslog in 'Step4_power_limit1' File
#     #Start GNB BIP Log
#     Airphone Execute Egate Command    ${phr_override_profile_1_CMD}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=phr_override action\=activate profile_id\=1
#     #Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_power_limit1${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_power_limit1${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_power_limit1${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_power_limit1
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_power_limit1' File
# 
# 
# Step5:Override UE2’s PHR trigger UE2 UL power limited
#     Start Collect GNB and AP Syslog in 'Step5_power_limit2' File
#     #Start GNB BIP Log
#     Airphone Execute Egate Command    ${phr_override_profile_1_CMD}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=phr_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_power_limit2${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_power_limit2${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_power_limit2${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step5_power_limit2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_power_limit2' File
# 
