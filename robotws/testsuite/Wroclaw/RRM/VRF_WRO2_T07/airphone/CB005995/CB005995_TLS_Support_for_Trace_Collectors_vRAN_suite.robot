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

CB005995_activation_of_TLS_with_fallback_to_TLS_1_2_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vCU/test_CB005995_activation_of_TLS_with_fallback_to_TLS_1_2_vcu.py'
CB005995_activation_of_TLS_without_fallback_to_plain_text_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vCU/test_CB005995_activation_of_TLS_without_fallback_to_plain_text_vcu.py'
CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vCU/test_CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact_vcu.py'
CB005995_trace_connection_interruption_for_ongoing_trace_session_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vCU/test_CB005995_trace_connection_interruption_for_ongoing_trace_session_vcu.py'
CB005995_unsuccessful_activation_of_tls_missing_certificate_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vCU/test_CB005995_unsuccessful_activation_of_tls_missing_certificate_vcu.py'
CB005995_activation_of_TLS_with_fallback_to_TLS_1_2_vdu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vDU/test_CB005995_activation_of_TLS_with_fallback_to_TLS_1_2_vdu.py'
CB005995_activation_of_TLS_without_fallback_to_plain_text_vdu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vDU/test_CB005995_activation_of_TLS_without_fallback_to_plain_text_vdu.py'
CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact_vdu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vDU/test_CB005995_TLS_1_3_enabled_during_Cell_Trace_and_PCMD_act_and_deact_vdu.py'
CB005995_trace_connection_interruption_for_ongoing_trace_session_vdu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vDU/test_CB005995_trace_connection_interruption_for_ongoing_trace_session_vdu.py'
CB005995_unsuccessful_activation_of_tls_missing_certificate_vdu
    [Tags]  SKIP_REPORT
    Run Suite 'CB005995_TLS_Support_for_Trace_collectors/vDU/test_CB005995_unsuccessful_activation_of_tls_missing_certificate_vdu.py'
