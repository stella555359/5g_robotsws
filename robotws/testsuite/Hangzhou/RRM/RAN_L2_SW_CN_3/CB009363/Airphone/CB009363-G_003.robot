# *** Settings ***
# Documentation
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}   SCF_G_1cell_MP_LO.xml
# ${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
# ${WTS_NAME}    wts_D_1cell.cfg
# @{LOG_NAME_LIST}        egatelog
# #gnb_snapshot
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actAperCsi}                              text|true|//*[@name\="actAperCsi"]
# ${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlOpenLoopPwrCtrl}                    text|false|//*[@name\="actUlOpenLoopPwrCtrl"]
# ${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
# ${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
# ${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
# ${basicBeamSet}                            text|beamSet_3_1|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}             text|4 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${actShortBsrLimitAdaptation}              text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actUlDftSOfdm}                           text|false|//*[@name\="actUlDftSOfdm"]
# ${actDl256Qam}                             text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
# ${csirsNumberWithinReportPeriod_Set1}           text|3|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${csirsPower}                                   text|6|//*[@name\="csirsPower"]
# ${maxCsirsNumber}                               text|4|//*[@name\="maxCsirsNumber"]
# 
# ${PROFILE1}    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
# 
# *** Test Cases ***
# CB009363-G_003_aperiadic_CSI_handling_for_single_UE_with_low_UL_data
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach UE and Start sporadic UL Traffic
# 	Step3:Change CQI
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${actAperCsi}    ${nrCellType}                         
# 	...      ${actUlOpenLoopPwrCtrl}    ${pucchModeSelect}    ${numberOfRxBeamforming}    ${numberOfRxPucch}    ${actFdmScheduling}                   
# 	...      ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${actBbPoolTddFr1}    ${actBbPoolTddFr1Enh}    ${basicBeamSet}                       
# 	...      ${numberOfTransmittedSsBlocks}    ${actShortBsrLimitAdaptation}    ${actCsirsMultiplexing}    ${actUlDftSOfdm}                      
# 	...      ${actDl256Qam}    ${actUl256Qam}    
# #	...      ${csirsNumberWithinReportPeriod_Set1}    ${csirsPower}    ${maxCsirsNumber}                    
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
# 	add_txt_node    0x590004:4
# 	add_txt_node    0x5900a8:1
# 	add_txt_node    0x58057C:0xFFFFFFFF
# 	add_txt_node    0x580431:1
# 	add_txt_node    0x5900D4:2
# 	add_txt_node    0x580385:0
# 	add_txt_node    0x580422:1
# 	add_txt_node    0x580384:0x2
# 	add_txt_node    0x58041e:0x0
# 	add_txt_node    0x58041f:0x28
# 	add_txt_node    0x580420:0x28
# 	add_txt_node    0x420068:7     rdTddPoolingFeaturesEnable 
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     #add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE and Start sporadic UL Traffic
#     Start capture GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Start GNB BIP Log
# 	Attach SA ue with capability to 5g cell    1    SA_UE_NR_CAPA_FULL_7220_2200_9363
#     Wait '5s' for stable running
#     Airphone Execute Egate Command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 protocol\=udp mbps\=5 burst\=5
#     Airphone Execute Egate Command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 protocol\=udp mbps\=5 burst\=5
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step2
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Change CQI
# 	Start capture GNB and AP Syslog in 'Step3' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
# 	Start GNB BIP Log
#     Airphone Execute Egate Command    ${PROFILE1}    
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    Step3
#     Stop Gnb BIP Log    log_dir=${save_log}
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G_case02_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
# 	
# Capture ttitrace
#     [Arguments]    ${time}    ${save_log}     ${file_tag}
#     Start GNB Ttitrace With Streaming Mode
#     sleep    ${time}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
