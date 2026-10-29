*** Settings ***
Documentation
...    | Team:         |  CSV Ulm                                     |
...    | Contact:      |  I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com    |
...    | Description:  |  Common Keywords used in CSV testcases       |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    OperatingSystem

Resource   ../../../../Ulm/resources/Common/btslog.robot
Resource   ../../../../Ulm/resources/Common/tcpdump.robot
Resource   ../../../../Ulm/resources/Common/wts_ue.robot



*** Variables ***

${WITH_PCAP_TO_PDML_CONVERSION}               ${TRUE}       # [INFO] ${TRUE} or ${FALSE}
${WITH_SYSLOGS}                               ${TRUE}       # [INFO] ${TRUE} or ${FALSE}
${WITH_WTS_LOGS}                              ${TRUE}       # [INFO] ${TRUE} or ${FALSE}



*** Keywords ***

Collect WTS Logs
    IF    ${WITH_WTS_LOGS}    wts_ue.Collect Egate Log Files  target_dir=${ts_log_dir}/wts_${TEST_NAME}


Start X2 And L2 L3 Syscom Trace And Syslogs
    Run Keyword And Ignore Error    Start X2 Trace Collection
    IF    ${WITH_SYSLOGS}    Run Keyword And Ignore Error    Prepare And Start Syslogs


Stop X2 Syscom Traces And Stop Btslog Collection
    Run Keyword And Ignore Error    Stop X2 Trace Collection    s1x2_logs_collector_name=s1x2_${TEST_NAME}
    IF    ${WITH_SYSLOGS}    Run Keyword And Ignore Error    Stop BTSLog Collection    bts_log_collector_name=btslog_${TEST_NAME}


Start X2 Trace Collection
    ${backhaul_collector}    Run Keyword And Continue On Failure
    ...    tcpdump.Start Tcpdump On TestPC    options=-i ${ETHERNET_IF_FOR_WTS} -s0 'sctp or udp port 500 or esp'
    Set Test Variable    ${backhaul_collector}


Stop X2 Trace Collection
    [Arguments]  ${s1x2_logs_collector_name}
    ${output}    Run Keyword And Ignore Error    tcpdump.Stop Tcpdump On TestPc    collector=${backhaul_collector}
    ...                                                                            target_dir=${ts_log_dir}/${s1x2_logs_collector_name}
    IF    '${output[${0}]}'!='PASS'   RETURN
    IF    ${WITH_PCAP_TO_PDML_CONVERSION}    util.Convert PCAP To    format=PSML
    ...                                                              source=${output[${1}]}
    ...                                                              target=${ts_log_dir}/${s1x2_logs_collector_name}/backhaul.psml
    IF    ${WITH_PCAP_TO_PDML_CONVERSION}    util.Convert PCAP To    format=TABS
    ...                                                              source=${output[${1}]}
    ...                                                              target=${ts_log_dir}/${s1x2_logs_collector_name}/backhaul.tabs


Prepare And Start Syslogs
    btslog.Create CPlane Runtime File To gNB
    btslog.Start Btslog


Stop BTSLog Collection
    [Arguments]  ${bts_log_collector_name}
    Create Directory    ${ts_log_dir}/${bts_log_collector_name}
    btslog.Stop Btslog    target_dir=${ts_log_dir}/${bts_log_collector_name}


Start Collection Of Syscom L2 L3 Trace
    tcpdump.Start L2_L3 SYSCOM Trace On ABIO    collector=syscom_l2_l3


Stop Collection Of Syscom L2 L3 Trace
    [Arguments]  ${syscom_trace_collector_name}
    tcpdump.Stop L2_L3 SYSCOM Trace On ABIO    collector=syscom_l2_l3    target_dir=${ts_log_dir}/${syscom_trace_collector_name}
    IF    ${WITH_PCAP_TO_PDML_CONVERSION}    util.Convert PCAP To PDML    source=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_tcpdump.pcap
    ...                                                                   filter="sctp"
    ...                                                                   target=${ts_log_dir}/${syscom_trace_collector_name}/l2_l3_tcpdump.pdml


Create TTI-Trace Collectors For All Scenarios
    Log Variables
    ${source_ip}   Get Source IP Address For Classical BTS
    ${dest_ip}     Get Target IP Address For Classical BTS   source_ip_address=${source_ip}
    &{tti_collector_dict}    Create Dictionary
    Set Suite Variable    ${tti_collector_dict}
    ${collector}    ttitrace.Create TTI Trace Collector    nr_phy_cell_ids=${phy_cell_ids_on_the_testline}
    ...                                                    dest_ip=${dest_ip}
    ...                                                    tti_trace_filename=ttitrace_streaming_${TEST NAME}
    Set To Dictionary    ${tti_collector_dict}    ${scenario_name}=${collector}
    Append To List    ${collector_names}    ${collector}
    Log    ${collector_names}


Extract TTI Trace And Convert To Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}  Create List  utcTimeStampData     ulTdSchedSubcellData
    ...                              ulHarqRxData         dlHarqRxDataArray
    ...                              dlFdSchedData        ulFdSchedData
    ...                              dlLaDeltaCqiArray    ulLaDeltaSinr
    ...                              laIniDelta           csiSrReportData
    ...                              dlFdSchedAdditionalData
    ${df}    Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                  events_list=${events_required}
    ...                                                  write_to_pickle=${TRUE}
    ${target_path}    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI Trace From Data Frame To Csv    ${df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_ul_dl.csv


Save Resource Usage To File
    [Arguments]  ${collection_point}
    taf.ccs.aashell.Create Aashell Cli    name=aashell
    taf.ccs.aashell.Setup    aashell
    ${resources_usage}    taf.ccs.aashell.Get Resources Usage    aashell
    OperatingSystem.Create Directory    ${ts_log_dir}/resource_stats_${TEST_NAME}
    ${json_path}    builtin.Set Variable    ${ts_log_dir}/resource_stats_${TEST_NAME}/${collection_point}.json
    ${json_string}    Evaluate    json.dumps(${resources_usage}, sort_keys=True, indent=4)    modules=json
    OperatingSystem.Create File    ${json_path}    ${json_string}
    [Teardown]  taf.ccs.aashell.Teardown  aashell
