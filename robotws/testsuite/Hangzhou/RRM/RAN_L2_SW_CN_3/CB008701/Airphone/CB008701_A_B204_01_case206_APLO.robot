# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008701_A_B204_01_case206_4UEs_rank_4_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}     gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_8701.xml
# ${AIRPHONE_NAME}    AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}    wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_8701.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# 
# ${UE_NUM}         4
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
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
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# 
# *** Test Cases ***
# CB008701_A_B204_01_case206_4UEs_rank_4_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4UEs_rank4
#     Step3:push buffer
#     Step4:layer and paired_ratio check
#     Step5:change UE1 to rank3
#     Step6:change UE2 to rank2
#     Step7:change UE3 to rank1
# 	Step8:change UE4 to rank1
# 	Step9:change UE1-UE4 to rank4
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    12    8    6    0    6    0    6    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    4    22    0    22    0    22    0    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    23    9    6    0    6    0    6    0    2
#     #Set Pos By Modify L1ByPTestModeConfiguration    15    6    22    0    22    0    22    0    3    ComaMultiplier=29
#     ##Set Pos By Modify L1ByPTestModeConfiguration    13    7    6    0    6    0    6    0    0
#     ##Set Pos By Modify L1ByPTestModeConfiguration    6    7    22    0    22    0    22    0    1
#     ##Set Pos By Modify L1ByPTestModeConfiguration    25    7    6    0    6    0    6    0    2
#     ##Set Pos By Modify L1ByPTestModeConfiguration    17    7    22    0    22    0    22    0    3    ComaMultiplier=29
#     #Set Pos By Modify L1ByPTestModeConfiguration    15    8   6    0    6    0    6    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    12    7    6    0    6    0    6    0    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    21    8    22    0    22    0    22    0    2
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    7    22    0    22    0    22    0    3
#     #Set Pos By Modify L1ByPTestModeConfiguration    2    8    6    0    6    0    6    0    4
#     #Set Pos By Modify L1ByPTestModeConfiguration    25    7    6    0    6    0    6    0    5
# 
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${msg1FrequencyStart}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${bwp_profile5}    ${bwp_profile57}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actDl256Qam}    ${dlMuMaxNumLayerPerMuRbg}    ${nrBtsBeamRefinementP2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4UEs_rank4
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	#Start GNB BIP Log
#     Set UEs Pos	
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${UE_ID}    SetVariable    ${ID}
#     ${GW_ID}    SetVariable    ${ID}
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     END
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:push buffer
#     Start Collect GNB and AP Syslog in 'Step3_push_buffer' File
#     #Start GNB BIP Log
#     FOR    ${ID}    IN RANGE    1    5
#     Airphone SA Start Data Traffic    1    DL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    150M    trf_id=${ID}    pdu_id=1    duration=${3600}
#     END
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_push_buffer' File
# 
# Step4:Layer and paired_ratio check
#     Start Collect GNB and AP Syslog in 'step4_layer_paired_check' File
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
# 	${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step4_layer_paired_check/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} >0
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}step4_layer_paired_check${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}step4_layer_paired_check${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_always.ini    
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}step4_layer_paired_check${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_layer_paired_check' File
# 
# Step5:change UE1 to rank3
#     Start Collect GNB and AP Syslog in 'Step5_change_UE1_to_rank3' File
#     #Start GNB BIP Log
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_change_UE1_to_rank3${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_change_UE1_to_rank3/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_change_UE1_to_rank3
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_change_UE1_to_rank3/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE1_change.ini    
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_change_UE1_to_rank3${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_change_UE1_to_rank3' File
# 
# 
# Step6:change UE2 to rank2
#     Start Collect GNB and AP Syslog in 'Step6_change_UE2_to_rank2' File
#     #Start GNB BIP Log
# 
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1
# 
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_change_UE2_to_rank2${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step6_change_UE2_to_rank2/
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34015    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_change_UE2_to_rank2
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_change_UE2_to_rank2/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    
# 	...    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step6_change_UE2_to_rank2${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_change_UE2_to_rank2' File
# 
# 
# Step7:change UE3 to rank1
#     Start Collect GNB and AP Syslog in 'Step7_change_UE3_to_rank1' File
#     #Start GNB BIP Log
# 
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=4
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1
# 
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_change_UE3_to_rank1${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step7_change_UE3_to_rank1/
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
# 	${PPRB_DL_MU_MIMO_7LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34010    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_7LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step7_change_UE3_to_rank1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step7_change_UE3_to_rank1/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step7_change_UE3_to_rank1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_change_UE3_to_rank1' File
# 
# Step8:change UE4 to rank1
#     Start Collect GNB and AP Syslog in 'Step8_change_UE4_to_rank1' File
#     #Start GNB BIP Log
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=2
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=4
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=4
# 
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8_change_UE4_to_rank1${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step8_change_UE4_to_rank1/
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
# 	${PPRB_DL_MU_MIMO_7LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34010    cell_id=1
# 	${PPRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34009    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_7LAYER} ==0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_6LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step8_change_UE4_to_rank1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step8_change_UE4_to_rank1/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_UE2_change.ini    
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step8_change_UE4_to_rank1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step8_change_UE4_to_rank1' File
# 
# 
# Step9:change UE1-UE4 to rank4
#     Start Collect GNB and AP Syslog in 'Step9_change_UES_to_rank4' File
#     #Start GNB BIP Log
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=3    cri=1    li=1    pmi=500
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ID} testmode\=csi_override action\=activate profile_id\=1
#     END
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step9_change_UES_to_rank4${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    120
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step9_change_UES_to_rank4/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=1
#     ${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_12LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step9_change_UES_to_rank4
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step9_change_UES_to_rank4/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case206_tti_pair_always.ini    
# 	...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step9_change_UES_to_rank4${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step9_change_UES_to_rank4' File
# 
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=-50 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-4 testmode\=ul_sinr action\=activate profile_id\=5