*** Settings ***
Documentation    CB009556 RU-diagnostics part 5
...              author:        Patryk Wojcik
...              maintainer:    Patryk Wojcik
...              contact:       patryk.wojcik@nokia.com
...              The purpose of test suite is to test RF Diagnostic Tests and Antenna Line Online Monitoring.
...              The test suite will check the presentation of data when one RU is blocked and unblocked.
...              There are as well scenarios to verify the values of RTWP and ETP during Antenna Line Online
...              Monitoring/RF Diagnostic Test with and without data transfer.

Library          taf.selenium.sbts    WITH NAME    Selenium_sbts
Resource         ./resources/CB009556_resources.robot

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
Suite Teardown  Common Suite Teardown

Test Setup      Preconditions for CB009556
Test Teardown   Postconditions for CB009556

*** Test Cases ***
CB009556_C_Presentation_of_not_available_values_of_RF_measurements_in_WebEM_GUI_CPRI_gen1
    Selenium_sbts.block_cell    cell_idx=${0}    technology=LTE
    Log to console    \nCell blocked
    Selenium_sbts.Select Antenna Lines For Monitoring
    Antenna Line Monitoring Test
    ${RTWP_blocked}    Selenium_sbts.get_monitored_values    value_type=RTWP
    ${ETP_blocked}     Selenium_sbts.get_monitored_values    value_type=ETP
    Verify values from Antenna Online Monitoring    ${RTWP_blocked}    ${0}
    Verify values from Antenna Online Monitoring    ${ETP_blocked}     ${0}

    Selenium_sbts.unblock_cell    cell_idx=${0}    technology=LTE
    Log to console    \nCell unblocked
    Antenna Line Monitoring Test
    ${RTWP_unblocked}    Selenium_sbts.get_monitored_values    value_type=RTWP
    ${ETP_unblocked}     Selenium_sbts.get_monitored_values    value_type=ETP
    Verify values from Antenna Online Monitoring    ${RTWP_unblocked}   ${0}   -105
    Verify values from Antenna Online Monitoring    ${ETP_unblocked}    ${0}     25
    [Teardown]    Postconditions for CB009556   Postconditions_ForUE=${False}

CB009556_A_RTWP_in_Antenna_Line_Online_Monitoring_CPRI_gen1
    Change parameter qrxlevmin to -120 on cell-0
    Change parameter qrxlevmin to -120 on cell-1

    Selenium_sbts.Select Antenna Lines For Monitoring
    Antenna Line Monitoring Test
    ${RTWP_without_traffic}    Selenium_sbts.get_monitored_values    value_type=RTWP
    ${ETP_without_traffic}     Selenium_sbts.get_monitored_values    value_type=ETP
    Verify values from Antenna Online Monitoring    ${ETP_without_traffic}    ${0}    25
    Verify values from Antenna Online Monitoring    ${RTWP_without_traffic}   ${0}   -105
    Verify values from Antenna Online Monitoring    ${ETP_without_traffic}    ${2}    25
    Verify values from Antenna Online Monitoring    ${RTWP_without_traffic}   ${2}   -105

    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=300
    ...    dl_throughput=300M
    Antenna Line Monitoring Test
    ${RTWP_with_traffic}    Selenium_sbts.get_monitored_values    value_type=RTWP
    ${ETP_with_traffic}     Selenium_sbts.get_monitored_values    value_type=ETP
    Verify values from Antenna Online Monitoring    ${ETP_without_traffic}    ${0}    25
    Verify values from Antenna Online Monitoring    ${ETP_without_traffic}    ${2}    25
    Compare rtwps from antenna line online monitoring    ${RTWP_without_traffic}    ${RTWP_with_traffic}

CB009556_B_ETP_in_RF_diagnostic_test_LTE_CPRI_gen1
    Change parameter qrxlevmin to -120 on cell-0
    Change parameter qrxlevmin to -120 on cell-1

    Selenium_sbts.configure_rf_diagnostic_test    technology=LTE    cell=All LTE cells
    Selenium_sbts.start rf diagnostic test
    Log to console    \nStarted RF Diagnostic Test
    ${general_without_traffic}    Selenium_sbts.get_general_test_information            cell_id=LNCEL-1 (A1NSH841LCL021)
    ${detailed_without_traffic}   Selenium_sbts.get_detailed_result_for_each_antenna    cell_id=LNCEL-1 (A1NSH841LCL021)
    Verify general values from RF Diagnostic Test    ${general_without_traffic}     14
    Verify detailed values from RF Diagnostic Test   ${detailed_without_traffic}    14
    Selenium_sbts.clear_finished_results

    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=300
    ...    dl_throughput=300M
    Selenium_sbts.configure_rf_diagnostic_test    technology=LTE    cell=All LTE cells
    Selenium_sbts.start rf diagnostic test
    Log to console    \nStarted RF Diagnostic Test
    ${general_with_traffic}    Selenium_sbts.get_general_test_information            cell_id=LNCEL-1 (A1NSH841LCL021)
    ${detailed_with_traffic}   Selenium_sbts.get_detailed_result_for_each_antenna    cell_id=LNCEL-1 (A1NSH841LCL021)
    Verify general values from RF Diagnostic Test     ${general_with_traffic}    14
    Verify detailed values from RF Diagnostic Test    ${detailed_with_traffic}   14
    Compare RTWPs from RF Diagnostic Tests    ${detailed_without_traffic}    ${detailed_with_traffic}
    Selenium_sbts.clear_finished_results
