# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CNI83499_case01_ue_attach_detach_repeatedly_same_patternId_and_peak
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS22R4    RAN_5G_TDD    RAN_5G    owner_zhajiang
# Test Timeout      300 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${UE1_ID}         1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${FILTER1}    ((dldata_pdcchsendreq)||(dldata_pdschsendreq)||(DlData_CsiRsResource_t.density == 1)) && !(3gpp.rnti == 65535)
# @{title1}    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# ...          DlData_PdschGrant.patternId_item    DlData_CsiRsResource_t.patternId_item    DlData_DciInfo.patternId_item
# ...          DlData_CsiRsResource_t.csiRsConfig    DlData_CsiRsResource_t.density    DlData_PdschGrant.pdschPrecodingOption4x4
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# #${WTS_NAME}           wts_200SA.cfg
# ${COMAVALUE}          ${CONFIG_DIR_PATH}/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actUeCsirsCoexistCellCsirs}                   text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${pattern}                                      CA_P2_8x4_t2r4_n2
# ${ant5}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
# ${ant6}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
# ${ant7}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7
# ${ant8}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8
# ${UE_ID_list}                                   1...200
# *** Test Cases ***
# CNI83499_case01_ue_attach_detach_repeatedly_same_patternId_and_peak
#     Step1: Commission the above configuration on WebUI
#     Step2: Attach UE and detach repeatedly
# 
# *** Keywords ***
# Step1: Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${mod_iphy}    create list     text|1|//NumberOfSubCellsUL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     : FOR    ${num}    IN RANGE    0    8
#     \    Set Pos By Modify L1ByPTestModeConfiguration
#     ...    5    5    5    5    5    5    5    5    ${num}    0    0    0    0    0    0    0    0    4    4
# 
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CNI83499    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     del_eles_from_xml    ${scfc_path}    ${ant5}
#     del_eles_from_xml    ${scfc_path}    ${ant6}
#     del_eles_from_xml    ${scfc_path}    ${ant7}
#     del_eles_from_xml    ${scfc_path}    ${ant8}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${prachConfigurationIndex}    ${pucchModeSelect}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${actUeCsirsCoexistCellCsirs}    ${actUlMuMimoTapering}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2: Attach UE and detach repeatedly
#     Start Collect GNB and AP Syslog in 'Step2' File
# #    Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t4r4_n4
# #    send 3ues buffer
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
# #    : FOR    ${num}    IN RANGE    1    201
# #    \    airphone_execute_egate_command    ue_register id\=${num}
# #    \    Sleep    0.002
# #    Airphone SA Attach    ${UE_ID_list}   300
# #    airphone_execute_egate_command    ue_register id\=1-100
# #    Airphone Set Traffic Type    ${UE_ID_list}
# #    Airphone Pdu Session Setup    ${UE_ID_list}
# #     Attach SA ue with capability to 5g cell    200
#     : FOR    ${num}    IN RANGE    0    100
#     \    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     \    SA send multiple trf data    ${UE1_ID}    DL    175M    1
#     \    Start GNB BIP Log
#     \    Wait Throughput Timer    1
#     \    Stop Gnb BIP Log    log_dir=${save_log}/${num}
#     \    check patternid in bip    ${save_log}/${num}
#    # \    Start GNB Ttitrace With Streaming Mode
#     \    airphone_sa_stop_data_traffic    ${UE1_ID}   DL    pdu_id=1
#     \    airphone_sa_detach    ${UE1_ID}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2' File
# 
# check patternid in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap0    ${log_dir}/bip83499_case01.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip83499_case01.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# modify_swconfig_by_CNI83499
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
#     add_txt_node    0x5806D7:1
#     teardown_txt
# 
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt