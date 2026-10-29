*** Settings ***
Documentation
...    :copyright: Nokia
...    :author: VRF_WRO2_T07_03
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_setup.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_teardown.robot
Resource    ${CURDIR}${/}..${/}..${/}resources_btc/suite_run.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

*** Test Cases ***

CB006542_activation_of_SBA_TRS_via_NSETAP-X_extUeTraceRep_true_same_IP
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_SBA_TRS_via_NSETAP-X_extUeTraceRep_true_same_IP.py'
CB006542_activation_of_SBA_TRS_via_NSETAP-X_with_Cell_Trace_via_NSNTI_PCMD_via_NSETAP
    [Tags]  SKIP_REPORT
    Run Suite
    ...    'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_SBA_TRS_via_NSETAP-X_with_Cell_Trace_via_NSNTI_PCMD_via_NSETAP.py'
CB006542_activation_of_SBA_TRS_via_NSETAP-X_with_Cell_Trace_and_PCMD_via_NSETAP
    [Tags]  SKIP_REPORT
    Run Suite
    ...    'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_SBA_TRS_via_NSETAP-X_with_Cell_Trace_and_PCMD_via_NSETAP.py'
CB006542_activation_of_Subscriber_Trace_via_NSNTI_extUeTraceRep_true_different_IPs
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_Subscriber_Trace_via_NSNTI_extUeTraceRep_true_different_IPs.py'
CB006542_activation_of_TLS_for_Subscriber_Trace_with_NSETAP-X_and_extUeTraceRep_false
    [Tags]  SKIP_REPORT
    Run Suite
    ...    'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_TLS_for_Subscriber_Trace_with_NSETAP-X_and_extUeTraceRep_false.py'
CB006542_activation_of_TLS_for_Subscriber_Trace_with_NSETAP-X_and_extUeTraceRep_true
    [Tags]  SKIP_REPORT
    Run Suite
    ...    'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_activation_of_TLS_for_Subscriber_Trace_with_NSETAP-X_and_extUeTraceRep_true.py'
CB006542_Deactivation_of_LTE_Subscriber_Trace_via_NSETAP-X_interface
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Deactivation_of_LTE_Subscriber_Trace_via_NSETAP-X_interface.py'
CB006542_SBA_TRS_during_intra_eNB_handover_extUeTraceRep_true_different_Ips
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_SBA_TRS_during_intra_eNB_handover_extUeTraceRep_true_different_Ips.py'
CB006542_Subscriber_Trace_via_NSETAP-X_during_S1_handover
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_during_S1_handover.py'
CB006542_Subscriber_Trace_via_NSETAP-X_during_X2_handover
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_during_X2_handover.py'
CB006542_Subscriber_Trace_via_NSETAP-X_remaining_protocol_messages
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_remaining_protocol_messages.py'
CB006542_Trace_Records_amount_in_Report_msgs_extUeTraceRep_true_and_false_special_TCE_IP
    [Tags]  SKIP_REPORT
    ${tc_name}=  Catenate  SEPARATOR=
    ...    CB006542_LTE_Subscriber_Trace_over_NSETAP/
    ...    test_CB006542_Trace_Records_amount_in_Report_msgs_extUeTraceRep_true_and_false_special_TCE_IP.py
    Run Suite '${tc_name}'
CB006542_Subscriber_Trace_via_NSETAP-X_UE_context_modification_and_release
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_UE_context_modification_and_release.py'
CB006542_SBA_TRS_via_NSETAP-X_with_MAC_TA_and_E-RAB_operations
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_SBA_TRS_via_NSETAP-X_with_MAC_TA_and_E-RAB_operations.py'
CB006542_Subscriber_Trace_via_NSETAP-X_with_Immediate_MDT
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_with_Immediate_MDT.py'
CB006542_Subscriber_Trace_via_NSETAP-X_with_multiple_connection_and_session_failures
    [Tags]  SKIP_REPORT
    Run Suite
    ...    'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_with_multiple_connection_and_session_failures.py'
CB006542_Subscriber_Trace_via_NSETAP-X_with_RLF_reports
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_with_RLF_reports.py'
CB006542_Subscriber_Trace_via_NSETAP-X_UE_reestablishment
    [Tags]  SKIP_REPORT
    Run Suite 'CB006542_LTE_Subscriber_Trace_over_NSETAP/test_CB006542_Subscriber_Trace_via_NSETAP-X_UE_reestablishment.py'
