*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***
*** Test Cases ***
Test Collect Config Files For GNB
    [Tags]    gnb
    ${log_path}=    Get Current Testline Config Files For GNB    ${OUTPUT_DIR}/myconfigs/

Test Collect Config Files For Airphone
    [Tags]    ap
    ${log_path}=    Get Current Testline Config Files For AP    ${OUTPUT_DIR}/myconfigs/

*** Keywords ***
