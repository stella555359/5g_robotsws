# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_D_b2_case122_Coexistence with cDRX enabled_SrsCodebookAndTas_reuse_t1r4_TAS_CL_MIMO_8x4_uecsirs_cellcsirs_FDM_MultUE
# ...
# ...               When this feature is activated with cDRX enabled, gNodeB shall try to allocate SRS on DRX on duration.
# ...               If there is no free resource available on DRX on duration, then gNB shall try to allocate the SRS following
# ...               DRX on duration and the SRS is as near as possible to DRX on duration.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# ...    owner_jiangzhaona
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        MP_AP_LO.xml
# ${AIRPHONE_NAME}    SBTS00_SANSA_FS_AP_iphy_AEQE_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${WTS_NAME}         SBTS00_SANSA_FS_wts_config_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535))
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535)))
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# ${actCsirsMultiplexing}    text|true|//*[@name\="actCsirsMultiplexing"]
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS}    text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots80|//*[@name\="srsUePeriodicity"]
# ${chBw}    text|100MHz|//*[@name\="chBw"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actUlSrsBm}    text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}    text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${actCDrx}    text|true|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${lteToNrFrameShift}    text|3ms|//*[@name\="lteToNrFrameShift"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# #${bwp_profile87}    attrib\=distName|replace('BWP_PROFILE-44', 'BWP_PROFILE-87')|//managedObject
# #${bwp_profile87_p}    text|replace('BWP_PROFILE-44', 'BWP_PROFILE-87')|//p
# #${bwp_profile8}     attrib\=distName|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//managedObject
# #${bwp_profile8_p}    text|replace('BWP_PROFILE-0', 'BWP_PROFILE-8')|//p
# #${bwp_duration1}    text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='duration']
# #${bwp_duration3}    text|7|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='duration']
# #${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# #${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL16"]
# #${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL4_2}
# #...    text|n4|//*[contains(@distName, 'BWP_PROFILE-87/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# #${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//*[@name\="numOfPdcchCandidatesInAL8"]
# #${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-8')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# #${nPdcchCandidatesInAL4_dedi}    text|n5|//*[contains(@name, 'searchSpaceDedicated')]//item[2]/*[@name\='numOfPdcchCandidatesInAL4']
# ${drxInactivityTimer}    text|4ms|//*[@name\="drxInactivityTimer"]
# ${drxLongCycle}    text|40ms|//*[@name\="drxLongCycle"]
# ${drxOnDurationTimer}    text|20ms|//*[@name\="drxOnDurationTimer"]
# ${drxRetransTimerDl}    text|0slot|//*[@name\="drxRetransTimerDl"]
# ${drxRetransTimerUl}    text|0slot|//*[@name\="drxRetransTimerUl"]
# #${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[1]/*[@name\='periodicity']
# #${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-8')]//item[3]/*[@name\='periodicity']
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# 
# ${bwp_profile8}      text|MRBTS-1/NRBTS-2/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile87}     text|MRBTS-1/NRBTS-2/BWP_PROFILE-87|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${actBbPoolTddFr1}               text|true|//*[@name\="actBbPoolTddFr1"]
# ${actShortBsrLimitAdaptation}    text|true|//*[@name\="actShortBsrLimitAdaptation"]
# 
# *** Test Cases ***
# CB008247_D_b2_case122_Coexistence with cDRX enabled_SrsCodebookAndTas_reuse_t1r4_TAS_CL_MIMO_8x4_uecsirs_cellcsirs_FDM_MultUE
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 6 UEs without t1r4 cap, check rrc resource
#     Step3:Inject dl data
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
#     modify_swconfig_by_CB008247
#     ...    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    1csirs    rdDisableBestPmiBeamForPdcch    rdDlCoMaAgedCycle2    rdSrsCodebookAndTas1
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_all_elements    ${scfc_path}     NRBTS    actBbPoolTddFr1AlgEnh    true
#     add_all_elements    ${scfc_path}     NRBTS    actBbPoolTddFr1Enh    true
#     #add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     #add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs     true
#     add_all_elements    ${scfc_path}     NRBTS    actChannelMapVal     Disabled
#     ${modify_list}    create list    ${chBw}    ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrCellType}    ${nrBtsBeamRefinementP2}
#     ...            ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${actCDrx}
#     ...            ${numberOfTransmittedSsBlocks}    ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}
#     ...            ${cSRS}    ${srsUePeriodicity}
#     #...            ${bwp_profile87}    ${bwp_profile87_p}    ${bwp_profile8}    ${bwp_profile8_p}
#     #...            ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL4_2}
#     #...            ${bwp_duration1}    ${bwp_duration3}    ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL2_2}    ${bwp_duration_dedi}
#     #...            ${nPdcchCandidatesInAL4_dedi}    ${bwp_periodicity_1}    ${bwp_periodicity_3}
#     ...            ${drxInactivityTimer}    ${drxLongCycle}    ${drxOnDurationTimer}    ${drxRetransTimerDl}
#     ...            ${drxRetransTimerUl}    ${csirsNumberWithinReportPeriod_Set1}
#     ...            ${lteToNrFrameShift}    ${maxCsirsNumber}    ${actCsirsMultiplexing}
#     ...            ${bwp_profile8}    ${bwp_profile87}
#     ...            ${actBbPoolTddFr1} 
#     ...            ${actShortBsrLimitAdaptation}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#      Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 6 UEs without t1r4 cap, check rrc resource
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    6    CA_P2_8x4_t1r4_n1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_case122.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Inject dl data
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     send ues buffer    6
#     Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
#     Stop '6'UE DL Traffic
#     Wait Throughput Timer    4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   Set Suite Variable	 ${filter_name}    dlSrsBm1stBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS22R4'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS23R1'   Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     run keyword if    '${SW_VERSION}'=='SBTS00'     Set Suite Variable	 ${filter_name}    dlSrsBmBestBeamPatternId
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case122_ABIP.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #Check patterId in bip    ${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'Step4_detach' File
#     Stop '6'UE DL Traffic
#     Detach '6'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_detach' File
# 
# Check patterId in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap7    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap7    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap7    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case122_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case122_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case122_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# send ues buffer
#     [Arguments]    ${UENUM}    ${start}=1
#     : FOR    ${ueId}    IN RANGE    ${start}    ${UENUM}+${start}
#     \    SA send multiple trf data    ${ueId}    DL    10M    1
