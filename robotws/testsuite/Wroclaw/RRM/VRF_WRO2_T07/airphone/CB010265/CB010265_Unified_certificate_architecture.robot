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

CB010265_RSA_ECSDA_certificates_used_when_PCMD_with_TLS_is_activated
    [Tags]  SKIP_REPORT
    Run Suite 'CB010265_Unified_certificate_architecture/test_CB010265_RSA_ECSDA_certificates_used_when_PCMD_with_TLS_is_activated.py'
