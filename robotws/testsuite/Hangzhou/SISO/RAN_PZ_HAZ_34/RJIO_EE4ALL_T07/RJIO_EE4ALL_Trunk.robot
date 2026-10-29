*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia.com
...    squad group: RAN RD VRF HAZ 7
...    Feature: EE4ALL - ESM Measurement with KPI for RJIO


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    taf/rfrl/procedures/SISO/ESM/resources/ESM.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot


Suite Setup    Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${report_kpi}    True
${measurement_duration}    4500
${test_states}    OnAirBefore,ESM1,ESM2,OnAirAfter
${configuration_yaml_file}    ${CURDIR}/Resources/esm_configuration.yaml


*** Test Cases ***
[1]EE4ALL_KPI_MEASUREMENT_TEST
    [Setup]    robot_common_operations.Common Case Setup
    Connect to gnb coam via ssl
    Run ESM Measurement Procedure
    ...    connection=GNB_OAM
    ...    configuration_yaml_file=${configuration_yaml_file}
    ...    test_states=${test_states}
    ...    measurement_duration=${measurement_duration}
    ...    report_kpi=${report_kpi}
    [Teardown]    case teardown



*** Keywords ***
Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

case teardown
    robot_common_operations.Common case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    CI interface.Common Case Teardown
