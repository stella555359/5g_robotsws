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
[1]CB012190_Manual_SiSo_commission
    [Setup]
    Run Keyword and Continue on Failure    Scf commission 10 times for 2CC
    Run Keyword and Continue on Failure    Scf commission 10 times for concurrent 2CC
    [Teardown]    Run Keyword And Ignore error    COAM Logout
