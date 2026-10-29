# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008701_A_B201_02_case202_6UEs_rank_4_4_2_2_2_2_with_nonGBR_paired_with_dlMuMimoRankAdaption_online_change
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIB_ABIO_AQQL_TDD_eCPRI_cmwv_SANSA_1CC.xml
# ${WTS_NAME}          wts_config_AQQL_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM}         6
# ${PDU_ID}         1
# ${SLICE_ID}       1
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|16DL8UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# #dlmumimo
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                                   text|99|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                                  text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                             text|disabled|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                            text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                 text|30dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}                     text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${actDl256Qam}                              text|false|//*[@name\="actDl256Qam"]
# #1208
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# #bwp
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# 
# *** Test Cases ***
# CB008701_A_B201_02_case202_6UEs_rank_4_4_2_2_2_2_with_nonGBR_paired_with_dlMuMimoRankAdaption_online_change
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 6UEs_4_4_2_2_2_2
#     Step3:push buffer
#     Step4:layer and paired_ratio check
#     Step5:Online change dlMuMimoRankAdaption to always
#     Step6:Online change dlMuMimoRankAdaption to adaptive
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
# 
#     Set Pos By Modify L1ByPTestModeConfiguration    15    8    6    0    6    0    6    0    0    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    12    7    6    0    6    0    6    0    1    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    21    8    6    0    6    0    6    0    2    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    6    7    6    0    6    0    6    0    3    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    2    8    6    0    6    0    6    0    4    ComaMultiplier=29
#     Set Pos By Modify L1ByPTestModeConfiguration    25    7    6    0    6    0    6    0    5    ComaMultiplier=29
# 
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	#del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${msg1FrequencyStart}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${bwp_profile5}    ${bwp_profile57}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${actDl256Qam}    ${dlMuMaxNumLayerPerMuRbg}    ${nrBtsBeamRefinementP2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 6UEs_4_4_2_2_2_2
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	#Start GNB BIP Log
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${UE_ID}    SetVariable    ${ID}
#     ${GW_ID}    SetVariable    ${ID}
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     END
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
# ##    #airphone_execute_egate_command    ue_testmode_set_nr id\=${ID} testmode\=csi_override action\=activate profile_id\=1
# #    #Airphone Csi Override Testmode Nr    profile_id=1    cqi=15    ri=1    cri=1    li=1    pmi=500
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=csi_override action\=activate profile_id\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=csi_override action\=activate profile_id\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=5 testmode\=csi_override action\=activate profile_id\=1
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=6 testmode\=csi_override action\=activate profile_id\=1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_list[5]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:push buffer
#     Start Collect GNB and AP Syslog in 'Step3_push_buffer' File
#     #Start GNB BIP Log
#     FOR    ${ID}    IN RANGE    1    4
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    175M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    100M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    100M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    5    DL    100M    trf_id=${ID}    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    6    DL    100M    trf_id=${ID}    pdu_id=1    duration=${3600}
#     END
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_push_buffer' File
# 
# Step4:Layer and paired_ratio check
#     Start Collect GNB and AP Syslog in 'step4_disable_layer_paired_check' File
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
# 	${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step4_disable_layer_paired_check/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}step4_disable_layer_paired_check${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}step4_disable_layer_paired_check${/}tti
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case202_tti_pair_disable.ini
#     ...       log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}step4_disable_layer_paired_check${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_disable_layer_paired_check' File
# 
# Step5:Online change dlMuMimoRankAdaption to always
#     Start Collect GNB and AP Syslog in 'Step5_change_dlMuMimoRankAdaption_always' File
#     #Start GNB BIP Log
# 	Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8701_change_dlMuMimoRankAdaption_always.json
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5_change_dlMuMimoRankAdaption_always${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    120
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_change_dlMuMimoRankAdaption_always/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_12LAYER} >0
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_change_dlMuMimoRankAdaption_always
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_change_dlMuMimoRankAdaption_always/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case202_tti_pair_always.ini    
# 	...    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step5_change_dlMuMimoRankAdaption_always${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_change_dlMuMimoRankAdaption_always' File
# 
# 
# Step6:Online change dlMuMimoRankAdaption to adaptive
#     Start Collect GNB and AP Syslog in 'Step6_change_dlMuMimoRankAdaption_adaptive' File
#     #Start GNB BIP Log
# 	Online recommissioning with delta json file    ${CURDIR}/JSON/delta_8701_change_dlMuMimoRankAdaption_adaptive.json
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6_change_dlMuMimoRankAdaption_adaptive${/}
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=ave
#     END
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step6_change_dlMuMimoRankAdaption_adaptive/
#     ${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    cell_id=1
#     ${PPRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34019    cell_id=1
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} ==0
#     run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_12LAYER} >0
# 
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_change_dlMuMimoRankAdaption_adaptive
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_change_dlMuMimoRankAdaption_adaptive/tti
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case202_tti_pair_adaptive.ini    
# 	...    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step6_change_dlMuMimoRankAdaption_adaptive${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6_change_dlMuMimoRankAdaption_adaptive' File
# 
# 
