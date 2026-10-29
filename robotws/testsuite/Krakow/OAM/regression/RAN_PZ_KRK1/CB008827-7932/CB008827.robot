*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008827
...   authors: Klaudia Krzych
...   contact: klaudia.krzych@nokia.com
...   CB008827 is a parity feature of CB007932 for ABIP

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ../../../../resources/pm_counters/pm_counters_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

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
