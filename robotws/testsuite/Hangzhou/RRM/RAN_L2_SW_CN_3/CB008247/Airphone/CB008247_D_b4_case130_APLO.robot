# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008247_D_b4_case130_interaction with EIRP control functionalities 5G_RAN_USR_RRM_3294_CL_MIMO_8x4
# ...               for counter check, need 5min period and 50M and 256QAM false.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# ...    owner_xueminm
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|50MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actEirpControl}                               text|true|//*[@name\="actEirpControl"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|33|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actDl256Qam}                                  text|false|//*[@name\="actDl256Qam"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}                        text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks_0}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-0')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${numberOfTransmittedSsBlocks_1}                text|6 beams|//*[contains(@distName, 'NRCELLGRP-1')]/*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${csirsNumberWithinReportPeriod_Set1}           text|1|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|-1|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# ${ssPbchBlockPower}                             text|-4|//*[@name\="ssPbchBlockPower"]
# ${bwp_profile67}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-67')|//managedObject
# ${bwp_profile67_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-67')|//p
# ${bwp_profile6}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//managedObject
# ${bwp_profile6_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-6')|//p
# ${bwp_duration1}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-6')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL8}    text|n0|//*[contains(@distName, 'BWP_PROFILE-6')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...     text|n4|//*[contains(@distName, 'BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008247_D_b4_case130_interaction with EIRP control functionalities 5G_RAN_USR_RRM_3294_CL_MIMO_8x4
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1 with TAS_t2r4_n2 capability
#     Step3:Start UL DL data traffic
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Modify L1ByPTestModeConfiguration    5    5    15    7
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008247    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    p8
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tiltOffset">0</p>|//*[@name\='beamSet']/item
#     add_all_elements    ${scfc_path}     NRCELL    mMimoAntArrayMode     Full 64TRX Array (4x8x2)
# 	add_all_elements    ${scfc_path}     NRCELL    antennaMechanicalDowntilt     0
# 	add_all_elements    ${scfc_path}     NRCELL    actUeCsirsCoexistCellCsirs    false
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     add_srsForBeamMgmt_list_in_cells    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}
#     ...       ${chBw}
#     ...       ${dlMimoMode}
#     ...       ${nrCellType}
#     ...       ${actDlSrsBm}
#     ...       ${actUlSrsBm}
#     ...       ${pucchModeSelect}
#     ...       ${actEirpControl}
#     ...       ${actCDrx}
#     ...       ${actFdmScheduling}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${ulDlDataSlotRatio}
#     ...       ${prachConfigurationIndex}
#     ...       ${ssBurstSetPeriod}
#     ...       ${srsUePeriodicity}
#     ...       ${cSRS}
#     ...       ${bSRS}
#     ...       ${actDl256Qam}
#     ...       ${actBeamforming}
#     ...       ${numberOfRxBeamforming}
#     ...       ${numberOfTransmittedSsBlocks_0}
#     ...       ${numberOfTransmittedSsBlocks_1}
#     ...       ${basicBeamSet}
#     ...       ${actCsirsMultiplexing}
#     ...       ${nrBtsBeamRefinementP2}
#     ...       ${csiReportPeriodicity}
#     ...       ${csirsNumberWithinReportPeriod_Set1}
#     ...       ${csirsPower}
#     ...       ${maxCsirsNumber}
#     ...       ${ssPbchBlockPower}
#     ...            ${bwpProfile67}    ${bwp_profile67_p}    ${bwp_profile6}    ${bwp_profile6_p}    ${bwp_duration1}    ${bwp_duration3}
#     ...            ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL2_2}
#     ...            ${nPdcchCandidatesInAL8}    ${nPdcchCandidatesInAL4_2}    ${bwp_duration_dedi}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008247
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:3         #as PM counter period update to 15/3=5min
# 	add_txt_node    0x41001b:1          #CP-NRT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     add_txt_node    0x590105:1          #rdSelectedBeamset 1 is DFT beam, 0 is Gob beam
#     add_txt_node    0x580477:1          #print beam calc log
#     add_txt_node    0x580264:0x1F           #rdDlSrsLogControl
#     add_txt_node    0x590104:0          #rdPriorSrsForDlBm: 0: TAS[default], 1: codebook
#     Run Keyword if    '${add_node4}'=='rdSrsCodebookAndTas1'    add_txt_node    0x590103:1
#     ...        ELSE    add_txt_node    0x590103:0
#     Run Keyword if    '${add_node1}'=='1csirs'    add_txt_node    0x580265:1
#     Run Keyword if    '${add_node2}'=='rdDisableBestPmiBeamForPdcch'    add_txt_node    0x580421:0
#     Run Keyword if    '${add_node3}'=='rdDlCoMaAgedCycle2'    add_txt_node    0x580262:0x2
#     modify_txt_node    0x590072:1         #CP-RT log level (0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE1 with TAS_t2r4_n2 capability
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Airphone Set Traffic Type    1    1    internal
#     ${TAS_t2r4_n2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${TAS_t2r4_n2}
#     Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/TAS_t2r4_n2_srs_usage.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    175M    trf_id=3    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	Wait Throughput Timer    300
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     Set Suite Variable    ${PM_counter_file}
# 	${PM_counter_value_M55308C10003}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10003    cell_id=1
# 	${PM_counter_value_M55308C10001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
# 	${result}=    evaluate    float(${PM_counter_value_M55308C10001})/${PM_counter_value_M55308C10003}
# 	should be true     ${result} > 0.3
#     ${PM_counter_value_M55324C00301}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55324C00301    cell_id=1
#     run keyword if    '${SW_VERSION}'=='SBTS22R3'   should be true     ${PM_counter_value_M55324C00301} > 0
# 	run keyword if    '${SW_VERSION}'=='SBTS00'    get trunk eirp control counter
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# get trunk eirp control counter
# 	${counter_list} =  Create List
#     : FOR    ${times}    IN RANGE    301    361
#     \    ${M55324C00_pm} =    Parse counter file_'${PM_counter_file}' and return 'M55324C00${times}' value under cell'1'
#     \    append_to_list      ${counter_list}    ${M55324C00_pm}
#     Log To Console    ${counter_list}
# 
# Parse counter file_'${PM_counter_file}' and return '${counter_id}' value under cell'${cell_id}'
#     ${ret}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=${cell_id}
#     [Return]    ${ret}
