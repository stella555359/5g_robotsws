# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com...
# ...               QC case full name:
# ...               CB009235_A_B103_Case26_performance test_for_16UEsPerSlot_when_rdNumberOfCorrelationCalculation_default_value
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00RAN_5G_TDD    RAN_5G    owner_zhaoxu
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1C_8D4U_f1208_9235.xml
# ${AIRPHONE_NAME}      AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_9235.xml
# ${WTS_NAME}           wts_200ue_2S_AEHC_16D8U_TM4.cfg
# 
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# #common parameters config
# ${srbInactivityTimerSA}                 text|600|//*[@name\="srbInactivityTimerSA"]
# ${drbInactivityTimerSA}                 text|600|//*[@name\="drbInactivityTimerSA"]
# ${chBw}                                 text|100MHz|//*[@name\="chBw"]
# ${nrCellType}                           text|8DL4UL|//*[@name\="nrCellType"]
# ${frameStructureType}                   text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                    text|2Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}                    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}              text|98|//*[@name\="prachConfigurationIndex"]
# ${dlMimoMode}                           text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulDlDataSlotRatio}                    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${nrofHARQProcessesForPDSCH}            text|16|//*[@name\="nrofHARQProcessesForPDSCH"]
# #CB008247
# ${actDlSrsBm}                           text|true|//*[@name\="actDlSrsBm"]
# ${actBeamforming}                       text|true|//*[@name\="actBeamforming"]
# ${bSRS}                                 text|2|//*[@name\="bSRS"]
# ${cSRS}                                 text|63|//*[@name\="cSRS"]
# ${srsUePeriodicity}                     text|slots40|//*[@name\="srsUePeriodicity"]
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
# ${actMuAwareTdSch}                      text|false|//*[@name\="actMuAwareTdSch"]
# ${dlMuAwareCorrThd}                     text|20|//*[@name\="dlMuAwareCorrThd"]
# ${dlMuAwarePrbRatio}                    text|100|//*[@name\="dlMuAwarePrbRatio"]
# ${dlMuPairingPrbRatio}                  text|100|//*[@name\="dlMuPairingPrbRatio"]
# 
# ${pattern}     CA_P2_8x4_t2r4_n2
# 
# #${PROFILE1}    
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-55 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-55 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=55 zenith\=20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=55 zenith\=-20 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# ${PROFILE21}    ul_mimo_srs_beam_pos_nr profile_id\=21 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port=-450,-450,-280,-280
# 
# 
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# 
# 
# *** Test Cases ***
# CB009235_A_B103_Case27_performance_test_for_8UEsPerSlot_when_rdNumberOfCorrelationCalculation_maximum_value
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 100 sa ue with rank1 and check
#     Step3:check counter
# 	Step4:Online change actMuAwareTdSch to true
# 	Step5:check counter again
# 	#Step6:Detach ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB009235    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
# 	...    ${srbInactivityTimerSA}    ${drbInactivityTimerSA}
#     ...    ${chBw}    ${nrCellType}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${prachConfigurationIndex}     ${dlMimoMode}    ${ulDlDataSlotRatio}    ${nrofHARQProcessesForPDSCH}
#     ...    ${actDlSrsBm}	  ${actBeamforming}    ${bSRS}     ${cSRS}    ${srsUePeriodicity}
# 	...    ${actBbPoolTddFr1}    ${actShortBsrLimitAdaptation}    ${allowSlowPrbPoolingStatNdmSrs}
# 	...    ${actLargeBbPoolTddFr1}
# 	...    ${actDlMuMimoEnh}     ${dlMuMimoCorrThd}     ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}
# 	...    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${dlMuMaxNumLayerPerMuRbg}
# 	...    ${maxNumPuschAllocationPerSlot}    ${maxNumPdschAllocationPerSlot}
# 	...    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}     ${dlMuAwarePrbRatio}     ${dlMuPairingPrbRatio}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 100 sa ue with rank1 and check
#     Start capture gnb and ap syslog in 'Step2_attach' file
# 	Attach_Multi_SA_UE_and_send_low_traffic    60    ${pattern}
# 	Attach_Multi_SA_UE_and_send_Medium_Traffic    30    ${pattern}
# 	Attach_Multi_SA_UE_with_fullbuffer_data    10    ${pattern}
#     set pos for 100ue
#     ues send dl data
#     Wait Throughput Timer    10
#     get dl thp by egate
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE	
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    1	
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach	
#     Start GNB Ttitrace With Streaming Mode
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
#     [Teardown]    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:check counter
#     Start capture gnb and ap syslog in 'Step3_pm_counter' file
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step3_pm_counter${/}
#     Set Suite Variable    ${PM_counter_file}
#     ${MU_MIMO_16layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=1	
#     ${MU_MIMO_15layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34022    cell_id=1	
#     ${MU_MIMO_14layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34021    cell_id=1	
#     ${MU_MIMO_13layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34020    cell_id=1	
#     ${MU_MIMO_12layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34019    cell_id=1		
#     ${MU_MIMO_11layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34018    cell_id=1	
#     ${MU_MIMO_10layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34017    cell_id=1	
#     ${MU_MIMO_9layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34016    cell_id=1	
# 	
#     ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=1	
#     ${MU_MIMO_7layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34010    cell_id=1		
#     ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=1
#     ${MU_MIMO_5layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34008    cell_id=1	
#     ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=1
#     ${MU_MIMO_3layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34006    cell_id=1	
#     ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=1	
#     ${SU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=1	
#     ${SU_MIMO_3layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34003    cell_id=1		
#     ${SU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=1
#     ${SU_MIMO_1layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34001    cell_id=1		
#     ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=1	
#     ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=1	
#     ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=1	
#     ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=1
#     ${MU_MIMO_5PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34024    cell_id=1	
#     ${MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34025    cell_id=1
#     ${MU_MIMO_7PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34026    cell_id=1	
#     ${MU_MIMO_8PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34027    cell_id=1
# 	
#     ${DL_cell_throughput_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55309C12001    cell_id=1	
# 	${DL_throughput_false}    evaluate    ${DL_cell_throughput_counter}*8/1024/1024
#     ${UEs_on_PDSCH_per_slot}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C17001    cell_id=1
#     ${TRS_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00017    cell_id=1
#     ${SS_Burst_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00015    cell_id=1
#     ${Data_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00005    cell_id=1	
# 	${MU_MIMO_PAIR_UE}    evaluate    ${MU_MIMO_2PAIR_UE}+${MU_MIMO_3PAIR_UE}+${MU_MIMO_4PAIR_UE}+${MU_MIMO_5PAIR_UE}+${MU_MIMO_6PAIR_UE}
# 	${MU_MIMO_All_UE}    evaluate    ${MU_MIMO_NOPAIR_UE}+${MU_MIMO_PAIR_UE}
# 	${MU_MIMO_Pairing_Ratio_false}    evaluate    ${MU_MIMO_PAIR_UE}/${MU_MIMO_All_UE}
# 	Set Suite Variable    ${MU_MIMO_Pairing_Ratio_false}	
# 	${MU_MIMO_Pairing_Ratio_false}    evaluate    ${MU_MIMO_PAIR_UE}/${MU_MIMO_All_UE}
# 	${UE_per_slot}    evaluate     ${UEs_on_PDSCH_per_slot}/${Data_slot_with_PDSCH}
# 		
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step3_pm_counter' file
# 
# 
# Step4:Online change actMuAwareTdSch to true
#     Start capture gnb and ap syslog in 'Step4_onlinechange' file
#     Online change actMuAwareTdSch 'true'	
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step4_onlinechange' file
# 
# Step5:check counter again
#     Start capture gnb and ap syslog in 'Step5_check_pm_counter_again' file
#     get dl thp by egate
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5_check_pm_counter_again${/}   unzip=TRUE	
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step5_check_pm_counter_again	
#     Start GNB Ttitrace With Streaming Mode
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	#Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step5_check_pm_counter_again${/}
#     Set Suite Variable    ${PM_counter_file}	
#     ${MU_MIMO_16layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34023    cell_id=1	
#     ${MU_MIMO_15layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34022    cell_id=1	
#     ${MU_MIMO_14layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34021    cell_id=1	
#     ${MU_MIMO_13layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34020    cell_id=1	
#     ${MU_MIMO_12layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34019    cell_id=1		
#     ${MU_MIMO_11layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34018    cell_id=1	
#     ${MU_MIMO_10layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34017    cell_id=1	
#     ${MU_MIMO_9layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34016    cell_id=1	
# 
#     ${MU_MIMO_8layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34011    cell_id=1	
#     ${MU_MIMO_7layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...    counter_id=M55308C34010    cell_id=1		
#     ${MU_MIMO_6layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34009    cell_id=1
#     ${MU_MIMO_5layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34008    cell_id=1	
#     ${MU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34007    cell_id=1
#     ${MU_MIMO_3layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34006    cell_id=1	
#     ${MU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34005    cell_id=1	
#     ${SU_MIMO_4layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34004    cell_id=1	
#     ${SU_MIMO_3layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34003    cell_id=1		
#     ${SU_MIMO_2layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34002    cell_id=1
#     ${SU_MIMO_1layer}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34001    cell_id=1		
#     ${MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34012    cell_id=1	
#     ${MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34013    cell_id=1	
#     ${MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34014    cell_id=1	
#     ${MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34015    cell_id=1	
#     ${MU_MIMO_5PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34024    cell_id=1	
#     ${MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34025    cell_id=1
#     ${MU_MIMO_7PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34026    cell_id=1	
#     ${MU_MIMO_8PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C34027    cell_id=1	
# 	
#     ${DL_cell_throughput_counter}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55309C12001    cell_id=1	
# 	${DL_throughput_True}    evaluate    ${DL_cell_throughput_counter}*8/1024/1024
#     ${UEs_on_PDSCH_per_slot}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C17001    cell_id=1
#     ${TRS_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00017    cell_id=1
#     ${SS_Burst_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00015    cell_id=1
#     ${Data_slot_with_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
# 	...   counter_id=M55308C00005    cell_id=1	
# 	${MU_MIMO_PAIR_UE}    evaluate    ${MU_MIMO_2PAIR_UE}+${MU_MIMO_3PAIR_UE}+${MU_MIMO_4PAIR_UE}+${MU_MIMO_5PAIR_UE}+${MU_MIMO_6PAIR_UE}
# 	${MU_MIMO_All_UE}    evaluate    ${MU_MIMO_NOPAIR_UE}+${MU_MIMO_PAIR_UE}
# 	${MU_MIMO_Pairing_Ratio_True}    evaluate    ${MU_MIMO_PAIR_UE}/${MU_MIMO_All_UE}
# 	Set Suite Variable    ${MU_MIMO_Pairing_Ratio_true}		
# 	${UE_per_slot_True}    evaluate     ${UEs_on_PDSCH_per_slot}/${Data_slot_with_PDSCH}	
# 	[Teardown]    Stop capture gnb and ap syslog in 'Step5_check_pm_counter_again' file
# 
# 
# Step6:Detach ues
#     Detach '100'UE
# 
# 
# set pos for 100ue
#     Airphone Execute Egate Command    ${PROFILE1} 
# 	Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${PROFILE3} 
# 	Airphone Execute Egate Command    ${PROFILE4}	
#     Airphone Execute Egate Command    ${PROFILE5} 
# 	Airphone Execute Egate Command    ${PROFILE6}	
#     Airphone Execute Egate Command    ${PROFILE7} 
# 	Airphone Execute Egate Command    ${PROFILE8}
#     Airphone Execute Egate Command    ${PROFILE9} 
# 	Airphone Execute Egate Command    ${PROFILE10}
# 	Airphone Execute Egate Command    ${PROFILE11}
#     Airphone Execute Egate Command    ${PROFILE12}
# 	Airphone Execute Egate Command    ${PROFILE13}
#     Airphone Execute Egate Command    ${PROFILE14}
# 	Airphone Execute Egate Command    ${PROFILE15}
#     Airphone Execute Egate Command    ${PROFILE16}	
# 	Airphone Execute Egate Command    ${PROFILE17}
#     Airphone Execute Egate Command    ${PROFILE18}
#     Airphone Execute Egate Command    ${PROFILE19}	
# 	Airphone Execute Egate Command    ${PROFILE20}
# 	
#     :For    ${ue_id}    IN RANGE     1    4
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     :For    ${ue_id}    IN RANGE     4    7
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     :For    ${ue_id}    IN RANGE     7    10
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     :For    ${ue_id}    IN RANGE     10    13
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     :For    ${ue_id}    IN RANGE     13    16
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5	
#     :For    ${ue_id}    IN RANGE     16    19
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
#     :For    ${ue_id}    IN RANGE     19    22  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7	
#     :For    ${ue_id}    IN RANGE     22    25  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
#     :For    ${ue_id}    IN RANGE     25    28  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9	
#     :For    ${ue_id}    IN RANGE     28    31  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
#     :For    ${ue_id}    IN RANGE     31    34
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
#     :For    ${ue_id}    IN RANGE     34    37
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12	
#     :For    ${ue_id}    IN RANGE     37    40
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
#     :For    ${ue_id}    IN RANGE     40    43  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14	
#     :For    ${ue_id}    IN RANGE     43    46  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
#     :For    ${ue_id}    IN RANGE     46    49  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16	
#     :For    ${ue_id}    IN RANGE     49    52  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=17
#     :For    ${ue_id}    IN RANGE     52    55
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=18
#     :For    ${ue_id}    IN RANGE     55    58  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=19	
#     :For    ${ue_id}    IN RANGE     58    61  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=20
# 
# 
#     :For    ${ue_id}    IN RANGE     61    63
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5	
#     :For    ${ue_id}    IN RANGE     63    65
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
#     :For    ${ue_id}    IN RANGE     65    68  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7	
#     :For    ${ue_id}    IN RANGE     68    70  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
#     :For    ${ue_id}    IN RANGE     70    72  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9	
#     :For    ${ue_id}    IN RANGE     72    74  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
#     :For    ${ue_id}    IN RANGE     74    76
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
#     :For    ${ue_id}    IN RANGE     76    78
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12	
#     :For    ${ue_id}    IN RANGE     78    80
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
#     :For    ${ue_id}    IN RANGE     80    84  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14	
#     :For    ${ue_id}    IN RANGE     84    87  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
#     :For    ${ue_id}    IN RANGE     87    91  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16
# 
#     :For    ${ue_id}    IN RANGE     91    92  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9	
#     :For    ${ue_id}    IN RANGE     92    93  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10
#     :For    ${ue_id}    IN RANGE     93    94
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=11
#     :For    ${ue_id}    IN RANGE     94    95
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=12	
#     :For    ${ue_id}    IN RANGE     95    96
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=13
#     :For    ${ue_id}    IN RANGE     96    97  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=14	
#     :For    ${ue_id}    IN RANGE     97    98  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=15
#     :For    ${ue_id}    IN RANGE     98    99  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16	
#     :For    ${ue_id}    IN RANGE     99    100  
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=17
#     :For    ${ue_id}    IN RANGE     100    101
#     \     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=18
# 
#     #:For    ${ue_id}    IN RANGE     1    101 
#     #\    ${profile_id}    Evaluate    random.randint(1,20)    random
#     #\    Airphone Execute Egate Command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate 
#    ...    profile_id\=${profile_id}
# 
# 
# 
# 	
# ues send dl data
#     :FOR    ${u}    IN RANGE     91    101
#      \    Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=2    pdu_id=1    duration=${7200}
# 	 \    Airphone SA Start Data Traffic    ${u}    DL    150M    trf_id=2    pdu_id=1    duration=${7200}
#      \    Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=3    pdu_id=1    duration=${7200}
# 	 \    Airphone SA Start Data Traffic    ${u}    DL    150M    trf_id=3    pdu_id=1    duration=${7200}
#      \    Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=4    pdu_id=1    duration=${7200}
# 	 \    Airphone SA Start Data Traffic    ${u}    DL    150M    trf_id=4    pdu_id=1    duration=${7200}
#      \    Airphone SA Start Data Traffic    ${u}    UL    100M    trf_id=5    pdu_id=1    duration=${7200}
# 	 \    Airphone SA Start Data Traffic    ${u}    DL    150M    trf_id=5    pdu_id=1    duration=${7200}	 
# 	 \    Wait Throughput Timer    1   
# 
# get dl thp by egate
#     :FOR    ${u}    IN RANGE     1    101
#     \     run keyword and continue on failure   Airphone Get Throughput On Specific Scell    ${u}    0    pdsch    ave
# 
# 
# Online change actMuAwareTdSch '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=actMuAwareTdSch
#     ...    operation=update    value=${value}    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online\
# 	Wait Throughput Timer    180	
# 
# 
# Attach_Multi_SA_UE_and_send_low_traffic
#     [Arguments]    ${Num_UE}     ${pattern}	
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
# 	:For    ${ue_id}    IN RANGE     1    ${Num_UE}+1
#     \    Airphone SA Attach    ue_id=${ue_id}    ue_capability=${ue_ability}	
#     \    airphone_set_traffic_type    ${ue_id}    1    internal
#     \    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
# 	\    Airphone Execute Egate Command    trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 period_ms\=500 burst\=50 protocol\=tcp size\=500
# 	\    Wait '2s' for stable running
# 	
# 	
# Attach_Multi_SA_UE_and_send_Medium_Traffic
#     [Arguments]    ${Num_UE}     ${pattern}	
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
# 	:For    ${ue_id}    IN RANGE     61    ${Num_UE}+61
#     \    Airphone SA Attach    ue_id=${ue_id}    ue_capability=${ue_ability}	
#     \    airphone_set_traffic_type    ${ue_id}    1    internal
#     \    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
# 	\    Airphone Execute Egate Command    trf_data_start ue\=${ue_id} pdu\=1 dir\=dl trf_id\=1 period_ms\=30 burst\=50 protocol\=tcp size\=500
# 	\    Wait '2s' for stable running	
# 	
# Attach_Multi_SA_UE_with_fullbuffer_data
#     [Arguments]    ${Num_UE}     ${pattern}	
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
# 	:For    ${ue_id}    IN RANGE     91    ${Num_UE}+91
#     \    Airphone SA Attach    ue_id=${ue_id}    ue_capability=${ue_ability}	
#     \    airphone_set_traffic_type    ${ue_id}    1    internal
#     \    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
# 	\    Airphone SA Start Data Traffic    ${ue_id}    DL    1M    trf_id=1    pdu_id=1    duration=${7200}
# 	\    Airphone SA Start Data Traffic    ${ue_id}    UL    1M    trf_id=1    pdu_id=1    duration=${7200}
# 	\    Wait '2s' for stable running	
