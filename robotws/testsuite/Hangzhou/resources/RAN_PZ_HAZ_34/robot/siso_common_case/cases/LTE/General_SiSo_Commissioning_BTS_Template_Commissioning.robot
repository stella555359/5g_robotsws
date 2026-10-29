*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_Commissioning_BTS_Template_Commissioning
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check if not commissioned gNB can be correctly configured using
    ...    BTS Template, verify Managed Object Class in WebUI and update parameters via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.4.19 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${modify_params}  ${origin_params}  Modify TimeZone In Scf And Commissioning LTE
    sleep    120
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    Close Start Up View Window    timeout=60
    Check Parameters Modified Successfully  ${modify_params}
    Modify Parameters On Webem  ${origin_params}
    sleep    180
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    Close Start Up View Window    timeout=60
    Check Parameters Modified Successfully  ${origin_params}
    [Teardown]  Selenium Logout And Close Browser
