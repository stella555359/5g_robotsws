*** Settings ***
Documentation    Scenario Validation keywords for subfeature CB008246-J

Library    ../../../../resources/Common/python/tti_analyzer_framework/tti_dlharqmatcher.py
Library    ../../../../resources/Common/python/tti_analyzer_framework/tti_ulharqmatcher.py
Library    ./../../../resources/SQD66/pmc_analysis.py                   WITH NAME    pmc
Library    ./../../libraries/ttitrace_analysis.py                       WITH NAME    ttitrace_analysis
Library    ./../libraries/CB008246-J_validation.py                      WITH NAME    CB008246-J_validation

Resource   ../../../../resources/Common/pmcounters.robot
Resource   ../../libraries/syslog_validation.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Variables ***
# There should be few txNumber=3 and there should be no txNumber=4-8
@{ultxNumber_values}                          ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{ultxNumber_threshold}                       0.1     0.1       0.1       0       0       0
&{ultxNumber_validation}                      Value=@{ultxNumber_values}    Threshold=@{ultxNumber_threshold}

@{dltxNumber_values}                          ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
@{dltxNumber_threshold}                       0.1     0.1       0.1       0       0       0
&{dltxNumber_validation}                      Value=@{dltxNumber_values}    Threshold=@{dltxNumber_threshold}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
#--------------  PM Counter KWs   ---------------------------------------------------------------------------------------------------[150 characters]
Verify CB008246 PM Counters
    Verify Legacy UL PM Counters
    Verify New UL PM Counters
    Verify Legacy DL PM Counters
    Verify New DL PM Counters


Verify Legacy UL PM Counters
    ${expected_pusch_rank_pmi}=    ttitrace_analysis.get_expected_pusch_rank_pmi    ${path_to_ul_ttitrace_pkl}    cell=${cell}
    ${actual_pusch_rank_pmi_values}=    Get Actual PMC Values    ${expected_pusch_rank_pmi}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_pusch_rank_pmi_values}    ${expected_pusch_rank_pmi}    rel_tol=0.01
    Verify Sum Of PUSCH Rank PMI Counters
    ${expected_ul_mcs_pmc}=    ttitrace_analysis.get_expected_legacy_mcs_pmc_values    ${path_to_ul_ttitrace_pkl}
    ...    dir=ul    subfeature=E    cell=${cell}
    ${actual_ul_mcs_pmc_values}=    Get Actual PMC Values    ${expected_ul_mcs_pmc}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_ul_mcs_pmc_values}    ${expected_ul_mcs_pmc}    abs_tol=3


Verify New UL PM Counters
    ${max_dl_harq_tx}=    scf.get_value_from_scf    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-0    p_name=maxDlHarqTx
    ${max_ul_harq_tx}=    scf.get_value_from_scf    dist_name=MRBTS-1/NRBTS-1/NRCELLGRP-0    p_name=maxUlHarqTx
    ${expected_values}=    ttitrace_analysis.get_expected_new_pmc_values    ${path_to_ul_ttitrace_pkl}    dir=ul    subfeature=E    cell=${cell}
    ...    max_dl_harq_tx=${max_dl_harq_tx}    max_ul_harq_tx=${max_ul_harq_tx}    targetBlerPrf1=${0.01}    targetBlerPrf2=${0.005}
    ${actual_values}=    Get Actual PMC Values    ${expected_values}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_values}    rel_tol=0.01
    ${expected_pmc_values_dict}=    ttitrace_analysis.Get_Expected_Mcs_New_Pmc_Values    ${path_to_ul_ttitrace_pkl}    dir=ul    cell=${cell}
    ...    max_dl_harq_tx=${max_dl_harq_tx}    max_ul_harq_tx=${max_ul_harq_tx}
    ${actual_values}=    Get Actual PMC Values    ${expected_pmc_values_dict}[0]
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_pmc_values_dict}[0]    rel_tol=0.01
    ...    description=${expected_pmc_values_dict}[1]


Verify Legacy DL PM Counters
    [Arguments]    ${numTx}=4
    ${expected_values}=    ttitrace_analysis.get_expected_dl_pmc_values_4tx    ${path_to_dl_ttitrace_pkl}    cell=${cell}
    ${expected_pmc_dict}=    Create Dictionary for Rank Related PMC    ${expected_values}    ${numTx}
    ${actual_values}=    Get Actual PMC Values    ${expected_pmc_dict}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_pmc_dict}    rel_tol=0.01
    ${expected_mcs_pmc_values}=    ttitrace_analysis.get_expected_legacy_mcs_pmc_values    ${path_to_dl_ttitrace_pkl}    dir=dl    subfeature=D
    ...    cell=${cell}
    ${actual_mcs_pmc_values}=    Get Actual PMC Values    ${expected_mcs_pmc_values}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_mcs_pmc_values}    ${expected_mcs_pmc_values}    abs_tol=3


Verify New DL PM Counters
    ${expected_values}=    ttitrace_analysis.get_expected_new_pmc_values    ${path_to_dl_ttitrace_pkl}    dir=dl    subfeature=D    cell=${cell}
    ${actual_values}=    Get Actual PMC Values    ${expected_values}
    Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_values}    ${expected_values}    rel_tol=0.01
    ${expected_pmc_values_dict}=    ttitrace_analysis.Get_Expected_Mcs_New_Pmc_Values    ${path_to_dl_ttitrace_pkl}    dir=dl    cell=${cell}
    ${actual_values}=    Get Actual PMC Values    ${expected_pmc_values_dict}[0]
    Run Keyword And Continue On Failure    pmc.Analyze_Pmc    ${actual_values}    ${expected_pmc_values_dict}[0]    rel_tol=0.01
    ...    description=${expected_pmc_values_dict}[1]


Get Actual PMC Values
    [Arguments]    ${pmc_dict}
    ${pi_list}=    Get Dictionary Keys    ${pmc_dict}
    ${distName_NRCELL}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-${cell}    gnb_id=0
    ${actual_pmc_values_dict}=    Get Counter Value    ${pm_counters_dir}    ${distName_NRCELL[0]}    ${pi_list}    ${pmc_index}
    RETURN    ${actual_pmc_values_dict}


Create Dictionary for Rank Related PMC
    [Arguments]    ${expected_values}    ${numTx}=4
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


Verify Sum Of PUSCH Rank PMI Counters
    ${pm_reference_table}    Create List
    ...    M55303C02000 + M55303C02001 + M55303C02002 + M55303C02003 + M55303C02004 + M55303C02005  ==  M55303C04001
    ...    PUSCH transmissions with CP-OFDM using 2TX transmission with rank 1
    ...    M55303C03000 + M55303C03001 + M55303C03002  ==  M55303C04002
    ...    PUSCH transmissions with CP-OFDM using 2TX transmission with rank 2
    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_reference_table}
    ...    pm_dir=${PM_COUNTERS_DIR}  distname_suffix=${CELL}  meas_index=${PMC_INDEX}


Generate verdict on ${validate_with_scenario}
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    Get Statistical Analysis of DL TTI Trace Events
    Get Statistical Analysis of UL TTI Trace Events
    Plot analysis graphs    scenario=${validate_with_scenario}
    Verify Switch between HR and BR    scenario=${validate_with_scenario}
    IF  'DFTsOFDM' in '${validate_with_scenario}'    Verify if MCS vs Pathloss graph is inverted
    IF  'xpmc' in '${validate_with_scenario}'    Verify CB008246 PM Counters
    Verify Errors and Warnings in SYSLOG Trace


Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    Set Test Variable    ${syslog_dir}    ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_dl_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlharq.pkl
    ${path_to_ul_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ul.pkl
    ${path_to_syscom_pdml}=    set variable  ${ts_log_dir}/cell_setup_trace_initial/l2_l3_tcpdump.pdml
    ${path_to_scf_xml}=        set variable  ${ts_log_dir}/../Configs/scf_${scenario}.xml
    ${path_to_syslog_tgz}=     set variable  ${ts_log_dir}/btslog_${collector_name}/btslog_gnb0/syslog_files.tgz
    ${nrbts_str}=  Get distNames from gNB DU  regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${attached_ues}=  Get UE Ids configured for scenario  scenario_name=${scenario}
    set test variable  ${path_to_ttitrace_json}
    set test variable  ${path_to_dl_ttitrace_pkl}
    set test variable  ${path_to_ul_ttitrace_pkl}
    set test variable  ${path_to_syscom_pdml}
    set test variable  ${path_to_scf_xml}
    set test variable  ${path_to_syslog_tgz}
    set test variable  ${nrbts_str}
    set test variable  ${attached_ues}
    ${SW_DUPLEX}=    Set Variable if  'TDD' in '${scenario}'    TDD    FDD
    Set Suite Variable    ${SW_POSTFIX}    ${SW_DUPLEX}  # ${SW_POSTFIX} is used for RP, uncomment it when putting the case to Regression
    Get Feature Config From SCF


    ${dtx_values}=    Set variable    DTX
    Set test variable    &{dl_dtx_validation}    Value=${dtx_values}    Threshold=${dl_dtx_threshold}
    Set test variable    &{ul_dtx_validation}    Value=${dtx_values}    Threshold=${ul_dtx_threshold}
    IF  'xpmc' in '${scenario}'    Prepare PM Variables for Validation    scenario=${scenario}


Prepare PM Variables for Validation
    [Arguments]  ${scenario}
    ${pm_counters_dir}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${pmc_index}=  tools.get_pmc_index
    ...                                 scenario=${scenario}
    ...                                 pmc_scenario_dict=${PMC_SCENARIO_DICT}
    ...                                 ts_log_dir=${ts_log_dir}
    ${cell}=    Set Variable if  'TDD' in '${scenario}'    1    3
    set test variable  ${pm_counters_dir}
    set test variable  ${pmc_index}
    set test variable  ${cell}


Get Statistical Analysis of DL TTI Trace Events
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.mcsTable
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...                                              plot=Scatter
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.txNumber
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...                                              plot=Scatter
    ...                                              validate=&{dltxNumber_validation}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.numOfLayers
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...                                              plot=Scatter
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.rrmDlProposedMcs
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.rrmDlUsedMcs
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.ackNack
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...                                              plot=Scatter
    ...                                              validate=&{dl_dtx_validation}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.aggregationLevel
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...                                              plot=Scatter


Get Statistical Analysis of UL TTI Trace Events
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.mcsTable
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.numOfLayers
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.ptrsFlagUlProposedMcs
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulLaAverageSinr.rrmInstSinrRank
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.txNumber
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter
    ...                                              validate=&{ultxNumber_validation}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulHarqRxData.dtx
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter
    ...                                              validate=&{ul_dtx_validation}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulHarqRxData.crcResult
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.rrmUlProposedMcs
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Bar
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulFdSchedData.aggregationLevel
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...                                              plot=Scatter


Plot analysis graphs
    [Arguments]  ${scenario}
    IF    'DFTsOFDM' in '${scenario}'    Run Keyword And Continue On Failure
    ...    CB008246-J_validation.plot_graph_tp_switching    path_to_pickle=${path_to_ul_ttitrace_pkl}

    Run Keyword And Continue On Failure              ttitrace_analysis.Compare Proposed vs Used MCS
    ...                                              path_to_pickle=${path_to_dl_ttitrace_pkl}

    @{directions}    Set variable    dl    ul
    FOR    ${direction}    IN    @{directions}
        Log    ${direction}
        IF    '256QAM' in '${scenario}' or ('DFTsOFDM' in '${scenario}' and '${direction}' == 'dl')
        ...    Run Keyword And Continue On Failure
        ...    ttitrace_analysis.plot_graph_hr_vs_br
        ...    path_to_pickle=${path_to_${direction}_ttitrace_pkl}     direction=${direction}
    END


Verify Switch between HR and BR
    [Arguments]  ${scenario}

    ${validate_outage}=    Set variable if    'TC05' in '${scenario}' or 'TC06' in '${scenario}'    ${False}    ${True}
    ${isDftsOfdm_B21_scenario}=    Set variable if    'TC03' in '${scenario}' or 'TC04' in '${scenario}'    ${True}    ${False}
    ${isDftsOfdm_B22_scenario}=    Set variable if    'TC05' in '${scenario}' or 'TC06' in '${scenario}'    ${True}    ${False}

    IF    'DFTsOFDM' in '${scenario}'    Run Keyword And Continue On Failure
    ...    ttitrace_analysis.check_switch_between_hr_and_br_event    path_to_pickle=${path_to_ul_ttitrace_pkl}
    ...    direction=ul    outage_threshold=${hr_outage_percentage}    recover_threshold=${hr_recov_percentage}
    ...    validate_outage=${validate_outage}    validate_recover=${True}    is_subfeature_H_enabled=${True}

    IF    '256QAM' in '${scenario}'    Run Keyword And Continue On Failure
    ...    CB008246-J_validation.check_mcsTable_laMode_and_DftsOfdm_switching_in_different_phases    path_to_pickle=${path_to_dl_ttitrace_pkl}
    ...    direction=dl    outage_threshold=${hr_outage_percentage}    recover_threshold=${hr_recov_percentage}

    @{directions}    Set variable    dl    ul
    FOR    ${direction}    IN    @{directions}
        Log    ${direction}
        Run Keyword And Continue On Failure    CB008246-J_validation.check_bearer_addition_and_deletion_with_laMode_switching
        ...    path_to_pickle=${path_to_${direction}_ttitrace_pkl}     direction=${direction}    isDftsOfdm_B22_scenario=${isDftsOfdm_B22_scenario}

        IF    'DFTsOFDM' in '${scenario}'    Run Keyword And Continue On Failure
        ...    CB008246-J_validation.check_mcsTable_laMode_and_DftsOfdm_switching_in_different_phases
        ...    path_to_pickle=${path_to_${direction}_ttitrace_pkl}    direction=${direction}    outage_threshold=${hr_outage_percentage}
        ...    recover_threshold=${hr_recov_percentage}    isDftsOfdm_B21_scenario=${isDftsOfdm_B21_scenario}
        ...    isDftsOfdm_B22_scenario=${isDftsOfdm_B22_scenario}

        Run Keyword And Continue On Failure    ttitrace_analysis.check_target_bler_is_less_than_percentage
        ...    path_to_pickle=${path_to_${direction}_ttitrace_pkl}    xlaBlerTarget_hr_internal_value=${xlaBlerTarget_internal}
        ...    xlaBlerTarget_br_internal_value=${xlaBlerTarget_internal}    direction=${direction}
    END


Get feature config from SCF
    ${distName}=                gnb.Get distNames from Local SCF File  scf_path=${path_to_scf_xml}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRPDSCHHRLA-[0-9]+
    scf.load_scf                ${path_to_scf_xml}
    ${hr_outage_percentage}=    scf.get_value_from_scf    dist_name=${distName[0]}    p_name=dlHRBlerOutagePercentage
    ${hr_recov_percentage}=     scf.get_value_from_scf    dist_name=${distName[0]}    p_name=dlHRBlerRecoverPercentage
    Set Test Variable  ${hr_outage_percentage}
    Set Test Variable  ${hr_recov_percentage}


Verify if MCS vs Pathloss graph is inverted
    Run Keyword And Continue On Failure              ttitrace_analysis.Check Correlation Of Mcs And Pathloss
    ...                                              path_to_pickle=${path_to_ul_ttitrace_pkl}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    #--- DL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_dl}=  Create List    utcTimestampData
    ...                                    csiSrReportData
    ...                                    dlFdSchedData
    ...                                    dlHarqRxDataArray
    ...                                    dlLaAverageCqi
    ...                                    dlLaDeltaCqiArray
    ...                                    dlLaSwitchBetweenHrAndBr
    ...                                    dlFdSchedAdditionalData
    ${dl_df}=    Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                       events_list=${events_required_dl}
    ...                                                       write_to_pickle=${False}
    ...                                                       eventdecoder_stdout_path=${target_path}/ttitrace_streaming_dl_stdout.log

    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${dl_df}
    tti_dataframe.Write_Df_To_Pickle    df=${dlharq_matcher_df}    target_path=${target_path}/ttitrace_streaming_dlharq.pkl
    ttitrace.Convert TTI trace from data frame to csv    ${dlharq_matcher_df}
    ...                                                  ${target_path}
    ...                                                  tti_trace_filename=ttitrace_streaming_dlharq.csv

    #--- UL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_ul}=  Create List      utcTimestampData
    ...                                      ulFdSchedData
    ...                                      ulHarqRxData
    ...                                      ulLaAverageSinr
    ...                                      ulLaDeltaSinr
    ...                                      ulLaPhr
    ...                                      ulPuschReceiveRespPsData
    ...                                      laTimer
    ...                                      ulLaSwitchBetweenHrAndBr
    ...                                      ulFdSchedAdditionalData

    ${ul_df}=    Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                       events_list=${events_required_ul}
    ...                                                       write_to_pickle=${TRUE}
    ...                                                       eventdecoder_stdout_path=${target_path}/ttitrace_streaming_ul_stdout.log
    Move File    ${target_path}/ttitrace_streaming.pkl    ${target_path}/ttitrace_streaming_ul.pkl
    ttitrace.Convert TTI trace from data frame to CSV     ${ul_df}
    ...                                                   ${target_path}
    ...                                                   tti_trace_filename=ttitrace_streaming_ul.csv


