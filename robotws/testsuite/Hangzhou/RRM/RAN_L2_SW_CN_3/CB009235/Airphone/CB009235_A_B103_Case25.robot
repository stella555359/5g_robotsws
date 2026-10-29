# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B103_Case25_NumberOfCorrelationCalculation_more_than_NumberOfCorrelationCalculationTotal
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00RAN_5G_TDD    RAN_5G    owner_zhaoxu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library          taf.transport.ssh    WITH NAME    TAF_SSH
# Library          ta_a2a
# Library          ${CURDIR}/py_check/Check_BlockUeListAfterStep1.py
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}     gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_9235.xml
# ${AIRPHONE_NAME}    AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16D8U_9235.xml
# ${WTS_NAME}    wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_16DL8UL_9235.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM}         4
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# 
# #common parameters config
# ${chBw}                                 text|100MHz|//*[@name\="chBw"]
# ${nrCellType}                           text|16DL8UL|//*[@name\="nrCellType"]
# ${frameStructureType}                   text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                    text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}              text|98|//*[@name\="prachConfigurationIndex"]
# ${dlMimoMode}                           text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${actFdmScheduling}                     text|true|//*[@name\="actFdmScheduling"]
# ${msg1FrequencyStart}                   text|0|//*[@name\="msg1FrequencyStart"]
# ${nrofHARQProcessesForPDSCH}            text|16|//*[@name\="nrofHARQProcessesForPDSCH"]
# #CB008247
# ${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
# ${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
# ${bSRS}                                 text|2|//*[@name\="bSRS"]
# ${cSRS}                                 text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]
# 
# #CB007113
# ${actBbPoolTddFr1}                      text|true|//*[@name\="actBbPoolTddFr1"]
# ${actShortBsrLimitAdaptation}           text|true|//*[@name\="actShortBsrLimitAdaptation"]
# ${allowSlowPrbPoolingStatNdmSrs}        text|true|//*[@name\="allowSlowPrbPoolingStatNdmSrs"]
# 
# #CB008305_DLMIMO
# ${actDlMuMimoEnh}                       text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                      text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                       text|10|//*[@name\="dlMuMimoCqiThd"]
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
# #bwp
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${rdNumberOfCorrCalcUe}    0x19
# ${rdNumberOfCorrCalTotal}    0x02
# 
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=58 zenith\=22 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-18 zenith\=22 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-58 zenith\=-2 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-2 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
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
# ${SET_PROFILE9}    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE10}    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# 
# 
# *** Test Cases ***
# CB009235_A_B103_Case25_NumberOfCorrelationCalculation_more_than_NumberOfCorrelationCalculationTotal
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 10 MU_MIMO UEs in cell1 
#     Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
#     Step4:check log in TTITrace
#     Step5:check PM counter value 
# 	#Step6:Detach all Ues
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB009235    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}    ${rdNumberOfCorrCalcUe}    ${rdNumberOfCorrCalTotal}            
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${chBw}    ${nrCellType}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
#     ...    ${prachConfigurationIndex}    ${dlMimoMode}    ${actFdmScheduling}    ${msg1FrequencyStart}
# 	...    ${nrofHARQProcessesForPDSCH}
#     ...    ${actDlSrsBm}    ${actBeamforming}    ${bSRS}    ${cSRS}    ${srsUePeriodicity}
#     ...    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
#     ...    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}     ${dlMuMimoRankAdaption}
#     ...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV} 
#     ...    ${dlMuMaxNumLayerPerMuRbg}     ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot} 
#     ...    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio} 	
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 10 MU_MIMO UEs in cell1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Set UEs Pos	
#     Attach SA ue with capability to 5g cell    10    ${pattern}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     Wait Throughput Timer    3
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:UE1-UE10 start DL and UL full buffer nonGBR traffic
#     Start Collect GNB and AP Syslog in 'Step3_fullbuffer_nonGBR' File
#     :FOR    ${ID}    IN RANGE    1    11
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=5    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=5    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    DL    150M    trf_id=6    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${ID}    UL    150M    trf_id=6    pdu_id=1    duration=${3600}		
#     Wait Throughput Timer    20
# 	:FOR    ${ID}    IN RANGE    1    11
# 	\    ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
# 	\    ${ul_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pusch    tput_type=ave
# 	
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}   unzip=TRUE	
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    2	
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}tti			
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_fullbuffer_nonGBR' File
# 
# Step4:check log in TTITrace
# 	#rdNumberOfCorrCalTotal set value is 2,so dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1 UE list less than 3.
#     ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_fullbuffer_nonGBR${/}tti_dl.csv
# 	${Block_list_check_result}    CheckBlockUeListAfterStep1    ${dl_ttitrace_path}
# 	log    ${Block_list_check result}
# 	run keyword and continue on failure    should_be_true    ${Block_list_check_result}
# 
# 
# Step5:check PM counter value
#     Start Collect GNB and AP Syslog in 'Step5_pm_counter' File
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
#     ${DL_MIMO_PAIR_DL_SUCC}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34030    cell_id=1
# 	run keyword and continue on failure    should_be_true    ${DL_MIMO_PAIR_DL_SUCC}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_pm_counter' File
# 
# 
# Step6:Detach all Ues
#     Start Collect GNB and AP Syslog in 'Step6_detach' File
#     Detach '10'UE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_detach' File
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE7}
#     airphone_execute_egate_command    ${SET_PROFILE8}
#     airphone_execute_egate_command    ${SET_PROFILE9}
#     airphone_execute_egate_command    ${SET_PROFILE10}	