*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Cloud/step_keywords/Cloud_Rmods.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Cloud/step_keywords/Cloud_Cells.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_General_SiSo_RF_alarms_without_autonomous_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is verification of RU connection and fault reporting in WebUI.
    ...    RU should be affected error, that does not cause RU autonomous reset, triggered during normal BTS run.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 08.04.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${pipe_num}=4
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    log to console    \n Trigger Fault 2922 with "minor"
    FOR  ${pipe_index}  IN RANGE  ${pipe_num}
        ${expert_prompt}    set variable    PostCombGain\\s+=\\s+\\-inf\\s+\\[dB\\]
        ${output}    Cloud SSH Execute CMD    command=dapd -dg ${pipe_index} 0 -100   check_result=${False}   alias=${alias}
        ...    expert_prompt=${expert_prompt}
    END
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "minor"
    Wait until keyword succeeds    10min    30s     Expect Fault Should Present On vDU   fault_id=2922    severity=minor
    log to console    \n Trigger Fault 2922 with "major"
    ${expert_prompt}    set variable    PostCombGain\\s+=\\s+\\-inf\\s+\\[dB\\]
    ${output}    Cloud SSH Execute CMD    dapd -dg 4 0 -100   check_result=${False}   alias=${alias}
    ...    expert_prompt=${expert_prompt}
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "major" and cell "degraded"
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present On vDU    fault_id=2922    severity=major
    Cloud Cell Status Should as Expect    operational_state=enabled    availability_status=degraded
    ...    administrative_state=Unlocked    blocking_state=Unblocked
    log to console    \n Recover Fault 2922 by RU reset
    ${rmods}    create list    ${ru_index}
    Reset Rmod By Rest    rmods_list=${rmods}
    sleep    5m
    log to console    check cell status should be onair for du...
    wait until keyword succeeds     10min    10s    All Cells Should Be Onair For One Specific vDU
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}
