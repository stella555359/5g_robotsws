# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_B_B4a_case_125_8DL8UL_4UE_rank1_pair
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      8360_112_8d8u.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|true|//*[@name\="actUlMuMimoTapering"]
# ${ulMuMimoTaperingH}                            text|25dB|//*[@name\="ulMuMimoTaperingH"]
# ${ulMuMimoTaperingV}                            text|15dB|//*[@name\="ulMuMimoTaperingV"]
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
# ${cSRS}                                         text|51|//*[@name\="cSRS"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|50|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# ${reqMinNumPuschPrb}                           text|169|//*[@name\="reqMinNumPuschPrb"]
# ${bwp_size}    text|192|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='size']
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${FILTER1}    itf_l2_ps_cell_cellsetupreq
# @{title1}     itf_UlMuMimoConfig.actUlMuMimoTapering    itf_l2_ps_cell_DftBeamSet.dftBeamStartPatternId_item
# *** Test Cases ***
# CB008360_B_B4a_case_125_8DL8UL_4UE_rank1_pair
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 sa ue with rank1
#     Step3:Check log
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     modify_iphy    ${CONFIG_DIR_PATH}
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="ulMuMimoCorrThd2">50</p>|//*[contains(@distName, 'NRULMUMIMO-0')]
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}
#     ...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}
#     ...    ${bwpDN1}    ${bwpDN2}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${actUlPtrs}    ${srsUePeriodicity}
#     ...    ${ulDMRSAdditionalPosition}    ${cSRS}    ${ulMuMimoPrbThresholdAbsolute}    ${tiltOffset}    
#    ...    ${msg1FrequencyStart}    ${reqMinNumPuschPrb}
# 	...    ${ulSinrDiffThreshold}    ${bwp_size}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 sa ue with rank1
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2_pusch_1layer
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    2    UL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    3    UL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    4    UL    175M    trf_id=1    pdu_id=1    duration=${7200}
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
#     ${ue4_ul_tput}=    Airphone Get Throughput On Specific Scell    4    0    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 32000000
# 	should be true    ${PAIR_UE_PUSCH} > 90000
# 	should be true    ${ELIG_UE_PUSCH} > 90000
#     [Teardown]    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:Check log
#     ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}
#     ${tti_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Convert BIP To CSV    ${log_dir}/cellSetup0.pcap    ${log_dir}/cellSetup.csv    ${FILTER1}    ${title1}
#     ${ulStartPatternid}=    get_value_from_cellSetup      ${log_dir}/cellSetup.csv
#     ${ulStartPatternidDft}    set variable    ${ulStartPatternid[0]}
#     ${ulStartPatternidTapered}    set variable    ${ulStartPatternid[1]}
#     set suite variable    ${ulStartPatternidTapered}
#     set suite variable    ${ulStartPatternidDft}
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case125_tti_step2.ini     log_need_to_check=i    
#    ...    save_log_directory=${tti_dir}
# 
# Step4:Detach ues
#     Airphone SA Stop Data Traffic     1    UL
#     Airphone SA Stop Data Traffic     2    UL
#     Detach '2'UE
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     remove_xml_element     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}     ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml    //refinedBeams
#     remove_xml_element     ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml      ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml    //dlFeatures
#     add_xml_element
# 	...   ${TEST_LOG_DIRECTORY()}${/}iphy_mod2.xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod3.xml  <ulFeatures>tapering</ulFeatures>|//vcell
#     add_xml_element
# 	...   ${TEST_LOG_DIRECTORY()}${/}iphy_mod3.xml     ${TEST_LOG_DIRECTORY()}${/}iphy_mod4.xml  <refinedBeams>true</refinedBeams>|//vcell
#     add_xml_element
# 	...   ${TEST_LOG_DIRECTORY()}${/}iphy_mod4.xml    ${TEST_LOG_DIRECTORY()}${/}iphy_mod5.xml  <dlFeatures>pmiBeams</dlFeatures>|//vcell
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod5.xml
