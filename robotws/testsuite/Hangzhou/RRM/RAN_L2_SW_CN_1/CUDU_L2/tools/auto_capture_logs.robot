*** Settings ***
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
${FILE_PATH}        /home/ute/a
${log_type}      syslog,sherpa,ttitrace,bip,snapshot,egate_console,config
@{LOG_NAME_LIST}    btslog    cellsetup    #tShark    sherpa    snapShot    pmcounter
${TTITRACE_LOG}     no
${BIP_LOG}          no
${UTE_LOG}          no
*** Test Cases ***
Auto_Caputure_Logs
    Log To Console    \n Begin to start logs
    common_log_capture.Start Logs    ${LOG_NAME_LIST}    ${suite_log_directory}
    Log To Console    \n Start Logs done.
    Wait For Manual Case Step Done
    common_log_capture.Stop Logs    ${LOG_NAME_LIST}    ${suite_log_directory}
    Log To Console    \n start to getting WTS logs
    Run Keyword If    '${TTITRACE_LOG}'=='yes'    Capture And Format TTiTrace Log 2s
    Run Keyword If    '${BIP_LOG}'=='yes'    Capture BIP Log 2s
    Run Keyword If    '${UTE_LOG}'=='yes'    Collect UTE Files    ${suite_log_directory}
    Run Keyword And Ignore Error    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${suite_log_directory}
    Log To Console    \n get log done.

*** Keywords ***
Suite Prepare
    Run And Return Rc And Output    rm -rf ${FILE_PATH}
    ${status}    Run Keyword And Ignore Error    Check OnAir And Cell Setup
    Run Keyword If    '${status[0]}'=='PASS'    Create Log Directory And Get Version
    Run Keyword If    '${status[0]}'=='FAIL'    Make Gnb OnAir With QT Config

Check OnAir And Cell Setup
    Verify BTS Is OnAir
    Verify Cell Setup

Create Log Directory And Get Version
    Create Suite Directory
    Log To Console    \n ##################################
    Get Software Version
    Get WTS Version
    Log To Console    \n ##################################

Make Gnb OnAir With QT Config
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    ${status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
    Run Keyword If    '${status[0]}'=='FAIL'    Run Keywords    Reboot TL And Check Configured
    ...    AND    Suite Setup Start WTS And Check OnAir

Wait For Manual Case Step Done
    Log To Console    \n ###########################################
    Log To Console    Please execute "touch ${FILE_PATH}" command in another windows after finish your case to capture logs.
    Wait Until Created    path=${FILE_PATH}    timeout=60m
    Log To Console    \n ###########################################
    Log To Console    \n start to getting logs

Zip Log
    Log To Console    \n ###########################################
    Remove File    path=${FILE_PATH}
    @{log_dir_split}    Split String    ${suite_log_directory}    /
    ${zip_dir}    Evaluate    "/".join(${log_dir_split[:-1]})
    Run Keyword And Ignore Error    Process.Run Process    zip -q -r ${suite_log_directory}.zip ${log_dir_split[-1]}
    ...    shell=True    cwd=${zip_dir}
    Log To Console    \n ###########################################
    Log To Console    \n All logs: ${suite_log_directory}.zip

Capture And Format TTiTrace Log 2s
    Backup Scf    ${output_dir}    before_suite
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
    Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
    Process.Run Process    cp ${output_dir}/ttitrace_streaming/ ${suite_log_directory}/ttitrace_streaming

Capture BIP Log 2s
    Start Gnb BIP Log
    Sleep    2s    reason=Capture BIP Log
    Stop Gnb BIP Log    ${suite_log_directory}
