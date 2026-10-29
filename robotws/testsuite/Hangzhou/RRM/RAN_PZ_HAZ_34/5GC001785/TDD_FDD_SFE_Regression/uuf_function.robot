*** Settings ***
Documentation
...    Author: Ming Shi
...    Contact: ming.shi@nokia-sbell.com

Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/uuf_common_keywords.py

*** Variables ***
@{index_list}    ${0}    ${1}


*** Test Cases ***
uuf_upgrade
    [Documentation]    uuf upgrade
    [Tags]    classical    uuf
    [Setup]
    download_packages_to_ute
    multi_bts_upgrade
    [Teardown]    Run Keyword If Test Failed    multi_bts_save_snapshot    index_list=${index_list}

uuf_rollback
    [Documentation]    uuf rollback
    [Tags]    classical    uuf
    [Setup]
    multi_bts_rollback
    [Teardown]    Run Keyword If Test Failed    multi_bts_save_snapshot    index_list=${index_list}

uuf_reset
    [Documentation]    uuf reset
    [Tags]    classical    uuf
    [Setup]
    multi_bts_reset
    [Teardown]    Run Keyword If Test Failed    multi_bts_save_snapshot    index_list=${index_list}