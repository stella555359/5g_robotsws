*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/${log_idx}
    Check DTXNACK Rate    log_id=${log_idx}
    Check UL DTXCRC Rate    log_id=${log_idx}

Check DTXNACK Rate
    [Arguments]    ${log_id}=1    ${expect_rate}=0.1
    Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

Check UL DTXCRC Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.1
    Check Rate    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]    ${log_id}    ${expect_rate}
    Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK","NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=1    ${expect_rate}=0.1
    ${sub_nm}=    Get Substring    ${name}    0    2
    ${csv_files}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}    output_${sub_nm}.\[0\-9\].csv    ${True}
    FOR    ${index}    ${csv_file_name}    IN ENUMERATE    @{csv_files}
        ${total_data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
        ...    ${csv_file_name}    ${name}    ${total}    include    no
        ${total_count}    Get Length    ${total_data_list}
        ${failed_data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
         ...    ${csv_file_name}    ${name}     ${failed}    include    no
        ${failed_count}    Get Length    ${failed_data_list}
        ${rate}    Evaluate    float(${failed_count})/(${total_count})
        Log To Console    \n${name} rate is ${rate}\n
        Should Be True    ${rate}<${expect_rate}
    END

Single Ue Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
