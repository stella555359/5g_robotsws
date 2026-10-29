*** Settings ***
Documentation     Keywords for cpu statistics

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.statistics    WITH NAME    cpu_count

*** Keywords ***
Start CPU statistics
    [Arguments]         ${interval}=10
    [Documentation]  Start getting CPU statistics in background
    ...     :param interval:  time in seconds between getting statistics
    cpu_count.start_cpu_monitoring    interval=${interval}

Stop CPU statistics
    [Documentation]  Stop getting CPU statistics and save them to xlsx file
    cpu_count.stop_cpu_monitoring
