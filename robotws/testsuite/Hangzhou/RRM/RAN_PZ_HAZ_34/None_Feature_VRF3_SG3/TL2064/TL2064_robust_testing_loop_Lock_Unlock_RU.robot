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

[1]TL2064_robust_testing_Lock_unlocked_RU
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock RU 10 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vdu connection

[1]TL2064_robust_testing_Lock_unlocked_CELL
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock CELL 10 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vdu connection

[1]TL2064_robust_testing_Lock_unlocked_CELL_CU
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock CELL_CU 10 times
    [Teardown]    RUN KEYWORD AND Ignore error    Teardown vcu connection
