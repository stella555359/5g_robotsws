*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
...    feature about sherpa:5GC001808
Resource    ./../common_setup_teardown.robot
*** Variables ***
${LOG}    syslog,tti,sherpa,bip,sosreport,apbip,
${LOG_PATH}    ${OUTPUT_DIR}/mylog/
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Catch Sherpa Log
    [Tags]    case1
    Start Sherpa L2stream Log
    Sleep    10s
    Stop Sherpa L2stream Log    ${OUTPUT_DIR}
    Convert Pcap To Sherpa Csv    ${OUTPUT_DIR}

Small Case For Catch Sherpa Log Continuously
    [Tags]    case2
    Start Sherpa L2stream Log
    Wait Until User Manually Delete Stop Case File
    Stop Sherpa L2stream Log    ${OUTPUT_DIR}
    Convert Pcap To Sherpa Csv    ${OUTPUT_DIR}

*** Keywords ***

