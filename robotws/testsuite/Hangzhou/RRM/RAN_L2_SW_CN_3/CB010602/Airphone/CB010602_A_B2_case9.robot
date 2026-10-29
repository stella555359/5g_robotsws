# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name: CB010602_A_B3_case9_Rank 4_4X4 CL(UE CSI RS)_SRS based beamforming extension
# ...               CB0010602 extends to support power balancing for UE with UE specific CSI-RS.
# ...               This case is for RANK=4
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${UE1_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${FILTER1}            ((dldata_pdschsendreq)||(DlData_CsiRsResource_t.density == 1)) && !(3gpp.rnti == 65535)
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CONFIG_DIR_PATH}/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    tshark    egatelog
# ${actCsirsBeamPowerBalance}                     text|true|//*[@name\="actCsirsBeamPowerBalance"]
# ${actPdschBeamPowerBalance}                     text|true|//*[@name\="actPdschBeamPowerBalance"]
# ${beamPowerOffsetThreshold}                     text|6|//*[@name\="beamPowerOffsetThreshold"]
# ${ue_specific}                                  text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${actDlMuMimoEnh}                               text|false|//*[@name\="actDlMuMimoEnh"]
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
# ${pattern}    CA_P2_8x4_t2r4_n2
# @{title1}    DlData_PdschGrant.bestBeamPowerOffset    3gpp.rnti    DlData_PdschGrant.closedLoop3gppCodebook    DlData_PdschGrant.numOfLayers
# ...          DlData_PdschGrant.patternId_item    DlData_CsiRsResource_t.patternId_item    DlData_CsiRsResource_t.csiBestBeamPowerOffset
# ...          DlData_CsiRsResource_t.csiRsConfig        DlData_CsiRsResource_t.density
# ${ant5}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
# ${ant6}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
# ${ant7}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7
# ${ant8}                                         MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8
# 
# 
# *** Test Cases ***
# CB010602_A_B2_case9_Rank4_4X4_CL_UE_CSI_RS_SRS_based_beamforming_extension
#     Step1: Commission the above configuration on WebUI
#     Step2: Attach UE rank=3 send buffer and capture logs
# #    Step3: Detach UE
# 
# 
# *** Keywords ***
# Step1: Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${mod_iphy}    create list     text|1|//NumberOfSubCellsUL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    012    0    012    0    012    0    012    0    0
# #    Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB010602    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     del_eles_from_xml    ${scfc_path}    ${ant5}
#     del_eles_from_xml    ${scfc_path}    ${ant6}
#     del_eles_from_xml    ${scfc_path}    ${ant7}
#     del_eles_from_xml    ${scfc_path}    ${ant8}
#     ${modify_list}    create list
#     ...       ${actCsirsBeamPowerBalance}    ${actPdschBeamPowerBalance}    ${beamPowerOffsetThreshold}
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlSrsBm}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${prachConfigurationIndex}
#     ...       ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMaxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}
#     ...       ${dlMuMimoTaperingV}    ${pucchModeSelect}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
#     ...       ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${actDl256Qam}    ${ue_specific}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log
#     ...    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}    L1b=True
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2: Attach UE rank=3 send buffer and capture logs
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
#     Check beamOffset in bip    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${BEAM_PWR_OFFSET_RI4_INDEX4}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55305C14017  cell_id=1
#     should be true    ${BEAM_PWR_OFFSET_RI4_INDEX4} > 40000
#     should be true    ${BEAM_PWR_OFFSET_RI4_INDEX4} < 84001
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/rrc_case9_p4.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Check beamOffset in bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_off.pcap1    ${log_dir}/bip_case9_rank4.csv    ${FILTER1}    ${title1}
#     Check Log With Au2anlysis    ini_path=${CURDIR}/log_check/bip_case9_rank4.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# Step3: Detach UE
#     Start Collect GNB and AP Syslog in 'Step3_detach' File
#     airphone_sa_stop_data_traffic    ${UE1_ID}   DL    pdu_id=1
#     airphone_sa_detach    ${UE1_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_detach' File
# 
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
