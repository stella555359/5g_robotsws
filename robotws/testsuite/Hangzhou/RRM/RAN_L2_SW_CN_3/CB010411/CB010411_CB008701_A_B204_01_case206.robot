# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008701_A_B204_01_case206_4UEs_rank_4_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
# ...
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# #Resource          ../resources/sg11/internal_resource/robot/internal_aic.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_8701.xml
# ${CU_SCF}             scfc_VCU_8701.xml
# ${AIRPHONE_NAME}      iphy_8701.xml
# ${WTS_NAME}           basic_setup_8701.cfg
# 
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# 
# ${UE1_ID}             1
# ${UE2_ID}             2
# ${UE3_ID}             3
# ${UE4_ID}             4
# ${UE_NUM}             4
# ${par_of_bsr_name}       BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# #${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|16DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# #dlmumimo
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                                   text|99|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                                  text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                             text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                            text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                 text|30dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}                     text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${actDl256Qam}                              text|false|//*[@name\="actDl256Qam"]
# #1208
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# #bwp
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# 
# 
# *** Test Cases ***
# CB008701_A_B204_01_case206_4UEs_rank_4_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4UEs_rank4
#     Step3:push buffer
#     Step5:change UE1 to rank3
#     Step6:change UE2 to rank2
#     Step7:change UE3 to rank1
#     Step8:change UE4 to rank1
#     Step9:change UE1-UE4 to rank4
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# #    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# #    modify_swconfig_by_CB008305_vRan    ${CONFIG_DIR_PATH}${/}${DU_SCF}
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_8701.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${msg1FrequencyStart}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${bwp_profile5}    ${bwp_profile57}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actDl256Qam}    ${dlMuMaxNumLayerPerMuRbg}    ${nrBtsBeamRefinementP2}
# #    modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# #    AIC Get and Update BSR File    ${par_of_bsr_name}
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4UEs_rank4
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Set UEi position    ${UE1_ID}    ${PROFILE1}
#     Set UEi position    ${UE2_ID}    ${PROFILE2}
#     Set UEi position    ${UE3_ID}    ${PROFILE3}
#     Set UEi position    ${UE4_ID}    ${PROFILE4}
#     Attach SA ue with capability to 5g cell    4    ${pattern}
# #    csi_override_testmode_active    ${ueid}    ${profile_id}    ${ri}    ${cqi}=15
#     csi_override_testmode_active    ${UE1_ID}    1    3
#     csi_override_testmode_active    ${UE2_ID}    1    3
#     csi_override_testmode_active    ${UE3_ID}    1    3
#     csi_override_testmode_active    ${UE4_ID}    1    3
#     Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# #    VDU Stop Collect And Download Bip Logs    container_name=l2rt
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# #    vran syslog capture    &{MASTER_VDU}
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     Set test Variable	 ${rnti_4} 	${rnti_list[3]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:push buffer
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
# #    ${trace_id}     VDU Start TTiTrace Log
#     SA send multiple trf data    ${UE1_ID}    DL    150M    4
#     SA send multiple trf data    ${UE2_ID}    DL    150M    4
#     SA send multiple trf data    ${UE3_ID}    DL    150M    4
#     SA send multiple trf data    ${UE4_ID}    DL    150M    4
# #    Wait Throughput Timer    2
# #    VDU Stop TTiTrace Log    ${trace_id}
# #    VDU Decode TTiTrace Log    csv_dir=${save_log}/
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_2
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_always.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    300
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} > 0
# 
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step5:change UE1 to rank3
#     Start Collect GNB and AP Syslog in 'Step5_change_UE1_to_rank3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_change_UE1_to_rank3
#     csi_override_testmode_active    ${UE1_ID}    2    2
#     Wait Throughput Timer    3
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE1_change.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    60
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_change_UE1_to_rank3' File
# 
# 
# Step6:change UE2 to rank2
#     Start Collect GNB and AP Syslog in 'Step6_change_UE2_to_rank2' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_change_UE2_to_rank2
#     csi_override_testmode_active    ${UE2_ID}    3    1
#     Wait Throughput Timer    3
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    60
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} > 0
# 
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_change_UE2_to_rank2' File
# 
# 
# Step7:change UE3 to rank1
#     Start Collect GNB and AP Syslog in 'Step7_change_UE3_to_rank1' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_change_UE3_to_rank1
#     csi_override_testmode_active    ${UE3_ID}    4    0
#     Wait Throughput Timer    3
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    60
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} == 0
#     ${PPRB_DL_MU_MIMO_7LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34010   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_7LAYER} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_change_UE3_to_rank1' File
# 
# Step8:change UE4 to rank1
#     Start Collect GNB and AP Syslog in 'Step8_change_UE4_to_rank1' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8_change_UE4_to_rank1
#     csi_override_testmode_active    ${UE4_ID}    4    0
#     Wait Throughput Timer    3
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    60
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} == 0
#     ${PPRB_DL_MU_MIMO_7LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34010   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_7LAYER} == 0
#     ${PPRB_DL_MU_MIMO_6LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34009   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_6LAYER} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_change_UE4_to_rank1' File
# 
# 
# Step9:change UE1-UE4 to rank4
#     Start Collect GNB and AP Syslog in 'Step9_change_UES_to_rank4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step9_change_UES_to_rank4
#     csi_override_testmode_active    ${UE1_ID}    1    3
#     csi_override_testmode_active    ${UE2_ID}    1    3
#     csi_override_testmode_active    ${UE3_ID}    1    3
#     csi_override_testmode_active    ${UE4_ID}    1    3
#     Wait Throughput Timer    3
#     ${tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     Collet VDU and VCU syslog
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/
# #  check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_always.ini    log_need_to_check=i    
#    ...    save_log_directory=${save_log}
# 
#     Wait Throughput Timer    60
#     ${PPRB_DL_MU_MIMO_16LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34023   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     ${PPRB_DL_MU_MIMO_12LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34019   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_12LAYER} ==0
#     ${PPRB_DL_MU_MIMO_8LAYER}=    VDU Get PM Counter Value   counter_id=M55308C34011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     run keyword and continue on failure    Should Be True    ${PPRB_DL_MU_MIMO_8LAYER} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step9_change_UES_to_rank4' File
# 
# Set UEi position
#     [Arguments]    ${ue_id}    ${PROFILE}
#     airphone_execute_egate_command    ${PROFILE}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${ue_id}
