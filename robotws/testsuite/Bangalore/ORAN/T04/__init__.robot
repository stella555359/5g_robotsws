*** Settings ***
Documentation       Suite for all CIT executions.

Library             OperatingSystem    WITH NAME    os


Suite Setup         Suite Preconditions
Suite Teardown      Suite Postconditions


*** Keywords ***
Suite Preconditions
    Log To Console    Suite Preconditions started

Suite Postconditions
    Log To Console    suite_teardown
