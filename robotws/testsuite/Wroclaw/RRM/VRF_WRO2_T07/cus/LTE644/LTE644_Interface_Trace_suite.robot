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

LTE644_Interface_Trace_6261_trace_connection_faulty_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_6261_trace_connection_faulty_3rdparty.py'
LTE644_Interface_Trace_6263_trace_session_failure
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_6263_trace_session_failure.py'
LTE644_Interface_Trace_max_number_of_traced_ues
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_max_number_of_traced_ues.py'
LTE644_Interface_Trace_single_protocol_trace_mac
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_single_protocol_trace_mac.py'
LTE644_Interface_Trace_single_protocol_trace_rrc
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_single_protocol_trace_rrc.py'
LTE644_Interface_Trace_single_protocol_trace_s1
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_single_protocol_trace_s1.py'
LTE644_Interface_Trace_single_protocol_trace_x2
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_single_protocol_trace_x2.py'
LTE644_Interface_Trace_start_stop_ioms_and_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_start_stop_ioms_and_3rdparty.py'
LTE644_Interface_Trace_tracing_of_specific_messages
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_tracing_of_specific_messages.py'
LTE644_Interface_Trace_ue_inter_cell_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_ue_inter_cell_handover.py'
LTE644_Interface_Trace_ue_intra_cell_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_ue_intra_cell_handover.py'
LTE644_Interface_Trace_ue_x2_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_ue_x2_handover.py'
LTE644_Interface_Trace_with_cell_trace
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Interface_Trace/test_cpln_lte644_interface_trace_with_cell_trace.py'
