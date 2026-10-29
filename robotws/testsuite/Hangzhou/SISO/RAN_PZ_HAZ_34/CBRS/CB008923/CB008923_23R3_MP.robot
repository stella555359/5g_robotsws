*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup    Run keywords    CBRS Test Setup    AND    CBRS Get BTS Info
Test Teardown        CBRS Test Teardown

Resource    resources/CB008923_common_keywords_23R3_MP.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008923

Force Tags    SBTS00    CRT_23R1
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority
    [Tags]    CRT_TRUNK    CRT_22R4
    CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority_23R3_MP

[1]CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM
    [Tags]    CRT_TRUNK
    CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM_23R3_MP

[1]CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock
    [Tags]    CRT_TRUNK
    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8923_concurrent
    CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock_23R3_MP

[1]CB008923-B_33_verify_preemption_between_LTE_and_NR_cells
    [Tags]    CRT_TRUNK
    Commission SCF According btsname    btsName=${bts_info['name']}    config_id=8923_concurrent
    CB008923-B_33_verify_preemption_between_LTE_and_NR_cells_23R3_MP

*** Keywords ***
