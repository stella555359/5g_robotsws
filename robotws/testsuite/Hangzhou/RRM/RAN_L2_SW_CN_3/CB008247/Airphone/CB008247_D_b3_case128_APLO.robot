# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_D_b3_Case 128_Coexistence with multiple BWP_reuse_t2r4_TAS_CL_MIMO_8X4_CellCSIRS
# ...
# ...               When CB008247 is activated and UE is configured with 2 BWPs (5GC000937 is activated), TAS SRS is only configured in larger BWP.
# ...               SRS based beamforming is only applied in larger BWP. When UE is switched to smaller BWP (power saving BWP), 
# ...               the legacy beamforming is applied.
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
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${nrarfcn}                                      text|632000|//*[@name\="nrarfcn"]
# ${gscnOrSsPbchArfcn}                            text|7832|//*[@name\="gscnOrSsPbchArfcn"]
# ${msg1FrequencyStart}                            text|14|//*[@name\="msg1FrequencyStart"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|0|//*[@name\="bSRS"]
# ${actUeCsirsCoexistCellCsirs}                   text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks_0}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-0')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${numberOfTransmittedSsBlocks_1}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-1')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${lowerEdgeAngle}                               text|120|//*[@name\="lowerEdgeAngle"]
# ${upperEdgeAngle}                               text|60|//*[@name\="upperEdgeAngle"]
# ${actCsirsMultiplexing}                         text|true|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|2|//*[@name\="maxCsirsNumber"]
# ${ssPbchBlockPower}                             text|3|//*[@name\="ssPbchBlockPower"]
# ${actPowerSavingBWP}                             text|true|//*[@name\="actPowerSavingBWP"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008247_D_b3_case128_Coexistence with multiple BWP_reuse_t2r4_TAS_CL_MIMO_8X4_CellCSIRS
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach a UE with TAS SRS and powerSaving capability
#     Step3:Start Big DL Data Transfer and Check Switch To Large BWP
#     Step4:Stop Data Traffic And Check Switch To Power Saving BWP
#     Step5:ReStart Big DL Data Transfer and Check Switch To Large BWP
#     Step6:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    3    10    12    12
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     add_bwplist_list_in_cells    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}
#     ...       ${chBw}
#     ...       ${nrarfcn}
#     ...       ${gscnOrSsPbchArfcn}
#     ...       ${msg1FrequencyStart}
#     ...       ${dlMimoMode}
#     ...       ${nrCellType}
#     ...       ${actDlSrsBm}
#     ...       ${actUlSrsBm}
#     ...       ${pucchModeSelect}
#     ...       ${actCDrx}
#     ...       ${actFdmScheduling}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${ulDlDataSlotRatio}
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
#     ...       ${actPowerSavingBWP}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach a UE with TAS SRS and powerSaving capability
#     Start Collect GNB and AP Syslog in 'Step2_attach_UE' File
#     Start GNB BIP Log
# 	Airphone Set Traffic Type    1    1    internal
#     ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
# 	...     pass_regexp=Bwp Switched from bwpId 1 to 2
# 	#Decrease PUCCH power and DL NACK
#     #Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 sinr_target_pucch\=-280 noise_pucch\=-1053
#     #Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_UE${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_UE' File
# 
# Step3:Start Big DL Data Transfer and Check Switch To Large BWP
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# 	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     Airphone SA Start Data Traffic    1    DL    75M    trf_id=1    pdu_id=1    duration=${3600}
# 	Wait Throughput Timer    3
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}check_patttern_id${/}tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R2'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case128_tti_dl_patternid_dedicate_bwp_APLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}check_patttern_id
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Stop Data Traffic And Check Switch To Power Saving BWP
#     Start Collect GNB and AP Syslog in 'Step4_stop_data' File
#     Start GNB BIP Log
#     Airphone Sa Stop Data Traffic    ue_id=1    direction=dl    pdu_id=1    qfi_id=1
#     Wait Throughput Timer    3
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}check_patttern_id${/}tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case128_tti_dl_patternid_Powersaving_bwp.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_stop_data${/}check_patttern_id
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_stop_data' File
# 
# Step5:ReStart Big DL Data Transfer and Check Switch To Large BWP
#     Start Collect GNB and AP Syslog in 'Step5_inject_buffer' File
#     Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    DL    50M    trf_id=1    pdu_id=1    duration=${3600}
# 	Wait Throughput Timer    3
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id${/}tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case128_tti_dl_patternid_dedicate_bwp_APLO.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}check_patttern_id
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}   unzip=TRUE
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case128_bwp_switch.ini    log_need_to_check=u
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_inject_buffer${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_inject_buffer' File
# 
# Step6:Detach UE
#     Start Collect GNB and AP Syslog in 'Step6_detach_UE' File
#     Start GNB BIP Log
# 	Airphone Sa Detach    ue_id=1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_detach_UE${/}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_detach_UE' File
