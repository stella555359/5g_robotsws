*** Settings ***
Documentation    Author: Lan Shifu
...    Squad group: VRF_HAZ4_T04
...    Contact: shifu.lan@nokia-sbell.com
...    Feature CB013355 in trunk program

Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup        SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown     SISO Coam Test Teardown
Test Timeout      8h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CB013355_common_keywords.robot

Force Tags        HAZ4_T04

*** Test Cases ***
[1]CB013355-SR-B_07_DU_Uplane_counter_CombinedVerification
    [Documentation]    Verify DU Uplane counter combined verification
    ...
    ...    Purpose:
    ...    - Verify the behavior of DU Uplane counters with and without traffic
    ...    - Validate counter values meet expected criteria
    ...    - Validate RU-Cell counter relationships and summations
    ...
    ...    Steps:
    ...    1. Get BTS cell IDs
    ...    2. Modify ECpri parameters via REST API
    ...    3. Verify cells are OnAir with no alarms
    ...    4. Check initial counter values before traffic test
    ...    5. Run L3 call traffic test
    ...    6. Check counter values after traffic test
    ...
    ...    Expected Results:
    ...    - All cells should be OnAir with no alarms
    ...    - Counter values should meet specific verification criteria
    ...    - Traffic should run successfully
    ...    - Counter values should be updated correctly after traffic test
    ...    - RU and Cell counter relationships should be satisfied
    [Tags]  1S-2CC-72E
    # Get the number of UEs to use for the traffic test
    ${ue_num_each_call}=    Get Tput ue Number    given_num=2

    # Execute the combined counter verification with traffic
    DU_Uplane_Counter_Combined_Verification
    ...    with_call=${True}
    ...    with_peak=${True}
    ...    duration=900
    ...    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}
    ...    test_name=${TEST NAME}

[1]CB013355-SR-B_09_DU_counters_Cancelling_Fault_4706_4707
    [Documentation]    Verify DU counters behavior with fault 4706/4707 cancellation
    ...
    ...    Purpose:
    ...    - Verify the behavior of DU counter M55318 during fault 4706/4707 conditions
    ...    - Validate counter values meet expected criteria after fault cancellation
    ...
    ...    Steps:
    ...    1. Get all BTS cell IDs
    ...    2. Configure NIDD parameters via REST API
    ...    3. Modify swconfig file to add test flags
    ...    4. Restart base station to activate flags
    ...    5. Verify all cells are OnAir and check counter values
    ...    6. Verify cells have Degraded status and alarm 4707
    ...    7. Modify swconfig file to remove flags
    ...    8. Restart base station to reset conditions
    ...
    ...    Expected Results:
    ...    - All cells should be OnAir after parameter configuration
    ...    - Counter values should meet specific verification criteria
    ...    - Cells should be in Degraded status with alarm 4707 present
    ...    - After flag removal, cells should return to normal operation
    [Tags]  1S-2CC-72E
    ${fault_list}    Create List    4707
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    # Execute DU counters fault cancellation test
    DU_Counters_Fault_Cancellation_Test
    [Teardown]    Run Keywords    SISO Coam Test Teardown    AND    Remove Test Flags From Swconfig
