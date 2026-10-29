*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer:

Resource    ./resources/keywords.robot

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=7CC
...               increase_timeout_for_update_sw=${1800}
Suite Teardown    Custom Suite Teardown

Test Setup        Test Setup With UE
Test Teardown     Common Postconditions With Watching Alarms

*** Test Cases ***
[1][1.0] [5]5GC001937_SA_TC5_SFE_LTE_LTE_EN-DC_THROUGHPUT
    Perform UE Attach in Loop
    Validate Correct Values of PM Counters for SCell Additions

[1][1.0] [14]5GC001937_SA_TC14_SFE_NR_MEASUREMENTS
    Select Beams For Test
    Validate Beam Usage PM Counters
