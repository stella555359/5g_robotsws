# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008701_A_B203_01_case204_8UEs_rank_2_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
# 
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}     gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_8701.xml
# ${AIRPHONE_NAME}    AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}    wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_8701.cfg
# @{LOG_NAME_LIST}    egatelog\
# ${UE_NUM}         8
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# #${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|16DL8UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                              text|50|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                               text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                         text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                       text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                            text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                            text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}                      text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${actDl256Qam}                                  text|false|//*[@name\="actDl256Qam"]
# #ulmumimo
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|false|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUl256Qam}                                  text|true|//*[@name\="actUl256Qam"]
# 
# #1070
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# 
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|0|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# #bwp
# ${bwp_profile6}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile66}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-66|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# ${quadrantMappings}    <quadrantMappings>
# ...                        <azQuadCenterUpper>0</azQuadCenterUpper>
# ...                        <azQuadCenterLower>0</azQuadCenterLower>
# ...                        <azSubQuadBorderUpperLeft>-30</azSubQuadBorderUpperLeft>
# ...                        <azSubQuadBorderLowerLeft>-30</azSubQuadBorderLowerLeft>
# ...                        <azSubQuadBorderUpperRight>30</azSubQuadBorderUpperRight>
# ...                        <azSubQuadBorderLowerRight>30</azSubQuadBorderLowerRight>
# ...                        <elQuadCenterLeft>90</elQuadCenterLeft>
# ...                        <elQuadCenterRight>90</elQuadCenterRight>
# ...                        <elSubQuadBorderUpperLeft>95</elSubQuadBorderUpperLeft>
# ...                        <elSubQuadBorderUpperRight>95</elSubQuadBorderUpperRight>
# ...                        <elSubQuadBorderLowerLeft>85</elSubQuadBorderLowerLeft>
# ...                        <elSubQuadBorderLowerRight>85</elSubQuadBorderLowerRight>
# ...                        <deltaAz>30</deltaAz>
# ...                        <deltaEl>6</deltaEl>
# ...                     </quadrantMappings>
# 
# *** Test Cases ***
# CB008701_A_B203_01_case204_8UEs_rank_2_or_1_with_nonGBR_paired_with_dlMuMimoRankAdaption_always
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 8UEs
#     Step3:Push full buffer in DL
#     Step4:change UE1 to rank1
#     Step5:change UE2_4 to rank1
#     Step6:change UE5_8 to rank1
#     Step7:change UE1_8 to rank2
#     #Step8:stability test
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	modify_iphy    ${CONFIG_DIR_PATH}
# #    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}     ${bwp_profile6}    ${bwp_profile66}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${srsUePeriodicity}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${dlMuMaxNumLayerPerMuRbg}
# #    ...       ${actUlMuMimoTapering}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}
# #    ...       ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${ulMuMimoLinkAdaptionSwitch}    ${actUl256Qam}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 8UEs
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Set UEs Pos
#     Attach SA ue with capability to 5g cell    8    CA_P2_8x4_t2r4_n2
#     set_ue_layer    8    1
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_list[5]}
# 	Set test Variable	 ${rnti_7} 	${rnti_list[6]}
# 	Set test Variable	 ${rnti_8} 	${rnti_list[7]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in DL
#     Start capture gnb and ap syslog in 'Step3_inject_buffer' file
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     FOR    ${ID}    IN RANGE    1    3
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    5    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    6    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    7    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    8    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
#     END
#     Wait Throughput Timer    2
#     capture_decode_ttiTrace    ${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     ${PM_counter_file}    download PM counter file    ${save_log}
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
# 	${dL_thp_counter}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}       counter_id=M55309C12001
# 	run keyword and continue on failure    should be true    ${dL_thp_counter} > 0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
# 	run keyword and continue on failure    GET THP
# #    start collect sosReport
# #    Wait Throughput Timer    2
# #    stop collect sosReport
#     [Teardown]    Stop capture gnb and ap syslog in 'Step3_inject_buffer' file
# 
# Step4:change UE1 to rank1
#     Start Collect GNB and AP Syslog in 'Step4_change_UE1_to_rank1' File
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_change_UE1_to_rank1
# 	csi_override_testmode_active    ueid=1    profile_id=2   ri=0
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_change_UE1_to_rank1${/}
#     run keyword and continue on failure    GET THP
#     Wait Throughput Timer    2
#     capture_decode_ttiTrace    ${save_log}
#     ${PM_counter_file}    download PM counter file    ${save_log}
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
# 	${PPRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34022    cell_id=1
#     ${dL_thp_counter}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}       counter_id=M55309C12001
# 	run keyword and continue on failure    should be true    ${dL_thp_counter} > 0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_15LAYER} >0
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl_UE1_change.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_change_UE1_to_rank1' File
# 
# Step5:change UE2_4 to rank1
#     Start Collect GNB and AP Syslog in 'Step5_change_UE2_4_to_rank1' File
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_change_UE2_4_to_rank1
# 	csi_override_testmode_active    ueid=2    profile_id=2   ri=0
# 	csi_override_testmode_active    ueid=3    profile_id=2   ri=0
# 	csi_override_testmode_active    ueid=4    profile_id=2   ri=0
# 
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_change_UE2_4_to_rank1${/}
#     run keyword and continue on failure    GET THP
#     Wait Throughput Timer    2
#     capture_decode_ttiTrace    ${save_log}
#     ${PM_counter_file}    download PM counter file    ${save_log}
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
# 	${PPRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34022    cell_id=1
# 	${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=1
#     ${dL_thp_counter}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}       counter_id=M55309C12001
# 	run keyword and continue on failure    should be true    ${dL_thp_counter} > 0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_15LAYER} ==0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_12LAYER} >0
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl_UE2_4_change.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_change_UE2_4_to_rank1' File
# 
# Step6:change UE5_8 to rank1
#     Start Collect GNB and AP Syslog in 'Step6_change_UE5_8_to_rank1' File
#     #Start GNB BIP Log
# 	csi_override_testmode_active    ueid=5    profile_id=2   ri=0
# 	csi_override_testmode_active    ueid=6    profile_id=2   ri=0
# 	csi_override_testmode_active    ueid=7    profile_id=2   ri=0
# 	csi_override_testmode_active    ueid=8    profile_id=2   ri=0
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_change_UE5_8_to_rank1
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_change_UE5_8_to_rank1${/}
#     run keyword and continue on failure    GET THP
#     Wait Throughput Timer    2
#     capture_decode_ttiTrace    ${save_log}
#     ${PM_counter_file}    download PM counter file    ${save_log}
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
# 	${PPRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34022    cell_id=1
# 	${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=1
# 	${PPRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_15LAYER} ==0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_12LAYER} ==0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_8LAYER} >0
# 
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl_UE5_8_change.ini
# 	...    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_change_UE5_8_to_rank1' File
# 
# Step7:change UE1_8 to rank2
#     Start Collect GNB and AP Syslog in 'Step7_change_UE1_8_to_rank2' File
#     #Start GNB BIP Log
#     set_ue_layer    8    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_change_UE1_8_to_rank2
#     capture_decode_ttiTrace    ${save_log}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     ${PM_counter_file}    download PM counter file    ${save_log}
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${dL_thp_counter}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}       counter_id=M55309C12001
# 	run keyword and continue on failure    should be true    ${dL_thp_counter} > 0
# 	run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_change_UE1_8_to_rank2' File
# 
# Step8:stability test
#     #Start Collect GNB and AP Syslog in 'Step8_stability_test' File
#     #Start GNB BIP Log
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8_stability_test${/}
#     Wait Throughput Timer    1800
#     #run keyword and continue on failure    GET THP
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step8_stability_test/
#     ${DL_throughput}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     run keyword and continue on failure    should be true    ${DL_throughput} >0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step8_stability_test${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step8_stability_test${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case204_tti_pair_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step8_stability_test${/}
#     #[Teardown]    Stop Collect GNB and AP Syslog in 'Step8_stability_test' File
# 
# GET THP
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=current
#     END
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
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE8}
# 
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     add_xml_element
# 	...   ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml  ${quadrantMappings}|//vcell
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml
# 
# set_ue_layer
#     [Arguments]    ${ue_num}    ${ri}
#     : FOR    ${num}    IN RANGE    1    ${ue_num}+1
#     \    csi_override_testmode_active    ueid=${num}    profile_id=1   ri=${ri}
# 
# capture_decode_ttiTrace
#     [Arguments]    ${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
