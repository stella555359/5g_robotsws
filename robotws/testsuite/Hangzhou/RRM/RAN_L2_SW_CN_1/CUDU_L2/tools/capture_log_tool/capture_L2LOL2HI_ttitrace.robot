*** Settings ***
Resource    ../../common_setup_teardown.robot

*** Test Cases ***
Capture L2LOL2HI TTItrace Log
    Capture Convert L2LOL2HI Ttitrace With Streaming Mode    ${time}    log_dir=${OUTPUT_DIR}/ttitrace_streaming