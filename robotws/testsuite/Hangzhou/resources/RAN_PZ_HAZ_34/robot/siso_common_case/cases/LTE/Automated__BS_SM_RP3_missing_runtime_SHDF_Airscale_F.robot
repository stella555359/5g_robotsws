*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
Automated__BS_SM_RP3_missing_runtime_SHDF_Airscale_F
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to perform online cell addition and deletion from WebUI
    ...    under tested configuration (which is capable of adding another cell for the same sector).
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.20.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    log to console    \n Automated__BS_SM_RP3_missing_runtime_SHDF_Airscale_F
