# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_B3_case104_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_with_different_TAS_SRS_capability_ABIP
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_ABIP.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_ABIP.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      egatelog\    gnb_snapshot    ap_snapshot
# #    sosreport    
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
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
# ${lteToNrFrameShift}              text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots160|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|64 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1000|//*[@name\="srsQualityThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# ${dllaDeltaCqiMax}                text|0|//*[@name\="dllaDeltaCqiMax"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${srsUePeriodicityInput}         text|slots160|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}        text|slots160|//*[@name\="srsUePeriodicityOutput"]
# ${seThreshold}                   text|100|//*[@name\="seThreshold"]
# ${seHysteresis}                  text|50|//*[@name\="seHysteresis"]
# ${wbSrsPowerHysteresis}          text|50|//*[@name\="wbSrsPowerHysteresis"]
# ${channelStabilityThreshold}     text|20|//*[@name\="channelStabilityThreshold"]
# ${channelStabilityHysteresis}    text|5|//*[@name\="channelStabilityHysteresis"]
# ${rlqBadPercentage}              text|15|//*[@name\="rlqBadPercentage"]
# ${numWbSrsConfigSample}          text|6|//*[@name\="numWbSrsConfigSample"]
# ${numWbSrsReleaseSample}         text|6|//*[@name\="numWbSrsReleaseSample"]
# ${prbRatioThreshold}             text|10|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}            text|5|//*[@name\="prbRatioHysteresis"]
# ${srsSinrThreshold}              text|-400|//*[@name\="srsSinrThreshold"]
# ${rankHysteresis}                text|0|//*[@name\="rankHysteresis"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${pattern1}                       CA_P2_8x4_t2r4_n2
# ${pattern2}                       CA_P2_8x4_t1r4_n1 
# ${pattern3}                       CA_P2_8x4_t4r4_n4
# ${pattern4}                       CA_P2_8x4_noTas_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# *** Test Cases ***
# CB008322_B3_case104_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_with_different_TAS_SRS_capability
#     Step1:Commission the above configuration on WebUI
#     Step2:UEs with t1r4 t2r4 and RANK4 attach to cell1
#     Step3:Send DL full buffer to UE1
#     Step4:Send DL full buffer to UE2 UE3 UE4
#     Step5:Send DL full buffer to UE5 UE6
#     Step6:Override UE2 CQI to below rrmSbSrsSeTreshold
#     Step7:Override UE2 CQI to above rdWbSrsSeTresh
#     #Step8:Override UE3 SRS correlation to below rrmSbSrsCorrTresh
#     #Step9:Repeat step6 and step7 for more than 10 times
#     Step10:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
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
#     ...    ${dllaDeltaCqiMax}
#     ...    ${srsUePeriodicityInput}	        ${srsUePeriodicityOutput}       ${seThreshold}                 ${seHysteresis}
#     ...    ${wbSrsPowerHysteresis}          ${channelStabilityThreshold}    ${channelStabilityHysteresis}
#     ...    ${prbRatioThreshold}             ${prbRatioHysteresis}           ${srsSinrThreshold}            ${rankHysteresis} 	
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:UEs with t1r4 t2r4 and RANK4 attach to cell1
#     Start capture GNB and AP Syslog in 'Step2_attach' File
#     #${ue_capability}    Obtain Ue Capability    ${pattern1}
#     #Start GNB BIP Log
#     Attach UE to cell    1    ${pattern2}
#     Attach UE to cell    2    ${pattern2}
#     Attach UE to cell    3    ${pattern2}
#     Attach UE to cell    4    ${pattern1}
#     Attach UE to cell    5    ${pattern1}
#     Attach UE to cell    6    ${pattern1}
#     : FOR    ${i}    IN RANGE    1    7
#     \    Set UEi position    ${i}
#     #Override UEi to DL RANKj and CQIk    1    0    15
#     #Override UEi to DL RANKj and CQIk    2    1    15
#     #Override UEi to DL RANKj and CQIk    3    2    15
#     #Override UEi to DL RANKj and CQIk    4    2    15
#     #Override UEi to DL RANKj and CQIk    5    3    15
#     #Override UEi to DL RANKj and CQIk    6    3    15
#     #Set UE SRS power    1    -110   
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     Set test Variable	 ${rnti_4} 	${rnti_list[3]}
#     Set test Variable	 ${rnti_5} 	${rnti_list[4]}
#     Set test Variable	 ${rnti_6} 	${rnti_list[5]}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send DL full buffer to UE1
#     Start capture GNB and AP Syslog in 'Step3' File
#     Send trf for UE    1    DL    150M   9
#     Send trf for UE    2    DL    20M   1
#     Send trf for UE    3    DL    20M   1
#     Send trf for UE    4    DL    20M   1
#     Send trf for UE    5    DL    20M   1
#     Send trf for UE    6    DL    20M   1
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step3_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Send DL full buffer to UE2 UE3 UE4
#     Start capture GNB and AP Syslog in 'Step4' File
#     #Start GNB Ttitrace With Streaming Mode
# 	#: FOR    ${i}    IN RANGE    1    5
#     #\    Stop UE DL Traffic    ${i}
# 	Stop UE DL Traffic    1
# 	Send trf for UE    1    DL    100M   2
#     Send trf for UE    2    DL    100M   2
#     Send trf for UE    3    DL    100M   2
#     Send trf for UE    4    DL    100M   2
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4' File
# 	
# Step5:Send DL full buffer to UE5 UE6
#     Start capture GNB and AP Syslog in 'Step5' File
#     #Start GNB Ttitrace With Streaming Mode
# 	#Stop UE DL Traffic    5
# 	#Stop UE DL Traffic    6
#     Send trf for UE    5    DL    100M   2
# 	Send trf for UE    6    DL    100M   2
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     Wait '2s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5' File
# 
# Step6:Override UE2 CQI to below rrmSbSrsSeTreshold
#     Start capture GNB and AP Syslog in 'Step6' File
#     Override UEi to DL RANKj and CQIk    1    3    2
# 	Override UEi to DL RANKj and CQIk    2    3    15
# 	Override UEi to DL RANKj and CQIk    3    3    15
# 	Override UEi to DL RANKj and CQIk    4    1    15
# 	Override UEi to DL RANKj and CQIk    5    3    15
# 	Override UEi to DL RANKj and CQIk    6    3    15
#     Wait '10s' for stable running
# 	#Start GNB Ttitrace With Streaming Mode
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6' File
# 	
# Step7:Override UE2 CQI to above rdWbSrsSeTresh
#     Start capture GNB and AP Syslog in 'Step7' File
#     Override UEi to DL RANKj and CQIk    1    3    15
# 	Override UEi to DL RANKj and CQIk    4    3    15
#     Wait '10s' for stable running
# 	#Start GNB Ttitrace With Streaming Mode
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7' File
# 
# Step8:Override UE3 SRS correlation to below rrmSbSrsCorrTresh
#     Start capture GNB and AP Syslog in 'Step8' File
#     #Override UEi to DL RANKj and CQIk    2    3    10
#     Wait '10s' for stable running
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step8${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step8_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step8' File
# 	
# Step9:Repeat step6 and step7 for more than 10 times
#     Start capture GNB and AP Syslog in 'Step9' File
# 	: FOR    ${i}    IN RANGE    1    11
# 	\    Override UEi to DL RANKj and CQIk    2    3    2
# 	\    Override UEi to DL RANKj and CQIk    5    1    15
# 	\    Wait '1s' for stable running
# 	\    Override UEi to DL RANKj and CQIk    1    3    2
# 	\    Override UEi to DL RANKj and CQIk    4    1    15
# 	\    Wait '1s' for stable running
# 	\    Override UEi to DL RANKj and CQIk    2    3    15
# 	\    Override UEi to DL RANKj and CQIk    5    3    15
# 	#Start GNB Ttitrace With Streaming Mode
# 	#Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step9
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step9${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B_case104_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step9' File
# 
# Step10:Detach UEs
#     Start capture GNB and AP Syslog in 'Step10' File
#     : FOR    ${i}    IN RANGE    1    7
#     \    Stop UE DL Traffic    ${i}
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step10' File
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
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
#     Active L2ps Feature Debug Traces    ${debuglogs}
#     TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
#     TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     #add_txt_node    0x58076b:0x64     #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)  
#     add_txt_node    0x5805b4:10       #rdPeriodSrsCheck(Defalut Value is 20)
#     add_txt_node    0x58079e:0        #rdWbSrsConstraintTimer
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
