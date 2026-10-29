# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case153_D_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep
# ...               gnb cell config
# ...               Inter L2RT intra band CA Cell2&Cell3
# ...               Inter L2RT inter band CA Cell4&Cell1
# ...               Intra L2RT intra band CA Cell1&Cell2
# ...               Intra L2RT inter band CA Cell3&Cell4
# 
# Test Timeout      90 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4     Owner_xueminm    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Nsa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
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
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}                        text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${actInterMeNBMobility}                         text|true|//*[@name\="actInterMeNBMobility"]
# ${actIntraMeNBMobility}                         text|true|//*[@name\="actIntraMeNBMobility"]
# 
# 
# *** Test Cases ***
# CB007922_Case153_D_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep_bak
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell4
#     Step 3: Initiate DL data transfer for UE
#     Step 4: Trigger LTE intra handover
# 
# CB007922_Case153_D_A_9_Intra_MeNB_LTE_HO_without_SgNB_change_without_PSCell_change_CA_UE_traffic_keep
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell4
#     Step 3: Initiate DL data transfer for UE
#     Step 4: Trigger LTE intra handover
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
# 	${modify_list}      create list
#     ...       ${carrierAggregationSupportList}
#     ...       ${actInterNumerologyCa}
#     ...       ${flexibleCAMode}
#     ...       ${pucchModeSelect}
#     ...       ${actBeamforming}
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
#     ...       ${sCellAdditionMethod}
#     ...       ${maxNumScellsDl}
#     ...       ${actFdmScheduling}
#     ...       ${sCellDeactivationBadRlqCount}
#     ...       ${sCellActivationMethod}
#     ...       ${a1MeasSCellAddEnabled}
#     ...       ${a1ThresholdSCellAddSsbRsrpTDD}
#     ...       ${actMeasBasedSCellAddition}
#     ...       ${actCarrierAggregation}
#     ...       ${caConfigurationSupport}
#     ...       ${actInterMeNBMobility}
#     ...       ${actIntraMeNBMobility}
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
# Step 2: Attach CA UE to cell4
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    enb_cell_param enb\=1 id\=1 allow_endc\=on
#     airphone_execute_egate_command    enb_cell_param enb\=1 id\=2 allow_endc\=on
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=4
#     Inquery UE'11' NR Measurement Identities
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=11 meas_id\=1 event\=A1 srsrp_nr\=80
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
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     ${cells_thp}=       evaluate        ${Pcell_dl_throughput}+${Scell_dl_throughput}
#     should be true      ${Pcell_dl_throughput}>280000
#     should be true      ${Scell_dl_throughput}>280000
#     should be true      ${cells_thp} > 600000
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step 4: Trigger LTE intra handover
# 	Start Collect GNB and AP Syslog in 'step4_HO' File
# 	#Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Inquery UE'11' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_ho id=11 ho_mode=INTRA_LTE enb=1 cell=2
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     ${cmd}=    Set Variable    ue_ho id=11 ho_mode=INTRA_LTE enb=1 cell=1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     Check handover successfully
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_HO${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_HO' File
# 
# Check handover successfully
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/handovercheck   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/HO_Intra_MeNB.ini    log_need_to_check=u
#     ...        save_log_directory=${TEST_LOG_DIRECTORY()}/handovercheck
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
