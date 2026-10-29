*** Settings ***
Documentation    Scenario Validation keywords for subfeature CB013715

Library              OperatingSystem
Library              ArchiveLibrary
Library              resources/python/AreBlankedPrbNotUsed.py              WITH NAME    AreBlankedPrbNotUsed

# Libraries for pdml analysis
Library              taf.analyzer.pdml                                     WITH NAME      taf_pdml_analyser
Library              luashark_tools.analyzer                               WITH NAME      analyzer

Library              resources/TARF/python/tools.py                 WITH NAME      nps_tarf_tools
Library              ../resources/common/TtiTrace/python/ttitrace.py              WITH NAME      nps_ttitraces_tools
Library              resources/TARF/python/scf_gnb.py               WITH NAME      scf_gnb
Library              resources/TARF/python/tarf-lib.py              WITH NAME      CB013715
Library              resources/TARF/python/template_functions.py    WITH NAME      template
Library              resources/TARF/lib_py/ttitrace_analysis.py     WITH NAME      ttitrace_analysis
Library              ../resources/common/TtiTrace/python/tti_analyzer_framework/tti_dlharqmatcher.py
Library              resources/TARF/lib_py/bearersetup_req_parser.py       WITH NAME    bearersetup_req_parser
Library              resources/TARF/lib_py/usersetup_req_parser.py         WITH NAME    usersetup_req_parser
Library              resources/TARF/lib_py/cellsetup_req_parser.py         WITH NAME    cellsetup_req_parser
Library              ./resources/python/CB013715_tools.py                         WITH NAME    CB013715_tools
Library              ./resources/python/CB013715_validation.py
Library              ./resources/python/CB013715-PMC-validation.py                    WITH NAME     check_PMC
Library              ./resources/python/pdcch_dci_decode.py                           WITH NAME     pdcch_dci_decode
Library              resources/TARF/python/tti_analysis/check_ul_dtx_crc.py    WITH NAME     check_ul_dtx_crc
Library              resources/TARF/python/tti_analysis/check_nack.py          WITH NAME     check_nack
Library              resources/TARF/python/Tti-lib.py                          WITH NAME     Tti-lib
Library              ./resources/python/CellCalculator/FreqHoppingSRSCalculator.py    WITH NAME     FreqHoppingSRSCalculator
Library              resources/TARF/python/syslogs_analysis.py                 WITH NAME     syslogs_analysis

# Variables            ./CB013715_variables.yaml

Resource             resources/TARF/robot/power_calculation_common_keywords.robot
Resource             ./resources/robot/DSS-Verdict-keywords.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Variables ***
${ROBOTWS_PARENT_DIR}    /home/ute/NpsTest
${13715_ET_BASE_PATH}    ${ROBOTWS_PARENT_DIR}/robotws/testsuite/Paris/RRM/ET/CB013715

# for A32 (IWK CB008367-B2)
${search_space_id_large} =          8
${search_space_id_small} =          13
${search_space_id_pws} =            18
${pdcch_start_symbol_large} =       1
${pdcch_start_symbol_small} =       17

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

Generate verdict on ${validate_with_scenario}
    ${msg}=    set Variable   ${consTraceColorBgRed}${consTraceColorYellow}Generate verdict on ${validate_with_scenario}${defColor}
    BuiltIn.log to console    =========================================================================================
    BuiltIn.log to console    ${msg}
    BuiltIn.log to console    =========================================================================================
    Prepare Variables for Validation    scenario=${validate_with_scenario}
    Run Keyword And Continue On Failure    Verify CB013715 with ${validate_with_scenario}
    Run Keyword And Continue On Failure    Verify UserSetup with ${validate_with_scenario}
    Run Keyword And Continue On Failure    Verify CellSetup with ${validate_with_scenario}
    Run Keyword And Continue On Failure    DSS-Verdict-keywords.Generate Test Verdict For Prb Blanking L1l2 pcap with ${validate_with_scenario}
    return from Keyword

Verify PMC values for all scenario
    BuiltIn.log    TEST TAGS = ${TEST TAGS}
    ${list_of_scenarios}=  template.get_list_of_all_scenarios  ${TEST TAGS}
    ${nb_scenario}=  BuiltIn.get length  ${list_of_scenarios}
    Verify PMC values with nb of scenario ${nb_scenario}


Verify CB013715 with ${verify_with_scenario}
    ${output}    ${output_count}=    Get Last initialTa Value from GNB Syslog
    nps_tarf_tools.log_to_console_with_time_prefix     Last initialTa Value from GNB Syslog is ${output}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     initialTa Value Count from GNB Syslog is ${output_count}    level=INFO
    IF     '${logs_and_traces_flags['BackhaulTrace']['BHTrace']}' == 'True'
        IF    '${logs_and_traces_flags['BackhaulTrace']['conversion']['pdml']}'=='False'
            Dated log     =========> Convert PCAP to PDML for DL and UL Qos Load Indication MeasuredNgbrNnbrLoad ...
            ${collector_name}=  template.get_collector_name     ${verify_with_scenario}
            ${bh_trace_collector_name}=  Set Variable  backhaul_${collector_name}
            # ${path_to_tcpdump}    set variable    ${ts_log_dir}/${bh_trace_collector_name}/backhaul_${collector_name}
            ${path_to_bh_xp_pdml}=    run Keyword  TARF-Keywords.Convert PCAP to PDML  source=${path_to_bh_pcap}
            ...  filter=xp
            ...  target=${ts_log_dir}/${bh_trace_collector_name}/backhaul.pdml
        END
        Dated log     =========> Display DL and UL Qos Load Indication MeasuredNgbrNnbrLoad / measuredPdcchLoad...
        Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication MeasuredNgbrNnbrLoad       ${path_to_bh_xp_pdml}
        ${status}   ${avg_ul_MeasuredNgbrNnbrLoad}=  Run Keyword and Ignore Error
        ...     common_Dss_Keywords.Check UL Qos Load Indication MeasuredNgbrNnbrLoad     ${path_to_bh_xp_pdml}
        ...                                                                               with_verdict=False
        Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication measuredGbrLoad            ${path_to_bh_xp_pdml}
        Run Keyword and Ignore Error      common_Dss_Keywords.Check UL Qos Load Indication measuredGbrLoad            ${path_to_bh_xp_pdml}
        Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication measuredPdcchLoad          ${path_to_bh_xp_pdml}
    END
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${list_of_ue_per_cell_to_be_attached}=    template.get_attach_list_per_cell  scenario_name=${verify_with_scenario}
    nps_tarf_tools.log_to_console_with_time_prefix    list_of_ue_per_cell_to_be_attached=${list_of_ue_per_cell_to_be_attached}    level=INFO
    ${cell1_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${list_of_ue_per_cell_to_be_attached}    1
    ${cell3_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${list_of_ue_per_cell_to_be_attached}    3
    IF    ${cell1_exists}
        ${cellIdDss}=    set variable     1
    ELSE IF    ${cell3_exists}
        ${cellIdDss}=    set variable     3
    ELSE
        ${cellIdDss}=    set variable     1
    END
    ${actSlowPrbPooling_SCF}=         Get actSlowPrbPooling from SCF       CellId=${cellIdDss}
    IF    '${actSlowPrbPooling_SCF}'=='true'
        # csamson FOR PRECHECK TC08 : UL NbrOfPrb stuck to 36
        ${collector_name}=  template.get_collector_name     ${verify_with_scenario}
        Convert TTI Traces to Dataframe and store as pickle fo UL Pooling   collector=${collector_name}
        Run keyword and continue on failure   CB013715_validation.verify_TTITraces_for_UL_Pooling  path_to_pickle=${path_to_ttitrace_ulPooling_pkl}
        Convert TTI Traces to Dataframe and store as pickle fo DL Pooling   collector=${collector_name}
        Run keyword and continue on failure   CB013715_validation.verify_TTITraces_for_DL_Pooling  path_to_pickle=${path_to_ttitrace_dlPooling_pkl}
        # END samson FOR PRECHECK TC08
    END
    return from keyword if     '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Verify Bler and Dtx    ${verify_with_scenario}
    # return from keyword
    ${ue_groups}=  Get Dictionary Keys  ${csi_report_and_ue_info_dict}
    dated log     ====> Check target bler is less than percentage for direction=dl
    Run Keyword And Continue On Failure    Tti-lib.Check target bler is less than percentage
    ...                                              path_to_pickle=${path_to_ttitrace_dlfdsched_pkl}
    ...                                              xlaBlerTarget_hr_internal_value=${10}
    ...                                              xlaBlerTarget_br_internal_value=${10}
    ...                                              direction=dl
    ...                                              resultFile=${resultFile}
    dated log     ====> Check target bler is less than percentage for direction=ul
    Run Keyword And Continue On Failure    Tti-lib.Check target bler is less than percentage
    ...                                              path_to_pickle=${path_to_ttitrace_ulfdsched_pkl}
    ...                                              xlaBlerTarget_hr_internal_value=${10}
    ...                                              xlaBlerTarget_br_internal_value=${10}
    ...                                              direction=ul
    ...                                              resultFile=${resultFile}
    run keyword and continue on failure    CB013715_scenario_validations.Generate Test Verdict From TtiTraces
    Run Keyword And Ignore Error           Get subCellId mapping
    IF    '${w_check_prb_contraint}'=='True'
        ${step}=     Set Variable     MAIN STEP
        ${IS_CRT}=   Evaluate    'CRT' in @{TEST TAGS}
        IF     not ${IS_CRT}
            run keyword and continue on failure     DSS-Verdict-keywords.Generate Test Verdict For Prb Blanking
            ...                                                          FilePkl=${path_to_ttitrace_dlfdsched_pkl}
            ...                                                          verify_with_scenario=${verify_with_scenario}
        END

        ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
        ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
        sort list   ${distName_NRCELL}
        scf.load_scf    ${scf_file}
            ${chBwDl}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
            ${chBwUl}=    scf.get_value_from_scf    p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1

        ${bandwidth_dl}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl}
        ${bandwidth_ul}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwUl}

        ${PhysicalCellId1}=     Evaluate    ${50}+${fdd_cell_1}-${1}
        ${PhysicalCellId2}=     Evaluate    ${50}+${fdd_cell_2}-${1}
        ${prbBlanking_ul_1}     create dictionary     nbrOfBlankedPRBsLowEdgeUL=${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}
        ...                                           nbrOfBlankedPRBsHighEdgeUL=${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}
        ${context_ul_cell_1}    create dictionary     dir=ul   physCellId=${PhysicalCellId1}
        ...                                           actPrbBlanking=${parameters_PrbBlanking['actPRBBlanking']}
        ...                                           bandwidth=${bandwidth_dl}    prbBlanking=&{prbBlanking_ul_1}
        ${status}   AreBlankedPrbNotUsed.Predicate    ${context_ul_cell_1}    ${path_to_ttitrace_ulfdsched_pkl}
        BuiltIn.log     [ INFO ] AreBlankedPrbNotUsed_ul_cell${fdd_cell_1}_status=${status}     console=True
        ${resultTest}=    set variable if     '${status}'=='True'     PASS     FAIL
        Append To File   ${resultFile}    \n\t\t===> AreBlankedPrbNotUsed for ul cell${fdd_cell_1} status = ${resultTest}\n
        robot_extension.Run Keyword And Warn On Failure     Should be True   ${status}
        ...     msg=${consTraceColorRed}${context_ul_cell_1['dir']} direction: AreBlankedPrbNotUsed should be PASS for cell${fdd_cell_1}${defColor}
        declare Results in Test Results List     Type=Ttitrace: AreBlankedPrbNotUsed_ul_cell${fdd_cell_1}_status (PUSCH) for Step [${step}]
        ...                                      Result=${resultTest}

        ${prbBlanking_dl_1}     create dictionary     nbrOfBlankedPRBsLowEdgeDL=${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}
        ...                                           nbrOfBlankedPRBsHighEdgeDL=${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}
        ${context_dl_cell_1}    create dictionary     dir=dl   physCellId=${PhysicalCellId1}
        ...                                           actPrbBlanking=${parameters_PrbBlanking['actPRBBlanking']}
        ...                                           bandwidth=${bandwidth_ul}        prbBlanking=&{prbBlanking_dl_1}
        ${status}   AreBlankedPrbNotUsed.Predicate    ${context_dl_cell_1}    ${path_to_ttitrace_dlfdsched_pkl}
        ${resultTest}=    set variable if     '${status}'=='True'     PASS     FAIL
        BuiltIn.log     [ INFO ] AreBlankedPrbNotUsed_dl_cell${fdd_cell_1}_status=${status}     console=True
        Append To File   ${resultFile}    \t\t===> AreBlankedPrbNotUsed for dl cell${fdd_cell_1} status = ${resultTest}\n
        robot_extension.Run Keyword And Warn On Failure     Should be True   ${status}
        ...    msg=${consTraceColorRed}${context_ul_cell_1['dir']} direction: AreBlankedPrbNotUsed should be PASS for cell${fdd_cell_1}${defColor}
        declare Results in Test Results List     Type=Ttitrace: AreBlankedPrbNotUsed_dl_cell${fdd_cell_1}_status (PDSCH) for Step [${step}]
        ...                                      Result=${resultTest}

        ${list_of_ue_per_cell_to_be_attached}=    template.get_attach_list_per_cell  scenario_name=${verify_with_scenario}
        nps_tarf_tools.log_to_console_with_time_prefix    list_of_ue_per_cell_to_be_attached=${list_of_ue_per_cell_to_be_attached}    level=INFO
        ${cell2_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${list_of_ue_per_cell_to_be_attached}    2
        IF    ${cell2_exists}
            ${is_CELL_2_exits_in_JSON}=    set variable    ${True}
            ${text}     set variable     is_CELL_2_exits_in_JSON=${is_CELL_2_exits_in_JSON} => analysis is NOT bypassed.
        ELSE
            ${is_CELL_2_exits_in_JSON}=    set variable    ${False}
            ${text}     set variable     is_CELL_2_exits_in_JSON=${is_CELL_2_exits_in_JSON} => analysis is bypassed!
        END
        nps_tarf_tools.log_to_console_with_time_prefix    ${text}        level=INFO

        IF     ${is_CELL_2_exits_in_JSON}
            ${chBwDl}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1
            ${chBwUl}=    scf.get_value_from_scf    p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1

            ${bandwidth_dl}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl}
            ${bandwidth_ul}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwUl}

            ${prbBlanking_ul_2}     create dictionary     nbrOfBlankedPRBsLowEdgeUL=${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsLowEdgeUL']}
            ...                                           nbrOfBlankedPRBsHighEdgeUL=${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsHighEdgeUL']}
            ${context_ul_cell_2}    create dictionary     dir=ul   physCellId=${PhysicalCellId2}
            ...                                           actPrbBlanking=${parameters_PrbBlanking_Cell2['actPRBBlanking']}
            ...                                           bandwidth=${bandwidth_ul}    prbBlanking=&{prbBlanking_ul_2}
            ${status}   AreBlankedPrbNotUsed.Predicate    ${context_ul_cell_2}    ${path_to_ttitrace_ulfdsched_pkl}
            BuiltIn.log     [ INFO ] AreBlankedPrbNotUsed_ul_cell${fdd_cell_2}_status=${status}     console=True
            ${resultTest}=    set variable if     '${status}'=='True'     PASS     FAIL
            Append To File   ${resultFile}    \t\t===> AreBlankedPrbNotUsed for ul cell${fdd_cell_2} status = ${resultTest}\n
            robot_extension.Run Keyword And Warn On Failure     Should be True   ${status}
            ...  msg=${consTraceColorRed}${context_ul_cell_1['dir']} direction: AreBlankedPrbNotUsed should be PASS for cell${fdd_cell_2}${defColor}
            declare Results in Test Results List     Type=Ttitrace: AreBlankedPrbNotUsed_ul_cell${fdd_cell_2}_status (PUSCH) for Step [${step}]
            ...                                      Result=${resultTest}

            ${prbBlanking_dl_2}     create dictionary     nbrOfBlankedPRBsLowEdgeDL=${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsLowEdgeDL']}
            ...                                           nbrOfBlankedPRBsHighEdgeDL=${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsHighEdgeDL']}
            ${context_dl_cell_2}    create dictionary     dir=dl   physCellId=${PhysicalCellId2}
            ...                                           actPrbBlanking=${parameters_PrbBlanking_Cell2['actPRBBlanking']}
            ...                                           bandwidth=${bandwidth_dl}        prbBlanking=&{prbBlanking_dl_2}
            ${status}   AreBlankedPrbNotUsed.Predicate    ${context_dl_cell_2}    ${path_to_ttitrace_dlfdsched_pkl}
            BuiltIn.log     [ INFO ] AreBlankedPrbNotUsed_dl_cell${fdd_cell_2}_status=${status}     console=True
            ${resultTest}=    set variable if     '${status}'=='True'     PASS     FAIL
            Append To File   ${resultFile}    \t\t===> AreBlankedPrbNotUsed for dl cell${fdd_cell_2} status = ${resultTest}\n
            robot_extension.Run Keyword And Warn On Failure     Should be True   ${status}
            ...  msg=${consTraceColorRed}${context_ul_cell_1['dir']} direction: AreBlankedPrbNotUsed should be PASS for cell${fdd_cell_2}${defColor}
            declare Results in Test Results List     Type=Ttitrace: AreBlankedPrbNotUsed_dl_cell${fdd_cell_2}_status (PDSCH) for Step [${step}]
            ...                                      Result=${resultTest}
        END
        ${IS_CRT}=    Evaluate    'CRT' in @{TEST TAGS}
        return from keyword if     ${IS_CRT}
        pdcch_dci_decode.Decode_PDCCH_Dciinfo    ${path_to_ttitrace_dlPdcchDciData_csv}
        pdcch_dci_decode.Decode_PDCCH_Dciinfo    ${path_to_ttitrace_ulPdcchDciData_csv}
        ${ue_groups}=  Get Dictionary Keys  ${csi_report_and_ue_info_dict}
        FOR  ${ue_group}  IN  @{ue_groups}
            ${rnti_list}=     Set Variable    ${csi_report_and_ue_info_dict["${ue_group}"]["rntis"]}
            ${ue_rntis_keys}=  Get Dictionary Keys  ${rnti_list}
            FOR  ${ue_rnti_key}  IN  @{ue_rntis_keys}
                ${rnti}   Get From Dictionary       ${rnti_list}     ${ue_rnti_key}
                pdcch_dci_decode.Verify_DCI    ${path_to_ttitrace_dlPdcchDciData_pkl}    dir=dl    ue_rnti=${rnti}    nbrEvent=${4000}
                pdcch_dci_decode.Verify_DCI    ${path_to_ttitrace_ulPdcchDciData_pkl}    dir=ul    ue_rnti=${rnti}    nbrEvent=${4000}
                dated log    DCI decoding completed for ue_rnti=${rnti}
            END
        END
        dated log    DCI decoding completed
    END

Verify Bler and Dtx
   [Arguments]  ${scenario}
   ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
   Extract TTI Trace and Convert to Pickle for Bler and Dtx  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pcap
   ...  ttitracepath=${ts_log_dir}/tti_trace_${collector_name}/
   Get Statistical Analysis of DL TTI Trace Events
   Get Statistical Analysis of UL TTI Trace Events


Verify UserSetup with ${verify_with_scenario}
    return from keyword if     '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'
    BuiltIn.log      scenario=${verify_with_scenario}
    ${usersetupreq_config_Sorted}=    usersetup_req_parser.extract_sa_param_user_relation    ${path_to_syscom_pdml}    ncell_ref=32769
    Append To File   ${resultFile}    \n
    FOR     ${item}    IN     @{usersetupreq_config_Sorted}
        Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase
        ...                             ${item}
        ...                             title=Itf-l2ps-UserSetupReq-CellId-${item['cellId']}-rnti-${item['rnti']}-ueAddCause-${item['ueAddCause']}
        Append To File   ${resultFile}
        ...              \tItf-l2ps-UserSetupReq-CellId-${item['cellId']}-rnti-${item['rnti']}-ueAddCause-${item['ueAddCause']}=${item}\n
    END
    # only check for Cell1 !!!
    ${index_cell_in_msg}=     evaluate     ${fdd_cell_1}-${1}
    ${usersetupreq_config_Sorted_cell1}=    set variable    ${usersetupreq_config_Sorted[${index_cell_in_msg}]}
    return from keyword if     'CA' in '${SUITE_NAME}'
    BuiltIn.Run Keyword And Warn On Failure    Check In L3L2 SRS User Setup    ${verify_with_scenario}
    ...                                                                        ${usersetupreq_config_Sorted_cell1['freqDomainPosition']}
    ...                                                                        ${usersetupreq_config_Sorted_cell1['freqDomainShift']}
    ...                                                                        ${path_to_syscom_cellsetup_initial_pdml}


Verify CellSetup with ${verify_with_scenario}
    return from keyword if     '${logs_and_traces_flags['Syscom_L2_L3_Trace']}'=='False'
    BuiltIn.log      scenario=${verify_with_scenario}
    ${cellsetupreq_config_Sorted}=    cellsetup_req_parser.extract_sa_param_cellsetup_relation    ${path_to_syscom_cellsetup_initial_pdml}
    Append To File   ${resultFile}    \n
    FOR     ${item}    IN     @{cellsetupreq_config_Sorted}
        Run Keyword And Ignore Error    nps_feature_tools.display_dictionnary_parameters_of_the_TestCase
        ...                                        ${item}
        ...                                        title=Itf-l2ps-CellSetupReq-CellId-${item['cellId']}
        Append To File   ${resultFile}     \tItf-l2ps-CellSetupReq-CellId-${item['cellId']}=${item}\n
    END
    # only check for Cell1 meaning ${fdd_cell_1}
    ${index_cell_in_msg}=     evaluate     ${fdd_cell_1}-${1}
    ${cellsetupreq_config_cell1}=    set variable    ${cellsetupreq_config_Sorted[${index_cell_in_msg}]}
    run keyword and continue on failure      Check In L3L2 TRS Cell Setup Configuration   ${verify_with_scenario}
    ...                                                                                   ${cellsetupreq_config_cell1['csirsTrackingStartingPrb']}
    ...                                                                                   ${cellsetupreq_config_cell1['csirsTrackingNumOfPrbs']}
    ...                                                                                   ${path_to_syscom_cellsetup_initial_pdml}


Verify CB013715 PMC values
    [Arguments]  ${scenario}
    IF        '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
        builtIn.log     [INFO] BEWARE that TtiTrace are mandatory for PMC verification!     level=WARN
    END
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    Convert TTI Traces to Dataframe and store as pickle for DL Prb    collector=${collector_name}
    ${output_dl_prb_statistics}    ${output_dl_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                          Tti-lib.get_prb_statistics_physCellId_dl
    ...                                                                                 ${path_to_ttitrace_dlfdsched_pkl}
    nps_tarf_tools.log_to_console_with_time_prefix   From TtiTraces: avg Dl Prb is ${output_dl_prb_statistics_results['avg']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix   From TtiTraces: Dl Pdsch tx count is ${output_dl_prb_statistics_results['count']}   level=INFO
    Convert TTI Traces to Dataframe and store as pickle for UL Prb    collector=${collector_name}
    ${output_ul_prb_statistics}    ${output_ul_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                          Tti-lib.get_prb_statistics_physCellId_ul
    ...                                                                                 ${path_to_ttitrace_ulfdsched_pkl}
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: avg UL Prb is ${output_ul_prb_statistics_results['avg']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: UL Prb Sum is ${output_ul_prb_statistics_results['sum']}     level=INFO
    ${pdsch_tx_count}    run keyword and continue on failure    check_PMC.Verify PMC values    topo_tl=${SW_POSTFIX}    cell_id=${fdd_cell_1}
    ...                                                                   dl_prb_avg=${output_dl_prb_statistics_results['avg']}
    ...                                                                   ul_prb_avg=${output_ul_prb_statistics_results['avg']}
    nps_tarf_tools.log_to_console_with_time_prefix     From PMC: pdsch tx count is ${output_dl_prb_statistics_results['count']}     level=INFO
    check_PMC.verify_within_threshold    pid=M55300C0600x     pm_info=pdsch tx count
    ...            reported_value=${pdsch_tx_count}  expected_value=${output_dl_prb_statistics_results['count']}
    ...            threshold_percent=5      filename=${resultFile}


Verify PMC values with nb of scenario equal to ${nb_scenario} with ${scenario}
    ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario}
    ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario}
    ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
    IF  not ${is_with_pm_counters}   RETURN
    nps_tarf_tools.log_info    functionNameStr=Verify PMC values with nb of scenario equal to ${nb_scenario} with ${scenario}
    ...                       message=--------> Verify PMC values
    append to file     ${resultFile}     \n\t--------> Verify PMC values\n
    IF        '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
        builtIn.log     [INFO] BEWARE that TtiTrace are mandatory for PMC verification!     level=WARN
    END
    ${result_filename}    nps_tarf_tools.return_basename   ${resultFile}
    ${result_path}        nps_tarf_tools.return_path       ${resultFile}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_dlfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlFdSchedData.pkl
    ${path_to_ttitrace_ulfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulFdSchedData.pkl
    ${path_to_syslog}=    set variable  ${ts_log_dir}/btslog/syslog_files.tgz
    set test variable    ${path_to_ttitrace_dlfdsched_pkl}
    set test variable    ${path_to_ttitrace_ulfdsched_pkl}
    set test variable    ${path_to_syslog}
    dated log     --------> Calculate DL/UL Prb usage mean/median/sum/count based TtiTraces
    append to file     ${resultFile}     \n\t--------> Calculate DL/UL Prb usage mean/median/sum/count based TtiTraces\n
    Convert TTI Traces to Dataframe and store as pickle for DL Prb    collector=${collector_name}
    dated log     [INFO] get_prb_statistics_physCellId_dl return numOfPrb per rnti and NbrPrbPerSlot!!!
    ${output_dl_prb_statistics}    ${output_dl_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                    Tti-lib.get_prb_statistics_physCellId_dl
    ...                                                                                 ${path_to_ttitrace_dlfdsched_pkl}
    ...                                                                                 w_display_table=${True}
    ...                                                                                 base_location=${result_path}
    ...                                                                                 filename=${result_filename}
    ...                                                                                 both=${True}
    nps_tarf_tools.log_to_console_with_time_prefix  From TtiTraces: avg Dl Prb is ${output_dl_prb_statistics_results['avg']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix  From TtiTraces: median Dl Prb is ${output_dl_prb_statistics_results['median']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix  From TtiTraces: sum Dl Prb is ${output_dl_prb_statistics_results['sum']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix  From TtiTraces: Dl Pdsch tx count is ${output_dl_prb_statistics_results['count']}     level=INFO
    append to file     ${resultFile}     \n\tFrom TtiTraces: avg Dl Prb is ${output_dl_prb_statistics_results['avg']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: median Dl Prb is ${output_dl_prb_statistics_results['median']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: sum Dl Prb is ${output_dl_prb_statistics_results['sum']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: Dl Pdsch tx count is ${output_dl_prb_statistics_results['count']}\n
    Convert TTI Traces to Dataframe and store as pickle for UL Prb    collector=${collector_name}
    dated log     [INFO] get_prb_statistics_physCellId_ul return numOfPrb per rnti and NbrPrbPerSlot!!
    ${output_ul_prb_statistics}    ${output_ul_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                          Tti-lib.get_prb_statistics_physCellId_ul
    ...                                                                                 ${path_to_ttitrace_ulfdsched_pkl}
    ...                                                                                 w_display_table=${True}
    ...                                                                                 base_location=${result_path}
    ...                                                                                 filename=${result_filename}
    ...                                                                                 both=${True}
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: avg UL Prb is ${output_ul_prb_statistics_results['avg']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: median UL Prb is ${output_ul_prb_statistics_results['median']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: sum UL Prb is ${output_ul_prb_statistics_results['sum']}     level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: Ul Pusch tx count is ${output_ul_prb_statistics_results['count']}   level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     From TtiTraces: where we have max numOfPrb, ul_max_ratio = 100*(numOfPrb/rrmMaxNumPrbUl)
    ...      level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix  From TtiTraces: ul_ratio_max is ${output_ul_prb_statistics_results['ul_ratio_max_or_dl_max_prb']}
    ...      level=INFO
    append to file     ${resultFile}     \n\tFrom TtiTraces: avg Ul Prb is ${output_ul_prb_statistics_results['avg']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: median Ul Prb is ${output_ul_prb_statistics_results['median']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: sum Ul Prb is ${output_ul_prb_statistics_results['sum']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: Ul Pusch tx count is ${output_ul_prb_statistics_results['count']}\n
    append to file     ${resultFile}     \n\tFrom TtiTraces: ul_ratio_max is ${output_ul_prb_statistics_results['ul_ratio_max_or_dl_max_prb']}\n
    Verify PRB Avg with scenario ${scenario}
    dated log     --------> Verify PMC values
    append to file     ${resultFile}     \n\t--------> Verify PMC values\n
    ${pdsch_tx_count}   ${M55308C10002_value}    run keyword and continue on failure   check_PMC.Verify PMC values
    ...                                                                                      topo_tl=${SW_POSTFIX}    cell_id=${fdd_cell_1}
    ...                                                                                      dl_prb_avg=${output_dl_prb_statistics_results['avg']}
    ...                                                                                      ul_prb_avg=${output_ul_prb_statistics_results['avg']}
    ...                                                                                      nbr_sce=${nb_scenario}   filename=${resultFile}
    nps_tarf_tools.log_to_console_with_time_prefix     \nFrom PMC: pdsch tx count is ${pdsch_tx_count}     level=INFO
    append to file     ${resultFile}     \n\tFrom PMC: pdsch tx count is ${pdsch_tx_count}\n
    check_PMC.print_pm_counter_testcase_info_to_console    tc_name=${TEST NAME}    cell_id=Cell-${fdd_cell_1}
    check_PMC.print_pm_counter_testcase_header    qcTestCaseName=${TEST NAME}    testcase_str=${TEST NAME[0:10]}    filename=${resultFile}
    ${tc_result}=    check_PMC.verify_pm_within_threshold    pid=M55300C0600x     pm_info=pdsch tx count
    ...            reported_value=${pdsch_tx_count}  expected_value=${output_dl_prb_statistics_results['count']}
    ...            threshold_percent=10      filename=${resultFile}
    check_PMC.print_pm_counter_testcase_footer    tc_result=${tc_result}    filename=${resultFile}
    ${tc_result}=    check_PMC.verify_pm_within_threshold    pid=M55308C10002     pm_info=PRBs used for PUSCH
    ...            reported_value=${M55308C10002_value}  expected_value=${output_ul_prb_statistics_results['sum']}
    ...            threshold_percent=8      filename=${resultFile}
    check_PMC.print_pm_counter_testcase_footer    tc_result=${tc_result}    filename=${resultFile}
    #  M55308C36001: Max DL PRB utilization per slot
    #  M55308C36002: Max UL PRB Utilization per slot
    ${dl_max_prb}=      Convert To Integer    ${output_dl_prb_statistics_results['ul_ratio_max_or_dl_max_prb']}
    ${ul_ratio_max}=    Convert To Integer    ${output_ul_prb_statistics_results['ul_ratio_max_or_dl_max_prb']}
    #  dl_ratio_max calculation
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
        ${chBwDl}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
        ${nbrOfBlankedPRBsHighEdgeDL}=  scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nbrOfBlankedPRBsHighEdgeDL
        ${nbrOfBlankedPRBsLowEdgeDL}=   scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nbrOfBlankedPRBsLowEdgeDL
    ${nbrOfBlankedPRBsHighEdgeDL_int}=        Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL_int}=         Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL}
    ${nbrOfBlankedPRBsDL}    Evaluate    ${nbrOfBlankedPRBsHighEdgeDL} + ${nbrOfBlankedPRBsLowEdgeDL}
    ${bandwidth_dl}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl}
    ${max_usable_prb}=    Evaluate   ${bandwidth_dl} - ${nbrOfBlankedPRBsDL}
    ${total_prb_bw_int}=                      Convert To Integer    ${bandwidth_dl}
    ${chBW}   ${rat0bitmap_full}  ${usablepdsch}   ${rat0bitmap}   CB013715_tools.cal_num_of_pdsch   chBW=${total_prb_bw_int}     ConfigType=${1}
    ...                                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_int}
    ...                                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_int}
    nps_tarf_tools.log_to_console_with_time_prefix        cal_num_of_pdsch : chBW=${chBW} ConfigType=1 full rat0bitmap_full=${rat0bitmap_full}
    ...    level=INFO
    Append To File   ${resultFile}    \tcal_num_of_pdsch : chBW=${chBW} ConfigType=Type1 full rat0bitmap=${rat0bitmap_full}\n
    nps_tarf_tools.log_to_console_with_time_prefix        ===> usablepdsch=${usablepdsch} rat0bitmap=${rat0bitmap}    level=INFO
    Append To File   ${resultFile}    \tusablepdsch=${usablepdsch} rat0bitmap=${rat0bitmap}\n
    ${dl_ratio_max}=    Evaluate    ${dl_max_prb}/${usablepdsch}*${100}
    ${dl_ratio_max_int}   Convert To Integer    ${dl_ratio_max}
    ${details}=   Catenate  ${fdd_cell_1}:M55308C36001:${dl_ratio_max_int}:verify_within_threshold:0:
    ...                     M55308C36002:${ul_ratio_max}:verify_within_threshold:0
    ${details2}=  Catenate  ${fdd_cell_1}:M55308C10002:${output_ul_prb_statistics_results['sum']}:verify_within_threshold:7:
    ...                     M55332C02001:300000:verify_within_threshold:0
    run keyword and continue on failure    check_PMC.verify_pmc     CB013715
    ...                                                             ${details}
    ...                                                             ${details2}    filename=${resultFile}
    dated log     --------> Verify KPI values
    # append to file     ${resultFile}     \n\t--------> Verify KPI values\n
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5231 5G DSS Allocation ratio of DL slots assigned to NR;100*(M55332C00001)/(M55332C02001)               level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5232 5G DSS Maximum allocation ratio of DL slots assigned to NR;100*(M55332C00002)/(M55332C00001)       level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5233 5G DSS Minimum allocation raio of DL slots assigned to NR;100*(M55332C00003)/(M55332C00001)        level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5234 5G DSS Allocation ratio of UL PRBs assigned to NR;100*(M55332C01001)/(M55332C02002)                level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5235 5G DSS Maximum allocation ratio of UL PRBs assigned to NR;100*(M55332C01002)/(M55332C01001)        level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix
    ...   NR_5236 5G DSS Minimum allocation ratio of UL PRBs share assigned to NR;100*(M55332C01003)/(M55332C01001)  level=INFO
    ${relative_CB0013715_DssKpi_constraints_path}    set variable   ../../../../../CB013715/resources/counters/KpiDss.csv
    ${list_files}=    nps_tarf_tools.unzip_gnb_pm_counters_file    ${ts_log_dir}/PMC/gnb_pm_counters/gnb_pm_counters.zip
    # FOR    ${pm_file}    IN    @{list_files}
    #     ${CB0013715_DssKpi_constraints}=    nps_tarf_tools.get_file_path     relative_path=${relative_CB0013715_DssKpi_constraints_path}
    #     KPI Evaluate                    pmFile=${pm_file}
    #     ...                             constraintsFile=${CB0013715_DssKpi_constraints}
    #     ...                             failOnError=${False}
    # END
    ${pm_file}=   set variable  ${list_files[1]}
    ${CB0013715_DssKpi_constraints}=    nps_tarf_tools.get_file_path     relative_path=${relative_CB0013715_DssKpi_constraints_path}
    KPI Evaluate                    pmFile=${pm_file}
    ...                             constraintsFile=${CB0013715_DssKpi_constraints}
    ...                             failOnError=${False}

Prepare Variables for PMC Validation
    [Arguments]  ${scenario}
    ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario}
    ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario}
    ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
    IF  not ${is_with_pm_counters}   RETURN
    ${path_to_pmc_csv}=   set variable  ${ts_log_dir}/PMC/gnb_pm_counters/pmCounters.csv
    ${path_to_scf_xml}=   set variable  ${configuration_directory}/scf_${scenario}.xml
    ${pm_counters_dir}=   set variable  ${ts_log_dir}/PMC/gnb_pm_counters/
    ${pmc_index}=  nps_tarf_tools.get_pmc_index
    ...                                 scenario=${scenario}
    ...                                 pm_offset_path=${pm_counters_dir}/pm_counter_offsets.json

    set test variable  ${path_to_pmc_csv}
    set test variable  ${path_to_scf_xml}
    set test variable  ${pm_counters_dir}
    set test variable  ${pmc_index}

    # [0-9]{2} --> only two digit numbers
    ${distName_PDCCH}=    Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-1
    set test variable  ${distName_PDCCH}
    set test variable  ${distName_NRCELL}

    Set SW POSTFIX Variable equaled to cellTechnology    gnb_scf=${path_to_scf_xml}

Verify PRB Avg with scenario ${scenario}
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    append to file     ${resultFile}     \n\t--------> Verify Prb Avg\n

    ${result_filename}    nps_tarf_tools.return_basename   ${resultFile}
    ${result_path}        nps_tarf_tools.return_path       ${resultFile}
    ${collector_name}=    template.get_collector_name  scenario_name=${scenario}

    dated log      ${consTraceColor}--------> [DL/UL] Prb STATS${defColor}
    append to file     ${resultFile}     \n\t--------> [DL/UL] Prb STATS\n

    ${path_to_ttitrace_dlfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlFdSchedData.pkl
    ${path_to_ttitrace_ulfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulFdSchedData.pkl

    ${output_dl_prb_statistics}     ${output_dl_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                               Tti-lib.get_prb_statistics_physCellId_dl
    ...                                                                                 ${path_to_ttitrace_dlfdsched_pkl}
    dated log      ==output_dl_prb_statistics==
    append to file     ${resultFile}     \n\t==output_dl_prb_statistics==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html      ${output_dl_prb_statistics}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${output_dl_prb_statistics}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}

    ${output_ul_prb_statistics}    ${output_ul_prb_statistics_results}=   Run keyword and continue on failure
    ...                                                                            Tti-lib.get_prb_statistics_physCellId_ul
    ...                                                                                ${path_to_ttitrace_ulfdsched_pkl}
    dated log      ==path_to_ttitrace_ulfdsched_pkl==
    append to file     ${resultFile}     \n\t==path_to_ttitrace_ulfdsched_pkl==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html      ${output_ul_prb_statistics}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${output_ul_prb_statistics}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}


Prepare Variables for Validation
    [Arguments]  ${scenario}
    ${collector_name}=  template.get_collector_name  scenario_name=${scenario}
    ${path_to_ttitrace_json}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.json
    ${path_to_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pkl
    ${path_to_ttitrace_dl_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlharq.pkl   # Get Statistical Analysis
    ${path_to_ttitrace_dlfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlFdSchedData.pkl
    ${path_to_ttitrace_ulfdsched_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulFdSchedData.pkl
    ${path_to_ttitrace_dlPdcchDciData_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlPdcchDciData.pkl
    ${path_to_ttitrace_ulPdcchDciData_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulPdcchDciData.pkl
    ${path_to_ttitrace_csirsscheddata_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_csiRsSchedData.pkl
    ${path_to_ttitrace_ulPooling_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulPooling.pkl
    ${path_to_ttitrace_dlPooling_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlPooling.pkl
    ${path_to_dl_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlFdSchedData.pkl
    ${path_to_ul_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_ulFdSchedData.pkl
    ${path_to_dlharq_ttitrace_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_dlharq.pkl
    ${path_to_ttitrace_rach_pkl}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming_rach_ul_dl.pkl
    ${path_to_ttitrace_csv}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/tti_trace_${scenario}_default_scenario_dl_and_ul.csv
    ${path_to_ttitrace_dlPdcchPatternData_csv}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_dlPdcchPatternData.csv
    ${path_to_ttitrace_ulPdcchPatternData_csv}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_ulPdcchPatternData.csv
    ${path_to_ttitrace_ulPucchReceiveReqData_csv}=   set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_ulPucchReceiveReqData.csv
    ${path_to_ttitrace_ulPuschReceiveRespPsData_csv}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_ulPuschReceiveRespPsData.csv
    ${path_to_ttitrace_ulFdSchedData_csv}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_ulFdSchedData.csv
    ${path_to_ttitrace_dlPdcchDciData_csv}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_dlPdcchDciData_ttitrace.csv
    ${path_to_ttitrace_ulPdcchDciData_csv}=  set variable  ${ts_log_dir}/tti_trace_${collector_name}/filtered_ulPdcchDciData_ttitrace.csv
    ${path_to_syscom_cellsetup_initial_pcap}=    set variable  ${LOG_PATH}/cell_setup_trace_initial/l2_l3_syscom_tcpdump.pcap
    ${path_to_syscom_cellsetup_initial_pdml}=    set variable  ${LOG_PATH}/cell_setup_trace_initial/l2_l3_syscom_tcpdump.pdml
    ${path_to_syscom_cellsetup_change_config_pdml}=
    ...                        set variable  ${ts_log_dir}/syscom_l2_l3_change_config_${collector_name}/l2_l3_syscom_tcpdump.pdml
    ${path_to_scf_xml}=        set variable  ${configuration_directory}/scf_${scenario}.xml
    ${path_to_l1l2_pcap}=      set variable  ${ts_log_dir}/l1_l2_${collector_name}
    ${path_to_pmc_csv}=        set variable  ${ts_log_dir}/PMC/gnb_pm_counters/pmCounters.csv
    ${path_to_l1l2_csv}=       set variable  ${path_to_l1l2_pcap}/msg_DlData_PdcchSendReq_pcap.csv
    ${path_to_initial_cellsetup_traces}=        set variable  ${ts_log_dir}/../initial_cell_setup_trace
    ${path_to_syscom_pdml}=    set variable  ${ts_log_dir}/syscom_l2_l3_${collector_name}/l2_l3_syscom_tcpdump.pdml
    ${collector_name}=  template.get_collector_name     ${scenario}
    ${path_to_bh_pcap}=        set variable  ${ts_log_dir}/backhaul_${collector_name}/backhaul_${collector_name}/backhaul_${collector_name}.pcap
    ${path_to_bh_pdml}=        set variable  ${ts_log_dir}/backhaul_${collector_name}/backhaul.pdml
    ${path_to_bh_xp_pdml}=     set variable  ${ts_log_dir}/backhaul_${collector_name}/backhaul.pdml
    ${path_to_syslog_cellsetup_initial_tgz}    set variable     ${LOG_PATH}/btslog2_Intialize_Test_Suite/btslog/syslog_files.tgz
    Extract Tar File    ${path_to_syslog_cellsetup_initial_tgz}    ${ts_log_dir}
    ${path_to_syslog_cellsetup_initial}    set variable    ${ts_log_dir}
    # ${path_to_ttitrace_streaming_dlPdcchDciData}    set variable
    # [0-9]{2} --> only two digit numbers
    ${distName_PDCCH}=      Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    ${distName_NRCELL}=     Scenario-Common-Keywords.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    set test variable  ${distName_PDCCH}
    set test variable  ${distName_NRCELL}
    set test variable  ${path_to_ttitrace_json}
    set test variable  ${path_to_ttitrace_pkl}
    set test variable  ${path_to_ttitrace_dl_pkl}
    set test variable  ${path_to_ttitrace_dlfdsched_pkl}
    set test variable  ${path_to_ttitrace_ulfdsched_pkl}
    set test variable  ${path_to_ttitrace_csirsscheddata_pkl}
    set test variable  ${path_to_ttitrace_ulPooling_pkl}
    set test variable  ${path_to_ttitrace_dlPooling_pkl}
    set test variable  ${path_to_dl_ttitrace_pkl}
    set test variable  ${path_to_ul_ttitrace_pkl}
    set test variable  ${path_to_dlharq_ttitrace_pkl}
    set test variable  ${path_to_ttitrace_rach_pkl}
    set test variable  ${path_to_ttitrace_csv}
    set test variable  ${path_to_ttitrace_dlPdcchPatternData_csv}
    set test variable  ${path_to_ttitrace_ulPdcchPatternData_csv}
    set test variable  ${path_to_ttitrace_ulPucchReceiveReqData_csv}
    set test variable  ${path_to_ttitrace_ulPuschReceiveRespPsData_csv}
    set test variable  ${path_to_ttitrace_ulFdSchedData_csv}
    set test variable  ${path_to_syscom_cellsetup_initial_pcap}
    set test variable  ${path_to_syscom_cellsetup_initial_pdml}
    set test variable  ${path_to_syscom_cellsetup_change_config_pdml}
    set test variable  ${path_to_scf_xml}
    set test variable  ${path_to_bh_xp_pdml}
    set test variable  ${path_to_pmc_csv}
    set test variable  ${path_to_l1l2_csv}
    set test variable  ${path_to_initial_cellsetup_traces}
    set test variable  ${path_to_syscom_pdml}
    set test variable  ${path_to_bh_pdml}
    set test variable  ${path_to_bh_pcap}
    set test variable  ${path_to_syslog_cellsetup_initial}
    set test variable  ${path_to_syslog_cellsetup_initial_tgz}
    set test variable  ${path_to_ttitrace_dlPdcchDciData_csv}
    set test variable  ${path_to_ttitrace_ulPdcchDciData_csv}
    set test variable  ${path_to_ttitrace_dlPdcchDciData_pkl}
    set test variable  ${path_to_ttitrace_ulPdcchDciData_pkl}

    Initialisation Variables SA FDD with Blanking     verify_with_scenario=${scenario}

    ${dtx_values}=    Set variable    DTX
    # translate tolerance = 0.1 to tolerance = 10 %
    @{dl_dtx_threshold_percent}=     Evaluate   map(lambda x: int(float(x) * 100), @{dl_dtx_threshold})
    # builtIn.log    dl_dtx_threshold_percent=${dl_dtx_threshold_percent}    console=True
    @{ul_dtx_threshold_percent}=     Evaluate   map(lambda x: int(float(x) * 100), @{ul_dtx_threshold})
    # builtIn.log    ul_dtx_threshold_percent=${ul_dtx_threshold_percent}    console=True
    Set test variable    &{dl_dtx_validation}    Value=${dtx_values}    Threshold=${dl_dtx_threshold_percent}
    Set test variable    &{ul_dtx_validation}    Value=${dtx_values}    Threshold=${ul_dtx_threshold_percent}

    Set SW POSTFIX Variable equaled to cellTechnology    gnb_scf=${path_to_scf_xml}

    Load scf values for validations    ${scenario}

    ${IS_CRT}=   Evaluate    'CRT' in @{TEST TAGS}
    IF     not ${IS_CRT}
        ${13715_ET_BASE_PATH_TO_JSON}=    set variable    ${13715_ET_BASE_PATH}
    ELSE
        ${13715_ET_BASE_PATH_TO_JSON}=    set variable    ${CURDIR}
    END
    ${test_json_files}    nps_tarf_tools.get_test_json_file_paths    ${13715_ET_BASE_PATH_TO_JSON}
    Run Keyword And Ignore Error    OperatingSystem.Run  mkdir -p ${ts_log_dir}/JSON
    FOR    ${json_file}    IN    @{test_json_files}
        Run Keyword And Ignore Error    OperatingSystem.Run   cp -r ${json_file} ${ts_log_dir}/JSON 2>&1
    END

    return from keyword if     '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}'=='False'
    return from keyword if     '${logs_and_traces_flags['BIPTrace']['start_point']}'=='during_cellsetup'
    ${pcap_files}=     OperatingSystem.List Files In Directory    ${path_to_l1l2_pcap}/  *.pcap
    ${pcap_full_paths}=    Create List
    FOR    ${file}   IN   @{pcap_files}
        ${full_path}   Join Path    ${path_to_l1l2_pcap}  ${file}
        Append To List    ${pcap_full_paths}   ${full_path}
    END
    set test variable  ${path_to_l1l2_pcap}
    set test variable  ${pcap_full_paths}

Initialisation Variables SA FDD with Blanking
    [Documentation]   All global variables needed for the checks in L2L1. Variables are set according to the number of blanking PRB configuration.
    ...    nbrOfBlankedPRBsHighEdgeDL=12
    ...    nbrOfBlankedPRBsHighEdgeUL=12
    ...    nbrOfBlankedPRBsLowEdgeDL=14
    ...    nbrOfBlankedPRBsLowEdgeUL=14
    [arguments]      ${verify_with_scenario}
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
        ${chBwDl}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
        ${chBwUl}=    scf.get_value_from_scf    p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
        ${trsMutingInBlankedPRBsEnabled}    scf.get_value_from_scf    p_name=trsMutingInBlankedPRBsEnabled
        ...                                                          dist_name=${distName_NRCELL[${fdd_cell_1}-1]}
        ${msg1FrequencyStart}    scf.get_value_from_scf    p_name=msg1FrequencyStart
        ...                                                dist_name=${distName_NRCELL[${fdd_cell_1}-1]}

    ${bandwidth_dl}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl}
    ${bandwidth_ul}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwUl}

    ${nbrOfBlankedPRBsLowEdgeDL}    set variable   ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}
    ${brOfBlankedPRBsHighEdgeDL}    set variable   ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}
    ${nbrOfBlankedPRBsLowEdgeUL}    set variable   ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}
    ${nbrOfBlankedPRBsHighEdgeUL}    set variable   ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}
    ${actPrbBlanking}     set variable     ${parameters_PrbBlanking['actPRBBlanking']}
    set test variable     ${trsMutingInBlankedPRBsEnabled}

    Dated Log New Line     [Initialisation Variables SA FDD with Blanking]
    ${total_prb_bw}   set variable     ${bandwidth_dl}
    Set Suite Variable    ${total_prb_bw}

    Dated Log    -----> Bandwidth is ${chBwDl} and the total of PRB available in BW is ${total_prb_bw}.
    #blanking area location acording to nbrOfBlankedPRBsLowEdge and nbrOfBlankedPRBsHighEdge
    ${blanking_area_crb_low}       Evaluate      ${nbrOfBlankedPRBsLowEdgeDL}-1
    ${blanking_area_crb_high}      Evaluate      ${total_prb_bw}-${brOfBlankedPRBsHighEdgeDL}
    Set Suite Variable     ${blanking_area_crb_low}
    Set Suite Variable     ${blanking_area_crb_high}
    Dated Log    -----> Blanking area location:[crb0<xxx>crb${blanking_area_crb_low}<--BW-->crb${blanking_area_crb_high}<xxx>crb${total_prb_bw}(-1)]
    #Overlapping TC or not. No overlap allowed in SA
    Set Suite Variable     ${IsOverlapping}     False
    # For CSI RS for measurment and tracking (TRS)
    # From SPEC : set to 4*ROUNDUP(offsetPrbDl/4). For OffsetPrbDl see [5G_RAN_CP_36783]
    # From SPEC see [5G_RAN_CP_11056]
    ${csi_rs_size}        Set Variable If     '${chBwDl}' == '10MHz'    52
    ...                                       '${chBwDl}' == '15MHz'    80
    ...                                       '${chBwDl}' == '20MHz'    108    108
    Set Suite Variable    ${csi_rs_size}
    # Dated Log    -----> csi_rs_size = ${csi_rs_size}
    nps_tarf_tools.log_to_console_with_time_prefix     csi_rs_size is ${csi_rs_size}     level=INFO
    ${trs_size}    Set Variable If
    ...            '${trsMutingInBlankedPRBsEnabled}' == 'true'     ${blanking_area_crb_high}
    ...            '${trsMutingInBlankedPRBsEnabled}' == 'false'    ${csi_rs_size}
    Set Suite Variable   ${trs_size}
    # Dated Log    -----> trs_size = ${trs_size}
    nps_tarf_tools.log_to_console_with_time_prefix     trs_size is ${trs_size}     level=INFO

    #RAT0 allocation for PDSCH
    #From SPEC: In case of blanking. All RBGs containing at least one blanked PRB are excluded from PDSCH scheduling
    # Set Suite Variable    ${rat0_start}     ${16}
    # Set Suite Variable    ${rat0_end}       ${87}
    # Set Suite Variable    ${rat0_size}      ${72}
    # nps_tarf_tools.log_to_console_with_time_prefix     rat0_start is ${rat0_start} / rat0_end is ${rat0_end}      level=INFO
    # nps_tarf_tools.log_to_console_with_time_prefix     rat0_size is ${rat0_size}      level=INFO
    #RAT1 allocation for PUSCH and pdsch for msg2.
    #From SPEC: Blanked PRB are excluded from PUSCH scheduling
    # Set Suite Variable        ${rat1_start}     ${nbrOfBlankedPRBsLowEdgeUL}
    # ${rat1_end}    Evaluate   ${total_prb_bw}-${nbrOfBlankedPRBsHighEdgeUL}-1
    # Set Suite Variable        ${rat1_end}
    # nps_tarf_tools.log_to_console_with_time_prefix     rat1_start is ${rat1_start} / rat1_end is ${rat1_end}      level=INFO
    #PDCCH
    Set Suite Variable    ${l1l2_coreset0}        0x07f8000000000000
    Set Suite Variable    ${l1l2_coreset_init}    ${l1l2_coreset0}
    Set Suite Variable    ${l1l2_coreset_dedi}    ${l1l2_coreset0}
    #Msg 1
    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    ${cRbStartUl}     scf.get_value_from_scf    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl     index=0
    ${StartUl}        remove string     ${cRbStartUl}    crb
    ${prach_prb_offset}     Evaluate    ${StartUl}+${msg1FrequencyStart}
    Set Suite Variable    ${prach_prb_offset}
    nps_tarf_tools.log_to_console_with_time_prefix     StartUl is ${StartUl}                            level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     msg1FrequencyStart is ${msg1FrequencyStart}      level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     prach_prb_offset is ${prach_prb_offset}          level=INFO
    #SRS Configuration : 5G_RAN_CP_36175
    ${available_ul_prb}    Evaluate             ${total_prb_bw}-${nbrOfBlankedPRBsLowEdgeUL}-${nbrOfBlankedPRBsHighEdgeUL}
    ${c_srs}               Set Variable If     ${available_ul_prb} < ${24}    1
    ...                                        ${available_ul_prb} >= ${24} and ${available_ul_prb} < ${32}     7
    ...                                        ${available_ul_prb} >= ${32} and ${available_ul_prb} < ${52}     9
    ...                                        ${available_ul_prb} >= ${52} and ${available_ul_prb} < ${79}     14
    ...                                        ${available_ul_prb} >= ${79} and ${available_ul_prb} < ${106}    20
    ...                                        ${available_ul_prb} == ${106}    25
    Set Suite Variable    ${freq_pos}     ${0}
    Set Suite Variable    ${freq_shift}   ${prach_prb_offset}
    Set Suite Variable    ${c_srs}
    Set Suite Variable    ${b_srs}        ${0}
    Set Suite Variable    ${b_hop}        ${0}
    nps_tarf_tools.log_to_console_with_time_prefix     freq_pos is ${freq_pos}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     freq_shift is ${freq_shift}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     c_srs is ${c_srs}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     b_srs is ${b_srs}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     b_hop is ${b_hop}           level=INFO


Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    return from keyword


Extract TTI Trace and Convert to Pickle v1
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  create list    utcTimestampData
    ...                                 csiSrReportData
    ...                                 dlFdSchedData
    ...                                 ulFdSchedData
    ...                                 ulHarqRxData
    ...                                 dlHarqRxDataArray
    ...                                 ulPucchReceiveRespPsData
    ...                                 dlLaSwitchBetweenHrAndBr
    ...                                 ulLaSwitchBetweenHrAndBr

    Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                        events_list=${events_required}
    ...                                        write_to_pickle=${TRUE}

Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}    ${event_nr_max}=50000
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    BuiltIn.log    event_nr_max is ${event_nr_max}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}

    #--- dl -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData
    ...                               csiSrReportData
    ...                               dlHarqRxDataArray
    ...                               dlTdSchedSubcellData
    ...                               dlFdSchedData
    # ...                               dlPagingOrSibSchedData
    # ...                               dlPdcchDciData
    # ...                               dlPreTdBlockUeData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_dlFdSchedData_ttitrace.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_dlFdSchedData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

    #--- dl -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData
    ...                               dlPdcchDciData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_dlPdcchDciData_ttitrace.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_dlPdcchDciData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

    ${events_required}=  create list  utcTimeStampData
    ...                               csiRsSchedData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_csiRsSchedData_ttitrace.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_csiRsSchedData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

    #--- ul -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData
    ...                               csiSrReportData
    ...                               ulHarqRxData
    ...                               ulPucchReceiveRespPsData
    ...                               ulFdSchedData
    # ...                               ulPdcchDciData
    # ...                               ulPreTdBlockUeData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_ulFdSchedData_ttitrace.csv

    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_ulFdSchedData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

    #--- ul -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${IS_CRT}=   Evaluate    'CRT' in @{TEST TAGS}
    IF     not ${IS_CRT}
        ${events_required}=  create list  utcTimeStampData
        ...                               ulPdcchDciData
        ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
        ...                                                                   events_list=${events_required}
        ...                                                                   number_rows=${6000}
        ...                                                                   write_to_pickle=${TRUE}
        resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
        ...                                                           tti_trace_filename=filtered_ulPdcchDciData_ttitrace.csv
        ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
        ...                        ${ttitracepath}/ttitrace_streaming_ulPdcchDciData.pkl
        Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}
    END

    #--- ul -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${actSlowPrbPooling_SCF}=         Get actSlowPrbPooling from SCF       CellId=${fdd_cell_1}
    IF    '${actSlowPrbPooling_SCF}'=='true'
        ${events_required}=  create list  utcTimeStampData
        ...                               ulAllocatedPooledResourcesData    ulMetricIndData
        ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
        ...                                                                   events_list=${events_required}
        ...                                                                   number_rows=${6000}
        ...                                                                   write_to_pickle=${TRUE}
        resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
        ...                                                           tti_trace_filename=filtered_ulPooling_ttitrace.csv
        ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
        ...                        ${ttitracepath}/ttitrace_streaming_ulPooling.pkl
        Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}
    END
    return from keyword

    #--- DL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_dl}=  create list    utcTimestampData
    ...                                    dlFdSchedData
    ...                                    dlHarqRxDataArray
    ${dl_df}=    resource_ttitrace.Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                                         events_list=${events_required_dl}
    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${dl_df}
    ${dlharq_target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dlharq.pkl
    tti_dataframe.write_df_to_pickle    df=${dlharq_matcher_df}    target_path=${dlharq_target_path}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${dlharq_matcher_df}
    ...                                                           ${desired_storage_directory}
    ...                                                           tti_trace_filename=ttitrace_streaming_dlharq.csv

    return from keyword

    #--- RACH -----------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData                     preambleData
    ...                               ulHarqRxData                         dlHarqRxDataArray
    ...                               dlPreSchedData                       ulPreSchedData
    ${df}=  resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                events_list=${events_required}
    # ...                                                write_to_pickle=${TRUE}
    ${target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}
    ...                                                           ${target_path}
    ...                                                           tti_trace_filename=ttitrace_streaming_rach_ul_dl.csv
    ${target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_rach_ul_dl.pkl
    tti_dataframe.write_df_to_pickle    df=${df}    target_path=${target_path}

    ${events_required}=  create list  utcTimeStampData
    ...                               ulTdSchedSubcellData
    ...                               ulHarqRxData
    ...                               dlHarqRxDataArray
    ...                               dlTdSchedSubcellData
    ...                               dlFdSchedData
    ...                               csiSrReportData
    ...                               ulFdSchedData
    ...                               ulPucchReceiveRespPsData
    ...                               dlLaSwitchBetweenHrAndBr
    ...                               ulLaSwitchBetweenHrAndBr
    ...                               dlPdcchDciData
    ...                               ulPdcchDciData
    ...                               dlPreTdBlockUeData
    ...                               ulPreTdBlockUeData

    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_ttitrace.csv


Extract TTI Trace and Convert to Pickle for Bler and Dtx
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}    ${event_nr_max}=50000
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}
    #--- DL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_dl}=  create list    utcTimestampData
    ...                                    dlFdSchedData
    ...                                    dlHarqRxDataArray
    ${dl_df}=    resource_ttitrace.Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                                         events_list=${events_required_dl}
    ${dlharq_matcher_df}=    tti_dlharqmatcher.dlharq_matcher    dl_df=${dl_df}
    ${dlharq_target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_dlharq.pkl
    tti_dataframe.write_df_to_pickle    df=${dlharq_matcher_df}    target_path=${dlharq_target_path}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${dlharq_matcher_df}
    ...                                                           ${desired_storage_directory}
    ...                                                           tti_trace_filename=ttitrace_streaming_dlharq.csv

    return from keyword

    #--- RACH -----------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData                     preambleData
    ...                               ulHarqRxData                         dlHarqRxDataArray
    ...                               dlPreSchedData                       ulPreSchedData
    ${df}=  resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                events_list=${events_required}
    # ...                                                write_to_pickle=${TRUE}
    ${target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ${EMPTY}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}
    ...                                                           ${target_path}
    ...                                                           tti_trace_filename=ttitrace_streaming_rach_ul_dl.csv
    ${target_path}=    replace string    ${path_to_tti_trace_pcap}    ttitrace_streaming.pcap    ttitrace_streaming_rach_ul_dl.pkl
    tti_dataframe.write_df_to_pickle    df=${df}    target_path=${target_path}

Extract TTI Trace and Convert to Pickle for UL Pooling
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}

    #--- ul -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData
    ...                               ulAllocatedPooledResourcesData    ulMetricIndData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_ulPooling_ttitrace.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_ulPooling.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

Extract TTI Trace and Convert to Pickle for DL Pooling
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}

    #--- dl -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required}=  create list  utcTimeStampData
    ...                               dlAllocatedPooledResourcesData    dlMetricIndData
    ${df}=   resource_ttitrace.Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                                   events_list=${events_required}
    ...                                                                   number_rows=${6000}
    ...                                                                   write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                                           tti_trace_filename=filtered_dlPooling_ttitrace.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_dlPooling.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

Extract TTI Trace and Convert to Pickle for DL Prb Avg
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}    ${event_nr_max}=50000
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}
    #--- DL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_dl}=  create list    utcTimestampData
    ...                                    dlFdSchedData
    ${dl_df}=    resource_ttitrace.Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                                         events_list=${events_required_dl}
    ...                                                                         write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${dl_df}
    ...                                                           ${desired_storage_directory}
    ...                                                           tti_trace_filename=ttitrace_streaming_dlFdSchedData.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_dlFdSchedData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

Extract TTI Trace and Convert to Pickle for UL Prb Avg
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}    ${event_nr_max}=50000
    return from keyword if     '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    ${desired_storage_directory}=    nps_tarf_tools.return_path    file=${path_to_tti_trace_pcap}
    #--- UL -------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${events_required_dl}=  create list    utcTimestampData
    ...                                    ulFdSchedData
    ${ul_df}=    resource_ttitrace.Convert TTI trace from PCAP to data frame    input_file_path=${path_to_tti_trace_pcap}
    ...                                                                         events_list=${events_required_dl}
    ...                                                                         write_to_pickle=${TRUE}
    resource_ttitrace.Convert TTI trace from data frame to csv    ${ul_df}
    ...                                                           ${desired_storage_directory}
    ...                                                           tti_trace_filename=ttitrace_streaming_ulFdSchedData.csv
    ${cmd}=    Catenate     cp ${ttitracepath}/ttitrace_streaming.pkl
    ...                        ${ttitracepath}/ttitrace_streaming_ulFdSchedData.pkl
    Run Keyword And Ignore Error   OperatingSystem.Run    ${cmd}

Convert TTI Traces to Dataframe and store as pickle fo UL Pooling
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    # Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle for UL Pooling
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  ttitracepath=${ts_log_dir}/tti_trace_${collector}/

Convert TTI Traces to Dataframe and store as pickle fo DL Pooling
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    # Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle for DL Pooling
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  ttitracepath=${ts_log_dir}/tti_trace_${collector}/

Convert TTI Traces to Dataframe and store as pickle for DL Prb
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle for DL Prb Avg
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  ttitracepath=${ts_log_dir}/tti_trace_${collector}/

Convert TTI Traces to Dataframe and store as pickle for UL Prb
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle for UL Prb Avg
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  ttitracepath=${ts_log_dir}/tti_trace_${collector}/

Extract usedfull Info nr_l1dl_l2ps_dldata_pdcchsendreq_t from pcap
    [Arguments]  ${pcap_full_paths}

    Dated log                   Extract nr_l1dl_l2ps_dldata_pdcchsendreq_t info from PCAP file [${pcap_full_paths}]

    set test variable   ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t}
    ...                                                    pcapprocessed_Extract_pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t.txt
    set test variable   ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}  ${testCaseDir}/${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t}
    ${cmd1}=    Set Variable      tshark
    # 25R2
    # nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t
    # 24R3
    # nr_l1dl_l2ps_dldata_pdcchsendreq_t
    ${cmd_mcshark}    Catenate      ${cmd1} -r
    ...        ${pcap_full_paths} -T fields -Y "nr_l1dl_l2ps_dldata_pdcchsendreql1sw_t" -e _ws.col.Info
    # ...           -e frame.time_epoch
    ...           -e 3gpp.sfn
    ...           -e 3gpp.slot
    ...           -e 3gpp.rnti
    ...           -e DlData_DciInfoL1sw.dciSize
    ...           -e DlData_DciInfoL1sw.aggregationLevel
    ...           -e DlData_DciInfoL1sw.pdcchDciTransmitPower
    ...           -e DlData_DciInfoL1sw.pdcchPrecodingOption4x4
    ...           -E header=y -E separator=';' > ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}
    OperatingSystem.Run       ${cmd_mcshark}
    # remove space if present
    OperatingSystem.Run      command=sed -i -e 's/ //g' ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}

    # ${extract_col_info}   OperatingSystem.grep  -i  ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}   _ws.col.Info
    ${extract_col_info}   OperatingSystem.Run  command=grep -i _ws.col.Info ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}

    ${pattern}=     set variable       DlData_PdcchSendReq
    ${extract}  OperatingSystem.grep file  ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}
    ...                                    ${pattern}
    run keyword if  len($extract)==0     fail   DlData_PdcchSendReq not found
    OperatingSystem.copy file     ${pcapprocessed_nr_l1dl_l2ps_dldata_pdcchsendreq_t_path}    ${path_to_l1l2_pcap}/msg_DlData_PdcchSendReq_pcap.csv

    [return]    ${path_to_l1l2_pcap}/msg_DlData_PdcchSendReq_pcap.csv


Merge 2 csv files
    run keyword and continue on failure    CB012738.Verify_AL_selection_with_changing_CQI_values    ${path_to_ttitrace_pkl}
    ${dir}=    CB012738.get_directory    ${path_to_ttitrace_pkl}
    ${file_csv1}=    set variable     ${dir}/manual_analysis_AL_selection_with_changing_CQI_values.csv
    ${file_csv2}=    set variable     ${path_to_l1l2_csv}


Load scf values for validations
    [Arguments]    ${scenario}
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${scenario}.xml
    nps_tarf_tools.log_to_console_with_time_prefix     scf for scenario ${scenario} is ${scf_file}    level=INFO
    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_file}
    ...                                                                                regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRCELLGrp}=    Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_file}
    ...                                                                                regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
    ${actDlPowerBoost_NRCELL}    Create List
    ${numTxThreshForPowerBoost_NRCELL}    Create List
    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}    Create List
    ${cellTechnology_NRCELL}    Create List
    ${chBW_NRCELL}    Create List
    ${nbrOfBlankedPRBsDL_NRCELL}    Create List
    ${nbrOfBlankedPRBsUL_NRCELL}    Create List
    ${actBeamforming_NRCELL}     create list
    ${dlMimoMode_NRCELL}    create list
    ${gscn_NRCELL}    create list
    ${actHighSpeedCell_NRCELL}    create list
    ${ulDMRSAdditionalPosition_NRCELL}    create list
    ${dlDMRSAdditionalPosition_NRCELL}    create list
    ${frameStructureType_NRCELL}    create list
    ${ulDlDataSlotRatio_NRCELL}    create list
    ${prachConfigurationIndex_NRCELL}    create list
    ${numberOfTransmittedSsBlocks_NRCELLGrp}      create list
    ${actUlMuMimo_NRCELL}     create list
    ${actDlMuMimo_NRCELL}     create list
    ${actUlSrsBm_NRCELL}      create list
    ${actDlSrsBm_NRCELL}      create list
    ${prachSequenceType_NRCELL}      create list
    ${zeroCorrelationZoneConfig_NRCELL}      create list
    ${prachRootSequenceIndex_NRCELL}      create list
    ${lteNrDssMode_NRCELL}      create list
    FOR    ${distName}    IN   @{distName_NRCELL}
        ${actDlPowerBoost}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actDlPowerBoost
        ${numTxThreshForPowerBoost}=   Run Keyword If    '${actDlPowerBoost}' != 'disabled'
        ...                                                scf.get_value_from_scf    dist_name=${distName}    p_name=numTxThreshForPowerBoost
        ...                                ELSE            Set variable    ${0}
        ${maxPrbsIncludingPowerBoostPrbs}=    Run Keyword If    '${actDlPowerBoost}' != 'disabled'
        ...                                                  scf.get_value_from_scf    dist_name=${distName}   p_name=maxPrbsIncludingPowerBoostPrbs
        ...                                        ELSE      Set variable    ${0}
        ${cellTechnology}=    scf.get_value_from_scf    dist_name=${distName}   p_name=cellTechnology
        ${chBW}=    run Keyword If    '${cellTechnology}' == 'TDD'     scf.get_value_from_scf    dist_name=${distName}   p_name=chBw
        ...             ELSE                                           scf.get_value_from_scf    dist_name=${distName}/NRCELL_FDD-1   p_name=chBwDl
        ${chBW}     Fetch From Left    ${chBW}    MHz
        ${nbrOfBlankedPRBsHighEdgeDL}=    scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsHighEdgeDL
        ${nbrOfBlankedPRBsLowEdgeDL}=     scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsLowEdgeDL
        ${nbrOfBlankedPRBsHighEdgeUL}=    scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsHighEdgeUL
        ${nbrOfBlankedPRBsLowEdgeUL}=     scf.get_value_from_scf    dist_name=${distName}    p_name=nbrOfBlankedPRBsLowEdgeUL
        ${numTxThreshForPowerBoost}=    Convert To Integer     ${numTxThreshForPowerBoost}
        ${maxPrbsIncludingPowerBoostPrbs}=    Convert To Integer     ${maxPrbsIncludingPowerBoostPrbs}
        ${chBW}     Convert to Integer     ${chBW}
        ${nbrOfBlankedPRBsHighEdgeDL}=    Convert to Integer    ${nbrOfBlankedPRBsHighEdgeDL}
        ${nbrOfBlankedPRBsLowEdgeDL}=    Convert to Integer    ${nbrOfBlankedPRBsLowEdgeDL}
        ${nbrOfBlankedPRBsDL}    Evaluate    ${nbrOfBlankedPRBsHighEdgeDL} + ${nbrOfBlankedPRBsLowEdgeDL}
        ${nbrOfBlankedPRBsUL}    Evaluate    ${nbrOfBlankedPRBsHighEdgeUL} + ${nbrOfBlankedPRBsLowEdgeUL}
        ${actBeamforming}=    scf.get_value_from_scf    dist_name=${distName}    p_name=actBeamforming
        ${dlMimoMode}=        scf.get_value_from_scf    dist_name=${distName}    p_name=dlMimoMode
        ${gscnOrSsPbchArfcn}=     scf.get_value_from_scf    dist_name=${distName}    p_name=gscnOrSsPbchArfcn
        ${actHighSpeedCell}=      scf.get_value_from_scf    dist_name=${distName}    p_name=actHighSpeedCell
        ${ulDMRSAdditionalPosition}=    scf.get_value_from_scf    dist_name=${distName}    p_name=ulDMRSAdditionalPosition
        ${dlDMRSAdditionalPosition}=    scf.get_value_from_scf    dist_name=${distName}    p_name=dlDMRSAdditionalPosition
        IF     '${SW_POSTFIX}' == 'TDD'
            ${frameStructureType}=    scf.get_value_from_scf    dist_name=${distName}    p_name=frameStructureType
            ${ulDlDataSlotRatio}=     scf.get_value_from_scf    dist_name=${distName}    p_name=ulDlDataSlotRatio
        END
        ${prachConfigurationIndex}=     scf.get_value_from_scf    dist_name=${distName}    p_name=prachConfigurationIndex
        ${actUlMuMimo}=     scf.get_value_from_scf    dist_name=${distName}    p_name=actUlMuMimo
        ${actUlSrsBm}=      scf.get_value_from_scf    dist_name=${distName}    p_name=actUlSrsBm
        ${actDlMuMimo}=     scf.get_value_from_scf    dist_name=${distName}    p_name=actDlMuMimo
        ${actDlSrsBm}=      scf.get_value_from_scf    dist_name=${distName}    p_name=actDlSrsBm
        ${prachSequenceType}=      scf.get_value_from_scf    dist_name=${distName}    p_name=prachSequenceType
        ${zeroCorrelationZoneConfig}=      scf.get_value_from_scf    dist_name=${distName}    p_name=zeroCorrelationZoneConfig
        ${prachRootSequenceIndex}=         scf.get_value_from_scf    dist_name=${distName}    p_name=prachRootSequenceIndex
        ${lteNrDssMode}=         scf.get_value_from_scf    dist_name=${distName}    p_name=lteNrDssMode
        Append to list    ${actDlPowerBoost_NRCELL}    ${actDlPowerBoost}
        Append to list    ${numTxThreshForPowerBoost_NRCELL}    ${numTxThreshForPowerBoost}
        Append to list    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}    ${maxPrbsIncludingPowerBoostPrbs}
        Append to list    ${cellTechnology_NRCELL}    ${cellTechnology}
        Append to list    ${chBW_NRCELL}    ${chBW}
        Append to list    ${nbrOfBlankedPRBsDL_NRCELL}    ${nbrOfBlankedPRBsDL}
        Append to list    ${nbrOfBlankedPRBsUL_NRCELL}    ${nbrOfBlankedPRBsUL}
        Append to list    ${actBeamforming_NRCELL}    ${actBeamforming}
        Append to list    ${dlMimoMode_NRCELL}    ${dlMimoMode}
        Append to list    ${gscn_NRCELL}    ${gscnOrSsPbchArfcn}
        Append to list    ${actHighSpeedCell_NRCELL}    ${actHighSpeedCell}
        Append to list    ${ulDMRSAdditionalPosition_NRCELL}    ${ulDMRSAdditionalPosition}
        Append to list    ${dlDMRSAdditionalPosition_NRCELL}    ${dlDMRSAdditionalPosition}
        IF     '${SW_POSTFIX}' == 'TDD'
            Append to list    ${frameStructureType_NRCELL}    ${frameStructureType}
            Append to list    ${ulDlDataSlotRatio_NRCELL}     ${ulDlDataSlotRatio}
        END
        Append to list    ${prachConfigurationIndex_NRCELL}     ${prachConfigurationIndex}
        Append to list    ${actUlMuMimo_NRCELL}     ${actUlMuMimo}
        Append to list    ${actDlMuMimo_NRCELL}     ${actDlMuMimo}
        Append to list    ${actUlSrsBm_NRCELL}     ${actUlSrsBm}
        Append to list    ${actDlSrsBm_NRCELL}     ${actDlSrsBm}
        Append to list    ${prachSequenceType_NRCELL}     ${prachSequenceType}
        Append to list    ${zeroCorrelationZoneConfig_NRCELL}     ${zeroCorrelationZoneConfig}
        Append to list    ${prachRootSequenceIndex_NRCELL}  ${prachRootSequenceIndex}
        Append to list    ${lteNrDssMode_NRCELL}     ${lteNrDssMode}
    END
    FOR    ${distName}    IN   @{distName_NRCELLGrp}
        ${numberOfTransmittedSsBlocks}=    scf.get_value_from_scf    dist_name=${distName}    p_name=numberOfTransmittedSsBlocks
        Append to list    ${numberOfTransmittedSsBlocks_NRCELLGrp}     ${numberOfTransmittedSsBlocks}
    END
    Set test variable    ${actDlPowerBoost_NRCELL}
    Set test variable    ${numTxThreshForPowerBoost_NRCELL}
    Set test variable    ${maxPrbsIncludingPowerBoostPrbs_NRCELL}
    Set test variable    ${cellTechnology_NRCELL}
    Set test variable    ${chBW_NRCELL}
    Set test variable    ${nbrOfBlankedPRBsDL_NRCELL}
    Set test variable    ${nbrOfBlankedPRBsUL_NRCELL}
    Set test variable    ${actBeamforming_NRCELL}
    Set test variable    ${dlMimoMode_NRCELL}
    Set test variable    ${gscn_NRCELL}
    Set test variable    ${actHighSpeedCell_NRCELL}
    Set test variable    ${ulDMRSAdditionalPosition_NRCELL}
    Set test variable    ${dlDMRSAdditionalPosition_NRCELL}
    IF     '${SW_POSTFIX}' == 'TDD'
        Set test variable    ${frameStructureType_NRCELL}
        Set test variable    ${ulDlDataSlotRatio_NRCELL}
    END
    set test variable    ${prachConfigurationIndex_NRCELL}
    set test variable    ${numberOfTransmittedSsBlocks_NRCELLGrp}
    set test variable    ${actUlMuMimo_NRCELL}
    set test variable    ${actDlMuMimo_NRCELL}
    set test variable    ${actUlSrsBm_NRCELL}
    set test variable    ${actDlSrsBm_NRCELL}
    set test variable    ${prachSequenceType_NRCELL}
    set test variable    ${zeroCorrelationZoneConfig_NRCELL}
    set test variable    ${prachRootSequenceIndex_NRCELL}
    set test variable    ${lteNrDssMode_NRCELL}
    ${4x4_mimo_enabled}=      TARF-Keywords.Check 4X4 MIMO enabled      ${dlMimoMode_NRCELL[${fdd_cell_1}-1]}
    Set test variable    ${4x4_mimo_enabled}
    # Cell1 with AEHC RU Unit (RF Type = 64T64R)
    # Cell2 and Cell3 are with AEQE RU Unit (RF Type = 64T64R)
    IF     '${SW_POSTFIX}' == 'TDD'
        power_calculation_common_keywords.Get SSB Power Parameters Via Coam Admin    cell_id=1    cell_group_index=0
        power_calculation_common_keywords.Check SSB Power Calculation Parameters     cell_id=1    numOfTRX=${64}
        power_calculation_common_keywords.Get SSB Power Parameters Via Coam Admin    cell_id=2    cell_group_index=1
        power_calculation_common_keywords.Check SSB Power Calculation Parameters     cell_id=2    numOfTRX=${64}
        # power_calculation_common_keywords.Get SSB Power Parameters Via Coam Admin    cell_id=3    cell_group_index=2
        # power_calculation_common_keywords.Check SSB Power Calculation Parameters     cell_id=3    numOfTRX=${64}
    END
    StringTool.printLineWithTitle     title=Load scf values for validations
    ${list_scf_values}=    Create List
    ${msg}=   StringTool.getHeaderLine    cellTechnology_NRCELL        ${cellTechnology_NRCELL}
    ${dict}=    create dictionary     field=cellTechnology_NRCELL     content=${cellTechnology_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    dated log      ${msg}
    ${msg}=   StringTool.getHeaderLine    lteNrDssMode_NRCELL        ${lteNrDssMode_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=lteNrDssMode_NRCELL     content=${lteNrDssMode_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=   StringTool.getHeaderLine    chBW_NRCELL[MHz]      ${chBW_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=chBW_NRCELL[MHz]     content=${chBW_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   nbrOfBlankedPRBsDL_NRCELL   ${nbrOfBlankedPRBsDL_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=nbrOfBlankedPRBsDL_NRCELL    content=${nbrOfBlankedPRBsDL_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   nbrOfBlankedPRBsUL_NRCELL   ${nbrOfBlankedPRBsUL_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=nbrOfBlankedPRBsUL_NRCELL    content=${nbrOfBlankedPRBsUL_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actBeamforming_NRCELL   ${actBeamforming_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actBeamforming_NRCELL    content=${actBeamforming_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   dlMimoMode_NRCELL   ${dlMimoMode_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=dlMimoMode_NRCELL    content=${dlMimoMode_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   gscn_NRCELL   ${gscn_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=gscn_NRCELL    content=${gscn_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actHighSpeedCell_NRCELL   ${actHighSpeedCell_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actHighSpeedCell_NRCELL    content=${actHighSpeedCell_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   ulDMRSAdditionalPosition_NRCELL   ${ulDMRSAdditionalPosition_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=ulDMRSAdditionalPosition_NRCELL    content=${ulDMRSAdditionalPosition_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   dlDMRSAdditionalPosition_NRCELL   ${dlDMRSAdditionalPosition_NRCELL}
    dated log      ${msg}
    IF     '${SW_POSTFIX}' == 'TDD'
        ${msg}=    StringTool.getHeaderLine   frameStructure_NRCELL   ${frameStructure_cell}
        dated log      ${msg}
        ${msg}=    StringTool.getHeaderLine   frameStructureType_NRCELL   ${frameStructureType_NRCELL}
        dated log      ${msg}
        ${msg}=    StringTool.getHeaderLine   ulDlDataSlotRatio_NRCELL   ${ulDlDataSlotRatio_NRCELL}
        dated log      ${msg}
    END
    ${msg}=    StringTool.getHeaderLine   prachConfigurationIndex_NRCELL   ${prachConfigurationIndex_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=prachConfigurationIndex_NRCELL    content=${prachConfigurationIndex_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   prachRootSequenceIndex_NRCELL   ${prachRootSequenceIndex_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=prachRootSequenceIndex_NRCELL    content=${prachRootSequenceIndex_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   prachSequenceType_NRCELL   ${prachSequenceType_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=prachSequenceType_NRCELL    content=${prachSequenceType_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   zeroCorrelationZoneConfig_NRCELL   ${zeroCorrelationZoneConfig_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=zeroCorrelationZoneConfig_NRCELL    content=${zeroCorrelationZoneConfig_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   numberOfTransmittedSsBlocks_NRCELLGrp   ${numberOfTransmittedSsBlocks_NRCELLGrp}
    dated log      ${msg}
    ${dict}=    create dictionary     field=numberOfTransmittedSsBlocks_NRCELLGrp    content=${numberOfTransmittedSsBlocks_NRCELLGrp}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actUlMuMimo_NRCELL   ${actUlMuMimo_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actUlMuMimo_NRCELL    content=${actUlMuMimo_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actUlSrsBm_NRCELL   ${actUlSrsBm_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actUlSrsBm_NRCELL    content=${actUlSrsBm_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actDlMuMimo_NRCELL   ${actUlMuMimo_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actDlMuMimo_NRCELL    content=${actDlMuMimo_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    ${msg}=    StringTool.getHeaderLine   actDlSrsBm_NRCELL   ${actDlSrsBm_NRCELL}
    dated log      ${msg}
    ${dict}=    create dictionary     field=actDlSrsBm_NRCELL    content=${actDlSrsBm_NRCELL}
    Append to list    ${list_scf_values}      ${dict}
    StringTool.printLineWithTitle     title=-
    CB013715_tools.writeConfiguration     ${resultFile}    ${list_scf_values}

Generate Test Verdict From TtiTraces TDD CB013715
    dated log      ${consTraceColor}--------> [DL/UL] UL and DL DTX STATS${defColor}
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_ul    ${path_to_ul_ttitrace_pkl}
    dated log      ==output_dtx_statistics_physCellId_ul==
    Tti-lib.Display Df As Html      ${output_dtx_statistics}
    Tti-lib.display_df_as_table     ${output_dtx_statistics}
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_dl    ${path_to_dl_ttitrace_pkl}
    dated log      ==output_dtx_statistics_physCellId_dl==
    Tti-lib.Display Df As Html     ${output_dtx_statistics}
    Tti-lib.display_df_as_table     ${output_dtx_statistics}
    dated log      ${consTraceColor}--------> cells_and_ues_physCellId${defColor}
    ${output}   Run keyword and continue on failure    Tti-lib.get_cells_and_ues_physCellId   ${path_to_dl_ttitrace_pkl}
    dated log    ==cells_and_ues_physCellId==
    Tti-lib.Display Df As Html     ${output}
    Tti-lib.display_df_as_table     ${output}
    dated log      ${consTraceColor}--------> [DL] get_rank_statistics_rnti_dl${defColor}
    ${combined_rank_stats}  ${rank_stats}   Run keyword and continue on failure    Tti-lib.get_rank_statistics_rnti_dl   ${path_to_dl_ttitrace_pkl}
    dated log    ==get_rank_statistics_rnti_dl==
    Tti-lib.Display Df As Html     ${combined_rank_stats}
    Tti-lib.display_df_as_table     ${combined_rank_stats}
    dated log      ${consTraceColor}--------> [DL] filter_valid_events_and_check_acknack_retx${defColor}
    ${combined_acknack_stats_physCellId}  ${combined_acknack_stats_rnti}  ${combined_retx_stats_physCellId}  ${combined_retx_stats_rnti}
    ...      Run keyword and continue on failure    check_nack.filter_valid_events_and_check_acknack_retx   ${path_to_dl_ttitrace_pkl}
    dated log    ==combined_acknack_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_acknack_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_acknack_stats_physCellId}
    dated log    ==combined_acknack_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_acknack_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_acknack_stats_rnti}
    dated log    ==combined_txnumber_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_retx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_retx_stats_rnti}
    dated log    ==combined_txnumber_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_retx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_retx_stats_physCellId}
    dated log      ${consTraceColor}--------> [UL] filter_valid_events_and_check_ul_crc_dtx_retx${defColor}
    ${combined_ul_crc_stats_physCellId}  ${combined_ul_crc_stats_rnti}  ${combined_ul_retx_stats_physCellId}  ${combined_ul_retx_stats_rnti}
    ...                                   ${combined_ul_dtx_stats_physCellId}  ${combined_ul_dtx_stats_rnti}
    ...     Run keyword and continue on failure    check_ul_dtx_crc.filter_valid_events_and_check_ul_crc_dtx_retx   ${path_to_ul_ttitrace_pkl}
    dated log    ==combined_ul_crc_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_crc_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_crc_stats_physCellId}
    dated log    ==combined_ul_crc_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_crc_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_crc_stats_rnti}
    dated log    ==combined_ul_txnumber_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_retx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_retx_stats_physCellId}
    dated log    ==combined_ul_txnumber_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_retx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_retx_stats_rnti}
    dated log    ==combined_ul_dtx_stats_physCellId==
    Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_physCellId}
    Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_physCellId}
    dated log    ==combined_ul_dtx_stats_rnti==
    Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_rnti}
    Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_rnti}
    dated log      ${consTraceColor}--------> [UL] get_rank_statistics_rnti_ul${defColor}
    ${combined_ul_rank_stats}  ${ul_rank_stats}   Run keyword and continue on failure
    ...                                                 Tti-lib.get_rank_statistics_rnti_ul   ${path_to_ul_ttitrace_pkl}
    dated log    ==get_rank_statistics_rnti_ul==
    Tti-lib.Display Df As Html     ${combined_ul_rank_stats}
    Tti-lib.display_df_as_table     ${combined_ul_rank_stats}

Generate Test Verdict From TtiTraces
    ${result_filename}    nps_tarf_tools.return_basename   ${resultFile}
    ${result_path}        nps_tarf_tools.return_path       ${resultFile}
    dated log      ${consTraceColor}--------> [DL/UL] UL and DL DTX STATS${defColor}
    append to file     ${resultFile}     \n\t--------> [DL/UL] UL and DL DTX STATS\n
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_ul    ${path_to_ul_ttitrace_pkl}
    dated log      ==output_dtx_statistics_physCellId_ul==
    append to file     ${resultFile}     \n\t==output_dtx_statistics_physCellId_ul==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html      ${output_dtx_statistics}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${output_dtx_statistics}    base_location=${result_path}
    ...                                                                                          filename=${result_filename}
    ...                                                                                          both=${True}
    ${output_dtx_statistics}=   Run keyword and continue on failure     Tti-lib.get_dtx_statistics_physCellId_dl    ${path_to_dl_ttitrace_pkl}
    dated log      ==output_dtx_statistics_physCellId_dl==
    append to file     ${resultFile}     \n\t==output_dtx_statistics_physCellId_dl==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html      ${output_dtx_statistics}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${output_dtx_statistics}    base_location=${result_path}
    ...                                                                                          filename=${result_filename}
    ...                                                                                          both=${True}
    dated log      ${consTraceColor}--------> cells_and_ues_physCellId${defColor}
    append to file     ${resultFile}     \n\t--------> cells_and_ues_physCellId\n
    ${output}   Run keyword and continue on failure    Tti-lib.get_cells_and_ues_physCellId   ${path_to_dl_ttitrace_pkl}
    dated log    ==cells_and_ues_physCellId==
    append to file     ${resultFile}     \n\t==cells_and_ues_physCellId==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${output}
    Run keyword and ignore error     Tti-lib.display_df_as_table    ${output}
    ...                                                             base_location=${result_path}
    ...                                                             filename=${result_filename}
    ...                                                             both=${True}
    dated log      ${consTraceColor}--------> [DL] get_rank_statistics_rnti_dl${defColor}
    append to file     ${resultFile}     \n\t--------> [DL] get_rank_statistics_rnti_dl\n
    ${combined_rank_stats}  ${rank_stats}   Run keyword and continue on failure    Tti-lib.get_rank_statistics_rnti_dl   ${path_to_dl_ttitrace_pkl}
    dated log    ==get_rank_statistics_rnti_dl==
    append to file     ${resultFile}     \n\t==get_rank_statistics_rnti_dl==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_rank_stats}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_rank_stats}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    dated log      ${consTraceColor}--------> [DL] filter_valid_events_and_check_acknack_retx${defColor}
    append to file     ${resultFile}     \n\t [DL] filter_valid_events_and_check_acknack_retx\n
    ${combined_acknack_stats_physCellId}  ${combined_acknack_stats_rnti}  ${combined_retx_stats_physCellId}  ${combined_retx_stats_rnti}
    ...      Run keyword and continue on failure    check_nack.filter_valid_events_and_check_acknack_retx   ${path_to_dl_ttitrace_pkl}
    # dated log    ==combined_acknack_stats_physCellId==
    # Tti-lib.Display Df As Html     ${combined_acknack_stats_physCellId}
    # Tti-lib.display_df_as_table     ${combined_acknack_stats_physCellId}
    dated log    ==combined_acknack_stats_rnti==
    append to file     ${resultFile}     \n\t ==combined_acknack_stats_rnti==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_acknack_stats_rnti}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_acknack_stats_rnti}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    dated log    ==combined_txnumber_stats_rnti==
    append to file     ${resultFile}     \n\t ==combined_txnumber_stats_rnti==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_retx_stats_rnti}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_retx_stats_rnti}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    # dated log    ==combined_txnumber_stats_physCellId==
    # Tti-lib.Display Df As Html     ${combined_retx_stats_physCellId}
    # Tti-lib.display_df_as_table     ${combined_retx_stats_physCellId}
    dated log      ${consTraceColor}--------> [UL] filter_valid_events_and_check_ul_crc_dtx_retx${defColor}
    append to file     ${resultFile}     \n\t--------> [UL] filter_valid_events_and_check_ul_crc_dtx_retx\n
    ${combined_ul_crc_stats_physCellId}  ${combined_ul_crc_stats_rnti}  ${combined_ul_retx_stats_physCellId}  ${combined_ul_retx_stats_rnti}
    ...                                   ${combined_ul_dtx_stats_physCellId}  ${combined_ul_dtx_stats_rnti}
    ...     Run keyword and continue on failure    check_ul_dtx_crc.filter_valid_events_and_check_ul_crc_dtx_retx   ${path_to_ul_ttitrace_pkl}
    # dated log    ==combined_ul_crc_stats_physCellId==
    # Tti-lib.Display Df As Html     ${combined_ul_crc_stats_physCellId}
    # Tti-lib.display_df_as_table     ${combined_ul_crc_stats_physCellId}
    dated log    ==combined_ul_crc_stats_rnti==
    append to file     ${resultFile}     \n\t==combined_ul_crc_stats_rnti==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_ul_crc_stats_rnti}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_ul_crc_stats_rnti}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    # dated log    ==combined_ul_txnumber_stats_physCellId==
    # Tti-lib.Display Df As Html     ${combined_ul_retx_stats_physCellId}
    # Tti-lib.display_df_as_table     ${combined_ul_retx_stats_physCellId}
    dated log    ==combined_ul_txnumber_stats_rnti==
    append to file     ${resultFile}     \n\t==combined_ul_txnumber_stats_rnti==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_ul_retx_stats_rnti}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_ul_retx_stats_rnti}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    # dated log    ==combined_ul_dtx_stats_physCellId==
    # Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_physCellId}
    # Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_physCellId}
    dated log    ==combined_ul_dtx_stats_rnti==
    append to file     ${resultFile}     \n\t==combined_ul_dtx_stats_rnti==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_ul_dtx_stats_rnti}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_ul_dtx_stats_rnti}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}
    dated log      ${consTraceColor}--------> [UL] get_rank_statistics_rnti_ul${defColor}
    append to file     ${resultFile}     \n\t--------> [UL] get_rank_statistics_rnti_ul\n
    ${combined_ul_rank_stats}  ${ul_rank_stats}   Run keyword and continue on failure
    ...                                                 Tti-lib.get_rank_statistics_rnti_ul   ${path_to_ul_ttitrace_pkl}
    dated log    ==get_rank_statistics_rnti_ul==
    append to file     ${resultFile}     \n\t==get_rank_statistics_rnti_ul==\n
    Run keyword and ignore error     Tti-lib.Display Df As Html     ${combined_ul_rank_stats}
    Run keyword and ignore error     Tti-lib.display_df_as_table     ${combined_ul_rank_stats}
    ...                                                              base_location=${result_path}
    ...                                                              filename=${result_filename}
    ...                                                              both=${True}


Get Statistical Analysis of DL TTI Trace Events
    return from keyword if     '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=dlFdSchedData.ackNack
    ...                                              path_to_pickle=${path_to_ttitrace_dl_pkl}
    ...                                              validate=&{dl_dtx_validation}

Get Statistical Analysis of UL TTI Trace Events
    return from keyword if     '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulHarqRxData.dtx
    ...                                              path_to_pickle=${path_to_ttitrace_ulfdsched_pkl}
    ...                                              validate=&{ul_dtx_validation}
    Run Keyword And Continue On Failure              ttitrace_analysis.Verify Distribution Table of
    ...                                              column_name=ulHarqRxData.crcResult
    ...                                              path_to_pickle=${path_to_ttitrace_ulfdsched_pkl}

Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a PDML file as input, and returns it into a PDML file
    ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}

DisplayAndCheckTAValue From pcap
    [Arguments]    ${file_path}    ${value}=0
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...    field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    dated log    =======================================
    robot_extension.Run Keyword And Warn On Failure    dated log      UE1 NR-TADV: ${attrib_values}[0]
    robot_extension.Run Keyword And Warn On Failure    dated log      UE2 NR-TADV: ${attrib_values}[1]
    robot_extension.Run Keyword And Warn On Failure    dated log      UE3 NR-TADV: ${attrib_values}[2]
    robot_extension.Run Keyword And Warn On Failure    dated log      UE4 NR-TADV: ${attrib_values}[3]
    robot_extension.Run Keyword And Warn On Failure    dated log      All values NR-TADV: ${attrib_values}
    dated log    =======================================
    should be equal    ${attrib_values}[0]    NR-TADV: ${value}

DisplayAndCheckTAValue
    [Arguments]    ${pdmlFile}    ${value}=0
    return from keyword if     '${logs_and_traces_flags['BackhaulTrace']['conversion']['pdml']}'=='False'
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...    field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    # ${is_variable_exist}    run keyword and return status    variable should exist     ${attrib_values}[0]
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${attrib_values}
    # ${attached_ue_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario  scenario_name=${scenario_name}
    ${ue_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa
    ${ue_list}=  get dictionary keys  ${ue_dict}
    IF      not ${isEmpty}
        BuiltIn.log to console    =======================================
        FOR    ${ue}    IN    @{ue_list}
            robot_extension.Run Keyword And Warn On Failure  nps_tarf_tools.log_to_console_with_time_prefix
            ...                                                     UE${ue} ${attrib_values[${ue}-${1}]}  level=INFO
        END
        BuiltIn.log to console    =======================================
        robot_extension.Run Keyword And Warn On Failure    should be equal    ${attrib_values}[0]    NR-TADV: ${value}
    ELSE
        nps_tarf_tools.log_to_console_with_time_prefix     [ DisplayAndCheckTAValue ] => no Output!!    level=ERROR
    END


Get Last initialTa Value from GNB Syslog
    [Arguments]    ${log_dir}=/tmp/btslog2
    ${cmd}    Set Variable
    ...    grep -o 'initialTa\=[0-9]*' ${log_dir}/*.LOG | tail -50 | cut -d "=" -f2
    ${rc}    ${output}    Run And Return Rc And Output    ${cmd}
    ${rc}    ${output_count}    Run And Return Rc And Output    ${cmd}| wc -l
    [Return]  ${output}    ${output_count}

Verify That Nr Rrc Dmrs-Uplinkforpusch_Mappingtype${mapping_type} Not Contains dmrs-Additionalposition
    run keyword and continue on failure    CB013715_tools.verify_dmrs_additional_position_absence      pdml_file=${path_to_syscom_pdml}
    ...                                                                                                mapping_type=${mapping_type}
    CB013715_tools.verify_that_nr_rrc_dmrs_uplinkforpusch_does_not_contain_dmrs_additionalposition     pdml_file=${path_to_syscom_pdml}
    ...                                                                                                mapping_type=${mapping_type}

Verify That Nr Rrc Dmrs-Downlinkforpdsch_MappingtypeA Not Contains dmrs-Additionalposition
    CB013715_tools.verify_that_nr_rrc_dmrs_downlinkforpdsch_does_not_contain_dmrs_additionalposition    ${path_to_syscom_pdml}

Verify That Nr Rrc Dmrs-${direction}_Mappingtype${mapping_type} Contains dmrs-Additionalposition equal to ${value}
    CB013715_tools.verify_the_value_of_dmrs_additionalposition          pdml_file=${path_to_syscom_pdml}
    ...                                                                 mapping_type=${mapping_type}
    ...                                                                 value=${value}
    ...                                                                 direction=${direction}


Get subCellId mapping
    ${PhysicalCellId1}=     Evaluate    ${50}+${fdd_cell_1}-${1}
    ${PhysicalCellId2}=     Evaluate    ${50}+${fdd_cell_2}-${1}
    ${ret}   ${dll1spcells}  BuiltIn.Run Keyword And Warn On Failure     TARF-Keywords.Get dlsubcellid for cellId by cell with COAM
    ...                                                                  oam_alias=coam_gnb
    ...                                                                  PhysicalCellId1=${PhysicalCellId1}   PhysicalCellId2=${PhysicalCellId2}
    ${ret}   ${ull1spcells}  BuiltIn.Run Keyword And Warn On Failure     TARF-Keywords.Get ulsubcellid for cellId by cell with COAM
    ...                                                                  oam_alias=coam_gnb
    ...                                                                  PhysicalCellId1=${PhysicalCellId1}   PhysicalCellId2=${PhysicalCellId2}
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] dlsubcellCell1List=${dll1spcells[0]} ulsubcellCell1List=${ull1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_2} subcell mapping ] dlsubcellCell2List=${dll1spcells[1]} ulsubcellCell2List=${ull1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}

Check In L3L2 SRS User Setup Version1
    [Documentation]   Check in L3L2 setup that SRS is correclty configured outside the blanked area.
    [Arguments]    ${pdml_file}    ${value_pos}    ${value_shift}     ${value_csrs}    ${value_bsrs}    ${value_bhop}
    Dated Log    [Checking SRS configuration in l2ps_user_UserSetup_req]
    #From SPEC: freqDomainShift =  offsetPrbUl %4  = 2, offsetPrbUl = msg1FrequencyStart
    Dated Log    -----> Check of SRS freqDomainPosition
    ${frequ_pos_hex}      get_unique             pdmlFile=${pdml_file}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=.*/itf_l2_ps_user_UserSetupReq.srsResource_item_.*.freqDomainPosition$
    ...                             kind=show
    ...                             startPacket=${1}
    ...                             endPacket=${1}
    ${frequ_pos_int}     Convert To Integer     ${frequ_pos_hex}
    Dated Log    -----> freqDomainPosition = ${frequ_pos_int}
    Should Be True     ${frequ_pos_int}==${value_pos}

    Dated Log    -----> Check of SRS freqDomainShift
    ${frequ_shift_hex}     get_unique             pdmlFile=${pdml_file}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=.*/itf_l2_ps_user_UserSetupReq.srsResource_item_.*.freqDomainShift$
    ...                             kind=show
    ...                             startPacket=${1}
    ...                             endPacket=${1}
    ${frequ_shift_int}     Convert To Integer     ${frequ_shift_hex}
    Dated Log    -----> freqDomainShift = ${frequ_shift_int}
    Should Be True     ${frequ_shift_int}>=${value_shift}

    Dated Log    -----> Check of SRS freqHopping c_SRS
    ${csrs_hex}     get_unique             pdmlFile=${pdml_file}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=.*/itf_l2_ps_user_UserSetupReq.freqHopping.c_SRS
    ...                             kind=show
    ...                             startPacket=${1}
    ...                             endPacket=${1}
    ${csrs_int}     Convert To Integer     ${csrs_hex}
    Dated Log    -----> freqHopping c_SRS = ${csrs_int}
    Should Be True     ${csrs_int}==${value_csrs}

    Dated Log    -----> Check of SRS freqHopping b_SRS
    ${bsrs_hex}     get_unique             pdmlFile=${pdml_file}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=.*/itf_l2_ps_user_UserSetupReq.freqHopping.b_SRS
    ...                             kind=show
    ...                             startPacket=${1}
    ...                             endPacket=${1}
    ${bsrs_int}     Convert To Integer     ${bsrs_hex}
    Dated Log    -----> freqHopping b_SRS = ${bsrs_int}
    Should Be True     ${bsrs_int}==${value_bsrs}

    Dated Log    -----> Check of SRS freqHopping b_hop
    ${bhop_hex}     get_unique             pdmlFile=${pdml_file}
    ...                             packetName=itf_l2_ps_user_usersetupreq
    ...                             path=.*/itf_l2_ps_user_UserSetupReq.freqHopping.b_hop$
    ...                             kind=show
    ...                             startPacket=${1}
    ...                             endPacket=${1}
    ${bhop_int}     Convert To Integer     ${bhop_hex}
    Dated Log    -----> freqHopping b_hop = ${bhop_int}
    Should Be True     ${bhop_int}==${value_bhop}
    Dated Log    -----> Check SRS configuration completed.\n

Check In L3L2 SRS User Setup
    [Documentation]   Check in L3L2 setup that SRS is correclty configured outside the blanked area.
    [Arguments]    ${verify_with_scenario}    ${frequ_pos}   ${frequ_shift}    ${pdml_file}
    Dated Log    [Checking SRS configuration in l2ps_user_UserSetup_req]
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
    ${nbrOfBlankedPRBsHighEdgeUL}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/    p_name=nbrOfBlankedPRBsHighEdgeUL
    ${nbrOfBlankedPRBsLowEdgeUL}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/    p_name=nbrOfBlankedPRBsLowEdgeUL
    ${msg1FrequencyStart}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/    p_name=msg1FrequencyStart

    #From SPEC: freqDomainShift =  offsetPrbUl %4  = 2, offsetPrbUl = msg1FrequencyStart
    ${value_pos}   ${value_shift}  FreqHoppingSRSCalculator.FreqHoppingSRS    nbr_of_blanked_prbs_low_edge_ul_scf=${nbrOfBlankedPRBsLowEdgeUL}
    ...                                                                       msg1frequencyStart=${msg1FrequencyStart}
    nps_tarf_tools.log_to_console_with_time_prefix    SRS :[freqDomainPosition:${frequ_pos} ; freqDomainShift: ${frequ_shift}]    level=INFO
    Dated Log    -----> Check of SRS freqDomainPosition
    ${frequ_pos_int}     Convert To Integer     ${frequ_pos}
    Dated Log    -----> freqDomainPosition = ${frequ_pos_int}
    Should Be True     ${frequ_pos_int}==${value_pos}

    Dated Log    -----> Check of SRS freqDomainShift
    ${frequ_shift_int}     Convert To Integer     ${frequ_shift}
    Dated Log    -----> freqDomainShift = ${frequ_shift_int}
    Should Be True     ${frequ_shift_int}>=${value_shift}
    Append To File   ${resultFile}    \n\t\tSRS :[freqDomainPosition:${frequ_pos_int} ; freqDomainShift: ${frequ_shift_int}]\n
    Append To File   ${resultFile}    \t\t===> SRS configuration in l2ps_user_UserSetup_req Validation succeeded.\n
    nps_tarf_tools.log_to_console_with_time_prefix   SRS configuration in l2ps_user_UserSetup_req Validation succeeded.    level=INFO


Check In L3L2 TRS Cell Setup Configuration
    [Documentation]   Check in L2L3, in l2_ps_cell_CellSetupReq that TRS reference signal is correclty configured outside the blanked area.
    [Arguments]    ${verify_with_scenario}    ${csirsTrackingStartingPrb}    ${csirsTrackingNumOfPrbs}    ${pdml_file}
    Dated Log    [Checking TRS allocation in l2_ps_cell_CellSetupReq]
    Dated Log    -----> trsmuting = ${trsMutingInBlankedPRBsEnabled}. (if true TRS shall not occupied the whole BW)
    ${trs_start_int}      Convert To Integer      ${csirsTrackingStartingPrb}
    ${trs_numprb_int}     Convert To Integer      ${csirsTrackingNumOfPrbs}

    # need to subtract 1 from trs_crb_end to have the high frequence index (which starts from 0)
    ${trs_crb_end}     Evaluate    ${trs_start_int}+${trs_numprb_int}-1

    ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
    ${nbrOfBlankedPRBsHighEdgeDL}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/    p_name=nbrOfBlankedPRBsHighEdgeDL
    ${nbrOfBlankedPRBsLowEdgeDL}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/    p_name=nbrOfBlankedPRBsLowEdgeDL

    Dated Log    -----> TRS allocation:[startingPrb:${trs_start_int} ; NumOfPrbs: ${trs_numprb_int}]
    Run keyword If    '${trsMutingInBlankedPRBsEnabled}'=='false'    Should Be True     ${trs_start_int} == ${0}
    Run keyword If    '${trsMutingInBlankedPRBsEnabled}'=='false'    Should Be True     ${trs_crb_end} <= ${csi_rs_size}
    Run keyword If    '${trsMutingInBlankedPRBsEnabled}'=='true'     Should Be True     ${trs_start_int} >= ${nbrOfBlankedPRBsLowEdgeDL}
    Run keyword If    '${trsMutingInBlankedPRBsEnabled}'=='true' and ${nbrOfBlankedPRBsHighEdgeDL} == 0
    ...                Should Be True     ${trs_crb_end} <= ${csi_rs_size}
    Run keyword If    '${trsMutingInBlankedPRBsEnabled}'=='true' and ${nbrOfBlankedPRBsHighEdgeDL} > 0
    ...                Should Be True     ${trs_crb_end} < ${blanking_area_crb_high}
    nps_tarf_tools.log_to_console_with_time_prefix     TRS allocation in l2_ps_cell_CellSetupReq Validation succeeded.         level=INFO
    Append To File   ${resultFile}    \n\t\tTRS allocation:[startingPrb:${trs_start_int} ; NumOfPrbs: ${trs_numprb_int}]\n
    Append To File   ${resultFile}    \t\t===> TRS allocation in l2_ps_cell_CellSetupReq Validation succeeded.\n
