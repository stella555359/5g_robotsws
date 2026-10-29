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

LTE2084_ue_mac_meas_addition_to_cell_trace_bsr
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_bsr.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_partial_act
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_partial_act.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_pdsch_prb
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_pdsch_prb.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_pusch_prb
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_pusch_prb.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_remove_mtrace
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_remove_mtrace.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_restart_cell_block
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_restart_cell_block.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_restart_flag
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_restart_flag.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_restart_site_reset
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_restart_site_reset.py'
LTE2084_ue_mac_meas_addition_to_cell_trace_ri
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte2084_ue_mac_meas_addition_to_cell_trace_ri.py'
