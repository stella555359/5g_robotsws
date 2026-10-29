# *** Settings ***
# Documentation     Author: shuisheng.he@nokia-sbell.com
# ...               Full Case Name: CB010659_A_b1_102_case12_FDD_UL_CP_OFDM_first_trans_256QAM_table_256QAM_retrans_MCS_31
# ...               DESCRIPTION: This test aims at checking that when an initial transmission is done by using UL 256QAM
# ...               modulation scheme inside 256QAM table, MCS 31 is used for retransmission
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_zhajiang
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
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
# ${targetPctResourceReservedMcsDl}               text|50|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}                  text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}               text|50|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                                  text|4|//*[@name\="maxUlHarqTx"]
# 
# @{Rdparameter}       0x340000:15    0x580367:0x200000
# 
# *** Test Cases ***
# CB010659_A_b1_102_case08_FDD_UL_CP_OFDM_first_trans_16QAM_table_64QAM_retrans_MCS_30
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
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
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
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Trigger UL_HARQ_Retrans
#     Start Collect GNB and AP Syslog in 'Step3_retrans' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=1
#     ABIL_ul_bler_testmode_active    profile_id=1    error=100,80,60,40,0,0,0,0    ue_id=1
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_ul.csv   0.97
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case12_tti.ini     log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_retrans' File
# 
# Step4:Detach ue
#     Detach '1'UE
# 
# 
# 
# 
