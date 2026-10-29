# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_xueminm
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.xml
# ${AIRPHONE_NAME}    AP_iphy_AHLOA_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.xml 
# ${WTS_NAME}       wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS.cfg
# @{LOG_NAME_LIST}        egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBwDl}                                       text|20MHz|//*[@name\="chBwDl"]
# ${chBwUl}                                       text|20MHz|//*[@name\="chBwUl"]
# ${dlMimoMode}                                   text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ulMimoMode}                                   text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${actDl256Qam}                                  text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                                  text|false|//*[@name\="actUl256Qam"]
# ${actAdaptiveReTxResMcs}                        text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                     text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${minPctResourceReservedMcsDl}                  text|60|//*[@name\="minPctResourceReservedMcsDl"]
# ${targetPctResourceReservedMcsDl}               text|80|//*[@name\="targetPctResourceReservedMcsDl"]
# ${minPctResourceReservedMcsUl}                  text|60|//*[@name\="minPctResourceReservedMcsUl"]
# ${targetPctResourceReservedMcsUl}               text|80|//*[@name\="targetPctResourceReservedMcsUl"]
# ${ullaDeltaSinrMax}                             text|0|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|0|//*[@name\="ullaDeltaSinrMin"]
# ${maxUlHarqTx}                                  text|4|//*[@name\="maxUlHarqTx"]
# @{Rdparameter}       0x340000:3    0x580010:0x4000
# ${bler_testmode_nr_profile_1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=100,80,60,40,0,0,0,0 ul_bler_bit_error_periodicity\=5 
# ...        ul_bler_bit_error_duration\=0
# ${pattern}    FDD_UL_RANK2 
# 
# 
# *** Test Cases ***
# CB010659_A_b1_102_case20_FDD_Check_UL_64QAM_Counters_MCS_30
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1
#     Step3:Trigger UL_HARQ_Retrans and Check counter value
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
#     ...       ${actAdaptiveReTxResMcsEnh}    ${minPctResourceReservedMcsDl}    ${targetPctResourceReservedMcsDl}    
#    ...    ${minPctResourceReservedMcsUl}    
#     ...       ${targetPctResourceReservedMcsUl}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}     ${actAdaptiveReTxResMcs}    
# 	...       ${maxUlHarqTx}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     Wait Throughput Timer    15
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
# 	${FDD_UL_RANK2}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${FDD_UL_RANK2}
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal  
#     Wait Throughput Timer    3	
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl trf_id\=1 mbps\=75 seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=ul trf_id\=1 mbps\=75 seconds\=3600
#     Wait Throughput Timer    5
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Trigger UL_HARQ_Retrans and Check counter value
#     Start Collect GNB and AP Syslog in 'Step3_retrans' File
#     Start GNB BIP Log
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_retrans
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command	${bler_testmode_nr_profile_1}
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate
#     Wait Throughput Timer    10
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}	
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_retrans${/}
# 	${PM_M55302C05030}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C05030    cell_id=1
# 	${PM_M55302C03030}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C03030    cell_id=1
# 	${PM_M55304C04030}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C04030    cell_id=1
# 	${PM_M55303C01030}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C01030    cell_id=1
# 	${PM_M55302C05014}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C05014    cell_id=1
# 	${PM_M55302C03014}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C03014    cell_id=1
# 	${PM_M55304C04014}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C04014    cell_id=1
# 	${PM_M55303C01014}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C01014    cell_id=1
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_retrans${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
# 	#Get ttitrace value
# 	${tti_mcs30_success}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=30))
#     ${tti_M55302C05030}     Evaluate    len(${tti_mcs30_success})
#     ${tti_mcs30_unsuccess_last_reTx}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    
#    ...    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=NOK)&(ulFdSchedData.rrmUlUsedMcs=30)&(ulFdSchedData.txNumber=4))
#     ${tti_M55302C03030}     Evaluate    len(${tti_mcs30_unsuccess_last_reTx})
#     ${tti_mcs30_rank2}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulFdSchedData.rrmUlUsedMcs=30)&(ulFdSchedData.numOfLayers=RANK2))
#     ${tti_M55303C01030}     Evaluate    len(${tti_mcs30_rank2})
#     ${tti_mcs30_tbsize}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    ulFdSchedData.tbSize
#     ...        filter=(ulFdSchedData.rrmUlUsedMcs=30)    calculator=sum
#     ${tti_M55304C04030}     Evaluate    int(float(${tti_mcs30_tbsize})/8)
# 	#    Check PM counter value and ttitrace value
# 	should be true    ${PM_M55302C05030}==${tti_M55302C05030}
#     should be true    ${PM_M55302C03030}==${tti_M55302C03030}
#     should be true    ${PM_M55304C04030}==${tti_M55304C04030}
#     should be true    ${PM_M55303C01030}==${tti_M55303C01030}
# 	
# 	#Check AdaptiveReTxResMcs works
# 	${tti_mcs30_crc_ok}    read csv columns     ${TEST_LOG_DIRECTORY()}Step3_retrans/tti_re_ul.csv    ulHarqRxData.crcResult
#     ...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=30))
# 	${ttiCount_tti_mcs30_crc_ok}     Evaluate    len(${tti_mcs30_crc_ok})
# 	should be true   ${ttiCount_tti_mcs30_crc_ok} > 0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_retrans' File  
