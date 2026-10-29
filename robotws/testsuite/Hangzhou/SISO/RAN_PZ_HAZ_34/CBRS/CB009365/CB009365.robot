*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

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
[1]CB009365-A_4_4T4R gNB CBSD receives HB Response 500 with no operationParam
    [Tags]    CRT_TRUNK
    CB009365-A_4_4T4R gNB CBSD receives HB Response 500 with no operationParam

[1]CB009365-A_1_4T4R NR 4CC Frequency Selection Algorithm with more than 110Mhz available channels
    [Tags]    CRT_TRUNK
    CB009365-A_1_4T4R NR 4CC Frequency Selection Algorithm with more than 110Mhz available channels

[1]CB009365-A_7_data transfer conducted peak throughput on NR only 4T4R radio 40+40+40+30MHz
    [Tags]    CRT_TRUNK
    CB009365-A_7_data transfer conducted peak throughput on NR only 4T4R radio 40+40+40+30MHz

[1]CB009365-A_CA_2_online_modify_cCaPairCellId_Intra-gNB_FDD-TDD_CA_4CC
    [Tags]    CRT_TRUNK
    CB009365-A_CA_2_online_modify_cCaPairCellId_Intra-gNB_FDD-TDD_CA_4CC

[1]CB009509-B_11_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_80+40+20+10MHz
    [Tags]    CRT_TRUNK
    CB009509-B_11_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_80+40+20+10MHz

[1]CB009509-BA_6_Verify_Chbw_dynamic_update_40MHz_60MHz_80MHz
    [Tags]    CRT_TRUNK
    CB009509-BA_6_Verify_Chbw_dynamic_update_40MHz_60MHz_80MHz

[1]CB009509-BA_1_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_50+50+50MHz
    [Tags]    CRT_TRUNK
    CB009509-BA_1_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_50+50+50MHz

*** Keywords ***
