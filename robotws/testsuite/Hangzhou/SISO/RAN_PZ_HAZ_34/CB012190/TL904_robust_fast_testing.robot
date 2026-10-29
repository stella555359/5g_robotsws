*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
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
[1]TL904_robust__RAT_reset
    [Setup]
    Run Keyword and Continue on Failure    NR reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL904_robust_BBMOD_lock_unlock
    [Setup]
    Run Keyword and Continue on Failure    BBMOD lock/unlock 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL904_robust_site_reset
    [Setup]
    Run Keyword and Continue on Failure    Site reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout


[1]TL904_robust_BBMOD_reset
    [Setup]
    Run Keyword and Continue on Failure    BBMOD reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL904_SiSo_NR_Block_Unblock_Site
    [Setup]
    Run Keyword and Continue on Failure    Block and Unblock site 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL904_robust_RU reset
    [Setup]
    Run Keyword and Continue on Failure    RU reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

