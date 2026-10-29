*** Settings ***
Resource    ../../common_setup_teardown.robot

*** Test Cases ***
Capture TTItrace Log
    Run    rm -rf ${OUTPUT_DIR}/ttitrace_streaming/*
    Capture Convert Format Ttitrace With Streaming Mode    ${time}    log_dir=${OUTPUT_DIR}/ttitrace_streaming

