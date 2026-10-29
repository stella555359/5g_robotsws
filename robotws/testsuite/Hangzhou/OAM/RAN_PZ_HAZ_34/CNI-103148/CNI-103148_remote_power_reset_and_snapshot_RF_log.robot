*** Settings ***
Suite Setup
Suite Teardown

Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CNI-103148 test

Force Tags            RAN_5G     SBTS00      CRT_UTE


Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-103148/Resources/CNI-103148_KW.robot

*** Variables ***
${snapshot_zip_path}      None
*** Test Cases ***
[1]CNI-103148_remote_power_reset_and_snapshot_RF_log
    [Tags]    CIT_22R3
    [Setup]      Run Keyword And Ignore Error
    ...      AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    CNI103148.Check_SYSLOG_RFLOG_in_SISO_scenario_loop    case_name=None  retry_times=150   KPI10_MAX=${600}
    ...     Snapshot_loop=True
    ...    max_size=15728640    gap_size=3355444
    ...    analyze_path=/home/ute/syscom_trace     keyword=AaTraceRecord
    ...    excluded_keywords=_pm_    suffix=.atr
    ...    filesSystem=/dev/vda2
    ...    check_trace=False
    ...    Check_RF_Log=True
    ...    Max_used_space_ratio=0.92
    ...    fail_loop_max=150
    ...    test_scenario=remote_power_reset_site
    ...    parallel=True
    [Teardown]      Run Keyword And Ignore Error      AlarmWatchdog.remove_allow_alarms
    ...      fault_id=${allow_fault_list}
