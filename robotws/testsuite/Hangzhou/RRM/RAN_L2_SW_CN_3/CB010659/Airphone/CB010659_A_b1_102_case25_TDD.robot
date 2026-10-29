# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags         AP    CRT    SBTS00    RAN_5G    owner_penny    CLOUD_5G_I_BLLL_AP_LOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_case05_TDD.xml
# ${AIRPHONE_NAME}    IPHY_1cell_AEQE_TDD.xml
# ${WTS_NAME}    wts_10659_ABIL_ASIL_TDD_1cell.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# # ${bler_testmode}    ul_cell_noise_testmode_nr profile_id\=1  noise_pusch\=-680
# # ${bler_testmode_activate}    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
# ${bler_sinr}    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-380 
# @{Rdparameter}       0x9D0000:3    0x580367:0x400000
# ${UE_ID}    1
# ${TTI_TAG}    tdd_case25
# 
# *** Test Cases ***
# CB010659_A_b1_101_case25_TDD_Check_UL_256QAM_Counters_MCS_31
#     Prepare test
#     Prepare gnb onair
#     Online change 'actUl256Qam' to 'true'
#     Online change 'minPctResourceReservedMcsUl' to '70'
#     Online change 'targetPctResourceReservedMcsUl' to '75'
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file 
#     Attach ue and send data
#     Check 256qam counter is correct
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# 
# 
# *** Keywords ***
# Attach ue and send data
#     Attach SA ue to 5g cell    ${UE_ID}
#     # Attach SA ue to 5g cell    2    PDU_ID=2    GW_ID=2
#     SA send dl and ul data    1    number=1    dl_data=100M    ul_data=100M
#     # SA send dl and ul data    2    number=1    dl_data=100M    ul_data=100M    pdu_id=2
# 
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
#     airphone_execute_egate_command    ${bler_sinr}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=1 action\=activate
# 
# Online change '${par}' to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ${par}    ${value}    online
#     Wait '30s' for stabible
#     TAF_ADMIN.teardown admin    connection=online
# 
# Check 256qam counter is correct
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/All
#     Start GNB Ttitrace With Streaming Mode
#     Trigger ul retrans
#     Wait Throughput Timer    10
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 action\=deactivate
#     airphone_execute_egate_command	ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=1 action\=deactivate
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}/
#     ${PM_M55304C10031}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55304C10031    cell_id=1
# 	${PM_M55302C12031}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C12031    cell_id=1
#     ${PM_M55303C22031}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C22031    cell_id=1
# 	${PM_M55303C23031}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55303C23031    cell_id=1
# 	${PM_M55302C14031}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55302C14031    cell_id=1
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_re
#     #Get ttitrace value
#    # ${tti_mcs1}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.tbSize
#   #  ...        filter=ulFdSchedData.rrmUlUsedMcs=31    calculator=sum
#    # ${tti_mcs2_unsuccess_last_reTx}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     #...        filter=((ulHarqRxData.crcResult=NOK)&(ulFdSchedData.rrmUlUsedMcs=31)&(ulFdSchedData.txNumber=4))  
#     #${tti_mcs3_rank1}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     #...        filter=((ulFdSchedData.rrmUlUsedMcs=31)&(ulFdSchedData.numOfLayers=RANK1))
#     #${tti_mcs4_rank2}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     #...        filter=((ulFdSchedData.rrmUlUsedMcs=31)&(ulFdSchedData.numOfLayers=RANK2))
#     #${tti_mcs5}    read csv columns     ${save_log}/tti_re_ul.csv    ulFdSchedData.redundancyVersion
#     #...        filter=((ulHarqRxData.crcResult=OK)&(ulFdSchedData.rrmUlUsedMcs=31)) 
#     #${tti_1}     Evaluate    int(float(${tti_mcs1})/8)
#     #${tti_2}     Evaluate    len(${tti_mcs2_unsuccess_last_reTx})
#     #${tti_3}     Evaluate    len(${tti_mcs3_rank1})
#     #${tti_4}     Evaluate    len(${tti_mcs4_rank2})
#     #${tti_5}     Evaluate    len(${tti_mcs5})
# 	#run keyword and continue on failure    should be true    ${PM_M55304C10031}==${tti_1}>0
#     #run keyword and continue on failure    should be true    ${PM_M55302C12031}==${tti_2}
#     #run keyword and continue on failure    should be true    ${PM_M55303C22031}==${tti_3}
#     #run keyword and continue on failure    should be true    ${PM_M55303C23031}==${tti_4}>0
#     #run keyword and continue on failure    should be true    ${PM_M55302C14031}==${tti_5}
#     #Check reserved mcs in ttitrace is correct    tti_re
