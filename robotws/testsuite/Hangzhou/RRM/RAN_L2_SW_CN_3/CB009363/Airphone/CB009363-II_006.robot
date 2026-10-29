# *** Settings ***
# Documentation
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}   SCF_II_1cell_MP_LO.xml
# ${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
# ${WTS_NAME}    wts_D_1cell.cfg
# @{LOG_NAME_LIST}        egatelog    gnb_snapshot
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|false|//*[@name\="actUlSrsBm"]
# ${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
# ${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
# ${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actFdmEnhancedScheduling}                text|true|//*[@name\="actFdmEnhancedScheduling"]
# ${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
# ${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
# ${allowSlowPrbPoolingStatNdmSrs}           text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${actLargeBbPoolTddFr1}                    text|true|//*[@name\="actLargeBbPoolTddFr1"]
# ${basicBeamSet}                            text|beamSet_4|//*[@name\="basicBeamSet"]
# ${actShortBsrLimitAdaptation}              text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${bSRS}                                    text|2|//*[@name\="bSRS"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${numberOfTransmittedSsBlocks}             text|4 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# 
# ${PROFILE1}    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0,1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
# 
# ${PROFILE2}    ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-600 sinr_target_pusch=-600
# ${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=3 action=activate
# ${Deact_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=3 action=deactivate
# 
# ${PROFILE3}    ul_mimo_switch_nr profile_id=2 pusch_tx_mix_ratio=100 srs_tx_mix_ratio=100
# ${SET_PROFILE3}    ue_testmode_set_nr id=1 testmode=ul_mimo_switch_nr profile_id=2 action=activate
# ${Deact_PROFILE3}    ue_testmode_set_nr id=1 testmode=ul_mimo_switch_nr profile_id=2 action=deactivate
# 
# ${FILTER1}    uldata_srsreceivereq
# @{title1}     3gpp.rnti    UlData_srsReceiveReqUes_t.numOfSrsPorts    UlData_srsReceiveReqUes_t.numCeAxCIndex    
# ...     UlData_srsReceiveReqUes_t.ceAxCIndex_item     UlData_srsReceiveReqUes_t.patternId_item
# 
# *** Test Cases ***
# CB009363-II_006_rank2_rank1_rank2_and_TPMI_measurement_on_8Rx_SRS_and_8Rx_PUSCH_with_configured_grant_aperiodicSRS
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach UE and start buffer
# 	Step3:Degrade radio condition to allow only rank1 transmission
# 	Step4:Upgrade radio conditions
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${pucchModeSelect}    ${numberOfRxBeamforming}
# 	...      ${numberOfRxPucch}    ${nrCellType}    ${actFdmScheduling}    ${actFdmEnhancedScheduling}    ${actBeamforming}
# 	...      ${nrBtsBeamRefinementP2}    ${actBbPoolTddFr1}    ${actBbPoolTddFr1Enh}    ${allowSlowPrbPoolingStatNdmSrs}    ${actLargeBbPoolTddFr1}
# 	...      ${basicBeamSet}    ${actShortBsrLimitAdaptation}    ${bSRS}    ${cSRS}    ${numberOfTransmittedSsBlocks}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
# 	add_txt_node    0x580627:1
# 	add_txt_node    0x580117:3
# 	add_txt_node    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
# 	add_txt_node    0x59017D:10       #rdSrsBwFraction
# 	add_txt_node    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     #add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE and start buffer
#     Start capture GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Start GNB BIP Log
# 	#------- Prepare SSB Beam Attach-----#
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    2
#     SA send multiple trf data    1    UL    175M    2
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step2
#     Stop Gnb BIP Log    log_dir=${save_log}
# #    Check Rrc Reconfiguration For 8124 Validation
# 
# #    Verify Refine Correlated Patten Id In PUSCH
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case06_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
# #    Check counter
#     Get And Validate Counters    ${save_log}
#     should be true    ${value_M55303C03000} > 0
#     should be true    ${value_M55303C04001} == 0
#     should be true    ${value_M55303C04002} > 0
# 	should be true    ${rank2_value} > 0
# 	should be true    ${rank1_value} == 0
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Degrade radio condition to allow only rank1 transmission
#     Start capture GNB and AP Syslog in 'Step3_rank1' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_rank1
# 	Start GNB BIP Log
# 	#------- Set Ul Sinr Testmode Nr -----#
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step3
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Get And Validate Counters    ${save_log}
#     should be true    ${value_M55303C02000} > 0
#     should be true    ${value_M55303C02001} > 0
#     should be true    ${value_M55303C04001} > 0
#     should be true    ${value_M55303C04002} == 0
# 	should be true    ${rank2_value} == 0
# 	should be true    ${rank1_value} > 0
# #    Verify Refine Correlated Patten Id In PUSCH
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/bip_srsreceivereq.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case06_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step3_rank1' File
# 
# Step4:Upgrade radio conditions
#     Start capture GNB and AP Syslog in 'Step4_rank2' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank2
# 	Start GNB BIP Log
#     Airphone Execute Egate Command    ${Deact_PROFILE2}
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step2
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Get And Validate Counters    ${save_log}
#     should be true    ${value_M55303C03000} > 0
#     should be true    ${value_M55303C04001} == 0
#     should be true    ${value_M55303C04002} > 0
# 	should be true    ${rank2_value} > 0
# 	should be true    ${rank1_value} == 0
# #    Verify Refine Correlated Patten Id In PUSCH
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case06_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step4_rank2' File
# 
# Step5:Deregister Ue
#     Start capture GNB and AP Syslog in 'Step5_detach_ue' File
#     Detach '1'UE
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_detach_ue' File
# 
# Step6:Change to 8124 Disabled
#     Start capture GNB and AP Syslog in 'Step6_disable_8124' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_disable_8124
#     Online recommissioning with delta json file    ${CURDIR}/JSON/delta_i16_8124_off.json
#     Wait Throughput Timer    60
# 	[Teardown]   Stop capture GNB and AP Syslog in 'Step6_disable_8124' File
# 
# Capture ttitrace
#     [Arguments]    ${time}    ${save_log}     ${file_tag}
#     Start GNB Ttitrace With Streaming Mode
#     sleep    ${time}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
# 
# Get And Validate Counters
#     [Arguments]    ${save_log}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     ${value_M55303C03000}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C03000    cell_id=1
# 	${value_M55303C02000}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C02000    cell_id=1
#     ${value_M55303C02001}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C02001    cell_id=1
# 	${value_M55303C04001}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C04001    cell_id=1
#     ${value_M55303C04002}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C04002    cell_id=1
# 	@{value_list_PUSCH_CP_Rank2_256TBL}    Create List
#     @{value_list_PUSCH_CP_Rank1_256TBL}    Create List
# 	:FOR    ${i}    IN RANGE     00     31
# 	\    ${index}     evaluate     "${i}".zfill(2)
# 	\    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C230${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_CP_Rank2_256TBL}   ${value}
# 	\    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C220${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_CP_RANK1_256TBL}   ${value}
#     log     ${value_list_PUSCH_CP_Rank2_256TBL}
#     log     ${value_list_PUSCH_CP_Rank1_256TBL}
# 	${rank2_value}    Evaluate    sum(${value_list_PUSCH_CP_Rank2_256TBL})
# 	${rank1_value}    Evaluate    sum(${value_list_PUSCH_CP_Rank1_256TBL})
# 	Set test Variable    ${rank2_value}
# 	Set test Variable    ${rank1_value}
# 	Set test Variable    ${value_M55303C03000}
#     Set test Variable    ${value_M55303C02000}
#     Set test Variable    ${value_M55303C02001}
# 	Set test Variable    ${value_M55303C04001}
# 	Set test Variable    ${value_M55303C04002}
