*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com


*** Variables ***



*** Keywords ***
Check bip message'${msg}' with ${filter} is equal to value'${value}'
    log to console    check bip message ${msg}
    ${pcap_path}    set variable    ${test_log_directory()}/All/${bip_tag}
    ${ret}=    Get Field Value From BIP Files By Name    ${pcap_path}/*.pcap*    ${msg}    ${filter}
    should be equal    int(${ret}[0])    int(${value})

Check rrc log with a2a
    [Arguments]    ${ini_path}
    check_log_with_au2anlysis    ini_path=${ini_path}    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Get pm counter value
    [Arguments]    ${counter_id}    ${cell_id}    ${counter_path}
    ${PM_counter_file}    download_latest_pmcounter    ${counter_path}
    ${PM_counter_value}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=${cell_id}
    [return]    ${PM_counter_value}

Check pm counter ${counter} in cell ${cell_id} is expected ${symbol} ${expected_value}
    ${cpath}    set variable    ${test_log_directory()}/All/counter_${counter}/
    ${counter_value}    Get pm counter value    ${counter}    ${cell_id}    ${cpath}
    should be true    ${counter_value} ${symbol} ${expected_value}

Check ue '${ue_id}' dl throughput should be larger than '${low_tput}' and smaller than '${high_tput}'
    ${dl_tput}    NSA get ue '${ue_id}' dl throughput
    should_be_true    ${low_tput} < ${dl_tput} < ${high_tput}

Get cell dl throught
    [Arguments]    ${UE_ID}    ${CELL_ID}    ${type}=pdsch
    ${dl_tput}    Airphone Get Throughput On Specific Scell    ${UE_ID}    ${CELL_ID}    type=${type}
    [Return]    ${dl_tput}

Get cell ul throught
    [Arguments]    ${UE_ID}    ${CELL_ID}    ${type}=pusch
    ${ul_tput}    Airphone Get Throughput On Specific Scell    ${UE_ID}    ${CELL_ID}    type=${type}
    [Return]    ${ul_tput}

Check NSA ue '${UE_ID}' '${cell}' dl throught should '${symbol} ${dl_threshold}'
    Wait '3s' for stabible
    ${dl_tput}    Run Keyword If    '${cell}' == 'pcell'    Get cell dl throught    ${UE_ID}    8
    ...    ELSE    Get cell dl throught    ${UE_ID}    9
    should be true    ${dl_tput} ${symbol} ${dl_threshold}

Check SA ue '${UE_ID}' '${cell}' dl throught should '${symbol} ${dl_threshold}'
    Wait '3s' for stabible
    ${dl_tput}    Run Keyword If    '${cell}' == 'pcell'    Get cell dl throught    ${UE_ID}    0
    ...    ELSE    Get cell dl throught    ${UE_ID}    1
    should be true    ${dl_tput} ${symbol} ${dl_threshold}

Check NSA ue '${UE_ID}' '${cell}' ul throught should '${symbol} ${ul_threshold}'
    Wait '3s' for stabible
    ${ul_tput}    Run Keyword If    '${cell}' == 'pcell'    Get cell ul throught    ${UE_ID}    8
    ...    ELSE    Get cell ul throught    ${UE_ID}    9
    should be true    ${ul_tput} ${symbol} ${ul_threshold}

Check SA ue '${UE_ID}' '${cell}' ul throught should '${symbol} ${ul_threshold}'
    Wait '3s' for stabible
    ${ul_tput}    Run Keyword If    '${cell}' == 'pcell'    Get cell ul throught    ${UE_ID}    0
    ...    ELSE    Get cell ul throught    ${UE_ID}    1
    should be true    ${ul_tput} ${symbol} ${ul_threshold}

Obtain one sa ue dl and ul throught
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${qfi_id}=1
    ${dl_tput}    airphone_sa_get_throughput    ${ue_id}    dl    ${pdu_id}    ${qfi_id}
    ${ul_tput}    airphone_sa_get_throughput    ${ue_id}    ul    ${pdu_id}    ${qfi_id}
    [return]     ${dl_tput}    ${ul_tput}


Obtain sa one ue throught
    [Arguments]    ${ue_id}    ${direction}    ${pdu_id}=1    ${qfi_id}=1
    ${tput}    airphone_sa_get_throughput    ${ue_id}    direction=${direction}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    [return]     ${tput}

Check reserved mcs in ttitrace is correct
    [Arguments]    ${tti_tag}
    ${modulation}    ${targetPct}    ${minPct}    ${DftSOfdm}    ${ulTransPrecodePi2Bpsk}    Get ul256qam in gnb scfc
    ${codeRate}    Run Keyword If    '${ASP_BOARD_TYPE}[0]'=='ABIL'    set variable    0.97 
    ...    ELSE    set variable    1.3  
    check_10659_bler_algorithm    ${test_log_directory()}/All/    ${tti_tag}    ${modulation}    
    ...    ${targetPct}    ${minPct}   ${DftSOfdm}    ${codeRate}    ${ulTransPrecodePi2Bpsk}

Get ul256qam in gnb scfc    
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=gnb
    ${xml}    TAF_ADMIN.get_current_scf_file    local_dir_path=${test_log_directory()}    file_name=scfc_using.xml   connection=gnb
    TAF_ADMIN.teardown admin    connection=gnb
    ${ul256qam}=   XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL')]/p[@name="actUl256Qam"])
    ${targetPct}=   XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL')]/p[@name="targetPctResourceReservedMcsUl"])
    ${minPct}=   XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL')]/p[@name="minPctResourceReservedMcsUl"])
    ${DftSOfdm}=   XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL')]/p[@name="actUlDftSOfdm"])
    ${ulTransPrecodePi2Bpsk}    Read Xml    ${xml}    
    ...    text|//*[@name\='ulTransPrecodeCtl']//*[@name\='ulTransPrecodePi2Bpsk']
    [Return]    ${ul256qam}    ${targetPct}    ${minPct}    ${DftSOfdm}    ${ulTransPrecodePi2Bpsk}
