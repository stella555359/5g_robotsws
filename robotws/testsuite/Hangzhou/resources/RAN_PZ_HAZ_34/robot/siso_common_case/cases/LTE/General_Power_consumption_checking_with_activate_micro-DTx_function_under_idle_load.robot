*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_Power_consumption_checking_with_activate_micro-DTx_function_under_idle_load
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to check Power consumption activate micro-DTx function
    ...    and allow traffic concentrate at the same time for TDD RRU CPRI connection
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.04.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1
    ${flag}    run keyword and return status    Should contain    ${TEST_TAGS}[0]    S-
    ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
    run keyword if    ${flag}      Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    sleep  30
    ${cell_id_list}  Get All Cell Id  cell_type=${cell_type}
    log to console   \n enable Power Saving mode
    ${modify_params}  Get actMicroDTX modify parameters list  cell_id_list=${cell_id_list}  new_value=true
    Modify Parameters On Webem  modify_params=${modify_params}
    sleep  30
    ${power_meassure_1}  Get RMOD Power Measurement  ru_index=${ru_index}
    log to console   \n disable Power Saving mode
    ${modify_params}  Get actMicroDTX modify parameters list  cell_id_list=${cell_id_list}  new_value=false
    Modify Parameters On Webem  modify_params=${modify_params}
    sleep  30
    ${power_meassure_2}  Get RMOD Power Measurement  ru_index=${ru_index}
    ${p_value}    Evaluate    "%.2f" % ((${power_meassure_2}-${power_meassure_1})/${power_meassure_2})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent with idle load:${per_value}%
    should be true      0.05 <= ${p_value} < 0.8
