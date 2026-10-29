*** Settings ***
Suite Setup          CBRS UTE Upgrade Suite Setup    UTECloud=True
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

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_SA_ASOE_AWHQU_HAZ

*** Test Cases ***
[1]CB009509-BA_1_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_50+50+50MHz
    [Tags]    CRT_TRUNK
    CB009509-BA_1_NR_Only 4T4R_Data_Transfer_Conducted_Peak_TPUT_50+50+50MHz

[1]CB009365-A_1_4T4R NR 4CC Frequency Selection Algorithm with more than 110Mhz available channels
    [Tags]    CRT_TRUNK
    CB009365-A_1_4T4R NR 4CC Frequency Selection Algorithm with more than 110Mhz available channels

[1]CB009365-A_CA_2_online_modify_cCaPairCellId_Intra-gNB_FDD-TDD_CA_4CC
    [Tags]    CRT_TRUNK
    CB009365-A_CA_2_online_modify_cCaPairCellId_Intra-gNB_FDD-TDD_CA_4CC

