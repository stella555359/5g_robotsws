*** Settings ***
Documentation     author: Huang Shushu
...               contact: shushu.huang@nokia-sbell.com
...               squad group: MMW_SG_03
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    Resources/TL924_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T924
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}


*** Test Cases ***
[1][1.0] General_SiSo_Auto_RAT_reset_with_L3call
    [Setup]
    Check the GNSS Update status    connection=${connection}
    Run Keyword and Continue on Failure    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    NR reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_robust_BBMOD_lock_unlock
    [Setup]
    Run Keyword and Continue on Failure    BBMOD lock/unlock 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_robust_site_reset
    [Setup]
    Run Keyword and Continue on Failure    Site reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout


[1]TL924_robust_BBMOD_reset
    [Setup]
    Run Keyword and Continue on Failure    BBMOD reset 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_SiSo_NR_Block_Unblock_Site
    [Setup]
    Run Keyword and Continue on Failure    Block and Unblock site 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_robust_RU_lock_unlock
    [Setup]
    Run Keyword and Continue on Failure    RU lock/unlock 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_robust_CELL_lock_unlock
    [Setup]
    Run Keyword and Continue on Failure    cell lock/unlock 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout

[1]TL924_robust_CELL_delete_add
    [Setup]
    Run Keyword and Continue on Failure    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    CELL delete and add 5 times
    [Teardown]    Run Keyword And Ignore error    COAM Logout