# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case120_D_B_5a_inter_frequency_handover_with_measurement_gap_intra_gnb
# ...
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CIT    SBTS00    SBTS23R1    Owner_xueminm
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
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
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}                        text|bufferAndRLQualityBased|//*[@name\="sCellActivationMethod"]
# ${sCellGoodChannelQualityThreshold}             text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}              text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# #${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${a2MeasSCellRelEnabled}                        text|rsrpCombined|//*[@name\="a2MeasSCellRelEnabled"]
# ${actIntraFreqHoSA}                             text|true|//*[@name\="actIntraFreqHoSA"]
# ${actInterFreqHoSA}                             text|true|//*[@name\="actInterFreqHoSA"]
# ${miNrRelReportCu}                              text|15min|//*[@name\="miNrRelReportCu"]
# #${actGeneralConnectivitySilver}                 text|true|//*[@name\="actGeneralConnectivitySilver"]
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
# ${a3HysteresisSsbRsrp}                          text|2|//*[contains(@distName, 'NRHOIF-1')]/*[@name\="a3HysteresisSsbRsrp"]
# ${a3OffsetSsbRsrp}                              text|10|//*[contains(@distName, 'NRHOIF-1')]/*[@name\="a3OffsetSsbRsrp"]
# ${a3TimeToTriggerSsbRsrp}                       text|ms256|//*[contains(@distName, 'NRHOIF-1')]/*[@name\="a3TimeToTriggerSsbRsrp"]
# ${ssbFrequency1}                                text|638688|//*[contains(@distName, 'NRCELL-1')]/*[@name\="ssbFrequency"]
# ${ssbFrequency2}                                text|631968|//*[contains(@distName, 'NRCELL-2')]/*[@name\="ssbFrequency"]
# ${a5MeasEnabled}                                text|none|//*[@name\="a5MeasEnabled"]
# ${chBw}           text|80MHz|//*[@name="chBw"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# 
# *** Test Cases ***
# CB007922_Case120_D_B_5a_inter_frequency_handover_with_measurement_gap_intra_gnb
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell2 Send measurement report for A1 event to gNB
#     Step 3: Initiate big DL data transfer for UE
# 	Step 4: Perform UE handover to gnb2 cell1
# 	Step 5: Perform UE handover to gnb2 cell2
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                          ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    a2MeasSCellRelEnabled     rsrp
# 	add_a3measssbrsrp_list_in_cells     xml_path=${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1    ca_relation=disable
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2    ca_relation=disable
# 	add_nrhoif_extend_parameter_on_cell   xml_path=${scfc_path}    cellid=2    ho_id=1
# 	add_nrhoif_extend_parameter_on_cell   xml_path=${scfc_path}    cellid=1    ho_id=1
# 	${modify_list}      create list        ${carrierAggregationSupportList}
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
#     ...       ${actCarrierAggregation}
#     ...       ${caConfigurationSupport}
#     ...       ${a1ThresholdSCellAddSsbRsrpTDD}
# 	...       ${actIntraFreqHoSA}
# 	...       ${actInterFreqHoSA}
# 	...       ${miNrRelReportCu}
# #	...       ${actGeneralConnectivitySilver}
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
#     ...       ${a5MeasEnabled}
#     ...       ${ifhoSsbSmtcOffset}
#     ...       ${gapOffset}
# 	...       ${ssbFrequency1}
# 	...       ${ssbFrequency2}
# 	...       ${dlMimoMode}
# 	...       ${chBw}
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
# Step 2: Attach CA UE to cell2 Send measurement report for A1 event to gNB
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    ue_change_location id\=${UE_ID} cell\=2
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=80
#     Airphone Measurement Send Nr    id=1    meas_id=3    event=A1    srsrp_nr=80
# 	...    pass_regexp=sCellToAddModList
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: Initiate big DL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    UL    20M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step 4: Perform UE handover to gnb2 cell1
# 	Start Collect GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
# 	#Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'1' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=45
#     airphone_execute_egate_command    ${cmd}
# 	Inquery UE'1' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=6 event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
# 	Run Keyword And Ignore Error    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb2_1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb2_1{/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
# 
# Step 5: Perform UE handover to gnb2 cell2
#     Start Collect GNB and AP Syslog in 'step5_HO_back_to_gnb2_2' File
# 	#Start GNB BIP Log    duration=10
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'1' NR Measurement Identities
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=7 event=A2 srsrp_nr=45
#     airphone_execute_egate_command    ${cmd}
# 	Inquery UE'1' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=10 event=A3 srsrp_nr=30 phycell_id=51 nrsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
# 	Inquery UE'1' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=13 event=A1 srsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToAddModList
# 	wait Throughput Timer    2
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_HO_back_to_gnb2_2
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_HO_back_to_gnb2_2{/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_HO_back_to_gnb2_2{/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_HO_back_to_gnb2_2' File
# 
