*** Settings ***
Documentation    author：Xiao Hou
...              contact: susie.hou@nokia-sbell.com
...              squad group: VRF_HAZ4_12

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/tti_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.lib.PM_Counter.PMCounter    WITH NAME    counter
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG12/python/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG4.TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG4.TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${scf}    ${CURDIR}/8927_ST10_scf.xml
${TS_CASE_LOG_PATH}    ${output_dir}
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${nrcell_tdd}              611451184
${nrcell_tdd_id}           304
${bts_id}                     37320

*** Keywords ***
UE Setup
    BuiltIn.Log To Console    \n ### Prepare UE ###
    Wait Until Keyword Succeeds    3m    1m    power_ue.Prepare UE    ue_type=askey

UE Teardown
    BuiltIn.Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_type=askey

Start And Check UL And DL traffic
    [Arguments]    ${target_ul}    ${target_dl}    ${time}=360s
    BuiltIn.Log To Console    \n ### DL Traffic ###
    power_ue.Start traffic    ue_type=askey    direction=dl    throughput=1700M    duration=1800
    BuiltIn.Log To Console    \n ### UL Traffic ###
    power_ue.Start traffic    ue_type=askey    direction=ul    throughput=230M    duration=1800
    ${cellid}    create list    ${nrcell_tdd}
    ${log_path}    power_ue.Collect Tput     ue_type=askey    duration=${time}    ignore_time=30s    check_source=aasyslog
    Wait Until Keyword Succeeds    5m    1m    power_ue.Check Bi Tput    ue_type=askey    log=${log_path}    cells=${cellid}
    ...    ultarget_throughput=${target_ul}    dltarget_throughput=${target_dl}    check_source=aasyslog

Stop UL And DL Traffic
    Log To Console    \n ### STOP Traffic ###
    power_ue.Stop traffic    ue_type=askey    direction=ul
    power_ue.Stop traffic    ue_type=askey    direction=dl

Capture And Decode TTI log
    [Arguments]    ${log_time}=3    ${bts_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console    \n ### Capture And Decode TTI
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${csv_path}    Capture And Decode TTitrace    duration=${log_time}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}

Check DL And UL By TTI
    Log To Console    \n ### Check DL And UL By TTI
    CUDU_L2 Check DTXNACK Rate    log_id=l2stream3_ttitrace
    CUDU_L2 Check UL DTXCRC Rate    log_id=l2stream3_ttitrace

CUDU_L2 Check DTXNACK Rate
    [Arguments]    ${log_id}=dtxnack    ${expect_rate}=0.1
    CUDU_L2 Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

CUDU_L2 Check UL DTXCRC Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.1
    CUDU_L2 Check Rate    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

CUDU_L2 Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ...    ${expect_rate}=0.1
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    CUDU_L2 Get Total Number    ${name}    ${total}    ${log_id}
    ${failed_number}    CUDU_L2 Get Total Failed Number    ${name}    ${failed}    ${log_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<${expect_rate}

CUDU_L2 Get Total Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    tcpdump_ttitrace_dl.csv    tcpdump_ttitrace_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TS_CASE_LOG_PATH}/ttitrace_streaming/${log_id}/${csv_file_name}    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

CUDU_L2 Get Total Failed Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    tcpdump_ttitrace_dl.csv    tcpdump_ttitrace_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TS_CASE_LOG_PATH}/ttitrace_streaming/${log_id}/${csv_file_name}    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Capture And Check Counters
    [Arguments]    ${starting_log_timestamp}
    Log To Console    \n ### Capture And Check Counters
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    set variable     ${nrcell_tdd_id}
    ${list_measurement_ids}    create list    M55308C00092    M55365C00011    M55308C00093    M55308C10003
    ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
    ${M55308C00092_value}    set variable    ${dict_measurements_value['${cell_check_list}']['M55308C00092']}
    ${M55365C00011_value}    set variable    ${dict_measurements_value['${cell_check_list}']['M55365C00011']}
    ${M55308C00093_value}    set variable    ${dict_measurements_value['${cell_check_list}']['M55308C00093']}
    ${M55308C10003_value}    set variable    ${dict_measurements_value['${cell_check_list}']['M55308C10003']}
    Run keyword And Continue On Failure   Run Keywords    Should be True      ${M55308C00092_value} == 273
    ...                                        AND        Should be true      ${M55365C00011_value} > 0
    ...                                        AND        Should be true      ${M55308C00093_value} > 0
    ...                                        AND        Should be true      ${M55308C10003_value} > 0

Get Counts Of Filter Column
    [Arguments]    ${cell_id}=52    ${list_filter}=11.0    ${filter}=dlPagingOrSibSchedData.numOfPrb    ${log_id}=l2stream3_ttitrace
    ${sub_name}=    Get Substring    ${filter}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    tcpdump_ttitrace_dl.csv    tcpdump_ttitrace_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Other    ${TS_CASE_LOG_PATH}/ttitrace_streaming/${log_id}/${csv_file_name}
    ...    physCellId     ["${cell_id}"]    include    ${filter}    no
    ${counts}=    Collections.Count Values In List    ${data_list}    ${list_filter}
    Log To Console    ${counts}
    [Return]    ${counts}

Case Setup
    robot_common_operations.Common Case Setup
    Run Keyword And Ignore Error    UE Teardown

Case Teardown
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

Commissionin SCF For TL
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf}
    ...                              timeout=${600}    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air

Block Cell By Admin
    [Arguments]    ${cell_name}=MRBTS-37320/NRBTS-37320/NRCELL-314
    [Documentation]    This keyword is to block cell by admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_name} | Yes | Cell dist name. such as MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    ...    Examples:
    ...    | Block Cell By Admin | MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    Log To Console    Cell ${cell_name} Locked
    coam.Setup Admin
    coam.Block Cell    dist_name=${cell_name}
    Sleep    30s    reason=wait for gnb ok
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Unblock Cell By Admin
    [Arguments]    ${cell_name}=MRBTS-37320/NRBTS-37320/NRCELL-314
    [Documentation]    This keyword is to unblock cell by admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_name} | Yes | Cell dist name. such as MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    ...    Examples:
    ...    | unBlock Cell By Admin | MRBTS-1/NRBTS-1/NRCELL-5 |
    ...
    Log To Console    Cell ${cell_name} Unlocked
    coam.Setup Admin
    coam.UnBlock Cell    dist_name=${cell_name}
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Check Beam Info From Tti
    [Arguments]    ${name}=dlFdSchedData.beamType    ${pmi}=["PMI"]    ${log_id}=l2stream3_ttitrace
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    tcpdump_ttitrace_dl.csv    tcpdump_ttitrace_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TS_CASE_LOG_PATH}/ttitrace_streaming/${log_id}/${csv_file_name}    ${name}     ${pmi}    include    no
    ${count}    Get Length    ${data_list}
    Should be True    ${count}>0