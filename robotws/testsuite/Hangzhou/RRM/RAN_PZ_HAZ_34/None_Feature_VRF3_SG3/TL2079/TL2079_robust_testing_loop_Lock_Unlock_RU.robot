*** Settings ***
Documentation    This is keyword file used for VRAN4.0 testline.
...   author: Aiyang zhang
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

[1]TL2079_robust_testing_Lock_unlocked_RU
    [Setup]
    Run Keyword and Continue on Failure    Lock&Unlock RU 20 times
    [Teardown]    Run keywords    RUN KEYWORD AND Ignore error    Perform RMOD unlock for teardowm
    ...    AND    RUN KEYWORD AND Ignore error    Teardown vdu connection