*** Settings ***
Documentation  Test suite for CNI-133587 test case. It is located in CB006877 directory due to relation with this
...            feature. It is just extension for an ABIL board.
...            Topology -> CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_AHFIB_3xAHLOA_20B -> S041

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB006877/resources/tests_cni.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot

Test Teardown    Add Scout Data Info To Testcase

*** Test Cases ***
CNI-133487_A1_TC_01_SA_Dynamic_UL_resource_allocation_counters_FT_ON_vs_FT_OFF_15MHz
    CNI-133487_A1_TC_01_SA_Dynamic_UL_resource_allocation_counters_FT_ON_vs_FT_OFF_15MHz
