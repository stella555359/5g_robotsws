# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CNI84878_case101_B_1_Beam_power_balancing_optimizations_for_CB008247_8x4_rank4
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS22R4    RAN_5G_TDD    RAN_5G    owner_zhajiang
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${UE1_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${FILTER1}            dldata_pdschsendreq
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CONFIG_DIR_PATH}/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                              text|35|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                               text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}                       text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMaxNumLayerPerMuRbg}                      text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}                         text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}                            text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                            text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${BeamPowerBalance}                     text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${beamPowerOffset}                     text|15|//*[@name\="beamPowerOffsetThreshold"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# @{title1}    DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# 
# *** Test Cases ***
# CNI84878_case101_B_1_Beam_power_balancing_optimizations_for_CB008247_8x4_rank4
#     Step1: Commission the above configuration on WebUI
#     Step2: Attach UE rank=4 send buffer and capture logs
#     Step3: Check bip log
#     Step4: Change rank=3 check bip log
#     Step5: Change rank=2 check bip log
#     Step6: Change rank=1 check bip log
#     Step7: Detach UE
# 
# 
# *** Keywords ***
# Step1: Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    001    0    001    0    001    0    001    0    0
#     Set Pos By Modify L1ByPTestModeConfiguration    001    0    001    0    001    0    001    0    1
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CNI84878    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${prachConfigurationIndex}
#     ...       ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMaxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}
#     ...       ${dlMuMimoTaperingV}    ${pucchModeSelect}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
#     ...       ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${BeamPowerBalance}    ${beamPowerOffset}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2: Attach UE rank=4 send buffer and capture logs
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     airphone_override_deactive
#     airphone_override_active    3
#     SA send multiple trf data    ${UE1_ID}    DL    175M    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3: Check bip log
#     ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap1    ${log_dir}/bip_cni84878_rank4.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_cni84878_rank4.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# Step4: Change rank=3 check bip log
#     Start Collect GNB and AP Syslog in 'Step4_rank3' File
#     airphone_override_deactive
#     airphone_override_active    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank3
#     Start GNB BIP Log
#     Wait Throughput Timer    1
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/bip_cni84878_rank3.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_cni84878_rank3.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_rank3' File
# 
# Step5: Change rank=2 check bip log
#     Start Collect GNB and AP Syslog in 'Step5_rank2' File
#     airphone_override_deactive
#     airphone_override_active    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_rank2
#     Start GNB BIP Log
#     Wait Throughput Timer    1
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/bip_cni84878_rank2.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_cni84878_rank2.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_rank2' File
# 
# Step6: Change rank=1 check bip log
#     Start Collect GNB and AP Syslog in 'Step6_rank1' File
#     airphone_override_deactive
#     airphone_override_active    0
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_rank1
#     Start GNB BIP Log
#     Wait Throughput Timer    1
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/bip_cni84878_rank1.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_cni84878_rank1.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_rank1' File
# 
# Step7: Detach UE
#     Start Collect GNB and AP Syslog in 'Step7_detach' File
#     airphone_sa_stop_data_traffic    ${UE1_ID}   DL    pdu_id=1
#     airphone_sa_detach    ${UE1_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_detach' File
# 
# Step0
#     Start Collect GNB and AP Syslog in 'Step3' File
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File
# 
# 
# modify_swconfig_by_CNI84878
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:15         #as PM counter period update to 15/15=1min
# 	add_txt_node    0x580264:0x3        #rdDlSrsLogControl
# 	add_txt_node   0x580477:1           #print beam calc log
# 	add_txt_node    0x580396:0x1        #rdBestBeamPowerBalancingEnable
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# airphone_override_active
#     [Arguments]    ${i}
#     Airphone Execute Egate Command
#     ...    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=${i} cri_mode\=fixed cri\=1 li_mode\=fixed li\=${i}
#     #csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=2 pmi_mode=fixed pmi=500 cri_mode=fixed cri=1 li_mode=fixed li=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=csi_override action\=activate profile_id\=1
# 
# airphone_override_deactive
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE1_ID} testmode\=csi_override action\=deactivate profile_id\=1
