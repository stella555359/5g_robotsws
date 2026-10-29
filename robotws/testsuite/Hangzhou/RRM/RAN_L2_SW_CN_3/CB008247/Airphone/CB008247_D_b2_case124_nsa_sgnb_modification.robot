# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_D_b2_case124_nsa_sgnb_modification
# ...
# ...               add new regression case to couer a new scenario which developer asked
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhajiang
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        scfc_8247_case124.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# ${UE_ID}          11
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# 
# ${actCarrierAggregation}    text|true|//*[@name\="actCarrierAggregation"]
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationBadRlqCount}    text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellGoodChannelQualityThreshold}    text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}    text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS}    text|49|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${rightEdgeAngle}    text|45|//*[@name\="rightEdgeAngle"]
# ${leftEdgeAngle}    text|45|//*[@name\="rightEdgeAngle"]
# ${actUlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actUlSrsBm']
# ${actUlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actUlSrsBm']
# ${actUlSrsBm_3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actUlSrsBm']
# ${actUlSrsBm_4}    text|false|//*[contains(@distName, 'NRCELL-4')]/*[@name='actUlSrsBm']
# ${actDlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_4}    text|false|//*[contains(@distName, 'NRCELL-4')]/*[@name='actDlSrsBm']
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode2}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-2')]/*[@name='dlMimoMode']
# ${dlMimoMode1}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-1')]/*[@name='dlMimoMode']
# ${nrBtsBeamRefinementP21}    text|true|//*[contains(@distName, 'NRCELL-1')]//p[@name\='nrBtsBeamRefinementP2']
# ${nrBtsBeamRefinementP22}    text|false|//*[contains(@distName, 'NRCELL-2')]//p[@name\='nrBtsBeamRefinementP2']
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}    text|false|//*[@name\="actCDrx"]
# ${basicBeamSet}    text|beamSet_4_2|//*[@name\="basicBeamSet"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${caConfigurationSupport}    text|2CCDL_2CCUL|//*[@name\="caConfigurationSupport"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${lteToNrFrameShift}          text|3ms|//*[@name\="lteToNrFrameShift"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${actPdschRmCsirsForTracking}    text|false|//*[@name\="actPdschRmCsirsForTracking"]
# 
# 
# *** Test Cases ***
# CB008247_D_b2_case124_nsa_sgnb_modification
#     Step1:Commission the above configuration on WebUI
#     Step2:UE1 attach
#     Step3:UE1 attach scell refuse
#     Step4:scell normal add
#     Step5:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list    ${nrCellType}    ${maxCsirsNumber}    ${numberOfRxBeamforming}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${srsUePeriodicity}
#     ...            ${actUlSrsBm_1}
#     ...            ${actUlSrsBm_2}
#     ...            ${actUlSrsBm_3}
#     ...            ${actUlSrsBm_4}
#     ...            ${actDlSrsBm_1}
#     ...            ${actDlSrsBm_2}
#     ...            ${actDlSrsBm_3}
#     ...            ${actDlSrsBm_4}
#     ...            ${sCellDeactivationTimerGNB}
#     ...            ${actPdschRmCsirsForTracking}
#     ...            ${nrBtsBeamRefinementP21}
#     ...            ${nrBtsBeamRefinementP22}
#     ...            ${caConfigurationSupport}
#     ...            ${actCarrierAggregation}
#     ...            ${actInterNumerologyCa}
#     ...            ${actPdschAtSsbSlots}
#     ...            ${sCellAdditionMethod}
#     ...            ${maxNumScellsDl}
#     ...            ${sCellActivationMethod}
#     ...            ${sCellDeactivationBadRlqCount}
#     ...            ${sCellGoodChannelQualityThreshold}
#     ...            ${sCellBadChannelQualityThreshold}
#     ...            ${sCellChannelEstimationPeriod}
#     ...            ${lteToNrFrameShift}
#     ...            ${dlMimoMode1}
#     ...            ${dlMimoMode2}
#     ...            ${chBw}
#     ...            ${cSRS}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:UE1 attach
#     Start capture gnb and ap syslog in 'Step2' file
#     Start GNB BIP Log
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
# 	Airphone Nsa Attach    ${UE_ID}
# 	#sgnb_modif_reqd_rsp    refuse
#     #Airphone Measurement Send Nr    id=${UE_ID}    meas_id=1    event=A1    srsrp_nr=80
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M    trf_id=5    duration=${3600}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 650000
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     ${counter_file}    download PM counter file    ${save_log}
# 	${MAC_DTCH_CELL_THP_DL_MAX1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     ${MAC_DTCH_CELL_THP_DL_MAX2}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=2
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX1} > 86000000
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX2} == 0
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case124_NSA_step2.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2' file
# 
# Step3:UE1 attach scell refuse
#     Start capture gnb and ap syslog in 'Step3_scell_refuse' file
#     Start GNB BIP Log
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_scell_refuse
# 	sgnb_modif_reqd_rsp    refuse
#     disp_ue_meas
#     send_meas
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Wait Throughput Timer    10    
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 650000
#     ${counter_file}    download PM counter file    ${save_log}
# 	${MAC_DTCH_CELL_THP_DL_MAX1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     ${MAC_DTCH_CELL_THP_DL_MAX2}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=2
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX1} > 86000000
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX2} == 0
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case124_NSA_step2.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_scell_refuse' file
# 
# Step4:scell normal add
#     Start capture gnb and ap syslog in 'Step4_scell_normal' file
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_scell_normal
#     sgnb_modif_reqd_rsp    normal_rsp
#     disp_ue_meas
#     send_meas
#     Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 320000
#     should be true    ${Scell_dl_throughput} > 320000
#     ${counter_file}    download PM counter file    ${save_log}
# 	${MAC_DTCH_CELL_THP_DL_MAX1}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     ${MAC_DTCH_CELL_THP_DL_MAX2}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=2
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX1} > 42000000
# 	should be true    ${MAC_DTCH_CELL_THP_DL_MAX2} > 42000000
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case124_NSA_step4.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_scell_normal' file
# 
# Step5:Detach UE
#     airphone_nsa_detach    ue_id=${UE_ID}
# 
# add_ca_relation_CB8247
#     [Arguments]    ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# sgnb_modif_reqd_rsp
#     [Arguments]    ${type}
#     airphone_execute_egate_command    link_x2_management_abnormal_cases id\=1 partner\=2 sgnb_modification_reqd_rsp\=${type}
# 
# disp_ue_meas
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=11 meas_obj_type\=nr
# 
# send_meas
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=1 event\=A1 srsrp_nr\=80
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 srsrp_nr\=80
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=3 event\=A1 srsrp_nr\=80
#     airphone_execute_egate_command    ue_measurement_send_nr id\=11 meas_id\=4 event\=A1 srsrp_nr\=80
