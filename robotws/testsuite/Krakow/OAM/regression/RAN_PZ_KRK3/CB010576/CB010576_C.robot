*** Settings ***
Documentation
...    Test suite for regression testing of feature CB010576-C
...    author:      Maciej Majewski
...    contact:     maciej.majewski@nokia.com
...    maintainer:  maciej.majewski@nokia.com

Library       ./resources/CB010576_resources.py
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./resources/variables.py

Test Setup                  Common Preconditions
Test Teardown               Common Postconditions

Suite Setup                 Common Suite Setup With OnAir Test Line Preparation
Suite Teardown              Common Suite Teardown

*** Variables ***
@{allowed_alarms}                   SSH enabled
...                                 R&D Service Port enabled
...                                 Service account root access is enabled
...                                 Ethernet port security is disabled
...                                 ToP reference missing
...                                 LMP access via port 443
@{cells_from_selected_nrcellgrp}    5    6
@{all_cells}                        1    2    5    6

*** Test Cases ***
[1][1.0] CB010576_SR_C- General_SiSo_Cell_block_and_unblock
    Block cells and check alarm activation    cell_list=${cells_from_selected_nrcellgrp}
    Log to console    Cells from selected NRCELLGRP are blocked
    Unblock cells    cell_list=${cells_from_selected_nrcellgrp}
    Log to console    Cells from selected NRCELLGRP are unblocked
    Block cells and check alarm activation    cell_list=${all_cells}
    Log to console    All cells are blocked
    Check X2 alarm activation
    Log to console    X2 alarm is activated
    Unblock cells    cell_list=${all_cells}
    Log to console    All cells are unblocked, waiting for alarm deactivation
    Check cell blocked alarm deactivation
    Check X2 alarm deactivation
    Check all cells are onair

[1][1.0] CB010576_SR_C-General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Lock selected cells    cell_list=${cells_from_selected_nrcellgrp}
    Log to console    Cells from selected NRCELLGRP are locked
    Unlock selected cells    cell_list=${cells_from_selected_nrcellgrp}
    Log to console    Cells from selected NRCELLGRP are unlocked
    Lock selected cells    cell_list=${all_cells}
    Log to console    All cells are locked
    Check X2 alarm activation
    Log to console    X2 alarm is activated
    Unlock selected cells    cell_list=${all_cells}
    Log to console    All cells are unlocked, waiting for X2 alarm deactivation
    Check X2 alarm deactivation
    Check all cells are onair

[1][1.0] CB010576_SR_E_CB008782_FM_RMOD_power_off_on_FID4589
    Power Reset gNB Radio Unit
    Log to console    RU power reset is performed
    Check unit power reset alarm activation
    Log to console    Unit power reset alarm is activated
    Check all cells are onair
