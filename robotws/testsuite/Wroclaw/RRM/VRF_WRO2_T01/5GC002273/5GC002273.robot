*** Settings ***
Documentation  Test Suite for 5GC002273 feature.
...            Topology: CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU -> T177

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002273/resources/test_2273.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot

Test Teardown    Add Scout Data Info To Testcase

*** Test Cases ***
[1]5GC002273_AH_A02_EIRP_measurement_of_broadcasted_single_cell_segment_multiple_broadcast_beams_beamset2
    [1]5GC002273_AH_A02_EIRP_measurement_of_broadcasted_single_cell_segment_multiple_broadcast_beams_beamset2
