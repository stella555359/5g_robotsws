*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ../../../../VRF_WRO2_T07/resources_btc/suite_setup.robot
Resource    ../../../../VRF_WRO2_T07/resources_btc/suite_teardown.robot
Resource    ../../../../VRF_WRO2_T07/resources_btc/suite_run.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

*** Test Cases ***

CB007732_Deactivation_of_TLS_during_SBA_TRS_for_default_TCE_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Deactivation_of_TLS_during_SBA_TRS_for_default_TCE_vcu.py'
CB007732_Deactivation_of_TLS_during_SBA_TRS_for_non_special_TCE_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Deactivation_of_TLS_during_SBA_TRS_for_non_special_TCE_vcu.py'
CB007732_Modification_of_TCP_connection_towards_default_TCE_ongoing_SBA_TRS_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Modification_of_TCP_connection_towards_default_TCE_ongoing_SBA_TRS_vcu.py'
CB007732_Modification_of_TCP_connection_towards_non_special_TCE_ongoing_SBA_TRS_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Modification_of_TCP_connection_towards_non_special_TCE_ongoing_SBA_TRS_vcu.py'
CB007732_Reconfiguration_of_TCE_to_enable_TLS_MBA_SBA_TRS_default_TCE_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Reconfiguration_of_TCE_to_enable_TLS_MBA_SBA_TRS_default_TCE_vcu.py'
CB007732_Reporting_of_SBA_TRS_to_default_TCE_with_TLS_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Reporting_of_SBA_TRS_to_default_TCE_with_TLS_vcu.py'
CB007732_Reporting_of_SBA_TRS_to_default_TCE_without_TLS_and_non_special_TCE_with_TLS_vcu
    [Tags]  SKIP_REPORT
    ${tc_name}=  Catenate  SEPARATOR=
    ...  CB007732_Subscriber_Trace_for_SA/vRAN/
    ...  test_CB007732_Reporting_of_SBA_TRS_to_default_TCE_without_TLS_and_non_special_TCE_with_TLS_vcu.py
    Run Suite '${tc_name}'
CB007732_Reporting_of_SBA_TRS_to_non_special_TCE_with_TLS_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Reporting_of_SBA_TRS_to_non_special_TCE_with_TLS_vcu.py'
CB007732_Unsuccessful_reporting_of_SBA_TRS_caused_by_TLS_error_vcu
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/vRAN/test_CB007732_Unsuccessful_reporting_of_SBA_TRS_caused_by_TLS_error_vcu.py'
