# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...               QC case full name:
# ...               CB008360_B_B2a_case_114_case 1 16DL8UL, 2 UE rank1 + rank2 pair
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CIT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library           OperatingSystem
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${linux_cmd1}    vmstat
# ${linux_cmd2}    free -m
# ${linux_cmd3}    mpstat 1 2
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots10|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|1|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|true|//*[@name\="actUlMuMimoTapering"]
# ${actUlPtrs}                          text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}           text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${ulMuMimoCorrThd2}                          text|5|//*[@name\="ulMuMimoCorrThd2"]
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
# CB008360_B_B2a_case_114_case 1 16DL8UL, 2 UE rank1 and rank2 pair
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3UEs, UE1 in H11V6,UE2 in H4V8,UE3 in H20V6
# 	Step3:Push full buffer in UL
#     Step4:Move 3UEs to H0V0
#     Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
# 	Step6:check counter
#     Step7:stability test
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration
#     ...    5    0    0    0    5    0    5    0    0    50000    50000    0    0    0    0    0    0    2    2    2    2
#     Set Pos By Modify L1ByPTestModeConfiguration
#     ...    12    0    0    0    12    0    12    0    1    50000    50000    0    0    0    0    0    0    2    2    2    2
#     Set Pos By Modify L1ByPTestModeConfiguration
#     ...    22    0    0    0    22    0    22    0    2    50000    50000    0    0    0    0    0    0    2    2    2    2
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${ulMuMimoCorrThd2}
#     ...       ${bwp_profile57}    ${bwp_profile57_p}    ${bwp_duration1}    ${bwp_duration3}    ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_3}    ${nPdcchCandidatesInAL4_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:Attach 3UEs, UE1 in H11V6,UE2 in H4V8,UE3 in H20V6
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait '5s' for stable running
# #	Airphone Nsa Attach    ue_id=11    cell_id=1
#     Airphone Execute Egate Command    set_pdu_param ue\=11 pdu\=1 trf_type\=internal
#     Airphone Execute Egate Command    ue_attach id\=11
#     Airphone Execute Egate Command    set_pdu_param ue\=12 pdu\=1 trf_type\=internal
#     Airphone Execute Egate Command    ue_attach id\=12
# 	Wait '10s' for stable running
# 	Airphone Execute Egate Command    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
#     Airphone Execute Egate Command    ue_dc_enb_start ue\=12 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# 	Wait '10s' for stable running
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
# 	Airphone Nsa Start Data Traffic    11    UL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    11    UL    150M    trf_id=2    duration=${3600}
#     Airphone Nsa Start Data Traffic    12    UL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    12    UL    150M    trf_id=2    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${nsa_ul_tput1}=    Airphone NSA Get Throughput        11     UL
#     ${nsa_ul_tput2}=    Airphone NSA Get Throughput        12     UL
#     ${output1}    Run    ${linux_cmd1}
# 	Log    ${output1}
# 	${output2}    Run    ${linux_cmd2}
# 	Log    ${output2}
# 	${output3}    Run    ${linux_cmd3}
# 	Log    ${output3}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Move 3UEs to H0V0
#     Start Collect GNB and AP Syslog in 'Step4_3ues_move_unpair' File
#     #Start GNB BIP Log
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_se_higher${/}
#     Wait Throughput Timer    20
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}tti_unpair
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_unpaired.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_3ues_move_unpair' File
# 
# Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
#     Start Collect GNB and AP Syslog in 'Step5_3ues_move_pair' File
#     #Start GNB BIP Log
#     Wait Throughput Timer    60
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     Wait Throughput Timer    30
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_3ues_move_pair' File
# 
# Step6:check counter
#     Start Collect GNB and AP Syslog in 'Step6_check_counter' File
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step6_check_counter/
#     ${PRB_UL_SU_MIMO_1LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35001    cell_id=1
#     ${PRB_UL_SU_MIMO_2LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35002    cell_id=1
#     ${PRB_UL_MU_MIMO_2LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1
#     ${PRB_UL_MU_MIMO_3LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35004    cell_id=1
#     ${PRB_UL_MU_MIMO_4LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35005    cell_id=1
#     ${PRB_UL_MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35006    cell_id=1
#     ${PRB_UL_MU_MIMO_2PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1
#     ${PRB_UL_MU_MIMO_3PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
#     ${PRB_UL_MU_MIMO_4PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
#     ${TOT_MU_MIMO_PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35010    cell_id=1
#     ${TOT_MU_MIMO_ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35011    cell_id=1
#     #${PRB_UL_MU_MIMO_3L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD351    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD352    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S4L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD353    cell_id=1
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_1LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_2LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4LAYERP} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_NOPAIR_UE}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2PAIR_UE}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3PAIR_UE} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4PAIR_UE}==0
#     run keyword and continue on failure    should be true    ${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH} >0.9
# #    should be true    ${PRB_UL_MU_MIMO_3L_S2L_MUREC}==213
# #    should be true    ${PRB_UL_MU_MIMO_4L_S2L_MUREC}==213
# #    should be true    ${PRB_UL_MU_MIMO_4L_S4L_MUREC}==213   
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_check_counter' File
#    
# Step7:stability test
#     #Start Collect GNB and AP Syslog in 'Step7_stability test' File
#     #Start GNB BIP Log
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     Wait Throughput Timer    1800
# 	${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${nsa_ul_tput1}=    Airphone NSA Get Throughput        11     UL
#     ${nsa_ul_tput2}=    Airphone NSA Get Throughput        12     UL
# 	should be true    ${Ul_throughput_ue1} >0
# 	should be true    ${nsa_ul_tput1} >0
# 	should be true    ${nsa_ul_tput2} >0
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step7_stability test${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step7_stability test${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step7_stability test${/}
#     #[Teardown]    Stop Collect GNB and AP Syslog in 'Step7_stability test' File
# 
