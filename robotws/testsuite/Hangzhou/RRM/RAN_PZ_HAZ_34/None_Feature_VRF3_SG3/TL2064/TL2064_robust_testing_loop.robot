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
[1]TL2064_robust_testing_DU_reset_loop
    [Setup]
    Run Keyword and Continue on Failure    check update fault
    Run Keyword and Continue on Failure    DU reset 20 times
    [Teardown]