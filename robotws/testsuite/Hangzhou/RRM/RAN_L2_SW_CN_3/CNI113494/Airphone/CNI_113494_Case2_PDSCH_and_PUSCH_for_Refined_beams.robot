# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               check PDSCH and PUSCH refined beam ibler counters
# ...               M55330C00047,M55330C00048,M55330C00028,M55330C00029
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    SBTS00    zhaoxu
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_4S_1CC_CNI113494.cfg
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
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
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
# #${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${chBw}           text|80MHz|//*[@name\="chBw"]
# ${actPdschRmCsirsForTracking}    text|true|//*[@name\="actPdschRmCsirsForTracking"]
# 
# ${miNrBeamforming2}    text|15min|//*[@name\="miNrBeamforming2"]
# ${miNrDlHarq}    text|15min|//*[@name\="miNrDlHarq"]
# ${miNrUlHarq}    text|15min|//*[@name\="miNrUlHarq"]
# ${miNrDlHarqLowSEMCS}    text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
# ${miNrUlHarqLowSEMCS}    text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
# ${miNrUlHarqOne}    text|15min|//*[@name\="miNrUlHarqOne"]
# 
# 
# ${BEAM_SET_2}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5 
# ...    csirs_bestbeam\=2 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BEAM_SET_5}    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=0,1,2,3,4,5 
# ...    csirs_bestbeam\=5 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# 
# ${BEAM_action_pcell}    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0
# ${BEAM_action_scell}    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=1
# ${BEAM_switch}    ue_testmode_set_nr id\=1 scell\=0,1 testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch
# 
# 
# *** Test Cases ***
# CNI_113494_Case2_PDSCH_and_PUSCH_iBLER_counters_for_Refined_beams
#     Step1:Set parameter and wait for onair
#     Step2:UE attach to cell
#     Step3:Send measurement report for A1 event to gNB
#     Step4:Initiate enough DL and UL data transfer for UE
# 	Step5:Trigger_DL_Bler
# 	Step6:Beam_switch
#     Step7:Detach UE
# 
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_csirsBeamMgmt_list_in_cells    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${carrierAggregationSupportList}    ${actInterNumerologyCa}    ${flexibleCAMode}
#     ...    ${pucchModeSelect}    ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${numberOfTransmittedSsBlocks}    ${numberOfRxBeamforming}
#     ...    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
#     ...    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${sCellGoodChannelQualityThreshold}    ${sCellBadChannelQualityThreshold}
#     ...    ${sCellChannelEstimationPeriod}    ${actDl256Qam}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}
#     ...    ${sCellDeactivationBadRlqCount}    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}    ${chBw}
# 	...    ${dlMimoMode}    ${actPdschRmCsirsForTracking}    
# 	...    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}   ${miNrUlHarqOne} 
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE attach to cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
# 	Set SSB Beam
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:Send measurement report for A1 event to gNB
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=1    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     Wait Throughput Timer    5
# 	airphone_execute_egate_command    ${BEAM_action_scell}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_A1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_A1/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:Initiate enough DL and UL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step4_UL_DL_data_256qam' File
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=7    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=8    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    150M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    150M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    150M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}	
# 	Wait Until Keyword Succeeds    30s    3s    check thp
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step4_UL_DL_data_256qam
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step4_UL_DL_data_256qam/output
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step4_UL_DL_data_256qam${/}	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_UL_DL_data_256qam' File
# 
# Step5:Trigger_DL_Bler
#     Start Collect GNB and AP Syslog in 'step5_Trigger_DL_Bler' File
#     # Trigger DL bler 1st 10%,2th 10%,3th 10%     
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=3 dl_bler\=100,100,100
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0,1 testmode\=bler profile_id\=3 action\=activate 
# 	Wait Throughput Timer    10	
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step5_Trigger_DL_Bler
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step5_Trigger_DL_Bler/output	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step5_Trigger_DL_Bler${/}
#     ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00047    cell_id=1
#     ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00048    cell_id=1 
#     ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00047    cell_id=2
#     ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00048    cell_id=2 
# 	${PDSCH_cell1_ibler}    Evaluate    float(${PDSCH_SUC_cell1})/float(${PDSCH_INI_cell1})
# 	${PDSCH_cell2_ibler}    Evaluate    float(${PDSCH_SUC_cell2})/float(${PDSCH_INI_cell2})	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Trigger_DL_Bler' File
# 
# Step6:Beam_switch
#     Start Collect GNB and AP Syslog in 'step6_Beam_switch' File
# 	Start GNB Ttitrace With Streaming Mode	
#     airphone_execute_egate_command    ${BEAM_switch}
# 	Wait Throughput Timer    3	
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step6_Beam_switch
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step6_Beam_switch/output
# 	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step6_Beam_switch${/}
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_Beam_switch' File
# 
# Step7:Detach UE
#     Start Collect GNB and AP Syslog in 'step7_Detach_UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_Detach_UE' File
# 
# 
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
# 
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET_2}
#     airphone_execute_egate_command    ${BEAM_SET_5}	
#     airphone_execute_egate_command    ${BEAM_action_pcell}
# 	
# 	
# Check_CNI113494_iBler_match_Legacy_counters
#     [Arguments]    ${PM_counter_file}	
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
# 	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
# 	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
# 	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
#     ${PDSCH_INI_All_Beam_counter_cell1}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell2}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell3}    	create list
#     ${PDSCH_INI_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
#     ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
#     ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
#     ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell3}    ${PDSCH_INI_cell3}
#     ${PDSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell4}    ${PDSCH_INI_cell4}	
# 	END
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}	
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_INI_All_Beam_counter_cell3}	
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_INI_All_Beam_counter_cell4}
# 	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
# 	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})
# 	${PDSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell3})    
# 	${PDSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell4})	
#     Log To Console    \n----------------------end-------------------------
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
# 	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
# 	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
# 	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
#     ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell2}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell3}    	create list
#     ${PDSCH_SUC_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
#     ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
#     ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
#     ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell3}    ${PDSCH_SUC_cell3}
#     ${PDSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell4}    ${PDSCH_SUC_cell4}	
# 	END
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}	
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_SUC_All_Beam_counter_cell3}	
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_SUC_All_Beam_counter_cell4}
# 	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
# 	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})
# 	${PDSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell3})    
# 	${PDSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell4})	
# 	Log To Console    \n----------------------end-------------------------			
#     Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
# 	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
#     ${PUSCH_INI_All_Beam_counter_cell1}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell2}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell3}    	create list
#     ${PUSCH_INI_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
#     ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
#     ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
#     ${PUSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell3}    ${PUSCH_INI_cell3}
#     ${PUSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell4}    ${PUSCH_INI_cell4}	
# 	END	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_INI_All_Beam_counter_cell3}	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_INI_All_Beam_counter_cell4}
# 	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
# 	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
# 	${PUSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell3})    
# 	${PUSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell4})
#     Log To Console    \n----------------------end-------------------------	
# 	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
# 	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
#     ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell3}    	create list
#     ${PUSCH_SUC_All_Beam_counter_cell4}    	create list	
#     FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
#     ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
#     ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}
#     ${PUSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell3}    ${PUSCH_SUC_cell3}
#     ${PUSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell4}    ${PUSCH_SUC_cell4}		
# 	END		
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}	
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_SUC_All_Beam_counter_cell3}	
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_SUC_All_Beam_counter_cell4}
# 	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
# 	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
# 	${PUSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell3})    
# 	${PUSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell4})
#     Log To Console    \n----------------------end-------------------------	
# 	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
# 	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
# 	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}    	create list
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell4}    	create list	
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell4}    	create list	
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}    	create list		
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell4}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=3
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=4
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell3:${PDSCH_INITX_64TBL_MCS_00_28_cell3}
#     Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell4:${PDSCH_INITX_64TBL_MCS_00_28_cell4}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell3:${PDSCH_INITX_256TBL_MCS_00_27_cell3}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell4:${PDSCH_INITX_256TBL_MCS_00_27_cell4}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell3:${PDSCH_INITX_LOWSE_MCS_00_28_cell3}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell4:${PDSCH_INITX_LOWSE_MCS_00_28_cell4}
# 	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
# 	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
# 	${PDSCH_INITX_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell3})
# 	${PDSCH_INITX_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell4})	
# 	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
# 	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})
# 	${PDSCH_INITX_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell3})
# 	${PDSCH_INITX_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell4})		
# 	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
# 	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})
# 	${PDSCH_INITX_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell3})
# 	${PDSCH_INITX_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell4})		
#     ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
#     ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}	
#     ${PDSCH_LG_INITX_Sum_cell3}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell3}+${PDSCH_INITX_256TBL_Sum_cell3}+${PDSCH_INITX_LOWSE_Sum_cell3}
#     ${PDSCH_LG_INITX_Sum_cell4}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell4}+${PDSCH_INITX_256TBL_Sum_cell4}+${PDSCH_INITX_LOWSE_Sum_cell4}	
#     Log To Console    \n----------------------end-------------------------
# 	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
# 	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
# 	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}    	create list
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell4}    	create list	
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell4}    	create list	
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}    	create list		
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell4}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=3
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=4
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell3:${PDSCH_SUC_64TBL_MCS_00_28_cell3}
#     Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell4:${PDSCH_SUC_64TBL_MCS_00_28_cell4}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell3:${PDSCH_SUC_256TBL_MCS_00_27_cell3}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell4:${PDSCH_SUC_256TBL_MCS_00_27_cell4}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell3:${PDSCH_SUC_LOWSE_MCS_00_28_cell3}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell4:${PDSCH_SUC_LOWSE_MCS_00_28_cell4}
# 	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
# 	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
# 	${PDSCH_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell3})
# 	${PDSCH_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell4})	
# 	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
# 	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})
# 	${PDSCH_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell3})
# 	${PDSCH_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell4})		
# 	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
# 	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})
# 	${PDSCH_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell3})
# 	${PDSCH_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell4})		
#     ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
#     ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}	
#     ${PDSCH_LG_SUC_Sum_cell3}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell3}+${PDSCH_SUC_256TBL_Sum_cell3}+${PDSCH_SUC_LOWSE_Sum_cell3}
#     ${PDSCH_LG_SUC_Sum_cell4}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell4}+${PDSCH_SUC_256TBL_Sum_cell4}+${PDSCH_SUC_LOWSE_Sum_cell4}
#     Log To Console    \n----------------------end-------------------------
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
# 	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
# 	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
# 	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013		
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}    	create list		
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}    	create list	
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}    	create list			
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}    	create list		
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=3
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}   ${DFT_64}		
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=3
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=4
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=4
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END		
# 	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
# 	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
# 	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2	
# 	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2
# 	${INI_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=3	
# 	${INI_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=3	
# 	${INI_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=4	
# 	${INI_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=4
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell3:${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell4:${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}	
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell3:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell4:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell3:${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell4:${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}		
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell3:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell4:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}	
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell3:${INI_SAG_R2_C3}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell4:${INI_SAG_R2_C4}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell3:${INI_SAG_R4_C3}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell4:${INI_SAG_R4_C4}	
# 	
# 	
# 	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
# 	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
# 	${CP_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell3})
# 	${CP_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell4})
# 	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
# 	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})
# 	${DFT_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3})
# 	${DFT_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4})	
# 	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
# 	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})
# 	${CP_INI_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell3})
# 	${CP_INI_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell4})	
# 	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
# 	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
# 	${CP_INI_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3})
# 	${CP_INI_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4})	
#     ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
#     ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
#     ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
#     ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}	
#     ${PUSCH_LG_INI_Sum_cell3_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell3}+${DFT_INI_64TBL_Sum_cell3}+${CP_INI_256TBL_Sum_cell3}
#     ${PUSCH_LG_INI_Sum_cell3}    Evaluate    ${PUSCH_LG_INI_Sum_cell3_tmp}+${CP_INI_LOWSE_Sum_cell3}+${INI_SAG_R2_C3}+${INI_SAG_R4_C3}	
#     ${PUSCH_LG_INI_Sum_cell4_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell4}+${DFT_INI_64TBL_Sum_cell4}+${CP_INI_256TBL_Sum_cell4}
#     ${PUSCH_LG_INI_Sum_cell4}    Evaluate    ${PUSCH_LG_INI_Sum_cell4_tmp}+${CP_INI_LOWSE_Sum_cell4}+${INI_SAG_R2_C4}+${INI_SAG_R4_C4}
#     Log To Console    \n----------------------end-------------------------	
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
# 	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
# 	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015	
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}    	create list		
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}    	create list	
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}    	create list			
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}    	create list
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}    	create list		
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
# 	END
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=3
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}   ${DFT_64}		
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=3
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=4
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=4
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
# 	END		
# 	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
# 	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
# 	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2	
# 	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2
# 	${SUC_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=3	
# 	${SUC_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=3	
# 	${SUC_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=4	
# 	${SUC_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=4
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell3:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell4:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}	
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell3:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell4:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}		
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell3:${SUC_SAG_R2_C3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell4:${SUC_SAG_R2_C4}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell3:${SUC_SAG_R4_C3}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell4:${SUC_SAG_R4_C4}	
# 	
# 	
# 	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
# 	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
# 	${CP_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3})
# 	${CP_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4})
# 	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
# 	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})
# 	${DFT_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3})
# 	${DFT_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4})	
# 	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
# 	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})
# 	${CP_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3})
# 	${CP_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4})	
# 	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
# 	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})
# 	${CP_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3})
# 	${CP_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4})	
#     ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
#     ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
#     ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
#     ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}	
#     ${PUSCH_LG_SUC_Sum_cell3_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell3}+${DFT_SUC_64TBL_Sum_cell3}+${CP_SUC_256TBL_Sum_cell3}
#     ${PUSCH_LG_SUC_Sum_cell3}    Evaluate    ${PUSCH_LG_SUC_Sum_cell3_tmp}+${CP_SUC_LOWSE_Sum_cell3}+${SUC_SAG_R2_C3}+${SUC_SAG_R4_C3}	
#     ${PUSCH_LG_SUC_Sum_cell4_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell4}+${DFT_SUC_64TBL_Sum_cell4}+${CP_SUC_256TBL_Sum_cell4}
#     ${PUSCH_LG_SUC_Sum_cell4}    Evaluate    ${PUSCH_LG_SUC_Sum_cell4_tmp}+${CP_SUC_LOWSE_Sum_cell4}+${SUC_SAG_R2_C4}+${SUC_SAG_R4_C4}
#     Log To Console    \n----------------------end-------------------------		
#     Log To Console    \n----------------------All Counter Summary-------------------------
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2} 
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell3--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell3:${PDSCH_INI_counter_Sum_cell3}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell3:${PDSCH_SUC_counter_Sum_cell3}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_INITX_Sum_cell3}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_SUC_Sum_cell3}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell3}==${PDSCH_LG_INITX_Sum_cell3}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell3}==${PDSCH_LG_SUC_Sum_cell3} 
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell4--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell4:${PDSCH_INI_counter_Sum_cell4}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell4:${PDSCH_SUC_counter_Sum_cell4}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_INITX_Sum_cell4}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_SUC_Sum_cell4}	
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell4}==${PDSCH_LG_INITX_Sum_cell4}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell4}==${PDSCH_LG_SUC_Sum_cell4} 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 		
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}		
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2} 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell3--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell3:${PUSCH_INI_counter_Sum_cell3} 
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell3:${PUSCH_SUC_counter_Sum_cell3}	
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_INI_Sum_cell3}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_SUC_Sum_cell3}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell3}==${PUSCH_LG_INI_Sum_cell3}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell3}==${PUSCH_LG_SUC_Sum_cell3} 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell4--------		
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell4:${PUSCH_INI_counter_Sum_cell4}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell4:${PUSCH_SUC_counter_Sum_cell4}	
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_INI_Sum_cell4}
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_SUC_Sum_cell4}	    
# 	run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell4}==${PUSCH_LG_INI_Sum_cell4}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell4}==${PUSCH_LG_SUC_Sum_cell4} 	
# 		