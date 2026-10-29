*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB008453
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Karol Switon, karol.switon@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/delta.py
Variables   resources/variables.py

Suite Setup       Common suite setup with onAir Test Line preparation
...               prefix_tag=CB008453
Suite Teardown    Common suite teardown
Test Setup        Common preconditions with watching alarms
Test Teardown     CB008453 Test teardown

*** Variables ***
${UE}    REAL_UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}      ${False}
${ENABLE_RACH_OBSERVER}                   ${False}

*** Test Cases ***
[1][1.0] CB008453-B_ITW4_Single_UE_scheduling_with_8CC
    Log to console    Delta commisioning for prach 176
    Perform delta commissioning on gNB    delta=${delta_176}
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir
    Perform L3 call and verify throughput    cells_for_l3_call=${cell_tput_after}

*** Keywords ***
CB008453 Test teardown
    Common postconditions with watching alarms
    Log to console    Delta commisioning for prach 175
    Perform delta commissioning on gNB    delta=${delta_175}
    Wait until keyword succeeds    600 sec    15 sec    gnbcell.Verify all cells are onAir

Perform L3 call and verify throughput
    [Arguments]    ${cells_for_l3_call}
    Set test variable    ${L3_CALL_STATUS}    ${True}
    Prepare UE for L3 call
    ...    capabilities=${UE}
    ...    alias=${UE}
    ${cell_ids}    Get dictionary keys    ${cells_for_l3_call}
    FOR    ${cell_id}    IN     @{cell_ids}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=1%
        ...    parallel_streams_dl=8
        ...    parallel_streams_ul=4
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected

Perform L3 call on selected cell
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}
    ...            ${parallel_streams_dl}=4    ${parallel_streams_ul}=2    ${attach_timeout}=${20}
    Log to console    Run tput on cell ${cell_id}
    ${status}    Run keyword and ignore error
    ...    Verify L3 call data transfer DL&UL
    ...    duration=60s
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    protocol=udp
    ...    deviation=${deviation}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet=1300B
    ...    alias=${UE}
    ...    attach_timeout=${attach_timeout}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}

Analyse L3 call status
    [Arguments]    ${l3_call_status}    ${cell_id}
    Run keyword if    '${l3_call_status[0]}'=='FAIL'    Run keywords
    ...    Log to console    Tput on cell ${cell_id} failed: ${l3_call_status[1]}
    ...    AND
    ...    Set test variable    ${L3_CALL_STATUS}    ${False}
