*** Settings ***
Force Tags    PY36
Documentation    This case is a tool for capture logs automatically
...              \n Author : xiapzhan    xiaping.zhang@nokia-sbell.com
...              \n Arguments introduce:
...              \n FILE_PATH: the file path is used to create to start capture logs when finish munual testing. Do not modify this augument
...              \n LOG_NAME_LIST: list the log type which can be capture in this case. if you do not need some one log, just delete the log type
...              \n LOG_COLLECTOR_PATH:    the script path for capture WTS logs.
...              \n    for AirPhone env:    /home/ute/robotws5g/testsuite/AUTO/Wroclaw/basic_ap_test/sh/log_collector.sh
...              \n    for UTE env:    /home/ute/AUTO5g/testsuite/AUTO/Wroclaw/basic_ap_test/sh/log_collector.sh
...              \n library need to pay attention:
...              \n    1. taf.gnb.oam.coam.admin>= 2.2.0
...              \n excute command:    e.g.
...              \n pybot -V /home/ute/robotws5g/testsuite/RRM/ECE/Resource/robot/7_5_CLOUD402TET411/ -b debug.log
...              -d result_zxp /home/ute/robotws5g/testsuite/RRM/ECE/Resource/robot/auto_capture_logs.robot
Resource         ./../common_setup_teardown.robot
Suite Setup      Suite Prepare
Test Teardown    Zip Log

*** Variables ***
${FILE_PATH}             /home/ute/a
@{LOG_NAME_LIST}         btslog    tShark    sherpa    snapShot    pmcounter    #tcpdump

*** Test Cases ***
Auto_Caputure_Logs
    Log To Console    \n Begin to start logs
    common_log_capture.Start Logs    ${LOG_NAME_LIST}
    Log To Console    \n Start Logs done.
    Wait For Manual Case Step Done
    common_log_capture.Stop Logs    ${LOG_NAME_LIST}    ${SUITE_LOG_DIRECTORY}
    Log To Console    \n start to getting WTS logs
    Collect UTE Logs    ${SUITE_LOG_DIRECTORY}
    Log To Console    \n get log done.

*** Keywords ***
Suite Prepare
    run and return rc and output    rm -rf ${FILE_PATH}
    ${status}    Run Keyword And Ignore Error    Check onAir and cell Setup
    Run Keyword If    '${status[0]}'=='PASS'    Create Log Directory and Get Version
    Run Keyword If    '${status[0]}'=='FAIL'    Make Gnb onAir with QT config


Check onAir and cell Setup
    Verify BTS Is OnAir
    Verify Cell Setup

Create Log Directory and Get Version
    Create Suite Directory
    Log To Console    \n ##################################
    Get Software Version
    Get WTS Version
    Log To Console    \n ##################################

Make Gnb onAir with QT config
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    ${status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
    Run Keyword If    '${status[0]}'=='FAIL'    Run Keywords    Reboot TL And Check Configured
    ...                                         AND    Suite Setup Start WTS And Check OnAir

Wait For Manual Case Step Done
    Log To Console    \n ###########################################
    Log To Console    Please execute "touch ${FILE_PATH}" command in another windows after finish your case to capture logs.
    Wait Until Created    path=${FILE_PATH}    timeout=60m
    Log To Console    \n ###########################################
    Log To Console    \n start to getting logs

Zip Log
    Log To Console    \n ###########################################
    Remove File    path=${FILE_PATH}
    @{log_dir_split}    Split String    ${SUITE_LOG_DIRECTORY}    /
    ${zip_dir}    Evaluate    "/".join(${log_dir_split[:-1]})
    Run Keyword And Ignore Error    Process.Run Process    zip -q -r ${SUITE_LOG_DIRECTORY}.zip ${log_dir_split[-1]}
    ...    shell=True    cwd=${zip_dir}
    Log To Console    \n ###########################################
    Log To Console    \n All logs: ${SUITE_LOG_DIRECTORY}.zip
