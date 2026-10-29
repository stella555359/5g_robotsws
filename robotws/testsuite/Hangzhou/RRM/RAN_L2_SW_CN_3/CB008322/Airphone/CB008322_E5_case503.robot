# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_E5_case503_IWK_EIRP_multiple_UEs_with_multiple_segments_configured
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      200 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_eirp3.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_9496.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog\    ap_snapshot    gnb_snapshot
# #sosreport   
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
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
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${actEirpControl}                 text|true|//*[@name\="actEirpControl"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${prbSampleHighLowPercentage}          text|100|//*[@name\="prbSampleHighLowPercentage"]
# ${prbRatioThreshold}                   text|2|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}                  text|1|//*[@name\="prbRatioHysteresis"]
# ${srsSinrThreshold}                    text|-400|//*[@name\="srsSinrThreshold"]
# 
# ${pattern1}                       CA_P2_8x4_t2r4_n2
# ${pattern2}                       CA_P2_8x4_t1r4_n1 
# ${pattern3}                       CA_P2_8x4_t4r4_n4
# ${pattern4}                       CA_P2_8x4_noTas_n2
# 
# ${PROFILE}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 test_type=SRS
# ...               multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200 
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=-30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200 
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id=14 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id=15 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS
# ...                multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=-5 srs_transmit_power_per_port=-200,-200,-200,-200
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# #calulated by maxTxPowerPerCCmW maxBeamGain dutyCycle eirpControlPowerReductionFactorList
# ${actual_EIRP_targe_1}    363724
# ${actual_EIRP_targe_2}    363724
# ${actual_EIRP_targe_3}    363724
# ${actual_EIRP_targe_4}    363724
# 
# *** Test Cases ***
# CB008322_E5_case503_IWK_EIRP_multiple_UEs_with_multiple_segments_configured
#     Step1:Commission the above configuration on WebUI
#     Step2:UEs attach and send DL data
#     Step3:Online change actDlSrsSubbandBm to false
#     Step4:DFT UEs with EIRP control
#     Step5:Online change eirpControlPowerReductionFactorList to 0
#     Step6:Online change actDlSrsSubbandBm to true
#     Step7:RT UEs without EIRP control
#     Step8:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${iphy_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}iphy.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${iphy_path}
#     ${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${iphy_path}      ${iphy_path}    ${mod_iphy}
#     change_iphy_rru_version    ${iphy_path}
#     #modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     #change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
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
#     ...    ${actEirpControl}
#     ...    ${prbSampleHighLowPercentage}    ${prbRatioThreshold}       ${prbRatioHysteresis}
#     ...    ${srsSinrThreshold}
#     ...    ${tiltOffset}
# 	modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File2    ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:UEs attach and send DL data
#     Start capture GNB and AP Syslog in 'Step2_RT_UE_EIRP_control' File    
#     Attach UEs and send DL data
#     Wait '60s' for stable running
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_RT_UE_EIRP_control${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_RT_UE_EIRP_control${/}/egate_console.log.001   crnti: (\\d+)
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
#     ${RT_M55324C00000}    ${RT_M55324C00306}    ${RT_M55324C00314}    ${RT_M55324C00325}    ${RT_M55324C00335}
#     ...    ${RT_M55324C00706}    ${RT_M55324C00714}    ${RT_M55324C00725}    ${RT_M55324C00735}    get EIRP counters from PM counter
#     BuiltIn.Set Test Variable    ${RT_M55324C00000}
#     BuiltIn.Set Test Variable    ${RT_M55324C00306}
#     BuiltIn.Set Test Variable    ${RT_M55324C00314}
#     BuiltIn.Set Test Variable    ${RT_M55324C00325}
#     BuiltIn.Set Test Variable    ${RT_M55324C00335}
#     BuiltIn.Set Test Variable    ${RT_M55324C00706}
#     BuiltIn.Set Test Variable    ${RT_M55324C00714}
#     BuiltIn.Set Test Variable    ${RT_M55324C00725}
#     BuiltIn.Set Test Variable    ${RT_M55324C00735}
#     ${RT_EIRP_706}    evaluate    ${RT_M55324C00706}/${RT_M55324C00000}
#     ${RT_EIRP_714}    evaluate    ${RT_M55324C00714}/${RT_M55324C00000}
# 	${RT_EIRP_725}    evaluate    ${RT_M55324C00725}/${RT_M55324C00000}
#     ${RT_EIRP_735}    evaluate    ${RT_M55324C00735}/${RT_M55324C00000}
#     run keyword and continue on failure    should be true    ${RT_M55324C00325}>0
#     run keyword and continue on failure    should be true    ${RT_EIRP_706}<${actual_EIRP_targe_1}
#     run keyword and continue on failure    should be true    ${RT_EIRP_714}<${actual_EIRP_targe_2}
#     run keyword and continue on failure    should be true    ${RT_EIRP_725}<${actual_EIRP_targe_3}
#     run keyword and continue on failure    should be true    ${RT_EIRP_735}<${actual_EIRP_targe_4}
# 	#Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_RT_UE_EIRP_control      
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_RT_UE_EIRP_control${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_E5_case503_step2_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     Detach All UEs	
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_RT_UE_EIRP_control' File
# 
# Step3:Online change actDlSrsSubbandBm to false
#     Start capture GNB and AP Syslog in 'Step3_change_actDlSrsSubbandBm_to_true' File
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actDlSrsSubbandBm
#     ...    operation=update    value=false    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_change_actDlSrsSubbandBm_to_true' File
# 
# Step4:DFT UEs with EIRP control
#     Start capture GNB and AP Syslog in 'Step4_DFT_UE_EIRP_control' File    
#     Attach UEs and send DL data
#     Wait '60s' for stable running	
#     ${DFT_M55324C00000}    ${DFT_M55324C00306}    ${DFT_M55324C00314}    ${DFT_M55324C00325}    ${DFT_M55324C00335}
#     ...    ${DFT_M55324C00706}    ${DFT_M55324C00714}    ${DFT_M55324C00725}    ${DFT_M55324C00735}    get EIRP counters from PM counter
#     BuiltIn.Set Test Variable    ${DFT_M55324C00000}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00306}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00314}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00325}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00335}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00706}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00714}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00725}
#     BuiltIn.Set Test Variable    ${DFT_M55324C00735}
#     ${DFT_EIRP_706}    evaluate    ${DFT_M55324C00706}/${DFT_M55324C00000}
#     ${DFT_EIRP_714}    evaluate    ${DFT_M55324C00714}/${DFT_M55324C00000}
#     ${DFT_EIRP_725}    evaluate    ${DFT_M55324C00725}/${DFT_M55324C00000}
#     ${DFT_EIRP_735}    evaluate    ${DFT_M55324C00735}/${DFT_M55324C00000}
#     ${RT_DFT_M55324C00706}    evaluate    ${RT_M55324C00706}/${DFT_M55324C00706}
#     ${RT_DFT_M55324C00714}    evaluate    ${RT_M55324C00714}/${DFT_M55324C00714}
#     ${RT_DFT_M55324C00725}    evaluate    ${RT_M55324C00725}/${DFT_M55324C00725}
#     ${RT_DFT_M55324C00735}    evaluate    ${RT_M55324C00735}/${DFT_M55324C00735}
#     run keyword and continue on failure    should be true    ${DFT_M55324C00325}>0
#     run keyword and continue on failure    should be true    1.4>${RT_DFT_M55324C00706}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT_DFT_M55324C00714}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT_DFT_M55324C00725}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT_DFT_M55324C00735}>0.6
#     run keyword and continue on failure    should be true    ${DFT_EIRP_706}<${actual_EIRP_targe_1}
#     run keyword and continue on failure    should be true    ${DFT_EIRP_714}<${actual_EIRP_targe_2}
#     run keyword and continue on failure    should be true    ${DFT_EIRP_725}<${actual_EIRP_targe_3}
#     run keyword and continue on failure    should be true    ${DFT_EIRP_735}<${actual_EIRP_targe_4}	
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_DFT_UE_EIRP_control' File
# 	
# Step5:Online change eirpControlPowerReductionFactorList to 0
#     Start capture GNB and AP Syslog in 'Step5_DFT_UE' File	
#     Online recommissioning with delta json file    ${CURDIR}/JSON/CB008322_change_eirpControlPowerReductionFactorList_3.json
#     Wait '60s' for stable running
#     ${DFT2_M55324C00106}    ${DFT2_M55324C00114}    ${DFT2_M55324C00125}    ${DFT2_M55324C00135}    get EIRP counters from PM counter2
#     BuiltIn.Set Test Variable    ${DFT2_M55324C00106}
#     BuiltIn.Set Test Variable    ${DFT2_M55324C00114}
#     BuiltIn.Set Test Variable    ${DFT2_M55324C00125}
#     BuiltIn.Set Test Variable    ${DFT2_M55324C00135}
#     Detach All UEs
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_DFT_UE' File
# 	
# Step6:Online change actDlSrsSubbandBm to true
#     Start capture GNB and AP Syslog in 'Step6_change_actDlSrsSubbandBm_to_false' File
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actDlSrsSubbandBm
#     ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6_change_actDlSrsSubbandBm_to_false' File
# 
# Step7:RT UEs without EIRP control
#     Start capture GNB and AP Syslog in 'Step7_RT_UE' File	
#     Attach UEs and send DL data
#     Wait '60s' for stable running    
#     ${RT2_M55324C00106}    ${RT2_M55324C00114}    ${RT2_M55324C00125}    ${RT2_M55324C00135}    get EIRP counters from PM counter2
#     BuiltIn.Set Test Variable    ${RT2_M55324C00106}
#     BuiltIn.Set Test Variable    ${RT2_M55324C00114}
#     BuiltIn.Set Test Variable    ${RT2_M55324C00125}
#     BuiltIn.Set Test Variable    ${RT2_M55324C00135}
#     ${RT2_DFT2_M55324C00106}    evaluate    ${RT2_M55324C00106}/${DFT2_M55324C00106}
#     ${RT2_DFT2_M55324C00114}    evaluate    ${RT2_M55324C00114}/${DFT2_M55324C00114}
#     ${RT2_DFT2_M55324C00125}    evaluate    ${RT2_M55324C00125}/${DFT2_M55324C00125}
#     ${RT2_DFT2_M55324C00135}    evaluate    ${RT2_M55324C00135}/${DFT2_M55324C00135}
#     run keyword and continue on failure    should be true    1.4>${RT2_DFT2_M55324C00106}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT2_DFT2_M55324C00114}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT2_DFT2_M55324C00125}>0.6
#     run keyword and continue on failure    should be true    1.4>${RT2_DFT2_M55324C00135}>0.6
# 	#Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode	
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_RT_UE
#     Wait '1s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_RT_UE${/}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/CB008322_E5_case503_step2_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7_RT_UE' File
# 
# Step8:Detach UEs
#     Start capture GNB and AP Syslog in 'Step8_detach' File
#     Detach All UEs
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
# Attach UEs and send DL data
#     : FOR    ${i}    IN RANGE    1    5
#     \    Attach UE to cell    ${i}    ${pattern1}
#     : FOR    ${i}    IN RANGE    5    9
#     \    Attach UE to cell    ${i}    ${pattern2}
#     : FOR    ${i}    IN RANGE    51    55
#     \    Attach UE to cell    ${i}    ${pattern3}
#     : FOR    ${i}    IN RANGE    55    59
#     \    Attach UE to cell    ${i}    ${pattern4}	
#     Set UEi position2    1    ${PROFILE1}    1
#     Set UEi position2    5    ${PROFILE2}    2
#     Set UEi position2    51    ${PROFILE3}    3
#     Set UEi position2    55    ${PROFILE4}    4
#     Set UEi position2    2    ${PROFILE5}    5
#     Set UEi position2    6    ${PROFILE6}    6
#     Set UEi position2    52    ${PROFILE7}    7
#     Set UEi position2    56    ${PROFILE8}    8
#     Set UEi position2    3    ${PROFILE9}    9
#     Set UEi position2    7    ${PROFILE10}    10
#     Set UEi position2    53    ${PROFILE11}    11
#     Set UEi position2    57    ${PROFILE12}    12
#     Set UEi position2    4    ${PROFILE13}    13
#     Set UEi position2    8    ${PROFILE14}    14
#     Set UEi position2    54    ${PROFILE15}    15
#     Set UEi position2    58    ${PROFILE16}    16
#     : FOR    ${i}    IN RANGE    1    9
#     \    Airphone Sa Start Data Traffic    ue_id=${i}    direction=DL    throughput=80M    trf_id=1    duration=3600
#     : FOR    ${i}    IN RANGE    51    59
#     \    Airphone Sa Start Data Traffic    ue_id=${i}    direction=DL    throughput=80M    trf_id=1    duration=3600
#     #: FOR    ${i}    IN RANGE    1    9
#     #\    Airphone Sa Start Data Traffic    ue_id=${i}    direction=DL    throughput=30M    trf_id=2    duration=3600
#     #: FOR    ${i}    IN RANGE    51    59
#     #\    Airphone Sa Start Data Traffic    ue_id=${i}    direction=DL    throughput=30M    trf_id=2    duration=3600
# 
# Detach All UEs
#     : FOR    ${i}    IN RANGE    1    9
#     \    Detach UE    ${i}
#     : FOR    ${i}    IN RANGE    51    59
#     \    Detach UE    ${i}
# 
# Send trf for UE
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone Sa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=3600s    trf_id=${num}
# 
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     Airphone Sa Stop Data Traffic    ${ue_id}    DL
# 	
# Detach UE
#     [Arguments]    ${ue_id} 
#     Airphone Sa Detach    ue_id=${ue_id}    timeout=30
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
# Set UEi position2
#     [Arguments]    ${ue_id}    ${PROFILE_name}    ${PROFILE_id}
#     airphone_execute_egate_command    ${PROFILE_name}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${PROFILE_id}
# 
# get EIRP counters from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+600
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#  
#     ${PM_counter_M55324C00000}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00000
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00306}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00306
#     ...   cell_id=1
# 
#     ${PM_counter_M55324C00314}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00314
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00325}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00325
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00335}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00335
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00706}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00706
#     ...   cell_id=1
# 
#     ${PM_counter_M55324C00714}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00714
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00725}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00725
#     ...   cell_id=1
# 		
#     ${PM_counter_M55324C00735}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00735
#     ...   cell_id=1
#     #${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 
#     [Return]    ${PM_counter_M55324C00000}    ${PM_counter_M55324C00306}    ${PM_counter_M55324C00314}    ${PM_counter_M55324C00325}
#     ...         ${PM_counter_M55324C00335}
#     ...         ${PM_counter_M55324C00706}    ${PM_counter_M55324C00714}    ${PM_counter_M55324C00725}    ${PM_counter_M55324C00735}
# 
# get EIRP counters from PM counter2
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+600
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#  
#     ${PM_counter_M55324C00000}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00000
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00106}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00106
#     ...   cell_id=1
# 
#     ${PM_counter_M55324C00114}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00114
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00125}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00125
#     ...   cell_id=1
# 	
#     ${PM_counter_M55324C00135}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55324C00135
#     ...   cell_id=1
#     [Return]    ${PM_counter_M55324C00106}    ${PM_counter_M55324C00114}    ${PM_counter_M55324C00125}    ${PM_counter_M55324C00135}
# 
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
#     add_txt_node    0x9D0000:5             #as PM counter period update to 15/15=1min
#     add_txt_node    0x5805b4:10            #rdPeriodSrsCheck(Defalut Value is 20)
#     add_txt_node    0x58079e:0             #rdWbSrsConstraintTimer(int;60;[0..10000])
#     add_txt_node    0x58079e:0             #rdWbSrsConstraintTimer
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Get and Update BSR File2
#     [Arguments]      ${par_of_bsr_name}=BSR_AEQE_6_H6_ALN60
#     ${bsr_file_path}     get BSR file name3      ${par_of_bsr_name}
#     COAM.setup admin
#     ${ret}     COAM.Update Software      ${bsr_file_path}
#     COAM.teardown admin
#  
# get BSR file name2 
#     [Arguments]       ${part_of_file_name}
#     ${files}     List Files In Directory      ${CONFIG_DIR_PATH}/${SW_BRANCH}/BSR_FILE
#     :FOR     ${f}    IN    @{files}
#     \    Return From Keyword if     '${part_of_file_name}' in '${f}'         ${CONFIG_DIR_PATH}/${SW_BRANCH}/BSR_FILE/${f}
# 
# get BSR file name3 
#     [Arguments]       ${part_of_file_name}
#     ${files}     List Files In Directory      ${PRIVATE_LOCAL_PATH}/temp
#     :FOR     ${f}    IN    @{files}
#     \    Return From Keyword if     '${part_of_file_name}' in '${f}'         ${PRIVATE_LOCAL_PATH}/temp/${f}
