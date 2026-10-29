# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case117_B_2_multiple_UEs_mixed_scheduling_with_1_layer_to_4_layers_mixed
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# #${WTS_NAME}           8305_MU_MIMO.lua
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${chBw}                           text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${actBeamforming}                 text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                   text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# 
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}                          text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
# 
# ${bwp_profile7}       text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}            CA_P2_8x4_t2r4_n2
# ${UE1_ID}         1
# ${UE2_ID}         2
# 
# *** Test Cases ***
# CB008305_case117_B_2_multiple_UEs_mixed_scheduling_with_1_layer_to_4_layers_mixed
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2 rank4 UEs
#     Step3:Push full buffer And Check Pair
#     Step4.1:Make UE1 report rank3
#     Step4.2:Make UE1 report rank2
#     Step4.3:Make UE1 report rank1
#     Step5:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
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
# Step2:Attach 2 rank4 UEs
#     Start Capture GNB and AP Syslog in 'Step2' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    ${pattern}
#     csi_override_testmode_active    ${UE1_ID}    3    3
#     csi_override_testmode_active    ${UE2_ID}    3    3
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2' File
# 
# Step3:Push full buffer And Check Pair
#     Start Capture GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     SA send multiple trf data    ${UE1_ID}    DL    175M    4
#     SA send multiple trf data    ${UE2_ID}    DL    175M    4
# 
#     Wait Throughput Timer    5
#     
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	
# 	
# #    ue_srs_beam_pos_active    ${UE1_ID}    1    0
# #    ue_srs_beam_pos_active    ${UE2_ID}    2    3
# #    ul_sinr_testmode_active    ${UE1_ID}    6    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE2_ID}    6    100    -300    -1053
# #    Start GNB BIP Log
# #    Wait Throughput Timer    1
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     wait Throughput Timer    5
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     capture_ttitrace    ${save_log}
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34011   cell_id=1
#     ${2rank4_dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value} > 12000000
#     Should Be True    ${2rank4_dL_thp_counter} > 150000000
#     check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
# 
# Step4.1:Make UE1 report rank3
#     Start Capture GNB and AP Syslog in 'Step4_1' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_1
# #    Start GNB BIP Log
#     csi_override_testmode_deactive    ${UE1_ID}    3
#     csi_override_testmode_active    ${UE1_ID}    2    2
# #    ul_sinr_testmode_active    ${UE1_ID}    7    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE1_ID}    7    100    -300    -230
# #    Wait Throughput Timer    1
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Wait Throughput Timer    5
#     capture_ttitrace    ${save_log}
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${counter_file}    download PM counter file    ${save_log}
#     ${PM_counter_6layer_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34009   cell_id=1
#     ${rank42_dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_6layer_value} > 12000000
#     Should Be True    ${rank42_dL_thp_counter} > 120000000
#     check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_1' File
# 
# Step4.2:Make UE1 report rank2
#     Start Capture GNB and AP Syslog in 'Step4_2' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_2
#     #Start GNB BIP Log
#     csi_override_testmode_deactive    ${UE1_ID}    2
#     csi_override_testmode_active    ${UE1_ID}    1    1
# #    ul_sinr_testmode_active    ${UE1_ID}    8    100    -300    -1053
#     Wait Throughput Timer    5
# #    Wait Throughput Timer    1
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     capture_ttitrace    ${save_log}
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${counter_file}    download PM counter file    ${save_log}
#     ${PM_counter_6layer_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34009   cell_id=1
#     ${rank42_dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_6layer_value} > 12000000
#     Should Be True    ${rank42_dL_thp_counter} > 120000000
#     check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_2' File
# 
# Step4.3:Make UE1 report rank1
#     Start Capture GNB and AP Syslog in 'Step4_3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_3
#     #Start GNB BIP Log
#     csi_override_testmode_deactive    ${UE1_ID}    1
#     csi_override_testmode_active    ${UE1_ID}    4    0
# #    ul_sinr_testmode_active    ${UE1_ID}    9    100    -300    -1053
# #    Wait Throughput Timer    1
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Wait Throughput Timer    5
#     capture_ttitrace    ${save_log}
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_1.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${ue1_dl_tput}=    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${ue2_dl_tput}=    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${counter_file}    download PM counter file    ${save_log}
#     ${PM_counter_5layer_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34008   cell_id=1
#     ${rank41_dL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_5layer_value} > 12000000
#     Should Be True    ${rank41_dL_thp_counter} > 100000000
# 	check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_3' File
# 
# Step5:Detach UEs
#     Stop '2'UE DL Traffic
#     Detach '2'UE
# 
# 
# check_prb_counter
#     [Arguments]    ${counter_file}
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34013   cell_id=1
# 	${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10001   cell_id=1
# 	${PM_counter_availPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10003   cell_id=1
# 	${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C20001   cell_id=1
# 	${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55338C00001   cell_id=1
# 	Should Be True    ${PM_counter_2pairUE_value} > 10000000
# 	Should Be True    ${PM_counter_usedPrb_value} > 10000000
# 	Should Be True    ${PM_counter_availPrb_value} > 10000000
# 	Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
# 	Should Be True    ${PM_counter_usedPrbPlmn_value} > 10000000
# 
# 
# 
# cell_srs_beam_pos_active
#     [Arguments]    ${profile_id}    ${num_pos}    ${azimuth}    ${cell_id}
#     airphone_execute_egate_command
#     ...    cell_srs_beam_pos_nr profile_id\=${profile_id} num_of_ue_positions\=${num_pos} azimuth\=${azimuth}
#     airphone_execute_egate_command
#     ...    cell_testmode_set_nr cell_id\=${cell_id} gnb\=2 testmode\=cell_srs_beam_pos profile_id\=${profile_id} action\=activate
# 
# capture_ttitrace
#     [Arguments]    ${tti_dir}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${tti_dir}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${tti_dir}/tti
# 
# 
