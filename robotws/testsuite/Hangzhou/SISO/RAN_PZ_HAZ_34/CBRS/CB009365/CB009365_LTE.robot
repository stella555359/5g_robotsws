*** Settings ***
Suite Setup          LTE TL CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           LTE TL CBRS Test Setup
Test Teardown        LTE TL CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB009365_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009365

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB009365-B_2_data transfer conducted peak throughput on LTE only 4T4R radio 20+20+20+20MHz
    [Tags]    CRT_TRUNK
    CB009365-B_2_data transfer conducted peak throughput on LTE only 4T4R radio 20+20+20+20MHz

[1]CB009365-B_CA_3_online_modify_cCaPairCellId_Intra-eNB_FDD-TDD_CA_4CC_channel_change
    [Tags]    CRT_TRUNK
    CB009365-B_CA_3_online_modify_cCaPairCellId_Intra-eNB_FDD-TDD_CA_4CC_channel_change

*** Keywords ***
