*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify cell and group cell lock/ unlock functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${stream}    get stream from version    ${Active_SW_version}
    ${boundary}    get the boundary of stream    stream=${stream}
    ${cell_info_list}    Get All Cells Status Info    cell_type=${cell_type}
    ${modify_params}    Generate Modify cell lock unlock Parameters list    cell_info_list=${cell_info_list}
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    sleep  120
    Cell Status Info Should Be locked    cell_type=${cell_type}    boundary=${boundary}
    ${modify_params}    Generate Modify cell lock unlock Parameters list
    ...    cell_info_list=${cell_info_list}    new_value=unlocked
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    sleep  120
    Cell Status Info Should Be Enable   cell_type=${cell_type}    boundary=${boundary}
    Simple UE L3 Call And Throughput
