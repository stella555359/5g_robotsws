# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CNI-110347_08_with_support_both_Cell_Specific_and_UE_Specific_CSI-RS
#             
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
# ...    owner_zhaoxu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library          ${CURDIR}/log_check/Check_CNI110347_function.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CNI110347.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CNI110347.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CNI110347.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
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
# ${srsUePeriodicity}                             text|slots20|//*[@name\="srsUePeriodicity"]
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
# ${actCsirsMultiplexing}                         text|true|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# ${ssPbchBlockPower}                             text|3|//*[@name\="ssPbchBlockPower"]
# 
# #CNI-110347_Bell_Canada
# ${MCC}                                          text|302|//*[@name\="mcc"]
# ${MNC}                                          text|610|//*[@name\="mnc"]
# ${actCaWimaxInterferenceAvoidance}              text|true|//*[@name\="actCaWimaxInterferenceAvoidance"]
# ${actUeCsirsCoexistCellCsirs}                   text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# 
# ${pattern}    CA_P2_8x4_noTas_n2
# 
# *** Test Cases ***
# CNI-110347_08_with_support_both_Cell_Specific_and_UE_Specific_CSI-RS
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1 without TAS SRS capability with Codebook SRS capability
#     Step3:Start UL DL data traffic
# 	Step4:Check CNI110347 function in TTItrace
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
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
#     ...       ${csiReportPeriodicity}
#     ...       ${csirsNumberWithinReportPeriod_Set1}
#     ...       ${csirsPower}
#     ...       ${maxCsirsNumber}
#     ...       ${ssPbchBlockPower}
# 	...       ${MCC}
# 	...       ${MNC}
# 	...       ${actCaWimaxInterferenceAvoidance}
# 	...       ${actUeCsirsCoexistCellCsirs}
# 	
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1 without TAS SRS capability with Codebook SRS capability
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Airphone Set Traffic Type    1    1    internal
# 	${No_TAS}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${No_TAS}
#     Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}	
#     Wait Throughput Timer    5
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    10
#     #Start GNB BIP Log	
#     #Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Check CNI110347 function in TTItrace
# 	#DL slot6,7,16,17 no data used in PDSCH 
# 	#DL slot5,15 have data used in PDSCH
# 	#UL slot8,9 and 18 have data used in PUSCH
#     ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_dl.csv
# 	${ul_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_ul.csv  
# 	${CNI110347_DL_check_point}    Check_Slot6_7_And_Slot16_17_PDSCH_no_used_data    ${dl_ttitrace_path}
# 	${CNI110347_UL_check_point}    Check_Slot8_9_And_Slot18_PUSCH_Used_data    ${ul_ttitrace_path}	
# 	log    ${CNI110347_DL_check_point}
# 	log    ${CNI110347_UL_check_point}
# 	run keyword and continue on failure    should_be_true    ${CNI110347_DL_check_point}
# 	run keyword and continue on failure    should_be_true    ${CNI110347_UL_check_point}
