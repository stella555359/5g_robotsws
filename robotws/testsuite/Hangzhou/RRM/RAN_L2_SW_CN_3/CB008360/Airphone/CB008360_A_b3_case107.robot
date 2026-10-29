# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B3a_case_107_2UEs (rank1) with non-GBR high load paired in 1subcell based on MU-SINR estimation NSA+SA mode
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
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
# @{LOG_NAME_LIST}    egatelog\
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
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
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
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
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
# *** Test Cases ***
# CB008360_A_B3a_case_107_2UEs_rank1_with non-GBR high load paired in 1subcell based on MU-SINR estimation NSA+SA mode
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach SA UE1 in H0V0,attach NSA UE11 in H30V0
# 	Step3:Push full buffer in UL
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    22    0    22    0    22    0    22    0    1
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${bwp_profile57}    ${bwp_profile57_p}    ${bwp_duration1}    ${bwp_duration3}    ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_3}    ${nPdcchCandidatesInAL4_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach SA UE1 in H0V0,attach NSA UE11 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait '5s' for stable running
# #	Airphone Nsa Attach    ue_id=11    cell_id=1
#     Airphone Execute Egate Command    set_pdu_param ue\=11 pdu\=1 trf_type\=internal
#     Airphone Execute Egate Command    ue_attach id\=11
# 	Wait '10s' for stable running
#     Airphone Execute Egate Command    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# 	Wait '10s' for stable running
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Wait Throughput Timer    60
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# 	Airphone Nsa Start Data Traffic    11    UL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    11    UL    150M    trf_id=2    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Wait Throughput Timer    60
#     ${Ul_throughput_UE1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${nsa_ul_tput}=    Airphone NSA Get Throughput        11     UL
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case107_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#  
#    	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
# 	${cell_tput_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55309C12002    cell_id=1
# 	${result}=    evaluate    ${cell_tput_value}*8/1024/1024	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
