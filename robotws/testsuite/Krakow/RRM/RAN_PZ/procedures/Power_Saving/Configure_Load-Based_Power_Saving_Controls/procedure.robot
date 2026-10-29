*** Settings ***

Resource    ../resources/Power_Saving_cmW.robot


*** Keywords ***
Configure_Load-Based_Power_Saving_Controls
    Add new power group     power_group_id=0    cell_id=1
    Activate feature 5GC000431
    Add new power group     power_group_id=1    cell_id=2    cell_switch_off_order=90

    Check if add same cell to two diffrent Power groups is not possible

    Check if lbpsStartTimeHour values are out of range
    Check if lbpsStartTimeMinute values are out of range
    Check if lbpsDuration values are out of range

    Check if lbpsMaxLoad percentage values are out of range
    Check if lbpsMinLoad percentage values are out of range
    Check if lbpsLastMinLoad percentage values are out of range

    Check if set cell switch-off in wrong order is impossible
    Log to console    \n--Check if last cell will not be removed from power group----
    Check if last cell will not be removed from power group      power_group_id=0    node_index=0

    Check if proper values of each parameters will be accepted
    [Teardown]    Run keywords       Deactivate feature 5GC000431                      AND
    ...     Remove power group      power_group_id=0                                   AND
    ...     Remove power group      power_group_id=1
