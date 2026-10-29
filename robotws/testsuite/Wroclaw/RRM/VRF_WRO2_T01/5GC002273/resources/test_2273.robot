*** Settings ***
Documentation  Test Cases implementation for feature 5GC002273. Code is rewritten based on original to allign with new
...            test line.

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002273/resources/keywords.robot

*** Keywords ***
[1]5GC002273_AH_A02_EIRP_measurement_of_broadcasted_single_cell_segment_multiple_broadcast_beams_beamset2
    Perform 5GC002273 commissioning

    Wait for counter interval
    ${counter1_before}  Get M55324C00101 counter
    ${counter2_before}  Get M55324C00400 counter

    check_counters_are_zero  ${counter1_before}
    check_counters_are_zero  ${counter2_before}

    Activate feature
    Wait for counter interval
    ${counter1_after}  Get M55324C00101 counter
    ${counter2_after}  Get M55324C00400 counter

    check_counters_are_greater_than_zero  ${counter1_after}
    check_counters_are_greater_than_zero  ${counter2_after}
