*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot


*** Variables ***

*** Keywords ***
BS-RF_Chaining_Activation_Deactivation_via_WebEM
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify actRfChaining=true/false functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.07.2022 - - Created
    ...    *******************
    ...    Owner_xiaodong.d.chen@nokia-sbell.com
    [Arguments]  ${scf_path}    ${dist_name}    ${filter_param}=Activate support for RF chaining
    ...          ${abbr}=actRfChaining
    Commissioning SCF And Check On Air LTE    scf_path=${scf_path}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...                                       username=${http_username}    password=${http_password}
    Check and Modify Single Parameter on WebUI    dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           abbr=${abbr}
    ...                                           new_value=false
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present on WebUI    faultId=4084
    Cell Status Info Should Be Disabled
    Check and Modify Single Parameter on WebUI    dist_name=${dist_name}
    ...                                           filter_param=${filter_param}
    ...                                           abbr=${abbr}
    ...                                           new_value=true
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent on WebUI     faultId=4084
    Cell Status Info Should Be Enable
    [Teardown]   Selenium Logout And Close Browser
