# *** Settings ***
# Documentation
# ...
# ...    Number of PRBs for 4-layer Rx for MU MIMO in UL (M55308C35005)	
# ...    Number of PRBs for 3-layer Rx for MU MIMO in UL (M55308C35004)	
# ...    Number of PRBs for 2-layer Rx for MU MIMO in UL (M55308C35003)	
# ...    Number of PRBs for 2-layer Rx for SU MIMO in UL (M55308C35002)	
# ...    Number of PRBs for non-paired UE Rx for MU MIMO in UL (M55308C35006)	
# ...    Number of PRBs for 1-layer Rx for SU MIMO in UL (M55308C35001)	
# ...    Number of PRBs for 2 UE pair Rx for MU MIMO in UL (M55308C35007)	
# ...    Number of PRBs for 3 UE pair Rx for MU MIMO in UL (M55308C35008)	
# ...    Number of PRBs for 4 UE pair Rx for MU MIMO in UL (M55308C35009)	
# ...    Total Number of MU MIMO paired UEs for PUSCH (M55308C35010)	
# ...    Total number of MU MIMO eligible UEs scheduled on PUSCH (M55308C35011)
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
# ${SCFC_NAME}   SCF_AQQL_MU_MP_LO.xml
# ${AIRPHONE_NAME}    iphy_AQQL_MU_MP_LO.xml
# ${WTS_NAME}    wts_AQQL_MU.cfg
# @{LOG_NAME_LIST}        egatelog    gnb_snapshot
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
# ${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
# ${nrCellType}                              text|8DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${actFdmEnhancedScheduling}                text|true|//*[@name\="actFdmEnhancedScheduling"]
# ${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
# 
# ${PROFILE1}    ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ue_srs_beam_pos profile_id=1 action=activate
# 
# ${PROFILE2}    ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200
# ${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=3 action=activate
# ${Deact_PROFILE2}    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=3 action=deactivate
# 
# ${PROFILE3}    ul_mimo_switch_nr profile_id=2 pusch_tx_mix_ratio=100 srs_tx_mix_ratio=100
# ${SET_PROFILE3}    ue_testmode_set_nr id=1 testmode=ul_mimo_switch_nr profile_id=2 action=activate
# ${Deact_PROFILE3}    ue_testmode_set_nr id=1 testmode=ul_mimo_switch_nr profile_id=2 action=deactivate
# 
# ${POS_1}        ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO
# ${UE1_POS_1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# ${POS_2}        ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=UL_MIMO
# ${UE2_POS_2}    ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=5
# 
# ${POS_3}        ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO
# ${UE3_POS_3}    ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=12
# 
# ${POS_4}        ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO
# ${UE4_POS_4}    ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=16
# 
# ${filter_1}    (uldata_puschreceiverespps)||(uldata_srsreceivereq)||(uldata_puschreceiverespps)
# @{title_1}     3gpp.rnti    UlData_UePuschReceiveRespPs_t.ulRank    UlData_UePuschReceiveRespPs_t.dtx
# ...       UlData_UePuschReceiveRespPs_t.ulPmiRank1    UlData_UePuschReceiveRespPs_t.ulPmiRank1Sinr
# ...       UlData_UePuschReceiveRespPs_t.ulPmiRank2    UlData_UePuschReceiveRespPs_t.ulPmiRank2Sinr_item
# 
# *** Test Cases ***
# CB009363_IWK_UL_MU
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach 4UEs and start buffer
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
# 	...      ${cellDepType}             
# 	...      ${chBw}                    
# 	...      ${dlMimoMode}              
# 	...      ${actDlSrsBm}              
# 	...      ${actUlSrsBm}              
# 	...      ${pucchModeSelect}         
# 	...      ${numberOfRxBeamforming}   
# 	...      ${numberOfRxPucch}         
# 	...      ${nrCellType}              
# 	...      ${actFdmScheduling}        
# 	...      ${actFdmEnhancedScheduling}
# 	...      ${actBeamforming}          
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
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
# 	add_txt_node    0x580759:1
# 	add_txt_node    0x600018:1        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
# 	add_txt_node    0x59017D:10       #rdSrsBwFraction,The flag to control available aperiodic SRS bandwidth comparing to PUSCH bandwidth.
# 	teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     #add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach 4UEs and start buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Start GNB BIP Log
# 	Attach SA '4'ue to 5g cell
# 	Wait '5s' for stable running
# 	Airphone Execute Egate Command    ${POS_1}    
# 	Airphone Execute Egate Command    ${UE1_POS_1}
# 	
# 	Airphone Execute Egate Command    ${POS_2}    
# 	Airphone Execute Egate Command    ${UE2_POS_2}
# 	
# 	Airphone Execute Egate Command    ${POS_3}    
# 	Airphone Execute Egate Command    ${UE3_POS_3}
# 
# 	Airphone Execute Egate Command    ${POS_4}    
# 	Airphone Execute Egate Command    ${UE4_POS_4}
# 
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    2
#     SA send multiple trf data    1    UL    175M    1
# 	SA send multiple trf data    2    DL    175M    2
#     SA send multiple trf data    2    UL    175M    1
# 	SA send multiple trf data    3    DL    175M    2
#     SA send multiple trf data    3    UL    175M    1
# 	SA send multiple trf data    4    DL    175M    2
#     SA send multiple trf data    4    UL    175M    1
#     Wait Throughput Timer    60
#     Capture ttitrace    3s    ${save_log}    step2
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/MU_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	
# 	#get tput from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step2_attach${/}
#     ${PRBs for 4-layer Rx_UL_MU}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C35005    cell_id=1
# 	${PRBs for 4 UE pair Rx_UL_MU}=           get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C35009    cell_id=1
# 	should be true    ${PRBs for 4-layer Rx_UL_MU}  > 0
# 	should be true    ${PRBs for 4 UE pair Rx_UL_MU}  > 0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step2:Attach UE and start buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Start GNB BIP Log
# 	#------- Define SRS Beam Position-----#
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     #------- Ul Sinr Testmode Nr------#
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait '5s' for stable running
#     SA send multiple trf data    1    DL    175M    2
#     SA send multiple trf data    1    UL    175M    2
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step2
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case05_tti_rank2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Degrade radio condition to allow only rank1 transmission
#     Start Collect GNB and AP Syslog in 'Step3_rank1' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_rank1
# 	Start GNB BIP Log
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step3
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Get And Validate Counters    ${save_log}
#     should be true    ${value_M55303C02000} > 0
#     should be true    ${value_M55303C02001} > 0
#     should be true    ${value_M55303C04001} > 0
# 	should be true    ${rank1_value}> 0
#     #    Verify Refine Correlated Patten Id In PUSCH
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case05_tti_rank1.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_rank1' File
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
# 	
# Step4:Upgrade radio conditions
#     Start Collect GNB and AP Syslog in 'Step4_rank2' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank2
# 	Start GNB BIP Log
#     Airphone Execute Egate Command    ${Deact_PROFILE3}
#     Wait Throughput Timer    15
#     Capture ttitrace    3s    ${save_log}    step4
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Get And Validate Counters    ${save_log}
#     should be true    ${value_M55303C03000} > 0
#     should be true    ${value_M55303C04001} == 0
#     should be true    ${value_M55303C04002} > 0
# 	should be true    ${rank2_value} > 0
# 	should be true    ${rank1_value} == 0
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/II_case05_tti_rank2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_rank2' File
# 
# Capture ttitrace
#     [Arguments]    ${time}    ${save_log}     ${file_tag}
#     Start GNB Ttitrace With Streaming Mode
#     sleep    ${time}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
# 
# Step5:Deregister Ue
#     Start capture GNB and AP Syslog in 'Step5_detach_ue' File
#     Detach '1'UE
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_detach_ue' File
