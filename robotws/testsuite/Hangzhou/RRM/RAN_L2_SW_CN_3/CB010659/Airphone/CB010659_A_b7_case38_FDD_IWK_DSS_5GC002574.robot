# *** Settings ***
# Documentation     Author: shuisheng.he@nokia-sbell.com
# ...               Full Case Name: CB010659_A_b7_case38_FDD_IWK_DSS_5GC002574
# ...               DESCRIPTION: This test aims at checking that UL DSS allocations changes are considered by adaptative retransmission
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_shuihe
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           String
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config/
# ${SCFC_NAME}          SCFC_10659_1cell_FDD_DSS_case38.xml
# ${AIRPHONE_NAME}      AP_iphy_10659_1cell_FDD_DSS_case38.xml
# ${WTS_NAME}           wts_10659_1cell_FDD_DSS_case38.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
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
# ${targetPctResourceReservedMcsDl}               text|75|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}                  text|50|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}               text|75|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                                  text|5|//*[@name\="maxUlHarqTx"]
# 
# @{Rdparameter}       0x340000:15    0x580010:0x400000    0x5801a6:1
# 
# *** Test Cases ***
# CB010659_A_b7_case38_FDD_IWK_DSS_5GC002574
#     Step1:Commission the above configuration on WebUI
#     Step2:Setup FullStack DSS Phase3
#     Step3:Attach UE1
#     Step4:Trigger UL_HARQ_Retrans
# 	Step5:Change DSS Allocations
# 	Step6:Detach ue
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_onair' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_onair
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB010659    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}	@{Rdparameter}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBwDl}    ${chBwUl}    ${dlMimoMode}    ${ulMimoMode}    ${actDl256Qam}    ${actUl256Qam}
#     ...       ${actAdaptiveReTxResMcsEnh}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    ${minPctResourceReservedMcsUl}
#     ...       ${targetPctResourceReservedMcsUl}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}     ${actAdaptiveReTxResMcs}
# 	...       ${maxUlHarqTx}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Configured    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${/}WTS${/}${WTS_NAME}    reset_after_commission=${False}
#     Airphone Start Wtssim With Cfg File    ${CONFIG_DIR_PATH}${/}${/}WTS${/}${WTS_NAME}
# 	Wait Until Keyword Succeeds    300    15    Verify BTS Is Onair
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_onair' File
# 
# Step2:Setup FullStack DSS Phase3
#     Start Capture GNB and AP Syslog in 'Step2_Setup_DSS' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_Setup_DSS
#     ${cmd_string}    Get File    ${CONFIG_DIR_PATH}${/}${SW_BRANCH}${/}WTS${/}DSS_FS_commands.txt    encoding=UTF-8    encoding_errors=strict
#     @{cmd_list}    Split String    ${cmd_string}    \n
# 	${cmds_num}    Evaluate    len(@{cmd_list})
# 	Log To Console    ${cmds_num}
#     : FOR     ${i}    IN RANGE    ${cmds_num}-${3}
#     \    Log To Console     @{cmd_list}[${i}]
#     \    airphone_execute_egate_command    @{cmd_list}[${i}]
# 	\    Wait Throughput Timer    2
# 	${a}    Evaluate    ${cmds_num}-${3}
# 	Set Suite Variable    ${change_dss_alloc_cmd}    @{cmd_list}[${a}]
# 	Log To Console    ${change_dss_alloc_cmd}
#     airphone_execute_egate_command    command=enb_crm_status enb=1 cell=1    pass_regexp=DMS3
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_Setup_DSS' File
# 
# Step3:Attach UE1
#     Start Capture GNB and AP Syslog in 'Step3_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_attach
#     Attach SA '1'ue to 5g cell
#     Airphone SA Start Data Traffic    1    UL    20M    trf_id=1    pdu_id=1    duration=${3600}
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     run keyword and continue on failure    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE	
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step3_attach' File
# 
# Step4:Trigger UL_HARQ_Retrans
#     Start Capture GNB and AP Syslog in 'Step4_retrans' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_retrans
# 	ABIL_ul_bler_testmode_deactive    profile_id=1    ue_id=1
#     ABIL_ul_bler_testmode_active    profile_id=1    error=100,80,60,40,0,0,0,0    ue_id=1
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_ul.csv   0.97
#     run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case38_tti.ini     log_need_to_check=i    save_log_directory=${save_log}
#     csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step4_retrans' File
# 
# Step5:Change DSS Allocations
#     Start Capture GNB and AP Syslog in 'Step5_Change_DSS_Alloc' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Change_DSS_Alloc
# 	airphone_execute_egate_command  ${change_dss_alloc_cmd}
#     Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_ul.csv   0.97
#     run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case38_step5_tti.ini     log_need_to_check=i    save_log_directory=${save_log}
#     csv_split_with_rnti_and_retransmission    ${save_log}${/}tti_ul.csv
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step5_Change_DSS_Alloc' File
# 
# Step6:Detach ue
#     Detach '1'UE
# 
# *** Keywords ***
# Perform Full Commission And Reach Configured
#     [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
#     ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600
#     [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
#     ...    | Input Parameters | Man. | Description |
#     ...    | scfc | Yes | SCF file path. |
#     ...    | wts_config | Yes | WTS config file |
#     ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
#     ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
#     ...    Examples:
#     ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
#     Log to console    Perform Full Commissioning And Reach Configured start.
#     ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
#     Perform Full Commission     ${new_scfc}
#     Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
#     : FOR    ${loop}    IN RANGE    2
#     \    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
#     \    Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
# 
# 
