# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case7_D_3_RLQ_based_stop_and_resume_scheduling_nonBF
# ...
# ...               Single UE connection setup and DL/UL data scheduling in SA option 2
# ...               BufferAndRLQualityBased scell Deactivation
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS22R2    SBTS22R3    SBTS23R1
# Resource    ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQA_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${WTS_NAME}         wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|false|//*[@name\="actBeamforming"]
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
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellGoodChannelQualityThreshold}             text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}              text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${sCellActivationMethod}                        text|bufferBased|//*[@name\="sCellActivationMethod"]
# #${chBw}                                         text|20MHz|//*[@name\="chBw"]
# #${nrCellType}                                   text|4DL2UL|//*[@name\="nrCellType"]
# 
# *** Test Cases ***
# CB007922_case7_D_3_RLQ_based_stop_and_resume_scheduling_nonBF
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell1
#     Step 3: UE send A1 measurement report
#     Step 4: Initiate big DL data transfer to active scell
#     Step 5: Override scell CQI or add NACK to bad but not reach bad scell RLQ threshold
#     Step 6: increase path loss for Scell to trigger bad RLQ
#     Step 7: Override scell CQI to reach good scell RLQ threshold
#     Step 8: Override scell CQI to reach bad scell RLQ threshold for more than 200s
#     Step 9: Override scell CQI to reach good scell RLQ threshold
#     Step 10: Detach UE
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}                Set Variable           ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
#     ${modify_list}      create list        ${carrierAggregationSupportList}
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
#     ...       ${actDl256Qam}
#     ...       ${sCellAdditionMethod}
#     ...       ${maxNumScellsDl}
#     ...       ${actFdmScheduling}
#     ...       ${sCellDeactivationBadRlqCount}
#     ...       ${sCellActivationMethod}
#     ...       ${sCellGoodChannelQualityThreshold}
#     ...       ${sCellBadChannelQualityThreshold}
#     ...       ${a1MeasSCellAddEnabled}
#     ...       ${actMeasBasedSCellAddition}
#     ...       ${actCarrierAggregation}
#     ...       ${caConfigurationSupport}
#     ...       ${a1ThresholdSCellAddSsbRsrpTDD}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step 2: Attach CA UE to cell1
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=200\,600\,700\,800\,200\,300\,400\,500
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=2 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0,1
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 kbps\=100 dir\=dl protocol\=udp seconds\=3600
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: UE send A1 measurement report
#     Start Collect GNB and AP Syslog in 'step3_trigger_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_trigger_A1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_trigger_A1' File
# 
# Step 4: Initiate big DL data transfer to active scell
#     Start Collect GNB and AP Syslog in 'step4_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_send_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_send_data/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_data${/}
# #    ${pcell_dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
# #    log    ${pcell_dl_tput}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_send_data' File
# 
# Step 5: Override scell CQI or add NACK to bad but not reach bad scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'step5_modify_cqi_to_7' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=11 pmi\=2 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 	Wait Throughput Timer     2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_modify_cqi_to_7
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_modify_cqi_to_7${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_modify_cqi_to_7${/}
#     ${dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     ${ul_tput}=    airphone_sa_get_throughput    ${UE_ID}    UL    ${PDU_ID}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_modify_cqi_to_7/output
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step5_modify_cqi_to_7' File
# 
# Step 6: increase path loss for Scell to trigger bad RLQ
#     Start Collect GNB and AP Syslog in 'step6_modify_cqi_to_1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 pmi\=2 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 	Wait Throughput Timer     2
# 	Airphone Bler Testmode Nr    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=1 testmode\=bler profile_id\=1 action\=activate
# 	Wait Throughput Timer     5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_modify_cqi_to_1
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_modify_cqi_to_1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_modify_cqi_to_1${/}
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_modify_cqi_to_1/output
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} == 0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step6_modify_cqi_to_1' File
# 
# Step 7: Override scell CQI to reach good scell RLQ threshold
# 	Start Collect GNB and AP Syslog in 'step7_modify_cqi_to_15' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
# #    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 pmi\=2 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# #	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override scell\=1 profile_id\=2 action\=deactivate
# 	Wait Throughput Timer    2
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=1 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_modify_cqi_to_15
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_modify_cqi_to_15${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_modify_cqi_to_15${/}
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_modify_cqi_to_15/output
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step7_modify_cqi_to_15' File
# 
# Step 8: Override scell CQI to reach bad scell RLQ threshold for more than 200s
#     Start Collect GNB and AP Syslog in 'step8_modify_cqi_to_1_keep_200s' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 pmi\=2 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 	Wait Throughput Timer    2
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=1 testmode\=bler profile_id\=1 action\=activate
# 	Wait Throughput Timer    2
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_modify_cqi_to_1_keep_200s${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_modify_cqi_to_1_keep_200s${/}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step8_modify_cqi_to_1_keep_200s
#     Wait Throughput Timer    200
#     ${dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_modify_cqi_to_1_keep_200s/output
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} == 0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step8_modify_cqi_to_1_keep_200s' File
# 
# Step 9: Override scell CQI to reach good scell RLQ threshold
# 	Start Collect GNB and AP Syslog in 'step9_modify_cqi_to_15' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override scell\=1 profile_id\=2 action\=deactivate
# 	Wait Throughput Timer    2
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=1 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step9_modify_cqi_to_15
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_modify_cqi_to_15${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_modify_cqi_to_15${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step9_modify_cqi_to_15/output
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} == 0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step9_modify_cqi_to_15' File
# 
# Step 10: Detach UE
#     Start Collect GNB and AP Syslog in 'step10_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step10_detach' File
# 
