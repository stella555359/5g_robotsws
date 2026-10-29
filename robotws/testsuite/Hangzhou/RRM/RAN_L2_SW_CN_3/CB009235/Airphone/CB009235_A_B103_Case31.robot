# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B103_Case31_Set_UE_block_reason_for_CorrealtionCheck_fail_and_non-MU_UE
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library          ${CURDIR}/py_check/Check_cs2BlockUeList.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1C_8D4U_f1116_0_9235.xml
# ${AIRPHONE_NAME}      AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_8_4_9235.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8DL4UL_9235.cfg
# #${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# #common parameters config
# ${srbInactivityTimerSA}                 text|600|//*[@name\="srbInactivityTimerSA"]
# ${drbInactivityTimerSA}                 text|600|//*[@name\="drbInactivityTimerSA"]
# ${chBw}                                 text|100MHz|//*[@name\="chBw"]
# ${nrCellType}                           text|8DL4UL|//*[@name\="nrCellType"]
# ${frameStructureType}                   text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}              text|97|//*[@name\="prachConfigurationIndex"]
# ${dlMimoMode}                           text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${nrofHARQProcessesForPDSCH}            text|16|//*[@name\="nrofHARQProcessesForPDSCH"]
# ${actDl256Qam}                          text|false|//*[@name\="actDl256Qam"]
# #CB008247
# ${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
# ${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
# ${bSRS}                                 text|2|//*[@name\="bSRS"]
# ${cSRS}                                 text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]
# ${actCsirsMultiplexing}                 text|true|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${actUeCsirsCoexistCellCsirs}           text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# 
# 
# #CB007113 pooling
# ${actBbPoolTddFr1}                      text|true|//*[@name\="actBbPoolTddFr1"]
# ${actShortBsrLimitAdaptation}           text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${allowSlowPrbPoolingStatNdmSrs}        text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# ${actLargeBbPoolTddFr1}                 text|true|//*[@name\="actLargeBbPoolTddFr1"]
# 
# #CB008305_DLMIMO
# ${actDlMuMimoEnh}                       text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                      text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                       text|10|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                 text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}               text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                    text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                    text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}              text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${maxNumPuschAllocationPerSlot}         text|8|//*[@name\="maxNumPuschAllocationPerSlot"]
# ${maxNumPdschAllocationPerSlot}         text|8|//*[@name\="maxNumPdschAllocationPerSlot"]
# 
# #CB009235
# ${actMuAwareTdSch}                      text|true|//*[@name\="actMuAwareTdSch"]
# ${dlMuAwareCorrThd}                     text|10|//*[@name\="dlMuAwareCorrThd"]
# ${dlMuAwarePrbRatio}                    text|50|//*[@name\="dlMuAwarePrbRatio"]
# ${dlMuPairingPrbRatio}                  text|50|//*[@name\="dlMuPairingPrbRatio"]
# 
# #change CQI
# ${dllaDeltaCqiMax}                      text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                      text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                 text|0|//*[@name\="dllaDeltaCqiStepdown"]
# 
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=53 zenith\=20 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-20 srs_transmit_power_per_port\=-450,-450,-280,-280
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-53 zenith\=20 srs_transmit_power_per_port\=-450,-450,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-18 zenith\=-20 srs_transmit_power_per_port\=-450,-450,-280,-280
# 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# 
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# 
# *** Test Cases ***
# CB009235_A_B103_Case31_Set_UE_block_reason_for_CorrealtionCheck_fail_and_non-MU_UE
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 10 NonGBR UEs
#     Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
# 	Step4:change UE9 and UE10 CQI less than dlMuMimoCqiTh to make UE9_10 non_Mu Eligible
# 	Step5:check block in cs2BlockUeList
# 	Step6:check PM counter value 
# 	#Step7:Detach all Ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
# 	Start capture gnb and ap syslog in 'Step1_before_onair' file
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB009235    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
# 	...    ${srbInactivityTimerSA}    ${drbInactivityTimerSA}
#     ...    ${chBw}    ${nrCellType}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
#     ...    ${prachConfigurationIndex}     ${dlMimoMode}    ${ulDlDataSlotRatio}    ${nrofHARQProcessesForPDSCH}    ${actDl256Qam}
#     ...    ${actDlSrsBm}	  ${actBeamforming}    ${bSRS}     ${cSRS}    ${srsUePeriodicity}     ${actCsirsMultiplexing}
# 	...    ${nrBtsBeamRefinementP2}    ${actUeCsirsCoexistCellCsirs}
# 	...    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
# 	...    ${actLargeBbPoolTddFr1}
# 	...    ${actDlMuMimoEnh}     ${dlMuMimoCorrThd}     ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}
# 	...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${dlMuMaxNumLayerPerMuRbg}
# 	...    ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
# 	...    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}     ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio}
# 	...    ${dllaDeltaCqiMax}     ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}      
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step1_before_onair' file
# 
# Step2:Attach 10 NonGBR UEs
# 	Start capture gnb and ap syslog in 'Step2_attach' file
#     #Start GNB BIP Log    
#     Attach SA ue with capability to 5g cell    10    ${pattern}
# 	Set UEs Pos
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
#     Set test Variable     ${rnti_4}     ${rnti_list[3]}
#     Set test Variable     ${rnti_5}     ${rnti_list[4]}
#     Set test Variable     ${rnti_6}     ${rnti_list[5]}
#     Set test Variable     ${rnti_7}     ${rnti_list[6]}
#     Set test Variable     ${rnti_8}     ${rnti_list[7]}
#     Set test Variable     ${rnti_9}     ${rnti_list[8]}
#     Set test Variable     ${rnti_10}     ${rnti_list[9]}	
#     [Teardown]    run keyword and continue on failure    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
# 	Start capture gnb and ap syslog in 'Step3_fullbuffer_nonGBR' file
#     :FOR    ${ID}    IN RANGE    1    11
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    100M    trf_id=3    pdu_id=1    duration=${3600}		
#     Wait Throughput Timer    20
# 	:FOR    ${ID}    IN RANGE    1    11
# 	\    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
# 	\    ${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave
# 	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}   unzip=TRUE	
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    1	
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}tti			
#     [Teardown]    Stop capture gnb and ap syslog in 'Step3_fullbuffer_nonGBR' file
# 
# 
# Step4:change UE9 and UE10 CQI less than dlMuMimoCqiTh to make UE9_10 non_Mu Eligible
# 	Start capture gnb and ap syslog in 'step4_change_non_Mu_Eligible' file
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=6 cqi\=2 cqi_mode\=fixed
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=9 testmode\=csi_override action\=activate profile_id\=6
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=10 testmode\=csi_override action\=activate profile_id\=6
#     Wait Throughput Timer    20
# 	:FOR    ${ID}    IN RANGE    1    11
# 	\    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
# 	\    ${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}step4_change_non_Mu_Eligible${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}step4_change_non_Mu_Eligible${/}tti	 
#     [Teardown]    Stop capture gnb and ap syslog in 'step4_change_non_Mu_Eligible' file
# 
# 
# Step5:check block in cs2BlockUeList
# 	#Adding new block reason CS2_CORRCHECKBLOCK and CS2_NONMUELIGIBLEBLOCK in dlPreTdBlockUeData.cs2BlockUeList
# 	#when UEs have been scheduled and dlFdSchedData.numOfPrb has value ,cs2BlockUeList need remove Uelist
#     ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}step4_change_non_Mu_Eligible${/}tti_dl.csv
# 	${cs2BlockUeList_check_result}    Checkcs2BlockUeList    ${dl_ttitrace_path}
# 	log    ${cs2BlockUeList_check_result}
# 	run keyword and continue on failure    should_be_true    ${cs2BlockUeList_check_result}
# 
# Step6:check PM counter value 
# 	Start capture gnb and ap syslog in 'Step6_pm_counter' file
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step6_pm_counter/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}   
# 	...    counter_id=M55308C34019    cell_id=1
#     ${PPRB_DL_MU_MIMO_10LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34017    cell_id=1
#     ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=1	
#     ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=1
#     ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=1	
#     ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=1	
#     ${SU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=1	
#     ${SU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=1
#     ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=1	
#     ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=1	
#     ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=1	
#     ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=1
#     ${DL_cell_throughput_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55309C12001    cell_id=1	
# 	
#     ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=1 		
#     [Teardown]    Stop capture gnb and ap syslog in 'Step6_pm_counter' file
# 
# Step7:Detach all Ues
# 	Start capture gnb and ap syslog in 'Step7_detach' file	
#     run keyword and continue on failure    Detach '10'UE
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step7_detach' file
# 
# 
# 
# 
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}		
#     airphone_execute_egate_command    ${SET_PROFILE1}	
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE9}
#     airphone_execute_egate_command    ${SET_PROFILE10}
# 	
# 	
# Online change dlMuMimoCorrThd '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwareCorrThd
#     ...    operation=update    value=${value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online\
# 	Wait Throughput Timer    30		
