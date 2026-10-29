*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
Inter-site_CA_Activation_Deactivation
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of the test is to verify that the Inter-site CA can be activated
    ...    and deactivated properly.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.18.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
    COAM Commission with scf file  scf_file_path=${SCF_Path}    timeout=600
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Run Keyword And Ignore Error    Close Start Up View Window    timeout=5
    ${modify_params}    Get CA modify parameters list
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Simple UE L3 Call And Throughput
    ${modify_params}    Get CA modify parameters list    new_value=false
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    Simple UE L3 Call And Throughput
