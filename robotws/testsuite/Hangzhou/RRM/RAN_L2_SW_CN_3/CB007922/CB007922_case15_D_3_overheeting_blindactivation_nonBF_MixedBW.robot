# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case15_D_3_overheeting_blindactivation_nonBF_MixedBW
# ...
# ...               UE overheating or vRLF triggered SCell scheduling suspension
# ...               This user scenario describes successful handling of UE indicated overheating or vRLF by gNB.
# ...               UE indicates overheating/vRLF by providing CSI reports with CQI = 0 for active SCell.
# ...               Upon reception of CSI report for SCell with CQI = 0 via PUCCH on PCell,
# ...               gNB shall suspend scheduling data on SCell and keep the SCell active.
# ...               gNB continue receiving CSI measurements for SCell and once CSI report with CQI ≠ 0 is received,
# ...               gNB shall resume scheduling on SCell after TCI state indication to UE for Scell.
# 
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS22R2    SBTS22R3    SBTS23R1
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
# ${sCellGoodChannelQualityThreshold}  text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}   text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}      text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}                       text|false|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}               text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                  text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}      text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}             text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}             text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}     text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}         text|false|//*[@name\="actMeasBasedSCellAddition"]
# #${chBw}                              text|60MHz|//*[@name\="chBw"]
# 
# *** Test Cases ***
# CB007922_case15_D_3_overheeting_blindactivation_nonBF_MixedBW
#     Step1:Set parameter and wait for onair
#     Step2:UE attach to cell1, push DL and UL full data to UE
#     Step3:Trigger UE to report CQI is 0 on SCell
#     Step4:Stop pushing DL and UL data
#     Step5:push DL and UL full data to UE, Trigger UE to report CQI greater than 0 on SCell
#     Step6:Trigger CSI report with CQI is 0 on PCell
# 
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}                Set Variable                      ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
#     ${modify_list}      create list        ${carrierAggregationSupportList}
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
#     #...        ${chBw}
#     ...        ${a1ThresholdSCellAddSsbRsrpTDD}
#     modify_xml          ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE attach to cell1, push DL and UL full data to UE
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
# #    Start GNB BIP Log
# #    Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=1 cqi=15 pmi=0 ri=1 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0,1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    2
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# #    Airphone SA Start Data Traffic    ${UE_ID}    UL    20M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:Trigger UE to report CQI is 0 on SCell
#     Start Collect GNB and AP Syslog in 'step3_trigger_cqi_0' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    ue_cqi_param id\=1 on\=nr nr_cqi_mode\=fixed scell\=1 nr_ri\=0 nr_cqi\=0
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=2 cqi=0 pmi=2 ri=0 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=2 scell=1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_cqi_0${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_cqi_0${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_trigger_cqi_0
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_trigger_cqi_0/output
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_trigger_cqi_0' File
# 
# Step4:Stop pushing DL and UL data
#     Start Collect GNB and AP Syslog in 'step4_stop_data' File
# #    Start GNB BIP Log
# #    Start AP BIP Log
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     #airphone_sa_stop_data_traffic    ${UE_ID}    UL    pdu_id=${PDU_ID}
#     Wait Throughput Timer    20
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_stop_data${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_stop_data${/}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} == 0
#     should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_stop_data' File
# 
# Step5:push DL and UL full data to UE, Trigger UE to report CQI greater than 0 on SCell
#     Start Collect GNB and AP Syslog in 'step5_trigger_cqi_15' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# #    Airphone SA Start Data Traffic    ${UE_ID}    UL    20M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    2
# #    ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=2 cqi=15 pmi=0 ri=1 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
# #    airphone_execute_egate_command    ${cmd}
# #    ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=2 scell=1
# #    airphone_execute_egate_command    ${cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override scell\=1 profile_id\=2 action\=deactivate
#     Wait Throughput Timer    10
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_trigger_cqi_15${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_trigger_cqi_15${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_trigger_cqi_15
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_trigger_cqi_15/output
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_trigger_cqi_15' File
# 
# Step6:Trigger CSI report with CQI is 0 on PCell
#     Start Collect GNB and AP Syslog in 'step6_trigger_cqi_0_pcell' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    ue_cqi_param id\=1 on\=nr nr_cqi_mode\=fixed scell\=0 nr_ri\=0 nr_cqi\=0
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=3 cqi=0 pmi=2 ri=0 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=3 scell=0
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_trigger_cqi_0_pcell${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_trigger_cqi_0_pcell${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_trigger_cqi_0_pcell
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_trigger_cqi_0_pcell/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_trigger_cqi_0_pcell' File
