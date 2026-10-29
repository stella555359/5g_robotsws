# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b2_case114_Best beam with cell specific CSI-RS_8x4 CL-MIMO_Rank4_t2r4_TAS_maxCsirsNumber=4_No_Free_Periodic SRS
# ...
# ...               In case of cell specific CSI-RS, cell shall determine the best beams for PDCCH and PDSCH.
# ...               The best beams are selected from the predefined oversample DFT beams via the correlation with SRS measurement.
# ...               If SRS resource is exhausted, for other newly added UE,
# ...               codebook based BF will be configured with cell specific CSI-RS or UE specific CSI-RS.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
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
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535))
# ${FILTER2}    ((dldata_pdschsendreq) && !(3gpp.rnti == 65535))
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{titles1}    3gpp.rnti    DlData_DciInfo.patternId_item
# @{titles2}    3gpp.rnti    DlData_PdschGrant.patternId_item
# @{titles3}    DlData_CsiRsResource_t.patternId_item
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|60MHz|//*[@name\="chBw"]
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
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|0|//*[@name\="bSRS"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks_0}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-0')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${numberOfTransmittedSsBlocks_1}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-1')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${lowerEdgeAngle}                               text|120|//*[@name\="lowerEdgeAngle"]
# ${upperEdgeAngle}                               text|60|//*[@name\="upperEdgeAngle"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# ${ssPbchBlockPower}                             text|3|//*[@name\="ssPbchBlockPower"]
# ${bwp_profile75}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-73')|//managedObject
# ${bwp_profile75_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-73')|//p
# ${bwp_profile7}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//managedObject
# ${bwp_profile7_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//p
# ${bwp_duration1}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-73/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-73/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='periodicity']
# ${slotOffset_1}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='slotOffset']
# ${slotOffset_2}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='slotOffset']
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008247_B_b2_case114_Best beam with cell specific CSI-RS_8x4 CL-MIMO_Rank4_t2r4_TAS_maxCsirsNumber=4_No_Free_Periodic SRS
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1-5 to exhaust periodic TAS SRS
#     Step3:Attach UE6 to exhaust periodic codebook SRS
#     Step4:Attach UE7 using aperiodic codebook SRS
#     Step5:Start UL DL data traffic
#     Step6:Release UE1
#     Step7:Attach UE8 using periodic TAS SRS
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    1    1    12    12
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}
#     ...       ${chBw}
#     ...       ${dlMimoMode}
#     ...       ${nrCellType}
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
#     ...       ${lowerEdgeAngle}
#     ...       ${upperEdgeAngle}
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
#     ...       ${slotOffset_1}
#     ...       ${slotOffset_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1-5 to exhaust periodic TAS SRS
#     Start Collect GNB and AP Syslog in 'Step2_attach_UE1_5' File
#     Start GNB BIP Log
# 	: FOR    ${num}    IN RANGE    1    6
# 	\   Airphone Set Traffic Type    ${num}    1    internal
# 	\   ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
# 	\   Airphone SA Attach    ue_id=${num}    ue_capability=${TAS_t2r4_n2}
# 	\   Airphone Pdu Session Setup    ue_id=${num}    pdu_id=1    nwslice_id=1    gw_id=${num}
#     \   Wait Throughput Timer    15
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE1_5${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE1_5' File
# 
# Step3:Attach UE6 to exhaust periodic codebook SRS
#     Start Collect GNB and AP Syslog in 'Step3_attach_UE6' File
#     Start GNB BIP Log
#     Airphone Set Traffic Type    6    1    internal
# 	${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=6    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=6    pdu_id=1    nwslice_id=1    gw_id=6
#     Wait Throughput Timer    15
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_attach_UE6${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_attach_UE6' File
# 
# Step4:Attach UE7 using aperiodic codebook SRS
#     Start Collect GNB and AP Syslog in 'Step4_attach_UE7' File
#     Start GNB BIP Log
#     Airphone Set Traffic Type    7    1    internal
# 	${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=7    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=7    pdu_id=1    nwslice_id=1    gw_id=7
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_attach_UE7${/}
#     Wait Throughput Timer    15
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4_attach_UE7${/}   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step4_attach_UE7${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_list[5]}
# 	Set test Variable	 ${rnti_7} 	${rnti_list[6]}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_SRS_exhausted.ini    log_need_to_check=p
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_attach_UE7${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_attach_UE7' File
# 
# Step5:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step5_inject_buffer' File
# #    Start GNB BIP Log
# 	: FOR    ${num}    IN RANGE    1    8
# 	\   Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
#     \   Airphone Execute Egate Command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1
#     Airphone SA Start Data Traffic    1...7    DL    75M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1...7    UL    75M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
# #	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}tcpdump_L2L1_bip_filtering_off.pcap4    
# #	...    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}/bip_pdcch.csv    ${FILTER1}    ${titles1}
# #    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}tcpdump_L2L1_bip_filtering_off.pcap4    
# #	...    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}/bip_pdsch.csv    ${FILTER2}    ${titles2}
# #    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}tcpdump_L2L1_bip_filtering_off.pcap4    
# #	...    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}/bip_csirs.csv    ${FILTER3}    ${titles3}
# #    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/case114_bip_pdcch_patternid.ini     log_need_to_check=i
# #    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
# #    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/case114_bip_pdsch_patternid.ini     log_need_to_check=i
# #    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
# #    Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/case114_bip_csirs_patternid.ini     log_need_to_check=i
# #    ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id${/}tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R2'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_dl_patternid_APLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_tti_ul_patternid_APLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_inject_buffer' File
# 
# Step6:Release UE1
#     Start Collect GNB and AP Syslog in 'Step6_detach_UE1' File
#     Start GNB BIP Log
# 	Airphone Sa Detach    ue_id=1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_detach_UE1${/}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_detach_UE1' File
# 
# Step7:Attach UE8 using periodic TAS SRS
#     Airphone Cleanup Egate Console Log
#     Start Collect GNB and AP Syslog in 'Step7_attach_UE8' File
#     Start GNB BIP Log
# 	Airphone Set Traffic Type    8    1    internal
# 	${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=8    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=8    pdu_id=1    nwslice_id=1    gw_id=8
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_attach_UE8${/}
# 	Wait Throughput Timer    15
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7_attach_UE8${/}   unzip=TRUE
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case114_UE8_TAS_SRS.ini    log_need_to_check=p
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step7_attach_UE8${/}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step7_attach_UE8' File
