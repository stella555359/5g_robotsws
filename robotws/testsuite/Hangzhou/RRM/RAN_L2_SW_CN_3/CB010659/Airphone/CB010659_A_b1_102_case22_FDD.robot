# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_penny
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_case02_FDD.xml
# ${AIRPHONE_NAME}    IPHY_AHLOA_ASIB_ABIL_FDD.xml 
# ${WTS_NAME}       WTS_ASIB_ABIL_FDD_CPRI_SANSA_FS.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${bler_testmode_nr_profile_1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=150,150,150,150,0,0,0,0 ul_bler_bit_error_periodicity\=3 
# ...        ul_bler_bit_error_duration\=0
# @{Rdparameter}       0x340000:3    0x580367:0x10
# ${UE_ID}    1
# ${TTI_TAG}    fdd_case22
# 
# *** Test Cases ***
# CB010659_A_b1_102_case22_FDD_Check_UL_256QAM_Counters_MCS_28
#     Prepare test
#     Prepare gnb onair
#     Establish enb x2 link
#     Start capture gnb and ap syslog in 'after_onair' file
#     Online change 'actUl256Qam' to 'true'
#     Online change 'targetPctResourceReservedMcsUl' to '55'
#     airphone_cleanup_egate_console_log
#     Attach ue and send data
#     Check 256qam counter is correct
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# 
# 
# 
# 
# *** Keywords ***
# Attach ue and send data
#     Attach SA ue to 5g cell    ${UE_ID}
#     SA send dl and ul data    1    number=1    dl_data=100M    ul_data=100M
# 
# 
# Online change '${par}' to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ${par}    ${value}    online
#     Wait '30s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# 
# Attach SA ue to 5g cell
#     [Arguments]    ${UE_ID}    ${PDU_ID}=1    ${GW_ID}=1    ${SLICE_ID}=1
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}    
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '1s' for stabible
# 
# Prepare test
#     # Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Trigger ul retrans
#     airphone_execute_egate_command	${bler_testmode_nr_profile_1}
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate
#     Wait '2s' for stabible
#     airphone_execute_egate_command	ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=activate
# 
# 
# Check 256qam counter is correct
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
#     Start GNB Ttitrace With Streaming Mode
#     Trigger ul retrans
#     Wait Throughput Timer    10
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=deactivate
#     airphone_execute_egate_command	ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=deactivate
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}/
#     ${PM_M55304C10028}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C10028    cell_id=1
# 	${PM_M55302C12028}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C12028    cell_id=1
#     ${PM_M55303C22028}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C22028    cell_id=1
# 	${PM_M55303C23028}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C23028    cell_id=1
# 	${PM_M55302C14028}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C14028    cell_id=1
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     #Get ttitrace value
#     ${tti_mcs1}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.tbSize
#     ...        filter=(ulFdSchedData.rrmUlUsedMcs=28)    calculator=sum
#     ${tti_mcs2_unsuccess_last_reTx}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=NOK)&(ulFdSchedData.rrmUlUsedMcs=28)&(ulFdSchedData.txNumber=4))  
#     ${tti_mcs3_rank1}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulFdSchedData.rrmUlUsedMcs=28)&(ulFdSchedData.numOfLayers=RANK1))
#     ${tti_mcs4_rank2}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulFdSchedData.rrmUlUsedMcs=28)&(ulFdSchedData.numOfLayers=RANK2))
#     ${tti_mcs5}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     ...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=28)) 
#     ${tti_1}     Evaluate    int(float(${tti_mcs1})/8)
#     ${tti_2}     Evaluate    len(${tti_mcs2_unsuccess_last_reTx})
#     ${tti_3}     Evaluate    len(${tti_mcs3_rank1})
#     ${tti_4}     Evaluate    len(${tti_mcs4_rank2})
#     ${tti_5}     Evaluate    len(${tti_mcs5})
# 	should be true    ${PM_M55304C10028}==${tti_1}
#     should be true    ${PM_M55302C12028}==${tti_2}
#     should be true    ${PM_M55303C22028}==${tti_3}
#     should be true    ${PM_M55303C23028}==${tti_4}
#     should be true    ${PM_M55302C14028}==${tti_5}
#     Check reserved mcs in ttitrace is correct    tti_re