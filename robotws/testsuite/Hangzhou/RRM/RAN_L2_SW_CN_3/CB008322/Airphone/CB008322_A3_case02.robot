# *** Settings ***
# Documentation     Author: xuemin.mae@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_A3_case01_dynamic_fallback_with_SRS_power_100M_SubBandSize0_RANK4_CLoseLoopMimo
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
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
# ${SCFC_NAME}    gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# @{LOG_NAME_LIST}      egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|40MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|false|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                       text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                         text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}                       text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|25|//*[@name\="cSRS"]
# ${bSRS}                                    text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-800|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|128 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|1|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1000|//*[@name\="srsQualityThreshold"]
# ${profile85_size}                          text|96|//*[contains(@distName, 'BWP_PROFILE-85/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='size']
# ${pattern}    CA_P2_8x4_t1r4_n1
# ${PROFILE_rank_CQI}       csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=2
# ${ACT_rank}        ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
# ${DEACT_rank}        ue_testmode_set_nr id=1 testmode=csi_override action=deactivate profile_id=1
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# ${DEACT_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=1
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-600,-540,-600,-540
# ${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
# ${DEACT_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=2
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    itf_l2_ps_cell_BfSetup.actDlSrsBm    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm     itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# 	...      UlCell_SetupReq_t.pSRSBwvAct    itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs    itf_l2_ps_cell_DlSubbandBmConfig.srsQualityThreshold
# 
# ${FILTER2}      (uldata_srsreceivereq)||(uldata_srsreceiverespbwvps)||(uldata_srsreceiverespbmps)
# @{title2}       UlData_srsReceiveReqSubcell_t.srsBwvEnable    UlData_srsBwvReportRequest_t.startPatternId
#     ...        UlData_srsBwvReportRequest_t.srsResourceIdentity
#     ...        UlData_srsBwvReportRequest_t.bfSubbandId_item    UlData_srsBwvReportRequest_t.bfSubbandId_item
# ${FILTER3}    uldata_srsreceiverespbwvps
# @{title3}    3gpp.rnti    UlData_srsReceiveRespBwvPsSubcell_t.fhTransDelay    UlData_srsBwvReport_t.portPower_item    UlData_srsBwvReport_t.result
# ...    UlData_srsBwvReport_t.numBwvPerSubband    UlData_srsBwvReport_t.startPatternId
# ${FILTER_csirs}    dldata_csirssendreq
# @{title_csirs}    3gpp.sfn    3gpp.slot    DlData_CsiRsResource_t.patternId_item   DlData_CsiRsResource_t.density
# ...   DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.numCeAxCIndex   DlData_CsiRsResource_t.ceAxCIndex_item
# ...   DlData_CsiRsResource_t.csiBestBeamPowerOffset
# 
# *** Test Cases ***
# CB008322_A3_case02_dynamic_fallback_with_SRS_power_40M_SubBandSize128_RANK3_CLoseLoopMimo
#     Step1:Commission the above configuration on WebUI
#     Step2:UE with t1r4 capability attach to cell1
#     Step3:Change channel condition bad, trigger beam fallback
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
#     add_bwplist_list_in_cells_new    ${scfc_path}    key_3
#     ${modify_list}    create list
# 	...       ${cellDepType}     ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
# 	...       ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
# 	...       ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
# 	...       ${prachConfigurationIndex}    ${profile85_size}
# 	...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
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
# 	add_txt_node    0x5901EB:1      #rdForceEnablingWidebandTasSrs use for  itf_l2_ps_user_usermodifyreq.isWBTasConfigured_item_0=1
#     add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
#     add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
#     add_txt_node    0x580556:0x834        #rdStartPatternId
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:UE with t1r4 capability attach to cell1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     ${ue_cap}    Obtain Ue Capability    ${pattern}
#     airphone_sa_attach    ue_id=1    ue_capability=${ue_cap}
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '5s' for stable running
#     Airphone Execute Egate Command    ${PROFILE_rank_CQI}
#     Airphone Execute Egate Command    ${ACT_rank}
#     Airphone SA Start Data Traffic    ue_id=1    direction=ul    throughput=175M    trf_id=1    pdu_id=1    duration=3600s
#     Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=1    pdu_id=1    duration=3600s
#     Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=2    pdu_id=1    duration=3600s
#     Set UE1 position
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     #check cell set up bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/A3_case02_cellsetup.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case02_cellsetup.ini     log_need_to_check=i    save_log_directory=${save_log}
#     #    check PDSCH/CSIRS RT beam works ok
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case02_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE1 position
#     #ul_mimo_srs_beam_pos_nr need set after trafffic
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '5s' for stable running
# 
# Step3:Change channel condition bad, trigger beam fallback
#     Start Collect GNB and AP Syslog in 'Step3_fallback' File
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_fallback
# 	Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_fallback
#     #check beam fall back to SSB/Refine beam
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case02_tti_fallback.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #    check  CSIRS back to SSB/Refine beam
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap3    ${save_log}/A3_case02_csirs_bip.csv
#     ...        ${FILTER_csirs}    ${title_csirs}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case02_csirs_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #    convert uldata_srsreceiverespbwvps
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap2    ${save_log}/A3_case02_respbwv.csv    ${FILTER3}    ${title3}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_fallback' File
