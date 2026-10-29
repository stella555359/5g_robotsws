*** Settings ***
Documentation
...   author: lixia tang
...   squad group: MMW_SG3
...   contact: lixia.tang@nokia-sbell.com
...   Feature CB009801 in 5G24R2 program
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB011104_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T910
${scf_file}    SCF_SBTS00.xml


*** Test Cases ***

[1]CB011104_robust_RU_reset
    [Setup]
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    RU reset 5 times
    Run Keyword and Continue on Failure    Site reset 30 times
    Run Keyword and Continue on Failure    NR reset 30 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout


