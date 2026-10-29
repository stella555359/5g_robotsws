# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B103_Case29_MU_aware_TD_scheduling_optimization_Deprioritized_Traffic_Check
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
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
# Library          ${CURDIR}/py_check/Check_deprioritizedVoip.py
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_VoNR_9235.xml
# ${AIRPHONE_NAME}     AP_iphy_AEHC_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_VoNR_9235.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_VoNR_9235.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# #common parameters config
# ${srbInactivityTimerSA}                 text|600|//*[@name\="srbInactivityTimerSA"]
# ${drbInactivityTimerSA}                 text|600|//*[@name\="drbInactivityTimerSA"]
# ${chBw}                                 text|100MHz|//*[@name\="chBw"]
# ${nrCellType}                           text|16DL8UL|//*[@name\="nrCellType"]
# ${frameStructureType}                   text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}              text|97|//*[@name\="prachConfigurationIndex"]
# ${dlMimoMode}                           text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${nrofHARQProcessesForPDSCH}            text|16|//*[@name\="nrofHARQProcessesForPDSCH"]
# ${actDl256Qam}                          text|true|//*[@name\="actDl256Qam"]
# #CB008247
# ${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
# ${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
# ${bSRS}                                 text|2|//*[@name\="bSRS"]
# ${cSRS}                                 text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]
# ${actCsirsMultiplexing}                 text|false|//*[@name\="actCsirsMultiplexing"]
# ${nrBtsBeamRefinementP2}                text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${actUeCsirsCoexistCellCsirs}           text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# 
# #CB008305_DLMIMO
# ${actDlMuMimoEnh}                       text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                      text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                       text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                 text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}               text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                    text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                    text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}              text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${maxNumPuschAllocationPerSlot}         text|8|//*[@name\="maxNumPuschAllocationPerSlot"]
# ${maxNumPdschAllocationPerSlot}         text|8|//*[@name\="maxNumPdschAllocationPerSlot"]
# 
# #CB009235
# ${actMuAwareTdSch}                      text|true|//*[@name\="actMuAwareTdSch"]
# ${dlMuAwareCorrThd}                     text|10|//*[@name\="dlMuAwareCorrThd"]
# ${dlMuAwarePrbRatio}                    text|10|//*[@name\="dlMuAwarePrbRatio"]
# ${dlMuPairingPrbRatio}                  text|10|//*[@name\="dlMuPairingPrbRatio"]
# 
# #VONR_5QI-1
# ${actVoNR}                              text|true|//*[@name\="actVoNR"]
# ${actEnhancedVoNR}                      text|true|//*[@name\="actEnhancedVoNR"]
# ${actVoipPacketAggr}                    text|true|//*[@name\="actVoipPacketAggr"]
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=2
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed test_type\=SRS init_quad_pos\=1 init_sub_quad_pos\=0
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed test_type\=SRS init_quad_pos\=1 init_sub_quad_pos\=2
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed test_type\=SRS init_quad_pos\=2 init_sub_quad_pos\=0
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed test_type\=SRS init_quad_pos\=2 init_sub_quad_pos\=2
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed test_type\=SRS init_quad_pos\=3 init_sub_quad_pos\=0
# ...    step\=5 trigger_puxch_update\=0
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed test_type\=SRS init_quad_pos\=3 init_sub_quad_pos\=2
# ...    step\=5 trigger_puxch_update\=0
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# ${SET_PROFILE9}    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE10}    ue_testmode_set_nr id\=10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# ${pattern}               CA_P2_8x4_t2r4_n2
# ${pattern_vonr}          vonr_n78
# 
# 
# 
# *** Test Cases ***
# CB009235_A_B103_Case29_MU_aware_TD_scheduling_optimization_Deprioritized_Traffic_Check
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 9 NonGBR UEs and 1 GBR UE
#     Step3:start DL and UL full buffer nonGBR traffic
# 	Step4:check resReqClassPrio in TTItrace log
# 	Step5:check PM counter value 
# 	Step6:Detach all Ues
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
# 	...    ${nrBtsBeamRefinementP2}     ${actUeCsirsCoexistCellCsirs}
# 	...    ${actDlMuMimoEnh}     ${dlMuMimoCorrThd}     ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}
# 	...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${dlMuMaxNumLayerPerMuRbg}
# 	...    ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
# 	...    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}     ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio}
# 	...    ${actVoNR}    ${actEnhancedVoNR}    ${actVoipPacketAggr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step1_before_onair' file
# 
# Step2:Attach 9 NonGBR UEs and 1 GBR UE
# 	Start capture gnb and ap syslog in 'Step2_attach' file
#     #Start GNB BIP Log 
#     Attach VONR UE and data buffer sent
# 	Attach_Multi_SA_UE_with_fullbuffer_data    9    ${pattern}
# 	set pos for 10ue
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[9]}	
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step2_attach
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti		
#     [Teardown]    run keyword and continue on failure    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:start DL and UL full buffer nonGBR traffic
# 	Start capture gnb and ap syslog in 'Step3_fullbuffer_nonGBR' file
#     Start SA 9UEs DL and UL traffic data		
#     Wait Throughput Timer    20
# 	:FOR    ${ID}    IN RANGE    1    11
# 	\    run keyword and continue on failure    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
# 	\    run keyword and continue on failure    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}   unzip=TRUE	
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    1	
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}tti			
#     [Teardown]    Stop capture gnb and ap syslog in 'Step3_fullbuffer_nonGBR' file
# 
# 
# Step4:check resReqClassPrio in TTItrace log
# #    when VONR UE ue attach,"dlTdSchedSubcellData.resReqClassPrio" value need include 25.
#     ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}tti_dl.csv
# 	${Check_deprioritizedVoip_result}    Check_deprioritizedVoip    ${dl_ttitrace_path}
# 	 log    ${Check_deprioritizedVoip_result}
# 	run keyword and continue on failure    should_be_true    ${Check_deprioritizedVoip_result}	
# 
# 
# Step5:check PM counter value 
# 	Start capture gnb and ap syslog in 'Step5_pm_counter' file
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step5_pm_counter/
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
# 	
#     ${DL_SUCC_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34030    cell_id=1 
#     ${FAIL_BWP_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34031    cell_id=1 
#     ${FAIL_TRAF_TYPE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34032    cell_id=1
#     ${FAIL_SRS_BEAM_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34033    cell_id=1
#     ${FAIL_LOW_CQI_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34034    cell_id=1
#     ${FAIL_LOW_PRB_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34035    cell_id=1
#     ${FAIL_HIGH_CORR_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34036    cell_id=1
#     ${FAIL_SE_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34037    cell_id=1
#     ${FAIL_OTHER_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34038    cell_id=1
# 	
#     [Teardown]    Stop capture gnb and ap syslog in 'Step5_pm_counter' file
# 	
# 
# Step6:Detach all Ues
# 	Start capture gnb and ap syslog in 'Step6_detach' file	
#     run keyword and continue on failure    Detach '10'UE
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step6_detach' file
# 
# 
# set pos for 10ue
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${PROFILE7}
#     airphone_execute_egate_command    ${PROFILE8}	
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
# Start SA 9UEs DL and UL traffic data	
#     :FOR    ${ID}    IN RANGE    1    10
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    50M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    50M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=5    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    50M    trf_id=5    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=6    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    50M    trf_id=6    pdu_id=1    duration=${3600}	
# 
# Attach_Multi_SA_UE_with_fullbuffer_data
#     [Arguments]    ${Num_UE}     ${pattern}	
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
# 	:For    ${ue_id}    IN RANGE     1    ${Num_UE}+1
#     \    Airphone SA Attach    ue_id=${ue_id}    ue_capability=${ue_ability}	
#     \    airphone_set_traffic_type    ue_id=${ue_id}    pdu_id= ${ue_id}    type=internal
#     \    Airphone Pdu Session Setup    ue_id=${ue_id}   pdu_id=${ue_id}   nwslice_id=1   gw_id=${ue_id}
# 	\    Airphone SA Start Data Traffic    ${ue_id}    DL    5M    trf_id=1    pdu_id=${ue_id}    duration=${7200}
# 	\    Airphone SA Start Data Traffic    ${ue_id}    UL    5M    trf_id=1    pdu_id=${ue_id}    duration=${7200}
# 	\    Wait '2s' for stable running	
# 
# 		
# 	
# Attach_VONR_UE_with_send_data
#     [Arguments]    ${Num_UE}     ${pattern}	
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
# 	:For    ${ue_id}    IN RANGE     1    ${Num_UE}+1
#     \    Airphone SA Attach    ue_id=${ue_id}    ue_capability=${ue_ability}	
#     \    airphone_set_traffic_type    ${ue_id}    1    internal
#     \    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
# 	\    airphone_execute_egate_command    ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=2 by\=amf
# 	\    Wait Throughput Timer    2	
# 	\    airphone_execute_egate_command    ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=3 by\=amf
# 	\    Wait Throughput Timer    2
#     \    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp seconds\=3600
# 
# Attach VONR UE and data buffer sent
#     : FOR    ${num}    IN RANGE    10    11
#     \    airphone_cleanup_egate_console_log
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait Throughput Timer    2
#     \    Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \    Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \    Wait Throughput Timer    2
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=2 by\=amf
#     \    Wait Throughput Timer    5
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=3 by\=amf
#     \    Wait Throughput Timer    5
#     \    airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${num} qfi\=3 trf_id\=1 mbps\=10 dir\=dl
#     \    Wait Throughput Timer    5
# 	