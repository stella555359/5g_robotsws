*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007932
...   authors: Marek Kobosko, Miroslaw Wiacek
...   contact: marek.kobosko@nokia.com, miroslaw.wiacek@nokia.com


Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/pm_counters/pm_counters_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/SISO/features/CB007932/resources/variables.py

Force Tags    STATE_SW_UPLOADED    CRT    PY36
...           RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABIOB6_FXED
...           RAN_5G_MP__WITH__SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABIOB6_FXED
...           RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABIOB6_FXED

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=testsuite/Krakow/SISO/features/CB007932/resources/swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${allowed_fault_name}    BTS Reset Cause
@{CUSTOM_ALLOWED_ALARMS}    ${allowed_fault_name}

*** Test Cases ***
SBTS_TEMPERATURE_counters_activation
     Full counters verification    interval=15min
     ...                           counters=${temperature_counters}
     Full counters verification    interval=30min
     ...                           counters=${temperature_counters}
     [Teardown]    Run Keywords    Run Keyword If Test Failed
     ...    Disable counters    counters=${temperature_counters}
     ...    AND
     ...    Common Postconditions With Watching Alarms

SBTS_TEMPERATURE_counters_deactivation
     Counters deactivation    interval=15min
     ...                      counters=${temperature_counters}
