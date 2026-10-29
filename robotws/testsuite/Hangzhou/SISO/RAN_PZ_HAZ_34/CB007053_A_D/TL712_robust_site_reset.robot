*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    Resources/TL712_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T712
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}


*** Test Cases ***

[1]TL712_robust_site_reset
    [Setup]
	Scf commission and wait on-air    scf_name=SCF_CB007053_A_10.xml
    Run Keyword and Continue on Failure    Site reset 10 times
    Run Keyword and Continue on Failure    Block and Unblock site 10 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout
