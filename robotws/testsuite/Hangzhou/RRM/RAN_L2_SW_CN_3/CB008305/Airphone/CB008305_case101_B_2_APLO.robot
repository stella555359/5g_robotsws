# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case101_B_1_two_UE_move_with_25dB_tapering_and_online_change_dlMuMimoCorrThd
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|false|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|20|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ##${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ##${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ##${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ##${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|23|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                              text|33|//*[@name\="dlMuMimoCorrThd"]
# ${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
# 
# #bwp1208
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile53}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-53|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# 
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case101_B_1_two_UE_move_with_25dB_tapering_and_online_change_dlMuMimoCorrThd
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2 NonGBR UEs
#     Step3:Push full buffer And check
#     Step4:Online change dlMuMimoCorrThd form 0.1 to 0 and check counter
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    15    6    15    6    6    0    6    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    12    6    12    6    21    0    21    0    1
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actUlSrsBm}    ${actUlMuMimo}
#     ...       ${actUlPtrs}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${bwp_profile5}    ${bwp_profile53}     ${actCustomBsr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="pdcpDelayThreshRetxMode">disabled</p>|//*[contains(@distName, 'NRDRB_PDCP-3')]
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="discardTimer">1500ms</p>|//*[contains(@distName, 'NRDRB-15')]
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="schedulBSD">50ms</p>|//*[contains(@distName, 'NRDRB_MAC-3')]
#     add_xml_element     ${scfc_path}    ${scfc_path}
#     ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1     3
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=5    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=6    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=7    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=8    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=9    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=10    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Pcell_dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
# 	
# #    airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 srsMode\=fixed init_pos\=0
# #    airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=3
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# #    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     
# 
# 
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 
#     #airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 sinr_target_pucch\=-300 sinr_target_srs\=100 noise_srs\=-1053
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=1
# 
#     Wait Throughput Timer    5
#     ${Pcell_dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log1}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     ${pacp1}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log1}
#     Decoder Tttirace From Pcap To Csv    ${pacp1}    ${save_log1}/tti
#     Wait Throughput Timer    40
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Dl_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=dl
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_throughput_ue1} > 550000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_throughput_ue2} > 550000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case101_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 
# 
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 12000000
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34013
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} > 12000000
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_usedPrb_value} > 12000000
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10003
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 12000000
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C20001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
#     #run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 273
# 
# 
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Online change dlMuMimoCorrThd form 0.1 to 0 and check counter
#     Start Capture GNB and AP Syslog in 'Step4_online_change_dlMuMimoCorrThd_to_0' File
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoCorrThd
#     ...    operation=update    value=0    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait Throughput Timer    30
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_online_change_dlMuMimoCorrThd_to_0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case101_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_online_change_dlMuMimoCorrThd_to_0' File
