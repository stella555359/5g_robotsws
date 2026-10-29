# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_B_B2a_case_115_case 2 8DL8UL, 3UE rank1 pair
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CIT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          8360_112_8d8u.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}        egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoCorrThd2}                             text|45|//*[@name\="ulMuMimoCorrThd2"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${tiltOffset}                          text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${actUlPtrs}                          text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}           text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# 
# ${bwp_profile75}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-75')|//managedObject
# ${bwp_profile75_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-75')|//p
# ${bwp_profile7}     attrib\=distName|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//managedObject
# ${bwp_profile7_p}    text|replace('BWP_PROFILE-5', 'BWP_PROFILE-7')|//p
# ${bwp_duration1}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='duration']
# ${bwp_duration3}    text|9|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='duration']
# ${bwp_duration_dedi}    text|1|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${bwp_duration_dedi_2}    text|1|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
# ${nPdcchCandidatesInAL16}     text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}    text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_1}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL4_3}    text|n2|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8}      text|n0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-75/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${bwp_periodicity_1}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='periodicity']
# ${bwp_periodicity_3}    text|sl10|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='periodicity']
# ${slotOffset_1}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='slotOffset']
# ${slotOffset_2}    text|4|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='slotOffset']
# 
# ${pattern}    t2r4_n2_pusch_1layer
# 
# *** Test Cases ***
# CB008360_B_B2a_case_115_case 2 8DL8UL, 3UE rank1 pair
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3UEs, UE1 in H5V0,UE2 in H120V0,UE3 in H22V0
#     Step3:Push full buffer in UL
#     Step4:Move 3UEs to H0V0
#     Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
#     Step6:check counter
# 	 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    5    0    0    0    5    0    5    0    0    30000    30000    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    12   0    0    0    12    0    12    0    1    30000    30000    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    22   0    0    0    22    0    22    0    2    30000    30000    0    0
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actUlSrsBm}    ${actUlMuMimo}
#     ...       ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}    ${ulMuMimoCorrThd2}    ${ulDMRSAdditionalPosition}    ${actUlPtrs}
#     ...       ${tiltOffset}    ${ulSinrDiffThreshold}	
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${bwp_profile75}    ${bwp_profile75_p}    ${bwp_profile7}    ${bwp_profile7_p}    ${bwp_duration1}    ${bwp_duration3}
#     ...       ${bwp_duration_dedi}    ${bwp_duration_dedi_2}    ${nPdcchCandidatesInAL16}    ${nPdcchCandidatesInAL2_2}
#     ...       ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL4_3}    ${nPdcchCandidatesInAL8}
#     ...       ${nPdcchCandidatesInAL4_2}    ${bwp_periodicity_1}    ${bwp_periodicity_3}    ${slotOffset_1}    ${slotOffset_2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 3UEs, UE1 in H5V0,UE2 in H120V0,UE3 in H22V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# 	Attach SA ue with capability to 5g cell    3    t2r4_n2_pusch_1layer
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=50 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=5
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_sinr action\=activate profile_id\=5
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=5 testmode\=ul_sinr action\=activate profile_id\=5
#     #Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2    from=3
# 	#airphone_execute_egate_command
#     #...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     #airphone_execute_egate_command
#     #...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
# 
#     Wait Throughput Timer    5
# 	#Attach SA ue with capability to 5g cell    5    t2r4_n2_pusch_1layer
# 	Wait Throughput Timer    5
#     airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	${rnti_list}    file match all    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	  ${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	  ${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	  ${rnti_list[2]}
# 	#Set test Variable	 ${rnti_4} 	  ${rnti_list[3]}
# 	#Set test Variable	 ${rnti_5} 	  ${rnti_list[4]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     #Airphone SA Start Data Traffic    4    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     #Airphone SA Start Data Traffic    4    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
# 	#Airphone SA Start Data Traffic    5    UL    170M    trf_id=1    pdu_id=1    duration=${3600}
#     #Airphone SA Start Data Traffic    5    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    2
# 	#airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=200 noise_srs\=-1053
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Wait Throughput Timer    5
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_paired_FS.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 	
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Move 3UEs to H0V0
#     Start Collect GNB and AP Syslog in 'Step4_3ues_move_unpair' File
#     #Start GNB BIP Log
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Wait Throughput Timer    5
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}tti_unpair
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_unpaired.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step4_3ues_move_unpair${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_3ues_move_unpair' File
# 
# 
# Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
#     Start Collect GNB and AP Syslog in 'Step5_3ues_move_pair' File
#     #Start GNB BIP Log
#     #Wait Throughput Timer    2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Wait Throughput Timer    5	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_paired_FS.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_3ues_move_pair${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_3ues_move_pair' File
# 
# Step6:check counter
#     Start Collect GNB and AP Syslog in 'Step6_check_counter' File
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step6_check_counter/
#     ${PRB_UL_MU_MIMO_3LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35004    cell_id=1
#     ${PRB_UL_MU_MIMO_4LAYERP}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35005    cell_id=1
#     ${PRB_UL_MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35008    cell_id=1
#     #${PRB_UL_MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35009    cell_id=1
#     ${TOT_MU_MIMO_PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35010    cell_id=1
#     ${TOT_MU_MIMO_ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C35011    cell_id=1
#     #${PRB_UL_MU_MIMO_3L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD351    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S2L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD352    cell_id=1
#     #${PRB_UL_MU_MIMO_4L_S4L_MUREC}= get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308CRD353    cell_id=1
#     should be true    ${PRB_UL_MU_MIMO_3LAYERP} >0
#     should be true    ${PRB_UL_MU_MIMO_4LAYERP}==0
#     should be true    ${PRB_UL_MU_MIMO_3PAIR_UE} >0
#     #should be true    ${PRB_UL_MU_MIMO_4PAIR_UE}==0
#     should be true    ${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH} >0.9
#    
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_check_counter' File
