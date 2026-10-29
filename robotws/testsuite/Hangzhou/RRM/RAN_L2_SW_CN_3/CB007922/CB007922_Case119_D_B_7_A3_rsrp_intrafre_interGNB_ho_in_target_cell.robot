# *** Settings ***
# Documentation
# ...               Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:CB007922_Case119_D_B_7_A3_rsrp_intrafre_interGNB_ho_in_target_cell
# ...
# 
# Test Timeout      90 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4    Owner_xueminm    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC_intergnb_ho.cfg
# ${COM1}    ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=2 time_ue_stayed_in_cell\=97
# ${COM2}    ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=3 time_ue_stayed_in_cell\=98
# ${COM3}    ue_history_information_list id\=1 action\=commit
# ${COM4}    ue_enb_param id\=1 ue_history_list\=1
# ${COM5}    gnb_param id\=3 xn_listening_socket\=1 send_xn_setup\=true measEvent\=A3
# ${COM6}    gnb_xn_ngran_conf_update_param id\=3 reset; gnb_xn_setup_param id\=3 reset
# ${A3_1}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=381 nrsrp_nr\=30 nrsrq_nr\=30
# ${A3_2}    ue_measurement_send_nr id\=1 meas_id\=3 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=51 nrsrp_nr\=30 nrsrq_nr\=30
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}     text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}              text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                   text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                    text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}             text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}       text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                      text|beamSet_1|//*[@name\="basicBeamSet"]
# ${nrCellType}                        text|2DL2UL|//*[@name\="nrCellType"]
# ${cellDepType}                       text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}                           text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                 text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                 text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}           text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                  text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellGoodChannelQualityThreshold}  text|8|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}   text|4|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}      text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}                       text|false|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}               text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                  text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}      text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}             text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}             text|none|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}     text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${a1MeashoEnabled}                   text|none|//*[@name\="a1MeashoEnabled"]
# ${a2MeashoEnabled}                   text|none|//*[@name\="a2MeashoEnabled"]
# ${a1MeashoEnabledSA}                 text|rsrp|//*[@name\="a1MeashoEnabledSA"]
# ${a2MeashoEnabledSA}                 text|rsrp|//*[@name\="a2MeashoEnabledSA"]
# ${a2ThresholdhoSsbRsrpSA}            text|34|//*[@name\="a2ThresholdhoSsbRsrpSA"]
# ${actMeasBasedSCellAddition}         text|false|//*[@name\="actMeasBasedSCellAddition"]
# ${actMeasBasedSCellAdditionNsa}      text|false|//*[@name\="actMeasBasedSCellAdditionNsa"]
# ${a2MeasSCellRelEnabled}             text|none|//*[@name\="a2MeasSCellRelEnabled"]
# ${a3MeasEnabled}                     text|rsrp|//*[@name\="a3MeasEnabled"]
# ${ifhoSsbSmtcOffset}                 text|0|//*[@name\="ifhoSsbSmtcOffset"]
# ${gapOffset}                         text|0|//*[@name\="gapOffset"]
# ${actIntraFreqHoSA}                  text|true|//*[@name\="actIntraFreqHoSA"]
# ${chBw}                              text|80MHz|//*[@name\="chBw"]
# ${nrarfcn_cell1}                     text|632000|//*[contains(@distName, 'NRCELL-1')]/*[@name='nrarfcn']
# ${nrarfcn_cell2}                     text|638688|//*[contains(@distName, 'NRCELL-2')]/*[@name='nrarfcn']
# ${nrarfcn_cell3}                     text|632000|//*[contains(@distName, 'NRCELL-3')]/*[@name='nrarfcn']
# ${nrarfcn_cell4}                     text|528030|//*[contains(@distName, 'NRCELL-4')]/*[@name='nrarfcn']
# ${NRADJNRCELL_nrarfcn}               text|638688|//*[contains(@distName, 'NRADJNRCELL-1')]/*[@name\="nrarfcn"]
# 
# 
# *** Test Cases ***
# CB007922_Case119_D_B_7_A3_rsrp_intrafre_interGNB_ho_in_target_cell_bak
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach ue with blind addition and blind activation
#     Step 3: Send UL/DL traffic
#     Step 4: Perform UE handover to gnb3 cell1
# 
# CB007922_Case119_D_B_7_A3_rsrp_intrafre_interGNB_ho_in_target_cell
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach ue with blind addition and blind activation
#     Step 3: Send UL/DL traffic
#     Step 4: Perform UE handover to gnb3 cell1
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                      ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_ca_relation_CB7922    ${scfc_path}
# 	add_a3measssbrsrp_list_in_cells     xml_path=${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1    ca_relation=disable    gnbid=35
#     add_nradjnrcell_extend_parameter_on_cell     xml_path=${scfc_path}    index_id=1
# 	add_nradjgnb_extend_parameter_on_cell     xml_path=${scfc_path}    index_id=1
# 	${modify_list}      create list        ${carrierAggregationSupportList}
#     ...        ${actInterNumerologyCa}
#     ...        ${flexibleCAMode}
#     ...        ${pucchModeSelect}
#     ...        ${actBeamforming}
#     ...        ${nrBtsBeamRefinementP2}
#     ...        ${numberOfTransmittedSsBlocks}
#     ...        ${basicBeamSet}
#     ...        ${cellDepType}
#     ...        ${actCDrx}
#     ...        ${frameStructureType}
#     ...        ${guardPeriodLength}
#     ...        ${lteToNrFrameShift}
#     ...        ${prachConfigurationIndex}
#     ...        ${ssBurstSetPeriod}
#     ...        ${sCellGoodChannelQualityThreshold}
#     ...        ${sCellBadChannelQualityThreshold}
#     ...        ${sCellChannelEstimationPeriod}
#     ...        ${actDl256Qam}
#     ...        ${sCellAdditionMethod}
#     ...        ${maxNumScellsDl}
#     ...        ${actFdmScheduling}
#     ...        ${sCellDeactivationBadRlqCount}
#     ...        ${sCellActivationMethod}
#     ...        ${a1MeasSCellAddEnabled}
#     ...        ${actMeasBasedSCellAddition}
#     ...        ${actMeasBasedSCellAdditionNsa}
#     ...        ${a2MeasSCellRelEnabled}
#     ...        ${a2MeashoEnabledSA}
#     ...        ${ifhoSsbSmtcOffset}
#     ...        ${gapOffset}
#     ...        ${a1MeashoEnabled}
#     ...        ${a2MeashoEnabled}
#     ...        ${a1MeashoEnabledSA}
#     ...        ${a2MeashoEnabledSA}
#     ...        ${a2ThresholdhoSsbRsrpSA}
#     ...        ${a3MeasEnabled}
#     ...        ${actIntraFreqHoSA}
#     ...        ${chBw}
#     ...        ${nrarfcn_cell1}
# 	...        ${nrarfcn_cell2}
# 	...        ${nrarfcn_cell3}
# 	...        ${nrarfcn_cell4}
# 	...        ${NRADJNRCELL_nrarfcn}
#     ...        ${a1ThresholdSCellAddSsbRsrpTDD}
# 	...        ${nrCellType}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
#     Perform Full Commission And Reach Onair
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
# Step 2: Attach ue with blind addition and blind activation
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    ${COM1}
# 	airphone_execute_egate_command    ${COM2}
# 	airphone_execute_egate_command    ${COM3}
# 	airphone_execute_egate_command    ${COM4}
# 	airphone_execute_egate_command    ${COM5}
#     airphone_execute_egate_command    ${COM6}
#     airphone_execute_egate_command    gnb_xn_link_up gnb\=3 target\=2
#     Airphone Location Change    id=${UE_ID}    cell_id=2
# 	Airphone SA Attach    ue_id=${UE_ID}
# 	airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: Send UL/DL traffic
#     Start Collect GNB and AP Syslog in 'step3_data_traffic' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Internal send mutiple trf '1' for each '175M' DL data
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_data_traffic${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_data_traffic${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_data_traffic
# 	Wait until keyword succeeds    120s    5s    Verify UE throughput
# 	#${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     #should be true    ${Pcell_dl_throughput}>80000
#     #should be true    ${Scell_dl_throughput}>80000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_data_traffic' File
# 
# Internal send mutiple trf '${number}' for each '${dl_data}' DL data
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${UE_ID}    DL    ${dl_data}    pdu_id=${PDU_ID}    duration=6000s    trf_id=${num}
# 
# Verify UE throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell}>0
# 
# Step 4: Perform UE handover to gnb3 cell1
#     Start Collect GNB and AP Syslog in 'step4_HO_to_gnb3_1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'1' NR Measurement Identities
# 	airphone_execute_egate_command    ${A3_1}
# 	...     pass_regexp=Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed
# 	Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb3_1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO_to_gnb3_1${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb3_1
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO_to_gnb3_1' File
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
# 
# 
