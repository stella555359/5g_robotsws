*** Settings ***
Documentation
...   Common keywords for regression testing of feature CB012685
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot

*** Keywords ***
CB012685 Common test setup
    Set test variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions with watching alarms

Perform L3 call on all cells
    [Arguments]    ${cells_for_l3_call}
    Block all cells before L3 call
    Prepare UE for L3 call
    ...    capabilities=${UE}
    ...    alias=${UE}
    ${cell_ids}    Get dictionary keys    ${cells_for_l3_call}
    FOR    ${cell_id}    IN     @{cell_ids}
        Perform L3 call on selected cell
        ...    cell_id=${cell_id}
        ...    tput_dl=${cells_for_l3_call["${cell_id}"]["tput_dl"]}
        ...    tput_ul=${cells_for_l3_call["${cell_id}"]["tput_ul"]}
        ...    deviation=20%
        ...    parallel_streams_dl=4
        ...    parallel_streams_ul=12
    END
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown
