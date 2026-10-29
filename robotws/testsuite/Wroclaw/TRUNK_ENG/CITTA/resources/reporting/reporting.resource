*** Settings ***
Documentation    Keywords for reporting various data (notably KPI reports) to 3rd party tools.

Library    Collections

Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal
Library    taf.sw.syslog    WITH NAME    taf_syslog

Library    ./memory.py


*** Keywords ***
Report miscellaneous KPIs
    [Documentation]    Adds various KPI reports to the test.
    ...    Fails if used outside of test case teardown stage.
    VARIABLE SHOULD EXIST    ${TEST STATUS}    This keyword can be used in Test Teardown only!
    Run Keyword And Ignore Error    Record Memory Consumption    # so we don't have to add it in tests explicitly
    Report Memory Consumption
    Report Syslog Prints Counters

Record Memory Consumption
    [Documentation]    Appends current memory consumption measurements to the list of measurements done for current test.
    ...    Returns all measurements recorded so far.
    ${MEMORY CONSUMPTION MEASUREMENTS}=    GET VARIABLE VALUE   ${MEMORY CONSUMPTION MEASUREMENTS}    @{EMPTY}
    ${measurements}=    Wait Until Keyword Succeeds    3x    1 minute    memory.get_measurements
    APPEND TO LIST    ${MEMORY CONSUMPTION MEASUREMENTS}    @{measurements}
    SET TEST VARIABLE    ${MEMORY CONSUMPTION MEASUREMENTS}
    [Return]    ${MEMORY CONSUMPTION MEASUREMENTS}

Report Memory Consumption
    [Documentation]    Adds KPI report to the test with system and cgroup level memory consumption metrics.
    ...    For this keyword to take any effect, data has to be collected first.
    ...    This can be done by using ``Record Memory Consumption`` at any point of test.
    ${measurements}=    GET VARIABLE VALUE    ${MEMORY CONSUMPTION MEASUREMENTS}    @{EMPTY}
    FOR    ${sample}    IN    @{measurements}
        taf_reporting_portal.report_kpi_results
        ...    target=0
        ...    name=${sample}[name]
        ...    visible_to_db=Yes
        ...    value=${sample}[value]
        ...    kpi_type=int
        ...    description=${sample}[description]
        ...    category=Memory Consumption
        ...    unit=kB
    END

Report Syslog Prints Counters
    [Documentation]    Adds KPI reports to the test with number of generated syslog prints during that test.
    ${SYSLOG_ERR_COUNTER}=    GET VARIABLE VALUE    ${SYSLOG_ERR_COUNTER}    ${0}
    ${SYSLOG_WRN_COUNTER}=    GET VARIABLE VALUE    ${SYSLOG_WRN_COUNTER}    ${0}

    # calculate prints increments
    ${total_err}=    count syslog prints    ERR
    ${total_wrn}=    count syslog prints    WRN
    ${err_count}=    EVALUATE    $total_err - $SYSLOG_ERR_COUNTER
    ${wrn_count}=    EVALUATE    $total_wrn - $SYSLOG_WRN_COUNTER

    # create KPI reports for calculated values
    ${err_count}=    CONVERT TO STRING    ${err_count}
    ${wrn_count}=    CONVERT TO STRING    ${wrn_count}
    taf_reporting_portal.report_kpi_results
    ...    target=0
    ...    name=ERR
    ...    visible_to_db=Yes
    ...    value=${err_count}
    ...    kpi_type=int
    ...    description=ERR/WRN syslog prints
    ...    category=ERR/WRN
    ...    unit=\#
    taf_reporting_portal.report_kpi_results
    ...    target=0
    ...    name=WRN
    ...    visible_to_db=Yes
    ...    value=${wrn_count}
    ...    kpi_type=int
    ...    description=ERR/WRN syslog prints
    ...    category=ERR/WRN
    ...    unit=\#

    # update counters so we don't report same prints twice
    SET SUITE VARIABLE    ${SYSLOG_ERR_COUNTER}    ${total_err}
    SET SUITE VARIABLE    ${SYSLOG_WRN_COUNTER}    ${total_wrn}

Count Syslog Prints
    [Arguments]    ${severity}    ${syslog_alias}=default
    [Documentation]    Counts **all** syslog messages of given ``severity``.
    ...    Valid ``severity`` values are: ``ERR``, ``WRN``, ``INF``, ``DBG``, and ``VIP``.
    ${timestamp_regex}=    SET VARIABLE    <[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{6}Z>
    ${counter}=    taf_syslog.count_syslog_messages    ${timestamp_regex} [^ ]+ ${severity}/    alias=${syslog_alias}
    [Return]    ${counter}
