*** Settings ***
Documentation  This File collects all Trace collection Keywords used in TEAL Common Keywords


Library    ../../libraries/ulm_common_library.py             WITH NAME   ucl
Library    ../../libraries/template_functions.py             WITH NAME   template
Library    ../../../../resources/Common/syslog_parser/syslog_parser.py  WITH NAME   syslog_parser
Resource   ../../../../resources/Common/bip_trace.robot
Resource   ../../../../resources/Common/bip_trace_ap.robot
Resource   ../../../../resources/Common/ttitrace.robot
Resource   ../../../../resources/Common/dcap.robot
Resource   ../../../../resources/Common/btslog.robot

*** Variables ***
${logs_and_traces_flags}  ${EMPTY}
${ts_log_dir}  ${EMPTY}
${scenario_name}  ${EMPTY}
${pCell_dict}  ${EMPTY}
${collector_names}  ${EMPTY}


*** Keywords ***

Start collection of Syscom L2 L3 trace
    IF    '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'   RETURN
    ${l2_l3_trace_collector_name}=  Set variable  syscom_l2_l3
    ucl.kwrun  Start L2_L3 SYSCOM Trace on ABIO  collector=${l2_l3_trace_collector_name}
    Set Test variable  ${l2_l3_trace_collector_name}


Stop collection of Syscom L2 L3 trace
    [Arguments]  ${syscom_trace_collector_name}
    IF    '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'   RETURN
    ucl.kwrun  Stop L2_L3 SYSCOM Trace on ABIO  collector=${l2_l3_trace_collector_name}
    ...  target_dir=${ts_log_dir}/${syscom_trace_collector_name}
    ucl.kwrun  util.Convert PCAP to PDML  source=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_tcpdump.pcap    filter="sctp"
    ...  target=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_tcpdump.pdml


Start/Stop TTI/BIP/DCAP Traces
    [Arguments]  ${call_location}  ${collector_name}
    ${tti_start_point}=  template.get_ttitrace_start_point
    ${tti_stop_point}  ${stop_delay_tti}  template.get_ttitrace_stop_point_and_delay
    ${bip_start_point}=  template.get_biptrace_start_point
    ${bip_stop_point}  ${stop_delay_bip}  template.get_biptrace_stop_point_and_delay
    ${dcap_start_point}  template.get_dcap_start_point
    ${dcap_stop_point}  template.get_dcap_stop_point
    ${bip_trace_collector_name}=  Set Variable  l1_l2_${collector_name}
    ${bip_trace_stop_points}=  Create List  failed_attach  ${bip_stop_point}
    ${tti_trace_stop_points}=  Create List  failed_attach  ${tti_stop_point}
    ${dcap_stop_points}=  Create List  failed_attach  ${dcap_stop_point}
    IF  "${call_location}"=="${tti_start_point}"    Run keyword and Continue on Failure  Start Collection of TTI Traces
    IF  "${call_location}"=="${bip_start_point}"    Start L1_L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}
    IF  "${call_location}"=="${dcap_start_point}" and "${logs_and_traces_flags['DCAP']['collection']}"=="True"
        dcap.Start DCAP Tracing  custom_profile=${logs_and_traces_flags['DCAP']['custom_profile']}
    END
    ${STOP_BIP_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${bip_trace_stop_points}  ${call_location}
    ${STOP_TTI_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${tti_trace_stop_points}  ${call_location}
    ${STOP_DCAP_TRACES}=  Run Keyword and return status
    ...  List Should Contain Value  ${dcap_stop_points}  ${call_location}
    Stop TTI and BIP Traces  ${STOP_BIP_TRACES}  ${STOP_TTI_TRACES}  ${bip_trace_collector_name}
    ...  ${stop_delay_tti}  ${stop_delay_bip}  ${STOP_DCAP_TRACES}


Start L1_L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Run Keyword And Warn On Failure  Start Collection Of Airphone L1 L2 Traces  bip_trace_collector_name=ue_${bip_trace_collector_name}
    Run Keyword And Warn On Failure  Start Collection Of GNB L1 L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}



Stop TTI and BIP Traces
    [Arguments]  ${STOP_BIP_TRACES}  ${STOP_TTI_TRACES}  ${bip_trace_collector_name}  ${stop_delay_tti}  ${stop_delay_bip}
    ...  ${STOP_DCAP_TRACES}
    IF  ${STOP_BIP_TRACES}  Sleep    ${stop_delay_bip}  reason=Wait for the delay set by the user in the JSON
    IF  ${STOP_BIP_TRACES}  Stop L1_L2 Traces  bip_trace_collector_name=${bip_trace_collector_name}
    IF  ${STOP_TTI_TRACES}  Sleep    ${stop_delay_tti}  reason=Wait for the delay set by the user in the JSON
    IF  ${STOP_TTI_TRACES}  Stop Collection of TTI Traces
    IF  ${STOP_DCAP_TRACES} and "${logs_and_traces_flags['DCAP']['collection']}"=="True"  ucl.kwrun  dcap.Stop DCAP Tracing


Stop L1_L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    Run Keyword And Warn On Failure  Stop Collection Of GNB L1 L2 Traces
    ...  bip_trace_collector_name=${bip_trace_collector_name}
    Run Keyword And Warn On Failure  Stop Collection Of Airphone L1 L2 Traces
    ...  bip_trace_collector_name=ue_${bip_trace_collector_name}


Start X2 and L2 L3 Syscom Trace and Syslogs
    Run Keyword And Warn On Failure  Start X2 Trace Collection
    Run Keyword And Warn On Failure  Prepare And Start Syslogs
    Run Keyword And Warn On Failure  Start Collection Of Syscom L2 L3 Trace


Start Collection of Airphone L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    IF    '${logs_and_traces_flags['BIPTrace']['AP_L1L2BIPTrace']}'=='False'   RETURN
    Run Keyword And Warn On Failure    ucl.kwrun  bip_trace_ap.Start Airphone BIP Traces  collector=ue_${bip_trace_collector_name}


Stop Collection of Airphone L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    IF    '${logs_and_traces_flags['BIPTrace']['AP_L1L2BIPTrace']}'=='False'   RETURN
    Run Keyword And Warn On Failure  ucl.kwrun  bip_trace_ap.Stop Airphone BIP Traces
    ...  collector=ue_${bip_trace_collector_name}
    ...  target_dir=${ts_log_dir}


Start Collection of TTI Traces
    IF    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'   RETURN
    ucl.kwrun  ttitrace.Start TTI Trace generation  tti_trace_collector_name=${tti_collector_dict['${scenario_name}']}


Stop Collection of TTI Traces
    IF    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'   RETURN
    ucl.kwrun  ttitrace.Stop TTI Trace generation  tti_trace_collector_name=${tti_collector_dict['${scenario_name}']}


Start Collection of gNB L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    IF    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}' == 'False'   RETURN
    Run Keyword And Warn On Failure    ucl.kwrun  bip_trace.Start BIP Traces           collector=${bip_trace_collector_name}


Stop Collection of gNB L1 L2 Traces
    [Arguments]  ${bip_trace_collector_name}
    IF    '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}' == 'False'   RETURN
    Run Keyword And Warn On Failure  ucl.kwrun  bip_trace.Stop BIP Traces
    ...  collector=${bip_trace_collector_name}
    ...  target_dir=${ts_log_dir}


Start X2 Trace Collection
    IF    '${logs_and_traces_flags['X2Trace']}' == 'False'   RETURN
    ${backhaul_collector}=  Run Keyword And Continue On Failure    ucl.kwrun  tcpdump.Start Tcpdump on TestPC   options=-i eth3 -U sctp
    set test variable  ${backhaul_collector}


Stop X2 Trace Collection
    [Arguments]  ${s1x2_logs_collector_name}
    IF    '${logs_and_traces_flags['X2Trace']}' == 'False'   RETURN
    Run Keyword And Warn On Failure  Stop Backhaul Trace Capture And Covert Trace To PDML
    ...  s1x2_logs_collector_name=${s1x2_logs_collector_name}


Collect WTS Logs
    IF    '${logs_and_traces_flags['WtsLogs']}'=='False'   RETURN
    ucl.kwrun  wts_ue.Collect egate log files  target_dir=${ts_log_dir}
    ucl.kwrun  wts_ue.Collect edaemon log files  target_dir=${ts_log_dir}


Stop X2 Syscom Traces and Stop Btslog collection
    [Arguments]  ${collector_name}
    ${s1x2_logs_collector_name}=  set variable  s1x2_${collector_name}
    ${btslog_collector_name}=     set variable  btslog_${collector_name}
    Run Keyword And Warn On Failure  Stop X2 Trace Collection  s1x2_logs_collector_name=${s1x2_logs_collector_name}
    Run Keyword And Warn On Failure  Stop BTSLog Collection   bts_log_collector_name=${btslog_collector_name}
    Run Keyword And Warn On Failure  Stop Collection Of Syscom L2 L3 Trace   syscom_trace_collector_name=syscom_l2_l3_${collector_name}


Stop Backhaul trace capture and covert trace to PDML
    [Arguments]  ${s1x2_logs_collector_name}
    ${status}    Run Keyword And Return Status    Directory Should Exist     ${TS_LOG_DIR}/${s1x2_logs_collector_name}
    IF    ${status}
        Log    X2 Trace seems to be already collected. Not collecting again.   console=yes
        RETURN
    END
    ${path_to_tcpdump}=    ucl.kwrun  Stop Tcpdump on TestPc
    ...  collector=${backhaul_collector}
    ...  target_dir=${ts_log_dir}/${s1x2_logs_collector_name}
    ucl.kwrun  util.Convert PCAP to PDML  source=${path_to_tcpdump}
    ...  filter="x2ap"
    ...  target=${ts_log_dir}/${s1x2_logs_collector_name}/backhaul.pdml


Check if TTI Trace needs to be Reinitialized
    [Arguments]  ${re_init}=${True}
    ${tti_init_required}=  Evaluate  ${gnb_rebooted} or not ${re_init}
    ${gnb_rebooted}=  Set Variable if  ${gnb_rebooted}  ${False}
    Set Suite Variable  ${gnb_rebooted}
    RETURN  ${tti_init_required}


Create TTI-Trace Collectors for all Scenarios
    [Arguments]  ${scenario_names}
    IF    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'   RETURN
    ${phy_cell_ids}=  Get Dictionary Values  ${pCell_dict}  sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,    @{phy_cell_ids}
    ${phy_cell_ids}=  Set Variable if  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}  ${logs_and_traces_flags['TTITrace']['phy_cell_ids']}

    ${source_ip}=   ucl.kwrun   Get Source IP Address For Classical BTS
    ${dest_ip}=     ucl.kwrun   Get Target IP Address For Classical Bts   source_ip_address=${source_ip}

    &{tti_collector_dict}=  Create Dictionary
    Set Suite Variable    ${tti_collector_dict}
    FOR    ${scenario_name}    IN   @{scenario_names}
        ${collector}=  ucl.kwrun  ttitrace.Create TTI Trace Collector
        ...    nr_phy_cell_ids=${phy_cell_ids}
        ...    dest_ip=${dest_ip}
        ...    tti_trace_filename=ttitrace_streaming_${scenario_name}
        ...    tti_filter=${logs_and_traces_flags['TTITrace']['tti_filter']}
        Set To Dictionary  ${tti_collector_dict}  ${scenario_name}=${collector}
    END


Collect TTI-Traces For all Scenarios
    [Arguments]  ${scenario_names}  ${collector_dict}
    IF    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'   RETURN
    FOR    ${scenario_name}    IN    @{scenario_names}
        ${kw_status}=    run keyword and return status
        ...    ucl.kwrun    ttitrace.Collect TTI Trace and teardown collectors
        ...                     desired_file_name=ttitrace_streaming_${scenario_name}
        ...                     desired_storage_directory=${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}
        IF    not ${kw_status}    log    Collect TTI Trace and teardown collectors on ${scenario_name} FAILED!    level=ERROR
        Run Keyword And Warn On Failure
        ...    OperatingSystem.Move File
        ...        ${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}/ttitrace_streaming_${scenario_name}.pcap
        ...        ${ts_log_dir}/tti_trace_${collector_dict["${scenario_name}"]["collector_name"]}/ttitrace_streaming.pcap
    END

Process TTI Traces for all scenarios
    IF    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'   RETURN
    FOR    ${collector}    IN    @{collector_names}
        log    processing tti traces for collector: ${collector}
        ${status}=    run keyword and return status    Convert TTI Traces to CSV  collector=${collector}
        IF    not ${status}    log    Convert TTI Traces to CSV failed in ${collector} FAILED!    level=ERROR
        ${status}=    run keyword and return status    Convert TTI Traces to filtered JSON    collector=${collector}
        IF    not ${status}    log    Convert TTI Traces to filtered JSON in ${collector} FAILED!    level=ERROR
        ${status}=    run keyword and return status    Convert TTI Traces to Dataframe and store as pickle    collector=${collector}
        IF    not ${status}    log    Convert TTI Traces to Dataframe and store as pickle in ${collector} FAILED!    level=ERROR
    END


Convert TTI Traces to CSV
    [Arguments]  ${collector}  ${size_per_file_bytes}=${30000000}
    IF    '${logs_and_traces_flags['TTITrace']['conversion']['excelCsv']}'=='False'   RETURN
    ${file_size_bytes}=  Get File Size  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ${num_of_splits}=  Evaluate  int(math.ceil(float(${file_size_bytes})/float(${size_per_file_bytes})))  math
    log to console  TTI Trace will be split into ${num_of_splits} files
    IF  ${num_of_splits}>${1}  Split and convert PCAP Files to CSV
    ...  collector=${collector}
    ...  num_of_splits=${num_of_splits}
    ...  size_per_file_bytes=${size_per_file_bytes}  ELSE  Convert unsplit file from pcap to csv  collector=${collector}


Split and convert PCAP Files to CSV
    [Arguments]  ${collector}  ${num_of_splits}  ${size_per_file_bytes}
    Prepare and split pcap to smaller files
    ...  collector=${collector}
    ...  size_per_file_bytes=${size_per_file_bytes}
    Convert split pcap file to csv  collector=${collector}  num_of_splits=${num_of_splits}


Convert split pcap file to csv
    [Arguments]  ${collector}  ${num_of_splits}
    Log to console  Converting TTI Trace to excel CSV: 1/${num_of_splits}
    Run keyword and continue on failure  ucl.kwrun  Convert TTI trace from pcap to excelCsv
    ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap
    ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_split_0
    FOR  ${split_itr}  IN RANGE  1  ${num_of_splits}
        Run keyword and continue on failure  ucl.kwrun  Convert TTI trace from pcap to excelCsv
        ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap${split_itr}
        ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_split_${split_itr}
        Log to console  Converting TTI Trace to excel CSV: ${split_itr + ${1}}/${num_of_splits}
    END


Convert unsplit file from pcap to csv
    [Arguments]  ${collector}
    Run keyword and continue on failure  ucl.kwrun  Convert TTI trace from pcap to excelCsv
    ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_${collector}


Prepare and split pcap to smaller files
    [Arguments]  ${collector}  ${size_per_file_bytes}
    ${tti_source_file}=  Set variable  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ${tti_split_destination_file}=  Set variable  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap
    ${size_per_file_MB}=  Evaluate  int(${size_per_file_bytes}/${1000000})
    Split PCAP File  source_path=${tti_source_file}  destination_split_path=${tti_split_destination_file}
    ...  size_per_split_MB=${size_per_file_MB}


Split PCAP File
    [Arguments]  ${source_path}  ${destination_split_path}  ${size_per_split_MB}
    OperatingSystem.Run   tcpdump -r ${source_path} -w ${destination_split_path} -C ${size_per_split_MB}


Convert TTI Traces to filtered JSON
    [Arguments]  ${collector}
    IF    '${logs_and_traces_flags['TTITrace']['conversion']['filtered_json']}'=='False'   RETURN
    Run keyword and continue on failure  Extract TTI Trace and Convert to JSON
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  target_directory=${ts_log_dir}/tti_trace_${collector}


Convert TTI Traces to Dataframe and store as pickle
    [Arguments]  ${collector}
    IF    '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'   RETURN
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap


Stop and collect running traces
    [Arguments]  ${collector_name}  ${scenario_name}
    log to console  Traces are being collected for ${scenario_name}
    run keyword and continue on failure  Start/Stop TTI/BIP/DCAP Traces  call_location=after_detach
                ...  collector_name=${collector_name}
    Stop X2 Syscom Traces and Stop Btslog collection    ${collector_name}


Prepare And Start Syslogs
    IF    ${SYSLOG_PREPERATION_NEEDED}
        ucl.kwrun  btslog.Prepare CPlane Component Log Level
        Set Suite Variable  ${SYSLOG_PREPERATION_NEEDED}    ${False}
    END
    ucl.kwrun  btslog.Start Btslog


Stop BTSLog Collection
    [Arguments]  ${bts_log_collector_name}
    Create Directory  ${ts_log_dir}/${bts_log_collector_name}
    ucl.kwrun  Stop Btslog  target_dir=${ts_log_dir}/${bts_log_collector_name}
    OperatingSystem.Run    rm -rf /tmp/btslog2/*
    Analyze Syslog With Syslog Parser    ${bts_log_collector_name}


Analyze Syslog With Syslog Parser
    [Arguments]    ${bts_log_collector_name}
    ${files}=    OperatingSystem.List Files In Directory    ${ROBOT_SUITE_DIR}
    ${testsuite_path}=    String.Split String    ${ROBOT_SUITE_DIR}    Ulm
    ${exception_file}=    Set Variable If    'SYSLOG_ERROR_EXCEPTION.TXT' in ${files}
    ...  ${robot_suite_dir}/SYSLOG_ERROR_EXCEPTION.TXT    ${testsuite_path[${0}]}/Ulm/ET/L2/syslog_parser_resources/SYSLOG_ERROR_EXCEPTION.TXT
    ${error_array}=    Set Variable If    'SYSLOG_ARRAY.TXT' in ${files}
    ...  ${robot_suite_dir}/SYSLOG_ARRAY.TXT    ${testsuite_path[${0}]}/Ulm/ET/L2/syslog_parser_resources/SYSLOG_ARRAY.TXT
    ${required_file}=    Set Variable If    'SYSLOG_ERROR_REQUIREMENT.TXT' in ${files}
    ...  ${robot_suite_dir}/SYSLOG_ERROR_REQUIREMENT.TXT    None
    ${syslog_path}=
    ...  Run Keyword And Continue On Failure    syslog_parser.find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...  ${ts_log_dir}/${bts_log_collector_name}/btslog_gnb0/syslog_files.tgz
    ...  ignorefname=${exception_file}
    ...  requirementfname=${required_file}
    ...  errordeffname=${error_array}

    # If suite variable doesn't exist, create it as an empty list
    ${syslog_output_list_value}=    Get Variable Value    $SYSLOG_PARSER_OUTPUT_LIST
    IF  $syslog_output_list_value is None
        Set Suite Variable    @{SYSLOG_PARSER_OUTPUT_LIST}    @{EMPTY}
    END
    Append To List    ${SYSLOG_PARSER_OUTPUT_LIST}    ${syslog_path}


Check For Errors In Syslog
    ${syslog_path_value}=    Get Variable Value    $SYSLOG_PARSER_OUTPUT_LIST
    IF  $syslog_path_value is not None
        FOR    ${syslog_path}    IN    @{SYSLOG_PARSER_OUTPUT_LIST}
            ${matches}=    OperatingSystem.Grep File    ${syslog_path}    ERR/
            Run Keyword And Continue On Failure    Should Be Empty    ${matches}    msg=ERR prints in syslog!
        END
    ELSE
        Log    No syslog available for checking ERR prints!    WARN
    END
