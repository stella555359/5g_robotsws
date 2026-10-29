*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults TC

Resource  ../test_resources/WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults.robot


*** Test Cases ***
WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Teardown]  TC Teardown
