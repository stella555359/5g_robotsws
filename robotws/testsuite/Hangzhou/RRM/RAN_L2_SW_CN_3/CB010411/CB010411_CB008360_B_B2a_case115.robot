# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008360_A_B1a_case_102_2 Rank1 UEs blindly paired online change ulMinPrbThreshold
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    
# Test Timeout      90 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# #Resource          ../resources/sg11/internal_resource/robot/internal_aic.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_8360_8D8U.xml
# ${CU_SCF}             scfc_VCU_8360_8D4U.xml
# ${AIRPHONE_NAME}      iphy_8360_8D4U.xml
# ${WTS_NAME}           basic_setup_8360.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${ulMuMimoTaperingH}                            text|20dB|//*[@name\="ulMuMimoTaperingH"]
# ${ulMuMimoTaperingV}                            text|25dB|//*[@name\="ulMuMimoTaperingV"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${prbThreshRangeOne}                            text|50|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}                            text|50|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}                          text|50|//*[@name\="prbThreshRangeThree"]
# ${ullaDeltaSinrMax}                             text|5|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|-5|//*[@name\="ullaDeltaSinrMin"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${cSRS}                                         text|51|//*[@name\="cSRS"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|50|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${tiltOffset}                                   text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
# ${msg1FrequencyStart}                           text|14|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# ${reqMinNumPuschPrb}                           text|169|//*[@name\="reqMinNumPuschPrb"]
# ${bwp_size}          text|192|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='size']
# 
# ${bwp_profile7}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile77}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-77|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${pattern}    t2r4_n2_pusch_1layer
# 
# *** Test Cases ***
# CB008360_B_B2a_case_115_case 2 8DL8UL, 3UE rank1 pair_vran
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3UEs, UE1 in H5V0,UE2 in H120V0,UE3 in H22V0
#     Step3:Push full buffer in UL
#     Step4:Move 3UEs to H0V0
#     Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
# #    Step6:check counter
# 	
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_8360.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
# 
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}
#     ...    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${actUlPtrs}    
#     ...    ${ulDMRSAdditionalPosition}    ${cSRS}    ${ulMuMimoPrbThresholdAbsolute}    ${tiltOffset}    ${ulSinrDiffThreshold}    
#     ...    ${msg1FrequencyStart}    ${srsUePeriodicity}    ${reqMinNumPuschPrb}    ${bwp_size}  
#     ...    ${bwp_profile7}   	${bwp_profile77}
# 
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list}
# 
#     Modify TL VM And AP SCTP Configuration
#     AIC Get and Update BSR File         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 3UEs, UE1 in H5V0,UE2 in H120V0,UE3 in H22V0
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    3    t2r4_n2_pusch_1layer
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Wait Throughput Timer    5
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer in UL
#     Start Collect GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
# #    Airphone SA Start Data Traffic    1    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
# #    Airphone SA Start Data Traffic    2    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    3    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
# #    Airphone SA Start Data Traffic    3    UL    100M    trf_id=2    pdu_id=1    duration=${3600}
# 
#     Wait Throughput Timer    8
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3${/}   unzip=TRUE
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
# 
# #    ${trace_id}     VDU Start TTiTrace Log
# #    Wait Throughput Timer    3
# #    VDU Stop TTiTrace Log    ${trace_id}
# #    run keyword and continue on failure    VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
# 
# #    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_paired_FS.ini
# #    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#    [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File
# 
# Step4:Move 3UEs to H0V0
#     Start Collect GNB and AP Syslog in 'Step4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     #Start GNB BIP Log
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
# 	airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4${/}   unzip=TRUE
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
# 
# #    ${trace_id}     VDU Start TTiTrace Log
# #    Wait Throughput Timer    3
# #    VDU Stop TTiTrace Log    ${trace_id}
# #    run keyword and continue on failure    VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
# 
# #    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_unpaired.ini
# #    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step4
#    
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File
# 
# Step5:Move UE1 to H12V0,UE2 to H5V0,UE3 to H22V0
#     Start Collect GNB and AP Syslog in 'Step5' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     #Start GNB BIP Log
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
# 
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0	
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
#     Wait Throughput Timer    5
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5${/}   unzip=TRUE
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
# 
# #    ${trace_id}     VDU Start TTiTrace Log
# #    Wait Throughput Timer    3
# #    VDU Stop TTiTrace Log    ${trace_id}
# #    run keyword and continue on failure    VDU Decode TTiTrace Log    csv_dir=${save_log}/ttiTrace
# 
# #    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case115_tti_paired_FS.ini
# #    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}Step5
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5' File
# 
# 
# Step6:check counter
#     Start Collect GNB and AP Syslog in 'Step6' File
#     Wait Throughput Timer    300
#     ${PRB_UL_MU_MIMO_3LAYERP}=    VDU Get PM Counter Value   counter_id=M55308C35004   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${PRB_UL_MU_MIMO_4LAYERP}=    VDU Get PM Counter Value   counter_id=M55308C35005   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${PRB_UL_MU_MIMO_3PAIR_UE}=    VDU Get PM Counter Value   counter_id=M55308C35008   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${TOT_MU_MIMO_PAIR_UE_PUSCH}=    VDU Get PM Counter Value   counter_id=M55308C35010   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
#     ${TOT_MU_MIMO_ELIG_UE_PUSCH}=    VDU Get PM Counter Value   counter_id=M55308C35011   dimension_dn=MRBTS-1/NRBTS-1/NRCELL-1
# 
#     run keyword and continue on failure    Should Be True    ${PRB_UL_MU_MIMO_3LAYERP} >0
#     run keyword and continue on failure    Should Be True    ${PRB_UL_MU_MIMO_4LAYERP} ==0
#     run keyword and continue on failure    Should Be True    ${PRB_UL_MU_MIMO_3PAIR_UE} >0
# 	run keyword and continue on failure    Should Be True    ${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH} >0.9
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step6' File
