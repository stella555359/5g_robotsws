# *** Settings ***
# Documentation     Author: wenchao.zhang@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case105_D_A_3_Single_UE_Peak_BW20_20_closedmode42_256qam_64QAM
# ...
# ...              US5GC001729-A#9: Single UE connection setup and DL/UL data scheduling in SA option 2
# ...              (BF activated, A1 MR based SCell addition and buffer-based SCell activation
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    ownerbylilyu
# #...    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrCellType}     text|4DL4UL|//*[@name\="nrCellType"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellGoodChannelQualityThreshold}    text|8|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}    text|4|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}    text|true|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${chBw}           text|80MHz|//*[@name\="chBw"]
# 
# *** Test Cases ***
# CB007922_Case105_D_A_3_Single_UE_Peak_BW20_20_closedmode42_256qam_64QAM
#     Step1:Set parameter and wait for onair
#     Step2:UE attach to cell
#     Step3:Send measurement report for A1 event to gNB
#     Step4:Initiate enough DL and UL data transfer for UE
#     Step5:Detach UE
#     Step6:Change actDl256Qam is false
#     Step7:Attach CA UE to cell1
#     Step8:Send measurement report for A1 event to gNB
#     Step9:Initiate enough DL and UL data transfer for UE again
#     Step10:Detach UE
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${carrierAggregationSupportList}    ${actInterNumerologyCa}    ${flexibleCAMode}
#     ...    ${pucchModeSelect}    ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${numberOfTransmittedSsBlocks}    ${numberOfRxBeamforming}
#     ...    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
#     ...    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${sCellGoodChannelQualityThreshold}    ${sCellBadChannelQualityThreshold}
#     ...    ${sCellChannelEstimationPeriod}    ${actDl256Qam}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}
#     ...    ${sCellDeactivationBadRlqCount}    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}    ${actMeasBasedSCellAddition}    ${chBw}
# 	...    ${dlMimoMode}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE attach to cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:Send measurement report for A1 event to gNB
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=1    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_A1
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_A1/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:Initiate enough DL and UL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step4_UL_DL_data_256qam' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=7    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=8    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
# 	Wait Until Keyword Succeeds    90s    3s    check thp
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_UL_DL_data_256qam${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_UL_DL_data_256qam${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_UL_DL_data_256qam
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_UL_DL_data_256qam/output
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/case105_step4.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}step4_UL_DL_data_256qam
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_UL_DL_data_256qam' File
# 
# Step5:Detach UE
#     Start Collect GNB and AP Syslog in 'step5_Detach_UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Detach_UE' File
# 
# Step6:Change actDl256Qam is false
#     #Start Collect GNB and AP Syslog in 'step6_Change_parameter' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1    parameter=actDl256Qam    operation=update    value=false
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-2    parameter=actDl256Qam    operation=update    value=false
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-3    parameter=actDl256Qam    operation=update    value=false
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-4    parameter=actDl256Qam    operation=update    value=false
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    20
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_Change_parameter${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_Change_parameter${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_Change_parameter' File
# 
# Step7:Attach CA UE to cell1
#     #Start Collect GNB and AP Syslog in 'step7_UE_attach_again' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_UE_attach_again${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_UE_attach_again${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_UE_attach_again
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_UE_attach_again/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_UE_attach_again' File
# 
# Step8:Send measurement report for A1 event to gNB
#     #Start Collect GNB and AP Syslog in 'step8_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=1    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_send_A1' File
# 
# Step9:Initiate enough DL and UL data transfer for UE again
#     #Start Collect GNB and AP Syslog in 'step9_send_dl_data_64qam' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    6
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_send_dl_data_64qam${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_send_dl_data_64qam${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step9_send_dl_data_64qam
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step9_send_dl_data_64qam/output
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/case105_step9.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step9_send_dl_data_64qam
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_send_dl_data_64qam' File
# 
# Step10:Detach UE
#     Comment    Start Collect GNB and AP Syslog in 'step10_Detach UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step10_Detach UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# check thp
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
