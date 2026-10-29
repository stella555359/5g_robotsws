*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot

*** Variables ***

*** Keywords ***
5GC000561_eCPRI_sync_generic_startup_at_RAU
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RAU synchronization startup for eLLF interface
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.4.20 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    Sync Startup is verified LTE
    Sync status reported to O&M is verified
