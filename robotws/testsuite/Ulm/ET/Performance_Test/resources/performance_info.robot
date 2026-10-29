*** Settings ***
Documentation    Test keyword resource file for Performance_Test

Library    taf.sw.wtssim  # perf_info -> taf_sw_wtssim_wrapper dependency

Library    python/scripts.py
Library    python/perf_info.py
Library    python/pmcounter_manager.py

Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/wts_ue.robot

Resource    performance_info_kpi.robot
Resource    performance_keywords.robot


*** Keywords ***
Check UE TP
    [Arguments]    ${dir}    ${max_ue}=100
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    ${output}=    Send Egate Command and verify output    cmd=ue_stats_nr id=1-${max_ue} scell=0 type=${type}

Print TTI PM Counters
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    IF         "${P_console}"=="${False}"   RETURN
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distNames_NRCELL}

    FOR   ${distName_NRCELL}    IN    @{distNames_NRCELL}
        ${_}    ${dl_tti}    Run Keyword And Warn On Failure    Get PM counter value    ${pmfile}
        ...                                                     M55308C17002   ${distName_NRCELL}  #DL
        ${_}    ${ul_tti}    Run Keyword And Warn On Failure    Get PM counter value    ${pmfile}
        ...                                                     M55308C18002   ${distName_NRCELL}  #UL

        Log to Console    \n${distName_NRCELL}
        Log to console    - M55308C17002 value: [${dl_tti}] MAX_SCHED_UE_PDSCH (dl tti)
        Log to console    - M55308C18002 value: [${ul_tti}] MAX_SCHED_UE_PUSCH (ul tti)
    END


Print PMC ULDL Throughput
    [Arguments]    ${pmcounter_interval}=${TP.PM_COUNTER_INTERVAL}
    ...            ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}    ${rate}=mbps
    ${pmc_tput}    pmcounter_manager.get_pmc_tput_as_table    ${pmfile}    interval=${pmcounter_interval}    rate=${rate}
    Log to console     [ Print PMC ULDL Throughput ] \n${pmc_tput}


Print Cell Stats
    [Arguments]    ${current}=${False}    ${type}=throughput    ${enb}=2    ${insert_db}=true    ${args}=&{EMPTY}
    IF    not ${TC_SIB_STATUS} or not ${TC_AP_CELL_STATUS}   RETURN
    perf_info.Save Cell Stats    current=${current}    testcase_id=${DB_TESTCASE_ID}    itype=${type}    enb=${enb}    insert_db=${insert_db}
    ...                          start_cell=${args['start_cell']}     end_cell=${args['end_cell']}    uec=${args['uec_list']}

Print Additional Tput PMC
    [Arguments]    ${pmfile}=${T_PM_FILES_LOCATION_default_traffic}
    IF         "${P_console}"=="${False}"   RETURN
    ${_}    ${dl_tp}     Run Keyword and Ignore Error    Get PM counter value    ${pmfile}    M55319C11006   NRBTS-1  #DL
    ${_}    ${ul_tp}     Run Keyword and Ignore Error    Get PM counter value    ${pmfile}    M55319C16006   NRBTS-1  #UL

    ${_}    ${dl_tput}   Run Keyword and Ignore Error    Get PM counter value    ${pmfile}    M55326C00501   MNC-489  #DL
    ${_}    ${ul_tput}   Run Keyword and Ignore Error    Get PM counter value    ${pmfile}    M55326C00502   MNC-489  #UL

    Log to console    M55319C11006 value: [${dl_tp}] DL_SDU_TX_SA_QOS_GRP_06
    Log to console    M55319C16006 value: [${ul_tp}] UL_VOL_RX_SA_QOS_GRP_06\n

Get Expected PM Value
    [Arguments]    ${args}    ${dir}
    ${EXPECTED_PM_VALUE}    scripts.get_expected_pmcounter_value_with_max_ue_per_cell_and_per_cell_throughput   ${args}
    ...                                                                        dir=${dir}
    ...                                                                        interval=${TP.PM_COUNTER_INTERVAL}
    ${EXPECTED_PM_VALUE}    Convert To Integer    ${EXPECTED_PM_VALUE}
    RETURN    ${EXPECTED_PM_VALUE}
