*** Settings ***
Documentation    Author: Lan Shifu
...              Squad group: VRF_HAZ4_T04
...              Contact: shifu.lan@nokia-sbell.com
...              Feature CNI-117636 in trunk program
...              This test suite verifies fault 4598 trigger and clear mechanism.

Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup        SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown     SISO Coam Test Teardown
Test Timeout      8h

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource          ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-117636/Resource/CNI-117636_common_keyword.robot

Force Tags    HAZ4_T04

*** Test Cases ***
[1]CNI-117636-D_01_fault_trigger_4598_TiltOffset_out_of_Range_full_mode
    [Documentation]    Verify fault 4598 can be triggered and cleared by modifying TiltOffset parameter.
    ...
    ...                Steps:
    ...                1. Get all BTS cell IDs with RU index 1
    ...                2. Configure 1116_3ms frame structure with PRACH index list
    ...                3. Configure mMIMO muting parameters
    ...                4. Verify all cells are OnAir with no alarms
    ...                5. Test fault 4598 trigger and clear for each beamSet
    ...
    ...                Expected Results:
    ...                1. Fault 4598 should be triggered when TiltOffset is out of range
    ...                2. Fault 4598 should be cleared when TiltOffset is set back to normal range
    [Tags]    2S-2CC-16D-2U-72E
    # Initialize fault list
    @{fault_list}=    Create List    4598

    # Allow fault 4598 to be present during test
    Allowed Watchdog additional alarms    fault_list=${fault_list}

    # Create PRACH index list for frame structure configuration
    # delete some values due to these values don't support multi beamset. WESTLAKE-12524
    ${prach_index_list}    Create List    3  5  7  12  89  93  94  98  148  151  157  160  162
    ...  196  201  202  203  205

    # Trigger and verify fault 4598
    Trigger_Fault_4598_By_Modify_Cell_TiltOffset_Parameter
    ...    prach_index_list=${prach_index_list}
    ...    frame_structure=1116_3ms_GP1_A5
    ...    ru_index=1
    [Teardown]  SISO Coam Test Teardown   perform_case_scf=${True}
