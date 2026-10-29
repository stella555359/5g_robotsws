*** Settings ***
Documentation
...  Test Suite Author: Mateusz Chryplewicz
...  Test Suite Owner: Mateusz Chryplewicz
...  Team: T01

Resource    ../../../test_resources/BS-RF/SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.robot



*** Variables ***
${HW_LOCATION_CODE}      Wroclaw
${TESTLINE_NAME}    10_16_UTESRANSISO136
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${COMMISSIONING_PATH}   /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO136_PM.xml

*** Test Cases ***
[1][2.0] Automated_SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
    ...  AND  Set Test Variable  ${RMOD_SN}   K9245128883
#    ...  AND  Set Test Variable  ${EXTENDED_SLEEP_TIME}  10
    ...  AND  Set Test Variable  ${SKIP_5G}  True
    ...  AND  Set Test Variable  ${LTE_CELL_ID}      54
    ...  AND  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Setup
    ...  AND  Set Library Search Order    SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Timeout]  14400
    TC__SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Teardown]  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Teardown
