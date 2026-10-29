# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case148_D_A_7a_intraL2RT_intraBand_Intra_gNB_Intra_frequency_handover_for_blind_SCell_addition_NSA
# ...               gnb cell config
# ...               Inter L2RT intra band CA Cell2&Cell3
# ...               Inter L2RT inter band CA Cell4&Cell1
# ...               Intra L2RT intra band CA Cell1&Cell2
# ...               Intra L2RT inter band CA Cell3&Cell4
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    Owner_xueminm
# #...    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${A3_cmd}         ue_measurement_send_nr id=11 meas_id=1 event=A3  srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=50 nrsrq_nr=50
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Nsa|//list[@name\="carrierAggregationSupportList"]/p
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellChannelEstimationPeriod}                 text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}                          text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}                        text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellGoodChannelQualityThreshold}             text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}              text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${a2MeasSCellRelEnabled}                        text|rsrpCombined|//*[@name\="a2MeasSCellRelEnabled"]
# ${actIntraFreqInterGnbMobilityNSA3x}            text|true|//*[@name\="actIntraFreqInterGnbMobilityNSA3x"]
# ${actIntraFreqIntraGnbMobilityNSA}              text|true|//*[@name\="actIntraFreqIntraGnbMobilityNSA"]
# ${actInterFreqInterGnbMobilityNSA}              text|true|//*[@name\="actInterFreqInterGnbMobilityNSA"]
# ${actInterFreqIntraGnbMobilityNSA}              text|true|//*[@name\="actInterFreqIntraGnbMobilityNSA"]
# ${a1MeashoEnabled}                              text|rsrp|//*[@name\="a1MeashoEnabled"]
# ${a1MeashoEnabledSA}                            text|rsrp|//*[@name\="a1MeashoEnabledSA"]
# ${a1HysteresishoSsbRsrp}                        text|1|//*[@name\="a1HysteresishoSsbRsrp"]
# ${a1HysteresishoSsbRsrpSA}                      text|1|//*[@name\="a1HysteresishoSsbRsrpSA"]
# ${a1ThresholdhoSsbRsrp}                         text|56|//*[@name\="a1ThresholdhoSsbRsrp"]
# ${a1ThresholdhoSsbRsrpSA}                       text|56|//*[@name\="a1ThresholdhoSsbRsrpSA"]
# ${a1TimeToTriggerhoSsbRsrp}                     text|ms320|//*[@name\="a1TimeToTriggerhoSsbRsrp"]
# ${a1TimeToTriggerhoSsbRsrpSA}                   text|ms320|//*[@name\="a1TimeToTriggerhoSsbRsrpSA"]
# ${a2MeashoEnabled}                              text|rsrp|//*[@name\="a2MeashoEnabled"]
# ${a2MeashoEnabledSA}                            text|rsrp|//*[@name\="a2MeashoEnabledSA"]
# ${a2HysteresishoSsbRsrp}                        text|1|//*[@name\="a2HysteresishoSsbRsrp"]
# ${a2HysteresishoSsbRsrpSA}                      text|1|//*[@name\="a2HysteresishoSsbRsrpSA"]
# ${a2ThresholdhoSsbRsrp}                         text|48|//*[@name\="a2ThresholdhoSsbRsrp"]
# ${a2ThresholdhoSsbRsrpSA}                       text|48|//*[@name\="a2ThresholdhoSsbRsrpSA"]
# ${a2TimeToTriggerhoSsbRsrp}                     text|ms320|//*[@name\="a2TimeToTriggerhoSsbRsrp"]
# ${a2TimeToTriggerhoSsbRsrpSA}                   text|ms320|//*[@name\="a2TimeToTriggerhoSsbRsrpSA"]
# ${a3MeasEnabled}                                text|rsrp|//*[@name\="a3MeasEnabled"]
# ${ifhoSsbSmtcOffset}                            text|0|//*[@name\="ifhoSsbSmtcOffset"]
# ${gapOffset}                                    text|0|//*[@name\="gapOffset"]
# ${a5MeasEnabled}                                text|none|//*[@name\="a5MeasEnabled"]
# 
# 
# *** Test Cases ***
# CB007922_Case148_D_A_7a_intraL2RT_intraBand_Intra_gNB_Intra_frequency_handover_for_blind_SCell_addition_NSA
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell1
#     Step 3: Initiate DL data transfer for UE
# 	Step 4: Perform UE handover to gnb2 cell3
# 	Step 5: Perform UE handover to gnb2 cell1
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                          ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    a2MeasSCellRelEnabled     rsrp
# 	add_a3measssbrsrp_list_in_cells     xml_path=${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=3    ca_relation=disable
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=1    ca_relation=disable
# 	${modify_list}      create list
#     ...       ${carrierAggregationSupportList}
#     ...       ${chBw}
#     ...       ${actInterNumerologyCa}
#     ...       ${flexibleCAMode}
#     ...       ${pucchModeSelect}
#     ...       ${actBeamforming}
#     ...       ${numberOfRxBeamforming}
#     ...       ${nrBtsBeamRefinementP2}
#     ...       ${numberOfTransmittedSsBlocks}
#     ...       ${basicBeamSet}
#     ...       ${cellDepType}
#     ...       ${actCDrx}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${lteToNrFrameShift}
#     ...       ${prachConfigurationIndex}
#     ...       ${ssBurstSetPeriod}
#     ...       ${sCellChannelEstimationPeriod}
#     ...       ${actDl256Qam}
#     ...       ${sCellAdditionMethod}
#     ...       ${maxNumScellsDl}
#     ...       ${actFdmScheduling}
#     ...       ${sCellDeactivationBadRlqCount}
#     ...       ${sCellActivationMethod}
#     ...       ${sCellGoodChannelQualityThreshold}
#     ...       ${sCellBadChannelQualityThreshold}
#     ...       ${a1MeasSCellAddEnabled}
#     ...       ${a1ThresholdSCellAddSsbRsrpTDD}
#     ...       ${actMeasBasedSCellAddition}
#     ...       ${actCarrierAggregation}
#     ...       ${caConfigurationSupport}
#     ...       ${a2MeasSCellRelEnabled}
#     ...       ${actIntraFreqInterGnbMobilityNSA3x}
#     ...       ${actIntraFreqIntraGnbMobilityNSA}
#     ...       ${actInterFreqInterGnbMobilityNSA}
#     ...       ${actInterFreqIntraGnbMobilityNSA}
#     ...       ${a1MeashoEnabled}
#     ...       ${a1MeashoEnabledSA}
#     ...       ${a1HysteresishoSsbRsrp}
#     ...       ${a1HysteresishoSsbRsrpSA}
#     ...       ${a1ThresholdhoSsbRsrp}
#     ...       ${a1ThresholdhoSsbRsrpSA}
#     ...       ${a1TimeToTriggerhoSsbRsrp}
#     ...       ${a1TimeToTriggerhoSsbRsrpSA}
#     ...       ${a2MeashoEnabled}
#     ...       ${a2MeashoEnabledSA}
#     ...       ${a2HysteresishoSsbRsrp}
#     ...       ${a2HysteresishoSsbRsrpSA}
#     ...       ${a2ThresholdhoSsbRsrp}
#     ...       ${a2ThresholdhoSsbRsrpSA}
#     ...       ${a2TimeToTriggerhoSsbRsrp}
#     ...       ${a2TimeToTriggerhoSsbRsrpSA}
#     ...       ${a3MeasEnabled}
#     ...       ${ifhoSsbSmtcOffset}
#     ...       ${gapOffset}
#     ...       ${a5MeasEnabled}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
# 	comment  cell1 and cell2 is intra cell, cell2 and cell3 is inter cell, cell3 and cell4 is diff band cell
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# Step 2: Attach CA UE to cell1
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=1
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: Initiate DL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Nsa Start Data Traffic   ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     ${Dl_throughput} =    Airphone Nsa Get Throughput    ue_id=${UE_ID}    direction=dl    rate_type=ave    bearer_id=2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step 4: Perform UE handover to gnb2 cell3
# 	Start Collect GNB and AP Syslog in 'step4_HO_to_gnb2_3' File
# 	#Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'11' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=52 nrsrp_nr=30 nrsrq_nr=30
#     airphone_execute_egate_command    ${cmd}
#     Check handover successfully
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_3
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb2_3${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb2_3${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO_to_gnb2_3' File
# 
# Check handover successfully
#     Wait Throughput Timer    15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/HO_intra_gnb_intra_freq_NSA.ini    log_need_to_check=u
#     ...        save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
# 
# Step 5: Perform UE handover to gnb2 cell1
#     Start Collect GNB and AP Syslog in 'step5_HO_back_to_gnb2_1' File
# 	#Start GNB BIP Log    duration=10
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'11' NR Measurement Identities
# 	airphone_execute_egate_command    ${A3_cmd}
#     Check handover back successfully
# 	wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_HO_back_to_gnb2_1
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_HO_back_to_gnb2_1{/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_HO_back_to_gnb2_1{/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_HO_back_to_gnb2_1' File
# 
# Check handover back successfully
#     Wait Throughput Timer    15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/handover_back   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/HO_intra_gnb_intra_freq_NSA_2.ini    log_need_to_check=u
#     ...        save_log_directory=${TEST_LOG_DIRECTORY()}/All/handover_back
