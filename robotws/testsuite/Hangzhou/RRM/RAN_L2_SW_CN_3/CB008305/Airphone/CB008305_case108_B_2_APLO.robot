# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case108_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001116
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# #${SCFC_NAME}      8305_ca_1116.xml
# #${AIRPHONE_NAME}    iphy.xml
# #${WTS_NAME}       MUE_SRS_QT_2PDSCHLayer_wts.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|23|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${dlMuMimoRankAdaption}                         text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${dlMuMimoCorrThd}                           text|33|//*[@name\="dlMuMimoCorrThd"]
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# #bwp1070
# ${bwp_profile7}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# *** Test Cases ***
# CB008305_case108_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001116
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs
#     Step3:Push full buffer And check
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    15    6    15    6    15    6    15    6    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    12    6    12    6    12    6    12    6    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0      6    0    6    0    2
#     #Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0      21    0    21    0    3
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${dlMuMimoCorrThd} 
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${dlMuMimoRankAdaption}    ${miNrCellUtilPerPLMN}    ${bwp_profile7}    ${bwp_profile73}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2
#     Wait Throughput Timer    5
# 
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=2 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1     6
#     \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    3    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    4    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 
#     #airphone_execute_egate_command    cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions\=4 azimuth\=-70,1,1,70
# 	#airphone_execute_egate_command    cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions\=4 azimuth\=51,23,-15,-45
#     #airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=cell_srs_beam_pos profile_id\=1 action\=activate
# 
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 srsMode\=fixed init_pos\=0
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=3 srsMode\=fixed init_pos\=2
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=4 srsMode\=fixed init_pos\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ue_srs_beam_pos action\=activate profile_id\=4  
# 	
# 	airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=7 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=7
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=7
#     #airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 sinr_target_pucch\=-300
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=2
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_sinr action\=activate profile_id\=2
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_sinr action\=activate profile_id\=2
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check thp
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case108.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Wait Throughput Timer    90
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 12000000
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34015
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_4pairUE_value} > 12000000
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
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55338C00001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 12000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    1    5
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 320000
#     END
