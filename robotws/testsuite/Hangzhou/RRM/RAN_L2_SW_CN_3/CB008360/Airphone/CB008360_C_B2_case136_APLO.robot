# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_C_B2_case_136_IWK with MultipleDedicatedBWPs NSA
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library           ../../resources/sg11/internal_resource/python/ttitrace_handle.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}       gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_MultipleDedicatedBWPs.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_135.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_MultipleDedicatedBWPs.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${nrarfcn}                                      text|632032|//*[@name\="nrarfcn"]
# ${gscnOrSsPbchArfcn}                            text|7830|//*[@name\="gscnOrSsPbchArfcn"]
# ${msg1FrequencyStart}                           text|8|//*[@name\="msg1FrequencyStart"]
# #${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|5|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|10|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|49|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actMultipleDedicatedBWPs}                     text|true|//*[@name\="actMultipleDedicatedBWPs"]
# ${actDlPtrs}                                    text|false|//*[@name\="actDlPtrs"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                          text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# 
# 
# *** Test Cases ***
# CB008360_C_B2_case_136_IWK with MultipleDedicatedBWPs NSA
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NSA UEs,1UE's capability is restricted in small bwp
#     Step3:Push full buffer in UL
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    4    0    4    0    4    0    4    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    20    0    2    0    2    0    2    0    1
#     #Set Pos By Modify L1ByPTestModeConfiguration    14    0    25    0    25    0    25    0    2
#     #Set Pos By Modify L1ByPTestModeConfiguration    10    0    25    0    25    0    25    0    3
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${nrarfcn}    ${gscnOrSsPbchArfcn}    ${msg1FrequencyStart}
#     ...       ${dlMimoMode}    ${nrCellType}    ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}
#     ...       ${actUlMuMimoTapering}    ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}
#     ...       ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${ulMuMimoLinkAdaptionSwitch}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}
#     ...       ${actMultipleDedicatedBWPs}    ${actDlPtrs}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 NSA UEs,1UE's capability is restricted in small bwp
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=1 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
#     Wait Throughput Timer    3
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=11 testmode\=csi_override action\=activate profile_id\=1 scell\=8
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_attach id\=11
#     Wait Throughput Timer    3
#     airphone_execute_egate_command   ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=8
#     Wait Throughput Timer    5
# 	
# 	airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=2 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
#     Wait Throughput Timer    3
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=12 testmode\=csi_override action\=activate profile_id\=2 scell\=8
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_attach id\=12
#     Wait Throughput Timer    3
#     airphone_execute_egate_command   ue_dc_enb_start ue\=12 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=8
# 	Wait Throughput Timer    5
# 	
# 	airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=3 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
#     Wait Throughput Timer    3
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=13 testmode\=csi_override action\=activate profile_id\=3 scell\=8
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_attach id\=13
#     Wait Throughput Timer    3
#     airphone_execute_egate_command   ue_dc_enb_start ue\=13 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=8
# 	Wait Throughput Timer    5
# 	
# 	airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=4 cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed pmi\=0
#     Wait Throughput Timer    3
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=14 testmode\=csi_override action\=activate profile_id\=4 scell\=8
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_attach id\=14
#     Wait Throughput Timer    3
#     airphone_execute_egate_command   ue_dc_enb_start ue\=14 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=8	
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}tti_attach
# 	${rnti_list_1}    read_csv_columns    ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}tti_attach_ul.csv    rnti
# 	${rnti_list}=     get_nsa_ue_crnti    ${rnti_list_1}
#     Set test Variable	 ${rnti_1} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[3]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[5]}
#     Set test Variable	 ${rnti_4} 	${rnti_list[7]}
# 
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case136_rrc_small_bwp_NSA.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_data' File
#     #Start GNB BIP Log
#     : FOR    ${u_id}    IN RANGE   11    15
#     \    Airphone Nsa Start Data Traffic    ${u_id}    UL    170M    trf_id=1    duration=${3600}
#     \    Airphone Nsa Start Data Traffic    ${u_id}    UL    170M    trf_id=2    duration=${3600}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=8
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=8
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=8	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_data${/}tti_136
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case136_tti_small_bwp_NSA_FS.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step3_data${/}
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_data${/}
#     Set Suite Variable    ${PM_counter_file}
# 	${PM_counter_value_M55308C28004}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C28004    cell_id=1
#     ${PM_counter_value_M55308C28008}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C28008    cell_id=1
#     ${PM_counter_value_M55115C02001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55115C02001    cell_id=1
#     ${PM_counter_value_M55115C02002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55115C02002    cell_id=1
#     should be true     ${PM_counter_value_M55308C28004} == 1
#     should be true     ${PM_counter_value_M55308C28008} == 3
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_data' File
# 
# modify_swconfig_by_CB008360
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}    ${add_node1}=none    ${add_node2}=none    ${add_node3}=none    ${add_node4}=rdSrsCodebookAndTas0
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x9D0000:3         #as PM counter period update to 15/3=5min
# 	add_txt_node    0x58057a:0x4
# 	add_txt_node    0x58057e:0x16776192
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     modify_txt_node    0x10040:2
#     modify_txt_node    0x10041:5
#     add_txt_node    0x1003F:1
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
