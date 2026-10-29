# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_regression_robust_case01_TDD_antport and cdm group check
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           ../../resources/sg10/internal_resource/lib/pdcch_dci_decode.py
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          8360_112_8d8u.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
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
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoCorrThd2}                             text|50|//*[@name\="ulMuMimoCorrThd2"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${reqMinNumPuschPrb}                            text|225|//*[@name\="reqMinNumPuschPrb"]
# ${actUlDataDmrsFdm}                             text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres64QamMcs}                   text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# ${ulDataDmrsFdmThres256QamMcs}                  text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008360_regression_robust_case01_TDD_antport and cdm group check
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 1st UE UL 1layer,send full buffer UL and DL
# 	Step3:Attach 2nd UE UL 2layer,send full buffer UL and DL
# 	Step4:Attach 3rd UE UL 1layer,send full buffer UL and DL
#     Step5:make ul bler check again
#     Step6:Detach all ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}    ${tiltOffset}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeOne}    ${prbThreshRangeOne}
#     ...    ${bwpDN1}    ${bwpDN2}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
# 	...    ${ulSinrDiffThreshold}    ${msg1FrequencyStart}    ${srsUePeriodicity}    ${reqMinNumPuschPrb}    ${ulMuMimoCorrThd2}
# 	...    ${actUlDataDmrsFdm}    ${ulDataDmrsFdmThres64QamMcs}    ${ulDataDmrsFdmThres256QamMcs}    ${ulMuMimoSinrThd}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 1st UE UL 1layer,send full buffer UL and DL
#     Start capture gnb and ap syslog in 'Step2_1ue' file
#     #Start GNB BIP Log
# 	Airphone NSA Attach    11
# 	ul_mimo_srs_beam_pos_active    ue=11    profile=1    init=3    sub=3    step=5    scell=8
#     Airphone NSA Start Data Traffic    11    UL    175M    trf_id=1    duration=${7200}
#     Airphone Nsa Start Data Traffic    11    DL    175M    trf_id=1    duration=${7200}
#     Airphone Nsa Start Data Traffic    11    DL    175M    trf_id=2    duration=${7200}
#     Airphone Nsa Start Data Traffic    11    DL    175M    trf_id=3    duration=${7200}
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue11_dl_tput}=    Airphone Get Throughput On Specific Scell    11    8    pdsch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_1ue
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# #	run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${save_log}${/}tti_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case01_tti_step2.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
# 	Run Keyword And Ignore Error    should be true    ${UL_thp_counter} > 12000000
# 	Run Keyword And Ignore Error    should be true    ${DL_thp_counter} > 60000000
# 
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_1ue' file
# 
# Step3:Attach 2nd UE UL 2layer,send full buffer UL and DL
#     Start capture gnb and ap syslog in 'Step3_2ue' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    1    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=1    profile=2    init=2    sub=2    step=5    scell=0
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=2    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=3    pdu_id=1    duration=${7200}
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue11_dl_tput}=    Airphone Get Throughput On Specific Scell    11    8    pdsch    current
#     ${ue1_ul_tput}=     Airphone Get Throughput On Specific Scell    1     0    pusch    current
#     ${ue1_dl_tput}=     Airphone Get Throughput On Specific Scell    1     0    pdsch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_2ue
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${save_log}${/}tti_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case01_tti_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 30000000
# 	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_2ue' file
# 
# Step4:Attach 3rd UE UL 1layer,send full buffer UL and DL
#     Start capture gnb and ap syslog in 'Step4_3ue' file
#     #Start GNB BIP Log
# 	Airphone NSA Attach    12
# 	ul_mimo_srs_beam_pos_active    ue=11    profile=3    init=1    sub=0    step=5    scell=8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     Airphone NSA Start Data Traffic    12    UL    175M    trf_id=1    duration=${7200}
#     Airphone Nsa Start Data Traffic    12    DL    175M    trf_id=1    duration=${7200}
#     Airphone Nsa Start Data Traffic    12    DL    175M    trf_id=2    duration=${7200}
#     Airphone Nsa Start Data Traffic    12    DL    175M    trf_id=3    duration=${7200}
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue11_dl_tput}=    Airphone Get Throughput On Specific Scell    11    8    pdsch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue12_dl_tput}=    Airphone Get Throughput On Specific Scell    12    8    pdsch    current
#     ${ue1_ul_tput}=     Airphone Get Throughput On Specific Scell    1     0    pusch    current
#     ${ue1_dl_tput}=     Airphone Get Throughput On Specific Scell    1     0    pdsch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_3ue
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# #	run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${save_log}${/}tti_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case01_tti_step4.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${DL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
# 	Run Keyword And Ignore Error    should be true    ${UL_thp_counter} > 44000000
# 	Run Keyword And Ignore Error    should be true    ${DL_thp_counter} > 160000000
# 
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_3ue' file
# 
# Step5:make ul bler check again
#     Start capture gnb and ap syslog in 'Step5_bler' file
# #    ul_sinr_pathloss_active    ue_id=11    profile_id=1    pcmax=20    pathloss=130
# #    ul_sinr_pathloss_active    ue_id=12    profile_id=1    pcmax=20    pathloss=130
# #    ul_sinr_pathloss_active    ue_id=1    profile_id=1    pcmax=20    pathloss=130
#     Trigger ul bler    11    8    10,10
#     Trigger ul bler    12    8    10,10
#     Trigger ul bler    1     0
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue11_dl_tput}=    Airphone Get Throughput On Specific Scell    11    8    pdsch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue12_dl_tput}=    Airphone Get Throughput On Specific Scell    12    8    pdsch    current
#     ${ue1_ul_tput}=     Airphone Get Throughput On Specific Scell    1     0    pusch    current
#     ${ue1_dl_tput}=     Airphone Get Throughput On Specific Scell    1     0    pdsch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_bler
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# #	run keyword and continue on failure    Decode_PDCCH_Dciinfo    ${save_log}${/}tti_dl.csv
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case01_tti_step5.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step5_bler' file
# 
# Step6:Detach all ues
#     Airphone NSA Detach    ue_id=11
#     Airphone NSA Detach    ue_id=12
#     Airphone Sa Detach     ue_id=1
# 
