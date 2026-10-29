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

LTE1501_immediate_mdt_activation_and_deactivation
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_activation_and_deactivation.py'
LTE1501_immediate_mdt_and_trace_instantaneous_ta
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_and_trace_instantaneous_ta.py'
LTE1501_immediate_mdt_and_trace_interface_trace
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_and_trace_interface_trace.py'
LTE1501_immediate_mdt_and_trace_ue_consent_no_mdt
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_and_trace_ue_consent_no_mdt.py'
LTE1501_immediate_mdt_and_trace_ue_ho_fail
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_and_trace_ue_ho_fail.py'
LTE1501_immediate_mdt_InstantaneousTA_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_InstantaneousTA_measurement.py'
LTE1501_immediate_mdt_limitation_of_max_active_mdt_ues
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_limitation_of_max_active_mdt_ues.py'
LTE1501_immediate_mdt_phr_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_phr_measurement.py'
LTE1501_immediate_mdt_rip_alarming
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_rip_alarming.py'
LTE1501_immediate_mdt_rip_prb_subframe_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_rip_prb_subframe_measurement.py'
LTE1501_immediate_mdt_rip_subframe_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_rip_subframe_measurement.py'
LTE1501_immediate_mdt_ta_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ta_measurement.py'
LTE1501_immediate_mdt_ue_consent_reesta_inter_ho
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_consent_reesta_inter_ho.py'
LTE1501_immediate_mdt_ue_consent_s1_x2_ho
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_consent_s1_x2_ho.py'
LTE1501_immediate_mdt_ue_ho_fail
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_ho_fail.py'
LTE1501_immediate_mdt_ue_intra_cell_ho
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_intra_cell_ho.py'
LTE1501_immediate_mdt_ue_reestablishment_imm_and_trace
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_reestablishment_imm_and_trace.py'
LTE1501_immediate_mdt_ue_reestablishment_imm_only
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_reestablishment_imm_only.py'
LTE1501_immediate_mdt_ue_rlf_imm_and_trace
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_rlf_imm_and_trace.py'
LTE1501_immediate_mdt_ue_rlf_imm_only
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_rlf_imm_only.py'
LTE1501_immediate_mdt_ue_s1_ho
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_s1_ho.py'
LTE1501_immediate_mdt_ue_x2_ho
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ue_x2_ho.py'
LTE1501_immediate_mdt_ulsinr_measurement
    [Tags]  SKIP_REPORT
    Run Suite 'immediate_mdt/test_lte1501_immediate_mdt_ulsinr_measurement.py'
