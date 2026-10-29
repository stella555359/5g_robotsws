# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case140_D_A_4b_intraL2RT_intraBand_Single_UE_A1_Scell_addition_and_RLQ_deactivation_A2_Scell_release_ssbBF_NSA
# ...
# ...               Single UE EN-DC connection setup and DL/UL data scheduling in NSA option 3x with BF and A1/A2 measurement based SCell
# ...               addition/release
# 
# #Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# #Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# #Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS23R1    CRT
# #...   owner_jiangzhaona    AP
# #Test Timeout      60 minutes
# #Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# #Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# #Library           ta_a2a
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# #Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_7922.xml
# ${CU_SCF}             scfc_VCU_7922.xml
# ${AIRPHONE_NAME}      iphy_7922.xml
# ${WTS_NAME}           basic_setup_7922.cfg
# 
# #${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# #${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# #${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# #${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}        11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# #${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${sCellDeactivationBadRlqCount}    text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellChannelEstimationPeriod}    text|400|//*[@name\="sCellChannelEstimationPeriod"]
# ${sCellBadChannelQualityThreshold}        text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellGoodChannelQualityThreshold}        text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${a2MeasSCellRelEnabled}    text|rsrp|//*[@name\="a2MeasSCellRelEnabled"]
# ${a2ThresholdSCellRelSsbRsrp}    text|34|//*[@name\="a2ThresholdSCellRelSsbRsrp"]
# ${chBw}           text|50MHz|//*[@name='chBw']
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case140_D_A_4b_intraL2RT_intraBand_Single_UE_A1_Scell_addition_and_RLQ_deactivation_A2_Scell_release_ssbBF_NSA_vran
#     Step1:Configure parameters as descript in precondition
#     Step2:Attach UE to LTE cell,build EN-DC
#     Step3:Send A1 measurement
#     Step4:Start enough DL/UL data
#     Step5:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold
#     Step6:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Step7:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold for more than 100s
#     Step8:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Step9:Send A2 measurement
#     Step10:Send A1 measurement
#     Step11:Detach ue
# 
# *** Keywords ***
# Step1:Configure parameters as descript in precondition
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     #change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     #${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     #copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_7922.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
# 
#     ${vCU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VCU_7922.xml
#     copy_file    ${CONFIG_DIR_PATH}/${CU_SCF}   ${vCU_scfc_path}
# 
#     #add_ca_relation_CB7922    ${vDU_scfc_path}
# 
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${actCDrx}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}
#     ...    ${tdLteUlDlConfig}    ${sCellActivationMethod}    ${actFdmScheduling}
#     ...    ${sCellDeactivationTimerGNB}    ${sCellDeactivationBadRlqCount}    ${sCellChannelEstimationPeriod}
#     ...    ${sCellBadChannelQualityThreshold}    ${sCellGoodChannelQualityThreshold}    ${chBw}    ${numberOfRxBeamforming}
#     #...    ${dlMimoMode}    ${actPdschAtSsbSlots}
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
# 
#     #modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     #Modify TL VM And AP SCTP Configuration
#     #Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 
#     ${modify_list_CU}    create list    ${sCellAdditionMethod}    ${maxNumScellsDl}
#     ...    ${a1MeasSCellAddEnabled}    ${a1ThresholdSCellAddSsbRsrpTDD}    ${a2MeasSCellRelEnabled}    ${a2ThresholdSCellRelSsbRsrp}
#     modify_xml   ${vCU_scfc_path}   ${vCU_scfc_path}    ${modify_list_CU}
# 
#     Modify TL VM And AP SCTP Configuration
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${vCU_scfc_path}
#     #AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE to LTE cell,build EN-DC
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=1
#     #Set UE_${UE_ID} SSB Beam
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Send A1 measurement
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:Start enough DL/UL data
#     Start Collect GNB and AP Syslog in 'step4_send_data' File
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M    trf_id=5    duration=${3600}
# 
#     #Capture tti for 8s in step4_send_data
# 
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}step4_send_data/ttiTrace
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step4_send_data
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_ul_140.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 250000
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 250000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_send_data' File
# 
# Step5:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step5_RLQ_bad' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=activate
# 	#Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    20
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_RLQ_bad
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_RLQ_bad/output
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step5_RLQ_bad' File
# 
# Step6:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step6_RLQ_good' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    20
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
#     #${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0
#     
#     #Start GNB Ttitrace With Streaming Mode
# 	#Wait Throughput Timer    8
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_RLQ_good
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_RLQ_good/output
# 	
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step6_RLQ_good/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_RLQ_good' File
# 
# Step7:Keep big DL data transfer, override scell CQI to reach bad scell RLQ threshold for more than 100s
#     Start Collect GNB and AP Syslog in 'Step7_RLQ_bad_100s' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=activate
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
# 	run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
#     
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer     8
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s/output    #decode need time some mins
# 	
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step7_RLQ_bad_100s/ttiTrace
# 
#     Wait Throughput Timer    60
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_RLQ_bad_100s' File
# 
# Step8:Keep big DL data transfer, override scell CQI to reach good scell RLQ threshold
#     Start Collect GNB and AP Syslog in 'Step8_RLQ_good_scell_no' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=2 testmode\=bler profile_id\=1 action\=deactivate
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    8
# 
#     ${id}    VDU Start TTiTrace Log
#     Wait '8s' for stable
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
#     run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} == 0
# 	
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step8_RLQ_good_scell_no
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step8_RLQ_good_scell_no/output
# 	
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step8_RLQ_good_scell_no/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_RLQ_good_scell_no' File
# 
# Step9:Send A2 measurement
#     Start Collect GNB and AP Syslog in 'Step9_trigger_a2' File
# 	airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A2 scell=2 scell_rsrp=20
#     airphone_execute_egate_command    ${cmd}    pass_regexp=sCellToReleaseList
# 	
# 	#Start GNB Ttitrace With Streaming Mode
# 	#wait Throughput Timer    2
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step9_trigger_a2
# 	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step9_trigger_a2/output
# 
#     ${id}    VDU Start TTiTrace Log
#     Wait '2s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}Step9_trigger_a2/ttiTrace
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step9_trigger_a2' File
# 
# Step10:Send A1 measurement
#     Start Collect GNB and AP Syslog in 'step10_send_A1' File
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step10_send_A1' File
# 
# Step11:Detach ue
#     Airphone NSA Detach    ${UE_ID}
# 
# Set UE_${UE_ID} SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=secondary
# 
# wait ${time} to check log
#     sleep    ${time}
# 
# Capture tti for ${ttiduring} in ${ttipath}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    ${ttiduring}
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${ttipath}
# 	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${ttipath}/tti
# 
#     ${id}    VDU Start TTiTrace Log
#     #Wait ${ttiduring} for stable
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}${ttipath}/ttiTrace
# 
# Check ${ttipath} ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${ttipath}
