*** Settings ***
Documentation
...    Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com
...    Description: Block/unblock all cells, Reset BBMOD, Reset pRRH, Verify Load Balance Power Saving feature

Resource    ./resources/keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation
...              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...              increase_timeout_for_update_sw=1800
...              prefix_tag=TL342
...              list_of_additional_allowed_alarms=Failure detected on assigned antennas

Test Setup       Common Preconditions    verify_mandatory_scf_params=False

Test Teardown    Common Postconditions

*** Test Cases ***
[1][1.0] CB010611_lock_unlock_cells_power_saving_APHG_ABIP
    Log Current Time
    Verify Parameters Are Set To Correct Value For Cell Lock/Unlock
    Perform Lock Cell Test In Loop
    Verify Historic Alarms After Cell Lock
    [Teardown]    Teardown For Cell Unlock

[1][3.0] CB010575_reset_bbmod_ABIP
    Log Current Time
    Reset BBMODs And Wait For All Cells To Be OnAir
    Verify Historic Alarms After BBMOD reset

[1][2.0] CB010988_prrh_reset_ABIQ
    Log Current Time
    Reset ANTMOD In Loop And Wait For All Cells To Be OnAir
    Verify Historic Alarms After ANTMOD Reset

[1][1.0] CB010611_disable_cell_low_traffic_power_saving_APHA_ABIQ
    [Documentation]    Parameter NRPGRP:LbpsCellList must be created by a user
    Log Current Time
    Verify lbpsSOffTrRule Value
    Set Parameters To Correct Value For Low Traffic
    Save Test Start Time
    Run Tput And Wait For Cell To Be Disabled
    Verify If Cells Are Disabled During Traffic
    [Teardown]    Set lbpsPeriodList To Be Suspended

[1][2.0] CB010575_configure_multiRAT_l3call_ABIP
    Log Current Time
    Verify MultiRAT Configuration
    Perform L3Call
    Verify Historic Alarms After L3Call

[1][2.0] CB010575_hubReset_APHG_l3call_ABIP
    Log Current Time
    Perform L3Call
    Reset ASIRMOD And Wait For All Cells To Be OnAir
    Perform L3Call
    Verify Historic Alarms After ASIRMOD Reset

[1][3.0] CB010575_configure_SFN_20Mhz_2pRRH_l3call_ABIP
    Log Current Time
    Perform L3Call
    Verify Hostcell Bandwidth
    Verify Historic Alarms After L3Call
