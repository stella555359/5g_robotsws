*** Settings ***
Suite Setup       CNI103148.Suite setup      check_trace=${False}
Suite Teardown    CNI103148.Suite teardown

Documentation
...         author: n5liu
...         contact: ning.4.liu@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CNI-103148 test

Force Tags            RAN_5G     SBTS00      CRT_UTE


Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-103148/Resources/CNI-103148_KW.robot

*** Variables ***
${WarningConfiguration}    ignore:SomeDeprecatedKeyword:DeprecationWarning
#${Test_PC_IP}             ${tl.test_pc[0].default_ssh_connection_details.addr}
#${Test_PC_username}       ${tl.test_pc[0].default_ssh_connection_details.username}
#${Test_PC_password}       ${tl.test_pc[0].default_ssh_connection_details.password}

*** Test Cases ***
[1]CNI-103148_reset_RAT_snapshot_RF_LOG
    [Setup]      Run Keyword And Ignore Error    CNI103148.Case_setup
    CNI103148.Check_SYSLOG_RFLOG_in_SISO_scenario_loop     case_name=None  retry_times=2   KPI10_MAX=${600}
    ...    rat_type=NR
    ...    reset_typ=Hard     Snapshot_loop=True
    ...    max_size=15728640    gap_size=3355444
    ...    analyze_path=/home/ute/syscom_trace     keyword=AaTraceRecord
    ...    excluded_keywords=_pm_    suffix=.atr
    ...    filesSystem=/dev/vda2
    ...    check_trace=False
    ...    Check_RF_Log=True
    ...    Max_used_space_ratio=0.9
    ...    fail_loop_max=100
    ...    test_scenario=reset_NR_RAT
    [Teardown]      Run Keyword And Ignore Error    CNI103148.Case_teardown