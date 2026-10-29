*** Settings ***
Documentation    This Suite Is showing the possibility for alarm history analysis with
...              with help of taf.ul.log_collection

Library    taf.ul.log_collection
Resource       ../testline.robot
Library    OperatingSystem
Library    ../python/snapshot_helper.py
Library    ../python/alarm_parser.py

*** Variables ***
${ALARM_WHITE_LIST}    ${EMPTY}


*** Test Cases ***
Collect Classical Snapshot
    ${config_string}=    Catenate    {"SyslogLog"     : {"type": "syslog"},
    ...                               "GnbSnapshot"   : {"type": "snapshot"},
    ...                               "SnapshotLogs"  : {"type": "group",
    ...                                                  "members": "GnbSnapshot"}}

    ${log_configuration}=    Evaluate   ${config_string}
    ${target_dir}   testline.Get Testcase Log Directory

    taf.ul.log_collection.Create Collectors Using Testline Information    names=SnapshotLogs
    ...                                                                   configuration=${log_configuration}
    ...                                                                   network_elements=gnb_0

    taf.ul.log_collection.Setup Collectors     names=SnapshotLogs
    taf.ul.log_collection.Collect Collectors   names=SnapshotLogs    target_dir=${target_dir}
    taf.ul.log_collection.Teardown Collectors  names=SnapshotLogs


    ${snapshot_files}=   taf.ul.log_collection.Get Log File   log_type=snapshot   network_element=gnb_0    target_dir=${target_dir}
    FOR   ${snapshot_file}   IN   @{snapshot_files}
        OperatingSystem.File Should Exist           ${snapshot_file}
        OperatingSystem.File Should Not Be Empty    ${snapshot_file}
        Analyse Alarm History From Snapshot    ${snapshot_file}
    END


*** Keywords ***
Analyse Alarm History From Snapshot
    [Arguments]   ${snapshot_file}
    Log To Console     Analysing Alarm History from Snapshot file ${snapshot_file}
    ${raw_alarm_history}   snapshot_helper.Extract Raw Alarm History    ${snapshot_file}

    Log To Console    Extracted Raw Alarm History File: ${raw_alarm_history}

    No Alarm Should Be Present    filename=${raw_alarm_history}
    ...                           whitelist_ids=${ALARM_WHITE_LIST}
