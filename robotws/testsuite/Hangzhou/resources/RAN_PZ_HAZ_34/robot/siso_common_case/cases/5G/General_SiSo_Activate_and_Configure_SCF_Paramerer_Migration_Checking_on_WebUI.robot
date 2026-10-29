*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_Activate_and_Configure_SCF_Paramerer_Migration_Checking_on_WebUI
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to check feature parameter migration rules on WebUI.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.06.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${cell1_list}    Get split mode modify parameters list    cell_id=${1}    band=${60}    mMimoAntArrayMode=Top 16TRX Array (1x8x2)
    ${cell2_list}    Get split mode modify parameters list    cell_id=${2}    band=${30}    mMimoAntArrayMode=Bottom 16TRX Array (1x8x2)
    ${cell_list}    combine lists    ${cell1_list}    ${cell2_list}
    FOR  ${item}  IN  @{cell_list}
        selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    selenium_coam.validate_plan
    ${relation_errors}    wait until keyword succeeds    1min    5s   selenium_coam.get_relation_errors
    ${list_num}   Get Length   ${relation_errors}
    Should be True    ${list_num}==${0}
    selenium_coam.undo_changes
    [Teardown]  Selenium Logout And Close Browser
