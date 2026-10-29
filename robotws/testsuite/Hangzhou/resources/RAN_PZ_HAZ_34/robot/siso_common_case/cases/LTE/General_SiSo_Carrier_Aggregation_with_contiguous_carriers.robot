*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_Carrier_Aggregation_with_contiguous_carriers
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to operational 4G BTS, verify activated CA function.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.26.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${dl_tp}=256    ${ul_tp}=11.2    ${target_avg_percent}=0.95    ${duration}=180
    ${SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
    Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    UE L3 Call for Designated cell    dl_tp=${dl_tp}    ul_tp=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    duration=${duration}    scf_path=${SCF_Path}
    [Teardown]    Commissioning SCF And Check On Air for Common    scf_path=${Golden_SCF_Path}
