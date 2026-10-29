*** Settings ***
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/TL922_TMO_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T922
${scf_file}    SCF_SBTS00.xml

*** Test Cases ***
[1]TL922_Manual_SiSo_SM_BTS_NR_Reset
    [Setup]
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    NR reset 30 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout
