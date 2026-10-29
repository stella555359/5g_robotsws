*** Settings ***
Documentation    Scenario Validation keywords for CB007113 subfeatures of L2 Subpooling

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    String
Library    ../libraries/load_based_validation.py    WITH NAME  CB007113
Library    ../libraries/tti_analyzer_framework/pandas_gate.py
Library    ../libraries/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer
Library    ../libraries/tti_analyzer_framework/tti_dataframe.py            WITH NAME  tti_dataframe
Library    ../libraries/tti_analyzer_framework/set_pandas.py
Library    ../libraries/harq_retransmission.py   WITH NAME  harq

*** Keywords ***
Extract TTI Trace and Convert to Pickle
    [Arguments]   ${path_to_tti_trace_pcap}
    ${events_required}=  create list  utcTimeStampData   ulTdSchedSubcellData   ulHarqRxData   dlHarqRxDataArray
    Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}

Convert TTI trace from PCAP to data frame
    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${write_to_pickle}=${False}
    Init Pandas
    ${input_file_path}=  pandas_gate.add File ending if missing  file_path=${input_file_path}  file_ending=.pcap
    ${df}    tti_dataframe.convert_tti_trace_to_df    ${input_file_path}    ${events_list}
    Run Keyword If  ${write_to_pickle}  tti_dataframe.write_df_to_pickle  df=${df}  target_path=${input_file_path}
    [Return]   ${df}

Validate Total Pooled Prbs
    [Arguments]   ${pacp_path}    ${expected_prb}
    Extract TTI Trace and Convert to Pickle     ${pacp_path}
    ${pkl_path}   Replace String  ${pacp_path}   pcap   pkl
    CB007113.verify_total_pooled_prbs    ${pkl_path}    ${expected_prb}

Validate TTITraces For Loadbase Alogorithm
    [Arguments]    ${pacp_path}    ${expected_prb}
    Extract TTI Trace and Convert to Pickle     ${pacp_path}
    ${pkl_path}   Replace String  ${pacp_path}   pcap   pkl
    CB007113.verify_TTITraces_for_loadbase   ${pkl_path}     ${expected_prb}

Validate TTITraces For Loadbase on ASOE
    [Arguments]    ${pacp_path}    ${expected_prb}
    Extract TTI Trace and Convert to Pickle     ${pacp_path}
    ${pkl_path}   Replace String  ${pacp_path}   pcap   pkl
    CB007113.verify_TTITraces_for_loadbase_on_ASOE   ${pkl_path}     ${expected_prb}

Validate MaxHarqTxNum
    [Arguments]    ${file_path}    ${cell_id}=${53}    ${Maxharqnum}=4
    ${Status}    harq.validate_maxHarqTxNum  ${file_path}/output_ul_formated.csv     ${cell_id}  ${Maxharqnum}
    Run Keyword and continue on failure   Should be True   ${Status}

Validate Payload Size
    [Arguments]    ${file_path}     ${rnti}    ${cell_id}=${53}   ${payload}=${35000}
    ${Status}    harq.validate_maxHarqTxNum_rnti  ${file_path}/output_ul_formated.csv   ${cell_id}   ${rnti}   ${payload}=32111
    Run Keyword and continue on failure   Should be True   ${Status}

Get AVG UL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pusch_ue_stats}    load_based_validation_keywords.Get PUSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pusch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PUSCH UE stats for given CC
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET PUSCH UE Stats    expected=Average
    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

GET PUSCH UE Stats
    [Arguments]     ${expected}=NR PUSCH Throughput
    ${output}    wtsrunner.Read Wtsemu Output Until Prompt    timeout=10
    ${result}    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    Log to Console    ${output}
    Log to Console    ${expected}
    should contain    ${output}    Average
    [Return]      ${output}
