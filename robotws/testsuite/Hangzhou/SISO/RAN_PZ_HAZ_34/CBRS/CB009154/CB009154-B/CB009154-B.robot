*** Settings ***
Suite Setup          Run Keywords    CBRS Suite Setup
...                  AND     Case Preparation
Suite Teardown       CBRS Suite Teardown
Test Setup           CB009154 CBRS Test Setup
Test Teardown        CB009154 CBRS Test Teardown

Resource    Resources/CB009154-B_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009154

Force Tags    SBTS00    CRT_23R1
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB009154-B_16_eNB_side_CBRS_activated_deactivatied
    [Tags]    CRT_TRUNK
    CB009154-B_16_eNB_side_CBRS_activated_deactivatied

[1]CB009154-B_17_gNB_side_CBRS_activated_deactivatied
    [Tags]    CRT_TRUNK
    CB009154-B_17_gNB_side_CBRS_activated_deactivatied

[1]CB009154-B_18_gNB_data_transfer_conducted_peak_throughput_NR2x20MHz+LTE1x10MHz
    [Tags]    CRT_TRUNK
    CB009154-B_18_gNB_data_transfer_conducted_peak_throughput_NR2x20MHz+LTE1x10MHz

[1]CB009154-B_12_online_add_NR_cell_under_RFS
    [Tags]    CRT_TRUNK
    CB009154-B_12_online_add_NR_cell_under_RFS

[1]CB009154-B_13_online_delete_NR_cell_under_RFS
    [Tags]    CRT_TRUNK
    CB009154-B_13_online_delete_NR_cell_under_RFS

*** Keywords ***
