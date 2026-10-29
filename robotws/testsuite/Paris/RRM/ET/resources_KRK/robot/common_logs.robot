*** Settings ***
Documentation
...   author: Adrianna Pienkowska
...   contact: adrianna.pienkowska@nokia.com
...   description: Krakow Verification Engineering team for collecting logs

Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ute_tshark
Library     ../Python/utilities.py                                           WITH NAME       utilities__
Library    ../Python/slice_scheduling/logs.py                                WITH NAME       logs__

Resource    TtiTrace/tti_trace_collector.robot

*** Keywords ***

NG Start
    [Arguments]   ${options}=-i eth3
    logs__.ng_link_logs_start
    ...    options=${options}

NG Stop
    logs__.ng_link_logs_stop

Collect Counters
    [Arguments]  ${counter_list}  ${output_csv_dir}=${None}  ${save_logs}=${True}  ${prefix}=${None}  ${pm_period}=5  ${json}=${True}
    ...          ${json_prefix}=${None}
    logs__.collect_bts_kpi_counters
    ...    counter_list=${counter_list}
    ...    output_csv_dir=${output_csv_dir}
    ...    save_logs=${save_logs}
    ...    prefix=${prefix}
    ...    pm_period=${pm_period}
    ...    json=${json}
    ...    json_prefix=${json_prefix}

SYSCOM Start
    logs__.start_syscom_collection

SYSCOM Stop
    logs__.stop_syscom_collection

SYSLOG Start
    logs__.start_syslog_capture

SYSLOG Stop
    logs__.stop_syslog_capture

SHERPA Start
    [Arguments]    ${extended}=${False}
    logs__.start_sherpa_capture
    ...    extended=${extended}

SHERPA Stop
    logs__.stop_sherpa_capture

BIP Start
    logs__.start_bip_capture

BIP Stop
    logs__.stop_bip_capture

TTI Start
    [Arguments]   ${yaml_config_path}=${CURDIR}/TtiTrace/tti_trace_collectors.yaml
    utilities__.logger_console
    ...    Starting TTi Trace Collection
    tti_trace_collector.Start TTI trace collection
    ...    collector_name=${COLLECTOR_NAME}
    ...    yaml_config_path=${yaml_config_path}
    logs__.create_logs_dict
    ...    required_logs=TTI

TTI Stop
    Create Directory
    ...    ${OUTPUT_DIR_TC}/TTI
    utilities__.logger_console
    ...    Stoping TTi Trace Collection
    tti_trace_collector.Stop TTI Trace Collection
    ...    collector_name=${COLLECTOR_NAME}
    ...    target_path=${OUTPUT_DIR_TC}/TTI
    tti_trace_collector.Relocate TTI Traces Collected
    ...    collector_name=${COLLECTOR_NAME}
    ...    target_path=${OUTPUT_DIR_TC}/TTI

TTI Stop And Convert
    TTI Stop
    TTI Convert To JSON
    ...    tti_pcap_path=${OUTPUT_DIR_TC}/TTI/tcpdump.pcap
    # Run Keyword And Ignore Error     TTI Convert To CSV
    # ...    tti_pcap_path=${OUTPUT_DIR_TC}/TTI/tcpdump.pcap
    logs__.change_tti_trace_log_pcap_name
    ...    file_path=${OUTPUT_DIR_TC}/TTI/tcpdump.pcap
    logs__.save_log_paths
    ...    logs_type=TTI

TTI Convert To JSON
    [Arguments]    ${tti_pcap_path}
    Create Directory
    ...    ${OUTPUT_DIR_TC}/TTI_JSON
    Convert TTI trace from pcap
    ...    format=json
    ...    source_file_path=${tti_pcap_path}
    ...    target_files_path=${OUTPUT_DIR_TC}/TTI
    logs__.change_tti_trace_log_pcap_name
    ...    file_path=${OUTPUT_DIR_TC}/TTI/output.json
    ...    destination_dir=${OUTPUT_DIR_TC}/TTI_JSON
    logs__.save_log_paths
    ...    logs_type=TTI_JSON

TTI Convert To CSV
    [Arguments]    ${tti_pcap_path}
    Create Directory
    ...    ${OUTPUT_DIR_TC}/TTI_CSV_UL
    Create Directory
    ...    ${OUTPUT_DIR_TC}/TTI_CSV_DL
    Convert TTI trace from pcap
    ...    source_file_path=${tti_pcap_path}
    ...    target_files_path=${OUTPUT_DIR_TC}/TTI/
    BuiltIn.sleep    10
    logs__.change_tti_trace_log_pcap_name
    ...    file_path=${OUTPUT_DIR_TC}/TTI/output_dl.csv
    ...    destination_dir=${OUTPUT_DIR_TC}/TTI_CSV_DL
    logs__.change_tti_trace_log_pcap_name
    ...    file_path=${OUTPUT_DIR_TC}/TTI/output_ul.csv
    ...    destination_dir=${OUTPUT_DIR_TC}/TTI_CSV_UL
    logs__.save_log_paths
    ...    logs_type=TTI_CSV_UL
    logs__.save_log_paths
    ...    logs_type=TTI_CSV_DL

TTI BIP SYSLOG Start
    [Arguments]    ${tti_config}=${CURDIR}/TtiTrace/tti_trace_collectors.yaml
    SYSLOG Start
    BIP Start
    TTI Start
    ...    yaml_config_path=${tti_config}

SHERPA BIP SYSLOG Start
    [Arguments]    ${extended_sherpa}=${True}
    SYSLOG Start
    BIP Start
    SHERPA Start
    ...     extended=${extended_sherpa}

BIP SYSLOG Start
    SYSLOG Start
    BIP Start

TTI BIP SYSLOG Stop
    SYSLOG Stop
    BIP Stop
    TTI Stop
    logs__.save_log_paths
    ...    logs_type=TTI

SHERPA BIP SYSLOG Stop
    SYSLOG Stop
    SHERPA Stop
    BIP Stop

SHERPA SYSLOG Stop
    SYSLOG Stop
    SHERPA Stop

TTI BIP SYSLOG Stop And Convert TTI
    SYSLOG Stop
    BIP Stop
    TTI Stop And Convert

BIP SYSLOG Stop
    SYSLOG Stop
    BIP Stop
