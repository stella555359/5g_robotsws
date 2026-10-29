*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/scf_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
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
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${gnb_index}=${0}    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${modify_params}  ${origin_params}  Modify TimeZone In Scf And Commissioning
    Modify Parameters In SCF From Webem And Commission  modify_params=${modify_params}    gnb_index=${gnb_index}    connection=${connection}
    sleep    180
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    connection=${connection}    gnb_index=${gnb_index}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${modify_params}
    Modify Parameters On Webem  ${origin_params}
    sleep    180
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    connection=${connection}    gnb_index=${gnb_index}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${origin_params}
    [Teardown]  Selenium Logout And Close Browser
