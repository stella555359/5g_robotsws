*** Settings ***
Documentation    Keywords bundler for energy efficiency monitoring validations. Based on a below library.

Library    taf.ul.energy_efficiency_monitoring    WITH NAME    monitoring
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py


*** Variables ***
${interval}    15min    # Default interval value

*** Keywords ***
Start initial energy efficiency monitoring
    monitoring.configure_bts_connection
    log to console    __Setup initial energy efficiency values.
    monitoring.enable_energy_efficiency_monitoring
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.start_measurement_period    ee_features_status=disabled    interval=${interval}

Stop initial energy efficiency monitoring
    log to console    __Getting initial energy efficiency values.
    monitoring.stop_measurement_period    ee_features_status=disabled
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.save_energy_consumption_counters_values    ee_features_status=disabled    filepath=${OUTPUT DIR}/disabled_features_log.json


Start final energy efficiency monitoring
    log to console    __Setup final energy efficiency values.
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.start_measurement_period    ee_features_status=enabled    interval=${interval}

Stop final energy efficiency monitoring and compare values
    log to console    __Getting final energy efficiency values.
    monitoring.stop_measurement_period    ee_features_status=enabled
    monitoring.wait_for_next_pm_period    interval=${interval}
    monitoring.save_energy_consumption_counters_values    ee_features_status=enabled    filepath=${OUTPUT DIR}/enabled_features_log.json
    &{results}    monitoring.get_counters_difference_for_enabled_disabled_features
    check energy efficiency results    ${resluts}
