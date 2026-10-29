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

LTE4087_x2_interface_with_nr_gnb_successful_x2_link_establishment_it
    [Tags]  SKIP_REPORT
    Run Suite 'LTE4087_X2_interface_with_NR_gNB/test_cpln_lte4087_x2_interface_with_nr_gnb_successful_x2_link_establishment_it.py'
LTE4087_x2_interface_with_nr_gnb_x2_link_failure_it
    [Tags]  SKIP_REPORT
    Run Suite 'LTE4087_X2_interface_with_NR_gNB/test_cpln_lte4087_x2_interface_with_nr_gnb_x2_link_failure_it.py'
