*** Settings ***
Documentation    This is keyword file used for VRAN4.0 testline.
...   author: Aiyang Zhang
...   squad group: HAZ3_SG3

Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/TL2079_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G401T2079
${scf_file}    SCF_SBTS00.xml


*** Test Cases ***

[1]TL2079_robust_testing_commission_DU
    [Setup]
    DU Scf commission and wait on-air
    [Teardown]

[1]TL2079_robust_testing_reset_DU
    [Setup]
    Reset vDU and wait on-air
    [Teardown]

[1]TL2079_robust_testing_Rannic_reset_loop
    [Setup]
    Run Keyword and Continue on Failure    RANNIC reset 1 times
    [Teardown]

[1]TL2079_robust_testing_Lock_unlocked_RU_loop
   [Setup]
   Run Keyword and Continue on Failure    Lock&Unlock RU 1 times
   [Teardown]

[1]TL2079_robust_testing_RU_reset_loop
    [Setup]
    Run Keyword and Continue on Failure    RU reset 1 times
    [Teardown]
