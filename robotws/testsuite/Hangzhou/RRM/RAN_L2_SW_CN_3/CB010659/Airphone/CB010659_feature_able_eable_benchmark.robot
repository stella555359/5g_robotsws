# *** Settings ***
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
# @{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
# ${UE_ID}    1
# 
# 
# *** Test Cases ***
# CB010659_actAdaptiveReTxResMcsEnh_false_true_benchmark
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'on' file
#     Attach SA ue to 5g cell    ${UE_ID}
#     SA send dl and ul data    1    number=1    dl_data=100M    ul_data=100M
#     ${row_title}    create list    pathloss    ul_mcs    rank    sinr    bler    prb    cqi    rssi    
#     ...    rxPower    max_ul_tput    avg_ul_tput    min_ul_tput
#     ${row1}    create list    feature on(actAdaptiveReTxResMcsEnh=true)
#     ${list}    create list    ${row1}
#     append to list    ${list}    ${row_title}   
#     ${ul_tput_m0}    ${ul_tput_a0}    ${ul_tput_min0}    Send passloss and collect tti    85    on    ${list}
#     ${ul_tput_m1}    ${ul_tput_a1}    ${ul_tput_min1}    Send passloss and collect tti    95    on    ${list} 
#     ${ul_tput_m2}    ${ul_tput_a2}    ${ul_tput_min2}    Send passloss and collect tti    115    on    ${list}
#     ${ul_tput_m3}    ${ul_tput_a3}    ${ul_tput_min3}    Send passloss and collect tti    125    on    ${list}
#     ${ul_tput_m4}    ${ul_tput_a4}    ${ul_tput_min4}    Send passloss and collect tti    130    on    ${list}
#     ${ul_tput_m5}    ${ul_tput_a5}    ${ul_tput_min5}    Send passloss and collect tti    135   on    ${list}  
#     ${ul_tput_m6}    ${ul_tput_a6}    ${ul_tput_min6}    Send passloss and collect tti    140    on    ${list}
#     ${ul_tput_m7}    ${ul_tput_a7}    ${ul_tput_min7}    Send passloss and collect tti    145   on    ${list}
#     ${ul_tput_m8}    ${ul_tput_a8}    ${ul_tput_min8}    Send passloss and collect tti    150    on    ${list}
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'on' file
#     write csv    ${test_log_directory()}/All/on.csv    ${list}
#     airphone_sa_detach    ue_id=${UE_ID}
# 
#     run    pkill egate
#     run    sudo pkill edaemon
#     Wait '120s' for stabible
#     Prepare gnb onair
#     ${row2}    create list    feature off(actAdaptiveReTxResMcsEnh=false)
#     append to list    ${list}    ${row2}
#     append to list    ${list}    ${row_title}
#     Reboot and change 'actAdaptiveReTxResMcsEnh' to 'false'
#     Start capture gnb and ap syslog in 'off' file
#     Attach SA ue to 5g cell    ${UE_ID}
#     SA send dl and ul data    1    number=1    dl_data=100M    ul_data=100M
#     ${0ul_tput_m}    ${0ul_tput_a}    ${0ul_tput_min}    Send passloss and collect tti    85    off    ${list} 
#     ${1ul_tput_m}    ${1ul_tput_a}    ${1ul_tput_min}    Send passloss and collect tti    95    off    ${list} 
#     ${2ul_tput_m}    ${2ul_tput_a}    ${2ul_tput_min}    Send passloss and collect tti    115    off    ${list}
#     ${3ul_tput_m}    ${3ul_tput_a}    ${3ul_tput_min}    Send passloss and collect tti    125    off    ${list}
#     ${4ul_tput_m}    ${4ul_tput_a}    ${4ul_tput_min}    Send passloss and collect tti    130    off    ${list}
#     ${5ul_tput_m}    ${5ul_tput_a}    ${5ul_tput_min}    Send passloss and collect tti    135    off    ${list}
#     ${6ul_tput_m}    ${6ul_tput_a}    ${6ul_tput_min}    Send passloss and collect tti    140    off    ${list}
#     ${7ul_tput_m}    ${7ul_tput_a}    ${7ul_tput_min}    Send passloss and collect tti    145    off    ${list}
#     ${8ul_tput_m}    ${8ul_tput_a}    ${8ul_tput_min}    Send passloss and collect tti    150    off    ${list}
#     Stop capture gnb and ap syslog in 'off' file
#     write csv    ${test_log_directory()}/All/benchmark.csv    ${list}
#     ${max_on}     Evaluate       
#     ...   (${ul_tput_m5}+${ul_tput_m6}+${ul_tput_m7}+${ul_tput_m8})/6
#     ${avg_on}     Evaluate       
#     ...   (${ul_tput_a5}+${ul_tput_a6}+${ul_tput_a7}+${ul_tput_a8})/6
#     ${min_on}     Evaluate       
#     ...    (${ul_tput_min5}+${ul_tput_min6}+${ul_tput_min7}+${ul_tput_min8})/6
#     ${max_off}     Evaluate       
#     ...   (${5ul_tput_m}+${6ul_tput_m}+${7ul_tput_m}+${8ul_tput_m})/6
#     ${avg_off}     Evaluate       
#     ...   (${5ul_tput_a}+${6ul_tput_a}+${7ul_tput_a}+${8ul_tput_a})/6
#     ${min_off}     Evaluate       
#     ...    (${5ul_tput_min}+${6ul_tput_min}+${7ul_tput_min}+${8ul_tput_min})/6
#     ${gain_max}    Evaluate    (${max_on}/${max_off})-1
#     ${gain_avg}    Evaluate    (${avg_on}/${avg_off})-1
#     ${gain_min}    Evaluate    (${min_on}/${min_off})-1
#     log to console    ${gain_max}
#     log to console    ${gain_avg}
#     log to console    ${gain_min}
#     run keyword and continue on failure    should be true    ${gain_max}>0.02
#     run keyword and continue on failure    should be true    ${gain_avg}>0.02
#     run keyword and continue on failure    should be true    ${gain_min}>0.02
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# *** Keywords ***
# Send passloss and collect tti
#     [Arguments]    ${passloss}    ${feature_tag}    ${row}
#     log to console    pathloss is:${passloss}......
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=${UE_ID} pathloss\=${passloss}
#     Wait '1s' for stable
#     Airphone Execute Egate Command    
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr profile_id\=${UE_ID} scell\=0 action\=activate
#     Wait '40' for stable
#     ${path}    set variable    ${test_log_directory()}/${feature_tag}/tti${passloss}
#     ${bippath}    set variable    ${test_log_directory()}/${feature_tag}/bip${passloss}
#     ${ttilog_path}    set variable    ${test_log_directory()}/${feature_tag}/tti${passloss}_ul.csv
#     Start collect ttitrace    
#     Wait for '2s' to stop ttitrace with name'tti${passloss}' and path '${path}' 
#     # Start collect bip log
#     # Wait for '2s' to stop bip log with name'bip' with '${bippath}'
#     ${dl_tput_m}    ${ul_tput_m}    Obtain one sa ue dl and ul throught    1     max
#     log to console    max is ${ul_tput_m}
#     ${dl_tput_a1}    ${ul_tput_a1}    Obtain one sa ue dl and ul throught    1    ave
#     log to console    avg is ${ul_tput_a1}
#     ${dl_tput_min}    ${ul_tput_min}    Obtain one sa ue dl and ul throught    1    min
#     log to console    min is ${ul_tput_min}
# 
#     ${tbsize}    get_ues_tbsize_by_sfn    ${ttilog_path}    
#     ...    ${test_log_directory()}/${feature_tag}/tmp_ul.csv    
#     ...    1    ratio=0.2    filter=ulHarqRxData.crcResult\=OK   cared_title=ulFdSchedData.tbSize
#     ${tb}    Get Dictionary Values    ${tbsize}
#     ${ul_tput_a}    evaluate    ${tb}[0]/1/1024
#     log to console    tti avg tput is ${ul_tput_a}
# 
#     ${ret1}    Read Csv Columns    ${ttilog_path}    ulFdSchedData.rrmUlUsedMcs    calculator=avg 
#     
#     ${ret2_tmp}    Read Csv Columns    ${ttilog_path}    ulFdSchedData.numOfLayers     
#     ${ret2}    remove Duplicates    ${ret2_tmp}
# 
#     ${ret3_tmp}    Read Csv Columns    ${ttilog_path}    ulPuschReceiveRespPsData.sinr     
#     ${sum}    set variable    0
#     :FOR    ${item}    IN RANGE    len(${ret3_tmp})
#     \    ${value}    evaluate    list(${ret3_tmp}[${item}])[0]
#     \    ${sum}    evaluate    ${sum}+${value}
#     ${ret3}    evaluate    ${sum}/len(${ret3_tmp})
# 
#     ${ret4_tmp}    Read Csv Columns    ${ttilog_path}    ulHarqRxData.crcResult   
#     ${NOK_list}    create list    
#     :FOR    ${i}    IN RANGE    len(${ret4_tmp})
#     \    run keyword if    'NOK' in '${ret4_tmp}[${i}]'    append to list    ${NOK_list}    ${i}
#     ${ret4}    evaluate    len(${NOK_list})/len(${ret4_tmp})
# 
#     ${ret5_tmp}    Read Csv Columns    ${ttilog_path}    ulHarqRxData.dtx
#     ${dtx_list}    create list    
#     :FOR    ${i}    IN RANGE    len(${ret5_tmp})
#     \    run keyword if    'DTX' == '${ret5_tmp}[${i}]'    append to list    ${dtx_list}    ${i}
#     ${ret5}    evaluate    len(${dtx_list})/len(${ret5_tmp})
#     ${bler}    evaluate    ${ret4}+${ret5}
# 
#     ${ret6}    Read Csv Columns    ${ttilog_path}    ulFdSchedData.numOfPrb     calculator=avg 
#     ${ret7}    Read Csv Columns    ${ttilog_path}    csiSrReportData.csiReport.cqi     calculator=avg
#     ${ret8}    Read Csv Columns    ${ttilog_path}    ulPuschReceiveRespPsData.rssi     calculator=avg 
#     ${ret9}    Read Csv Columns    ${ttilog_path}    ulPuschReceiveRespPsData.rxPower     calculator=avg
#     ${row_values}    create list    ${passloss}    ${ret1}    ${ret2}    ${ret3}    ${bler}    ${ret6}    
#     ...    ${ret7}    ${ret8}    ${ret9}    ${ul_tput_m}    ${ul_tput_a}    ${ul_tput_min}
#     append to list    ${row}    ${row_values}
#     [Return]    ${ul_tput_m}    ${ul_tput_a}    ${ul_tput_min}
#     
# Wait for '${time}' to stop ttitrace with name'${tti_tag}' and path '${path}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${path}
# 
# Wait for '${time}' to stop bip log with name'${bip_tag}' with '${path}'
#     sleep   ${time}
#     Stop GNB BIP Log    ${path}
# 
# Reboot and change '${par}' to '${value}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    ${par}    ${value}    online
#     ###### avoide online affect add reboot
#     # Log To Console    -------- Reboot testline via ssh --------
#     # OperatingSystem.Run And Return Rc And Output
#     # ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
#     # OperatingSystem.Run And Return Rc And Output
#     # ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
#     # Wait Until Keyword Succeeds    60s    2s    check ping is disabled    ${GNB_ASIK.ip}
#     # Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${AP_ASIK.ip}
#     # Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${GNB_ASIK.ip}
#     ###### avoide online affect add reboot
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '60s' for stabible
# 
# Attach SA ue to 5g cell
#     [Arguments]    ${UE_ID}    ${PDU_ID}=1    ${GW_ID}=1    ${SLICE_ID}=1
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}    
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '1s' for stabible
# 
# 
# Obtain one sa ue dl and ul throught
#     [Arguments]    ${ue_id}    ${rate_type}    ${pdu_id}=1    ${qfi_id}=1     
#     ${dl_tput}    airphone_sa_get_throughput    ${ue_id}    dl    ${pdu_id}    ${qfi_id}    ${rate_type}
#     ${ul_tput}    airphone_sa_get_throughput    ${ue_id}    ul    ${pdu_id}    ${qfi_id}    ${rate_type}
#     [return]     ${dl_tput}    ${ul_tput}
# 
# 
