*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***
*** Test Cases ***
Test collect all config files
    ${log_path}=    Get Current Testline Config Files    ${OUTPUT_DIR}/myconfigs/
#    Recover Config Files To Testline    ${log_path}
*** Keywords ***
