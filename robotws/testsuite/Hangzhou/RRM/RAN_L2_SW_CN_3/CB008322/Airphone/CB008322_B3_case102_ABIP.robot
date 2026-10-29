# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_B3_case102_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_switch_based_on_buffer_ABIP
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
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
# @{LOG_NAME_LIST}      egatelog\
# #gnb_snapshot    ap_snapshot    sosreport
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
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1100|//*[@name\="srsPowerThresholdForDlBm"]
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
# ${srsUePeriodicityInput}          text|slots160|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}         text|slots160|//*[@name\="srsUePeriodicityOutput"]
# ${prbRatioThreshold}               text|10|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}             text|5|//*[@name\="prbRatioHysteresis"]
# ${prbSampleHighLowPercentage}     text|80|//*[@name\="prbSampleHighLowPercentage"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${pattern1}                       CA_P2_8x4_t2r4_n2
# ${pattern2}                       CA_P2_8x4_t1r4_n1 
# ${pattern3}                       CA_P2_8x4_t4r4_n4
# ${pattern4}                       CA_P2_8x4_noTas_n2
# ${pattern5}                       TDD_NSA_CA_NoRefinebeam
# #${pattern6}                       ue_eutra_nr_cap
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# *** Test Cases ***
# CB008322_B3_case102_wide_band_TAS_SRS_configuration_algorithm_multiple_UEs_switch_based_on_buffer
#     Step1:Commission the above configuration on WebUI
#     Step2:5 NSA UE with t2r4 capability attach to cell1
#     Step3:Send DL full buffer to UE1 UE2 UE3 UE4
#     Step4:Send DL full buffer to UE5
#     Step5:Decrease UE1 DL buffer to below rdSrsBufPercent
#     Step6:Decrease UE2 DL buffer and Increase UE1 buffer
#     Step7:Repeat step5 and step6 for more than 10 times
#     Step8:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     #add_bwplist_list_in_cells_new    ${scfc_path}    key_4
#     ${modify_list}    create list
# 	...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                     ${nrCellType}                
# 	...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                     ${actUlSrsBm}
#     ...    ${actUlClosedLoopPwrCtrl}        ${actCDrx}                 ${actFdmScheduling}               ${frameStructureType}
#     ...    ${guardPeriodLength}             ${ulDlDataSlotRatio}       ${prachConfigurationIndex}        ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}       ${srsTypeAllocForDlBm}
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}                    ${srsQualityThreshold}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${lteToNrFrameShift}  	        ${tdLteUlDlConfig}         ${actDlMuMimoEnh}
# 	...    ${actDl256Qam}                   ${actUl256Qam}
#     ...    ${srsUePeriodicityInput}    ${srsUePeriodicityOutput}    ${prbRatioThreshold}    ${prbRatioHysteresis}    
#     ...    ${prbSampleHighLowPercentage}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:5 NSA UE with t2r4 capability attach to cell1
#     Start capture GNB and AP Syslog in 'Step2_attach' File
# 	${ue_capability}    Obtain Ue Capability    ${pattern5}
# 	Start GNB BIP Log
# 	Airphone Nsa Attach    ue_id=11     ue_nr_capabilities=${ue_capability}
# 	Airphone Nsa Attach    ue_id=12     ue_nr_capabilities=${ue_capability}
# 	Airphone Nsa Attach    ue_id=13     ue_nr_capabilities=${ue_capability}
# 	Airphone Nsa Attach    ue_id=14     ue_nr_capabilities=${ue_capability}
# 	Airphone Nsa Attach    ue_id=15     ue_nr_capabilities=${ue_capability}
#     : FOR    ${i}    IN RANGE    11    16
#     \    Set UEi position    ${i} 
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '5s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	#${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send DL full buffer to UE1 UE2 UE3 UE4
#     Start capture GNB and AP Syslog in 'Step3' File
# 	Send trf for UE NSA    11    dl    80M    3
# 	Send trf for UE NSA    12    dl    80M    3
# 	Send trf for UE NSA    13    dl    80M    3
# 	Send trf for UE NSA    14    dl    80M    3
# 	Send trf for UE NSA    15    dl    10M    1
# 	#Airphone Nsa Start Data Traffic    ue_id=1    direction=dl    throughput=150M    trf_id=${i}
# 	Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case102_step3_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     #${DL_throughput}    get tput from PM counter
# 	#run keyword and continue on failure
# 	#    ...    should be true    ${DL_throughput}>900
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
# 	
# Step4:Send DL full buffer to UE5
# 	Start capture GNB and AP Syslog in 'Step4' File
# 	Send trf for UE NSA    15    dl    80M    3
# 	Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode	
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case102_step3_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step4' File
# 
# Step5:Decrease UE1 DL buffer to below rdSrsBufPercent
# 	Start capture GNB and AP Syslog in 'Step5' File
#     Airphone Nsa Stop Data Traffic    ue_id=11    direction=dl
# 	Wait '10s' for stable running
# 	Send trf for UE NSA    11    dl    10M    1
# 	Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode	
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case102_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step5' File
# 	
# Step6:Decrease UE2 DL buffer and Increase UE1 buffer
#     Start capture GNB and AP Syslog in 'Step6' File
# 	Airphone Nsa Stop Data Traffic    ue_id=12    direction=dl
# 	Airphone Nsa Stop Data Traffic    ue_id=11    direction=dl
# 	Wait '10s' for stable running
# 	Send trf for UE NSA    11    dl    80M    3
# 	Send trf for UE NSA    12    dl    10M    1
# 	Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case102_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step6' File
# 	
# Step7:Repeat step5 and step6 for more than 10 times
#     Start capture GNB and AP Syslog in 'Step7' File
# 	: FOR    ${i}    IN RANGE    1    11
# 	\    Airphone Nsa Stop Data Traffic    ue_id=11    direction=dl
# 	\    Airphone Nsa Stop Data Traffic    ue_id=12    direction=dl
# 	\    Wait '5s' for stable running
# 	\    Send trf for UE NSA    12    dl    80M    3
# 	\    Send trf for UE NSA    11    dl    5M    3
# 	\    Wait '5s' for stable running
# 	\    Airphone Nsa Stop Data Traffic    ue_id=11    direction=dl
# 	\    Airphone Nsa Stop Data Traffic    ue_id=12    direction=dl
# 	\    Wait '5s' for stable running
# 	\    Send trf for UE NSA    12    dl    5M    3
# 	\    Send trf for UE NSA    11    dl    80M    3
# 	#Airphone Nsa Stop Data Traffic    ue_id=11    direction=dl
# 	Start GNB BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait '1s' for stable running
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_B3_case102_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7' File
# 
# Step8:Detach UEs
#     Start capture GNB and AP Syslog in 'Step8' File
#     : FOR    ${i}    IN RANGE    11    16
# 	\    	Airphone Nsa Detach    ue_id=${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step8' File
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
# Attach UE to cell NSA
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
# Send trf for UE NSA
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone Nsa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    trf_id=${num}    bearer_id=2    duration=3600
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
# 	airphone_execute_egate_command
#    	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
# 	airphone_execute_egate_command
# 	...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}
# 	
# Set UE SRS power
#     [Arguments]    ${ue_id}    ${srspower}
# 	airphone_execute_egate_command
#    	...    ul_sinr_testmode_nr profile_id\=${ue_id} sinr_target_srs\=${srspower}
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${ue_id}
# 
# Set UEi position
#     [Arguments]    ${ue_id}
#     airphone_execute_egate_command    ${PROFILE1}
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x340000:1          #as PM counter period update to 15/15=1min
#     add_txt_node    0x58079e:0          #rdWbSrsConstraintTimer
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# get tput from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     ${remaining_time}     evaluate    ${remaining_time}+1800
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#     ${PM_counter_DL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12001
#     ...   cell_id=1
#     ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	[Return]    ${DL_throughput}
