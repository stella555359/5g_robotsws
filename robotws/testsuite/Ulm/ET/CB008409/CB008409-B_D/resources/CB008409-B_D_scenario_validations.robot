*** Settings ***
Documentation    Insert Feature Specific validation keywords here

#Import required libraries for validation
Library    ../../../../resources/Common/python/tti_analyzer_framework/tti_dlharqmatcher.py
Library    ../../../L2/libraries/tools.py                                                    WITH NAME    tools
Library    ../../../L2/libraries/template_functions.py                                       WITH NAME    template
Library    ../../../resources/SQD66/pmc_analysis.py                                          WITH NAME    pmc
Library    ../libraries/CB008409-B_D_ttitrace_analysis.py                                    WITH NAME    ttitrace_analysis

Resource    ../../../../resources/Common/pmcounters.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
Extract TTI Trace and Convert to JSON
    [Arguments]    @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List    dlFdSchedData
    ...                                 dlHarqRxDataArray
    ...                                 dlAllocatedPooledResourcesData
    ...                                 dlFdSchedAdditionalData
    ...                                 dlPagingOrSibSchedData
    ${df}=    ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                           events_list=${events_required}
    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${df}
    ${dlharq_target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dlharq.pkl
    tti_dataframe.write_df_to_pickle  df=${dlharq_matcher_df}    target_path=${dlharq_target_path}
    ${filtered_csv_target_path}=    Replace String    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    ttitrace.Convert TTI trace from data frame to csv    ${dlharq_matcher_df}   ${filtered_csv_target_path}
    ...                                                  tti_trace_filename=filtered_ttitrace.csv


Prepare Variables for validations
    [Arguments]    ${scenario}
    ${COLLECTOR_NAME}=  template.Get_Collector_Name  scenario_name=${scenario}
    Set Test Variable  ${COLLECTOR_NAME}
    Set Test Variable  ${PATH_TO_TTITRACE_PKL}    ${TS_LOG_DIR}/tti_trace_${COLLECTOR_NAME}/ttitrace_streaming_dlharq.pkl
    Set Test Variable  ${SYSLOG_DIR}    ${TS_LOG_DIR}/btslog_${COLLECTOR_NAME}/btslog_gnb0
    Set Test Variable  ${PM_COUNTERS_DIR}    ${TS_LOG_DIR}/PMC/gnb_pm_counters
    ${is_with_pm_counters}=  template.Is_With_Pm_Counters  ${scenario}
    IF  ${is_with_pm_counters}
        ${PMC_INDEX}=  tools.Get_Pmc_Index  scenario=${scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}  ts_log_dir=${TS_LOG_DIR}
        Set Test Variable    ${PMC_INDEX}
    END
    Load Scf Values For Validations    ${scenario}
    IF  'CB008409_B' in '${TEST_NAME}'
        Set Test Variable    ${SW_POSTFIX}    CB008409_B
    ELSE    # For CB008409_D
        Set Test Variable    ${SW_POSTFIX}    CB008409_D
    END


Verify maxNumberOfPRBperSlot
    run keyword and continue on failure    ttitrace_analysis.verify_maxNumberOfPRBperSlot
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    cellTechnology_NRCELL=${cellTechnology_NRCELL}
    ...    chBW_NRCELL=${chBW_NRCELL}
    ...    nbrOfBlankedPRBsDL_NRCELL=${nbrOfBlankedPRBsDL_NRCELL}
    ...    bwpChBwPowerSaving_NRCELL=${bwpChBwPowerSaving_NRCELL}


Verify power boost for ReTx
    run keyword and continue on failure    ttitrace_analysis.verify_powerBoost_for_ReTX
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    maxPrbsIncludingPowerBoostPrbs_NRCELL=${maxPrbsIncludingPowerBoostPrbs_NRCELL}
    ...    numTxThreshForPowerBoost_NRCELL=${numTxThreshForPowerBoost_NRCELL}
    ...    cellTechnology_NRCELL=${cellTechnology_NRCELL}
    ...    chBW_NRCELL=${chBW_NRCELL}
    ...    actDlPowerBoost_NRCELL=${actDlPowerBoost_NRCELL}
    ...    nbrOfBlankedPRBsDL_NRCELL=${nbrOfBlankedPRBsDL_NRCELL}
    ...    actAdaptiveReTxResMcs_NRCELL=${actAdaptiveReTxResMcs_NRCELL}
    ...    bwpChBwPowerSaving_NRCELL=${bwpChBwPowerSaving_NRCELL}


Verify PM Counter
    FOR    ${cell}    IN RANGE    ${1}    ${5}
        ${expected_mcs_pmc_values}=    ttitrace_analysis.get_expected_pmc_values    ${path_to_ttitrace_pkl}
        ...    cell=${cell}
        ${actual_mcs_pmc_values}=    Get Actual PMC Values    ${expected_mcs_pmc_values}    ${cell}
        Run Keyword And Continue On Failure    pmc.analyze_pmc    ${actual_mcs_pmc_values}    ${expected_mcs_pmc_values}
    END


Load scf values for validations
    [Arguments]    ${scenario}
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${scenario}.xml
    ${distName_NRCELL}=    gnb.Get distNames from Local SCF File  scf_path=${scf_file}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
    ${actDlPowerBoost_NRCELL}    Create List
    ${actAdaptiveReTxResMcs_NRCELL}    Create List
    ${actPowerSavingBWP_NRCELL}    Create List
    ${numTxThreshForPowerBoost_NRCELL}    Create List
    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}    Create List
    ${cellTechnology_NRCELL}    Create List
    ${chBW_NRCELL}    Create List
    ${bwpChBwPowerSaving_NRCELL}    Create List
    ${nbrOfBlankedPRBsDL_NRCELL}    Create List
    ${actDlDynSwitchAlloc_NRCELL}    Create List
    ${actRat1Alloc_NRCELL}    Create List
    FOR    ${distName}    IN   @{distName_NRCELL}
        ${actDlPowerBoost}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actDlPowerBoost
        IF    '${actDlPowerBoost}' != 'disabled'
            ${numTxThreshForPowerBoost}=    scf.get_value_from_scf    dist_name=${distName}    p_name=numTxThreshForPowerBoost
            ${maxPrbsIncludingPowerBoostPrbs}=    scf.get_value_from_scf    dist_name=${distName}   p_name=maxPrbsIncludingPowerBoostPrbs
        ELSE
            ${numTxThreshForPowerBoost}    Set variable    ${0}
            ${maxPrbsIncludingPowerBoostPrbs}   Set variable    ${0}
        END
        ${cellTechnology}=    scf.get_value_from_scf    dist_name=${distName}   p_name=cellTechnology
        IF  '${cellTechnology}' == 'TDD'
            ${chBW}=    scf.get_value_from_scf    dist_name=${distName}   p_name=chBw
        ELSE
            ${chBW}=    scf.get_value_from_scf    dist_name=${distName}/NRCELL_FDD-1   p_name=chBwDl
        END
        ${chBW}     Fetch From Left    ${chBW}    MHz
        ${actAdaptiveReTxResMcs}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actAdaptiveReTxResMcs
        ${actPowerSavingBWP}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actPowerSavingBWP
        IF  '${actPowerSavingBWP}' == 'true'
            ${bwpChBwPowerSaving}=    scf.get_value_from_scf    dist_name=${distName}   p_name=bwpChBwPowerSaving
            ${bwpChBwPowerSaving}     Fetch From Left    ${bwpChBwPowerSaving}    MHz
        ELSE
            ${bwpChBwPowerSaving}    Set variable    ${0}
        END
        ${nbrOfBlankedPRBsHighEdgeDL}=    scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsHighEdgeDL
        ${nbrOfBlankedPRBsLowEdgeDL}=    scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsLowEdgeDL
        ${actDlDynSwitchAlloc}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actDlDynSwitchAlloc
        ${actRat1Alloc}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actRat1Alloc
        ${numTxThreshForPowerBoost}=    Convert To Integer     ${numTxThreshForPowerBoost}
        ${maxPrbsIncludingPowerBoostPrbs}=    Convert To Integer     ${maxPrbsIncludingPowerBoostPrbs}
        ${chBW}     Convert to Integer     ${chBW}
        ${bwpChBwPowerSaving}     Convert to Integer     ${bwpChBwPowerSaving}
        ${nbrOfBlankedPRBsHighEdgeDL}=    Convert to Integer    ${nbrOfBlankedPRBsHighEdgeDL}
        ${nbrOfBlankedPRBsLowEdgeDL}=    Convert to Integer    ${nbrOfBlankedPRBsLowEdgeDL}
        ${nbrOfBlankedPRBsDL}    Evaluate    ${nbrOfBlankedPRBsHighEdgeDL} + ${nbrOfBlankedPRBsLowEdgeDL}
        Append to list    ${actDlPowerBoost_NRCELL}    ${actDlPowerBoost}
        Append to list    ${actAdaptiveReTxResMcs_NRCELL}    ${actAdaptiveReTxResMcs}
        Append to list    ${actPowerSavingBWP_NRCELL}    ${actPowerSavingBWP}
        Append to list    ${numTxThreshForPowerBoost_NRCELL}    ${numTxThreshForPowerBoost}
        Append to list    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}    ${maxPrbsIncludingPowerBoostPrbs}
        Append to list    ${cellTechnology_NRCELL}    ${cellTechnology}
        Append to list    ${chBW_NRCELL}    ${chBW}
        Append to list    ${bwpChBwPowerSaving_NRCELL}    ${bwpChBwPowerSaving}
        Append to list    ${nbrOfBlankedPRBsDL_NRCELL}    ${nbrOfBlankedPRBsDL}
        Append to list    ${actDlDynSwitchAlloc_NRCELL}    ${actDlDynSwitchAlloc}
        Append to list    ${actRat1Alloc_NRCELL}    ${actRat1Alloc}
    END
    Set test variable    ${actDlPowerBoost_NRCELL}
    Set test variable    ${actAdaptiveReTxResMcs_NRCELL}
    Set test variable    ${actPowerSavingBWP_NRCELL}
    Set test variable    ${numTxThreshForPowerBoost_NRCELL}
    Set test variable    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}
    Set test variable    ${cellTechnology_NRCELL}
    Set test variable    ${chBW_NRCELL}
    Set test variable    ${bwpChBwPowerSaving_NRCELL}
    Set test variable    ${nbrOfBlankedPRBsDL_NRCELL}
    Set test variable    ${actDlDynSwitchAlloc_NRCELL}
    Set test variable    ${actRat1Alloc_NRCELL}


Get Actual PMC Values
    [Arguments]    ${pmc_dict}    ${cell}
    ${pi_list}=    Get Dictionary Keys    ${pmc_dict}
    ${distName_NRCELL}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-${cell}    gnb_id=0
    ${actual_pmc_values_dict}=    pmcounters.Get Counter Value    ${pm_counters_dir}    ${distName_NRCELL[0]}    ${pi_list}    ${pmc_index}
    RETURN    ${actual_pmc_values_dict}


Verify if values changed after online modification
    Run keyword and continue on failure
    ...    ttitrace_analysis.verify_if_values_changed_after_online_modification    path_to_pickle=${path_to_ttitrace_pkl}


Verify Values Changed After Online Modification
    Run keyword And Continue On Failure
    ...    ttitrace_analysis.Verify_Values_Changed_After_Online_Modification   path_to_pickle=${path_to_ttitrace_pkl}


Verify RBG Randomization
    Run Keyword And Continue On Failure    ttitrace_analysis.Verify RBG Randomization
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    actPowerSavingBWP_NRCELL=${actPowerSavingBWP_NRCELL}
    ...    actRat1Alloc_NRCELL=${actRat1Alloc_NRCELL}


Verify max Number of PRB per slot not exceeding dlAllocatedPooledResourcesData.numAllocCellPrbDl
    run keyword and continue on failure    ttitrace_analysis.verify_maxNumberOfPRBPerSlotNotExceedingdlAllocatedPooledResourcesDatanumAllocCellPrbDl
    ...    path_to_pickle=${path_to_ttitrace_pkl}


Get dynamic RAT0 RAT1 pairing slots
    run keyword and continue on failure    ttitrace_analysis.Get_dynamic_RAT0_RAT1_pairing_slots
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    actDlDynSwitchAlloc_NRCELL=${actDlDynSwitchAlloc_NRCELL}


Verify RAT0 RAT1 dynamic switch
    run keyword and continue on failure    ttitrace_analysis.Verify_RAT0_RAT1_dynamic_switch
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    actDlDynSwitchAlloc_NRCELL=${actDlDynSwitchAlloc_NRCELL}


Verify if only RAT1 bitmap is present
    run keyword and continue on failure    ttitrace_analysis.Verify_if_only_RAT1_bitmap_is_present
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    actRat1Alloc_NRCELL=${actRat1Alloc_NRCELL}


Verify dlAllocatedPooledResourcesDataNumAllocCellPrbDl sfn scheduling interval based on bbPoolEvalPeriod
    run keyword and continue on failure
    ...    ttitrace_analysis.verify_dlAllocatedPooledResourcesDataNumAllocCellPrbDl_sfn_scheduling_interval_based_on_bbPoolEvalPeriod
    ...    path_to_pickle=${path_to_ttitrace_pkl}
    ...    cellTechnology_NRCELL=${cellTechnology_NRCELL}


Verify MuMimo pairing
    run keyword and continue on failure    ttitrace_analysis.verify_MuMimo_pairing
    ...    path_to_pickle=${path_to_ttitrace_pkl}


Get Key TTI Events
    Run Keyword And Continue On Failure    ttitrace_analysis.get_key_tti_events    path_to_pickle=${path_to_ttitrace_pkl}


Verify BaseBand Pooling Window
    Run Keyword And Continue On Failure    ttitrace_analysis.Verify_Bbpoolingwindow
    ...    path_to_pickle=${path_to_ttitrace_pkl}
