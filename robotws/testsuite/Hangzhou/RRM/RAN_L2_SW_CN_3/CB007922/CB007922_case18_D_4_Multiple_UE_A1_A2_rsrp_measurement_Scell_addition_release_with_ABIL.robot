# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case18_D_4_Multiple_UE_A1_A2_rsrp_measurement_Scell_addition_release_with_ABIL
# ...
# ...               This user scenario describes the successful UE connection setup with TDD FR1-TDD FR1 Carrier aggregation
# ...               Within this sub-feature the same CA functionalities are verified with CPRI configuration
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
# ${SLICE_ID}         1
# ${PDU_ID}           1
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
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}                        text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellGoodChannelQualityThreshold}             text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}              text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${a2MeasSCellRelEnabled}                        text|rsrpCombined|//*[@name\="a2MeasSCellRelEnabled"]
# 
# *** Test Cases ***
# CB007922_case18_D_4_Multiple_UE_A1_A2_rsrp_measurement_Scell_addition_release_with_ABIL
#     step1:Set parameter and wait for onair
#     step2:UE1/2 support CA and attach to TDD FR1 cell1
#     step3:UE3/4 support CA and attach to TDD FR1 cell2
#     step4:UE5/6 don't support CA and attach to cell1
#     step5:UE7/8 don't support CA and attach to cell2
#     step6:full buffer data transmission of the DRB bearer is started in DL and UL for all the Ues
#     step7:moving UE1/2/3/4 to SCell bad coverage area to trigger A2 measurement event
#     step8:moving UE1/2/3/4 to SCell good coverage area to trigger A1 measurement event
# #    step9:all UEs detached
# 
# *** Keywords ***
# step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}                Set Variable           ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_all_elements    ${scfc_path}     NRCELL    a2MeasSCellRelEnabled     rsrp
#     add_a2measscellrelssbrsrp_list_in_cells     xml_path=${scfc_path}
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
#     modify_xml          ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# step2:UE1/2 support CA and attach to TDD FR1 cell1
#     Start Collect GNB and AP Syslog in 'step2_ue12_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     attach '1' to cell '1' use ue cap 'CA_disable_vonr_n78'
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...   pass_regexp=sCellToAddModList
#     attach '2' to cell '1' use ue cap 'CA_disable_vonr_n78'
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_measurement_send_nr id\=2 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...   pass_regexp=sCellToAddModList
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue12_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue12_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue12_attach${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue12_attach/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue12_attach' File
# 
# step3:UE3/4 support CA and attach to TDD FR1 cell2
#     Start Collect GNB and AP Syslog in 'step3_ue34_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     attach '3' to cell '2' use ue cap 'CA_disable_vonr_n78'
#     airphone_execute_egate_command    ue_measurement_send_nr id\=3 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...   pass_regexp=sCellToAddModList
#     attach '4' to cell '2' use ue cap 'CA_disable_vonr_n78'
#     airphone_execute_egate_command    ue_measurement_send_nr id\=4 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...   pass_regexp=sCellToAddModList
#     Wait Throughput Timer    10
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_ue34_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_ue34_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue34_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue34_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_ue34_attach' File
# 
# step4:UE5/6 don't support CA and attach to cell1
#     Start Collect GNB and AP Syslog in 'step4_ue56_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     attach '5' to cell '1' use ue cap 'nr_common_cap'
#     attach '6' to cell '1' use ue cap 'nr_common_cap'
#     Wait Throughput Timer    10
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_ue56_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_ue56_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_ue56_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_ue56_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_ue56_attach' File
# 
# step5:UE7/8 don't support CA and attach to cell2
#     Start Collect GNB and AP Syslog in 'step5_ue78_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     attach '7' to cell '2' use ue cap 'nr_common_cap'
#     attach '8' to cell '2' use ue cap 'nr_common_cap'
#     Wait Throughput Timer    10
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_ue78_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_ue78_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_ue78_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_ue78_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_ue78_attach' File
# 
# step6:full buffer data transmission of the DRB bearer is started in DL and UL for all the Ues
#     Start Collect GNB and AP Syslog in 'step6_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    4    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    4    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    5    DL    50M     trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    6    DL    50M     trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    7    DL    50M     trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    8    DL    50M     trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    2
#     airphone_execute_egate_command  csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=2 ri\=0 cqi_mode\=fixed pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command  ue_testmode_set_nr id\=1-8 testmode\=csi_override action\=activate profile_id\=1 scell\=0,1
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_data
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_data' File
#     ${UE1_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     ${UE2_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     ${UE2_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=1    type=pdsch    tput_type=ave
#     ${UE3_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=3    scell_id=0    type=pdsch    tput_type=ave
#     ${UE3_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=3    scell_id=1    type=pdsch    tput_type=ave
#     ${UE4_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=4    scell_id=0    type=pdsch    tput_type=ave
#     ${UE4_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=4    scell_id=1    type=pdsch    tput_type=ave
#     ${UE5_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=5    scell_id=0    type=pdsch    tput_type=ave
#     ${UE6_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=6    scell_id=0    type=pdsch    tput_type=ave
#     ${UE7_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=7    scell_id=0    type=pdsch    tput_type=ave
#     ${UE8_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=8    scell_id=0    type=pdsch    tput_type=ave
# #    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_data/output
#     should be true    ${UE1_dl_throughput_s}>30000
#     should be true    ${UE2_dl_throughput_s}>30000
#     should be true    ${UE3_dl_throughput_s}>30000
#     should be true    ${UE4_dl_throughput_s}>30000
# 
# 
# step7:moving UE1/2/3/4 to SCell bad coverage area to trigger A2 measurement event
#     Start Collect GNB and AP Syslog in 'step7_trigger_a2' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=2 event=A2 scell=1 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=2 meas_id=2 event=A2 scell=1 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=3 meas_id=2 event=A2 scell=1 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=4 meas_id=2 event=A2 scell=1 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
#     wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_trigger_a2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_trigger_a2${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_trigger_a2${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_trigger_a2/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_trigger_a2' File
# 
# step8:moving UE1/2/3/4 to SCell good coverage area to trigger A1 measurement event
#     Start Collect GNB and AP Syslog in 'step8_trigger_a1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=3 event=A1 srsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToAddModList
#     wait Throughput Timer    2
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=2 meas_id=3 event=A1 srsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToAddModList
#     wait Throughput Timer    2
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=3 meas_id=3 event=A1 srsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToAddModList
#     wait Throughput Timer    2
#     ${cmd}=    Set Variable    ue_measurement_send_nr id=4 meas_id=3 event=A1 srsrp_nr=80
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToAddModList
#     wait Throughput Timer    2
#     airphone_execute_egate_command  csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=2 ri\=0 cqi_mode\=fixed pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command  ue_testmode_set_nr id\=1-8 testmode\=csi_override action\=activate profile_id\=1 scell\=0,1
#     wait Throughput Timer    10
#     ${UE1_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     ${UE2_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     ${UE2_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=2    scell_id=1    type=pdsch    tput_type=ave
#     ${UE3_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=3    scell_id=0    type=pdsch    tput_type=ave
#     ${UE3_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=3    scell_id=1    type=pdsch    tput_type=ave
#     ${UE4_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=4    scell_id=0    type=pdsch    tput_type=ave
#     ${UE4_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=4    scell_id=1    type=pdsch    tput_type=ave
#     ${UE5_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=5    scell_id=0    type=pdsch    tput_type=ave
#     ${UE6_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=6    scell_id=0    type=pdsch    tput_type=ave
#     ${UE7_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=7    scell_id=0    type=pdsch    tput_type=ave
#     ${UE8_dl_throughput} =    Airphone Get Throughput On Specific Scell      ue_id=8    scell_id=0    type=pdsch    tput_type=ave
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step8_trigger_a1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_trigger_a1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_trigger_a1${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_trigger_a1/output
#     should be true    ${UE1_dl_throughput_s}>30000
#     should be true    ${UE2_dl_throughput_s}>30000
#     should be true    ${UE3_dl_throughput_s}>30000
#     should be true    ${UE4_dl_throughput_s}>30000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_trigger_a1' File
# 
# step9:all UEs detached
#     Start Collect GNB and AP Syslog in 'step9_detach' File
#     airphone_sa_stop_data_traffic    1    DL    pdu_id=1
#     airphone_sa_stop_data_traffic    2    DL    pdu_id=2
#     airphone_sa_stop_data_traffic    3    DL    pdu_id=3
#     airphone_sa_stop_data_traffic    4    DL    pdu_id=4
#     airphone_sa_stop_data_traffic    5    DL    pdu_id=5
#     airphone_sa_stop_data_traffic    6    DL    pdu_id=6
#     airphone_sa_stop_data_traffic    7    DL    pdu_id=7
#     airphone_sa_stop_data_traffic    8    DL    pdu_id=8
#     airphone_sa_detach    1
#     airphone_sa_detach    2
#     airphone_sa_detach    3
#     airphone_sa_detach    4
#     airphone_sa_detach    5
#     airphone_sa_detach    6
#     airphone_sa_detach    7
#     airphone_sa_detach    8
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_detach' File
# 
# attach '${UE_ID}' to cell '${CELL_ID}' use ue cap '${ue_cap}'
#     ${GW_ID}    set variable     ${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Location Change    id=${UE_ID}    cell_id=${CELL_ID}
#     ${ue_ability}    Obtain Ue Capability    ${ue_cap}
#     Airphone SA Attach    ue_id=${UE_ID}       ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
