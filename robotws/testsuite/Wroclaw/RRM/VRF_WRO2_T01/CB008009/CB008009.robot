*** Settings ***
Documentation
...  author:     Paweł Wiśniewski
...  contact:    pawel.1.wisniewski@nokia.com
...  Description:   Test Cases for CB008009 A feature. Test Suite was created due to BEP 04286263 action. Because of
...                 TMO pronto we changed CB008009-A test case and now it benchmarks counters with feature parameter
...                 on and off. Also additional counter was added to test scenario. Customer test line is prefered for
...                 execution.
...  Topology:  CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU -> T177

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008009/resources/tests_8009.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot


Test Setup  run keywords
...  Get UEs  ${ues}  S25  AND
...  Start syslog capture

Test Teardown  run keywords
...      Stop syslog capture                 AND
...      Add Scout Data Info To Testcase     AND
...      Collect snapshot if test failed

*** Test Cases ***
[1]CB008009-B_6_UL_throughput_Time_counter_modification_on_SA
    [Tags]  8009  b6
    [1]CB008009-B_6_UL_throughput_Time_counter_modification_on_SA
