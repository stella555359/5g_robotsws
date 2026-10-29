*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_RF_module_addition_in_BIM_and_WebUI
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to check whether configured BTS components are visible in WebUI.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Perform BTS Site Reset
    sleep   2min
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Check HW modules detection
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Check RF config from webui  ru_index=${ru_index}
    END
    [Teardown]  Selenium Logout And Close Browser
