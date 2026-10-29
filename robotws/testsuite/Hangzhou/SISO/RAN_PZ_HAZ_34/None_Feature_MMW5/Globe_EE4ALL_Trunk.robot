# @Time    : 2026/2/9 19:21
# @Author  : Chun.li
# @Email   : chun.li@nokia.com
# @File    : Globe_EE4ALL_Trunk.robot
# @Software: PyCharm
# @Doc     : ESM Measurement with KPI for Globe
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia.com
...    Team: RAN RD VRF HAZ 7
...    Feature: EE4ALL - ESM Measurement with KPI for Globe

#Suite Setup       SISO Coam Suite Setup
#Suite Teardown    SISO Coam Suite Teardown
Test Setup        MMW5 Common Case Setup
Test Teardown     MMW5 Common Case Teardown
#Force Tags        CRT_TRUNK

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    taf/rfrl/procedures/SISO/ESM/resources/ESM.robot

*** Variables ***
${report_kpi}    True
#${measurment_duration}    120
${test_states}    OnAirBefore,ESM1,OnAirAfter
${configuration_yaml_file}    ${CURDIR}/Resources/esm_configuration.yaml


*** Test Cases ***
E2E_TL_ESM_Measurement_with_KPI
#    Connect to gnb coam via ssl
    Run ESM Measurement Procedure
    ...    connection=GNB_OAM
    ...    configuration_yaml_file=${configuration_yaml_file}
    ...    test_states=${test_states}
#    ...    measurment_duration=${measurment_duration}
    ...    report_kpi=${report_kpi}

#    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections
