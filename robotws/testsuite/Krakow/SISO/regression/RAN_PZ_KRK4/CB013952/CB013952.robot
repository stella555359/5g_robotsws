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
...                 Common Suite Setup With Commissioning    prefix_tag=${SCF_PREFIX}
Suite Teardown      Common Suite Teardown
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
${SCF_PREFIX}    FDD_EE_14
@{additional_allowed_alarms} =  VSWR lower threshold exceeded
@{CUSTOM_ALLOWED_ALARMS}    VSWR lower threshold exceeded

*** Test Cases ***
Energy_Efficiency_Measurements_Low_TM1-1-ETSI_slot-wise_Low_Medium_Busy_FDD_EE_14
    [Setup]    Test Setup With Commissioning    prefix_tag=FDD_EE_14
    Set Suite Variable    ${REFERENCE_CONFIGURATION_ID}    CNF_EE_14
    gnb_counter.Wait for next PM period
    Energy_Efficiency_Measurements
    ...    config=FDD_EE_14
    ...    load_levels=Medium,Busy,Full
    Report Reference Configuration ID

Energy_Efficiency_Measurements_Low_TM1-1-ETSI_slot-wise_Low_Medium_Busy_TDD_EE_14
    [Setup]    Test Setup With Commissioning    prefix_tag=TDD_EE_14
    Set Suite Variable    ${REFERENCE_CONFIGURATION_ID}    CNF_EE_14
    gnb_counter.Wait for next PM period
    Energy_Efficiency_Measurements
    ...    config=TDD_EE_14
    ...    load_levels=Medium,Busy,Full
    Report Reference Configuration ID

Energy_Efficiency_Measurements_Low_TM1-1-ETSI_slot-wise_Low_Medium_Busy_FDD_EE_11
    [Setup]    Test Setup With Commissioning    prefix_tag=FDD_EE_11
    Set Suite Variable    ${REFERENCE_CONFIGURATION_ID}    CNF_EE_11
    gnb_counter.Wait for next PM period
    Energy_Efficiency_Measurements
    ...    config=FDD_EE_11
    ...    load_levels=Medium,Busy,Full
    Report Reference Configuration ID

Energy_Efficiency_Measurements_Low_TM1-1-ETSI_slot-wise_Low_Medium_Busy_TDD_EE_11
    [Setup]    Test Setup With Commissioning    prefix_tag=TDD_EE_11
    Set Suite Variable    ${REFERENCE_CONFIGURATION_ID}    CNF_EE_11
    gnb_counter.Wait for next PM period
    Energy_Efficiency_Measurements
    ...    config=TDD_EE_11
    ...    load_levels=Medium,Busy,Full
    Report Reference Configuration ID
