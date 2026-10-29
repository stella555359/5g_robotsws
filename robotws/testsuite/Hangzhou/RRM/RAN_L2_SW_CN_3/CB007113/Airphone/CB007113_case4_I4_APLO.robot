# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...    QC case full name:
# ...    CB007113_case4_I4_single_layer_per_UE_MU_MIMO_with_less_than_L1PRB_AvailablePRBratio_AvailablePRBratio
# ...    Z = rrmAvailablePuschRadioPrbForMu,Y = rrmRequiredMuPrbNum,X = rrmAvailablePuschL1PrbForMu           
# ...    Ratio = 1.1 by default,
# ...    This case will verify that when X < Z*Ratio < Y, Two Ues pair only for 1+1 layer, 
# ...    No pairing for Ues with 2+2 layers or 2+1 layers, or 1+1+1 layers.           
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD    AP    SBTS00    RAN_5G_TDD    RAN_5G
# ...    CRT    owner_zhaoxu
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
# ${SCFC_NAME}      gNB_scfc_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_3S_1CC_LOOO.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_LOOO_3S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC.cfg
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
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# #Activate the UE pooling CB007113
# ${actBbPoolTddFr1}    text|true|//*[@name\="actBbPoolTddFr1"]
# ${allowSlowPrbPoolingStatNdmSrs}    text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${actShortBsrLimitAdaptation}    text|true|//*[@name\="actShortBsrLimitAdaptation"]
# 
# ${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${actDlSrsBm}    text|false|//*[@name\="actDlSrsBm"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# 
# #enable CB008306
# ${actUlMuMimo_cell1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actUlMuMimo']
# ${actUlMuMimo_cell2}    text|false|//*[contains(@distName, 'NRCELL-2')]/*[@name='actUlMuMimo']
# ${actUlMuMimo_cell3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actUlMuMimo']
# ${ulMuMimoSinrThd}    text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoCorrThd}    text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSpectralEffThd}    text|10|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMaxMuMimoLayer_cell1}    text|4|//*[contains(@distName, 'NRCELL-1')]/*[@name='ulMaxMuMimoLayer']
# ${ulMaxMuMimoLayer_cell2}    text|2|//*[contains(@distName, 'NRCELL-2')]/*[@name='ulMaxMuMimoLayer']
# ${ulMaxMuMimoLayer_cell3}    text|2|//*[contains(@distName, 'NRCELL-3')]/*[@name='ulMaxMuMimoLayer']
# 
# ${ulMinPrbThreshold}    text|50|//*[@name\="ulMinPrbThreshold"]
# ${prbThreshRangeOne}    text|20|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}    text|20|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}    text|20|//*[@name\="prbThreshRangeThree"]
# ${ulMuMimoLinkAdaptionSwitch}    text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUlMuMimoTapering}    text|false|//*[@name\="actUlMuMimoTapering"]
# ${bSRS}    text|0|//*[@name\="bSRS"]
# ${cSRS}    text|51|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${rightEdgeAngle}    text|60|//*[@name\="rightEdgeAngle"]
# ${leftEdgeAngle}    text|60|//*[@name\="leftEdgeAngle"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|2|//*[@name\="maxCsirsNumber"]
# #${actBbPoolTddFr1AlgEnh}    text|true|//*[@name\="actBbPoolTddFr1AlgEnh"]
# 
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:145	   maxNumStreamPrbL1Sp:290	  maxNumWbStreamPrbL1Sp:290
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:290	   maxNumStreamPrbL1Sp:580	  maxNumWbStreamPrbL1Sp:580
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# 
# *** Test Cases ***
# CB007113_case4_I4_single_layer_per_UE_MU_MIMO_with_less_than_L1PRB_AvailablePRBratio_AvailablePRBratio
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 3 rank1 Ues to 1st cell UE1 in H-15V0,UE2 in H-7V0,UE3 in H7V0
#     Step3:Start transfer UL non-GBR data with the peak
#     Step4:check PM counter
# 	Step5:check PM counter again
#     Step6:Detach UE
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    4    0    12    0    12    0    12    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    2    0    5    0    5    0    5    0    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    25    0    23    0    23    0    23    0    2	
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB007113   ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	add_periodiccsiacquisition_list_in_cells    ${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list    ${nrCellType_cell1}    ${nrCellType_cell2}   ${nrCellType_cell3} 
#     ...    ${dlMimoMode}    ${ulMimoMode}    ${pucchModeSelect}
#     ...    ${actBbPoolTddFr1}    ${allowSlowPrbPoolingStatNdmSrs}    ${actShortBsrLimitAdaptation}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${tdLteUlDlConfig}
#     ...    ${ulDlDataSlotRatio}    ${chBw}    ${actDlSrsBm}     ${actBeamforming}    ${prachConfigurationIndex}
#     ...    ${ulMaxMuMimoLayer_cell1}   ${ulMuMimoSinrThd}    ${ulMuMimoCorrThd}    ${ulMuMimoSpectralEffThd}
#     ...    ${actUlMuMimo_cell1}    ${actUlMuMimo_cell2}    ${actUlMuMimo_cell3}      
#     ...    ${ulMinPrbThreshold}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}    
#     ...    ${ulMuMimoLinkAdaptionSwitch}    ${actUlMuMimoTapering}    ${bSRS}    ${cSRS}    
# 	...    ${srsUePeriodicity}    ${rightEdgeAngle}    ${leftEdgeAngle}   
#     ...    ${csirsNumberWithinReportPeriod_Set1}    	${csirsPower}    ${maxCsirsNumber}
# 	...    ${bwp_profile5}    ${bwp_profile57}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
# 	modify_vendor_file_for_CB007113
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:attach 3 rank1 Ues to 1st cell UE1 in H-15V0,UE2 in H-7V0,UE3 in H7V0
#     Start Collect GNB and AP Syslog in 'Step2_attach_3UE' File
# 	Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2
# 	Wait Throughput Timer    5
# 
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_3UE${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach_3UE${/}   unzip=TRUE
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_3UE' File	
# 
# Step3:Start transfer UL non-GBR data with the peak
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# 	Airphone SA Start Data Traffic    1    UL    80M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    80M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    UL    80M    trf_id=1    pdu_id=1    duration=${3600}	
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Wait Throughput Timer    8
# 
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0	
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul	
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/output
# 	should_be_true      ${Ul_throughput_ue1}>44000
# 	should_be_true      ${Ul_throughput_ue2}>44000
# 	should_be_true      ${Ul_throughput_ue3}>44000	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# 
# Step4:check PM counter
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10004    cell_id=1	
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1	
# 	${PM_PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1	
#     should_be_true     ${PM_counter_PRB_pusch}>0
#     should_be_true     ${PM_PRB_AVAIL_PUSCH}>0
#     should_be_true     ${PM_counter_PRB_BB_pool}>0
# 	should_be_true     ${PM_PRB_UL_MU_MIMO_2PAIR_UE}>0
# 
# Step5:check PM counter again
#     Wait Throughput Timer    900s
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10004    cell_id=1	
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1	
# 	${PM_PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1		
#     should_be_true     ${PM_counter_PRB_pusch}>0
#     should_be_true     ${PM_PRB_AVAIL_PUSCH}>0
#     should_be_true     ${PM_counter_PRB_BB_pool}>0
# 	should_be_true     ${PM_PRB_UL_MU_MIMO_2PAIR_UE}>0
# 
# 
# 
# Step6:Detach UE
#     Start Collect GNB and AP Syslog in 'Step6_detach' File
#     airphone_sa_stop_data_traffic    1   UL    pdu_id=1
#     airphone_sa_stop_data_traffic    2   UL    pdu_id=1	
#     airphone_sa_stop_data_traffic    3   UL    pdu_id=1		
#     airphone_sa_detach    1
#     airphone_sa_detach    2	
#     airphone_sa_detach    3		
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_detach' File
# 
# 
# 
