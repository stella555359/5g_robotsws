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
${scf_file}    SCF_SBTS00.xml

*** Test Cases ***
[1]CB009576_Manual_SiSo_SM_Block_Unblock_site
    [Setup]
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    Block and Unblock site 20 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout
