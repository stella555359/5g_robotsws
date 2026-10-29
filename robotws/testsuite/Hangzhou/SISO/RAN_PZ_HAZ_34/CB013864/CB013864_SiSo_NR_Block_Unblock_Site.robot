*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    Resources/CB013864_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T924
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}


*** Test Cases ***
[1]CB013598_SiSo_NR_Block_Unblock_Site
    [Setup]
    Run Keyword and Continue on Failure    Scf commission and wait on-air    scf_name=SCF_SBTS00_72e.xml
    Run Keyword and Continue on Failure    Block and Unblock site 30 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

