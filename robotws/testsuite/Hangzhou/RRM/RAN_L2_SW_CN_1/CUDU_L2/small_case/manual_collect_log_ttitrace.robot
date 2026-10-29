*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
#Suite Setup    Run    sh /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ttitrace.sh
Resource    ./../common_setup_teardown.robot
*** Variables ***
${LOG}    syslog,tti,sherpa,bip,sosreport,apbip,
${LOG_PATH}    ${OUTPUT_DIR}/mylog/
${STOP_CASE_FILE}    ${CURDIR}/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Catch Ttitrace Log
    [Tags]    case1
    Start Ttitrace With Streaming Mode
    Sleep    1s
    Stop Ttitrace
    Decode Ttitrace Log

Small Case For Catch Ttitrace Log for 2 times
    [Tags]    case3
    Setup Ttitrace
    Begin Ttitrace
    Sleep    1s
    End Ttitrace    log_dir=${OUTPUT_DIR}/ttitrace_streaming1/
    Sleep    1s
    Begin Ttitrace
    Sleep    1s
    End Ttitrace    log_dir=${OUTPUT_DIR}/ttitrace_streaming2/
    Teardown Ttitrace
    #Decode Ttitrace Log

Small Case Test For Different Module
    [Tags]    case4
    Setup Ttitrace
    Begin Ttitrace
    Sleep    1s
    End Ttitrace    log_dir=${OUTPUT_DIR}/ttitrace_streaming1/
    Sleep    1s
    Teardown Ttitrace
    Sleep    1s
    Setup Ttitrace For Only L2PS
    Begin Ttitrace
    Sleep    1s
    End Ttitrace    log_dir=${OUTPUT_DIR}/ttitrace_streaming2/
    #Teardown Ttitrace
    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming1/
    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming2/

Small Case For Setup Ttitrace With L2PS L2lo L2Hi
    [Tags]    setup_all
    Setup Ttitrace

Small Case For Setup Ttitrace With L2PS
    [Tags]    setup_l2ps
    Setup Ttitrace For Only L2PS

Small Case For Catch Ttitrace Log Continuously
    [Tags]    case2
    Start Ttitrace With Streaming Mode
    Wait Until User Manually Delete Stop Case File
    Stop Ttitrace
    Decode Ttitrace Log

*** Keywords ***
