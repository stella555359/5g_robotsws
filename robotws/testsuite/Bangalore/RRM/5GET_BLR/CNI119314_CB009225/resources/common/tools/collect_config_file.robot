*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com
Resource    ./../common_setup_teardown.robot

*** Test Cases ***
Test collect all config files
    ${log_path}=    Get Current Testline Config Files    ${OUTPUT_DIR}/myconfigs/
#    Recover Config Files To Testline    ${log_path}

