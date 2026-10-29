# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case163_D_A_12_interL2RT_interBand_Single_UE_DL_UL_SSBBF_A1_SCell_addition_RLQ_deactivation_A2_Scell_release_SA
# ...
# ...               Single UE connection setup and DL/UL data scheduling in SA option 2 with BF and A1/A2 measurement based SCell addition/release
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
# ...   owner_jiangzhaona    AP
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# #${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}     text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrCellType}     text|4DL4UL|//*[@name\="nrCellType"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}    text|true|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|50|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${chBw1}           text|60MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${chBw3}           text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw4}           text|60MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${sCellDeactivationTimerGNB}        text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${sCellBadChannelQualityThreshold}        text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellGoodChannelQualityThreshold}        text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${a2MeashoEnabledSA}        text|rsrp|//*[@name\="a2MeashoEnabledSA"]
# ${a2MeasSCellRelEnabled}    text|rsrp|//*[@name\="a2MeasSCellRelEnabled"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case163_D_A_12_interL2RT_interBand_Single_UE_DL_UL_SSBBF_A1_SCell_addition_RLQ_deactivation_A2_Scell_release_SA
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE to NR cell
#     Step3:Send A1 measurement
#     Step4:Start enough DL/UL data
#     Step5:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold
#     Step6:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Step7:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold more than 100s
#     Step8:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Step9:Send A2 measurement
#     Step10:Repeat step 2 3 , scell add and active again
#     Step11:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${sCellGoodChannelQualityThreshold}
#     ...    ${sCellBadChannelQualityThreshold}    ${sCellChannelEstimationPeriod}    ${actDl256Qam}    ${sCellAdditionMethod}    ${maxNumScellsDl}
#     ...    ${actFdmScheduling}    ${sCellDeactivationBadRlqCount}    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}
#     ...    ${chBw1}      ${chBw4}    ${a1ThresholdSCellAddSsbRsrpTDD}    ${nrCellType}    ${dlMimoMode}    ${tdLteUlDlConfig}
#     ...    ${a2MeashoEnabledSA}    ${a2MeasSCellRelEnabled}    ${sCellDeactivationTimerGNB}    ${actMeasBasedSCellAddition}
# 	...    ${chBw3}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE to NR cell
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Set SSB Beam
#     Airphone Location Change    id=${UE_ID}    cell_id=4
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send A1 measurement
#     Start Collect GNB and AP Syslog in 'Step3_A1' File
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_A1' File
# 
# Step4:Start enough DL/UL data
#     Start Collect GNB and AP Syslog in 'Step4_DL_UL_data' File
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_DL_UL_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_DL_UL_data/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_DL_UL_data
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	${2cells_dl_throughput} =       evaluate        ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${2cells_dl_throughput} > 250
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_DL_UL_data/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_DL_UL_data' File
# 
# Step5:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step5_RLQ_bad' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=activate
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_RLQ_bad
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_RLQ_bad/output
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step5_RLQ_bad' File
# 
# Step6:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step6_RLQ_good' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=deactivate
#     Start GNB Ttitrace With Streaming Mode
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_RLQ_good
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_RLQ_good/output
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_RLQ_good' File
# 
# Step7:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold more than 100s
#     Start Collect GNB and AP Syslog in 'Step7_RLQ_bad_100s' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=activate
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer     8
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     Wait Throughput Timer     100
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s   unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_scell_deactivate.ini
#     ...    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s/tti    #decode need time some mins
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step7_RLQ_bad_100s' File
# 
# Step8:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step8_RLQ_good_scell_no' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=deactivate
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8_RLQ_good_scell_no${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8_RLQ_good_scell_no${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    10
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step8_RLQ_good_scell_no
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step8_RLQ_good_scell_no/output
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step8_RLQ_good_scell_no' File
# 
# Step9:Send A2 measurement
#     Start Collect GNB and AP Syslog in 'Step9_trigger_a2' File
# 	Start GNB Ttitrace With Streaming Mode
# 	airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=2 event=A2 scell=1 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
# 	wait Throughput Timer    3
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step9_trigger_a2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step9_trigger_a2/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step9_trigger_a2' File
# 
# Step10:Repeat step 2 3 , scell add and active again
#     Start Collect GNB and AP Syslog in 'Step10_Scell_add_again' File
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Start GNB Ttitrace With Streaming Mode
#     wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step10_Scell_add_again
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	${2cells_dl_throughput} =       evaluate        ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${2cells_dl_throughput} > 250
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step10_Scell_add_again/tti
# 
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step10_Scell_add_again' File
# 
# Step11:Detach UE
#     Start Collect GNB and AP Syslog in 'Step11_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step11_detach' File
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
