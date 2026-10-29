*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Blazej Michalik
...             :contact: blazej.michalik@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot

Library     DateTime
Library     OperatingSystem
Library     ta5g_testline_management
Library     ta5g_iphy
Library     ta5g_enb
Library     testsuite/Wroclaw/RRM/WRO_2/resources/common_functions.py

Variables    ta5g_global_var


*** Variables ***
@{SWCONFIG_FLAGS_LIST}=         ${ENABLE_CP_RT_DEBUG_LOGS}    ${ENABLE_CP_NRT_DEBUG_LOGS}
${ENABLE_CP_RT_DEBUG_LOGS}=     0x590072=1 #ENABLE CP_RT DEBUG LOGS'
${ENABLE_CP_NRT_DEBUG_LOGS}=    0x41001b=1 #ENABLE CP_NRT DEBUG LOGS'

*** Test Cases ***
Activate CPRT CPNRT logging
    Run Keywords    Log To Console    Setup started
    ...        AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
    ...        AND             Activate CPRT Trace Logging Level
    ...        AND             Reboot Gnb and Airphone
    ...        AND             Wait For Testline Icmp Echo Replies And Ssh Services

Start_logging
    [Setup]    Run Keywords    Log To Console    Setup logging
    ...        AND             Start Default Logging

    Pause Execution Till Enter

    [Teardown]    Run Keywords        Log To Console    Teardown logging
    ...        AND                    Stop Default Logging

Additional_logs
    Collect Wts Sim Logs
    Collect Bts Snapshot
    Collect Airphone Snapshot
    Collect Sos Report
    Collect Other Debug logs

*** Keywords ***
Collect Airphone Snapshot
    Run Keyword And Continue On Failure    Get Iphy Snapshot

Collect Bts Snapshot
    ${date}=    Get Current Date    result_format=%Y%m%d-%H%M
    ${filename}=    Catenate    SEPARATOR=    BTS_snapshot_    ${date}    .zip   # Filename should be BTS_snapshot_YYYYMMDD-HHMM.zip
    ${filepath}=    Join Path    ${OUTPUT_DIR}    ${filename}
    Run Keyword And Continue On Failure    Get Bts Snapshot    ${filepath}
