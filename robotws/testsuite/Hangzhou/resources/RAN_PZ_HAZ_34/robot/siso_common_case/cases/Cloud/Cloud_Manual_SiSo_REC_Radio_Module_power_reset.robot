*** Settings ***

Resource  taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The objective of the test case is to verify RU recovery and Site onair after Radio Power Reset.
    ...    - [PARAMETERS] suite_name,  default value, default;with_call, default value, True;test_name, default value, default
    ...    - [TEST METHODOLOGY] The test case is executed by following the steps below:
    ...    - 1. Get All Rmods Ids list.
    ...    - 2. Power off all radios module for at least 5s.and check radio status.
    ...    - 3. check rmod status is abnormal.
    ...    - 4. Power on all radios module.
    ...    - 5. Verify the RU recovery and Site onair and Make L3call success.
    ...    - [TEST EXPECTED RESULT] The RU should recover and Site should be onair after Radio Power Reset.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.05.2024 - - Created
    ...    *******************
    ...    Owner：kaihui.fan@nokia-sbell.com
    [Arguments]    ${suite_name}=default    ${with_call}=True    ${test_name}=default  ${gnb_index}=${0}    ${vdu_index}=${0}
    ...    ${fhgw_index}=${0}
    ${rmods_ids}=    Get RMOD ID List By RESTAPI
    FOR   ${rmod_id}    IN    @{rmods_ids}
        ${ru_model}  ${ru_pdu_ip}  ${ru_pdu_port}  Set RU Power Variables Based On Direct Connection Flag
         ...  ru_index=${rmod_id}    gnb_index=${gnb_index}    vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
        Cloud Perform RU Power Off   ru_index=${rmod_id}  gnb_index=${gnb_index}   vdu_index=${vdu_index}  model=${ru_model}
        ...   ru_pdu_ip=${ru_pdu_ip}    ru_pdu_port=${ru_pdu_port}
    END
    log to console   check ru status should be abnormal for all ru...
    Wait until keyword succeeds    5 min    30 sec
    ...   RMOD Status Should Be As Expected   rmods_id_list=${rmods_ids}    availability_status=not installed   operational_state=disabled
    FOR  ${rmod_id}    IN    @{rmods_ids}
        ${ru_model}  ${ru_pdu_ip}  ${ru_pdu_port}  Set RU Power Variables Based On Direct Connection Flag
        ...  ru_index=${rmod_id}    gnb_index=${gnb_index}    vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
        Cloud Perform RU Power On    ru_index=${rmod_id}  gnb_index=${gnb_index}   vdu_index=${vdu_index}  model=${ru_model}
        ...   ru_pdu_ip=${ru_pdu_ip}    ru_pdu_port=${ru_pdu_port}
    END
    log to console   check ru status should be normal for all ru...
    Wait until keyword succeeds    5 min    30 sec
    ...   RMOD Status Should Be As Expected   rmods_id_list=${rmods_ids}    availability_status=on line   operational_state=enabled
    log to console  check all cell status should be normal...
    Wait until keyword succeeds    5 min    30 sec   All Cells Should Be Onair For All vDUs
    log to console  check make L3call...
    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}  Cloud UE L3 Call And Throughput  cell_list=${cell_index_list}    test_name=${test_name}
    ...   suite_name=${suite_name}





