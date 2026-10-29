# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...               DESCRIPTION: This test aims at checking retransmission configuration when number of needed PRB exceeds maximum allowable code rate
# ...               In this case (see 5G_UP_ALG_12912), remaining number of PRB should be used for retransmission.
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_zhajiang
# Test Timeout      100 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.xml
# ${AIRPHONE_NAME}      AP_iphy_AHLOA_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.xml
# ${WTS_NAME}           wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.cfg
# @{LOG_NAME_LIST}      egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBwDl}                                       text|20MHz|//*[@name\="chBwDl"]
# ${chBwUl}                                       text|20MHz|//*[@name\="chBwUl"]
# ${dlMimoMode}                                   text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}                                   text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                                  text|true|//*[@name\="actUl256Qam"]
# ${actAdaptiveReTxResMcs}                        text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                     text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}                  text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}               text|75|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}                  text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}               text|75|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                                  text|4|//*[@name\="maxUlHarqTx"]
# 
# ${error1}            100,80,60,40,0,0,0,0
# @{Rdparameter}       0x340000:15    0x580367:0x10000
# 
# *** Test Cases ***
# CB010659_A_b1_104_case16_FDD_DL_UL_20UEs_Adaptive_Retrans_Robustness
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UEs
#     Step3:Trigger UL_HARQ_Retrans
#     Step4:Check PM counter
#     Step5:Online change param
# 	Step6:Detach ue
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture gnb and ap syslog in 'Step1_before_onair' file
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010659    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}	@{Rdparameter}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBwDl}    ${chBwUl}    ${dlMimoMode}    ${ulMimoMode}    ${actDl256Qam}    ${actUl256Qam}
#     ...       ${actAdaptiveReTxResMcsEnh}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}
#     ...       ${targetPctResourceReservedMcsUl}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}     ${actAdaptiveReTxResMcs}
# 	...       ${maxUlHarqTx}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step1_before_onair' file
# 
# Step2:Attach UEs
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Attach SA '20'ue to 5g cell
#     multi_ues_with_buffer    number=20    dl_buffer=175M    ul_buffer=20M
#     Start GNB BIP Log
# #    Wait Throughput Timer    3
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case15_tti_step2.ini     log_need_to_check=i    save_log_directory=${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
# 	${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	should be true    ${THP_UL_MAX} > 6500000
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step21
#     Start Collect GNB and AP Syslog in 'Step21' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step21
#     multi_ues_deactive_bler_testmode    1    1
#     multi_ues_active_bler_testmode    1    1    ${error1}
# #    Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step21' File
# 
# Step3:Trigger UL_HARQ_Retrans
#     Start capture gnb and ap syslog in 'Step3_retrans' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     multi_ues_deactive_bler_testmode    20    1
#     multi_ues_active_bler_testmode    20    1    ${error1}
# #    Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    75    50
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case16_tti_step3.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_retrans' file
# 
# Step4:Check PM counter
#     Start capture gnb and ap syslog in 'Step4_PM' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_PM
# 	check_10659_256qam_mcs30_counter    ${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step4_PM' file
# 
# Step5:Online change param
#     Start capture gnb and ap syslog in 'Step5_change_nidd' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_change_nidd
#     Online recommissioning with delta json file    ${CURDIR}/JSON/Delta_Configuration_scf_robustness_100_50.json
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     check_10659_retx_prb    ${save_log}${/}tti_re_ul.csv    100    50
#     check_10659_256qam_mcs30_counter    ${save_log}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case16_tti_step5.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step5_change_nidd' file
# 
# Step6:Detach ue
#     Detach '20'UE
# 
# multi_ues_with_buffer
#     [Arguments]    ${number}    ${dl_buffer}    ${ul_buffer}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    ${dl_buffer}    pdu_id=1    duration=3600s    trf_id=${num}
#     \    Airphone SA Start Data Traffic    ${num}    UL    ${ul_buffer}    pdu_id=1    duration=3600s    trf_id=${num}
# 
# multi_ues_deactive_bler_testmode
#     [Arguments]    ${ue_num}    ${profile}
#     : FOR    ${num}    IN RANGE    1    ${ue_num}+1
#     \    ABIL_ul_bler_testmode_deactive    profile_id=${profile}    ue_id=${num}
# 
# multi_ues_active_bler_testmode
#     [Arguments]    ${ue_num}    ${profile}    ${error}
#     : FOR    ${num}    IN RANGE    1    ${ue_num}+1
#     \    ABIL_ul_bler_testmode_active    profile_id=${profile}    error=${error}    ue_id=${num}
# 
# check_10659_256qam_mcs30_counter
#     [Arguments]    ${save_log}
#     ${counter_file}    download PM counter file    ${save_log}
#     ${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
#     ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C14030   cell_id=1
# 	${PUSCH_CP_RANK2_256TBL_MCS_30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55303C23030   cell_id=1
# 	${PUSCH_CP_INIRE_VOL_256TBL_MCS30}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55304C10030   cell_id=1
#     should be true    ${THP_UL_MAX} > 0
#     should be true    ${PUSCH_CP_SUCC_ANY_256TBL_MCS_30} > 0
#     should be true    ${PUSCH_CP_RANK2_256TBL_MCS_30} == 0
#     should be true    ${PUSCH_CP_INIRE_VOL_256TBL_MCS30} > 0
# 
# 
# check_10659_retx_prb
#     [Arguments]    ${ttitrace_path}    ${targetUl}    ${minUl}
#     ${numOfPrb_init}    read csv columns       ${ttitrace_path}    ulFdSchedData.numOfPrb
#     ...    filter=(ulFdSchedData.txNumber=1 )&(ulHarqRxData.crcResult=NOK)&(ulHarqRxData.dtx=NON_DTX)
#     ${CandRetx}    ${MinRetx}    ${MaxRetx}    ${Status}    ${numOfPrb_retx}    ${rePerPrbInitTx}    ${rePerPrbReTx}    ${version}
#     ...    read csv columns       ${ttitrace_path}
#     ...    ulFdSchedData.PRBCandRetx    ulFdSchedData.PRBMinRetx    ulFdSchedData.PRBMaxCodeRateRetx    ulFdSchedData.adaptRetxStatus
#     ...    ulFdSchedData.numOfPrb    ulFdSchedData.rePerPrbInitTx    ulFdSchedData.rePerPrbReTx    ulFdSchedData.redundancyVersion
#     ...    filter=(ulFdSchedData.txNumber>1 )&(ulFdSchedData.adaptRetxStatus=APPLY)
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
