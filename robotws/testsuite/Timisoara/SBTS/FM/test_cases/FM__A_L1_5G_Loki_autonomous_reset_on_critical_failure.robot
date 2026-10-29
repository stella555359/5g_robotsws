*** Settings ***
Documentation  This suite contains FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure_testcase TC

Resource  ../test_resources/FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.robot


*** Test Cases ***
TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure_testcase
    [Setup]  TC Setup
    TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Teardown]  TC Teardown
