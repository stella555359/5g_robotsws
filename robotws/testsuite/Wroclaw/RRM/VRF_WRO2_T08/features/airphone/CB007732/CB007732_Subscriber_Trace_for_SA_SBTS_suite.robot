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

CB007732_Deactivation_of_TLS_during_SBA_TRS_for_default_TCE
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Deactivation_of_TLS_during_SBA_TRS_for_default_TCE.py'
CB007732_Deactivation_of_TLS_during_SBA_TRS_for_non_special_TCE
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Deactivation_of_TLS_during_SBA_TRS_for_non_special_TCE.py'
CB007732_Modification_of_TCP_connection_towards_default_TCE_ongoing_SBA_TRS
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Modification_of_TCP_connection_towards_default_TCE_ongoing_SBA_TRS.py'
CB007732_Modification_of_TCP_connection_towards_non_special_TCE_ongoing_SBA_TRS
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Modification_of_TCP_connection_towards_non_special_TCE_ongoing_SBA_TRS.py'
CB007732_Reconfiguration_of_TCE_to_enable_TLS_MBA_SBA_TRS_default_TCE
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Reconfiguration_of_TCE_to_enable_TLS_MBA_SBA_TRS_default_TCE.py'
CB007732_Reporting_of_SBA_TRS_to_default_TCE_with_TLS
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Reporting_of_SBA_TRS_to_default_TCE_with_TLS.py'
CB007732_Reporting_of_SBA_TRS_to_default_TCE_without_TLS_and_non_special_TCE_with_TLS
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Reporting_of_SBA_TRS_to_default_TCE_without_TLS_and_non_special_TCE_with_TLS.py'
CB007732_Reporting_of_SBA_TRS_to_non_special_TCE_with_TLS
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Reporting_of_SBA_TRS_to_non_special_TCE_with_TLS.py'
CB007732_Unsuccessful_reporting_of_SBA_TRS_caused_by_TLS_error
    [Tags]  SKIP_REPORT
    Run Suite 'CB007732_Subscriber_Trace_for_SA/SBTS/test_CB007732_Unsuccessful_reporting_of_SBA_TRS_caused_by_TLS_error.py'
