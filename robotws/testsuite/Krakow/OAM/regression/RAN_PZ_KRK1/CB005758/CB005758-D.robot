*** Settings ***
Documentation    Test suite for testing of feature CB005758-D
...              authors: Marek Szlapa, Marcin Bereznicki
...              contact: marek.szlapa@nokia.com, marcin.bereznicki@nokia.com


Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/pm_counters/pm_counters_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/OAM/regression/RAN_PZ_KRK1/CB005758/resources/variables.py

Force Tags        STATE_SW_UPLOADED    CRT    PY36

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=testsuite/Krakow/OAM/regression/RAN_PZ_KRK1/CB005758/resources/swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}     BTS Reset Cause


*** Test Cases ***
[1]CB005758-D_ASiR_diagnostic_and_serviceability_parity-ASIRMOD_temperature_counters-Activation
     Full counters verification    interval=15min
     ...                           counters=${temperature_counters}
     Full counters verification    interval=30min
     ...                           counters=${temperature_counters}
     [Teardown]    Run Keywords    Run Keyword If Test Failed
     ...    Disable counters    counters=${temperature_counters}
     ...    AND
     ...    Common Postconditions With Watching Alarms

[1]CB005758-D_ASiR_diagnostic_and_serviceability_parity-ASIRMOD_temperature_counters-Deactivation
     Counters deactivation    interval=15min
     ...                      counters=${temperature_counters}
