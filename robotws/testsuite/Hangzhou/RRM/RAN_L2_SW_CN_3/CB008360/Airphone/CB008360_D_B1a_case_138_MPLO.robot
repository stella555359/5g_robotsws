# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_D_B1a_case_138_Retransmission UEs paired with initTx UEs
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      8360_112_8d8u.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# #${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${ulMuMimoTaperingH}                            text|20dB|//*[@name\="ulMuMimoTaperingH"]
# ${ulMuMimoTaperingV}                            text|25dB|//*[@name\="ulMuMimoTaperingV"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${prbThreshRangeOne}                            text|50|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}                            text|50|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}                          text|50|//*[@name\="prbThreshRangeThree"]
# ${bwpDN1}                                       text|MRBTS-1/NRBTS-2/BWP_PROFILE-7|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
# ${bwpDN2}                                       text|MRBTS-1/NRBTS-2/BWP_PROFILE-77|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
# ${ullaDeltaSinrMax}                             text|5|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|-5|//*[@name\="ullaDeltaSinrMin"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${tiltOffset}                          text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# ${reqMinNumPuschPrb}                           text|225|//*[@name\="reqMinNumPuschPrb"]
# 
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008360_D_B1a_case_138_Retransmission UEs paired with initTx UEs
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2 nsa ue with rank1 1 sa ue with rank2
# 	Step3:Send nack to UE1 to trigger retransmission
# 	Step4:Detach ue3, attach ue4 ue5 with rank1
#     Step5:Detach all ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    12    0    12    0    12    0    12    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    0    0    0    0    0    0    0    0    2
#     #Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0    21    0    21    0    3
#     #Set Pos By Modify L1ByPTestModeConfiguration    15    0    15    0    15    0    15    0    4    0    0    0    0    0    0    0    0    2    2
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="ulMuMimoCorrThd2">50</p>|//*[contains(@distName, 'NRULMUMIMO-0')]
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}    ${tiltOffset} 
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeOne}    ${prbThreshRangeOne}
#     ...    ${bwpDN1}    ${bwpDN2}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
# 	...    ${ulSinrDiffThreshold}    ${msg1FrequencyStart}    ${srsUePeriodicity}    ${reqMinNumPuschPrb}  
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2 nsa ue with rank1 1 sa ue with rank2
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 
# 	Airphone NSA Attach    11
# 	Wait Throughput Timer    3
# 	Airphone NSA Start Data Traffic    11     UL    100M    duration=${7200}
#     Wait Throughput Timer    3
# 	Airphone NSA Attach    12
# 	Wait Throughput Timer    3
# 	Airphone NSA Start Data Traffic    12     UL    100M    duration=${7200}
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=8
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=8	
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp0}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp0}    ${save_log}${/}tti_0
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
# 	#Start GNB BIP Log
# 	Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     Airphone SA Start Data Traffic    1    UL    170M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=2    pdu_id=1    duration=${7200}
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
# 	airphone_execute_egate_command
#     ...    ul_sinr_testmode_nr profile_id\=1 sinr_target_srs\=-100 sinr_target_pucch\=-500 noise_srs\=1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=ul_sinr action\=activate profile_id\=1 scell\=8
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	
# 	run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case138_tti_step2_FS.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 40000000
# 	should be true    ${PAIR_UE_PUSCH} > 60000
# 	should be true    ${ELIG_UE_PUSCH} > 60000
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send nack to UE1 to trigger retransmission
#     Start Collect GNB and AP Syslog in 'Step3_trigger_retrx' File
#     #Start GNB BIP Log
#     Trigger ul bler    11    8    10,10
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_trigger_retrx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case138_tti_step3_FS.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 30000000
# 	should be true    ${PAIR_UE_PUSCH} > 60000
# 	should be true    ${ELIG_UE_PUSCH} > 60000
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_trigger_retrx' File
# 
# Step4:Detach ue3, attach ue4 ue5 with rank1
#     Start Collect GNB and AP Syslog in 'Step4_attach_ue4_5' File
#     #Start GNB BIP Log
# 	Trigger ul bler    11    8    100,100
#     Airphone SA Detach    1
#     Airphone NSA Attach    13
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=8
#     Airphone NSA Attach    14
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=8	
#     Airphone NSA Start Data Traffic    13     UL    150M    duration=${7200}
#     Airphone NSA Start Data Traffic    14     UL    150M    duration=${7200}
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_attach_ue4_5
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case138_tti_step4_FS.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 10000000
# 	should be true    ${PAIR_UE_PUSCH} > 70000
# 	should be true    ${ELIG_UE_PUSCH} > 70000
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_attach_ue4_5' File
# 
# Step5:Detach all ues
#     Stop nsa ue data and detach    11    UL
#     Stop nsa ue data and detach    12    UL
#     Stop nsa ue data and detach    13    UL
#     Stop nsa ue data and detach    14    UL
# 
