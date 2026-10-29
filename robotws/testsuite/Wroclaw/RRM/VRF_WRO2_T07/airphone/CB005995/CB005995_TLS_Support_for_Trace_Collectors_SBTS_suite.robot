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

CB005995_activation_of_TLS_according_to_TCE_settings
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_activation_of_TLS_according_to_TCE_settings.py'
CB005995_activation_of_tls_for_already_configured_trace_session
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_activation_of_tls_for_already_configured_trace_session.py'
CB005995_activation_of_TLS_with_fallback_to_TLS_1_2
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_activation_of_TLS_with_fallback_to_TLS_1_2.py'
CB005995_activation_of_TLS_without_fallback_to_plain_text
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_activation_of_TLS_without_fallback_to_plain_text.py'
CB005995_activation_of_trace_session_for_new_DU_resource
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_activation_of_trace_session_for_new_DU_resource.py'
CB005995_modification_of_tls_connection_param_used_by_trace_session
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_modification_of_tls_connection_param_used_by_trace_session.py'
CB005995_trace_connection_interruption_for_ongoing_trace_session
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_trace_connection_interruption_for_ongoing_trace_session.py'
CB005995_unsuccessful_activation_of_tls_missing_certificate_and_crl
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_unsuccessful_activation_of_tls_missing_certificate_and_crl.py'
CB005995_unsuccessful_activation_of_tls_revoked_certificate
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASIL/test_CB005995_unsuccessful_activation_of_tls_revoked_certificate.py'
CB005995_activation_of_trace_session_for_new_cell_resource
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASOH/test_CB005995_activation_of_trace_session_for_new_cell_resource.py'
CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASOH/test_CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact.py'
CB005995_trace_connection_failure_for_new_trace_session
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/ASOH/test_CB005995_trace_connection_failure_for_new_trace_session.py'
