# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_B_b2_case112
# ...
# ...               This scenario describes in case of cell specific CSI-RS, cell shall determine the best beams for PDCCH and PDSCH.
# ...               The best beams are selected from the predefined oversample DFT beams via the correlation with SRS measurement.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# ...    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Library           ta_a2a
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# ${UE_ID}          3
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${FILTER1}    ((dldata_pdcchsendreq) && !(3gpp.rnti == 65535)) && !(DlData_DciInfo.patternId_item == 101)
# ${FILTER2}    (((dldata_pdschsendreq) && !(3gpp.rnti == 65535))) && !(DlData_PdschGrant.patternId_item == 101)
# ${FILTER3}     DlData_CsiRsResource_t.density == 1
# @{title1}    DlData_DciInfo.patternId_item
# @{title2}    DlData_PdschGrant.patternId_item
# @{title3}    DlData_CsiRsResource_t.patternId_item
# 
# ${bSRS}    text|2|//*[@name\="bSRS"]
# ${cSRS}    text|38|//*[@name\="cSRS"]
# ${srsUePeriodicity}    text|slots40|//*[@name\="srsUePeriodicity"]
# ${chBw}    text|60MHz|//*[@name\="chBw"]
# ${actUlSrsBm}    text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsBm}    text|true|//*[@name\="actDlSrsBm"]
# ${nrCellType}    text|8DL4UL|//*[@name\="nrCellType"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${csirsNumberWithinReportPeriod_Set1}    text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${actCDrx}    text|false|//*[@name\="actCDrx"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${frameStructureType}    text|semiStatic|//*[@name\="frameStructureType"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# ${guardPeriodLength}    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}    text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${bwp_profile63}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-63')|//managedObject
# ${bwp_profile63_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-63')|//p
# ${bwp_profile6}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//managedObject
# ${bwp_profile6_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//p
# ${bwp_duration1}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_1_dedi}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-63/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# 
# *** Test Cases ***
# CB008247_B_b2_case112_Best beam with cell specific CSI-RS_with_8x4_CL-MIMO_sub-panel_split_2x2_Rank1toRank4_t2r4_TAS_maxCsirsNumber = 4
#     Step1:Commission the above configuration on WebUI
#     Step2:UE3 attach nr cell with capability of t2r4 and rank1
#     Step3:Start UL DL data traffic
#     Step4:Unblock the blocked 3 routes signal
#     Step5:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    5    5    0    0
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list    ${chBw}    ${dlMimoMode}    ${actUlSrsBm}    ${actDlSrsBm}    ${nrCellType}    ${nrBtsBeamRefinementP2}
#     ...            ${csirsNumberWithinReportPeriod_Set1}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...            ${prachConfigurationIndex}    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
#     ...            ${bwpProfile63}    ${bwp_profile63_p}    ${bwp_profile6}    ${bwp_profile6_p}    ${bwp_duration1}    ${bwp_duration3}
#     ...            ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL2_2}
#     ...            ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL4_2}    ${bwp_duration_dedi}    ${nPdcchCandidatesInAL4_1_dedi}
#     ...            ${maxCsirsNumber}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:UE3 attach nr cell with capability of t2r4 and rank1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=0    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     Airphone Set Traffic Type    ${UE_ID}    1    internal
# 	Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ue_id=${UE_ID}    pdu_id=1    nwslice_id=1    gw_id=1
#     Wait Throughput Timer    3
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     run keyword and continue on failure     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/TAS_t2r4_n2_srs_usage_refinebeam.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=0    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	#check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case112_dl_patternid.ini   log_need_to_check=p
# 	#...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case112_ul_patternid.ini   log_need_to_check=p
# 	#...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
#     ${Dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=ul
#     #Check patterId in bip    ${save_log}
#     should be true    ${dl_throughput} > 150000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Unblock the blocked 3 routes signal
#     Start Collect GNB and AP Syslog in 'Step4_Unblock_3routes_signal' File
#     Start GNB BIP Log
# 	#Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=deactivate profile_id\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override profile_id\=1 action\=deactivate
#     Airphone Csi Override Testmode Nr    profile_id=2    cqi=15    ri=3    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command     ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Unblock_3routes_signal
#     Stop Gnb BIP Log    log_dir=${save_log}${/}
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_Unblock_3routes_signal${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_Unblock_3routes_signal${/}tti
# 	#check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case112_dl_patternid.ini   log_need_to_check=p
# 	#...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case112_ul_patternid.ini   log_need_to_check=p
# 	#...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
#     Wait Throughput Timer    15
#     ${Dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=ul
#     #Check patterId in bip    ${save_log}
#     should be true    ${dl_throughput} > 600000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_Unblock_3routes_signal' File
# 
# Step5:Detach UE
#     Start Collect GNB and AP Syslog in 'Step5_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}   DL    pdu_id=1
#     #airphone_sa_stop_data_traffic    ${UE_ID}   UL    pdu_id=1
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_detach' File
# 
# 
# Check patterId in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdcch.csv    ${FILTER1}    ${title1}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_pdsch.csv    ${FILTER2}    ${title2}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip_csirs.csv    ${FILTER3}    ${title3}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case112_pdcch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case112_pdsch.ini     log_need_to_check=i    save_log_directory=${log_dir}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case112_csirs.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
