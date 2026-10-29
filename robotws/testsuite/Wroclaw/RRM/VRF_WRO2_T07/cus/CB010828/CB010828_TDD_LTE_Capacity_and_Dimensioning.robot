*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_setup.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_teardown.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_run.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

*** Test Cases ***

CB010828_LTE_TDD_ASOE_capacity_with_Cell_Trace
    [Tags]  SKIP_REPORT
    Run Suite 'CB010828_TDD_LTE_Capacity_and_Dimensioning/test_LTE_TDD_ASOE_capacity_with_Cell_Trace.py'
