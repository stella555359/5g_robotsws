# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case103_B_2_three_UEs_mixed_scheduling_with_dlMuMimoRankAdaption_equal_to_adaptive
# ...
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# #Resource          ../resources/sg11/internal_resource/robot/internal_aic.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_8305.xml
# ${CU_SCF}             scfc_VCU.xml
# ${AIRPHONE_NAME}      new_iphy.xml
# ${WTS_NAME}           basic_setup.cfg
# 
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# ${UE1_ID}             1
# ${UE2_ID}             2
# ${UE3_ID}             3
# @{LOG_NAME_LIST}      egatelog
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoRankAdaption}                         text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|33|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${dlMuMimoCorrThd}                           text|80|//*[@name\="dlMuMimoCorrThd"]
# #bwp1208
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}           CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case103_B_2_three_UEs_mixed_scheduling_with_dlMuMimoRankAdaption_equal_to_adaptive_vran
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3 NonGBR UEs
#     Step3:Push full buffer And check
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# #    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# #    modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${DU_SCF}
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_8305.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
#     ${modify_list}    create list    ${actDlMuMimoEnh}    ${dlMuMimoRankAdaption}
# #    ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${dlMuMimoCorrThd}
# #    ...       ${frameStructureType}    ${guardPeriodLength}    ${prachConfigurationIndex}    ${bwp_profile5}    ${bwp_profile57}
# #    ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}
# #    ...       ${msg1FrequencyStart}    ${schedulBSD}    ${dlMuMimoRankAdaption}    ${miNrCellUtilPerPLMN}
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 3 NonGBR UEs
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     ue_srs_beam_pos_active    ${UE1_ID}    1    0
#     ue_srs_beam_pos_active    ${UE2_ID}    2    1
#     ue_srs_beam_pos_active    ${UE3_ID}    3    3
#     #ul_sinr_testmode_active    ${UE1_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE2_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE3_ID}    6    100    -300    -1053
#     Attach SA ue with capability to 5g cell    3    ${pattern}
#     csi_override_testmode_active    ${UE1_ID}    2    3
#     csi_override_testmode_active    ${UE2_ID}    2    3
#     csi_override_testmode_active    ${UE3_ID}    2    3
# 
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# #    VDU Stop Collect And Download Bip Logs    container_name=l2rt
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# #    vran syslog capture    &{MASTER_VDU}
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     SA send multiple trf data    ${UE1_ID}    DL    150M    5
#     SA send multiple trf data    ${UE2_ID}    DL    150M    5
#     SA send multiple trf data    ${UE3_ID}    DL    150M    5
#     
#     Wait Throughput Timer    5
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
# #    Should Be True    ${tput_ue1} > 600000
# #    Should Be True    ${tput_ue2} > 600000
# #    Should Be True    ${tput_ue3} > 600000
# 
#     Wait Throughput Timer    3
#     ${Dl_tput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Dl_tput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=dl
#     ${Dl_tput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=dl
# 
# #    VDU Start Collect Bip Logs    l2rt
# #    Wait Throughput Timer    3
# #    VDU Stop Collect And Download Bip Logs    container_name=l2rt
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    3
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case103_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    300
#     ${PM_counter_noPair_value}=    VDU Get PM Counter Value   counter_id=M55308C34012   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_noPair_value} < 2000000
#     ${PM_counter_8layer_value}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} < 2000000
#     ${PM_counter_2pairUE_value}=    VDU Get PM Counter Value   counter_id=M55308C34013   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} < 2000000
#     ${PM_counter_6layer_value}=    VDU Get PM Counter Value   counter_id=M55308C34009   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_6layer_value} > 20000000
#     ${PM_counter_3pairUE_value}=    VDU Get PM Counter Value   counter_id=M55308C34014   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_3pairUE_value} > 20000000
#     ${PM_counter_usedPrb_value}=    VDU Get PM Counter Value   counter_id=M55308C10001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_usedPrb_value} > 20000000
#     ${PM_counter_availPrb_value}=    VDU Get PM Counter Value   counter_id=M55308C10003   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 20000000
#     ${PM_counter_MaxAllocPrb_value}=    VDU Get PM Counter Value   counter_id=M55308C20001   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 273
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
