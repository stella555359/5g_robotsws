# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_G4_case004_WB_SRS_release_Unexpected_cases
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_pmi.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_pmi.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot    
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1000|//*[@name\="srsQualityThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${srsSinrThreshold}               text|350|//*[@name\="srsSinrThreshold"]
# ${prbRatioThreshold}              text|20|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}             text|5|//*[@name\="prbRatioHysteresis"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${bwp_profile5}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern1}                       CA_P2_8x4_t2r4_n2
# ${pattern2}                       CA_P2_8x4_t1r4_n1 
# ${pattern3}                       CA_P2_8x4_t4r4_n4
# ${pattern4}                       CA_P2_8x4_noTas_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-220,-220,-220,-220
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-690,-690,-690,-690
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# *** Test Cases ***
# CB008322_G4_case004_WB_SRS_release_Unexpected_cases
#     Step1:Commission the above configuration on WebUI
#     Step2:Unexpected case01 high percentage of BWV failure
#     Step3:Online change srsSinrThreshold to 6
#     Step4:UEs attach to cell1 and send data
#     Step5:Set SINR lower than srsSinrThreshold add 2dB
# 	#Step6:Set SINR lower than srsSinrThreshold
#     #Step7:Repeat Step3
#     #Step8:Repeate Step4
# 	#Step9:Set SINR lower than srsSinrThreshold add 2dB
#     Step10:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     ${modify_list}    create list
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                     ${nrCellType}            
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                     ${actUlSrsBm}
#     ...    ${actUlClosedLoopPwrCtrl}        ${actCDrx}                 ${actFdmScheduling}               ${frameStructureType}
#     ...    ${guardPeriodLength}             ${ulDlDataSlotRatio}       ${prachConfigurationIndex}        ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}       ${srsTypeAllocForDlBm}
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}                    ${srsQualityThreshold}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${actDlMuMimoEnh}                ${actDl256Qam}             ${actUl256Qam}
#     ...    ${srsSinrThreshold}              ${prbRatioThreshold}       ${prbRatioHysteresis}
#     ...    ${bwp_profile5}                  ${bwp_profile52}
#     ...    ${tiltOffset}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Wts Execute Aashell Command     
#     ...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Unexpected case01 high percentage of BWV failure
#     Start capture GNB and AP Syslog in 'Step2_BWV_failure_SBSRS' File
#     : FOR    ${i}    IN RANGE    1    2
# 	\    Attach UE to cell    ${i}    ${pattern2}
#     \    Set UEi position    ${i}
#     \    Send trf for UE    ${i}    dl    150M    8
#     \    Send trf for UE    ${i}    ul    20M    1
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_BWV_failure_SBSRS
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_BWV_failure_SBSRS${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case004_step2_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
#     : FOR    ${i}    IN RANGE    1    2
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_BWV_failure_SBSRS' File
# 
# Step3:Online change srsSinrThreshold to 6
#     Start capture GNB and AP Syslog in 'Step3_change_srsSinrThreshold' File
#     Online recommissioning with delta json file    ${CURDIR}/JSON/CB008322_change_srsSinrThreshold_G4_case004.json
#     Reset Testline
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_change_srsSinrThreshold' File
# 
# Step4:UEs attach to cell1 and send data
#     Start capture GNB and AP Syslog in 'Step4_WBSRS_used' File
#     airphone_execute_egate_command    ul_cell_noise_testmode_nr profile_id\=1 noise_srs\=-300
#     airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait '5s' for stable running
# 	#Attach UE to cell    1    ${pattern2}
#     : FOR    ${i}    IN RANGE    1    2
# 	\    Attach UE to cell    ${i}    ${pattern2}
#     \    Set UEi position    ${i}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4_WBSRS_used${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step4_WBSRS_used${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable    ${rnti_1} 	  ${rnti_list[0]}
#     : FOR    ${i}    IN RANGE    1    2
#     \    Send trf for UE    ${i}    dl    150M    9
#     \    Send trf for UE    ${i}    ul    20M    1
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_WBSRS_used
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_WBSRS_used${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case004_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_WBSRS_used' File
# 
# Step5:Set SINR lower than srsSinrThreshold add 2dB
#     Start capture GNB and AP Syslog in 'Step5_DFT_used' File
#     Set UEi position bad    1	
#     Wait '5s' for stable running
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_DFT_used
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_DFT_used${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case004_step2_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     #run keyword and continue on failure    split_value_of_bwv_response  ${save_log}/target_dl.csv    ${save_log}/target_bwv.csv
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_DFT_used' File
# 
# Step6:Set SINR lower than srsSinrThreshold
#     Start capture GNB and AP Syslog in 'Step4_DFT_used' File	
# 	Change Cell SRS SINR    -900
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#    	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_DFT_used${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_DFT_used
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case001_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_DFT_used' File
# 
# Step7:Repeat Step3
#     Start capture GNB and AP Syslog in 'Step5_RT_used_2' File	
# 	Change Cell SRS SINR    -100
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#    	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_RT_used_2${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_RT_used_2
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case003_step2_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_RT_used_2' File
# 
# Step8:Repeate Step4
#     Start capture GNB and AP Syslog in 'Step5_DFT_used_2' File	
# 	Change Cell SRS SINR    -100
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#    	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_DFT_used_2${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_DFT_used_2
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case001_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_DFT_used_2' File
# 
# Step9:Set SINR lower than srsSinrThreshold add 2dB
#     Start capture GNB and AP Syslog in 'Step_WBSRS_release' File	
# 	Change Cell SRS SINR    -800
#     Wait '5s' for stable running
# 	#Start GNB BIP Log
#    	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step_WBSRS_release${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step_WBSRS_release
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_G4_case001_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step_WBSRS_release' File
# 
# Step10:Detach UEs
#     Start capture GNB and AP Syslog in 'Step8_detach' File
#     : FOR    ${i}    IN RANGE    1    2
#     \    Airphone Sa Stop Data Traffic    ${i}    dl
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step8_detach' File
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
# Change Cell SRS SINR
#     [Arguments]    ${noise_num}
#     airphone_execute_egate_command    ul_cell_noise_testmode_nr profile_id\=1 noise_srs\=${noise_num}
#     airphone_execute_egate_command    cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=ul_cell_noise profile_id\=1 action\=activate
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
#     add_txt_node    0x58076a:10        #rdNumWbSrsMeas(Default Value is 5, [1,200])
#     add_txt_node    0x800070:1        #rdRtBwvDowngradeMethod(default is 1,[0,4])
# 	add_txt_node    0x58077f:0        #rdHighVolatileUeFallbackTStep(default is 0, [0,400])
#     #add_txt_node    0x580717:0        #rdPdcchApplyToSeparateStreams(default is true)
#     add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
#     #add_txt_node    0x580030:20       #rdCqiExpiryTime
#     add_txt_node    0x58079e:600      #rdWbSrsConstraintTimer
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
