# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B3a_case_108_2UEs (rank1) with non-GBR high load paired in 1subcell based on MU-SINR estimation with
# ...               fix SINR change Correlation and SE
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
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|10|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${lteToNrFrameShift}        text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}        text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}    text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|49|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# 
# ${bwp_profile77}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-77')|//managedObject
# ${bwp_profile77_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-77')|//p
# ${bwp_profile7}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//managedObject
# ${bwp_profile7_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//p
# ${bwp_duration1}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='periodicity']
# ${slotOffset_1}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='slotOffset']
# ${slotOffset_2}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='slotOffset']
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008360_A_B3a_case_108_2UEs_rank1_with non-GBR high load paired in 1subcell based on MU-SINR estimation with fix SINR change Correlation and SE
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1 in H0V0,UE2 in H30V0
# 	Step3:Push full buffer in UL
# 	Step4:Online modify ulMuMimoCorrThd=0.01
# 	Step5:Online modify ulMuMimoCorrThd=0.05
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
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}
#     ...       ${ulDlDataSlotRatio}   ${prachConfigurationIndex}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}
#     ...       ${bwp_profile77}    ${bwp_profile77_p}    ${bwp_profile7}    ${bwp_profile7_p}    ${bwp_duration1}    ${bwp_duration3}
#     ...       ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL2_2}
#     ...       ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}     ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_2}    ${nPdcchCandidatesInAL4_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
# 	: FOR    ${num}    IN RANGE    1    3
# 	\   Airphone Set Traffic Type    ${num}    1    internal
# 	\   ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
# 	\   Airphone SA Attach    ue_id=${num}    ue_capability=${TAS_t2r4_n2}
# 	\   Airphone Pdu Session Setup    ue_id=${num}    pdu_id=1    nwslice_id=1    gw_id=${num}
#     \   Wait Throughput Timer    15
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    100M    trf_id=3    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    100M    trf_id=3    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case108_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Online modify ulMuMimoCorrThd=0.01
#     Start Collect GNB and AP Syslog in 'Step4_mod_corr' File
#     Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_case108_Corr_0dot01.json
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_mod_corr${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_mod_corr${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_mod_corr${/}tti_corr_lower
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case108_tti_badCorr.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_mod_corr${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_mod_corr' File
# 
# Step5:Online modify ulMuMimoCorrThd=0.05
#     Start Collect GNB and AP Syslog in 'Step5_corr_higher' File
#     Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_case108_Corr_0dot05.json
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_corr_higher${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_corr_higher${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_corr_higher${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case108_tti_paired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_corr_higher${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
# 
#    	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_corr_higher${/}
# 	${cell_tput_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55309C12002    cell_id=1
# 	${result}=    evaluate    ${cell_tput_value}*8/1024/1024
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_corr_higher' File
