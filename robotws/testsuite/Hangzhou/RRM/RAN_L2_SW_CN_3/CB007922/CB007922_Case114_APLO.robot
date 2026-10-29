# *** Settings ***
# Documentation     example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case114_D_B_3_A1_addition_and_RLQ-based_SCell_deactivation_with_Bf
# ...
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    
#    ...    SBTS00    SBTS23R1    owner_yulili AP
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# ** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 
#    ...    pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
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
# ${sCellGoodChannelQualityThreshold}    text|22|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}    text|15|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}    text|false|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|50|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${chBw}           text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${sCellDeactivationBadRlqCount}       text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellDeactivationTimerGNB}         text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# 
# *** Test Cases ***
# CB007922_Case114_D_B_3_A1_addition_and_RLQ-based_SCell_deactivation_with_Bf
#     Step1:Commission the above configuration on WebUI
#     Step2:UE attach to cell2
#     Step3:send A1 report
#     Step4:push DL and UL full data to UE
#     Step5:keep big DL data transfer,override scell CQI to bad but not reach bad scell RLQ threshold
#     Step6:keep big DL data transfer,override scell CQI to reach bad scell RLQ threshold
#     Step7:keep big DL data transfer,override scell CQI to reach good scell RLQ threshold
#     Step8:keep big DL data transfer,override scell CQI to reach bad scell RLQ threshold for more than 200s
#     Step9:keep big DL data transfer,override scell CQI to good again
#     Step10:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${carrierAggregationSupportList}    ${actInterNumerologyCa}    
#    ...    ${flexibleCAMode}    ${pucchModeSelect}
#     ...    ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${cellDepType}    ${actCDrx}    
#    ...    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    
#    ...    ${sCellGoodChannelQualityThreshold}     ${nrCellType}
#     ...    ${sCellBadChannelQualityThreshold}    ${sCellChannelEstimationPeriod}    ${actDl256Qam}    
#    ...    ${sCellAdditionMethod}    ${maxNumScellsDl}
#     ...    ${actFdmScheduling}    ${sCellDeactivationBadRlqCount}    ${sCellActivationMethod}   
#    ...     ${a1MeasSCellAddEnabled}    ${chBw}    ${dlMimoMode}
#     ...    ${a1ThresholdSCellAddSsbRsrpTDD}      ${sCellDeactivationBadRlqCount}     
#    ...    ${sCellDeactivationTimerGNB}    ${actMeasBasedSCellAddition}
#     ...    ${numberOfRxBeamforming}      ${numberOfTransmittedSsBlocks}     ${basicBeamSet}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#    ...        reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE attach to cell2
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     #    open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 
#    ...    ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control 
#    ...    action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:send A1 report
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 
#    ...    srsrp_nr\=80    pass_regexp=sCellToAddModList
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_A1
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_A1/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:push DL and UL full data to UE
#     Start Collect GNB and AP Syslog in 'step4_DL_UL_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_DL_UL_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_DL_UL_data${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_DL_UL_data
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_DL_UL_data/output
#     Wait Throughput Timer    20
#     airphone_execute_egate_command    ${pmi_cmd}
#     Wait Until Keyword Succeeds    90s    3s    check thp
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput}>60000
#     should be true    ${Scell_dl_throughput}>60000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_DL_UL_data' File
# 
# Step5:keep big DL data transfer,override scell CQI to bad but not reach bad scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'step5_override_cqi_nottoobad' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=8
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=1 scell\=1
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_override_cqi_nottoobad${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_override_cqi_nottoobad${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_override_cqi_nottoobad
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_override_cqi_nottoobad/output
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 10000
#     should be true    ${Scell_dl_throughput} > 10000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_override_cqi_nottoobad' File
# 
# Step6:keep big DL data transfer,override scell CQI to reach bad scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'step6_override_cqi_bad' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=2 scell\=1
#     #Wait Throughput Timer    20
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_override_cqi_bad${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_override_cqi_bad${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_override_cqi_bad
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_override_cqi_bad/output
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0   
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1   
#    ...     type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 30000
#     should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_override_cqi_bad' File
# 
# Step7:keep big DL data transfer,override scell CQI to reach good scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'step7_overide_cqi_good' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=1 scell\=1
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_overide_cqi_good${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_overide_cqi_good${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_overide_cqi_good
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_overide_cqi_good/output
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 30000
#     should be true    ${Scell_dl_throughput} > 30000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_overide_cqi_good' File
# 
# Step8:keep big DL data transfer,override scell CQI to reach bad scell RLQ threshold for more than 200s
#     #Start Collect GNB and AP Syslog in 'step8_override_cqi_bad_longtime' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=2 scell\=1
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_override_cqi_bad_longtime${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_override_cqi_bad_longtime${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}
#    ...    step8_override_cqi_bad_longtime
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_override_cqi_bad_longtime/output
#     Wait Throughput Timer    300
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0   
#    ...     type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 30000
#     should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_override_cqi_bad_longtime' File
# 
# Step9:keep big DL data transfer,override scell CQI to good again
#     Start Collect GNB and AP Syslog in 'step9_override_cqi_good' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=1 scell\=1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_override_cqi_good${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step9_override_cqi_good${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step9_override_cqi_good
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step9_override_cqi_good/output
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    
#    ...    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 30000
#     should be true    ${Scell_dl_throughput} == 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_override_cqi_good' File
# 
# Step10:Detach UE
#     Start Collect GNB and AP Syslog in 'Step10_Detach_UE' File
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate 
#    ...    profile_id\=1 scell\=1
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step10_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band 
#    ...    CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# check thp
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   
#    ...     scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    
#    ...    scell_id=1    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
