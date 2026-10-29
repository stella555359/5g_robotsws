# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...               QC case full name:
# ...               CB008305_case120_B_2_multiple_UEs_mixed_scheduling_with_RSRP_change
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
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${chBw}                           text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|10|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|always|//*[@name\="dlMuMimoRankAdaption"]
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
# ${actUlMuMimoTapering}            text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                     text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}            text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}           text|false|//*[@name\="actCsirsMultiplexing"]
# ${dllaDeltaCqiMax}                text|0|//*[@name\="dllaDeltaCqiMax"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${UE1_ID}                         1
# ${UE2_ID}                         2
# ${UE3_ID}                         3
# ${UE4_ID}                         4
# ${UE5_ID}                         5
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case120_B_2_multiple_UEs_mixed_scheduling_with_RSRP_change
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 5 NonGBR UEs
#     Step3:Push full buffer And Check Pair
#     Step4:Override UE1 CQI Less Than 10
#     Step5:Override UE1 CQI Bigger Than 10
#     Step6:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1' File
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
#     ...       ${bwp_profile7}    ${bwp_profile73}    ${dllaDeltaCqiMax}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1' File
# 
# Step2:Attach 5 NonGBR UEs
#     Start Collect GNB and AP Syslog in 'Step2' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Start GNB BIP Log
# #    ul_sinr_testmode_active    ${UE1_ID}    6    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE2_ID}    6    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE3_ID}    6    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE4_ID}    6    100    -300    -1053
# #    ul_sinr_testmode_active    ${UE5_ID}    6    100    -300    -1053
#     csi_override_testmode_active    ${UE1_ID}    1    3
#     csi_override_testmode_active    ${UE2_ID}    1    3
#     csi_override_testmode_active    ${UE3_ID}    1    3
#     csi_override_testmode_active    ${UE4_ID}    1    3
#     csi_override_testmode_active    ${UE5_ID}    1    3
#     ue_srs_beam_pos_active    ${UE1_ID}    1    0
#     ue_srs_beam_pos_active    ${UE2_ID}    2    1
#     ue_srs_beam_pos_active    ${UE3_ID}    3    2
#     ue_srs_beam_pos_active    ${UE4_ID}    4    3
#     ue_srs_beam_pos_active    ${UE5_ID}    5    3
#     Attach SA ue with capability to 5g cell    5    ${pattern}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2' File
# 
# Step3:Push full buffer And Check Pair
#     Start Collect GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     SA send multiple trf data    ${UE1_ID}    DL    175M    2
#     SA send multiple trf data    ${UE2_ID}    DL    175M    2
#     SA send multiple trf data    ${UE3_ID}    DL    175M    2
#     SA send multiple trf data    ${UE4_ID}    DL    175M    2
#     SA send multiple trf data    ${UE5_ID}    DL    175M    2
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case120_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, Legacy PM counter    ${counter_file}    8    4
#     ${PM_counter_8layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34011    cell_id=1
#     ${PM_counter_4pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34015    cell_id=1
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value} > 5000000
#     Should Be True    ${PM_counter_4pairUE_value} > 5000000
#     Should Be True    ${dL_thp_counter} > 12000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File
# 
# Step4:Override UE1 CQI Less Than 10
#     Start Collect GNB and AP Syslog in 'Step4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     csi_override_testmode_deactive    ${UE5_ID}    1
#     csi_override_testmode_active    ${UE5_ID}    2    3    8
#     Wait Throughput Timer    5
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case120_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, Legacy PM counter    ${counter_file}    8    4
#     ${PM_counter_8layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34011    cell_id=1
#     ${PM_counter_4pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34015    cell_id=1
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value} > 2000000
#     Should Be True    ${PM_counter_4pairUE_value} > 2000000
#     Should Be True    ${dL_thp_counter} > 11000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File
# 
# 
# Step5:Override UE1 CQI Bigger Than 10
#     Start Collect GNB and AP Syslog in 'Step5' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     csi_override_testmode_deactive    ${UE5_ID}    2
#     csi_override_testmode_active    ${UE5_ID}    3    3    15
#     Wait Throughput Timer    5
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case120_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, Legacy PM counter    ${counter_file}    8    4
#     ${PM_counter_8layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34011    cell_id=1
#     ${PM_counter_4pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34015    cell_id=1
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value} > 5000000
#     Should Be True    ${PM_counter_4pairUE_value} > 5000000
#     Should Be True    ${dL_thp_counter} > 12000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5' File
# 
# Step6:Detach UEs
#     Stop '5'UE DL Traffic
#     Detach '5'UE
# 
# Check MUlayer, PairUE, Legacy PM counter
#     [Arguments]    ${counter_file}    ${MUlayer}    ${PairUE}
# #    ${PM_counter_8layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34011    cell_id=1
#     ${PM_counter_6layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34009    cell_id=1
#     ${PM_counter_4layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34007    cell_id=1
#     ${PM_counter_3pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34014    cell_id=1
#     ${PM_counter_2pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34013    cell_id=1
#     ${PM_counter_usedPrb_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C10001    cell_id=1
#     ${PM_counter_availPrb_value}=       get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C10003    cell_id=1
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C20001    cell_id=1
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55338C00001    cell_id=1
#     Should Be True    ${PM_counter_usedPrb_value} > 12000000
#     Should Be True    ${PM_counter_availPrb_value} > 12000000
# #    Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
#     Should Be True    ${PM_counter_usedPrbPlmn_value} > 12000000
# 
# 
# Check 5UEs Thp On Specific Scell
#     ${Dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${Dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${Dl_throughput_ue3} =    Airphone Get Throughput On Specific Scell    3    0    pdsch
#     ${Dl_throughput_ue4} =    Airphone Get Throughput On Specific Scell    4    0    pdsch
#     ${Dl_throughput_ue5} =    Airphone Get Throughput On Specific Scell    5    0    pdsch
#     Should Be True    ${Dl_throughput_ue1} > 0
#     Should Be True    ${Dl_throughput_ue2} > 0
#     Should Be True    ${Dl_throughput_ue3} > 0
#     Should Be True    ${Dl_throughput_ue4} > 0
#     Should Be True    ${Dl_throughput_ue5} > 0
# 
