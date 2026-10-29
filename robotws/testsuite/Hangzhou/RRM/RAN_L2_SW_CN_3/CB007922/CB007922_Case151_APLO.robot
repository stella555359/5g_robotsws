# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case151_D_A_8b_interL2RT_interBand_Inter_gNB_Inter_frequency_handover_for_A1_SCell_addition_NSA
# ...               gnb cell config
# ...               Inter L2RT intra band CA Cell2&Cell3
# ...               Inter L2RT inter band CA Cell4&Cell1
# ...               Intra L2RT intra band CA Cell1&Cell2
# ...               Intra L2RT inter band CA Cell3&Cell4
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS23R1    CIT    Owner_xueminm
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
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC_intergnb_ho_NSA.cfg
# ${cmd_measGap}    ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${cmd_A2}    ue_measurement_send_nr id=11 meas_id=2 event=A2 rs_type=ssb srsrp_nr=40
# ${cmd_A3}    ue_measurement_send_nr id=11 meas_id=5 event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=54 nrsrp_nr=50 nrsrq_nr=50
# ${cmd_A3_22R3}    ue_measurement_send_nr id=11 meas_id=6 event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=54 nrsrp_nr=50 nrsrq_nr=50
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Nsa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_1|//*[@name\="basicBeamSet"]
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
# ${actIntraFreqIntraGnbMobilityNSA}              text|false|//*[@name\="actIntraFreqIntraGnbMobilityNSA"]
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
# ${NRHOIF_freqBandIndicatorNR}                   text|41|//*[contains(@distName, 'NRHOIF-1')]/*[@name\="freqBandIndicatorNR"]
# ${NRHOIF_ssbFrequency}                          text|509790|//*[contains(@distName, 'NRHOIF-1')]/*[@name\="ssbFrequency"]
# ${NRADJGNB_gNodeBId}                            text|3|//*[contains(@distName, 'NRADJGNB-1')]/*[@name\="gNodeBId"]
# ${NRADJNRCELL_gNbId}                            text|3|//*[contains(@distName, 'NRADJNRCELL-1')]/*[@name\="gNbId"]
# ${NRADJNRCELL_nrarfcn}                          text|509790|//*[contains(@distName, 'NRADJNRCELL-1')]/*[@name\="nrarfcn"]
# ${NRADJNRCELL_physCellId}                       text|54|//*[contains(@distName, 'NRADJNRCELL-1')]/*[@name\="physCellId"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${chBw3}           text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw4}           text|80MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# *** Test Cases ***
# CB007922_Case151_D_A_8b_interL2RT_interBand_Inter_gNB_Inter_frequency_handover_for_A1_SCell_addition_NSA
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell4 and trigger scell addition
#     Step 3: Initiate DL data transfer for UE
# 	Step 4: Trigger inergnb interfreq handover to gnb3 cell1
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
#     add_a3measssbrsrp_list_in_cells     xml_path=${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    a2MeasSCellRelEnabled     rsrp
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1    ca_relation=disable    gnbid=3    nrrelid=0
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1    ca_relation=enable    gnbid=2    nrrelid=1
#     add_nrhoif_extend_parameter_on_cell   xml_path=${scfc_path}    cellid=4    ho_id=1
#     add_nradjgnb_extend_parameter_on_cell     xml_path=${scfc_path}    index_id=1
#     add_nradjnrcell_extend_parameter_on_cell     xml_path=${scfc_path}    index_id=1
# 	${modify_list}      create list
#     ...       ${carrierAggregationSupportList}
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
#     ...       ${NRHOIF_freqBandIndicatorNR}
#     ...       ${NRHOIF_ssbFrequency}
#     ...       ${NRADJGNB_gNodeBId}
#     ...       ${NRADJNRCELL_gNbId}
#     ...       ${NRADJNRCELL_nrarfcn}
#     ...       ${NRADJNRCELL_physCellId}
# 	...       ${dlMimoMode}
# 	...       ${chBw3}
# 	...       ${chBw4}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
#     OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
# #    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth3
# 	Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
# 	setup X2 link to gnb3
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# setup X2 link to gnb3
#     Airphone Setup X2 Connection
#     Airphone Setup X2 Connection    gnb_id=3
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
# 	comment  cell1 and cell2 is intra cell, cell2 and cell3 is inter cell, cell3 and cell4 is diff band cell
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# Step 2: Attach CA UE to cell4 and trigger scell addition
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=4
#     Inquery UE'11' NR Measurement Identities
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=11 meas_id\=3 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
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
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Wait Throughput Timer    10
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should be true      ${Pcell_dl_throughput}>300000
#     should be true      ${Scell_dl_throughput}>300000
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step 4: Trigger inergnb interfreq handover to gnb3 cell1
# 	Start Collect GNB and AP Syslog in 'step4_HO' File
# 	#Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Cqi Param    id=11    scell_id=8    nr_ri=1    nr_cqi=15
#     Airphone Cqi Param    id=11    scell_id=9    nr_ri=1    nr_cqi=15
#     airphone_execute_egate_command    ${cmd_measGap}
#     Inquery UE'11' NR Measurement Identities
# 	airphone_execute_egate_command    ${cmd_A2}
# 	Inquery UE'11' NR Measurement Identities
#     Run Keyword If     "${SW_VERSION}"=="SBTS22R3"     airphone_execute_egate_command    ${cmd_A3_22R3}
#     ...    ELSE    airphone_execute_egate_command    ${cmd_A3}
#     Check handover successfully
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO' File
# 
# Check handover successfully
#     Wait Throughput Timer    10
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/handover   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/HO_inter_gnb_inter_freq_NSA.ini
# 	...       log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/handover
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
