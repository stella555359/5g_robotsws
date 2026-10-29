# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B3b_case_111_2UEs_rank1_with non-GBR high load paired in 1subcell based on MCS compensation power limit UE
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      90 minutes
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
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots10|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|1|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_8|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}                  text|8 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${nrBtsBeamRefinementP2}                        text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${manualFrameTimingAdjustment}    text|23023400|//*[contains(@distName, 'MRBTS-1/MNL-1/MNLENT-1/SYNC-1')]//*[@name\="manualFrameTimingAdjustment"]
# 
# ${bwp_profile87}            attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-87')|//managedObject
# ${bwp_profile87_p}          text|replace('BWP_PROFILE-54', 'BWP_PROFILE-87')|//p
# ${bwp_profile8}             attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-8')|//managedObject
# ${bwp_profile8_p}           text|replace('BWP_PROFILE-5', 'BWP_PROFILE-8')|//p
# ${bwp8_duration1}           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='duration']
# ${bwp8_duration3}           text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='duration']
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='periodicity']
# ${bwp87_duration1}
# ...    text|7|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="duration"]
# ${bwp87_duration3}
# ...    text|7|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="duration"]
# ${87_nPdcchCandidatesInAL2_2}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${87_nPdcchCandidatesInAL4_1}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${87_nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${87_nPdcchCandidatesInAL4_3}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${87_nPdcchCandidatesInAL8}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${87_nPdcchCandidatesInAL16}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${bwp87_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\='periodicity']
# ${bwp87_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\='periodicity']
# ${bwp87_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# 
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id=1 phr_mode=Fixed
# ...          phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=1 phr_period=20 pc_max=30
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008360_A_B3b_case_111_2UEs_rank1_with non-GBR high load paired in 1subcell based on MCS compensation power limit UE
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach SA UE1 and UE2 in H0V0
# 	Step3:Push full buffer in UL
# 	Step4:Move UE2 to H30V0
# 	Step5:Online modify ulMuMimoSpectralEffThd=2 to trigger SE check
# 	Step6:Online modify ulMuMimoSpectralEffThd back to 0.5
# 	Step7:Override UE1’s PHR trigger UE1 UL power limited
# 	Step8:Override UE2’s PHR trigger UE1 UL power limited
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    22    0    22    0    22    0    1    50000    0    0    0
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	#del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${manualFrameTimingAdjustment}
#     ...       ${lteToNrFrameShift}    ${numberOfTransmittedSsBlocks}
#     ...       ${bwp_profile87}    ${bwp_profile87_p}    ${bwp_profile8}    ${bwp_profile8_p}    ${bwp8_duration1}    ${bwp8_duration3}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${nPdcchCandidatesInAL16}    ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${bwp87_duration1}    ${bwp87_duration3}
#     ...       ${87_nPdcchCandidatesInAL2_2}    ${87_nPdcchCandidatesInAL4_1}    ${87_nPdcchCandidatesInAL4_2}    ${87_nPdcchCandidatesInAL4_3}
#     ...       ${87_nPdcchCandidatesInAL8}    ${87_nPdcchCandidatesInAL16}    ${bwp87_periodicity_1}    ${bwp87_periodicity_3}
#     ...       ${bwp87_duration_dedi}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach SA UE1 and UE2 in H0V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     Wait '5s' for stable running
#    # Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput_UE1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_UE1} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_unpair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Move UE2 to H30V0
#     Start Collect GNB and AP Syslog in 'Step4_UE2_move' File
#     #Start GNB BIP Log
#     Wait Throughput Timer    20        #wait AP profile switch
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_UE2_move${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_UE2_move${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_UE2_move${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_UE2_move
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_UE2_move' File
# 
# Step5:Online modify ulMuMimoSpectralEffThd=2 to trigger SE check
#     Start Collect GNB and AP Syslog in 'Step5_se_higher' File
#     #Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_case105_SE_2.json
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_se_higher${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_se_higher${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_se_higher${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_unpair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step5_se_higher
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_se_higher' File
# 
# Step6:Online modify ulMuMimoSpectralEffThd back to 0.5
#     Start Collect GNB and AP Syslog in 'Step6_se_lower' File
#     #Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_case105_SE_0dot5.json
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_se_lower${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step6_se_lower${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step6_se_lower${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step6_se_lower
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_se_lower' File
# 
# Step7:Override UE1’s PHR trigger UE1 UL power limited
#     Start Collect GNB and AP Syslog in 'Step7_power_limit1' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    ${phr_override_profile_1_CMD}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=phr_override action\=activate profile_id\=1
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_power_limit1${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step7_power_limit1${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step7_power_limit1${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step7_power_limit1
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_power_limit1' File
# 
# 
# Step8:Override UE2’s PHR trigger UE1 UL power limited
#     Start Collect GNB and AP Syslog in 'Step8_power_limit2' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    ${phr_override_profile_1_CMD}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=phr_override action\=activate profile_id\=1
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8_power_limit2${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step8_power_limit2${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step8_power_limit2${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case101_tti_ul_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step8_power_limit2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_power_limit2' File
