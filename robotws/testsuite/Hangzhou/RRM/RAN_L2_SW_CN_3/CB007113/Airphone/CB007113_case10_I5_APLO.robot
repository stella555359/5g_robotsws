# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...    QC case full name:
# ...    CB007113_case10_I5_Mix_MU_MIMO_Ues_and_GBR_UE
# ...    Z = rrmAvailablePuschRadioPrbForMu,Y = rrmRequiredMuPrbNum,X = rrmAvailablePuschL1PrbForMu           
# ...    Ratio = 1.1 by default,
# ...    This case will verify that GBR don't pair.          
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    SBTS00    RAN_5G_TDD    RAN_5G
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
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${chBw}    text|100MHz|//*[@name\="chBw"]
# ${actDlSrsBm}    text|false|//*[@name\="actDlSrsBm"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
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
# ${discardTimer_NRDRB15}    text|100ms|//*[contains(@distName, 'NRDRB-15')]//*[@name\="discardTimer"]
# ${actBbPoolTddFr1AlgEnh}    text|true|//*[@name\="actBbPoolTddFr1AlgEnh"]
# 
# 
# 
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:546	   maxNumStreamPrbL1Sp:1092	  maxNumWbStreamPrbL1Sp:1092
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:1092	   maxNumStreamPrbL1Sp:2184	  maxNumWbStreamPrbL1Sp:2184
# ${pattern}    vonr_n78
# 
# ${bwp_profile8}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile87}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-87|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# 
# *** Test Cases ***
# CB007113_case10_I5_Mix_MU_MIMO_Ues_and_GBR_UE
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 2 rank2 Ues to 1st cell UE1 in H0V0,UE2 in H30V0
# 	Step3:Start transfer UL non-GBR data with the peak
# 	Step4:check PM counter_time1
# 	Step5:attach the third UE to the 1st cell
# 	Step6:Add 5QI-5 PDU Session for UE3 makes GBR call
# 	Step7:check PM counter_time2
# 	Step8:Detach UE
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    22    0    22    0    22    0    22    0    1
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB007113   ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	add_vonr_extend_parameter_on_bts     xml_path=${scfc_path}
# 	add_periodiccsiacquisition_list_in_cells    ${scfc_path}			
#     ${modify_list}    create list    ${nrCellType_cell1}    ${nrCellType_cell2}   ${nrCellType_cell3} 
#     ...    ${dlMimoMode}    ${ulMimoMode}    ${pucchModeSelect}
#     ...    ${actBbPoolTddFr1}    ${allowSlowPrbPoolingStatNdmSrs}    ${actShortBsrLimitAdaptation}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}
#     ...    ${ulDlDataSlotRatio}    ${chBw}    ${actDlSrsBm}     ${actBeamforming}    ${prachConfigurationIndex}
#     ...    ${actUlMuMimo}   ${ulMuMimoSinrThd}    ${ulMuMimoCorrThd}    ${ulMuMimoSpectralEffThd}
#     ...    ${ulMaxMuMimoLayer_cell1}    ${ulMaxMuMimoLayer_cell1}    ${ulMaxMuMimoLayer_cell1}    
#     ...    ${ulMinPrbThreshold}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}    
#     ...    ${ulMuMimoLinkAdaptionSwitch}    ${actUlMuMimoTapering}    ${bSRS}    ${cSRS}    
#     ...    ${srsUePeriodicity}    ${rightEdgeAngle}    ${leftEdgeAngle}   
#     ...    ${csirsNumberWithinReportPeriod_Set1}    	${csirsPower}    ${maxCsirsNumber}
#     ...    ${discardTimer_NRDRB15}    ${bwp_profile8}    ${bwp_profile87}
# 	...    ${actBbPoolTddFr1AlgEnh}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
# 	modify_vendor_file_for_CB007113
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:attach 2 rank2 Ues to 1st cell UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach_2UE' File
# 	#Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    vonr_n78
# 	Wait Throughput Timer    5
# 
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach_2UE${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach_2UE${/}   unzip=TRUE
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach_2UE' File	
# 
# Step3:Start transfer UL non-GBR data with the peak
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# 	RI_override_testmode_active     profile_id=1     ri=2   
# 	Airphone SA Start Data Traffic    1    UL    150M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Wait Throughput Timer    8
# 
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	
# 
#     Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/output
# 	should_be_true      ${Ul_throughput_ue1}>99000
# 	should_be_true      ${Ul_throughput_ue2}>99000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 	
# 
# Step4:check PM counter_time1
# 	#${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	should_be_true      ${PM_counter_PRB_pusch}>0
# 	should_be_true      ${PM_counter_PRB_BB_pool}>0
# 
# 
# Step5:attach the third UE to the 1st cell
#     Start Collect GNB and AP Syslog in 'Step5_attach_1UE' File
# 	Start GNB BIP Log
#     Attach SA ue with capability    3    vonr_n78
# 	Airphone Pdu Session Setup    3    1    1    3
# 	Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_attach_1UE${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5_attach_1UE${/}   unzip=TRUE
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_attach_1UE' File	
# 	
# Step6:Add 5QI-5 PDU Session for UE3 makes GBR call
#     Start Collect GNB and AP Syslog in 'Step6_gbr' File
#     Start GNB BIP Log
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=3 pdu\=1 qosflows_to_add\=2 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=3 pdu\=1 qosflows_to_add\=3 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    3  
#     airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=2 trf_id\=1 mbps\=70 dir\=ul protocol\=tcp seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=3 pdu\=1 qfi\=3 trf_id\=1 mbps\=70 dir\=ul protocol\=tcp seconds\=3600
# 	Wait Throughput Timer    3
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_gbr${/}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_gbr
#     #yDecoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_gbr/output		
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_gbr' File
# 
# 
# Step7:check PM counter_time2
# 	#${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
# 	${remaining_time}=    get_counter_file_remaining_time
# 	Wait Throughput Timer    ${remaining_time}
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
# 	${PM_counter_PRB_pusch}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10002    cell_id=1
# 	${PM_PRB_AVAIL_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10004    cell_id=1	
# 	${PM_counter_PRB_BB_pool}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10006    cell_id=1
# 	${PM_PRB_UL_MU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35005    cell_id=1	
# 	${PM_PRB_UL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35007    cell_id=1
#     should_be_true      ${PM_counter_PRB_pusch}>${PM_PRB_UL_MU_MIMO_4LAYER}
# 		
# 
# Step8:Detach UE
#     Start Collect GNB and AP Syslog in 'Step8_detach' File
#     airphone_sa_stop_data_traffic    1   UL    pdu_id=1
#     airphone_sa_stop_data_traffic    2   UL    pdu_id=1		
#     airphone_sa_detach    1
#     airphone_sa_detach    2	
#     airphone_sa_detach    3	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_detach' File
# 
# 
# RI_override_testmode_active
#     [Arguments]    ${profile_id}    ${ri}    ${cqi}=15
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${profile_id} cqi\=${cqi} cqi_mode\=fixed ri\=${ri} ri_mode\=fixed
# 
