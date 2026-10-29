# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_A3_case01_dynamic_fallback_with_SRS_power_100M_SubBandSize0_RANK4_CLoseLoopMimo
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# @{LOG_NAME_LIST}      egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actPdschBeamPowerBalance}                text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${beamPowerOffsetThreshold}                text|6|//*[@name\="beamPowerOffsetThreshold"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actDlMuMimoEnh}                          text|false|//*[@name\="actDlMuMimoEnh"]
# ${frameStructureType}                      text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                       text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                         text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}                       text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots20|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|cell bandwidth|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|1|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1050|//*[@name\="srsQualityThreshold"]
# ${csiReportPeriodicity}                    text|slots320|//*[@name\="csiReportPeriodicity"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${ssPbchBlockPower}               text|3|//*[@name\="ssPbchBlockPower"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# #${miNrMacSduReport}              text|15min|//*[@name\="miNrMacSduReport"]
# ${tiltOffset}                    text|0|//*[@name\="tiltOffset"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${bwp_profile8}                            text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}                           text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-230,-230,-230,-230
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# ${DEACT_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=1
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-600,-540,-600,-540
# ${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
# ${DEACT_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=2
# 
# ${PROFILE_3}      ul_cell_noise_testmode_nr profile_id=3 noise_srs=-850
# ${SET_PROFILE3}    cell_testmode_set_nr  cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=3 action=activate
# 
# ${PROFILE_4}      ul_cell_noise_testmode_nr profile_id=4 noise_srs=-900
# ${SET_PROFILE4}    cell_testmode_set_nr  cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=4 action=activate
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.srsPowerThreshold
# ...    itf_l2_ps_cell_DlSubbandBmConfig.srsSinrThreshold       itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
# ...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
# ...    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSlot    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSymbol
# ${FILTER2}    dldata_csirssendreq
# @{title2}    3gpp.sfn    3gpp.slot    DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density
# ...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item
# ...   DlData_CsiRsResource_t.csiBestBeamPowerOffset
# ${FILTER3}    uldata_srsreceiverespbwvps
# @{title3}    3gpp.rnti    UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay    UlData_srsBwvReport_t.portPower_item    UlData_srsBwvReport_t.result
# ...    UlData_srsBwvReport_t.numBwvPerSubband    UlData_srsBwvReport_t.startPatternId
# ${FILTER4}    dldata_pdschsendreq
# @{title4}     DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook
# 
# *** Test Cases ***
# CB008322_A3_case01_dynamic_fallback_with_SRS_power_100M_SubBandSize0_RANK4_CLoseLoopMimo
#     Step1:Commission the above configuration on WebUI
#     Step2:UE with t2r4 capability attach to cell1
#     Step3:Change channel condition bad, trigger beam fallback
#     Step4:Change channel condition good,trigger beam fallback to RT beam
# 	Step5:Detach ue
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
# 	...       ${cellDepType}     ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
# 	...       ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}    ${actDlMuMimoEnh}
# 	...       ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
# 	...       ${prachConfigurationIndex}    ${csiReportPeriodicity}    ${actPdschBeamPowerBalance}    ${beamPowerOffsetThreshold}
# 	...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
# 	...       ${maxCsirsNumber}    ${csirsPower}    ${ssPbchBlockPower}    ${actCustomBsr}
# 	...       ${customBeamSetName}    ${actIncreasedFdmUsersPerSlot}    ${tiltOffset}    ${csirsNumberWithinReportPeriod_Set1}
# 	...       ${bwp_profile8}    ${bwp_profile85}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
#     add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
# 	add_txt_node    0x5805b5:30       #rdNumSrsCheck
# 	add_txt_node    0x5805b0:100       #rdSrsBufPercent=50(Default Value is 70)
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:UE with t2r4 capability attach to cell1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     airphone_sa_attach    ue_id=1
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     Set UE1 position
#     Wait Throughput Timer    15
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch    current
#     #check cell set up bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/A3_case01_cellsetup.csv    ${FILTER1}    ${title1}
# 
#     #check PDSCH/CSIRS RT beam works ok
#     Set Suite Variable    ${tti_name}    tti_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case01_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE1 position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '5s' for stable running
# 
# Step3:Change channel condition bad, trigger beam fallback
#     Start Collect GNB and AP Syslog in 'Step3_fallback' File
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_fallback
#     Airphone Execute Egate Command    ${DEACT_PROFILE1}
# 	Wait '5s' for stable running
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_fallback
#     #    check PDSCH beam back to DFT and poweroffset not equal 0
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case01_tti_fallback.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #    check  CSIRS back to DFT
# #    Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap3    ${save_log}/A3_case01_csirs_bip.csv    ${FILTER2}    ${title2}
# #    run keyword and continue on failure    check_log_with_au2anlysis
# #    ...    ini_path=${CURDIR}/log_check/A3_case01_csirs_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_fallback' File
# 
# Step4:Change channel condition good,trigger beam fallback to RT beam
#     Start Collect GNB and AP Syslog in 'Step4_back_to_RT' File
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_back_to_RT
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# 	Wait '5s' for stable running
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_back_RT
#     #   check PDSCH/CSIRS RT beam works ok
#     Set Suite Variable    ${tti_name}    tti_back_RT_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case01_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_back_to_RT' File
# 
# Step5:Detach ue
#     Start capture GNB and AP Syslog in 'Step5_detach' File
#     Detach '1'UE
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_detach' File
