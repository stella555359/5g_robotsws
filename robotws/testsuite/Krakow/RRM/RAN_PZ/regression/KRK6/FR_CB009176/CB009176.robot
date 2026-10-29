*** Settings ***
Documentation
...   author: Andrzej Pencak
...   contact: andrzej.pencak@nokia.com
...   maintainer: andrzej.pencak@nokia.com


Resource    ./resources/suite_specific_keywords.robot

Suite Setup       Suite Setup

*** Variables ***
${interval}    15min

*** Test Cases ***
CB009176_07_RU_shutdown_through_FPFH_PDU_port_for_energy_saving_successful_scenario
    [Setup]    Test Setup
    Attach UE for test
    Start UDP DL and UL data transmission and verify results
    Detach UE after tput
    Collect counters from next interval
    Lock cell and check RU has been powered off for energy saving
    Check counters while RMOD poweroffbyes
    [Teardown]    Test Teardown

CB009176_11_RU_power_on_through_FPFH_PDU_port_from_energy_saving_due_to_cell_activation
    [Setup]    Test Setup with RU power off check
    Collect counters from next interval
    Unlock cell on RU and check RU woke up from energy saving
    Attach UE for test
    Start UDP DL and UL data transmission and verify results
    Detach UE after tput
    Check counters while RMOD awake
    [Teardown]    Test Teardown 24

CB009176_19_FPFH_reset_DCPORT_reset_RU_reset_when_RU_shut_down_for_energy_saving
    [Setup]    Test Setup with RU power off check
    Try to reset RMOD DCPORT and FPFH when RU powered off for energy saving
    Change actAutoPwrOffDCPort to false
    Unlock gNB Cell    cell_id=1
    Wait until all cells are onair
    Try to reset RMOD
    [Teardown]    Test Teardown

CB009176_24_advanceTimeForDCPortPwrOn_change_when_RU_powered_off_for_energy_saving
    [Setup]    Test Setup with RU power off check
    Change advanceTimeForDCPortPwrOn from configuration
    Check RU woke up from energy saving
    Unlock gNB Cell    cell_id=1
    Wait until all cells are onair
    Attach UE for test
    Start UDP DL and UL data transmission and verify results
    Detach UE after tput
    [Teardown]    Test Teardown 24

Energy_monitoring
    [Setup]    monitoring.configure_bts_connection
    monitoring.enable_energy_efficiency_monitoring
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.start_measurement_period    ee_features_status=disabled    interval=${interval}
    monitoring.stop_measurement_period    ee_features_status=disabled
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.save_energy_consumption_counters_values    ee_features_status=disabled    filepath=${OUTPUT DIR}/disabled_features_log.json
    Log to console    Turn on EE feature
    Change energySavingMode to DEEP SLEEP
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.start_measurement_period    ee_features_status=enabled    interval=${interval}
    Sleep    6min    reason=Wait for RU Deep Sleep
    monitoring.stop_measurement_period    ee_features_status=enabled
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.save_energy_consumption_counters_values    ee_features_status=enabled    filepath=${OUTPUT DIR}/enabled_features_log.json
    monitoring.get_counters_difference_for_enabled_disabled_features

