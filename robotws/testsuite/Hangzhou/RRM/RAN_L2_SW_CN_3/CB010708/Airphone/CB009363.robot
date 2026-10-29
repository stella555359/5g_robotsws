# *** Settings ***
# Documentation     
# ...
# ...               QC case full name:
# ...               
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
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
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}    gNB_scf_ASIM_ABIP_AVQL_TDD_eCPRI_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AVQL_ASIM_ABIP_TDD_eCPRI_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfRxPucch}                         text|4Rx|//*[@name\="numberOfRxPucch"]
# ${nrCellType}                              text|8D8U|//*[@name\="nrCellType"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actCustomBsr}                            text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}                       text|BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002|//*[@name\="customBeamSetName"]
# ${basicBeamSet}                            text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}             text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# 
# *** Test Cases ***
# CB010708_start_up
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach UE and start buffer
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
# 	...      ${chBw}    ${cellDepType}    ${actDlSrsBm}    ${actUlSrsBm}    ${dlMimoMode}    ${numberOfRxBeamforming}
# 	...      ${numberOfRxPucch}    ${actFdmScheduling}    ${actBeamforming}    ${nrBtsBeamRefinementP2}
# 	...      ${nrCellType}    ${actCustomBsr}    ${customBeamSetName}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
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
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     #add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE and start buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2_fullpower
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     Wait Throughput Timer    15
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File