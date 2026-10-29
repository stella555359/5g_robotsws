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

LTE163_subscriber_trace_6261_trace_connection_faulty_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_6261_trace_connection_faulty_3rdparty.py'
LTE163_subscriber_trace_6263_trace_session_failure
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_6263_trace_session_failure.py'
LTE163_subscriber_trace_failed_session_with_x2_ho
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_failed_session_with_x2_ho.py'
LTE163_subscriber_trace_intra_cell_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_intra_cell_handover.py'
LTE163_subscriber_trace_max_number_of_traced_ues
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_max_number_of_traced_ues.py'
LTE163_subscriber_trace_start_stop_ioms_and_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_start_stop_ioms_and_3rdparty.py'
LTE163_subscriber_trace_ue_intra_enb_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_ue_intra_enb_handover.py'
LTE163_subscriber_trace_ue_x2_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_ue_x2_handover.py'
LTE163_subscriber_trace_vendor_specific_tracing
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_vendor_specific_tracing.py'
LTE163_subscriber_trace_with_cell_trace
    [Tags]  SKIP_REPORT
    Run Suite 'LTE163_Subscriber_Trace/test_cpln_lte163_subscriber_trace_with_cell_trace.py'
