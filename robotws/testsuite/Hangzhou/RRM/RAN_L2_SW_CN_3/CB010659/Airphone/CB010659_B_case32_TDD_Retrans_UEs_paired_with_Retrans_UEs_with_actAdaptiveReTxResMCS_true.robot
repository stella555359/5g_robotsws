# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               DESCRIPTION:
# ...               This case is to verify that the reserved MCS is used when retransmission with UL pairing for 4 UEs (rank 1)
# ...               based on MU SINR estimation and using 64QAM MCS index table.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    
#     ...    RAN_5G    owner_jiangzhaona
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
# ${chBw}                                     text|100MHz|//*[@name\="chBw"]
# ${cSRS}                                     text|63|//*[@name\="cSRS"]
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
# ${actUl256Qam}                              text|false|//*[@name\="actUl256Qam"]
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
# CB010659_B_case32_TDD_Retrans_UEs_paired_with_Retrans_UEs_with_actAdaptiveReTxResMCS_true
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NSA UE
# 	Step3:trigger ue11 retransmission
# 	Step4:trigger ue12 retransmission
# 	Step5:trigger ue13 retransmission
# 	Step6:trigger ue14 retransmission
# 	Step7:Detach all ues
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
#     ...    ${cSRS}    ${ulMuMimoCorrThd}    ${tiltOffset}    ${ulSinrDiffThreshold}
#     ...    ${ulMuMimoCorrThd2}    ${ulMuMimoLinkAdaptionSwitch}    ${actAdaptiveReTxResMcs}    ${actAdaptiveReTxResMcsEnh}    
#    ...    ${actUl256Qam}
#     ...    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}    
#     ...    ${targetPctResourceReservedMcsUl}
#     ...    ${maxUlHarqTx}   ${ulDataDmrsFdmThres64QamMcs}    ${ulDataDmrsFdmThres256QamMcs}    ${prbThreshRangeOne}
# 
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step1_before_onair' file
# 
# Step2:Attach 4 NSA UE
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     Airphone NSA Attach    11...14
# #    Attach SA ue with capability to 5g cell    4    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=11    profile=1    init=3    sub=3    step=5
#     ul_mimo_srs_beam_pos_active    ue=12    profile=2    init=1    sub=1    step=2
#     ul_mimo_srs_beam_pos_active    ue=13    profile=3    init=2    sub=3    step=3
#     ul_mimo_srs_beam_pos_active    ue=14    profile=4    init=0    sub=1    step=4
#     Airphone NSA Start Data Traffic    11     UL    100M    duration=${7200}
#     Airphone NSA Start Data Traffic    12     UL    100M    duration=${7200}
#     Airphone NSA Start Data Traffic    13     UL    100M    duration=${7200}
#     Airphone NSA Start Data Traffic    14     UL    100M    duration=${7200}
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case32_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
# #    csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:trigger ue11 retransmission
#     Start capture gnb and ap syslog in 'Step3_retx' file
#     #Start GNB BIP Log
# #    ul_cell_noise_testmode_deactive    profile_id=3
# #    ul_cell_noise_testmode_active    profile_id=3    noise_pusch=-350
#     ul_sinr_pathloss_active    ue_id=11    profile_id=1    pcmax=20    pathloss=110
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step3.ini    log_need_to_check=i    
#     ...    save_log_directory=${save_log}
# 
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_retx' file
# 
# Step4:trigger ue12 retransmission
#     Start capture gnb and ap syslog in 'Step4_retx' file
#     #Start GNB BIP Log
# #    ul_sinr_pusch_active    ue_id=2    profile_id=4    sinr_pusch=-401
#     ul_sinr_pathloss_active    ue_id=12    profile_id=2    pcmax=20    pathloss=110
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_retx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_64qam_mcs31_counter    ${save_log}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step4.ini    log_need_to_check=i    
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_retx' file
# 
# Step5:trigger ue13 retransmission
#     Start capture gnb and ap syslog in 'Step5_retx' file
#     #Start GNB BIP Log
# #    ul_sinr_pusch_active    ue_id=3    profile_id=5    sinr_pusch=-401
#     ul_sinr_pathloss_active    ue_id=13    profile_id=3    pcmax=20    pathloss=110
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_retx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_64qam_mcs31_counter    ${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step5_retx' file
# 
# Step6:trigger ue14 retransmission
#     Start capture gnb and ap syslog in 'Step6_retx' file
#     #Start GNB BIP Log
# #    ul_sinr_pusch_active    ue_id=4    profile_id=6    sinr_pusch=-411
#     ul_sinr_pathloss_active    ue_id=14    profile_id=4    pcmax=20    pathloss=110
#     Wait Throughput Timer    3
#     ${ue11_ul_tput}=    Airphone Get Throughput On Specific Scell    11    8    pusch
#     ${ue12_ul_tput}=    Airphone Get Throughput On Specific Scell    12    8    pusch
#     ${ue13_ul_tput}=    Airphone Get Throughput On Specific Scell    13    8    pusch
#     ${ue14_ul_tput}=    Airphone Get Throughput On Specific Scell    14    8    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_retx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
# 	check_10659_64qam_mcs31_counter    ${save_log}
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case30_tti_step6.ini    log_need_to_check=i    
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step6_retx' file
# 
# Step7:Detach all ues
#     Airphone NSA Detach    11
#     Airphone NSA Detach    12
#     Airphone NSA Detach    13
#     Airphone NSA Detach    14
# 
# 
# check_10659_64qam_mcs31_counter
#     [Arguments]    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
#     ${PUSCH_CP_SUCC_ANY_64TBL_MCS_31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   
#     ...    counter_id=M55302C05031   cell_id=1
# 	${PUSCH_CP_RANK2_64TBL_MCS_31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   
#     ...    counter_id=M55303C01031   cell_id=1
# 	${PUSCH_CP_INIRE_VOL_64TBL_MCS31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   
#     ...    counter_id=M55304C04031   cell_id=1
#     should be true    ${THP_UL_MAX} > 0
#     should be true    ${PUSCH_CP_SUCC_ANY_64TBL_MCS_31} > 0
#     should be true    ${PUSCH_CP_RANK2_64TBL_MCS_31} == 0
#     should be true    ${PUSCH_CP_INIRE_VOL_64TBL_MCS31} > 0
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
