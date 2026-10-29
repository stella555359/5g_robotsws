*** Settings ***
Documentation
...   author: Marcin Szlapa, Pawel Marszalek
...   contact: marcin.szlapa@nokia.com, pawel.marszalek@nokia.com

Library     taf.sw.reporting_portal
Library     taf.rfrl.common_resources.reporting_portal.ref_configuration_id
Resource    ./Energy_Efficiency_Measurements.robot
Variables   ./kpi.py

Suite Setup         Run Keywords
...                 gnbbbu.Upload swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt    AND
...                 set_swconfig_flag    flag=0x450027    value=1    AND
...                 set_swconfig_flag    flag=0x980007    value=1    AND
...                 Common Suite Setup With Commissioning    prefix_tag=idle_low_EE_11
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Test Cases ***
Energy_Efficiency_Measurements_Cell_blocked_Idle_TDD
    Set Suite Variable    ${REFERENCE_CONFIGURATION_ID}    CNF_EE_11
    gnb_counter.Wait for next PM period
    Energy_Efficiency_Measurements
    ...    config=idle_low_EE_11
    ...    load_levels=Idle,Low
    Report Reference Configuration ID
