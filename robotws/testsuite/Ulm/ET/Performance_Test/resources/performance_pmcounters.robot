*** Settings ***
Documentation    Generalized PM Counter collection for performance testing and comparing with previous runs

Library    python/pmcounter_manager.py
Library    python/pmcounter_sqlite_inf.py
Library    python/pmcounter_to_html.py
Library    python/pmcounter_assert.py
Library    python/perf_timer.py
Library    python/perf_log_collection.py

*** Variables ***
${pmcounter_assert_fail}=  ${EMPTY}

&{ALL_COUNTERS_DICTIONARY}    &{empty}

*** Keywords ***
Save PM Counters
    [Arguments]    ${pi_dir}    ${filename}=base    ${insert_db}=true    ${subfolder}=${empty}    ${inactive_cells}=${None}
    ${pm_st}    perf_timer.Start
    ${_}    ${all_counters}    Run Keyword And Warn On Failure    pmcounter_manager.Get All Counters    ${pi_dir}    inactive_cells=${inactive_cells}
    ...                                                                                                 ignore_zero=${True}
    ${json_fmt}              Evaluate      json.dumps($all_counters, indent=2)    modules=json

    Run Keyword And Warn On Failure    Create File              ${P_resultTestDir}/pmcounters_${filename}.json      ${json_fmt}
    Run Keyword And Warn On Failure    perf_log_collection.Queue Logs To Turandot    ${P_resultTestDir}/pmcounters_${filename}.json
    ...                                                         compress=false     subfolder=${subfolder}

    ${database_connection}    pmcounter_sqlite_inf.Connect DB    ${TP.DB_SQLITE3_DATABASE}
    IF    ${database_connection}
        IF    "${insert_db}"=="true"
            pmcounter_sqlite_inf.insert_to_db    ${DB_TESTCASE_ID}    ${all_counters}    ignore_zero=${True}
        END
        Run Keyword And Warn On Failure    performance_database.Insert PM Counters dictionary    data=${all_counters}
        ${result}    ${pm_cmp}    Run Keyword And Warn On Failure
        ...                           pmcounter_sqlite_inf.Get Pm Counter Comparison Dictionary From DB    ${all_counters}    ${PREV_DB_TESTCASE_ID}
        IF    "${result}"=="PASS"
            Run Keyword And Warn On Failure    pmcounter_to_html.Write To Html    ${pm_cmp}    ${PREV_DB_TESTCASE_ID}
            ...                                                                   ${P_resultTestDir}/pmcounters_${filename}_detailed.html
        END
        Run Keyword And Warn On Failure    perf_log_collection.Queue Logs To Turandot
        ...                                    ${P_resultTestDir}/pmcounters_${filename}_detailed.html
        ...                                    compress=false
        ...                                    subfolder=${subfolder}
    ELSE
        Log    Unable to connect to DB: ${TP.DB_SQLITE3_DATABASE}
    END

    IF    """${pm_cmp}"""!="${None}"
        ${table}    pmcounter_sqlite_inf.Format Cmp Dict As Table    ${pm_cmp}
        Log to console    \n${table}\n
    END

    IF    "${TP.CFG_PMCOUNTERS_TOLERANCE}"!="null"
        IF    ${database_connection}
            Fail    database_connection required to assert PM Counters
        END
        Run Keyword And Continue On Failure     Assert PM Counters     ${pm_cmp}    ${TP.CFG_PMCOUNTERS_TOLERANCE}
    END
    perf_timer.Stop    msg=PM Calculation:    start_time=${pm_st}


Assert PM Counters
    [Arguments]    ${pm_counter_comparison_dictionary}    ${tolerance}
    IF    "${TP.SCF_SET_VAR_NRBTS_actFlowControlLoadBalance}"!="null"
        ${result}    ${return}    Run Keyword And Ignore Error
        ...    pmcounter_assert.Assert All Counters For ActFlowControlLoadBalance Checking
        ...        ${pm_counter_comparison_dictionary}
        ...        tolerance=${tolerance}
        IF    "${result}"=="PASS"
            Run Keyword And Continue On Failure    Should Be True    ${return}    msg=Assert ActFlowControlLoadBalance PM Counters Fail
        ELSE
            Run Keyword And Continue On Failure    Fail    Assert ActFlowControlLoadBalance PM Counters KW Fail
        END
    END
