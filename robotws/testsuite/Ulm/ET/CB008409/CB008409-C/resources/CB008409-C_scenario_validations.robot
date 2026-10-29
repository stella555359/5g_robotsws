*** Settings ***
Documentation    Insert Feature Specific validation keywords here

#Import required libraries for validation
Library    Collections
Library    String
Library    ../../../L2/libraries/template_functions.py          WITH NAME   template
Library    ../../../L2/libraries/tools.py                       WITH NAME   tools
Library    ../../../resources/SQD66/pmc_analysis.py             WITH NAME   pmc
Library    ../libraries/ttitrace_analysis.py                    WITH NAME   ttitrace_analysis


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***

Verify CB008409-C restriction phases and incremental CQI step size values
    [Arguments]    ${testcase}    ${allowedCqiIncrementSpecial}=${3}    ${starttime_specialphase}=${0}    ${endtime_specialphase}=${0}
    IF    '${testcase}' == 'TC03'
        ${starttime_specialphase}    Set variable    ${starttime_specialphase_TC03}     # set in scenario_modification.robot
        ${endtime_specialphase}    Set variable    ${endtime_specialphase_TC03}     # set in scenario_modification.robot
    END
    run keyword and continue on failure     ttitrace_analysis.verify_restriction_phases_and_incremental_CQI_step_size_values
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    testcase=${testcase}
    ...    allowedCqiIncrementSpecial=${allowedCqiIncrementSpecial}
    ...    starttime=${starttime_specialphase}
    ...    endtime=${endtime_specialphase}


Show Cqi value increment report
    run keyword and continue on failure     ttitrace_analysis.show_cqi_values_increment_report
    ...    path_to_pickle=${path_to_ttitrace_pkl}


Verify PM Counter
    ${cell}    Set Variable    ${3}
    ${pmc_values_dict}=    ttitrace_analysis.Get_Expected_Pmc_Values_EDA04035793    ${path_to_ttitrace_pkl}
    ...    cell=${3}
    ${actual_mcs_pmc_values}=    Get Actual PMC Values    ${pmc_values_dict}[0]    ${cell}
    Run Keyword And Continue On Failure    pmc.Analyze_Pmc    ${actual_mcs_pmc_values}    ${pmc_values_dict}[0]
    ...    rel_tol=${0}    abs_tol=${1}    description=${pmc_values_dict}[1]


Get Actual PMC Values
    [Arguments]    ${pmc_dict}    ${cell}
    ${pi_list}=    Collections.Get Dictionary Keys    ${pmc_dict}
    ${distName_NRCELL}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-${cell}    gnb_id=0
    ${actual_pmc_values_dict}=    pmcounters.Get Counter Value    ${pm_counters_dir}    ${distName_NRCELL[0]}    ${pi_list}    ${pmc_index}
    RETURN    ${actual_pmc_values_dict}


Extract TTI Trace and Convert to JSON
    [Arguments]    @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${eventdecoder_stdout_path}    String.Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_stdout.log
    ${events_required}=  Create List  csiSrReportData  dlFdSchedData  dlLaAverageCqi
    ttitrace.Convert TTI Trace From Pcap To Data Frame
    ...    input_file_path=${path_to_tti_trace_pcap}
    ...    events_list=${events_required}
    ...    write_to_pickle=${TRUE}
    ...    eventdecoder_stdout_path=${eventdecoder_stdout_path}


Prepare Variables for validations
    [Arguments]    ${scenario}
    ${COLLECTOR_NAME}=  template.Get_Collector_Name  scenario_name=${scenario}
    Set Test Variable    ${COLLECTOR_NAME}
    Set Test Variable    ${SYSLOG_DIR}    ${TS_LOG_DIR}/btslog_${COLLECTOR_NAME}/btslog_gnb0
    Set Test Variable    ${PATH_TO_TTITRACE_PKL}    ${TS_LOG_DIR}/tti_trace_${COLLECTOR_NAME}/ttitrace_streaming.pkl
    Set Test Variable    ${TTI_TRACE_PATH_FOLDER}    ${TS_LOG_DIR}/tti_trace_${COLLECTOR_NAME}/
    Set Test Variable    ${PM_COUNTERS_DIR}    ${TS_LOG_DIR}/PMC/gnb_pm_counters
    ${is_with_pm_counters}=  template.Is_With_Pm_Counters  ${scenario}
    IF  ${is_with_pm_counters}
        ${PMC_INDEX}=  tools.Get_Pmc_Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
        Set Test Variable    ${PMC_INDEX}
    END
    Set Test Variable    ${SW_POSTFIX}    CB008409_C
