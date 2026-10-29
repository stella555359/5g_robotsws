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

CB008254_Reconfiguration_of_RSA_ECDSA_certificate_support_for_TLS_5G_Cell_Trace_and_PCMD
    [Tags]  SKIP_REPORT
    ${tc1_name}=  Catenate  SEPARATOR=
    ...  CB008254_RSA_and_EC_certificate_support_for_TLS/
    ...  test_CB008254_Reconfiguration_of_RSA_ECDSA_certificate_support_for_TLS_5G_Cell_Trace_and_PCMD.py
    Run Suite '${tc1_name}'
CB008254_Successful_TLS_conn_using_RSA_and_ECDSA_certificates_MBA_SBA_TRS_same_UE
    [Tags]  SKIP_REPORT
    ${tc2_name}=  Catenate  SEPARATOR=
    ...  CB008254_RSA_and_EC_certificate_support_for_TLS/
    ...  test_CB008254_Successful_TLS_conn_using_RSA_and_ECDSA_certificates_MBA_SBA_TRS_same_UE.py
    Run Suite '${tc2_name}'
CB008254_Successful_TLS_connections_using_RSA_and_ECDSA_certificates_SBA_different_UEs
    [Tags]  SKIP_REPORT
    ${tc3_name}=  Catenate  SEPARATOR=
    ...  CB008254_RSA_and_EC_certificate_support_for_TLS/
    ...  test_CB008254_Successful_TLS_connections_using_RSA_and_ECDSA_certificates_SBA_different_UEs.py
    Run Suite '${tc3_name}'
