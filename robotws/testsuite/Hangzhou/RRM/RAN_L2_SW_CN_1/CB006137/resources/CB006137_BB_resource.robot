*** Settings ***
Library            ../../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
*** Variables ***

*** Keywords ***
Common Suite Setup 2
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

SA Attach
    [Arguments]    ${sa_ue_id}
    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
    ...    ue_register
    ...    set_pdu_param
    ...    ue_pdu_session_setup
    SA 5G Attach    ue_id=${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${sa_ue_id}

Scell Addition Triggered By A1 Event
    [Arguments]    ${ue_id}    ${meas_id}=1    ${srsrp_nr}=75
    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Start SA UL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=175 trf_id\=${t_time}
        Log To Console    \nUE${ue_id} Start UL 175M Traffic for trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${last_mbps} trf_id\=${ul_times+1}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start UL ${last_mbps}M Traffic for trf_id=${ul_times+1}

Start SA UL Small Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big ul udp traffic which more than 175.
    ${ul_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${ul_times}+1
        SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=1    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${ul_times}
    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=1    trf_id=${ul_times+1}

Start SA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=175 trf_id\=${t_time}
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${last_mbps} trf_id\=${dl_times+1}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start DL ${last_mbps}M Traffic for trf_id=${dl_times+1}

Start SA DL Small Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=1    trf_id=${t_time}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=1    trf_id=${dl_times+1}
Check UL TP On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    ${ulsum_tp}    evaluate    ${pcell_ulTP}+${scell_ulTP}
    Log To Console    UL Troughput is ${ulsum_tp}    console=True
    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}

Check UL TP On Target for B07 step1
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    Step1 Pcell UL Troughput is ${pcell_ulTP}    console=True
    Log To Console    Step1 Scell UL Troughput is ${scell_ulTP}    console=True
    Should Be True    ${pcell_ulTP}>=${target_ulsum_tp}

Check UL TP On Target for B07 step2
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_ulsum_tp}
    ${pcell_ulTP}    Get CA Pcell Average Throughput for B07    ${ueId}    ul    pcell    ${pcell_index}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    Step2 Pcell UL Troughput is ${pcell_ulTP} Kbps   console=True
    Log To Console    Step2 Scell UL Troughput is ${scell_ulTP} Mbps   console=True
    Should Be True    ${scell_ulTP}>=${target_ulsum_tp} and ${pcell_ulTP}<100

Get CA Pcell Average Throughput for B07
    [Arguments]    ${ue_id}    ${dir}    ${cell_type}    ${scell_index}
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${cmd}    Set Variable    ue_stats_nr id\=${ue_id} type\=${type} scell\=${scell_index}
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}    pass_regexp=CellIndex
    ${regexp_cell}    Set Variable    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)Kbps\\s+){3}(?P<AvgTput>\\d+.?\\d*)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${all_cell_tp}=    EVALUATE    sum(map(float,${avg_tp_list}))
    Log To Console    ${all_cell_tp}
    [Return]    ${all_cell_tp}

Check DL TP On Target
    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}
    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    ${dlsum_tp}    evaluate    ${pcell_dlTP}+${scell_dlTP}
    Log To Console    DL Troughput is ${dlsum_tp}    console=True
    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=2
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check Rate
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv      ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]
    ...    ${failed}=["NACK","DTX"]
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    Get Total Number    ${csv_file_path}    ${csv}    ${name}    ${total}
    ${failed_number}    Get Total Failed Number    ${csv_file_path}    ${csv}    ${name}    ${failed}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<0.1

Get Total Number
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${csv_file_path}/${csv}    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed Number
    [Arguments]    ${csv_file_path}    ${csv}=output_dl.csv    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${csv_file_path}/${csv}    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check DL DTXNACK Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]
    Check Rate    ${csv_file_path}    output_dl.csv    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]

Check UL DTXCRC Rate
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]
    Check Rate    ${csv_file_path}    output_ul.csv    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]

Get and Check PM Counter for Symbol
    #<p name="reportingIntervalPm">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${pcell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55335C05006    cell_id=1
    Should Be True    "${pcell_dl_tp}">"0"
    ${scell_dl_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55335C05006    cell_id=2
    Should Be True    "${scell_dl_tp}">"0"
    ${pcell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55335C05007    cell_id=1
    Should Be True    "${pcell_ul_tp}">"0"
    ${scell_ul_tp}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55335C05007    cell_id=2
    Should Be True    "${scell_ul_tp}">"0"

Check Scell Active Status
    [Arguments]    ${cell_nums}    ${scell_active_status}=activated    ${scell_index_start}=1
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} ${scell_active_status} successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=1
    END

Set Value For PHR Testmode
    [Arguments]    ${profile_id}=1    ${phr_mode}=Fixed    ${phr_start}=10    ${phr_min}=0    ${phr_max}=20    ${phr_step_size}=5
    ...    ${phr_period}=10    ${pc_max}=23
    Log To Console    Set Value For PHR Testmode...
    ${cmd}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start}
    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
    ute_wtssim.Execute Egate Command    ${cmd}

Set Value For BLER Testmode
    [Arguments]    ${profile_id}=30    ${ul_bler}=200,200,200,200,200,200,200,200
    Log To Console    Set Value For BLER Testmode...
    ${cmd}    Set Variable    bler_testmode_nr profile_id=${profile_id} ul_bler=${ul_bler}
    ute_wtssim.Execute Egate Command    ${cmd}

Send Action To GNB
    [Arguments]    ${ue_id}    ${testmode}    ${action}    ${profile_id}    ${scell}
    Log To Console    set action=${action} to gnb...
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=${testmode} action=${action}
    ...     profile_id=${profile_id} scell=${scell}
    ute_wtssim.Execute Egate Command    ${cmd}

Check Scell RlqAlgorithm
    [Arguments]    ${id}
    ${BadPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["BAD"]    include    ulScellRlqGoodToBadPathlossData.rlqFilteredDlPathloss    yes
    ${GoodPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["GOOD"]    include    ulScellRlqBadToGoodPathlossData.rlqDlPathlossThreshold    yes
    ${Difference}    Evaluate    ${BadPathloss[-1]}-${GoodPathloss[-1]}
    Should Be True    "${Difference}"=="5.0"
    Log To Console    \n Difference is ${Difference}\n

    ${InstantDlPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["GOOD"]    include    ulScellRlqBadToGoodPathlossData.rlqInstantDlPathloss    yes
    ${rlqDlPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqBadToGoodPathlossData.rlqInstantDlPathloss    ["${InstantDlPathloss[-1]}"]    include
    ...    ulScellRlqBadToGoodPathlossData.rlqDlPathlossThreshold    no
    ${Length}=    Get Length    ${rlqDlPathloss}
    Should Be True    "${Length}"=="5"
    Log To Console    \n Times is ${Length}\n

    ${pCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.pCellBufferSplitRslt    yes
    ${sCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.sCellBufferSplitRslt    yes
    ${rate}    Evaluate    float(${pCellBuffer[-1]})/(${sCellBuffer[-1]})
    Log To Console    \n rate is ${rate}\n
    Should Be True    ${rate}<9.1
    Should Be True    ${rate}>8.9

Delete RD counter xml
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Send Command    rm /tmp/RD.BTS*
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Get RD counter value from xml
    [Arguments]    ${counter}    ${cellid}=1
    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/RD.BTS*.xml|grep ${counter}
    ${Scell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-${cellid}<\/DN><\/MO><NE-WBTS_1.0 measurementType="NCADU">
    ${count_var}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Catenate    SEPARATOR=    ${Scell_var}    ${count_var}
    Log To Console    ${regex}
    ${scell}    Get Regexp Matches    ${counter_info}    ${regex}    1
    ${len}    Get Length    ${scell}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${scell}    ${id}
        Exit For Loop If    '${counter_value}'>'0'
    END
    Log To Console    \n ${counter} is ${counter_value}\n
    should be true    ${counter_value}>0

Gunzip Counter File
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    2s    wait pm counter file generated stable.
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS* ${SUITE_LOG_DIRECTORY}/
    OperatingSystem.Run And Return Rc And Output    gunzip ${SUITE_LOG_DIRECTORY}/RD.BTS*.gz

Check Scell Suspend Resume When Bad RLQ
    Delete RD counter xml
    Set Value For PHR Testmode
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=1
    Set Value For BLER Testmode    ul_bler=200,200,200,200,200,200,200,200
    Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=30    scell=1
    Sleep    10s    reason=make sure the cmd take affect
    Set Value For BLER Testmode    ul_bler=950,950,950,950,950,950,950,950
    Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=30    scell=1
    Sleep    20s    reason=make sure the cmd take affect
    Send Action To GNB    ue_id=3    testmode=bler    action=deactivate    profile_id=30    scell=1
    Start Ttitrace With Streaming Mode    2
    Sleep    2s
    Set Value For PHR Testmode    phr_start=30    phr_max=30
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=1
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    #Check Scell RlqAlgorithm    2
    Gunzip Counter File
    Get RD counter value from xml    SCELL_UL_SUSPEND_RLQ
    Get RD counter value from xml    SCELL_UL_RECOV_RLQ
    Check Scell RlqAlgorithm for B009    2

Send Assistance Information To GNB
    [Arguments]    ${ue_id}    ${operation}    ${reducedCCsDL}    ${reducedCCsUL}
    Log To Console    start send Assistance Information to gnb...
    ${cmd}    Catenate    ue_assistance_send_nr ue_id=${ue_id} forOverheating=${operation} reducedCCsDL=${reducedCCsDL}
    ...    reducedCCsUL=${reducedCCsUL}
    ute_wtssim.Execute Egate Command    ${cmd}
    Sleep    1s


Check Scell Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${egate_file}=/opt/iphy/latest/egate_console.log.001
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    failed
    [Return]    ${scell_status}

Check pcell and Scell Suspend Resume When Bad RLQ
    Delete RD counter xml
    Set Value For PHR Testmode    profile_id=1    phr_start=3   phr_max=30
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=0
    Set Value For PHR Testmode    profile_id=2    phr_start=9   phr_max=30
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=2    scell=1
    Start Ttitrace With Streaming Mode    2
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Set Value For BLER Testmode
    Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=30    scell=1
    Start Ttitrace With Streaming Mode    3
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Send Action To GNB    ue_id=3    testmode=bler    action=deactivate    profile_id=30    scell=1
    Start Ttitrace With Streaming Mode    4
    Sleep    2s
    Set Value For PHR Testmode    profile_id=2    phr_start=30   phr_max=30
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=2    scell=1
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Check Scell RlqAlgorithm for B009    4
    Check scell and pcell power in ttitrace    2
    Check pcell power when scell bad rlq    3
    Check power when resume    4
    Check pcell and scell tti    4
    Gunzip Counter File
    Get RD counter value from xml    SCELL_UL_SUSPEND_RLQ
    Get RD counter value from xml    NUM_OF_CA_UE_OVER_PWR    2

Check scell Bad RLQ and then Overheating
    Set Value For PHR Testmode    profile_id=1    phr_start=9   phr_max=30
    Start Ttitrace With Streaming Mode    2
    Sleep    2s
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=1
    Set Value For BLER Testmode
    Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=30    scell=1
    Set Value For CQI Testmode
    Send Action To GNB    ue_id=3    testmode=csi_override    action=activate    profile_id=3    scell=1
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Set Value For BLER Testmode    ul_bler=950,950,950,950,950,950,950,950
    Send Action To GNB    ue_id=3    testmode=bler    action=activate    profile_id=30    scell=1
    Sleep    20s    reason=make sure the cmd take affect
    Start Ttitrace With Streaming Mode    3
    Send Action To GNB    ue_id=3    testmode=bler    action=deactivate    profile_id=30    scell=1
    Set Value For PHR Testmode    profile_id=1    phr_start=30   phr_max=30
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=1
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Set Value For CQI Testmode    cqi=15    ri=1
    Send Action To GNB    ue_id=3    testmode=csi_override    action=activate    profile_id=3    scell=1
    Sleep    2s
    Start Ttitrace With Streaming Mode    4
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Check pcell prb when scell suspend    2
    Check Scell RlqAlgorithm for B009    3
    Check pcell and scell scheduling    4

Check pcell prb when scell suspend
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/pcell_prb.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Check pcell and scell scheduling
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power5.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Set Value For CQI Testmode
    [Arguments]    ${profile_id}=3    ${cqi}=15    ${cqi_mode}=fixed    ${cqi_min}=1    ${cqi_max}=15    ${ri}=0
    Log To Console    Set Value For CQI Testmode...
    ${cmd}    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=${cqi_mode}
    ...    cqi_min=${cqi_min} cqi_max=${cqi_max} ri=${ri}
    ute_wtssim.Execute Egate Command    ${cmd}

Check Scell RlqAlgorithm for B009
    [Arguments]    ${id}
    ${pCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.pCellBufferSplitRslt    yes
    ${sCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.sCellBufferSplitRslt    yes
    ${rate}    Evaluate    float(${pCellBuffer[-1]})/(${sCellBuffer[-1]})
    Log To Console    \n rate is ${rate}\n
    Should Be True    ${rate}<9.1

Check scell and pcell power in ttitrace
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power1.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power2.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Check pcell power when scell bad rlq
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power3.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Check power when resume
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power4.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Check pcell and scell tti
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB009_power5.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

Stop Ttitrace And Decode Ttitrace log
    [Arguments]    ${log_id}=1    ${duration}=2
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Trigger PHR To GNB
    [Arguments]    ${profile_id}=1    ${phr_start}=10    ${phr_min}=0    ${phr_max}=20    ${phr_step_size}=5
    ...    ${phr_period}=10    ${pc_max}=23    ${phr_mode}=Fixed    ${ue_id}=3    ${cell_id}=1
    Log To Console    start send Power Headroom Report to gnb...
    ${cmd1}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start}
    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
    ute_wtssim.Execute Egate Command    ${cmd1}
    ${cmd2}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate
    ...     profile_id=${profile_id} scell=${cell_id}
    ute_wtssim.Execute Egate Command    ${cmd2}

Trigger BLER To GNB
    [Arguments]    ${profile_id}=30    ${ul_bler}=200,200,200,200,200,200,200,200    ${ue_id}=3    ${cell_id}=1
    Log To Console    start send BLER to gnb...
    ${cmd1}    Set Variable    bler_testmode_nr profile_id=${profile_id} ul_bler=${ul_bler}
    ute_wtssim.Execute Egate Command    ${cmd1}
    ${cmd2}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=bler action=activate
    ...     profile_id=${profile_id} scell=${cell_id}
    ute_wtssim.Execute Egate Command    ${cmd2}
    Sleep    2s

Check Scell RlqAlgorithm for BB07 case
    [Arguments]    ${id}
    ${NumMcsCheck}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["BAD"]    include    ulScellRlqMonitoringData.rrmNumMcsCheckForRLQ    yes
    Should Be True    ${NumMcsCheck[0]}>=50.0 and ${NumMcsCheck[0]}<=80.0
    ${BadPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["BAD"]    include    ulScellRlqGoodToBadPathlossData.rlqFilteredDlPathloss    yes
    Log To Console    BadPathloss value is: ${BadPathloss[0]}\n
    ${rlqInstantDlPathloss}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/output_ul.csv
    ...    ulScellRlqMonitoringData.rrmScellRLQStatus    ["BAD"]    include    ulScellRlqGoodToBadPathlossData.rlqInstantDlPathloss    yes
    Log To Console    rlqInstantDlPathloss value is: ${rlqInstantDlPathloss[0]}\n
    [Return]    ${BadPathloss[0]}     ${rlqInstantDlPathloss[0]}

Trigger Scell Resume for B07
    Send Action To GNB    ue_id=3    testmode=bler    action=deactivate    profile_id=30    scell=1
    Sleep    2s
    Start Gnb BIP Log
    Start Ttitrace With Streaming Mode    3
    Set Value For PHR Testmode    phr_start=30    phr_max=30
    Sleep    2s
    Send Action To GNB    ue_id=3    testmode=phr_override    action=activate    profile_id=1    scell=1
    Sleep    2s
    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}/bipAfterTM2/
    Stop Ttitrace And Decode Ttitrace log    3    2

Check PatternID From Wirshark
    [Arguments]    ${log_id}    ${phycell_id}    ${PatternID}=1321,1377,0,0
    Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq    ${log_id}    ${phycell_id}
    Check PatternID In Puschreceivereq    ${log_id}    ${PatternID}

Convert BIP To CSV By MCShark For Srsreceivereq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}

Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    UlData_eCpriConfigStruct_t.patternId_item
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv    ${filter}
    ...    ${csv_title_list}

Send L1ByPTestModeConfiguration File To Airphone
    [Arguments]    ${L1ByPTestModeConfiguration_path}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${L1ByPTestModeConfiguration_path} toor4nsn@192.168.200.1:/ffs/run/logs

Check Srsreceivereq From Wirshark
    [Arguments]    ${log_id}    ${SRSPeriod}
    Convert BIP To CSV By MCShark For Srsreceivereq    ${log_id}
    ${sfn1}    ${sfn2}    Check sfn In Srsreceivereq    ${log_id}
    ${sfn_delta}    Evaluate    ${sfn2}-${sfn1}
    should be equal as numbers    ${sfn_delta}    ${SRSPeriod}

Check sfn In Srsreceivereq
    [Arguments]    ${log_id}
    @{sfn_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    3gpp.sfn    ["1025", ""]    except    no
    [Return]    @{sfn_list}[0]    @{sfn_list}[1]

Check overlap Symbols From Wirshark
    [Arguments]    ${log_id}    ${phycell_id}    ${symbol_num}
    Convert BIP To CSV By MCShark For overlapSymbol Of Puschreceivereq    ${log_id}    ${phycell_id}
    Check overlap Symbols In Puschreceivereq    ${log_id}    ${symbol_num}

Convert BIP To CSV By MCShark For overlapSymbol Of Puschreceivereq
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off*.pcap*
    ...    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/12Symbols_Puschreceivereq.csv    ${filter}
    ...    ${csv_title_list}

Check overlap Symbols In Puschreceivereq
    [Arguments]    ${log_id}    ${symbol_num}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/12Symbols_Puschreceivereq.csv    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ...    ["${symbol_num}"]    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check PatternID In Puschreceivereq
    [Arguments]    ${log_id}    ${PatternID}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv     UlData_eCpriConfigStruct_t.patternId_item    ["${PatternID}"]
    ...    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check Scell UL TP Decreased
    [Arguments]    ${ueId}    ${scell_index}    ${target_ul_tp}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    Scell's UL Troughput is ${scell_ulTP}    console=True
    Should Be True    ${scell_ulTP}<${target_ul_tp}

L3 Call And Check
    L3 Call and Traffic    ${UE_ID}    ${4CC_2F2T_SCELL}    500    200    400
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for traffic stable
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
    Capture And Decode TTItrace    log_id=1
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
    Check Srsreceivereq From Wirshark    /BIP/1    2
    #Check PatternID From Wirshark    /BIP/1    61
    Check overlap Symbols From Wirshark    /BIP/1    52    12

L3 Call and Traffic
    [Arguments]    ${ue_Id}=${UE_ID}    ${scell_info}=${4CC_2F2T_SCELL}    ${dl_tput}=600    ${ul_tput}=200    ${check_dl_tput}=550
    Set TestMode for SRS    UE_ID=${UE_ID}    profile_id=1    init_pos=0
    SA Attach    ${UE_ID}
    Scell Addition Triggered By A1 Event    ${UE_ID}    1    120
    Get And Check Scell Infos    ${scell_info}
    Start SA UL Big Traffic Internal    ${ue_Id}    ${ul_tput}
    Start SA DL Big Traffic Internal    ${ue_Id}    ${dl_tput}
    Sleep    10s    reason=Wait for logs
    Check UL TP On Target    ${UE_ID}    0    3    90
    Check DL TP On Target    ${UE_ID}    0    1-3    ${check_dl_tput}
	
Set TestMode for SRS
    [Arguments]     ${profile_id}    ${init_pos}    ${UE_ID}
    Log To Console    Set TestMode for SRS
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_srs_beam_pos_nr profile_id\=${profile_id} init_pos\=${init_pos} srsMode\=fixed
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${UE_ID} testmode=ue_srs_beam_pos action=activate profile_id=${profile_id}

Capture BIP Log
    [Arguments]    ${log_id}    ${timer}=1
    Start Gnb BIP Log
    Sleep    ${timer}s
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/${log_id}
    OperatingSystem.Run
    ...    mergecap -a -w ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap*

Check Srsreceivereq With A2A
    [Arguments]    ${log_id}    ${file_ini}=ttitrace_srsreceivereq.ini
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots    ${log_id}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/${file_ini}    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}

Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_srsBmResource_t.srsResourceIdentity
    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}
    OperatingSystem.Run
    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq_bk.csv

Check overlap Symbols With A2A
    [Arguments]    ${log_id}    ${phycell_id}    ${csv_file}
    Convert BIP To CSV By MCShark For overlapSymbol With Slots    ${log_id}    ${phycell_id}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/Symbols_Puschreceivereq.csv
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/${csv_file}    ${TEST_LOG_DIRECTORY}/${log_id}/Symbols_Puschreceivereq.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}

Convert BIP To CSV By MCShark For overlapSymbol With Slots
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfPuschSymbols    3gpp.slot
    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/Symbols_Puschreceivereq.csv    ${filter}    ${csv_title_list}
    OperatingSystem.Run
    ...    cp ${TEST_LOG_DIRECTORY}/${log_id}/Symbols_Puschreceivereq.csv ${TEST_LOG_DIRECTORY}/${log_id}/Symbols_Puschreceivereq_bk.csv

Trigger Low PHR And Check
    [Arguments]    ${scell_index}    ${pcell_index}    ${ue_id}
    Teardown All Connections
    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Trigger PHR To GNB    profile_id=1    phr_start=0     ue_id=${ue_id}    cell_id=${pcell_index}
    Trigger PHR To GNB    profile_id=2    phr_start=20    ue_id=${ue_id}    cell_id=${scell_index}
    Wait for message in syslog file  regexp=scellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
    Capture BIP Log    BIP/2
    Check Scell UL TP Decreased    ${UE_ID}    ${scell_index}     50
    Check Srsreceivereq From Wirshark    /BIP/2    2
    Check overlap Symbols From Wirshark    /BIP/2    52    12
    Gunzip Counter File
    Get RD counter value from xml    NUM_OF_CA_UE_OVER_PWR    3

Recover Default PHR And Check
    [Arguments]    ${scell_index}    ${pcell_index}    ${ue_id}
    Teardown All Connections
    ${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Trigger PHR To GNB    profile_id=1    phr_start=38    ue_id=${ue_id}    cell_id=${scell_index}
    Trigger PHR To GNB    profile_id=2    phr_start=38    ue_id=${ue_id}    cell_id=${pcell_index}
    Wait for message in syslog file  regexp=scellResume  timeout=80  alias=${GNB_SYSLOG.alias}
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Collect from savepoint  savepoint=${savepoint1}  destination_file=${TEST_LOG_DIRECTORY}/syslog2  alias=${GNB_SYSLOG.alias}
    Capture BIP Log    BIP/3
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3
    Check UL TP On Target    ${UE_ID}    0    3    90
    Check DL TP On Target    ${UE_ID}    0    1-3    450
    Check Srsreceivereq From Wirshark    /BIP/3    2
    Check PatternID From Wirshark    /BIP/3    61
    Check overlap Symbols From Wirshark    /BIP/3    52    12

Check Scell Active Status For B027
    [Arguments]    ${cell_nums}    ${scell_active_status}=activated    ${scell_index_start}=1
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}+1
    ${scell_activation}    Set Variable    SCellIndex ${id} ${scell_active_status} successfully at airphone
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=2
    END

Check Scell Suspend Resume When CQI overheating for BB020
    Set Value For CQI Testmode    profile_id=11    cqi=0
    Set Value For CQI Testmode    profile_id=12    cqi=15    ri=1
    Send Action To GNB    ue_id=1   testmode=csi_override    action=activate    profile_id=11    scell=1
    Send Action To GNB    ue_id=1   testmode=csi_override    action=activate    profile_id=11    scell=3
    Sleep    10s
    Check DL TP equal to 0 On cell    ueId=1    scell_index=1
    Check DL TP equal to 0 On cell    ueId=1    scell_index=3
    Check UL TP equal to 0 On cell    ueId=1    scell_index=3
    Capture And Decode TTitrace    log_id=BB020_2
    #Check pcell with full power for UL    log_id=BB020_2
    Start Ttitrace With Streaming Mode
    Send Action To GNB    ue_id=1   testmode=csi_override    action=activate    profile_id=12    scell=3
    Sleep    2s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BB020_3
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BB020_3
    #Check initial split power on Pcell and Scell after cqi resume    log_id=BB020_3
    Check buffer rate of Pcell and Scell after cqi resume    log_id=BB020_3

Check DL TP equal to 0 On cell
    [Arguments]    ${ueId}    ${scell_index}
    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
    Should Be True    ${scell_dlTP}==0

Check UL TP equal to 0 On cell
    [Arguments]    ${ueId}    ${scell_index}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Should Be True    ${scell_ulTP}==0

Check pcell with full power for UL
    [Arguments]    ${log_id}    ${physCellId}=52
    Log To Console    Check pcell with full power for UL
    @{power}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    ulFdSchedData.dciFormat    physCellId    UL_01    include    ${physCellId}    include    ulFdSchedData.splitTxpower    yes
    Should Be True    ${power[1]}>199

Check initial split power on Pcell and Scell after cqi resume
    [Arguments]    ${log_id}
    Log To Console    Check initial split power on Pcell and Scell after cqi resume
    ${pCellPower}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["13.0"]    include    bufferSplitForFr1UlCa.pCellInitialSplitTxPower    yes
    ${sCellPower}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["13.0"]    include    bufferSplitForFr1UlCa.sCellInitialSplitTxPower    yes
    Should Be True    ${pCellPower[0]}==50
    Should Be True    ${sCellPower[0]}>149

Check buffer rate of Pcell and Scell after cqi resume
    [Arguments]    ${log_id}
    Log To Console    Check buffer rate of Pcell and Scell after cqi resume
    ${pCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["13.0"]    include    bufferSplitForFr1UlCa.pCellBufferSplitRslt    yes
    ${sCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["13.0"]    include    bufferSplitForFr1UlCa.sCellBufferSplitRslt    yes
    ${rate}    Evaluate    float(${pCellBuffer[-1]})/(${sCellBuffer[-1]})
    Log To Console    \n rate is ${rate}\n
    Should Be True    ${rate}<9.1
    Should Be True    ${rate}>8.9

Start Small Data And Check Scell Deactive
    [Arguments]    ${log_id}    ${ue_id}    ${mbps_ul}    ${mbps_dl}
    Start SA UL Small Traffic Internal    ${ue_id}    ${mbps_ul}
    Start SA DL Small Traffic Internal    ${ue_id}    ${mbps_dl}
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check Scell Active Status    4    deactivated    2
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Start Big Data And Check Scell Active
    [Arguments]    ${log_id}    ${ue_id}    ${mbps_ul}    ${mbps_dl}
    Start SA UL Big Traffic Internal    ${ue_id}    ${mbps_ul}
    Start SA DL Big Traffic Internal    ${ue_id}    ${mbps_dl}
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check Scell Active Status For B027    3    activated    2
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Send Send Assistance Information And Check Scell Active Status
    [Arguments]    ${log_id}    ${ue_id}    ${reducedCCsDL}    ${reducedCCsUL}    ${cell_nums}    ${scell_active_status}=activated
    Start Ttitrace With Streaming Mode
    Send Assistance Information To GNB    ${ue_id}    yes    ${reducedCCsDL}    ${reducedCCsUL}
    Check Scell Active Status From Egate    ${cell_nums}    ${scell_active_status}
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check Scell Active Status From Egate
    [Arguments]    ${scell_nums}    ${scell_active_status}=activated
    ${loop}    Evaluate    ${scell_nums}+1
    Log To Console    \nverify Scell Deactivation Info...
    FOR    ${id}    IN RANGE    1    ${loop}
    Check Scell Status    ${id}    ${scell_active_status}
    END

Check TP On Target For 4CC
    [Arguments]    ${ueId}    ${dir}    ${scell_index}    ${target_sum_tp}
    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ${dir}    scell    ${scell_index}
    Log To Console    ${dir} Troughput is ${scell_TP}    console=True
    Should Be True    ${scell_TP}>=${target_sum_tp}

Check Priority In BufferSplitTrigger
    [Arguments]    ${log_id}    ${prio}
    ${BufferSplitTrigger}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv   bufferSplitForFr1UlCa.bufferSplitTrigger   ["${prio}"]   include   no
    ${Length}=    Get Length    ${BufferSplitTrigger}
    Should Be True    "${Length}">="1"

Check InitialSplitTxPower After PowerSplitResume
    [Arguments]    ${log_id}
    Log To Console    Check InitialSplitTxPower After PowerSplitResume
    ${pCellPower}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["14.0"]    include    bufferSplitForFr1UlCa.pCellInitialSplitTxPower    yes
    ${sCellPower}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["14.0"]    include    bufferSplitForFr1UlCa.sCellInitialSplitTxPower    yes
    Should Be True    ${pCellPower[0]}==50
    Should Be True    ${sCellPower[0]}>149

Check UL PowerRecover After CQI Not Equal 0
    #Start Ttitrace With Streaming Mode
    Set Value For PHR Testmode    profile_id=1    phr_start=38
    Set Value For PHR Testmode    profile_id=2    phr_start=38
    Send Action To GNB    ue_id=1    testmode=phr_override    action=activate    profile_id=1    scell=3
    Send Action To GNB    ue_id=1    testmode=phr_override    action=activate    profile_id=2    scell=0
    Sleep    2s
    Set Value For PHR Testmode    profile_id=2    phr_start=0
    Set Value For PHR Testmode    profile_id=1    phr_start=-10
    #Sleep    2s
    #Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    #Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    #Check Priority In BufferSplitTrigger    2    9.0
    Sleep    10s    reason=Wait for scell UL data
    ${scell_TP}    Get CA Cell Average Throughput    ${UE1_ID}    ul    scell    3
    Log To Console    UL Troughput is ${scell_TP}    console=True
    Should Be True    ${scell_TP}==0
    Check TP On Target For 4CC    ${UE1_ID}    dl    0-3    300
    Capture And Decode TTitrace    log_id=3
    Check Pcell With Full Power For UL    log_id=3
    Set Value For CQI Testmode    profile_id=3    cqi=0
    Send Action To GNB    ue_id=1    testmode=csi_override    action=activate    profile_id=3    scell=3
    Sleep    10s    reason=Wait for scell DL data
    ${scell_TP}    Get CA Cell Average Throughput    ${UE1_ID}    dl    scell    3
	Log To Console    DL Troughput is ${scell_TP}    console=True
    Should Be True    ${scell_TP}==0
    Start Ttitrace With Streaming Mode
    Set Value For CQI Testmode    profile_id=3    cqi=15    ri=1
    Sleep    2s
    Set Value For PHR Testmode    profile_id=1    phr_start=38
    Set Value For PHR Testmode    profile_id=2    phr_start=38
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/4
    Check InitialSplitTxPower After PowerSplitResume    log_id=4
    Check TP On Target For 4CC    ${UE1_ID}    ul    0-3    100
    Check TP On Target For 4CC    ${UE1_ID}    dl    0-3    300

Check MuMIMO behavior by A2A
    [Arguments]    ${id}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/BB033_mumimo.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${id}/

SA Attach 2UEs and Start ULDL internal Traffic
    [Arguments]       ${number_of_ues}=${2}
    FOR    ${ue_id}    IN RANGE    1    ${number_of_ues}+1
            SA Attach    ${ue_id}
            Scell Addition Triggered By A1 Event    ${ue_id}    1    120
            Start SA UL Big Traffic Internal    ${ue_id}    mbps=100
            Start SA DL Big Traffic Internal    ${ue_id}    mbps=300
            Sleep    3s    reason=Wait traffic stable
            Check DL TP On Target    ${ue_id}    0    1-3    250
            Check UL TP On Scell for BB033    ${ue_id}    3    10
    END
    Sleep    10s    reason=Wait traffic stable
    Check UL TP On Scell for BB033    1    3    35
    Check UL TP On Scell for BB033    2    3    35

Check UL TP On Scell for BB033
    [Arguments]    ${ueId}    ${scell_index}    ${target_ulsum_tp}
    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
    Log To Console    UL Troughput for UE:${ueId} is ${scell_ulTP}   console=True
    Should Be True    ${scell_ulTP}>=${target_ulsum_tp}

Check DRX For Cell
    [Arguments]    ${csv_file_path}
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/ttitrace_drx.ini    output_ul.csv    ${csv_file_path}

Check Srsreceivereq With A2A_B40
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq With Slots    ${log_id}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/ttitrace_srsreceivereq_B40.ini    ${TEST_LOG_DIRECTORY}/${log_id}/csv_Srsreceivereq.csv
    ...    ${TEST_LOG_DIRECTORY}/${log_id}

Check For BB047
    Start Gnb BIP Log
    Sleep    1s
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
    Capture And Decode TTItrace    log_id=1
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
    Check Srsreceivereq With A2A    /BIP/1    ttitrace_srsreceivereqBB047.ini
    Check overlap Symbols With A2A    /BIP/1    52    ttitrace_13Symbols.ini

Trigger Low Phr To Suspend Scell For BB047
    [Arguments]    ${scell_index}    ${pcell_index}    ${ue_id}
    Teardown All Connections
    Trigger PHR To GNB    profile_id=1    phr_start=0     ue_id=${ue_id}    cell_id=${pcell_index}
    Trigger PHR To GNB    profile_id=2    phr_start=20    ue_id=${ue_id}    cell_id=${scell_index}
    ute_syslog.Wait For Message In Syslog File  regexp=scellSuspend  timeout=60  alias=${GNB_SYSLOG.alias}
    Capture BIP Log    /BIP/2
    Capture And Decode TTItrace    log_id=2
    Check pcell with full power for UL    2    52
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2
    Check Scell UL TP Decreased    ${UE_ID}    ${scell_index}     50
    Check Srsreceivereq With A2A    /BIP/2    ttitrace_srsreceivereqBB047.ini
    Check overlap Symbols With A2A    /BIP/2    52    ttitrace_13Symbols.ini
    Gunzip Counter File
    Get RD counter value from xml    NUM_OF_CA_UE_OVER_PWR    3

Recover Default PHR To Resume Scell And Check For BB047
    [Arguments]    ${scell_index}    ${pcell_index}    ${ue_id}
    Teardown All Connections
    Trigger PHR To GNB    profile_id=1    phr_start=38    ue_id=${ue_id}    cell_id=${scell_index}
    Trigger PHR To GNB    profile_id=2    phr_start=38    ue_id=${ue_id}    cell_id=${pcell_index}
    ute_syslog.Wait For Message In Syslog File  regexp=scellResume  timeout=80  alias=${GNB_SYSLOG.alias}
    Start Ttitrace With Streaming Mode
    Sleep    2s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Capture BIP Log    /BIP/3
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
    Check UL TP On Target    ${UE_ID}    0    3    90
    Check DL TP On Target    ${UE_ID}    0    1-3    550
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3
    Check PatternID From Wirshark    /BIP/3    61    1749,1805,0,0
    Check Srsreceivereq With A2A    /BIP/3    ttitrace_srsreceivereqBB047.ini
    Check overlap Symbols With A2A    /BIP/3    52    ttitrace_13Symbols.ini

Convert BIP To CSV By MCShark For UL Scheduled Slots
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${log_id}    5GBipL2L1_filtering_off.pcap
    ...    ${True}
    Convert BIP To CSV By MCShark   @{bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/Pusch_${phycell_id}.csv    ${filter}
    ...    ${csv_title_list}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/Pusch_${phycell_id}.csv

Check Pcell Ul Scheduled On All Slots
    [Arguments]    ${phycell_id}=52    ${log_id}=BIP/1
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/ttitrace_ul_pcell.ini
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/Pusch_${phycell_id}.csv    ${TEST_LOG_DIRECTORY}/${log_id}/

Check Scell Ul Scheduled On Overlap Slots
    [Arguments]    ${phycell_id}=61    ${log_id}=BIP/1
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/ttitrace_ul_scell.ini
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/Pusch_${phycell_id}.csv    ${TEST_LOG_DIRECTORY}/${log_id}/

L3 Call and Traffic For 43
    [Arguments]    ${ue_Id}=${UE_ID}    ${scell_info}=${4CC_2F2T_SCELL}    ${dl_tput}=400    ${ul_tput}=160
    SA Attach    ${UE_ID}
    Scell Addition Triggered By A1 Event    ${UE_ID}    1    120
    Get And Check Scell Infos    ${scell_info}
    Start SA UL Big Traffic Internal    ${ue_Id}    ${ul_tput}
    Start SA DL Big Traffic Internal    ${ue_Id}    ${dl_tput}
    Sleep    10s    reason=Wait for logs
    Check UL TP On Target    ${UE_ID}    0    3    69
    Check DL TP On Target    ${UE_ID}    0    1-3    300

Check Fail Ratio Of CsiReport
    [Arguments]    ${csv_file_path}
    Check Rate    ${csv_file_path}    output_ul.csv    ulPuschReceiveRespPsData.dtx    ["0.0","1.0"]    ["1.0"]

Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq for BB043
    [Arguments]    ${log_id}    ${phycell_id}
    ${filter}=    Set Variable    (uldata_puschreceivereq) && (3gpp.dmrsScramblingSequenceInt == ${phycell_id})
    @{csv_title_list}=    Create List    UlData_eCpriConfigStruct_t.patternId_item
    ${bip_names}=    Set Variable     ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark   ${bip_names}    ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv    ${filter}
    ...    ${csv_title_list}
    Run    sed -i 's/"//g' ${TEST_LOG_DIRECTORY}/${log_id}/PatternId_Puschreceivereq.csv

Check PatternID From Wirshark for BB043
    [Arguments]    ${log_id}    ${phycell_id}    ${PatternID}=1749,1805,0,0
    Convert BIP To CSV By MCShark For PatternId Of Puschreceivereq for BB043    ${log_id}    ${phycell_id}
#    Check PatternID In Puschreceivereq    ${log_id}    ${PatternID}
