*** Settings ***
Documentation    CB013151 case
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup

Force Tags    CLOUD_5G_I_LOO_AP_LOOO
Resource    testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB013151/CB013151_common_keyword.robot
Library     testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB013151/CB013151_syslog_check.py
*** Variables ***
${log_name_B_B3_01}    log_name_B_B3_01.pcap
${log_name_B_B3_02}    log_name_B_B3_02.pcap
${log_name_C_B1_01}    log_name_C_B1_01.pcap
${log_name_C_B1_02}    log_name_C_B1_02.pcap
#@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog
${UE_NUM_SA}    2
@{pucch_ResourceId}    10

*** Test Cases ***
[1]CB013151-B_B3_01_Adding_the_SRCX_when_number_of_UE_reaches_expansion_threshold_1116_0ms_multi_BWP
     [Documentation]    frameStructureType:tdlte
     [Tags]    CB013151-B    CRT    TRUNK
     [Timeout]    3 hour
     Wait Until Keyword Succeeds    3x    15s    step1-B_B3_01 prepare ENV
     Comment    the first part:attach all UEs
     Start capture gNB log on master    filename=${log_name_B_B3_01}    gNB_index=${0}
#     Start capture gnb and ap syslog in 'B_B3_01_mutiUEs_traffic_01' file
     Special UEs attach    ue_id_start=1    ue_id_end_before=3    pdu_id=11
     Special UEs attach    ue_id_start=3    ue_id_end_before=11    pdu_id=12
     Airphone Multi-UE SA Attach    ue_id_start=11    ue_id_end_before=101   trf_type=internal     #pdu_id=1
     Stop capture all gnb and ap syslog in 'B_B3_01_mutiUEs_traffic_01' file
     sleep    5s
     Special UEs UL traffic    ue_id_start=1    ue_id_end_before=3    pdu_id=11    ul_data=10M    tput=20
     Special UEs UL traffic    ue_id_start=3    ue_id_end_before=11    pdu_id=12    ul_data=250K    tput=1.8
     setp3 mutiUEs UL traffic    ue_id_start=11    ue_id_end_before=101    ul_data=250K    tput=20
     Stop and download the Logs   filename=${log_name_B_B3_01}    gNB_index=${0}
     check B_B3_01 syslog for SRCX acivity

     Comment    the second part:detach part UEs
     Start capture gNB log on master    filename=${log_name_B_B3_02}    gNB_index=${0}
     Start capture gnb and ap syslog in 'B_B3_01_UE1_UE2_traffic_02' file
     detach all UEs    ue_id_start=3    ue_id_end_before=91
     sleep    60s
     check Special UL mutiUEs Tput traffic    ue_id_start=1    ue_id_end_before=3    tput=3.5
     comment    sleep 5min to trigger SRCX release
     sleep    5min
     Stop capture all gnb and ap syslog in 'B_B3_01_UE1_UE2_traffic_02' file
     Stop and download the Logs   filename=${log_name_B_B3_02}    gNB_index=${0}
     Comment    20251215 due to SW change,delete the checkpoint SRCX release,refer to teams record with zhangbo
#     check B_B3_01 syslog for SRCX release
     check wireshark log for UE91-UE100 RRCconfig    filename=${log_name_B_B3_02}
    [Teardown]    Run Keywords
    ...    Stop capture all gnb and ap syslog in 'B_B3_01_mutiUEs_traffic_01' file   AND
    ...    Stop capture all gnb and ap syslog in 'B_B3_01_UE1_UE2_traffic_02' file   AND
    ...    detach all UEs    ue_id_start=1    ue_id_end_before=101    AND
    ...    Stop and download the Logs   filename=${log_name_B_B3_01}    gNB_index=${0}    AND
    ...    Stop and download the Logs   filename=${log_name_B_B3_02}    gNB_index=${0}    AND
    ...    Common Test Teardown


[1]CB013151-C_B1_01_PUSCH_expansion_over_the_PRBs_of_PUCCH_single_UE_1116_0ms_15M_eCPRI_FDM_disable
     [Documentation]    frameStructureType:semiStatic
     [Tags]    CB013151-B    CRT    TRUNK
     [Timeout]    3 hour
     Wait Until Keyword Succeeds    3x    15s    step1-C_B1_01 prepare ENV
     Comment    the first part:attach all UEs
     Start capture gNB log on master    filename=${log_name_C_B1_01}    gNB_index=${0}
     Start capture gnb and ap syslog in 'C_B1_01_mutiUEs_traffic' file
     Special UEs attach    ue_id_start=1    ue_id_end_before=3    pdu_id=11
     Special UEs attach    ue_id_start=3    ue_id_end_before=11    pdu_id=12
     Airphone Multi-UE SA Attach    ue_id_start=11    ue_id_end_before=101   trf_type=internal     #pdu_id=1
     Stop capture all gnb and ap syslog in 'C_B1_01_mutiUEs_traffic' file
     sleep    5s
     Special UEs UL traffic    ue_id_start=1    ue_id_end_before=3    pdu_id=11    ul_data=10M    tput=20
     Special UEs UL traffic    ue_id_start=3    ue_id_end_before=11    pdu_id=12    ul_data=250K    tput=1.8
     setp3 mutiUEs UL traffic    ue_id_start=11    ue_id_end_before=101    ul_data=250K    tput=20
     Stop and download the Logs   filename=${log_name_C_B1_01}    gNB_index=${0}
     check C_B1_01 syslog for SRCX acivity

     Comment    the second part:detach part UEs
     Start capture gNB log on master    filename=${log_name_C_B1_02}    gNB_index=${0}
     Start capture gnb and ap syslog in 'C_B1_01_UE1_UE2_traffic' file
     detach all UEs    ue_id_start=3    ue_id_end_before=91
     sleep    60s
     check Special UL mutiUEs Tput traffic    ue_id_start=1    ue_id_end_before=3    tput=3.5
     comment    sleep 5min to trigger SRCX release
     sleep    5min
     Stop capture all gnb and ap syslog in 'C_B1_01_UE1_UE2_traffic' file
     Stop and download the Logs   filename=${log_name_C_B1_02}    gNB_index=${0}
     check C_B1_01 syslog for SRCX release
     check wireshark log for UE91-UE100 RRCconfig    filename=${log_name_C_B1_02}
    [Teardown]    Run Keywords
    ...    Stop capture all gnb and ap syslog in 'C_B1_01_mutiUEs_traffic' file   AND
    ...    Stop capture all gnb and ap syslog in 'C_B1_01_UE1_UE2_traffic' file   AND
    ...    detach all UEs    ue_id_start=1    ue_id_end_before=101    AND
    ...    Stop and download the Logs   filename=${log_name_C_B1_01}    gNB_index=${0}    AND
    ...    Stop and download the Logs   filename=${log_name_C_B1_02}    gNB_index=${0}    AND
    ...    Common Test Teardown

[1]CB013151-test
     [Documentation]    frameStructureType:semiStatic
     [Tags]    CB013151-B    CRT    TRUNK
     [Timeout]    3 hour
     Wait Until Keyword Succeeds    3x    15s    step1 prepare ENV
#     Start capture syslog via btslog on ute
#     Stop capture syslog via btslog on ute
     Comment    the first part:attach all UEs
     Start capture gNB log on master    filename=${log_name_B_B3_01}    gNB_index=${0}
     Start capture gnb and ap syslog in 'setp3_mutiUEs_traffic' file
     Special UEs attach    ue_id_start=1    ue_id_end_before=3    pdu_id=11
     Special UEs attach    ue_id_start=3    ue_id_end_before=16    pdu_id=12
     Airphone Multi-UE SA Attach    ue_id_start=16    ue_id_end_before=101   trf_type=internal     #pdu_id=1
     Stop capture all gnb and ap syslog in 'setp3_mutiUEs_traffic' file
     SA UL send data '${UE_NUM_SA}' UEs
     sleep    5s
     Special UEs UL traffic    ue_id_start=1    ue_id_end_before=3    pdu_id=11    ul_data=10M    tput=20
     Special UEs UL traffic    ue_id_start=3    ue_id_end_before=16    pdu_id=12    ul_data=250K    tput=2.5
     setp3 mutiUEs UL traffic    ue_id_start=16    ue_id_end_before=101
     Stop and download the Logs   filename=${log_name_B_B3_01}    gNB_index=${0}
     Comment    the second part:detach part UEs
     Start capture gNB log on master    filename=${log_name_B_B3_02}    gNB_index=${0}
     Start capture gnb and ap syslog in 'UE1_UE2_traffic' file
     detach all UL traffic    ue_id_start=16    ue_id_end_before=101
     detach all UEs    ue_id_start=3    ue_id_end_before=91
     sleep    60s
     check Special UL mutiUEs Tput traffic    ue_id_start=1    ue_id_end_before=3    tput=3.5
     Stop capture all gnb and ap syslog in 'UE1_UE2_traffic' file
     Stop and download the Logs   filename=${log_name_B_B3_02}    gNB_index=${0}
    [Teardown]    Run Keywords
    ...    Stop capture all gnb and ap syslog in 'setp3_mutiUEs_traffic' file   AND
    ...    Stop capture all gnb and ap syslog in 'UE1_UE2_traffic' file   AND
    ...    detach all UL traffic    ue_id_start=1    ue_id_end_before=101    AND
    ...    detach all UEs    ue_id_start=1    ue_id_end_before=101    AND
    ...    Stop and download the Logs   filename=${log_name_B_B3_01}    gNB_index=${0}    AND
    ...    Stop and download the Logs   filename=${log_name_B_B3_02}    gNB_index=${0}    AND
    ...    Common Test Teardown

*** Keywords ***
Prepare gnb onair for B_B3_01
    [Arguments]    ${custom_error}=${None}    ${multi_cells}=${False}
    Check GPS status enable
    ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${GNB_SWCONFIG_NAME}
    ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
    Run Keyword If    '${status0}'=='PASS'    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_NAME}
#    ...    ELSE    Modify Swconfig for gnb
    Run Keyword If    '${status1}'=='PASS'    Airphone Upload Swconfig    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}
    ...    ELSE    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
#    ${cfg_path}    Run Keyword If    '${FCT_BOARD_TYPE}' == 'ASIB'    Set variable    ${CURDIR}/../../KISS/cfg/${ABIO_CFG}
#    ...    ELSE    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${ret}    Evaluate Xml Xpath    ${scfc_path}    count(//*[@name\='carrierAggregationSupportList']/p)
    ${type}    Run Keyword If    ${ret} == 1    Read Xml     ${scfc_path}    text|//*[@name\='carrierAggregationSupportList']/p
    ...    ELSE    Get carrierAggregation value    ${ret}    ${scfc_path}
#    Run Keyword If    'Nsa' in '${type}'    Configure NSA TL VM ETH
    Configure TL VM ETH
    Stop capture gnb and ap syslog in 'before_onair' file '${custom_error}'
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
    Start capture gnb and ap syslog in 'B_B3_01_mutiUEs_traffic_01' file
    Perform Full Commission And Reach Onair     ${scfc_path}    ${cfg_path}    2000    False    800    800    multi_cells=${multi_cells}
    Run Keyword If    'Nsa' in '${type}' and 'ABIL' in ${ASP_BOARD_TYPE}   Establish enb x2 link
#    Stop capture gnb and ap syslog in 'before_onair' file '${custom_error}'
    Log To Console    BTS is onAir now

step1-C_B1_01 prepare ENV
    Set Test Variable    ${SCFC_NAME}            SCFC_C_B1_01.xml
    Set Test Variable    ${AIRPHONE_NAME}        iphy.xml
    Set Test Variable    ${WTS_NAME}             wts.cfg
#    Set Test Variable    ${GNBCUTYPE}    NSA
    Set Test Variable    ${GNBCUTYPE}    SA
    ADD RD for C_B1_01
    Prepare gnb onair    multi_cells=True
    Comment    sleep 20s for stable
    sleep    20s

step1-B_B3_01 prepare ENV
    Set Test Variable    ${SCFC_NAME}            SCFC_B3_01.xml
    Set Test Variable    ${AIRPHONE_NAME}        iphy.xml
    Set Test Variable    ${WTS_NAME}             wts.cfg
#    Set Test Variable    ${GNBCUTYPE}    NSA
    Set Test Variable    ${GNBCUTYPE}    SA
    ADD RD for B_B3_01
    Prepare gnb onair for B_B3_01    multi_cells=True
    Comment    sleep 20s for stable
    sleep    20s

ADD RD for C_B1_01
	Add GNB swconfig	0x5901A6:5        #rdPCsiPoolHkfPeriod_min, default time is 15min

ADD RD for B_B3_01
	Add GNB swconfig	0x5901A6:5        #rdPCsiPoolHkfPeriod_min, default time is 15min

ADD RD
	Add GNB swconfig	0x5901A6:5        #rdPCsiPoolHkfPeriod_min, default time is 15min

check wireshark log for UE91-UE100 RRCconfig
    [Arguments]    ${filename}
    Check RRCconfig contain 10 pucch_resourceID   filename=${filename}

Check RRCconfig contain 10 pucch_resourceID
    [Arguments]    ${filename}
    ${nr_rrc_pucch_ResourceId_list}    Create List
    ${all_packets}=    cap.Load Pcap File    pcap_file=${CONFIG_DIR_PATH}/${filename}    alias=test6
    ${filter_expression}=     Catenate    (nr-rrc.pucch_ResourceId == 8) && (f1ap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_pucch_ResourceId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.pucch_ResourceId    pcap_parser=test6
    ${pucch_ResourceId_num}    get length    ${nr_rrc_pucch_ResourceId}
    Should Be True   ${pucch_ResourceId_num}>=${pucch_ResourceId[0]}
#    FOR    ${i}    IN    @{nr_rrc_pucch_ResourceId}
#        Append To List    ${nr_rrc_pucch_ResourceId_list}    ${i}
#    END
#    Sort List    ${nr_rrc_pucch_ResourceId_list}
#    Lists Should Be Equal    ${nr_rrc_pucch_ResourceId_list}    ${pucch_ResourceId}

check B_B3_01 syslog for SRCX acivity
    [Documentation]    check SRCX active
    Check Syslog For Pattern    B_B3_01_mutiUEs_traffic_01    set SrcxState to configured with offsetForSrcx    gnb

check B_B3_01 syslog for SRCX release
    [Documentation]    check SRCX release
    Check Syslog For Pattern    B_B3_01_UE1_UE2_traffic_02    set SrcxState to idle    gnb

check C_B1_01 syslog for SRCX acivity
    [Documentation]    check SRCX active
    Check Syslog For Pattern    C_B1_01_mutiUEs_traffic    set SrcxState to configured with offsetForSrcx    gnb

check C_B1_01 syslog for SRCX release
    [Documentation]    check SRCX release
    Check Syslog For Pattern    C_B1_01_UE1_UE2_traffic    set SrcxState to idle    gnb

check Special UL mutiUEs Tput traffic
    [Arguments]    ${tput}    ${ue_id_start}=1    ${ue_id_end_before}=101
	Log To Console    check all UE UL TTraffic
		run keyword and continue on failure
		...   Wait Until Keyword Succeeds    150s    2s  check UL throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '${tput}'

Special UEs UL traffic
    [Arguments]    ${ul_data}=1M    ${pdu_id}=1    ${tput}=1    ${ue_id_start}=1    ${ue_id_end_before}=101
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} UL traffic
	    run keyword and continue on failure    Airphone SA Start Data Traffic    ${ue_id}   UL   ${ul_data}   pdu_id=${pdu_id}
	    ...    duration=3600   trf_id=${pdu_id}
    END
    Sleep    30s
    Log To Console    check all UE UL TTraffic
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    150s    2s  check UL throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '${tput}'

Special UEs attach
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}    ${pdu_id}    ${trf_type}=internal    ${sleep_time}=3s    #${pdu_id}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} attach
        Airphone SA Attach    ue_id=${ue_id}
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=${pdu_id} ue\=${ue_id}
        Sleep    ${sleep_time}
    END

SA UL send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf ul data    ${num}    2    110M   ${num}
    END
    check UL mutiUEs Tput traffic    ue_id_start=1    ue_id_end_before=3

SA send mutiple trf ul data
    [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}=1    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
#        ${pdu_id}    Evaluate    (${num} - 1) // 10 + 1
        Airphone SA Start Data Traffic    ${ue_id}    UL    ${dl_data}    pdu_id=${pdu_id}    duration=6000s    trf_id=${num}
        ...    protocol=${protocol}
    END

check UL mutiUEs Tput traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101
#    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
#        Log To Console    the ${ue_id} DL traffic
#        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
#	    run keyword and continue on failure    Airphone SA Start Data Traffic    ${ue_id}   DL   100M   pdu_id=${pdu_id}
#	    ...    duration=3600   trf_id=${pdu_id}
#    END
    Sleep    5s
    Log To Console    check all UE UL TTraffic
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    150s    2s  check UL throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '210'

SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    10   50M   ${num}
    END
    check mutiUEs Tput traffic    ue_id_start=1    ue_id_end_before=3

SA send mutiple trf dl data
    [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}=1    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        ${pdu_id}    Evaluate    (${num} - 1) // 10 + 1
        Airphone SA Start Data Traffic    ${ue_id}    DL    ${dl_data}    pdu_id=${pdu_id}    duration=6000s    trf_id=${num}
        ...    protocol=${protocol}
    END

check mutiUEs Tput traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101
#    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
#        Log To Console    the ${ue_id} DL traffic
#        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
#	    run keyword and continue on failure    Airphone SA Start Data Traffic    ${ue_id}   DL   100M   pdu_id=${pdu_id}
#	    ...    duration=3600   trf_id=${pdu_id}
#    END
    Sleep    5s
    Log To Console    check all UE DL TTraffic
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    150s    2s  check throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '1000'

#Stop capture all gnb and ap syslog in '${file_name}' file
#    run keyword and continue on failure    check_err_wrn_in_btslog    ${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}    ${file_name}
#    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${True}
#    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.log
#    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${True}
#    ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_ap.log

Stop capture all gnb and ap syslog in '${file_name}' file
#    run keyword and continue on failure    check_err_wrn_in_btslog    ${CONFIG_DIR_PATH}${/}All${/}syslog_${file_name}${/}    ${file_name}
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${True}
    ...    destination=${CONFIG_DIR_PATH}${/}All${/}syslog_${file_name}${/}     #${file_name}_gnb.log
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${True}
    ...    destination=${CONFIG_DIR_PATH}${/}All${/}syslog_${file_name}${/}    #${file_name}_ap.log

