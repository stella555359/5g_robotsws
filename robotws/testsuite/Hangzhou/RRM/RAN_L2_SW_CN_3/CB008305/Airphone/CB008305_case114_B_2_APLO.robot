# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case114_B_2_multiple_UEs_mixed_scheduling_with_more_than_4UEs_single_layers
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    AP_REG
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
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
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
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
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${UE1_ID}                         1
# ${UE2_ID}                         2
# ${UE3_ID}                         3
# ${UE4_ID}                         4
# ${UE5_ID}                         5
# ${UE6_ID}                         6
# ${UE7_ID}                         7
# ${UE8_ID}                         8
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case114_B_2_multiple_UEs_mixed_scheduling_with_more_than_4UEs_single_layers
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 8 NonGBR UEs
#     Step3:Override Rank1 Push full buffer And Check Pair
#     Step4.1:Make UE-1 report rank2
#     Step4.2:Make UE-2 report rank2
#     Step4.3:Make UE-3 report rank2
#     Step4.4:Make UE-4 report rank2
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# #    add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}
#     ...       ${bwp_profile7}    ${bwp_profile73}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 8 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log    bip_use_admin_api=true
# #    : FOR    ${UE_ID}    IN RANGE    1      9
# #    \    ul_sinr_testmode_active    ${UE_ID}    6    100    -300    -1053
#     
#     Attach SA ue with capability to 5g cell    8    ${pattern}
#     
#     : FOR    ${UE_ID}    IN RANGE    1      9
#     \    csi_override_testmode_active    ${UE_ID}    1    0 
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
#     Set test Variable     ${rnti_4}     ${rnti_list[3]}
#     Set test Variable     ${rnti_5}     ${rnti_list[4]}
#     Set test Variable     ${rnti_6}     ${rnti_list[5]}
#     Set test Variable     ${rnti_7}     ${rnti_list[6]}
#     Set test Variable     ${rnti_8}     ${rnti_list[7]}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Override Rank1 Push full buffer And Check Pair
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     SA send multiple trf data    ${UE1_ID}    DL    175M    1
#     SA send multiple trf data    ${UE2_ID}    DL    175M    1
#     SA send multiple trf data    ${UE3_ID}    DL    175M    1
#     SA send multiple trf data    ${UE4_ID}    DL    175M    1
#     SA send multiple trf data    ${UE5_ID}    DL    175M    1
#     SA send multiple trf data    ${UE6_ID}    DL    175M    1
#     SA send multiple trf data    ${UE7_ID}    DL    175M    1
#     SA send multiple trf data    ${UE8_ID}    DL    175M    1
# #    Start GNB BIP Log    bip_use_admin_api=true
# #    Wait Throughput Timer    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 
#     : FOR    ${UE_ID}    IN RANGE    1      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     ue_srs_beam_pos_active    ${UE1_ID}    1    0
#     ue_srs_beam_pos_active    ${UE2_ID}    2    1
#     ue_srs_beam_pos_active    ${UE3_ID}    3    2
#     ue_srs_beam_pos_active    ${UE4_ID}    4    3
#     ue_srs_beam_pos_active    ${UE5_ID}    5    0
#     ue_srs_beam_pos_active    ${UE6_ID}    6    1
#     ue_srs_beam_pos_active    ${UE7_ID}    7    2
#     ue_srs_beam_pos_active    ${UE8_ID}    8    3
# 
#     Wait Throughput Timer    30
#     : FOR    ${UE_ID}    IN RANGE    1      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 70000
#     
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     get ttiTrace file number    ${save_log}/
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case114_step3_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
# 
#     ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     Should Be True    ${PM_counter_4layer_value}  > 10000000
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4.1:Make UE-1 report rank2
#     Start Capture GNB and AP Syslog in 'Step4.1_UE1_rank2' File
#     csi_override_testmode_deactive    ${UE1_ID}    1
#     csi_override_testmode_active      ${UE1_ID}    3    1
#     SA send multiple trf data    ${UE1_ID}    DL    175M    2
#     Wait Throughput Timer    10
#         : FOR    ${UE_ID}    IN RANGE    1      2
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 150000
#     : FOR    ${UE_ID}    IN RANGE    2      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 70000
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.1_UE1_rank2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4.1_UE1_rank2${/}
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_5layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34008   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     Should Be True    ${PM_counter_4layer_value}  > 5000000
#     Should Be True    ${PM_counter_5layer_value}  > 5000000
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.1_UE1_rank2' File
# 
# Step4.2:Make UE-2 report rank2
#     Start Capture GNB and AP Syslog in 'Step4.2_UE2_rank2' File
#     csi_override_testmode_deactive    ${UE2_ID}    1
#     csi_override_testmode_active      ${UE2_ID}    3    1
#     SA send multiple trf data         ${UE2_ID}    DL    175M    2
#     Wait Throughput Timer    10
#         : FOR    ${UE_ID}    IN RANGE    1      3
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 150000
#     : FOR    ${UE_ID}    IN RANGE    3      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 70000
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.2_UE2_rank2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4.2_UE2_rank2${/}
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_6layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34009   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     Should Be True    ${PM_counter_4layer_value}  > 1000000
#     Should Be True    ${PM_counter_6layer_value}  > 1000000
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.2_UE2_rank2' File
# 
# Step4.3:Make UE-3 report rank2
#     Start Capture GNB and AP Syslog in 'Step4.3_UE3_rank2' File
#     csi_override_testmode_deactive    ${UE3_ID}    1
#     csi_override_testmode_active      ${UE3_ID}    3    1
#     SA send multiple trf data         ${UE3_ID}    DL    175M    2
#     Wait Throughput Timer    10
#         : FOR    ${UE_ID}    IN RANGE    1      4
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 150000
#     : FOR    ${UE_ID}    IN RANGE    4      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 70000
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.3_UE3_rank2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4.3_UE3_rank2${/}
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_7layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34010   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     Should Be True    ${PM_counter_4layer_value}  > 1000000
#     Should Be True    ${PM_counter_7layer_value}  > 1000000
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.3_UE3_rank2' File
# 
# Step4.4:Make UE-4 report rank2
#     Start Capture GNB and AP Syslog in 'Step4.4_UE4_rank2' File
#     csi_override_testmode_deactive    ${UE4_ID}    1
#     csi_override_testmode_active      ${UE4_ID}    3    1
#     SA send multiple trf data         ${UE4_ID}    DL    175M    2
#     Wait Throughput Timer    10
#         : FOR    ${UE_ID}    IN RANGE    1      5
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 150000
#     : FOR    ${UE_ID}    IN RANGE    5      9
#     \    ${dl_tput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}   scell_id=0    type=pdsch    tput_type=ave
#     \    Should Be True    ${dl_tput_ue} > 70000
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.4_UE4_rank2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step4.4_UE4_rank2${/}
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_8layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34011   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10001   cell_id=1
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10003   cell_id=1
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C20001   cell_id=1
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55338C00001   cell_id=1
#     Should Be True    ${PM_counter_4layer_value}  > 0
#     Should Be True    ${PM_counter_8layer_value}  > 0
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     Should Be True    ${PM_counter_usedPrb_value} > 10000000
#     Should Be True    ${PM_counter_availPrb_value} > 10000000
#     Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
#     Should Be True    ${PM_counter_usedPrbPlmn_value} > 10000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.4_UE4_rank2' File
# 
# ul_sinr_testmode_active
#     [Arguments]    ${ue_id}    ${profile_id}    ${sinr_srs}    ${sinr_pucch}    ${noise_srs}
#     airphone_execute_egate_command
#     ...    ul_sinr_testmode_nr profile_id\=${profile_id} sinr_target_srs\=${sinr_srs} sinr_target_pucch\=${sinr_pucch} noise_srs\=${noise_srs}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${profile_id}
# 
# csi_override_testmode_active
#     [Arguments]    ${ueid}    ${profile_id}    ${ri}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${profile_id} cqi\=15 cqi_mode\=fixed ri\=${ri} ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=activate profile_id\=${profile_id}
# 
# csi_override_testmode_deactive
#     [Arguments]    ${ueid}    ${profile_id}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=deactivate profile_id\=${profile_id}
#     
# cell_srs_beam_pos_active
#     [Arguments]    ${profile_id}    ${num_pos}    ${azimuth}    ${cell_id}
#     airphone_execute_egate_command
#     ...    cell_srs_beam_pos_nr profile_id\=${profile_id} num_of_ue_positions\=${num_pos} azimuth\=${azimuth}
#     airphone_execute_egate_command
#     ...    cell_testmode_set_nr cell_id\=${cell_id} gnb\=2 testmode\=cell_srs_beam_pos profile_id\=${profile_id} action\=activate    
# 
# get ttiTrace file number
#     [Arguments]    ${tti_log_path}
#     ${files}     List Files In Directory      ${tti_log_path}          tti_dl*.csv
#     ${tti_num}       evaluate        len(${files})
#     ${tti_name}      set variable if     ${tti_num} ==1        tti_dl.csv       tti_dl.0.csv
#     set global variable  ${tti_name}
