*** Settings ***
Documentation    This is keyword file used for VRAN4.0 testline.
...   author: shushu huang
...   squad group: MMW_SG3

Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/TL2064_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T2064
${scf_file}    SCF_SBTS00.xml


*** Test Cases ***

[1]TL2064_robust_testing_commission_DU
    [Setup]
    DU Scf commission and wait on-air
    [Teardown]

[1]TL2064_robust_testing_reset_DU
    [Setup]
    Reset vDU and wait on-air
    [Teardown]

[1]TL2064_robust_testing_Rannic_reset
    [Setup]
    RANNIC reset and wait on-air
    [Teardown]

[1]TL2064_robust_testing_snapshot
    [Setup]
    Collect vDU snapshot
    [Teardown]

[1]TL2064_robust_testing_Lock_unlocked_RU
    [Setup]
    Lock&Unlock RU
    [Teardown]

[1]TL2064_robust_testing_RU_reset
    [Setup]
    RU reset
    [Teardown]
