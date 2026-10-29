*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    10889 Suite Setup
Suite Teardown    Suite TearDown For 10889
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010889/TestData/CB010889_case_steps.robot

*** Test Cases ***
[1]CB010889_SR_AA_04_ULMUMIMO_2_rank2_paired_with_ulsrsbm_2CC_4UE
    [Documentation]    CHBW:60_60MHz
    [Tags]    Classical    CRT_TRUNK    CRT_24R3    CRT_25R1    CRT_25R2
    [Setup]  10889 Case SetUp    scf_file_name=SCF_${stream}_1S_2CC_16D8U_8RX
    CB010889_SR_AA_04_ULMUMIMO_2_rank2_paired_with_ulsrsbm_2CC_4UE
    [Teardown]   10889 Case TearDown
