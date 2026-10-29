*** Settings ***
Suite Setup          CB009939 CBRS Suite Setup
Suite Teardown       CB009939 CBRS Suite Teardown
Test Setup           CB009939 CBRS Test Setup
Test Teardown        CB009939 CBRS Test Teardown

Resource    resources/CB009939_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009939

Force Tags    SBTS00


*** Test Cases ***
[1]CB009939-SR-CC_7_Do_controlled_switchover_concurrent
    [Tags]    CRT_TRUNK
    CB009939-SR-CC_7_Do_controlled_switchover_concurrent

[1]CB009939-SR-C_7_online_change_Redundancy_Cell_Pair_list
    [Tags]    CRT_TRUNK
    CB009939-SR-C_7_online_change_Redundancy_Cell_Pair_list
