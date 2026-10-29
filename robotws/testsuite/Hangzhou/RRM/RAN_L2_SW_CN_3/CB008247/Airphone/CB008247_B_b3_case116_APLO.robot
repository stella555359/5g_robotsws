# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b3_case116_Adaptation between SRS based beam and legacy PMI beam_with 8x4 CL-MIMO_sub-panel split 2x2_No_TAS_Recover
# ...
# ...               When SRS measurement is not available or SRS DTX, UE’s channel covariance matrix is out of date.
# ...               Then gNodeB will apply the legacy PMI Beams. When SRS measurement is recovered, gNodeB will switch to the SRS based beams.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# ...    owner_jiangzhaona
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# ${UE1_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# ${actCsirsMultiplexing}    text|false|//*[@name\="actCsirsMultiplexing"]
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS}    text|49|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots20|//*[@name\="srsUePeriodicity"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actUlSrsBm}    text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}    text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}    text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${bwp_profile65}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-65')|//managedObject
# ${bwp_profile65_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-65')|//p
# ${bwp_profile6}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//managedObject
# ${bwp_profile6_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//p
# ${bwp_duration1}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-65/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-65/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# 
# *** Test Cases ***
# CB008247_B_b3_case116_Adaptation between SRS based beam and legacy PMI beam_with 8x4 CL-MIMO_sub-panel split 2x2_No_TAS_Recover
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach one UE with noTas
#     Step3:Inject dl and ul data, check fallback and recovery
#     Step4:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    5    5    00    00    5    5    00    00    8    20    61    20    61
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    none    rdDisableBestPmiBeamForPdcch
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs     false
#     add_all_elements    ${scfc_path}     NRBTS    actChannelMapVal     Disabled
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list    ${chBw}    ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrCellType}    ${nrBtsBeamRefinementP2}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
#     ...            ${maxCsirsNumber}    ${bwp_profile65}    ${bwp_profile65_p}    ${bwp_profile6}    ${bwp_profile6_p}
#     ...            ${bwp_duration1}    ${bwp_duration3}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}
#     ...            ${nPdcchCandidatesInAL4_2}    ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL2_2}    ${bwp_duration_dedi}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#      Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# Modify L1ByPTestModeConfiguration
#     [Arguments]    ${H0}    ${V0}    ${H1}    ${V1}    ${H2}    ${V2}    ${H3}    ${V3}    ${ueNum}=8
#     ...        ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0    ${srsNumCountSwitchProfile3}=0    ${srsNumCountSwitchProfile4}=0
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     ${modify_list0} =    create list    @{empty}
#     : FOR    ${ue}    IN RANGE    ${ueNum}
#     \    ${list0}    create list
#     ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
# 	...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
#     ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
#     ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
#     ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
#     ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
#     \    ${modify_list0}    Combine Lists    ${modify_list0}    ${list0}
#     ${modify_list1}    create list
#     ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
#     ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
#     ...    text|${srsNumCountSwitchProfile3}|//*[@TestProfile\="Profile-3"]//srsNumCountSwitchProfile
#     ...    text|${srsNumCountSwitchProfile4}|//*[@TestProfile\="Profile-4"]//srsNumCountSwitchProfile
#     ${modify_list}    Combine Lists    ${modify_list0}    ${modify_list1}
#     #${modify_list}    Combine Lists    ${modify_list2}    ${extra_modify}
#     Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
# 
# 
# Step2:Attach one UE with noTas
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability    ${UE1_ID}     CA_P2_8x4_noTas_n2
#     airphone_set_traffic_type    ${UE1_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE1_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	#Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 sinr_target_pucch\=-280 noise_pucch\=-1053
#     #Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2
#     Airphone Csi Override Testmode Nr    profile_id=1     cqi=15    ri=3    cri=1    li=3    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=csi_override action\=activate profile_id\=1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     #Stop Gnb BIP Log    log_dir=${save_log}${/}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_noTas_p8.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Inject dl and ul data, check fallback and recovery
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     SA send multiple trf data    ${UE1_ID}    DL    175M    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R2'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case116_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #Check patterId in bip    ${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'Step4_detach' File
#     Stop '1'UE DL Traffic
#     Detach '1'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File
# 
# Check patterId in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case116_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case116_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case116_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}
