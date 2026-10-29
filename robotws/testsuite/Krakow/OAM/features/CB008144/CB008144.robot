*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB008144-5G Improved 5G sleeping cell detection

Resource      resources/Resources.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      resources/variables.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     resources/counter_dict.py
Library       DateTime

Test Timeout  24 hours

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
...                                increase_time_for_checking_bbmod=600
...                                increase_timeout_for_update_sw=1800
...                                increase_time_for_checking_radios=2100
...                                increase_time_for_checking_cells=700
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}
...    Sleeping Cell Detection Due To Abnormal Antenna TX Power Measurements
...    Sleeping Cell Detection Due To Abnormal Antenna RX Power Measurements
...    Baseband card autonomous reset as recovery action
...    No feedback signal
...    BTS site autonomous reset as recovery action
...    Setup of X2 connectivity to gNB failed
...    NgGnbInitFullReset
...    BTS Reset Cause

*** Test Cases ***
CB008144-5G_1_Antenna_RX_power_sleeping_cell_detected_all_recovery_phases
    CB008144-5G_1_Antenna_RX_power_sleeping_cell_detected_all_recovery_phases

CB008144-5G_6_Antenna_TX_power_sleeping_cell_detected_only_selected_recovery_phases
    CB008144-5G_6_Antenna_TX_power_sleeping_cell_detected_only_selected_recovery_phases

CB008144-5G_7_Antenna_RX_power_sleeping_cell_detected_limit_of_recovery_actions
    CB008144-5G_7_Antenna_RX_power_sleeping_cell_detected_limit_of_recovery_actions
