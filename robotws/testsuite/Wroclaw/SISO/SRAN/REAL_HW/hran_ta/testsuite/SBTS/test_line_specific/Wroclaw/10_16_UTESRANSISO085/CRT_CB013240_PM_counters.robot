*** Settings ***
Documentation
...  Test Suite Author: Zuzanna Adles
...  Test Suite Owner: Zuzanna Adles
...  Team: T05

Resource    ../../../test_resources/BS-RF/SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.robot

*** Variables ***
${HW_LOCATION_CODE}      Wroclaw
${TESTLINE_NAME}    10_16_UTESRANSISO085
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${COMMISSIONING_PATH}  /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO085_PM_COUNTERS_AHFIB_AHFII.xml

*** Test Cases ***
[1][2.0] Automated_SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
    ...  AND  Set Test Variable  ${RMOD_SN}  BL2221N405O,K9180124579
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  36910,36901
    ...  AND  Set Test Variable  ${5G_CELL_ID}  36927,36928
    ...  AND  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Setup
    ...  AND  Set Library Search Order    SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Timeout]  14400
    TC__SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Teardown]  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Teardown
