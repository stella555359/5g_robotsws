*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB009576_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T2068
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}


*** Test Cases ***
[1][1.0] General_SiSo_Auto_RAT_reset_with_L3call
    [Setup]
    Run Keyword and Continue on Failure    NR reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL2068_robust_site_reset
    [Setup]
    Run Keyword and Continue on Failure    Site reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout


[1]TL2068_SiSo_NR_Block_Unblock_Site
    [Setup]
    Run Keyword and Continue on Failure    Block and Unblock site 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

