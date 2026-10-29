*** Settings ***
Documentation    Scenario Validation keywords for CNI-116926 feature

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    String
Library    ../libraries/CNI116926_validation.py                      WITH NAME  CNI116926
Resource   ../../../resources/Common/ttitrace.robot



*** Keywords ***

Verify L3Call_MUE_on_SingleCell_with_Reesteblishments
    Prepare Variables for Validation    scenario_1
    Run Keyword And Continue On Failure   CNI116926.Verify TTITraces For RaState  cell=1  num_of_ues=40  ue_type=nsa  procedure_type=attach
    Run Keyword And Continue On Failure   CNI116926.Verify TTITraces For RaState  cell=2  num_of_ues=1   ue_type=sa   procedure_type=attach+reest
    Run Keyword And Continue On Failure   CNI116926.Verify TTITraces For RaState  cell=3  num_of_ues=40  ue_type=nsa  procedure_type=attach
    Run Keyword And Continue On Failure   CNI116926.Verify TTITraces For RaState  cell=4  num_of_ues=1   ue_type=sa   procedure_type=attach+reest


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Prepare Variables For Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.Get Collector Name  scenario_name=${scenario}
    Set Test Variable  ${path_to_ttitrace_json}  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    Set Test Variable  ${path_to_ttitrace_pkl}   ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    Set Test Variable  ${path_to_syscom_pdml}    ${ts_log_dir}/cell_setup_trace_initial/l2_l3_tcpdump.pdml
    Set Test Variable  ${path_to_scf_xml}        ${configuration_directory}/scf_${scenario}.xml
    Set Test Variable  ${path_to_syslog_tgz}     ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0/syslog_files.tgz
    Set Test Variable  ${pm_counters_dir}        ${ts_log_dir}/PMC/gnb_pm_counters/

    ${nrbts_str}=  Get DistNames From GNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  Get UE Ids Configured For Scenario  scenario_name=${scenario}
    Set Test Variable  ${nrbts_str}
    Set Test Variable  ${attached_ues}
    Set Test Variable  ${scenario}
    Set SW Duplex Variable According To CellTechnology
    Set SW Wavelength Variable According To Nrarfcn


Extract TTI Trace And Convert To JSON
     [Arguments]  @{varargs}
     RETURN


Extract TTI Trace And Convert To Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List  utcTimeStampData                     preambleData
    ...                               ulHarqRxData                         dlHarqRxDataArray
    ...                               dlPreSchedData                       ulPreSchedData
    ${eventdecoder_stdout_path}    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_stdout.log
    ${df}=  ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                         events_list=${events_required}
    ...                                                         write_to_pickle=${TRUE}
    ...                                                         eventdecoder_stdout_path=${eventdecoder_stdout_path}
    ${target_path}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI trace From Data Frame To Csv    ${df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_ul_dl.csv
