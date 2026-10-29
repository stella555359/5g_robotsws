# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               QC case full name:
# ...               CNI_113494_Case3_PDSCH_iBLER_counters_for_PMI_beams
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    SBTS00
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# #${UE_ID}          8
# ${UE_NUM}         8
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${BEAR_ID}        2
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${mo}    com.nokia.srbts.nrbts:NRCELL
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|150|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${sCellActivationMinDataThreshold}    text|6000|//*[@name\="sCellActivationMinDataThreshold"]
# ${sCellActivationLevel}    text|1TTI|//*[@name\="sCellActivationLevel"]
# ${chBw1}    text|100MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${chBw2}    text|80MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
# ${chBw3}    text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw4}    text|80MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${pucchF3ModulationScheme}    text|qpsk_4psk|//*[@name\="pucchF3ModulationScheme"]
# ${actPerCsiReportBundlingTddFr1}    text|true|//*[@name\="actPerCsiReportBundlingTddFr1"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${pucchF3MaxCodeRate}    text|zeroDot15|//*[@name\="pucchF3MaxCodeRate"]
# ${srPeriodicity}    text|slots160|//*[@name\="srPeriodicity"]
# ${csiReportPeriodicity}    text|slots320|//*[@name\="csiReportPeriodicity"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${sCellDeactivationBadRlqCount}    text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${actDl256Qam}    text|false|//*[@name\="actDl256Qam"]
# ${actCsirsMultiplexing}    text|true|//*[@name\="actCsirsMultiplexing"]
# ${csirsNumberWithinReportPeriod_Set1}    text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# 
# ${miNrBeamforming2}    text|15min|//*[@name\="miNrBeamforming2"]
# ${miNrDlHarq}    text|15min|//*[@name\="miNrDlHarq"]
# ${miNrUlHarq}    text|15min|//*[@name\="miNrUlHarq"]
# ${miNrDlHarqLowSEMCS}    text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
# ${miNrUlHarqLowSEMCS}    text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
# ${miNrUlHarqOne}    text|15min|//*[@name\="miNrUlHarqOne"]
# 
# ${maxNumPuschAllocationPerSlot}         text|8|//*[@name\="maxNumPuschAllocationPerSlot"]
# ${maxNumPdschAllocationPerSlot}         text|8|//*[@name\="maxNumPdschAllocationPerSlot"]
# 
# 
# *** Test Cases ***
# CNI_113494_Case3_PDSCH_iBLER_counters_for_PMI_beams
#     Step1:Commission the above configuration on WebUI
#     Step2:open beaforming and attach to cell2
#     Step3:push DL_UL_data
#     Step4:Trigger_DL_Bler
# 	Step5:change SSBeamId
#     Step6:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     add_csirsBeamMgmt_list_in_cells    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${srPeriodicity}    ${csiReportPeriodicity}    ${chBw1}    ${chBw2}     ${actFdmScheduling}
#     ...    ${nrBtsBeamRefinementP2}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${dlMimoMode}    ${chBw3}    ${chBw4}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${actPdschAtSsbSlots}
#     ...    ${maxCsirsNumber}    ${pucchF3ModulationScheme}    ${actPerCsiReportBundlingTddFr1}     ${pucchF3MaxCodeRate}     ${sCellActivationLevel}
#     ...    ${sCellAdditionMethod}    ${sCellActivationMethod}    ${sCellActivationMinDataThreshold}    ${sCellDeactivationTimerGNB}
#     ...    ${numberOfRxBeamforming}    ${sCellDeactivationBadRlqCount}    ${actDl256Qam}
# 	...    ${actCsirsMultiplexing}    ${csirsNumberWithinReportPeriod_Set1}
# 	...    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}   ${miNrUlHarqOne} 	
# 	...    ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:open beaforming and attach to cell2
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1 csirs_bestbeam\=0 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0 csirs_bestbeam\=5 csirs_rsrp_best\=-45 csirs_rsrp_avg\=-120
#     FOR    ${ID}    IN RANGE    11    ${UE_NUM}+11
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8,9
#     END	
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=2
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     END
# 	Wait Throughput Timer    30	
# 	Start GNB Ttitrace With Streaming Mode		
# 	Wait Throughput Timer    2	
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step2_ue_attach/output	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# 
# Step3:push DL_UL_data
#     Start Collect GNB and AP Syslog in 'step3_push_data' File
#     #Start GNB BIP Log
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    100M    trf_id=1   duration=${3600}
#     END	
# 	Wait Throughput Timer    30
#     airphone_execute_egate_command    ${pmi_cmd}
# 	check thp
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    1	
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step3_push_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step3_push_data/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step3_push_data${/}
#     ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00030    cell_id=2
#     ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00031    cell_id=2 
#     ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00030    cell_id=3
#     ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00031    cell_id=3 
# 	${PDSCH_cell2_ibler}    Evaluate    float(${PDSCH_SUC_cell2})/float(${PDSCH_INI_cell2})
# 	${PDSCH_cell3_ibler}    Evaluate    float(${PDSCH_SUC_cell3})/float(${PDSCH_INI_cell3})		
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}		
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_push_data' File
# 
# Step4:Trigger_DL_Bler
#     Start Collect GNB and AP Syslog in 'step4_Trigger_DL_Bler' File
#     # Trigger DL bler 1st 10%,2th 10%,3th 10%     
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=3 dl_bler\=100,100,100
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11	
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=8,9 testmode\=bler profile_id\=3 action\=activate 	
#     END	
# 	Wait Throughput Timer    60	
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step4_Trigger_DL_Bler
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step4_Trigger_DL_Bler/output	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step4_Trigger_DL_Bler${/}
#     ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00030    cell_id=2
#     ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00031    cell_id=2 
#     ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00030    cell_id=3
#     ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55330C00031    cell_id=3 
# 	${PDSCH_cell2_ibler}    Evaluate    float(${PDSCH_SUC_cell2})/float(${PDSCH_INI_cell2})
# 	${PDSCH_cell3_ibler}    Evaluate    float(${PDSCH_SUC_cell3})/float(${PDSCH_INI_cell3})	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_Trigger_DL_Bler' File
# 
# 
# Step5:change SSBeamId
#     Start Collect GNB and AP Syslog in 'step5_change_beamid' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     FOR    ${ID}    IN RANGE    11    ${UE_NUM}+11
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=8
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=9
#     END
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}/step5_change_beamid
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}/step5_change_beamid/output	
# 	Wait Throughput Timer    60
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_change_beamid${/}	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/step5_change_beamid${/}	
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}			
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_change_beamid' File
# 
# 
# Step6:Detach UE
#     Start Collect GNB and AP Syslog in 'step6_Detach_UE' File
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone NSA Stop Data Traffic   ${UE_ID}    DL
#     Airphone NSA Stop Data Traffic   ${UE_ID}    UL
#     Airphone NSA Detach    ${UE_ID}
#     END
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     #should be true    ${Pcell_dl_throughput} > 0
#     #should be true    ${Scell_dl_throughput} > 0
#     END
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