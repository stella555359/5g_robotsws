# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...    QC case full name:
# ...    CB007113_case5_I4_single_layer_per_UE_MU_MIMO_with_less_than_AvailablePRBratio_L1PRB_ReqPRb
# ...    Z = rrmAvailablePuschRadioPrbForMu,Y = rrmRequiredMuPrbNum,X = rrmAvailablePuschL1PrbForMu           
# ...    Ratio = 1.1 by default,
# ...    This case will verify that when Z*Ratio < X*ratio < Y, Ues pairing with different UE layers. 
# ...    But the used PRBS are limited by X.           
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    SBTS00    RAN_5G_TDD    RAN_5G
# ...    owner_zhaoxu
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           string
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# #${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      gNB_scfc_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# 
# ${nrCellType_cell1}    text|8DL8UL|//*[contains(@distName, 'NRCELL-1')]/*[@name='nrCellType']
# ${nrCellType_cell2}    text|4DL4UL|//*[contains(@distName, 'NRCELL-2')]/*[@name='nrCellType']
# ${nrCellType_cell3}    text|4DL4UL|//*[contains(@distName, 'NRCELL-3')]/*[@name='nrCellType']
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}    text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${ssPbchBlockPower}    text|12|//*[@name\="ssPbchBlockPower"]
# ${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# #Activate the UE pooling CB007113
# ${actBbPoolTddFr1}    text|true|//*[@name\="actBbPoolTddFr1"]
# ${allowSlowPrbPoolingStatNdmSrs}    text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${actShortBsrLimitAdaptation}    text|true|//*[@name\="actShortBsrLimitAdaptation"]
# 
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|4Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}    text|2/8|//*[@name\="ulDlDataSlotRatio"]
# ${chBw_cell1}    text|60MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${chBw_cell2}    text|100MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
# ${chBw_cell3}    text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${actDlSrsBm}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actDlSrsBm']
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${prachConfigurationIndex}    text|156|//*[@name\="prachConfigurationIndex"]
# ${reqMinNumPuschPrb}    text|13|//*[@name\="reqMinNumPuschPrb"]
# 
# #enable CB008306
# ${actUlMuMimo}    text|true|//*[@name\="actUlMuMimo"]
# ${ulMuMimoSinrThd}    text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoCorrThd}    text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSpectralEffThd}    text|10|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoPrbThresholdAbsolute}    text|50|//*[contains(@distName, 'NRCELL-1')]/*[@name='ulMuMimoPrbThresholdAbsolute']
# #${ulMaxMuMimoLayer}    text|4|//*[@name\="ulMaxMuMimoLayer"]
# 
# ${ulMinPrbThreshold}    text|50|//*[@name\="ulMinPrbThreshold"]
# ${prbThreshRangeOne}    text|20|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}    text|20|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}    text|20|//*[@name\="prbThreshRangeThree"]
# ${ulMuMimoLinkAdaptionSwitch}    text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUlMuMimoTapering}    text|true|//*[@name\="actUlMuMimoTapering"]
# ${bSRS}    text|0|//*[@name\="bSRS"]
# ${cSRS}    text|42|//*[@name\="cSRS"]
# 
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${lowerEdgeAngle}                               text|120|//*[@name\="lowerEdgeAngle"]
# ${upperEdgeAngle}                               text|60|//*[@name\="upperEdgeAngle"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|15|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:216	   maxNumStreamPrbL1Sp:432	  maxNumWbStreamPrbL1Sp:432
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:432	   maxNumStreamPrbL1Sp:864	  maxNumWbStreamPrbL1Sp:864
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# 
# *** Test Cases ***
# CB007113_case5_I4_single_layer_per_UE_MU_MIMO_with_less_than_AvailablePRBratio_L1PRB_ReqPRb
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 3 rank1 Ues to 1st cell UE1 in H-15V0,UE2 in H-7V0,UE3 in H7V0
# 	Step3:Start transfer UL non-GBR data with the peak
# 	Step4:check PM counter
# 	Step5:Detach UE
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    4    0    12    0    12    0    12    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    2    0    5    0    5    0    5    0    1
#     Set Pos By Modify L1ByPTestModeConfiguration    25    0    23    0    23    0    23    0    2
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB007113   ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list    ${nrCellType_cell1}    ${nrCellType_cell2}   ${nrCellType_cell3} 
#     ...    ${dlMimoMode}    ${ulMimoMode}    ${ssPbchBlockPower}    ${nrBtsBeamRefinementP2}    ${pucchModeSelect}
#     ...    ${actBbPoolTddFr1}    ${allowSlowPrbPoolingStatNdmSrs}    ${actShortBsrLimitAdaptation}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${tdLteUlDlConfig}
#     ...    ${ulDlDataSlotRatio}    ${chBw_cell1}    ${chBw_cell2}    ${chBw_cell3}    ${actDlSrsBm}     
# 	...    ${actBeamforming}    ${prachConfigurationIndex}    ${reqMinNumPuschPrb}
#     ...    ${actUlMuMimo}   ${ulMuMimoSinrThd}    ${ulMuMimoCorrThd}    ${ulMuMimoSpectralEffThd}    
# 	...    ${ulMuMimoPrbThresholdAbsolute}  
#     ...    ${ulMinPrbThreshold}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}    
#     ...    ${ulMuMimoLinkAdaptionSwitch}    ${actUlMuMimoTapering}    
# 	...    ${bSRS}    ${cSRS}   
# 	...    ${srsUePeriodicity}       ${lowerEdgeAngle}    ${upperEdgeAngle}
#     ...    ${csirsNumberWithinReportPeriod_Set1}    	${csirsPower}    ${maxCsirsNumber}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
# 	modify_vendor_file_for_CB007113
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:attach 3 rank1 Ues to 1st cell UE1 in H-15V0,UE2 in H-7V0,UE3 in H7V0
#     Start Collect GNB and AP Syslog in 'Step2_attach_3UE' File
# 	Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2
# 	Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_3UE${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach_3UE${/}   unzip=TRUE
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_3UE' File	
# 
# Step3:Start transfer UL non-GBR data with the peak
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# 	Airphone SA Start Data Traffic    1    UL    60M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    60M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    UL    60M    trf_id=1    pdu_id=1    duration=${3600}	
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Wait Throughput Timer    8
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul	
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# 
# Step4:check PM counter
# 	#${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10004    cell_id=1	
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35004    cell_id=1	
# 	${PM_PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1	
# 	${PM_PRB_UL_MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
# 		
# 
# Step5:Detach UE
#     Start Collect GNB and AP Syslog in 'Step5_detach' File
#     airphone_sa_stop_data_traffic    1   UL    pdu_id=1
#     airphone_sa_stop_data_traffic    2   UL    pdu_id=1	
#     airphone_sa_stop_data_traffic    3   UL    pdu_id=1		
#     airphone_sa_detach    1
#     airphone_sa_detach    2	
#     airphone_sa_detach    3		
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_detach' File
# 
# 
# 
# 
# 
