# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b2_case105_Best beam with cell specific CSI-RS_8x4 CL-MIMO_Rank1_t2r4_TAS_maxCsirsNumber=4
# ...
# ...               In case of cell specific CSI-RS, cell shall determine the best beams for PDCCH and PDSCH.
# ...               The best beams are selected from the predefined oversample DFT beams via the correlation with SRS measurement.
# ...               the case using 0x580265=0 to restrict UE specific CSI-RS
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...    owner_xueminm
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|49|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks_0}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-0')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${numberOfTransmittedSsBlocks_1}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-1')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# ${ssPbchBlockPower}                             text|3|//*[@name\="ssPbchBlockPower"]
# ${bwp_profile75}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-75')|//managedObject
# ${bwp_profile75_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-75')|//p
# ${bwp_profile7}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//managedObject
# ${bwp_profile7_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//p
# ${bwp_duration1}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}    
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='periodicity']
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008247_B_b2_case105_Best beam with cell specific CSI-RS_8x4 CL-MIMO_Rank1_t2r4_TAS_maxCsirsNumber=4
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1 with TAS_t2r4_n2 capability
#     Step3:Start UL DL data traffic
#     Step4:Override CSI and check pattern id
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Modify L1ByPTestModeConfiguration    5    8    15    7
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">-6</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}
#     ...       ${actDlSrsBm}
#     ...       ${actUlSrsBm}
#     ...       ${pucchModeSelect}
#     ...       ${actCDrx}
#     ...       ${actFdmScheduling}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${lteToNrFrameShift}
#     ...       ${prachConfigurationIndex}
#     ...       ${ssBurstSetPeriod}
#     ...       ${srsUePeriodicity}
#     ...       ${cSRS}
#     ...       ${bSRS}
#     ...       ${actDl256Qam}
#     ...       ${actBeamforming}
#     ...       ${numberOfRxBeamforming}
#     ...       ${numberOfTransmittedSsBlocks_0}
#     ...       ${numberOfTransmittedSsBlocks_1}
#     ...       ${basicBeamSet}
#     ...       ${actCsirsMultiplexing}
#     ...       ${nrBtsBeamRefinementP2}
#     ...       ${csiReportPeriodicity}
#     ...       ${csirsNumberWithinReportPeriod_Set1}
#     ...       ${csirsPower}
#     ...       ${maxCsirsNumber}
#     ...       ${ssPbchBlockPower}
#     ...       ${bwp_profile75}
#     ...       ${bwp_profile75_p}
#     ...       ${bwp_profile7}
#     ...       ${bwp_profile7_p}
#     ...       ${bwp_duration1}
#     ...       ${bwp_duration3}
#     ...       ${bwp_duration_dedi}
#     ...       ${nPdcchCandidatesInAL16}
#     ...       ${nPdcchCandidatesInAL2_2}
#     ...       ${nPdcchCandidatesInAL4_1}
#     ...       ${nPdcchCandidatesInAL4_3}
#     ...       ${nPdcchCandidatesInAL8}
#     ...       ${nPdcchCandidatesInAL4_2}
#     ...       ${bwp_periodicity_1}
#     ...       ${bwp_periodicity_3}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    
#    ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1 with TAS_t2r4_n2 capability
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Airphone Set Traffic Type    1    1    internal
#     ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/TAS_t2r4_n2_srs_usage.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     should be true    ${Ul_throughput} > 95000
#     should be true    ${Dl_throughput} > 95000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Override CSI and check pattern id
#     Start Collect GNB and AP Syslog in 'Step4_Override_csi' File
#     Start GNB BIP Log
#     Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     Wait Throughput Timer    8
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_Override_csi${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_Override_csi${/}check_patttern_id${/}tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case105_tti_dl_patternid.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_Override_csi${/}check_patttern_id
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case105_tti_ul_patternid.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_Override_csi${/}check_patttern_id
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_Override_csi${/}
#     Wait Throughput Timer    8
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_Override_csi' File
