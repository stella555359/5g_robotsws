# *** Settings ***
# Documentation     Author: xuemin.mae@nokia-sbell.com
# ...
# 
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
# ${SCFC_NAME}    gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_4d4u.xml                     #<rtPidCapacity>8192</rtPidCapacity>
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# @{LOG_NAME_LIST}      egatelog\
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|16 PRBs|//*[@name\="bfSubbandSize"]        #16 PRBs
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# ${bwp_profile5}                            text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}                           text|MRBTS-1/NRBTS-1/BWP_PROFILE-52|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-230,-230,-230,-230
# ${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# ${DEACT_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=1
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-600,-650,-600,-650
# ${SET_PROFILE2}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
# ${DEACT_PROFILE2}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=deactivate profile_id=2
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.srsPowerThreshold
# ...    itf_l2_ps_cell_DlSubbandBmConfig.srsSinrThreshold       itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
# ...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
# ...    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSlot    itf_l2_ps_cell_DlSubbandBmConfig.dlMaxBeamsPerSymbol
# 
# *** Test Cases ***
# CB008322_A3_case00_skt_config
#     Step1:Commission the above configuration on WebUI
#     Step2:NSA UE with t1r4 capability attach to cell1
#     Step3:modify SRS power trigger beamswitch
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}
# 	...      ${actCDrx}    ${actFdmScheduling}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
# 	...      ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...      ${bwp_profile5}    ${bwp_profile52}
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
# 	add_txt_node    0x340000:1         #as PM counter period update to 15/15=1min
#     add_txt_node    0x580556:0x834        #rdStartPatternId
#     add_txt_node    0x5901EB:1      #rdForceEnablingWidebandTasSrs use for  itf_l2_ps_user_usermodifyreq.isWBTasConfigured_item_0=1
#     add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
#     add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
# 
#     add_txt_node    0x5901E8:1     #CPRT rdActCB009496
# 	add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
# 	add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
# 	add_txt_node    0x42008E:1     # BOAM DCS
# 	add_txt_node    0x88004B:0             # L1 FH, rdEnableSktMvp
# 	add_txt_node    0x880x31:14 	       # L1 FH, rdBwvTxOpportunities (symbols/slot for sending BWV)
# 	add_txt_node    0x580556:65535 	     #rdStartPatternId
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:NSA UE with t1r4 capability attach to cell1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     Airphone Nsa Attach    ue_id=11
#     NSA send multiple trf data    11     DL    175M    5
#     Wait '5s' for stable running
#     Set UE11 position
#     Wait '5s' for stable running
#     ${ue11_dl_tput}=    Airphone Get Throughput On Specific Scell    11    8    pdsch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     #check cell set up bip
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/A3_case00_cellsetup.csv    ${FILTER1}    ${title1}
#     ${rtBeamStartPid_cellsetup}    read csv columns     ${save_log}/A3_case00_cellsetup.csv    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid
#     ...        filter=_ws.col.Info=itf_l2_ps_cell_CellSetupReq
# 
#     #check beamtype and pattern id
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/A3_case00_BOAM_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE11 position
#     #ul_mimo_srs_beam_pos_nr need set after trafffic
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '5s' for stable running
# 
# NSA send multiple trf data
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone NSA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    duration=3600s    trf_id=${num}
# 
# Step3:modify SRS power trigger beamswitch
#     Start Collect GNB and AP Syslog in 'Step3_fallback' File
#     Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_fallback
#     airphone_execute_egate_command	${PROFILE2}
# 	airphone_execute_egate_command	${SET_PROFILE2}
# 	Wait '5s' for stable running
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_fallback
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_fallback_dl.csv    ${save_log}/target_fallback_dl.csv
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_fallback' File
