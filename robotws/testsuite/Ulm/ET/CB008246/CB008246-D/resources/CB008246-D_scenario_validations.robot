*** Settings ***
Documentation    Scenario Validation keywords for subfeature CB008246-D

Library    taf.config.scf                                                                           WITH NAME   scf
Library    ../../../../resources/Common/python/tti_analyzer_framework/tti_dlharqmatcher.py
Library    ../../../L2/libraries/template_functions.py                                              WITH NAME   template
Library    ../../../resources/SQD66/pmc_analysis.py                                                 WITH NAME   pmc
Library    ../../libraries/ttitrace_analysis.py                                                     WITH NAME   ttitrace_analysis



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  create list    csiSrReportData
    ...                                 dlFdSchedData
    ...                                 dlHarqRxDataArray
    ...                                 dlLaAverageCqi
    ...                                 dlLaDeltaCqiArray
    ...                                 dlLaSwitchBetweenHrAndBr
    ...                                 dlFdSchedAdditionalData

    ${eventdecoder_stdout_path}=    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_stdout.log
    ${df}=    ttitrace.Convert TTI Trace From PCAP To Data Frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                           events_list=${events_required}
    ...                                                           eventdecoder_stdout_path=${eventdecoder_stdout_path}
    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${df}
    ${dlharq_target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dlharq.pkl
    tti_dataframe.write_df_to_pickle  df=${dlharq_matcher_df}    target_path=${dlharq_target_path}
    ${filtered_csv_target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI trace from data frame to csv    ${dlharq_matcher_df}   ${filtered_csv_target_path}
    ...                                                  tti_trace_filename=filtered_ttitrace.csv

Prepare Variables for validations
    [Arguments]    ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    Set Test Variable    ${syslog_dir}    ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0
    ${path_to_json}=  Set Variable  ${ts_log_dir}/tti_trace_${collector_name}/tti_data.json
    ${path_to_ttitrace_pkl}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlharq.pkl
    ${path_to_RRC_Reconfig}=  Set Variable  ${ts_log_dir}/s1x2_${collector_name}/backhaul.pdml
    ${tti_trace_folder}=  Set Variable  ${ts_log_dir}/tti_trace_${collector_name}/
    ${pm_counters_dir}=  Set Variable  ${ts_log_dir}/PMC/gnb_pm_counters
    ${is_with_pm_counters}=  template.is_with_pm_counters  ${scenario}
    ${pmc_index}=  IF  ${is_with_pm_counters}  tools.get_pmc_index
    ...    scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}    ts_log_dir=${ts_log_dir}
    Set Test Variable  ${path_to_json}
    Set Test Variable  ${path_to_RRC_Reconfig}
    Set Test Variable  ${pm_counters_dir}
    Set Test Variable  ${path_to_ttitrace_pkl}
    Set Test Variable  ${tti_trace_folder}
    ${SW_DUPLEX}=    Set Variable if  'TDD' in '${scenario}'    TDD    FDD
    Set Suite Variable    ${SW_POSTFIX}    ${SW_DUPLEX}  # ${SW_POSTFIX} is used for RP, uncomment it when putting the case to Regression
    IF  ${is_with_pm_counters}  Set Test Variable  ${pmc_index}
    ${DICT_NUMBER_OF_UE_LIST_PER_CELL}=  template.Get_Total_Number_Of_UEs_Configured_Per_Cell  scenario_name=${scenario_name}
    Set Test Variable  ${DICT_NUMBER_OF_UE_LIST_PER_CELL}
    Get Config Info for cOAM


#--------------  PM Counter KWs   ---------------------------------------------------------------------------------------------------[150 characters]

Verify CB008246 DL PM Counters
    ${numTx_FDD}    Set Variable If    any(x in '${SW_BUILD}' for x in ['25R3', '26R1'])    2   4
    FOR    ${cell}   IN    @{DICT_NUMBER_OF_UE_LIST_PER_CELL}
        # numTx is depending on scf parameter dlMimoMode, for TDD cell we have scf value "4x4 or 4x2 Closed Loop Spatial Multiplexing"
        # and for FDD cell we have starting with 26R2 scf value "4x4 or 4x2 Closed Loop Spatial Multiplexing" and before 26R2 we have
        # for FDD cell scf value "2x2 Open Loop Spatial Multiplexing"
        ${numTx}    Set Variable If    ${cell}==1 or ${cell}==2    4    ${numTx_FDD}
        Verify Legacy DL PM Counters    cell=${cell}  numTx=${numTx}
        Verify New DL PM Counters    cell=${cell}
    END


Verify Legacy DL PM Counters
    [Arguments]    ${cell}    ${numTx}=${4}
    ${expected_values}=    ttitrace_analysis.get_expected_dl_pmc_values_4tx    ${path_to_ttitrace_pkl}    cell=${cell}
    ${expected_pmc_dict}=    Create Dictionary for Rank Related PMC    ${expected_values}    ${numTx}
    ${actual_values}=    Get Actual PMC Values    ${expected_pmc_dict}    ${cell}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_pmc_dict}    rel_tol=0.01
    ${expected_mcs_pmc_values}=    ttitrace_analysis.get_expected_legacy_mcs_pmc_values    ${path_to_ttitrace_pkl}    dir=dl    subfeature=D
    ...    cell=${cell}
    ${actual_mcs_pmc_values}=    Get Actual PMC Values    ${expected_mcs_pmc_values}    ${cell}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_mcs_pmc_values}    ${expected_mcs_pmc_values}    abs_tol=3


Verify New DL PM Counters
    [Arguments]    ${cell}
    ${max_dl_harq_tx}=    scf.Get_Value_From_Scf    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-${${cell} -1}    p_name=maxDlHarqTx
    ${max_ul_harq_tx}=    scf.Get_Value_From_Scf    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-${${cell} -1}    p_name=maxUlHarqTx
    ${expected_values}=    ttitrace_analysis.get_expected_new_pmc_values    ${path_to_ttitrace_pkl}    dir=dl    subfeature=D    cell=${cell}
    ...    max_dl_harq_tx=${max_dl_harq_tx}    max_ul_harq_tx=${max_ul_harq_tx}    sw_build=${SW_BUILD}
    ${actual_values}=    Get Actual PMC Values    ${expected_values}    ${cell}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_values}    rel_tol=0.01
    ${expected_pmc_values_dict}=    ttitrace_analysis.Get_Expected_Mcs_New_Pmc_Values    ${path_to_ttitrace_pkl}    dir=dl    cell=${cell}
    ...    max_dl_harq_tx=${max_dl_harq_tx}    max_ul_harq_tx=${max_ul_harq_tx}
    ${actual_values}=    Get Actual PMC Values    ${expected_pmc_values_dict}[0]    ${cell}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_pmc_values_dict}[0]    rel_tol=0.01
    ...    description=${expected_pmc_values_dict}[1]


Get Actual PMC Values
    [Arguments]    ${pmc_dict}    ${cell}
    ${pi_list}=    Get Dictionary Keys    ${pmc_dict}
    ${distName_NRCELL}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-${cell}    gnb_id=0
    ${actual_pmc_values_dict}=    Get Counter Value    ${pm_counters_dir}    ${distName_NRCELL[0]}    ${pi_list}    ${pmc_index}
    RETURN    ${actual_pmc_values_dict}


Create Dictionary for Rank Related PMC
    [Arguments]    ${expected_values}    ${numTx}
    IF    ${numTx}==2
        ${PDSCH_SUCC_PMC}   Create Dictionary
                            ...    M55300C08001=${expected_values['succ_pdsch_r1_count']}
                            ...    M55300C08002=${expected_values['succ_pdsch_r2_count']}
    ELSE IF    ${numTx}==4
        ${PDSCH_SUCC_PMC}   Create Dictionary
                            ...    M55300C10001=${expected_values['succ_pdsch_r1_count']}
                            ...    M55300C10002=${expected_values['succ_pdsch_r2_count']}
                            ...    M55300C10003=${expected_values['succ_pdsch_r3_count']}
                            ...    M55300C10004=${expected_values['succ_pdsch_r4_count']}
    END
    RETURN    ${PDSCH_SUCC_PMC}


Get RLC ReTx PMC Values
    ${pi_list}=    Create List
    ...            M55311C05006
    ...            M55311C05009
    ...            M55311C06006
    ...            M55311C06009
    ${distName_NRDU}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+/NRDU-1    gnb_id=0
    ${actual_pmc_values_dict}=    Get Counter Value    ${pm_counters_dir}    ${distName_NRDU[0]}    ${pi_list}    ${pmc_index}
    ${items}     Get Dictionary Items   ${actual_pmc_values_dict}
    FOR    ${pi}    ${value}    IN    @{items}
        Run Keyword and Warn on Failure    Should Be Equal	${value}	${0}	${pi} is not 0
    END

Generate verdict for CB008246_R3_PMC
    [Documentation]    Same as 'Generate verdict for TC09_PMC' under CB008246-R3_scenario_validations.robot
    FOR    ${cell}   IN    @{DICT_NUMBER_OF_UE_LIST_PER_CELL}
        ${reference_table}    Create List
        #About ACC_UE_CONFIG_HRDRB calculation:
        #In both TDD&FDD PMC cases there are two UEs have configed HR DRB, ie. there is 2 UEs per slot in 30sec traffic duration
        #then ACC_UE_CONFIG_HRDRB=30sec * (2000slots in TDD / 1000slots in FDD) * 2UEs = 120000 in TDD / 60000 in FDD
        #average number of UEs configured with High Reliability DRB = ACC_UE_CONFIG_HRDRB/SAMPLE_CNT_NR_CELL_UTIL_DL = 0.2
        # for case stability, validate whether is average number of UEs in range (0.2, 0.3)
        ...  M55366C00013 / M55308C01000  >  0.2    average number of UEs configured with High Reliability DRB
        ...  M55366C00013 / M55308C01000  <  0.3    average number of UEs configured with High Reliability DRB
        #About ACC_UE_HR_ACTIVE_DL calculation:
        #In this case at begining 2 UEs with high-reliability mode active in DL, later 2 UEs has been triggered HR DL fallback to BR
        #then in some slots there is no UEs with HR service, the number of ACC_UE_HR_ACTIVE_DL should be in range of (0, 120000/60000)
        #average number of UEs with High Reliability mode active in DL = ACC_UE_HR_ACTIVE_DL/SAMPLE_CNT_NR_CELL_UTIL_DL
        #then validate average number of UEs with High Reliability mode active in DL in range of (0, 0.2)
        ...  M55366C00014 / M55308C01000  >  0      average number of UEs with High Reliability mode active in DL
        ...  M55366C00014 / M55308C01000  <  0.2    average number of UEs with High Reliability mode active in DL
        #ACC_UE_HR_ACTIVE_UL calculation:
        #In both TDD&FDD PMC cases there are two UEs with high-reliability mode active in UL, ie. there is 2 UEs per slot in 30sec traffic duration
        #then ACC_UE_HR_ACTIVE_UL=30sec * (2000slots in TDD / 1000slots in FDD) * 2UEs = 120000 in TDD / 60000 in FDD
        #average number of UEs configured with High Reliability DRB = ACC_UE_HR_ACTIVE_UL/SAMPLE_CNT_NR_CELL_UTIL_UL = 0.2
        # for case stability, validate whether is average number of UEs in range (0.2, 0.3)
        ...  M55367C00013 / M55308C01001  >  0.2     average number of UEs with High Reliability mode active in UL
        ...  M55367C00013 / M55308C01001  <  0.3     average number of UEs with High Reliability mode active in UL
        Run Keyword And Continue On Failure   Verify PM Counter Reference Table    reference_table=${reference_table}  pm_dir=${pm_counters_dir}
        ...                                                                      distname_suffix=${cell}  meas_index=${pmc_index}
    END


#--------------  TTI Trace KWs   ---------------------------------------------------------------------------------------------------[150 characters]
Get Statistical Analysis of TTI Trace Events
    ttitrace_analysis.Verify Distribution Table of   column_name=dlFdSchedData.numOfLayers
    ...                                              path_to_pickle=${path_to_ttitrace_pkl}
    ...                                              plot=Scatter
    ttitrace_analysis.Verify Distribution Table of   column_name=dlFdSchedData.rrmDlProposedMcs
    ...                                              path_to_pickle=${path_to_ttitrace_pkl}
    ttitrace_analysis.Verify Distribution Table of   column_name=dlFdSchedData.rrmDlUsedMcs
    ...                                              path_to_pickle=${path_to_ttitrace_pkl}
    ttitrace_analysis.Verify Distribution Table of   column_name=dlFdSchedData.ackNack
    ...                                              path_to_pickle=${path_to_ttitrace_pkl}
    ...                                              plot=Scatter
    ttitrace_analysis.Verify Distribution Table of   column_name=dlFdSchedData.aggregationLevel
    ...                                              path_to_pickle=${path_to_ttitrace_pkl}
    ...                                              plot=Scatter
    ttitrace_analysis.Compare Proposed vs Used MCS   path_to_pickle=${path_to_ttitrace_pkl}

    ttitrace_analysis.Plot Muti Correlation Events   path_to_pickle=${path_to_ttitrace_pkl}
    ...                                              event1=dlFdSchedData.aggregationLevel
    ...                                              event2=dlFdSchedData.cqiAlSelection
    ...                                              event3=dlFdSchedData.cqiPdcchOffset
    ...                                              event4=dlFdSchedData.pdcchCqi
    ...                                              title=pdcch_AlSelection

Verify Switch to BR then HR
    ${distName}=                gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRPDSCHHRLA-[0-9]+
    ${scf_file}=                gnb.Get SCF from gNB
    scf.load_scf                ${scf_file}
    ${hr_outage_percentage}=    scf.get_value_from_scf    dist_name=${distName[0]}    p_name=dlHRBlerOutagePercentage
    ${hr_recov_percentage}=     scf.get_value_from_scf    dist_name=${distName[0]}    p_name=dlHRBlerRecoverPercentage
    Run Keyword And Continue On Failure    ttitrace_analysis.Check switch between HR and BR event
    ...                                    path_to_pickle=${path_to_ttitrace_pkl}
    ...                                    direction=dl
    ...                                    outage_threshold=${hr_outage_percentage}
    ...                                    recover_threshold=${hr_recov_percentage}

Check Static PDCCH Aggregation Level for BR and HR
    Run Keyword And Continue On Failure    ttitrace_analysis.Check Aggregation Level    path_to_pickle=${path_to_ttitrace_pkl}
    ...                                                                                 direction=dl
    ...                                                                                 la_mode=BASICRELIABILITY
    ...                                                                                 aggregation_level=${4}
    Run Keyword And Continue On Failure    ttitrace_analysis.Check Aggregation Level    path_to_pickle=${path_to_ttitrace_pkl}
    ...                                                                                 direction=dl
    ...                                                                                 la_mode=HIGHRELIABILITY
    ...                                                                                 aggregation_level=${8}

Check Dynamic PDCCH Aggregation Level for BR and HR
    Run Keyword And Continue On Failure    ttitrace_analysis.Check Aggregation Level    path_to_pickle=${path_to_ttitrace_pkl}
    ...                                                                                 direction=dl
    ...                                                                                 la_mode=BASICRELIABILITY
    ...                                                                                 aggregation_level=@{${4}, ${8}}
    Run Keyword And Continue On Failure    ttitrace_analysis.Check Aggregation Level    path_to_pickle=${path_to_ttitrace_pkl}
    ...                                                                                 direction=dl
    ...                                                                                 la_mode=HIGHRELIABILITY
    ...                                                                                 aggregation_level=@{${1}, ${2}}
