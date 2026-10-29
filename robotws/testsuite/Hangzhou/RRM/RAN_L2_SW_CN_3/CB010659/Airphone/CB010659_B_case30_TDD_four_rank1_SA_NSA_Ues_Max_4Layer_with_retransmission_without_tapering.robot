# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               DESCRIPTION:
# ...               This case is to verify that the reserved MCS is used when UL pairing for 4 UEs (rank 1) based on MU SINR estimation,
# ...               retransmission, and using the 256QAM MCS index table. UE1, UE2 and UE3 are power limited UEs and UE4
 #    ...    is not power limited UE.
# ...               The case shall be verified with channel emulator or under OTA.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_AEQE_TDD_eCPRI_cmwv_SANSA_1CC_FS.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      egatelog\
# 
# ${cellDepType}                              text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                     text|80MHz|//*[@name\="chBw"]
# ${cSRS}                                     text|51|//*[@name\="cSRS"]
# ${dlMimoMode}                               text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                               text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                              text|true|//*[@name\="actUlMuMimo"]
# ${actUlDataDmrsFdm}                         text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres64QamMcs}               text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# ${ulDataDmrsFdmThres256QamMcs}              text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# ${ulMaxMuMimoLayer}                         text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                      text|false|//*[@name\="actUlMuMimoTapering"]
# ${frameStructureType}                       text|tdLte|//*[@name\="frameStructureType"]
# ${ulDlDataSlotRatio}                        text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${guardPeriodLength}                        text|6Symbols|//*[@name\="guardPeriodLength"]
# ${prachConfigurationIndex}                  text|97|//*[@name\="prachConfigurationIndex"]
# ${lteToNrFrameShift}                        text|0ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                          text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ullaDeltaSinrMax}                         text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                         text|0|//*[@name\="ullaDeltaSinrMin"]
# ${ulMuMimoCorrThd}                          text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoCorrThd2}                         text|45|//*[@name\="ulMuMimoCorrThd2"]
# ${bwpDN1}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-4|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
# ${bwpDN2}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-75|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
# ${tiltOffset}                               text|0|//*[@name\="tiltOffset"]
# ${ulSinrDiffThreshold}                      text|30|//*[@name\="ulSinrDiffThreshold"]
# ${ulMuMimoLinkAdaptionSwitch}               text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUl256Qam}                              text|true|//*[@name\="actUl256Qam"]
# ${prbThreshRangeOne}                        text|50|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeThree}                      text|50|//*[@name\="prbThreshRangeThree"]
# ${prbThreshRangeTwo}                        text|50|//*[@name\="prbThreshRangeTwo"]
# 
# ${actAdaptiveReTxResMcs}                    text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                 text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}              text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}           text|50|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}              text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}           text|75|//*[@name\="targetPctResourceReservedMcsUl"]
# ${maxUlHarqTx}                              text|4|//*[@name\="maxUlHarqTx"]
# ${pattern}                                  CA_P2_8x4_t2r4_n2_pusch_1layer
# @{Rdparameter}                              0x340000:15    0x58061A:1
# 
# *** Test Cases ***
# CB010659_B_case30_TDD_four_rank1_SA_NSA_Ues_Max_4Layer_with_retransmission_without_tapering
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4UE
# 	Step3:Inject ul data
# 	Step4:Trigger UE1 retransmission
# 	Step5:Deregister and reRegiater UE1
# 	Step6:Trigger UE1 UE2 retransmission
# 	Step7:Deregister and reRegiater UE1 and UE2
# 	Step8:Trigger UE1 UE2 UE3 retransmission
# 	Step9:Deregister and reRegiater UE1 UE2 UE3
# 	Step10:Trigger all UE retransmission
# 	Step11:Deregister all UEs and register
# 	Step12:Trigger UE1 retransmission
# 	Step13:Deregister and reRegiater UE1
# 	Step14:Trigger UE1 and UE5 retransmission
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture gnb and ap syslog in 'Step1_before_onair' file
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010659    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}	@{Rdparameter}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${actUlDataDmrsFdm}    ${prbThreshRangeThree}    ${prbThreshRangeTwo}
#     ...    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${bwpDN1}    ${bwpDN2}
#     ...    ${cSRS}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${tiltOffset}    ${ulSinrDiffThreshold}
#     ...    ${ulMuMimoCorrThd2}    ${ulMuMimoLinkAdaptionSwitch}    ${actAdaptiveReTxResMcs}    ${actAdaptiveReTxResMcsEnh}   
#    ...     ${actUl256Qam}
#     ...    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}    
#    ...    ${targetPctResourceReservedMcsUl}
#     ...    ${ullaDeltaSinrMax}    ${maxUlHarqTx}   ${ulDataDmrsFdmThres64QamMcs}    ${ulDataDmrsFdmThres256QamMcs}    ${prbThreshRangeOne}
# 
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step1_before_onair' file
# 
# Step2:Attach 4UE
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     Airphone NSA Attach    11...14
# #    Attach SA ue with capability to 5g cell    4    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=11    profile=1    init=3    sub=3    step=5
#     ul_mimo_srs_beam_pos_active    ue=12    profile=2    init=1    sub=1    step=2
#     ul_mimo_srs_beam_pos_active    ue=13    profile=3    init=2    sub=3    step=3
#     ul_mimo_srs_beam_pos_active    ue=14    profile=4    init=0    sub=1    step=4
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:Inject ul data
#     Start capture gnb and ap syslog in 'Step3' file
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    12     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    13     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    14     UL    80M    duration=${7200}
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 65000
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3' file
# 
# Step4:Trigger UE1 retransmission
#     Start capture gnb and ap syslog in 'Step4_retx' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_retx
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
#     run keyword and continue on failure    should be true    ${ue11_ul_tput} < 60000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 60000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 60000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 60000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_retx' file
# 
# Step5:Deregister and reRegiater UE1
#     Start capture gnb and ap syslog in 'Step5' file
#     #Start GNB BIP Log
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=11    scell=8    testmode=ul_sinr
#     ul_mimo_srs_beam_pos_deactive    ue=11    profile=1
#     Wait Throughput Timer    5
#     airphone_nsa_detach    ue_id=11
#     Airphone NSA Attach    11
#     ul_mimo_srs_beam_pos_active    ue=11    profile=5    init=3    sub=3    step=5
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 65000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step5' file
# 
# 
# Step6:Trigger UE1 UE2 retransmission
#     Start capture gnb and ap syslog in 'Step6_retx' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=12    profile_id=1    sinr_pusch=-312
# #    ul_sinr_pathloss_active    ue_id=2    profile_id=2    pcmax=20    pathloss=120
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_retx
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_256qam_mcs30_counter    ${save_log}
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
#     run keyword and continue on failure    should be true    ${ue11_ul_tput} < 50000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} < 50000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 50000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 50000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step6_retx' file
# 
# Step7:Deregister and reRegiater UE1 and UE2
#     Start capture gnb and ap syslog in 'Step7' file
#     #Start GNB BIP Log
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=11    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=12    scell=8    testmode=ul_sinr
#     ul_mimo_srs_beam_pos_deactive    ue=11    profile=1
#     ul_mimo_srs_beam_pos_deactive    ue=12    profile=2
#     Wait Throughput Timer    5
#     airphone_nsa_detach    ue_id=11
#     airphone_nsa_detach    ue_id=12
#     Wait Throughput Timer    5
#     Airphone NSA Attach    11...12
#     ul_mimo_srs_beam_pos_active    ue=11    profile=5    init=3    sub=3    step=5
#     ul_mimo_srs_beam_pos_active    ue=12    profile=6    init=1    sub=1    step=2
#     Wait Throughput Timer    5
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    12     UL    80M    duration=${7200}
# #    Attach SA ue with capability to 5g cell    2    ${pattern}
# #    ul_sinr_pusch_active    ue_id=3    profile_id=6    sinr_pusch=-411
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 65000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step7' file
# 
# Step8:Trigger UE1 UE2 UE3 retransmission
#     Start capture gnb and ap syslog in 'Step8' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=12    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=13    profile_id=1    sinr_pusch=-312
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step5.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step8' file
# 
# Step9:Deregister and reRegiater UE1 UE2 UE3
#     Start capture gnb and ap syslog in 'Step9' file
#     #Start GNB BIP Log
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=11    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=12    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=13    scell=8    testmode=ul_sinr
#     ul_mimo_srs_beam_pos_deactive    ue=11    profile=1
#     ul_mimo_srs_beam_pos_deactive    ue=12    profile=2
#     ul_mimo_srs_beam_pos_deactive    ue=13    profile=3
#     Wait Throughput Timer    5
#     airphone_nsa_detach    ue_id=11
#     airphone_nsa_detach    ue_id=12
#     airphone_nsa_detach    ue_id=13
#     Wait Throughput Timer    5
#     Airphone NSA Attach    11...13
#     ul_mimo_srs_beam_pos_active    ue=11    profile=5    init=3    sub=3    step=5
#     ul_mimo_srs_beam_pos_active    ue=12    profile=6    init=1    sub=1    step=2
#     ul_mimo_srs_beam_pos_active    ue=13    profile=3    init=2    sub=3    step=3
#     Wait Throughput Timer    3
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    12     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    13     UL    80M    duration=${7200}
# #    Attach SA ue with capability to 5g cell    2    ${pattern}
# #    ul_sinr_pusch_active    ue_id=3    profile_id=6    sinr_pusch=-411
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step9
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_lg_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue13_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue14_ul_tput} > 65000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step9' file
# 
# Step10:Trigger all UE retransmission
#     Start capture gnb and ap syslog in 'Step10' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=12    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=13    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=14    profile_id=1    sinr_pusch=-312
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch    current
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step10
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# #	check_10659_256qam_mcs30_counter    ${save_log}
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step6.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step10' file
# 
# Step11:Deregister all UEs and register
#     Start capture gnb and ap syslog in 'Step11' file
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=11    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=12    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=13    scell=8    testmode=ul_sinr
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=14    scell=8    testmode=ul_sinr
#     ul_mimo_srs_beam_pos_deactive    ue=11    profile=1
#     ul_mimo_srs_beam_pos_deactive    ue=12    profile=2
#     ul_mimo_srs_beam_pos_deactive    ue=13    profile=3
#     ul_mimo_srs_beam_pos_deactive    ue=14    profile=4
#     Wait Throughput Timer    5
#     airphone_nsa_detach    ue_id=11
#     airphone_nsa_detach    ue_id=12
#     airphone_nsa_detach    ue_id=13
#     airphone_nsa_detach    ue_id=14
#     Wait Throughput Timer    5
#     Airphone NSA Attach    11...12
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     ul_mimo_srs_beam_pos_active    ue=11    profile=5    init=3    sub=3    step=5
#     ul_mimo_srs_beam_pos_active    ue=12    profile=6    init=1    sub=1    step=2
#     ul_mimo_srs_beam_pos_active    ue=1    profile=3    init=2    sub=3    step=3
#     Wait Throughput Timer    3
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Airphone NSA Start Data Traffic    12     UL    80M    duration=${7200}
#     Airphone SA Start Data Traffic    1    UL    80M    trf_id=1    pdu_id=1    duration=${7200}
# #    Attach SA ue with capability to 5g cell    2    ${pattern}
# #    ul_sinr_pusch_active    ue_id=3    profile_id=6    sinr_pusch=-411
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step11
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step11.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue1_ul_tput} > 65000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step11' file
# 
# Step12:Trigger UE1 retransmission
#     Start capture gnb and ap syslog in 'Step12_retx' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step12_retx
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step12.ini    log_need_to_check=i    save_log_directory=${save_log}
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
#     run keyword and continue on failure    should be true    ${ue11_ul_tput} < 60000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 60000
# 	run keyword and continue on failure    should be true    ${ue1_ul_tput} > 60000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step12_retx' file
# 
# Step13:Deregister and reRegiater UE1
#     Start capture gnb and ap syslog in 'Step13' file
#     #Start GNB BIP Log
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=11    scell=8    testmode=ul_sinr
#     ul_mimo_srs_beam_pos_deactive    ue=11    profile=1
#     Wait Throughput Timer    5
#     airphone_nsa_detach    ue_id=11
#     Airphone NSA Attach    11
#     ul_mimo_srs_beam_pos_active    ue=11    profile=5    init=3    sub=3    step=5
#     Airphone NSA Start Data Traffic    11     UL    80M    duration=${7200}
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step13
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step11.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    should be true    ${ue11_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 65000
# 	run keyword and continue on failure    should be true    ${ue1_ul_tput} > 65000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step5' file
# 
# Step14:Trigger UE1 and UE5 retransmission
#     Start capture gnb and ap syslog in 'Step14_retx' file
#     #Start GNB BIP Log
#     ul_sinr_pusch_active    ue_id=11    profile_id=1    sinr_pusch=-312
#     ul_sinr_pusch_active    ue_id=1    profile_id=1    sinr_pusch=-312
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch    current
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch    current
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch    current
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step12_retx
# #    Start GNB Ttitrace With Streaming Mode
# #    Wait Throughput Timer    3
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# #	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# #	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step14.ini    log_need_to_check=i    save_log_directory=${save_log}
# #	csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
#     run keyword and continue on failure    should be true    ${ue11_ul_tput} < 60000
# 	run keyword and continue on failure    should be true    ${ue12_ul_tput} > 60000
# 	run keyword and continue on failure    should be true    ${ue1_ul_tput} < 60000
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step14_retx' file
# 
# 
# Step6:Detach all ues
#     Airphone SA Stop Data Traffic     1    UL
#     Airphone SA Stop Data Traffic     2    UL
#     Airphone SA Stop Data Traffic     3    UL
#     Airphone SA Stop Data Traffic     4    UL
#     Detach '4'UE
# 
# 
# check_10659_256qam_mcs30_counter
#     [Arguments]    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
#     ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   
#    ...    counter_id=M55302C14030   cell_id=1
# 	${PUSCH_CP_RANK2_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55303C23030   cell_id=1
# 	${PUSCH_CP_INIRE_VOL_256TBL_MCS30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   
#    ...    counter_id=M55304C10030   cell_id=1
#     should be true    ${THP_UL_MAX} > 0
#     should be true    ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30} > 0
#     should be true    ${PUSCH_CP_RANK2_256TBL_MCS_30} == 0
#     should be true    ${PUSCH_CP_INIRE_VOL_256TBL_MCS30} > 0
# 
# check_10659_retx_prb
#     [Arguments]    ${ttitrace_path}    ${targetUl}    ${minUl}
#     ${numOfPrb_init}    read csv columns       ${ttitrace_path}    ulFdSchedData.numOfPrb
#     ...    filter=(ulFdSchedData.txNumber=1 )&(ulHarqRxData.crcResult=NOK)&(ulHarqRxData.dtx=NON_DTX)
#     ${CandRetx}    ${MinRetx}    ${MaxRetx}    ${Status}    ${numOfPrb_retx}    ${rePerPrbInitTx}    ${rePerPrbReTx}    ${version}
#     ...    read csv columns       ${ttitrace_path}
#     ...    ulFdSchedData.PRBCandRetx    ulFdSchedData.PRBMinRetx    ulFdSchedData.PRBMaxCodeRateRetx    ulFdSchedData.adaptRetxStatus
#     ...    ulFdSchedData.numOfPrb    ulFdSchedData.rePerPrbInitTx    ulFdSchedData.rePerPrbReTx    ulFdSchedData.redundancyVersion
#     ...    filter=(ulFdSchedData.txNumber=2 )&(ulFdSchedData.adaptRetxStatus=APPLY)
#     ${avg_prb_init}     evaluate    math.ceil(float(sum(${numOfPrb_init})/len(${numOfPrb_init})))       math
#     ${avg_can_retx}     evaluate    math.ceil(float(sum(${CandRetx})/len(${CandRetx})))                 math
#     ${avg_min_retx}     evaluate    math.ceil(float(sum(${MinRetx})/len(${MinRetx})))                   math
#     ${prb_kinds}        evaluate    len(list(set(${numOfPrb_init})))
#     ${res1}             evaluate    math.ceil(float(${avg_prb_init}*${targetUl}/100))                   math
#     ${res2}             evaluate    math.ceil(float(${avg_prb_init}*${minUl}/100))                      math
#     ${res3}             evaluate    ${rePerPrbInitTx}==${rePerPrbReTx}
#     should be true      ${res1}-1<=${avg_can_retx}<=${res1}+1
#     should be true      ${res2}-1<=${avg_min_retx}<=${res2}+1
#     should be true      ${res3}
# 
# 
