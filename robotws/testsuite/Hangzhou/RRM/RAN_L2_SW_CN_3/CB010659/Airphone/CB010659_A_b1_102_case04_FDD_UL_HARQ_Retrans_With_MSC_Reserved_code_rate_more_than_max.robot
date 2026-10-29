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
# Test Timeout      60 minutes
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
# ${actDl256Qam}                                  text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                                  text|false|//*[@name\="actUl256Qam"]
# ${actAdaptiveReTxResMcs}                        text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                     text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}                  text|50|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}               text|50|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}                  text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}               text|50|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                                  text|4|//*[@name\="maxUlHarqTx"]
# #init mcs 26 reserve 31
# @{Rdparameter}       0x340000:15    0x580010:0x4000000
# 
# *** Test Cases ***
# CB010659_A_b1_102_case04_FDD_UL_HARQ_Retrans_With_MSC_Reserved_code_rate_more_than_max
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1
#     Step3:Trigger UL_HARQ_Retrans
# 	Step4:Detach ue
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
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
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1
#     Start capture gnb and ap syslog in 'Step2_attach' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Attach SA '1'ue to 5g cell
#     Airphone SA Start Data Traffic    1    UL    20M    trf_id=1    pdu_id=1    duration=${3600}
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case15_tti_step2.ini     log_need_to_check=i    save_log_directory=${save_log}
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
# 
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step2_attach' file
# 
# Step3:Trigger UL_HARQ_Retrans
#     Start capture gnb and ap syslog in 'Step3_retrans' file
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=1
#     ABIL_ul_bler_testmode_active    profile_id=1    error=100,80,60,40,0,0,0,0    ue_id=1
#     Airphone_collect_egate_log_files    ${save_log}    unzip=TRUE
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     ${counter_file}    download PM counter file    ${save_log}
# 	${THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PUSCH_CP_SUCC_ANY_64TBL_MCS_31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55302C05031   cell_id=1
# 	${PUSCH_CP_RANK2_64TBL_MCS_31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55303C01031   cell_id=1
# 	${PUSCH_CP_INIRE_VOL_64TBL_MCS31}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55304C04031   cell_id=1
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case04_tti_step3.ini     log_need_to_check=i    save_log_directory=${save_log}
#     should be true    ${THP_UL_MAX} > 0
#     should be true    ${PUSCH_CP_SUCC_ANY_64TBL_MCS_31} > 2000
#     should be true    ${PUSCH_CP_RANK2_64TBL_MCS_31} == 0
#     should be true    ${PUSCH_CP_INIRE_VOL_64TBL_MCS31} > 30000000
#     [Teardown]    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'Step3_retrans' file
# 
# Step4:Detach ue
#     Detach '1'UE
# 
# 
