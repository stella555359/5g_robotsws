*** Settings ***
Documentation
...    Author: shifu.lan@nokia-sbell.com
...    Team group: VRF_HAZ4_T04
...    Feature CNI-146617 in trunk program

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         36h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_Module_Stability_Run.robot

Force Tags    HAZ4_T04


*** Test Cases ***
[1]CNI-146617_General_SiSo_Auto_RF_Module_Stability_Run
    ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    ${testline_name}    Get Testline Name
    ${ru_index}    Set variable If    '${testline_name}'=='7_5_UTE5G402T572'    ${2}    ${1}
    Log    message=\nRun stability testing on RU-${ru_index}
    General_SiSo_RF_Module_Stability_Run    ru_index=${ru_index}
