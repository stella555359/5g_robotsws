*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
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
[1]TL2064_robust_testing_DU_reset_loop
    [Setup]
    Run Keyword and Continue on Failure    check update fault
    Run Keyword and Continue on Failure    DU reset 5 times
    [Teardown]


[1]TL2064_robust_testing_commission_DU
    [Setup]
    Run Keyword and Continue on Failure    DU Commission 5 times
    [Teardown]

[1]TL2064_robust_testing_commission_CU
    [Setup]
    Run Keyword and Continue on Failure    CU Commission 5 times
    [Teardown]

[1]TL2064_robust_testing_CU_reset
    [Setup]
    Run Keyword and Continue on Failure    CU reset 5 times
    [Teardown]

[1]TL2064_robust_testing_Lock_unlocked_RU
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock RU 5 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vdu connection

[1]TL2064_robust_testing_Lock_unlocked_CELL
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock CELL 5 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vdu connection

[1]TL2064_robust_testing_Lock_unlocked_CELL_CU
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock CELL_CU 5 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vcu connection

[1]TL2064_robust_testing_RU_reset
    [Setup]
    Run Keyword and Continue on Failure    RU reset 2 times
    [Teardown]
