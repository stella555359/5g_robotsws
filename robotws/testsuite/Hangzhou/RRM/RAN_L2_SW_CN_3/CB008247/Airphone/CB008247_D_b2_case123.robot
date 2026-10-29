# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_D_b2_case123_Coexistence with DL CA_T+T_reuse_No_TAS_CL_MIMO_p4x4_s8X4
# ...
# ...               This scenario describes when this feature is activated, for any CA case, NDM SRS is only configured to UE in TDD PCell.FOR
# ...               UE in Scell no NDM SRS is configured. Hence SRS based beamforming solutions are only applied to Pcell when the Pcell is TDD cell.
# ...               In Scell, no SRS based beamforming is applied, UE feedback-based GoB or codebook-based PMI beam is used.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00     RAN_5G_TDD    RAN_5G    SBTS23R1
# ...    owner_lilyu
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Library           ta_a2a
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# ${UE_ID}          1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# 
# 
# ${actCarrierAggregation}    text|true|//*[@name\="actCarrierAggregation"]
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS1}    text|63|//*[contains(@distName, 'NRCELL-1')]//p[@name\='cSRS']
# ${cSRS2}    text|49|//*[contains(@distName, 'NRCELL-2')]//p[@name\='cSRS']
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${chBw1}           text|100MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${chBw2}           text|80MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
# ${actUlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actUlSrsBm']
# ${actUlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actUlSrsBm']
# ${actDlSrsBm_1}    text|true|//*[contains(@distName, 'NRCELL-1')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_2}    text|true|//*[contains(@distName, 'NRCELL-2')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_3}    text|false|//*[contains(@distName, 'NRCELL-3')]/*[@name='actDlSrsBm']
# ${actDlSrsBm_4}    text|false|//*[contains(@distName, 'NRCELL-4')]/*[@name='actDlSrsBm']
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode1}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-1')]/*[@name='dlMimoMode']
# ${dlMimoMode2}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-2')]/*[@name='dlMimoMode']
# ${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|1|//*[@name\="maxCsirsNumber"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}    text|false|//*[@name\="actCDrx"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${caConfigurationSupport}    text|2CCDL_2CCUL|//*[@name\="caConfigurationSupport"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${actPdschRmCsirsForTracking}    text|false|//*[@name\="actPdschRmCsirsForTracking"]
# ${bwp_profile57}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//managedObject
# ${bwp_profile57_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//p
# ${nPdcchCandidatesInAL4_1}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_1}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16_1}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_2}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_3}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_3}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16_3}
# ...     text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL16"]
# @{remove_list}    //*[contains(@distName, 'NRCELL-1')]//p[@name\='csirsNumberWithinReportPeriod_Set1']
# ...           //*[contains(@distName, 'NRCELL-1')]//p[@name\='csirsPower']
# ...           //*[contains(@distName, 'NRCELL-1')]//p[@name\='maxCsirsNumber']
# *** Test Cases ***
# CB008247_D_b2_case123_Coexistence with DL CA_T+T_reuse_No_TAS_CL_MIMO_p4x4_s8X4_bak
#     Step1:Commission the above configuration on WebUI
#     Step2:UE attach nr cell with no tas capability
#     Step3:Start UL DL data traffic
#     step4:Change the HV direction
#     Step5:Detach UE
# 
# CB008247_D_b2_case123_Coexistence with DL CA_T+T_reuse_No_TAS_CL_MIMO_p4x4_s8X4
#     Step1:Commission the above configuration on WebUI
#     Step2:UE attach nr cell with no tas capability
#     Step3:Start UL DL data traffic
#     step4:Change the HV direction
#     Step5:Detach UE
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Modify L1ByPTestModeConfiguration   5    5    10    5    4    24000    0
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_all_elements    ${scfc_path}     NRCELL    actUlSrsBm     true
#     add_all_elements    ${scfc_path}     NRCELL    actDlSrsBm     true
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">-6</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	add_all_elements    ${scfc_path}     NRBTS    actChannelMapVal     Disabled
#     add_ca_relation_CB8247    ${scfc_path}
#     Remove Xml Element     ${scfc_path}    ${scfc_path}    ${remove_list}
#     ${modify_list}    create list    ${nrCellType}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${srsUePeriodicity}
# 	...            ${actUlSrsBm_1}
# 	...            ${actUlSrsBm_2}
# 	...            ${actDlSrsBm_1}
# 	...            ${actDlSrsBm_2}	
#     ...            ${actDlSrsBm_3}
# 	...            ${actDlSrsBm_4}	
#     ...            ${actPdschRmCsirsForTracking}
#     ...            ${caConfigurationSupport}
#     ...            ${actCarrierAggregation}
#     ...            ${actInterNumerologyCa}
#     ...            ${actPdschAtSsbSlots}
#     ...            ${sCellAdditionMethod}
#     ...            ${maxNumScellsDl}
#     ...            ${sCellActivationMethod}
# 	...            ${sCellDeactivationTimerGNB}
#     ...            ${dlMimoMode1}
#     ...            ${dlMimoMode2}
#     ...            ${chBw1}
#     ...            ${chBw2}
#     ...            ${cSRS1}
#     ...            ${cSRS2}
#     ...            ${bwpProfile57}
#     ...            ${bwp_profile57_p}
#     ...            ${nPdcchCandidatesInAL16_1}
#     ...            ${nPdcchCandidatesInAL8_1}
#     ...            ${nPdcchCandidatesInAL4_1}
#     ...            ${nPdcchCandidatesInAL2_2}
#     ...            ${nPdcchCandidatesInAL8_2}
#     ...            ${nPdcchCandidatesInAL4_2}
#     ...            ${nPdcchCandidatesInAL16_3}
#     ...            ${nPdcchCandidatesInAL8_3}
#     ...            ${nPdcchCandidatesInAL4_3}
# 
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:UE attach nr cell with no tas capability
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# 	#Start GNB Ttitrace With Streaming Mode
# 	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=3    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     Airphone Set Traffic Type    ${UE_ID}    1    internal
#     ${ue_ability}    Obtain Ue Capability    CA_P2_8x4_noTas_n2
# 	Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
#     #Airphone SA Attach    ue_id=${UE_ID}       ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ue_id=${UE_ID}    pdu_id=1    nwslice_id=1    gw_id=1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     run keyword and continue on failure     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_noTas_CA.ini   log_need_to_check=p
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Wait Throughput Timer    180
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 100000
#     should be true    ${Scell_dl_throughput} > 100000
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/output
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternIdOnly
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case123_tti_dl_patternid.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case123_tti_ul_patternid.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# step4:Change the HV direction
#     Start Collect GNB and AP Syslog in 'Step4_change_HV' File
#     Wait Throughput Timer    300
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_change_HV
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_change_HV/output
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case123_tti_dl_patternid_change.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_change_HV
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case123_tti_ul_patternid_change.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_change_HV
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_change_HV' File
# 
# 
# Step5:Detach UE
#     Start Collect GNB and AP Syslog in 'Step5_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}   DL    pdu_id=1
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_detach' File
# 
# 
# add_ca_relation_CB8247
#     [Arguments]    ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
