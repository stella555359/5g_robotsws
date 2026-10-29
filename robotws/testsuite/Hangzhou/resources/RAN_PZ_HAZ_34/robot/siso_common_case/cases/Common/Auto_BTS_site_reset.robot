*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***

*** Keywords ***
Auto_BTS_site_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify success rate of gNB site reset activated from WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.07.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Perform BTS Site Reset On WebUI
    sleep  60
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
