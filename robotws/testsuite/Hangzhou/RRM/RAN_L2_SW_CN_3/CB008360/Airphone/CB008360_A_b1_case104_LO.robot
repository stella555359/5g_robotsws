# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B1c_case_104_2 Rank1 UEs blindly paired in one subcells based on MCS compensate...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS22R4    RAN_5G_TDD    RAN_5G    owner_lily
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_A.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${UE_NUM}         100
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# #${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|100|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# #1070
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots10|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|12|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# ${actUlPtrs}                          text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${bwp_profile61}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-61')|//managedObject
# ${bwp_profile61_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-61')|//p
# ${bwp_profile6}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//managedObject
# ${bwp_profile6_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//p
# ${bwp_duration1}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-61/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${bwp_periodicity_1}    text|sl5|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl5|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='periodicity']
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-61/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${pattern}    t2r4_n2_pusch_1layer
# 
# 
# *** Test Cases ***
# CB008360_A_B1c_case_104_2 Rank1 UEs blindly paired in one subcells based on MCS compensate
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Step3:Push full buffer in UL
# 	Step4:Enalbe CNI-104041
# 	Step5:Re-attach and send buffer
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# #    modify_iphy    ${CONFIG_DIR_PATH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${bwp_profile61}    ${bwp_profile61_p}    ${bwp_profile6}    ${bwp_profile6_p}    ${bwp_duration1}    ${bwp_duration3}
#     ...       ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL2_2}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
#     ...       ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}     ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${nPdcchCandidatesInAL4_2}
#     ...       ${actUlMuMimoTapering}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     Stop Collect GNB and AP Syslog in 'Step1' File
#     unzip_file    ${TEST_LOG_DIRECTORY()}Step1${/}Step1_ap.tar.gz    ${TEST_LOG_DIRECTORY()}Step1
#     ${oam_enable}=    check_specific_word_in_btslog
#     ...    ${TEST_LOG_DIRECTORY()}Step1${/}Step1_ap${/}Step1_ap${/}*ap*    "puschBeamFormingEnabled": false
#     ${l1_enable}=    check_specific_word_in_btslog
#     ...    ${TEST_LOG_DIRECTORY()}Step1${/}Step1_ap${/}Step1_ap${/}*ap*    isPuschBeamFormingEnabled 0
#     should be true    ${oam_enable}
#     should be true    ${l1_enable}
# 
# Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# #    start collect sosReport
#     Attach SA ue with capability to 5g cell    2    t2r4_n2_pusch_1layer
# 	set pos for 2ue
#     Wait Throughput Timer    3
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# #    stop collect sosReport
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     send ul data
#     Wait Throughput Timer    3
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch    current
#     should be true    ${ue1_ul_tput} > 90000
#     should be true    ${ue2_ul_tput} > 90000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case104_tti_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     run keyword and continue on failure    Detach '2'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Enalbe CNI-104041
#     Start Collect GNB and AP Syslog in 'Step4' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     modify_iphy    ${CONFIG_DIR_PATH}
#     do reset
#     Stop Collect GNB and AP Syslog in 'Step4' File
#     unzip_file    ${TEST_LOG_DIRECTORY()}Step4${/}Step4_ap.tar.gz    ${TEST_LOG_DIRECTORY()}Step4
#     ${oam_enable}=    check_specific_word_in_btslog
#     ...    ${TEST_LOG_DIRECTORY()}Step4${/}Step4_ap${/}Step4_ap${/}*ap*    "puschBeamFormingEnabled": true
#     ${l1_enable}=    check_specific_word_in_btslog
#     ...    ${TEST_LOG_DIRECTORY()}Step4${/}Step4_ap${/}Step4_ap${/}*ap*    isPuschBeamFormingEnabled 1
#     should be true    ${oam_enable}
#     should be true    ${l1_enable}
# 
# Step5:Re-attach and send buffer
#     Start capture gnb and ap syslog in 'Step5' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     Attach SA ue with capability to 5g cell    2    t2r4_n2_pusch_1layer
# 	set pos for 2ue
#     set pusch tx power
# 	Wait Throughput Timer    1
# 	send ul data
# 	Wait Throughput Timer    3
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch    current
#     should be true    ${ue1_ul_tput} > 90000
#     should be true    ${ue2_ul_tput} > 90000
# #    Start GNB BIP Log
# #    Wait Throughput Timer    3
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case104_tti_pair.ini
#     ...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop capture gnb and ap syslog in 'Step5' file
# 
# set pos for 2ue
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 
# send ul data
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    70M    trf_id=2    pdu_id=1    duration=${3600}
# 
# do reset
#       Reset Testline
#       Wait Until Keyword Succeeds    300    15    Verify BTS Is Onair
#       _wait_until_sib1_received_for_all_cells    timeout=180
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     remove_xml_element     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}     ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    //refinedBeams
#     add_xml_element
# 	...   ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml  <ulFeatures>puschBeamForming</ulFeatures>|//vcell
#     add_xml_element
# 	...   ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml     ${TEST_LOG_DIRECTORY()}${/}iphy_mod3.xml  <refinedBeams>true</refinedBeams>|//vcell
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod3.xml
# 
# set pusch tx power
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pusch_tx_power\=-500 pathloss\=28
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=1 action\=activate
