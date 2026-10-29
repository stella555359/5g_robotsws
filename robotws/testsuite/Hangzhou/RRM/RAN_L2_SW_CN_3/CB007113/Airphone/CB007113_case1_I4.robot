# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...    QC case full name:
# ...    CB007113_case1_I4_single_layer_per_UE_MU_MIMO_with_less_than_L1PRB_ReqPRb_AvailablePRBratio
# ...    Z = rrmAvailablePuschRadioPrbForMu,Y = rrmRequiredMuPrbNum,X = rrmAvailablePuschL1PrbForMu           
# ...    Ratio = 1.1 by default,
# ...    This case will verify that when X < Y < Z*Ratio, only 1 +1 layer shall pair.           
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
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
# ${SCFC_2cell}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
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
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# #Activate the UE pooling CB007113
# ${actBbPoolTddFr1}    text|true|//*[@name\="actBbPoolTddFr1"]
# ${allowSlowPrbPoolingStatNdmSrs}    text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${actShortBsrLimitAdaptation}    text|true|//*[@name\="actShortBsrLimitAdaptation"]
# 
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|4Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}    text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${chBw}    text|100MHz|//*[@name\="chBw"]
# ${actDlSrsBm}    text|false|//*[@name\="actDlSrsBm"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# 
# #enable CB008306
# ${actUlMuMimo}    text|true|//*[@name\="actUlMuMimo"]
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
# ${cSRS}    text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${rightEdgeAngle}    text|60|//*[@name\="rightEdgeAngle"]
# ${leftEdgeAngle}    text|60|//*[@name\="leftEdgeAngle"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|3|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|2|//*[@name\="maxCsirsNumber"]
# 
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:182	   maxNumStreamPrbL1Sp:364	  maxNumWbStreamPrbL1Sp:364
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:364	   maxNumStreamPrbL1Sp:728	  maxNumWbStreamPrbL1Sp:728
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# 
# *** Test Cases ***
# CB007113_case1_I4_single_layer_per_UE_MU_MIMO_with_less_than_L1PRB_ReqPRb_AvailablePRBratio
#     Step1:Commission the above configuration on WebUI
#     Step2:Block the 2nd and 3rd cells
#     Step3:attach 2 rank1 UEs in cell1 UE1 in H0V0,UE2 in H30V0
# 	Step4:Start transfer UL non-GBR data with 20% the peak
#     step5:Unblock the 2nd and 3rd cells
# 	Step6:check PM counter
# 	Step7:Detach UE
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    22    0    22    0    22    0    22    0    1
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB007113   ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list    ${nrCellType_cell1}    ${nrCellType_cell2}   ${nrCellType_cell3} 
#     ...    ${dlMimoMode}    ${ulMimoMode}    ${pucchModeSelect}
#     ...    ${actBbPoolTddFr1}    ${allowSlowPrbPoolingStatNdmSrs}    ${actShortBsrLimitAdaptation}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}
#     ...    ${ulDlDataSlotRatio}    ${chBw}    ${actDlSrsBm}     ${actBeamforming}
#     ...    ${actUlMuMimo}   ${ulMuMimoSinrThd}    ${ulMuMimoCorrThd}    ${ulMuMimoSpectralEffThd}
#     ...    ${ulMaxMuMimoLayer_cell1}    ${ulMaxMuMimoLayer_cell1}    ${ulMaxMuMimoLayer_cell1}    
#     ...    ${ulMinPrbThreshold}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}    
#     ...    ${ulMuMimoLinkAdaptionSwitch}    ${actUlMuMimoTapering}    ${bSRS}    ${cSRS}    
# 	...    ${srsUePeriodicity}    ${rightEdgeAngle}    ${leftEdgeAngle}   
#     ...    ${csirsNumberWithinReportPeriod_Set1}    	${csirsPower}    ${maxCsirsNumber}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
# 	modify_vendor_file_for_CB007113
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:Block the 2nd and 3rd cells	
#     Start Collect GNB and AP Syslog in 'Step2_Block_cell' File
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=administrativeState    operation=update    value=Locked
#     ...    skip_parameter_relation_errors=True    connection=online	
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-3    parameter=administrativeState    operation=update    value=Locked
#     ...    skip_parameter_relation_errors=True    connection=online		
#     TAF_ADMIN.teardown admin    connection=online	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_Block_cell' File
# 
# Step3:attach 2 rank1 UEs in cell1 UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step3_attach_2UE' File
# 	Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
# 	Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_attach_2UE${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_attach_2UE${/}   unzip=TRUE
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_attach_2UE' File	
# 
# Step4:Start transfer UL non-GBR data with 20% the peak
#     Start Collect GNB and AP Syslog in 'Step4_inject_buffer' File
#     Start GNB BIP Log
# 	Airphone SA Start Data Traffic    1    UL    40M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    40M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Wait Throughput Timer    8
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_inject_buffer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_inject_buffer/output
# 	should_be_true      ${Ul_throughput_ue1}>39000
# 	should_be_true      ${Ul_throughput_ue2}>39000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_inject_buffer' File
# 
# step5:Unblock the 2nd and 3rd cells
#     Start Collect GNB and AP Syslog in 'Step5_unblock_2nd_3rd_cells' File
# 	Start GNB BIP Log
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-2    parameter=administrativeState    operation=update    value=Unlocked
#     ...    skip_parameter_relation_errors=True    connection=online	
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-3    parameter=administrativeState    operation=update    value=Unlocked
#     ...    skip_parameter_relation_errors=True    connection=online		
#     TAF_ADMIN.teardown admin    connection=online  
#     Wait Throughput Timer    30	
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_inject_buffer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_inject_buffer/output	
# 	should_be_true      ${Ul_throughput_ue1}>39000
# 	should_be_true      ${Ul_throughput_ue2}>39000	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_unblock_2nd_3rd_cells' File
# 	
# 
# Step6:check PM counter
# 	#${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10004    cell_id=1	
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35003    cell_id=1	
# 	${PM_ PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1	
# 
# 		
# 
# Step7:Detach UE
#     Start Collect GNB and AP Syslog in 'Step7_detach' File
#     airphone_sa_stop_data_traffic    1   UL    pdu_id=1
#     airphone_sa_stop_data_traffic    2   UL    pdu_id=1	
#     airphone_sa_detach    1
#     airphone_sa_detach    2	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_detach' File
# 
# 
# 
