*** Settings ***
Documentation    Iperf keywords
Library      OperatingSystem
Library      taf.transport.ssh    WITH NAME    ssh
Library      ${CURDIR}/../python/throughput_calculate.py

*** Variables ***
${iperf_egrep}    egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${LOW_TPUT}       5

*** Keywords ***
Set IPerf results
    [Arguments]    ${ul_log_path}    ${dl_log_path}
    ${ul_dict}     parse_log    ${ul_log_path}
    ${dl_dict}     parse_log    ${dl_log_path}
    ${average_throughput_ul}    Set Variable    ${ul_dict["average_throughput"]}
    ${throughput_time_ul}       Set Variable    ${ul_dict["throughput_time"]}
    ${average_throughput_dl}    Set Variable    ${dl_dict["average_throughput"]}
    ${throughput_time_dl}       Set Variable    ${dl_dict["throughput_time"]}
    Set Test Variable    ${average_throughput_ul}
    Set Test Variable    ${throughput_time_ul}
    Set Test Variable    ${average_throughput_dl}
    Set Test Variable    ${throughput_time_dl}

Verify UL
    Run Keyword If    'RF${RF}' in @{LTE_RF_LIST}    Should Be True    ${average_throughput_ul} >${tl.target_traffic${capability}}[MIN_UL]
    Run Keyword If    'RF${RF}' not in @{LTE_RF_LIST}    Run Keyword And Continue On Failure
    ...    Should Be True    ${average_throughput_ul} > ${tl.target_traffic${capability}}[MIN_UL]
    ${IPERF_DURATION_CHECK}    Evaluate    ${tl.target_traffic${capability}}[IPERF_DURATION]-10
    Log To Console    \n--> UL TP time (sec): ${throughput_time_ul}
    Run Keyword If    ${average_throughput_ul} <= ${LOW_TPUT}
    ...               Log to Console    \n >>>> Check Attach Manually <<<< \n
    Should Be True    ${throughput_time_ul} >= ${IPERF_DURATION_CHECK}

Verify DL
    Run Keyword If    'RF${RF}' in @{LTE_RF_LIST}    Should Be True    ${average_throughput_dl} > ${tl.target_traffic${capability}}[MIN_DL]
    Run Keyword If    'RF${RF}' not in @{LTE_RF_LIST}    Run Keyword And Continue On Failure
    ...    Should Be True    ${average_throughput_dl} > ${tl.target_traffic${capability}}[MIN_DL]
    ${IPERF_DURATION_CHECK}    Evaluate    ${tl.target_traffic${capability}}[IPERF_DURATION]-10
    Log To Console    --> DL TP time (sec): ${throughput_time_dl}
    Run Keyword If    ${average_throughput_dl} <= ${LOW_TPUT}
    ...               Log to Console    \n >>>> Check Attach Manually <<<< \n
    Should Be True    ${throughput_time_dl} >= ${IPERF_DURATION_CHECK}
