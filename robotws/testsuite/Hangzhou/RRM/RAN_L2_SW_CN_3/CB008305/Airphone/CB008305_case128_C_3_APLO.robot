# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...               QC case full name:
# ...               CB008305_case128_C_3_Interworking_with_subcell_pooling_on_ABIO
# ...               This case is to verify the DL MU-MIMO only applies to PCell in TDD.
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC_case128.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC_case128-BSR.xml
# ${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_3S_1CC_case128.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# ${UE1_ID}             1
# ${UE2_ID}             2
# ${UE3_ID}             3
# ${UE4_ID}             4
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog\
# 
# ${actSpatialStreamPooling}        text|true|//*[@name\="actSpatialStreamPooling"]
# ${actTddPrePooling}               text|true|//*[@name\="actTddPrePooling"]
# ${chBw}                           text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${actBeamforming}                 text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                   text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}        text|97|//*[@name\="prachConfigurationIndex"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|42|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${nrBtsBeamRefinementP2}          text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}             text|2|//*[@name\="msg1FrequencyStart"]
# ${schedulBSD}                     text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}            text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}           text|false|//*[@name\="actCsirsMultiplexing"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${pattern}            CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case128_C_3_Interworking_with_subcell_pooling_on_ABIO
#     Step1:Commission the above configuration on WebUI
#     Step2:UE attach nr cell
#     Step3:Push full buffer in DL
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# #    modify_swconfig_by_CB008305_128    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${actSpatialStreamPooling}    ${actTddPrePooling}
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}    
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}    
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}    
#     ...       ${bwp_profile7}    ${bwp_profile73}     ${actCustomBsr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}
# 	...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:UE attach nr cell
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    4    ${pattern}
#     csi_override_testmode_active    1    3    3
#     csi_override_testmode_active    2    3    3
#     csi_override_testmode_active    3    3    3
#     csi_override_testmode_active    4    3    3
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
# 	Set test Variable     ${rnti_3}     ${rnti_list[2]}
# 	Set test Variable     ${rnti_4}     ${rnti_list[3]}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in DL
#     Start Capture GNB and AP Syslog in 'Step3' File
#     : FOR    ${i}    IN RANGE    1     6
#     \    Airphone SA Start Data Traffic    1    DL    100M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    DL    100M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    3    DL    100M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    4    DL    100M    trf_id=${i}    pdu_id=1    duration=${3600}
# #    SA send multiple trf data    1    DL    150M    5
# #    SA send multiple trf data    2    DL    150M    5
# #    SA send multiple trf data    3    DL    150M    5
# #    SA send multiple trf data    4    DL    150M    5
# 
#     Wait Throughput Timer    5
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${ue3_dl_tput}=    Airphone Get Throughput On Specific Scell    3    0    pdsch
#     ${ue4_dl_tput}=    Airphone Get Throughput On Specific Scell    4    0    pdsch
#         
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4 
# 
#     wait Throughput Timer    5
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${ue3_dl_tput}=    Airphone Get Throughput On Specific Scell    3    0    pdsch
#     ${ue4_dl_tput}=    Airphone Get Throughput On Specific Scell    4    0    pdsch
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     #run keyword and continue on failure    check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/log_check/tti_case128.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
