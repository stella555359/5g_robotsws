*** Settings ***
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB012190_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T904
${scf_file}    SCF_SBTS00.xml

*** Test Cases ***
[1]CB012190_Manual_SiSo_SM_BTS_NR_Reset
    [Setup]
    Scf commission and wait on-air    scf_name=SCF_CB012190_TMO_concurrent.xml
    Run Keyword and Continue on Failure    NR reset 20 times

    Scf commission and wait on-air    scf_name=SCF_CB012190_TMO.xml
    Run Keyword and Continue on Failure    NR reset 20 times


    [Teardown]    Run Keyword And Ignore error    COAM Logout
