*** Settings ***
Documentation    Test variable and keyword resource file for Performance_Test

Library    String
Library    python/perf_keywords.py
Library    python/wts_wrapper.py
Library    python/wts_verification.py

Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    performance_verification.robot
Resource    performance_info.robot

*** Variables ***
${TOTAL_UES_ATTACHED}    0
${TC_SIB_STATUS}         ${False}
${TC_AP_CELL_STATUS}     ${False}

*** Keywords ***
#---------------------------------------------------------- Verification ------------------------------------------------------------[150 characters]
Verify TP With Counters TDD
    [Documentation]
    ...    Achieved in non-AP PET TL
    ...         Throughput         PMC value
    ...    DL = ~900 Mbps    -->   33750000
    ...    UL = ~180 Mbps    -->   6750000
    [Arguments]    ${dir}    ${SA_DL_TPUT_COUNTER}=33750000    ${SA_UL_TPUT_COUNTER}=6750000
    Verify TP With Counters    ${dir}    ${SA_DL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}

Verify TP With Counters FDD
    [Documentation]
    ...    Expected Values from NR Dimensioning Tool:
    ...         Throughput         PMC value
    ...    DL = 441.8 Mbps   -->   16567500
    ...    UL = 207.6 Mbps   -->   7785000
    ...    Achieved in non-AP PET TL
    ...    DL = ~380 Mbps    -->   14250000
    ...    UL = ~180 Mbps    -->   6750000
    [Arguments]    ${dir}    ${SA_DL_TPUT_COUNTER}=14250000    ${SA_UL_TPUT_COUNTER}=6750000
    Verify TP With Counters    ${dir}    ${SA_DL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}

Verify TP With Counters TDD 8246
    [Documentation]
    ...    Expected ~25% TP degredation
    ...         Throughput         PMC value
    ...    DL = ~675         -->   25312500
    ...    UL = ~135 Mbps    -->   5062500
    [Arguments]    ${dir}    ${SA_DL_TPUT_COUNTER}=25312500    ${SA_UL_TPUT_COUNTER}=5062500
    Verify TP With Counters    ${dir}    ${SA_DL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}

Verify TP With Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${dir}    ${SA_DL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}
    ...            ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    ...            ${distname}=MNC-489
    @{dl_reference_table}    Create List    (${distname})M55326C00501    >=    ${SA_DL_TPUT_COUNTER}     SA_DL_TPUT_COUNTER
    @{ul_reference_table}    Create List    (${distname})M55326C00502    >=    ${SA_UL_TPUT_COUNTER}     SA_UL_TPUT_COUNTER
    @{both_reference_table}=    Combine Lists    ${dl_reference_table}    ${ul_reference_table}
    ${counter_stat}    Run Keyword And Return Status           Verify PM Counter Reference Table    reference_table=${${dir}_reference_table}
    ...                                                        pm_dir=${pmfile}
    ${tput_stat}       Run Keyword And Return Status           Print Additional Tput PMC    pmfile=${pmfile}
    IF    not ${counter_stat} or not ${tput_stat}
    ...    Run Keyword And Continue On Failure
    ...    Fail   msg=Tput Check Failed: \n - PMC:${counter_stat}\n - Tput:${tput_stat}\n ${SPACE} ${SPACE}- ${pmfile}\n

Verify TP With Counters Using Rate
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}    ${distname}=MNC-489    &{args}

    ${SA_DL_TPUT_COUNTER}=    Get Expected PM Value    ${args}    dir=dl
    ${SA_UL_TPUT_COUNTER}=    Get Expected PM Value    ${args}    dir=ul

    Verify TP With Counters    ${args.trf_direction}    ${SA_DL_TPUT_COUNTER}    ${SA_UL_TPUT_COUNTER}    pmfile=${pmfile}    distname=${distname}

Verify All Active UEs and per cell
    [Arguments]    ${ue_per_cell}    ${total_cell}    ${active_cells}=${TS_LIST_ALL}    ${cell_max_ue}=${TS_LIST_NULL}
    IF    not ${TC_SIB_STATUS} or not ${TC_AP_CELL_STATUS}   RETURN
    IF    ${active_cells}==${TS_LIST_ALL}
        ${total_active_cells}    Set Variable    ${total_cell}
    ELSE
        ${total_active_cells}    Evaluate    len(${active_cells})
    END

    ${cell_specific_expected}      Evaluate           ${ue_per_cell}*${total_active_cells}
    ${max_ue}                      Evaluate           ${ue_per_cell} * ${total_cell}
    ${expected_total_ue}           Set Variable If    ${active_cells}==${TS_LIST_ALL}    ${max_ue}    ${cell_specific_expected}

    ${expected_arr}    Set Variable If    ${cell_max_ue}!=${TS_LIST_NULL}    ${cell_max_ue}    ${ue_per_cell}
    ${printout}    wts_wrapper.Get UE Count Per Cell Table    num_cells=${total_cell}
    ...                                                       expected=${expected_arr}    active_cells=${active_cells}
    Log to console    ${printout}

    performance_verification.Verify Total Number of Active UEs       expected=${expected_total_ue}    cell_max_ue=${cell_max_ue}
    ...                                                              num_cells=${total_cell}
    wts_verification.Verify Number of Active UEs in Cells    ${ue_per_cell}    ${total_cell}    cell_max_ue=${cell_max_ue}
    ...                                                      active_cells=${active_cells}

Verify Total Number of Active UEs
    [Documentation]
    ...    KW to grep total number of Active UEs in GNB from egate output
    [Arguments]    ${expected}    ${cell_max_ue}=${TS_LIST_NULL}    ${insert_db}=true    ${num_cells}=24
    ${cells}   wts_wrapper.get_ue_count_per_cell    num_cells=${num_cells}

    IF    ${cell_max_ue}!=${TS_LIST_NULL}
        ${expected}    Evaluate    sum([int(float(x)) for x in ${cell_max_ue}])
    ELSE
        ${expected}    Set Variable    ${expected}
    END

    ${all_ue_attached}    Evaluate    sum(${cells})
    ${percent}    Set Variable If
    ...   int(${expected}) == 0   0
    ...   ${True}                 ${{ round(${all_ue_attached}/${expected},2) * 100 }}

    Run Keyword And Continue On Failure    Should Be True    ${all_ue_attached} >= ${expected}
    ...                                    msg=All Cells : Expected ${expected} Ues Attached, (${all_ue_attached})
    IF    "${insert_db}"=="true"
        performance_database.Insert testcase results    total_ue_attached    ${all_ue_attached} / ${expected} ( ${percent} )
    END
    Set Test Variable    $TOTAL_UES_ATTACHED    ${all_ue_attached}

Verify TTI PM Counter equal or bigger than
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${dir}    ${expected}    ${nr_cell_index}=0
    ...            ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_ORIG_SCF}    regex=NRCELL-[0-9]+
    Sort List    ${distNames_NRCELL}

    ${dl_reference_table}    Create List
    ...   M55308C17002  >=  ${expected}    MAX_SCHED_UE_PDSCH
    ${ul_reference_table}    Create List
    ...   M55308C18002  >=  ${expected}    MAX_SCHED_UE_PUSCH
    ${both_reference_table}=    Combine Lists    ${dl_reference_table}    ${ul_reference_table}

    Verify PM Counter Reference table    reference_table=${${dir}reference_table}
    ...                                  pm_dir=${pmfile}
    ...                                  distname_suffix=${distNames_NRCELL[${nr_cell_index}]}


Verify Beamforming PM Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${dir}    ${nr_cell_index}=0
    ...            ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_ORIG_SCF}    regex=NRCELL-[0-9]+
    Sort List    ${distNames_NRCELL}

    ${ul_reference_table}    Create List
    ...   M55305C01001  >=  0    UL_SERV_BEAM_ID_BEAM_00
    ...   M55305C01002  >=  0    UL_SERV_BEAM_ID_BEAM_01
    ${dl_reference_table}    Create List
    ...   M55305C00001  >=  0    DL_SERV_BEAM_ID_BEAM_00
    ...   M55305C00002  >=  0    DL_SERV_BEAM_ID_BEAM_01
    ${both_reference_table}=    Combine Lists    ${dl_reference_table}    ${ul_reference_table}

    Verify PM Counter Reference table    reference_table=${${dir}reference_table}
    ...                                  pm_dir=${pmfile}
    ...                                  distname_suffix=${distNames_NRCELL[${nr_cell_index}]}

Verify CB013028-A-TC01 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    16    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    1    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    13    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference Table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB013028-A-TC02 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C17002    >=    16    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-2)M55308C17002    >=    6    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-3)M55308C17002    >=    8    MAX_SCHED_UE_PDSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB013028-A-TC03 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C17002    >=    16    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-2)M55308C17002    >=    7    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-3)M55308C17002    >=    7    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-1)M55308C18002    >=    12    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    7    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    7    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB013028-C-TC01 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    16    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    8    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-7)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB013028-C-TC02 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C17002    >=    16    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-2)M55308C17002    >=    8    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-3)M55308C17002    >=    3    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-7)M55308C17002    >=    3    MAX_SCHED_UE_PDSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB013028-C-TC03 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C17002    >=    16    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-2)M55308C17002    >=    7    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-3)M55308C17002    >=    3    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-7)M55308C17002    >=    3    MAX_SCHED_UE_PDSCH
    ...                                  (NRCELL-1)M55308C18002    >=    12    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    8    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-7)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference Table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB014179-A-TC01 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    7    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference Table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB014179-B-TC01 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    7    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB014179-C-TC01 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    15    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Verify CB014179-B-TC02 Counters
    [Documentation]    TODO: use suite dict in performance_pmcounters.robot instead of parsing the pmcounter again
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    @{reference_table}    Create List    (NRCELL-1)M55308C18002    >=    14    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-2)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-3)M55308C18002    >=    14    MAX_SCHED_UE_PUSCH
    ...                                  (NRCELL-7)M55308C18002    >=    3    MAX_SCHED_UE_PUSCH
    Run Keyword And Continue On Failure     Verify PM Counter Reference table    reference_table=${reference_table}
    ...                                     pm_dir=${pmfile}

Is Item In List
    [Arguments]    ${item}    ${list}
    FOR  ${element}  IN  @{list}
        IF  "${element}" == "${item}"     RETURN    ${true}
    END
    RETURN    ${false}

Wait until Active UE reach expected count
    [Arguments]    ${expected_total_ue}    ${timeout}=20min    ${retry_interval}=1min    ${cell_max_ue}=${TS_LIST_NULL}
    Log to Console    Wait for ${expected_total_ue} UE up
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    ${timeout}    ${retry_interval}
    ...    Verify Total Number of Active UEs       expected=${expected_total_ue}    cell_max_ue=${cell_max_ue}    insert_db=false
