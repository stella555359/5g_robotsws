# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_B_B6a_case_132_case 7 5UE rank1 16DL8UL online change ulMaxMuMimoLayer 234
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CIT    SBTS00    RAN_5G_TDD    RAN_5G    owner_lilyu    SBTS23R1
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          8360_112_8d8u.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|80|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoCorrThd2}                             text|80|//*[@name\="ulMuMimoCorrThd2"]
# ${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${bwp_profile57}              attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//managedObject
# ${bwp_profile57_p}            text|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//p
# ${bwp_duration1}              text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='duration']
# ${bwp_duration3}              text|3|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}          text|1|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-5')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_periodicity_1}          text|sl5|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}          text|sl5|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='periodicity']
# ${slotOffset_1}    text|0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[1]/*[@name\='slotOffset']
# ${slotOffset_3}    text|0|//*[contains(@distName, 'BWP_PROFILE-5')]//item[3]/*[@name\='slotOffset']
# 
# ${pattern}    t2r4_n2_pusch_1layer
# 
# *** Test Cases ***
# CB008360_B_B6a_case_132_case 7 5UE rank1 16DL8UL online change ulMaxMuMimoLayer 234
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 5UES, UE1 in H12V0,UE2 in H6V0,UE3 in H0V0,UE4 in H19V0,UE5 in H13V0
#     Step3:Push full buffer in UL
#     Step4:Online modify ulMaxMuMimoLayer to 3
#     Step5:Online modify ulMaxMuMimoLayer to 4
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${ulDMRSAdditionalPosition}     
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}    ${actUlMuMimoTapering}    ${tiltOffset}  
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${actUlPtrs}    ${ulMuMimoCorrThd2}    
#     ...       ${bwp_profile57}    ${bwp_profile57_p}    ${bwp_duration1}    ${bwp_duration3}    ${bwp_duration_dedi}    ${nPdcchCandidatesInAL16}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_3}    ${nPdcchCandidatesInAL4_2}
#     ...       ${ulSinrDiffThreshold}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 5UES, UE1 in H12V0,UE2 in H6V0,UE3 in H0V0,UE4 in H19V0,UE5 in H13V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    5    t2r4_n2_pusch_1layer
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=10    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=1    sub=2    step=10    scell=0
#     ul_mimo_srs_beam_pos_active    ue=3    profile=3    init=2    sub=3    step=10    scell=0
#     ul_mimo_srs_beam_pos_active    ue=4    profile=4    init=3    sub=1    step=10    scell=0
#     ul_mimo_srs_beam_pos_active    ue=5    profile=5    init=3    sub=3    step=10    scell=0
# 
#     Wait Throughput Timer    5
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}       ${rnti_list[0]}
#     Set test Variable     ${rnti_2}       ${rnti_list[1]}
#     Set test Variable     ${rnti_3}       ${rnti_list[2]}
#     Set test Variable     ${rnti_4}       ${rnti_list[3]}
#     Set test Variable     ${rnti_5}       ${rnti_list[4]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    4    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    4    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    5    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    5    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     ${Ul_throughput_ue5} =    Airphone Sa Get Throughput    ue_id=5    direction=ul
# #    Wait Throughput Timer    180
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer/
#     ${PRB_UL_SU_MIMO_1LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35001    cell_id=1
#     ${PRB_UL_SU_MIMO_2LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35002    cell_id=1
#     ${PRB_UL_MU_MIMO_2LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1
#     ${PRB_UL_MU_MIMO_3LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35004    cell_id=1
#     ${PRB_UL_MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35006    cell_id=1
#     ${PRB_UL_MU_MIMO_2PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1
#     ${PRB_UL_MU_MIMO_3PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
#     ${PRB_UL_MU_MIMO_4PAIR_UE} =    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
#     ${TOT_MU_MIMO_PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35010    cell_id=1
#     ${TOT_MU_MIMO_ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35011    cell_id=1
#     #${PRB_UL_MU_MIMO_3L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD351    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD352    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S4L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD353    cell_id=1
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_1LAYERP} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_2LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2LAYERP} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_NOPAIR_UE} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2PAIR_UE} > 0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3PAIR_UE}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4PAIR_UE}==0
#     run keyword and continue on failure    should be true    ${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH} >0.75
#     #should be true    ${PRB_UL_MU_MIMO_3L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S4L_MUREC}==213
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case132_tti_pair_2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Online modify ulMaxMuMimoLayer to 3
#     Start Collect GNB and AP Syslog in 'Step4_ulMaxMuMimoLayer_3' File
#     #Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_ulMaxMuMimoLayer_3.json
#     Wait Throughput Timer    5
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_ulMaxMuMimoLayer_3${/}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_higher_ulMuMimoSinrThd${/}
# 
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     ${Ul_throughput_ue5} =    Airphone Sa Get Throughput    ue_id=5    direction=ul
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4_ulMaxMuMimoLayer_3/
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
# #    run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_1LAYERP} <2000
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_2LAYERP}==0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2LAYERP} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3LAYERP} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4LAYERP}==0
# #    run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_NOPAIR_UE} <2000
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_2PAIR_UE} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_3PAIR_UE} >0
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4PAIR_UE}==0
#     run keyword and continue on failure    should be true    ${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH} >0.9
#     #should be true    ${PRB_UL_MU_MIMO_3L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S4L_MUREC}==213
# 
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_ulMaxMuMimoLayer_3${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case132_tti_pair_3_FS.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_ulMaxMuMimoLayer_3
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_ulMaxMuMimoLayer_3' File
# 
# Step5:Online modify ulMaxMuMimoLayer to 4
#     Start Collect GNB and AP Syslog in 'Step5_ulMaxMuMimoLayer_4' File
#     #Start GNB BIP Log
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_ulMaxMuMimoLayer_4.json
#     Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     ${Ul_throughput_ue5} =    Airphone Sa Get Throughput    ue_id=5    direction=ul
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_ulMaxMuMimoLayer_4${/}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_ulMaxMuMimoLayer_4${/}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# #    Wait Throughput Timer    180
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_ulMaxMuMimoLayer_4/
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
# #    run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_1LAYERP} >0
#     run keyword and continue on failure    should be true    (${PRB_UL_SU_MIMO_1LAYERP}/${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.35
#     run keyword and continue on failure    should be true    ${PRB_UL_SU_MIMO_2LAYERP}==0
#     run keyword and continue on failure    should be true    (${PRB_UL_MU_MIMO_2LAYERP}/${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.05
#     run keyword and continue on failure    should be true    (${PRB_UL_MU_MIMO_3LAYERP}/${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.05
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4LAYERP} > 10000
#     run keyword and continue on failure    should be true    (${PRB_UL_MU_MIMO_NOPAIR_UE} /${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.35
#     run keyword and continue on failure    should be true    (${PRB_UL_MU_MIMO_2PAIR_UE}/${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.05
#     run keyword and continue on failure    should be true    (${PRB_UL_MU_MIMO_3PAIR_UE}/${PRB_UL_MU_MIMO_4PAIR_UE}) < 0.05
#     run keyword and continue on failure    should be true    ${PRB_UL_MU_MIMO_4PAIR_UE} > 10000
#     run keyword and continue on failure    should be true    (${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH}) >0.75
#     #should be true    ${PRB_UL_MU_MIMO_3L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S2L_MUREC}==213
#     #should be true    ${PRB_UL_MU_MIMO_4L_S4L_MUREC}==213
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_ulMaxMuMimoLayer_4${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case132_tti_pair_4_FS.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step5_ulMaxMuMimoLayer_4
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_ulMaxMuMimoLayer_4' File
