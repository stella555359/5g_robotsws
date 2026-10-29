# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_B3_case107_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_with_peridic_SRS_and_aperiodic
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      360 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_BOAM.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot
# #sosreport    
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|4x4 or 4x2 Open Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|false|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1000|//*[@name\="srsQualityThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${srsUePeriodicityInput}          text|slots40|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}         text|slots40|//*[@name\="srsUePeriodicityOutput"]
# ${prbSampleHighLowPercentage}     text|100|//*[@name\="prbSampleHighLowPercentage"]
# ${rlqBadPercentage}               text|100|//*[@name\="rlqBadPercentage"]
# ${rlqGoodPercentage}              text|100|//*[@name\="rlqGoodPercentage"]
# ${prbRatioThreshold}              text|2|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}             text|1|//*[@name\="prbRatioHysteresis"]
# ${srsSinrThreshold}               text|-400|//*[@name\="srsSinrThreshold"]
# ${pattern1}                       CA_P2_8x4_t2r4_n2
# ${pattern2}                       CA_P2_8x4_t1r4_n1 
# ${pattern3}                       CA_P2_8x4_t4r4_n4
# ${pattern4}                       CA_P2_8x4_noTas_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-550,-550,-550,-550
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-690,-690,-690,-690
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# *** Test Cases ***
# CB008322_B3_case107_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_with_peridic_SRS_and_aperiodic
#     Step1:Commission the above configuration on WebUI
#     Step2:Online change NIDD parameters
#     Step3:UEs attach to cell1
#     Step4:Send DL full buffer to UEs
#     Step5:Decrease U3 UE4 UE5 UE6 SRSpower to switch
#     Step6:Repeat Step3 to Step5 for 50 times
#     Step7:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     #${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     #add_bwplist_list_in_cells_new    ${scfc_path}    key_3
#     ${modify_list}    create list
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                     ${nrCellType}            
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                     ${actUlSrsBm}
#     ...    ${actUlClosedLoopPwrCtrl}        ${actCDrx}                 ${actFdmScheduling}               ${frameStructureType}
#     ...    ${guardPeriodLength}             ${ulDlDataSlotRatio}       ${prachConfigurationIndex}        ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}       ${srsTypeAllocForDlBm}
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}                    ${srsQualityThreshold}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${actDlMuMimoEnh}                ${actDl256Qam}             ${actUl256Qam}
#     ...    ${lteToNrFrameShift}             ${tdLteUlDlConfig}
#     ...    ${bwp_profile8}                  ${bwp_profile85}
#     ...    ${srsUePeriodicityInput}         ${srsUePeriodicityOutput}    ${prbSampleHighLowPercentage}
#     ...    ${rlqBadPercentage}              ${rlqGoodPercentage}         ${prbRatioThreshold}            ${prbRatioHysteresis}
#     ...    ${srsSinrThreshold}	
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Online change NIDD parameters
#     Start capture GNB and AP Syslog in 'Step2_change_parameters' File
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actDlSrsSubbandBm
#     ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait '10s' for stable running
#     Online recommissioning with delta json file    ${CURDIR}/JSON/CB008322_change_maxNumUeSrs.json
#     #: FOR    ${i}    IN RANGE    1    11
#     #\    Block Cell1
#     #\    Wait '10s' for stable running
#     #\    Unlock Cell1
#     #\    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Wait '10s' for stable running
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_change_parameters' File
# 
# Step3:UEs attach to cell1
#     Start capture GNB and AP Syslog in 'Step3_attach' File
#     #Start GNB BIP Log
#     Attach All UEs to cell
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step3_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable    ${rnti_1} 	  ${rnti_list[0]}
#     Set test Variable    ${rnti_2} 	  ${rnti_list[1]}
#     Set test Variable    ${rnti_3} 	  ${rnti_list[2]}
#     Set test Variable    ${rnti_4} 	  ${rnti_list[3]}
#     Set test Variable    ${rnti_5} 	  ${rnti_list[4]}
#     Set test Variable    ${rnti_6} 	  ${rnti_list[5]}
#     Set test Variable    ${rnti_7} 	  ${rnti_list[6]}
#     Set test Variable    ${rnti_8} 	  ${rnti_list[7]}
#     Set test Variable    ${rnti_9} 	  ${rnti_list[8]}
#     Set test Variable    ${rnti_10}    ${rnti_list[9]}
#     Set test Variable    ${rnti_11}    ${rnti_list[10]}
#     Set test Variable    ${rnti_12}    ${rnti_list[11]}
#     Set test Variable    ${rnti_13}    ${rnti_list[12]}
#     Set test Variable    ${rnti_14}    ${rnti_list[13]}
#     Set test Variable    ${rnti_15}    ${rnti_list[14]}
#     Set test Variable    ${rnti_16}    ${rnti_list[15]}
#     Set test Variable    ${rnti_17}    ${rnti_list[16]}
#     Set test Variable    ${rnti_18}    ${rnti_list[17]}
#     Set test Variable    ${rnti_19}    ${rnti_list[18]}
#     Set test Variable    ${rnti_20}    ${rnti_list[19]}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_attach' File
# 
# Step4:Send DL full buffer to UEs
#     Start capture GNB and AP Syslog in 'Step4_send_data' File
#     Send trf for All UEs
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_send_data
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_send_data${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case107_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_send_data' File
# 
# Step5:Decrease U3 UE4 UE5 UE6 SRSpower to switch
#     Start capture GNB and AP Syslog in 'Step5_switch' File
#     Set UEi position bad    3
#     Set UEi position bad    4
#     Set UEi position bad2    5
#     Set UEi position bad2    6
# 	Wait '60s' for stable running
#     : FOR    ${i}    IN RANGE    51    61
#     \    Airphone Sa Stop Data Traffic    ${i}    dl	
#     Wait '5s' for stable running
#     : FOR    ${i}    IN RANGE    51    61
#     \    Airphone SA Start Data Traffic    ue_id=${i}    direction=DL    throughput=70M    trf_id=1
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_switch
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_switch${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case107_step5_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_switch' File
# 
# Step6:Repeat Step3 to Step5 for 50 times
#     Start capture GNB and AP Syslog in 'Step6_Repeat_Step3_to_Step5' File
#     : FOR    ${i}    IN RANGE    1    26
#     \    Detach All UEs
# 	\    Wait '5s' for stable running
#     \    Attach All UEs to cell
#     \    Send trf for All UEs
#     \    Wait '5s' for stable running
#     \    Set UEi position bad    3
#     \    Set UEi position bad    4
#     \    Set UEi position bad2    5
#     \    Set UEi position bad2    6
#     \    Wait '5s' for stable running
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_Repeat_Step3_to_Step5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_Repeat_Step3_to_Step5${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case107_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	${DL_throughput}    ${UL_throughput}    get tput from PM counter
#     should be true    ${DL_throughput}>1150
# 	should be true    ${UL_throughput}>150
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6_Repeat_Step3_to_Step5' File
# 
# Step7:Detach UEs
#     Start capture GNB and AP Syslog in 'Step7_detach' File
#     : FOR    ${i}    IN RANGE    1    11
#     \    Airphone Sa Stop Data Traffic    ${i}    dl
#     \    Detach UE    ${i}
#     : FOR    ${i}    IN RANGE    51    61
#     \    Airphone Sa Stop Data Traffic    ${i}    dl
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7_detach' File
# 
# 	
# Attach UE to cell
#     [Arguments]    ${ue_id}    ${pattern}
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     ${newNum}=    evaluate    ${ue_id}+8
#     Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '2s' for stable running
# 	
# Attach All UEs to cell
#     Attach UE to cell    1    ${pattern4}
#     Attach UE to cell    2    ${pattern3}
#     Attach UE to cell    3    ${pattern1}
#     Attach UE to cell    4    ${pattern2}
#     Attach UE to cell    5    ${pattern1}
#     Attach UE to cell    6    ${pattern2}
#     Attach UE to cell    7    ${pattern2}
#     Attach UE to cell    8    ${pattern2}
#     Attach UE to cell    9    ${pattern2}
#     Attach UE to cell    10    ${pattern2}
#     : FOR    ${i}    IN RANGE    51    61
#     \    Attach UE to cell    ${i}    ${pattern1}
#     : FOR    ${i}    IN RANGE    1    11
#     \    Set UEi position    ${i}
#     : FOR    ${i}    IN RANGE    51    61
#     \    Set UEi position    ${i}
# 
# Send trf for All UEs
#     : FOR    ${i}    IN RANGE    1    7
#     \    Airphone SA Start Data Traffic    ue_id=${i}    direction=dl    throughput=70M    trf_id=1    duration=3600
#     \    Airphone Sa Start Data Traffic    ue_id=${i}    direction=ul    throughput=10M    trf_id=1    duration=3600
#     Wait '5s' for stable running
#     : FOR    ${i}    IN RANGE    7    11
#     \    Airphone SA Start Data Traffic    ue_id=${i}    direction=dl    throughput=70M    trf_id=1    duration=3600
#     \    Airphone Sa Start Data Traffic    ue_id=${i}    direction=ul    throughput=10M    trf_id=1    duration=3600
#     : FOR    ${i}    IN RANGE    51    61
#     \    Airphone SA Start Data Traffic    ue_id=${i}    direction=dl    throughput=70M    trf_id=1    duration=3600
#     \    Airphone Sa Start Data Traffic    ue_id=${i}    direction=ul    throughput=10M    trf_id=1    duration=3600
# 
# Send trf for UE
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=3600s    trf_id=${num}
# 
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     airphone_sa_stop_data_traffic    ${ue_id}    DL
# 
# Detach UE
#     [Arguments]    ${ue_id} 
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30
# 	
# Detach All UEs
#     : FOR    ${i}    IN RANGE    1    11
#     \    Airphone Sa Stop Data Traffic    ${i}    dl
#     \    Detach UE    ${i}
#     : FOR    ${i}    IN RANGE    51    61
#     \    Airphone Sa Stop Data Traffic    ${i}    dl
#     \    Detach UE    ${i} 
# 
# Override UEi to DL RANKj and CQIk
#     [Arguments]    ${ue_id}    ${ranki}    ${cqii}
#     airphone_execute_egate_command
#    	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}
# 
# Set UEi position
#     [Arguments]    ${ue_id}
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 	
# Set UEi position bad 
#     [Arguments]    ${ue_id}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# Set UEi position bad2
#     [Arguments]    ${ue_id}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# 
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
#     Active L2ps Feature Debug Traces    ${debuglogs}
#     TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
#     TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# Block Cell1
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
#     ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
# 	
# Unlock Cell1
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
#     ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
# 
# get tput from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     ${remaining_time}     evaluate    ${remaining_time}+300
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#     ${PM_counter_DL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12001
#     ...   cell_id=1
#     ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12002
#     ...   cell_id=1
#     ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
#     [Return]    ${DL_throughput}    ${UL_throughput}
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x340000:1             #as PM counter period update to 15/15=1min
#     add_txt_node    0x58079e:0        #rdWbSrsConstraintTimer
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
