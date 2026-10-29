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

LTE644_Cell_Trace_6261_trace_connection_faulty_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_6261_trace_connection_faulty_3rdparty.py'
LTE644_Cell_Trace_6263_trace_session_failure
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_6263_trace_session_failure.py'
LTE644_Cell_Trace_max_number_of_traced_ues
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_max_number_of_traced_ues.py'
LTE644_Cell_Trace_start_stop_ioms_and_3rdparty
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_start_stop_ioms_and_3rdparty.py'
LTE644_Cell_Trace_ue_ho_fail
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_ue_ho_fail.py'
LTE644_Cell_Trace_ue_intra_cell_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_ue_intra_cell_handover.py'
LTE644_Cell_Trace_ue_paging
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_ue_paging.py'
LTE644_Cell_Trace_ue_rlf_tracing
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_ue_rlf_tracing.py'
LTE644_Cell_Trace_ue_x2_handover
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_ue_x2_handover.py'
LTE644_Cell_Trace_vendor_specific_tracing
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_vendor_specific_tracing.py'
LTE644_Cell_Trace_with_imsi
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte644_cell_trace_with_imsi.py'
LTE644_Cell_Trace_lte2199_2_ct_session_different_buffering_time
    [Tags]  SKIP_REPORT
    Run Suite 'LTE644_Cell_Trace/test_cpln_lte2199_2_ct_session_different_buffering_time.py'
