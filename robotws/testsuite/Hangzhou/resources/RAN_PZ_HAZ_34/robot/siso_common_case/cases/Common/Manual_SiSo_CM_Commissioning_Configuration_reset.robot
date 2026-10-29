*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_CM_Commissioning_Configuration_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to check that configuration reset from WebEM is working as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Coam Logout And Close Browser
    Selenium Coam Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://192.168.255.129
    ...    username=${http_username}    password=${http_password}
    Reset Configuration
    sleep  300
    Selenium Coam Logout And Close Browser
    Selenium Coam Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://192.168.255.129
    ...    username=${http_username}    password=${http_password}
    selenium_coam.continue_after_plug_and_play_modal_appear
    [Teardown]    Run keywords    COAM Commission with scf file  scf_file_path=${Golden_SCF_Path}    timeout=600
    ...    AND    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
