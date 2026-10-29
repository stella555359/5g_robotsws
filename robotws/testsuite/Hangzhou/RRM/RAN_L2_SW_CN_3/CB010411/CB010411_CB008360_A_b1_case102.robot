# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B1a_case_102_2 Rank1 UEs blindly paired online change ulMinPrbThreshold
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# #Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS22R4    RAN_5G_TDD    RAN_5G    owner_lily
# Test Timeout      90 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# #Resource          ../resources/sg11/internal_resource/robot/internal_aic.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}        scfc_VDU_8360_8D4U.xml
# ${CU_SCF}        scfc_VCU_8360_8D4U.xml
# ${AIRPHONE_NAME}    iphy_8360_8D4U.xml
# ${WTS_NAME}           basic_setup_8360.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${UE_NUM}         100
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|2|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|0|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|0|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${prbThreshRangeOne}                 text|0|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}                 text|0|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}                 text|0|//*[@name\="prbThreshRangeThree"]
# ${ulMuMimoCorrThd}                              text|100|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|51|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# ${actUlPtrs}                          text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                          text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# 
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${pattern}    t2r4_n2_pusch_1layer
# 
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id=1 phr_mode=Fixed
# ...          phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=1 phr_period=20 pc_max=30
# 
# 
# @{MO_DN_LIST1}         MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0
# @{MO_DN_LIST2}         MRBTS-1/NRBTS-1/NRCELL-2/NRULMUMIMO-0
# @{UPDATED_PARAS_DICT_LIST1}    ${Modify_Params1}
# &{Modify_Params1}    ulMuMimoPrbThresholdRatio/prbThreshRangeOne=0.5    ulMuMimoPrbThresholdRatio/prbThreshRangeTwo=0.5
#     ...       ulMuMimoPrbThresholdRatio/prbThreshRangeThree=0.5
# 
# @{UPDATED_PARAS_DICT_LIST2}    ${Modify_Params2}
# &{Modify_Params2}    ulMuMimoPrbThresholdAbsolute=50
# 
# @{UPDATED_PARAS_DICT_LIST3}    ${Modify_Params3}
# &{Modify_Params3}    ulMinPrbThreshold=270
# 
# @{UPDATED_PARAS_DICT_LIST4}    ${Modify_Params4}
# &{Modify_Params4}    ulMuMimoPrbThresholdAbsolute=0
# 
# 
# *** Test Cases ***
# CB008360_A_B1a_case_102_2 Rank1 UEs blindly paired online change ulMinPrbThreshold
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Step3:Push full buffer in UL
#     Step4:Online increase prbThreshRange to 05
#     Step5:Online increase ulMuMimoPrbThresholdAbsolut to 50
#     Step6:Online increase ulMinPrbThreshold to 273
#     Step7:Online reduce ulMuMimoPrbThresholdAbsolut to 0
# 	
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     #change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    0
#     #Set Pos By Modify L1ByPTestModeConfiguration    22    0    17    0    22    0    17    0    1
#     #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     #modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    none    none
# 
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_8360.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
# 
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=csirsPower
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=csirsNumberWithinReportPeriod_Set1
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=maxCsirsNumber
# 
#     ${modify_list}    create list    ${chBw}
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}
#     ...       ${actUlSrsBm}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${msg1FrequencyStart}
#     ...       ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}    ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}
#     ...       ${ulMuMimoLinkAdaptionSwitch}    
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${actUlPtrs}    ${ulDMRSAdditionalPosition}
#     ...       ${actUlMuMimoTapering}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}
#     ...       ${bwp_profile5}    ${bwp_profile57}
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
# 
# 
#     Modify TL VM And AP SCTP Configuration
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# 
# Step2:Attach 2UEs,UE1 in H0V0,UE2 in H30V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
# 	Attach SA ue with capability to 5g cell    2    t2r4_n2_pusch_1layer
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0	   
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	#Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Start GNB BIP Log
# 	Airphone SA Start Data Traffic    1    UL    40M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    UL    40M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    40M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    UL    40M    trf_id=2    pdu_id=1    duration=${3600}
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     #Start GNB Ttitrace With Streaming Mode
# 
#     #Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
# 
#     Wait Throughput Timer    3
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
# 
#     #Wait Throughput Timer    3
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
# 
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case102_tti_pair_step3.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
# 	@{list_directory}    List Files In Directory    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer    *.log    
# 	${paired_ratio}    file match all   ${TEST_LOG_DIRECTORY()}Step3_inject_buffer/@{list_directory}[0]   
# 	...    Current ratio is: (0.\\d+) for check point: {'ULFDSCHEDDATA.ULMUSTATUS': 'MUPAIRED_NO_TAPERING'}
#     Set suite Variable	 ${paired_step3} 	${paired_ratio[0]}	
# 	#should be true    ${paired_size}>0.01  
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File	
# 
# Step4:Online increase prbThreshRange to 05
#     Start Collect GNB and AP Syslog in 'Step4_increase_prbThreshRange' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_increase_prbThreshRange
#     #Start GNB BIP Log
# 	#check validity of prbThreshRang
# 	##Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_prbThreshRange_05.json
#     ##Wait Throughput Timer    5
# 
#     VDU Online Change Parameters    ${MO_DN_LIST1}      ${UPDATED_PARAS_DICT_LIST1}
#     VDU Online Change Parameters    ${MO_DN_LIST2}      ${UPDATED_PARAS_DICT_LIST1}
#     Wait '30s' for stabible
# 
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_increase_prbThreshRange${/}
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step4_increase_prbThreshRange${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step4_increase_prbThreshRange${/}tti
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case102_tti_pair_step4.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_increase_prbThreshRange
# 	@{list_directory}    List Files In Directory    ${TEST_LOG_DIRECTORY()}Step4_increase_prbThreshRange    *.log    
# 	${paired_ratio}    file match all   ${TEST_LOG_DIRECTORY()}Step4_increase_prbThreshRange/@{list_directory}[0]   
# 	...    Current ratio is: (0.\\d+) for check point: {'ULFDSCHEDDATA.ULMUSTATUS': 'MUPAIRED_NO_TAPERING'}
#     Set suite Variable	 ${paired_step4} 	${paired_ratio[0]}
# 	run keyword and continue on failure    should be true    ${paired_step4}>${paired_step3}    
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_increase_prbThreshRange' File
# 
# Step5:Online increase ulMuMimoPrbThresholdAbsolut to 50
#     Start Collect GNB and AP Syslog in 'Step5_increase_ulMuMimoPrbThresholdAbsolut' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_increase_ulMuMimoPrbThresholdAbsolut
#     #Start GNB BIP Log
# 	#check validity of ulMinPrbThreshold
# 	##Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_ulMuMimoPrbThresholdAbsolut_50.json
#     ##Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_increase_ulMuMimoPrbThresholdAbsolut${/}
# 
#     VDU Online Change Parameters    ${MO_DN_LIST1}      ${UPDATED_PARAS_DICT_LIST2}
#     VDU Online Change Parameters    ${MO_DN_LIST2}      ${UPDATED_PARAS_DICT_LIST2}
#     Wait '30s' for stabible
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti_abprb50
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step5_increase_ulMuMimoPrbThresholdAbsolut${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step5_increase_ulMuMimoPrbThresholdAbsolut${/}tti_abprb50
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case102_tti_pair_step5.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step5_increase_ulMuMimoPrbThresholdAbsolut
# 	@{list_directory}    List Files In Directory    ${TEST_LOG_DIRECTORY()}Step5_increase_ulMuMimoPrbThresholdAbsolut    *.log    
# 	${paired_ratio}    file match all   ${TEST_LOG_DIRECTORY()}Step5_increase_ulMuMimoPrbThresholdAbsolut/@{list_directory}[0]   
# 	...    Current ratio is: (0.\\d+) for check point: {'ULFDSCHEDDATA.ULMUSTATUS': 'MUPAIRED_NO_TAPERING'}
#     Set suite Variable	 ${paired_step5} 	${paired_ratio[0]}
# 	${pair_ratio_step5_float}    Evaluate    0.1
# 	${pair_ratio_step5_estimate_b}    Evaluate        ${paired_step4}+${pair_ratio_step5_float}
#     ${pair_ratio_step5_estimate_s}    Evaluate        ${paired_step4}-${pair_ratio_step5_float}
# 	run keyword and continue on failure    should be true    ${paired_step5}>${pair_ratio_step5_estimate_s} 
# 	run keyword and continue on failure    should be true    ${paired_step5}<${pair_ratio_step5_estimate_b}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_increase_ulMuMimoPrbThresholdAbsolut' File
# 
# 
# Step6:Online increase ulMinPrbThreshold to 273
#     Start Collect GNB and AP Syslog in 'Step6_change_ulMinPrbThreshold_273' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_change_ulMinPrbThreshold_273
#     #Start GNB BIP Log
#     ##Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_ulMinPrbThreshold_273.json
# 	##Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_change_ulMinPrbThreshold_273${/}
#     Wait Throughput Timer    5
# 
#     VDU Online Change Parameters    ${MO_DN_LIST1}      ${UPDATED_PARAS_DICT_LIST3}
#     VDU Online Change Parameters    ${MO_DN_LIST2}      ${UPDATED_PARAS_DICT_LIST3}
#     Wait '30s' for stabible
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti_minprb273
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step6_change_ulMinPrbThreshold_273${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step6_change_ulMinPrbThreshold_273${/}tti_minprb273
# 
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case102_tti_pair_step6.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step6_change_ulMinPrbThreshold_273
#     @{list_directory}    List Files In Directory    ${TEST_LOG_DIRECTORY()}Step6_change_ulMinPrbThreshold_273    *.log    
# 	${paired_ratio}    file match all   ${TEST_LOG_DIRECTORY()}Step6_change_ulMinPrbThreshold_273/@{list_directory}[0]   
# 	...    Current ratio is: (0.\\d+) for check point: {'ULFDSCHEDDATA.ULMUSTATUS': 'MUPAIRED_NO_TAPERING'}
#     Set suite Variable	 ${paired_step6} 	${paired_ratio[0]}
#     #run keyword and continue on failure    should be true    ${paired_step6}<${paired_step5}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_change_ulMinPrbThreshold_273' File
# 
# Step7:Online reduce ulMuMimoPrbThresholdAbsolut to 0
#     Start Collect GNB and AP Syslog in 'Step7_lower_ulMinPrbThreshold' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_lower_ulMinPrbThreshold
#     #Start GNB BIP Log
# 	#check validity of ulMuMimoPrbThresholdAbsolute
# 	##Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8360_change_ulMuMimoPrbThresholdAbsolut_0.json
#     ##Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7_lower_ulMinPrbThreshold${/}
# 
#     VDU Online Change Parameters    ${MO_DN_LIST1}      ${UPDATED_PARAS_DICT_LIST4}
#     VDU Online Change Parameters    ${MO_DN_LIST2}      ${UPDATED_PARAS_DICT_LIST4}
#     Wait '30s' for stabible
# 
#     ${trace_id}     VDU Start TTiTrace Log
#     Wait Throughput Timer    2
#     VDU Stop TTiTrace Log    ${trace_id}
#     VDU Decode TTiTrace Log    csv_dir=${save_log}/tti_abprb0
# 
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step7_lower_ulMinPrbThreshold${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step7_lower_ulMinPrbThreshold${/}tti_abprb0
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case102_tti_pair_step7.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step7_lower_ulMinPrbThreshold
# 	@{list_directory}    List Files In Directory    ${TEST_LOG_DIRECTORY()}Step7_lower_ulMinPrbThreshold    *.log    
# 	${paired_ratio}    file match all   ${TEST_LOG_DIRECTORY()}Step7_lower_ulMinPrbThreshold/@{list_directory}[0]   
# 	...    Current ratio is: (0.\\d+) for check point: {'ULFDSCHEDDATA.ULMUSTATUS': 'MUPAIRED_NO_TAPERING'}
#     Set suite Variable	 ${paired_step7} 	${paired_ratio[0]}
# 	run keyword and continue on failure    should be true    ${paired_step7}<${paired_step6}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_lower_ulMinPrbThreshold' File
