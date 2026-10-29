# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b1_case101_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t2r4_TAS_Supported
# ...
# ...               In case cell is configured to 8x4 CL-MIMO, an CSI-RS resource pool is created for UE specific CSI-RS resource allocation.
# ...               When an UE is admitted, firstly UE specific CSI-RS resource for resource pool is allocated to this UE.
# ...               If there are no free CSI-RS resource available in the pool, then cell specific CSI-RS is allocated to this UE
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CIT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# #...    CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        MP_AP_LO_2.xml
# ${AIRPHONE_NAME}    SBTS00_SANSA_FS_AP_iphy_AEQE_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${WTS_NAME}         SBTS00_SANSA_FS_wts_config_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# ${UE1_ID}          1
# ${UE2_ID}          2
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS}    text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${chBw}    text|100MHz|//*[@name\="chBw"]
# ${actUlSrsBm}    text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}    text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}    text|false|//*[@name\="actCDrx"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}    text|3/7|//*[@name\="ulDlDataSlotRatio"]
# #${bwp_profile67}    attrib\=distName|replace('BWP_PROFILE-44', 'BWP_PROFILE-67')|//managedObject
# #${bwp_profile67_p}    text|replace('BWP_PROFILE-44', 'BWP_PROFILE-67')|//p
# #${bwp_profile6}     attrib\=distName|replace('BWP_PROFILE-0', 'BWP_PROFILE-6')|//managedObject
# #${bwp_profile6_p}    text|replace('BWP_PROFILE-0', 'BWP_PROFILE-6')|//p
# #${bwp_duration1}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# #${bwp_duration3}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# #${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# #${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# #${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# #${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# #${nPdcchCandidatesInAL4_2}
# #...     text|n4|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# 
# ${bwp_profile6}      text|MRBTS-1/NRBTS-2/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile67}     text|MRBTS-1/NRBTS-2/BWP_PROFILE-67|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# 
# *** Test Cases ***
# CB008247_B_b1_case101_UE specific CSI-RS allocation for cell with 8x4 CL-MIMO_Multi UE_t2r4_TAS_Supported
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2UEs with t2r4
#     Step3:Inject full dl and ul data
#     Step4:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    5    5    0    0
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     #add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     #add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs     true
#     #add_all_elements    ${scfc_path}     NRBTS    actChannelMapVal     Disabled
#     #add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     #add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list    ${chBw}    
#     #...            ${dlMimoMode}
#     #...            ${actUlSrsBm}    ${actDlSrsBm}
#     #...            ${nrCellType}
#     #...            ${nrBtsBeamRefinementP2}
#     #...            ${csirsNumberWithinReportPeriod_Set1}
#     #...            ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     #...            ${numberOfTransmittedSsBlocks}    ${basicBeamSet}
#     #...            ${bSRS}    ${cSRS}    ${srsUePeriodicity}    ${bwp_profile6}    ${bwp_profile67}
#     #...            ${bwpProfile67}    ${bwp_profile67_p}    ${bwp_profile6}    ${bwp_profile6_p}    ${bwp_duration1}    ${bwp_duration3}
#     #...            ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL2_2}
#     #...            ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL4_2}    ${bwp_duration_dedi}
#     #modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2UEs with t2r4
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=120 noise_srs\=-1053
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=ul_sinr action\=activate profile_id\=5
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE2_ID} testmode\=ul_sinr action\=activate profile_id\=5
#     Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_t2r4_p4_2ue.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Inject full dl and ul data
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     SA send multiple trf data    ${UE1_ID}    DL    175M    1
#     SA send multiple trf data    ${UE1_ID}    UL    25M    1
#     SA send multiple trf data    ${UE2_ID}    DL    175M    1
#     SA send multiple trf data    ${UE2_ID}    UL    25M    1
#     Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case101_ABIP.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #Check patterId in bip    ${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'Step4_detach' File
#     Stop '2'UE DL Traffic
#     Detach '2'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File
# 
# Check patterId in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case102_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}
