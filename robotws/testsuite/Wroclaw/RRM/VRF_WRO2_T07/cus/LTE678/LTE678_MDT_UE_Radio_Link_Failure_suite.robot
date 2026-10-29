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

LTE678_ue_rlf_rrcestablishment_it_rlfreportsonly
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcestablishment_it_rlfreportsonly.py'
LTE678_ue_rlf_rrcestablishment_it_traceonly
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcestablishment_it_traceonly.py'
LTE678_ue_rlf_rrcreconfiguration_ct_rlfreportsonly
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcreconfiguration_ct_rlfreportsonly.py'
LTE678_ue_rlf_rrcreconfiguration_immAndTrace
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcreconfiguration_immAndTrace.py'
LTE678_ue_rlf_rrcreestablishment_ct_trace_rlfreports
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcreestablishment_ct_trace_rlfreports.py'
LTE678_ue_rlf_rrcreestablishment_ct_traceonly
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcreestablishment_ct_traceonly.py'
LTE678_ue_rlf_rrcreestablishment_ct_x2
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_rrcreestablishment_ct_x2.py'
LTE678_ue_rlf_subscriber_rlfreportsonly
    [Tags]  SKIP_REPORT
    Run Suite 'LTE678_MDT_UE_Radio_Link_Failure/test_lte678_ue_rlf_subscriber_rlfreportsonly.py'
