*** Settings ***
Suite Setup          LTE TL CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           LTE TL CBRS Test Setup
Test Teardown        LTE TL CBRS Test Teardown

Resource    resources/CB008184_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008184

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1]Manual_SiSo_CALL_LTE_data_call_3CC_10MHz+10MHz+20MHz
    [Tags]    CRT_TRUNK
    Manual_SiSo_CALL_LTE_data_call_3CC_10MHz+10MHz+20MHz

[1][1.0] Manual_SiSo_SM_LTE Cell_block_unblock
    [Tags]    CRT_TRUNK
    CB008184_Manual_SiSo_SM_LTE Cell_block_unblock

*** Keywords ***
