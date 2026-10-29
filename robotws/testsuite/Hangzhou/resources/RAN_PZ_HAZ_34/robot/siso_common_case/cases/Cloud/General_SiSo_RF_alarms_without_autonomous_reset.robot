*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_operations.robot

*** Keywords ***
General_SiSo_RF_alarms_without_autonomous_reset
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify RU connection and fault reporting. RU should be affected
    ...      error, that does not cause RU autonomous reset.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Fault conditon is started.
    ...        2. Fault is reported but no RU autonomous recovery occurred
    ...        3. Perform manual recovery action to cancel fault
    ...        4. Fault is cancled, cells back to onair
    ...    - [EXPECTED RESULTS] Fault is cancled, cells back to onair.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The index of RU. Default value is 1.|

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 06.12.2024  - Created
    ...    *******************
    ...    * Owner_wenjin.zhang@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${ru_index}=1
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${output}    Cloud SSH Execute CMD    command=which sudo   check_result=${False}
    ...          expert_prompt=\r\n$    alias=${alias}
    ${sudo}    Replace String    ${output}    \r\n    ${EMPTY}

    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${sudo} frmonShellClient localhost 2000
    Cloud SSH Execute CMD    command=${cmd}   check_result=${False}   alias=${alias}    expert_prompt=done ok
    ${cmd}   Set Variable  echo '/CI/resetControl/module action enable_fail_safe_mode'|${sudo} frmonShellClient localhost 2000
    Cloud SSH Execute CMD    command=${cmd}   check_result=${False}   alias=${alias}    expert_prompt=done ok

    ${rmods}    create list    ${ru_index}
    Reset Rmod By Rest    rmods_list=${rmods}
    Wait until keyword succeeds    15min    30s    Expect Fault Should Present On vDU    fault_id=2934    severity=critical

    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${sudo} frmonShellClient localhost 2000
    Cloud SSH Execute CMD    command=${cmd}   check_result=${False}   alias=${alias}    expert_prompt=done ok
    ${cmd}   Set Variable  echo '/CI/resetControl/module action disable_fail_safe_mode'|${sudo} frmonShellClient localhost 2000
    Cloud SSH Execute CMD    command=${cmd}   check_result=${False}   alias=${alias}    expert_prompt=done ok

    ${rmods}    create list    ${ru_index}
    Reset Rmod By Rest    rmods_list=${rmods}

    Wait until keyword succeeds    15min    30s    Expect Fault Should Absent On vDU    fault_id=2934
    Wait until keyword succeeds    15min    30s    Checking All Cells Should Be Onair For All VDUs
