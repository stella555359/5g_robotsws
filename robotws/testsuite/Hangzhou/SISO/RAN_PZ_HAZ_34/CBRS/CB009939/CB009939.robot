*** Settings ***
Suite Setup          CB009939 CBRS Suite Setup
Suite Teardown       CB009939 CBRS Suite Teardown
Test Setup           CB009939 CBRS Test Setup
Test Teardown        CB009939 CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB009939_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009939

Force Tags    SBTS00
...   PY36

*** Test Cases ***
[1]CB009939-SR-CC_7_Do_controlled_switchover_concurrent
    [Tags]    CRT_TRUNK
    CB009939-SR-CC_7_Do_controlled_switchover_concurrent

[1]CB009939-SR-C_7_online_change_Redundancy_Cell_Pair_list
    [Tags]    CRT_TRUNK
    CB009939-SR-C_7_online_change_Redundancy_Cell_Pair_list

[1]CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz
    [Tags]    CRT_TRUNK
    CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz

[1]CB005763-BA_Dying_Gasp_alarm_check_cpri_RFS_on_primary_BTS_AZNA
    [Tags]    CRT_TRUNK
    CB005763-BA_Dying_Gasp_alarm_check_cpri_RFS_on_primary_BTS_AZNA
