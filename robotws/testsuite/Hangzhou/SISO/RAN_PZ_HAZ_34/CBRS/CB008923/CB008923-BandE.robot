*** Settings ***
Suite Setup          CB008923-B CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CB008923-B CBRS Test Setup
Test Teardown        CB008923-B CBRS Test Teardown

Resource    resources/CB008923_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008923

Force Tags    SBTS00
...    PY36

*** Test Cases ***
[1]CB008923-E_2_CBSD Cell Activation - TS version 2.0_under_SBTS_RFS
    [Tags]    CRT_TRUNK
    CB008923-E_2_CBSD Cell Activation - TS version 2.0_under_SBTS_RFS

[1]CB008923-B_13_CBSD_behavior_check_when_NR_RAT_reset
    [Tags]    CRT_TRUNK
    CB008923-B_13_CBSD_behavior_check_when_NR_RAT_reset

[1]CB008923-B_29_data_transfer_conducted_peak_throughput_NR_20MHz_LTE_10MHz
    [Tags]    CRT_TRUNK
    CB008923-B_29_data_transfer_conducted_peak_throughput_NR_20MHz_LTE_10MHz

[1]CB008923-B_11_CBSD_behavior_check_when_RU_reset
    [Tags]    CRT_TRUNK
    CB008923-B_11_CBSD_behavior_check_when_RU_reset

[1]CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock
    [Tags]    CRT_TRUNK
    CB008923-B_9_CBSD_behavior_check_when_NR_cell_block_unblock

[1]CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM
    [Tags]    CRT_TRUNK
    CB008923-B_3_Migration of a NR only site to a NR-LTE RF sharing site with AEQM

[1]CB008923-B_33_verify_preemption_between_LTE_and_NR_cells
    [Tags]    CRT_TRUNK
    CB008923-B_33_verify_preemption_between_LTE_and_NR_cells

[1]CB008923-B_25_online_add_one_higher_LTE_cell_under_RFS
    [Tags]    CRT_TRUNK
    CB008923-B_25_online_add_one_higher_LTE_cell_under_RFS

[1]CB008923-B_21_online_modify_supportedSpectrumV2_to_expand_bandwidth
    [Tags]    CRT_TRUNK
    CB008923-B_21_online_modify_supportedSpectrumV2_to_expand_bandwidth
