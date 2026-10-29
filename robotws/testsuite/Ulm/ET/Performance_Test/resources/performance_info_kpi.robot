*** Settings ***
Documentation    TODO: use the CLI method of gathering the KPI, this will be obsolete soon
...              OR use performance_pmcounters.robot to get all the pmcounters dictionary to reduce execution time
...
Library     python/perf_timer.py

Library     python/ltepat_assert.py
Library     python/ltepat_to_html.py
Library     python/ltepat_manager.py
Library     python/ltepat_sqlite_inf.py
Library     db/db_interface_insert.py

Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/gnb.robot

Resource    performance_database.robot
Resource    performance_log_collection.robot
Resource    performance_pmcounters.robot
Resource    performance_keywords.robot


*** Keywords ***
Save KPI Counters
    [Arguments]    ${pi_dir}    ${insert_db}=true    ${filename}=kpi    ${tolerance}=${TP.CFG_KPI_TOLERANCE}
    ...            ${subfolder}=${empty}    ${index}=-1    ${inactive_cells}=${None}
    ${kpi_st}    perf_timer.Start
    ${dirname}    performance_keywords.Get Directory Name from string    ${pi_dir}
    Log to console    Generate KPI from [../${subfolder}/${dirname}]
    ${database_connection}    ltepat_sqlite_inf.Connect DB    ${TP.DB_SQLITE3_DATABASE}
    ${ltepat_log_dir}    Set Variable    ${P_resultTestDir}/${subfolder}/ltepat
    ${active_release}    gnb.Get Release Name
    ${release}    Set Variable If    "26" in "${active_release}"    SBTS25R3    ${active_release}

    @{pi_dirs}    Create List    ${pi_dir}
    TRY
        ${ltepat_output_excel}     ltepat_manager.run_ltepat    ${pi_dirs}
        ...                                     conversion_options=${None}
        ...                                     runtime_options=${None}
        ...                                     log_dir=${ltepat_log_dir}
        ...                                     release=${release}
        ${ltepat_sucess}    Set Variable    ${true}
    EXCEPT    .*System.InvalidOperationException.*    type=regexp
        Run Keyword And Continue On Failure    FAIL    LTE PAT: (Mono) System.InvalidOperationException
        ${ltepat_sucess}    Set Variable    ${false}
    EXCEPT
        Run Keyword And Continue On Failure    FAIL    LTE PAT: General Failure
        ${ltepat_sucess}    Set Variable    ${false}
    END
    IF    ${ltepat_sucess} and ${ltepat_output_excel} is not ${None}
        perf_log_collection.Queue Logs To Turandot    ${ltepat_log_dir}    subfolder=${subfolder}    archive_name=ltepat    tar=${True}

        TRY
            ${all_kpi}    ltepat_manager.Get Kpis All To Dict    ${ltepat_output_excel[0]}    index=${index}    inactive_cells=${inactive_cells}
            ...                                                  ignore_zero=${True}
            IF    "${insert_db}"=="true"
                performance_database.Insert kpi results    ${all_kpi}
            END
            ${json_fmt}    Evaluate    json.dumps($all_kpi, indent=4)    modules=json
            Create File              ${P_resultTestDir}/${filename}.json      ${json_fmt}
            perf_log_collection.Queue Logs To Turandot    ${P_resultTestDir}/${filename}.json    compress=false    subfolder=${subfolder}
            ...                                          archive_name=kpi

            IF    ${database_connection}
                ${kpi_comparison_dictionary}    Kpi Comparison Dictionary    ${all_kpi}    ${P_resultTestDir}/${filename}.html    ${subfolder}
            ELSE
                Log    Unable to connect to: ${TP.DB_SQLITE3_DATABASE}    level=WARN
            END
        EXCEPT    KpiSheetNotFound    type=regexp
            Log    LTEPAT: KpiSheetNotFound    level=WARN
        END
    ELSE
        Log    LTEPat failure    level=WARN
    END

    IF    """${kpi_comparison_dictionary}"""!="${None}"
        ${table}    ltepat_sqlite_inf.format_cmp_dict_as_table    ${kpi_comparison_dictionary}
        Log to console    \n${table}\n
    END

    Kpi Assert    ${tolerance}    ${kpi_comparison_dictionary}
    perf_timer.Stop    msg=KPI Calculation:    start_time=${kpi_st}


Kpi Comparison Dictionary
    [Arguments]    ${all_kpi}    ${html_path}    ${subfolder}
    IF     """${all_kpi}"""=="${None}"
        RETURN    ${None}
    END
    IF    "${PREV_DB_TESTCASE_ID}"=="${None}"
        Log    Previous testcase id not available, unable to create comparission table    level=WARN
        RETURN    ${None}
    END
    ${kpi_comparison_dictionary}    ltepat_sqlite_inf.Get Kpi Comparison Dictionary From Db    ${all_kpi}    ${PREV_DB_TESTCASE_ID}
    Run Keyword And Warn On Failure        ltepat_to_html.Write To Html    ${DB_TESTCASE_ID}
    ...                                                                    ${PREV_DB_TESTCASE_ID}
    ...                                                                    ${kpi_comparison_dictionary}
    ...                                                                    ${html_path}
    ...                                                                    ignore_zero=${True}
    perf_log_collection.Queue Logs To Turandot    ${html_path}    compress=false    subfolder=${subfolder}
    ...                                          archive_name=kpi
    RETURN  ${kpi_comparison_dictionary}


Kpi Assert
    [Arguments]    ${tolerance}    ${kpi_comparison_dictionary}
    IF    "${tolerance}" == "null"
        RETURN    ${None}
    END
    IF    """${kpi_comparison_dictionary}"""=="${None}"
        Run Keyword And Continue On Failure     Fail    KPI Failed: dictionary empty
        RETURN    ${None}
    END
    ${assert_res}    ltepat_assert.assert_kpi_dictionary    ${kpi_comparison_dictionary}
    ...                                                     average_only=${True}
    ...                                                     tolerance=${tolerance}
    IF    not ${assert_res}
        Run Keyword And Continue On Failure     Fail    KPI Assert Failed
    END
